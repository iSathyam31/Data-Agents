-- <query payment_method_analysis>
-- <description>Payment success rate and revenue by payment method</description>
-- <query>
SELECT
    payment_method,
    COUNT(*) AS total_payments,
    SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END) AS successful,
    SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed,
    SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending,
    ROUND(100.0 * SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 1) AS success_rate_pct,
    COALESCE(SUM(CASE WHEN status = 'Success' THEN amount ELSE 0 END), 0) AS successful_revenue
FROM ecommerce.payments
GROUP BY payment_method
ORDER BY successful_revenue DESC;
-- </query>
