

## 🧩 Core Entities

### 👤 `users`
Roles include cooks, editors, and admins.
Stores profile data, preferences, and access levels.

### 📋 `recipes`
Contains structured metadata (title, category, tags) and semi-structured instructions (`JSONB`).
Supports versioning and collaborative editing.

### 🧂 `ingredients`
Normalized list of ingredients with units, categories, and aliases.
Used across multiple recipes.

### 🍳 `cooking_sessions`
Tracks when users cook specific recipes.
Includes timestamps, feedback, and optional notes.

### 🕒 `recipe_versions`
Temporal table for versioning recipes over time.
Includes `valid_from`, `valid_to`, and change metadata.

### 🛡️ `audit_log`
Trigger-based table that logs inserts, updates, and deletes.
Captures `before_state`, `after_state`, user, and timestamp.

### 📈 `materialized_views`
Precomputed views for trending recipes, top contributors, and most-used ingredients.
Supports analytics and dashboard queries.

### 🔐 `roles`
Implements Role-Based Access Control (RBAC):
- `viewer_role`: read-only access
- `editor_role`: can modify recipes
- `admin_role`: full access including audit and user management

## 🛠️ Challenge Modules (Mapped to Topics)

### 🔐 Security
- Define roles: `viewer_role`, `editor_role`, `admin_role`
- Use `GRANT`, `REVOKE`, and schema-level permissions
- Enforce least privilege and document an access matrix
→ [[Role-Based Access Control]]
→ [[SQL Privileges and Roles]]
→ [[Privileges Granularity]]

---

### 🧱 Model
- Normalize `ingredients`, `recipes`, and `users`
- Apply `CHECK`, `NOT NULL`, `UNIQUE`, `FOREIGN KEY` constraints
- Use `JSONB` for flexible recipe instructions
- Create views: `public_recipes`, `user_favorites`
→ [[Database Modelling Essentials]]
→ [[Normalization and Data Integrity]]
→ [[Views and Derived Tables]]
→ [[Data Types Deep Dive]]

---

### 🔄 Manipulation
- Use `INSERT ON CONFLICT` to upsert ingredients
- Create `AFTER INSERT` trigger to log changes
- Write a stored procedure to duplicate a recipe
- Use `EXISTS` to check if a user has cooked a recipe
- Use `CTEs` to calculate average cook time per user
- Use `window functions` to rank top contributors
→ [[Upserts (INSERT ON CONFLICT)]]
→ [[Triggers & Event-Driven Logic]]
→ [[Stored Procedures & Functions]]
→ [[Common Table Expressions]]
→ [[Window Functions]]
→ [[Subqueries and EXISTS Logic]]

---

### 🕒 Concurrency
- Simulate concurrent edits to the same recipe
- Use `BEGIN`, `SAVEPOINT`, `ROLLBACK` to test ACID behavior
- Add `recipe_versions` table with `valid_from` / `valid_to`
- Use `pg_locks` to inspect locking behavior
- Apply schema migration: add `difficulty_level` to `recipes`
→ [[Transaction Control & ACID]]
→ [[Temporal Tables & Audit Trails]]
→ [[Schema Versioning & Migrations]]
→ [[Concurrency & Locking]]

---

### 🚀 Optimization
- Partition `cooking_sessions` by month
- Create indexes on `user_id`, `recipe_id`, `created_at`
- Use `EXPLAIN ANALYZE` to optimize trending queries
- Create a materialized view for top 10 recipes this week
- Compare OLTP (editing) vs OLAP (analytics) queries
→ [[Query Optimization & EXPLAIN]]
→ [[Partitioning and Sharding]]
→ [[Materialized Views]]
→ [[OLAP vs OLTP]]

| Create a normalized schema for `recipes`, `ingredients`, and `users`| Modeling, Constraints     |
| Insert a new recipe with JSON instructions and upsert ingredients   | JSON, Upserts             |
| Simulate two users editing the same recipe concurrently             | Concurrency, Locking      |
| Add a trigger to log every recipe update                            | Triggers, Audit Trails    |
| Create a materialized view for top 10 recipes by cook count         | Aggregation, Optimization |
| Write a stored procedure to clone a recipe and assign it to a user  | Functions, DML            |
| Partition `cooking_sessions` by month and test query speed          | Partitioning, EXPLAIN     |
| Grant `editor_role` access to update recipes but not delete         | RBAC, Privileges          |

