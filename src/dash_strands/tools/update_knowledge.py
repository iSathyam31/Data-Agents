"""Tool: Register new dash schema objects in the knowledge base."""

from strands import tool

from dash_strands.knowledge.store import get_knowledge_collection


@tool
def update_knowledge(
    object_name: str,
    object_type: str,
    description: str,
    columns: str,
    example_queries: str,
) -> str:
    """Register a newly created view or table in the knowledge base.

    Call this AFTER creating a view or table in the dash schema so that
    the Analyst can discover and use it in future queries.

    Args:
        object_name: Full name including schema (e.g., "dash.monthly_mrr").
        object_type: Type of object ("view" or "table").
        description: What this object contains and when to use it.
        columns: Comma-separated list of column names and their descriptions.
        example_queries: One or more example SQL queries that use this object.

    Returns:
        Confirmation message.
    """
    collection = get_knowledge_collection()
    doc = (
        f"Dash Schema Object: {object_name} ({object_type})\n"
        f"Description: {description}\n\n"
        f"Columns:\n{columns}\n\n"
        f"Example Queries:\n{example_queries}"
    )
    collection.upsert(
        ids=[f"dash_object_{object_name}"],
        documents=[doc],
        metadatas=[{"source": "dash_schema", "name": object_name, "type": object_type}],
    )
    return f"Registered {object_type} '{object_name}' in knowledge base."
