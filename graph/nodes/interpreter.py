"""Result Interpreter node — turns raw SQL results into human insights."""

import logging
import json
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
from graph.state import DashState

logger = logging.getLogger("dash.interpreter")
import config

_INTERPRETER_SYSTEM = """You are a data analyst interpreting SQL query results for business users.

RULES:
1. Provide a clear, concise insight — not just the raw numbers.
2. Highlight key findings, trends, or anomalies.
3. Use plain language. No SQL jargon.
4. If results are empty, explain what that might mean.
5. If numbers look surprising, call it out.
6. Keep it to 2-4 sentences for simple results, more for complex ones.
7. Format numbers nicely (e.g., $1.2B, 45.3%, 2.1M units).

CHART SPECIFICATION:
After your insight text, if the data is suitable for a chart, output a JSON block
fenced with ```chart ... ``` containing a chart configuration.

WHEN TO INCLUDE A CHART:
- The result has 2+ rows AND 2+ columns (at least one label column and one numeric column).
- Do NOT include a chart for single-value answers (e.g., "total revenue is $X").
- Do NOT include a chart if there is only 1 row of data.

CHART CONFIG JSON FORMAT:
{{
  "chart_type": "bar" | "grouped_bar" | "stacked_bar" | "line" | "pie" | "donut" | "area",
  "title": "Short descriptive chart title",
  "x": "column_name_for_x_axis",
  "y": ["col1", "col2"],           // one or more numeric columns
  "color": "optional_column_for_series_grouping",
  "orientation": "v" | "h",        // vertical or horizontal (bar only)
  "labels": {{"col_name": "Display Label"}}  // optional rename map
}}

CHART TYPE SELECTION GUIDE:
- **bar**: Comparing categories (e.g., revenue by channel). Use "h" orientation when category labels are long.
- **grouped_bar**: Comparing multiple metrics side-by-side across categories (e.g., sales vs returns by store).
- **stacked_bar**: Showing composition/parts-of-whole across categories.
- **line**: Time series or trends over ordered values (months, years, quarters).
- **area**: Same as line but emphasize volume/magnitude.
- **pie**: Showing proportion/share when there are 2-6 categories. Only ONE y column.
- **donut**: Same as pie but with a hole — use for a cleaner look.

MULTI-SERIES:
- If the result has multiple numeric columns (e.g., STORE_SALES, CATALOG_SALES, WEB_SALES),
  list them all in "y" for a grouped_bar or line chart.
- If there is a single numeric column but a categorical "color" column, use "color" for series grouping.

The user asked: {user_question}
The SQL that was run: {sql}
"""


# ── Singleton LLM client ──────────────────────────────────────────────────────
_llm = None
def _get_llm():
    global _llm
    if _llm is None:
        _llm = AzureChatOpenAI(
            azure_deployment=config.AZURE_OPENAI_CHAT_DEPLOYMENT,
            api_version=config.AZURE_OPENAI_API_VERSION,
            azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
            api_key=config.AZURE_OPENAI_API_KEY,
            temperature=0.3,
            max_tokens=1000,
        )
    return _llm


def interpreter(state: DashState) -> dict:
    """Interpret SQL results into human-readable insights."""
    sql_result = state.get("sql_result")

    if not sql_result or not sql_result.get("rows"):
        return {
            "insight": "The query returned no results. This could mean the filters are too restrictive, or the data doesn't exist for the specified criteria.",
            "messages": [AIMessage(content="The query returned no results. This could mean the filters are too restrictive, or the data doesn't exist for the specified criteria.")],
        }

    llm = _get_llm()

    # Get user question
    user_question = ""
    for m in reversed(state["messages"]):
        if hasattr(m, "type") and m.type == "human":
            user_question = m.content
            break
        elif isinstance(m, dict) and m.get("role") == "user":
            user_question = m["content"]
            break
        elif isinstance(m, tuple) and m[0] == "user":
            user_question = m[1]
            break

    # Format results for the LLM (limit to avoid token overflow)
    rows = sql_result["rows"][:50]  # Cap at 50 rows for interpretation
    result_text = json.dumps(rows, indent=2, default=str)
    if len(result_text) > 4000:
        result_text = result_text[:4000] + "\n... (truncated)"

    system_prompt = _INTERPRETER_SYSTEM.format(
        user_question=user_question,
        sql=state.get("generated_sql", ""),
    )

    response = llm.invoke([
        SystemMessage(content=system_prompt),
        HumanMessage(content=f"Query returned {sql_result['row_count']} rows.\n\nResults:\n{result_text}"),
    ])

    insight = response.content.strip()

    # Extract chart config if present
    chart_config = None
    import re
    chart_match = re.search(r"```chart\s*\n(.*?)\n```", insight, re.DOTALL)
    if chart_match:
        try:
            chart_config = json.loads(chart_match.group(1))
            logger.info("Chart config extracted: %s", chart_config.get("chart_type"))
        except json.JSONDecodeError:
            logger.warning("Failed to parse chart config JSON")
            chart_config = None
        # Remove the chart block from the insight text
        insight = insight[:chart_match.start()].rstrip() + insight[chart_match.end():].lstrip()

    # Build a nice formatted response
    warnings = state.get("validation_result", {}).get("warnings", [])
    full_response = insight
    if warnings:
        full_response += "\n\n⚠️ " + " | ".join(warnings)

    logger.info("\n%s", "-" * 60)
    logger.info("NODE: Interpreter")
    logger.info("Insight preview: %s", insight[:200])
    if chart_config:
        logger.info("Chart type: %s", chart_config.get("chart_type"))
    if warnings:
        logger.info("Warnings attached: %s", warnings)
    logger.info("%s", "-" * 60)

    result = {
        "insight": insight,
        "messages": [AIMessage(content=full_response)],
    }
    if chart_config:
        result["chart_config"] = chart_config
    return result
