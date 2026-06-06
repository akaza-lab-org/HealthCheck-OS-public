"""Gemini configuration loader for HCOS local scripts."""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv

_REPO_ROOT = Path(__file__).resolve().parents[2]
_DEFAULT_ENV_PATH = _REPO_ROOT / "secret" / ".env"

# Characters that Python interprets as escape sequences inside .env string values
# when Windows path separators are misread.
_WINDOWS_ENV_ESCAPE_FIXES = {
    "\a": "a",
    "\b": "b",
    "\f": "f",
    "\n": "n",
    "\r": "r",
    "\t": "t",
    "\v": "v",
}


def _repair_windows_path_escapes(raw_path: str) -> str:
    repaired: list[str] = []
    for ch in str(raw_path or ""):
        replacement = _WINDOWS_ENV_ESCAPE_FIXES.get(ch)
        if replacement is None:
            repaired.append(ch)
            continue
        # Re-insert a separator before the escaped character so the path stays valid.
        if repaired and repaired[-1] not in {"\\", "/"}:
            repaired.append(os.sep)
        repaired.append(replacement)
    return "".join(repaired)


def _normalize_google_credentials_env() -> None:
    """Fix GOOGLE_APPLICATION_CREDENTIALS when dotenv mis-parses Windows paths."""
    raw = str(os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or "").strip().strip('"').strip("'")
    if not raw:
        return
    if Path(raw).exists():
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = raw
        return

    for candidate in [raw.replace("\\", "/"), _repair_windows_path_escapes(raw)]:
        if candidate and Path(candidate).exists():
            os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = candidate
            return


@dataclass
class GeminiConfig:
    """Runtime configuration for Gemini API access."""

    use_vertex_ai: bool = False
    gemini_api_key: str = ""
    google_cloud_project: str = ""
    google_cloud_location: str = "global"
    default_gemini_model: str = "gemini-2.5-flash"

    @classmethod
    def from_env(cls, env_path: Optional[str] = None) -> "GeminiConfig":
        """Load config from .env file and process environment.

        Args:
            env_path: Path to .env file. Defaults to secret/.env at repo root.
        """
        path = env_path or str(_DEFAULT_ENV_PATH)
        load_dotenv(path, override=False)
        _normalize_google_credentials_env()

        return cls(
            use_vertex_ai=str(os.getenv("VERTEX_AI", "0")).strip() == "1",
            gemini_api_key=(os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY") or "").strip(),
            google_cloud_project=(os.getenv("GOOGLE_CLOUD_PROJECT") or "").strip(),
            google_cloud_location=(os.getenv("GOOGLE_CLOUD_LOCATION") or "global").strip(),
            default_gemini_model=(os.getenv("DEFAULT_GEMINI_MODEL") or "gemini-2.5-flash").strip(),
        )

    def validate(self) -> list[str]:
        """Return a list of configuration errors. Empty list means valid."""
        errors: list[str] = []
        if self.use_vertex_ai:
            if not self.google_cloud_project:
                errors.append("VERTEX_AI=1 requires GOOGLE_CLOUD_PROJECT.")
        else:
            if not self.gemini_api_key:
                errors.append("VERTEX_AI=0 requires GEMINI_API_KEY.")
        return errors

    @property
    def backend_name(self) -> str:
        return "Vertex AI" if self.use_vertex_ai else "Google AI Studio"
