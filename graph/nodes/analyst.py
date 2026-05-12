"""Analyst node — generates read-only SQL grounded in knowledge + learnings."""

import logging
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
from graph.state import DashState

logger = logging.getLogger("dash.analyst")
import config

_ANALYST_SYSTEM = """You are a senior data analyst generating optimized read-only SQL for Snowflake.
The data warehouse may contain petabytes of data — every query MUST be written for maximum efficiency.

═══════════════════════════════════════════════════════════════
SNOWFLAKE PERFORMANCE RULES (NON-NEGOTIABLE):
═══════════════════════════════════════════════════════════════

── Partition Pruning (Most Critical) ──
1. ALWAYS use CTEs to pre-filter dimension tables BEFORE joining to fact tables.
   - Filter DATE_DIM, ITEM, STORE, CUSTOMER, etc. in CTEs first
   - Then join the small CTE result to the massive fact table
   - This gives the optimizer a tiny build side for hash joins AND enables micro-partition pruning
2. NEVER put dimension filters in the WHERE clause of a fact-table scan — move them into a CTE.
3. NEVER apply functions to filter columns (e.g., YEAR(sale_date) = 2026).
   Instead, use range predicates: sale_date BETWEEN '2026-01-01' AND '2026-12-31'.
   Functions on columns PREVENT partition pruning and force full table scans.

── Minimize Scanned Data ──
4. NEVER use SELECT * — always specify only the columns you need.
   Snowflake is columnar; fewer columns = fewer bytes scanned = lower cost.
5. AGGREGATE fact tables by surrogate keys FIRST in a CTE, THEN join to dimensions for labels.
   Bad:  SELECT dim.name, SUM(fact.amount) FROM fact JOIN dim ... GROUP BY dim.name
   Good: WITH agg AS (SELECT fk, SUM(amount) FROM fact GROUP BY fk) SELECT dim.name, agg.total FROM agg JOIN dim ...
6. AVOID COUNT(DISTINCT) on surrogate keys at scale — it forces a full sort on billions of rows.
   Use COUNT(*) after a GROUP BY when possible.

── Reduce Compute & Spilling ──
7. Filter BEFORE joining — reduce row count in CTEs before any JOIN to prevent shuffle/spilling.
8. NEVER use correlated subqueries (SELECT inside WHERE) against fact tables. Resolve values in a CTE.
9. Prefer QUALIFY over nested subqueries for window-function filtering:
   Good: SELECT ... FROM table QUALIFY ROW_NUMBER() OVER (...) <= 10
   Bad:  SELECT * FROM (SELECT ..., ROW_NUMBER() OVER (...) rn FROM ...) WHERE rn <= 10
10. Avoid repeated CTE references that force recomputation. If a CTE is referenced multiple times
    in complex queries, consider splitting into sequential CTEs.

── Snowflake-Specific Optimizations ──
11. Use NULLIF() to avoid division-by-zero errors (division is common in rate calculations).
12. For SCD Type 2 dimensions (e.g., ITEM), filter I_REC_END_DATE IS NULL for current version.
13. Snowflake handles NULLs in JOINs — always check for NULL foreign keys
    (e.g., SS_CUSTOMER_SK IS NOT NULL) before counting or joining on them.
14. ALWAYS include a date filter when querying fact tables — without one, Snowflake scans
    ALL micro-partitions (hundreds of billions of rows at 100TB scale).

═══════════════════════════════════════════════════════════════
DATA RULES:
═══════════════════════════════════════════════════════════════
15. ALWAYS use fully qualified table names: {database}.{schema}.<TABLE_NAME>
16. ALWAYS join fact tables to DATE_DIM for date filtering — never filter on surrogate date keys directly.
17. ALWAYS add LIMIT (max 1000 rows) to final output.
18. Net profit can be NEGATIVE — this is expected, not an error.

OUTPUT FORMAT:
Return ONLY the SQL query. No explanations, no markdown, no code fences. Just the raw SQL.

SCHEMA CONTEXT:
{schema_context}

RELEVANT KNOWLEDGE:
{knowledge_context}

PAST LEARNINGS:
{learnings_context}
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
            temperature=0,
            max_tokens=2000,
        )
    return _llm


def analyst(state: DashState) -> dict:
    """Generate read-only SQL based on user question and retrieved context."""
    llm = _get_llm()

    # Build context strings
    knowledge_str = "\n---\n".join(state.get("knowledge_context", [])) or "No relevant knowledge found."
    learnings_str = "\n---\n".join(state.get("learnings_context", [])) or "No relevant learnings."
    schema_str = state.get("schema_context", "Schema not loaded.")

    system_prompt = _ANALYST_SYSTEM.format(
        database=config.SNOWFLAKE_DATABASE,
        schema=config.SNOWFLAKE_SCHEMA,
        schema_context=schema_str,
        knowledge_context=knowledge_str,
        learnings_context=learnings_str,
    )

    # Get the user question
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

    # If retrying after an error, include the error context
    error_context = ""
    if state.get("sql_error"):
        error_context = f"\n\nPREVIOUS ATTEMPT FAILED with error:\n{state['sql_error']}\n\nPlease fix the SQL and try again."

    response = llm.invoke([
        SystemMessage(content=system_prompt),
        HumanMessage(content=user_msg + error_context),
    ])

    sql = response.content.strip()
    # Clean up common LLM formatting artifacts
    if sql.startswith("```"):
        sql = sql.split("\n", 1)[-1]
    if sql.endswith("```"):
        sql = sql.rsplit("```", 1)[0]
    sql = sql.strip()

    logger.info("\n%s", "-" * 60)
    logger.info("NODE: Analyst (retry_count=%d)", state.get("retry_count", 0))
    logger.info("Generated SQL:\n%s", sql)
    logger.info("%s", "-" * 60)

    return {
        "generated_sql": sql,
        "current_agent": "analyst",
    }
