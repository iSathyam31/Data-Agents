"""Central configuration for Dash-LangGraph."""

import os
from dotenv import load_dotenv

load_dotenv()

# ── Azure OpenAI ──────────────────────────────────────────────────────────────
AZURE_OPENAI_API_KEY = os.getenv("AZURE_OPENAI_API_KEY", "")
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT", "")
AZURE_OPENAI_CHAT_DEPLOYMENT = os.getenv("AZURE_OPENAI_CHAT_DEPLOYMENT", "gpt-4o")
AZURE_OPENAI_MINI_DEPLOYMENT = os.getenv("AZURE_OPENAI_MINI_DEPLOYMENT", "gpt-4o-mini")
AZURE_OPENAI_EMBEDDING_DEPLOYMENT = os.getenv("AZURE_OPENAI_EMBEDDING_DEPLOYMENT", "text-embedding-3-small")
AZURE_OPENAI_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION", "2024-12-01-preview")

# ── Snowflake ─────────────────────────────────────────────────────────────────
SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT", "")
SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER", "")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD", "")
SNOWFLAKE_DATABASE = os.getenv("SNOWFLAKE_DATABASE", "SNOWFLAKE_SAMPLE_DATA")
SNOWFLAKE_SCHEMA = os.getenv("SNOWFLAKE_SCHEMA", "TPCDS_SF100TCL")
SNOWFLAKE_WAREHOUSE = os.getenv("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH")
SNOWFLAKE_ROLE = os.getenv("SNOWFLAKE_ROLE", "SYSADMIN")

# ── Cost / Safety Thresholds ──────────────────────────────────────────────────
MAX_RESULT_ROWS = 1000          # Hard cap on result set size
COST_BYTES_THRESHOLD = 10 * (1024 ** 3)   # 10 GB — ask user before scanning more
MAX_SQL_RETRIES = 3             # Analyst retry budget on SQL errors

# ── Vector Store ──────────────────────────────────────────────────────────────
CHROMA_PERSIST_DIR = os.path.join(os.path.dirname(__file__), ".chroma_db")
KNOWLEDGE_TOP_K = 5
LEARNINGS_TOP_K = 3
