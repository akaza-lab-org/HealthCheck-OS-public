# HealthCheck-OS (HCOS) 開発基盤アーキテクチャ

HCOS（HealthCheck-OS）リポジトリは、単なるアプリケーションのソースコード置き場ではありません。**「複数のAIエージェント（Codex, Claude, Gemini）と人間（Human CTO）が協働し、医療現場向けの自動化システムを安全かつ継続的に進化させるためのメタフレームワーク（開発基盤）」**です。

本ドキュメントでは、HCOSの開発プロセスを支える全体的な仕組みを俯瞰して解説します。

---

## 1. コアコンセプト：「コードは消え、知識は蓄積する」

HCOSにおける開発の最重要原則は **"Code disappears. Knowledge accumulates. PRs are temporary. Docs are permanent."** です。

機能実装やバグ修正のコード（PR）は一時的なものとして扱われ、そのプロセスで得られた「設計の意図」「安全性のルール」「汎用的な実装パターン」を**永続的な知識（ドキュメント）としてリポジトリに定着させること**をシステム全体で強制・自動化しています。

---

## 2. コアメカニズム（4つの柱）

HCOSの自律的な開発サイクルは、以下の4つの高度に自動化された仕組みによって支えられています。

### ① PR Orchestration（PR主導の開発と安全保障）
AI（Codex等）による `main` ブランチへの直接コミットは固く禁じられています。
すべての実装は必ずIssueを起点とし、Featureブランチを切ってPRとして提出されます。
*   **Gatekeeper:** GitHub Actions（`HCOS PR Policy` 等）が、自動テストの通過、Claudeによるアーキテクチャ＆安全性のレビュー承認をマージの必須条件として強制します。
*   **Triage:** 提出されたPRには自動で適切なラベルが貼られ、レビュー待ち状態に移行します。

### ② Knowledge Promotion（知識の自動昇華とトラッキング）
PRで作成された新しい知識（ドキュメント）を自動的に検出し、リリースノート（`CHANGELOG.md`）へ刻み込みます。
*   **対象:** `docs/patterns/pattern_*.md`（実装パターン）, `docs/adr_*.md`（設計上の意思決定）, `docs/safety_*.md`（安全性ルール）
*   **自動化:** PRマージ直後に GitHub Action (`HCOS Knowledge Promotion`) が走り、追加されたこれらのファイルを検知して `CHANGELOG.md` を自動更新します。

### ③ Decision Memory（思考プロセス・WHYの継承）
コードレビューやIssueのやり取りの中で交わされた「なぜその実装にしたのか（WHY）」という背景情報を、AIが自動で構造化して記録する仕組みです。
*   **自動生成:** PRマージ時に GitHub Action (`HCOS Decision Memory`) が起動し、関連IssueのコメントやPRのレビュー内容を抽出。
*   **要約:** ローカルのGemini APIモジュールを通じて「採用された設計、却下された代替案、安全性の考慮事項」などを抽出し、`docs/adr/` ディレクトリにMarkdownとして自動コミットします（個人情報やシークレットは自動除外されます）。

### ④ Mobile Context Sync（モバイルAI・外部Gemへの前提同期）
HCOSのルールや方針（`AGENTS.md`）は日々進化します。この最新の前提知識を、外出先やスマートフォンから指示を出すためのAI（Gem等）にも常に同期させる仕組みです。
*   **動的同期:** `AGENTS.md` に更新（Push）があった際、GitHub Action (`HCOS Mobile Context Sync`) が起動。
*   **再生成:** Gemini APIを用いて、Gemのインストラクションに最適な形式である `docs/mobile_ai_context.md` を構造を保ったまま自動再生成し、`main` にコミットします。さらにIssueを通じて人間へ同期を促します。

---

## 3. アクターの役割分担

HCOSでは、それぞれの得意分野に合わせてAIと人間の役割が明確に定義されています。

| アクター | ツール / モデル | 主な役割 |
| :--- | :--- | :--- |
| **Implementer** | Codex (Cursor, VS Code) | Issueの意図を汲み取り、設計・実装を行う。関連する知識ドキュメント（Pattern, ADR）を執筆し、PRを提出する。 |
| **Reviewer** | Claude (GitHub Actions) | 提出されたPRに対し、アーキテクチャの妥当性や医療安全リスク（PHI漏洩、破壊的変更）がないかを自動レビューする。 |
| **Librarian** | Gemini (Post-merge Actions) | マージ後の「意思決定の要約（Decision Memory）」や「外部AI向けコンテキストの同期（Mobile Context Sync）」といった高度なテキスト処理をバックグラウンドで担う。 |
| **Director** | Human CTO (人間) | 最終的な意思決定、医療ロジックの承認、PRのMergeボタンの押下、およびAIが対応できない物理的・運用的な判断を行う。 |

---

## 4. 開発のライフサイクル

ある新機能を実装する場合の流れは以下のようになります。

1. **Intent (意図の発生):** Human CTO または AI が Issue を立てる。
2. **Context (前提の確認):** Codexは `AGENTS.md` や `docs/` 内のPattern/ADRを読み、過去の意思決定（Decision Memory）を踏まえて方針を立てる。
3. **Execution (実装):** CodexがFeatureブランチを作成して実装。必要に応じて新しい `pattern_*.md` などを記述し、PRを作成する。
4. **Validation (検証):** CI（PR Policy）が作動し、テストとClaudeの承認を待つ。
5. **Approval & Merge (承認):** Human CTOがマージを実行。
6. **Integration (知識の定着):** マージ後、Geminiが自動で `CHANGELOG.md` を更新し、Decision Memoryを生成し、必要ならモバイル用コンテキストを同期する。

---

## 5. まとめ

HCOSのリポジトリは、単にアプリを動かすためだけでなく、**「AI同士が協働し、過去の失敗や設計意図を自ら学習・参照しながら安全に開発を進めるためのエコシステム」**として機能しています。
属人化を徹底的に排除し、すべての判断基準や仕様を「機械可読な知識（Knowledge）」として循環させることが、HCOSアーキテクチャの最大の目的です。
