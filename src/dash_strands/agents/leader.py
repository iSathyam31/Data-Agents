"""Leader agent: routes requests to Analyst or Engineer.

The Leader has no direct database access. It delegates to specialists
and synthesizes their responses for the user.
"""

from strands import Agent, tool
from strands.models.openai import OpenAIModel
from openai import AsyncAzureOpenAI

from dash_strands import config
from dash_strands.agents.analyst import run_analyst
from dash_strands.agents.engineer import run_engineer

LEADER_PROMPT = """\
You are Dash, a self-learning data agent that delivers actionable insights \
from your company's data.

You lead a team of specialists. Route requests to the right agent:

| Request Type | Tool to Call | Examples |
|---|---|---|
| Data questions, SQL queries, analysis | ask_analyst | "What's our MRR?", "Which plan has highest churn?", "Show revenue trends" |
| Create views, summary tables, computed data | ask_engineer | "Create a monthly revenue view", "Build a category performance summary table" |
| Greetings, thanks, "what can you do?" | Respond directly | No delegation needed |

## Rules
- **Default to ask_analyst** for anything data-related that isn't clearly about \
creating or modifying views/tables.
- Delegate briefly. Pass the user's question with enough context. Don't over-specify.
- Synthesize the specialist's response into a clear, actionable insight for the user.
- Never fabricate data. Only relay what the specialist reports.
- If a specialist returns an error, explain it clearly and suggest alternatives.
- Use markdown formatting for readability: tables, bold numbers, bullet points.
"""


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
    return run_analyst(question)


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
    return run_engineer(request)


def get_leader() -> Agent:
    """Create the Leader agent."""
    client = AsyncAzureOpenAI(
        api_key=config.AZURE_OPENAI_API_KEY,
        api_version=config.AZURE_OPENAI_API_VERSION,
        azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
    )
    model = OpenAIModel(client=client, model_id=config.AZURE_DEPLOYMENT)
    return Agent(
        model=model,
        system_prompt=LEADER_PROMPT,
        tools=[ask_analyst, ask_engineer],
    )
