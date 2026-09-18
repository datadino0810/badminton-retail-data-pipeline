-- Products that need attention now
SELECT product_code, product_name, city, quantity_on_hand, reorder_level, stock_status
FROM inventory_status
WHERE stock_status IN ('Low stock', 'Out of stock')
ORDER BY quantity_on_hand, product_name;

-- Product count for every category, including empty categories
SELECT c.category_name, COUNT(p.product_code) AS product_count
FROM category AS c
LEFT JOIN product AS p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC, c.category_name;

-- Unit profit based on the current list price
SELECT
    product_code,
    product_name,
    ROUND(cost_price_cents / 100.0, 2) AS cost_price,
    ROUND(retail_price_cents / 100.0, 2) AS retail_price,
    ROUND((retail_price_cents - cost_price_cents) / 100.0, 2) AS unit_profit
FROM product
ORDER BY unit_profit DESC;

-- Top five products for a selected period
SELECT
    p.product_name,
    SUM(si.quantity_sold) AS units_sold,
    ROUND(SUM(si.quantity_sold * si.unit_price_cents) / 100.0, 2) AS revenue
FROM sale_item AS si
JOIN sale AS s ON s.sale_id = si.sale_id
JOIN product AS p ON p.product_code = si.product_code
WHERE s.sale_date BETWEEN :start_date AND :end_date
GROUP BY p.product_code, p.product_name
ORDER BY units_sold DESC, revenue DESC
LIMIT 5;

-- Shuttlecock demand for a selected period
SELECT COALESCE(SUM(si.quantity_sold), 0) AS shuttlecocks_sold
FROM sale_item AS si
JOIN sale AS s ON s.sale_id = si.sale_id
JOIN product AS p ON p.product_code = si.product_code
JOIN category AS c ON c.category_id = p.category_id
WHERE c.category_name = 'Shuttlecock'
  AND s.sale_date BETWEEN :start_date AND :end_date;

-- Average racquet price for a selected brand
SELECT
    b.brand_name,
    ROUND(AVG(p.retail_price_cents) / 100.0, 2) AS average_racquet_price
FROM product AS p
JOIN brand AS b ON b.brand_id = p.brand_id
JOIN category AS c ON c.category_id = p.category_id
WHERE c.category_name = 'Racquet'
  AND b.brand_name = :brand_name
GROUP BY b.brand_id, b.brand_name;

-- Products restocked in a selected period
SELECT p.product_name, l.city, i.last_restock_date
FROM inventory AS i
JOIN product AS p ON p.product_code = i.product_code
JOIN store_location AS l ON l.location_id = i.location_id
WHERE i.last_restock_date BETWEEN :start_date AND :end_date
ORDER BY i.last_restock_date, p.product_name;

-- Revenue by broad product group
SELECT
    CASE
        WHEN c.category_name = 'Apparel' THEN 'Apparel'
        WHEN c.category_name IN ('Racquet', 'Shuttlecock') THEN 'Equipment'
        ELSE 'Other'
    END AS revenue_group,
    ROUND(SUM(si.quantity_sold * si.unit_price_cents) / 100.0, 2) AS revenue
FROM sale_item AS si
JOIN product AS p ON p.product_code = si.product_code
JOIN category AS c ON c.category_id = p.category_id
GROUP BY revenue_group
ORDER BY revenue DESC;

-- Sales activity for a selected period
SELECT
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_amount_cents) / 100.0, 2) AS revenue
FROM sale_summary
WHERE sale_date BETWEEN :start_date AND :end_date;

-- Products that have never sold
SELECT p.product_code, p.product_name
FROM product AS p
LEFT JOIN sale_item AS si ON si.product_code = p.product_code
WHERE si.product_code IS NULL
ORDER BY p.product_name;

-- Brand with the widest category coverage
SELECT b.brand_name, COUNT(DISTINCT p.category_id) AS category_count
FROM brand AS b
JOIN product AS p ON p.brand_id = b.brand_id
GROUP BY b.brand_id, b.brand_name
ORDER BY category_count DESC, b.brand_name
LIMIT 1;

-- Suppliers for products at or below their reorder level
SELECT
    s.supplier_name,
    p.product_name,
    i.quantity_on_hand,
    i.reorder_level,
    l.city
FROM inventory AS i
JOIN product AS p ON p.product_code = i.product_code
JOIN supplier AS s ON s.supplier_id = p.supplier_id
JOIN store_location AS l ON l.location_id = i.location_id
WHERE i.quantity_on_hand <= i.reorder_level
ORDER BY s.supplier_name, p.product_name;
