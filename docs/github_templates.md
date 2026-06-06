# GitHub Templates

## Registered Templates

Issue and PR templates are registered in the working repositories so new plans can start directly from GitHub Issues. Issue templates include the AI Task Queue header where available.

Templates must be present on the repository's default branch to appear in GitHub's issue chooser. `clinic-app` and `AHK_setting` both use `main` as the default branch, so templates are mirrored there.

Templates are repository-local. Adding or updating a template in HealthCheck-OS does not automatically change the templates shown in `clinic-app`, `AHK_setting`, or future application repositories. Use `docs/pattern_hcos_repo_onboarding.md` when extending this workflow to another repository.

## clinic-app

Use this repo for app work:

- UI/API/DB/PDF/distribution changes
- app-side AHK bridge behavior
- reception/doctor/control workflow changes

Templates:

- `simple-ai-draft.md`
- `kensin-app-task.yml`
- `kensin-ahk-task.yml`
- `pull_request_template.md`

## AHK_setting

Use this repo for AutoHotkey work:

- QR scanner handling
- bridge scripts
- EMR operation logic
- config migration behavior

Templates:

- `simple-ai-draft.md`
- `ahk-bridge-task.yml`
- `pull_request_template.md`

## HealthCheck-OS

Use this repo for coordination:

- cross-agent rules
- repo-role definitions
- release/sub-PC operation docs
- shared lessons and decision logs

## Drafting Rule

Start with the repo closest to the work:

```text
App behavior -> clinic-app Issue
AHK behavior -> AHK_setting Issue
Cross-agent / policy -> HealthCheck-OS Issue or docs
```

If a task crosses app and AHK, create the first issue in the repo where the first implementation change should happen, then link the paired issue in the other repo if needed.

## Simple AI Draft Template

Use `simple-ai-draft.md` when a Gem or mobile AI has already shaped the Issue body.

This template intentionally avoids required categories and form fields. Paste the AI-drafted Markdown into the body, then review it for:

- patient identifiers
- production logs or screenshots with identifiers
- terminal secrets or credentials
- uncertain claims
- overly broad scope

Use the structured YAML templates when drafting directly on GitHub and the Issue still needs queue fields, acceptance criteria, or safety prompts.

For private repository Issue access from agents, see `docs/github_issue_access.md`.

## Repository-Local Scope

The current related repositories have Issue/PR templates, but PR gates are not implied by templates alone.

Before assuming a repository has the same HCOS enforcement as HealthCheck-OS, verify:

```powershell
gh workflow list --repo <owner>/<repo> --all
gh label list --repo <owner>/<repo> --limit 100
```

As of 2026-05-30, `clinic-app` and `AHK_setting` have Issue/PR templates and active Issue triage workflows. `HCOS PR Policy` and Knowledge/Council workflows are HealthCheck-OS workflows unless separately added to the target repository.

## Execution Attribution Field

The HealthCheck-OS PR template may include an `Execution Attribution` section for human-readable attribution such as the primary implementing AI or supporting reviewer/design AI.

This field is advisory only.

- It is not an authentication mechanism.
- It is not part of approval or merge-gate logic.
- It must not be used as a substitute for Claude review.

For `HCOS PR Policy`, only PR Reviews returned by the Review API are evaluated for the Claude approval signal.

## gh CLI Review Constraint

`gh pr review --request-changes` fails with a GraphQL error when the authenticated user is the PR author:

```
failed to create review: GraphQL: Review Can not request changes on your own pull request
```

When reviewing a PR you authored, use `gh pr review --comment` instead (this creates a PR Review with state `COMMENTED`, which the merge gate does check):

```powershell
gh pr review <number> --repo <owner>/<repo> --comment --body "PR Review: Approve

<review body here>"
```

> **Note:** `gh pr comment` creates a regular PR/issue comment, **not** a PR Review. The merge gate calls `pulls.listReviews` and does not see regular comments. Only reviews submitted via the Review API (including `COMMENTED`-state reviews) are evaluated for the `PR Review: Approve` signal.
