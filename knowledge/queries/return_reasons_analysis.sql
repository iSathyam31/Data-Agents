-- <query return_reasons_analysis>
-- <description>Breakdown of return volumes and financial impact by return reason across all three channels. Joins to the REASON dimension using the return reason SK. Essential for understanding why customers return products.</description>
-- <query>
WITH store_return_reasons AS (
    SELECT r.R_REASON_DESC, 'Store' AS channel,
           SUM(sr.SR_RETURN_QUANTITY) AS return_qty,
           SUM(sr.SR_RETURN_AMT)      AS return_amt,
           SUM(sr.SR_NET_LOSS)        AS net_loss,
           COUNT(*)                   AS return_transactions
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_RETURNS sr
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.REASON r ON sr.SR_REASON_SK = r.R_REASON_SK
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON sr.SR_RETURNED_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
    GROUP BY r.R_REASON_DESC
),
catalog_return_reasons AS (
    SELECT r.R_REASON_DESC, 'Catalog' AS channel,
           SUM(cr.CR_RETURN_QUANTITY), SUM(cr.CR_RETURN_AMOUNT), SUM(cr.CR_NET_LOSS), COUNT(*)
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CATALOG_RETURNS cr
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.REASON r ON cr.CR_REASON_SK = r.R_REASON_SK
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON cr.CR_RETURNED_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
    GROUP BY r.R_REASON_DESC
),
web_return_reasons AS (
    SELECT r.R_REASON_DESC, 'Web' AS channel,
           SUM(wr.WR_RETURN_QUANTITY), SUM(wr.WR_RETURN_AMT), SUM(wr.WR_NET_LOSS), COUNT(*)
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_RETURNS wr
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.REASON r ON wr.WR_REASON_SK = r.R_REASON_SK
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON wr.WR_RETURNED_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
    GROUP BY r.R_REASON_DESC
),
combined AS (
    SELECT * FROM store_return_reasons
    UNION ALL SELECT * FROM catalog_return_reasons
    UNION ALL SELECT * FROM web_return_reasons
)
SELECT
    R_REASON_DESC                       AS return_reason,
    SUM(return_qty)                     AS total_return_qty,
    ROUND(SUM(return_amt), 2)           AS total_return_amt,
    ROUND(SUM(net_loss), 2)             AS total_net_loss,
    SUM(return_transactions)            AS total_return_transactions
FROM combined
GROUP BY R_REASON_DESC
ORDER BY total_net_loss DESC;
-- </query>
