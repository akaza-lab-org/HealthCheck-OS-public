# Human CTO コマンドリファレンス

Human CTO が実際に操作する場面ごとのコマンド・手順一覧です。

---

## 1. PR マージ（最頻出）

Claude の Approve コメントとテスト通過を確認してから実行。

```
GitHub PR 画面 → "Squash and merge" を選択 → マージ実行
```

**ルール:**
- Squash and merge のみ（Merge commit / Rebase merge は使わない）
- Claude Approve コメントがない PR はマージしない
- `main` への直接 push はしない
- マージは Human CTO が GitHub UI または gh CLI で直接行う

**AI reviewer の Approve と Merge の境界:**

Claude / Codex は、設計・実装・レビュー・`PR Review: Approve` まで担当してよい。

ただし、`PR Review: Approve` は merge-ready の合図であり、マージ実行の委任ではない。
Approve 後も AI agent は PR をマージしてはならない。

`ok`、`はい`、`進めて`、`マージ承認 <PR番号>` などの返答も、AI へのマージ実行委任とはみなさない。
AI が実行してよいのは、PR 状態確認・レビュー・修正・Approve・Human CTO 向けマージ手順提示まで。

---

## 2. Issue 承認・アンブロック

`status:blocked` の Issue を動かすとき。

**方法 A — Issue 本文を更新する（推奨）**

Issue 本文の Queue セクションを編集:
```
- Human decision: required
↓
- Human decision: decided
```

その後 `status:blocked` ラベルを外し `status:ready` を付ける。

**方法 B — コメントで承認を記録する**

```
Human decision: decided

承認内容: <決定内容>
実装可能範囲: <Codex に渡してよい範囲>
```

---

## 3. `council:decision` ラベルの付与

Human CTO のみが付けられるラベル。AI が付けると自動削除される。

```
Issue 画面 → Labels → council:decision を選択
```

順序: `council:open` → `council:review` → **`council:decision`** → `council:archived`

`council:archived` は bot が自動で付ける。

---

## 4. Codex への実装依頼

Issue 番号を確認してから、以下のプロンプトを Codex に渡す。

**kensin 実装の場合:**
```
HealthCheck-OS の AGENTS.md に従ってください。

HCOS STATE: IMPLEMENTING
ROLE: BUILDER
TARGET: #<Issue番号>

対象repo: clinic-app
Issue: #<Issue番号>
役割: Codex = 実装・検証担当

gh issue view でIssue本文・ラベル・自動triageコメントを確認してください。
QueueのAI owner / Safety level / Human decision / Next action に従って進めてください。

Human decision required または status:blocked の場合は実装せず、確認事項をIssueコメント案として整理してください。
実装可能な場合は、必要な変更、検証、commit、push、Issueコメントでの結果報告までお願いします。

config.ini、settings.json、患者情報、本番ログ、端末秘密は触らないでください。
```

**HCOS 実装の場合:**
```
HealthCheck-OS の AGENTS.md に従ってください。

HCOS STATE: IMPLEMENTING
ROLE: BUILDER
TARGET: #<Issue番号>

対象repo: HealthCheck-OS
Issue: #<Issue番号>
役割: Codex = 実装・検証担当

gh issue view でIssue本文・コメントを確認してください。
実装、検証、commit、push、PRの提出までお願いします。

config.ini、settings.json、患者情報、本番ログ、端末秘密は触らないでください。
医療ロジック・AHK実行フロー・本番配布に関係するファイルは変更しないでください。
```

---

## 5. Claude レビュー依頼

PR が上がったら Claude に渡す。

```
<PR URL> レビューしてください
```

または Issue に対して設計レビューを求める場合:

```
<Issue URL> レビューしてください。良ければ Codex に実装させます
```

---

## 6. GitHubコメントでAI作業を依頼する（スマホ/自宅内）

スマホや別端末からは、GitHub Issue/PR コメントを「指示キュー」として使う。実作業は開発PC側の Codex / Claude セッションが GitHub thread を読んで実行する。

**Codex 実装依頼:**

```text
Codex request:

Target: #<Issue番号>
Goal: <何を達成するか>

Allowed:
- Inspect GitHub Issue/PR comments and labels.
- Edit files within the stated scope.
- Run local verification.
- Commit, push, and open a PR.

Prohibited:
- Do not merge.
- Do not apply production settings or destructive changes.
- Do not include patient data, identifiers, production logs, screenshots with identifiers, terminal secrets, or credentials.

Completion:
- Leave an Issue/PR comment with changed files, commit, verification, and remaining cautions.
```

**dry-run のみ許可:**

```text
Dry-run only:

Target: #<Issue番号>

Allowed:
- Inspect current repo/GitHub state.
- Run read-only checks and dry-run commands.
- Post findings.

Prohibited:
- Do not write files.
- Do not push.
- Do not apply labels/settings/production operations.
- Do not merge.
```

**見るべきラベル:**

| 状況 | ラベル |
|---|---|
| Codex 着手待ち | `ai:codex` + `status:ready` |
| Claude レビュー待ち | `review:claude` + `status:review` |
| Human CTO マージ待ち | `handoff:human-merge` |
| 真のブロック | `status:blocked` |

`status:blocked` / `ai:human-review` / `review:human` は単なるマージ待ちには使わない。レビュー済みで残りが Human CTO の merge 操作だけなら `handoff:human-merge` を使う。

---

