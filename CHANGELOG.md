# Changelog

## 2026-07-04

- Feature: docs: add agmsg protocol closes #1.
## 2026-06-05

- Feature: docs(safety): Rule 3-E に result_code_strip 例外型を追加 (kensin #438).
- Safety Rule added: docs/safety/phi_external_output_safety_rule.md.
## 2026-06-05

- Feature: docs(safety): AI活用システム セキュリティ規約 例外条項を追加 closes #161.
- Safety Rule added: docs/safety/ai_security_regulation_exception.md.
## 2026-06-05

- Feature: [HCOS] Add advisory execution attribution field to PR template closes #162.
## 2026-06-02

- Feature: docs(safety): PHIルール Rule 3-E 追加案（#381 裁定後マージ）.
- Safety Rule added: docs/safety/phi_external_output_safety_rule.md.
## 2026-05-31

- Feature: docs: Claude 起草 docs PR の gate デッドロック解消ルールを明文化（#158 選択肢 A） closes #158.
## 2026-06-01

- Docs: [HCOS] Claude 起草 docs PR の gate デッドロック解消ルールを claude_project_context.md に追記（選択肢 A: Human CTO override 運用の明文化）closes #158.
- Docs: [HCOS] docs/core/NEXT_ACTION.md を新設（AI 起動時の経営方針ダッシュボード・2026-06-01 版）closes #156.

## 2026-05-31

- Feature: docs: AUTHORITY.md を新設し権限マトリクスを1ページに集約.
## 2026-05-31

- Docs: [HCOS] AUTHORITY.md に Operational Principle 節を追加（Authority ≠ Workflow の分離を明文化）(#155).
- Docs: [HCOS] AUTHORITY.md に Decision Boundary / Override Rule / Conflict Resolution / Authority Delegation Prohibition の4節を追加 (#155).
- Docs: [HCOS] docs/core/AUTHORITY.md を新設し権限マトリクスを1ページに集約。BOOT.md の必読ファイルを7→8に更新、AGENTS.md のフロー図に AUTHORITY.md を追加 (#155).
- Feature: [HCOS] docs/sub_pc_*.md を docs/guides/hardware/ へ移動 (#90 Part 4 / 最終) closes #90.
## 2026-05-31

- Refactor: [HCOS] docs/sub_pc_*.md を docs/guides/hardware/ へ移動 (#90 Part 4). AGENTS.md・内部クロスリンクを更新。
- Feature: [HCOS] docs/kensin_*.md を docs/guides/kensin/ へ移動 (#90 Part 3).
- Refactor: [HCOS] docs/kensin_*.md を docs/guides/kensin/ へ移動 (#90 Part 3). AGENTS.md・kensin内部クロスリンクを更新。
- Feature: [HCOS] docs/gcp_*.md を docs/guides/gcp/ へ移動 (#90 Part 2).
- Refactor: [HCOS] docs/gcp_*.md を docs/guides/gcp/ へ移動 (#90 Part 2). AGENTS.md 参照を更新。
- Feature: [HCOS] docs/pattern_*.md を docs/patterns/ へ移動 (#90 Part 1).
- ADR added: docs/adr/adr_003_agent_identity_signature_principles.md.
- Refactor: [HCOS] docs/pattern_*.md を docs/patterns/ へ移動 (#90 Part 1). hcos_pr_policy.yml regex, AGENTS.md, KNOWLEDGE_INDEX.md, 内部リンク5箇所を一括更新。
- Feature: [HCOS] audit follow-up: Tier B ステータス更新・古いリンク修正 (#148 後続).
- Feature: [HCOS] docs Read First / Knowledge Index lightweight audit closes #148.
- Feature: [HCOS] Claude review request template を issue_comment_templates.md に追加 (#146) closes #146.
- Feature: [HCOS] mobile GitHub instruction workflow templates closes #144.
- Feature: [HCOS] label sync Phase 2 rename safety and handoff labels closes #142.
- Fix: [HCOS] label sync Phase 2: rename migration を通常 sync 前に分離し、triage / PR labels を taxonomy v1.2 に整合 closes #142.
- Feature: [HCOS] ラベル体系の正本・同期スクリプト (#140 Phase 1) closes #140.
- Docs/scripts added: docs/label_taxonomy.md, scripts/labels.json, scripts/sync_labels.ps1（ラベル体系の正本・同期スクリプト。Issue #140 Phase 1。handoff:human-merge と色衝突/repo間ドリフトの是正設計。適用は Phase 2 別Issue）.
- Feature: [HCOS] Tier B オンボーディング: ikensho_git (#120 部分完了).
- Feature: [HCOS] Tier B オンボーディング: keikakusho / DM-kousin / wakumy_apilot (#120 残り) closes #120.
- Feature: [HCOS] セットアップ文書の旧パスを標準パスに修正・skills startup shortcut 手順を追加.
- Feature: [HCOS] ADR 003: エージェント識別と署名の原則（Council #138 合意文書）.
- Feature: [HCOS] Tier B オンボーディング完了: skills (#121) closes #121.
- Feature: [HCOS] AI reviewer の Approve と Merge 権限境界を明文化 closes #127.
- Feature: [HCOS] 新規端末向け local workspace bootstrap script を追加 closes #131.
- Scripts updated: scripts/bootstrap_local_workspace.ps1, scripts/check_local_workspace.ps1, scripts/install_git_safety_hooks.ps1.
- Feature: [HCOS] Antigravity / AI agent の main push・merge 誤操作ガードを追加 closes #129.
- Docs/scripts added: docs/ai_agent_merge_guardrails.md, scripts/install_git_safety_hooks.ps1, scripts/git-hooks/pre-push.
- Feature: [HCOS] ローカルrepo配置・ワークスペース標準と診断スクリプトを追加 closes #125.
- Feature: [HCOS] 複数プロジェクト保守・再始動の運用基盤を追加 closes #123.
- Feature: [HCOS] Add local workspace standard, role guide, VS Code workspace, and diagnosis script closes #125.
- Docs added: docs/local_workspace_standard.md, docs/local_workspace_roles.md, workspaces/hcos-dev.code-workspace, scripts/check_local_workspace.ps1.
- Feature: [HCOS] Add multi-project maintenance catalog, re-entry checklist, and monthly review template closes #123.
- Docs added: docs/repo_catalog.md, docs/project_reentry_checklist.md, .github/ISSUE_TEMPLATE/monthly_hcos_review.yml.
- Feature: [HCOS] HCOS 発足振り返り：ドキュメント整備・管理対象リポジトリ拡張・AGENTS.md 再編.

## 2026-05-30

- Feature: [HCOS] docs: summarymaker オンボーディング記録と own-PR review 制約の文書化.

- Feature: [HCOS] Document HCOS workflow onboarding for related repositories closes #117.

## 2026-05-21

- Feature: [HCOS] Document Git metadata permissions for agent workspaces closes #109.
## 2026-05-21

- Feature: [HCOS] READMEから開発環境セットアップへ辿れる導線を整備する closes #114.
## 2026-05-20

- Feature: feat: add pdfplumber and python-pptx to requirements.txt.
## 2026-05-20

- Feature: [HCOS] Clarify environment setup scope and add application setup guide (Part B).
## 2026-05-20

- Feature: [HCOS] Add GitHub account selection warnings to terminal setup.
## 2026-05-20

- Feature: [HCOS] Add complete terminal setup procedure with Git ACL fix.
## 2026-05-20

- Feature: [HCOS] Add git setup guide for agents.
## 2026-05-17

- Feature: [HCOS] Add kensin cancelled visit output safety rule closes #98.
- Safety Rule added: docs/safety/kensin_cancelled_visit_output_safety_rule.md.
## 2026-05-17

- Feature: [HCOS] Chat-first decision pattern closes #103.
- Pattern added: docs/pattern_chat_first_hcos_decision.md.
## 2026-05-17

- Feature: [HCOS] Record Council #98 reception cancel policy ADR.
- ADR added: docs/adr/adr_002_reception_cancel_rebooking_policy.md.
## 2026-05-13

- Feature: [HCOS] fix(workflows): support status auto-advance and preserve existing states closes #94.
## 2026-05-11

- Feature: fix(triage): クリック/clickによる誤ブロックを修正.
## 2026-05-11

- Feature: [HCOS] docs/adr_001_pdf_digitizer_scope.md を docs/adr/ へ移動.
- ADR added: docs/adr/adr_001_pdf_digitizer_scope.md.
## 2026-05-10

- Feature: [HCOS] GitHub Actions 失敗通知修正：GCP guard ステップと docs-only PR バイパス.
## 2026-05-10

- Feature: [HCOS] Issue バックログ定期監査パターンの追加.
- Pattern added: docs/pattern_hcos_issue_audit.md.
## 2026-05-10

- Feature: [HCOS] README 整理：リポジトリ構造・クイックリンク・アクティブプロジェクト表の追加.
## 2026-05-10

- Feature: [HCOS] ADR-001: pdf_digitizer の役割を Phase 1-2 座標抽出に限定する closes #78.
## 2026-05-10

- Feature: [HCOS] クリニック sub PC での kensin アップデート・hotfix 手順書の作成 closes #82.
- Pattern added: docs/pattern_kensin_clinic_subpc_update.md.
## 2026-05-10

- Feature: [HCOS] 院内ポータブルアプリ向け GCP サービスアカウント別 JSON キー管理ガイド整備 closes #80.
- Pattern added: docs/pattern_gcp_portable_key.md.
## 2026-05-10

- Feature: [HCOS] Create docs/claude_project_context.md — Claude Projects system prompt for mobile HCOS sessions closes #76.
## 2026-05-10

- Feature: [HCOS] Add Gem sync procedure and Claude Projects setup to human_cto_commands.md closes #75.
## 2026-05-10

- Feature: [HCOS] One-Line BOOT System (Stage-2.6) の実装 closes #71.
## 2026-05-10

- Feature: [HCOS] Add pre-flight git cleanup step to Codex implementation prompts closes #68.
## 2026-05-10

- Feature: [HCOS] Stage-2 — externalize humanCto username to repository variable closes #64.
## 2026-05-10

- Feature: [HCOS] Stage-2 — hcos_boot_context.py live GitHub state reading closes #63.
## 2026-05-10

- Feature: [HCOS] Add Human CTO command reference.
## 2026-05-10

- Feature: [HCOS] Stage-2 — remaining role files and BOOT.md load list update closes #62.
## 2026-05-10

- Feature: [HCOS] Phase 4 — GitHub Actions state guard workflows closes #59.
## 2026-05-10

- Feature: [HCOS] Phase 1 completion — role entry files and extended boot roles closes #58.
## 2026-05-10

- Feature: [HCOS] Add --full option to hcos_boot_context.py closes #55.
## 2026-05-10

- Feature: [HCOS] Refine issue triage to reduce false safety:emr-ahk classification closes #54.
## 2026-05-10

- Feature: [HCOS] Add boot/state/role protocol for agent sessions closes #52.
## 2026-05-09

- Feature: [HCOS] Promote sub-PC sync and AHK bridge status knowledge closes #50.
## 2026-05-09

- Feature: [HCOS] Add sub-PC sync tools and usage docs.
## 2026-05-09

- Feature: [HCOS] Corporate GCP Setup Guide and Issue #38 draft.
## 2026-05-09

- Feature: [HCOS] Migrate to Vertex AI and Setup Workload Identity Federation for GitHub Actions closes #36.
## 2026-05-08

- Feature: [HCOS] Add ADR 001 for FOBT manual entry policy.
- ADR added: docs/adr/adr_001_fobt_manual_entry_policy.md.

## 2026-05-07

- Feature: [HCOS] docs/gcp_corporate_admin_setup_guide.md: 法人管理者向け Vertex AI セットアップガイド作成
- Feature: [kensin] docs/manuals/staff_one_page_guide.html: スタッフ向け1枚絵運用クイックガイド作成
- Fix: [kensin] docs/manuals/03_doctor.md: 血糖値統合ロジックの詳細を追記
- Council: [HCOS] Issue #38: 法人GCP移行と認証標準化の議題を起票
## 2026-05-06

- Feature: [HCOS] Fix post-merge workflow token permissions for Issue #34 closes #34.
## 2026-05-06

- Feature: [HCOS] Promote idempotent build pattern from Issue #32 closes #32.
- Pattern added: docs/pattern_idempotent_build.md.
## 2026-05-06

- Feature: [HCOS] Document HCOS Mobile CTO Terminal (Issue Creator Gem) closes #30.
## 2026-05-06

- Feature: [HCOS] Clarify Codex-driven Knowledge Promotion process closes #28.
- Pattern added: docs/pattern_hcos_pr_workflow.md.
## 2026-05-06

- Feature: [HCOS] Implement HCOS AI Council (Multi-Agent Meeting System) closes #26.
## 2026-05-06

- Feature: [HCOS] Apply Agent Operational Safety Rule closes #25.
## 2026-05-06

- Feature: [HCOS] Agent Operational Safety Rule Integration closes #23.
- Safety Rule added: docs/safety/agent_operational_safety_rule.md.
## 2026-05-05

- Feature: [HCOS] Knowledge OS workflow hardening closes #19.
## 2026-05-05

- Feature: [HCOS] Filter tier-relevant docs in knowledge index sync closes #18.
## 2026-05-05

- Feature: [HCOS] PR Policy Integration (Safety Gate v2) (PR D) closes #12.
## 2026-05-05

- Feature: [HCOS] AI Context Builder Script (PR B) closes #12.
## 2026-05-05

- Feature: [HCOS] 自動化ワークフローのコミット先ブランチ修正 closes #11.
