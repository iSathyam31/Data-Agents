"""Create the 'dash' schema in the existing PostgreSQL database."""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

import psycopg2

from dash_strands import config


def init_db():
    print(f"Connecting to {config.DB_HOST}:{config.DB_PORT}/{config.DB_DATABASE}...")
    conn = psycopg2.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        user=config.DB_USER,
        password=config.DB_PASS,
        dbname=config.DB_DATABASE,
        sslmode="require",
    )
    conn.autocommit = True
    cur = conn.cursor()

    # Create dash schema for agent-managed views and tables
    # (ecommerce schema already exists from seed_data.py)
    cur.execute("CREATE SCHEMA IF NOT EXISTS dash")
    print("Created schema 'dash' (ecommerce schema already exists from seed data)")

    cur.close()
    conn.close()
    print("Done.")


if __name__ == "__main__":
    init_db()
