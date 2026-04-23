-- <query total_revenue>
-- <description>Total revenue from non-cancelled orders</description>
-- <query>
SELECT
    COALESCE(SUM(total_amount), 0) AS total_revenue,
    COUNT(*) AS total_orders
FROM ecommerce.orders
WHERE status != 'Cancelled';
-- </query>
