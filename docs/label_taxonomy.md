# HCOS Label Taxonomy

HCOS と各リポジトリで使うラベルの**正本（source of truth）と運用ルール**。

- 機械可読の正本: [`scripts/labels.json`](../scripts/labels.json)
- 各リポジトリへの展開: [`scripts/sync_labels.ps1`](../scripts/sync_labels.ps1)
- 由来: Issue #140

ラベルを追加・変更するときは、**まず `scripts/labels.json` を編集**し、その後 `sync_labels.ps1` で各リポジトリに反映する。リポジトリ側で直接ラベルを足さない。

## 設計原則

1. **色で軸が分かる。** 分類軸（`repo:` `ai:`）は軸ごとに単色。勾配軸（`safety:` `status:`）は段階ごとに別色。`council:` は teal 系で独立。
2. **異なる意味に同じ色を割り当てない**（軸内の意図的な共有を除く: `repo:*`, `ai:*`, `knowledge:adr`/`pattern`）。
3. **プレフィックスで役割が分かる。** 分類 / 状態 / ルーティング / ハンドオフ / トピックの5カテゴリ。
4. **正本は HCOS。** `labels.json` が唯一の真実。triage workflow の自動付与リストもこれに一致させる。
5. **既存の意味は安易に消さない。** 特に `safety:` は医療安全の粒度（medical-logic / patient-data / critical）を保持する。

## カテゴリとプレフィックス

| カテゴリ | プレフィックス | 役割 | 色の方針 |
|---|---|---|---|
| 分類 | `repo:` | どのリポジトリの作業か | 単色 grey `#cfd3d7` |
| 分類 | `ai:` | 担当AIの提案（選択肢） | 単色 purple `#8250df` |
| 分類 | `safety:` | リスクレベル（1→6） | 緑→黄→橙→赤の勾配 |
| 状態 | `status:` | ワークフローのライフサイクル | 青灰→緑→青→黄→暗 + blocked 赤 |
| 状態 | `council:` | Council のライフサイクル（HCOSのみ） | teal 系 |
| ルーティング | `review:` `knowledge:` | 任意のフラグ | アクセント色 |
| ハンドオフ | `handoff:` | 次の明確な人間操作 | ピンク系 |
| トピック | `type:` | 議題の種類 | 個別 |

## status ライフサイクル（正規・全リポジトリ共通）

```
status:triage → status:ready → status:in-progress → status:review → status:done
                                                                  ↑
                                       status:blocked （直交フラグ：どの段階でも付きうる）
```

| ラベル | 色 | 意味 |
|---|---|---|
| `status:triage` | 🟦 `#c5def5` | 分類待ち |
| `status:ready` | 🟢 `#0e8a16` | 承認済み・着手可 |
| `status:in-progress` | 🔵 `#1d76db` | 作業中 |
| `status:review` | 🟡 `#fbca04` | レビュー・検証待ち |
| `status:done` | ⬛ `#586069` | 完了 |
| `status:blocked` | 🔴 `#e11d21` | 依存・人間判断でブロック（直交） |

triage workflow は `status:ready` / `status:in-progress` / `status:review` を上書きしない（既存状態を保護）。

## safety リスクレベル（6段階・正準）

| ラベル | 色 | レベル | 例 |
|---|---|---|---|
| `safety:ordinary` | 🟩 `#c2e0c6` | 1/6 | 通常のドキュメント・低リスクツール |
| `safety:deployment` | 🟨 `#fef2c0` | 2/6 | 配布・端末セットアップ・同期影響 |
| `safety:emr-ahk` | 🟧 `#f9a03f` | 3/6 | EMR/AHK 実行フローに関わる |
| `safety:medical-logic` | 🟥 `#d93f0b` | 4/6 | 医療判断・点数/オーダーロジック |
| `safety:patient-data` | 🟥 `#b60205` | 5/6 | 患者データ・PHI・識別子 |
| `safety:critical` | 🟥 `#6e0000` | 6/6 | 重大な安全・Knowledge OS 整合性リスク |

`safety:emr-ahk` 以上は原則 Human CTO の判断を要する（`docs/safety/agent_operational_safety_rule.md`）。
旧 `safety:phi` は `safety:patient-data` に統合（リネーム移行）。

## ai 担当（選択肢・単色）

`ai:codex` / `ai:claude` / `ai:gemini` / `ai:human-review`（すべて purple `#8250df`）。
「人間判断が必要」という緊急性は `status:blocked` で表現し、`ai:` は担当の提案にとどめる。`ai:human-review` は Human CTO が設計・安全・運用判断をする必要があるときに使い、単なるマージ待ちには使わない。

> 注: 旧運用では ai:* に個別色を割り当てていたが、gemini=`#fbca04`（status:review と衝突）・human-review=`#b60205`（safety と衝突）など軸をまたぐ色衝突があったため、`repo:` と同じく単色に統一した。

## council（HCOSのみ・teal 系）

`council`（room マーカー `#1f883d`）／ `council:open`（`#54aeb3`）→ `council:review`（`#2d8a8f`）→ `council:decision`（`#0b5e63`）→ `council:archived`（`#cfe0e0`）。

