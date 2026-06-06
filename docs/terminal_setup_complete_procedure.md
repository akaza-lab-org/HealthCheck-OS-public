# HCOS Agent Environment Setup Procedure

HCOS AI エージェント向けの**共通環境セットアップ**手順です。

## 📋 スコープ

このドキュメントは HCOS 開発環境の**基盤となる環境設定**のみを対象とします。

### ✓ このドキュメントで実施する内容
- Git グローバル設定（user.name, user.email, credential.helper）
- Windows Credential Manager のクリーンアップ
- Git ACL 権限修復（`.git` ディレクトリ）
- Shared Skills セットアップ（Codex, Claude Code, Antigravity）
- Python 仮想環境セットアップ
- VS Code 拡張機能と開発ツール（推奨オプション）

### ✗ このドキュメントに含まれない内容
- **kensin アプリケーションのセットアップ** → 別ドキュメント参照
- **AHK（AutoHotkey）のセットアップ** → 別ドキュメント参照
- 案件固有のアプリケーション構築

---

**推定時間**: 15-20 分  
**権限要件**: Administrator または管理者権限のある PowerShell

## 前提条件

- [ ] Windows 10/11 Pro 以上
- [ ] Git for Windows がインストール済み（`where git` で確認）
- [ ] Python 3.10+ がインストール済み（`python --version` で確認）
- [ ] PowerShell 5.0 以上

## Step 1: リポジトリのクローン

現在の標準配置では、最初に HCOS だけ clone し、以後は bootstrap script で必要 repository を標準 path にそろえます。

```powershell
New-Item -ItemType Directory -Force C:\path\to\repos | Out-Null
git clone https://github.com/akaza-lab-org/HealthCheck-OS.git C:\path\to\repos\HealthCheck-OS
cd C:\path\to\repos\HealthCheck-OS

# Development PC standard set
powershell -ExecutionPolicy Bypass -File scripts\bootstrap_local_workspace.ps1 -Role dev -InstallHooks

# Narrow setup example
powershell -ExecutionPolicy Bypass -File scripts\bootstrap_local_workspace.ps1 -Repos kensin,ahk -InstallHooks
```

標準 path と role 別 repository は `docs/local_workspace_standard.md` と `docs/local_workspace_roles.md` を参照してください。以下の旧パス例は、過去端末の復旧やトラブルシュート用の参考として扱います。

```powershell
cd C:\path\to\projects\hcos_project

# 4 つのリポジトリをクローン
git clone https://github.com/akaza-lab-org/clinic-app.git
git clone https://github.com/akaza-lab-org/AHK_setting.git
git clone https://github.com/akaza-lab-org/skills.git
git clone https://github.com/akaza-lab-org/HealthCheck-OS.git
```

### ⚠️ 初回認証時の重要な注意

クローン実行時に GitHub 認証ダイアログが表示される場合があります。

**正しい操作**:
```
Select an account ダイアログが出たら
→ human-cto アカウントを選択
→ それだけ
```

**避けるべき操作（重要）**:
```
❌ 複数のアカウントを試す
❌ 別のアカウントを選択して承認する
❌ 複数回異なるアカウントで認証する
```

**なぜ重要か**:
複数のアカウント認証情報が Windows Credential Manager に保存されると、その後のすべての git 操作で「Select an account」ダイアログが繰り返し出現します（最大 4 回）。

**もし複数保存された場合**:
Step 2.1 の「Windows Credential Manager クリーンアップ」で削除できます。

## Step 2: Git グローバル設定初期化

```powershell
# グローバル git config を設定
git config --global user.name "HCOS Agent"
git config --global user.email "hcos-agent@akaza-lab.local"
git config --global credential.helper wincred
git config --global core.autocrlf true
git config --global core.safecrlf warn

# 確認
git config --global --list | Select-String "user\.|credential"
```

**期待される出力**:
```
user.name=HCOS Agent
user.email=hcos-agent@akaza-lab.local
credential.helper=wincred
core.autocrlf=true
core.safecrlf=warn
```

### 2.1 Windows Credential Manager クリーンアップ（重要！）

**このステップは、Step 1 で複数のアカウントを認証してしまった場合に必須です。**

