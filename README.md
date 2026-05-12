<div align="center">
  <h1>🧠 Dash: Self Learning Data Agents</h1>
  <p><em>A self-learning data agent system built with LangGraph, Azure OpenAI, Snowflake, and Qdrant.</em></p>

  <p>
    <a href="https://python.org/"><img src="https://img.shields.io/badge/Python-3.10+-blue.svg?logo=python&logoColor=white" alt="Python"></a>
    <a href="https://streamlit.io/"><img src="https://img.shields.io/badge/Streamlit-FF4B4B.svg?logo=streamlit&logoColor=white" alt="Streamlit"></a>
    <a href="https://www.snowflake.com/"><img src="https://img.shields.io/badge/Snowflake-29B5E8.svg?logo=snowflake&logoColor=white" alt="Snowflake"></a>
    <a href="https://azure.microsoft.com/"><img src="https://img.shields.io/badge/Azure_OpenAI-0089D6.svg?logo=microsoft-azure&logoColor=white" alt="Azure"></a>
    <a href="https://www.langchain.com/langgraph"><img src="https://img.shields.io/badge/LangGraph-1C3C3C.svg?logo=langchain&logoColor=white" alt="LangGraph"></a>
    <a href="https://qdrant.tech/"><img src="https://img.shields.io/badge/Qdrant-EF295F.svg?logo=qdrant&logoColor=white" alt="Qdrant"></a>
  </p>
  
  <img src="assets/Dash.png" alt="Dash Application Interface" width="800" style="border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
</div>

---

