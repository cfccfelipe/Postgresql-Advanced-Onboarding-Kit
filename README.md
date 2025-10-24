# 🧠 Practice Scenario: ProjectPulse – Scalable Project Collaboration Platform

## 🧭 Purpose
In this lab, you'll put PostgreSQL best practices into action to build high-quality, maintainable databases step-by-step.

## 🎯 Learning Objectives
Build and optimize a PostgreSQL schema that supports:

- 👥 Multi-user collaboration on projects
- 📝 Version history and audit trails
- 🔐 Role-based access control (RBAC)
- 🧩 Structured and semi-structured data (JSON)
- 🚀 Performance at scale (partitioning, indexing, materialized views)

## 🧱 System Overview
**ProjectPulse** enables users to:

- Create, edit, and share project profiles
- Attach and manage project documents
- Track work sessions and outcomes
- Audit changes and version history
- Collaborate securely with differentiated permissions (owner vs participant)

## 📁 Folde Structure

```plaintext
potgresql-advanced-onboarding-kit/
├── README.md
├── .gitignore
├── docs/ #Step-by-step guides to complete quests
│
├── src/
│   ├── security # Security-based files
│   ├── sql # Scripts extractiong from de docs/quests.
```


## 🧩 Quest Log – ProjectPulse


| 🧩 Quest                                                   | 🧠 Skill Domain                  |
|------------------------------------------------------------|----------------------------------|
| Design ER diagram                                          | Business Rules and Normalization |
| Design phyisical model                                     | Data Modeling                    |
| Create a Role-Based Access Control (RBAC)                  | SQL Privileges and Roles         |
| Improve Performance & Integrity                            | Performance Tuning & Integrity   |
| Workflows & DB Validation using Fakes                      | Unit Testing                     |

## Automation
make db           # Create DB
make fakes        # Installs Poetry if missing, do tests and generate fake data.