複数の GitHub アカウント認証情報が保存されていると、git 操作のたびに「Select an account」ダイアログが出現します。

**クリーンアップ手順**:

1. **Windows キー** を押して「資格情報マネージャー」と検索
2. **「Windows 資格情報」** をクリック
3. **GitHub 関連エントリを確認**:
   - 保持: `git:https://github.com`, `git:https://human-cto@github.com`, `gh:github.com:human-cto`
   - 削除: 上記以外の github エントリ（特に数字だけのアカウント）

4. **不要なエントリを右クリック → 削除**
5. **確認ダイアログで「はい」をクリック**

**確認方法**:
```powershell
# アカウント選択ダイアログが出ないことを確認
git push --dry-run origin main
```

**結果**:
- ✓ ダイアログが出ない → クリーンアップ成功 → Step 3 へ進む
- ✗ ダイアログが出る → 削除しきれていないエントリがある → 手順を繰り返す

## Step 3: Git ACL 権限修復（重要！）

**このステップが最も重要です**。Windows ACL で `.git` ディレクトリへの書き込み権限が制限されていることがあります。

`.git/index.lock` / `.git/HEAD.lock` の生成は Git の内部メタデータ書き込みを必要とするため、作業用クローンは `.git` 以下にフルアクセスがあるディレクトリに置いてください。システムの一時フォルダやアクセス制限のある `C:\tmp` などのパスでは、`git add` やブランチ作成時に権限エラーが発生することがあります。

### 3.1 ACL 修復スクリプト実行

```powershell
cd C:\path\to\repos\HealthCheck-OS

# スクリプト実行（管理者権限必須）
powershell -ExecutionPolicy Bypass -File .\scripts\fix_git_acl_permissions.ps1 -RepoPath $PWD -Verify
```

**期待される出力**:
```
✓ ACL reset successful
✓ Permissions granted successfully
✓ git add works correctly
```

### 3.2 他のリポジトリにも適用

```powershell
# 各リポジトリで同じスクリプトを実行
$repos = @(
    "C:\data\GitHub\kensin",
    "C:\path\to\apps\ahk",
    "C:\path\to\repos\skills"
)

foreach ($repo in $repos) {
    Write-Host "Fixing ACL in $repo..." -ForegroundColor Cyan
    powershell -ExecutionPolicy Bypass -File "C:\path\to\repos\HealthCheck-OS\scripts\fix_git_acl_permissions.ps1" -RepoPath $repo -Verify
}
```

## Step 4: Shared Skills セットアップ

```powershell
cd C:\path\to\repos\skills

# Codex, Claude Code, Antigravity 用の junction を作成
powershell -ExecutionPolicy Bypass -File .\setup-shared-skills.ps1

# Windows 起動時の自動更新ショートカットを作成する場合（任意）
powershell -ExecutionPolicy Bypass -File .\automation\create_shortcut.ps1
```

**期待される出力**:
```
[setup] Setup complete for Claude Code, Codex and Antigravity
```

## Step 5: HealthCheck-OS Python 環境セットアップ

```powershell
cd C:\path\to\repos\HealthCheck-OS

# 仮想環境作成
python -m venv .venv

# 依存関係インストール
.\.venv\Scripts\python.exe -m pip install -r requirements.txt

# .env 設定
# secret\.env をコピーするか、環境変数を設定
```

## Step 6: Git 動作確認テスト

各リポジトリで動作テストを実行：

```powershell
# テスト関数
function Test-GitSetup($RepoPath) {
    Push-Location $RepoPath
    
    Write-Host "`n=== Testing $RepoPath ===" -ForegroundColor Cyan
    
    # 1. git status
    git status --short | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Host "✓ git status works" -ForegroundColor Green }
    
    # 2. Branch テスト
    git checkout -b test/setup-verification 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "✓ Branch creation works" -ForegroundColor Green
        git checkout main
        git branch -D test/setup-verification 2>&1 | Out-Null
    } else {
        Write-Host "✗ Branch creation failed" -ForegroundColor Red
    }
    
    # 3. File write + git add テスト
    "test" | Out-File -FilePath ".setup_verify" -Encoding UTF8
    git add .setup_verify 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "✓ git add works" -ForegroundColor Green
        git restore --staged .setup_verify
        Remove-Item .setup_verify
    } else {
        Write-Host "✗ git add failed" -ForegroundColor Red
    }
    
    Pop-Location
}

