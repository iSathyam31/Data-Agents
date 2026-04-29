# Dash — Self-Learning Data Agent (Snowflake Edition)

Dash is an AI-powered conversational agent that lets anyone ask plain English questions about a company's database and get real answers backed by live SQL. Instead of requiring analysts to write queries, you just ask: *"What's our average length of stay?"* or *"Which department generates the most revenue?"* and Dash figures out the SQL, runs it, and returns an insight.

This version of Dash is built using the **AWS Strands Agents SDK** and is connected to a **Snowflake** data warehouse running a massive **Healthcare & Hospital Management** database. 

The defining feature of Dash is that it **learns from every interaction**. Successful queries, discovered fixes, and user corrections are all stored in a local vector database and retrieved automatically on future questions!

---

## 🏗️ Architecture Overview

Dash uses a **multi-agent architecture** with a "Leader" that delegates work to two "Specialists". Each agent has a specific job and different permissions.

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
        │  formats the answer.  │
        └──────────┬────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
┌───────────────┐   ┌──────────────────┐
│   ANALYST     │   │    ENGINEER      │
│               │   │                  │
│ Answers data  │   │ Builds analytics │
│ questions     │   │ objects in the   │
│ with SQL.     │   │ database.        │
│ (READ ONLY)   │   │ (WRITE ACCESS)   │
└──────┬────────┘   └────────┬─────────┘
       │                     │
       ▼                     ▼
   Snowflake             Snowflake
 (healthcare.*)        (dash.* only)
```

---

## 🤖 The Three-Agent System

### 1. Leader Agent
The Leader is the only agent you talk to directly. It understands what you want and decides whether to hand your request to the **Analyst** (to read data) or the **Engineer** (to build something). It has no database access itself.

### 2. Analyst Agent
The Analyst's job is to answer your questions. 
- It has **Read-Only** access to the Snowflake database.
- Before it writes any SQL, it searches the **Knowledge Base** to see if it already knows the answer.
- It executes SELECT queries and turns the raw data into helpful insights.
- If it writes a great query, it saves it to the Knowledge Base for next time.

### 3. Engineer Agent
The Engineer's job is to build analytics infrastructure.
- It has **Write Access**, but *only* to a specific schema called `dash`.
- It cannot modify the raw source data.
- It creates SQL `VIEW`s and summary tables so that future questions are easier to answer.
- Whenever it builds a new view, it documents it in the Knowledge Base so the Analyst knows it exists.

---

## 🏥 Database Structure

The Snowflake database (`HOSPITAL_DB`) is divided into two schemas:

### `healthcare` schema (Source Data - Read Only)
Contains 15 robust tables simulating a real hospital:
- **Operations:** `departments`, `doctors`, `wards`, `rooms`
- **Patients:** `patients`, `insurance_providers`, `patient_insurance`
- **Patient Journey:** `appointments`, `admissions`, `medical_records`
- **Clinical:** `medications`, `prescriptions`, `lab_tests`, `test_results`
- **Finance:** `billing`

### `dash` schema (Agent Workspace - Write Access)
This schema starts empty! The Engineer agent will populate this with useful views (like `dash.daily_admissions` or `dash.revenue_summary`) when you ask it to.

---

## 🧠 The Self-Learning System

Dash gets smarter over time using a local vector database called **ChromaDB**. 

When you ask a question, Dash converts your question into a "vector" (a mathematical representation of meaning) using Azure OpenAI, and searches its memory for similar concepts.

**It stores two types of memory:**
1. **Knowledge:** Pre-validated SQL queries, table documentation, and business rules (like how to calculate "Bed Occupancy Rate").
2. **Learnings:** If Dash writes a bad SQL query and gets an error from Snowflake, it will fix the error and *save the fix* to its memory. The next time you ask a similar question, it remembers the mistake and avoids it!

---

## 🚀 Setup and Running

### Prerequisites
- Python 3.11+
- [uv](https://github.com/astral-sh/uv) (recommended Python package manager)
- A Snowflake Account
- Azure OpenAI API key

### 1. Install Dependencies
```bash
uv pip install -r requirements.txt
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env` and fill in your values:

```text
# Snowflake Configuration
SF_ACCOUNT=your_account_identifier
SF_USER=dash_user
SF_PASSWORD=your_password
SF_DATABASE=HOSPITAL_DB
SF_SCHEMA=healthcare
SF_WAREHOUSE=COMPUTE_WH
SF_ROLE_ANALYST=dash_analyst_role
SF_ROLE_ENGINEER=dash_engineer_role

# Azure OpenAI
AZURE_OPENAI_API_KEY=...
AZURE_OPENAI_ENDPOINT=...
# ... (see .env.example)
```

### 3. Load the Knowledge Base (Run Once)
This step reads the hospital documentation and validated queries and injects them into the agent's memory.
```bash
uv run python scripts/load_knowledge.py --recreate
```

### 4. Run the App!
Start the Streamlit chat interface:
```bash
uv run streamlit run app.py
```
The app will open at `http://localhost:8501`. 

*(Check out `Sample_Questions.md` for some great questions to ask!)*
