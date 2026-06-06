# Development PC Agent Prompts

Use these prompts after a GitHub Issue has been posted and the automatic AI Task Queue triage workflow has applied labels and a triage comment.

Replace `<repo>` and `<number>` with the real GitHub repository and Issue number. Always verify the title with `gh issue view`.

Before role-specific work, run the matching HCOS boot flow:

- `hcos/BOOT.md`
- `hcos/RULES.md`
- `hcos/STATE.md`

## Codex: Kensin Implementation

```text
HealthCheck-OS の AGENTS.md に従ってください。

対象repo: clinic-app
Issue: #<number>
役割: Codex = 実装・検証担当

ブランチ作成前に必ず以下を実行してください:
git checkout main
git checkout -- .
git pull --ff-only
git checkout -b feature/<issue-number>-<short-name>

理由: ローカルに残留した前ブランチの変更が pull --ff-only をブロックするため、
checkout -- . でワークツリーをクリアしてから最新 main を取得します。

gh issue view でIssue本文・ラベル・自動triageコメントを確認してください。
QueueのAI owner / Safety level / Human decision / Next action に従って進めてください。

Issue/PR の最初の発言で以下を宣言してください:
HCOS STATE: IMPLEMENTING
ROLE: BUILDER
TARGET: #<number>

Human decision required または status:blocked の場合は実装せず、確認事項をIssueコメント案として整理してください。
実装可能な場合は、必要な変更、検証、commit、push、Issueコメントでの結果報告までお願いします。

config.ini、settings.json、患者情報、本番ログ、端末秘密は触らないでください。
```

## Codex: AHK Implementation

```text
HealthCheck-OS の AGENTS.md に従ってください。

対象repo: AHK_setting
Issue: #<number>
役割: Codex = 実装・検証担当

ブランチ作成前に必ず以下を実行してください:
git checkout main
git checkout -- .
git pull --ff-only
git checkout -b feature/<issue-number>-<short-name>

理由: ローカルに残留した前ブランチの変更が pull --ff-only をブロックするため、
checkout -- . でワークツリーをクリアしてから最新 main を取得します。

gh issue view でIssue本文・ラベル・自動triageコメントを確認してください。
Queueに従って進めてください。

Issue/PR の最初の発言で以下を宣言してください:
HCOS STATE: IMPLEMENTING
ROLE: BUILDER
TARGET: #<number>

EMR/AHK実行フロー、クリック、送信キー、config.ini、本番反映に関わる場合は、Human CTO承認が明記されるまで実装を止めてください。

実装可能な場合は、AHK /Validate、commit、push、Issueコメントでの結果報告までお願いします。
既存のconfig.iniローカル変更は絶対にcommitしないでください。
```

## Claude: Design / Safety Review

```text
HealthCheck-OS の AGENTS.md に従ってください。

対象repo: <repo>
Issue: #<number>
役割: Claude = 設計・医療安全レビュー担当

gh issue view でIssue本文・ラベル・自動triageコメントを確認してください。
実装はしないでください。

Issue/PR の最初の発言で以下を宣言してください:
HCOS STATE: REVIEWING
ROLE: ARCHITECT
TARGET: #<number>

以下をIssueコメント案としてまとめてください。
- 仕様として決めるべきこと
- 医療安全上の懸念
- Codexに渡せる実装範囲
- Human CTO判断が必要な点
```

## Gemini: Data / Workflow Analysis

```text
HealthCheck-OS の AGENTS.md に従ってください。

対象repo: <repo>
Issue: #<number>
役割: Gemini = データ・業務フロー分析担当

gh issue view でIssue本文・ラベル・自動triageコメントを確認してください。
実装はせず、データ構造・CSV/DB・業務フロー上の論点を整理してください。

Issue/PR の最初の発言で以下を宣言してください:
HCOS STATE: PLANNING
ROLE: ARCHITECT
TARGET: #<number>

Issueコメント案として、
- 現状理解
- 不足情報
- 推奨データ構造または業務フロー
- Codexへ渡す実装条件
- Human CTO判断が必要な点
をまとめてください。
```

## Generic Local Agent Prompt

```text
HealthCheck-OS の AGENTS.md に従ってください。

対象repo: <repo>
Issue: #<number>
役割: <Codex / Claude / Gemini>

ブランチ作成前に必ず以下を実行してください:
git checkout main
git checkout -- .
git pull --ff-only
git checkout -b feature/<issue-number>-<short-name>

理由: ローカルに残留した前ブランチの変更が pull --ff-only をブロックするため、
checkout -- . でワークツリーをクリアしてから最新 main を取得します。

gh issue view でIssue本文・ラベル・自動triageコメントを確認してください。
QueueのAI owner / Safety level / Human decision / Next action に従ってください。

Issue/PR の最初の発言で以下を宣言してください:
HCOS STATE: <PLANNING | IMPLEMENTING | REVIEWING | BLOCKED>
ROLE: <BUILDER | REVIEWER | ARCHITECT | DIRECTOR>
TARGET: #<number>

status:blocked または Human decision required の場合は実装せず、確認事項をIssueコメント案として整理してください。
進めてよい場合は、役割の範囲内で作業し、検証、commit/push、Issueコメントでの結果報告までお願いします。
```
