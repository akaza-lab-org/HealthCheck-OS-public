# HealthCheck-OS

> **⚠️ Public mirror — read only.**
> This is a sanitized reference copy. Development, Issues, and PRs are tracked in the private repository.
> Do not use this repo as a working directory for AI agents.

健診業務・医療業務の自動化開発を、複数AIエージェントと人間が安全に分担するための共有OSです。

## クイックスタート

**AI エージェント向け** → [`AGENTS.md`](AGENTS.md) を最初に読む（Read First リスト・ルール・ロール定義）

**Human CTO 向け** → [`docs/human_cto_commands.md`](docs/human_cto_commands.md)（PR マージ・Issue 承認・Codex 依頼・git 操作）

**開発環境セットアップ** → [`docs/guides/kensin/kensin_ahk_dev_environment.md`](docs/guides/kensin/kensin_ahk_dev_environment.md)（kensin / AHK / HCOS のローカル開発環境）

**モバイル AI セッション向け** → [`docs/claude_project_context.md`](docs/claude_project_context.md)（Claude Projects system prompt）

**ローカル初期セットアップ** → [`docs/local_environment_bootstrap.md`](docs/local_environment_bootstrap.md)（HealthCheck-OS / kensin / AHK_setting / 共通 skills の初期配置と更新導線）

**新規端末 bootstrap** → 最初に HCOS を clone 後、`scripts/bootstrap_local_workspace.ps1 -Role dev -InstallHooks` で標準 repo clone・診断・hook install

## リポジトリ構造

```
hcos/           # AI BOOT 時の必読ファイル群
  BOOT.md       # 起動プロトコル・One-Line BOOT ショートハンド
  RULES.md      # 絶対遵守ルール
  STATE.md      # 現在のフェーズ・アクティブ Issue
  roles/        # ロール定義（builder / reviewer / architect）

docs/           # 運用ドキュメント・パターン・ADR
  pattern_*.md  # 実装パターン集
  adr_*.md      # アーキテクチャ決定記録
  safety/       # 安全規則

.github/        # Issue テンプレート・GitHub Actions ワークフロー
```

## 管理対象リポジトリ

HCOS の管理を3段階のティアで運用しています。

運用目録と再始動手順:

- [`docs/repo_catalog.md`](docs/repo_catalog.md) — 管理対象 repository / local-only tool の Tier、状態、次アクション、注意点
- [`docs/project_reentry_checklist.md`](docs/project_reentry_checklist.md) — 休眠・低頻度 project を再開する前の確認手順
- [`docs/local_workspace_standard.md`](docs/local_workspace_standard.md) — 標準 local path、clone command、VS Code workspace
- [`docs/local_workspace_roles.md`](docs/local_workspace_roles.md) — 開発PC・サブPC・実機端末ごとの必要 repository
- [`docs/ai_agent_merge_guardrails.md`](docs/ai_agent_merge_guardrails.md) — AI agent の direct push / merge 誤操作を防ぐ GitHub 設定と local hook
- [`.github/ISSUE_TEMPLATE/monthly_hcos_review.yml`](.github/ISSUE_TEMPLATE/monthly_hcos_review.yml) — 月次の複数 repository 棚卸し Issue template

### Tier A — フルHCOS管理
Issue/PR テンプレート・ブランチ保護・triage ワークフローをすべて適用。

| リポジトリ | 役割 |
|---|---|
| `akaza-lab-org/HealthCheck-OS` | 本リポジトリ（調整・ドキュメント・ガバナンス） |
| clinic app repos | クリニック業務アプリ（健診管理・PDF 生成など） |
| AHK/automation repos | AutoHotkey 連携（EMR 操作自動化） |

### Tier B — アドバイザリ管理
PR テンプレートのみ適用。HCOS 側の Issue でタスクを追跡し、PRゲートは強制しない。

| リポジトリ | 役割 | 状態 |
|---|---|---|
| `akaza-lab-org/summarymaker` | 糖尿病サマリー作成アプリ（Gemini / Next.js / Electron） | オンボーディング中 |
| `akaza-lab-org/pdf_digitizer` | PDF 座標抽出ツール（[ADR-001](docs/adr/adr_001_pdf_digitizer_scope.md): Phase 1-2 のみ） | 管理中 |
| `akaza-lab-org/skills` | 共通 AI skills（Codex / Claude Code / Antigravity） | Tier B 適用済み |
| `akaza-lab-org/ikensho_git` | 医療文書・意見書作成アプリ | Tier B 適用済み |
| `akaza-lab-org/keikakusho` | 計画書作成ツール（診療補助） | Tier B 適用済み |
| `akaza-lab-org/DM-kousin` | DM 受診勧奨ツール（診療補助） | Tier B 適用済み |
| `akaza-lab-org/wakumy_apilot` | 巡回・ワクチン接種管理ツール | Tier B 適用済み |

### Tier C — 目録管理のみ
リポジトリ側に変更を加えず、HCOS 内に存在を記録するだけ。

| ツール | 場所 | 備考 |
|---|---|---|
| tobu（トブチケ） | ローカルのみ | skill あり |
| chatworks | ローカルのみ | — |
| 講演会スライド | Google Drive | リポジトリなし |

## HCOS AI Council

Issue を「AI 会議室」として使う Council 運用を導入しています。

- Issue テンプレート: [`.github/ISSUE_TEMPLATE/ai_council.yml`](.github/ISSUE_TEMPLATE/ai_council.yml)
- ワークフロー: [`.github/workflows/hcos_ai_council.yml`](.github/workflows/hcos_ai_council.yml)
- 決定記録: [`docs/adr_*.md`](docs/)

Council ライフサイクル:

```
council:open → council:review → council:decision → council:archived
                                ↑ Human CTO のみ遷移可
```

ルール:
- Council Dispatch は静的テンプレート投稿のみ（AI API 呼び出しなし）
- `council:review → council:decision` の遷移は Human CTO のみ
- AI エージェントは `council:decision` ラベルを付けてはならない
