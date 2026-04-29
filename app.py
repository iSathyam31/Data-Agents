"""Dash — Self-learning Data Agent (Streamlit UI)."""

import sys
from pathlib import Path

# Ensure src/ is importable
sys.path.insert(0, str(Path(__file__).parent / "src"))

import streamlit as st

st.set_page_config(page_title="Dash | Healthcare Data Agent", page_icon="🏥", layout="wide")

# ── Sidebar ──────────────────────────────────────────────────────────────────
with st.sidebar:
    st.header("🏥 Dash")
    st.markdown("Your **self-learning healthcare data agent**.")
    
    st.markdown("### 👨‍💻 Agent Roles")
    st.markdown(
        """
        - 🧭 **Leader**: Understands intent & routes questions.
        - 📊 **Analyst**: Reads data & answers questions via SQL.
        - 🛠️ **Engineer**: Builds views & tables in the `dash` schema.
        """
    )
    
    st.markdown("---")
    st.markdown("### 🧠 Capabilities")
    st.markdown(
        """
        - Learns from SQL errors.
        - Remembers complex business rules.
        - Seamlessly searches 15+ hospital tables.
        """
    )

    st.markdown("---")
    if st.button("🗑️ Clear Chat History", use_container_width=True):
        st.session_state.messages = []
        st.session_state.pop("leader", None)
        st.rerun()

    st.markdown("<br><br><br><div style='text-align: center; color: gray; font-size: 0.8em;'>Powered by Strands Agents + Snowflake + ChromaDB</div>", unsafe_allow_html=True)


# ── Initialize ───────────────────────────────────────────────────────────────
if "messages" not in st.session_state:
    st.session_state.messages = []

if "leader" not in st.session_state:
    with st.spinner("Starting Dash and connecting to Snowflake..."):
        from dash_strands.agents.leader import get_leader
        st.session_state.leader = get_leader()

# ── Main Header Layout ───────────────────────────────────────────────────────
col1, col2 = st.columns([3, 1])

with col1:
    st.title("Welcome to Dash")
    st.markdown("Ask anything about the **Hospital Database**. Dash will automatically route to the right specialist.")

with col2:
    with st.expander("💡 Sample Questions"):
        st.markdown("""
        * "What is our overall bed occupancy rate?"
        * "Show me the top 10 prescribed medications."
        * "What percentage of revenue comes from insurance?"
        * "Create a view for daily admissions summary."
        """)

st.divider()

# ── Chat Interface ───────────────────────────────────────────────────────────
chat_container = st.container()

with chat_container:
    if not st.session_state.messages:
        st.info("👋 Hi! I'm Dash. I can analyze patient admissions, medical records, billing, and more. What would you like to know today?")

    for msg in st.session_state.messages:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

# ── Chat Input ───────────────────────────────────────────────────────────────
if prompt := st.chat_input("Ask Dash about admissions, revenue, or patient demographics..."):
    # Show user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Get and show assistant response
    with st.chat_message("assistant"):
        with st.spinner("Analyzing data..."):
            try:
                response = st.session_state.leader(prompt)
                response_text = str(response)
            except Exception as e:
                response_text = f"⚠️ Error: {e}"
        st.markdown(response_text)

    st.session_state.messages.append({"role": "assistant", "content": response_text})
