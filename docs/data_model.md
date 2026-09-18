# Data Model

## Business rules

1. A product belongs to one category, one brand, and one supplier.
2. A product can have inventory at several store locations.
3. A staff member works at one store location.
4. A sale is handled by one staff member and belongs to one customer.
5. A sale contains one or more sale items.
6. A product can appear in many sale items.
7. Prices are stored as integer cents and quantities are stored as integers.
8. Sale totals are derived from their line items.

## Table catalogue

| Table | Grain | Primary key | Main relationships |
| --- | --- | --- | --- |
| `category` | One product category | `category_id` | Referenced by `product` |
| `brand` | One manufacturer | `brand_id` | Referenced by `product` |
| `supplier` | One source of products | `supplier_id` | Referenced by `product` |
| `store_location` | One retail location | `location_id` | Referenced by `staff` and `inventory` |
| `staff` | One employee | `staff_id` | References `store_location` |
| `customer` | One customer | `customer_id` | Referenced by `sale` |
| `product` | One sellable product | `product_code` | References category, brand, and supplier |
| `inventory` | One product at one location | `inventory_id` | References product and location |
| `sale` | One transaction | `sale_id` | References staff and customer |
| `sale_item` | One product line in a sale | `sale_item_id` | References sale and product |

## Curated views

### `inventory_status`

Combines products, locations, and inventory. It assigns each row one of three statuses: In stock, Low stock, or Out of stock.

### `sale_summary`

Returns one row per sale. It joins staff and customer details, counts units, and calculates the transaction total from line items.

### `product_performance`

Returns one row per product, including products with no sales. It calculates units sold, revenue, and gross profit while preserving zero activity rows through a left join.

## Index choices

Indexes cover the foreign keys used most often in joins and the sale date used by reporting filters. SQLite already indexes primary keys and unique constraints, so those columns do not need duplicate indexes.

The current dataset is small, so indexing is not required for speed. The indexes document the expected access paths and make the design ready for larger sample volumes.
