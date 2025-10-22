# 🧠 Data Modeling – ProSync

Design a normalized, auditable, and onboarding-friendly PostgreSQL schema for project collaboration, document lifecycle, and secure access control. This model supports FastAPI, S3 integration, CI/CD pipelines, and scalable multi-user workflows.

---

## 🟢 Step 0: Modeling Principles

**Purpose**: Define the foundational goals of the schema.

**Goals**:
- Normalize for integrity and traceability
- Enable audit trails and history tracking
- Support soft deletes and staging workflows
- Align with FastAPI + PostgreSQL + S3 architecture
- Facilitate role-based access and CI/CD compatibility

**Traceability**:
- Use ER diagrams or schema visualizers to validate relationships
- Document assumptions and constraints in `modeling-notes.md`

---

## ✅ Step 1: Users and Sessions

**Entities**:
- `users.users`: login credentials and identity
- `auth.sessions`: active authentication tokens with metadata

**Design Decisions**:
- Use `UUID` for session IDs to support distributed systems
- Include `revoked_at`, `expires_at`, and `last_active_at` for audit and timeout logic
- Store `user_agent` and `ip_address` for anomaly detection

**Traceability**:
- Use `pg_stat_activity` and `pg_authid` for session monitoring

---

## ✅ Step 2: Projects and Access Control

**Entities**:
- `projects.projects`: metadata and ownership
- `projects.project_history`: change tracking
- `projects.project_access`: user-to-project mapping
- `projects.access_role_reference`: role definitions

**Design Decisions**:
- Include `deleted_at` for soft deletes
- Use `updated_by` and `project_history` for auditability
- Separate access roles into reference table for normalization

**Traceability**:
- Use `pg_roles` and `pg_auth_members` for access audits

---

## ✅ Step 3: Tags and Classification

**Entities**:
- `projects.tag_reference`: semantic tags
- `projects.project_tag`: many-to-many mapping

**Design Decisions**:
- Normalize tags for reuse and filtering
- Include `category` for grouping and UI segmentation

**Traceability**:
- Use `pg_enum` or `category` filters for tag analytics

---

## ✅ Step 4: Documents and Storage

**Entities**:
- `documents.documents`: uploaded files and metadata
- `documents.document_history`: change tracking
- `documents.filetype_reference`: MIME normalization
- `documents.storage_reference`: S3 and provider metadata

**Design Decisions**:
- Use `checksum` to detect duplicates
- Include `image_url` for previewing documents
- Separate `filetype` and `storage` for normalization and flexibility

**Traceability**:
- Use `pg_largeobject` or external S3 logs for file verification

---

## ✅ Step 5: Staging Area

**Entity**:
- `staging.documents_ingest`: buffer for uploaded files before validation

**Design Decisions**:
- Include `status`, `rejection_reason`, and `metadata` for ingestion workflows
- Use `checksum` and `s3_key` for integrity and traceability
- Allow `notes` for manual review or annotations

**Traceability**:
- Use staging views (`pending_documents`, `rejected_documents`) for operational dashboards

---

## ✅ Step 6: Audit and Schema Versioning

**Entities**:
- `audit.audit_log`: system actions and traceability
- `system.schema_version`: migration tracking

**Design Decisions**:
- Include `actor_id`, `action`, and `timestamp` for full audit trail
- Use `schema_version` for CI/CD compatibility and rollback tracking

**Traceability**:
- Use `pg_stat_statements` and `pg_event_trigger` for deeper audit hooks

---

## ✅ Step 7: Indexes

**Purpose**: Optimize performance and enforce business rules.

**Examples**:
- `idx_documents_project_date`: fast lookup by project and time
- `idx_documents_ingest_checksum`: deduplication
- `idx_project_access_user_role`: permission resolution

**Traceability**:
- Use `pg_indexes` and `EXPLAIN` to validate coverage
- Monitor with `pg_stat_user_indexes`

---

## ✅ Step 8: DBMS Configuration

**Purpose**: Tune PostgreSQL for performance and maintenance.

**Decisions**:
- `fillfactor`: optimize update-heavy tables (`documents`, `audit_log`)
- `parallel_workers`: enable parallel query execution
- `autovacuum`: ensure timely cleanup of audit logs
- `toast_tuple_target`: optimize storage of large fields
- `STORAGE EXTENDED`: allow compression of verbose columns

**Traceability**:
- Use `pg_settings`, `pg_stat_bgwriter`, and `pg_stat_user_tables` for monitoring

---

## ✅ Step 9: Partitioning Strategy

**Purpose**: Improve scalability and query performance for large tables by month.

**Decisions**:
- Partition `documents` by `uploaded_at` (e.g. quarterly)
- Partition `audit_log` by `timestamp` for efficient log rotation
- Use `PARTITION BY RANGE` for time-based slicing

**Traceability**:
- Use `pg_inherits` and `pg_partitioned_table` to inspect structure
- Automate rotation with triggers or scheduled jobs

---

## ✅ Step 10: Constraints and Validation

**Purpose**: Enforce data integrity and business rules.

**Examples**:
- `CHECK (size > 0)` on documents
- `CHECK (status IN ...)` on staging
- `UNIQUE (checksum)` for deduplication
- `CHECK (login LIKE '%@%')` for email validation

**Traceability**:
- Use `pg_constraint` and `pg_class` to audit enforcement
- Validate with test cases in CI/CD pipelines
- Apply `CHECK`, `NOT NULL`, `UNIQUE`, `FOREIGN KEY` constraints

---

## ✅ Views and Operational Dashboards

**Purpose**: Simplify access to common queries and support onboarding.

**Examples**:
- `onboarding_project_summary`: project + document + participant counts
- `active_documents`: filter out soft-deleted files
- `audit_trail_by_project`: join audit logs with project metadata

**Design Decisions**:
- Views abstract complexity and support API responses
- Can be materialized for performance if needed

**Traceability**:
- Use `pg_views` and `pg_matviews` to inspect definitions
- Version views in Git for schema evolution

---

## ✅ Quest Complete

This data model enables normalized, auditable, and scalable collaboration in ProSync. It supports secure access, document lifecycle management, and integration with FastAPI, S3, and CI/CD pipelines. Views, partitions, and DBMS tuning ensure performance and maintainability at scale.
