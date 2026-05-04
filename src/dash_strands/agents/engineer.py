"""Engineer agent: dash schema builder and knowledge updater.

Uses direct SQLAlchemy connection. Writes are scoped to the 'dash' schema
by an application-level regex guard in the sql_dash_write tool.
"""

from strands import Agent
from strands.models.openai import OpenAIModel
from openai import AsyncAzureOpenAI

from dash_strands import config
from dash_strands.instructions import build_engineer_instructions
from dash_strands.tools.sql_dash_write import execute_sql_dash
from dash_strands.tools.sql_readonly import execute_sql_readonly
from dash_strands.tools.introspect_schema import introspect_schema
from dash_strands.tools.knowledge_search import knowledge_search
from dash_strands.tools.update_knowledge import update_knowledge
from dash_strands.tools.save_learning import save_learning


def _make_model() -> OpenAIModel:
    client = AsyncAzureOpenAI(
        api_key=config.AZURE_OPENAI_API_KEY,
        api_version=config.AZURE_OPENAI_API_VERSION,
        azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
    )
    return OpenAIModel(client=client, model_id=config.AZURE_DEPLOYMENT)


def create_engineer() -> Agent:
    """Create a persistent Engineer agent with the dynamic system prompt."""
    return Agent(
        model=_make_model(),
        system_prompt=build_engineer_instructions(),
        tools=[
            execute_sql_dash,
            execute_sql_readonly,
            introspect_schema,
            knowledge_search,
            update_knowledge,
            save_learning,
        ],
    )


def run_engineer(agent: Agent, request: str) -> str:
    """Run the Engineer agent. Pass the persistent agent instance for history retention."""
    result = agent(request)
    return str(result)
