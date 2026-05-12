"""Dash: Self-Learning Data Agent (Streamlit UI)"""

import warnings
warnings.filterwarnings("ignore", category=PendingDeprecationWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning, module="langgraph")

import logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(name)-28s | %(levelname)-5s | %(message)s",
    datefmt="%H:%M:%S",
)
# Keep third-party loggers quiet
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)
logging.getLogger("openai").setLevel(logging.WARNING)
logging.getLogger("chromadb").setLevel(logging.WARNING)
logging.getLogger("snowflake").setLevel(logging.WARNING)
logging.getLogger("urllib3").setLevel(logging.WARNING)

import streamlit as st
import uuid
import json
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import config
from langchain_core.messages import HumanMessage, AIMessage


# ── Chart rendering helper ────────────────────────────────────────────────────
_PALETTES = [
    # Ocean Breeze — teals, cyans, blues
    ["#06b6d4", "#0ea5e9", "#14b8a6", "#22d3ee", "#38bdf8", "#2dd4bf", "#67e8f9", "#5eead4"],
    # Sunset Glow — warm oranges, pinks, reds
    ["#f59e0b", "#ef4444", "#ec4899", "#f97316", "#fb923c", "#f43f5e", "#e879f9", "#fbbf24"],
    # Aurora — purples, greens, electric accents
    ["#8b5cf6", "#10b981", "#6366f1", "#a78bfa", "#34d399", "#818cf8", "#c084fc", "#4ade80"],
]

_PLOTLY_LAYOUT = dict(
    paper_bgcolor="rgba(0,0,0,0)",
    plot_bgcolor="rgba(0,0,0,0)",
    font=dict(color="#e2e8f0", size=13),
    title_font=dict(color="#f1f5f9", size=16),
    legend=dict(bgcolor="rgba(0,0,0,0)", font=dict(color="#cbd5e1")),
    xaxis=dict(gridcolor="rgba(148,163,184,0.12)", zerolinecolor="rgba(148,163,184,0.12)"),
    yaxis=dict(gridcolor="rgba(148,163,184,0.12)", zerolinecolor="rgba(148,163,184,0.12)"),
    margin=dict(l=40, r=20, t=50, b=40),
)


def render_chart(chart_cfg: dict, rows: list, palette_idx: int = 0) -> go.Figure | None:
    """Build a Plotly figure from chart_config + result rows. Returns None on failure."""
    if not chart_cfg or not rows:
        return None
    colors = _PALETTES[palette_idx % len(_PALETTES)]
    try:
        df = pd.DataFrame(rows)
        # Coerce numeric columns to float (Snowflake returns Decimal)
        for col in df.columns:
            try:
                df[col] = df[col].apply(lambda v: float(v) if not isinstance(v, str) else v)
            except (TypeError, ValueError):
                pass
        chart_type = chart_cfg.get("chart_type", "bar")
        title = chart_cfg.get("title", "")
        x = chart_cfg.get("x")
        y_cols = chart_cfg.get("y", [])
        if isinstance(y_cols, str):
            y_cols = [y_cols]
        color = chart_cfg.get("color")
        orientation = chart_cfg.get("orientation", "v")
        labels = chart_cfg.get("labels", {})

        # Validate columns exist
        available = set(df.columns)
        if x and x not in available:
            # Try case-insensitive match
            match = [c for c in df.columns if c.lower() == x.lower()]
            x = match[0] if match else None
        y_cols = [_resolve_col(df, c) for c in y_cols]
        y_cols = [c for c in y_cols if c is not None]
        if color:
            cm = [c for c in df.columns if c.lower() == color.lower()]
            color = cm[0] if cm else None

        if not x or not y_cols:
            return None

        fig = None
        is_bar = chart_type in ("bar", "grouped_bar", "stacked_bar")
        barmode = "group" if chart_type == "grouped_bar" else "stack" if chart_type == "stacked_bar" else "relative"

        if chart_type in ("pie", "donut"):
            fig = px.pie(
                df, names=x, values=y_cols[0], title=title,
                color_discrete_sequence=colors,
                labels=labels,
                hole=0.45 if chart_type == "donut" else 0,
            )
        elif chart_type == "line":
            fig = px.line(
                df, x=x, y=y_cols, title=title,
                color_discrete_sequence=colors,
                labels=labels, markers=True,
            )
        elif chart_type == "area":
            fig = px.area(
                df, x=x, y=y_cols, title=title,
                color_discrete_sequence=colors,
                labels=labels,
            )
        elif is_bar and orientation == "h":
            # Horizontal bars: melt wide-form into long-form to avoid Plotly axis issues
            if len(y_cols) == 1 and not color:
                fig = px.bar(
                    df, x=y_cols[0], y=x, title=title,
                    orientation="h",
                    color_discrete_sequence=colors,
                    labels=labels,
                )
            else:
                melted = df.melt(id_vars=[x], value_vars=y_cols,
                                 var_name="variable", value_name="value")
                fig = px.bar(
                    melted, x="value", y=x, color="variable",
                    title=title, barmode=barmode, orientation="h",
                    color_discrete_sequence=colors,
                    labels={**labels, "value": "", "variable": ""},
                )
        elif is_bar:
            # Vertical bars
            if color and len(y_cols) == 1:
                fig = px.bar(
                    df, x=x, y=y_cols[0], color=color, title=title,
                    barmode=barmode,
                    color_discrete_sequence=colors,
                    labels=labels,
                )
            else:
                fig = px.bar(
                    df, x=x, y=y_cols, title=title,
                    barmode=barmode,
                    color_discrete_sequence=colors,
                    labels=labels,
                )

        if fig:
            fig.update_layout(**_PLOTLY_LAYOUT)
        return fig
    except Exception as exc:
        logging.getLogger("dash.chart").warning("Chart rendering failed: %s", exc, exc_info=True)
        return None


