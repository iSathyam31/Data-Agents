"""Engineer agent: dash schema builder and knowledge updater.

Uses direct SQLAlchemy connection. Writes are scoped to the 'dash' schema
by an application-level regex guard in the sql_dash_write tool.
"""

from strands import Agent
from strands.models.openai import OpenAIModel
from openai import AsyncAzureOpenAI

from dash_strands import config
from dash_strands.tools.sql_dash_write import execute_sql_dash
from dash_strands.tools.sql_readonly import execute_sql_readonly
from dash_strands.tools.introspect_schema import list_schemas, list_tables, describe_table
from dash_strands.tools.knowledge_search import knowledge_search
from dash_strands.tools.update_knowledge import update_knowledge
from dash_strands.tools.save_learning import save_learning

ENGINEER_PROMPT = """\
You are the Data Engineer on the Dash team. Your role is to build and maintain \
analytics infrastructure in the 'dash' schema.

## Workflow
1. Search knowledge to understand existing tables, views, and business rules.
2. Use list_schemas, list_tables, describe_table to inspect the current schema state.
3. Use execute_sql_readonly to SELECT from ecommerce tables for data exploration.
4. Use execute_sql_dash to CREATE views, tables, or computed data in the 'dash' schema ONLY.
5. After creating any new object, register it in knowledge with update_knowledge.

## Rules
- You can ONLY create objects in the 'dash' schema. **NEVER** modify the 'ecommerce' schema.
- All CREATE statements MUST use 'dash.' prefix (e.g., CREATE VIEW dash.monthly_revenue AS ...).
- Source data is in the 'ecommerce' schema (e.g., ecommerce.orders, ecommerce.users).
- After creating any view or table, ALWAYS call update_knowledge to register it.
- Prefer views over materialized tables unless performance requires it.
- If you encounter an error, save the fix with save_learning.

## Before Creating Anything
1. Check if a similar object already exists in knowledge.
2. Inspect the source tables in 'ecommerce' to understand the data.
3. Plan the view/table schema before executing CREATE statements.
4. Use CREATE OR REPLACE VIEW when possible to make updates idempotent.
"""


def _get_model():
    client = AsyncAzureOpenAI(
        api_key=config.AZURE_OPENAI_API_KEY,
        api_version=config.AZURE_OPENAI_API_VERSION,
        azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
    )
    return OpenAIModel(client=client, model_id=config.AZURE_DEPLOYMENT)


def run_engineer(request: str) -> str:
    """Create and run the Engineer agent with dash-scoped SQL tools."""
    agent = Agent(
        model=_get_model(),
        system_prompt=ENGINEER_PROMPT,
        tools=[
            execute_sql_dash,
            execute_sql_readonly,
            list_schemas,
            list_tables,
            describe_table,
            knowledge_search,
            update_knowledge,
            save_learning,
        ],
    )
    result = agent(request)
    return str(result)
