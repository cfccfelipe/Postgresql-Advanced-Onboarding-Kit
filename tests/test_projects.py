def test_projects_table(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM projects.projects")
        count = cur.fetchone()[0]
        assert count > 0, "❌ La tabla projects.projects está vacía"

        cur.execute("""
            SELECT p.project_id
            FROM projects.projects p
            LEFT JOIN users.users u ON p.owner_id = u.user_id
            WHERE u.user_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ owner_id inválido en projects.projects"

        cur.execute("""
            SELECT p.project_id
            FROM projects.projects p
            LEFT JOIN reference.phase_reference ph ON p.phase_id = ph.phase_id
            WHERE ph.phase_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ phase_id inválido en projects.projects"