## 7. One-Line BOOT（モバイル向けショートハンド）

AIセッションを1行で確定させるコマンド形式。

| コマンド例 | 意味 |
|---|---|
| `HCOS>B#71` | Issue #71 を BUILDER / IMPLEMENTING で開始 |
| `HCOS>R#71` | Issue #71 を REVIEWER / REVIEWING で開始 |
| `HCOS>A#71` | Issue #71 を ARCHITECT / PLANNING で開始 |
| `HCOS>G#71` | Issue #71 を GEMINI / PLANNING で開始 |
| `HCOS>E#71` | Issue #71 を ESCALATION / PLANNING で開始 |
| `HCOS>I` | セッション終了・IDLE |

One-Line BOOT を受けた AI は、必ず Full Declaration に展開してから作業を開始する。

```text
HCOS STATE: <STATE>
ROLE: <ROLE>
TARGET: #<issue-number>
```

---

## 8. Gem Manual Sync

Gem workspace は現在手動同期で運用する。

実施タイミング:
- `AGENTS.md` 変更後
- `hcos/` 配下（`BOOT.md`, `RULES.md`, `STATE.md`, `roles/`）の主要変更後
- `docs/mobile_ai_context.md` または運用ルール文書の更新後

手順:
1. GitHub 上の最新 `AGENTS.md` と関連 `docs/` を確認する。
2. Gem のナレッジ/指示欄を開く。
3. 既存テキストとの差分を反映し、古い制約や手順を更新する。
4. 反映後、短い確認メモを Issue または運用メモに残す（例: `Gem sync completed`）。

注意:
- 患者情報・本番ログ・端末秘密を Gem へ貼らない。
- private repository URL だけ渡しても内容を読めない場合があるため、必要テキストを明示的に渡す。

---

## 9. Claude Projects Setup

`docs/claude_project_context.md` を Claude mobile sessions の system prompt として設定する。

初回セットアップ（1回）:
1. `claude.ai/projects` を開く。
2. `New project` を作成する。
3. `docs/claude_project_context.md` の内容を instructions に貼り付ける。
4. 保存して、プロジェクト名を HCOS 用と分かる名前に設定する。

更新タイミング:
- `AGENTS.md` の重要更新後
- `hcos/` の major 変更後（role/state/boot 仕様変更など）
- Human CTO が運用方針を更新した後

更新手順:
1. 最新の `docs/claude_project_context.md` を開く。
2. Claude Project の instructions を上書き更新する。
3. 変更日と更新理由を短くメモする。

---

## 10. hcos_boot_context.py — コンテキスト確認

セッション開始時に HCOS の現在のルールセットを確認する。

```bash
# 最小出力（BOOT/RULES/STATE + AGENTS.md）
python scripts/hcos_boot_context.py BUILDER

# フル出力（上記 + ai_cto_rules + agent_operational_safety_rule）
python scripts/hcos_boot_context.py BUILDER --full

# Issue の状態も含めて確認
python scripts/hcos_boot_context.py BUILDER --issue <Issue番号>
python scripts/hcos_boot_context.py BUILDER --issue <Issue番号> --full
```

利用可能なロール: `BUILDER` / `REVIEWER` / `ARCHITECT` / `DIRECTOR` / `GEMINI` / `ANTIGRAVITY` / `ESCALATION`

---

## 11. git 操作

**main を最新化する（通常）:**
```bash
git pull --ff-only
```

**ローカルの余分な変更を確認・破棄する:**
```bash
git diff --name-only          # 変更ファイルを確認
git checkout -- .             # 全変更を破棄（確認後に実行）
```

**feature ブランチを作り直す:**
```bash
git checkout main
git branch -D feature/<branch-name>
git push origin --delete feature/<branch-name>
git pull --ff-only
git checkout -b feature/<branch-name>
```

**マージ済み feature ブランチの掃除:**
```bash
git fetch --prune
git branch --merged main | grep feature/ | xargs git branch -d
```

---

## 12. GitHub Settings 操作

**Repository Variable の追加:**
```
Settings → Secrets and variables → Actions → Variables → New repository variable
```

現在設定済みの変数:
| 変数名 | 値 | 用途 |
|---|---|---|
| `HUMAN_CTO_USERNAME` | `akazatmd-ctrl` | state guard の actor チェック |

---

## 13. 判断フロー早見表

```
Issue が届いた
  → status:blocked + ai:human-review → 自分で判断 → 方法A/B で承認
  → status:triage + ai:codex        → Codex に実装依頼
  → status:review + review:claude   → Claude にレビュー依頼

PR が届いた
  → Claude Approve あり + テスト通過 → Squash and merge
  → Claude Request Changes あり      → Codex に修正依頼
  → review:claude のみ               → Claude にレビュー依頼

council Issue が届いた
  → council:open    → 議論参加・方針決定
  → council:review  → レビュー・合意確認
  → 決定したら      → council:decision ラベルを付ける（Human CTO のみ）
```

---

## 14. やってはいけないこと

| 禁止事項 | 理由 |
|---|---|
| `main` に直接 push | PR ゲートを迂回するため |
| Merge commit / Rebase merge | Squash and merge のみが HCOS ルール |
| Claude Approve なしのマージ | 安全レビューが未完了 |
| `council:decision` を AI に付けさせる | Human CTO 専用ラベル |
| `config.ini` / `settings.json` / 本番ログを commit | 端末秘密・本番設定の流出リスク |
