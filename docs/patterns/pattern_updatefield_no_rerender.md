# Pattern: updateField は再描画しない

## 概要

医師エディタの `updateField()` は、フィールド値をサーバーに永続化し、
楽観ロックトークン（`updated_at`）を同期する責務のみを持つ。
DOM の再描画（`renderEditor` / `renderAlertPane`）は行わない。

## 背景・理由

`updateField` は各入力フィールドの `onchange` で即時発火する。
連続入力（例: 身長 → Tab → 体重）中に成功後の `apiGet` + `renderEditor` を
呼ぶと次の 2 つの問題が起きる。

1. **入力中 DOM の上書き** — 再描画でフォームが初期化され、入力中の値が吹き飛ぶ。
2. **saveDiagnosis との updated_at 競合** — `updateField` 完了直後に `saveDiagnosis`
   が発火しても `expected_updated_at` が再描画前の古い値を参照し、stale 409 を返す。

## ルール

```
updateField の責務
  ✅ apiPost('/doctor/api/update_field', ...) でフィールドを保存
  ✅ currentExamData.updated_at をレスポンスから更新
  ❌ apiGet でデータを再取得しない
  ❌ renderEditor / renderAlertPane を呼ばない

renderEditor を呼ぶべきタイミング
  ✅ selectExam（患者選択時）
  ✅ registerDiagnosis（登録ボタン押下後）
  ✅ refreshDoctorView（上部「更新」ボタン）
  ✅ stale 発生後のリカバリで明示的に必要な場合のみ
```

## stale リトライ時の扱い

stale リトライ（`refreshSelectedExam({ render: false })` → `apiPost` 再試行）が
成功した場合も、再描画は行わない。
次の `saveDiagnosis` や `registerDiagnosis` が正しい `updated_at` で呼ばれることで
整合性が保たれる。

## 関連 Issue / PR

- Issue #14: 医師エディタ stale UX 補強（根本調査）
- Issue #20: updateField 不要再描画削除（本パターン確立）
- PR #21: 実装（`+2/-8` 行、`doctor.js` のみ）

## 適用リポジトリ

- `clinic-app` — `app/static/js/doctor.js`

## 更新日

2026-05-05
