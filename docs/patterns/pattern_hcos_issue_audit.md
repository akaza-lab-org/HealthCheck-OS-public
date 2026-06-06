# Pattern: HCOS Issue バックログ定期監査

## 問題

HCOS は hcos/ ディレクトリ・docs/・AGENTS.md を段階的に整備してきた。
初期に提案された Issue がその後の実装で実質的に完了していても、open のまま残ることがある。
放置すると Codex が重複実装を試みたり、Human CTO が処理済み事項を再検討したりするコストが発生する。

## 解決策

月1回程度、オープン Issue を現在の実装状態と照合し、実装済み・重複・superseded のものをクローズする。

## 監査手順

### 1. オープン Issue 一覧を取得

```bash
gh issue list --repo akaza-lab-org/HealthCheck-OS --state open --limit 50
```

### 2. 各 Issue を以下の順で照合

| 確認先 | 確認内容 |
|---|---|
| `hcos/STATE.md` | 現フェーズ・アクティブ Issue と矛盾しないか |
| `hcos/RULES.md` | Issue が提案するルールが既に明文化されていないか |
| `hcos/BOOT.md` | BOOT プロトコル系の提案が既に実装されていないか |
| `AGENTS.md` | Read First リスト・Agent Rules・PR Workflow と重複しないか |
| `docs/pattern_*.md` | 実装パターンとして既に文書化されていないか |
| `docs/adr_*.md` | 設計決定として既に記録されていないか |
| `docs/safety/` | 安全規則として既に定義されていないか |

### 3. 判定基準

| 判定 | 条件 | 対応 |
|---|---|---|
| **実装済み** | Issue が提案する機能が既にリポジトリ内で稼働している | close + コメントで対応箇所を明示 |
| **重複** | 別 Issue または PR で同内容が扱われている | close + 重複先 Issue/PR 番号を明示 |
| **superseded** | 設計方針が変わり、Issue の前提が無効になった | close + 理由を記録 |
| **スコープ外確定** | Human CTO が実装しないと決定した | close + 決定を記録 |
| **有効** | 上記に当てはまらず、今後対応が必要 | ラベルを整理して継続 |

### 4. クローズコメントの書き方

```
<実装済み / 重複 / superseded> のため close。

対応箇所:
- <ファイルまたは Issue/PR へのリンク>

理由: <1〜2文で説明>
```

## 実施タイミング

- 月1回の定期監査（目安: 月初）
- 大きな機能追加・設計変更の直後
- AGENTS.md の大幅更新後

## 注意

- クローズは「削除」ではなく「記録」。理由を必ずコメントに残す。
- `status:blocked` の Issue は Human CTO の判断が必要なものが多いため、監査対象から外して別途確認する。
- council Issue（`council:open` 等）はライフサイクルが別管理のため、この手順の対象外。

## 関連

- `hcos/RULES.md`
- `hcos/STATE.md`
- `docs/human_cto_commands.md` — Issue 承認・アンブロック手順
