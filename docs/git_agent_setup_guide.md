# Git Agent Setup Guide

このドキュメントは、Claude Code エージェント（Codex、Antigravity、Claude）が git ブランチ作成・コミット・プッシュを実行する際に必要な設定について説明しています。

## クイックセットアップ

エージェントが git コマンド実行時にエラーが発生する場合、以下の初期化スクリプトを実行してください：

```powershell
# 1. グローバル git config の確認
git config --global user.name
git config --global user.email

# 2. 設定がない場合は初期化
if (-not (git config --global user.name)) {
    git config --global user.name "HCOS Agent"
    git config --global user.email "hcos-agent@akaza-lab.local"
}

# 3. Windows 認証ヘルパーの設定
git config --global credential.helper wincred

# 4. 推奨設定
git config --global core.autocrlf true
git config --global core.safecrlf warn

# 5. 設定確認
git config --global --list | Select-String "user\.|credential"
```

## デバッグ手順

git コマンドが失敗した場合の確認順序：

### Step 1: git 実行可能ファイルの確認

```powershell
# git が見つかるか確認
where git

# または
(Get-Command git).Source
```

### Step 2: グローバル設定の確認

```powershell
# user.name と user.email が設定されているか確認
git config --global user.name
git config --global user.email

# すべてのグローバル設定を表示
git config --global --list
```

### Step 3: ローカルリポジトリ設定の確認

```powershell
cd <repository-path>
git status
git config --local user.name   # 未設定で OK（グローバル設定を使う）
```

### Step 4: リモート認証のテスト

```powershell
# SSH / HTTPS の remote を確認
git remote -v

# push 権限をテスト（dry-run）
git push --dry-run origin main
```

## よくあるエラーと解決方法

### エラー: `fatal: unable to read config file`

**原因**: グローバル git config ファイルが破損しているか読み取り権限がない

**解決**:
```powershell
# 既存の config をバックアップ
Copy-Item $env:USERPROFILE\.gitconfig $env:USERPROFILE\.gitconfig.bak

# config を再初期化
git config --global user.name "HCOS Agent"
git config --global user.email "hcos-agent@akaza-lab.local"
```

### エラー: `Please tell me who you are` （コミット時）

**原因**: `user.name` または `user.email` が未設定

**解決**:
```powershell
git config --global user.name "HCOS Agent"
git config --global user.email "hcos-agent@akaza-lab.local"
```

### エラー: `Permission denied` / `Authentication failed`

**原因**: 認証情報ヘルパーが未設定、または認証情報が無効

**解決**:
```powershell
# Windows credential manager を使用するよう設定
git config --global credential.helper wincred

# 保存されている認証情報をクリア
& git credential-wincred erase
# そこで以下を入力:
# host=github.com
# protocol=https
# [Enter] を 2 回押す

# 次の push で新しい認証情報を要求される
git push
```

## Agent 起動時の設定手順

他のエージェント（Codex、Antigravity など）が起動する場合、以下を確認してください：

1. **初回起動時**:
   ```powershell
   # git config 確認
   git config --global user.name
   
   # 未設定なら初期化
   if (-not (git config --global user.name)) {
     git config --global user.name "HCOS Agent"
     git config --global user.email "hcos-agent@akaza-lab.local"
     git config --global credential.helper wincred
   }
   ```

2. **HCOS 作業開始前**:
   ```powershell
   # 各リポジトリの remote 確認
   cd <repository-path>
   git remote -v
   git status
   ```

3. **ブランチ作成前**:
   ```powershell
   # main/develop ブランチが最新か確認
   git fetch origin
   git log --oneline -n 3
   ```

## 仕様

- **User Name**: `HCOS Agent` （複数エージェント共通の名義）
- **User Email**: `hcos-agent@akaza-lab.local` （実在しないローカルドメイン）
- **Credential Helper**: `wincred` （Windows Credential Manager）
- **Line Ending**: `autocrlf=true` （Windows と Unix の混在環境対応）

## 参考

- `docs/git_push_policy.md` - Push 戦略
- `docs/pattern_hcos_pr_workflow.md` - PR ワークフロー
- `AGENTS.md` - Agent エントリーポイント

