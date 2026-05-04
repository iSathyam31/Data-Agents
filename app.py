"""Dash — Self-learning Data Agent (Streamlit UI)."""

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "src"))

import streamlit as st

st.set_page_config(
    page_title="Dash | Retail Data Agent",
    page_icon="🛒",
    layout="wide",
    initial_sidebar_state="expanded",
)

# ── CSS ───────────────────────────────────────────────────────────────────────
st.markdown("""
<style>
/* ── Main chat area ─────────────────────────────────── */
.block-container {
    padding-top: 2.5rem;
    padding-bottom: 2rem;
    max-width: 100% !important;
    padding-left: 2rem;
    padding-right: 2rem;
}

/* ── Sidebar ────────────────────────────────────────── */
[data-testid="stSidebar"] {
    background: #111318;
    border-right: 1px solid #1e2128;
    min-width: 260px !important;
    max-width: 260px !important;
}
[data-testid="stSidebar"] > div { padding: 1.4rem 1rem; }

/* Hide default sidebar header chrome */
[data-testid="stSidebarHeader"] { display: none; }

/* ── Agent badges ───────────────────────────────────── */
.badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.74rem;
    font-weight: 600;
    margin: 2px 3px 2px 0;
    letter-spacing: 0.02em;
}
.badge-leader   { background: #1c2e4a; color: #7aabf7; }
.badge-analyst  { background: #1a3327; color: #5dba7d; }
.badge-engineer { background: #3d2e0a; color: #f0b740; }

/* ── Section label ──────────────────────────────────── */
.section-label {
    font-size: 0.65rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.12em;
    color: #555;
    margin: 1.4rem 0 0.5rem 0;
}

/* ── Sample questions ───────────────────────────────── */
.sample-q {
    font-size: 0.76rem;
    color: #666;
    font-style: italic;
    line-height: 1.8;
    cursor: default;
}

/* ── Footer ─────────────────────────────────────────── */
.sidebar-footer {
    font-size: 0.65rem;
    color: #333;
    text-align: center;
    padding-top: 1rem;
    margin-top: 1.5rem;
    border-top: 1px solid #1e2128;
    letter-spacing: 0.05em;
}

/* ── Brand header ───────────────────────────────────── */
.brand-name {
    font-size: 1.45rem;
    font-weight: 700;
    letter-spacing: -0.5px;
    color: #f0f0f0;
    line-height: 1;
}
.brand-sub {
    font-size: 0.78rem;
    color: #555;
    margin-top: 3px;
    margin-bottom: 1.5rem;
}
</style>
""", unsafe_allow_html=True)


# ── Helper ────────────────────────────────────────────────────────────────────
def extract_sql(text: str) -> str | None:
    m = re.search(r"```sql\s*(.*?)```", text, re.DOTALL | re.IGNORECASE)
    return m.group(1).strip() if m else None


# ── Session state ─────────────────────────────────────────────────────────────
if "messages" not in st.session_state:
    st.session_state.messages = []
if "sql_map" not in st.session_state:
    # maps message index (assistant) -> SQL string
    st.session_state.sql_map = {}

if "leader" not in st.session_state:
    with st.spinner("Connecting to Snowflake and loading knowledge base..."):
        from dash_strands.agents.leader import get_leader
        st.session_state.leader = get_leader()


# ════════════════════════════════════════════════════════════════════════════
# SIDEBAR — info panel
# ════════════════════════════════════════════════════════════════════════════
with st.sidebar:
    # Brand
    st.markdown('<div class="brand-name">🛒 Dash</div>', unsafe_allow_html=True)
    st.markdown('<div class="brand-sub">TPC-DS SF100TCL · Snowflake</div>', unsafe_allow_html=True)

    # Agents
    st.markdown('<div class="section-label">Agents</div>', unsafe_allow_html=True)
    st.markdown(
        '<span class="badge badge-leader">🧭 Leader</span>'
        '<span class="badge badge-analyst">📊 Analyst</span>'
        '<span class="badge badge-engineer">🛠️ Engineer</span>',
        unsafe_allow_html=True,
    )

    # Sample questions
    st.markdown('<div class="section-label">Try asking</div>', unsafe_allow_html=True)
    samples = [
        "Total store revenue for 2001?",
        "Compare all 3 channels by profit.",
        "Top 10 items by category in 2001.",
        "Stores with highest return rate?",
        "Create a monthly revenue view.",
        "Low inventory across warehouses.",
    ]
    for q in samples:
        st.markdown(f'<div class="sample-q">· {q}</div>', unsafe_allow_html=True)

    # Clear + footer
    st.markdown('<div style="margin-top:1.4rem;"></div>', unsafe_allow_html=True)
    if st.button("🗑️ Clear Chat", use_container_width=True):
        st.session_state.messages = []
        st.session_state.sql_map = {}
        st.session_state.pop("leader", None)
        st.rerun()

    st.markdown(
        '<div class="sidebar-footer">Strands Agents · Snowflake · ChromaDB</div>',
        unsafe_allow_html=True,
    )


# ════════════════════════════════════════════════════════════════════════════
# MAIN — chat
# ════════════════════════════════════════════════════════════════════════════
st.markdown('<div class="brand-name">Welcome to Dash</div>', unsafe_allow_html=True)
st.markdown(
    '<div class="brand-sub">Ask anything about the TPC-DS retail dataset — '
    'Dash routes to the right specialist automatically.</div>',
    unsafe_allow_html=True,
)

if not st.session_state.messages:
    st.markdown(
        "> 👋 Hi! I'm **Dash**. Ask me anything about store sales, returns, "
        "promotions, inventory, or customer demographics across store, catalog, "
        "and web channels."
    )
else:
    for i, msg in enumerate(st.session_state.messages):
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])
            # Show SQL expander under assistant messages that had a query
            if msg["role"] == "assistant" and i in st.session_state.sql_map:
                with st.expander("🔍 View SQL", expanded=False):
                    st.code(st.session_state.sql_map[i], language="sql")

if prompt := st.chat_input("Ask about sales, returns, promotions, inventory, or customers..."):
    st.session_state.messages.append({"role": "user", "content": prompt})

    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            try:
                response = st.session_state.leader(prompt)
                response_text = str(response)
            except Exception as e:
                response_text = f"⚠️ Error: {e}"
        st.markdown(response_text)

        sql = extract_sql(response_text)
        if sql:
            assistant_idx = len(st.session_state.messages)  # index it will get
            st.session_state.sql_map[assistant_idx] = sql
            with st.expander("🔍 View SQL", expanded=False):
                st.code(sql, language="sql")

    st.session_state.messages.append({"role": "assistant", "content": response_text})
    st.rerun()

