# アプリごとの GCP サービスアカウント作成ガイド（法人 IT 担当者向け）

## 0. はじめに

このガイドで作るもの:
- アプリごとの「AI 利用専用アカウント（サービスアカウント）」
- 各アプリで使う「鍵ファイル（JSON）」

必要なもの:
- GCP プロジェクト管理権限のある Google アカウント

---

## 1. GCP Console へのログインとプロジェクト選択

1. `https://console.cloud.google.com/` を開く
2. 画面上部のプロジェクト選択ドロップダウンで対象プロジェクトを選ぶ

注意:
- 正しいプロジェクトが選択されているか、作業前に必ず確認してください

---

## 2. サービスアカウントの作成（アプリごとに繰り返す）

ナビゲーション手順:
1. 左上ハンバーガーメニュー -> `IAM と管理` -> `サービス アカウント`
2. 画面上部の `+ サービス アカウントを作成` をクリック
3. 入力例:
   - サービスアカウント名: `summarymaker-vertex-sa`
   - サービスアカウント ID: 自動入力される内容を確認
   - 説明（任意）: `summarymaker 用 Vertex AI アクセス`
4. `作成して続行` をクリック

補足:
- 画面上部の検索窓に「サービスアカウント」と入力して到達してもよい

---

## 3. IAM ロール（権限）の付与

この手順は最重要です。設定が不足すると AI 呼び出しが失敗します。

### 方法 A（推奨）: SA 作成フロー内で設定

1. SA 作成の Step 2 画面で「このサービス アカウントにプロジェクトへのアクセスを許可する」を開く
2. `ロールを選択` をクリック
3. 検索欄に `Vertex AI ユーザー` と入力
4. `Vertex AI ユーザー (roles/aiplatform.user)` を選択
5. `続行` -> `完了`

### 方法 B: SA 作成後に IAM 画面で設定

1. `IAM と管理` -> `IAM` を開く
2. `アクセスを許可` をクリック
3. `新しいプリンシパル` に SA メールを入力
4. `ロールを選択` で `Vertex AI ユーザー` を選択
5. `保存`

よくある失敗:
- `Vertex AI 管理者` を選ぶ（過剰権限）
- ロール未選択のまま完了する
- 別プロジェクト上で作業してしまう

---

## 4. JSON キー（鍵ファイル）の発行

1. `サービス アカウント` 画面で対象 SA のメールをクリック
2. `キー` タブを選択
3. `鍵を追加` -> `新しい鍵を作成`
4. キータイプが `JSON` であることを確認
5. `作成` をクリックしてダウンロード

注意:
- この JSON は非常に重要な秘密情報です。メール・チャット送信は禁止

---

## 5. 院内 PC へのキー配置（B案標準）

配置先:

```text
C:\Users\<ユーザー名>\.config\gcp\summarymaker_key.json
```

手順:
1. エクスプローラーのアドレスバーに `%USERPROFILE%\.config\gcp` を入力して Enter
2. フォルダがない場合は作成
3. ダウンロードした JSON をコピーし、アプリ名が分かる名前に変更
   - 例: `summarymaker_key.json`

---

## 6. アプリへの設定（開発担当者向け）

`run.bat` または `start.bat` の Python 起動行より前に、次を設定:

```batch
set GOOGLE_APPLICATION_CREDENTIALS=%USERPROFILE%\.config\gcp\summarymaker_key.json
```

---

## 7. 動作確認

1. アプリを起動
2. Gemini / Vertex AI の呼び出しが成功することを確認

エラー時の確認:
- `PERMISSION_DENIED`: 手順 3 の IAM ロールを再確認
- `File not found`: JSON パスとファイル名を再確認

---

## 8. アプリごとの SA 管理台帳

| アプリ | SA 名 | キーファイル名 | 備考 |
| --- | --- | --- | --- |
| summarymaker | `summarymaker-vertex-sa` | `summarymaker_key.json` | 医療情報あり |
| ikensho | `ikensho-vertex-sa` | `ikensho_key.json` | 医療情報あり |
| pdf_digitizer | `pdf-digitizer-vertex-sa` | `pdf_digitizer_key.json` | マスク処理後 |
| kensin | `kensin-vertex-sa` | `kensin_key.json` | 将来実装 |

---

## 安全上の注意

- JSON キーファイルをメール・Slack・GitHub に貼らない
- アプリフォルダ内（ZIP 配布対象）に置かない
- 退職者が利用した SA は速やかにキーを無効化する

## スコープ外

- EMR/AHK 変更なし
- 患者情報を含まない
- 本番配布手続きは別途
