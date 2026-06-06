# ADR-001: pdf_digitizer の役割を Phase 1-2 座標抽出に限定する

## Status

Decided — 2026-05-10

## Context

pdf_digitizer は Phase 1（PDF解析）・Phase 2（座標エディタ）・Phase 3（OCR + 値エディタ）の3フェーズで構成されている。

kensin の帳票生成（がん検診一覧表・個人票・結果票）に pdf_digitizer を活用する際、どこまでを pdf_digitizer で行い、どこから kensin で行うかを決める必要があった。

主な検討要素:

- Phase 3 は UI の完成度が低く、非エンジニアが単独で操作するには困難な状態
- 患者データは kensin DB にある。pdf_digitizer にデータを渡す経路を作ると PHI リスクが増える
- kensin はすでに fitz (PyMuPDF) を使った PDF Overlay の実装パターンを持っている（`cancer_registry.py`）
- 帳票フォーマットの種類は限られており、座標は1形式につき1回のセットアップで済む

## Decision

**pdf_digitizer は Phase 1-2（座標抽出専用）として使用する。PDF 生成は kensin 側で完結させる。**

```
pdf_digitizer (Phase 1-2 のみ)
  入力: 白紙テンプレート PDF
  処理: フィールド定義・座標チューニング
  出力: 座標 JSON → kensin/data/pdf_coords/<form_name>.json
  頻度: 1帳票につき1回限りのセットアップ

kensin (PDF 生成)
  入力: 座標 JSON + DB の患者データ・検査結果
  処理: fitz Overlay
  出力: 印刷用 PDF
  頻度: 受診者ごとに都度生成
```

## 座標 JSON 標準フォーマット

`kensin/data/pdf_coords/<form_name>.json` に配置する。

```json
{
  "template": "<form_name>",
  "template_img_w": 1755.0,
  "template_img_h": 1234.0,
  "fields": [
    {
      "name": "<field_name>",
      "label": "<表示名>",
      "x0": 123, "y0": 228, "x1": 219, "y1": 285,
      "fontsize": 12,
      "align": "center"
    }
  ]
}
```

## Consequences

**メリット:**

- PHI が kensin DB の外に出ない
- Phase 3 の未完成部分を使わずに済む
- kensin の既存 overlay パターン（`cancer_registry.py`）を再利用できる
- 座標変更は JSON の編集だけで済み、コードを触らなくてよい
- 帳票追加のたびに pdf_digitizer での座標抽出 → JSON 配置の手順が標準化される

**トレードオフ:**

- Phase 2 出力（`edited_fields.xlsx`）を座標 JSON に変換するステップが必要（手動 or エクスポート機能追加）
- pdf_digitizer Phase 3 は kensin 用途では使わないが、他用途（summarymaker 等）では引き続き有効

## 対象帳票（2026年度）

| 帳票 | JSON ファイル名 |
|---|---|
| がん検診一覧表（WS000023） | `cancer_registry.json` |
| 肺がん・大腸がん個人票 | `cancer_individual_result.json` |
| 肺がん・大腸がん結果票 | `cancer_result_slip.json` |

## 関連

- Issue #78: PDF フォーム生成エンジンの標準化と専門ロール 'DESIGNER' の設計
- `docs/pattern_gcp_portable_key.md`: ポータブルアプリの認証パターン（同様の関心分離の先例）
