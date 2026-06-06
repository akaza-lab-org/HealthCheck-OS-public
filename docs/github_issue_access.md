# GitHub Issue Access

## Purpose

Agents need GitHub Issue access to use Issues as the first draft and task handoff surface.

For private repositories, browser-based web access from the agent may show `404`. Use GitHub CLI (`gh`) from the local machine instead.

## One-Time Setup

GitHub CLI is installed on the main PC via winget.

If `gh` is not available after install, restart the shell or use the installed path under:

```text
%LOCALAPPDATA%\Microsoft\WinGet\Packages\GitHub.cli_*\bin\gh.exe
```

Authenticate once:

```powershell
gh auth login
```

Recommended choices:

```text
GitHub.com
HTTPS
Login with a web browser
```

If the agent reports this message, authentication has not been completed on that Windows user profile:

```text
You are not logged into any GitHub hosts. To log in, run: gh auth login
```

In that case, a human operator must complete the browser login. Agents should not ask for, print, paste, or store GitHub tokens.

Recommended explicit login command:

```powershell
gh auth login --hostname github.com --git-protocol https --web
```

If browser login is not possible, use a personal access token only through the official `gh auth login --with-token` prompt or a temporary local environment variable. Do not write the token into this repository, scripts, docs, shell history snippets, or agent chat.

After login, verify:

```powershell
gh auth status
gh issue list --repo akaza-lab-org/clinic-app
gh issue view 1 --repo akaza-lab-org/clinic-app
```

For this coordination workflow, verify all active private repositories:

```powershell
gh repo view akaza-lab-org/HealthCheck-OS
gh repo view akaza-lab-org/clinic-app
gh repo view akaza-lab-org/AHK_setting
```

## Agent Preflight

Before an agent claims it has read, updated, or commented on a GitHub Issue, it should run:

```powershell
gh auth status
gh issue view <number> --repo <owner>/<repo>
```

The agent must compare the returned Issue title with the requested task. Do not infer a GitHub Issue number from a numbered checklist or backlog document.

GitHub Issue numbers are assigned by GitHub and cannot be renamed or edited directly. Editing an Issue title or body from the web UI only changes text, not the real number shown in the URL.

Issue and Pull Request numbers share the same repository-wide number sequence. Always use the canonical reference after creation:

```text
akaza-lab-org/clinic-app#2
https://github.com/akaza-lab-org/clinic-app/issues/2
```

If authentication fails, the agent should stop before pretending the Issue was updated and provide the exact Issue comment or command for a human to run after login.

MCP tools such as GitKraken issue tools are optional convenience paths. For HealthCheck-OS operations, `gh` is the canonical fallback because it runs from the local authenticated Windows profile.

## Posting Issue Comments

After authentication, add a prepared handoff comment with:

```powershell
gh issue comment 1 --repo akaza-lab-org/clinic-app --body-file .\handoff_issue_1.md
```

For short comments:

```powershell
gh issue comment 1 --repo akaza-lab-org/clinic-app --body "Status: verified on develop; pytest still required before main merge."
```

Do not commit temporary `handoff_*.md` files unless they contain durable cross-agent knowledge. Prefer deleting them after posting the Issue comment.

## Agent Usage

When asking an agent to work from an Issue:

```text
HealthCheck-OS の AGENTS.md に従ってください。
対象repo: clinic-app
Issue: #123
役割: Codex = 実装担当

Issue内容を gh issue view で読んで実装してください。
完了後はテスト、commit、push、結果報告までお願いします。
```

Reusable development-PC prompts for Codex, Claude, and Gemini live in `docs/development_pc_agent_prompts.md`.

## Mobile Issue Drafting

When away from the development PC, use AI chat as a drafting assistant and GitHub mobile/web as the posting surface.

For reusable background, paste or attach `docs/mobile_ai_context.md` into the mobile AI chat or Gem. Keep Gem instructions short and use the context pack as the shared project brief.

For private GitHub repositories, do not rely on a mobile AI reading a pasted GitHub URL. Open the file yourself and share the text, or attach a Google Drive copy to the Gem.

Recommended flow:

1. Tell the AI the target repository, rough problem, urgency, and any safety concern.
2. Ask the AI to format a GitHub Issue title and Markdown body.
3. Review the text yourself, removing patient identifiers, logs, screenshots, terminal secrets, and uncertain claims.
4. Post it from GitHub mobile/web.
5. Later, ask a local agent to read the created Issue with `gh issue view <number> --repo <owner>/<repo>`.

Mobile-created Issues may be rough. Agents should refine them by adding a comment or editing the body after confirming the real Issue number and title.

Suggested mobile prompt:

```text
HealthCheck-OS のルールに従って、GitHub Issueとして投稿できる形に整形してください。
対象repo:
困っていること:
期待する状態:
制約・安全上の注意:
受け入れ条件:
対象外:

患者情報・端末秘密・本番ログは含めないでください。
タイトルとMarkdown本文だけ出してください。
```

## Template Visibility Rule

GitHub Issue templates and forms must be present on the repository's default branch.

For these repos, the default branch is `main`:

- `clinic-app`
- `AHK_setting`

Templates were also developed on `develop` or feature branches, but GitHub will not show them in the issue chooser until they are merged or cherry-picked into `main`.

Current status:

- `clinic-app/main` has Issue and PR templates.
- `AHK_setting/main` has Issue and PR templates.

## If Issues Still Cannot Be Read

Check:

```powershell
gh auth status
gh repo view akaza-lab-org/clinic-app
gh issue view 1 --repo akaza-lab-org/clinic-app
```

If access fails, confirm that the GitHub account used by `gh auth login` has access to the private organization repository.
