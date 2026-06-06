# Pattern: GCP Portable Key Management (Per-App)

## Purpose

院内ポータブルアプリで GCP (Vertex AI) を安全に利用するために、JSON キーの保存場所と起動時注入方法を統一する。

## Context

- 対象: 院内で配布する Python/バッチ起動アプリ
- 前提: アプリごとにサービスアカウントを分離
- 要件: 端末セットアップを最小化し、配布 ZIP に秘密情報を含めない

## Decision

- 鍵ファイル保存先は B案を採用:
  - `%USERPROFILE%\.config\gcp\<appname>_key.json`
- アプリ起動時に `run.bat` / `start.bat` で環境変数を設定:
  - `set GOOGLE_APPLICATION_CREDENTIALS=%USERPROFILE%\.config\gcp\<appname>_key.json`

## Why

- Windows ユーザープロファイル配下で、端末ごとの秘密情報を分離できる
- 配布フォルダ（USB/ZIP）に鍵が混入しない
- 既存運用と互換性が高く、移行コストが低い

## Implementation Checklist

1. GCP でアプリ専用 SA を作成する
2. `roles/aiplatform.user` を付与する
3. JSON キーを発行する
4. `%USERPROFILE%\.config\gcp\` へ保存する
5. `run.bat` または `start.bat` に `GOOGLE_APPLICATION_CREDENTIALS` を設定する
6. `PERMISSION_DENIED` と `File not found` を最初に確認する

## Security Rules

- キーファイルを Git 管理に含めない
- メール/チャット/GitHub に貼り付けない
- 退職者・不要 SA はキーをローテーションまたは無効化する
- 過剰権限（例: `roles/aiplatform.admin`）を避け、最小権限を守る

## Non-Goals

- EMR/AHK 実行フローの変更
- 医療判断ロジックの変更
- 本番配布承認フローの代替
