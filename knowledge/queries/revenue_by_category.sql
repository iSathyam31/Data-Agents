-- <query revenue_by_category>
-- <description>Revenue breakdown by product category from non-cancelled orders</description>
-- <query>
SELECT
    c.name AS category,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS order_count
FROM ecommerce.order_items oi
JOIN ecommerce.orders o ON o.order_id = oi.order_id
JOIN ecommerce.products p ON p.product_id = oi.product_id
JOIN ecommerce.categories c ON c.category_id = p.category_id
WHERE o.status != 'Cancelled'
GROUP BY c.name
ORDER BY revenue DESC;
-- </query>
