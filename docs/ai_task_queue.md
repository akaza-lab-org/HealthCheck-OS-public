# AI Task Queue

## Purpose

Use GitHub Issues and Projects as the visible task queue for the Human CTO and AI team.

The queue answers:

- what is waiting
- who should act next
- which tasks are blocked
- which changes need human decision
- what verification is required before close

Do not create a separate task system unless GitHub becomes insufficient. GitHub is the execution source of truth.

## Flow

```text
Notion / mobile AI / meeting note
  -> triage into GitHub Issue
  -> queue fields or labels show owner and state
  -> assigned AI or human acts
  -> PR / commit / verification
  -> Issue comment records result
  -> reusable lessons move to HealthCheck-OS docs
```

## Queue Fields

If using GitHub Projects, start with these fields:

| Field | Values |
| --- | --- |
| Status | Inbox / Needs triage / Ready / In progress / Blocked / Review / Done |
| Repo | HealthCheck-OS / clinic-app / AHK_setting |
| AI owner | Human CTO / Claude / Codex / Gemini / unassigned |
| Safety level | ordinary / deployment / patient-data-risk / medical-logic / EMR-AHK |
| Human decision | none / required / decided |
| Next action | short plain-language next step |
| Verification | docs check / pytest / AHK Validate / build ZIP / manual review |
| Blocked by | Issue, PR, person, or external condition |

If not using GitHub Projects yet, put these fields at the top of the Issue body.

## Minimal Labels

Use labels when Projects are not available:

```text
repo:kensin
repo:ahk
repo:hcos

ai:codex
ai:claude
ai:gemini
ai:human-review

status:triage
status:ready
status:in-progress
status:blocked
status:review
status:done

handoff:human-merge

safety:ordinary
safety:deployment
safety:patient-data
safety:medical-logic
safety:emr-ahk
```

Labels are advisory. The Issue body and comments remain the detailed record.

Current status:

```text
2026-05-04: Minimal queue labels synced to:
- akaza-lab-org/HealthCheck-OS
- akaza-lab-org/clinic-app
- akaza-lab-org/AHK_setting
2026-05-30: Label presence rechecked with `gh label list` for the same three repositories.
```

## Triage Rules

1. Confirm the real GitHub Issue number and title.
2. Select the target repo closest to the first implementation change.
3. Assign one next owner, not every possible participant.
4. Mark `Human decision: required` when Stop Conditions apply.
5. Keep scope narrow and move adjacent work to follow-up candidates.
6. Do not start implementation until the Issue is `Ready` or clearly approved.

## Automated Triage

Each active repository has a GitHub Actions workflow at:

```text
.github/workflows/issue_triage.yml
```

The workflow runs when an Issue is opened, edited, or reopened. It:

- adds `repo:*`, `ai:*`, `status:*`, and `safety:*` labels from the Issue title/body
- detects AI CTO Stop Conditions with conservative keyword checks
- posts one `AI Task Queue triage` comment with the suggested owner, safety level, status, and next action
- marks likely Stop Condition Issues as `ai:human-review` and `status:blocked`
- does not use `status:blocked`, `ai:human-review`, or `review:human` for ordinary merge wait; use `handoff:human-merge` when review is complete and only Human CTO merge remains

The workflow does not implement code, merge PRs, change production settings, or approve deployment. It is only an automatic sorting and reminder layer.

Issue triage is repository-local. A repository participates in automated triage only when `.github/workflows/issue_triage.yml` exists and is active in that repository. As of 2026-05-30, `HealthCheck-OS`, `clinic-app`, and `AHK_setting` each have an active `Issue triage` workflow.

Do not confuse Issue triage with PR enforcement. `HCOS PR Policy`, Council workflows, Knowledge workflows, and Decision Memory workflows are active in HealthCheck-OS, but they do not automatically protect application repositories. For onboarding or auditing another repository, follow `docs/patterns/pattern_hcos_repo_onboarding.md`.

Smoke test:

```text
2026-05-04: HealthCheck-OS#1 verified that automated triage labels and the triage comment are applied, then updated correctly after Issue edits. The temporary test Issue was closed.
```

## AI Owner Defaults

| Work type | Default owner |
| --- | --- |
| Code, tests, refactoring, release scripts | Codex |
| Architecture, workflow design, medical safety review | Claude |
| CSV/DB shape, imports/exports, workflow gap analysis | Gemini |
| Medical, fee, order, deployment approval | Human CTO |

Cross-repo work should start with a HealthCheck-OS coordination Issue, then split into repo-specific Issues when the first code change is clear.

## Issue Header Template

```text
Queue:
- Status:
- Repo:
- AI owner:
- Safety level:
- Human decision:
- Next action:
- Verification:
- Blocked by:
```

## Completion Record

Every completed task should end with an Issue or PR comment:

```text
Result:
Changed repo:
Changed files:
Commit:
Push:
Tests / verification:
Not done / out of scope:
Operational caution:
Docs promoted:
```

Reusable comment templates live in `docs/issue_comment_templates.md`.

## Human CTO Review Points

Human CTO review is required before:

- merging medical workflow changes
- changing fee or order logic
- changing EMR/AHK execution behavior
- deploying to production or sub-PC release flow
- accepting destructive database migrations
- closing a task with unresolved safety questions
