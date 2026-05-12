-- <query top_selling_categories>
-- <description>Top 10 product categories by total sales amount from store sales for a given year. Pre-filters dates and items in CTEs before joining to the massive fact table.</description>
-- <best_practice>Filter dimension tables in CTEs first, then join to fact. Avoid joining large tables directly — narrow them before the join.</best_practice>
-- <query>
WITH date_filter AS (
    SELECT D_DATE_SK
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM
    WHERE D_YEAR = 2001
),
current_items AS (
    SELECT I_ITEM_SK, I_CATEGORY
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.ITEM
    WHERE I_REC_END_DATE IS NULL
),
sales_filtered AS (
    SELECT ss.SS_ITEM_SK,
           ss.SS_EXT_SALES_PRICE,
           ss.SS_QUANTITY,
           ss.SS_TICKET_NUMBER
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    INNER JOIN date_filter d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
)
SELECT 
    ci.I_CATEGORY,
    SUM(sf.SS_EXT_SALES_PRICE) AS total_sales,
    SUM(sf.SS_QUANTITY) AS total_units,
    COUNT(DISTINCT sf.SS_TICKET_NUMBER) AS transaction_count
FROM sales_filtered sf
INNER JOIN current_items ci ON sf.SS_ITEM_SK = ci.I_ITEM_SK
GROUP BY ci.I_CATEGORY
ORDER BY total_sales DESC
LIMIT 10;
-- </query>
