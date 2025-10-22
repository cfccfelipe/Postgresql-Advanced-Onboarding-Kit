## 🧩 Specific Quest Breakdown – ProSync
| Simulate Real-World Operations                              | SQL Testing & Edge Case Design   |
| Validate Constraint Application During Data Save            | Data Quality & Integrity         |
| Apply and validate Access by role-table                     | Security & Role Verification     |
| Top 3 Materialized Views – Validate Performance             | Query Optimization & Aggregation |
---

### 🔄 Quest: Manipulate and Transform Data

| Task                                                       | Skill Domain             |
|------------------------------------------------------------|--------------------------|
| Use `INSERT ON CONFLICT` to upsert project metadata        | JSON, Upserts            |
| Create `AFTER INSERT` trigger to log document creation     | Triggers, Audit Trails   |
| Write a stored procedure to clone a project and its tags   | Functions, DML           |
| Use `EXISTS` to check if a user has access to a project    | Access Checks            |
| Use `CTEs` to calculate document count per project         | Aggregation, CTEs        |
| Use `window functions` to rank projects by activity        | Analytics, Window Funcs  |

---

### 🕒 Quest: Concurrency and Transaction Safety

| Task                                                       | Skill Domain             |
|------------------------------------------------------------|--------------------------|
| Simulate concurrent edits to the same project              | Concurrency, Locking     |
| Use `BEGIN`, `SAVEPOINT`, `ROLLBACK` to test ACID behavior | Transaction Control      |
| Add `project_versions` table with `valid_from` / `valid_to`| Temporal Modeling        |
| Use `pg_locks` to inspect locking behavior                 | System Inspection        |
| Apply schema migration: add `priority_level` to projects   | Schema Evolution         |

---

### 🚀 Quest: Optimize Queries and Performance

| Task                                                       | Skill Domain             |
|------------------------------------------------------------|--------------------------|
| Use `EXPLAIN ANALYZE` to optimize dashboard queries         | Query Profiling          |
| Create a materialized view for top 10 active projects       | Aggregation, Optimization|
| Compare OLTP (editing) vs OLAP (reporting) queries          | Workload Analysis        |

---

### 🛡️ Quest: Access Control and Privilege Management

| Task                                                       | Skill Domain             |
|------------------------------------------------------------|--------------------------|
| Grant `editor_role` access to update projects but not delete| RBAC, Privileges         |
| Validate access with privilege audit queries               | Security Verification    |

---

### 🧪 Quest: Monitor and Validate System Behavior

| Task                                                       | Skill Domain             |
|------------------------------------------------------------|--------------------------|
| Use `pg_stat_statements` to track query performance        | Monitoring & Tuning      |
| Validate constraint enforcement during data save           | Data Quality             |
| Ensure sensitive operations are logged and auditable       | Compliance & Traceability|
| Test edge cases with simulated inserts and deletes         | SQL Testing              |