def _resolve_col(df: pd.DataFrame, name: str) -> str | None:
    """Case-insensitive column name resolver."""
    if name in df.columns:
        return name
    match = [c for c in df.columns if c.lower() == name.lower()]
    return match[0] if match else None


def _display_chart_glass(fig: go.Figure):
    """Render a Plotly figure inside a glassmorphism container."""
    st.markdown('<div class="glass-chart">', unsafe_allow_html=True)
    st.plotly_chart(fig, width="stretch")
    st.markdown('</div>', unsafe_allow_html=True)


st.set_page_config(
    page_title="Dash | Data Agent",
    page_icon="⚡",
    layout="wide",
)

# ── Custom CSS ────────────────────────────────────────────────────────────────
st.markdown("""
<style>
/* ── Base: deep teal/emerald dark gradient ── */
.stApp {
    background: linear-gradient(160deg, #0a0a0a 0%, #0d1117 25%, #0b1a2b 50%, #0a1628 75%, #0d1117 100%);
    background-attachment: fixed;
}

/* ── Animated mesh overlay for depth ── */
.stApp::before {
    content: '';
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: 
        radial-gradient(ellipse 600px 400px at 15% 20%, rgba(16, 185, 129, 0.06) 0%, transparent 70%),
        radial-gradient(ellipse 500px 500px at 85% 60%, rgba(6, 182, 212, 0.05) 0%, transparent 70%),
        radial-gradient(ellipse 400px 300px at 50% 90%, rgba(59, 130, 246, 0.04) 0%, transparent 70%);
    pointer-events: none;
    z-index: 0;
}

/* ── Sidebar: frosted glass ── */
section[data-testid="stSidebar"] {
    background: rgba(10, 15, 20, 0.85) !important;
    backdrop-filter: blur(24px) saturate(1.4);
    -webkit-backdrop-filter: blur(24px) saturate(1.4);
    border-right: 1px solid rgba(16, 185, 129, 0.12);
}
section[data-testid="stSidebar"] > div {
    background: transparent !important;
}

/* ── Header gradient text ── */
.gradient-header {
    background: linear-gradient(135deg, #10b981, #06b6d4, #3b82f6, #8b5cf6);
    background-size: 200% auto;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 3.2rem;
    font-weight: 800;
    letter-spacing: -1px;
    margin-bottom: 0;
    padding-bottom: 0;
}
.header-subtitle {
    color: rgba(148, 163, 184, 0.8);
    font-size: 1.05rem;
    margin-top: 4px;
    margin-bottom: 28px;
    font-weight: 400;
}

/* ── Sidebar brand ── */
.sidebar-brand {
    background: linear-gradient(135deg, #10b981, #06b6d4);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 1.8rem;
    font-weight: 800;
    letter-spacing: -0.5px;
}

/* ── Chat messages: glass cards ── */
.stChatMessage {
    background: rgba(15, 23, 35, 0.55) !important;
    border: 1px solid rgba(16, 185, 129, 0.1) !important;
    border-radius: 16px !important;
    backdrop-filter: blur(16px) saturate(1.2) !important;
    -webkit-backdrop-filter: blur(16px) saturate(1.2) !important;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.2), inset 0 1px 0 rgba(255, 255, 255, 0.03) !important;
    padding: 16px 20px !important;
    margin-bottom: 12px !important;
}

/* ── Chat input: floating glass bar ── */
.stChatInput,
.stChatInput *,
.stBottom, .stBottom > div,
div[data-testid="stBottom"],
div[data-testid="stBottom"] > div,
div[data-testid="stChatInput"],
div[data-testid="stChatInput"] > div,
.stChatInput > div > div,
.stChatInput [data-baseweb],
.stChatInput [data-baseweb] > div {
    background: transparent !important;
    background-color: transparent !important;
}
.stChatInput > div {
    background: rgba(15, 23, 35, 0.7) !important;
    border: 1px solid rgba(16, 185, 129, 0.2) !important;
    border-radius: 16px !important;
    backdrop-filter: blur(20px) saturate(1.3) !important;
    -webkit-backdrop-filter: blur(20px) saturate(1.3) !important;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.04) !important;
    transition: border-color 0.3s ease, box-shadow 0.3s ease !important;
}
.stChatInput > div:focus-within {
    border-color: rgba(16, 185, 129, 0.5) !important;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3), 0 0 20px rgba(16, 185, 129, 0.1), inset 0 1px 0 rgba(255, 255, 255, 0.04) !important;
}
.stChatInput textarea, .stChatInput input {
    color: #e2e8f0 !important;
    background: transparent !important;
    background-color: transparent !important;
}
.stChatInput textarea::placeholder, .stChatInput input::placeholder {
    color: rgba(148, 163, 184, 0.5) !important;
}
/* Send button inside chat input */
.stChatInput button {
    background: linear-gradient(135deg, #10b981, #06b6d4) !important;
    border: none !important;
    border-radius: 10px !important;
    transition: all 0.3s ease !important;
}
.stChatInput button:hover {
    box-shadow: 0 0 16px rgba(16, 185, 129, 0.4) !important;
}

/* ── Expander: subtle glass ── */
details {
    background: rgba(15, 23, 35, 0.4) !important;
    border: 1px solid rgba(16, 185, 129, 0.1) !important;
    border-radius: 12px !important;
    backdrop-filter: blur(12px) !important;
    margin-bottom: 8px !important;
}
details summary {
    color: #94a3b8 !important;
}

/* ── Buttons: gradient glass ── */
.stButton > button {
    background: linear-gradient(135deg, rgba(16, 185, 129, 0.2), rgba(6, 182, 212, 0.2)) !important;
    color: #e2e8f0 !important;
    border: 1px solid rgba(16, 185, 129, 0.25) !important;
    border-radius: 12px !important;
    font-weight: 600 !important;
    backdrop-filter: blur(8px) !important;
    transition: all 0.3s ease !important;
}
.stButton > button:hover {
    background: linear-gradient(135deg, rgba(16, 185, 129, 0.35), rgba(6, 182, 212, 0.35)) !important;
    border-color: rgba(16, 185, 129, 0.5) !important;
    box-shadow: 0 4px 20px rgba(16, 185, 129, 0.2) !important;
    color: #ffffff !important;
}

/* ── Dividers ── */
hr {
    border-color: rgba(16, 185, 129, 0.08) !important;
}

/* ── Connection info cards: glass tiles ── */
.conn-card {
    background: rgba(16, 185, 129, 0.06);
    border: 1px solid rgba(16, 185, 129, 0.12);
    border-radius: 10px;
    padding: 10px 14px;
    margin-bottom: 8px;
    backdrop-filter: blur(8px);
}
.conn-label {
    color: rgba(16, 185, 129, 0.7);
    font-size: 0.7rem;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    font-weight: 600;
    margin-bottom: 2px;
}
.conn-value {
    color: #e2e8f0;
    font-size: 0.9rem;
    font-family: 'JetBrains Mono', 'Fira Code', monospace;
}

/* ── Code blocks ── */
.stCodeBlock {
    border-radius: 12px !important;
    border: 1px solid rgba(16, 185, 129, 0.1) !important;
}

/* ── Dataframe ── */
.stDataFrame {
    border-radius: 12px !important;
    overflow: hidden;
    border: 1px solid rgba(16, 185, 129, 0.1) !important;
}

/* ── Subheaders ── */
section[data-testid="stSidebar"] h2, section[data-testid="stSidebar"] h3 {
    color: #94a3b8 !important;
    font-size: 0.85rem !important;
    text-transform: uppercase !important;
    letter-spacing: 1.5px !important;
    font-weight: 600 !important;
}

/* ── Scrollbar ── */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb {
    background: rgba(16, 185, 129, 0.2);
    border-radius: 3px;
}
::-webkit-scrollbar-thumb:hover { background: rgba(16, 185, 129, 0.4); }

/* ── Glassmorphism chart container ── */
.glass-chart {
    background: rgba(15, 23, 42, 0.45);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid rgba(148, 163, 184, 0.12);
    border-radius: 16px;
    padding: 12px 8px 4px 8px;
    margin: 12px 0;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255,255,255,0.05);
}

/* ── Pulse dot animation for live status ── */
.pulse-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #10b981;
    display: inline-block;
    animation: pulse 1.2s ease-in-out infinite;
}
@keyframes pulse {
    0%, 100% { opacity: 0.3; transform: scale(0.8); }
    50% { opacity: 1; transform: scale(1.2); }
}

/* ── Welcome section ── */
.welcome-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 60px 20px 30px 20px;
    text-align: center;
}
.welcome-heading {
    background: linear-gradient(135deg, #10b981, #06b6d4, #3b82f6, #8b5cf6);
    background-size: 200% auto;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 3.4rem;
    font-weight: 800;
    letter-spacing: -1px;
    margin-bottom: 8px;
}
.welcome-sub {
    color: rgba(148, 163, 184, 0.7);
    font-size: 1.1rem;
    font-weight: 400;
    margin-bottom: 48px;
}

/* ── Suggestion cards grid ── */
.suggestions-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    max-width: 720px;
    width: 100%;
    margin: 0 auto;
}
.suggestion-card {
    background: rgba(15, 23, 35, 0.5);
    border: 1px solid rgba(16, 185, 129, 0.12);
    border-radius: 14px;
    padding: 16px 18px;
    cursor: pointer;
    backdrop-filter: blur(12px);
    transition: all 0.25s ease;
    text-align: left;
}
.suggestion-card:hover {
    border-color: rgba(16, 185, 129, 0.4);
    background: rgba(16, 185, 129, 0.08);
    box-shadow: 0 4px 20px rgba(16, 185, 129, 0.1);
    transform: translateY(-1px);
}
.suggestion-icon {
    font-size: 1.3rem;
    margin-bottom: 6px;
}
.suggestion-text {
    color: #cbd5e1;
    font-size: 0.88rem;
    line-height: 1.4;
}

/* ── Suggestion buttons (override default) ── */
div[data-testid="stHorizontalBlock"] .stButton > button[kind="secondary"] ,
button[key^="suggestion_"] ,
div[data-testid="stColumns"] .stButton > button {
    background: rgba(15, 23, 35, 0.5) !important;
    border: 1px solid rgba(16, 185, 129, 0.12) !important;
    border-radius: 14px !important;
    padding: 18px 18px !important;
    text-align: left !important;
    font-size: 0.88rem !important;
    color: #cbd5e1 !important;
    font-weight: 400 !important;
    backdrop-filter: blur(12px) !important;
    transition: all 0.25s ease !important;
    line-height: 1.5 !important;
    min-height: 70px !important;
}
div[data-testid="stColumns"] .stButton > button:hover {
    border-color: rgba(16, 185, 129, 0.4) !important;
    background: rgba(16, 185, 129, 0.08) !important;
    box-shadow: 0 4px 20px rgba(16, 185, 129, 0.12) !important;
    color: #e2e8f0 !important;
    transform: translateY(-1px);
}
</style>
""", unsafe_allow_html=True)

