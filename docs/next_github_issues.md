# Next GitHub Issues

Use these as the first issues for stabilizing the `kensin` + `AHK_setting` development environment.

The section numbers in this file are draft/backlog order only. They are not GitHub Issue numbers.

Before an agent works from an Issue number, verify the actual title with:

```powershell
gh issue view <number> --repo <owner>/<repo>
```

## 1. Remove tracked temporary backup from kensin

Repository: `akaza-lab-org/clinic-app`

Actual GitHub Issue:

```text
akaza-lab-org/clinic-app#2
```

Title:

```text
[cleanup] Remove tracked $path.bak-20260418 backup file
```

Body:

```text
Goal:
Remove the tracked temporary backup file `$path.bak-20260418` if confirmed unnecessary.

Context:
The file appears to duplicate AHK legacy automation notes and is currently deleted in the local worktree.

Acceptance criteria:
- [ ] Confirm the file is not referenced by app code or docs
- [ ] Remove it in a dedicated cleanup commit/PR
- [ ] Run `pytest`
- [ ] Keep unrelated local changes untouched
```

Scope note:

```text
Keep this Issue limited to `$path.bak-20260418`.
If other tracked temporary files are found, list them as follow-up candidates instead of expanding this Issue silently.
```

## 2. Decide AHK config tracking policy

Repository: `akaza-lab-org/AHK_setting`

Title:

```text
[ahk] Define config.ini tracking and deployment policy
```

Body:

```text
Goal:
Decide whether `config.ini` should remain tracked, be replaced by `config.sample.ini`, or stay tracked only as a development template.

Context:
`config.ini` is UTF-16 LE with BOM and contains terminal/profile settings. Local changes exist and may represent real terminal tuning.

Acceptance criteria:
- [ ] Decide policy for production terminal values
- [ ] Document UTF-16 LE requirement
- [ ] Confirm `setup.ahk` preserves existing target config
- [ ] If moving to sample config, add migration/update guidance
- [ ] Validate `main.ahk`, `kenshin_order_bridge.ahk`, and `config_editor.ahk`
```

## 3. Create bridge dry-run verification mode

Repository: `akaza-lab-org/AHK_setting`

Title:

```text
[kensin-ahk] Add safe dry-run mode for kenshin_order_bridge
```

Body:

```text
Goal:
Allow developers to verify CLI parsing and QR payload handling without touching the EMR.

Acceptance criteria:
- [ ] Add a dry-run flag or config-controlled mode
- [ ] Log parsed action, exam ID, patient ID, and order set IDs
- [ ] Do not click or send keys in dry-run mode
- [ ] Keep normal bridge behavior unchanged
- [ ] Validate with AutoHotkey v2 `/Validate`
```

## 4. Record app-side AHK pending/reissue behavior

Repository: `akaza-lab-org/clinic-app`

Title:

```text
[kensin-ahk] Review pending/unissued recovery path for AHK order execution
```

Body:

```text
Goal:
Confirm the reception/doctor UI exposes a clear recovery path when AHK order execution is skipped, fails, or is saved without issue.

Acceptance criteria:
- [ ] Review current `run_ahk_order` behavior
- [ ] Confirm audit log detail for success/failure
- [ ] Confirm UI labels distinguish pending, failed, and done
- [ ] Add tests if any behavior is missing
- [ ] Update docs if operational guidance changes
```

## 5. Harden USB release workflow for sub PC

Repository: `akaza-lab-org/clinic-app`

Title:

```text
[deploy] Harden sub-PC USB release packaging and handoff workflow
```

Body:

```text
Goal:
Make the clinic sub PC the safe release workstation for generating portable ZIPs, transferring them by USB, and applying light fixes without overwriting production settings.

Context:
The sub PC connects to the EMR-side production environment by USB. It is mainly used for ZIP generation/distribution and small fixes.

Acceptance criteria:
- [ ] Confirm `build_portable.bat` excludes development-only files
- [ ] Confirm generated ZIP contains release_manifest.json
- [ ] Document USB folder layout and handoff process
- [ ] Confirm production `settings.json` is preserved by update scripts
- [ ] Confirm AHK `config.ini` is not overwritten during handoff
- [ ] Run `pytest`
```

## Follow-up Candidate: Audit tracked generated/sample files in kensin

Repository: `akaza-lab-org/clinic-app`

Title:

```text
[cleanup] Audit tracked generated and sample files
```

Body:

```text
Goal:
Review root-level generated files, debug logs, PDFs, images, and spreadsheet samples in the kensin repository and decide which should be removed, moved under docs/samples, or kept.

Context:
While preparing Issue #1, an AI-generated plan identified additional tracked files such as `error.txt`, `ipconfig_full.txt`, generated PDFs, images, and spreadsheet/text samples. Some may be disposable, but others may be documentation or operational samples.

Acceptance criteria:
- [ ] List tracked root-level generated/sample candidates with current git status
- [ ] Confirm whether each file is referenced by tests, docs, build scripts, or operations
- [ ] Remove only confirmed disposable files
- [ ] Move useful samples to an appropriate documented location if needed
- [ ] Add specific `.gitignore` rules only for confirmed generated artifacts
- [ ] Avoid broad root ignores such as `/*.pdf`, `/*.xlsx`, or `/*.jpg` unless explicitly justified
- [ ] Run `pytest`
- [ ] Keep unrelated local changes untouched
```
