# Agent Git Troubleshooting

**エージェントで git ブランチ作成・コミット・プッシュが失敗する場合のトラブルシューティング**

## 確認順序

### 1️⃣ **まず実行してください**（初回起動時）

```powershell
# 現在のユーザーと git 実行環境を確認
$env:USERNAME
git config --global user.name
git config --global user.email

# 設定がなければ以下を実行
git config --global user.name "HCOS Agent"
git config --global user.email "hcos-agent@akaza-lab.local"
git config --global credential.helper wincred
```

**成功時の出力例**:
```
iakaza
HCOS Agent
hcos-agent@akaza-lab.local
```

### 2️⃣ **git コマンドが見つからない場合**

```powershell
# git の所在を確認
where git

# または
Get-Command git
```

**見つからない場合**: Git for Windows をインストールしてください → https://git-scm.com/download/win

### 3️⃣ **リポジトリで git status を実行**

```powershell
cd C:\DATA\project\hcos_project\<リポジトリ名>
git status
```

**出力例**:
```
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

### 4️⃣ **テストブランチを作成**

```powershell
git checkout -b test/agent-setup-check
git branch -v
```

**成功時の出力**:
```
* test/agent-setup-check <commit-hash>
  main <commit-hash>
```

### 5️⃣ **push テスト（認証確認）**

```powershell
git push --dry-run origin test/agent-setup-check
```

**成功時の出力**:
```
To https://github.com/akaza-lab-org/<repo>.git
 * [new branch]      test/agent-setup-check -> test/agent-setup-check
```

**認証が求められた場合**: Windows Credential Manager で GitHub の認証情報を入力してください。

### 6️⃣ **テストブランチをクリーンアップ**

```powershell
git checkout main
git branch -d test/agent-setup-check
```

## よくある失敗パターン

### ❌ `fatal: unable to read config file`

```powershell
# ✅ 解決策
git config --global user.name "HCOS Agent"
git config --global user.email "hcos-agent@akaza-lab.local"
```

### ❌ `Please tell me who you are`（コミット時）

```powershell
# ✅ 解決策
git config --global user.name "HCOS Agent"
git config --global user.email "hcos-agent@akaza-lab.local"
```

### ❌ `authentication failed`

```powershell
# ✅ 解決策 1: credential helper をセット
git config --global credential.helper wincred

# ✅ 解決策 2: 認証情報をクリア（次の push で再入力される）
git credential-wincred erase
# 以下を入力:
# host=github.com
# protocol=https
# [Enter] x 2
```

### ❌ `Permission denied (publickey)`（SSH の場合）

HTTPS を使用してください:
```powershell
cd <repository>
git remote set-url origin https://github.com/akaza-lab-org/<repo>.git
```

### ❌ `.git/index.lock` / `.git/HEAD.lock` の Permission denied

Agent ワークスペースでは Git が `.git` ディレクトリ内にロックファイルを作成します。`.git` 以下に書き込み権限がない場合、`git add` や `git checkout` が失敗します。

```powershell
# HealthCheck-OS リポジトリのルートで実行
cd <HealthCheck-OS のクローン先>
powershell -ExecutionPolicy Bypass -File .\scripts\fix_git_acl_permissions.ps1 -RepoPath $PWD -Verify
```

それでも失敗する場合は、リポジトリをユーザーがフルアクセスできるパスに再クローンしてください。

## 環境情報を報告する場合

以下の情報を一緒に報告してください：

```powershell
"=== Environment ===" 
$PSVersionTable.PSVersion
git --version
$env:USERNAME
"=== Git Config ===" 
git config --global user.name
git config --global user.email
"=== Repository ===" 
cd <repository>
git remote -v
git branch -v
```

## チェックリスト

- [ ] `git config --global user.name` が `HCOS Agent` に設定されている
- [ ] `git config --global user.email` が `hcos-agent@akaza-lab.local` に設定されている
- [ ] `git config --global credential.helper` が `wincred` に設定されている
- [ ] `git status` がリポジトリで実行できる
- [ ] テストブランチを作成・削除できる
- [ ] `git push --dry-run` で認証が機能する

すべてチェックできたら、ブランチ作成・コミット・プッシュが可能です。

## 参考資料

- `docs/git_agent_setup_guide.md` - 詳細なセットアップガイド
- `docs/git_push_policy.md` - Push ポリシー
- `docs/local_environment_bootstrap.md` - 全体のセットアップ手順

