# Dash - Self-Learning Data Agent

Dash is an AI-powered conversational agent that lets anyone ask plain English questions about a massive retail dataset and get real answers backed by live SQL. Instead of requiring analysts to write queries, you just ask: *"What is our total store revenue for 2001?"* or *"Which channel has the highest profit margin?"* and Dash figures out the SQL, runs it, and returns an insight.

This version of Dash is built using the **AWS Strands Agents SDK** and is stress-tested against the **TPC-DS SF100TCL** benchmark dataset on Snowflake — a 100TB, ~300 billion row retail decision-support dataset covering store, catalog, and web sales channels.

The defining feature of Dash is that it **learns from every interaction**. Successful queries, discovered fixes, and user corrections are all stored in a local vector database and retrieved automatically on future questions.

![Dash UI](assets/Dash.png)

---

## 🏗️ Architecture Overview

Dash uses a **multi-agent architecture** with a Leader that delegates work to two specialists. Each agent has a specific job and different permissions.

```text
┌─────────────────────────────────────────┐
│             Streamlit (UI)              │
│         User types a question           │
└───────────────────┬─────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │       LEADER          │
        │                       │
        │  Routes to the right  │
        │  specialist and       │
        │  synthesizes answers. │
        └──────────┬────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
┌───────────────┐   ┌──────────────────┐
│   ANALYST     │   │    ENGINEER      │
│               │   │                  │
│ Answers data  │   │ Builds analytics │
│ questions     │   │ views in the     │
│ with SQL.     │   │ dash schema.     │
│ (READ ONLY)   │   │ (WRITE: dash.*)  │
└──────┬────────┘   └────────┬─────────┘
       │                     │
       ▼                     ▼
   Snowflake             Snowflake
(TPCDS_SF100TCL.*)      (dash.* only)
```

---

## 🤖 The Three-Agent System

### 1. Leader Agent
The Leader is the only agent you talk to directly. It understands your request and routes it to the **Analyst** (for data questions) or the **Engineer** (to build views or summaries). It has no direct database access — it synthesizes and explains.

### 2. Analyst Agent
The Analyst answers data questions.
- **Read-only** access to `SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.*` and `dash.*`.
- Searches the Knowledge Base before writing any SQL — reuses validated patterns.
- Executes SELECT queries, interprets results, and delivers insights with context.
- Saves successful queries and error fixes back to the Knowledge Base automatically.

### 3. Engineer Agent
The Engineer builds analytics infrastructure.
- **Write access only to `dash` schema** — never touches source data.
- Creates `VIEW`s and summary tables (e.g. `dash.monthly_store_revenue`) on top of TPC-DS source tables.
- Registers every new object in the Knowledge Base so the Analyst can discover and use it.

---

## 🛒 Database Structure

The source data is `SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL` — Snowflake's built-in TPC-DS 100TB sample.

### `TPCDS_SF100TCL` schema (Source Data — Read Only)

**Fact Tables** (large — always filter by date):

| Table | Approx. Rows | Description |
|-------|-------------|-------------|
| `STORE_SALES` | ~300B | In-store transactions |
| `CATALOG_SALES` | ~144B | Catalog channel orders |
| `WEB_SALES` | ~72B | Web channel orders |
| `STORE_RETURNS` | ~30B | In-store returns |
| `CATALOG_RETURNS` | ~16B | Catalog returns |
| `WEB_RETURNS` | ~8B | Web returns |
| `INVENTORY` | ~12B | Daily warehouse inventory snapshots |

**Dimension Tables (17):** `CUSTOMER`, `CUSTOMER_ADDRESS`, `CUSTOMER_DEMOGRAPHICS`, `DATE_DIM`, `TIME_DIM`, `ITEM`, `STORE`, `PROMOTION`, `CALL_CENTER`, `CATALOG_PAGE`, `WEB_SITE`, `WEB_PAGE`, `WAREHOUSE`, `SHIP_MODE`, `REASON`, `HOUSEHOLD_DEMOGRAPHICS`, `INCOME_BAND`

### `dash` schema (Agent Workspace — Write Access)
Starts empty. The Engineer populates this with views like `dash.monthly_store_revenue`, `dash.top_items_by_category`, `dash.store_performance_ranking`, etc.

---

## 🧠 The Self-Learning System

Dash gets smarter over time using a local **ChromaDB** vector database.

When you ask a question, Dash converts it to an embedding using Azure OpenAI and searches its memory for relevant context before writing any SQL.

**Two types of memory:**
1. **Knowledge** — Pre-loaded table metadata (24 TPC-DS tables), 12 validated SQL query patterns, and a business rules file covering KPIs, channel definitions, and critical gotchas (date filter warnings, SCD Type 2 patterns, NULL SK handling, Y/N VARCHAR flags, etc.).
2. **Learnings** — When Dash fixes a bad query or encounters a data quirk, it saves the fix. Future similar questions automatically benefit from past mistakes.

---

## ⚠️ Key TPC-DS Gotchas

Dash's knowledge base is pre-loaded with these, but worth knowing:

- **Always filter fact tables by date** — `STORE_SALES` has ~300B rows. Without a `DATE_DIM` join and `D_YEAR` filter, queries will be very expensive.
- **SCD Type 2 dimensions** — `ITEM`, `STORE`, `WEB_SITE`, `CALL_CENTER` have historical versions. Always add `WHERE I_REC_END_DATE IS NULL` (or equivalent) for current records.
- **Y/N flags are VARCHAR** — `D_HOLIDAY`, `C_PREFERRED_CUST_FLAG`, etc. Use `= 'Y'`, not `= 1`.
- **TPC-DS date range** — Data covers years 1998–2002.
- **Cross-channel totals** — Must `UNION ALL` across `STORE_SALES`, `CATALOG_SALES`, and `WEB_SALES`.

