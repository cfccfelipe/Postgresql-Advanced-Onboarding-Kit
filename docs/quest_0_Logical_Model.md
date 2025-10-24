# 🧩 Logical Modeling & Normalization – ProjectPulse ER Model

This document outlines the logical modeling and normalization process used to design the ProjectPulse PostgreSQL schema. It begins with business rule extraction and conceptual modeling, then applies normalization and table generation to support audit resilience, onboarding clarity, and semantic traceability.

---

## ✅ Step 0: Logical Modeling & Business Rule Definition

**Purpose**
Capture the domain logic, entities, and relationships that define the ProjectPulse platform before physical implementation.

**Approach**
- Identified core business processes: project tracking, document management, decision logging, and audit history
- Defined entity responsibilities and relationships based on real-world workflows
- Focused on semantic clarity, modularity, and traceability across all interactions

**Business Rules Captured**
- A user can own, update, and audit multiple projects
- Projects can have multiple documents, tags, features, and tech stacks
- Every document and project change must be traceable via history tables
- Decisions must be logged with type, author, and timestamp
- Semantic metadata (tags, features, tech) must be reusable and normalized
- All entities must support soft deletes and versioning

**Traceability**
- Captured in early ER sketches and domain walkthroughs
- Validated with onboarding scenarios and audit simulations
- Served as the foundation for normalization and schema generation

---

## ✅ Step 1: Core Entity Identification

**Purpose**
Define the foundational entities and relationships that drive collaboration, document tracking, and auditability.

**Core Entities**
- `USERS`: contributors, editors, and owners
- `PROJECTS`: central unit of work
- `DOCUMENTS`: attached files and metadata
- `PROJECT_DECISION_LOG`: decisions and rationale
- `PROJECT_HISTORY`, `DOCUMENT_HISTORY`: audit trails
- `SESSIONS`: user activity tracking

**Relationship Mapping**
- Users update projects, edit histories, and make decisions
- Projects include documents, tags, features, tech stacks, and decisions
- Documents evolve through history and are typed and stored
- Semantic metadata is linked via reference tables

**Traceability**
- Modeled using Mermaid ER diagram (see final section)
- Validated against onboarding, audit, and semantic tagging needs

---

## ✅ Step 2: Normalization Strategy

**Purpose**
Ensure data integrity, eliminate redundancy, and support scalable querying.

**Normalization Applied**
- **1NF**: atomic fields, no repeating groups
- **2NF**: removed partial dependencies (e.g., project metadata split from tags/features)
- **3NF**: removed transitive dependencies (e.g., license and priority abstracted into lookup tables)

**Examples**
- `PROJECTS` references `license_id`, `priority_id`, `phase_id` instead of raw strings
- Bridge tables (`PROJECT_TAG`, `PROJECT_FEATURE`, `PROJECT_TECH_STACK`) support many-to-many relationships
- `DOCUMENTS` normalized to separate metadata from filetype and storage references

**Traceability**
- Normalization steps documented in `docs/schema-normalization.md`
- Reviewed via onboarding walkthroughs and audit simulations

---

## ✅ Step 3: Table Generation

**Purpose**
Translate the normalized model into PostgreSQL tables with constraints, indexes, and semantic clarity.

**Mechanism**
- Tables created via SQL scripts in `src/sql/schema/`
- Primary and foreign keys enforced
- Audit fields (`created_at`, `updated_at`, `version`, `deleted_at`) included across all core tables
- JSONB fields used for flexible metadata (`settings`, `endpoints`, `custom_properties`)

**Examples**
- `PROJECTS`: includes semantic references and ownership metadata
- `DOCUMENTS`: includes file metadata, semantic typing, and storage references
- `PROJECT_DECISION_LOG`: links decisions to users and projects

**Traceability**
- Scripts versioned in Git
- ER diagrams updated in `docs/diagrams/`
- Validated via test data and CI/CD coverage

---

## ✅ Step 4: Semantic Tagging & Reference Integrity

