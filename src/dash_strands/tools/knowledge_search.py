"""Tool: Search curated knowledge and learnings."""

from strands import tool

from dash_strands.knowledge.store import get_knowledge_collection, get_learnings_collection


@tool
def knowledge_search(query: str) -> str:
    """Search the knowledge base for table metadata, validated queries, business rules, and past learnings.

    Use this BEFORE writing any SQL to find relevant context about the database schema,
    known-good query patterns, business rules, and previously discovered fixes.

    Args:
        query: Natural language description of what you're looking for.

    Returns:
        Relevant knowledge and learnings as text.
    """
    results = []

    # Search curated knowledge
    knowledge = get_knowledge_collection()
    k_results = knowledge.query(query_texts=[query], n_results=5)
    if k_results and k_results["documents"] and k_results["documents"][0]:
        for doc, meta in zip(k_results["documents"][0], k_results["metadatas"][0]):
            source = meta.get("source", "knowledge")
            results.append(f"[Knowledge — {source}]\n{doc}")

    # Search learnings
    learnings = get_learnings_collection()
    try:
        l_results = learnings.query(query_texts=[query], n_results=3)
        if l_results and l_results["documents"] and l_results["documents"][0]:
            for doc in l_results["documents"][0]:
                results.append(f"[Learning]\n{doc}")
    except Exception:
        pass  # Empty collection raises on some ChromaDB versions

    if not results:
        return "No relevant knowledge or learnings found. Proceed using schema introspection."

    return "\n\n---\n\n".join(results)
