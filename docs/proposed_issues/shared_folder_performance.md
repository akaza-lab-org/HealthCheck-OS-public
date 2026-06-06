Title:
[HCOS Council] 共有フォルダ経由での起動遅延の調査と改善方針の策定

Body:

## Council Type
Operations | Architecture

## Status
council:open

## Participants
- Human CTO
- Antigravity (Reporter/Analyzer)
- Claude (Architect)
- Codex (Builder)

## Decision Required
共有フォルダ（SMB/CIFS等）経由でアプリを実行した際の「起動の遅さ」が許容範囲内か、あるいは改善が必要な異常事態かを判断し、必要に応じて技術的な改善策（ローカルキャッシュの利用、配布パッケージの最適化等）を決定する。

---

## Goal
- 共有フォルダ実行環境における起動時間の現状把握と目標値の設定。
- ユーザー体験を損なわない安定した起動プロセスの確立。
- ネットワーク負荷の低減。

## Context
現在、`kensin` アプリおよび `ahk` スクリプトを共有フォルダに配置して実行する運用をテストしているが、起動にかなりの時間を要している。特に Python の仮想環境（venv）や多数の小規模なライブラリファイルをネットワーク越しに読み込む際、SMBプロトコルのオーバーヘッドにより遅延が発生しやすい。

## Scope
- 起動遅延のボトルネック特定（ファイル読み込み、DB接続、AHK初期化等）。
- 「共有フォルダから直接実行」 vs 「共有フォルダからローカルにコピーして実行」の比較検討。
- `run.bat` における起動プロセスの最適化。

## Out of Scope
- ネットワークインフラ自体（ルーターやLANケーブル等）の物理的な改修。
- 電子カルテ（EMR）本体の動作速度改善。

## Risks / Safety Considerations
- **配布ミスのリスク:** ローカルコピー運用に移行する場合、最新版への更新漏れが発生しやすくなる（同期メカニズムが必要）。
- **依存関係の破損:** ネットワーク瞬断時に一部のライブラリが読み込めず、不完全な状態で起動するリスク。

## Acceptance Criteria
- [ ] 共有フォルダ経由での平均起動時間を計測し、レポートすること。
- [ ] 起動時間が目標値（例: 5秒以内）を超えた場合の対策案が提示されていること。
- [ ] 技術的な改善案（例: ローカルキャッシュ、単一実行ファイル化等）が1つ以上合意されていること。

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
