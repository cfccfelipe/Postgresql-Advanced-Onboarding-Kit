# 🧠 Practice Scenario: ProjectPulse – Scalable Projects Collaboration Platform

## 🧭 Purpose
In this lab, you'll put PostgreSQL best practices into action to build maintainable databases step-by-step.

## 🧱 System Overview
**ProjectPulse** enables users to:

- Create, edit, and share project profiles
- Attach and manage project documents
- Track work sessions and outcomes
- Collaborate securely with Role-based access control (RBAC)
- Includes Structured and semi-structured data (JSON)
- Performance at scale (partitioning, indexing, materialized views)
- DB Containerization, Automation with Make, Env with Poetry, and Automation with Make

## 📁 Folder Structure

```plaintext
potgresql-advanced-onboarding-kit/
├── README.md
├── .gitignore
├── Makefile
├── Dockerfile
├── pyproject.toml #Python enviroment for tests
├── docs/ #Step-by-step guides to complete quests
│
├── src/
│   ├── security # Security-based files
│   ├── sql # SQL Scripts extractiong from de docs/quests.
│   ├── scripts # Python Script to generate fakes
```


## 🧩 Quest Log – ProjectPulse


| 🧩 Quest                                                   | 🧠 Skill Domain                  |
|------------------------------------------------------------|----------------------------------|
| Design ER diagram                                          | Business Rules and Normalization |
| Design phyisical model                                     | Data Modeling                    |
| Create a Role-Based Access Control (RBAC)                  | SQL Privileges and Roles         |
| Improve Performance & Integrity                            | Performance Tuning & Integrity   |
| Workflows & DB Validation using Fakes                      | EngX Test                     |
| Containerization                                           | Isolation            |

## Run
- make db           # Create DB
- make fakes        # Test DB with fake data
