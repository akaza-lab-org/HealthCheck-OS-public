# Pattern: Chat-first HCOS Decision

## Problem

HCOS keeps Issues, PRs, and docs as shared organizational memory.
However, requiring a GitHub Issue or label transition before every small decision creates excess operation cost when the Human CTO has already decided a low-risk matter in chat.

This friction can block documentation updates, backlog cleanup, wording changes, and small coordination decisions even when no medical safety or production risk is involved.

## Solution

Use chat as the decision surface for low-risk operational decisions, and use GitHub/docs as the record layer afterward.

GitHub remains mandatory before action only for high-risk gates.
For low-risk coordination and documentation decisions, a clear Human CTO instruction in chat is sufficient to proceed.

## Decision Tiers

| Tier | Meaning | Action |
|---|---|---|
| Chat Decision | Low-risk decision made by Human CTO in chat | Proceed, then record durable knowledge if needed |
| GitHub Record | Decision can be made in chat but should be preserved | Proceed, then add an Issue/PR comment or docs entry |
| Formal Gate | Decision requires explicit GitHub/Council/PR workflow | Stop until the required gate is satisfied |

## Chat Decision Scope

Agents may proceed from a Human CTO chat decision when the work is limited to:

- documentation wording or organization,
- adding or updating HCOS patterns, handoff notes, or operational guidance,
- backlog triage suggestions,
- non-destructive Issue audit or close-comment drafts,
- task ordering and implementation sequencing,
- clarifying an existing rule without changing its safety meaning,
- deciding whether reusable knowledge belongs in docs or a skill.

If the decision produces durable knowledge, Codex should promote it into `docs/`, an Issue comment, or a PR body during the same work session when practical.

## GitHub Record Scope

Use GitHub or docs as a record layer when the chat decision affects future agents but does not require approval blocking:

- repeated HCOS operating procedures,
- Issue triage standards,
- PR body or review templates,
- agent handoff conventions,
- knowledge promotion criteria,
- low-risk documentation structure changes.

The record may be created after the chat decision.
The absence of a pre-existing Issue must not block the work when Human CTO has clearly authorized it in chat and the work remains low risk.

## Formal Gate Scope

Agents must stop and use the existing GitHub/Council/PR gate before acting when work touches:

- medical safety,
- fee or order logic,
- EMR/AHK execution flow,
- destructive data changes,
- production deployment approval,
- patient data, PHI, logs, or terminal secrets,
- `council:decision` lifecycle transitions,
- PR merge authority,
- broad implementation scope not already covered by an Issue.

In these cases, chat may clarify intent, but it does not replace the required gate.

## Agent Behavior

When proceeding from a chat decision, agents should:

1. State that the decision is treated as a Chat Decision or GitHub Record.
2. Confirm that no Formal Gate topic is involved.
3. Make the smallest useful documentation or coordination change.
4. Record the chat-derived decision in durable form if it will affect future agents.
5. Mention in the final handoff that the work was based on Human CTO chat authorization.

## Safety Boundary

This pattern reduces coordination overhead only.
It does not weaken Human CTO authority, PR review requirements, Council lifecycle authority, PHI rules, or merge restrictions.

If a low-risk documentation change uncovers a high-risk implementation decision, stop and escalate through the normal gate.

## Related

- `hcos/RULES.md`
- `docs/pattern_hcos_pr_workflow.md`
- `docs/pattern_hcos_issue_audit.md`
- `docs/safety/agent_operational_safety_rule.md`
