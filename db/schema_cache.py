"""One-time schema introspection — cache INFORMATION_SCHEMA locally to avoid repeated Snowflake queries."""

import json
import os
from pathlib import Path
from db import execute_readonly
import config

CACHE_FILE = os.path.join(os.path.dirname(__file__), "..", "schema_cache.json")

# ── In-memory cache ──────────────────────────────────────────────
_schema_mem: dict | None = None


def fetch_and_cache_schema() -> dict:
    """Query INFORMATION_SCHEMA once and cache to JSON file."""
    tables_sql = f"""
    SELECT TABLE_NAME, TABLE_TYPE, ROW_COUNT, BYTES
    FROM {config.SNOWFLAKE_DATABASE}.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{config.SNOWFLAKE_SCHEMA}'
    ORDER BY TABLE_NAME
    """
    tables = execute_readonly(tables_sql)

    columns_sql = f"""
    SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE, 
           COLUMN_DEFAULT, ORDINAL_POSITION, CHARACTER_MAXIMUM_LENGTH,
           NUMERIC_PRECISION, NUMERIC_SCALE
    FROM {config.SNOWFLAKE_DATABASE}.INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{config.SNOWFLAKE_SCHEMA}'
    ORDER BY TABLE_NAME, ORDINAL_POSITION
    """
    columns = execute_readonly(columns_sql)

    # Normalize keys to uppercase (Snowflake/SQLAlchemy may return lowercase)
    tables = [{k.upper(): v for k, v in row.items()} for row in tables]
    columns = [{k.upper(): v for k, v in row.items()} for row in columns]

    # Group columns by table
    schema = {}
    for t in tables:
        tname = t["TABLE_NAME"]
        schema[tname] = {
            "table_name": tname,
            "table_type": t.get("TABLE_TYPE", ""),
            "row_count": t.get("ROW_COUNT"),
            "bytes": t.get("BYTES"),
            "columns": [],
        }

    for c in columns:
        tname = c["TABLE_NAME"]
        if tname in schema:
            schema[tname]["columns"].append({
                "name": c["COLUMN_NAME"],
                "type": c["DATA_TYPE"],
                "nullable": c["IS_NULLABLE"],
                "position": c["ORDINAL_POSITION"],
            })

    # Write cache
    Path(CACHE_FILE).parent.mkdir(parents=True, exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        json.dump(schema, f, indent=2, default=str)

    global _schema_mem
    _schema_mem = schema
    return schema


def load_cached_schema() -> dict:
    """Load schema from cache file. Returns empty dict if not cached yet."""
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE, "r") as f:
            return json.load(f)
    return {}


def get_schema(force_refresh: bool = False) -> dict:
    """Get schema — from memory, then disk cache, otherwise fetch from Snowflake."""
    global _schema_mem
    if force_refresh:
        return fetch_and_cache_schema()
    if _schema_mem is not None:
        return _schema_mem
    if os.path.exists(CACHE_FILE):
        _schema_mem = load_cached_schema()
        return _schema_mem
    return fetch_and_cache_schema()


def get_table_names() -> list[str]:
    """Return list of all table names in the schema."""
    schema = get_schema()
    return sorted(schema.keys())


def get_table_ddl(table_name: str) -> str:
    """Return a readable DDL-like string for a table from the cache."""
    schema = get_schema()
    table = schema.get(table_name.upper())
    if not table:
        return f"Table {table_name} not found in schema cache."
    lines = [f"-- {table['table_name']} (rows: {table.get('row_count', 'N/A')})"]
    for col in table["columns"]:
        nullable = "NULL" if col["nullable"] == "YES" else "NOT NULL"
        lines.append(f"  {col['name']} {col['type']} {nullable}")
    return "\n".join(lines)
