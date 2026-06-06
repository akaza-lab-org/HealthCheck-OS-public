# Project Re-entry Checklist

Use this checklist when restarting a repository or local tool that has been quiet for more than a few weeks.

The goal is to re-enter gently: understand the current state, avoid stale assumptions, and create a narrow first Issue before changing behavior.

## 1. Identify the Project

- Confirm repository URL and local path.
- Confirm default branch and active development branch, if any.
- Read `README.md`, `AGENTS.md`, or project-specific onboarding notes if present.
- Check whether HCOS classifies the project as Tier A, Tier B, or Tier C in `docs/repo_catalog.md`.

## 2. Check GitHub State

Run these before implementation:

```powershell
gh issue list --repo <owner>/<repo> --state open --limit 20
gh pr list --repo <owner>/<repo> --state open --limit 20
gh workflow list --repo <owner>/<repo> --all
gh label list --repo <owner>/<repo> --limit 100
```

Record anything surprising in the new Issue or handoff note.

## 3. Check Local State

- Review `git status --short --branch`.
- Do not delete or revert unrelated local files.
- Identify untracked logs, exports, samples, or generated artifacts before running tests.
- Confirm environment files and secrets are local-only and not staged.
- Confirm the project can be opened without using patient data.

## 4. Rebuild the Mental Model

- What user workflow does this project support?
- What is the smallest useful next improvement?
- What data enters the system, and what leaves it?
- Does the project interact with EMR, AHK, PDF output, external AI, email/chat, or patient outreach?
- What is the current source of truth for records, settings, and audit history?

## 5. Safety Review

Stop for Human CTO decision if the first planned change touches:

- medical decision logic
- fee/order logic
- EMR/AHK execution flow
- destructive data changes
- production deployment approval
- patient outreach or reminder rules
- PHI-bearing external output

For external AI workflows, confirm whether original PHI, masked images, derived text, or summaries are sent outside the local machine.

## 6. Create the First Narrow Issue

The first Issue after re-entry should be small and observable.

Include:

- current repo and local path
- current runnable state
- specific problem or improvement
- acceptance criteria
- safety notes
- expected files likely to change
- test or manual verification plan

Prefer one small PR over a broad cleanup. If investigation reveals larger debt, create follow-up Issues instead of expanding the first task.

## 7. Handoff

Every re-entry task should leave:

- Issue or task ID
- changed repository and files
- test or manual verification result
- commit hash and push status
- operational caution
- knowledge that should move into docs or a skill
