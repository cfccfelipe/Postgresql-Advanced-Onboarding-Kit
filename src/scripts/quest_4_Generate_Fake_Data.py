#!/usr/bin/env python3
"""
Fake data generator for projectpulse database — normalized, audit-ready
"""
import json
from faker import Faker
import psycopg2
import psycopg2.extras
from datetime import datetime, timedelta
import random
import uuid

fake = Faker(['en_US'])

def get_connection():
    return psycopg2.connect(
        dbname='projectpulse',
        user='nobody',
        password='secure123',
        host='localhost'
    )

def truncate_all_tables(conn):
    cur = conn.cursor()
    cur.execute("""
        TRUNCATE TABLE
            audit.document_history,
            audit.project_history,
            documents.documents,
            projects.projects,
            users.sessions,
            users.users,
            reference.tech_stack_reference,
            reference.feature_reference,
            reference.access_role_reference,
            reference.license_reference,
            reference.phase_reference,
            reference.decision_type_reference,
            reference.tag_reference,
            reference.filetype_reference,
            reference.storage_reference,
            reference.priority_reference
        CASCADE;
    """)
    conn.commit()
    cur.close()

# USERS
def generate_users(conn, count=10):
    cur = conn.cursor()
    data = [(fake.email(), fake.sha256()) for _ in range(count)]
    psycopg2.extras.execute_values(
        cur,
        "INSERT INTO users.users (login, password_hash) VALUES %s",
        data
    )
    conn.commit()
    cur.close()


def generate_sessions(conn, count=20):
    cur = conn.cursor()
    cur.execute("SELECT user_id FROM users.users")
    user_ids = [r[0] for r in cur.fetchall()]

    data = []
    for _ in range(count):
        uid = random.choice(user_ids)
        created = fake.date_time_between(start_date='-30d')
        metadata = {
            "browser": fake.chrome(),
            "device": random.choice(["Desktop", "Mobile", "Tablet"]),
            "location": fake.city()
        }
        data.append((
            str(uuid.uuid4()),                      # session_id
            uid,                                    # user_id
            created,                                # created_at
            created + timedelta(hours=random.randint(1, 48)),  # last_active_at
            created + timedelta(days=30),           # expires_at
            fake.ipv4(),                            # ip_address
            fake.user_agent(),                      # user_agent
            None,                                   # revoked_at
            json.dumps(metadata)                    # metadata as JSON
        ))

    psycopg2.extras.execute_values(
        cur,
        """INSERT INTO users.sessions (
            session_id, user_id, created_at, last_active_at, expires_at,
            ip_address, user_agent, revoked_at, metadata
        ) VALUES %s""",
        data
    )
    conn.commit()
    cur.close()


# REFERENCE
def generate_reference_tables(conn):
    cur = conn.cursor()

    techs = ['Python', 'Docker', 'PostgreSQL', 'React', 'Node.js']
    features = ['Login', 'Search', 'Export', 'Analytics', 'Notifications']
    roles = [('Admin', 'all'), ('Editor', 'write'), ('Viewer', 'read')]
    licenses = [('MIT', 'Permissive'), ('GPL', 'Copyleft'), ('Apache', 'Flexible')]
    phases = [('Planning', 'Initial'), ('Development', 'Active'), ('Testing', 'QA'), ('Deployment', 'Live')]
    decisions = ['Approve', 'Reject', 'Defer']
    tags = [('Security', 'Compliance'), ('UI', 'Design'), ('Backend', 'Architecture')]
    filetypes = [('pdf', 'application/pdf', 'PDF document'), ('txt', 'text/plain', 'Text file')]
    storages = [('AWS', 'us-east-1', '30d'), ('GCP', 'europe-west1', '90d')]
    priorities = ['Low', 'Medium', 'High']

    cur.executemany("INSERT INTO reference.tech_stack_reference (technology) VALUES (%s)", [(t,) for t in techs])
    cur.executemany("INSERT INTO reference.feature_reference (feature) VALUES (%s)", [(f,) for f in features])
    cur.executemany("INSERT INTO reference.access_role_reference (role, capabilities) VALUES (%s, %s)", roles)
    cur.executemany("INSERT INTO reference.license_reference (license_name, description) VALUES (%s, %s)", licenses)
    cur.executemany("INSERT INTO reference.phase_reference (phase_name, description) VALUES (%s, %s)", phases)
    cur.executemany("INSERT INTO reference.decision_type_reference (type_name) VALUES (%s)", [(d,) for d in decisions])
    cur.executemany("INSERT INTO reference.tag_reference (tag, category) VALUES (%s, %s)", tags)
    cur.executemany("INSERT INTO reference.filetype_reference (extension, mime_type, description) VALUES (%s, %s, %s)", filetypes)
    cur.executemany("INSERT INTO reference.storage_reference (provider, location, retention_policy) VALUES (%s, %s, %s)", storages)
    cur.executemany("INSERT INTO reference.priority_reference (priority_name) VALUES (%s)", [(p,) for p in priorities])

    conn.commit()
    cur.close()

