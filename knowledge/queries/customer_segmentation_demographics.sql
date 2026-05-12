-- <query customer_segmentation_by_demographics>
-- <description>Customer spending by demographic segments — gender, marital status, education. Aggregates at store_sk level first, then joins to dimension tables to avoid carrying dimension columns through billions of rows.</description>
-- <best_practice>For multi-dimension breakdowns, aggregate fact table by the surrogate keys first (small result set), then join to dimensions for labels. Avoid joining all dimensions before the GROUP BY — it inflates the working set.</best_practice>
-- <query>
WITH date_filter AS (
    SELECT D_DATE_SK
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM
    WHERE D_YEAR = 2001
),
sales_by_customer AS (
    SELECT 
        ss.SS_CUSTOMER_SK,
        SUM(ss.SS_EXT_SALES_PRICE) AS total_spend,
        COUNT(*) AS txn_count
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    INNER JOIN date_filter d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE ss.SS_CUSTOMER_SK IS NOT NULL
    GROUP BY ss.SS_CUSTOMER_SK
)
SELECT 
    cd.CD_GENDER,
    cd.CD_MARITAL_STATUS,
    cd.CD_EDUCATION_STATUS,
    COUNT(*) AS customer_count,
    SUM(sc.total_spend) AS total_spend,
    SUM(sc.total_spend) / NULLIF(COUNT(*), 0) AS avg_spend_per_customer
FROM sales_by_customer sc
INNER JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER c ON sc.SS_CUSTOMER_SK = c.C_CUSTOMER_SK
INNER JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_DEMOGRAPHICS cd ON c.C_CURRENT_CDEMO_SK = cd.CD_DEMO_SK
GROUP BY cd.CD_GENDER, cd.CD_MARITAL_STATUS, cd.CD_EDUCATION_STATUS
ORDER BY total_spend DESC
LIMIT 20;
-- </query>
