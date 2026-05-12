"""Context retrieval node — searches knowledge + learnings + schema cache."""

import logging
from graph.state import DashState
from vectorstore import search_knowledge, search_learnings
from db.schema_cache import get_table_ddl, get_table_names
import config

logger = logging.getLogger("dash.context_retrieval")


def _extract_query_text(state: DashState) -> str:
    """Extract the latest user query from messages."""
    for m in reversed(state["messages"]):
        if hasattr(m, "type") and m.type == "human":
            return m.content
        elif isinstance(m, dict) and m.get("role") == "user":
            return m["content"]
        elif isinstance(m, tuple) and m[0] == "user":
            return m[1]
    return ""


def context_retrieval(state: DashState) -> dict:
    """Search knowledge base, learnings, and provide schema context."""
    query_text = _extract_query_text(state)

    # 1. Search knowledge (tables, queries, business rules)
    knowledge_results = search_knowledge(query_text, n_results=config.KNOWLEDGE_TOP_K)
    knowledge_context = [item["document"] for item in knowledge_results]

    # 2. Search learnings (past errors, fixes, discoveries)
    learnings_results = search_learnings(query_text, n_results=config.LEARNINGS_TOP_K)
    learnings_context = [item["document"] for item in learnings_results]

    # 3. Build schema context from cached metadata
    # Include a summary of all tables for the agent
    table_names = get_table_names()
    schema_lines = [f"Available tables in {config.SNOWFLAKE_DATABASE}.{config.SNOWFLAKE_SCHEMA}:"]
    schema_lines.append(f"({len(table_names)} tables total)\n")

    # Include DDL for tables mentioned in knowledge results or likely relevant
    mentioned_tables = set()
    for doc in knowledge_context:
        for tname in table_names:
            if tname.lower() in doc.lower():
                mentioned_tables.add(tname)

    # Always include core tables
    core_tables = {"STORE_SALES", "CATALOG_SALES", "WEB_SALES", "DATE_DIM", "ITEM", "CUSTOMER"}
    for t in (mentioned_tables | core_tables):
        if t in table_names or t.upper() in table_names:
            ddl = get_table_ddl(t)
            schema_lines.append(ddl)
            schema_lines.append("")

    schema_context = "\n".join(schema_lines)

    logger.info("\n%s", "-" * 60)
    logger.info("NODE: Context Retrieval")
    logger.info("Knowledge docs retrieved: %d", len(knowledge_context))
    logger.info("Learnings retrieved: %d", len(learnings_context))
    logger.info("Schema tables in context: %d", schema_context.count("CREATE TABLE") if schema_context else 0)
    logger.info("%s", "-" * 60)

    return {
        "knowledge_context": knowledge_context,
        "learnings_context": learnings_context,
        "schema_context": schema_context,
    }
