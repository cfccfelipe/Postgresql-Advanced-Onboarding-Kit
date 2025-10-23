-- STEP 1: USERS TABLES
CREATE SCHEMA IF NOT EXISTS users;

CREATE TABLE users.users (
  user_id SERIAL PRIMARY KEY,
  login TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL
);

CREATE TABLE users.sessions (
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


-- STEP 2: REFERENCES TABLES
CREATE SCHEMA IF NOT EXISTS reference;

CREATE TABLE reference.feature_reference (
  feature_id SERIAL PRIMARY KEY,
  feature TEXT UNIQUE NOT NULL
);

CREATE TABLE reference.tech_stack_reference (
  tech_id SERIAL PRIMARY KEY,
  technology TEXT UNIQUE NOT NULL
);

CREATE TABLE reference.access_role_reference (
  role_id SERIAL PRIMARY KEY,
  role TEXT UNIQUE NOT NULL,
  capabilities TEXT NOT NULL
);

CREATE TABLE reference.license_reference (
  license_id SERIAL PRIMARY KEY,
  license_name TEXT UNIQUE NOT NULL,
  description TEXT
);

CREATE TABLE reference.phase_reference (
  phase_id SERIAL PRIMARY KEY,
  phase_name TEXT UNIQUE NOT NULL,
  description TEXT
);

CREATE TABLE reference.decision_type_reference (
  type_id SERIAL PRIMARY KEY,
  type_name TEXT UNIQUE NOT NULL
);

CREATE TABLE reference.tag_reference (
  tag_id SERIAL PRIMARY KEY,
  tag TEXT UNIQUE NOT NULL,
  category TEXT
);

CREATE TABLE reference.filetype_reference (
  filetype_id SERIAL PRIMARY KEY,
  extension TEXT UNIQUE NOT NULL,
  mime_type TEXT NOT NULL,
  description TEXT
);

CREATE TABLE reference.storage_reference (
  storage_id SERIAL PRIMARY KEY,
  provider TEXT NOT NULL,
  location TEXT NOT NULL,
  retention_policy TEXT
);

CREATE TABLE reference.priority_reference (
  priority_id SERIAL PRIMARY KEY,
  priority_name TEXT UNIQUE NOT NULL
);


-- STEP 3: PROJECT TABLES

CREATE SCHEMA IF NOT EXISTS projects;

CREATE TABLE projects.projects (
  project_id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  endpoints JSONB,
  settings JSONB,
  owner_id INT REFERENCES users.users(user_id),
  image_url TEXT,
  phase_id INT REFERENCES reference.phase_reference(phase_id),
  version NUMERIC DEFAULT 0.1,
  license_id INT REFERENCES reference.license_reference(license_id),
  priority_id INT REFERENCES reference.priority_reference(priority_id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP,
  updated_by INT REFERENCES users.users(user_id),
  deleted_at TIMESTAMP
);

CREATE TABLE projects.project_feature (
  project_feature_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id) ON DELETE CASCADE,
  feature_id INT NOT NULL REFERENCES reference.feature_reference(feature_id)
);

CREATE TABLE projects.project_tech_stack (
  project_tech_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id) ON DELETE CASCADE,
  tech_id INT NOT NULL REFERENCES reference.tech_stack_reference(tech_id)
);

CREATE TABLE projects.project_decision_log (
  decision_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id) ON DELETE CASCADE,
  decided_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  decided_by INT NOT NULL REFERENCES users.users(user_id),
  type_id INT REFERENCES reference.decision_type_reference(type_id),
  summary TEXT NOT NULL,
  rationale TEXT,
  impact TEXT,
  related_feature_id INT REFERENCES reference.feature_reference(feature_id),
  related_document_id INT REFERENCES documents.documents(document_id)
);

CREATE TABLE projects.project_tag (
  project_tag_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  tag_id INT NOT NULL REFERENCES reference.tag_reference(tag_id)
);

-- STEP 4: DOCUMENTS TABLES

CREATE SCHEMA IF NOT EXISTS documents;

CREATE TABLE documents.documents (
  document_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  filename TEXT NOT NULL,
  size INT NOT NULL,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  filetype_id INT NOT NULL REFERENCES reference.filetype_reference(filetype_id),
  uploaded_by TEXT,
  storage_id INT NOT NULL REFERENCES reference.storage_reference(storage_id),
  image_url TEXT,
  version NUMERIC DEFAULT 0.1,
  priority_id INT REFERENCES reference.priority_reference(priority_id),
  phase_id INT REFERENCES reference.phase_reference(phase_id),
  description TEXT,
  checksum TEXT UNIQUE,
  custom_properties JSONB,
  deleted_at TIMESTAMP
);

-- STEP 5: AUDIT TABLES

CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE audit.project_history (
  history_id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects.projects(project_id),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  changed_by INT NOT NULL REFERENCES users.users(user_id),
  owner_id INT REFERENCES users.users(user_id),
  title TEXT,
  description TEXT,
  settings JSONB,
  endpoints JSONB,
  version NUMERIC,
  priority_id INT REFERENCES reference.priority_reference(priority_id),
  image_url TEXT,
  deleted_at TIMESTAMP,
  change_summary TEXT
);

CREATE TABLE audit.document_history (
  history_id SERIAL PRIMARY KEY,
  document_id INT NOT NULL REFERENCES documents.documents(document_id),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  changed_by INT NOT NULL REFERENCES users.users(user_id),
  filename TEXT,
  size INT,
  version NUMERIC,
  priority_id INT REFERENCES reference.priority_reference(priority_id),
  phase_id INT REFERENCES reference.phase_reference(phase_id),
  filetype_id INT REFERENCES reference.filetype_reference(filetype_id),
  storage_id INT REFERENCES reference.storage_reference(storage_id)
);
