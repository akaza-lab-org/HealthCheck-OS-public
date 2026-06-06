# Git Push Policy

## Default

Completed and verified work should be committed and pushed to the remote repository at appropriate checkpoints.

This keeps the main PC, sub PC, and other agents aligned.

## When to Push

Push after:

- documentation or coordination updates are complete
- a focused code change passes its required tests
- a release ZIP was generated from a known commit
- an urgent fix has been captured in source control
- work needs to move between the main PC and sub PC

## Before Pushing

Always check:

```powershell
git status --short -b
git diff --stat
```

For code changes, run the relevant tests first.

For `kensin`:

```powershell
.\.venv\Scripts\python.exe -m pytest
```

For AHK changes:

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "kenshin_order_bridge.ahk"
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "main.ahk"
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "config_editor.ahk"
```

## Do Not Push

Do not push:

- real patient data
- logs or screenshots containing identifiers
- production terminal secrets
- terminal-specific `config.ini` changes unless the issue explicitly says to promote them
- local `settings.json` from production or sub PC
- unrelated local changes
- unverified medical/fee/order logic changes

## If Worktree Is Dirty

If dirty files are unrelated to the current task, leave them out of the commit.

If dirty files may be terminal-specific, especially AHK `config.ini` or production `settings.json`, treat them as local state and do not push them without explicit confirmation.

## Handoff Note

Every final report should include:

```text
commit:
push:
tests:
not pushed / reason:
```
