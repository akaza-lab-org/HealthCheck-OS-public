# HCOS Boot Procedure

HCOS BOOT is the required entry point for agent sessions in this repository.

## Scope

- BOOT defines how an agent initializes role and state before work.
- BOOT does not replace GitHub Issues/PRs as the source of truth.
- BOOT does not grant merge authority to AI agents.

## Boot Commands

Supported commands:

- `HCOS BOOT BUILDER`
- `HCOS BOOT REVIEWER`
- `HCOS BOOT ARCHITECT`
- `HCOS BOOT DIRECTOR`
- `HCOS BOOT GEMINI`
- `HCOS BOOT ANTIGRAVITY`
- `HCOS BOOT ESCALATION`

## Shorthand Commands

Format: `HCOS><ALIAS>#<Issue>`

| Alias | Full Role | Initial STATE |
| --- | --- | --- |
| `B` | `BUILDER` | `IMPLEMENTING` |
| `R` | `REVIEWER` | `REVIEWING` |
| `A` | `ARCHITECT` | `PLANNING` |
| `G` | `GEMINI` | `PLANNING` |
| `E` | `ESCALATION` | `PLANNING` |
| `I` | `NONE` (session close / idle) | `IDLE` |

AI must expand shorthand to Full Declaration before acting:

```text
HCOS STATE: <STATE>
ROLE: <ROLE>
TARGET: #<issue-number>
```

Then run:

`python scripts/hcos_boot_context.py <ROLE> --issue <number>`

Role mapping:

- `BUILDER`: Codex / Antigravity implementation role
- `REVIEWER`: Claude review role
- `ARCHITECT`: Claude design and safety architecture role
- `DIRECTOR`: Human CTO authority role
- `GEMINI`: Data and workflow analysis role
- `ANTIGRAVITY`: Builder-class implementation support role
- `ESCALATION`: High-capability model session activated by Human operator. Authority is bounded by assigned task scope; role constraints still apply. ESCALATION does not grant merge authority or `council:decision` authority.

## Required Files to Load

At boot start, the agent must load:

1. `AGENTS.md`
2. `hcos/RULES.md`
3. `hcos/STATE.md`
4. `docs/core/AUTHORITY.md`
5. `docs/core/ai_cto_rules.md`
6. `docs/safety/agent_operational_safety_rule.md`
7. Target Issue/PR in GitHub
8. `hcos/roles/<your-role>.md` (load the role file matching your BOOT role)

## Boot Sequence

1. Read role command and lock to one role.
2. Load required files.
3. Read target Issue/PR labels and comments.
4. Resolve initial state using `hcos/STATE.md`.
5. Declare state header before action.

State declaration format:

```text
HCOS STATE: <STATE>
ROLE: <BUILDER | REVIEWER | ARCHITECT | DIRECTOR | GEMINI | ANTIGRAVITY | ESCALATION>
TARGET: #<issue-or-pr-number>
```

## Safety Boundaries

- If target is blocked (`status:blocked` or Human decision required), do not implement.
- If medical, fee/order, EMR/AHK execution, or destructive deployment decisions are involved, stop and escalate to Human CTO.
- AI agents must not merge PRs or transition Council issues to `council:decision`.
