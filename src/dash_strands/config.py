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
SF_DATABASE = os.getenv("SF_DATABASE", "HOSPITAL_DB")
SF_SCHEMA = os.getenv("SF_SCHEMA", "healthcare")
SF_WAREHOUSE = os.getenv("SF_WAREHOUSE", "COMPUTE_WH")
SF_ROLE_ANALYST = os.getenv("SF_ROLE_ANALYST", "dash_analyst_role")
SF_ROLE_ENGINEER = os.getenv("SF_ROLE_ENGINEER", "dash_engineer_role")

# --- Azure OpenAI (Chat) ---
AZURE_OPENAI_API_KEY = os.getenv("AZURE_OPENAI_API_KEY", "")
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT", "")
AZURE_DEPLOYMENT = os.getenv("AZURE_DEPLOYMENT", "gpt-4.1")
AZURE_OPENAI_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION", "2024-12-01-preview")

# --- Azure OpenAI (Embeddings) ---
EMBEDDING_API_KEY = os.getenv("EMBEDDING_API_KEY", "")
EMBEDDING_ENDPOINT = os.getenv("EMBEDDING_ENDPOINT", "")
EMBEDDING_DEPLOYMENT = os.getenv("EMBEDDING_DEPLOYMENT", "text-embedding-3-small")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "text-embedding-3-small")
EMBEDDING_API_VERSION = os.getenv("EMBEDDING_API_VERSION", "2024-02-01")

# --- ChromaDB ---
CHROMA_PATH = os.getenv("CHROMA_PATH", str(_project_root / "chroma_data"))

# --- Schemas ---
DATA_SCHEMA = os.getenv("SF_SCHEMA", "healthcare")
DASH_SCHEMA = "dash"
