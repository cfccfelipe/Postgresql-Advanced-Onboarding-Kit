-- STEP 1: INDEXES

-- Fast lookup of documents by project and upload date
CREATE INDEX idx_documents_project_uploaded_at ON documents.documents(project_id, uploaded_at DESC);

-- Fast lookup of tags by project
CREATE INDEX idx_project_tag_project_id ON projects.project_tag(project_id);

-- Fast lookup of projects by owner
CREATE INDEX idx_projects_owner_id ON projects.projects(owner_id);

-- Fast lookup of projects by phase
CREATE INDEX idx_projects_phase_id ON projects.projects(phase_id);

-- Fast lookup of projects by priority
CREATE INDEX idx_projects_priority_id ON projects.projects(priority_id);

-- Fast lookup of projects by license
CREATE INDEX idx_projects_license_id ON projects.projects(license_id);

-- Fast lookup of projects by tech stack
CREATE INDEX idx_project_tech_stack_tech_id ON projects.project_tech_stack(tech_id);

-- Fast lookup of projects by feature
CREATE INDEX idx_project_feature_feature_id ON projects.project_feature(feature_id);


-- STEP 2: DBMS PERFORMANCE CONFIGURATION

-- Improve update performance by reducing page fill
ALTER TABLE documents.documents SET (fillfactor = 80);

-- Enable parallel query execution
ALTER TABLE documents.documents SET (parallel_workers = 2);

-- Optimize TOAST storage for large JSONB or text fields
ALTER TABLE documents.documents SET (toast_tuple_target = 2048);

-- Extended storage for long text fields
ALTER TABLE reference.filetype_reference ALTER COLUMN description SET STORAGE EXTENDED;

-- Improve update performance by reducing page fill
ALTER TABLE projects.projects SET (fillfactor = 80);

-- Enable parallel query execution for large scans or joins
ALTER TABLE projects.projects SET (parallel_workers = 2);

-- Optimize TOAST storage for large JSONB fields (e.g., endpoints, settings)
ALTER TABLE projects.projects SET (toast_tuple_target = 2048);

-- STEP 3: CHECKING_CONSTRAINTS

-- Ensure login is a valid email format
ALTER TABLE users.users ADD CONSTRAINT chk_users_login_email CHECK (login LIKE '%@%');

-- Ensure document size is positive
ALTER TABLE documents.documents ADD CONSTRAINT chk_document_size_positive CHECK (size > 0);

-- Prevent empty passwords
ALTER TABLE users.users ADD CONSTRAINT chk_password_not_empty CHECK (char_length(password_hash) > 0);

-- Optional: enforce lowercase logins
ALTER TABLE users.users ADD CONSTRAINT chk_login_lowercase CHECK (login = lower(login));

-- Ensure version is always positive
ALTER TABLE projects.projects ADD CONSTRAINT chk_project_version_positive CHECK (version >= 0);

-- Prevent empty titles
ALTER TABLE projects.projects ADD CONSTRAINT chk_project_title_not_empty CHECK (char_length(title) > 0);

-- Ensure version is always positive
ALTER TABLE documents.documents ADD CONSTRAINT chk_document_version_positive CHECK (version >= 0);

-- Prevent empty filenames
ALTER TABLE documents.documents ADD CONSTRAINT chk_filename_not_empty CHECK (char_length(filename) > 0);

-- Ensure summary is present
ALTER TABLE projects.project_decision_log ADD CONSTRAINT chk_decision_summary_not_empty CHECK (char_length(summary) > 0);


-- STEP 4: PARTITIONING
-- Future implementation for time-based
-- -- Master partitioned table for documents
-- CREATE TABLE documents.documents_partitioned (
--   LIKE documents.documents INCLUDING DEFAULTS INCLUDING CONSTRAINTS
-- ) PARTITION BY RANGE (uploaded_at);

-- -- Monthly partitions
-- CREATE TABLE documents.documents_2025_01 PARTITION OF documents.documents_partitioned
-- FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- CREATE TABLE documents.documents_2025_02 PARTITION OF documents.documents_partitioned
-- FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE projects.projects_partitioned (
  LIKE projects.projects INCLUDING DEFAULTS INCLUDING CONSTRAINTS
) PARTITION BY LIST (priority_id);