# ── Session State Init ────────────────────────────────────────────────────────
if "session_id" not in st.session_state:
    st.session_state.session_id = uuid.uuid4().hex
if "messages" not in st.session_state:
    st.session_state.messages = []
if "graph" not in st.session_state:
    from graph.builder import build_graph
    st.session_state.graph = build_graph()
if "sql_history" not in st.session_state:
    st.session_state.sql_history = []
if "rich_history" not in st.session_state:
    st.session_state.rich_history = []

# ── Sidebar ───────────────────────────────────────────────────────────────────
with st.sidebar:
    st.markdown('<p class="sidebar-brand">⚡ Dash</p>', unsafe_allow_html=True)
    st.caption("Self-learning data agent for Snowflake")

    st.divider()
    st.subheader("Connection")
    st.markdown(f"""
    - **Database:** `{config.SNOWFLAKE_DATABASE}`
    - **Schema:** `{config.SNOWFLAKE_SCHEMA}`
    - **Warehouse:** `{config.SNOWFLAKE_WAREHOUSE}`
    - **Role:** `{config.SNOWFLAKE_ROLE}`
    """)

    st.divider()
    st.subheader("SQL History")
    if st.session_state.sql_history:
        for i, entry in enumerate(reversed(st.session_state.sql_history[-10:])):
            with st.expander(f"Query {len(st.session_state.sql_history) - i}", expanded=False):
                st.code(entry.get("sql", ""), language="sql")
                if entry.get("row_count") is not None:
                    st.caption(f"Rows: {entry['row_count']}")
    else:
        st.caption("No queries yet.")

    st.divider()
    if st.button("🗑️ Clear Chat", width="stretch"):
        st.session_state.messages = []
        st.session_state.sql_history = []
        st.session_state.rich_history = []
        st.session_state.session_id = uuid.uuid4().hex
        st.rerun()

    st.divider()
    st.subheader("Knowledge Base")
    if st.button("📚 Reload Knowledge", width="stretch"):
        from scripts.load_knowledge import main as load_kb
        with st.spinner("Loading knowledge into ChromaDB..."):
            load_kb(recreate=True)
        st.success("Knowledge reloaded!")

