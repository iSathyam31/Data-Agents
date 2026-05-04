-- <query store_performance_ranking>
-- <description>Rank all stores by total revenue for a given year. Includes store name, location, manager, employee count, and key financial metrics. Filter S_REC_END_DATE IS NULL to get current store records.</description>
-- <query>
SELECT
    s.S_STORE_ID,
    s.S_STORE_NAME,
    s.S_CITY,
    s.S_STATE,
    s.S_MANAGER,
    s.S_NUMBER_EMPLOYEES,
    s.S_FLOOR_SPACE,
    COUNT(DISTINCT ss.SS_TICKET_NUMBER)         AS total_transactions,
    SUM(ss.SS_QUANTITY)                         AS total_units_sold,
    ROUND(SUM(ss.SS_EXT_SALES_PRICE), 2)        AS total_revenue,
    ROUND(SUM(ss.SS_NET_PROFIT), 2)             AS total_profit,
    ROUND(SUM(ss.SS_NET_PROFIT) / NULLIF(SUM(ss.SS_EXT_SALES_PRICE), 0) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(ss.SS_EXT_SALES_PRICE) / NULLIF(s.S_NUMBER_EMPLOYEES, 0), 2)        AS revenue_per_employee,
    RANK() OVER (ORDER BY SUM(ss.SS_EXT_SALES_PRICE) DESC)                         AS revenue_rank
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE s
    ON ss.SS_STORE_SK = s.S_STORE_SK
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
    ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
WHERE d.D_YEAR = 2001
  AND s.S_REC_END_DATE IS NULL              -- current store records only
GROUP BY
    s.S_STORE_ID, s.S_STORE_NAME, s.S_CITY, s.S_STATE,
    s.S_MANAGER, s.S_NUMBER_EMPLOYEES, s.S_FLOOR_SPACE
ORDER BY revenue_rank
LIMIT 50;
-- </query>
