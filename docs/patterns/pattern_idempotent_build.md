# Pattern: Idempotent Portable Build

## Purpose

`build_portable.bat` の再実行時に、ワークスペース汚れ（`__pycache__`, `*.pyc`, lock）や Python 実行中ロックによって失敗ループに入る問題を防ぐ。

目標は「一度失敗しても、条件を満たせば再実行で復旧できる」運用を作ること。

## Context

Kensin の portable build では、以下の要因で失敗が継続することがある。

- 開発実行・テスト実行で生成された Python キャッシュがビルド前検査に引っかかる
- 既存 `python/` 配下が実行中プロセスにロックされ、置換できない
- 失敗条件が曖昧で、復旧手順が運用者に伝わりにくい

## Pattern

### 1. Cleanup default + skip flag

- cleanup はデフォルトで実行する
- 省略時のみ明示フラグを使う（例: `--skip-cleanup`）

これにより、通常運用では「何も考えず実行」で復旧しやすくなる。

### 2. Bytecode isolation

- `PYTHONDONTWRITEBYTECODE=1` を設定
- `PYTHONPYCACHEPREFIX=%TEMP%\\kensin_pycache_%STAMP%` を設定

ビルド中に生成されるキャッシュをソースツリー外へ隔離する。

### 3. Temp extraction + delayed replace

- Python 展開は最終配置 `python/` ではなく一時領域 `PYTHON_TMP_DIR` に実施
- 依存導入・検証も一時領域の Python で行う
- 最後に `python/` を差し替える

これにより、展開工程が既存 `python/` ロックの影響を受けにくくなる。

### 4. Fail-fast on lock at replace point

- 差し替え時に `python/` が残るなら、即エラー終了する
- エラーメッセージで「kensin を停止して再実行」を明示する

## Operational Guidance

- 通常: `build_portable.bat`
- 高速再ビルド（意図的に cleanup 省略）: `build_portable.bat --skip-cleanup`
- 置換失敗時:
  - kensin を停止
  - 端末内の Python 利用プロセスを確認
  - 再実行

## Safety Notes

- 本パターンはビルドスクリプト改善のみを対象とする
- PHI・医療判断・料金ロジック・EMR/AHK 実行フローには触れない
- `data/` `append/` など運用データ領域は削除対象にしない

## Reuse Criteria

以下の条件を満たす配布バッチで再利用可能。

- portable Python を同梱して配布する
- 開発機で zip ビルドを行う
- ローカルキャッシュ汚れやロックがビルド失敗要因になる
