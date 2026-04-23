-- <query monthly_revenue>
-- <description>Monthly revenue trend from non-cancelled orders</description>
-- <query>
SELECT
    DATE_TRUNC('month', order_date) AS month,
    COALESCE(SUM(total_amount), 0) AS revenue,
    COUNT(*) AS order_count,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM ecommerce.orders
WHERE status != 'Cancelled'
GROUP BY 1
ORDER BY 1 DESC;
-- </query>
