def test_project_tech_stack_links(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT pt.project_tech_id
            FROM projects.project_tech_stack pt
            LEFT JOIN projects.projects p ON pt.project_id = p.project_id
            WHERE p.project_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ project_id inválido en project_tech_stack"

        cur.execute("""
            SELECT pt.project_tech_id
            FROM projects.project_tech_stack pt
            LEFT JOIN reference.tech_stack_reference t ON pt.tech_id = t.tech_id
            WHERE t.tech_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ tech_id inválido en project_tech_stack"
