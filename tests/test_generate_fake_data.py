import pytest
from src.scripts.quest_4_Generate_Fake_Data import (
    generate_users,
    generate_sessions,
    generate_reference_tables,
    generate_projects,
    generate_project_links,
    truncate_all_tables,
    generate_documents,
    generate_decision_logs
)

def test_generate_users_runs(conn):
    truncate_all_tables(conn)
    generate_users(conn, count=5)

    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM users.users")
        count = cur.fetchone()[0]
        assert count == 5

def test_generate_sessions_runs(conn):
    generate_sessions(conn, count=10)

    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM users.sessions")
        count = cur.fetchone()[0]
        assert count == 10

def test_generate_reference_tables_runs(conn):
    generate_reference_tables(conn)

    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM reference.tech_stack_reference")
        assert cur.fetchone()[0] > 0

def test_generate_projects_runs(conn):
    generate_projects(conn, count=3)

    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM projects.projects")
        assert cur.fetchone()[0] == 3

def test_generate_project_links_runs(conn):
    generate_project_links(conn)

    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM projects.project_feature")
        assert cur.fetchone()[0] > 0


def test_generate_documents(conn):
    generate_documents(conn, count=5)
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM documents.documents")
        assert cur.fetchone()[0] >= 5

def test_generate_decision_logs(conn):
    generate_decision_logs(conn, count=5)
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM projects.project_decision_log")
        assert cur.fetchone()[0] >= 5
