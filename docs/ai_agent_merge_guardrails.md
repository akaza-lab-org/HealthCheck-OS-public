# AI Agent Merge Guardrails

AI agent は設計、実装、レビュー、Approve までを支援できますが、`main`/`master` への反映は Human CTO の操作だけで行います。

この文書は、Antigravity / Codex / Claude などの agent が誤って直 push や merge を実行しないためのガードを、GitHub Free で使える範囲を中心に定義します。

## Why This Happens

Antigravity などの統合環境では、次の条件が重なると意図せず `main` 作業や merge 操作に進むことがあります。

- HCOS の repository root ではない場所で起動し、`AGENTS.md` / `hcos/BOOT.md` を読めていない
- 作業開始時点の current branch が `main` / `master`
- GitHub token が Human CTO と同等の権限を持っている
- 「ok」「承認」「進めて」を、PR 作成や merge までの許可として広く解釈する
- GitHub 側の branch protection が未設定、または private repository で Free plan の制限に当たっている

対策は一つに頼らず、GitHub 側、token 側、local clone 側、prompt 側で重ねます。

## GitHub Free Compatible Settings

GitHub 公式ドキュメントでは、protected branches と rulesets は GitHub Free / GitHub Free for organizations の public repository で利用できます。private repository では利用できる保護機能が plan に依存します。

参考:

- [GitHub Docs: About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Docs: About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)

Public repository では、`Settings` -> `Branches` または `Rules` -> `Rulesets` で、default branch (`main` / `master`) に次を設定します。

- Require a pull request before merging
- Require approvals before merging
- Require status checks before merging
- Require conversation resolution before merging
- Block force pushes
- Block deletions
- Include administrators / do not allow bypass, if the setting is available
- Restrict who can push to matching branches, if the setting is available

HCOS Tier A repository では、少なくとも `policy` workflow を required status check に含めます。workflow 名や job 名が変わると required check が外れるため、変更時は branch protection も見直します。

Private repository で Free plan の制限により同等の保護が設定できない場合は、次の local hook と token discipline を必須扱いにします。

## Token Discipline

AI agent 用 token / account は、Human CTO の merge authority と分けます。

- AI agent には admin / maintain 権限を渡さない
- 可能なら repository ごとの least privilege token を使う
- Human CTO が GitHub UI で merge する account と、agent が実装する account を分ける
- AI agent に `gh pr merge`、GitHub UI の merge button、merge API の実行を依頼しない
- AI agent が approve まで進めても、最後は「Human CTO merge 待ち」で止める

Local hook は `git push origin main` を止められますが、`gh pr merge` や GitHub UI の merge API は止められません。API merge を止める層は branch protection と token discipline です。

## Local Pre-push Hook

各 clone では、次の script で safety hook を入れます。

```powershell
powershell -ExecutionPolicy Bypass -File C:\data\GitHub_org\HealthCheck-OS\scripts\install_git_safety_hooks.ps1 -Role dev
```

Role は端末に合わせて選びます。

- `dev`: 開発PCで使う主要 repository
- `subpc`: サブPCで使う repository
- `clinic`: 実機/EMR 端末で使う repository
- `all`: 標準 path 上の全 repository

この hook は、`main` / `master` への直接 push を拒否します。feature branch への push と PR 作成は妨げません。

Hook は clone ごとの local file です。新規 clone、別端末、repository 再作成の後は必ず再インストールします。

## Agent Start Checklist

AI agent セッション開始時は、実装前に次を確認します。

1. HCOS repository root または標準 VS Code workspace で起動している
2. `AGENTS.md`、`hcos/BOOT.md`、対象 Issue / PR を読んでいる
3. `git branch --show-current` が `main` / `master` ではない
4. 実装なら `feature/<issue-number>-short-name` を作成してから編集する
5. `scripts/install_git_safety_hooks.ps1` で hook 済み、または hook 未導入を明示して作業を止める
6. `gh pr merge` / GitHub UI merge / merge API を実行しない
7. PR 作成、レビュー、Approve まで完了したら Human CTO merge 待ちとして停止する

## Human CTO Merge Flow

Human CTO は GitHub UI で PR を確認し、次の条件を満たした場合のみ squash merge します。

- Claude review approved
- required status checks passing
- safety checks complete
- diff scope が Issue と一致

AI agent は、merge を提案しても実行しません。
