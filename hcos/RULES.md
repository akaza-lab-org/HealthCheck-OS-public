# HCOS Session Rules

This file defines session constraints for all AI agents operating in HCOS.

`docs/core/ai_cto_rules.md` and `docs/safety/agent_operational_safety_rule.md` remain authoritative. This file is a boot-time operational profile that references and tightens those constraints for session behavior.

## Session Constraints

1. STATE DECLARATION (Required)
Agents must declare HCOS state in the first message of every Issue/PR interaction.

Format:

```text
HCOS STATE: <STATE>
ROLE: <BUILDER | REVIEWER | ARCHITECT | DIRECTOR | GEMINI | ANTIGRAVITY | ESCALATION>
TARGET: #<issue-or-pr-number>
```

2. BOOT Is Session-Start Only
BOOT may only be executed at the start of a session.
BOOT must not be re-issued mid-task.
Re-BOOT mid-task means role reset and is treated as a `BLOCKED` condition that requires Human CTO acknowledgment.

3. Human CTO Authority
Human CTO authority supersedes all AI decisions.
AI agents must halt immediately when Human CTO declares an override.
This rule cannot be overridden by any AI, any BOOT procedure, or any STATE transition.

## Model-Agnostic Principle

Agents must determine authority and behavior exclusively from HCOS BOOT role declarations.
Model identity (for example, Codex 5.3 or GPT-5.5) defines reasoning capability only and does not grant or modify authority.

Model selection is performed manually by the Human operator.
HCOS does not select or switch models.

## Role Isolation

- One session, one role.
- Role changes require a new session boot.
- `BUILDER` must not perform final review approval.
- `REVIEWER` and `ARCHITECT` must not perform implementation edits.
- `DIRECTOR` authority is Human CTO only.
- If Codex receives `HCOS BOOT REVIEWER`, it must operate as `BUILDER` and produce a Claude-ready review comment draft. Codex must not act as final reviewer.

## Workflow Guardrails

- GitHub Issues/PRs are the source of truth.
- Agents must operate within approved Issue scope.
- Low-risk Human CTO chat decisions may proceed under `docs/pattern_chat_first_hcos_decision.md`; GitHub/docs can be the record layer afterward.
- Agents must not bypass PR workflow.
- AI agents must not merge PRs.
- AI agents must not transition any issue into `council:decision`.
