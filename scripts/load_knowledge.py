"""Load knowledge files (tables, queries, business rules) into ChromaDB."""

import json
import os
import sys
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from dash_strands.knowledge.store import get_knowledge_collection

KNOWLEDGE_DIR = Path(__file__).parent.parent / "knowledge"


def load_tables():
    """Load table metadata JSON files from knowledge/tables/."""
    tables_dir = KNOWLEDGE_DIR / "tables"
    if not tables_dir.exists():
        print("  No tables/ directory found, skipping.")
        return

    collection = get_knowledge_collection()
    count = 0
    for f in sorted(tables_dir.glob("*.json")):
        data = json.loads(f.read_text(encoding="utf-8"))
        name = data.get("table_name", f.stem)

        doc_parts = [f"Table: {name}"]
        if desc := data.get("table_description"):
            doc_parts.append(f"Description: {desc}")
        if uses := data.get("use_cases"):
            doc_parts.append(f"Use cases: {', '.join(uses)}")
        if notes := data.get("data_quality_notes"):
            doc_parts.append("Data quality notes:\n- " + "\n- ".join(notes))
        if cols := data.get("table_columns"):
            col_lines = [
                f"  {c['name']}: {c['type']} — {c.get('description', '')}"
                for c in cols
            ]
            doc_parts.append("Columns:\n" + "\n".join(col_lines))

        doc = "\n\n".join(doc_parts)
        collection.upsert(
            ids=[f"table_{name}"],
            documents=[doc],
            metadatas=[{"source": "table_metadata", "name": name}],
        )
        count += 1
        print(f"  Loaded table: {name}")

    print(f"  {count} table metadata files loaded.")


def load_queries():
    """Load validated SQL query files from knowledge/queries/."""
    queries_dir = KNOWLEDGE_DIR / "queries"
    if not queries_dir.exists():
        print("  No queries/ directory found, skipping.")
        return

    collection = get_knowledge_collection()
    count = 0
    for f in sorted(queries_dir.glob("*.sql")):
        content = f.read_text(encoding="utf-8")
        name = f.stem
        description = ""

        for line in content.split("\n"):
            line_s = line.strip()
            if line_s.startswith("-- <query ") and line_s.endswith(">"):
                name = line_s[len("-- <query "):-1].strip()
            elif line_s.startswith("-- <description>") and line_s.endswith("</description>"):
                description = line_s[len("-- <description>"):-len("</description>")].strip()

        doc = f"Query: {name}\nDescription: {description}\n\nSQL:\n{content}"
        collection.upsert(
            ids=[f"query_{name}"],
            documents=[doc],
            metadatas=[{"source": "validated_query", "name": name}],
        )
        count += 1
        print(f"  Loaded query: {name}")

    print(f"  {count} validated query files loaded.")


def load_business_rules():
    """Load business rules JSON files from knowledge/business/."""
    business_dir = KNOWLEDGE_DIR / "business"
    if not business_dir.exists():
        print("  No business/ directory found, skipping.")
        return

    collection = get_knowledge_collection()
    count = 0
    for f in sorted(business_dir.glob("*.json")):
        data = json.loads(f.read_text(encoding="utf-8"))
        doc_parts = []

        if metrics := data.get("metrics"):
            for m in metrics:
                doc_parts.append(
                    f"Metric: {m['name']}\n"
                    f"Definition: {m.get('definition', '')}\n"
                    f"Calculation: {m.get('calculation', '')}"
                )
        if gotchas := data.get("common_gotchas"):
            for g in gotchas:
                doc_parts.append(f"Gotcha: {g['issue']}\nSolution: {g['solution']}")

        if doc_parts:
            doc = "\n\n".join(doc_parts)
            collection.upsert(
                ids=[f"business_{f.stem}"],
                documents=[doc],
                metadatas=[{"source": "business_rules", "name": f.stem}],
            )
            count += 1
            print(f"  Loaded business rules: {f.stem}")

    print(f"  {count} business rule files loaded.")


def load_knowledge():
    print("Loading knowledge into ChromaDB...")
    load_tables()
    load_queries()
    load_business_rules()
    print("Done.")


if __name__ == "__main__":
    load_knowledge()
