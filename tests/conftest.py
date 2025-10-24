import pytest
import psycopg2

@pytest.fixture(scope="session")
def conn():
    return psycopg2.connect(
        dbname="projectpulse",
        user="nobody",
        password="secure123",
        host="localhost",
        port="5432"
    )
