-- <query top_selling_items_by_category>
-- <description>Top 20 items ranked by total store sales revenue within each product category. Uses ITEM dimension to get category, brand, and product name. Always filter I_REC_END_DATE IS NULL to get current item version.</description>
-- <query>
WITH item_sales AS (
    SELECT
        i.I_CATEGORY,
        i.I_BRAND,
        i.I_PRODUCT_NAME,
        i.I_ITEM_ID,
        SUM(ss.SS_EXT_SALES_PRICE)      AS total_revenue,
        SUM(ss.SS_QUANTITY)             AS total_units_sold,
        SUM(ss.SS_NET_PROFIT)           AS total_profit,
        ROUND(AVG(ss.SS_SALES_PRICE), 2) AS avg_selling_price
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.ITEM i
        ON ss.SS_ITEM_SK = i.I_ITEM_SK
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
        ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
      AND i.I_REC_END_DATE IS NULL       -- current version of item only
    GROUP BY i.I_CATEGORY, i.I_BRAND, i.I_PRODUCT_NAME, i.I_ITEM_ID
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY I_CATEGORY ORDER BY total_revenue DESC) AS rank_in_category
    FROM item_sales
)
SELECT
    I_CATEGORY      AS category,
    I_BRAND         AS brand,
    I_PRODUCT_NAME  AS product_name,
    rank_in_category,
    ROUND(total_revenue, 2)     AS total_revenue,
    total_units_sold,
    ROUND(total_profit, 2)      AS total_profit,
    avg_selling_price
FROM ranked
WHERE rank_in_category <= 20
ORDER BY I_CATEGORY, rank_in_category;
-- </query>
