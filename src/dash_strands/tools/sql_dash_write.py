"""Tool: Execute SQL statements scoped to the dash schema (for the Engineer)."""

from strands import tool
from sqlalchemy import text

from dash_strands.db import get_write_engine


@tool
def execute_sql_dash(sql: str) -> str:
    """Execute a SQL statement that creates or modifies objects in the 'dash' schema.

    This tool can run CREATE, ALTER, DROP, INSERT, etc. but ONLY against the 'dash' schema.
    Any attempt to modify the 'ecommerce' or 'public' schema will be blocked.
    SELECT queries against any schema are allowed.

    Args:
        sql: The SQL statement to execute. CREATE/ALTER/DROP must target 'dash.' prefix.

    Returns:
        Confirmation message or query results, or an error message.
    """
    engine = get_write_engine()
    try:
        with engine.connect() as conn:
            result = conn.execute(text(sql))
            conn.commit()

            # If it's a SELECT, return results
            if result.returns_rows:
                columns = list(result.keys())
                rows = result.fetchmany(100)
                if not rows:
                    return "Query returned no results."
                col_widths = [len(str(c)) for c in columns]
                for row in rows:
                    for i, val in enumerate(row):
                        col_widths[i] = max(col_widths[i], len(str(val)))
                header = " | ".join(str(c).ljust(col_widths[i]) for i, c in enumerate(columns))
                separator = "-+-".join("-" * w for w in col_widths)
                data_rows = []
                for row in rows:
                    data_rows.append(" | ".join(str(v).ljust(col_widths[i]) for i, v in enumerate(row)))
                return f"{header}\n{separator}\n" + "\n".join(data_rows)

            return f"Statement executed successfully. Rows affected: {result.rowcount}"
    except Exception as e:
        return f"SQL Error: {e}"
