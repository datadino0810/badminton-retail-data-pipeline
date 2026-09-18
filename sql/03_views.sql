CREATE VIEW inventory_status AS
SELECT
    i.inventory_id,
    i.product_code,
    p.product_name,
    l.location_id,
    l.city,
    i.quantity_on_hand,
    i.reorder_level,
    i.last_restock_date,
    CASE
        WHEN i.quantity_on_hand = 0 THEN 'Out of stock'
        WHEN i.quantity_on_hand < i.reorder_level THEN 'Low stock'
        ELSE 'In stock'
    END AS stock_status
FROM inventory AS i
JOIN product AS p ON p.product_code = i.product_code
JOIN store_location AS l ON l.location_id = i.location_id;

CREATE VIEW sale_summary AS
SELECT
    s.sale_id,
    s.sale_date,
    s.payment_method,
    st.staff_name,
    c.customer_name,
    SUM(si.quantity_sold) AS units_sold,
    SUM(si.quantity_sold * si.unit_price_cents) AS total_amount_cents
FROM sale AS s
JOIN staff AS st ON st.staff_id = s.staff_id
JOIN customer AS c ON c.customer_id = s.customer_id
JOIN sale_item AS si ON si.sale_id = s.sale_id
GROUP BY s.sale_id, s.sale_date, s.payment_method, st.staff_name, c.customer_name;

CREATE VIEW product_performance AS
SELECT
    p.product_code,
    p.product_name,
    c.category_name,
    b.brand_name,
    COALESCE(SUM(si.quantity_sold), 0) AS units_sold,
    COALESCE(SUM(si.quantity_sold * si.unit_price_cents), 0) AS revenue_cents,
    COALESCE(SUM(si.quantity_sold * (si.unit_price_cents - p.cost_price_cents)), 0) AS gross_profit_cents
FROM product AS p
JOIN category AS c ON c.category_id = p.category_id
JOIN brand AS b ON b.brand_id = p.brand_id
LEFT JOIN sale_item AS si ON si.product_code = p.product_code
GROUP BY p.product_code, p.product_name, c.category_name, b.brand_name;
