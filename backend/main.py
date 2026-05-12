"""FastAPI backend for Dash — Self-Learning Data Agent."""

import sys
import os
import warnings
import logging
import uuid
import json
from decimal import Decimal
from collections.abc import Generator

warnings.filterwarnings("ignore", category=PendingDeprecationWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning, module="langgraph")

# Ensure project root is on path for existing imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(name)-28s | %(levelname)-5s | %(message)s",
    datefmt="%H:%M:%S",
)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)
logging.getLogger("openai").setLevel(logging.WARNING)
logging.getLogger("chromadb").setLevel(logging.WARNING)
logging.getLogger("snowflake").setLevel(logging.WARNING)
logging.getLogger("urllib3").setLevel(logging.WARNING)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

import config
from graph.builder import build_graph
from langchain_core.messages import HumanMessage

logger = logging.getLogger("dash.api")

# ── App ───────────────────────────────────────────────────────────────────────
app = FastAPI(title="Dash API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Graph singleton ──────────────────────────────────────────────────────────
_graph = None

def _get_graph():
    global _graph
    if _graph is None:
        _graph = build_graph()
    return _graph


# ── Node status mapping ─────────────────────────────────────────────────────
NODE_STATUS = {
    "intent_classifier": {"icon": "🧠", "label": "Classifying intent..."},
    "context_retrieval": {"icon": "🔍", "label": "Retrieving knowledge and schema context..."},
    "analyst": {"icon": "📝", "label": "Generating SQL query..."},
    "sql_validator": {"icon": "✅", "label": "Validating SQL for safety..."},
    "executor": {"icon": "⚡", "label": "Executing query on Snowflake..."},
    "interpreter": {"icon": "💡", "label": "Interpreting results..."},
    "learning_evaluator": {"icon": "📚", "label": "Evaluating learnings..."},
    "leader": {"icon": "🤖", "label": "Composing response..."},
    "engineer": {"icon": "🛠️", "label": "Building database object..."},
    "analyst_retry": {"icon": "🔄", "label": "Retrying with error context..."},
    "validation_failed": {"icon": "❌", "label": "Validation failed"},
    "execution_failed": {"icon": "❌", "label": "Execution failed"},
}


# ── JSON serializer for Decimal ──────────────────────────────────────────────
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return float(o)
        return super().default(o)


def _serialize(obj: dict) -> str:
    return json.dumps(obj, cls=DecimalEncoder)


# ── Request / Response models ────────────────────────────────────────────────
class ChatRequest(BaseModel):
    message: str
    session_id: str | None = None


class ConnectionInfo(BaseModel):
    database: str
    schema_name: str
    warehouse: str
    role: str


# ── Routes ───────────────────────────────────────────────────────────────────

@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/connection")
def connection_info():
    return ConnectionInfo(
        database=config.SNOWFLAKE_DATABASE,
        schema_name=config.SNOWFLAKE_SCHEMA,
        warehouse=config.SNOWFLAKE_WAREHOUSE,
        role=config.SNOWFLAKE_ROLE,
    )


@app.post("/api/chat")
async def chat(request: ChatRequest):
    """Stream chat responses as Server-Sent Events."""
    session_id = request.session_id or uuid.uuid4().hex
    logger.info("\n%s", "=" * 60)
    logger.info("NEW REQUEST  |  session=%s", session_id[:12])
    logger.info("User message: %s", request.message[:120])
    logger.info("=" * 60)

    def generate() -> Generator[str, None, None]:
        graph = _get_graph()

        initial_state = {
            "messages": [HumanMessage(content=request.message)],
            "intent": "",
            "current_agent": "",
            "knowledge_context": [],
            "learnings_context": [],
            "schema_context": "",
            "generated_sql": "",
            "validation_result": {},
            "cost_estimate": {},
            "sql_result": None,
            "sql_error": None,
            "insight": "",
            "chart_config": None,
            "retry_count": 0,
            "learning_candidate": None,
            "session_id": session_id,
        }

        accumulated = {}

        try:
            for event in graph.stream(initial_state):
                for node_name, node_output in event.items():
                    status = NODE_STATUS.get(node_name, {"icon": "⏳", "label": f"Running {node_name}..."})
                    logger.info("%s  %s", status["icon"], status["label"])
                    yield f"data: {_serialize({'type': 'status', 'node': node_name, **status})}\n\n"

                    if isinstance(node_output, dict):
                        accumulated.update(node_output)

            # Build final response
            response_text = accumulated.get("insight", "I couldn't generate a response.")
            generated_sql = accumulated.get("generated_sql", "")
            sql_result = accumulated.get("sql_result")
            chart_config = accumulated.get("chart_config")
            validation = accumulated.get("validation_result", {})
            warnings_list = validation.get("warnings", [])

            result = {
                "type": "result",
                "response": response_text,
                "sql": generated_sql,
                "chart_config": chart_config,
                "warnings": warnings_list,
                "rows": None,
                "row_count": None,
            }

            if sql_result and sql_result.get("rows"):
                result["rows"] = sql_result["rows"]
                result["row_count"] = sql_result["row_count"]

            logger.info("-" * 60)
            logger.info("RESPONSE READY  |  sql=%s  rows=%s  chart=%s  warnings=%d",
                        bool(generated_sql), result["row_count"] or 0,
                        chart_config.get("chart_type") if chart_config else None,
                        len(warnings_list))
            logger.info("-" * 60)

            yield f"data: {_serialize(result)}\n\n"
            yield "data: {\"type\": \"done\"}\n\n"

        except Exception as e:
            logger.exception("Chat error")
            yield f"data: {_serialize({'type': 'error', 'message': str(e)})}\n\n"

    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@app.post("/api/reload-knowledge")
def reload_knowledge():
    """Reload the knowledge base."""
    from scripts.load_knowledge import main as load_kb
    load_kb(recreate=True)
    return {"status": "ok", "message": "Knowledge reloaded"}
