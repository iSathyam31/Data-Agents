-- <query shipping_carrier_performance>
-- <description>Shipping performance by carrier</description>
-- <query>
SELECT
    sd.carrier,
    COUNT(*) AS shipments,
    SUM(CASE WHEN sd.shipping_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN sd.shipping_status = 'In Transit' THEN 1 ELSE 0 END) AS in_transit,
    ROUND(100.0 * SUM(CASE WHEN sd.shipping_status = 'Delivered' THEN 1 ELSE 0 END) / COUNT(*), 1) AS delivery_rate_pct,
    ROUND(AVG(sd.estimated_delivery - o.order_date::date), 1) AS avg_est_delivery_days
FROM ecommerce.shipping_details sd
JOIN ecommerce.orders o ON o.order_id = sd.order_id
GROUP BY sd.carrier
ORDER BY delivery_rate_pct DESC;
-- </query>
