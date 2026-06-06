# Local Workspace Standard

HCOS 関連 repository は、端末ごとの気分で置き場所を変えず、標準 local path に clone します。

この標準は「迷わず clone できること」と「診断スクリプトでズレを検出できること」を目的にします。すでに別の場所で動いている端末は、すぐ移動せず `docs/local_workspace_roles.md` に沿って例外として扱い、月次レビューで整理します。

## Directory Roots

| Root | Use |
|---|---|
| `C:\data\GitHub_org` | HCOS, skills, advisory app repos |
| `C:\data\GitHub` | clinic app repos, AHK, heavier implementation repos |

## Standard Repository Layout

| Repository | Standard local path | Default branch | Clone command |
|---|---|---|---|
| `akaza-lab-org/HealthCheck-OS` | `C:\data\GitHub_org\HealthCheck-OS` | `main` | `git clone https://github.com/akaza-lab-org/HealthCheck-OS.git C:\data\GitHub_org\HealthCheck-OS` |
| `akaza-lab-org/skills` | `C:\data\GitHub_org\skills` | `main` | `git clone https://github.com/akaza-lab-org/skills.git C:\data\GitHub_org\skills` |
| `akaza-lab-org/summarymaker` | `C:\data\GitHub_org\summarymaker` | `main` | `git clone https://github.com/akaza-lab-org/summarymaker.git C:\data\GitHub_org\summarymaker` |
| `akaza-lab-org/clinic-app` | `C:\data\GitHub\kensin` | `main` | `git clone https://github.com/akaza-lab-org/clinic-app.git C:\data\GitHub\kensin` |
| `akaza-lab-org/AHK_setting` | `C:\data\GitHub\ahk` | `main` | `git clone https://github.com/akaza-lab-org/AHK_setting.git C:\data\GitHub\ahk` |
| `akaza-lab-org/pdf_digitizer` | `C:\data\GitHub\pdf_digitizer` | `master` | `git clone https://github.com/akaza-lab-org/pdf_digitizer.git C:\data\GitHub\pdf_digitizer` |
| `akaza-lab-org/ikensho_git` | `C:\data\GitHub_org\ikensho_git` | `main` | `git clone https://github.com/akaza-lab-org/ikensho_git.git C:\data\GitHub_org\ikensho_git` |
| `akaza-lab-org/keikakusho` | `C:\data\GitHub_org\keikakusho` | `main` | `git clone https://github.com/akaza-lab-org/keikakusho.git C:\data\GitHub_org\keikakusho` |
| `akaza-lab-org/DM-kousin` | `C:\data\GitHub_org\DM-kousin` | `main` | `git clone https://github.com/akaza-lab-org/DM-kousin.git C:\data\GitHub_org\DM-kousin` |
| `akaza-lab-org/wakumy_apilot` | `C:\data\GitHub_org\wakumy_apilot` | `main` | `git clone https://github.com/akaza-lab-org/wakumy_apilot.git C:\data\GitHub_org\wakumy_apilot` |

## VS Code Workspace

Development PC sessions should open:

```powershell
code C:\data\GitHub_org\HealthCheck-OS\workspaces\hcos-dev.code-workspace
```

The workspace uses absolute standard paths. If a folder is missing, clone it into the standard path rather than editing the workspace file for one terminal.

## What Must Stay Local

Do not commit:

- `.env`, `.env.local`, or other secret files
- production logs
- exported patient data
- terminal-specific `config.ini`
- generated PDFs, CSVs, screenshots, or scan images containing identifiers
- private scratch folders such as `.vscode/` unless intentionally reviewed

## Before Starting Work

On a new terminal, clone HCOS first:

```powershell
New-Item -ItemType Directory -Force C:\data\GitHub_org | Out-Null
git clone https://github.com/akaza-lab-org/HealthCheck-OS.git C:\data\GitHub_org\HealthCheck-OS
cd C:\data\GitHub_org\HealthCheck-OS
```

Then clone the repositories needed on that terminal and install safety hooks:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bootstrap_local_workspace.ps1 -Role dev -InstallHooks
```

For a narrower setup, specify repository aliases:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bootstrap_local_workspace.ps1 -Repos kensin,ahk -InstallHooks
```

Run the local workspace check:

```powershell
powershell -ExecutionPolicy Bypass -File C:\data\GitHub_org\HealthCheck-OS\scripts\check_local_workspace.ps1 -Role dev
```

Use `-Role clinic` on a clinic/EMR terminal and `-Role subpc` on a sub PC.

If the script reports a missing repository, prefer cloning into the standard path. If it reports a remote mismatch, stop and inspect before pulling or pushing.

Install the local git safety hook after cloning repositories:

```powershell
powershell -ExecutionPolicy Bypass -File C:\data\GitHub_org\HealthCheck-OS\scripts\install_git_safety_hooks.ps1 -Role dev
```

The hook blocks direct push to `main` / `master` from that clone. It does not block GitHub UI/API merge, so branch protection and token separation are still required. See [`docs/ai_agent_merge_guardrails.md`](ai_agent_merge_guardrails.md).
