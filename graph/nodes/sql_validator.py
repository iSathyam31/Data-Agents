"""SQL Validator node — parse and verify SQL before execution."""

import re
import logging
from graph.state import DashState
import config

logger = logging.getLogger("dash.sql_validator")

# Forbidden operations for the analyst path
_FORBIDDEN_PATTERNS = [
    r'\bDROP\b', r'\bDELETE\b', r'\bTRUNCATE\b', r'\bALTER\b',
    r'\bINSERT\b', r'\bUPDATE\b', r'\bCREATE\b', r'\bGRANT\b',
    r'\bREVOKE\b', r'\bMERGE\b',
]

_FORBIDDEN_RE = re.compile("|".join(_FORBIDDEN_PATTERNS), re.IGNORECASE)


def sql_validator(state: DashState) -> dict:
    """Validate generated SQL before execution."""
    sql = state.get("generated_sql", "")
    errors = []
    warnings = []

    if not sql.strip():
        errors.append("Empty SQL generated.")
        return {"validation_result": {"valid": False, "errors": errors, "warnings": warnings}}

    # 1. Check for forbidden operations (analyst is read-only)
    if state.get("current_agent") == "analyst":
        forbidden_matches = _FORBIDDEN_RE.findall(sql)
        if forbidden_matches:
            errors.append(f"Forbidden operations detected: {', '.join(set(forbidden_matches))}. Analyst is read-only.")

    # 2. Check for SELECT *
    if re.search(r'\bSELECT\s+\*', sql, re.IGNORECASE):
        warnings.append("SELECT * detected — this can be very expensive on large tables. Consider specifying columns.")

    # 3. Check for LIMIT clause
    if not re.search(r'\bLIMIT\b', sql, re.IGNORECASE):
        warnings.append(f"No LIMIT clause. Adding LIMIT {config.MAX_RESULT_ROWS} for safety.")
        sql = sql.rstrip().rstrip(';') + f"\nLIMIT {config.MAX_RESULT_ROWS};"

    # 4. Check for date filter on fact tables
    fact_tables = ['STORE_SALES', 'CATALOG_SALES', 'WEB_SALES', 'STORE_RETURNS',
                   'CATALOG_RETURNS', 'WEB_RETURNS', 'INVENTORY']
    uses_fact_table = any(ft in sql.upper() for ft in fact_tables)
    has_date_filter = 'D_YEAR' in sql.upper() or 'D_DATE' in sql.upper() or 'DATE_DIM' in sql.upper()

    if uses_fact_table and not has_date_filter:
        warnings.append("Query uses fact tables without a DATE_DIM filter. This could scan hundreds of billions of rows!")

    # 5. Check fully qualified table names
    db_upper = config.SNOWFLAKE_DATABASE.upper()
    schema_upper = config.SNOWFLAKE_SCHEMA.upper()
    if db_upper not in sql.upper() and schema_upper not in sql.upper():
        warnings.append(f"Table names may not be fully qualified. Use {config.SNOWFLAKE_DATABASE}.{config.SNOWFLAKE_SCHEMA}.<TABLE>.")

    valid = len(errors) == 0

    logger.info("\n%s", "-" * 60)
    logger.info("NODE: SQL Validator")
    logger.info("Valid: %s", valid)
    if errors:
        logger.warning("Errors: %s", errors)
    if warnings:
        logger.warning("Warnings: %s", warnings)
    logger.info("%s", "-" * 60)

    return {
        "generated_sql": sql,  # May have been modified (LIMIT added)
        "validation_result": {"valid": valid, "errors": errors, "warnings": warnings},
    }
