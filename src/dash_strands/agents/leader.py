"""Leader agent: routes requests to Analyst or Engineer.

The Leader has no direct database access. It delegates to specialists
and synthesizes their responses for the user.

All three agents (Leader, Analyst, Engineer) are created once per session
via get_leader() and remain persistent — preserving conversation history
across turns, matching the Agno pattern of add_history_to_context=True.
"""

from strands import Agent, tool
from strands.models.openai import OpenAIModel
from openai import AsyncAzureOpenAI

from dash_strands import config
from dash_strands.instructions import build_leader_instructions
from dash_strands.agents.analyst import create_analyst, run_analyst
from dash_strands.agents.engineer import create_engineer, run_engineer


def get_leader() -> Agent:
    """Create all three agents and return the persistent Leader.

    The Analyst and Engineer are created here and captured in closures so that
    the ask_analyst / ask_engineer tool functions always call the same persistent
    agent instances, preserving conversation history across turns.
    """
    client = AsyncAzureOpenAI(
        api_key=config.AZURE_OPENAI_API_KEY,
        api_version=config.AZURE_OPENAI_API_VERSION,
        azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
    )
    model = OpenAIModel(client=client, model_id=config.AZURE_DEPLOYMENT)

    # Create persistent specialist agents — shared for the lifetime of this session
    _analyst = create_analyst()
    _engineer = create_engineer()

    @tool
    def ask_analyst(question: str) -> str:
        """Route data questions, SQL queries, and analysis requests to the Data Analyst.

        The Analyst has read-only access to the database, searches knowledge for
        context, writes SQL, executes it, and returns insights.

        Args:
            question: The data question or analysis request to send to the Analyst.

        Returns:
            The Analyst's response with data insights.
        """
        return run_analyst(_analyst, question)

    @tool
    def ask_engineer(request: str) -> str:
        """Route infrastructure requests to the Data Engineer.

        The Engineer can create views, summary tables, and computed data in the
        'dash' schema. It registers new objects in the knowledge base.

        Args:
            request: Description of the view, table, or infrastructure to create.

        Returns:
            The Engineer's response confirming what was created.
        """
        return run_engineer(_engineer, request)

    return Agent(
        model=model,
        system_prompt=build_leader_instructions(),
        tools=[ask_analyst, ask_engineer],
    )
