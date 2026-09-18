PRAGMA foreign_keys = ON;

CREATE TABLE category (
    category_id TEXT PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE,
    category_description TEXT NOT NULL
);

CREATE TABLE brand (
    brand_id TEXT PRIMARY KEY,
    brand_name TEXT NOT NULL UNIQUE,
    country TEXT NOT NULL
);

CREATE TABLE supplier (
    supplier_id TEXT PRIMARY KEY,
    supplier_name TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL
);

CREATE TABLE store_location (
    location_id TEXT PRIMARY KEY,
    address TEXT NOT NULL,
    city TEXT NOT NULL
);

CREATE TABLE staff (
    staff_id TEXT PRIMARY KEY,
    staff_name TEXT NOT NULL,
    role TEXT NOT NULL,
    location_id TEXT NOT NULL,
    FOREIGN KEY (location_id) REFERENCES store_location(location_id)
);

CREATE TABLE customer (
    customer_id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    CHECK (email LIKE '%_@_%._%')
);

CREATE TABLE product (
    product_code TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_type TEXT NOT NULL,
    cost_price_cents INTEGER NOT NULL,
    retail_price_cents INTEGER NOT NULL,
    category_id TEXT NOT NULL,
    brand_id TEXT NOT NULL,
    supplier_id TEXT NOT NULL,
    CHECK (cost_price_cents >= 0),
    CHECK (retail_price_cents >= 0),
    FOREIGN KEY (category_id) REFERENCES category(category_id),
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE inventory (
    inventory_id TEXT PRIMARY KEY,
    product_code TEXT NOT NULL,
    location_id TEXT NOT NULL,
    quantity_on_hand INTEGER NOT NULL,
    reorder_level INTEGER NOT NULL,
    last_restock_date TEXT NOT NULL,
    CHECK (quantity_on_hand >= 0),
    CHECK (reorder_level >= 0),
    CHECK (last_restock_date = date(last_restock_date)),
    UNIQUE (product_code, location_id),
    FOREIGN KEY (product_code) REFERENCES product(product_code),
    FOREIGN KEY (location_id) REFERENCES store_location(location_id)
);

CREATE TABLE sale (
    sale_id TEXT PRIMARY KEY,
    sale_date TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    staff_id TEXT NOT NULL,
    customer_id TEXT NOT NULL,
    CHECK (sale_date = date(sale_date)),
    CHECK (payment_method IN ('Cash', 'Credit', 'Debit', 'Online')),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE sale_item (
    sale_item_id TEXT PRIMARY KEY,
    sale_id TEXT NOT NULL,
    product_code TEXT NOT NULL,
    quantity_sold INTEGER NOT NULL,
    unit_price_cents INTEGER NOT NULL,
    CHECK (quantity_sold > 0),
    CHECK (unit_price_cents >= 0),
    UNIQUE (sale_id, product_code),
    FOREIGN KEY (sale_id) REFERENCES sale(sale_id),
    FOREIGN KEY (product_code) REFERENCES product(product_code)
);

CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_brand ON product(brand_id);
CREATE INDEX idx_product_supplier ON product(supplier_id);
CREATE INDEX idx_inventory_location ON inventory(location_id);
CREATE INDEX idx_sale_date ON sale(sale_date);
CREATE INDEX idx_sale_staff ON sale(staff_id);
CREATE INDEX idx_sale_customer ON sale(customer_id);
CREATE INDEX idx_sale_item_product ON sale_item(product_code);
