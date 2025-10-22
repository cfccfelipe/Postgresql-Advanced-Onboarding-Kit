-- STEP 1: USERS AND SESSIONS

CREATE TABLE users.users (
  user_id SERIAL PRIMARY KEY,
  login TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL
);

CREATE TABLE auth.sessions (
  session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id INT NOT NULL REFERENCES users.users(user_id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_active_at TIMESTAMP,
  expires_at TIMESTAMP,
  ip_address TEXT,
  user_agent TEXT,
  revoked_at TIMESTAMP,
  metadata JSONB
);

-- STEP 2: PROJECTS AND ACCESS

CREATE TABLE projects.projects (
  project_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  settings JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP,
  updated_by INT REFERENCES users.users(user_id),
  deleted_at TIMESTAMP
);

CREATE TABLE projects.project_history (
  history_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  changed_by INT NOT NULL REFERENCES users.users(user_id),
  name TEXT,
  description TEXT
);

CREATE TABLE projects.access_role_reference (
  role_id SERIAL PRIMARY KEY,
  role TEXT UNIQUE NOT NULL
);

CREATE TABLE projects.project_access (
  access_id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users.users(user_id),
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  role_id INT NOT NULL REFERENCES projects.access_role_reference(role_id)
);

-- STEP 3: TAGS

CREATE TABLE projects.tag_reference (
  tag_id SERIAL PRIMARY KEY,
  tag TEXT UNIQUE NOT NULL,
  category TEXT
);

CREATE TABLE projects.project_tag (
  project_tag_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  tag_id INT NOT NULL REFERENCES projects.tag_reference(tag_id)
);

-- STEP 4: DOCUMENTS AND STORAGE

CREATE TABLE documents.filetype_reference (
  filetype_id SERIAL PRIMARY KEY,
  extension TEXT UNIQUE NOT NULL,
  mime_type TEXT NOT NULL,
  description TEXT
);

CREATE TABLE documents.storage_reference (
  storage_id SERIAL PRIMARY KEY,
  provider TEXT NOT NULL,
  location TEXT NOT NULL,
  retention_policy TEXT
);

CREATE TABLE documents.documents (
  document_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  filename TEXT NOT NULL,
  size INT NOT NULL,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  filetype_id INT NOT NULL REFERENCES documents.filetype_reference(filetype_id),
  uploaded_by INT NOT NULL REFERENCES users.users(user_id),
  storage_id INT NOT NULL REFERENCES documents.storage_reference(storage_id),
  image_url TEXT,
  checksum TEXT UNIQUE,
  custom_properties JSONB,
  deleted_at TIMESTAMP
);

CREATE TABLE documents.document_history (
  history_id SERIAL PRIMARY KEY,
  document_id INT NOT NULL REFERENCES documents.documents(document_id),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  changed_by INT NOT NULL REFERENCES users.users(user_id),
  filename TEXT,
  size INT,
  filetype_id INT,
  storage_id INT
);

-- STEP 5: STAGING

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.documents_ingest (
  ingest_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  uploaded_by INT NOT NULL REFERENCES users.users(user_id),
  filename TEXT NOT NULL,
  size INT NOT NULL,
  checksum TEXT UNIQUE,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'pending',
  rejection_reason TEXT,
  s3_key TEXT,
  metadata JSONB,
  notes TEXT
);

-- STEP 6: AUDIT AND VERSIONING

CREATE TABLE audit.audit_log (
  audit_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  actor_id INT NOT NULL REFERENCES users.users(user_id),
  action TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE system.schema_version (
  version_id SERIAL PRIMARY KEY,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  description TEXT
);

-- STEP 7: INDEXES

CREATE INDEX idx_documents_project_date ON documents.documents(project_id, uploaded_at DESC);
CREATE INDEX idx_project_access_user_role ON projects.project_access(user_id, role_id);
CREATE INDEX idx_audit_actor_timestamp ON audit.audit_log(actor_id, timestamp DESC);
CREATE INDEX idx_project_tag_project ON projects.project_tag(project_id);
CREATE INDEX idx_documents_ingest_project_status ON staging.documents_ingest(project_id, status);
CREATE INDEX idx_documents_ingest_uploaded_by ON staging.documents_ingest(uploaded_by);
CREATE INDEX idx_documents_ingest_checksum ON staging.documents_ingest(checksum);

-- STEP 8: DBMS CONFIGURATION

ALTER TABLE documents.documents SET (fillfactor = 80);
ALTER TABLE audit.audit_log SET (fillfactor = 90);

ALTER TABLE documents.documents SET (parallel_workers = 2);
ALTER TABLE audit.audit_log SET (parallel_workers = 2);

ALTER TABLE audit.audit_log SET (
  autovacuum_enabled = true,
  autovacuum_vacuum_threshold = 100,
  autovacuum_analyze_threshold = 100
);

ALTER TABLE documents.documents SET (toast_tuple_target = 2048);

ALTER TABLE documents.filetype_reference ALTER COLUMN description SET STORAGE EXTENDED;
ALTER TABLE audit.audit_log ALTER COLUMN action SET STORAGE EXTENDED;

-- STEP 9: PARTITIONING

CREATE TABLE documents.documents_partitioned (
  LIKE documents.documents INCLUDING ALL
) PARTITION BY RANGE (uploaded_at);

CREATE TABLE documents_2025_01 PARTITION OF documents.documents_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE documents_2025_02 PARTITION OF documents.documents_partitioned
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE audit.audit_log_partitioned (
  LIKE audit.audit_log INCLUDING ALL
) PARTITION BY RANGE (timestamp);

CREATE TABLE audit_2025_01 PARTITION OF audit.audit_log_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE audit_2025_02 PARTITION OF audit.audit_log_partitioned
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');


-- STEP 10: CONSTRAINTS

ALTER TABLE users.users ADD CONSTRAINT chk_users_login_email CHECK (login LIKE '%@%');
ALTER TABLE documents.documents ADD CONSTRAINT chk_document_size_positive CHECK (size > 0);
ALTER TABLE staging.documents_ingest ADD CONSTRAINT chk_ingest_size_positive CHECK (size > 0);
ALTER TABLE staging.documents_ingest ADD CONSTRAINT chk_ingest_status_valid CHECK (status IN ('pending', 'validated', 'rejected', 'processed'));
