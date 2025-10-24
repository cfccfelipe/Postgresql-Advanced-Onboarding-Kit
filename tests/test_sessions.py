def test_sessions_table(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM users.sessions")
        count = cur.fetchone()[0]
        assert count > 0, "❌ La tabla users.sessions está vacía"

        cur.execute("""
            SELECT s.session_id
            FROM users.sessions s
            LEFT JOIN users.users u ON s.user_id = u.user_id
            WHERE u.user_id IS NULL
        """)
        assert cur.rowcount == 0, "❌ user_id inválido en users.sessions"
