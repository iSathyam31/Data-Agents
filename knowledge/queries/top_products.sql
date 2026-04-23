-- <query top_products>
-- <description>Top 10 products by revenue</description>
-- <query>
SELECT
    p.name AS product,
    c.name AS category,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(AVG(r.rating), 1) AS avg_rating
FROM ecommerce.order_items oi
JOIN ecommerce.orders o ON o.order_id = oi.order_id
JOIN ecommerce.products p ON p.product_id = oi.product_id
JOIN ecommerce.categories c ON c.category_id = p.category_id
LEFT JOIN ecommerce.reviews r ON r.product_id = p.product_id
WHERE o.status != 'Cancelled'
GROUP BY p.name, c.name
ORDER BY revenue DESC
LIMIT 10;
-- </query>
