# ADR 003: エージェント識別と署名の原則（Attribution vs Authentication）

## Status

Accepted（原則部分）。

本 ADR は **エージェント識別に関する共通認識・原則** を確定する。
署名プロトコルの具体実装（AGENT_ID 書式・必須ヘッダー/フッター・パーサ等、Council Issue #138）は **未決定** であり、本 ADR の原則に従う形で別途判断する。

由来: Council Issue #138（`council:open`）。Human CTO・Claude・Codex・Gemini の議論を経て合意。

## Context

HCOS では現在、GitHub 上のすべての操作（push / PR / コメント / レビュー）が **単一の Human CTO 認証情報（`akazatmd-ctrl`）** で実行される。このため GitHub の actor identity では、Claude / Codex / Gemini を区別できない。

Issue #138 は「どのAIがその作業を行ったか」を判別可能にする署名プロトコルを提案した。検討の過程で、識別を語る際に混同されがちな **3つの層** を分離する必要が明らかになった。

| 層 | 意味 | 単一 credential 下で可能か |
|---|---|---|
| **Authentication（認証）** | 本当に本人か、を証明する | ❌ 不可能 |
| **Attribution（帰属）** | 誰がやったか、を記録する | ⭕ 可能（協力前提） |
| **Authorization（権限）** | 何をしてよいか、を決める | ⭕ ただし別の仕組みで担保する |

重要な事実として、現行の `HCOS PR Policy` merge gate は既に **自己申告ベース** で動作している。承認判定は次のロジックを含む。

```javascript
(/claude/i.test(review.user.login) || /PR Review:\s*Approve/i.test(review.body))
```

`||` により、**本文に `PR Review: Approve` と書けば actor が誰であっても gate を通過する**。つまり「署名による承認」は HCOS に既に非公式に存在しており、#138 はそれを明文化する性質を持つ。明文化は、自己申告に過度な意味（=セキュリティ的信頼）を持たせる危険を伴う。

## Decision

以下を、Human CTO と全AIエージェントの **拘束的な共通認識** とする。

1. **署名は Attribution であり、Authentication ではない。**
   コメント/PR に付す AGENT_ID 署名は、メールの `From:` 行と同じ性質を持つ。人間可読で便利だが、**誰でも詐称でき、忘れられうる**。署名の存在は「本人である証明」には一切ならない。

2. **署名を Authorization（権限）の根拠にしてはならない。**
   署名・本文テキストの一致のみで、merge・デプロイ・破壊的変更・`council:decision` 遷移などの権限を解錠してはならない。自己申告テキストが権限を解錠する設計は、詐称による権限昇格の穴になる。

3. **唯一の本物のセキュリティ境界は「Human CTO が自分で merge する行為」である。**
   GitHub が認証できる事実は「`akazatmd-ctrl` が操作した」のみ。その下で特定AIに帰属させる情報はすべて自己申告。したがって、最終的な信頼の拠り所は、Human CTO が PR を読み、レビューの真正性を自ら判断し、自ら merge する行為に置く。これは既存ルール「**merge は Human CTO のみ・例外なし**」（`docs/human_cto_commands.md`）と一致する。

4. **署名は Human CTO の判断を助ける監査ログである。**
   署名の価値は「誰が何を提案したか」を人間可読の記録として残すこと。判断の代替ではなく、判断の材料。詐称されても、原則 3 により安全は保たれる（詐称しても merge できない）。

5. **将来の認証化（GitHub App / 専用アカウント）への道を閉じない。**
   署名プロトコルを導入する場合も、後から各AIに専用 identity を与えて actor を本物にできる構造を保つ。その際も署名は人間可読ログとして併存しうる。

## Consequences

- 署名プロトコル（#138）を実装する場合、ドキュメントに **「署名は認証ではない／権限の根拠にしない」** と明記することが必須要件になる。
- 現行 merge gate のテキストベース承認判定は、**advisory readiness signal（merge 準備完了の助言的シグナル）** と位置づけ直す。真の承認は Human CTO の merge 行為である、という理解を共有する。
- 全AIは、自分の署名が「自分を証明するもの」ではないと理解した上で運用する。署名の有無で他者の権限主張を信用してはならない。
- セキュリティを署名に依存させないため、`safety:*` に関わる判断は引き続き Human CTO に escalate する。

## Alternatives Considered

識別の「堅さ」には段階がある。本 ADR は原則の確定にとどめ、どの段階を採るかは #138 で別途判断する。

1. **純粋な自己署名**（Gemini 初期案）— モデルが自分で AGENT_ID を打つ。完全に詐称可能・打ち忘れ可能。Attribution として最低限。
2. **ツール注入署名** — 端末別 `config.ini` / 環境変数から `gh` ラッパーや git hook が AGENT_ID を自動付与。「honest by default（黙っていても正しく記録される）」。HCOS の端末別 config 文化と相性が良いが、本質は依然 Attribution。
3. **AIごとの token / account** — GitHub actor が本物になり Authentication が成立。運用・コスト負担増。
4. **GitHub App** — 最もクリーンで scoped。将来の理想形。

いずれを採っても原則 1〜5 は不変であり、特に **2〜4 でも「署名/identity を Human CTO merge の代替にしない」点は維持する**。

## References

- Council Issue #138: Agent Identity and Signature Protocol
- `docs/human_cto_commands.md` — merge は Human CTO のみ・例外なし
- `docs/patterns/pattern_chat_first_hcos_decision.md` — chat-first 決定の記録手順
- `docs/safety/agent_operational_safety_rule.md`
