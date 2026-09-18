# Engineering Decisions

## Rebuild the database from source

A binary database is useful while developing, but it does not explain how the database was created. The pipeline builds a fresh database from versioned schema, seed, and view scripts. This makes each run repeatable and keeps code review focused on readable source files.

The build writes to a temporary database first. The completed file replaces the previous output only after all SQL scripts finish successfully. A failed build cannot leave a half populated database at the expected output path.

## Keep one model across relational and XML outputs

The database and XML document both contain category, brand, supplier, location, staff, customer, product, inventory, sale, and sale item data. The XML file is generated from SQLite rather than maintained as a second manual dataset.

This removes the risk of two files describing different versions of the business. The XSD checks data types, unique identifiers, and references after every export.

## Derive transaction totals

Storing a total on the sale and storing prices on sale items creates two sources for the same value. The current design stores line item facts and calculates transaction totals in the `sale_summary` view.

This keeps the model normalized and prevents totals from drifting when a line item changes.

## Store money as cents

SQLite uses binary floating point for `REAL` values. Values such as 54.99 may not have an exact binary representation. Integer cents make equality checks and sums predictable. Formatting back to dollars happens only in reports and query results.

## Publish curated outputs

The operational tables are useful for detailed queries. CSV exports from the curated views provide cleaner inputs for a dashboard, spreadsheet, or downstream pipeline. XML and XSLT show the same source data moving through a different serialization and reporting path.

## Keep generated files out of Git

The database, CSV files, XML export, HTML reports, compiled Java classes, and downloaded dependencies are build products. They are excluded because the pipeline can recreate them. The repository contains the instructions and source data required to reproduce every result.

## Current boundary

This implementation is a local batch pipeline. It demonstrates data modeling, constraints, transformations, quality checks, and reproducibility. It does not use distributed processing, streaming, or cloud orchestration. Those tools would add complexity without solving a problem at the current data volume.