# 全リポジトリをテスト
@(
    "C:\path\to\repos\HealthCheck-OS",
    "C:\data\GitHub\kensin",
    "C:\path\to\apps\ahk",
    "C:\path\to\repos\skills"
) | ForEach-Object { Test-GitSetup $_ }
```

## Step 7: VS Code 拡張機能と開発ツールのセットアップ

### 7.1 VS Code 拡張機能（推奨）

VS Code を使用する場合、以下の拡張機能をインストールすると開発効率が向上します。

#### Python 開発向け（kensin 開発用）

**必須**:
```powershell
code --install-extension ms-python.python           # Debugger, 環境管理, テスト機能統合
code --install-extension ms-python.vscode-pylance   # 型チェック, IntelliSense
code --install-extension ms-python.black-formatter  # コード整形
```

**推奨**:
```powershell
code --install-extension ms-python.isort             # インポート整理
code --install-extension hbenl.vscode-test-explorer # テストエクスプローラーUI
```

**注**: `pytest` はコマンドラインから直接実行可能（拡張機能不要）

#### JavaScript/TypeScript 開発向け（doctor.js など）

**推奨**:
```powershell
code --install-extension dbaeumer.vscode-eslint      # JS コード品質チェック
code --install-extension esbenp.prettier-vscode      # コードフォーマッター
```

#### AutoHotkey 開発向け（AHK_setting）

**推奨**:
```powershell
code --install-extension mark-wiemer.vscode-autohotkey-plus-plus  # シンタックス, デバッガ
```

#### Git & 協働作業向け

**必須**:
```powershell
code --install-extension eamodio.gitlens            # git 可視化, blame情報
```

**推奨**:
```powershell
code --install-extension mhutchie.git-graph         # ブランチツリー表示
code --install-extension GitHub.copilot              # AI 補助（医療コードは要確認）
```

#### ドキュメント & その他

**推奨**:
```powershell
code --install-extension yzhang.markdown-all-in-one       # Markdown TOC生成
code --install-extension davidanson.vscode-markdownlint   # Markdown スタイル検査
code --install-extension aaron-bond.better-comments        # コメント色分け
code --install-extension humao.rest-client                 # API テスト（REST）
code --install-extension postmanlabs.postman               # API テスト（GUI）
```

**インストール一括実行**:

```powershell
# 最小必須拡張機能のみ（これで開発可能）
$essentialExtensions = @(
    'ms-python.python',
    'ms-python.vscode-pylance',
    'ms-python.black-formatter',
    'eamodio.gitlens'
)

# 追加推奨拡張機能
$optionalExtensions = @(
    'ms-python.isort',
    'dbaeumer.vscode-eslint',
    'esbenp.prettier-vscode',
    'mark-wiemer.vscode-autohotkey-plus-plus',
    'hbenl.vscode-test-explorer',
    'yzhang.markdown-all-in-one',
    'aaron-bond.better-comments'
)

Write-Host "必須拡張機能をインストール中..." -ForegroundColor Cyan
foreach ($ext in $essentialExtensions) {
    Write-Host "  $ext" -ForegroundColor White -NoNewline
    code --install-extension $ext 2>&1 | Out-Null
    Write-Host " ✓" -ForegroundColor Green
}

Write-Host "`n✓ 必須拡張機能のインストールが完了しました" -ForegroundColor Green
Write-Host "オプション拡張機能は VS Code UI から個別にインストールできます" -ForegroundColor Yellow
```

### 7.2 VS Code settings.json 推奨設定

**設定場所**: `C:\Users\<username>\AppData\Roaming\Code\User\settings.json` または VS Code → Settings → JSON

```json
{
  "[python]": {
    "editor.defaultFormatter": "ms-python.python",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": false,
  "python.linting.flake8Enabled": true,
  "gitlens.showWelcomeOnInstall": false,
  "gitlens.keymap": "chorded",
  "editor.rulers": [100, 120],
  "editor.wordWrap": "on",
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true,
    "**/.pytest_cache": true
  }
}
```

### 7.3 開発ツール（コマンドラインツール）

#### Python 開発ツール

```powershell
# HealthCheck-OS の仮想環境を有効化
cd C:\path\to\repos\HealthCheck-OS
.\.venv\Scripts\Activate.ps1

