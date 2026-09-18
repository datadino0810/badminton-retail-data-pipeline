from __future__ import annotations

import sqlite3
from dataclasses import dataclass


@dataclass(frozen=True)
class CheckResult:
    name: str
    passed: bool
    detail: str


def run_database_checks(connection: sqlite3.Connection) -> list[CheckResult]:
    checks: list[CheckResult] = []

    integrity = connection.execute("PRAGMA integrity_check").fetchone()[0]
    checks.append(CheckResult("SQLite integrity", integrity == "ok", str(integrity)))

    foreign_key_rows = connection.execute("PRAGMA foreign_key_check").fetchall()
    checks.append(
        CheckResult(
            "Foreign key integrity",
            not foreign_key_rows,
            f"{len(foreign_key_rows)} violation(s)",
        )
    )

    expected_tables = {
        "brand",
        "category",
        "customer",
        "inventory",
        "product",
        "sale",
        "sale_item",
        "staff",
        "store_location",
        "supplier",
    }
    actual_tables = {
        row[0]
        for row in connection.execute(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'"
        )
    }
    checks.append(
        CheckResult(
            "Expected tables",
            actual_tables == expected_tables,
            f"found {len(actual_tables)} of {len(expected_tables)} tables",
        )
    )

    products_without_inventory = connection.execute(
        """
        SELECT COUNT(*)
        FROM product AS p
        LEFT JOIN inventory AS i ON i.product_code = p.product_code
        WHERE i.product_code IS NULL
        """
    ).fetchone()[0]
    checks.append(
        CheckResult(
            "Inventory coverage",
            products_without_inventory == 0,
            f"{products_without_inventory} product(s) have no inventory record",
        )
    )

    sales_without_items = connection.execute(
        """
        SELECT COUNT(*)
        FROM sale AS s
        LEFT JOIN sale_item AS si ON si.sale_id = s.sale_id
        WHERE si.sale_id IS NULL
        """
    ).fetchone()[0]
    checks.append(
        CheckResult(
            "Sale item coverage",
            sales_without_items == 0,
            f"{sales_without_items} sale(s) have no line item",
        )
    )

    invalid_dates = connection.execute(
        """
        SELECT
            (SELECT COUNT(*) FROM sale WHERE sale_date != date(sale_date))
          + (SELECT COUNT(*) FROM inventory WHERE last_restock_date != date(last_restock_date))
        """
    ).fetchone()[0]
    checks.append(
        CheckResult(
            "ISO date format",
            invalid_dates == 0,
            f"{invalid_dates} invalid date value(s)",
        )
    )

    invalid_money = connection.execute(
        """
        SELECT
            (SELECT COUNT(*) FROM product WHERE cost_price_cents < 0 OR retail_price_cents < 0)
          + (SELECT COUNT(*) FROM sale_item WHERE unit_price_cents < 0)
        """
    ).fetchone()[0]
    checks.append(
        CheckResult(
            "Nonnegative money values",
            invalid_money == 0,
            f"{invalid_money} invalid value(s)",
        )
    )

    return checks


def require_passing(checks: list[CheckResult]) -> None:
    failures = [check for check in checks if not check.passed]
    if failures:
        summary = "; ".join(f"{check.name}: {check.detail}" for check in failures)
        raise RuntimeError(f"Data quality checks failed. {summary}")
