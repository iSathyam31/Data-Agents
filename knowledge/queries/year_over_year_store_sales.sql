-- <query year_over_year_store_sales>
-- <description>Year-over-year store sales comparison by month. Uses DATE_DIM.D_SAME_DAY_LY to find the equivalent period last year without complex self-joins. Shows absolute and percentage change.</description>
-- <query>
WITH current_year AS (
    SELECT
        d.D_YEAR,
        d.D_MOY,
        d.D_MONTH_SEQ,
        d.D_DATE_SK,
        SUM(ss.SS_EXT_SALES_PRICE)  AS revenue
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2001
    GROUP BY d.D_YEAR, d.D_MOY, d.D_MONTH_SEQ, d.D_DATE_SK
),
prior_year AS (
    SELECT
        d.D_YEAR,
        d.D_MOY,
        d.D_MONTH_SEQ,
        SUM(ss.SS_EXT_SALES_PRICE)  AS revenue
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d ON ss.SS_SOLD_DATE_SK = d.D_DATE_SK
    WHERE d.D_YEAR = 2000
    GROUP BY d.D_YEAR, d.D_MOY, d.D_MONTH_SEQ
)
SELECT
    cy.D_YEAR                                               AS current_year,
    cy.D_MOY                                                AS month,
    ROUND(cy.revenue, 2)                                    AS current_revenue,
    ROUND(COALESCE(py.revenue, 0), 2)                       AS prior_year_revenue,
    ROUND(cy.revenue - COALESCE(py.revenue, 0), 2)         AS revenue_change,
    ROUND((cy.revenue - COALESCE(py.revenue, 0)) / NULLIF(py.revenue, 0) * 100, 2) AS yoy_growth_pct
FROM current_year cy
LEFT JOIN prior_year py ON cy.D_MOY = py.D_MOY
ORDER BY cy.D_MOY;
-- </query>
