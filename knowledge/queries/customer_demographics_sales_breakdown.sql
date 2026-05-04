-- <query customer_demographics_sales_breakdown>
-- <description>Breaks down store sales revenue by customer gender, marital status, education level, and credit rating. Joins STORE_SALES to CUSTOMER_DEMOGRAPHICS via SS_CDEMO_SK. Key demographic segmentation query.</description>
-- <query>
SELECT
    cd.CD_GENDER                                AS gender,
    cd.CD_MARITAL_STATUS                        AS marital_status,
    cd.CD_EDUCATION_STATUS                      AS education,
    cd.CD_CREDIT_RATING                         AS credit_rating,
    COUNT(DISTINCT ss.SS_TICKET_NUMBER)         AS total_transactions,
    COUNT(DISTINCT ss.SS_CUSTOMER_SK)           AS unique_customers,
    SUM(ss.SS_QUANTITY)                         AS total_units,
    ROUND(SUM(ss.SS_EXT_SALES_PRICE), 2)        AS total_revenue,
    ROUND(AVG(ss.SS_EXT_SALES_PRICE), 2)        AS avg_basket_value,
    ROUND(SUM(ss.SS_NET_PROFIT), 2)             AS total_profit
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_DEMOGRAPHICS cd
    ON ss.SS_CDEMO_SK = cd.CD_DEMO_SK
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
    ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
WHERE d.D_YEAR = 2001
  AND ss.SS_CUSTOMER_SK IS NOT NULL          -- exclude anonymous transactions
GROUP BY cd.CD_GENDER, cd.CD_MARITAL_STATUS, cd.CD_EDUCATION_STATUS, cd.CD_CREDIT_RATING
ORDER BY total_revenue DESC
LIMIT 30;
-- </query>
