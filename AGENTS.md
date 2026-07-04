# Agent Entry Point

This repository coordinates medical checkup automation work across agents.

## Read First

### Boot（必読 — 常に最初に読む）

`hcos/BOOT.md` に起動手順と必読8ファイルが定義されています。Boot前に読むファイルはそちらを参照してください。

`agmsg` を使う場合は `docs/agents/agmsg_protocol.md` も参照してください。agmsg は optional local transport であり、GitHub Issue/PR や Human CTO decision の source of truth ではありません。

```
hcos/BOOT.md → hcos/RULES.md → hcos/STATE.md
→ docs/core/AUTHORITY.md
→ docs/core/ai_cto_rules.md
→ docs/safety/agent_operational_safety_rule.md
→ Target Issue/PR
→ hcos/roles/<your-role>.md
```

**⚠️ git コマンドが失敗する場合** → `docs/agent_git_troubleshooting.md` を先に実行する

知識全体の索引は `docs/KNOWLEDGE_INDEX.md`（Tier 1〜4）を参照してください。

---

### 目的別クイックリファレンス（必要なときだけ読む）

| 作業内容 | 読むファイル |
|---|---|
| **今週の優先度・経営方針** | `docs/core/NEXT_ACTION.md` |
| **新規端末セットアップ** | `docs/terminal_setup_complete_procedure.md` → `docs/local_environment_bootstrap.md` → `docs/git_agent_setup_guide.md` |
| **PHI外部送信・AI画像送信** | `docs/safety/phi_external_output_safety_rule.md` |
| **サブPC・クリニックデプロイ** | `docs/guides/hardware/sub_pc_usb_release_workstation.md` → `docs/guides/hardware/sub_pc_tasks_only.md` → `docs/guides/hardware/sub_pc_sync_tools.md` |
| **GCP / Vertex AI 設定** | `docs/guides/gcp/gcp_vertex_wif_admin_guide.md` → `docs/guides/gcp/gcp_corporate_admin_setup_guide.md` → `docs/guides/gcp/gcp_per_app_sa_setup_guide.md` → `docs/patterns/pattern_gcp_portable_key.md` |
| **HCOS Issue / PR 運用** | `docs/git_push_policy.md` → `docs/github_templates.md` → `docs/github_issue_access.md` → `docs/patterns/pattern_hcos_pr_workflow.md` → `docs/ai_agent_merge_guardrails.md` → `docs/label_taxonomy.md` → `docs/issue_comment_templates.md` |
| **リポジトリ管理・オンボーディング** | `docs/repo_catalog.md` → `docs/local_workspace_standard.md` → `docs/local_workspace_roles.md` → `docs/project_reentry_checklist.md` → `docs/patterns/pattern_hcos_repo_onboarding.md` → `docs/patterns/pattern_hcos_issue_audit.md` → `docs/patterns/pattern_chat_first_hcos_decision.md` |
| **モバイル / 外部AIセッション** | `docs/claude_project_context.md` → `docs/mobile_ai_context.md` → `docs/gem_hcos_issue_creator.md` |
| **タスク・ハンドオフ管理** | `docs/agent_plan_handoff.md` → `docs/ai_task_queue.md` → `docs/notion_ai_triage.md` → `docs/development_pc_agent_prompts.md` |
| **Antigravity セッション** | `docs/antigravity_start_guide.md` → `docs/ai_agent_merge_guardrails.md` |
| **pdf_digitizer スコープ** | `docs/adr/adr_001_pdf_digitizer_scope.md` |

## Active Project

管理対象リポジトリの全体像は `README.md` の「管理対象リポジトリ」セクションと `docs/repo_catalog.md` を参照してください。

管理対象リポジトリの詳細は `docs/repo_catalog.md` を参照してください。

## Agent Rules

- Do not change medical decision logic without an explicit issue and review.
- Stop and request Human CTO decision when work touches medical safety, fee/order logic, EMR/AHK execution flow, destructive data changes, or production deployment approval.
- Do not overwrite terminal-specific `config.ini` values.
- Preserve manual operation paths even when adding app-triggered automation.
- Keep implementation tasks in GitHub Issues and record important lessons in docs or ADRs.
- Do not treat private AI workspace files as shared plans; move durable plans into GitHub Issues, PRs, or this repository's docs.
- Keep Issue scope narrow. If investigation finds adjacent cleanup or refactoring work, create or propose a follow-up Issue instead of expanding the current Issue silently.
- Never commit real patient data, logs containing identifiers, or production terminal secrets.
- Commit and push completed, verified work at appropriate checkpoints unless the user asks to hold locally.
- Before pushing, review `git status` and do not include unrelated user/local changes.
- Detect `HCOS><ALIAS>#<Issue>` shorthand in the first message and expand to Full Declaration before acting. See `hcos/BOOT.md` for alias mapping.
- HCOS AI Council lifecycle authority:
  - `council:open` -> `council:review`: Bot or Human CTO
  - `council:review` -> `council:decision`: Human CTO only
  - `council:decision` -> `council:archived`: Bot (administrative only)
- AI agents MUST NOT transition any Issue into `council:decision`.

## PR Workflow (HCOS)

All PRs automatically request Claude Architecture & Safety Review.

AI agents MUST:
1. Read Issue first
2. Implement only within scope
3. Wait for review before merge

**[ABSOLUTE CONSTRAINT] AI agents MUST NOT merge PRs. Merge authority belongs ONLY to Human CTO.**

PRs are the execution unit. Issues are intent. Docs are organizational memory.

Codex MUST NOT commit directly to `main`. For implementation work, Codex must create `feature/<issue-number>-short-name`, push it, and open a PR titled `[HCOS] <Issue Title>` with the standard PR template filled.

Knowledge promotion (Codex responsibility):
- Codex evaluates promotion candidates **during implementation** (not after review)
- If promotion is warranted, Codex adds the doc to `docs/` in the same PR **before requesting review**:
  - Pattern: `docs/patterns/pattern_<name>.md` (under `docs/patterns/`)
  - ADR: `docs/adr_<number>_<name>.md`
  - Safety Rule: `docs/safety_<name>.md`
- After adding doc, Codex updates `AGENTS.md` Read First list in the same PR
- If the new doc changes repo structure or active projects, check whether `README.md` also needs updating
- If unsure, Codex describes the candidate in PR body; Claude decides during review

Merge policy:
- Claude approved
- Tests passing
- Safety checks complete
- Squash and merge only (**Human CTO action only**)

HCOS rule: Code disappears. Knowledge accumulates. PRs are temporary. Docs are permanent.

## Recommended Handoff

Every completed task should leave:

- Issue link or task ID
- Changed repositories and files
- Test or manual verification result
- Commit hash and push status
- Any new operational caution
- Any knowledge that should be promoted to docs
