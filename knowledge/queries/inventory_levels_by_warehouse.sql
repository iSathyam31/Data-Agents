-- <query inventory_levels_by_warehouse>
-- <description>Current inventory snapshot per item category and warehouse. INVENTORY is a periodic snapshot table — use MAX(INV_DATE_SK) to get the most recent snapshot per item-warehouse pair. Do NOT sum quantities across dates.</description>
-- <query>
WITH latest_snapshot AS (
    SELECT
        INV_ITEM_SK,
        INV_WAREHOUSE_SK,
        MAX(INV_DATE_SK) AS latest_date_sk
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.INVENTORY
    GROUP BY INV_ITEM_SK, INV_WAREHOUSE_SK
),
current_inventory AS (
    SELECT
        inv.INV_ITEM_SK,
        inv.INV_WAREHOUSE_SK,
        inv.INV_QUANTITY_ON_HAND
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.INVENTORY inv
    JOIN latest_snapshot ls
        ON inv.INV_ITEM_SK     = ls.INV_ITEM_SK
        AND inv.INV_WAREHOUSE_SK = ls.INV_WAREHOUSE_SK
        AND inv.INV_DATE_SK      = ls.latest_date_sk
)
SELECT
    w.W_WAREHOUSE_NAME,
    w.W_STATE,
    i.I_CATEGORY,
    COUNT(DISTINCT ci.INV_ITEM_SK)                              AS distinct_items,
    SUM(ci.INV_QUANTITY_ON_HAND)                                AS total_qty_on_hand,
    SUM(CASE WHEN ci.INV_QUANTITY_ON_HAND = 0 THEN 1 ELSE 0 END) AS stockout_count,
    ROUND(AVG(ci.INV_QUANTITY_ON_HAND), 1)                      AS avg_qty_per_item,
    ROUND(SUM(CASE WHEN ci.INV_QUANTITY_ON_HAND = 0 THEN 1 ELSE 0 END)
          / NULLIF(COUNT(*), 0) * 100, 2)                       AS stockout_rate_pct
FROM current_inventory ci
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WAREHOUSE w ON ci.INV_WAREHOUSE_SK = w.W_WAREHOUSE_SK
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.ITEM i      ON ci.INV_ITEM_SK = i.I_ITEM_SK
WHERE i.I_REC_END_DATE IS NULL
GROUP BY w.W_WAREHOUSE_NAME, w.W_STATE, i.I_CATEGORY
ORDER BY w.W_WAREHOUSE_NAME, stockout_rate_pct DESC;
-- </query>
