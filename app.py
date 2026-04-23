"""Dash — Self-learning Data Agent (Streamlit UI)."""

import sys
from pathlib import Path

# Ensure src/ is importable
sys.path.insert(0, str(Path(__file__).parent / "src"))

import streamlit as st

st.set_page_config(page_title="Dash", page_icon="📊", layout="wide")


# ── Sidebar ──────────────────────────────────────────────────────────────────
with st.sidebar:
    st.header("📊 Dash")
    st.markdown(
        """
        A **self-learning data agent** with 3 specialists:

        | Agent | Role |
        |---|---|
        | **Leader** | Routes your questions |
        | **Analyst** | Answers data questions (read-only SQL) |
        | **Engineer** | Creates views & tables in `dash` schema |

        Dash learns from every interaction and gets better over time.

        ---
        **Powered by** Strands Agents + postgres-mcp + ChromaDB
        """
    )
    if st.button("🗑️ Clear Chat"):
        st.session_state.messages = []
        st.session_state.pop("leader", None)
        st.rerun()


# ── Initialize ───────────────────────────────────────────────────────────────
if "messages" not in st.session_state:
    st.session_state.messages = []

if "leader" not in st.session_state:
    with st.spinner("Starting Dash..."):
        from dash_strands.agents.leader import get_leader

        st.session_state.leader = get_leader()

# ── Title ────────────────────────────────────────────────────────────────────
st.title("📊 Dash")
st.caption("Ask anything about your data. Dash routes to the right specialist automatically.")

# ── Display chat history ─────────────────────────────────────────────────────
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# ── Chat input ───────────────────────────────────────────────────────────────
if prompt := st.chat_input("Ask Dash anything about your data..."):
    # Show user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Get and show assistant response
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            try:
                response = st.session_state.leader(prompt)
                response_text = str(response)
            except Exception as e:
                response_text = f"⚠️ Error: {e}"
        st.markdown(response_text)

    st.session_state.messages.append({"role": "assistant", "content": response_text})
