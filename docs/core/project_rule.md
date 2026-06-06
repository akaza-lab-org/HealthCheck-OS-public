# Project Rule

## Purpose

健診業務・医療業務の自動化とAI化を、医療安全を最優先に進める。

## Principles

- 医療安全を最優先にする
- 手動介入可能性を必ず残す
- ブラックボックス化を避ける
- 患者情報・実データ・端末固有秘密をGitHubへ入れない
- 実装判断、検証結果、運用上の注意はGitHubに残す

## Development Rules

- 作業は原則 GitHub Issue 経由で行う
- Notionは企画・俯瞰・議事録・非エンジニア向け説明に使う
- 仕様確定が必要な大きな変更は、Issueまたはdocsで合意内容を明文化する
- 医療判断ロジック、料金ロジック、EMR/AHK実行フローは単独AI判断で変更しない
- `kensin` と `AHK_setting` の連携では、`kensin` を業務状態の正、AHKを実行手段として扱う
- 完了した検証済み作業は、適切な区切りでcommitし、原則remoteへpushする
- push前に `git status` を確認し、端末固有設定・患者情報・無関係なローカル変更を含めない

## Agent Collaboration

- Claude: 設計・レビュー
- Codex: 実装・検証
- Gemini: データ・業務フロー

1つのAIだけで大きな仕様変更を完結させない。実装が終わったら、重要な学びをdocsまたはADRへ昇格する。
