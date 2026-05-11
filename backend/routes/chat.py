"""Chat API routes — handles user messages and returns agent responses."""

import json
import re
from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from backend.agent_session import get_or_create_session

router = APIRouter()


# ── Request / Response Models ─────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = "default"


class ChartSpec(BaseModel):
    type: str = "bar"
    title: str = ""
    x_label: str = ""
    y_label: str = ""
    data: Optional[list] = None
    series: Optional[list] = None


class ChatResponse(BaseModel):
    message: str
    chart: Optional[dict] = None
    sql: Optional[str] = None
    session_id: str


# ── Helpers ───────────────────────────────────────────────────────────────────

def extract_sql(text: str) -> Optional[str]:
    m = re.search(r"```sql\s*(.*?)```", text, re.DOTALL | re.IGNORECASE)
    return m.group(1).strip() if m else None


def extract_chart(text: str) -> tuple[Optional[dict], str]:
    """Extract ```chart JSON block from response text."""
    m = re.search(r"```chart\s*(.*?)```", text, re.DOTALL | re.IGNORECASE)
    if not m:
        return None, text
    raw_json = m.group(1).strip()
    # Fix common hallucination: JS expressions like "AAAA".replace(" ","")
    raw_json = re.sub(
        r'"([^"]*)"\.replace\([^)]*\)',
        lambda x: json.dumps(x.group(1).replace(" ", "")),
        raw_json,
    )
    try:
        spec = json.loads(raw_json)
    except json.JSONDecodeError:
        return None, text
    cleaned = text[: m.start()].rstrip() + text[m.end() :]
    return spec, cleaned.strip()


# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    """Send a message to the Dash agent and get a response."""
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    leader = get_or_create_session(request.session_id)

    try:
        response = leader(request.message)
        response_text = str(response)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Agent error: {e}")

    # Parse chart and SQL from the response
    chart_spec, cleaned_text = extract_chart(response_text)
    sql = extract_sql(cleaned_text)

    return ChatResponse(
        message=cleaned_text,
        chart=chart_spec,
        sql=sql,
        session_id=request.session_id,
    )


@router.post("/chat/clear")
def clear_session(session_id: str = "default"):
    """Clear a chat session to start fresh."""
    from backend.agent_session import clear_session as _clear
    _clear(session_id)
    return {"status": "cleared", "session_id": session_id}
