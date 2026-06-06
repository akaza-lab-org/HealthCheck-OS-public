import argparse
import sys
from pathlib import Path

# Add project root to sys.path to import hcos
REPO_ROOT = Path(__file__).resolve().parent.parent
DOCS_ROOT = REPO_ROOT / "docs"
sys.path.insert(0, str(REPO_ROOT))

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")




def read_markdown_files(
    directory: Path,
    pattern: str = "*.md",
    add_constraint_tag: bool = False,
    skip_templates: bool = True,
) -> str:
    """Read markdown files in deterministic order and concatenate their contents."""
    if not directory.is_dir():
        return ""
    contents = []
    for filepath in sorted(directory.glob(pattern)):
        if skip_templates and filepath.name.startswith("_"):
            continue
        try:
            text = filepath.read_text(encoding="utf-8").strip()
            if not text:
                continue
            display_path = filepath.relative_to(REPO_ROOT).as_posix()
            contents.append(f"### File: {display_path}")
            if add_constraint_tag:
                contents.append("[ABSOLUTE CONSTRAINT]")
            contents.append(text)
            contents.append("")
        except Exception as e:
            print(f"Warning: Failed to read {filepath}: {e}", file=sys.stderr)
    return "\n".join(contents)


def build_context() -> str:
    """Build the raw AI context by concatenating files in the required order."""
    sections = []

    core_text = read_markdown_files(DOCS_ROOT / "core")
    if core_text:
        sections.append("## Tier 1: Core Knowledge\n" + core_text)

    safety_text = read_markdown_files(DOCS_ROOT / "safety", add_constraint_tag=True)
    if safety_text:
        sections.append("## Tier 2: Safety Rules\n" + safety_text)

    adr_text = read_markdown_files(DOCS_ROOT / "adr")
    if adr_text:
        sections.append("## Tier 3: Architecture Decision Records (ADR)\n" + adr_text)

    pattern_text = read_markdown_files(DOCS_ROOT, "pattern_*.md")
    if pattern_text:
        sections.append("## Tier 4: Implementation Patterns\n" + pattern_text)

    return "\n\n".join(sections).strip() + "\n"


def summarize_context(raw_context: str) -> str:
    """Summarize the raw context using Gemini."""
    try:
        from hcos.gemini.client import GeminiClient
        client = GeminiClient()
    except (ImportError, Exception) as e:
        print(f"Error initializing GeminiClient: {e}", file=sys.stderr)
        print("Falling back to raw context assembly.", file=sys.stderr)
        return raw_context

    prompt = (
        "You are the HCOS Knowledge OS Context Builder.\n"
        "Your task is to summarize the following project knowledge into a cohesive system prompt context for an AI agent.\n"
        "RULES:\n"
        "1. Preserve the meaning of all rules and patterns.\n"
        "2. Any section marked with [ABSOLUTE CONSTRAINT] must be copied verbatim or preserved with no loss of obligations, prohibitions, or stop conditions.\n"
        "3. Output ONLY the summarized markdown text, ready to be used as an AI context.\n\n"
        "--- KNOWLEDGE BASE ---\n\n"
        f"{raw_context}"
    )

    try:
        print("Calling Gemini API to summarize context...", file=sys.stderr)
        return client.generate_text(prompt)
    except Exception as e:
        print(f"Error calling Gemini API: {e}", file=sys.stderr)
        print("Falling back to raw context assembly.", file=sys.stderr)
        return raw_context


def main():
    parser = argparse.ArgumentParser(description="Build AI context from HCOS documentation.")
    parser.add_argument("--output", default="stdout", help="Output destination: 'stdout' or a file path.")
    parser.add_argument("--summarize", action="store_true", help="Use Gemini to summarize the combined context.")
    args = parser.parse_args()

    raw_context = build_context()

    if args.summarize:
        final_context = summarize_context(raw_context)
    else:
        final_context = raw_context

    if args.output == "stdout":
        print(final_context)
    else:
        try:
            output_path = Path(args.output)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(final_context, encoding="utf-8")
            print(f"Successfully wrote AI context to {args.output}", file=sys.stderr)
        except Exception as e:
            print(f"Error writing to {args.output}: {e}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
