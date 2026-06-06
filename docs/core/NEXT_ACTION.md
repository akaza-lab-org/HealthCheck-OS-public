# NEXT_ACTION — 経営方針ダッシュボード

> **AI 起動時の優先度指針。Human CTO が週次で更新する。AI は読むだけ。**
>
> 「誰が決めるか」→ `docs/core/AUTHORITY.md`  
> 「各リポジトリの基本情報」→ `docs/repo_catalog.md`  
> 「今どこに力を使うか」→ このファイル

Last Updated: 2026-06-01

---

## Current Mission

1. **kensin 特定健診の本番運用を安定させる**（最優先）
2. **R8 療養計画書を全診察室で安定稼働させる**
3. kensin / keikakusho / AHK の個別チューニングを粛々と進める

新規プロジェクト立ち上げ・repo 増設は優先度が低い。

---

## Project Priority

### P1 — 特定健診本番スタート

**Repos:** `kensin`

**Mode:** active（本番運用中）

**Current Focus:**

- 処置室・医師エディタ・印刷・保存が本番環境で正常に動作すること
- 肺がん検診 2 次読影（約 2 週間後〜）の準備
  - がん検診名簿の本番作成
  - 番号管理・印刷の動作確認
  - 所見入力の円滑な動作確認
- 便潜血 仕様最終決定
  - 電子カルテから直接取得（見込み）→ データ書式確定次第、取り込みロジックに反映
  - オプション: 個別入力（OCR または手入力）の入力欄動作確認
  - OCR 環境最終確認（エンジン導入方法・セットアップガイドの補強）

**Open Risks:**

- 健診本番運用中のバグは即時対応が必要
- 便潜血データ書式が未確定のため取り込みロジックが未着手
- OCR エンジンのセットアップ手順が未整備

**Note:** 予約機能は現状正常動作中。

---

### P2 — R8 療養計画書の運用開始

**Repos:** `keikakusho`, `AHK_setting`

**Mode:** active（運用開始フェーズ）

**Current Focus:**

- (1) **新規作成** — 全診察室で円滑に動作すること
  - AHK および VBA の動作確認
  - 各端末の初期設定
- (2) **更新作成** — 円滑に動作すること
- (3) **未確認・今後の課題** — 更新 2 回目（R8 書式で作成済み → 4 か月後にさらに更新）が正常に行えること

**Options（優先度低）:**

- op1: 作成速度のチューニング
- op2: 起動方法の検討（Word リボン / ホットキー / Stream Deck / AHK ランチャ）

**Open Risks:**

- 更新 2 回目（R8 → R8）の動作は未検証

---

### P3 — AHK チューニング

**Repos:** `AHK_setting`

**Mode:** maintenance

**Current Focus:**

- クリック失敗・動作速度向上のためのチューニング
- ログ解析
- マウス用ランチャーの新作

---

### P4 — 糖尿病専門医更新用 症例まとめ作成

**Repos:** `DM-kousin`, `summarymaker`

**Mode:** paused → 再開

**Current Focus:**

- DM-kousin の作成再開
- summarymaker を補助ツールとして連携
- それぞれの機能改修と連携確認

**Resume Condition:** P1（kensin）が安定後に本格化

---

## Human CTO Bottlenecks

_（確認待ち事項が発生したらここに追記する）_

---

## AI Guidance

判断に迷ったときの行動指針:

1. P1（kensin 本番）関連の Issue を最優先で読む
2. 次に P2（R8 計画書）の Issue を確認する
3. 上記の優先順に従って着手する
4. **新規アーキテクチャ作業は Human CTO の承認なしに開始しない**
5. 判断に迷ったら、まず Issue または PR にコメントで確認事項を書く
6. Human CTO の判断を待たないと作業が進められない場合のみ `status:blocked` を付ける

---

## Not Doing

現在着手しない:

- 新規大型リファクタリング
- 新規サービス・repo の立ち上げ
- P4（DM-kousin）の本格着手（P1 安定後）
