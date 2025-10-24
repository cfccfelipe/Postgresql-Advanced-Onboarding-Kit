def test_project_feature_links(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT pf.project_feature_id
            FROM projects.project_feature pf
            LEFT JOIN projects.projects p ON pf.project_id = p.project_id
            WHERE p.project_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ project_id inválido en project_feature"

        cur.execute("""
            SELECT pf.project_feature_id
            FROM projects.project_feature pf
            LEFT JOIN reference.feature_reference f ON pf.feature_id = f.feature_id
            WHERE f.feature_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ feature_id inválido en project_feature"
