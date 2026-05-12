"""LangGraph builder — assembles the full Dash state graph."""

import warnings
from langgraph.graph import StateGraph, START, END
from graph.state import DashState
from graph.nodes.intent_classifier import intent_classifier
from graph.nodes.context_retrieval import context_retrieval
from graph.nodes.analyst import analyst
from graph.nodes.sql_validator import sql_validator
from graph.nodes.executor import executor
from graph.nodes.interpreter import interpreter
from graph.nodes.learning_evaluator import learning_evaluator
from graph.nodes.leader import leader
from graph.nodes.engineer import engineer
from graph.edges import (
    route_after_intent,
    route_after_context,
    route_after_validation,
    route_after_execution,
)
from langchain_core.messages import AIMessage
import config


def _increment_retry(state: DashState) -> dict:
    """Increment retry counter and clear error for next attempt."""
    return {
        "retry_count": state.get("retry_count", 0) + 1,
        "sql_error": None,
        "validation_result": {},
    }


def _validation_failed_response(state: DashState) -> dict:
    """Handle validation failure after max retries."""
    errors = state.get("validation_result", {}).get("errors", ["Unknown validation error"])
    msg = f"I wasn't able to generate valid SQL after {config.MAX_SQL_RETRIES} attempts. Errors: {'; '.join(errors)}"
    return {
        "insight": msg,
        "messages": [AIMessage(content=msg)],
    }


def _execution_failed_response(state: DashState) -> dict:
    """Handle execution failure after max retries."""
    error = state.get("sql_error", "Unknown error")
    msg = f"The SQL query failed after {config.MAX_SQL_RETRIES} attempts. Last error: {error}"
    return {
        "insight": msg,
        "messages": [AIMessage(content=msg)],
    }


def build_graph():
    """Build and compile the Dash LangGraph."""
    graph = StateGraph(DashState)

    # ── Add nodes ─────────────────────────────────────────────────────────────
    graph.add_node("intent_classifier", intent_classifier)
    graph.add_node("context_retrieval", context_retrieval)
    graph.add_node("analyst", analyst)
    graph.add_node("sql_validator", sql_validator)
    graph.add_node("executor", executor)
    graph.add_node("interpreter", interpreter)
    graph.add_node("learning_evaluator", learning_evaluator)
    graph.add_node("leader", leader)
    graph.add_node("engineer", engineer)
    graph.add_node("analyst_retry", _increment_retry)
    graph.add_node("validation_failed", _validation_failed_response)
    graph.add_node("execution_failed", _execution_failed_response)

    # ── Entry point ───────────────────────────────────────────────────────────
    graph.add_edge(START, "intent_classifier")

    # ── Intent routing ────────────────────────────────────────────────────────
    graph.add_conditional_edges(
        "intent_classifier",
        route_after_intent,
        {
            "context_retrieval": "context_retrieval",
            "leader": "leader",
        },
    )

    # ── Context → Analyst or Engineer ─────────────────────────────────────────
    graph.add_conditional_edges(
        "context_retrieval",
        route_after_context,
        {
            "analyst": "analyst",
            "engineer": "engineer",
        },
    )

    # ── Analyst → Validator ───────────────────────────────────────────────────
    graph.add_edge("analyst", "sql_validator")

    # ── Validator → Execute or Retry ──────────────────────────────────────────
    graph.add_conditional_edges(
        "sql_validator",
        route_after_validation,
        {
            "executor": "executor",
            "analyst_retry": "analyst_retry",
            "validation_failed": "validation_failed",
        },
    )

    # ── Retry → Analyst ───────────────────────────────────────────────────────
    graph.add_edge("analyst_retry", "analyst")

    # ── Executor → Interpreter or Retry ───────────────────────────────────────
    graph.add_conditional_edges(
        "executor",
        route_after_execution,
        {
            "interpreter": "interpreter",
            "analyst_retry": "analyst_retry",
            "execution_failed": "execution_failed",
        },
    )

    # ── Interpreter → Learning Evaluator → END ────────────────────────────────
    graph.add_edge("interpreter", "learning_evaluator")
    graph.add_edge("learning_evaluator", END)

    # ── Terminal nodes ────────────────────────────────────────────────────────
    graph.add_edge("leader", END)
    graph.add_edge("engineer", END)
    graph.add_edge("validation_failed", END)
    graph.add_edge("execution_failed", END)

    with warnings.catch_warnings():
        warnings.filterwarnings(
            "ignore",
            message="The default value of `allowed_objects` will change",
            category=PendingDeprecationWarning,
        )
        return graph.compile()
