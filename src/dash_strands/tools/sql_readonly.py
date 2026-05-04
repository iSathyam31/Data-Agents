"""Tool: Execute read-only SQL queries (for the Analyst)."""

import re

from strands import tool
from sqlalchemy import text

from dash_strands import config
from dash_strands.db import get_readonly_engine

# TPC-DS fact tables that are too large to scan without a date dimension filter.
# Each has billions of rows at SF100TCL scale.
_LARGE_FACT_TABLES = {
    "STORE_SALES",       # ~300B rows
    "STORE_RETURNS",     # ~87B rows
    "CATALOG_SALES",     # ~143B rows
    "CATALOG_RETURNS",   # ~43B rows
    "WEB_SALES",         # ~72B rows
    "WEB_RETURNS",       # ~21B rows
    "INVENTORY",         # ~1.3B rows
}

# Date-related tokens that indicate a safe filter is present
_DATE_FILTER_TOKENS = re.compile(
    r"\b(D_YEAR|D_DATE|D_MON|D_QOY|D_WEEK_SEQ|DATE_DIM|SS_SOLD_DATE_SK"
    r"|CS_SOLD_DATE_SK|WS_SOLD_DATE_SK|SR_RETURNED_DATE_SK"
    r"|CR_RETURNED_DATE_SK|WR_RETURNED_DATE_SK|INV_DATE_SK)\b",
    re.IGNORECASE,
)


def _check_query_safety(sql: str) -> str | None:
    """Return an error string if the query would cause a full scan of a large fact table.

    Returns None if the query looks safe.
    """
    sql_upper = sql.upper()
    # Detect which large fact tables are referenced
    referenced = [t for t in _LARGE_FACT_TABLES if re.search(r"\b" + t + r"\b", sql_upper)]
    if not referenced:
        return None  # No large fact tables — safe
    # Querying DASH_AGENT.dash.* views — always safe (pre-aggregated)
    if "DASH_AGENT.DASH." in sql_upper or "dash." in sql.lower():
        return None

    # Check for a date filter token
    if _DATE_FILTER_TOKENS.search(sql):
        return None  # Date filter present — safe

    tables_str = ", ".join(referenced)
    return (
        f"QUERY BLOCKED — missing date filter.\n\n"
        f"The query references large fact table(s): {tables_str}\n"
        f"At TPC-DS SF100TCL scale these tables contain billions of rows. "
        f"Without a date filter (join DATE_DIM and filter D_YEAR) this query "
        f"would time out or scan terabytes of data.\n\n"
        f"Fix: Join DATE_DIM on the fact table's date SK column and add a year "
        f"or date range filter. Example pattern:\n"
        f"  JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d "
        f"ON <fact_table>.< date_sk_col> = d.D_DATE_SK\n"
        f"  WHERE d.D_YEAR = <year>  -- or D_YEAR BETWEEN <start> AND <end>\n\n"
        f"Alternatively, ask the Engineer to create a dash.* pre-aggregated "
        f"view so this question can be answered from a small summary table."
    )


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
        # Pre-flight: block full scans of large fact tables before hitting Snowflake
        safety_error = _check_query_safety(sql)
        if safety_error:
            return safety_error

        with engine.connect() as conn:
            # Guarantee warehouse is active on this connection
            conn.execute(text(f"USE WAREHOUSE {config.SF_WAREHOUSE}"))
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
