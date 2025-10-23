# 🧠 Data Modeling – ProjectPulse

Design a normalized, auditable, and onboarding-friendly PostgreSQL schema for project collaboration, document lifecycle, and secure access control. This model supports FastAPI, S3 integration, CI/CD pipelines, and scalable multi-user workflows.

---

## 🟢 Step 0: Modeling Principles

**Purpose**:
Define the foundational goals of the schema.

**Goals**:
- Normalize for integrity and traceability
- Enable audit trails and history tracking
- Align with FastAPI + PostgreSQL + S3 architecture
- Facilitate role-based access and CI/CD compatibility

**Traceability**:
- Use ER diagrams or schema visualizers to validate relationships
- Document assumptions and constraints in `modeling-notes.md`

---

## ✅ Step 1: Users and Sessions

**Entities**:
- `users.users`: login credentials and identity
- `users.sessions`: active authentication tokens with metadata

**Design Decisions**:
- Use `SERIAL` for user IDs and `UUID` for session IDs
- Include `revoked_at`, `expires_at`, and `last_active_at` for audit and timeout logic
- Store `user_agent`, `ip_address`, and `metadata` for anomaly detection and session context

**Traceability**:
- Monitor sessions via `pg_stat_activity`
- Audit role membership via `pg_auth_members`

---

## ✅ Step 2: Reference Tables

**Entities**:
- `feature_reference`, `tech_stack_reference`, `access_role_reference`
- `license_reference`, `phase_reference`, `decision_type_reference`
- `tag_reference`, `filetype_reference`, `storage_reference`, `priority_reference`

**Design Decisions**:
- Normalize all lookup values for reuse and filtering
- Include `category`, `description`, and `retention_policy` where applicable
- Use `UNIQUE` constraints to enforce semantic consistency

**Traceability**:
- Use `pg_class`, `pg_attribute`, and `information_schema.columns` to inspect structure
- Document reference semantics in `reference-glossary.md`

---

## ✅ Step 3: Projects and Access Control

**Entities**:
- `projects.projects`: metadata and ownership
- `project_feature`, `project_tech_stack`: many-to-many mappings
- `project_decision_log`: rationale and impact tracking
- `project_tag`: semantic classification

**Design Decisions**:
- Include `deleted_at` for soft deletes
- Use `updated_by` and `project_history` for auditability
- Normalize features, tech stack, and tags for filtering and UI segmentation
- Link decisions to features and documents for traceability

**Traceability**:
- Use `pg_roles`, `pg_auth_members`, and `pg_namespace` for access audits
- Document decision rationale in `decision-log.md`

---

## ✅ Step 4: Documents and Storage

**Entities**:
- `documents.documents`: uploaded files and metadata
- `document_history`: change tracking
- `filetype_reference`: MIME normalization
- `storage_reference`: S3 and provider metadata

**Design Decisions**:
- Use `checksum` to detect duplicates
- Include `image_url` for previewing documents
- Store `custom_properties` in JSONB for flexible tagging
- Normalize `filetype`, `storage`, `priority`, and `phase` for filtering and lifecycle control

**Traceability**:
- Use external S3 logs and internal audit hooks for file verification
- Document ingestion rules in `document-ingest.md`

---

## ✅ Step 5: Audit and History Tracking

**Entities**:
- `audit.project_history`: snapshots of project metadata
- `audit.document_history`: snapshots of document metadata

**Design Decisions**:
- Include `changed_by`, `changed_at`, and `change_summary` for audit resilience
- Track version, priority, phase, and ownership over time
- Use history tables to support rollback, compliance, and onboarding clarity

**Traceability**:
- Use `pg_stat_statements`, `pg_event_trigger`, and `pg_constraint` for deeper audit hooks
- Document audit policies in `audit-policy.md`

---

### 🧠 Semantic Tags
`#data-modeling` `#postgresql` `#audit-ready` `#fastapi` `#s3` `#ci-cd` `#onboarding` `#schema-design`
