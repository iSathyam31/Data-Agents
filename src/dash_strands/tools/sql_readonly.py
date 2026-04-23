"""Tool: Execute read-only SQL queries (for the Analyst)."""

from strands import tool
from sqlalchemy import text

from dash_strands.db import get_readonly_engine


@tool
def execute_sql_readonly(sql: str) -> str:
    """Execute a read-only SQL query against the database and return results.

    This tool has READ-ONLY access enforced at the database level.
    Any write operations (INSERT, UPDATE, DELETE, DROP, etc.) will be rejected by the database.

    Args:
        sql: The SQL query to execute. Must be a SELECT or other read-only statement.

    Returns:
        Query results formatted as a text table, or an error message.
    """
    engine = get_readonly_engine()
    try:
        with engine.connect() as conn:
            result = conn.execute(text(sql))
            columns = list(result.keys())
            rows = result.fetchmany(100)  # Limit to 100 rows

            if not rows:
                return "Query returned no results."

            # Format as a readable table
            col_widths = [len(str(c)) for c in columns]
            for row in rows:
                for i, val in enumerate(row):
                    col_widths[i] = max(col_widths[i], len(str(val)))

            header = " | ".join(str(c).ljust(col_widths[i]) for i, c in enumerate(columns))
            separator = "-+-".join("-" * w for w in col_widths)
            data_rows = []
            for row in rows:
                data_rows.append(" | ".join(str(v).ljust(col_widths[i]) for i, v in enumerate(row)))

            table = f"{header}\n{separator}\n" + "\n".join(data_rows)
            row_count = len(rows)
            suffix = f"\n\n({row_count} row{'s' if row_count != 1 else ''} returned)"
            if row_count == 100:
                suffix += " — results truncated at 100 rows"
            return table + suffix
    except Exception as e:
        return f"SQL Error: {e}"
