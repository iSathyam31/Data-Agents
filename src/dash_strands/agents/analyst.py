"""Analyst agent: read-only SQL, data analysis, insights.

Uses direct SQLAlchemy connection with database-enforced read-only mode.
The analyst is created once per session (persistent) so it retains conversation
history across turns, matching the Agno pattern of num_history_runs=5.
"""

from strands import Agent
from strands.models.openai import OpenAIModel
from openai import AsyncAzureOpenAI

from dash_strands import config
from dash_strands.instructions import build_analyst_instructions
from dash_strands.tools.sql_readonly import execute_sql_readonly
from dash_strands.tools.introspect_schema import introspect_schema
from dash_strands.tools.knowledge_search import knowledge_search
from dash_strands.tools.save_validated_query import save_validated_query
from dash_strands.tools.save_learning import save_learning


def _make_model() -> OpenAIModel:
    client = AsyncAzureOpenAI(
        api_key=config.AZURE_OPENAI_API_KEY,
        api_version=config.AZURE_OPENAI_API_VERSION,
        azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
    )
    return OpenAIModel(client=client, model_id=config.AZURE_DEPLOYMENT)


def create_analyst() -> Agent:
    """Create a persistent Analyst agent with the dynamic system prompt."""
    return Agent(
        model=_make_model(),
        system_prompt=build_analyst_instructions(),
        tools=[
            execute_sql_readonly,
            introspect_schema,
            knowledge_search,
            save_validated_query,
            save_learning,
        ],
    )


def run_analyst(agent: Agent, question: str) -> str:
    """Run the Analyst agent. Pass the persistent agent instance for history retention."""
    result = agent(question)
    return str(result)
