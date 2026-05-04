"""Load and format TPC-DS table metadata for injection into agent system prompts.

Reads knowledge/tables/*.json files and formats them as a structured semantic
model section so agents know the schema without requiring a knowledge_search call.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

# Root of the project: src/dash_strands/context/ -> up 4 levels -> project root
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
TABLES_DIR = _PROJECT_ROOT / "knowledge" / "tables"

# Max items to include per table to keep the prompt lean
_MAX_COLUMNS = 12
_MAX_QUALITY_NOTES = 3
_MAX_USE_CASES = 3


def _load_table_metadata(tables_dir: Path | None = None) -> list[dict[str, Any]]:
    """Load all table JSON files from the tables directory."""
    if tables_dir is None:
        tables_dir = TABLES_DIR

    tables: list[dict[str, Any]] = []
    if not tables_dir.exists():
        logger.warning("Tables directory not found: %s", tables_dir)
        return tables

    for filepath in sorted(tables_dir.glob("*.json")):
        try:
            with open(filepath, encoding="utf-8") as f:
                data = json.load(f)
            tables.append(data)
        except (json.JSONDecodeError, OSError) as exc:
            logger.error("Failed to load %s: %s", filepath, exc)

    return tables


def build_semantic_model(tables_dir: Path | None = None) -> str:
    """Build a formatted semantic model string for injection into a system prompt.

    Each table gets a compact section with its full reference, description,
    key columns, and top data quality notes.
    """
    tables = _load_table_metadata(tables_dir)
    if not tables:
        return ""

    lines: list[str] = []
    for table in tables:
        name = table.get("table_name", "UNKNOWN")
        full_ref = table.get("full_reference") or table.get("schema", "") + "." + name
        description = table.get("table_description", "")

        lines.append(f"### {name}")
        lines.append(f"Full path: `{full_ref}`")
        if description:
            lines.append(description[:300])  # cap very long descriptions

        # Use cases
        use_cases = table.get("use_cases", [])[:_MAX_USE_CASES]
        if use_cases:
            lines.append("**Use for:** " + "; ".join(use_cases))

        # Columns
        columns: list[dict[str, Any]] = table.get("table_columns", [])[:_MAX_COLUMNS]
        if columns:
            lines.append("**Key Columns:**")
            for col in columns:
                col_name = col.get("name", "")
                col_type = col.get("type", "")
                col_desc = col.get("description", "")
                lines.append(f"  - `{col_name}` ({col_type}): {col_desc}")

        # Data quality notes
        dq_notes = table.get("data_quality_notes", [])[:_MAX_QUALITY_NOTES]
        if dq_notes:
            lines.append("**Data Quality:**")
            for note in dq_notes:
                lines.append(f"  - {note}")

        lines.append("")  # blank line between tables

    return "\n".join(lines)