# PROJECTS

def generate_projects(conn, count=30):
    cur = conn.cursor()
    cur.execute("SELECT user_id FROM users.users")
    users = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT phase_id FROM reference.phase_reference")
    phases = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT license_id FROM reference.license_reference")
    licenses = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT priority_id FROM reference.priority_reference")
    priorities = [r[0] for r in cur.fetchall()]

    data = []
    for _ in range(count):
        data.append((
            fake.catch_phrase(),                              # title
            fake.text(100),                                   # description
            json.dumps({"api": fake.url()}),                  # endpoints (JSONB)
            json.dumps({"setting": fake.word()}),             # settings (JSONB)
            random.choice(users),                             # owner_id
            fake.image_url(),                                 # image_url
            random.choice(phases),                            # phase_id
            0.1,                                               # version
            random.choice(licenses),                          # license_id
            random.choice(priorities),                        # priority_id
            datetime.now(),                                   # created_at
            datetime.now(),                                   # updated_at
            random.choice(users),                             # updated_by
            None                                              # deleted_at
        ))

    psycopg2.extras.execute_values(
        cur,
        """INSERT INTO projects.projects (
            title, description, endpoints, settings, owner_id, image_url,
            phase_id, version, license_id, priority_id,
            created_at, updated_at, updated_by, deleted_at
        ) VALUES %s""",
        data
    )
    conn.commit()
    cur.close()

def generate_project_links(conn):
    cur = conn.cursor()
    cur.execute("SELECT project_id FROM projects.projects")
    projects = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT feature_id FROM reference.feature_reference")
    features = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT tech_id FROM reference.tech_stack_reference")
    techs = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT tag_id FROM reference.tag_reference")
    tags = [r[0] for r in cur.fetchall()]

    pf = [(random.choice(projects), random.choice(features)) for _ in range(50)]
    pt = [(random.choice(projects), random.choice(techs)) for _ in range(50)]
    pg = [(random.choice(projects), random.choice(tags)) for _ in range(50)]

    psycopg2.extras.execute_values(
        cur, "INSERT INTO projects.project_feature (project_id, feature_id) VALUES %s", pf
    )
    psycopg2.extras.execute_values(
        cur, "INSERT INTO projects.project_tech_stack (project_id, tech_id) VALUES %s", pt
    )
    psycopg2.extras.execute_values(
        cur, "INSERT INTO projects.project_tag (project_id, tag_id) VALUES %s", pg
    )

    conn.commit()
    cur.close()

def generate_decision_logs(conn, count=30):
    cur = conn.cursor()
    cur.execute("SELECT project_id FROM projects.projects")
    projects = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT user_id FROM users.users")
    users = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT type_id FROM reference.decision_type_reference")
    types = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT feature_id FROM reference.feature_reference")
    features = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT document_id FROM documents.documents")
    docs = [r[0] for r in cur.fetchall()]

    data = []
    for _ in range(count):
        data.append((
            random.choice(projects), datetime.now(), random.choice(users),
            random.choice(types), fake.sentence(), fake.text(50), fake.text(50),
            random.choice(features), random.choice(docs)
        ))
    psycopg2.extras.execute_values(
        cur,
        """INSERT INTO projects.project_decision_log (
            project_id, decided_at, decided_by, type_id,
            summary, rationale, impact,
            related_feature_id, related_document_id
        ) VALUES %s""",
        data
    )
    conn.commit()
    cur.close()

# DOCUMENTS
import json

