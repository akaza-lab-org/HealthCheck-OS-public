# Sub PC USB Release Workstation

For the short list of tasks that should actually be performed on the sub PC, see `docs/guides/hardware/sub_pc_tasks_only.md`.

## Purpose

The clinic sub PC is not primarily a production terminal. Treat it as a release workstation for:

- generating `kensin` portable ZIP packages
- copying ZIPs to the EMR-side environment through USB
- applying light fixes after release
- validating AHK bridge syntax and package contents before handoff

It should not become the normal source of truth for production DB state, terminal roles, or tuned EMR coordinates.

## Repository Layout

Use the Organization-aligned layout:

```text
C:\path\to\repos\
  HealthCheck-OS\
  kensin\
  AHK_setting\
```

If the sub PC already has older working copies elsewhere, finish or back up their local changes before switching active work to this layout.

## Required Local Tools

- Git
- PowerShell
- AutoHotkey v2
- Network access for build-time downloads on the sub PC
- USB storage used only as a transfer medium

Recommended checks:

```powershell
git --version
powershell -NoProfile -Command "$PSVersionTable.PSVersion"
Test-Path "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

`gh` CLI is optional. If unavailable, create GitHub Issues manually from `docs/next_github_issues.md`.

## Git Setup

Configure identity once:

```powershell
git config --global user.name "your-name"
git config --global user.email "your-email"
git config --global core.autocrlf true
```

Before building or fixing, always check:

```powershell
git -C C:\path\to\repos\kensin status --short -b
git -C C:\path\to\repos\AHK_setting status --short -b
git -C C:\path\to\repos\HealthCheck-OS status --short -b
```

## Release Build Flow

Build only on the sub PC or another designated development/build machine, never on the EMR production PC.

```powershell
cd C:\path\to\repos\kensin
git pull
pytest
.\build_portable.bat
```

Expected outputs:

```text
dist\kenshin_<version>_<commit>.zip
dist\kenshin_portable.zip
logs\setup_<timestamp>.log
```

The versioned ZIP is the preferred release artifact. The legacy `kenshin_portable.zip` alias is convenient, but do not rely on it for release history.

## USB Transfer Flow

Use USB only for carrying release artifacts and, when needed, logs. Do not use USB as the working repository.

Recommended USB layout:

```text
USB:\
  kensin_release\
    incoming\
    applied\
    logs\
```

Copy from sub PC:

```text
C:\path\to\repos\kensin\dist\kenshin_<version>_<commit>.zip
```

to:

```text
USB:\kensin_release\incoming\
```

After applying on the EMR-side environment, move the ZIP to:

```text
USB:\kensin_release\applied\
```

and copy any update logs back to:

```text
USB:\kensin_release\logs\
```

## Production-Side Application

On the EMR-side PC, avoid setup or dependency installation. The production side should only receive the ZIP and run the existing update path.

Preferred production update model:

```text
ZIP from USB
  -> releases folder
  -> update_from_share.bat
  -> C:\DATA\FONC\current
```

The exact destination may differ by clinic setup. Preserve the existing production deployment layout and do not replace `C:\DATA\FONC\data\settings.json`.

## AHK Handling

AHK is more terminal-specific than the `kensin` app package.

Rules:

- Do not overwrite production `config.ini` from the sub PC.
- Keep production coordinates, profiles, printers, and hotkeys on the production side.
- Promote new AHK behavior through scripts and migration defaults, not by copying a tuned config over another terminal.
- Validate scripts on the sub PC before USB handoff.

Sub PC validation:

```powershell
cd C:\path\to\repos\AHK_setting
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "kenshin_order_bridge.ahk"
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "main.ahk"
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "config_editor.ahk"
```

Production-side AHK updates should use `setup.ahk` or a documented copy/update script that:

- backs up existing `config.ini`
- fills only missing keys
- restores the backup if migration fails
- includes any new bridge/helper files in copy targets

## Light Fix Flow

For small fixes on the sub PC:

1. Create or reference a GitHub Issue.
2. Work in the affected repo only.
3. Run focused tests.
4. Run full `pytest` for `kensin` before packaging.
5. Validate AHK scripts if AHK changed.
6. Build a new versioned ZIP.
7. Record the result in the Issue or PR.

Do not patch production files directly unless it is an emergency hotfix. If an emergency hotfix is used, create a follow-up Issue to bring the repository source back into agreement with production.

## What Should Not Be Synced From Sub PC

Do not carry these from sub PC to production by ordinary copy:

- `.git`
- `.venv`
- `.pytest_cache`
- `tmp`
- `scratch`
- local `data\settings.json`
- local test DBs
- AHK `config.ini` unless intentionally migrating that exact terminal's settings
- logs containing patient identifiers

## Release Checklist

- [ ] `git status --short -b` checked in changed repos
- [ ] `pytest` passed in `kensin`
- [ ] AHK `/Validate` passed if AHK changed
- [ ] `build_portable.bat` completed
- [ ] Versioned ZIP copied to USB
- [ ] Production settings were not overwritten
- [ ] Production `config.ini` was not overwritten
- [ ] Update result/log copied back to sub PC if available
- [ ] GitHub Issue or PR updated with version, commit, and verification result
