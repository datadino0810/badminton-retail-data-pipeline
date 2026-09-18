from __future__ import annotations

import sqlite3
import tempfile
import unittest
from pathlib import Path

from retail_pipeline.database import build_database, connect
from retail_pipeline.export import export_xml, render_xslt_reports, validate_xml
from retail_pipeline.quality import run_database_checks
from retail_pipeline.run import project_root


class PipelineTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.output_dir = Path(self.temporary_directory.name)
        self.database_path = self.output_dir / "badminton_retail.db"
        build_database(project_root(), self.database_path)

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def test_database_passes_all_quality_checks(self) -> None:
        with connect(self.database_path) as connection:
            checks = run_database_checks(connection)
        self.assertTrue(all(check.passed for check in checks), checks)

    def test_expected_source_row_counts(self) -> None:
        expected_counts = {
            "brand": 10,
            "category": 10,
            "customer": 5,
            "inventory": 10,
            "product": 10,
            "sale": 10,
            "sale_item": 12,
            "staff": 5,
            "store_location": 5,
            "supplier": 5,
        }
        with sqlite3.connect(self.database_path) as connection:
            actual_counts = {
                table: connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
                for table in expected_counts
            }
        self.assertEqual(actual_counts, expected_counts)

    def test_sale_totals_are_calculated_from_line_items(self) -> None:
        with sqlite3.connect(self.database_path) as connection:
            total = connection.execute(
                "SELECT SUM(total_amount_cents) FROM sale_summary"
            ).fetchone()[0]
        self.assertEqual(total, 160987)

    def test_analytics_catalogue_executes(self) -> None:
        query_text = (project_root() / "sql" / "04_analytics.sql").read_text(encoding="utf-8")
        statements = [statement.strip() for statement in query_text.split(";") if statement.strip()]
        parameters = {
            "start_date": "2026-01-01",
            "end_date": "2026-02-28",
            "brand_name": "Yonex",
        }

        with sqlite3.connect(self.database_path) as connection:
            results = [connection.execute(statement, parameters).fetchall() for statement in statements]

        self.assertEqual(len(results), 12)
        self.assertTrue(all(result is not None for result in results))

    def test_xml_export_matches_schema(self) -> None:
        xml_path = self.output_dir / "badminton_retail.xml"
        with connect(self.database_path) as connection:
            export_xml(connection, xml_path)
        validate_xml(xml_path, project_root() / "xml" / "badminton_retail.xsd")

        reports = render_xslt_reports(
            xml_path,
            project_root() / "xml" / "transforms",
            self.output_dir / "reports",
        )
        self.assertEqual(len(reports), 5)
        self.assertTrue(all("<table" in report.read_text(encoding="utf-8") for report in reports))


if __name__ == "__main__":
    unittest.main()
