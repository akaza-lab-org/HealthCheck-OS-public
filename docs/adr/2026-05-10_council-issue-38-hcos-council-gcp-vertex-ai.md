# HCOS Council Decision Memory

Date: 2026-05-10
Issue: #38
Title: [HCOS Council] 院内ツールにおける法人GCP/Vertex AI認証の標準化と管理者向け導入ガイドの策定
URL: https://github.com/akaza-lab-org/HealthCheck-OS/issues/38

## Context
## Council Type
Architecture / Safety

## Status
council:open

## Participants
- Human CTO
- Claude (セキュリティ・設計レビュー)
- Codex (実装標準化)
- Antigravity (現状分析・ドキュメント作成)

## Decision Required
1.  **JSON キー管理の標準化**: 院内 PC で複数のスタッフが利用する際、JSON キーをどこに、どのように安全に配置すべきか（例：環境変数、暗号化設定ファイル、または特定ユーザーのみアクセス可能なフォルダ）。
2.  **法人管理者向け「疎通確認済」ガイドの完成**: GCP 側の設定（プロジェクト作成、サービスアカウント、IAM、API有効化）を、専門外の管理者でも迷わず実行できる手順書。
3.  **複数アプリへの横断適用**: `summarymaker` を含む各アプリで、認証情報を共通の形式（例：`GOOGLE_APPLICATION_CREDENTIALS` 等）で読み込むための実装パターンの統一。

## Goal
法人の IT 管理者に「この通りに設定してください」と渡すだけで、安全かつ確実に院内ツールが法人 GCP 権限で稼働する状態を作る。

## Context
現在は個人アカウントの Vertex AI を利用しているが、組織のガバナンスと継続性の観点から法人アカウントへの移行が急務。過去に設定の複雑さから移行が頓挫した経緯があるため、再現性の高いガイドが必要。

---
## Next Actions
- [ ] 法人管理者向け「GCP プロジェクト初期設定ガイド」のドラフト作成
- [ ] 既存アプリ（summarymaker 等）の認証読み込みロジックの調査
- [ ] 安全な JSON キー保管場所のベストプラクティス選定

## Final Decision Signal
Author: @human-cto

GCP 認証標準化ガイドは PR #81 でマージ済み（gcp_per_app_sa_setup_guide.md / pattern_gcp_portable_key.md）。Council 決定事項の実装完了につき archived として close。

## Council Transcript Index
1. @github-actions[bot] (2026-05-06T21:58:07Z)
2. @human-cto (2026-05-10T10:46:39Z)
3. @human-cto (2026-05-10T10:49:05Z)
4. @human-cto (2026-05-10T11:17:10Z)
5. @human-cto (2026-05-10T13:40:44Z)
