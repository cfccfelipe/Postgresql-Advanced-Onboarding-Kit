def test_document_foreign_keys(conn):
    cur = conn.cursor()
    cur.execute("""
        SELECT d.project_id
        FROM documents.documents d
        LEFT JOIN projects.projects p ON d.project_id = p.project_id
        WHERE p.project_id IS NULL
    """)
    assert cur.rowcount == 0, "❌ project_id inválido en documents"

    cur.execute("""
        SELECT d.filetype_id
        FROM documents.documents d
        LEFT JOIN reference.filetype_reference f ON d.filetype_id = f.filetype_id
        WHERE f.filetype_id IS NULL
    """)
    assert cur.rowcount == 0, "❌ filetype_id inválido en documents"

    cur.execute("""
        SELECT d.storage_id
        FROM documents.documents d
        LEFT JOIN reference.storage_reference s ON d.storage_id = s.storage_id
        WHERE s.storage_id IS NULL
    """)
    assert cur.rowcount == 0, "❌ storage_id inválido en documents"

    cur.close()

def test_document_custom_properties_format(conn):
    cur = conn.cursor()
    cur.execute("SELECT custom_properties FROM documents.documents LIMIT 10")
    rows = cur.fetchall()
    for row in rows:
        assert isinstance(row[0], dict) or isinstance(row[0], str), "❌ custom_properties no es JSON serializable"
    cur.close()
