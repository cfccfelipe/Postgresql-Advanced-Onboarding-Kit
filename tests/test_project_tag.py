def test_project_tag_links(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT pt.project_tag_id
            FROM projects.project_tag pt
            LEFT JOIN projects.projects p ON pt.project_id = p.project_id
            WHERE p.project_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ project_id inválido en project_tag"

        cur.execute("""
            SELECT pt.project_tag_id
            FROM projects.project_tag pt
            LEFT JOIN reference.tag_reference t ON pt.tag_id = t.tag_id
            WHERE t.tag_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ tag_id inválido en project_tag"
