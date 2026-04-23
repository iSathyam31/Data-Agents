-- <query avg_product_rating>
-- <description>Average product ratings with review counts, highlighting low-rated products</description>
-- <query>
SELECT
    p.name AS product,
    c.name AS category,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    MIN(r.rating) AS min_rating,
    MAX(r.rating) AS max_rating
FROM ecommerce.products p
JOIN ecommerce.categories c ON c.category_id = p.category_id
LEFT JOIN ecommerce.reviews r ON r.product_id = p.product_id
GROUP BY p.name, c.name
HAVING COUNT(r.review_id) > 0
ORDER BY avg_rating ASC;
-- </query>
