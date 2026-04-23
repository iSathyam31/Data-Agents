-- <query customer_lifetime_value>
-- <description>Top customers by total spend (non-cancelled orders only)</description>
-- <query>
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email,
    u.city,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_value,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order
FROM ecommerce.users u
JOIN ecommerce.orders o ON o.user_id = u.user_id
WHERE o.status != 'Cancelled'
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.city
ORDER BY lifetime_value DESC
LIMIT 20;
-- </query>
