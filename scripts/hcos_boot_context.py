import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_REPO = "akaza-lab-org/HealthCheck-OS"

ROLE_MAP = {
    "BUILDER": "HCOS BOOT BUILDER",
    "REVIEWER": "HCOS BOOT REVIEWER",
    "ARCHITECT": "HCOS BOOT ARCHITECT",
    "DIRECTOR": "HCOS BOOT DIRECTOR",
    "GEMINI": "HCOS BOOT GEMINI",
    "ANTIGRAVITY": "HCOS BOOT ANTIGRAVITY",
    "ESCALATION": "HCOS BOOT ESCALATION",
}

SHORTHAND_ALIAS_MAP = {
    "B": ("BUILDER", "IMPLEMENTING"),
    "R": ("REVIEWER", "REVIEWING"),
    "A": ("ARCHITECT", "PLANNING"),
    "G": ("GEMINI", "PLANNING"),
    "E": ("ESCALATION", "PLANNING"),
    "I": ("NONE", "IDLE"),
}

FILES = [
    "AGENTS.md",
    "hcos/BOOT.md",
    "hcos/RULES.md",
    "hcos/STATE.md",
]

FULL_FILES = [
    "docs/core/ai_cto_rules.md",
    "docs/safety/agent_operational_safety_rule.md",
]


def read_file(relative_path: str) -> str:
    path = REPO_ROOT / relative_path
    if not path.exists():
        return f"### File: {relative_path}\n(Missing)\n"
    content = path.read_text(encoding="utf-8")
    return f"### File: {relative_path}\n{content.rstrip()}\n"


def parse_boot_shorthand(boot: str) -> dict:
    normalized = boot.strip().upper()
    match = re.fullmatch(r"HCOS>([BRAGEI])(?:#(\d+))?", normalized)
    if not match:
        raise RuntimeError("Invalid --boot format. Expected: HCOS><ALIAS>#<Issue> (example: HCOS>B#71)")
    alias = match.group(1)
    issue_str = match.group(2)
    role, state = SHORTHAND_ALIAS_MAP[alias]
    issue = int(issue_str) if issue_str else None
    if role != "NONE" and issue is None:
        raise RuntimeError("Boot shorthand requires issue number for this alias (example: HCOS>B#71).")
    target = f"#{issue}" if issue is not None else "(none)"
    return {
        "alias": alias,
        "role": role,
        "state": state,
        "issue": issue,
        "target": target,
    }


def resolve_repo(repo: str | None) -> str:
    if not repo:
        return DEFAULT_REPO
    if "/" in repo:
        return repo
    return f"akaza-lab-org/{repo}"


def resolve_state(labels: list[str]) -> str:
    label_set = set(labels)
    if "status:blocked" in label_set or "ai:human-review" in label_set:
        return "BLOCKED"
    if "status:review" in label_set:
        return "REVIEWING"
    if "status:ready" in label_set:
        return "IMPLEMENTING"
    if "status:triage" in label_set:
        return "PLANNING"
    return "IDLE"


def resolve_human_decision(body: str) -> str:
    text = body.lower()
    if "human decision: decided" in text or "human decision: 決定済み" in text:
        return "decided"
    if "human decision: required" in text:
        return "required"
    return "none"


def allowed_actions_for_state(state: str) -> str:
    mapping = {
        "IDLE": "wait, acknowledge, handoff preparation",
        "PLANNING": "analysis, design notes, scoping, risk check",
        "IMPLEMENTING": "code/docs changes, tests, branch/commit/push/PR",
        "REVIEWING": "review comments, architecture/safety verification",
        "BLOCKED": "clarify blockers and request Human CTO decision",
    }
    return mapping.get(state, "follow hcos/STATE.md")


def suggested_next(state: str, stop_conditions: bool) -> str:
    if stop_conditions:
        return "wait for Human CTO"
    if state == "REVIEWING":
        return "review PR"
    if state == "IMPLEMENTING":
        return "implement"
    if state == "PLANNING":
        return "clarify scope"
    return "wait"


