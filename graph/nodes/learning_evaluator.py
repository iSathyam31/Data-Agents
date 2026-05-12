"""Learning Evaluator node — decides whether to save learnings from the interaction."""

import logging
import uuid
from datetime import datetime, timezone
from graph.state import DashState

logger = logging.getLogger("dash.learning_evaluator")
from vectorstore import save_learning


def learning_evaluator(state: DashState) -> dict:
    """Evaluate whether this interaction produced a reusable learning."""
    sql_error = state.get("sql_error")
    retry_count = state.get("retry_count", 0)
    sql_result = state.get("sql_result")
    generated_sql = state.get("generated_sql", "")

    # Case 1: SQL error that was fixed (retry succeeded)
    if retry_count > 0 and sql_result and not sql_error:
        learning_text = (
            f"SQL error was auto-corrected after {retry_count} retries. "
            f"Final working SQL: {generated_sql[:500]}"
        )
        learning_id = f"learning-{uuid.uuid4().hex[:8]}"
        save_learning(
            learning_id=learning_id,
            text=learning_text,
            metadata={
                "type": "error_correction",
                "retry_count": retry_count,
                "created_at": datetime.now(timezone.utc).isoformat(),
            },
        )
        logger.info("\n%s", "-" * 60)
        logger.info("NODE: Learning Evaluator")
        logger.info("Saved error_correction learning: %s", learning_id)
        logger.info("%s", "-" * 60)
        return {"learning_candidate": {"id": learning_id, "type": "error_correction", "text": learning_text}}

    # Case 2: Successful query — save as a validated query pattern
    if sql_result and sql_result.get("row_count", 0) > 0 and not sql_error:
        # Only save if the query is non-trivial
        if len(generated_sql) > 50:
            logger.info("\n%s", "-" * 60)
            logger.info("NODE: Learning Evaluator")
            logger.info("Saved successful_query candidate (%d rows)", sql_result["row_count"])
            logger.info("%s", "-" * 60)
            return {"learning_candidate": {
                "type": "successful_query",
                "sql": generated_sql,
                "row_count": sql_result["row_count"],
            }}

    logger.info("\n%s", "-" * 60)
    logger.info("NODE: Learning Evaluator")
    logger.info("No learning candidate this run.")
    logger.info("%s", "-" * 60)
    return {"learning_candidate": None}