def generate_documents(conn, count=50):
    cur = conn.cursor()
    cur.execute("SELECT project_id FROM projects.projects")
    projects = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT filetype_id FROM reference.filetype_reference")
    filetypes = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT storage_id FROM reference.storage_reference")
    storages = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT priority_id FROM reference.priority_reference")
    priorities = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT phase_id FROM reference.phase_reference")
    phases = [r[0] for r in cur.fetchall()]

    data = []
    for _ in range(count):
        custom_props = {
            "reviewed": random.choice([True, False]),
            "tags": [fake.word(), fake.word()],
            "source": random.choice(["internal", "external"]),
            "format": random.choice(["pdf", "docx", "txt"])
        }

        data.append((
            random.choice(projects),                      # project_id
            fake.file_name(),                             # filename
            random.randint(1000, 1000000),                # size
            datetime.now(),                               # uploaded_at
            random.choice(filetypes),                     # filetype_id
            fake.name(),                                  # uploaded_by
            random.choice(storages),                      # storage_id
            fake.image_url(),                             # image_url
            0.1,                                           # version
            random.choice(priorities),                    # priority_id
            random.choice(phases),                        # phase_id
            fake.text(100),                               # description
            fake.sha1(),                                  # checksum
            json.dumps(custom_props),                     # ✅ custom_properties as JSON
            None                                           # deleted_at
        ))

    psycopg2.extras.execute_values(
        cur,
        """INSERT INTO documents.documents (
            project_id, filename, size, uploaded_at, filetype_id, uploaded_by,
            storage_id, image_url, version, priority_id, phase_id,
            description, checksum, custom_properties, deleted_at
        ) VALUES %s""",
        data
    )
    conn.commit()
    cur.close()

# AUDIT

def generate_project_history(conn, count=50):
    cur = conn.cursor()

    # Obtener claves foráneas válidas
    cur.execute("SELECT project_id FROM projects.projects")
    projects = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT user_id FROM users.users")
    users = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT priority_id FROM reference.priority_reference")
    priorities = [r[0] for r in cur.fetchall()]

    data = []
    for _ in range(count):
        project_id = random.choice(projects)
        changed_by = random.choice(users)
        owner_id = random.choice(users)
        changed_at = fake.date_time_between(start_date='-30d')

        change_summary = {
            "field": random.choice(["title", "description", "priority_id", "version"]),
            "old": fake.word(),
            "new": fake.word()
        }

        data.append((
            project_id,                          # project_id
            changed_at,                          # changed_at
            changed_by,                          # changed_by
            owner_id,                            # owner_id
            fake.catch_phrase(),                 # title
            fake.text(100),                      # description
            json.dumps({"setting": fake.word()}),# settings (JSONB)
            json.dumps({"api": fake.url()}),     # endpoints (JSONB)
            round(random.uniform(0.1, 1.5), 2),  # version
            random.choice(priorities),           # priority_id (válido)
            fake.image_url(),                    # image_url
            None,                                # deleted_at
            json.dumps(change_summary)           # change_summary (JSONB)
        ))

    psycopg2.extras.execute_values(
        cur,
        """INSERT INTO audit.project_history (
            project_id, changed_at, changed_by, owner_id, title, description,
            settings, endpoints, version, priority_id, image_url,
            deleted_at, change_summary
        ) VALUES %s""",
        data
    )
    conn.commit()
    cur.close()

def generate_document_history(conn):
    cur = conn.cursor()
    cur.execute("SELECT document_id FROM documents.documents")
    documents = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT user_id FROM users.users")
    users = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT priority_id FROM reference.priority_reference")
    priorities = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT phase_id FROM reference.phase_reference")
    phases = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT filetype_id FROM reference.filetype_reference")
    filetypes = [r[0] for r in cur.fetchall()]
    cur.execute("SELECT storage_id FROM reference.storage_reference")
    storages = [r[0] for r in cur.fetchall()]

    data = []
    for doc_id in documents:
        data.append((
            doc_id, datetime.now(), random.choice(users),
            fake.file_name(), random.randint(1000, 1000000), 0.2,
            random.choice(priorities), random.choice(phases),
            random.choice(filetypes), random.choice(storages)
        ))

    psycopg2.extras.execute_values(
        cur,
        """INSERT INTO audit.document_history (
            document_id, changed_at, changed_by,
            filename, size, version,
            priority_id, phase_id, filetype_id, storage_id
        ) VALUES %s""",
        data
    )
    conn.commit()
    cur.close()

def main():
    print("=" * 60)
    print("🧪 FAKE DATA GENERATOR — PROJECTPULSE")
    print("=" * 60)

    conn = get_connection()
    try:
        truncate_all_tables(conn)
        generate_users(conn)
        generate_sessions(conn)
        generate_reference_tables(conn)
        generate_projects(conn)
        generate_project_links(conn)
        generate_documents(conn)
        generate_decision_logs(conn)
        generate_project_history(conn)
        generate_document_history(conn)
        print("✅ Data generation complete")
    except Exception as e:
        print(f"❌ Error: {e}")
        conn.rollback()
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    main()
