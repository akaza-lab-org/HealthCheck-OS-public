# Pattern: HCOS Repository Onboarding

## Purpose

Use this pattern when adding an application or automation repository to the HCOS operating model.

HCOS rules do not automatically apply to another GitHub repository just because that repository is part of the same organization. Templates, labels, Actions workflows, branch protection, and required checks are repository-local unless GitHub organization settings explicitly provide them.

## Current Active Repositories

### Tier A — Full HCOS Management
Issue/PR templates + branch protection + triage workflow enforced.

| Repository | Purpose | HCOS onboarding status |
| --- | --- | --- |
| `akaza-lab-org/HealthCheck-OS` | Coordination, rules, docs, decision memory | Full HCOS workflow |
| `akaza-lab-org/clinic-app` | Kensin app implementation | Issue/PR templates, queue labels, and Issue triage workflow |
| `akaza-lab-org/AHK_setting` | AutoHotkey integration and EMR bridge scripts | Issue/PR templates, queue labels, and Issue triage workflow |

### Tier B — Advisory Management
PR template only. Tasks tracked via HCOS Issues; PR gates not enforced.

| Repository | Purpose | HCOS onboarding status |
| --- | --- | --- |
| `akaza-lab-org/summarymaker` | Diabetes summary app (Gemini / Next.js / Electron) | PR template applied, advisory review |
| `akaza-lab-org/pdf_digitizer` | PDF coordinate extraction tool (Phase 1-2 only, see ADR-001) | Advisory management |
| `akaza-lab-org/skills` | Shared AI skills (Codex / Claude Code / Antigravity) | PR template, Issue template (skill_change), labels, advisory triage workflow added (skills#4) |
| `akaza-lab-org/ikensho_git` | Medical document / opinion letter generation app | PR template, Issue templates, labels, advisory triage workflow added (ikensho_git#2) |
| `akaza-lab-org/keikakusho` | Care plan document tool (clinical support) | PR template, Issue templates, labels, advisory triage workflow added (keikakusho#7) |
| `akaza-lab-org/DM-kousin` | Diabetes visit recommendation tool (clinical support) | PR template, Issue templates, labels, advisory triage workflow added (DM-kousin#1) |
| `akaza-lab-org/wakumy_apilot` | Round visit / vaccination management tool | PR template, Issue templates, labels, advisory triage workflow added (wakumy_apilot#1) |

### Tier C — Inventory Only
No changes made to these repositories; existence recorded in HCOS only.

| Tool | Location | Notes |
| --- | --- | --- |
| tobu (トブチケ) | Local only | skill exists |
| chatworks | Local only | — |
| 講演会スライド | Google Drive | No repository |

`HCOS PR Policy`, Council workflows, Knowledge workflows, and Decision Memory workflows are currently HealthCheck-OS workflows. Do not assume they are active in application repositories unless `gh workflow list --repo <owner>/<repo> --all` confirms them.

## Onboarding Checklist

For each repository that should participate in HCOS:

1. Add Issue templates under `.github/ISSUE_TEMPLATE/`.
2. Add `.github/pull_request_template.md`.
3. Sync the AI Task Queue labels:
   - `repo:*`
   - `ai:*`
   - `status:*`
   - `safety:*`
   - review and knowledge labels when review routing is needed
4. Add `.github/workflows/issue_triage.yml`.
5. Confirm the templates and workflow are present on the repository default branch.
6. Run a smoke test by creating or editing a non-sensitive test Issue.
7. Confirm labels and the `AI Task Queue triage` comment are applied.
8. Decide whether PR gates are advisory or enforced.
9. If PR gates should be enforced, add the relevant PR workflow and branch protection.

## Template Visibility Rule

GitHub shows Issue templates from the default branch only.

If templates exist on `develop` or a feature branch but not on the default branch, users will not see them in the GitHub Issue chooser.

## Triage vs PR Gates

`issue_triage.yml` is an advisory sorting layer. It can add labels and comments, but it does not approve work, merge code, deploy, or enforce review.

`HCOS PR Policy` is a merge-gate workflow. It only protects a repository when:

- the workflow exists in that repository
- the workflow is active
- branch protection requires the workflow status check
- Human CTO keeps the no-merge-by-AI rule in force

## Cross-Repository Work

Start from the repository closest to the first implementation change:

```text
App behavior -> clinic-app Issue
AHK behavior -> AHK_setting Issue
Cross-agent / policy -> HealthCheck-OS Issue or docs
```

If one task spans repositories, create the first Issue where the first code change will happen, then link paired Issues or PRs in the other repositories.

For medical safety, fee/order logic, EMR/AHK execution flow, destructive data changes, or production deployment approval, stop for Human CTO review even if labels or workflows did not detect the risk.

## Verification Commands

Use these commands before claiming a repository is onboarded:

```powershell
gh label list --repo <owner>/<repo> --limit 100
gh workflow list --repo <owner>/<repo> --all
gh issue list --repo <owner>/<repo> --state open --limit 5
```

For default-branch template checks, confirm the files exist in the default branch through GitHub or a local checkout of that branch.
