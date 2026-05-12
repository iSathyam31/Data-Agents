-- <query return_rate_by_channel>
-- <description>Return metrics (count, amount, net loss) by sales channel for a given year. Uses a shared date CTE to avoid scanning DATE_DIM three times.</description>
-- <best_practice>When querying multiple fact tables with the same filter, define the filter CTE once and reference it in each sub-query. Avoid COUNT(DISTINCT) on surrogate keys at petabyte scale — use COUNT(*) when one row = one return transaction.</best_practice>
-- <query>
WITH date_filter AS (
    SELECT D_DATE_SK
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM
    WHERE D_YEAR = 2001
),
store_ret AS (
    SELECT COUNT(*) AS return_txns,
           SUM(sr.SR_RETURN_AMT) AS return_amount,
           SUM(sr.SR_NET_LOSS) AS net_loss
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_RETURNS sr
    INNER JOIN date_filter d ON sr.SR_RETURNED_DATE_SK = d.D_DATE_SK
),
catalog_ret AS (
    SELECT COUNT(*) AS return_txns,
           SUM(cr.CR_RETURN_AMOUNT) AS return_amount,
           SUM(cr.CR_NET_LOSS) AS net_loss
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CATALOG_RETURNS cr
    INNER JOIN date_filter d ON cr.CR_RETURNED_DATE_SK = d.D_DATE_SK
),
web_ret AS (
    SELECT COUNT(*) AS return_txns,
           SUM(wr.WR_RETURN_AMT) AS return_amount,
           SUM(wr.WR_NET_LOSS) AS net_loss
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_RETURNS wr
    INNER JOIN date_filter d ON wr.WR_RETURNED_DATE_SK = d.D_DATE_SK
)
SELECT 'store' AS channel, return_txns, return_amount, net_loss FROM store_ret
UNION ALL
SELECT 'catalog', return_txns, return_amount, net_loss FROM catalog_ret
UNION ALL
SELECT 'web', return_txns, return_amount, net_loss FROM web_ret;
-- </query>
