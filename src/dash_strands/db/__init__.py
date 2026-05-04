"""Database connection factories using SQLAlchemy."""

import re
from sqlalchemy import create_engine, text, event
from sqlalchemy.engine import Engine
from snowflake.sqlalchemy import URL

from dash_strands import config

# Patterns that target schemas other than 'dash'
_BLOCKED_PATTERNS = [
    re.compile(r"\b(DROP|ALTER|TRUNCATE|DELETE|INSERT|UPDATE|CREATE)\b.*\b" + config.DATA_SCHEMA + r"\.", re.IGNORECASE),
    re.compile(r"\b(DROP|ALTER|TRUNCATE|DELETE|INSERT|UPDATE|CREATE)\b.*\bpublic\.", re.IGNORECASE),
    re.compile(r"\bDROP\s+SCHEMA\b", re.IGNORECASE),
]

# Patterns that are entirely blocked for read-only access
_ALL_WRITE_PATTERNS = [
    re.compile(r"\b(DROP|ALTER|TRUNCATE|DELETE|INSERT|UPDATE|CREATE)\b", re.IGNORECASE),
]

def _build_read_url() -> URL:
    """URL for the Analyst: read-only access to the source TPC-DS data."""
    return URL(
        account=config.SF_ACCOUNT,
        user=config.SF_USER,
        password=config.SF_PASSWORD,
        database=config.SF_DATABASE,
        schema=config.SF_SCHEMA,
        warehouse=config.SF_WAREHOUSE,
        role=config.SF_ROLE_ANALYST,
    )


def _build_write_url() -> URL:
    """URL for the Engineer: full access to the DASH_AGENT.dash schema."""
    return URL(
        account=config.SF_ACCOUNT,
        user=config.SF_USER,
        password=config.SF_PASSWORD,
        database=config.SF_DASH_DATABASE,
        schema=config.DASH_SCHEMA,
        warehouse=config.SF_WAREHOUSE,
        role=config.SF_ROLE_ENGINEER,
    )


def _add_session_init(engine: Engine, database: str, schema: str) -> None:
    """Ensure every new connection sets the correct database, schema, and warehouse."""
    @event.listens_for(engine, "connect")
    def set_session_context(dbapi_conn, connection_record):
        try:
            cursor = dbapi_conn.cursor()
            cursor.execute(f"USE DATABASE {database}")
            cursor.execute(f"USE SCHEMA {database}.{schema}")
            cursor.execute(f"USE WAREHOUSE {config.SF_WAREHOUSE}")
            cursor.close()
        except Exception:
            pass  # URL already sets these; failure here is non-fatal


_readonly_engine: Engine | None = None
_write_engine: Engine | None = None


def get_readonly_engine() -> Engine:
    """Engine for the Analyst — enforces read-only via role and event listener."""
    global _readonly_engine
    if _readonly_engine is None:
        _readonly_engine = create_engine(
            _build_read_url(),
            connect_args={
                "session_parameters": {
                    "QUERY_TAG": "dash_analyst",
                    "STATEMENT_TIMEOUT_IN_SECONDS": "120",  # kill after 2 min
                    "LOCK_TIMEOUT": "30",
                }
            },
            pool_pre_ping=True,
        )
        _add_session_init(_readonly_engine, config.SF_DATABASE, config.SF_SCHEMA)

        @event.listens_for(_readonly_engine, "before_cursor_execute")
        def intercept_query_readonly(conn, cursor, statement, parameters, context, executemany):
            """Block all writes for the Analyst engine as a double safeguard."""
            for pattern in _ALL_WRITE_PATTERNS:
                if pattern.search(statement):
                    raise ValueError(
                        "BLOCKED: This engine is strictly READ-ONLY. "
                        "You cannot execute DDL or DML statements."
                    )
    return _readonly_engine


def get_write_engine() -> Engine:
    """Engine for the Engineer — can write to the dash schema in DASH_AGENT."""
    global _write_engine
    if _write_engine is None:
        _write_engine = create_engine(
            _build_write_url(),
            connect_args={
                "session_parameters": {
                    "QUERY_TAG": "dash_engineer",
                    "STATEMENT_TIMEOUT_IN_SECONDS": "300",  # 5 min for CREATE VIEW
                    "LOCK_TIMEOUT": "30",
                }
            },
            pool_pre_ping=True,
        )
        _add_session_init(_write_engine, config.SF_DASH_DATABASE, config.DASH_SCHEMA)

        @event.listens_for(_write_engine, "before_cursor_execute")
        def intercept_query(conn, cursor, statement, parameters, context, executemany):
            """Block writes to the main data and public schemas."""
            for pattern in _BLOCKED_PATTERNS:
                if pattern.search(statement):
                    raise ValueError(
                        f"BLOCKED: This statement appears to modify the '{config.DATA_SCHEMA}' or 'public' schema. "
                        "You can only create/modify objects in the 'dash' schema. "
                        "Use 'dash.' prefix for all DDL/DML statements."
                    )

    return _write_engine