Inspired by [Ashpreet Bedi's Dash](https://ashpreetbedi.com/dash-v2), rebuilt from scratch with an enhanced multi-node architecture on top of the **TPC-DS 100TB** benchmark dataset.

Dash answers natural language questions about retail data by generating, validating, executing, and interpreting SQL — and **learns from every interaction**.

## ✨ Key Features
- **Natural Language to SQL**: Converts complex business questions into optimized Snowflake SQL.
- **Self-Learning**: Captures and reuses successful query patterns and error corrections.
- **Cost Protection**: 4 layers of credit protection to prevent expensive Snowflake queries.
- **Multi-Agent Architecture**: 9 specialized nodes orchestrated by LangGraph.

---

## 🏗️ Architecture

```text
User ──► Intent Classifier (gpt-4o-mini)
              │
              ├── data_question / infra_request ──► Context Retrieval
              │                                        │
              │                          ┌─────────────┼─────────────┐
              │                          ▼             ▼             │
              │                       Analyst      Engineer          │
              │                          │             │             │
              │                     SQL Validator      │             │
              │                      │       │         │             │
              │                 Executor  ◄─retry      │             │
              │                      │       │         │             │
              │                 Interpreter   │        │             │
              │                      │        │        │             │
              │              Learning Evaluator│       │             │
              │                      │        │        │             │
              ├── general / feedback ──► Leader │      │             │
              │                          │     │       │             │
              ▼                          ▼     ▼       ▼             │
             END ◄───────────────────────┴─────┴───────┘             │
                                                                     │
                                   ┌─────────────────────────────────┘
                                   ▼
                         validation_failed / execution_failed ──► END
```

> **9 specialized nodes** + 3 helper nodes (*retry, validation_failed, execution_failed*) connected via conditional edges with a max 3-retry loop.

---

## 🛠️ Tech Stack

| Component | Technology | Description |
|-----------|-----------|-------------|
| 🎼 **Orchestration** | **LangGraph** | StateGraph for routing and flow control |
| 🧠 **LLM** | **Azure OpenAI** | `gpt-4o` (analyst, engineer, interpreter) + `gpt-4o-mini` (intent, leader) |
| 🔤 **Embeddings** | **Azure OpenAI** | `text-embedding-3-small` |
| 🗄️ **Vector Store** | **Qdrant** | Persistent storage for knowledge & learnings (supports both local memory and Cloud) |
| ❄️ **Database** | **Snowflake** | `SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL` (100TB) |
| 🎨 **Frontend** | **Streamlit** | Interactive chat UI |

---

## 📊 Dataset: TPC-DS SF100TCL

A **100TB retail benchmark** featuring:
- 📈 **7 Fact Tables**: `STORE_SALES` (~300B rows), `CATALOG_SALES`, `WEB_SALES`, `STORE_RETURNS`, `CATALOG_RETURNS`, `WEB_RETURNS`, `INVENTORY`.
- 🗂️ **17 Dimension Tables**: `CUSTOMER` (~100M rows), `ITEM` (~500K rows), `DATE_DIM`, `STORE`, `CUSTOMER_ADDRESS`, etc.
- 🕒 **Scope**: 1998–2002 across 3 sales channels (Store, Catalog, Web).

---

## 📂 Project Structure

<details>
<summary>Click to expand</summary>

```text
Dash-LangGraph/
├── app.py                        # Streamlit UI
├── config.py                     # Central configuration (env vars)
├── requirements.txt              # Python dependencies
│
├── db/
│   ├── __init__.py               # Snowflake connection factory (read + write engines)
│   └── schema_cache.py           # INFORMATION_SCHEMA → local JSON cache
│
├── graph/
│   ├── state.py                  # DashState TypedDict (shared graph state)
│   ├── edges.py                  # 4 conditional routing functions
│   ├── builder.py                # Graph assembly (nodes + edges + compile)
│   ├── graph_view.py             # Export compiled graph as PNG
│   └── nodes/
│       ├── intent_classifier.py  # Classifies intent (gpt-4o-mini)
│       ├── context_retrieval.py  # Fetches knowledge + learnings + schema
│       ├── analyst.py            # Generates read-only SQL (gpt-4o)
│       ├── sql_validator.py      # Validates SQL (regex, no LLM)
│       ├── executor.py           # Runs SQL on Snowflake
│       ├── interpreter.py        # Converts results to insights (gpt-4o)
│       ├── learning_evaluator.py # Saves learnings from interactions
│       ├── leader.py             # Handles general/greeting messages
│       └── engineer.py           # Creates views in DASH schema (gpt-4o)
│
├── vectorstore/
│   └── __init__.py               # Qdrant wrapper (knowledge + learnings)
│
├── knowledge/
│   ├── tables/                   # 24 table metadata JSONs (all TPC-DS tables)
│   ├── queries/                  # 8 validated SQL patterns
│   └── business/
│       └── rules.json            # Metrics, gotchas, join patterns
│
├── scripts/
│   ├── snowflake_setup.sql       # Snowflake setup (warehouse, roles, grants)
│   ├── cache_schema.py           # One-time schema fetch → JSON
│   └── load_knowledge.py         # Embed knowledge into Qdrant
│
├── .env.example                  # Environment variable template
└── .gitignore
```
</details>

---

## 🚀 Setup & Installation

### 1. Clone & Environment
```bash
git clone <repo-url>
cd Dash-LangGraph
python -m venv venv

# Windows
.\venv\Scripts\activate
# macOS/Linux
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Environment Variables
```bash
cp .env.example .env
```
Update `.env` with your credentials. *(See [Environment Variables Reference](#-environment-variables-reference) below)*.

### 4. Snowflake Setup
Run `scripts/snowflake_setup.sql` in a Snowflake worksheet as **ACCOUNTADMIN**. This creates:
- `COMPUTE_WH` — XSMALL warehouse (auto-suspend 60s)
- `DASH_DB.DASH` — Schema for Engineer-created views
- Required Roles: `DASH_ANALYST` (read-only) & `DASH_ENGINEER` (read/write to DASH schema)
- Resource monitor capping at **10 credits/month**

### 5. Initialization (One-Time)
Cache the schema to avoid expensive queries, and load knowledge into ChromaDB:
```bash
python scripts/cache_schema.py
python scripts/load_knowledge.py --recreate
```

### 6. Launch App
```bash
streamlit run app.py
```

*(Optional)* Visualize the graph structure:
```bash
python graph/graph_view.py
```

---

## 🛡️ Cost Protection & Optimizations

Running on a 100TB dataset requires aggressive cost controls:

| Layer | Mechanism | How it Works |
|-------|-----------|--------------|
| **1. Knowledge-first** | Skip SQL generation | Pre-validated queries matched via semantic search. |
| **2. SQL Validator** | Prevent expensive scans | Auto-injects `LIMIT`, warns on missing date filters, blocks DML. |
| **3. Schema Cache** | Avoid info queries | Fetched once, stored as local JSON, kept in memory. |
| **4. Vector Store**| Zero Snowflake cost | Qdrant stores pre-calculated vectors. Fallbacks to in-memory for testing, saving I/O. |

**Performance Gains:** Connection pooling, LLM singletons, and memory caching reduce per-request overhead, bringing response times down to ~18-20s after an initial warmup.

---

## 🔄 Self-Learning Loop

The `Learning Evaluator` node captures two types of data:
1. 🐛 **Error Corrections**: When a SQL error is fixed after a retry, the `error → fix` pattern is saved.
2. 🎯 **Successful Patterns**: When a query runs successfully, it's saved as a reusable pattern.

These are stored in Qdrant and retrieved by the Context node for future queries.

---

## 💬 Example Questions

Try these out in the Streamlit app:
> *"What is the total revenue by sales channel for 2001?"*  
> *"Show me the top 10 product categories by sales amount"*  
> *"What's the return rate comparison across store, catalog, and web?"*  
> *"Rank all stores by revenue for year 2000"*  
> *"How does customer spending vary by education level?"*  
> *"Create a view that shows monthly revenue trends by channel"*  

---

## 🔑 Environment Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `AZURE_OPENAI_API_KEY` | Azure OpenAI API key | *Required* |
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI endpoint URL | *Required* |
| `AZURE_OPENAI_CHAT_DEPLOYMENT`| GPT-4o deployment name | `gpt-4o` |
| `AZURE_OPENAI_MINI_DEPLOYMENT`| GPT-4o-mini deployment name | `gpt-4o-mini` |
| `AZURE_OPENAI_EMBEDDING_DEPLOYMENT`| Embedding model deployment | `text-embedding-3-small`|
| `AZURE_OPENAI_API_VERSION` | Azure API version | `2024-12-01-preview`|
| `SNOWFLAKE_ACCOUNT` | Snowflake account identifier | *Required* |
| `SNOWFLAKE_USER` | Snowflake username | *Required* |
| `SNOWFLAKE_PASSWORD` | Snowflake password | *Required* |
| `SNOWFLAKE_DATABASE` | Database name | `SNOWFLAKE_SAMPLE_DATA`|
| `SNOWFLAKE_SCHEMA` | Schema name | `TPCDS_SF100TCL` |
| `SNOWFLAKE_WAREHOUSE` | Warehouse name | `COMPUTE_WH` |
| `SNOWFLAKE_ROLE` | Default role | `SYSADMIN` |
| `QDRANT_URL` | Qdrant Cluster URL | *Optional (defaults to memory)* |
| `QDRANT_API_KEY` | Qdrant API Key | *Optional* |
