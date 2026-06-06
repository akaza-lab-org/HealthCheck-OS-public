# [ABSOLUTE CONSTRAINT] Agent Operational Safety Rule

このドキュメントは、HCOS Knowledge OS における AI エージェント（Codex, Claude, Gemini, Antigravity等）の運用安全性を定義する Tier 2 (Safety) ルールである。すべてのエージェントはこの制約を最優先で遵守しなければならない。

## 1. マージおよびメインブランチ操作の禁止

[ABSOLUTE CONSTRAINT]
すべての AI エージェントは、いかなる理由があっても以下の操作を禁止する。

- `main` ブランチ（または保護されたベースブランチ）への直接コミット (`git push origin main`)。
- `git merge`, `git rebase` による `main` ブランチの破壊的な更新（ローカルでの `main` 同期を除く）。
- GitHub CLI (`gh pr merge`) または GitHub UI を使用したプルリクエストのマージ。
- マージ権限は **Human CTO** のみが保持し、実行する。

## 2. 役割の完全隔離 (Role Isolation)

[ABSOLUTE CONSTRAINT]
各エージェントは、定義された役割を超えたツール使用および操作を禁止する。

- **設計・レビュー担当 (例: Claude)**:
  - 成果物としてのソースコードの直接編集（ファイル作成・上書き・部分置換・一括置換など、任意の書き込み系ツールの使用）を禁止する。
  - 実装の提案は Markdown や Issue コメント、あるいは PR のコードレビューコメントを通じて行う。
- **実装担当 (例: Codex, Antigravity)**:
  - 必ず `feature/<issue-number>-<name>` ブランチを作成し、PR を通じて変更を提案しなければならない。
  - 承認された Issue の範囲外のコード変更を禁止する。
- **Antigravity**:
  - IDE / agentic coding environment として、Codex と同じく実装支援エージェントに分類する。
  - ファイル編集・コマンド実行・PR 作成などの実装操作は、承認された Issue と feature ブランチの範囲内に限定する。
  - `main` への直接反映、PR のマージ、レビューゲートの無効化、または Human CTO の承認を代替する判断を禁止する。

## 3. ワークフロー・バイパスの禁止

[ABSOLUTE CONSTRAINT]
- PR を作成せずに `main` ブランチに影響を与える操作を試みてはならない。
- `hcos_pr_policy` (PR Gate) などの自動検証をバイパスするような設定変更やコミットを禁止する。

## 4. 違反時の挙動

[ABSOLUTE CONSTRAINT]
エージェントが上記制約に抵触する可能性があると判断した場合、直ちに操作を中断し、Human CTO に指示を仰がなければならない。
