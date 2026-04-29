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

def _build_url(role: str) -> URL:
    return URL(
        account=config.SF_ACCOUNT,
        user=config.SF_USER,
        password=config.SF_PASSWORD,
        database=config.SF_DATABASE,
        schema=config.SF_SCHEMA,
        warehouse=config.SF_WAREHOUSE,
        role=role,
    )


_readonly_engine: Engine | None = None
_write_engine: Engine | None = None


def get_readonly_engine() -> Engine:
    """Engine for the Analyst — enforces read-only via role and event listener."""
    global _readonly_engine
    if _readonly_engine is None:
        _readonly_engine = create_engine(
            _build_url(config.SF_ROLE_ANALYST),
            pool_pre_ping=True,
        )
        
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
    """Engine for the Engineer — can write to the dash schema."""
    global _write_engine
    if _write_engine is None:
        _write_engine = create_engine(
            _build_url(config.SF_ROLE_ENGINEER),
            pool_pre_ping=True,
        )
        
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