---

## 🚀 Setup and Running

### Prerequisites
- Python 3.11+
- Snowflake account with access to `SNOWFLAKE_SAMPLE_DATA`
- Azure OpenAI API key (used for both chat and embeddings)

### 1. Create a Virtual Environment and Install Dependencies
```bash
python -m venv venv
venv\Scripts\activate      # Windows
# source venv/bin/activate  # macOS/Linux
pip install -r requirements.txt
```

### 2. Configure Environment Variables
Create a `.env` file in the project root:

```text
# Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://<your-endpoint>.openai.azure.com/
AZURE_OPENAI_API_KEY=<your-key>
API_VERSION=2025-01-01-preview
CHAT_DEPLOYMENT=gpt-4o
EMBEDDING_DEPLOYMENT=text-embedding-3-small

# Snowflake
SF_ACCOUNT=<your-account>
SF_USER=dash_user
SF_PASSWORD=<your-password>
SF_DATABASE=SNOWFLAKE_SAMPLE_DATA
SF_SCHEMA=TPCDS_SF100TCL
SF_WAREHOUSE=COMPUTE_WH
SF_ROLE_ANALYST=dash_analyst_role
SF_ROLE_ENGINEER=dash_engineer_role

# ChromaDB
CHROMA_PATH=./chroma_data
```

### 3. Run Snowflake Setup (Once)
Execute `snowflake_setup/setup.sql` as `ACCOUNTADMIN` in your Snowflake account. This creates the roles, user, and grants read access to `SNOWFLAKE_SAMPLE_DATA`.

### 4. Load the Knowledge Base (Once)
Loads all 24 table JSONs, 12 SQL patterns, and business rules into ChromaDB:
```bash
python scripts/load_knowledge.py --recreate
```

### 5. Run the App
```bash
streamlit run app.py
```
Opens at `http://localhost:8501`.

*(Check out `Sample_Questions.md` for questions to try!)*

---

## 📁 Project Structure

```text
.
├── app.py                        # Streamlit chat UI
├── requirements.txt
├── .env / .env.example
│
├── knowledge/                    # Pre-loaded into ChromaDB on first run
│   ├── tables/                   # 24 TPC-DS table metadata JSONs
│   ├── queries/                  # 12 validated SQL query patterns
│   └── business/
│       └── tpcds_retail_rules.json
│
├── scripts/
│   └── load_knowledge.py         # python scripts/load_knowledge.py --recreate
│
├── snowflake_setup/
│   └── 01_setup.sql              # Run once as ACCOUNTADMIN
│
└── src/dash_strands/
    ├── config.py                 # Env var loader
    ├── agents/                   # leader.py · analyst.py · engineer.py
    ├── db/                       # Snowflake engine factory
    ├── knowledge/store.py        # ChromaDB + Azure embeddings
    └── tools/                    # SQL, introspect, search, save tools
```

---

## 🛠️ Tech Stack

| Layer | Technology | Role |
|-------|-----------|------|
| **Agent Framework** | [AWS Strands Agents SDK](https://github.com/strands-agents/sdk-python) | Multi-agent orchestration |
| **LLM** | Azure OpenAI — `gpt-4o` | Reasoning, SQL generation, synthesis |
| **Embeddings** | Azure OpenAI — `text-embedding-3-small` | Semantic knowledge search |
| **Data Warehouse** | Snowflake (`SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL`) | 100TB TPC-DS retail dataset |
| **Vector Store** | ChromaDB (local persistent) | Knowledge base + learnings memory |
| **UI** | Streamlit | Chat interface |
| **Language** | Python 3.11+ | — |

---

## ⚠️ Limitations & Known Issues

- **Query cost** — Fact tables like `STORE_SALES` have ~300B rows. Queries without a `DATE_DIM` year filter will scan the full table and may be slow or expensive. Dash's prompts enforce date filters, but complex or vague questions may bypass them.
- **TPC-DS date range** — All data covers years 1998–2002. Asking about "current" or "recent" data will return no results.
- **ChromaDB is local** — The vector store lives in `./chroma_data` on disk. It is not shared across machines. Each environment needs its own `load_knowledge.py` run.
- **Snowflake sample data is read-only** — `SNOWFLAKE_SAMPLE_DATA` is a shared Snowflake database. The `dash` schema for agent-built views must live in a separate writable database/schema that you provision.
- **No streaming** — Responses appear all at once after the agent finishes. Long multi-step queries may feel slow.
- **SQL extraction is heuristic** — The "View SQL" expander uses regex to find SQL in responses. Complex multi-block responses may not extract cleanly.

---

## 🙏 Credits

- **Inspiration** — [Dash v2](https://github.com/agno-agi/agno/tree/main/cookbook/examples/apps/dash) by [Ashpreet Bedi](https://github.com/ashpreetbedi) / [Agno](https://github.com/agno-agi/agno). This project replicates the Dash v2 concept using AWS Strands Agents instead of the Agno framework.
- **Dataset** — [TPC-DS](https://www.tpc.org/tpcds/) benchmark dataset, provided as `SNOWFLAKE_SAMPLE_DATA` in Snowflake.
- **Agent SDK** — [AWS Strands Agents](https://github.com/strands-agents/sdk-python)
- **LLM & Embeddings** — [Azure OpenAI Service](https://azure.microsoft.com/en-us/products/ai-services/openai-service)
