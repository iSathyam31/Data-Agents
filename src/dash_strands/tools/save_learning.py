"""Tool: Save discovered fixes and gotchas to the learnings store."""

import uuid

from strands import tool

from dash_strands.knowledge.store import get_learnings_collection


@tool
def save_learning(problem: str, fix: str, context: str = "") -> str:
    """Save a discovered fix, gotcha, or correction to the learnings store.

    Call this when you encounter and fix a SQL error, discover a data quality
    gotcha, or receive a user correction. This helps avoid repeating mistakes.

    Args:
        problem: What went wrong (e.g., "SUM on nullable column returns NULL").
        fix: How it was fixed (e.g., "Use COALESCE(SUM(col), 0)").
        context: Optional additional context about when this applies.

    Returns:
        Confirmation message.
    """
    collection = get_learnings_collection()
    doc = f"Problem: {problem}\nFix: {fix}"
    if context:
        doc += f"\nContext: {context}"
    collection.add(
        ids=[f"learning_{uuid.uuid4().hex[:8]}"],
        documents=[doc],
        metadatas=[{"source": "auto_learning"}],
    )
    return f"Learning saved: {problem[:80]}..."
