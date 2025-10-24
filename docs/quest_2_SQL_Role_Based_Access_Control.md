# 🔐 Role-Based Access Control (RBAC) – ProjectPulse

Design a secure and scalable PostgreSQL access model for project collaboration using functional roles, user inheritance, and schema-level permissions.

---

## 🟢 Step 0: Create the ProjectPulse Database

**Purpose**:
Establish a clean, UTF-8 encoded database with ICU locale support for multilingual compatibility.

**Traceability**:
- Confirm database creation and encoding via `\l`
- Ensure `postgres` is the owner for initial bootstrap
- Access via CLI or tooling (`psql -d projectpulse`)

---

## ✅ Step 1: Revoke Implicit Access from PUBLIC

**Purpose**:
Remove default access to the `public` schema to enforce explicit permissioning.

**Traceability**:
- Confirm no residual access via `pg_default_acl`
- Prevent accidental exposure of internal objects

---

## ✅ Step 2: Create Functional Roles

**Purpose**:
Define domain-specific access roles to separate responsibilities and enforce least privilege.

**Roles**:
- `developer_role`: full access to operational schemas
- `admin_role`: full access to all schemas

**Traceability**:
- Confirm role creation via `\du`
- Avoid table-level grants; rely on schema-level privileges

---

## ✅ Step 3: Create User-Specific Roles

**Purpose**:
Create login-enabled roles for individual users and assign them to functional roles.

**Users**:
- `felipe`: inherits `developer_role`

**Traceability**:
- Confirm login roles via `\dg`
- Validate inheritance via `pg_auth_members`
- Avoid direct grants to users; use role chaining

---

## ✅ Step 4: Create Foundational Schemas for Privilege Segmentation

**Purpose**:
Segment the database into logical domains for modular access control.

**Schemas**:
- `projects`: project metadata and ownership
- `documents`: uploaded files and metadata
- `reference`: shared lookup tables
- `users`: user profiles and identity

**Traceability**:
- Confirm schema existence via `pg_namespace`
- Assign ownership to `admin_role` for governance

---

## ✅ Step 5: Assign Privileges by Schema

**Purpose**:
Grant schema-level access to functional roles based on their responsibilities.

**Access Matrix**:
- `developer_role`: full access to `projects`, `documents`, `reference`
- `admin_role`: full access to all schemas

**Traceability**:
- Validate grants via `has_schema_privilege()`
- Ensure `USAGE` and `CREATE` are explicitly assigned

---

## ✅ Step 6: Validate Privileges

**Purpose**:
Confirm that each role has the correct access to each schema.

**Traceability**:
- Use joins between `pg_roles`, `pg_namespace`, and `pg_auth_members`
- Validate `USAGE`, `CREATE`, and table-level access
- Automate checks in CI/CD pipelines if needed

---

## ✅ Step 7: Document Role Hierarchy and Access Matrix

**Purpose**:
Maintain a version-controlled YAML file that defines role inheritance and schema access.

```yaml
# security/access-matrix.yaml

roles:
  developer_role:
    schemas: [projects, documents, reference]
    privileges: [USAGE, CREATE, SELECT, INSERT, UPDATE, DELETE]

  admin_role:
    schemas: [projects, documents, reference, users]
    privileges: [USAGE, CREATE, SELECT, INSERT, UPDATE, DELETE]

users:
  felipe:
    inherits: developer_role

