# ⚙️ Workflow & Validation – `generate_fakes`

This document outlines the integrated validation and data generation strategy behind the `generate_fakes` Makefile target. It combines Poetry environment setup, dependency installation, test coverage, and synthetic data generation into a single reproducible command to support onboarding and CI/CD integrity.

---

## ✅ Step 1: Poetry Environment Initialization

**Purpose**
Ensure Poetry is installed and available for dependency management and script execution.

**Mechanism**
- Checks for Poetry via `which poetry`
- Installs Poetry via `install.python-poetry.org` if missing

**Traceability**
- Logged output confirms installation status
- Compatible with CI/CD and local onboarding

---

## ✅ Step 2: Dependency Installation

**Purpose**
Install all required packages, including development tools, in a clean and reproducible way.

**Mechanism**
- Uses `poetry install --with dev` to install both runtime and dev dependencies
- Ensures availability of `pytest`, `coverage`, `faker`, and `psycopg2-binary`

**Traceability**
- Dependencies locked in `poetry.lock`
- Reproducible across environments

---

## ✅ Step 3: Test Execution with Coverage

**Purpose**
Validate schema logic, generators, and transformations with granular test coverage.

**Mechanism**
- Runs `pytest` with coverage flags
- Targets `src/` directory and outputs terminal + HTML reports

**Traceability**
- Coverage reports stored in `htmlcov/`
- CI/CD compatible via `PYTHONPATH=. poetry run pytest --cov=src`

---

## ✅ Step 4: Synthetic Data Generation

**Purpose**
Populate the PostgreSQL schema with realistic test data for onboarding and benchmarking.

**Mechanism**
- Executes `quest_4_Generate_Fake_Data.py` via Poetry
- Uses `faker` and domain logic to generate users, projects, documents, and metadata

**Traceability**
- Script located in `src/scripts/`
- Output validated via downstream queries

---

## ✅ Step 5: Check results
```sql
SELECT 'users.users' AS table_name, COUNT(*) FROM users.users
UNION ALL
SELECT 'users.sessions', COUNT(*) FROM users.sessions
UNION ALL
SELECT 'reference.tech_stack_reference', COUNT(*) FROM reference.tech_stack_reference
UNION ALL
SELECT 'reference.feature_reference', COUNT(*) FROM reference.feature_reference
UNION ALL
SELECT 'reference.access_role_reference', COUNT(*) FROM reference.access_role_reference
UNION ALL
SELECT 'reference.license_reference', COUNT(*) FROM reference.license_reference
UNION ALL
SELECT 'reference.phase_reference', COUNT(*) FROM reference.phase_reference
UNION ALL
SELECT 'reference.decision_type_reference', COUNT(*) FROM reference.decision_type_reference
UNION ALL
SELECT 'reference.tag_reference', COUNT(*) FROM reference.tag_reference
UNION ALL
SELECT 'reference.filetype_reference', COUNT(*) FROM reference.filetype_reference
UNION ALL
SELECT 'reference.storage_reference', COUNT(*) FROM reference.storage_reference
UNION ALL
SELECT 'reference.priority_reference', COUNT(*) FROM reference.priority_reference
UNION ALL
SELECT 'projects.projects', COUNT(*) FROM projects.projects
UNION ALL
SELECT 'projects.project_feature', COUNT(*) FROM projects.project_feature
UNION ALL
SELECT 'projects.project_tech_stack', COUNT(*) FROM projects.project_tech_stack
UNION ALL
SELECT 'projects.project_tag', COUNT(*) FROM projects.project_tag
UNION ALL
SELECT 'projects.project_decision_log', COUNT(*) FROM projects.project_decision_log;
```
