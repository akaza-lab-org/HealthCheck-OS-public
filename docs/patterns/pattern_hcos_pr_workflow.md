# HCOS PR Workflow

## System Concept

PR = Execution Unit
Issue = Intent
Docs = Organizational Memory (HCOS Knowledge)

## Development Flow

Gem -> GitHub Issue -> Codex Implementation -> Claude Review -> Knowledge Promotion -> Merge

## Codex PR Creation Rule

Codex must not commit directly to `main`.

For implementation work:

1. Read the linked Issue first.
2. Create a branch named `feature/<issue-number>-short-name`.
3. Implement only inside Issue scope.
4. Push the branch.
5. Open a PR against `main`.
6. Use the title `[HCOS] <Issue Title>`.
7. Fill the standard PR template.

## Claude Review Protocol

Every PR receives a Claude Architecture & Safety Review request.

Claude must review:

1. Code correctness
2. Architecture alignment
3. Medical safety validation
4. PHI safety validation
5. Knowledge promotion judgment

Claude output must include:

```text
PR Review: Approve / Request Changes

Knowledge Promotion:
- None
- Pattern
- ADR
- Safety Rule
```

## Knowledge Promotion

Codex evaluates promotion candidates **during implementation** (not after review):

### Codex Self-Evaluation Checklist (before submitting PR):

1. **Non-obvious design decision?** Did I make a choice that another implementer will face again?
   → If yes, candidate for Pattern or ADR

2. **Safety constraint?** Did I encounter a safety consideration that constrains future choices?
   → If yes, candidate for Safety Rule

3. **Workaround or failure mode?** Did I discover a constraint or failure pattern worth preserving?
   → If yes, candidate for ADR

4. **Future agent value?** Would a future AI reading `AGENTS.md` benefit from a pointer to this knowledge?
   → If yes, add to Read First list

If promotion is warranted, Codex must add the durable knowledge to `docs/` in the same PR:

- Pattern: `docs/pattern_<name>.md`
- ADR: `docs/adr_<number>_<name>.md`
- Safety Rule: `docs/safety_<name>.md`

Codex must then add the promoted doc to the `AGENTS.md` Read First list, commit to the same PR branch, and push the update before requesting review.

If Codex is unsure whether promotion is warranted, describe the candidate in the PR body; Claude will decide during review.

## Merge Policy

PRs may be merged only when:

- Claude approved
- Tests passing
- Safety checks complete

Use squash and merge.

Make `HCOS PR Policy` a required branch-protection status check on `main` so GitHub blocks merges that do not satisfy the gate.

## Post-Merge Automation

After merge, automation closes the linked Issue when the PR body includes `Closes #<issue-number>` and updates `CHANGELOG.md`.

The changelog entry records:

- Feature
- Safety Rule added, if any
- ADR added, if any

## Design Principle

Code disappears.
Knowledge accumulates.

PRs are temporary.
Docs are permanent.

Always promote reusable intelligence into `docs/`.