# または kensin の仮想環境
cd C:\data\GitHub\kensin
.\.venv\Scripts\Activate.ps1
```

**Python ツール確認**:
```powershell
# 仮想環境有効化後、以下で確認
pip list | Select-String "pytest|black|isort|sqlalchemy|fastapi|pydantic"
```

**期待される出力例**:
```
black
fastapi
isort
pydantic
pytest
sqlalchemy
```

#### AutoHotkey

**AHK v2 の確認**:
```powershell
$ahkPath = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
if (Test-Path $ahkPath) {
    Write-Host "✓ AutoHotkey v2 がインストール済みです" -ForegroundColor Green
    & $ahkPath --version
} else {
    Write-Host "✗ AutoHotkey v2 がインストールされていません" -ForegroundColor Red
    Write-Host "インストール: https://www.autohotkey.com/download/ahk2exe/"
}
```

#### Node.js（オプション）

JavaScript 開発が必要な場合：
```powershell
# 確認
node --version
npm --version

# インストール（必要な場合）
# https://nodejs.org/ からダウンロード
```

### 7.4 環境確認スクリプト

セットアップ完了後、以下を実行して確認：

```powershell
Write-Host "=== 開発環境確認 ===" -ForegroundColor Cyan

# Git
Write-Host "`n✓ Git" -ForegroundColor Green
git --version

# Python
Write-Host "`n✓ Python" -ForegroundColor Green
python --version

# VS Code
Write-Host "`n✓ VS Code" -ForegroundColor Green
code --version

# AutoHotkey（AHK開発者向け）
if (Test-Path "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe") {
    Write-Host "`n✓ AutoHotkey v2" -ForegroundColor Green
} else {
    Write-Host "`n⚠ AutoHotkey v2 がインストールされていません（AHK開発予定がある場合は必須）" -ForegroundColor Yellow
}

# Python パッケージ確認
Write-Host "`n✓ Python パッケージ" -ForegroundColor Green
python -c "import pytest; import sqlalchemy; import fastapi; print('  pytest, sqlalchemy, fastapi: OK')"

Write-Host "`n=== セットアップ完了 ===" -ForegroundColor Cyan
```

---

## トラブルシューティング

### git add が失敗する場合

```powershell
# ACL をもう一度修復
powershell -ExecutionPolicy Bypass -File .\scripts\fix_git_acl_permissions.ps1 -RepoPath $PWD -Verify
```

この種のエラーは `.git/index.lock` や `.git/HEAD.lock` の生成が原因であることが多いです。引き続き `Permission denied` が発生する場合は、作業リポジトリを権限が明確な場所に再クローンし、`.git` ディレクトリの書き込み権限を確認してください。

### Permission denied が続く場合

1. **PowerShell を管理者として実行** し直す
2. `.git` ディレクトリをマニュアルで確認：
   ```powershell
   icacls .git
   ```
3. 手動で権限を付与：
   ```powershell
   icacls .git /reset /T /C
   icacls .git /grant:r "$env:USERNAME`:(F)" /T /C
   ```

### Windows Credential Manager 認証が失敗する場合

```powershell
# 認証情報をクリア
git credential-wincred erase
# 以下を入力:
# host=github.com
# protocol=https
# [Enter] x 2

