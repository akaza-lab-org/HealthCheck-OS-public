# HCOS Knowledge Index

このドキュメントは、HCOSリポジトリに蓄積された知識（Knowledge）のエントリーポイントです。
すべてのAIエージェントおよび開発者は、実装や意思決定を行う際に必ずこのインデックスを参照し、関連する知識を読み込んでください。

## Tier 1 — Core (必読)
プロジェクトの根本的なルール、アーキテクチャ、およびAIと人間の協働における絶対的な制約を定義します。

- [HCOS Architecture](core/HCOS.md)
- [Project Rule](core/project_rule.md)
- [AI CTO Rules](core/ai_cto_rules.md)

## Tier 2 — Safety (ABSOLUTE CONSTRAINTS)
医療データの取り扱い、外部への出力、および破壊的変更に関する**絶対的な安全基準**です。これらに違反するコードや設計は自動的にリジェクトされます。

- [PHI External Output Safety Rule](safety/phi_external_output_safety_rule.md)
- [Agent Operational Safety Rule](safety/agent_operational_safety_rule.md)
- [AI Security Regulation Exception Clause](safety/ai_security_regulation_exception.md)

## Tier 3 — ADR (設計判断)
なぜその技術選定や設計に至ったか（WHY）の履歴です。既存の設計を変更・拡張する際は必ず関連するADRを確認してください。

- [ADR 001: pdf_digitizer の役割を Phase 1-2 座標抽出に限定する](adr/adr_001_pdf_digitizer_scope.md)
- [ADR 003: エージェント識別と署名の原則（Attribution vs Authentication）](adr/adr_003_agent_identity_signature_principles.md)
- [Council Decision: GCP Vertex AI 移行と認証標準化（Issue #38）](adr/2026-05-10_council-issue-38-hcos-council-gcp-vertex-ai.md)

## Tier 4 — Pattern (実装知識)
特定の要件を満たすための具体的な実装パターンや、プロジェクト特有のコーディング規約です。

**HCOS 運用**
- [HCOS Repository Catalog](repo_catalog.md)
- [HCOS Label Taxonomy](label_taxonomy.md)
- [Docs Lightweight Audit 2026-05-31](docs_lightweight_audit_2026-05-31.md)
- [Local Workspace Standard](local_workspace_standard.md)
- [Local Workspace Roles](local_workspace_roles.md)
- [AI Agent Merge Guardrails](ai_agent_merge_guardrails.md)
- [Human CTO Commands](human_cto_commands.md)
- [Mobile AI Context](mobile_ai_context.md)
- [Issue Comment Templates](issue_comment_templates.md)
- [AI Task Queue](ai_task_queue.md)
- [Agent Plan Handoff](agent_plan_handoff.md)
- [Project Re-entry Checklist](project_reentry_checklist.md)
- [Pattern: HCOS PR Workflow](patterns/pattern_hcos_pr_workflow.md)
- [Pattern: HCOS Repository Onboarding](patterns/pattern_hcos_repo_onboarding.md)
- [Pattern: HCOS Issue Audit](patterns/pattern_hcos_issue_audit.md)
- [Pattern: Chat-first HCOS Decision](patterns/pattern_chat_first_hcos_decision.md)

**実装パターン**
- [Pattern: Update Field No Rerender](patterns/pattern_updatefield_no_rerender.md)
- [Pattern: Idempotent Build](patterns/pattern_idempotent_build.md)

**インフラ・デプロイ**
- [Pattern: GCP Portable Key](patterns/pattern_gcp_portable_key.md)
