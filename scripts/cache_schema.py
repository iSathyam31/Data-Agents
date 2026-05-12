"""Cache the Snowflake INFORMATION_SCHEMA locally to avoid repeated queries."""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from db.schema_cache import fetch_and_cache_schema


def main():
    print("Fetching schema from Snowflake INFORMATION_SCHEMA...")
    schema = fetch_and_cache_schema()
    print(f"Cached {len(schema)} tables to schema_cache.json")
    for table_name, info in sorted(schema.items()):
        col_count = len(info.get("columns", []))
        row_count = info.get("row_count", "N/A")
        print(f"  {table_name}: {col_count} columns, {row_count} rows")


if __name__ == "__main__":
    main()
