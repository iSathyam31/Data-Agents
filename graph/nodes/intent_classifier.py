"""Intent classifier — cheap routing with gpt-4o-mini."""

import logging
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage
from graph.state import DashState
import config

logger = logging.getLogger("dash.intent_classifier")

_SYSTEM_PROMPT = """You are an intent classifier for a data agent system.
Classify the user's message into exactly one of these categories:

- data_question: User wants to query data, get metrics, see trends, analyze numbers
- infra_request: User wants to create a view, build a summary table, set up computed data
- feedback: User is correcting a previous answer or providing feedback on results
- general: Greetings, general questions, help requests, anything not data-related

Respond with ONLY the category name, nothing else."""

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
            temperature=0,
            max_tokens=20,
        )
    return _llm


def intent_classifier(state: DashState) -> dict:
    """Classify user intent using the cheap mini model."""
    llm = _get_llm()
    # Get the last user message
    last_msg = ""
    for m in reversed(state["messages"]):
        if hasattr(m, "type") and m.type == "human":
            last_msg = m.content
            break
        elif isinstance(m, dict) and m.get("role") == "user":
            last_msg = m["content"]
            break
        elif isinstance(m, tuple) and m[0] == "user":
            last_msg = m[1]
            break

    response = llm.invoke([
        SystemMessage(content=_SYSTEM_PROMPT),
        HumanMessage(content=last_msg),
    ])

    intent = response.content.strip().lower()
    if intent not in ("data_question", "infra_request", "feedback", "general"):
        logger.warning("Unknown intent '%s', defaulting to data_question", intent)
        intent = "data_question"  # Default to data question

    logger.info("\n%s", "=" * 60)
    logger.info("NODE: Intent Classifier")
    logger.info("User message: %s", last_msg[:100])
    logger.info("Classified intent: %s", intent)
    logger.info("%s", "=" * 60)

    return {"intent": intent}