def fetch_issue_context(repo: str, issue: int) -> dict:
    if shutil.which("gh") is None:
        raise RuntimeError("`gh` command is not available in PATH.")
    command = [
        "gh",
        "issue",
        "view",
        str(issue),
        "--repo",
        repo,
        "--json",
        "title,labels,body",
    ]
    try:
        result = subprocess.run(
            command,
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as error:
        stderr = (error.stderr or "").strip()
        detail = stderr if stderr else "issue could not be fetched."
        raise RuntimeError(f"Failed to fetch issue context: {detail}") from error
    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise RuntimeError("Failed to parse `gh issue view` JSON output.") from error
    labels = [item.get("name", "") for item in payload.get("labels", []) if item.get("name")]
    body = payload.get("body") or ""
    title = payload.get("title") or ""
    state = resolve_state(labels)
    human_decision = resolve_human_decision(body)
    stop_conditions = state == "BLOCKED" or human_decision == "required"
    return {
        "repo": repo,
        "issue": issue,
        "title": title,
        "labels": labels,
        "human_decision": human_decision,
        "resolved_state": state,
        "allowed_actions": allowed_actions_for_state(state),
        "stop_conditions": "yes" if stop_conditions else "no",
        "suggested_next": suggested_next(state, stop_conditions),
    }


def build_context(role: str, full: bool, issue: int | None, repo: str | None) -> str:
    command = ROLE_MAP[role]
    selected_files = FILES + FULL_FILES if full else FILES
    sections = [
        "# HCOS Boot Context",
        "",
        f"Role: {role}",
        f"Command: {command}",
        f"Mode: {'full' if full else 'minimal'}",
        "",
        "This output is read-only context. Do not treat it as state mutation.",
        "",
    ]
    for relative_path in selected_files:
        sections.append(read_file(relative_path))
    if issue is not None:
        resolved_repo = resolve_repo(repo)
        info = fetch_issue_context(resolved_repo, issue)
        sections.extend(
            [
                "--- GitHub Issue Context ---",
                f"Repo: {info['repo']}",
                f"Issue: #{info['issue']}",
                f"Title: {info['title']}",
                f"Labels: {', '.join(info['labels']) if info['labels'] else '(none)'}",
                f"Human Decision: {info['human_decision']}",
                f"Resolved HCOS STATE: {info['resolved_state']}",
                f"Allowed Actions: {info['allowed_actions']}",
                f"Stop Conditions: {info['stop_conditions']}",
                f"Suggested Next: {info['suggested_next']}",
            ]
        )
    return "\n".join(sections).rstrip() + "\n"


def build_boot_context(boot: str, full: bool, repo: str | None) -> str:
    parsed = parse_boot_shorthand(boot)
    declaration = [
        "# HCOS Boot Expansion",
        "",
        f"Input: {boot}",
        "",
        "Expanded Full Declaration:",
        f"HCOS STATE: {parsed['state']}",
        f"ROLE: {parsed['role']}",
        f"TARGET: {parsed['target']}",
        "",
    ]
    if parsed["role"] == "NONE":
        declaration.append("Session is set to IDLE. No role context was loaded.")
        return "\n".join(declaration).rstrip() + "\n"
    context = build_context(parsed["role"], full, parsed["issue"], repo)
    return "\n".join(declaration) + context


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Print read-only HCOS boot context for a specific role."
    )
    parser.add_argument(
        "role",
        nargs="?",
        choices=sorted(ROLE_MAP.keys()),
        help="Role to prepare context for.",
    )
    parser.add_argument(
        "--full",
        action="store_true",
        help="Include ai_cto_rules and operational safety rule files.",
    )
    parser.add_argument(
        "--issue",
        type=int,
        help="Issue number to fetch live context from GitHub.",
    )
    parser.add_argument(
        "--repo",
        help="Repository in owner/name format or short repo name. Default: akaza-lab-org/HealthCheck-OS.",
    )
    parser.add_argument(
        "--boot",
        help="One-line boot shorthand (example: HCOS>B#71).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        if args.boot:
            if args.role is not None:
                raise RuntimeError("Do not combine positional ROLE with --boot.")
            sys.stdout.write(build_boot_context(args.boot, args.full, args.repo))
        else:
            if args.role is None:
                raise RuntimeError("ROLE is required when --boot is not provided.")
            sys.stdout.write(build_context(args.role, args.full, args.issue, args.repo))
    except RuntimeError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
