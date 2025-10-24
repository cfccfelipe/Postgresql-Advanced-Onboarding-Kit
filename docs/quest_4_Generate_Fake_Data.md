# ⚙️ Workflow & Validation – `generate_fakes`

This document outlines the integrated validation and data generation strategy behind the `generate_fakes` Makefile target. It combines Poetry environment setup, dependency installation, test coverage, and synthetic data generation into a single reproducible command to support onboarding, audit resilience, and CI/CD integrity.

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
Populate the PostgreSQL schema with realistic, audit-ready test data for onboarding and benchmarking.

**Mechanism**
- Executes `quest_4_Generate_Fake_Data.py` via Poetry
- Uses `faker` and domain logic to generate users, projects, documents, and metadata

**Traceability**
- Script located in `src/scripts/`
- Output validated via downstream queries and audit views

---

### 🧠 Semantic Tags
`#workflow` `#makefile` `#poetry` `#pytest` `#coverage` `#faker`
`#data-generation` `#audit-ready` `#onboarding` `#ci-cd` `#postgresql`
