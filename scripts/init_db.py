"""Create the 'DASH_AGENT' database and 'dash' schema in Snowflake.

Run once before first use:
    python scripts/init_db.py

This is a convenience script. The same DDL lives in snowflake_setup/setup.sql
(steps 8–10) which should be run as ACCOUNTADMIN for full privilege grants.
This script only creates the DB/schema and is safe to re-run (idempotent).
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

import snowflake.connector

from dash_strands import config


def init_db():
    print(f"Connecting to Snowflake account {config.SF_ACCOUNT} as {config.SF_USER}...")
    conn = snowflake.connector.connect(
        account=config.SF_ACCOUNT,
        user=config.SF_USER,
        password=config.SF_PASSWORD,
        warehouse=config.SF_WAREHOUSE,
        role=config.SF_ROLE_ENGINEER,
    )
    cur = conn.cursor()

    print(f"Creating database {config.SF_DASH_DATABASE}...")
    cur.execute(f"CREATE DATABASE IF NOT EXISTS {config.SF_DASH_DATABASE}")

    print(f"Creating schema {config.SF_DASH_DATABASE}.{config.DASH_SCHEMA}...")
    cur.execute(f"USE DATABASE {config.SF_DASH_DATABASE}")
    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {config.DASH_SCHEMA}")

    cur.close()
    conn.close()
    print("Done. Dash schema is ready.")


if __name__ == "__main__":
    init_db()
