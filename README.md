# Dash — Self-Learning Data Agent

Dash is a conversational AI that lets anyone ask plain English questions about a company's database and get real answers backed by live SQL. Instead of requiring analysts to write queries, you just ask: *"What's our total revenue?"* or *"Which product category performs best?"* and Dash figures out the SQL, runs it, and returns an insight.

Dash is a port of [agno-agi/dash](https://github.com/agno-agi/dash), reimplemented using the **AWS Strands Agents SDK** and connected to a **Snowflake-hosted PostgreSQL** ecommerce database. The defining feature is that Dash **learns from every interaction** — successful queries, discovered fixes, and user corrections are all stored in a vector database and retrieved automatically on future questions.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Architecture Overview](#architecture-overview)
3. [The Three-Agent System](#the-three-agent-system)
4. [Database Structure](#database-structure)
5. [How Strands Agents Works](#how-strands-agents-works)
6. [Tools — The Agent's Hands](#tools--the-agents-hands)
7. [The Self-Learning System (ChromaDB)](#the-self-learning-system-chromadb)
8. [Knowledge Base Files](#knowledge-base-files)
9. [Request Flow End-to-End](#request-flow-end-to-end)
10. [Project Structure](#project-structure)
11. [Setup and Running](#setup-and-running)

---

## Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| UI | [Streamlit](https://streamlit.io) | Chat interface in the browser |
| Agent Framework | [Strands Agents SDK](https://github.com/strands-agents/sdk-python) | LLM orchestration, tool calling, agentic loop |
| LLM | Azure OpenAI GPT-4.1 | Language understanding and reasoning |
| Embeddings | Azure OpenAI text-embedding-3-small | Turning text into vectors for semantic search |
| Database | Snowflake-hosted PostgreSQL | Source of truth for all ecommerce data |
| DB Driver | SQLAlchemy + psycopg2 | Python-to-Postgres connection layer |
| Vector Store | [ChromaDB](https://www.trychroma.com) (embedded) | Local vector database for knowledge and learnings |

---

## Architecture Overview

Dash uses a **hierarchical multi-agent architecture** with a Leader that delegates to two specialists. Each agent has a scoped role and a different set of tools — no agent can do more than it is supposed to.

```
┌─────────────────────────────────────────┐
│             Streamlit (app.py)          │
│         User types a question           │
└───────────────────┬─────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │       LEADER          │
        │   (agents/leader.py)  │
        │                       │
        │  No DB access.        │
        │  Routes to the right  │
        │  specialist and       │
        │  synthesizes answer.  │
        └──────────┬────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
┌───────────────┐   ┌──────────────────┐
│   ANALYST     │   │    ENGINEER      │
│ analyst.py    │   │  engineer.py     │
│               │   │                  │
│ Reads data.   │   │ Builds analytics │
│ Answers data  │   │ objects in the   │
│ questions     │   │ dash schema.     │
│ with SQL.     │   │                  │
└──────┬────────┘   └────────┬─────────┘
       │                     │
       ▼                     ▼
 PostgreSQL             PostgreSQL
 (SELECT only)          (dash.* only)
```

The pattern where the Leader calls Analyst and Engineer is called **agent-as-tool** — the specialist agents are registered as `@tool` functions on the Leader. When GPT-4.1 decides to call `ask_analyst`, Strands Agents executes the `run_analyst()` function which spins up a fresh Analyst agent with its own tools and context.

---

## The Three-Agent System

### Leader (`src/dash_strands/agents/leader.py`)

The Leader is the **only agent the user interacts with**. It is initialized once when the Streamlit app starts and persists for the session.

**What it does:**
- Understands the intent of the user's message
- Decides whether to call `ask_analyst` (data questions) or `ask_engineer` (build something)
- Handles simple conversational messages directly without delegating
- Takes the specialist's raw answer and formats it into clean, readable markdown for the user

**What it cannot do:**
- It has no database tools. It cannot run SQL. It only delegates.

**Key implementation detail:** The Leader's two tools (`ask_analyst`, `ask_engineer`) are defined in the same file using the `@tool` decorator from Strands. These tool functions simply call `run_analyst()` and `run_engineer()` from the other agent files.

---

### Analyst (`src/dash_strands/agents/analyst.py`)

The Analyst is a **read-only data question answerer**. A new Analyst agent is created fresh for every question the Leader delegates.

**What it does:**
1. Searches the knowledge base for relevant context before writing any SQL
2. Inspects the database schema if needed (list tables, describe columns)
3. Writes a SQL SELECT query
4. Executes it against the database
5. Interprets the numbers into a useful insight (not just raw data)
6. Saves good queries and discovered fixes back into the knowledge base

**Read-only enforcement:** The Analyst uses a dedicated SQLAlchemy engine that passes `default_transaction_read_only=on` as a PostgreSQL startup parameter. Any write attempt is rejected at the database level before it executes.

**Tools available to the Analyst:**

| Tool | What it does |
|---|---|
| `execute_sql_readonly` | Runs a SELECT query and returns results as a formatted table |
| `list_schemas` | Lists all schemas in the database |
| `list_tables` | Lists all tables/views in a given schema |
| `describe_table` | Returns column names, types, and constraints for a table |
| `knowledge_search` | Searches ChromaDB for relevant context before writing SQL |
| `save_validated_query` | Saves a working query to ChromaDB for future reuse |
| `save_learning` | Saves an error fix or gotcha to ChromaDB to avoid repeating it |

---

### Engineer (`src/dash_strands/agents/engineer.py`)

The Engineer is a **schema builder**. It creates views and summary tables in the `dash` schema on request. Like the Analyst, a new instance is created per request.

**What it does:**
1. Searches knowledge for existing objects and business rules
2. Inspects source tables in `ecommerce` to understand the data
3. Creates views or tables in the `dash` schema using `CREATE OR REPLACE VIEW`
4. Registers every new object in the knowledge base so the Analyst can discover and use it

**Write isolation:** The Engineer uses a separate SQLAlchemy engine with full write access. However, before any SQL reaches the database, the `execute_sql_dash` tool runs regex pattern matching against the statement. Any `DROP`, `ALTER`, `TRUNCATE`, `DELETE`, `INSERT`, or `UPDATE` targeting the `ecommerce` or `public` schemas is **blocked at the application level** and never sent to the database.

**Tools available to the Engineer:**

| Tool | What it does |
|---|---|
| `execute_sql_dash` | Runs DDL/DML scoped to `dash.*` (blocks writes to ecommerce/public) |
| `execute_sql_readonly` | Runs SELECT queries on ecommerce tables for exploration |
| `list_schemas` | Lists all schemas in the database |
| `list_tables` | Lists tables in a given schema |
| `describe_table` | Returns column details for a table |
| `knowledge_search` | Searches ChromaDB for context |
| `update_knowledge` | Registers a newly created dash view/table in ChromaDB |
| `save_learning` | Saves fixes to ChromaDB |

---

## Database Structure

The database runs on **Snowflake's PostgreSQL-compatible interface** and is divided into two schemas:

### `ecommerce` schema — source data (read-only for agents)

| Table | Description |
|---|---|
| `users` | Customer accounts — name, email, registration date |
| `categories` | Product categories (Electronics, Clothing, etc.) |
| `products` | Product catalog — name, price, stock, category |
| `orders` | Order headers — user, date, status, total_amount |
| `order_items` | Line items per order — product, quantity, unit_price |
| `payments` | Payment records — method, amount, status |
| `reviews` | Product reviews — star rating, comment |
| `shipping_details` | Delivery tracking — carrier, tracking number, delivered date |

**Important business rules baked into the agents:**
- Always filter `WHERE status != 'Cancelled'` when calculating revenue
- Use `order_items.unit_price` (price at time of purchase), not `products.price` (current price)
- `orders.total_amount` stores the pre-calculated order total
- Not every order has a shipping record (some may still be processing)

### `dash` schema — agent-managed analytics layer

This schema starts empty and is populated by the Engineer on request. Examples of what gets created here:
- `dash.monthly_revenue` — revenue aggregated by month
- `dash.category_performance` — sales metrics per category
- `dash.customer_segments` — customer groupings by spend tier

The Analyst automatically discovers these objects via the knowledge base and uses them in queries.

---

## How Strands Agents Works

[Strands Agents](https://github.com/strands-agents/sdk-python) is AWS's open-source Python framework for building LLM agents. The core concepts used in this project:

### `@tool` decorator

Any Python function decorated with `@tool` becomes a tool the LLM can call. Strands automatically generates a JSON Schema from the function's type hints and docstring, which is sent to the LLM as part of its context.

```python
from strands import tool

@tool
def execute_sql_readonly(sql: str) -> str:
    """Execute a read-only SQL query. Returns results as a formatted table."""
    ...
```

When the LLM decides this tool is needed, Strands calls the Python function with the arguments the LLM provides and feeds the return value back into the conversation.

### `Agent` class

An `Agent` combines a model, a system prompt, and a list of tools into an agentic loop. When called with a message, it runs until it either has a final answer or has exhausted its tool calls.

```python
from strands import Agent
from strands.models.openai import OpenAIModel

agent = Agent(
    model=OpenAIModel(client=azure_client, model_id="gpt-4.1"),
    system_prompt="You are the Data Analyst...",
    tools=[execute_sql_readonly, knowledge_search, ...],
)
result = agent("What is our total revenue?")
```

### Agentic loop (simplified)

```
User message → LLM thinks → LLM calls a tool → tool result fed back → LLM thinks → ...repeat... → LLM returns final answer
```

The LLM keeps calling tools until it has enough information to answer. Strands handles all the message formatting, tool dispatch, and loop management automatically.

### `OpenAIModel` with Azure

Strands uses the OpenAI SDK's client interface. Azure OpenAI is passed in as a compatible client:

```python
from openai import AsyncAzureOpenAI
from strands.models.openai import OpenAIModel

client = AsyncAzureOpenAI(
    api_key=...,
    api_version="2024-12-01-preview",
    azure_endpoint="https://your-resource.cognitiveservices.azure.com/",
)
model = OpenAIModel(client=client, model_id="gpt-4.1")
```

---

## Tools — The Agent's Hands

All tools live in `src/dash_strands/tools/`. Each file contains one or more `@tool` functions.

### `sql_readonly.py` — `execute_sql_readonly(sql)`

Executes a SELECT query using the read-only SQLAlchemy engine. Results are formatted as a columnar text table (max 100 rows). The read-only engine connects with `default_transaction_read_only=on`, so any accidental write statement is rejected by PostgreSQL itself.

### `sql_dash_write.py` — `execute_sql_dash(sql)`

Executes DDL/DML statements using the write SQLAlchemy engine. **Before** sending anything to the database, it runs three regex patterns against the SQL:
- Blocks `DROP/ALTER/TRUNCATE/DELETE/INSERT/UPDATE ... ecommerce.`
- Blocks `DROP/ALTER/TRUNCATE/DELETE/INSERT/UPDATE ... public.`
- Blocks `DROP SCHEMA`

If any pattern matches, the statement is rejected with an explanatory error — the database never sees it.

### `introspect_schema.py` — `list_schemas()`, `list_tables(schema)`, `describe_table(table_name, schema)`

Three tools that query PostgreSQL's `information_schema` views to let agents discover the database structure dynamically. This means agents can work even if the schema changes, rather than relying only on hardcoded knowledge.

### `knowledge_search.py` — `knowledge_search(query)`

Searches both ChromaDB collections (`dash_knowledge` and `dash_learnings`) using semantic similarity. Takes a natural language query, converts it to a vector using Azure OpenAI embeddings, and returns the most relevant documents. Agents are instructed to call this before writing any SQL.

### `save_validated_query.py` — `save_validated_query(name, description, sql)`

Saves a SQL query that executed successfully and gave correct results into `dash_knowledge`. Uses `upsert` so re-saving the same query name just updates it rather than duplicating.

### `save_learning.py` — `save_learning(problem, fix, context)`

Saves error fixes and data gotchas into `dash_learnings`. Each learning has a random ID so the collection accumulates over time. Future agents search this when things go wrong to find known fixes instantly.

### `update_knowledge.py` — `update_knowledge(object_name, object_type, description, columns, example_queries)`

Called by the Engineer after creating any view or table in `dash`. Saves a structured description of the new object into `dash_knowledge` so the Analyst can discover and query it in future conversations.

---

## The Self-Learning System (ChromaDB)

ChromaDB is a local vector database stored in the `chroma_data/` folder. It converts text documents into numeric vectors using Azure OpenAI embeddings, enabling **semantic search** — finding relevant content even when the wording doesn't exactly match.

### Two collections

**`dash_knowledge`** — Curated, high-quality knowledge. Contains:
- Table metadata (loaded from `knowledge/tables/*.json` at startup)
- Validated SQL query patterns (loaded from `knowledge/queries/*.sql` at startup)
- Business rules and metric definitions (loaded from `knowledge/business/*.json` at startup)
- Dash schema objects registered by the Engineer at runtime

**`dash_learnings`** — Auto-discovered fixes. Contains:
- SQL errors the Analyst encountered and corrected, saved automatically
- Data quality gotchas discovered during analysis
- This collection grows with every conversation

### The embedding function

`src/dash_strands/knowledge/store.py` defines `AzureEmbeddingFunction`, a custom ChromaDB embedding function that calls Azure OpenAI's `text-embedding-3-small` model. This is passed to every ChromaDB collection so that both storing and querying use the same model.

### How learning accumulates

1. **First question about revenue:** Analyst searches knowledge → finds the pre-loaded `total_revenue.sql` template → executes it → saves it again as a validated query (reinforcing it)
2. **SQL error occurs:** Analyst fixes it → calls `save_learning(problem, fix)` → learning stored in ChromaDB
3. **Next question about revenue:** Analyst searches knowledge → immediately finds both the validated SQL and any past fixes → gets the answer faster with no mistakes repeated

---

## Knowledge Base Files

The `knowledge/` directory contains hand-curated content loaded into ChromaDB by `scripts/load_knowledge.py` during setup. This gives Dash a head start — it knows the schema and has working queries before anyone has asked a single question.

### `knowledge/tables/` — 8 JSON files

One file per ecommerce table. Each contains:
- `table_name` — fully qualified name (e.g., `ecommerce.orders`)
- `table_description` — what the table contains
- `use_cases` — list of analytical purposes
- `data_quality_notes` — gotchas (e.g., "filter cancelled orders for revenue")
- `table_columns` — column name, type, and description for each column

**Tables covered:** `users`, `categories`, `products`, `orders`, `order_items`, `payments`, `reviews`, `shipping_details`

### `knowledge/queries/` — 9 SQL files

Pre-validated SQL queries that the Analyst can retrieve and adapt. Each file uses comment tags for metadata:

```sql
-- <query total_revenue>
-- <description>Total revenue from non-cancelled orders</description>
SELECT
    COALESCE(SUM(total_amount), 0) AS total_revenue,
    COUNT(*) AS total_orders
FROM ecommerce.orders
WHERE status != 'Cancelled';
```

**Queries included:** `total_revenue`, `monthly_revenue`, `revenue_by_category`, `top_products`, `order_status_breakdown`, `payment_method_analysis`, `customer_lifetime_value`, `avg_product_rating`, `shipping_carrier_performance`

### `knowledge/business/ecommerce_rules.json`

Defines 6 standard business metrics (Total Revenue, AOV, CLV, etc.) and 6 common gotchas (cancelled orders, unit_price vs product price, missing shipping records, etc.) so the Analyst always applies correct business logic.

---

## Request Flow End-to-End

**Example: User asks "What is our total revenue?"**

```
1. app.py
   └── st.chat_input receives "What is our total revenue?"
   └── Calls: st.session_state.leader("What is our total revenue?")

2. Leader Agent (Strands agentic loop)
   └── GPT-4.1 reasons: this is a data question → call ask_analyst
   └── Calls tool: ask_analyst(question="What is our total revenue?")

3. ask_analyst() function in leader.py
   └── Calls: run_analyst("What is our total revenue?")

4. run_analyst() creates a fresh Analyst Agent and calls it

5. Analyst Agent (Strands agentic loop)
   ├── GPT-4.1 reasons: search knowledge first
   ├── Calls tool: knowledge_search("total revenue")
   │   └── ChromaDB returns: total_revenue.sql template + orders table metadata
   │
   ├── GPT-4.1 has enough context, writes the SQL query
   ├── Calls tool: execute_sql_readonly("SELECT COALESCE(SUM(total_amount), 0) ...")
   │   └── SQLAlchemy connects to Snowflake Postgres with SSL
   │   └── Returns: "total_revenue | total_orders\n$124,530.00 | 87"
   │
   ├── GPT-4.1 interprets the result
   ├── Calls tool: save_validated_query("total_revenue", "...", sql)
   │   └── ChromaDB stores the query for future reuse
   │
   └── Returns final answer string to run_analyst()

6. ask_analyst() returns the Analyst's answer to the Leader

7. Leader Agent
   └── GPT-4.1 formats the answer into clean markdown
   └── Returns final response string

8. app.py
   └── st.markdown() renders the response in the chat
```

---

## Project Structure

```
Dash/
│
├── app.py                          ← Entry point. Streamlit chat UI.
├── requirements.txt                ← All Python dependencies
├── .env                            ← Secrets (not committed to git)
├── .env.example                    ← Template showing required variables
├── .gitignore                      ← Excludes .env, venv, chroma_data
│
├── src/
│   └── dash_strands/
│       ├── __init__.py
│       ├── config.py               ← Reads .env into Python constants
│       │
│       ├── db/
│       │   └── __init__.py         ← SQLAlchemy engine factories
│       │                              get_readonly_engine() — read-only
│       │                              get_write_engine()    — dash schema writes
│       │
│       ├── agents/
│       │   ├── __init__.py
│       │   ├── leader.py           ← Leader agent + ask_analyst/ask_engineer tools
│       │   ├── analyst.py          ← Analyst agent (read-only SQL + insights)
│       │   └── engineer.py         ← Engineer agent (dash schema builder)
│       │
│       ├── tools/
│       │   ├── __init__.py
│       │   ├── sql_readonly.py         ← execute_sql_readonly()
│       │   ├── sql_dash_write.py       ← execute_sql_dash() with schema guard
│       │   ├── introspect_schema.py    ← list_schemas(), list_tables(), describe_table()
│       │   ├── knowledge_search.py     ← knowledge_search()
│       │   ├── save_validated_query.py ← save_validated_query()
│       │   ├── save_learning.py        ← save_learning()
│       │   └── update_knowledge.py     ← update_knowledge()
│       │
│       └── knowledge/
│           └── store.py            ← ChromaDB client + Azure embedding function
│                                      get_knowledge_collection()
│                                      get_learnings_collection()
│
├── knowledge/                      ← Pre-curated knowledge files (loaded at setup)
│   ├── tables/                     ← 8 JSON files, one per ecommerce table
│   ├── queries/                    ← 9 validated SQL query files
│   └── business/                   ← Business rules and metric definitions
│
├── scripts/
│   ├── init_db.py                  ← Creates the 'dash' schema (run once)
│   └── load_knowledge.py           ← Loads knowledge/ files into ChromaDB (run once)
│
├── chroma_data/                    ← ChromaDB persistent storage (auto-created)
├── seed_data.py                    ← Seeds the ecommerce database with test data
└── venv/                           ← Python virtual environment
```

---

## Setup and Running

### Prerequisites

- Python 3.11+
- Access to the Snowflake PostgreSQL database (VPN required)
- Azure OpenAI API key with GPT-4.1 and text-embedding-3-small deployments

### 1. Create and activate the virtual environment

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```powershell
pip install -r requirements.txt
```

### 3. Configure environment variables

Copy `.env.example` to `.env` and fill in your values:

```
AZURE_OPENAI_API_KEY=...
AZURE_OPENAI_ENDPOINT=https://your-resource.cognitiveservices.azure.com/
AZURE_DEPLOYMENT=gpt-4.1
AZURE_OPENAI_API_VERSION=2024-12-01-preview

EMBEDDING_API_KEY=...
EMBEDDING_ENDPOINT=https://your-resource.cognitiveservices.azure.com/
EMBEDDING_DEPLOYMENT=text-embedding-3-small
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_API_VERSION=2024-02-01

PGHOST=your-host.snowflake.app
PGPORT=5432
PGUSER=snowflake_admin
PGPASSWORD=your-password
PGDATABASE=postgres
```

### 4. Initialize the database (run once)

Creates the `dash` schema in PostgreSQL:

```powershell
python scripts/init_db.py
```

### 5. Load the knowledge base (run once)

Populates ChromaDB with table metadata, validated queries, and business rules:

```powershell
python scripts/load_knowledge.py
```

### 6. Run the app

```powershell
streamlit run app.py
```

The app opens at `http://localhost:8501`.

### Example questions to try

| Question | Agent used |
|---|---|
| What is our total revenue? | Analyst |
| Show me monthly revenue for the last 6 months | Analyst |
| Which product category has the highest sales? | Analyst |
| Who are our top 10 customers by spend? | Analyst |
| What is our order cancellation rate? | Analyst |
| Which payment method is most popular? | Analyst |
| Create a monthly revenue view in the dash schema | Engineer |
| Build a customer lifetime value summary table | Engineer |