`council:review → council:decision` の遷移は **Human CTO のみ**。AI は付与しない。

## ルーティング / トピック

| ラベル | 色 | 用途 |
|---|---|---|
| `review:claude` | 🟪 `#a371f7` | Claude のアーキ・安全レビュー対象 |
| `review:human` | 🟫 `#bf8700` | Human CTO レビュー要 |
| `handoff:human-merge` | `#db61a2` | レビュー・検証後、Human CTO のマージ操作待ち |
| `knowledge:adr` | 🟦 `#0969da` | ADR 昇格候補 |
| `knowledge:pattern` | 🟦 `#0969da` | 再利用パターン昇格候補 |
| `knowledge:safety` | 🟥 `#d1242f` | 安全ルール昇格候補 |
| `type:architecture` | 🟣 `#5319e7` | アーキテクチャ・設計の議題 |

## handoff:human-merge

`handoff:human-merge` は、AI 側の作業・レビュー・必要な確認が終わり、最後に Human CTO が merge するだけの状態を表す。

- `status:review` と併用してよい。
- `status:blocked` とは併用しない。ブロックではなく、予定された人間操作待ちである。
- `review:human` とは併用しない。追加レビューではなく、マージ権限の受け渡しである。
- `ai:human-review` とは併用しない。担当者の提案ではなく、次アクションの明示である。
- AI agents はこのラベルを付けても merge してはならない。merge は常に Human CTO の操作に限る。

## repo: ラベルの命名規則

- 小文字・短縮名に統一。
- リポジトリ名と異なる場合は短縮名を使う（例: `repo:kensin` ← clinic-app、`repo:ahk` ← AHK_setting）。
- HealthCheck-OS は全 `repo:*` を保持（cross-repo issue のルーティング用）。各アプリ repo は自分の `repo:*` を保持。
- 対応表は `labels.json` の `repo_self_label` を参照。

## 各リポジトリへの展開

```powershell
# まず差分を確認（dry-run）
pwsh -File scripts/sync_labels.ps1 -Repo akaza-lab-org/keikakusho -WhatIf

# 適用（作成・更新。削除はしない）
pwsh -File scripts/sync_labels.ps1 -Repo akaza-lab-org/keikakusho
```

- `gh label create --force` を使うため、既存ラベルは**色・説明が正本に更新される**（色ドリフトの是正もこれで行う）。
- 既定では削除しない。正本にないラベルを消す場合のみ `-Prune`（破壊的・GitHub既定ラベルは保護）。

## リネーム移行（明示実行）

リネームは issue への紐付けを保持するため、create+delete ではなく `gh label edit --name` で行う。`labels.json` の `migrations` に定義し、対象 repo で明示実行する。

**重要:** リネームは通常 sync より先に実行する。通常 sync が target ラベル（例: `safety:patient-data`）を先に作ると、GitHub の in-place rename が衝突して失敗する。`sync_labels.ps1 -ApplyRenames` は rename migration だけを実行して終了するため、次の順で行う。

```powershell
# 1. リネームだけ先に実行（issue 紐付け保持）
pwsh -File scripts/sync_labels.ps1 -Repo akaza-lab-org/DM-kousin -ApplyRenames

# 2. 結果確認後、通常 sync で色・説明・不足ラベルを揃える
pwsh -File scripts/sync_labels.ps1 -Repo akaza-lab-org/DM-kousin
```

rename 先ラベルが既に存在する場合、スクリプトは安全のため rename をスキップして警告する。この場合は旧ラベルが付いた Issue/PR を確認し、手動で新ラベルへ移してから旧ラベルを削除する。

現在の移行対象:

| from | to | repo |
|---|---|---|
| `safety:phi` | `safety:patient-data` | ikensho / keikakusho / DM-kousin / wakumy |
| `in-progress`（prefix欠落の壊れラベル） | `status:in-progress` | kensin |
| `repo:DM-kousin` | `repo:dm-kousin` | DM-kousin |
| `repo:wakumy_apilot` | `repo:wakumy` | wakumy_apilot |
| `architecture` | `type:architecture` | HealthCheck-OS / AHK_setting |

## 既知のドリフト（#140 時点・適用前）

| 症状 | 例 |
|---|---|
| 同色で別意味 | HCOS で `#0e8a16` が ai:codex / status:ready / council:decision など複数に重複 |
| 同名で別色 | `ai:codex` が緑(`#0e8a16`)・青(`#0366d6`)・紫(`#5319e7`) でrepo間不一致 |
| safety 不一致 | HCOS は `safety:patient-data`、新設repoは `safety:phi`（→ patient-data に統合） |
| status 2系統 | HCOS系 `triage→ready→blocked`、skills系 `triage→in-progress→review`（→ 6段階に統一） |
| 壊れラベル | kensin に prefix 欠落の `in-progress`（→ `status:in-progress`） |
| 命名不統一 | `repo:DM-kousin`（大文字）、`repo:wakumy_apilot`（アンダースコア） |

これらは正本適用（sync）＋リネーム移行で解消する。適用は別 Issue で段階実施する（Phase 2）。
