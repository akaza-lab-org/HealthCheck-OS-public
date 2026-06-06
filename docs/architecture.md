# Architecture

## System of Record

GitHub is the operational system of record for agent collaboration.

| Layer | Primary tool | Role |
| --- | --- | --- |
| Human planning / overview | Notion | Ideas, meeting notes, high-level roadmap, non-engineer dashboard |
| Intake triage | ChatGPT chat | Turn Notion notes into scoped Issue drafts and suggested AI owners |
| Task queue | GitHub Issues / Projects | AI owner, safety level, status, next action, verification |
| Work execution | GitHub Issues / Projects | Tasks, priority, ownership, acceptance criteria |
| Shared agent memory | GitHub docs / ADRs / PRs | Architecture, decisions, implementation history, verification results |
| Implementation | Repositories | Code, tests, deployment scripts |

## Active Repository Set

- `HealthCheck-OS`: coordination, rules, templates, cross-agent knowledge
- `kensin`:健診ローカルWebアプリ
- `AHK_setting`: AutoHotkey EMR/SC automation

## AI Roles

- Claude: architecture, workflow design, medical-safety review
- Codex: implementation, tests, refactoring, repo maintenance
- Gemini: data structure, CSV/DB workflow, requirement-gap detection

## Kensin + AHK Rule

`kensin` is the source of truth for workflow state and audit history. AHK is an execution bridge. The EMR is the execution target.
