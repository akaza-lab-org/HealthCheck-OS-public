# Mobile AI Context Pack

Use this compact context when drafting GitHub Issues from mobile AI chat or Gemini Gems.

## Project

HealthCheck-OS coordinates medical checkup automation work across humans and AI agents.

Active repositories:

- `akaza-lab-org/HealthCheck-OS`: coordination rules, agent handoff, shared docs
- `akaza-lab-org/clinic-app`: `kensin` local web app
- `akaza-lab-org/AHK_setting`: AutoHotkey EMR/SC automation

If you are setting up a fresh local environment, read `docs/local_environment_bootstrap.md` first.

## Core Rules

- Medical safety is the first priority.
- Do not include real patient data, identifiers, production logs, screenshots with identifiers, terminal secrets, or credentials.
- Work should be tracked in GitHub Issues.
- `kensin` is the source of truth for workflow state, selected exams, order intent, and audit history.
- AHK and the EMR are execution targets.
- Do not change medical decision logic, fee logic, or EMR/AHK execution flow without explicit review.
- Preserve manual operation paths even when adding automation.
- Do not overwrite terminal-specific `config.ini` or production `settings.json`.
- Issue numbers are assigned by GitHub. Backlog list numbers are not Issue numbers.
- After posting, GitHub Actions will add AI Task Queue labels and one triage comment.
- If a task touches medical safety, fee/order logic, EMR/AHK execution, production deployment, or destructive data changes, mark Human decision required.

## AI Roles

- Claude: architecture, workflow design, medical safety review
- Codex: implementation, tests, refactoring, repo maintenance
- Gemini: data structure, CSV/DB workflow, requirement-gap detection, mobile drafting

## Mobile Issue Drafting Goal

When away from the development PC, the mobile AI should help turn rough ideas into a GitHub Issue title and Markdown body. The human posts the Issue from GitHub mobile/web after checking safety.

## GitHub Comment Instruction Workflow

Use GitHub comments as the small instruction queue when the development PC is available at home but the Human CTO is operating from a phone or another lightweight device.

The phone does not run Codex directly. It records a clear instruction on the Issue or PR. The PC-side Codex/Claude session later reads that GitHub thread and acts within the written permission.

### Comment Templates

**Codex implementation request**

```text
Codex request:

Target: #<Issue or PR number>
Goal:

Allowed:
- Inspect GitHub Issue/PR comments and labels.
- Edit files within the stated scope.
- Run local verification.
- Commit, push, and open a PR.

Prohibited:
- Do not merge.
- Do not apply production settings or destructive changes.
- Do not include patient data, identifiers, production logs, screenshots with identifiers, terminal secrets, or credentials.

Completion:
- Leave an Issue/PR comment with changed files, commit, verification, and remaining cautions.
```

**Claude review request**

```text
Claude review request:

Target: <PR or Issue URL>
Review focus:
- Architecture and safety risks
- Scope drift
- Missing tests or verification
- Whether Human CTO decision is needed

Expected output:
- Approve only if safe to proceed.
- Otherwise list requested changes or open questions.
```

**Dry-run only request**

```text
Dry-run only:

Target: #<Issue number>
Allowed:
- Inspect current repo/GitHub state.
- Run read-only checks and dry-run commands.
- Post findings.

Prohibited:
- Do not write files.
- Do not push.
- Do not apply labels/settings/production operations.
- Do not merge.
```

**Human merge handoff**

```text
Human merge handoff:

PR: #<PR number>
State: review complete / checks passing / ready for Human CTO merge decision
Label: handoff:human-merge

AI agents must not merge this PR.
```

### Queue Labels To Check

Use these label combinations as the mobile dashboard:

| Need | Labels |
|---|---|
| Codex should start implementation | `ai:codex` + `status:ready` |
| Claude should review | `review:claude` + `status:review` |
| Human CTO should merge | `handoff:human-merge` |
| Human decision or dependency blocks progress | `status:blocked` |
| Council decision has been made | `council:decision` |

`status:blocked`, `ai:human-review`, and `review:human` are not merge-wait labels. Use `handoff:human-merge` when the remaining action is only the Human CTO merge operation.

## Sharing This Context On Mobile

Preferred options:

1. Open this file in GitHub mobile/web and copy the text into AI chat.
2. Save a copy in Google Drive and attach it to the Gem as knowledge.
3. Keep the Gem instructions short and tell it to use the attached context pack.

Do not assume that pasting a private GitHub URL lets a mobile AI read the page. The AI may not share the browser's GitHub login session. If the repository is private, pass the actual text or an attached file.

If using a Google Drive copy, refresh it after important HealthCheck-OS rule changes.

## Issue Format

When posting from a Gem or mobile AI that already formatted the body, choose the `Simple AI draft` Issue template and paste the generated Markdown directly. Use the structured templates only when drafting manually inside GitHub.

```text
Title:

Queue:
- Status: triage
- Repo:
- AI owner:
- Safety level:
- Human decision:
- Next action:
- Verification:
- Blocked by:

Goal:

Context:

Scope:

Out of scope:

Acceptance criteria:
- [ ]

Safety / operational cautions:

Verification:

Suggested owner / AI role:
```

## Mobile Prompt

```text
Use the HealthCheck-OS context below and format my rough note as a GitHub Issue.

Target repo:
Rough note:
Urgency:
Known constraints:

Rules:
- Do not include patient identifiers, production logs, screenshots with identifiers, terminal secrets, credentials, or uncertain claims.
- Keep the scope narrow.
- Include a Queue section with Status, Repo, AI owner, Safety level, Human decision, Next action, Verification, and Blocked by.
- Choose AI owner from Human CTO, Claude, Codex, Gemini, or unassigned.
- Choose Safety level from ordinary, deployment, patient-data-risk, medical-logic, or EMR-AHK.
- Use Human decision: required for medical safety, fee/order logic, EMR/AHK execution, production deployment, destructive data changes, or uncertain safety.
- If the note suggests adjacent work, put it under "Out of scope" or "Follow-up candidate".
- Output only a GitHub Issue title and Markdown body.
```
