# 🔐 Role-Based Access Control (RBAC) – CookSync

## 🧠 Mission
Design a secure, auditable, and scalable PostgreSQL access model using functional roles, user inheritance, and schema-level permissions.

---

## 🛠️ Workflow Steps

### 🟢 Step 0: Create the CookSync Database

```sql
-- Run this from a superuser or admin context
CREATE DATABASE cooksynth_db
  WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = icu
    ICU_LOCALE = 'en-US'
    TEMPLATE = template0;

```
Traceability:

- Use \l to confirm creation
- Ensure correct owner and encoding for compatibility
- Access the new DB: sudo -u postgres psql -d cooksynth_db

### ✅ Step 1: Create Functional Roles

```sql
-- Create functional roles
CREATE ROLE analyst_role;
CREATE ROLE developer_role;
CREATE ROLE auditor_role;
CREATE ROLE admin_role;
```
Traceability:

- Use \du to confirm scope.
- Schema-level grants avoid table-by-table errors.


### ✅ Step 2: Create User-Specific Roles

```sql
-- Create individual users
CREATE ROLE elon LOGIN PASSWORD 'secure123';
CREATE ROLE donald LOGIN PASSWORD 'secure456';
CREATE ROLE felipe LOGIN PASSWORD 'root';

-- Assign only one functional role per user
GRANT analyst_role TO elon;
GRANT auditor_role TO donald;
GRANT developer_role TO felipe;

-- Audit assigment
SELECT
  r1.rolname AS inherited_role,
  r2.rolname AS user,
  m.admin_option
FROM pg_auth_members m
JOIN pg_roles r1 ON m.roleid = r1.oid
JOIN pg_roles r2 ON m.member = r2.oid
WHERE r2.rolname IN ('felipe');

```
Traceability:

- Use \dg to confirm creation.
- Avoid direct grants to users.

### ✅ Step 3: Revoke Implicit Access from PUBLIC

```sql
-- Revoke default access
REVOKE ALL ON SCHEMA public FROM PUBLIC;
```
Traceability:
- Use pg_default_acl to confirm 0 rules.
- Enforce explicit permissioning to any schema. Avoid granting privileges on public;

### ✅ Step 4: Create foundational schemas for privilege segmentation

```sql
-- Create base schemas
CREATE SCHEMA IF NOT EXISTS recipes;
CREATE SCHEMA IF NOT EXISTS ingredients;
CREATE SCHEMA IF NOT EXISTS cooking_session;
CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS staging;
```
Traceability: Use pg_namespace to verify schema existence and ownership. Explicit schemas improve traceability.

### ✅ Step 5 Assign privileges by schema
```sql
-- DEVELOPER: acceso completo a ingredientes y sesiones
-- INGREDIENTS
GRANT USAGE, CREATE ON SCHEMA ingredients TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ingredients TO developer_role;

-- COOKING_SESSION
GRANT USAGE, CREATE ON SCHEMA cooking_session TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA cooking_session TO developer_role;

-- RECIPES
GRANT USAGE, CREATE ON SCHEMA recipes TO developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA recipes TO developer_role;


-- AUDITOR: acceso de solo lectura a tablas auditadas
GRANT USAGE ON SCHEMA audit TO auditor_role;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO auditor_role;

-- ADMIN: acceso total a todos los esquemas
GRANT ALL PRIVILEGES ON SCHEMA recipes, ingredients, cooking_session, users, audit, staging TO admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA recipes TO admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA users TO admin_role;
```
Traceability:

- Use pg_namespace to confirm schema-level privileges by role


### ✅ Step 8: Audit and validate privileges

```sql
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
```

Traceability:

- Confirms schema-level access per role
- Use has_schema_privilege() for granular validation

### ✅ Step 8: Document with Role Hierachy and Acess Matrix
# access-matrix.yaml (version-controlled)

```yaml
roles:
  analyst_role:
    schemas: [recipes]
    privileges: [USAGE, SELECT]

  developer_role:
    schemas: [recipes, ingredients, cooking_session]
    privileges: [USAGE, CREATE, SELECT, INSERT, UPDATE, DELETE]

  auditor_role:
    schemas: [audit]
    privileges: [USAGE, SELECT]

  admin_role:
    schemas: [recipes, ingredients, cooking_session, users, audit, staging]
    privileges: [USAGE, CREATE, SELECT, INSERT, UPDATE, DELETE]

users:
  donald:
    inherits: analyst_role

  elon:
    inherits: analyst_role

  felipe:
    inherits: developer_role
```

✅ Quest Complete
This RBAC foundation enables scalable onboarding, privilege auditing, and domain-based access control.
