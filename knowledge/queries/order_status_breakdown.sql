-- <query order_status_breakdown>
-- <description>Order count and revenue by order status</description>
-- <query>
SELECT
    status,
    COUNT(*) AS order_count,
    COALESCE(SUM(total_amount), 0) AS total_amount,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM ecommerce.orders
GROUP BY status
ORDER BY order_count DESC;
-- </query>
