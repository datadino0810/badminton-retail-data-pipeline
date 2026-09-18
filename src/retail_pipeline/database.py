from __future__ import annotations

import os
import sqlite3
from pathlib import Path


SQL_FILES = ("01_schema.sql", "02_seed.sql", "03_views.sql")


def connect(database_path: Path) -> sqlite3.Connection:
    connection = sqlite3.connect(database_path)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    return connection


def build_database(project_root: Path, database_path: Path) -> None:
    database_path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = database_path.with_suffix(".tmp")

    if temporary_path.exists():
        temporary_path.unlink()

    try:
        with connect(temporary_path) as connection:
            for filename in SQL_FILES:
                sql_path = project_root / "sql" / filename
                connection.executescript(sql_path.read_text(encoding="utf-8"))
        os.replace(temporary_path, database_path)
    except Exception:
        if temporary_path.exists():
            temporary_path.unlink()
        raise
