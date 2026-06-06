# Antigravity セッション開始ガイド

## Antigravity の HCOS における役割

**分類:** 実装支援エージェント（Codex と同等）＋ CTO 補助

| 許可 | 禁止 |
|------|------|
| Issue 原案の草稿作成 | `main` への直接コミット |
| マージ忘れ・TODO の指摘（通知のみ） | `gh pr merge` / GitHub UI でのマージ |
| `git clone`, `git pull` 等の読み取り系操作の代行 | コードの直接編集（feature ブランチ外） |
| トークン切れ時の Claude/Gemini 代替（同役割範囲内） | PR Gate のバイパス |
| feature ブランチ上での実装支援（承認済み Issue 範囲内） | Human CTO の承認を代替する判断 |
| **現状把握と次アクションの提案（CTO 補助）** | CTO に代わって意思決定・承認 |

詳細: `docs/safety/agent_operational_safety_rule.md` Section 2

---

## Pre-flight Guardrails

実装・レビュー補助に入る前に、必ず [`docs/ai_agent_merge_guardrails.md`](ai_agent_merge_guardrails.md) を確認する。

最低限、以下を満たすまで編集を開始しない。

```bash
git branch --show-current
```

- current branch が `main` / `master` の場合は、Issue に対応する `feature/<issue-number>-short-name` を作成してから作業する
- `gh pr merge`、GitHub UI merge、merge API は実行しない
- PR 作成、レビュー、Approve まで完了したら「Human CTO merge 待ち」で停止する

新規 clone または hook 未導入の端末では、HCOS root から次を実行する。

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install_git_safety_hooks.ps1 -Role dev
```

実機/EMR 端末では `-Role clinic`、サブPCでは `-Role subpc` を使う。

---

## セッション開始手順

### ステップ 1 — コンテキストを生成する

```bash
python scripts/build_ai_context.py --output stdout
```

出力内容:
- Tier 1 Core（プロジェクトルール・アーキテクチャ）
- Tier 2 Safety（`[ABSOLUTE CONSTRAINT]` タグ付き、マージ禁止・役割隔離ルールを含む）
- Tier 3 ADR（設計判断の履歴）
- Tier 4 Pattern（実装パターン）

### ステップ 2 — Antigravity に貼り付ける

上記の stdout 出力をそのままセッション冒頭のシステムプロンプトまたは最初のメッセージに貼り付ける。

### ステップ 3 — CTO ブリーフを依頼する（推奨）

コンテキストを読ませた後、以下を依頼する：

```
HCOS の現状を確認して、CTO が次に取るべきアクションを優先順位付きで提案してください。
```

Antigravity は下記「CTO 補助モード」の手順に従い、現状を把握してアクションリストを提示する。

---

## ローカル初期セットアップをする場合

新しい端末で HCOS / kensin / AHK_setting / shared skills をそろえるときは、先に [`docs/local_environment_bootstrap.md`](local_environment_bootstrap.md) を読む。
共有 skills の更新は `skills` リポジトリで `update-shared-skills.ps1` を実行する。

---

## CTO 補助モード — 現状把握と次アクション提案

### Antigravity が確認すること

以下の順で GitHub の現状を調査し、CTO への提案を生成する。

```bash
# 1. マージ承認済み・CTO マージ待ちの PR
gh pr list --repo akaza-lab-org/HealthCheck-OS --state open --json number,title,labels,reviews

# 2. レビュー待ち PR（status:review ラベル）
gh pr list --repo akaza-lab-org/HealthCheck-OS --label "status:review" --state open

# 3. 実装待ち Issue（status:ready ラベル）
gh issue list --repo akaza-lab-org/HealthCheck-OS --label "status:ready" --state open

# 4. ブロック中の Issue
gh issue list --repo akaza-lab-org/HealthCheck-OS --label "status:blocked" --state open

# 5. 直近マージ済み PR（フォローアップ確認）
gh pr list --repo akaza-lab-org/HealthCheck-OS --state merged --limit 5
```

### 提案フォーマット

```
## HCOS 現状ブリーフ — [日付]

### 今すぐ CTO が判断すること
1. PR #XX「タイトル」— Claude 承認済み・マージ待ち
2. ...

### AI に依頼できること
- Issue #XX「タイトル」— status:ready、Codex/Antigravity で実装可
- ...

### 確認・決定が必要なこと（Human CTO 判断）
- Issue #XX「タイトル」— 医療ロジック判断 / 外部連携承認 など
- ...

### ブロック中（外部待ち）
- Issue #XX「タイトル」— 待ち内容
```

### 提案時のルール

- **提案のみ、実行しない** — CTO が「お願いします」と言った時点で初めて動く
- マージは提案できるが実行しない（「PR #XX をマージするタイミングです」と伝えるのみ）
- 医療ロジック・費用・EMR 連携の判断は提案せず、Human CTO 判断として挙げるだけにする
- 不明な点は推測せず「確認が必要です」と明示する

---

## ファイル出力して使い回す場合

```bash
python scripts/build_ai_context.py --output docs/antigravity_context.md
```

- `docs/antigravity_context.md` は `.gitignore` に追加しておく（自動生成ファイルのため）
- **注意:** ファイルは古くなるため、セッション開始時は毎回スクリプトを実行すること

---

## HCOS 外タスクで使う場合

HCOS ルールは「HCOS コンテキストで動くときの行動規範」であり、常時制約ではない。  
HCOS 関連タスクを依頼するときだけ上記のステップ 1〜3 を実施する。

---

## 将来の自動化（未実装）

`hcos_mobile_context_sync.yml` と同じ仕組みで `antigravity_context.md` を AGENTS.md 変更時に自動再生成するワークフローを追加できる。必要になったら Issue を立てる。