# ── Main Chat Area ────────────────────────────────────────────────────────────

# Suggested questions
_SUGGESTIONS = [
    ("📊", "Compare total revenue across store, catalog, and web channels for 2001"),
    ("🏪", "Which store had the highest net profit in 2001?"),
    ("🔄", "What is the net loss from returns broken down by sales channel?"),
    ("📦", "Show me the top 10 best selling items by total revenue in 2001"),
    ("👥", "Break down store sales revenue by customer income band for 2001"),
    ("🎯", "Which promotions generated the highest incremental revenue in 2001?"),
]

# Show welcome screen when no messages, otherwise show chat
if not st.session_state.rich_history:
    st.markdown("""
    <div class="welcome-container">
        <div class="welcome-heading">Dash</div>
        <div class="welcome-sub">Ask anything about your data. I generate SQL, run it, and explain the results.</div>
    </div>
    """, unsafe_allow_html=True)

    # Suggestion cards as buttons
    cols = st.columns(2)
    selected_suggestion = None
    for idx, (icon, text) in enumerate(_SUGGESTIONS):
        with cols[idx % 2]:
            if st.button(f"{icon}  {text}", key=f"suggestion_{idx}", use_container_width=True):
                selected_suggestion = text

    if selected_suggestion:
        st.session_state._pending_input = selected_suggestion
        st.rerun()
