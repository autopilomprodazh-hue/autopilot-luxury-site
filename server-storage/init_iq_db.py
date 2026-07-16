import sqlite3
import sys
from pathlib import Path


schema_path = Path(sys.argv[1])
database_path = Path(sys.argv[2])
database_path.parent.mkdir(parents=True, exist_ok=True)

with sqlite3.connect(database_path) as connection:
    connection.executescript(schema_path.read_text(encoding="utf-8"))
    objects = connection.execute(
        "SELECT name FROM sqlite_master "
        "WHERE type IN ('table', 'view') ORDER BY name"
    ).fetchall()

print("DB_OK", ",".join(name for (name,) in objects))
