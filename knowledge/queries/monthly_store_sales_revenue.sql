-- <query monthly_store_sales_revenue>
-- <description>Monthly store sales revenue and net profit trend. Filters on a specific year. Always use a date filter to avoid scanning all 300B rows of STORE_SALES.</description>
-- <query>
SELECT
    d.D_YEAR                                    AS sale_year,
    d.D_MOY                                     AS sale_month,
    d.D_MONTH_SEQ                               AS month_seq,
    COUNT(DISTINCT ss.SS_TICKET_NUMBER)         AS total_transactions,
    SUM(ss.SS_QUANTITY)                         AS total_units_sold,
    SUM(ss.SS_EXT_SALES_PRICE)                  AS total_revenue,
    SUM(ss.SS_NET_PAID)                         AS net_paid,
    SUM(ss.SS_EXT_WHOLESALE_COST)               AS total_cost,
    SUM(ss.SS_NET_PROFIT)                       AS net_profit,
    ROUND(SUM(ss.SS_NET_PROFIT) / NULLIF(SUM(ss.SS_EXT_SALES_PRICE), 0) * 100, 2) AS profit_margin_pct
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
    ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
WHERE d.D_YEAR = 2001
GROUP BY d.D_YEAR, d.D_MOY, d.D_MONTH_SEQ
ORDER BY d.D_MONTH_SEQ;
-- </query>
