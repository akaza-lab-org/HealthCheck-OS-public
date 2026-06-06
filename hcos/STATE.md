# HCOS State Machine (Source of Truth)

This file is the machine-readable source of truth for HCOS execution states.

Human-readable explanation lives in `docs/core/hcos_state_machine.md`.

## States

| STATE | Meaning | Allowed Actions | GitHub Signal |
| --- | --- | --- | --- |
| `IDLE` | No active target or waiting | wait, acknowledge, handoff preparation | no active issue/pr |
| `PLANNING` | Analyze and design only | analysis, design notes, scoping, risk check | `status:triage`, `council:open` |
| `IMPLEMENTING` | Approved implementation in progress | code/docs changes, tests, branch/commit/push/PR | `status:ready` and feature branch context |
| `REVIEWING` | Review mode | architecture/safety review, review comments, verification notes | PR review state, `council:review` |
| `BLOCKED` | Awaiting human decision or external prerequisite | clarify blockers, draft decision requests, no implementation | `status:blocked`, `ai:human-review` |
| `MERGING` | Final merge authority state | merge execution only | Human CTO action only |

## Critical Constraints

- AI agents must never enter executable `MERGING` behavior.
- `MERGING` is reserved for Human CTO only.
- If labels or comments indicate stop conditions, transition to `BLOCKED`.
- If role/state mismatch is detected, stop and escalate in the issue.

## Transition Rules

- `IDLE -> PLANNING`: target Issue/PR is assigned or selected.
- `PLANNING -> IMPLEMENTING`: scope approved and not blocked.
- `PLANNING -> BLOCKED`: Human decision required or stop condition detected.
- `IMPLEMENTING -> REVIEWING`: PR opened or review requested.
- `IMPLEMENTING -> BLOCKED`: safety stop condition or authority conflict.
- `REVIEWING -> BLOCKED`: unresolved safety/authority issue.
- `REVIEWING -> IDLE`: review/handoff complete.
- `BLOCKED -> PLANNING`: Human CTO decision unblocks work.
- `MERGING`: not available to AI transitions.