```

Result: Enables reproducible access reviews and simplifies onboarding/offboarding.
-- ANALYST: acceso solo a vista filtrada de recetas
GRANT USAGE ON SCHEMA recipes TO analyst_role;
GRANT SELECT ON recipes.authorized_recipes_view TO analyst_role;
CREATE VIEW recipes.authorized_recipes_view AS
SELECT id, name, category
FROM recipes.recipes
WHERE owner = CURRENT_USER;
REVOKE ALL ON recipes.recipes FROM analyst_role;
ALTER TABLE recipes.recipes ENABLE ROW LEVEL SECURITY;
CREATE POLICY analyst_policy ON recipes.recipes
  FOR SELECT TO analyst_role
  USING (owner = CURRENT_USER);

# 🧠 Module: Enforcing Database Quality in PostgreSQL

## 🔍 The Hook (Self-awareness)

**Summary:**
Database quality is not about perfection—it’s about trust. A high-quality database maintains integrity, traceability, and performance under pressure.

Constraints act as filters, indexes as fuel injectors, and audit logs as diagnostics.

**Ask yourself:** Can I prove my database is accurate, secure, and optimized?

---

## 🧭 The Core Story (Structured-critical Thinking)

### Case of Use
A government agency is launching a public data portal. The backend must guarantee that published data is accurate, secure, and performant.

### Context
- Schemas: `demographics`, `audit`
- Data flows: ingestion → transformation → publication
- Stakeholders: data stewards, developers, compliance officers
- Tools: `CHECK`, `NOT NULL`, `FOREIGN KEY`, `EXPLAIN`, `pg_stat_statements`, triggers

---

## 🛠️ Workflow Steps

### 1. Enforce Integrity with Constraints
- `NOT NULL`, `CHECK`, and `FOREIGN KEY` constraints are applied to the `citizens` table.
- Prevents invalid data (e.g., negative age) and enforces business rules.

### 2. Enable Audit Logging
- A trigger logs every `INSERT`, `UPDATE`, and `DELETE` on `citizens`.
- Captures before/after states and stores them in `audit.change_log`.

### 3. Monitor Performance
- `EXPLAIN ANALYZE` is used to profile queries.
- `pg_stat_statements` tracks query statistics for optimization.

### 4. Apply Role-Based Access Control
- Roles like `analyst_role` and `auditor_role` are granted schema-level privileges.
- Enforces least privilege and supports compliance.

### 5. Validate Data Consistency
- Sample inserts, updates, and deletes simulate real-world operations.
- Ensures schema behaves as expected under edge cases.

---

## 🧠 The Resolution (Strategic Retention)

### Insights
- Quality is sustained through integrity, performance, and traceability.
- Constraints and audits prevent silent failures.
- Performance monitoring ensures scalability.

### Lessons
- Enforce constraints at the schema level.
- Use logging and profiling to detect issues early.
- Validate data flows with test cases.

### Thought Prompts
- ✅ Are all integrity constraints enforced and tested?
- ✅ Is every sensitive operation logged and auditable?
- ✅ Are slow queries identified and optimized?
- ✅ Is access control aligned with least privilege?
- ✅ Are data flows validated with test scenarios?

---

## 🧰 Toolkit

| Element | Description |
|--------|-------------|
| `CHECK` | Validates logical conditions on column values |
| `NOT NULL` | Ensures required fields are always filled |
| `FOREIGN KEY` | Enforces relationships between tables |
| `EXPLAIN` | Profiles query execution plans |
| `pg_stat_statements` | Tracks query performance metrics |

---

## ✅ Results

- Integrity constraints prevent invalid or inconsistent data
- Audit logs support accountability and compliance
- Performance monitoring ensures scalability and responsiveness

---

## ⚠️ Pitfalls

- ❌ Relying solely on application logic for validation
- ❌ Failing to log sensitive operations or changes
- ❌ Ignoring slow queries until performance degrades
- ❌ Lack of test coverage for data flows and transformations
