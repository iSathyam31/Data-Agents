-- <query promotion_effectiveness>
-- <description>Measure promotion effectiveness — promoted sales by promotion name. Pre-filters dates and active promotions before joining to the fact table.</description>
-- <best_practice>Filter small dimension tables (DATE_DIM, PROMOTION) into CTEs first, then join to fact. The optimizer can use the small CTE as the build side of a hash join, probing the fact table efficiently.</best_practice>
-- <query>
WITH date_filter AS (
    SELECT D_DATE_SK
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM
    WHERE D_YEAR = 2001
),
active_promos AS (
    SELECT P_PROMO_SK, P_PROMO_NAME
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.PROMOTION
    WHERE P_DISCOUNT_ACTIVE = 'Y'
),
promo_sales AS (
    SELECT 
        ss.SS_PROMO_SK,
        SUM(ss.SS_EXT_SALES_PRICE) AS promoted_sales,
        SUM(ss.SS_QUANTITY) AS promoted_units,
        COUNT(*) AS promoted_transactions,
        SUM(ss.SS_NET_PROFIT) AS promoted_profit
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    INNER JOIN date_filter d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    INNER JOIN active_promos ap ON ss.SS_PROMO_SK = ap.P_PROMO_SK
    GROUP BY ss.SS_PROMO_SK
)
SELECT 
    ap.P_PROMO_NAME,
    ps.promoted_sales,
    ps.promoted_units,
    ps.promoted_transactions,
    ps.promoted_profit
FROM promo_sales ps
INNER JOIN active_promos ap ON ps.SS_PROMO_SK = ap.P_PROMO_SK
ORDER BY ps.promoted_sales DESC
LIMIT 15;
-- </query>