else:
    # Display chat history with rich context
    for idx, entry in enumerate(st.session_state.rich_history):
        with st.chat_message("user"):
            st.markdown(entry["user_msg"])
        with st.chat_message("assistant"):
            st.markdown(entry["response"])
            if entry.get("sql"):
                with st.expander("🔍 SQL Query", expanded=False):
                    st.code(entry["sql"], language="sql")
            # Render chart if available
            if entry.get("chart_config") and entry.get("rows"):
                fig = render_chart(entry["chart_config"], entry["rows"], palette_idx=idx)
                if fig:
                    _display_chart_glass(fig)
            if entry.get("rows"):
                with st.expander(f"📋 Raw Results ({entry['row_count']} rows)", expanded=False):
                    df = pd.DataFrame(entry["rows"])
                    st.dataframe(df, width="stretch")
            if entry.get("warnings"):
                with st.expander("⚠️ Warnings", expanded=False):
                    for w in entry["warnings"]:
                        st.warning(w)

# ── Node display names for live status ────────────────────────────────────────
_NODE_STATUS = {
    "intent_classifier": ("🧠", "Classifying intent..."),
    "context_retrieval": ("🔍", "Retrieving knowledge and schema context..."),
    "analyst": ("📝", "Generating SQL query..."),
    "sql_validator": ("✅", "Validating SQL for safety..."),
    "executor": ("⚡", "Executing query on Snowflake..."),
    "interpreter": ("💡", "Interpreting results..."),
    "learning_evaluator": ("📚", "Evaluating learnings..."),
    "leader": ("🤖", "Composing response..."),
    "engineer": ("🛠️", "Building database object..."),
    "analyst_retry": ("🔄", "Retrying with error context..."),
    "validation_failed": ("❌", "Validation failed"),
    "execution_failed": ("❌", "Execution failed"),
}

