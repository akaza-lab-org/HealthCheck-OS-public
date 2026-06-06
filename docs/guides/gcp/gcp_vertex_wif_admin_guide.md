# Vertex AI + WIF 導入ガイド（法人管理者向け）

## 目的

このガイドは、`HealthCheck-OS` の GitHub Actions から Gemini を呼び出す認証を、API キー方式から **Workload Identity Federation (WIF)** へ移行するための手順書です。

目標:
- 長期 API キーを廃止する
- GitHub OIDC の短命トークンで Google Cloud 認証する
- Vertex AI 呼び出しを安定運用する

---

## 先に決める値（メモして進める）

- `GCP_PROJECT_ID`: 例 `hcos-prod-123456`
- `GCP_PROJECT_NUMBER`: 数値のプロジェクト番号
- `GCP_LOCATION`: 例 `us-central1`
- `GITHUB_OWNER`: `akaza-lab-org`
- `GITHUB_REPO`: `HealthCheck-OS`

---

## 前提条件

### GCP 側
- プロジェクトの IAM 管理権限がある
- Vertex AI API が有効化済み
- `gcloud` CLI が利用できる

### GitHub 側
- リポジトリ管理者権限がある
- Actions が有効

---

## 手順 1: Workload Identity Pool / Provider を作成

```bash
gcloud iam workload-identity-pools create "github-actions" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions OIDC"
```

```bash
gcloud iam workload-identity-pools providers create-oidc "github" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-actions" \
  --display-name="GitHub OIDC Provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner,attribute.ref=assertion.ref,attribute.workflow=assertion.workflow"
```

---

## 手順 2: GitHub Actions 用 Service Account を作成

```bash
gcloud iam service-accounts create "github-actions-sa" \
  --project="${GCP_PROJECT_ID}" \
  --display-name="GitHub Actions Vertex AI"
```

### 最小権限を付与

```bash
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:github-actions-sa@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

必要ならログ書き込みのみ追加:

```bash
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:github-actions-sa@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"
```

---

## 手順 3: GitHub リポジトリだけを信頼許可

```bash
gcloud iam service-accounts add-iam-policy-binding \
  "github-actions-sa@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${GCP_PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-actions/attribute.repository/${GITHUB_OWNER}/${GITHUB_REPO}"
```

---

## 手順 4: GitHub に Secrets / Variables を設定

### Repository Secrets

- `GCP_WORKLOAD_IDENTITY_PROVIDER`  
  例: `projects/123456789/locations/global/workloadIdentityPools/github-actions/providers/github`
- `GCP_SERVICE_ACCOUNT_EMAIL`  
  例: `github-actions-sa@hcos-prod-123456.iam.gserviceaccount.com`

### Repository Variables

- `GCP_PROJECT_ID` 例: `hcos-prod-123456`
- `GCP_LOCATION` 例: `us-central1`
- `VERTEX_MODEL` 例: `gemini-2.5-flash`

---

## 手順 5: 動作確認

1. ワークフロー実行後、`Authenticate to Google Cloud (WIF)` ステップが成功すること
2. Vertex API 呼び出しが 200 応答になること
3. 403 `Resource not accessible by integration` が消えること
4. Cloud Console の Vertex API メトリクスに呼び出しが見えること

---

## 失敗しやすいポイントと対処

### 1) `id-token: write` 未設定

症状:
- `google-github-actions/auth` が OIDC トークン取得に失敗

対処:
- 対象 workflow の `permissions` に `id-token: write` を追加

### 2) Provider 文字列ミス

症状:
- `invalid audience` / `provider not found`

対処:
- `GCP_WORKLOAD_IDENTITY_PROVIDER` を再確認
- `projects/<NUMBER>/locations/global/workloadIdentityPools/<POOL>/providers/<PROVIDER>` 形式であること

### 3) Service Account 信頼設定不足

症状:
- `permission denied` / `workloadIdentityUser` 関連エラー

対処:
- `roles/iam.workloadIdentityUser` バインドを再確認
- `attribute.repository` が `akaza-lab-org/HealthCheck-OS` と一致しているか確認

### 4) Vertex API 未有効

症状:
- `API has not been used or enabled` エラー

対処:
- Vertex AI API を有効化する

---

## セキュリティ運用ルール

- 長期 JSON キーを GitHub Secrets に保存しない
- ロールは `roles/aiplatform.user` を基準に最小化する
- 不要になった API キー（`GEMINI_API_KEY` など）は削除する
- 月次で IAM バインドを棚卸しする

---

## 変更履歴

- 2026-05-06: 初版作成（Issue #36 対応）
