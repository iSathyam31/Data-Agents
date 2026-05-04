-- <query high_value_customers>
-- <description>Identify the top 500 highest-spending customers across all channels combined. Uses CUSTOMER dimension for name and demographics. Handle SS_CUSTOMER_SK NULL (anonymous transactions are excluded). Good for loyalty program analysis.</description>
-- <query>
WITH all_customer_spend AS (
    SELECT SS_CUSTOMER_SK AS customer_sk, SUM(SS_EXT_SALES_PRICE) AS revenue, SUM(SS_NET_PROFIT) AS profit,
           COUNT(DISTINCT SS_TICKET_NUMBER) AS orders, SUM(SS_QUANTITY) AS units, 'Store' AS channel
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001 AND SS_CUSTOMER_SK IS NOT NULL
    GROUP BY SS_CUSTOMER_SK

    UNION ALL

    SELECT CS_BILL_CUSTOMER_SK, SUM(CS_EXT_SALES_PRICE), SUM(CS_NET_PROFIT),
           COUNT(DISTINCT CS_ORDER_NUMBER), SUM(CS_QUANTITY), 'Catalog'
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CATALOG_SALES cs
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON cs.CS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001 AND CS_BILL_CUSTOMER_SK IS NOT NULL
    GROUP BY CS_BILL_CUSTOMER_SK

    UNION ALL

    SELECT WS_BILL_CUSTOMER_SK, SUM(WS_EXT_SALES_PRICE), SUM(WS_NET_PROFIT),
           COUNT(DISTINCT WS_ORDER_NUMBER), SUM(WS_QUANTITY), 'Web'
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SALES ws
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON ws.WS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001 AND WS_BILL_CUSTOMER_SK IS NOT NULL
    GROUP BY WS_BILL_CUSTOMER_SK
),
customer_totals AS (
    SELECT
        customer_sk,
        SUM(revenue)    AS total_revenue,
        SUM(profit)     AS total_profit,
        SUM(orders)     AS total_orders,
        SUM(units)      AS total_units
    FROM all_customer_spend
    GROUP BY customer_sk
)
SELECT
    c.C_CUSTOMER_ID,
    c.C_FIRST_NAME || ' ' || c.C_LAST_NAME  AS customer_name,
    c.C_PREFERRED_CUST_FLAG                  AS preferred_customer,
    ct.total_orders,
    ct.total_units,
    ROUND(ct.total_revenue, 2)               AS total_revenue,
    ROUND(ct.total_profit, 2)                AS total_profit,
    ROUND(ct.total_revenue / NULLIF(ct.total_orders, 0), 2) AS avg_order_value,
    RANK() OVER (ORDER BY ct.total_revenue DESC)            AS revenue_rank
FROM customer_totals ct
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER c ON ct.customer_sk = c.C_CUSTOMER_SK
ORDER BY revenue_rank
LIMIT 500;
-- </query>
