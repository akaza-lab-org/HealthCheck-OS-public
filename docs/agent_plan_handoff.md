# Agent Plan Handoff

## Purpose

Keep Codex, Claude, Gemini, and human operators aligned when an AI drafts an implementation plan.

Private AI workspace folders are scratch space. They are useful while an agent is thinking, but they are not a team-visible source of truth.

## Shared Plan Locations

Use these durable locations instead:

| Plan type | Location |
| --- | --- |
| Implementation task | GitHub Issue in the affected repository |
| Cross-repository coordination | HealthCheck-OS Issue or `docs/` |
| Architecture or policy decision | `docs/` or ADR-style document |
| Completed verification result | Issue comment, PR description, or handoff note |

Use HealthCheck-OS `docs/` for durable rules, cross-agent contracts, release procedures, and lessons that should apply beyond one task.

Do not create one-off files such as `implementation_plan_<repo>_issue_<n>.md` or `walkthrough_<repo>_issue_<n>.md` in HealthCheck-OS for ordinary single-repository Issues. Put those details in the GitHub Issue or PR so the task history stays with the work.

Do not leave the only copy of a plan under paths such as:

```text
C:\Users\<user>\.gemini\
C:\Users\<user>\.claude\
C:\Users\<user>\.codex\
```

If an agent creates a useful plan there, copy the relevant summary into GitHub or HealthCheck-OS before treating it as accepted.

## Issue Scope Rule

An agent may inspect nearby files while working, but the implementation scope stays tied to the Issue acceptance criteria.

If investigation reveals additional work:

1. Complete the current Issue as written when safe.
2. Record the additional finding in the Issue or handoff note.
3. Create or propose a separate follow-up Issue for broader cleanup or refactoring.

Do not silently expand a narrow cleanup Issue into a broad repository hygiene change.

## Cleanup Issue Example

For `clinic-app` Issue #1, the intended scope is:

```text
Remove the tracked `$path.bak-20260418` backup file after confirming it is unused.
```

Other tracked files such as generated PDFs, debug logs, screenshots, Excel samples, or manuals may be worth reviewing, but they should be handled by a separate Issue because some may be operational samples or documentation assets.

Avoid broad ignore rules such as:

```text
/*.pdf
/*.xlsx
/*.jpg
```

These can hide legitimate root-level sample documents or release artifacts. Prefer specific patterns after confirming how the repository uses those files.

## Handoff Checklist

When an AI plan is promoted from scratch space, record:

```text
Issue:
Scope:
Out-of-scope findings:
Shared plan location:
Required verification:
Owner / next agent role:
```
