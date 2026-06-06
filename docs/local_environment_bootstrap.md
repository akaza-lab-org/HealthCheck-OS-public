# Local Environment Bootstrap

このメモは、HealthCheck-OS の作業環境を新しい端末で再現するときの初期設定手順をまとめたものです。

## 対象リポジトリ

過去の配置例:

- `C:\DATA\project\hcos_project\HealthCheck-OS`
- `C:\DATA\project\hcos_project\clinic-app`
- `C:\DATA\project\hcos_project\AHK_setting`
- `C:\DATA\project\hcos_project\skills`

現在の標準配置例:

- `C:\data\GitHub_org\HealthCheck-OS`
- `C:\data\GitHub_org\skills`
- `C:\data\GitHub_org\summarymaker`
- `C:\data\GitHub\kensin`
- `C:\data\GitHub\ahk`

新規端末では、最初に HCOS を clone してから bootstrap script を使う。

```powershell
New-Item -ItemType Directory -Force C:\data\GitHub_org | Out-Null
git clone https://github.com/akaza-lab-org/HealthCheck-OS.git C:\data\GitHub_org\HealthCheck-OS
cd C:\data\GitHub_org\HealthCheck-OS
powershell -ExecutionPolicy Bypass -File scripts\bootstrap_local_workspace.ps1 -Role dev -InstallHooks
```

## 初期セットアップ

1. 4 つのリポジトリを clone する。
   - Agent 作業領域では `.git` 内にロックファイルを生成するため、clone 先はユーザーがフルアクセスできるディレクトリにしてください。`C:\tmp` や一時環境の制限付きパスは避けます。
2. `skills` リポジトリで共有 skill の junction を作る。
3. `HealthCheck-OS` の Python 仮想環境と Gemini 設定を用意する。
4. `clinic-app` と `AHK_setting` のローカル運用手順を確認する。

**トラブル時**: `.git/index.lock` / `.git/HEAD.lock` の Permission denied が発生した場合、`HealthCheck-OS/scripts/fix_git_acl_permissions.ps1` を該当リポジトリで実行してください。

### 1. 共有 skills のセットアップ

`skills` リポジトリで次を実行する。

```powershell
cd C:\data\GitHub_org\skills
powershell -ExecutionPolicy Bypass -File .\setup-shared-skills.ps1
```

このセットアップで以下が既定有効になる。

- Codex: `~\.codex\skills`
- Claude Code: `~\.claude\agents`
- Antigravity: `~\.gemini\antigravity\skills`

更新時は次を使う。

```powershell
cd C:\data\GitHub_org\skills
powershell -ExecutionPolicy Bypass -File .\update-shared-skills.ps1
```

Windows 起動時に自動更新したい場合は次を実行する（スタートアップフォルダに `SyncSkills.lnk` が作成される）。

```powershell
cd C:\data\GitHub_org\skills
powershell -ExecutionPolicy Bypass -File .\automation\create_shortcut.ps1
```

### 2. HealthCheck-OS の Python セットアップ

```powershell
cd C:\data\GitHub_org\HealthCheck-OS
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

`.env` は `secret\.env` に置く。秘密情報は Git に入れない。

今回の構成では、Vertex AI 用に次を使った。

- `VERTEX_AI=1`
- `GOOGLE_CLOUD_PROJECT=your-gcp-project`
- `GOOGLE_CLOUD_LOCATION=global`
- `GOOGLE_APPLICATION_CREDENTIALS=C:/DATA/json/your-service-account-key.json`
- `DEFAULT_GEMINI_MODEL=gemini-2.5-flash`

### 3. kensin の初期確認

```powershell
cd C:\data\GitHub\kensin
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -U pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m pytest
.\build_portable.bat
.\run.bat
```

共有フォルダ運用や更新手順は `docs/manuals/setup.md` を参照する。

### 4. AHK_setting の初期確認

```powershell
cd C:\data\GitHub\ahk
```

- AutoHotkey v2 をインストールする
- `config.sample.ini` を元に `config.ini` を作る
- `config.ini` はローカル専用に保つ
- 端末ごとの座標やプリンタ設定を `config_editor.ahk` で調整する

## 更新ルール

- 共有 skills を更新したら `update-shared-skills.ps1` を実行して junction を再同期する。
- `secret\.env` と `AHK_setting\config.ini` はコミットしない。
- 端末固有の設定は上書きせず、必要なら個別に調整する。

