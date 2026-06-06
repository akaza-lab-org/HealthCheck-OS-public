# Docs Lightweight Audit 2026-05-31

Issue: #148
Parent: #90

## Scope

This is a lightweight audit before any `docs/` directory reorganization. No files were moved or renamed.

## Inventory

Current `docs/` inventory: 62 files.

| Group | Count | Notes |
|---|---:|---|
| `docs/core/` | 4 | Core rules and state model |
| `docs/safety/` | 3 | Safety rules |
| `docs/adr/` | 6 | ADRs plus template |
| root `pattern_*.md` | 8 | Reusable patterns still live at docs root |
| root `gcp_*.md` | 3 | GCP setup guides |
| root `kensin_*.md` | 4 | Kensin/AHK integration and exam policy |
| root `sub_pc_*.md` | 3 | Sub-PC / release workstation docs |
| `docs/proposed_issues/` | 2 | Draft issue material |
| other root docs | 29 | Operations, mobile context, GitHub, workspace, prompts, backlog |

## Entry Points

### Keep As Read First / Quick Reference

These are appropriate as short entry points and should remain easy to find:

- `AGENTS.md`
- `hcos/BOOT.md`
- `docs/KNOWLEDGE_INDEX.md`
- `docs/human_cto_commands.md`
- `docs/mobile_ai_context.md`
- `docs/issue_comment_templates.md`
- `docs/label_taxonomy.md`
- `docs/local_environment_bootstrap.md`
- `docs/terminal_setup_complete_procedure.md`
- `docs/repo_catalog.md`
- `docs/project_reentry_checklist.md`

### Keep In Knowledge Index

`docs/KNOWLEDGE_INDEX.md` already covers core/safety/ADR and many patterns. It should also include these operational docs because they are now durable workflow knowledge:

- `docs/human_cto_commands.md`
- `docs/mobile_ai_context.md`
- `docs/issue_comment_templates.md`
- `docs/ai_task_queue.md`
- `docs/agent_plan_handoff.md`
- `docs/development_pc_agent_prompts.md`
- `docs/github_issue_access.md`
- `docs/github_templates.md`
- `docs/git_push_policy.md`

## Alignment Findings

1. `AGENTS.md` quick reference is useful and should not be replaced by a long flat Read First list.
2. `AGENTS.md` and `README.md` still show several Tier B repositories as `未オンボーディング` or `オンボーディング中`, while `docs/repo_catalog.md` and `docs/pattern_hcos_repo_onboarding.md` record completed onboarding for `ikensho_git`, `keikakusho`, `DM-kousin`, `wakumy_apilot`, `skills`, and label sync work.
3. `docs/KNOWLEDGE_INDEX.md` is currently strongest for core/safety/ADR/patterns, but under-represents operational command docs added during the mobile/GitHub workflow work.
4. Some internal references still point at older paths or names:
   - `docs/safety/phi_external_output_safety_rule.md` references `docs/project_rule.md` and `docs/ai_cto_rules.md`, but the current files live under `docs/core/`.
   - `docs/terminal_setup_complete_procedure.md` references `docs/git_agent_troubleshooting.md`; the actual file is `docs/agent_git_troubleshooting.md`.
   - `docs/local_environment_bootstrap.md` references `docs/manuals/setup.md`; in context this appears to mean the kensin repository manual rather than an HCOS-local file.
5. Root-level guides are mixed by domain. This is manageable now because `AGENTS.md` provides purpose-based routing, but #90 should avoid a large one-shot move.

## Duplicate / Outdated Candidates

| Candidate | Proposed action |
|---|---|
| `README.md` Tier B status table | Update to match `docs/repo_catalog.md` |
| `AGENTS.md` Tier B status table | Update to match `docs/repo_catalog.md` |
| Old `docs/project_rule.md` / `docs/ai_cto_rules.md` references | Replace with `docs/core/project_rule.md` / `docs/core/ai_cto_rules.md` |
| `docs/git_agent_troubleshooting.md` reference | Replace with `docs/agent_git_troubleshooting.md` |
| `docs/proposed_issues/*` | Keep for now; review separately before pruning |

## Future Move Candidates

Do not move these in #148. If #90 proceeds, move in small groups and update links/workflow regexes in the same PR.

| Candidate group | Possible future location |
|---|---|
| `docs/pattern_*.md` | `docs/patterns/` |
| `docs/gcp_*.md` | `docs/guides/gcp/` |
| `docs/sub_pc_*.md` | `docs/guides/hardware/` or `docs/guides/sub_pc/` |
| `docs/kensin_*.md` | `docs/guides/kensin/` |
| GitHub / PR / Issue operation docs | `docs/guides/ops/` |

## Recommended Next Steps

1. Open a small follow-up to update `README.md` and `AGENTS.md` Tier B statuses from `docs/repo_catalog.md`.
2. Open a small follow-up to fix stale internal links listed above.
3. Update `docs/KNOWLEDGE_INDEX.md` to include the durable operational docs added during mobile/GitHub workflow work.
4. Defer physical directory moves until after the above cleanup. When moving, do one category per PR.

## Conclusion

The current docs tree is usable because `AGENTS.md` now provides task-based routing. The main risk is not directory shape yet; it is stale entry-point metadata and missing Knowledge Index links. Fix those first, then revisit #90 with smaller move batches.
