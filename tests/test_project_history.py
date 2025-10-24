import pytest
from datetime import datetime
import json

def test_foreign_keys_valid(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT ph.project_id
            FROM audit.project_history ph
            LEFT JOIN projects.projects p ON ph.project_id = p.project_id
            WHERE p.project_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ project_id inválido en project_history"

        cur.execute("""
            SELECT ph.priority_id
            FROM audit.project_history ph
            LEFT JOIN reference.priority_reference pr ON ph.priority_id = pr.priority_id
            WHERE pr.priority_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ priority_id inválido en project_history"

def test_changed_at_is_datetime(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT changed_at FROM audit.project_history LIMIT 10")
        rows = cur.fetchall()
        for row in rows:
            assert isinstance(row[0], datetime), f"❌ changed_at no es datetime: {row[0]}"

def test_change_summary_is_json(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT change_summary FROM audit.project_history LIMIT 10")
        rows = cur.fetchall()
        for row in rows:
            try:
                parsed = json.loads(row[0]) if isinstance(row[0], str) else row[0]
                assert isinstance(parsed, dict), "❌ change_summary no es un dict JSON válido"
            except Exception:
                assert False, f"❌ change_summary no es JSON parseable: {row[0]}"

def test_version_range(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM audit.project_history WHERE version < 0 OR version > 10")
        count = cur.fetchone()[0]
        assert count == 0, f"❌ {count} registros con version fuera de rango (0–10)"
