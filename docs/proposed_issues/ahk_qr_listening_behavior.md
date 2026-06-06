Title:
[HCOS Council] AHK QR読み取り動作の規定変更（常時待ち受けの無効化と運用変更）

Body:

## Council Type
Operations | Safety

## Status
council:open

## Participants
- Human CTO
- Antigravity (Reporter)
- Claude (Reviewer)
- Codex (Builder)

## Decision Required
AHKによるQRコード常時待ち受けリスナーのデフォルト設定を「無効」に変更し、パレット等の入力窓へのフォーカスを前提とした運用へ移行するかを決定する。

---

## Goal
- 意図しないキー入力のインターセプト（常時リスナーによる誤作動）のリスクを排除する。
- 「入力窓を選択してからスキャンする」という明示的なワークフローを標準化する。

## Context
現在の `main.ahk` は `InputHook` を用いてバックグラウンドで常にQRパターンを監視しているが、これはキー入力の衝突や誤判定のリスクを伴う。現場運用において、パレット上の「QR入力窓」等にフォーカスを当ててからスキャンする方式の方が、より確実で安全であるとの判断。

## Scope
- `main.ahk` の `StartKenshinQrKeyboardListener` のデフォルト無効化（`config.sample.ini` の更新）。
- パレット（Palette）のQR入力窓、およびホットキー起動（F12プリフィックス）を推奨運用として定義。
- `READ_ME.txt` および `README_トラブルシューティング.txt` の更新。

## Out of Scope
- AHK v1 互換スクリプトの改修。
- Kensinアプリ側のQR解析ロジックの変更（AHK側のみ）。

## Risks / Safety Considerations
- **利便性の低下:** スキャン前の1クリック（または1ホットキー）が必要になる。
- **習熟コスト:** 現場のスタッフに対する運用変更の周知が必要。

## Acceptance Criteria
- [ ] `config.sample.ini` で `KenshinQrKeyboardListener=0` がデフォルトになること。
- [ ] `main.ahk` の起動時ログでリスナーのステータスが正しく表示されること。
- [ ] パレットのQR入力窓によるスキャンが正常に動作し、オーダーダイアログが起動すること。
- [ ] 運用マニュアル（README）が新しい手順を反映していること。

---

## Speaking Protocol
Each AI must respond using:
### Analysis
### Proposal
### Risks
### Decision Suggestion

---

## Lifecycle Rule
- AI cannot finalize decisions.
- Human CTO moves issue to `council:decision`.
