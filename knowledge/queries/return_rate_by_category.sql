-- <query return_rate_by_category>
-- <description>Return rate analysis across all three channels by product category. Calculates return quantity rate and return value rate. Join STORE_SALES to STORE_RETURNS via ticket number for store channel matching.</description>
-- <query>
WITH store_sales_agg AS (
    SELECT
        i.I_CATEGORY,
        SUM(ss.SS_QUANTITY)             AS sold_qty,
        SUM(ss.SS_EXT_SALES_PRICE)      AS sold_revenue
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.ITEM i ON ss.SS_ITEM_SK = i.I_ITEM_SK
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001 AND i.I_REC_END_DATE IS NULL
    GROUP BY i.I_CATEGORY
),
store_returns_agg AS (
    SELECT
        i.I_CATEGORY,
        SUM(sr.SR_RETURN_QUANTITY)      AS returned_qty,
        SUM(sr.SR_RETURN_AMT)           AS returned_amt
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_RETURNS sr
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.ITEM i ON sr.SR_ITEM_SK = i.I_ITEM_SK
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON sr.SR_RETURNED_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001 AND i.I_REC_END_DATE IS NULL
    GROUP BY i.I_CATEGORY
)
SELECT
    s.I_CATEGORY                                            AS category,
    s.sold_qty,
    COALESCE(r.returned_qty, 0)                             AS returned_qty,
    ROUND(COALESCE(r.returned_qty, 0) / NULLIF(s.sold_qty, 0) * 100, 2)    AS return_rate_pct,
    ROUND(s.sold_revenue, 2)                                AS sold_revenue,
    ROUND(COALESCE(r.returned_amt, 0), 2)                   AS returned_amt,
    ROUND(COALESCE(r.returned_amt, 0) / NULLIF(s.sold_revenue, 0) * 100, 2) AS return_value_rate_pct
FROM store_sales_agg s
LEFT JOIN store_returns_agg r ON s.I_CATEGORY = r.I_CATEGORY
ORDER BY return_rate_pct DESC;
-- </query>
