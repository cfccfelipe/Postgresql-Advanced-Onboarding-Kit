-- Step 0: Create the CookSync Database
CREATE DATABASE cooksynth_db
  WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = icu
    ICU_LOCALE = 'en-US'
    TEMPLATE = template0;

-- Step 1: Create Functional Roles
CREATE ROLE analyst_role;
CREATE ROLE developer_role;
CREATE ROLE auditor_role;
CREATE ROLE admin_role;

-- Step 2: Create User-Specific Roles
CREATE ROLE elon LOGIN PASSWORD 'secure123';
CREATE ROLE donald LOGIN PASSWORD 'secure456';
CREATE ROLE felipe LOGIN PASSWORD 'root';

GRANT analyst_role TO elon;
GRANT auditor_role TO donald;
GRANT developer_role TO felipe;

-- Audit assignment
SELECT
  r1.rolname AS inherited_role,
  r2.rolname AS user,
  m.admin_option
FROM pg_auth_members m
JOIN pg_roles r1 ON m.roleid = r1.oid
JOIN pg_roles r2 ON m.member = r2.oid
WHERE r2.rolname IN ('felipe');

-- Step 3: Revoke Implicit Access from PUBLIC
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Step 4: Create Foundational Schemas
CREATE SCHEMA IF NOT EXISTS recipes;
CREATE SCHEMA IF NOT EXISTS ingredients;
CREATE SCHEMA IF NOT EXISTS cooking_session;
CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS staging;

-- Step 5: Assign Privileges by Schema

-- DEVELOPER
GRANT USAGE, CREATE ON SCHEMA ingredients TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ingredients TO developer_role;

GRANT USAGE, CREATE ON SCHEMA cooking_session TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA cooking_session TO developer_role;

GRANT USAGE, CREATE ON SCHEMA recipes TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA recipes TO developer_role;

-- AUDITOR
GRANT USAGE ON SCHEMA audit TO auditor_role;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO auditor_role;

-- ADMIN
GRANT ALL PRIVILEGES ON SCHEMA recipes, ingredients, cooking_session, users, audit, staging TO admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA recipes TO admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA users TO admin_role;

-- Step 8: Audit and Validate Privileges
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
