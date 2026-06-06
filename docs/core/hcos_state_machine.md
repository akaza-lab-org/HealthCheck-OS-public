# HCOS State Machine

## Purpose

This document explains the HCOS state model used by agents during Issue and PR work.

`hcos/STATE.md` is the machine-readable source of truth.
This file is the human-readable explanation.

## Design Principle

HCOS state controls what an agent is allowed to do at each step.
State is not private memory. State must align with GitHub observable signals.

## States and Intent

| STATE | Intent | Typical GitHub Signals |
| --- | --- | --- |
| `IDLE` | Wait or no target selected | no active issue/pr |
| `PLANNING` | Analyze/design only | `status:triage`, `council:open` |
| `IMPLEMENTING` | Build within approved scope | `status:ready` with feature-branch execution |
| `REVIEWING` | Review only | PR review status, `council:review` |
| `BLOCKED` | Pause for decision | `status:blocked`, `ai:human-review` |
| `MERGING` | Merge action | Human CTO only |

## Mandatory Declaration

Agents must declare state at first interaction in each Issue/PR thread:

```text
HCOS STATE: <STATE>
ROLE: <BUILDER | REVIEWER | ARCHITECT | DIRECTOR>
TARGET: #<issue-or-pr-number>
```

This prevents role drift and state mismatch.

## Role and Authority Alignment

- `BUILDER` (Codex/Antigravity): implementation only
- `REVIEWER` (Claude): review only
- `ARCHITECT` (Claude): design/safety structure only
- `DIRECTOR` (Human CTO): final authority, including merge authority

Human CTO authority supersedes all AI decisions.

## Merge Guard

`MERGING` is represented in the state model to keep lifecycle completeness, but AI agents do not execute merge operations.
AI agents can only report merge readiness.

## Relationship to Existing Rules

This document does not replace:

- `docs/core/ai_cto_rules.md`
- `docs/safety/agent_operational_safety_rule.md`
- `docs/patterns/pattern_hcos_pr_workflow.md`

It provides an explicit state layer compatible with those rules.
