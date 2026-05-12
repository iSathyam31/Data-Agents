"""Snowflake connection factory — read-only for Analyst, scoped for Engineer."""

import logging
from snowflake.sqlalchemy import URL
from sqlalchemy import create_engine, text, pool
import config

logger = logging.getLogger("dash.db")


def _build_url(**overrides) -> str:
    params = dict(
        account=config.SNOWFLAKE_ACCOUNT,
        user=config.SNOWFLAKE_USER,
        password=config.SNOWFLAKE_PASSWORD,
        database=config.SNOWFLAKE_DATABASE,
        schema=config.SNOWFLAKE_SCHEMA,
        warehouse=config.SNOWFLAKE_WAREHOUSE,
        role=config.SNOWFLAKE_ROLE,
    )
    params.update(overrides)
    return URL(**params)


# ── Singleton engines — created once, reused across all queries ───────────────
_readonly_engine = None
_dash_engine = None


def get_readonly_engine():
    """Engine for the Analyst — persistent connection pool with DASH_ANALYST role."""
    global _readonly_engine
    if _readonly_engine is None:
        logger.info("Creating persistent read-only engine (DASH_ANALYST)")
        _readonly_engine = create_engine(
            _build_url(role="DASH_ANALYST"),
            connect_args={"session_parameters": {"QUERY_TAG": "dash-analyst"}},
            pool_size=2,
            max_overflow=3,
            pool_pre_ping=True,
            pool_recycle=3600,
        )
    return _readonly_engine


def get_dash_engine():
    """Engine for the Engineer — persistent connection pool with DASH_ENGINEER role."""
    global _dash_engine
    if _dash_engine is None:
        logger.info("Creating persistent write engine (DASH_ENGINEER)")
        _dash_engine = create_engine(
            _build_url(role="DASH_ENGINEER", database="DASH_DB", schema="DASH"),
            connect_args={"session_parameters": {"QUERY_TAG": "dash-engineer"}},
            pool_size=1,
            max_overflow=1,
            pool_pre_ping=True,
            pool_recycle=3600,
        )
    return _dash_engine


def execute_readonly(sql: str, params: dict | None = None) -> list[dict]:
    """Run a read-only query and return results as list of dicts."""
    engine = get_readonly_engine()
    with engine.connect() as conn:
        result = conn.execute(text(sql), params or {})
        columns = list(result.keys())
        rows = [dict(zip(columns, row)) for row in result.fetchmany(config.MAX_RESULT_ROWS)]
    return rows


def execute_write(sql: str, params: dict | None = None) -> str:
    """Run a write query on the DASH schema. Returns status message."""
    engine = get_dash_engine()
    with engine.connect() as conn:
        conn.execute(text(sql), params or {})
        conn.commit()
    return "Query executed successfully."


def get_explain_estimate(sql: str) -> dict:
    """Use EXPLAIN to estimate query cost before execution."""
    engine = get_readonly_engine()
    try:
        with engine.connect() as conn:
            result = conn.execute(text(f"EXPLAIN USING JSON {sql}"))
            row = result.fetchone()
            if row:
                import json
                plan = json.loads(row[0]) if isinstance(row[0], str) else row[0]
                return {
                    "plan": plan,
                    "estimated": True,
                }
    except Exception as e:
        return {"error": str(e), "estimated": False}
    return {"estimated": False}
