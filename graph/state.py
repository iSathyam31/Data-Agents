"""LangGraph state definition for Dash."""

from typing import Annotated, Optional
from typing_extensions import TypedDict
from langgraph.graph.message import add_messages


class DashState(TypedDict):
    """Shared state flowing through the LangGraph graph."""

    # ── Conversation ──────────────────────────────────────────────────────────
    messages: Annotated[list, add_messages]

    # ── Routing ───────────────────────────────────────────────────────────────
    intent: str  # data_question | infra_request | general | feedback
    current_agent: str  # analyst | engineer | leader

    # ── Context (populated by context_retrieval node) ─────────────────────────
    knowledge_context: list[str]
    learnings_context: list[str]
    schema_context: str  # DDL summary of relevant tables

    # ── SQL Pipeline ──────────────────────────────────────────────────────────
    generated_sql: str
    validation_result: dict  # {valid: bool, errors: list, warnings: list}
    cost_estimate: dict  # {estimated: bool, plan: dict, approved: bool}
    sql_result: Optional[dict]  # {columns: list, rows: list, row_count: int}
    sql_error: Optional[str]

    # ── Output ────────────────────────────────────────────────────────────────
    insight: str  # Final interpreted answer
    chart_config: Optional[dict]  # Plotly chart specification from interpreter

    # ── Learning Loop ─────────────────────────────────────────────────────────
    retry_count: int
    learning_candidate: Optional[dict]  # Proposed learning

    # ── Session ───────────────────────────────────────────────────────────────
    session_id: str
