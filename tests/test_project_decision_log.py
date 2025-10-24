def test_decision_log_foreign_keys(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT decision_id
            FROM projects.project_decision_log d
            LEFT JOIN projects.projects p ON d.project_id = p.project_id
            WHERE p.project_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ project_id inválido en project_decision_log"

        cur.execute("""
            SELECT decision_id
            FROM projects.project_decision_log d
            LEFT JOIN users.users u ON d.decided_by = u.user_id
            WHERE u.user_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ decided_by inválido en project_decision_log"

        cur.execute("""
            SELECT decision_id
            FROM projects.project_decision_log d
            LEFT JOIN reference.decision_type_reference t ON d.type_id = t.type_id
            WHERE t.type_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ type_id inválido en project_decision_log"

        cur.execute("""
            SELECT decision_id
            FROM projects.project_decision_log d
            LEFT JOIN reference.feature_reference f ON d.related_feature_id = f.feature_id
            WHERE d.related_feature_id IS NOT NULL AND f.feature_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ related_feature_id inválido en project_decision_log"

        cur.execute("""
            SELECT decision_id
            FROM projects.project_decision_log d
            LEFT JOIN documents.documents doc ON d.related_document_id = doc.document_id
            WHERE d.related_document_id IS NOT NULL AND doc.document_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ related_document_id inválido en project_decision_log"
