-- <query inventory_levels_by_warehouse>
-- <description>Inventory levels by warehouse for the most recent snapshot date. Uses a CTE to find the latest date key first, avoiding a correlated subquery inside the main scan.</description>
-- <best_practice>Never use a correlated subquery (SELECT MAX inside WHERE) on a petabyte fact table. Resolve the filter value in a CTE first, then use it as a simple join or filter.</best_practice>
-- <query>
WITH latest_date AS (
    SELECT MAX(d.D_DATE_SK) AS max_date_sk
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.INVENTORY inv
    INNER JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON inv.INV_DATE_SK = d.D_DATE_SK
    LIMIT 1
),
inv_snapshot AS (
    SELECT inv.INV_WAREHOUSE_SK,
           inv.INV_ITEM_SK,
           inv.INV_QUANTITY_ON_HAND
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.INVENTORY inv
    INNER JOIN latest_date ld ON inv.INV_DATE_SK = ld.max_date_sk
)
SELECT 
    w.W_WAREHOUSE_NAME,
    w.W_STATE,
    COUNT(DISTINCT i.INV_ITEM_SK) AS unique_items,
    SUM(i.INV_QUANTITY_ON_HAND) AS total_quantity_on_hand,
    AVG(i.INV_QUANTITY_ON_HAND) AS avg_quantity_per_item
FROM inv_snapshot i
INNER JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WAREHOUSE w ON i.INV_WAREHOUSE_SK = w.W_WAREHOUSE_SK
GROUP BY w.W_WAREHOUSE_NAME, w.W_STATE
ORDER BY total_quantity_on_hand DESC;
-- </query>
