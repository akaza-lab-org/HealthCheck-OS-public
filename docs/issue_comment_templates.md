# Issue Comment Templates

Use these templates when agents report completion, pause for a Human CTO decision, or hand off work to another agent.

Do not paste patient identifiers, production logs, screenshots with identifiers, terminal secrets, or credentials.

## State Declaration Header

Use this as the first block in every Issue/PR interaction.

```text
HCOS STATE: <PLANNING | IMPLEMENTING | REVIEWING | BLOCKED>
ROLE: <BUILDER | REVIEWER | ARCHITECT | DIRECTOR>
TARGET: #<issue-or-pr-number>
```

## Completion Comment

```text
Result:

Changed repo:

Changed files:

Commit:

Push:

Tests / verification:

Not done / out of scope:

Operational caution:

Docs promoted:
```

## Human Decision Required

Use this when any AI CTO Stop Condition applies.

```text
Human decision required:

Reason:

Affected area:

Risk:

Options:
1.
2.
3.

Recommended next step:

Implementation paused:
```

## Agent Handoff

Use this when one AI has finished its role and another AI or human should act next.

```text
Handoff:

Current status:

What I checked:

What changed:

Open questions:

Suggested next owner:

Suggested next action:

Verification still required:
```

## Mobile Codex Request

Use this when the Human CTO leaves a phone-friendly GitHub comment for a PC-side Codex session.

```text
Codex request:

Target:
Goal:

Allowed:
- Inspect GitHub Issue/PR comments and labels.
- Edit files within the stated scope.
- Run local verification.
- Commit, push, and open a PR.

Prohibited:
- Do not merge.
- Do not apply production settings or destructive changes.
- Do not include patient data, identifiers, production logs, screenshots with identifiers, terminal secrets, or credentials.

Completion:
- Leave an Issue/PR comment with changed files, commit, verification, and remaining cautions.
```

## Dry-run Only Request

Use this when the Human CTO wants findings before allowing any write action.

```text
Dry-run only:

Target:

Allowed:
- Inspect current repo/GitHub state.
- Run read-only checks and dry-run commands.
- Post findings.

Prohibited:
- Do not write files.
- Do not push.
- Do not apply labels/settings/production operations.
- Do not merge.
```

## Human Merge Handoff

Use this when review is complete and the PR is waiting only for the Human CTO merge operation.

```text
Human merge handoff:

PR:
State: review complete / checks passing / ready for Human CTO merge decision
Label: handoff:human-merge

AI agents must not merge this PR.
```

## Claude Review Request

Use this when requesting Claude to review a PR or Issue for architecture, safety, and scope.

```text
Claude review request:

Target: <PR or Issue URL>
Review focus:
- Architecture and safety risks
- Scope drift
- Missing tests or verification
- Whether Human CTO decision is needed

Expected output:
- Approve only if safe to proceed.
- Otherwise list requested changes or open questions.
```

## Follow-up Candidate

Use this when adjacent work is discovered but should not expand the current Issue.

```text
Follow-up candidate:

Found while working on:

Why it is out of scope:

Suggested repo:

Suggested AI owner:

Suggested safety level:

Draft title:

Draft acceptance criteria:
- [ ]
```
