from __future__ import annotations

import argparse
from pathlib import Path

from retail_pipeline.database import build_database, connect
from retail_pipeline.export import export_csv_files, export_xml, render_xslt_reports, validate_xml
from retail_pipeline.quality import require_passing, run_database_checks


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def run_pipeline(output_dir: Path) -> None:
    root = project_root()
    database_path = output_dir / "badminton_retail.db"

    build_database(root, database_path)

    with connect(database_path) as connection:
        checks = run_database_checks(connection)
        require_passing(checks)
        csv_files = export_csv_files(connection, output_dir / "csv")
        xml_path = export_xml(connection, output_dir / "xml" / "badminton_retail.xml")

    schema_path = root / "xml" / "badminton_retail.xsd"
    validate_xml(xml_path, schema_path)
    report_files = render_xslt_reports(
        xml_path,
        root / "xml" / "transforms",
        output_dir / "reports",
    )

    print(f"Database: {database_path}")
    print(f"Database checks: {len(checks)} passed")
    print(f"CSV exports: {len(csv_files)} written")
    print(f"XML document: {xml_path}")
    print("XML validation: passed")
    print(f"HTML reports: {len(report_files)} written")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build and validate the badminton retail data pipeline")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("build"),
        help="Directory for the generated database and exports",
    )
    arguments = parser.parse_args()
    run_pipeline(arguments.output_dir.resolve())


if __name__ == "__main__":
    main()
