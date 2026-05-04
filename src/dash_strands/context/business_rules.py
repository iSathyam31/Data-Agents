"""Load and format TPC-DS business rules, metrics, and gotchas for agent system prompts.

Reads knowledge/business/*.json files and formats them as structured sections
(METRICS, SALES CHANNELS, BUSINESS RULES, COMMON GOTCHAS) injected into the prompt.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
BUSINESS_DIR = _PROJECT_ROOT / "knowledge" / "business"


def _load_business_rules(business_dir: Path | None = None) -> dict[str, Any]:
    """Load all business rule JSON files and merge them into a single dict."""
    if business_dir is None:
        business_dir = BUSINESS_DIR

    merged: dict[str, Any] = {
        "metrics": [],
        "sales_channels": [],
        "common_gotchas": [],
        "recommended_query_patterns": [],
        "product_hierarchy": None,
        "dimension_sizes": None,
    }

    if not business_dir.exists():
        logger.warning("Business directory not found: %s", business_dir)
        return merged

    for filepath in sorted(business_dir.glob("*.json")):
        try:
            with open(filepath, encoding="utf-8") as f:
                data = json.load(f)
            for key in ("metrics", "sales_channels", "common_gotchas", "recommended_query_patterns"):
                if key in data and isinstance(data[key], list):
                    merged[key].extend(data[key])
            for key in ("product_hierarchy", "dimension_sizes"):
                if key in data and merged[key] is None:
                    merged[key] = data[key]
        except (json.JSONDecodeError, OSError) as exc:
            logger.error("Failed to load %s: %s", filepath, exc)

    return merged


def build_business_context(business_dir: Path | None = None) -> str:
    """Build a formatted business context string for injection into a system prompt."""
    rules = _load_business_rules(business_dir)
    lines: list[str] = []

    # Metrics
    if rules["metrics"]:
        lines.append("## METRICS\n")
        for m in rules["metrics"]:
            name = m.get("name", "")
            defn = m.get("definition", "")
            calc = m.get("calculation", "")
            lines.append(f"**{name}**: {defn}")
            if calc:
                lines.append(f"  - Calculation: `{calc}`")
            lines.append("")

    # Sales channels
    if rules["sales_channels"]:
        lines.append("## SALES CHANNELS\n")
        for ch in rules["sales_channels"]:
            channel = ch.get("channel", "")
            fact = ch.get("fact_table", "")
            returns = ch.get("returns_table", "")
            date_col = ch.get("date_column", "")
            rev_col = ch.get("revenue_column", "")
            order_key = ch.get("order_key", "")
            desc = ch.get("description", "")
            lines.append(
                f"**{channel}**: fact=`{fact}`, returns=`{returns}`, "
                f"date_sk=`{date_col}`, revenue=`{rev_col}`, order_key=`{order_key}`"
            )
            if desc:
                lines.append(f"  {desc}")
            lines.append("")

    # Product hierarchy
    ph = rules.get("product_hierarchy")
    if ph:
        lines.append("## PRODUCT HIERARCHY\n")
        lines.append(ph.get("description", ""))
        for level in ph.get("levels", []):
            lines.append(f"  - {level}")
        lines.append("")

    # Dimension sizes
    ds = rules.get("dimension_sizes")
    if ds:
        lines.append("## DIMENSION TABLE SIZES\n")
        lines.append(ds.get("description", ""))
        for tname, size in ds.get("tables", {}).items():
            lines.append(f"  - `{tname}`: {size}")
        lines.append("")

    # Common gotchas
    if rules["common_gotchas"]:
        lines.append("## COMMON GOTCHAS\n")
        for g in rules["common_gotchas"]:
            issue = g.get("issue", "")
            solution = g.get("solution", "")
            lines.append(f"**{issue}**")
            if solution:
                lines.append(f"  - {solution}")
            lines.append("")

    # Recommended patterns
    if rules["recommended_query_patterns"]:
        lines.append("## RECOMMENDED QUERY PATTERNS\n")
        for p in rules["recommended_query_patterns"]:
            lines.append(f"- {p}")
        lines.append("")

    return "\n".join(lines)
