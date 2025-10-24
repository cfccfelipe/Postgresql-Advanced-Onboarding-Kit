-- STEP 0: CREATE DATABASE

CREATE DATABASE projectpulse
  WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = icu
    ICU_LOCALE = 'en-US'
    TEMPLATE = template0;

-- STEP 1: REVOKE PUBLIC ACCESS

REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- STEP 2: CREATE FUNCTIONAL ROLES

CREATE ROLE developer_role;
CREATE ROLE auditor_role;
CREATE ROLE admin_role;

-- STEP 3: CREATE USER-SPECIFIC ROLES

CREATE ROLE carlos LOGIN PASSWORD 'secure123';
CREATE ROLE felipe LOGIN PASSWORD 'secure123';
CREATE ROLE nobody LOGIN PASSWORD 'secure123';


GRANT auditor_role TO carlos;
GRANT developer_role TO felipe;
GRANT admin_role TO nobody;

-- STEP 4: CREATE FOUNDATIONAL SCHEMAS

CREATE SCHEMA IF NOT EXISTS projects;
CREATE SCHEMA IF NOT EXISTS documents;
CREATE SCHEMA IF NOT EXISTS reference;
CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS audit;

-- STEP 5: ASSIGN PRIVILEGES BY SCHEMA

-- DEVELOPER ROLE
GRANT USAGE, CREATE ON SCHEMA projects, documents, reference TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA projects, documents, reference TO developer_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA projects, documents, reference TO admin_role;

-- AUDITOR ROLE
GRANT USAGE ON SCHEMA audit TO auditor_role;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO auditor_role;

-- ADMIN ROLE
GRANT ALL PRIVILEGES ON SCHEMA projects, documents, reference, users, audit TO admin_role;
GRANT SELECT, INSERT, UPDATE,TRUNCATE, DELETE ON ALL TABLES IN SCHEMA projects, documents, reference, users, audit TO admin_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA projects, documents, reference, users, audit TO admin_role;

-- STEP 6: OWNERSHIP ASSIGNMENT

ALTER SCHEMA documents OWNER TO admin_role;
ALTER SCHEMA projects OWNER TO admin_role;
ALTER SCHEMA reference OWNER TO admin_role;
ALTER SCHEMA users OWNER TO admin_role;
ALTER SCHEMA audit OWNER TO admin_role;
