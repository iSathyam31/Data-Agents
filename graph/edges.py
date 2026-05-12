"""Conditional edge routing functions for the LangGraph."""

import logging
from graph.state import DashState
import config

logger = logging.getLogger("dash.edges")


def route_after_intent(state: DashState) -> str:
    """Route based on classified intent."""
    intent = state.get("intent", "general")
    if intent == "data_question":
        dest = "context_retrieval"
    elif intent == "infra_request":
        dest = "context_retrieval"
    elif intent == "feedback":
        dest = "leader"
    else:  # general
        dest = "leader"
    logger.info("EDGE: route_after_intent — intent=%s → %s", intent, dest)
    return dest


def route_after_context(state: DashState) -> str:
    """Route to analyst or engineer after context is retrieved."""
    intent = state.get("intent", "data_question")
    dest = "engineer" if intent == "infra_request" else "analyst"
    logger.info("EDGE: route_after_context — intent=%s → %s", intent, dest)
    return dest


def route_after_validation(state: DashState) -> str:
    """Route based on SQL validation result."""
    validation = state.get("validation_result", {})
    if not validation.get("valid", False):
        retry = state.get("retry_count", 0)
        if retry < config.MAX_SQL_RETRIES:
            logger.info("EDGE: route_after_validation — INVALID (retry %d/%d) → analyst_retry", retry, config.MAX_SQL_RETRIES)
            return "analyst_retry"
        logger.error("EDGE: route_after_validation — INVALID (max retries) → validation_failed")
        return "validation_failed"
    logger.info("EDGE: route_after_validation — VALID → executor")
    return "executor"


def route_after_execution(state: DashState) -> str:
    """Route based on SQL execution result."""
    if state.get("sql_error"):
        retry = state.get("retry_count", 0)
        if retry < config.MAX_SQL_RETRIES:
            logger.info("EDGE: route_after_execution — ERROR (retry %d/%d) → analyst_retry", retry, config.MAX_SQL_RETRIES)
            return "analyst_retry"
        logger.error("EDGE: route_after_execution — ERROR (max retries) → execution_failed")
        return "execution_failed"
    logger.info("EDGE: route_after_execution — SUCCESS → interpreter")
    return "interpreter"
