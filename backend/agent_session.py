"""Agent session management — creates and caches Leader agent instances per session."""

from __future__ import annotations

import threading
from typing import Dict

from strands import Agent

from dash_strands.agents.leader import get_leader

_lock = threading.Lock()
_sessions: Dict[str, Agent] = {}


def get_or_create_session(session_id: str) -> Agent:
    """Return the Leader agent for the given session, creating it if needed."""
    with _lock:
        if session_id not in _sessions:
            _sessions[session_id] = get_leader()
        return _sessions[session_id]


def clear_session(session_id: str) -> None:
    """Remove a session's agent so next call creates a fresh one."""
    with _lock:
        _sessions.pop(session_id, None)
