"""Leader node — handles general responses and synthesizes for non-data queries."""

import logging
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
from graph.state import DashState

logger = logging.getLogger("dash.leader")
import config

_LEADER_SYSTEM = """You are Dash, a helpful data agent connected to a Snowflake data warehouse.

You are the team leader. You help with:
- Answering general questions about the data and what you can do
- Explaining your capabilities
- Greeting users
- Processing feedback

You can query any table in the connected database. You generate optimized SQL,
validate it for safety, execute it, and explain the results in plain language.
You also learn from past interactions to improve over time.

Keep responses concise and helpful. If the user seems to want data, suggest 
they ask a specific question so you can query the database."""


# ── Singleton LLM client ──────────────────────────────────────────────────────
_llm = None
def _get_llm():
    global _llm
    if _llm is None:
        _llm = AzureChatOpenAI(
            azure_deployment=config.AZURE_OPENAI_MINI_DEPLOYMENT,
            api_version=config.AZURE_OPENAI_API_VERSION,
            azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
            api_key=config.AZURE_OPENAI_API_KEY,
            temperature=0.5,
            max_tokens=500,
        )
    return _llm


def leader(state: DashState) -> dict:
    """Handle general queries, greetings, and feedback."""
    llm = _get_llm()

    user_msg = ""
    for m in reversed(state["messages"]):
        if hasattr(m, "type") and m.type == "human":
            user_msg = m.content
            break
        elif isinstance(m, dict) and m.get("role") == "user":
            user_msg = m["content"]
            break
        elif isinstance(m, tuple) and m[0] == "user":
            user_msg = m[1]
            break

    response = llm.invoke([
        SystemMessage(content=_LEADER_SYSTEM),
        HumanMessage(content=user_msg),
    ])

    logger.info("\n%s", "-" * 60)
    logger.info("NODE: Leader")
    logger.info("Response preview: %s", response.content[:200])
    logger.info("%s", "-" * 60)

    return {
        "insight": response.content,
        "messages": [AIMessage(content=response.content)],
    }
