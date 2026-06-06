# Sub PC Sync Tools

This document explains two helper scripts and one patch file for sub-PC recovery and daily start checks.

## Scope

Use these tools only for the HCOS sub-PC release workstation and agent handoff environment.

- `subpc_startup_check.bat` is safe for routine daily checks.
- `subpc_sync_to_remote_main_keep_portable.bat` is a recovery/synchronization tool, not a normal development shortcut.
- Do not run the destructive sync tool on production EMR PCs.
- Do not use these scripts to bypass the normal Issue -> branch -> PR workflow.

## Files

- `scripts/subpc_startup_check.bat`
- `scripts/subpc_sync_to_remote_main_keep_portable.bat`
- `patches/subpc_sync_tools.patch`

## Purpose

- Prevent mixed old/new code on sub PC.
- Keep local `kensin` portable script fixes (`run.bat`, `setup.bat`, `build_portable.bat`) when syncing to remote `main`.
- Use ASCII-only `.bat` output to reduce mojibake risk on Windows terminals.

## 1) Startup Check (Non-destructive)

Command:

```bat
cmd /c scripts\subpc_startup_check.bat
```

What it does:

- Detects repo paths from:
  - `C:\data\GitHub\...`
  - `C:\path\to\repos\...`
- Runs `git fetch --all --prune` in each repo.
- Shows:
  - `git status -sb`
  - `git branch -vv`
  - current branch name

Use this at the start of work every day.

## 2) Sync to Remote Main (with portable-script keep)

Use this only when the sub-PC working copies need to be realigned with remote `main`, for example after mixed old/new code, interrupted manual sync, or unclear branch state.

Before running:

- Confirm no valuable uncommitted work exists outside the kept portable script files.
- Confirm patient data, production settings, logs with identifiers, and terminal-specific `config.ini` changes are not being preserved by this tool.
- Prefer committing or manually backing up important work instead of relying on the generated patch.

Command:

```bat
cmd /c scripts\subpc_sync_to_remote_main_keep_portable.bat
```

What it does:

1. Creates a backup patch for local diffs in:
   - `run.bat`
   - `setup.bat`
   - `build_portable.bat`
2. For each repo (`kensin`, `ahk`, `HealthCheck-OS`):
   - `git fetch --all --prune`
   - `git switch main`
   - `git reset --hard origin/main`
3. Re-applies saved `kensin` portable patch with `git apply --3way`.
4. Prints final `git status -sb`.

Backup patch output path:

- `%USERPROFILE%\Desktop\subpc_git_backup\kensin_portable_local_YYYYMMDD_HHMMSS.patch`

## 3) Patch Distribution

If another terminal needs these scripts, apply:

```bat
git apply patches\subpc_sync_tools.patch
```

## Notes

- `subpc_sync_to_remote_main_keep_portable.bat` includes destructive sync (`reset --hard`) to align with remote truth.
- The destructive sync intentionally discards ordinary local changes in the target repos.
- Keep terminal-specific config files (for example AHK `config.ini`) out of commit/push unless explicitly intended.
- If the generated portable-script patch fails to apply cleanly, stop and inspect the patch manually before continuing.
