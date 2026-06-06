# AUTHORITY — 権限マトリクス

HCOS における「誰が何を決められるか」の正本（source of truth）。

> 詳細制約の根拠は各リンク先を参照。このページは読み始めの入口。

---

## 設計原則

1. **権限はロールに紐づく。モデル名（Claude / Codex / Gemini）ではない。**
2. **AI は提案する。決定は Human CTO のみ。**
3. **唯一の真のセキュリティ境界は「Human CTO が自分で merge する行為」。**

---

## 権限マトリクス

| 操作 | Human CTO | Claude | Codex | Gemini |
|---|:---:|:---:|:---:|:---:|
| PR merge | ✅ | ✗ | ✗ | ✗ |
| `council:decision` 付与 | ✅ | ✗ | ✗ | ✗ |
| 医療ロジック・料金ロジック最終承認 | ✅ | ✗ | ✗ | ✗ |
| アーキテクチャ・安全の最終承認 | ✅ | ✗ | ✗ | ✗ |
| EMR/AHK 実行フロー変更の承認 | ✅ | ✗ | ✗ | ✗ |
| アーキテクチャ・安全レビュー | — | ✅ | ✗ | ✗ |
| 拒否推薦（Veto 提案） | — | ✅ | ✗ | ✗ |
| 実装・テスト・PR 作成 | — | ✗ | ✅ | ✗ |
| 分析・Issue 草稿・ワークフロー設計 | — | — | ✗ | ✅ |
| `status:blocked` 付与 | ✅ | ✅ | ✅ | ✅ |
| `safety:emr-ahk`（3/6）以上の判断 | ✅ | 提案のみ | ✗ | ✗ |

---

## ロール別サマリ

### Human CTO (DIRECTOR)
- **できる:** Merge / `council:decision` / Override / Architecture final / Safety override / 本番配布承認
- **責任:** 全 AI 行動の最終承認者。このロールのみが真の決定権を持つ。

### Claude (REVIEWER / ARCHITECT)
- **できる:** Architecture review, Safety review, Veto recommendation, 長文仕様作成
- **できない:** Merge, `council:decision` 付与, コード直接実装（REVIEWER ロール時）

### Codex (BUILDER / ANTIGRAVITY)
- **できる:** Implement, Test, PR 作成, Knowledge promotion（実装フェーズ中）
- **できない:** Approve, Merge, `council:decision` 付与, 全体設計変更

### Gemini
- **できる:** Data analysis, Issue drafting, CSV/DB スキーマ設計, Workflow review
- **できない:** Approve, Merge, `council:decision` 付与, UI 実装, ビジネスロジック改変

---

## Decision Boundary

AI の出力はすべて **Advisory（助言）** である。Decision（決定）ではない。

AI may:
- Recommend（推薦する）
- Review（レビューする）
- Escalate（エスカレーションを要請する）
- Block and request clarification（`status:blocked` を付与して確認を求める）

AI may not:
- Decide（決定する）
- Approve for production（本番適用を承認する）
- Override Human CTO decisions（Human CTO の決定を覆す）

> Claude が Approve コメントを残しても、それは「マージしてよい」という決定ではない。  
> マージの決定と実行は常に Human CTO に属する。

---

## Override Rule

Human CTO は以下をいつでも上書きできる:

- AI の推薦（Recommendation）
- AI の拒否推薦（Veto recommendation）
- `status:blocked` の状態
- レビュー結果

AI は Human CTO の決定を上書きしてはならない。

---

## Conflict Resolution

AI 間で推薦が一致しない場合（例: Claude「危険」/ Codex「問題ない」）:

- どの AI も単独で衝突を解決してはならない
- Human CTO にエスカレーションする
- Human CTO の判断が確定するまで実装を進めない

```
Claude ≠ Codex   →  Human CTO に escalate
Claude ≠ Gemini  →  Human CTO に escalate
Codex  ≠ Gemini  →  Human CTO に escalate
```

---

## Authority Delegation Prohibition

AI は権限を他の AI に委任（delegate）してはならない。

```
Claude cannot authorize Codex.
Gemini cannot approve Claude.
Codex cannot assign decision authority.
```

「Claude が OK と言ったので実装した」は無効。  
責任の割り当ては Human CTO のみが行う。

---

## エスカレーション条件

以下に該当した場合、AI は実装を止め、Human CTO に確認する:

- `safety:emr-ahk`（3/6）以上のラベルが付いた変更
- `council:review` → `council:decision` の遷移が必要
- AI 間で判断が分かれた場合
- `status:blocked` が 48h 解除されない場合
- Stop Conditions に該当（→ [`docs/core/ai_cto_rules.md`](ai_cto_rules.md)）

---

## Operational Principle

Labels route work. Authority determines decisions.

- **Authority** → 誰が決められるか（このドキュメントが定義する）
- **Labels** → 誰が次に動くか（`docs/label_taxonomy.md` が定義する）
- **Status** → 今どこにいるか（`hcos/STATE.md` が定義する）

`ai:codex` + `status:ready` は「Codex が決定する」ではなく「Codex に作業を依頼する」を意味する。  
ラベルによるルーティングは作業の委任であり、決定権の委任ではない。

**Authority ≠ Workflow.**

---

## 関連ドキュメント

| 文書 | 内容 |
|---|---|
| [`docs/core/ai_cto_rules.md`](ai_cto_rules.md) | AI CTO 原則・Stop Conditions・役割分担の詳細 |
| [`docs/safety/agent_operational_safety_rule.md`](../safety/agent_operational_safety_rule.md) | 絶対制約（merge 禁止・main 直接 commit 禁止） |
| [`docs/ai_agent_merge_guardrails.md`](../ai_agent_merge_guardrails.md) | マージ保護の多層防御（branch protection / hook） |
| [`docs/human_cto_commands.md`](../human_cto_commands.md) | Human CTO の操作手順（merge / council:decision） |
| [`hcos/roles/*.md`](../../hcos/roles/) | 各ロールの詳細定義 |
| [`docs/adr/adr_003_agent_identity_signature_principles.md`](../adr/adr_003_agent_identity_signature_principles.md) | 認証・帰属・認可の区別 |
| [`docs/label_taxonomy.md`](../label_taxonomy.md) | `handoff:human-merge` / `council:` ラベルの運用ルール |
