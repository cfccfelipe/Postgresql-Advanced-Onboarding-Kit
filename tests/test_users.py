def test_users_table(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM users.users")
        count = cur.fetchone()[0]
        assert count > 0, "❌ La tabla users.users está vacía"

        cur.execute("SELECT login FROM users.users")
        for login, in cur.fetchall():
            assert "@" in login and "." in login, f"❌ login inválido: {login}"
