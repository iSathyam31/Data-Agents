-- <query store_performance_ranking>
-- <description>Store performance ranking by revenue and profit for a given year. Pre-filters dates and aggregates before joining to the small dimension table.</description>
-- <best_practice>Aggregate the fact table first in a CTE (reducing billions of rows to a few hundred store-level aggregates), then join to small dimension tables for labels. This avoids carrying dimension columns through the massive GROUP BY.</best_practice>
-- <query>
WITH date_filter AS (
    SELECT D_DATE_SK
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM
    WHERE D_YEAR = 2001
),
store_agg AS (
    SELECT 
        ss.SS_STORE_SK,
        SUM(ss.SS_EXT_SALES_PRICE) AS total_revenue,
        SUM(ss.SS_NET_PROFIT) AS total_profit,
        COUNT(*) AS transaction_count
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    INNER JOIN date_filter d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    GROUP BY ss.SS_STORE_SK
)
SELECT 
    s.S_STORE_NAME,
    s.S_STATE,
    s.S_CITY,
    sa.total_revenue,
    sa.total_profit,
    sa.transaction_count,
    sa.total_revenue / NULLIF(sa.transaction_count, 0) AS revenue_per_transaction
FROM store_agg sa
INNER JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE s ON sa.SS_STORE_SK = s.S_STORE_SK
ORDER BY sa.total_revenue DESC
LIMIT 20;
-- </query>
