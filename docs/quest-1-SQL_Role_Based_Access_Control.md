# 🔐 Role-Based Access Control (RBAC) – ProSync

Design a secure, auditable, and scalable PostgreSQL access model for project collaboration using functional roles, user inheritance, and schema-level permissions.

---

## 🟢 Step 0: Create the ProSync Database

**Purpose**: Establish a clean, UTF-8 encoded database with ICU locale support for multilingual compatibility and audit-readiness.

**Traceability**:
- Use `\l` to confirm creation and encoding
- Ensure `postgres` is the owner for initial bootstrap
- Access via `psql -d prosync_db` or equivalent tooling

---

## ✅ Step 1: Create Functional Roles

**Purpose**: Define domain-specific access roles to separate responsibilities and enforce least privilege.

**Roles**:
- `analyst_role`: read-only access to project data
- `developer_role`: full access to operational schemas
- `auditor_role`: read-only access to audit logs
- `admin_role`: full access to all schemas

**Traceability**:
- Use `\du` to confirm role creation
- Avoid table-level grants; rely on schema-level privileges

---

## ✅ Step 2: Create User-Specific Roles

**Purpose**: Create login-enabled roles for individual users and assign them to functional roles.

**Users**:
- `elon`: inherits `analyst_role`
- `donald`: inherits `auditor_role`
- `felipe`: inherits `developer_role`

**Traceability**:
- Use `\dg` to confirm login roles
- Use `pg_auth_members` to audit inheritance
- Avoid direct grants to users; use role chaining

---

## ✅ Step 3: Revoke Implicit Access from PUBLIC

**Purpose**: Remove default access to the `public` schema to enforce explicit permissioning.

**Traceability**:
- Use `pg_default_acl` to confirm no residual access
- Prevent accidental exposure of internal objects

---

## ✅ Step 4: Create Foundational Schemas for Privilege Segmentation

**Purpose**: Segment the database into logical domains for modular access control and auditability.

**Schemas**:
- `projects`: project metadata and ownership
- `documents`: uploaded files and metadata
- `sessions`: authentication and session tracking
- `users`: user profiles and identity
- `audit`: system actions and trace logs
- `staging`: temporary ingest and validation zone
- `system`: schema versioning and migration tracking

**Traceability**:
- Use `pg_namespace` to confirm schema existence
- Assign ownership to `admin_role` for governance

---

## ✅ Step 5: Assign Privileges by Schema

**Purpose**: Grant schema-level access to functional roles based on their responsibilities.

**Access Matrix**:
- `developer_role`: full access to `projects`, `documents`, `sessions`
- `auditor_role`: read-only access to `audit`
- `admin_role`: full access to all schemas
- `analyst_role`: read-only access to `projects`

**Traceability**:
- Use `has_schema_privilege()` to validate grants
- Ensure `USAGE` and `CREATE` are explicitly assigned

---

## ✅ Step 6: Audit and Validate Privileges

**Purpose**: Confirm that each role has the correct access to each schema.

**Traceability**:
- Use `pg_roles` + `pg_namespace` joins to inspect privileges
- Validate `USAGE`, `CREATE`, and table-level access
- Automate checks in CI/CD pipelines if needed

---

## ✅ Step 7: Document Role Hierarchy and Access Matrix

**Purpose**: Maintain a version-controlled YAML file that defines role inheritance and schema access.

```yaml
# security/access-matrix.yaml

roles:
  analyst_role:
    schemas: [projects]
    privileges: [USAGE, SELECT]

  developer_role:
    schemas: [projects, documents, sessions]
    privileges: [USAGE, CREATE, SELECT, INSERT, UPDATE, DELETE]

  auditor_role:
    schemas: [audit]
    privileges: [USAGE, SELECT]

  admin_role:
    schemas: [projects, documents, sessions, users, audit, staging, system]
    privileges: [USAGE, CREATE, SELECT, INSERT, UPDATE, DELETE]

users:
  donald:
    inherits: analyst_role

  elon:
    inherits: analyst_role

  felipe:
    inherits: developer_role
```

Traceability:

Store in Git for auditability

Use as source of truth for onboarding and privilege reviews

✅ Quest Complete
This RBAC foundation enables scalable onboarding, privilege auditing, and domain-based access control for project collaboration in ProSync. It supports CI/CD, session tracking, document staging, and secure multi-user workflows.
