"""Tool: Save a validated SQL query to the knowledge base."""

import uuid

from strands import tool

from dash_strands.knowledge.store import get_knowledge_collection


@tool
def save_validated_query(name: str, description: str, sql: str) -> str:
    """Save a validated SQL query to the knowledge base for future reuse.

    Call this when you've written and executed a SQL query that gave correct results
    and could be useful for answering similar questions in the future.

    Args:
        name: Short identifier for the query (e.g., "monthly_mrr", "churn_by_plan").
        description: What this query answers.
        sql: The validated SQL statement.

    Returns:
        Confirmation message.
    """
    collection = get_knowledge_collection()
    doc = f"Query: {name}\nDescription: {description}\n\nSQL:\n{sql}"
    collection.upsert(
        ids=[f"query_{name}"],
        documents=[doc],
        metadatas=[{"source": "validated_query", "name": name}],
    )
    return f"Saved validated query '{name}' to knowledge base."
