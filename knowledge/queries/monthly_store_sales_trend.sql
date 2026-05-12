-- <query monthly_store_sales_trend>
-- <description>Monthly store sales trend for a given year — revenue, profit, and customer metrics. Pre-filters date dimension to constrain the fact table scan.</description>
-- <best_practice>For time-series aggregations, filter date dimension first in a CTE, then join. Avoid COUNT(DISTINCT) on large surrogate keys when possible — it forces a full sort. Use approximate counts if precision is not critical.</best_practice>
-- <query>
WITH date_filter AS (
    SELECT D_DATE_SK, D_YEAR, D_MOY
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM
    WHERE D_YEAR = 2001
)
SELECT 
    d.D_YEAR,
    d.D_MOY AS month_number,
    SUM(ss.SS_EXT_SALES_PRICE) AS monthly_revenue,
    SUM(ss.SS_NET_PROFIT) AS monthly_profit,
    COUNT(*) AS transactions
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
INNER JOIN date_filter d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
GROUP BY d.D_YEAR, d.D_MOY
ORDER BY d.D_YEAR, d.D_MOY;
-- </query>