**Purpose**
Enable flexible querying, onboarding clarity, and audit resilience.

**Mechanism**
- Bridge tables link projects to semantic metadata
- Reference tables (`LICENSE_REFERENCE`, `PRIORITY_REFERENCE`, etc.) enforce controlled vocabularies
- Materialized views planned for onboarding dashboards and audit snapshots

**Traceability**
- Tags defined in `docs/taxonomy/`
- Views tracked in `src/sql/views/`
- Linked to onboarding scripts and test cases

---

## ✅ Step 5: Entity Relationship Diagram

**Purpose**
Visualize the normalized schema and its relationships for onboarding, auditing, and semantic navigation.

```mermaid
erDiagram
    %% CORE ENTITIES
    USERS ||--o{ PROJECTS : updates
    USERS ||--o{ PROJECT_DECISION_LOG : decides
    USERS ||--o{ PROJECT_HISTORY : edits
    USERS ||--o{ DOCUMENT_HISTORY : edits

    PROJECTS ||--o{ DOCUMENTS : includes
    PROJECTS ||--o{ PROJECT_FEATURE : has_feature
    PROJECTS ||--o{ PROJECT_TECH_STACK : uses_tech
    PROJECTS ||--o{ PROJECT_TAG : tagged_with
    PROJECTS ||--o{ PROJECT_DECISION_LOG : has_decisions
    PROJECTS ||--o{ PROJECT_HISTORY : has_changes

    DOCUMENTS ||--o{ DOCUMENT_HISTORY : has_changes

    %% RELATIONSHIPS
    PROJECT_FEATURE ||--|| FEATURE_REFERENCE : uses_feature
    PROJECT_TECH_STACK ||--|| TECH_STACK_REFERENCE : tech_defined_in
    PROJECT_TAG ||--|| TAG_REFERENCE : uses_tag
    PROJECT_DECISION_LOG ||--|| DECISION_TYPE_REFERENCE : typed_as

    %% NORMALIZED REFERENCES
    PROJECTS ||--|| LICENSE_REFERENCE : licensed_under
    PROJECTS ||--|| PRIORITY_REFERENCE : has_priority
    PROJECTS ||--|| PHASE_REFERENCE : has_phase

    DOCUMENTS ||--|| FILETYPE_REFERENCE : has_type
    DOCUMENTS ||--|| STORAGE_REFERENCE : stored_in
    DOCUMENTS ||--|| PRIORITY_REFERENCE : has_priority
    DOCUMENTS ||--|| PHASE_REFERENCE : has_phase

    DOCUMENT_HISTORY ||--|| FILETYPE_REFERENCE : was_type
    DOCUMENT_HISTORY ||--|| STORAGE_REFERENCE : was_stored_in
    DOCUMENT_HISTORY ||--|| PHASE_REFERENCE : was_phase

    %% SUPPORTING ENTITIES
    USERS ||--o{ SESSIONS : initiates
    PROJECT_HISTORY ||--|| PROJECTS : belongs_to
    DOCUMENT_HISTORY ||--|| DOCUMENTS : belongs_to

    %% ENTITY DECLARATIONS
    USERS {
        int user_id PK
        string login
        string password_hash
    }

    PROJECTS {
        int project_id PK
        string title
        string description
        jsonb endpoints
        jsonb settings
        string image_url
        numeric version
        int license_id FK
        int priority_id FK
        int phase_id FK
        timestamp created_at
        timestamp updated_at
        int updated_by FK
        int owner_id FK
        timestamp deleted_at
    }

    DOCUMENTS {
        int document_id PK
        int project_id FK
        string filename
        int size
        timestamp uploaded_at
        text uploaded_by FK
        int filetype_id FK
        int storage_id FK
        string image_url
        numeric version
        int priority_id FK
        int phase_id FK
        string description
        string checksum
        jsonb custom_properties
        timestamp deleted_at
    }

    PROJECT_DECISION_LOG {}

    SESSIONS {}

    PROJECT_HISTORY {}

    DOCUMENT_HISTORY {}
