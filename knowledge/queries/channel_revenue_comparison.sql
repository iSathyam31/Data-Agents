-- <query channel_revenue_comparison>
-- <description>Compare total revenue, orders, and net profit across all three sales channels (store, catalog, web) for a given year. The definitive cross-channel performance query.</description>
-- <query>
WITH store_totals AS (
    SELECT
        'Store'                                 AS channel,
        COUNT(DISTINCT ss.SS_TICKET_NUMBER)     AS total_orders,
        SUM(ss.SS_QUANTITY)                     AS total_units,
        SUM(ss.SS_EXT_SALES_PRICE)              AS total_revenue,
        SUM(ss.SS_NET_PROFIT)                   AS total_profit
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
),
catalog_totals AS (
    SELECT
        'Catalog'                               AS channel,
        COUNT(DISTINCT cs.CS_ORDER_NUMBER)      AS total_orders,
        SUM(cs.CS_QUANTITY)                     AS total_units,
        SUM(cs.CS_EXT_SALES_PRICE)              AS total_revenue,
        SUM(cs.CS_NET_PROFIT)                   AS total_profit
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CATALOG_SALES cs
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON cs.CS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
),
web_totals AS (
    SELECT
        'Web'                                   AS channel,
        COUNT(DISTINCT ws.WS_ORDER_NUMBER)      AS total_orders,
        SUM(ws.WS_QUANTITY)                     AS total_units,
        SUM(ws.WS_EXT_SALES_PRICE)              AS total_revenue,
        SUM(ws.WS_NET_PROFIT)                   AS total_profit
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SALES ws
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON ws.WS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
)
SELECT
    channel,
    total_orders,
    total_units,
    ROUND(total_revenue, 2)                         AS total_revenue,
    ROUND(total_profit, 2)                          AS total_profit,
    ROUND(total_profit / NULLIF(total_revenue, 0) * 100, 2) AS profit_margin_pct,
    ROUND(total_revenue / NULLIF(total_orders, 0), 2)       AS avg_order_value
FROM (
    SELECT * FROM store_totals
    UNION ALL SELECT * FROM catalog_totals
    UNION ALL SELECT * FROM web_totals
)
ORDER BY total_revenue DESC;
-- </query>
