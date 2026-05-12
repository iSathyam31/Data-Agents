"""Load knowledge files (tables, queries, business rules) into ChromaDB."""

import json
import os
import sys

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from vectorstore import upsert_knowledge, get_knowledge_collection


KNOWLEDGE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "knowledge")


def load_table_knowledge():
    """Load table metadata JSON files into ChromaDB."""
    tables_dir = os.path.join(KNOWLEDGE_DIR, "tables")
    if not os.path.exists(tables_dir):
        print("No tables directory found.")
        return 0

    count = 0
    for filename in os.listdir(tables_dir):
        if not filename.endswith(".json"):
            continue
        filepath = os.path.join(tables_dir, filename)
        with open(filepath, "r") as f:
            table_data = json.load(f)

        table_name = table_data.get("table_name", filename.replace(".json", ""))

        # Build a rich text document for embedding
        doc_parts = [
            f"Table: {table_name}",
            f"Description: {table_data.get('table_description', '')}",
        ]
        if table_data.get("use_cases"):
            doc_parts.append(f"Use cases: {', '.join(table_data['use_cases'])}")
        if table_data.get("data_quality_notes"):
            doc_parts.append(f"Data quality notes: {'; '.join(table_data['data_quality_notes'])}")
        if table_data.get("key_columns"):
            cols = [f"{c['name']} ({c['type']}): {c['description']}" for c in table_data["key_columns"]]
            doc_parts.append(f"Key columns: {'; '.join(cols)}")

        doc_text = "\n".join(doc_parts)
        doc_id = f"table-{table_name.lower()}"

        upsert_knowledge(
            doc_id=doc_id,
            text=doc_text,
            metadata={"type": "table", "table_name": table_name, "source": filename},
        )
        count += 1
        print(f"  Loaded table: {table_name}")

    return count


def load_query_knowledge():
    """Load validated SQL query files into ChromaDB."""
    queries_dir = os.path.join(KNOWLEDGE_DIR, "queries")
    if not os.path.exists(queries_dir):
        print("No queries directory found.")
        return 0

    count = 0
    for filename in os.listdir(queries_dir):
        if not filename.endswith(".sql"):
            continue
        filepath = os.path.join(queries_dir, filename)
        with open(filepath, "r") as f:
            content = f.read()

        # Parse the custom format
        query_name = filename.replace(".sql", "")
        description = ""
        for line in content.split("\n"):
            if "<description>" in line:
                description = line.split("<description>")[1].split("</description>")[0].strip()
                break

        doc_text = f"Validated Query: {query_name}\nDescription: {description}\n\n{content}"
        doc_id = f"query-{query_name}"

        upsert_knowledge(
            doc_id=doc_id,
            text=doc_text,
            metadata={"type": "query", "query_name": query_name, "source": filename},
        )
        count += 1
        print(f"  Loaded query: {query_name}")

    return count


def load_business_knowledge():
    """Load business rules JSON files into ChromaDB."""
    business_dir = os.path.join(KNOWLEDGE_DIR, "business")
    if not os.path.exists(business_dir):
        print("No business directory found.")
        return 0

    count = 0
    for filename in os.listdir(business_dir):
        if not filename.endswith(".json"):
            continue
        filepath = os.path.join(business_dir, filename)
        with open(filepath, "r") as f:
            biz_data = json.load(f)

        # Build document from metrics
        doc_parts = [f"Business Rules: {biz_data.get('domain', 'Unknown')}"]
        doc_parts.append(f"Description: {biz_data.get('description', '')}")

        if biz_data.get("metrics"):
            for m in biz_data["metrics"]:
                doc_parts.append(f"\nMetric: {m['name']}")
                doc_parts.append(f"  Definition: {m.get('definition', '')}")
                doc_parts.append(f"  Calculation: {m.get('calculation', '')}")
                if m.get("notes"):
                    doc_parts.append(f"  Notes: {m['notes']}")

        if biz_data.get("common_gotchas"):
            doc_parts.append("\nCommon Gotchas:")
            for g in biz_data["common_gotchas"]:
                doc_parts.append(f"  Issue: {g['issue']}")
                doc_parts.append(f"  Solution: {g['solution']}")

        if biz_data.get("join_patterns"):
            doc_parts.append("\nJoin Patterns:")
            for name, pattern in biz_data["join_patterns"].items():
                doc_parts.append(f"  {name}: {pattern}")

        doc_text = "\n".join(doc_parts)
        doc_id = f"business-{filename.replace('.json', '')}"

        upsert_knowledge(
            doc_id=doc_id,
            text=doc_text,
            metadata={"type": "business_rules", "source": filename},
        )
        count += 1
        print(f"  Loaded business rules: {filename}")

    return count


def main(recreate: bool = False):
    """Main entry point for loading knowledge."""
    if recreate:
        print("Recreating knowledge collection...")
        collection = get_knowledge_collection()
        # Delete all existing documents
        existing = collection.get()
        if existing["ids"]:
            collection.delete(ids=existing["ids"])
        print("  Cleared existing knowledge.\n")

    print("Loading table knowledge...")
    table_count = load_table_knowledge()
    print(f"  → {table_count} tables loaded.\n")

    print("Loading query knowledge...")
    query_count = load_query_knowledge()
    print(f"  → {query_count} queries loaded.\n")

    print("Loading business rules...")
    biz_count = load_business_knowledge()
    print(f"  → {biz_count} business rule files loaded.\n")

    total = table_count + query_count + biz_count
    print(f"Done. {total} knowledge documents loaded into ChromaDB.")


if __name__ == "__main__":
    recreate = "--recreate" in sys.argv
    main(recreate=recreate)
