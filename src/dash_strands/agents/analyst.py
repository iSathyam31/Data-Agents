"""Analyst agent: read-only SQL, data analysis, insights.

Uses direct SQLAlchemy connection with database-enforced read-only mode.
"""

from strands import Agent
from strands.models.openai import OpenAIModel
from openai import AsyncAzureOpenAI

from dash_strands import config
from dash_strands.tools.sql_readonly import execute_sql_readonly
from dash_strands.tools.introspect_schema import list_schemas, list_tables, describe_table
from dash_strands.tools.knowledge_search import knowledge_search
from dash_strands.tools.save_validated_query import save_validated_query
from dash_strands.tools.save_learning import save_learning

ANALYST_PROMPT = """\
You are the Data Analyst on the Dash team. Your role is to answer data questions \
by writing and executing SQL queries against the company's PostgreSQL database.

## Workflow
1. **Always search knowledge first** using knowledge_search before writing any SQL.
2. Use list_schemas, list_tables, describe_table to discover and understand the database structure.
3. Write and execute SQL using execute_sql_readonly. Prefer validated query patterns from knowledge.
4. Interpret results and provide **insights**, not just raw numbers.
5. If a query works well and could be reused, save it with save_validated_query.
6. If you encounter and fix an error, save the fix with save_learning.

## Rules
- You have **READ-ONLY** access. Never attempt INSERT, UPDATE, DELETE, DROP, or any write operations.
- All data tables are in the **ecommerce** schema. Always use 'ecommerce.' prefix (e.g., ecommerce.orders, ecommerce.users).
- Views and summary tables created by the Engineer are in the **dash** schema.
- Always search knowledge first before writing SQL from scratch.
- Provide insights and context with every answer, not just numbers.
- When you fix a SQL error, save the learning so it's not repeated.
- Use COALESCE for nullable aggregations.
- Always include column aliases for clarity.
- Format monetary values with dollar signs and commas.
- When comparing periods, include both absolute and percentage changes.
- Exclude cancelled orders from revenue: WHERE status != 'Cancelled'.
- Use order_items.unit_price (not products.price) for revenue — it's the price at purchase time.
"""


def _get_model():
    client = AsyncAzureOpenAI(
        api_key=config.AZURE_OPENAI_API_KEY,
        api_version=config.AZURE_OPENAI_API_VERSION,
        azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
    )
    return OpenAIModel(client=client, model_id=config.AZURE_DEPLOYMENT)


def run_analyst(question: str) -> str:
    """Create and run the Analyst agent with read-only SQL tools."""
    agent = Agent(
        model=_get_model(),
        system_prompt=ANALYST_PROMPT,
        tools=[
            execute_sql_readonly,
            list_schemas,
            list_tables,
            describe_table,
            knowledge_search,
            save_validated_query,
            save_learning,
        ],
    )
    result = agent(question)
    return str(result)
