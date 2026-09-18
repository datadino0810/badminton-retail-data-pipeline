from __future__ import annotations

import csv
import sqlite3
from pathlib import Path

from lxml import etree


CSV_EXPORTS = {
    "inventory_status.csv": "SELECT * FROM inventory_status ORDER BY inventory_id",
    "product_performance.csv": "SELECT * FROM product_performance ORDER BY product_code",
    "sale_summary.csv": "SELECT * FROM sale_summary ORDER BY sale_date, sale_id",
}


XML_LAYOUT = (
    ("categories", "category", "category", ("category_id", "category_name", "category_description")),
    ("brands", "brand", "brand", ("brand_id", "brand_name", "country")),
    ("suppliers", "supplier", "supplier", ("supplier_id", "supplier_name", "phone")),
    ("store_locations", "store_location", "store_location", ("location_id", "address", "city")),
    ("staff_members", "staff", "staff", ("staff_id", "staff_name", "role", "location_id")),
    ("customers", "customer", "customer", ("customer_id", "customer_name", "email")),
    (
        "products",
        "product",
        "product",
        (
            "product_code",
            "product_name",
            "product_type",
            "cost_price_cents",
            "retail_price_cents",
            "category_id",
            "brand_id",
            "supplier_id",
        ),
    ),
    (
        "inventory_records",
        "inventory",
        "inventory",
        (
            "inventory_id",
            "product_code",
            "location_id",
            "quantity_on_hand",
            "reorder_level",
            "last_restock_date",
        ),
    ),
    ("sales", "sale", "sale", ("sale_id", "sale_date", "payment_method", "staff_id", "customer_id")),
    (
        "sale_items",
        "sale_item",
        "sale_item",
        ("sale_item_id", "sale_id", "product_code", "quantity_sold", "unit_price_cents"),
    ),
)


def export_csv_files(connection: sqlite3.Connection, output_dir: Path) -> list[Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []

    for filename, query in CSV_EXPORTS.items():
        rows = connection.execute(query).fetchall()
        output_path = output_dir / filename
        with output_path.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.writer(stream)
            writer.writerow(rows[0].keys() if rows else [])
            writer.writerows(rows)
        written.append(output_path)

    return written


def export_xml(connection: sqlite3.Connection, output_path: Path) -> Path:
    root = etree.Element("badminton_retail_data")

    for container_name, item_name, table_name, columns in XML_LAYOUT:
        container = etree.SubElement(root, container_name)
        query = f"SELECT {', '.join(columns)} FROM {table_name} ORDER BY {columns[0]}"
        for row in connection.execute(query):
            item = etree.SubElement(container, item_name)
            for column in columns:
                etree.SubElement(item, column).text = str(row[column])

    output_path.parent.mkdir(parents=True, exist_ok=True)
    tree = etree.ElementTree(root)
    tree.write(output_path, encoding="UTF-8", xml_declaration=True, pretty_print=True)
    return output_path


def validate_xml(xml_path: Path, schema_path: Path) -> None:
    schema = etree.XMLSchema(etree.parse(schema_path))
    document = etree.parse(xml_path)
    schema.assertValid(document)


def render_xslt_reports(xml_path: Path, transforms_dir: Path, output_dir: Path) -> list[Path]:
    document = etree.parse(xml_path)
    output_dir.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []

    for transform_path in sorted(transforms_dir.glob("*.xsl")):
        transform = etree.XSLT(etree.parse(transform_path))
        result = transform(document)
        output_path = output_dir / f"{transform_path.stem}.html"
        output_path.write_bytes(etree.tostring(result, pretty_print=True, method="html"))
        written.append(output_path)

    return written
