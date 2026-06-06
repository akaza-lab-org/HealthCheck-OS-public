# Local Workspace Roles

Not every terminal needs every repository. Keep each terminal role small enough that updates are understandable.

## Development PC

Purpose: implementation, review, PR creation, docs, and verification.

Recommended repositories:

| Repository | Standard local path | Why |
|---|---|---|
| `HealthCheck-OS` | `C:\path\to\repos\HealthCheck-OS` | governance, docs, issue/PR workflows |
| `skills` | `C:\path\to\repos\skills` | shared AI skills |
| `summarymaker` | `C:\path\to\repos\summarymaker` | advisory app development |
| `clinic-app` | `C:\data\GitHub\kensin` | kensin maintenance |
| `AHK_setting` | `C:\path\to\apps\ahk` | AHK maintenance and EMR bridge review |
| `pdf_digitizer` | `C:\data\GitHub\pdf_digitizer` | paused/advisory tool, only when needed |

Open `workspaces/hcos-dev.code-workspace` from the HCOS repository.

## Sub PC / Release Workstation

Purpose: release preparation, USB/share deployment rehearsal, and sync support.

Recommended repositories:

| Repository | Standard local path | Why |
|---|---|---|
| `HealthCheck-OS` | `C:\path\to\repos\HealthCheck-OS` | release procedure docs |
| `clinic-app` | `C:\data\GitHub\kensin` | app build and release artifacts |
| `AHK_setting` | `C:\path\to\apps\ahk` | AHK release and config migration checks |

Do not treat this terminal as the source of production settings. Release outputs and logs should stay outside git unless explicitly documented.

## Clinic / EMR Terminal

Purpose: run deployed tools and terminal-specific AHK settings.

Recommended repositories:

| Repository | Standard local path | Why |
|---|---|---|
| `AHK_setting` | `C:\path\to\apps\ahk` | AHK scripts and terminal-specific `config.ini` |
| `HealthCheck-OS` | optional | reference docs only |

Rules:

- Do not overwrite terminal-specific `config.ini`.
- Do not use the clinic terminal as a broad development workspace.
- Prefer tested release packages or setup scripts over direct ad hoc git operations.

## Advisory / Re-entry Projects

For `ikensho_git`, `keikakusho`, `DM-kousin`, and `wakumy_apilot`, clone only when re-entry work begins.

Before implementation:

1. Run `scripts/check_local_workspace.ps1 -Role dev`.
2. Read `docs/project_reentry_checklist.md`.
3. Create a narrow Issue in the repository closest to the first code change.
4. Record local path and runnable state in the Issue.

## Exception Handling

If a terminal cannot use the standard path:

- Record the exception in the relevant Issue or monthly review.
- Do not silently edit shared workspace files for one terminal.
- Prefer a local note outside git for terminal-only paths.
- Revisit exceptions during monthly HCOS review.
