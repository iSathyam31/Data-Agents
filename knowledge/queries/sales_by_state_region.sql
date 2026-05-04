-- <query sales_by_state_region>
-- <description>Total store sales revenue by US state for geographic/regional analysis. Joins STORE_SALES to CUSTOMER_ADDRESS via SS_ADDR_SK to get the customer's location, not the store's location. Change SS_ADDR_SK to SS_STORE_SK + STORE for store-location analysis.</description>
-- <query>
SELECT
    ca.CA_STATE                                 AS state,
    ca.CA_COUNTRY                               AS country,
    COUNT(DISTINCT ss.SS_CUSTOMER_SK)           AS unique_customers,
    COUNT(DISTINCT ss.SS_TICKET_NUMBER)         AS total_transactions,
    SUM(ss.SS_QUANTITY)                         AS total_units,
    ROUND(SUM(ss.SS_EXT_SALES_PRICE), 2)        AS total_revenue,
    ROUND(AVG(ss.SS_EXT_SALES_PRICE), 2)        AS avg_transaction_value,
    ROUND(SUM(ss.SS_NET_PROFIT), 2)             AS total_profit
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_ADDRESS ca
    ON ss.SS_ADDR_SK = ca.CA_ADDRESS_SK
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
    ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
WHERE d.D_YEAR = 2001
  AND ss.SS_ADDR_SK IS NOT NULL
GROUP BY ca.CA_STATE, ca.CA_COUNTRY
ORDER BY total_revenue DESC
LIMIT 50;
-- </query>