# 次の push で再度認証される
git push origin main
```

## 環境変数（オプション）

GCP Vertex AI を使う場合：

```powershell
$env:VERTEX_AI="1"
$env:GOOGLE_CLOUD_PROJECT="your-gcp-project"
$env:GOOGLE_CLOUD_LOCATION="global"
$env:GOOGLE_APPLICATION_CREDENTIALS="C:/DATA/json/your-service-account-key.json"
$env:DEFAULT_GEMINI_MODEL="gemini-2.5-flash"
```

`.env` またはシステム環境変数に設定。

## 完了確認チェックリスト

### Part A: 基盤環境セットアップ

- [ ] 4 つのリポジトリがクローンされている
- [ ] 初回認証時に `human-cto` アカウントのみを選択した
- [ ] `git config --global user.name` が `HCOS Agent` になっている
- [ ] Windows Credential Manager クリーンアップを実施（複数アカウントがある場合）
- [ ] `git push --dry-run` でアカウント選択ダイアログが出ない
- [ ] ACL 修復スクリプトが全リポジトリで実行済み
- [ ] `git add` / `git commit` が動作する
- [ ] `git branch` / `git push --dry-run` が動作する
- [ ] Shared skills セットアップが完了している
- [ ] Python 仮想環境が `.venv` に存在する
- [ ] `.env` ファイルが設定済み（または環境変数が設定済み）

### Step 7: 開発ツール（オプションだが推奨）

- [ ] VS Code 拡張機能がインストールされている（少なくともPylance, GitLens）
- [ ] VS Code settings.json が設定済み（またはデフォルトで動作）
- [ ] AutoHotkey v2 がインストール済み（AHK 開発予定がある場合）
- [ ] 環境確認スクリプトが正常に実行される

**Part A 完了基準**: ✅ の項目が全て チェック完了
**Step 7 完了基準**: 開発効率向上のためのオプション（後から追加可能）

すべてチェックできたら、**Part A（基盤環境）のセットアップ完了**です！

## 次のステップ

**セットアップ直後（Part A 完了時）**:
1. `AGENTS.md` を読む（AI エージェント向け）
2. `hcos/BOOT.md` を確認（HCOS 起動プロトコル）
3. `docs/agent_git_troubleshooting.md` をブックマーク（問題発生時）

**開発作業開始前（推奨）**:
4. Step 7 の VS Code 拡張機能をインストール
5. 各リポジトリの workspace 設定を確認（VS Code で開く）
6. 割り当てられた Issue / タスクから作業開始

## 参考資料

- `docs/local_environment_bootstrap.md` - 詳細なセットアップ背景
- `docs/git_agent_setup_guide.md` - git 設定の詳細説明
- `docs/agent_git_troubleshooting.md` - git トラブルシューティング
- `scripts/fix_git_acl_permissions.ps1` - ACL 修復スクリプト

---

# Part B: アプリケーション固有のセットアップ（案件別）

**Part A（上記）の環境設定が完了したら、以下のステップに進みます。**

各案件に応じて、必要なアプリケーションのセットアップを実施してください。

## kensin アプリケーションのセットアップ

kensin（健診管理・PDF 生成アプリケーション）を開発する場合：

```powershell
cd C:\data\GitHub\kensin

# セットアップドキュメントを参照
# docs/manuals/setup.md を確認
```

**参考**:
- `clinic-app/docs/manuals/setup.md` - kensin セットアップ手順
- `clinic-app/README.md` - プロジェクト概要

---

## AHK（AutoHotkey）の EMR 自動化セットアップ

AHK を使用して EMR 操作を自動化する場合：

```powershell
cd C:\path\to\apps\ahk

# セットアップドキュメントを参照
# README.md を確認
```

**参考**:
- `AHK_setting/README.md` - AHK プロジェクト概要
- `AHK_setting/config.sample.ini` - 設定ファイルテンプレート

**注意**: `config.ini` はターミナル固有の設定（座標、プリンタ）を含むため、Git に含めないでください。

---

## その他のセットアップ

- PDF 座標抽出ツール（`pdf_digitizer`）: 追加セットアップ不要（Part A で完備）
- Shared Skills: Part A の Step 4 で既に完了

---

## 次のステップ

環境設定とアプリケーション選択が完了したら：

1. `AGENTS.md` を読む（AI エージェント向け初期ガイダンス）
2. `hcos/BOOT.md` を確認（HCOS 起動プロトコル）
3. 割り当てられた Issue / タスクから作業開始
4. 問題発生時は `docs/agent_git_troubleshooting.md` を参照

---

**質問や問題**: Issue #109 または #110 を参照（セットアップ関連の既知問題）