# ── Chat Input ────────────────────────────────────────────────────────────────
# Handle pending suggestion click
_pending = st.session_state.pop("_pending_input", None)
user_input = st.chat_input("Ask a question about your data...") or _pending

if user_input:
    # Display user message
    with st.chat_message("user"):
        st.markdown(user_input)

    # Run the graph with streaming
    with st.chat_message("assistant"):
        status_container = st.empty()
        accumulated = {}

        try:
            initial_state = {
                "messages": [HumanMessage(content=user_input)],
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
                "session_id": st.session_state.session_id,
            }

            # Stream node-by-node for live status updates
            for event in st.session_state.graph.stream(initial_state):
                for node_name, node_output in event.items():
                    icon, label = _NODE_STATUS.get(node_name, ("⏳", f"Running {node_name}..."))
                    status_container.markdown(
                        f'<div style="display:flex;align-items:center;gap:10px;padding:8px 0;">'
                        f'<span style="font-size:1.2rem;">{icon}</span>'
                        f'<span style="color:#94a3b8;font-size:0.95rem;">{label}</span>'
                        f'<span class="pulse-dot"></span>'
                        f'</div>',
                        unsafe_allow_html=True,
                    )
                    if isinstance(node_output, dict):
                        accumulated.update(node_output)

            # Clear the status indicator
            status_container.empty()

            # Extract the response
            response_text = accumulated.get("insight", "I couldn't generate a response.")

            # Show the response
            st.markdown(response_text)

            # Render chart if interpreter produced one
            chart_config = accumulated.get("chart_config")
            generated_sql = accumulated.get("generated_sql", "")
            sql_result = accumulated.get("sql_result")
            logger = logging.getLogger("dash.chart")
            logger.info("chart_config present: %s", chart_config is not None)
            if chart_config:
                logger.info("chart_config: %s", chart_config)
            if chart_config and sql_result and sql_result.get("rows"):
                fig = render_chart(chart_config, sql_result["rows"], palette_idx=len(st.session_state.rich_history))
                logger.info("Figure created: %s", fig is not None)
                if fig:
                    _display_chart_glass(fig)

            # Show SQL if one was generated
            if generated_sql:
                with st.expander("🔍 SQL Query", expanded=False):
                    st.code(generated_sql, language="sql")

                # Show raw results if available
                if sql_result and sql_result.get("rows"):
                    with st.expander(f"📋 Raw Results ({sql_result['row_count']} rows)", expanded=False):
                        df = pd.DataFrame(sql_result["rows"])
                        st.dataframe(df, width="stretch")

                    # Add to SQL history
                    st.session_state.sql_history.append({
                        "sql": generated_sql,
                        "row_count": sql_result["row_count"],
                    })

            # Show validation warnings
            validation = accumulated.get("validation_result", {})
            warn_list = validation.get("warnings", [])
            if warn_list:
                with st.expander("⚠️ Warnings", expanded=False):
                    for w in warn_list:
                        st.warning(w)

            # Show learning candidate
            learning = accumulated.get("learning_candidate")
            if learning and learning.get("type") == "error_correction":
                st.info(f"📝 Learning saved: {learning.get('text', '')[:200]}")

            # Store rich history entry
            st.session_state.rich_history.append({
                "user_msg": user_input,
                "response": response_text,
                "sql": generated_sql,
                "rows": (sql_result or {}).get("rows"),
                "row_count": (sql_result or {}).get("row_count"),
                "warnings": warn_list,
                "chart_config": chart_config,
            })

        except Exception as e:
            status_container.empty()
            error_msg = f"Error: {str(e)}"
            st.error(error_msg)
            st.session_state.rich_history.append({
                "user_msg": user_input,
                "response": error_msg,
                "sql": None,
                "rows": None,
                "row_count": None,
                "warnings": [],
            })
