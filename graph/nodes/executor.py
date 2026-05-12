"""SQL Executor node — runs validated SQL on Snowflake."""

import logging
from graph.state import DashState
from db import execute_readonly

logger = logging.getLogger("dash.executor")


def executor(state: DashState) -> dict:
    """Execute the validated SQL query on Snowflake (read-only)."""
    sql = state.get("generated_sql", "")
    validation = state.get("validation_result", {})

    if not validation.get("valid", False):
        return {
            "sql_error": f"Validation failed: {'; '.join(validation.get('errors', []))}",
            "sql_result": None,
        }

    try:
        rows = execute_readonly(sql)
        columns = list(rows[0].keys()) if rows else []
        logger.info("\n%s", "-" * 60)
        logger.info("NODE: Executor")
        logger.info("Rows returned: %d", len(rows))
        logger.info("Columns: %s", columns)
        logger.info("%s", "-" * 60)
        return {
            "sql_result": {
                "columns": columns,
                "rows": rows,
                "row_count": len(rows),
            },
            "sql_error": None,
        }
    except Exception as e:
        error_msg = str(e)
        logger.error("\n%s", "-" * 60)
        logger.error("NODE: Executor — FAILED")
        logger.error("Error: %s", error_msg[:300])
        logger.error("%s", "-" * 60)
        # Truncate very long error messages
        if len(error_msg) > 500:
            error_msg = error_msg[:500] + "..."
        return {
            "sql_error": error_msg,
            "sql_result": None,
        }
