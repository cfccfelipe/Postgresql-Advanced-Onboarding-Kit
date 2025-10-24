import pytest
from datetime import datetime

def test_document_history_foreign_keys(conn):
    with conn.cursor() as cur:
        # Verifica que todos los document_id existan en documents
        cur.execute("""
            SELECT dh.history_id
            FROM audit.document_history dh
            LEFT JOIN documents.documents d ON dh.document_id = d.document_id
            WHERE d.document_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ document_id inválido en document_history"

        # Verifica que todos los changed_by existan en users
        cur.execute("""
            SELECT dh.history_id
            FROM audit.document_history dh
            LEFT JOIN users.users u ON dh.changed_by = u.user_id
            WHERE u.user_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ changed_by inválido en document_history"

        # Verifica que todos los priority_id existan
        cur.execute("""
            SELECT dh.history_id
            FROM audit.document_history dh
            LEFT JOIN reference.priority_reference pr ON dh.priority_id = pr.priority_id
            WHERE dh.priority_id IS NOT NULL AND pr.priority_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ priority_id inválido en document_history"

        # Verifica que todos los phase_id existan
        cur.execute("""
            SELECT dh.history_id
            FROM audit.document_history dh
            LEFT JOIN reference.phase_reference ph ON dh.phase_id = ph.phase_id
            WHERE dh.phase_id IS NOT NULL AND ph.phase_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ phase_id inválido en document_history"

        # Verifica que todos los filetype_id existan
        cur.execute("""
            SELECT dh.history_id
            FROM audit.document_history dh
            LEFT JOIN reference.filetype_reference ft ON dh.filetype_id = ft.filetype_id
            WHERE dh.filetype_id IS NOT NULL AND ft.filetype_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ filetype_id inválido en document_history"

        # Verifica que todos los storage_id existan
        cur.execute("""
            SELECT dh.history_id
            FROM audit.document_history dh
            LEFT JOIN reference.storage_reference s ON dh.storage_id = s.storage_id
            WHERE dh.storage_id IS NOT NULL AND s.storage_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ storage_id inválido en document_history"

def test_document_history_changed_at_is_datetime(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT changed_at FROM audit.document_history LIMIT 10")
        rows = cur.fetchall()
        for row in rows:
            assert isinstance(row[0], datetime), f"❌ changed_at no es datetime: {row[0]}"
