"""Tool: Inspect database schema (tables, columns, types)."""

from strands import tool
from sqlalchemy import text

from dash_strands import config
from dash_strands.db import get_readonly_engine


@tool
def list_schemas() -> str:
    """List all available schemas in the database.

    Returns:
        List of schema names.
    """
    engine = get_readonly_engine()
    try:
        with engine.connect() as conn:
            result = conn.execute(text(
                "SELECT schema_name FROM information_schema.schemata "
                "WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast') "
                "ORDER BY schema_name"
            ))
            schemas = [row[0] for row in result]
            return "Schemas: " + ", ".join(schemas)
    except Exception as e:
        return f"Error: {e}"


@tool
def list_tables(schema_name: str = "TPCDS_SF100TCL") -> str:
    """List all tables and views in a given schema.

    Args:
        schema_name: Schema name to inspect. Defaults to 'TPCDS_SF100TCL'.

    Returns:
        List of tables/views with their types.
    """
    engine = get_readonly_engine()
    try:
        with engine.connect() as conn:
            result = conn.execute(text(
                "SELECT table_name, table_type "
                "FROM information_schema.tables "
                "WHERE table_schema ILIKE :schema "
                "ORDER BY table_type, table_name"
            ), {"schema": schema_name})
            rows = result.fetchall()
            if not rows:
                return f"No tables found in schema '{schema_name}'."
            lines = [f"  {name} ({ttype})" for name, ttype in rows]
            return f"Tables in '{schema_name}':\n" + "\n".join(lines)
    except Exception as e:
        return f"Error: {e}"


@tool
def describe_table(table_name: str, schema_name: str = "TPCDS_SF100TCL") -> str:
    """Get column details for a specific table.

    Args:
        table_name: Name of the table to describe.
        schema_name: Schema the table belongs to. Defaults to 'TPCDS_SF100TCL'.

    Returns:
        Column names, types, and nullable info.
    """
    engine = get_readonly_engine()
    try:
        with engine.connect() as conn:
            result = conn.execute(text(
                "SELECT column_name, data_type, is_nullable, column_default "
                "FROM information_schema.columns "
                "WHERE table_schema ILIKE :schema AND table_name ILIKE :table "
                "ORDER BY ordinal_position"
            ), {"schema": schema_name, "table": table_name})
            rows = result.fetchall()
            if not rows:
                return f"Table '{schema_name}.{table_name}' not found."
            lines = []
            for col, dtype, nullable, default in rows:
                parts = [f"  {col}: {dtype}"]
                if nullable == "NO":
                    parts.append("NOT NULL")
                if default:
                    parts.append(f"DEFAULT {default}")
                lines.append(" ".join(parts))
            return f"Columns in {schema_name}.{table_name}:\n" + "\n".join(lines)
    except Exception as e:
        return f"Error: {e}"
