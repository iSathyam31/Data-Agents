"""Centralized configuration loaded from .env."""

import os
from pathlib import Path

from dotenv import load_dotenv

# Load .env from project root
_project_root = Path(__file__).resolve().parent.parent.parent
load_dotenv(_project_root / ".env")

# --- Snowflake ---
SF_ACCOUNT = os.getenv("SF_ACCOUNT", "")
SF_USER = os.getenv("SF_USER", "")
SF_PASSWORD = os.getenv("SF_PASSWORD", "")
SF_DATABASE = os.getenv("SF_DATABASE", "SNOWFLAKE_SAMPLE_DATA")
SF_SCHEMA = os.getenv("SF_SCHEMA", "TPCDS_SF100TCL")
SF_WAREHOUSE = os.getenv("SF_WAREHOUSE", "COMPUTE_WH")
SF_ROLE_ANALYST = os.getenv("SF_ROLE_ANALYST", "dash_analyst_role")
SF_ROLE_ENGINEER = os.getenv("SF_ROLE_ENGINEER", "dash_engineer_role")

# --- Azure OpenAI (Chat) ---
AZURE_OPENAI_API_KEY = os.getenv("AZURE_OPENAI_API_KEY", "")
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT", "")
AZURE_DEPLOYMENT = os.getenv("CHAT_DEPLOYMENT", "gpt-4o")
AZURE_OPENAI_API_VERSION = os.getenv("API_VERSION", "2025-01-01-preview")

# --- Azure OpenAI (Embeddings) ---
# Embeddings share the same endpoint, key, and API version as the chat model
EMBEDDING_DEPLOYMENT = os.getenv("EMBEDDING_DEPLOYMENT", "text-embedding-3-small")

# --- ChromaDB ---
CHROMA_PATH = os.getenv("CHROMA_PATH", str(_project_root / "chroma_data"))

# --- Schemas ---
DATA_SCHEMA = os.getenv("SF_SCHEMA", "TPCDS_SF100TCL")
DASH_SCHEMA = "dash"
