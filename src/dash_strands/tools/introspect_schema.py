"""Tool: Unified schema introspection — list tables or describe a specific table.

A single tool replaces the old list_schemas / list_tables / describe_table trio.
- action="list"     → lists tables in both schemas (source + dash) with row counts
- action="describe" → returns full column details for the named table

Source tables that exist in the local JSON knowledge files are described from those
files (fast, no Snowflake hit). Dash views are always described live from Snowflake.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path

from sqlalchemy import text
from strands import tool

from dash_strands import config
from dash_strands.db import get_readonly_engine

logger = logging.getLogger(__name__)

_SRC_DB = config.SF_DATABASE          # SNOWFLAKE_SAMPLE_DATA
_SRC_SCHEMA = config.SF_SCHEMA        # TPCDS_SF100TCL
_DASH_DB = config.SF_DASH_DATABASE    # DASH_AGENT
_DASH_SCHEMA = config.DASH_SCHEMA     # dash

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
_TABLES_DIR = _PROJECT_ROOT / "knowledge" / "tables"

# Lazy cache: table_name (upper) -> JSON dict
_TABLE_CACHE: dict[str, dict] = {}


def _load_table_cache() -> dict[str, dict]:
    global _TABLE_CACHE
    if _TABLE_CACHE:
        return _TABLE_CACHE
    if _TABLES_DIR.exists():
        for fp in _TABLES_DIR.glob("*.json"):
            try:
                with open(fp, encoding="utf-8") as f:
                    data = json.load(f)
                _TABLE_CACHE[data.get("table_name", fp.stem).upper()] = data
            except Exception as exc:
                logger.error("Failed to load %s: %s", fp, exc)
    return _TABLE_CACHE


def _describe_from_json(table_data: dict) -> str:
    """Format a table description from its JSON metadata."""
    name = table_data.get("table_name", "")
    full_ref = table_data.get("full_reference", "")
    description = table_data.get("table_description", "")
    columns = table_data.get("table_columns", [])
    dq_notes = table_data.get("data_quality_notes", [])

    lines = [f"## {name}", f"Full path: `{full_ref}`"]
    if description:
        lines.append(description)
    if columns:
        lines.append("\n**Columns:**")
        for col in columns:
            col_name = col.get("name", "")
            col_type = col.get("type", "")
            col_desc = col.get("description", "")
            lines.append(f"  - `{col_name}` ({col_type}): {col_desc}")
    if dq_notes:
        lines.append("\n**Data Quality Notes:**")
        for note in dq_notes:
            lines.append(f"  - {note}")
    return "\n".join(lines)


def _describe_from_snowflake(table_name: str, database: str, schema: str) -> str:
    """Query information_schema for column details (used for dash views)."""
    engine = get_readonly_engine()
    try:
        with engine.connect() as conn:
            conn.execute(text(f"USE WAREHOUSE {config.SF_WAREHOUSE}"))
            result = conn.execute(
                text(
                    "SELECT column_name, data_type, is_nullable "
                    f"FROM {database}.information_schema.columns "
                    "WHERE table_schema ILIKE :schema AND table_name ILIKE :table "
                    "ORDER BY ordinal_position"
                ),
                {"schema": schema, "table": table_name},
            )
            rows = result.fetchall()
            if not rows:
                return f"Table '{schema}.{table_name}' not found in {database}."
            lines = [f"## {schema}.{table_name} (from Snowflake)"]
            lines.append("**Columns:**")
            for col, dtype, nullable in rows:
                null_note = "" if nullable == "YES" else " NOT NULL"
                lines.append(f"  - `{col}` ({dtype}){null_note}")
            return "\n".join(lines)
    except Exception as exc:
        return f"Error describing {schema}.{table_name}: {exc}"


@tool
def introspect_schema(action: str = "list", table_name: str = "") -> str:
    """Inspect the database schema: list all tables or describe a specific table.

    Use action="list" to see all available tables in both schemas (source + dash)
    with approximate row counts. Use action="describe" to get full column details
    for a specific table or view.

    Source tables are described from embedded JSON metadata (fast, no Snowflake cost).
    Dash views are described live from Snowflake.

    Args:
        action: "list" to list all tables, "describe" to describe a specific table.
        table_name: Required when action="describe". The table or view name.
                    For source tables use just the name (e.g. "STORE_SALES").
                    For dash views use "dash.<name>" or just "<name>".

    Returns:
        Formatted schema information.
    """
    action = action.strip().lower()

    if action == "list":
        lines = [
            f"## Source Schema: `{_SRC_DB}.{_SRC_SCHEMA}`",
            "(Read-only TPC-DS SF100TCL — 100TB retail benchmark)\n",
        ]
        cache = _load_table_cache()
        if cache:
            for tname in sorted(cache):
                desc = cache[tname].get("table_description", "")[:100]
                lines.append(f"  - **{tname}**: {desc}")
        else:
            # Fallback: query Snowflake
            engine = get_readonly_engine()
            try:
                with engine.connect() as conn:
                    conn.execute(text(f"USE WAREHOUSE {config.SF_WAREHOUSE}"))
                    result = conn.execute(text(
                        f"SELECT table_name, row_count "
                        f"FROM {_SRC_DB}.information_schema.tables "
                        f"WHERE table_schema = '{_SRC_SCHEMA}' "
                        "ORDER BY table_name"
                    ))
                    for tname, row_count in result:
                        rc = f"{row_count:,}" if row_count else "unknown"
                        lines.append(f"  - {tname} (~{rc} rows)")
            except Exception as exc:
                lines.append(f"  (Error querying source schema: {exc})")

        lines.append(f"\n## Dash Schema: `{_DASH_DB}.{_DASH_SCHEMA}`")
        lines.append("(Agent-managed views — query these first for pre-aggregated data)\n")
        engine = get_readonly_engine()
        try:
            with engine.connect() as conn:
                conn.execute(text(f"USE WAREHOUSE {config.SF_WAREHOUSE}"))
                result = conn.execute(text(
                    "SELECT table_name, table_type "
                    f"FROM {_DASH_DB}.information_schema.tables "
                    f"WHERE table_schema ILIKE '{_DASH_SCHEMA.upper()}' "
                    "ORDER BY table_name"
                ))
                rows = result.fetchall()
                if rows:
                    for tname, ttype in rows:
                        lines.append(f"  - **DASH_AGENT.dash.{tname}** ({ttype})")
                else:
                    lines.append("  (No dash views created yet)")
        except Exception as exc:
            lines.append(f"  (Error querying dash schema: {exc})")

        return "\n".join(lines)

    elif action == "describe":
        if not table_name:
            return "Error: table_name is required for action='describe'."

        # Normalise: strip schema prefix to get bare name
        bare = table_name.upper().replace("DASH_AGENT.DASH.", "").replace("DASH.", "")
        bare_src = bare.replace(f"{_SRC_DB}.{_SRC_SCHEMA}.".upper(), "")

        # Check JSON cache for source tables
        cache = _load_table_cache()
        if bare_src in cache:
            return _describe_from_json(cache[bare_src])

        # Try dash schema in Snowflake
        result = _describe_from_snowflake(bare, _DASH_DB, _DASH_SCHEMA.upper())
        if "not found" not in result:
            return result

        # Try source schema in Snowflake as last resort
        return _describe_from_snowflake(bare_src, _SRC_DB, _SRC_SCHEMA.upper())

    else:
        return f"Unknown action '{action}'. Use 'list' or 'describe'."
