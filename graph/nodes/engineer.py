"""Engineer node — creates views and summary tables in the DASH schema."""

import logging
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
from graph.state import DashState

logger = logging.getLogger("dash.engineer")
from db import execute_write
from vectorstore import upsert_knowledge
import config
import uuid

_ENGINEER_SYSTEM = """You are a data engineer working with Snowflake. Your job is to create SQL views 
or summary tables based on user requests.
The data warehouse may contain petabytes of data — every view MUST be written for maximum efficiency.

═══════════════════════════════════════════════════════════════
SNOWFLAKE PERFORMANCE RULES (NON-NEGOTIABLE):
═══════════════════════════════════════════════════════════════

── Partition Pruning ──
1. ALWAYS use CTEs to pre-filter dimension tables BEFORE joining to fact tables.
   - Filter DATE_DIM, ITEM, STORE, CUSTOMER, etc. in CTEs first
   - Then join the small CTE result to the massive fact table
2. NEVER put dimension filters in the WHERE clause of a fact-table scan — move them into a CTE.
3. NEVER apply functions to filter columns (e.g., YEAR(date_col)) — use range predicates instead.

── Minimize Scanned Data ──
4. NEVER use SELECT * — only specify needed columns. Snowflake is columnar; fewer columns = less cost.
5. AGGREGATE fact tables by surrogate keys FIRST in a CTE, THEN join to dimensions for labels.
6. AVOID COUNT(DISTINCT) on surrogate keys at scale — use COUNT(*) after GROUP BY.

── Reduce Compute & Spilling ──
7. Filter BEFORE joining — reduce row counts in CTEs before any JOIN.
8. NEVER use correlated subqueries against fact tables. Resolve values in a CTE.
9. Use QUALIFY for window-function filtering instead of nested subqueries.
10. Avoid repeated CTE references that force recomputation.

DDL RULES:
11. All objects you create MUST be in the target schema (DASH).
12. Use CREATE OR REPLACE VIEW DASH.<name> AS ... for views.
13. Views should reference fully qualified source tables: {database}.{schema}.<table>
14. Include clear column aliases.
15. Handle NULLs with NULLIF() and COALESCE() for edge cases.
16. Return ONLY the SQL DDL. No explanations, no markdown, no code fences.

SCHEMA CONTEXT:
{schema_context}

RELEVANT KNOWLEDGE:
{knowledge_context}
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


def engineer(state: DashState) -> dict:
    """Generate DDL for views/tables in the DASH schema."""
    llm = _get_llm()

    knowledge_str = "\n---\n".join(state.get("knowledge_context", [])) or "None"
    schema_str = state.get("schema_context", "Not loaded")

    system_prompt = _ENGINEER_SYSTEM.format(
        database=config.SNOWFLAKE_DATABASE,
        schema=config.SNOWFLAKE_SCHEMA,
        schema_context=schema_str,
        knowledge_context=knowledge_str,
    )

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

    response = llm.invoke([
        SystemMessage(content=system_prompt),
        HumanMessage(content=user_msg),
    ])

    ddl_sql = response.content.strip()
    if ddl_sql.startswith("```"):
        ddl_sql = ddl_sql.split("\n", 1)[-1]
    if ddl_sql.endswith("```"):
        ddl_sql = ddl_sql.rsplit("```", 1)[0]
    ddl_sql = ddl_sql.strip()

    # Execute the DDL
    try:
        result_msg = execute_write(ddl_sql)
        # Save to knowledge base so Analyst can discover the view
        view_id = f"dash-view-{uuid.uuid4().hex[:8]}"
        upsert_knowledge(
            doc_id=view_id,
            text=f"Engineer created view/table:\n{ddl_sql}",
            metadata={"type": "dash_view", "created_by": "engineer"},
        )
        reply = f"Done. I've created the following:\n\n```sql\n{ddl_sql}\n```\n\nThis has been recorded in the knowledge base for the Analyst to use."
    except Exception as e:
        reply = f"Failed to create the view/table:\n\nError: {str(e)}\n\nSQL attempted:\n```sql\n{ddl_sql}\n```"

    logger.info("\n%s", "-" * 60)
    logger.info("NODE: Engineer")
    logger.info("DDL SQL:\n%s", ddl_sql)
    logger.info("Result: %s", reply[:200])
    logger.info("%s", "-" * 60)

    return {
        "generated_sql": ddl_sql,
        "current_agent": "engineer",
        "insight": reply,
        "messages": [AIMessage(content=reply)],
    }