CREATE TABLE projects.projects_high_priority PARTITION OF projects.projects_partitioned
FOR VALUES IN (1);

CREATE TABLE projects.projects_medium_priority PARTITION OF projects.projects_partitioned
FOR VALUES IN (2);

CREATE TABLE projects.projects_low_priority PARTITION OF projects.projects_partitioned
FOR VALUES IN (3);

CREATE TABLE documents.documents_partitioned_by_priority (
  LIKE documents.documents INCLUDING DEFAULTS INCLUDING CONSTRAINTS
) PARTITION BY LIST (priority_id);

CREATE TABLE documents.documents_high_priority PARTITION OF documents.documents_partitioned_by_priority
FOR VALUES IN (1);

CREATE TABLE documents.documents_medium_priority PARTITION OF documents.documents_partitioned_by_priority
FOR VALUES IN (2);

CREATE TABLE documents.documents_low_priority PARTITION OF documents.documents_partitioned_by_priority
FOR VALUES IN (3);


-- STEP 5: MATERIALIZED VIEWS FOR OPTIMIZED ACCESS

CREATE MATERIALIZED VIEW projects.matview_project_summary AS
SELECT
  p.project_id,
  p.title,
  p.description,
  u.login AS owner_login,
  pr.priority_name,
  ph.phase_name,
  lr.license_name,
  p.version,
  p.created_at,
  p.updated_at,
  p.deleted_at
FROM projects.projects p
LEFT JOIN users.users u ON p.owner_id = u.user_id
LEFT JOIN reference.priority_reference pr ON p.priority_id = pr.priority_id
LEFT JOIN reference.phase_reference ph ON p.phase_id = ph.phase_id
LEFT JOIN reference.license_reference lr ON p.license_id = lr.license_id;
-- REFRESH MATERIALIZED VIEW projects.matview_project_summary;

CREATE MATERIALIZED VIEW documents.matview_document_metadata AS
SELECT
  d.document_id,
  d.project_id,
  d.filename,
  d.size,
  d.version,
  d.uploaded_at,
  d.uploaded_by,
  ft.extension AS file_extension,
  ft.mime_type,
  s.provider AS storage_provider,
  s.location AS storage_location,
  d.priority_id,
  d.phase_id,
  d.deleted_at
FROM documents.documents d
LEFT JOIN reference.filetype_reference ft ON d.filetype_id = ft.filetype_id
LEFT JOIN reference.storage_reference s ON d.storage_id = s.storage_id;
-- REFRESH MATERIALIZED VIEW documents.matview_document_metadata;

CREATE MATERIALIZED VIEW projects.matview_project_tags AS
SELECT
  pt.project_id,
  tr.tag,
  tr.category
FROM projects.project_tag pt
JOIN reference.tag_reference tr ON pt.tag_id = tr.tag_id;
-- REFRESH MATERIALIZED VIEW projects.matview_project_tags;

CREATE MATERIALIZED VIEW projects.matview_project_feature_matrix AS
SELECT
  pf.project_id,
  fr.feature
FROM projects.project_feature pf
JOIN reference.feature_reference fr ON pf.feature_id = fr.feature_id;
-- REFRESH MATERIALIZED VIEW projects.matview_project_feature_matrix;

CREATE MATERIALIZED VIEW projects.matview_project_tech_stack AS
SELECT
  pts.project_id,
  ts.tech_name,
  ts.category
FROM projects.project_tech_stack pts
JOIN reference.tech_stack_reference ts ON pts.tech_id = ts.tech_id;
-- REFRESH MATERIALIZED VIEW projects.matview_project_tech_stack;

CREATE MATERIALIZED VIEW audit.matview_project_history_audit AS
SELECT
  h.history_id,
  h.project_id,
  h.changed_at,
  u.login AS changed_by,
  h.title,
  h.description,
  h.version,
  h.priority,
  h.image_url,
  h.deleted_at,
  h.change_summary
FROM audit.project_history h
LEFT JOIN users.users u ON h.changed_by = u.user_id;
-- REFRESH MATERIALIZED VIEW audit.matview_project_history_audit;
