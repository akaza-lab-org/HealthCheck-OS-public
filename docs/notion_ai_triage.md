# Notion to AI Triage

## Purpose

Use Notion and ChatGPT chat as the human-friendly intake layer, then promote actionable work into GitHub Issues with a suggested AI owner.

Notion is for ideas, overview, meeting notes, and non-engineer explanations. GitHub Issues remain the execution record.

## Recommended Shape

```text
Notion idea / meeting note
  -> ChatGPT triage and formatting
  -> GitHub Issue in the target repo
  -> Codex / Claude / Gemini reads the Issue
  -> implementation, review, verification, commit, push
```

Do not ask agents to implement directly from a Notion note. Promote the task to GitHub first when code, tests, deployment, or operational changes are needed.

## Notion Database Fields

Keep the Notion side lightweight:

| Field | Purpose |
| --- | --- |
| Title | Human-readable idea or problem |
| Status | Inbox / Drafted / Issue created / In progress / Done / Archived |
| Area | kensin / AHK / HealthCheck-OS / operations / unknown |
| Urgency | Now / Soon / Later |
| Safety | medical logic / patient data risk / deployment risk / ordinary |
| Suggested repo | clinic-app / AHK_setting / HealthCheck-OS / undecided |
| Suggested AI | Codex / Claude / Gemini / human review first |
| GitHub Issue | Canonical URL after creation |
| Notes | Human context, links, screenshots without identifiers |

## Triage Rules

Use the smallest safe owner:

| Task type | Suggested destination |
| --- | --- |
| App UI/API/DB/tests/distribution | `clinic-app` Issue, Codex |
| AHK bridge, QR, EMR operation script | `AHK_setting` Issue, Codex or Gemini first for workflow |
| Architecture, medical-safety workflow, policy | HealthCheck-OS docs/Issue, Claude review |
| CSV, import/export, DB structure, requirement gaps | Gemini draft, then GitHub Issue |
| Cross-repo deployment or sub-PC operation | HealthCheck-OS first, then linked repo Issues |
| Medical decision logic, fee logic, order logic | Human review first, then Claude review before implementation |

If uncertain, create a HealthCheck-OS coordination Issue or ask ChatGPT to classify the note before creating repo-specific Issues.

## ChatGPT Triage Prompt

```text
HealthCheck-OS のルールに従って、以下のNotionメモをトリアージしてください。

目的:
- GitHub Issue化すべきか判断する
- 対象repoを選ぶ
- 担当AIを提案する
- 必要ならIssueタイトルとMarkdown本文を作る

Notionメモ:
---
<ここに貼る>
---

出力:
1. 判定: Issue化する / Notionに残す / 人間確認が先
2. 対象repo:
3. 推奨AI:
4. 安全上の注意:
5. GitHub Issue title:
6. GitHub Issue body:

ルール:
- 患者情報・端末秘密・本番ログは含めない
- 医療判断ロジック、料金ロジック、EMR/AHK実行フローは単独AI実装にしない
- スコープを狭くする
- 隣接作業はOut of scopeまたはFollow-up candidateに分ける
```

## Promotion Checklist

Before creating the GitHub Issue:

```text
- [ ] Patient identifiers removed
- [ ] Repository selected
- [ ] Scope is narrow
- [ ] Acceptance criteria are testable
- [ ] Safety cautions are explicit
- [ ] Suggested AI role is recorded
- [ ] Notion page will receive the final GitHub Issue URL
```

## Backlink Rule

After posting the GitHub Issue, paste the Issue URL back into Notion. After an agent finishes the task, the Issue or PR is the source of truth for implementation history.
