-- STEP 0: CREATE DATABASE

CREATE DATABASE prosync_db
  WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = icu
    ICU_LOCALE = 'en-US'
    TEMPLATE = template0;

-- STEP 1: CREATE FUNCTIONAL ROLES

CREATE ROLE analyst_role;
CREATE ROLE developer_role;
CREATE ROLE auditor_role;
CREATE ROLE admin_role;

-- STEP 2: CREATE USER-SPECIFIC ROLES

CREATE ROLE elon LOGIN PASSWORD 'secure123';
CREATE ROLE donald LOGIN PASSWORD 'secure456';
CREATE ROLE felipe LOGIN PASSWORD 'root';

GRANT analyst_role TO elon;
GRANT auditor_role TO donald;
GRANT developer_role TO felipe;

-- STEP 3: REVOKE PUBLIC ACCESS

REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- STEP 4: CREATE FOUNDATIONAL SCHEMAS

CREATE SCHEMA IF NOT EXISTS projects;
CREATE SCHEMA IF NOT EXISTS documents;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS system;

-- STEP 5: ASSIGN PRIVILEGES BY SCHEMA

-- DEVELOPER ROLE
GRANT USAGE, CREATE ON SCHEMA projects TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA projects TO developer_role;

GRANT USAGE, CREATE ON SCHEMA documents TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA documents TO developer_role;

GRANT USAGE, CREATE ON SCHEMA auth TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA auth TO developer_role;

-- AUDITOR ROLE
GRANT USAGE ON SCHEMA audit TO auditor_role;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO auditor_role;

-- ADMIN ROLE
GRANT ALL PRIVILEGES ON SCHEMA projects, documents, auth, users, audit, staging, system TO admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA users TO admin_role;

-- STEP 6: DBMS CONFIGURATION

ALTER SCHEMA documents SET SCHEMA OWNER TO admin_role;
ALTER SCHEMA audit SET SCHEMA OWNER TO admin_role;

-- STEP 7: AUDIT AND VALIDATE PRIVILEGES

SELECT
  r.rolname AS role,
  n.nspname AS schema,
  CASE
    WHEN has_schema_privilege(r.rolname, n.nspname, 'USAGE') THEN 'USAGE '
    ELSE ''
  END ||
  CASE
    WHEN has_schema_privilege(r.rolname, n.nspname, 'CREATE') THEN 'CREATE '
    ELSE ''
  END AS privileges
FROM pg_roles r
JOIN pg_namespace n ON has_schema_privilege(r.rolname, n.nspname, 'USAGE')
   OR has_schema_privilege(r.rolname, n.nspname, 'CREATE')
WHERE r.rolname IN ('analyst_role', 'developer_role', 'auditor_role', 'admin_role')
ORDER BY r.rolname, n.nspname;
