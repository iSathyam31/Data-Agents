-- <query total_revenue_by_channel>
-- <description>Total revenue across all 3 sales channels (store, catalog, web) for a given year. Uses CTE to pre-filter DATE_DIM and avoid full fact-table scans.</description>
-- <best_practice>Always pre-filter the date dimension in a CTE first, then join to fact tables. This gives the optimizer a small probe set for the hash join.</best_practice>
-- <query>
WITH date_filter AS (
    SELECT D_DATE_SK
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM
    WHERE D_YEAR = 2001
),
store_rev AS (
    SELECT SUM(ss.SS_EXT_SALES_PRICE) AS revenue,
           COUNT(*) AS txn_count
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    INNER JOIN date_filter d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
),
catalog_rev AS (
    SELECT SUM(cs.CS_EXT_SALES_PRICE) AS revenue,
           COUNT(*) AS txn_count
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CATALOG_SALES cs
    INNER JOIN date_filter d ON cs.CS_SOLD_DATE_SK = d.D_DATE_SK
),
web_rev AS (
    SELECT SUM(ws.WS_EXT_SALES_PRICE) AS revenue,
           COUNT(*) AS txn_count
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SALES ws
    INNER JOIN date_filter d ON ws.WS_SOLD_DATE_SK = d.D_DATE_SK
)
SELECT 'store' AS channel, revenue AS total_revenue, txn_count AS transaction_count FROM store_rev
UNION ALL
SELECT 'catalog', revenue, txn_count FROM catalog_rev
UNION ALL
SELECT 'web', revenue, txn_count FROM web_rev;
-- </query>
