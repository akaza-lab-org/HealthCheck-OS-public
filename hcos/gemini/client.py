"""Gemini API client utilities for HCOS local scripts.

Supports two backends via GeminiConfig.use_vertex_ai:
- Vertex AI (project/location + service account)
- Google AI Studio (api_key)
"""

from __future__ import annotations

import re
import time
from typing import Optional

from google import genai
from google.genai import types

from hcos.gemini.config import GeminiConfig

MODEL_ID_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{1,127}$")


def normalize_model_id(model_id: str) -> str:
    """Normalize and validate a Gemini model ID."""
    normalized = str(model_id or "").strip().strip('"').strip("'")
    if not normalized:
        raise ValueError("Model ID is empty.")
    if normalized.startswith("=") or normalized in {"=", "=.", "."}:
        raise ValueError(
            f"Invalid model ID: {normalized!r}. "
            "Use a value like 'gemini-2.5-flash'."
        )
    if not MODEL_ID_PATTERN.match(normalized):
        raise ValueError(
            f"Invalid model ID format: {normalized!r}. "
            "Use a value like 'gemini-2.5-flash'."
        )
    return normalized


def _build_http_options() -> types.HttpOptions:
    return types.HttpOptions(
        timeout=600_000,
        retryOptions=types.HttpRetryOptions(attempts=5),
    )


def create_gemini_client(config: Optional[GeminiConfig] = None) -> genai.Client:
    """Create a Gemini client from config.

    Args:
        config: GeminiConfig instance. Loads from secret/.env if None.
    """
    if config is None:
        config = GeminiConfig.from_env()

    http_options = _build_http_options()

    if config.use_vertex_ai:
        if not config.google_cloud_project:
            raise ValueError("GOOGLE_CLOUD_PROJECT is required when VERTEX_AI=1.")
        print(
            f"[Gemini] Vertex AI client initialized "
            f"(project={config.google_cloud_project}, location={config.google_cloud_location})"
        )
        return genai.Client(
            vertexai=True,
            project=config.google_cloud_project,
            location=config.google_cloud_location,
            http_options=http_options,
        )

    if not config.gemini_api_key:
        raise ValueError("GEMINI_API_KEY is required when VERTEX_AI=0.")
    print("[Gemini] Google AI Studio client initialized")
    return genai.Client(
        api_key=config.gemini_api_key,
        http_options=http_options,
    )


def generate_text(
    prompt: str,
    model_id: Optional[str] = None,
    config: Optional[GeminiConfig] = None,
    max_retries: int = 3,
) -> str:
    """Generate text from a prompt using Gemini.

    Args:
        prompt: Text prompt to send.
        model_id: Model ID override. Uses config.default_gemini_model if None.
        config: GeminiConfig instance. Loads from secret/.env if None.
        max_retries: Number of retry attempts on transient errors.
    """
    if config is None:
        config = GeminiConfig.from_env()
    client = create_gemini_client(config)
    resolved_model = normalize_model_id(model_id or config.default_gemini_model)

    contents = [types.Content(role="user", parts=[types.Part(text=prompt)])]
    last_error: Optional[Exception] = None

    for attempt in range(max_retries):
        try:
            print(f"[Gemini] Request start (attempt {attempt + 1}/{max_retries}, model={resolved_model})")
            response = client.models.generate_content(model=resolved_model, contents=contents)
            text = str(getattr(response, "text", "") or "").strip()
            print(f"[Gemini] Request complete (chars={len(text)})")
            return text
        except Exception as e:
            last_error = e
            if attempt == max_retries - 1:
                raise
            print(f"[Gemini] Retry ({attempt + 1}/{max_retries}): {e}")
            time.sleep(attempt + 1)

    raise last_error  # type: ignore[misc]


class GeminiClient:
    """High-level Gemini client with lazy initialization.

    Usage:
        client = GeminiClient()
        text = client.generate_text("Hello, world!")
    """

    def __init__(self, config: Optional[GeminiConfig] = None):
        if config is None:
            config = GeminiConfig.from_env()
        self.config = config
        self._client: Optional[genai.Client] = None

    @property
    def client(self) -> genai.Client:
        if self._client is None:
            self._client = create_gemini_client(self.config)
        return self._client

    @property
    def default_model(self) -> str:
        return normalize_model_id(self.config.default_gemini_model)

    def generate_text(
        self,
        prompt: str,
        model_id: Optional[str] = None,
        max_retries: int = 3,
    ) -> str:
        resolved_model = normalize_model_id(model_id or self.default_model)
        contents = [types.Content(role="user", parts=[types.Part(text=prompt)])]
        last_error: Optional[Exception] = None

        for attempt in range(max_retries):
            try:
                print(f"[Gemini] Request start (attempt {attempt + 1}/{max_retries}, model={resolved_model})")
                response = self.client.models.generate_content(model=resolved_model, contents=contents)
                text = str(getattr(response, "text", "") or "").strip()
                print(f"[Gemini] Request complete (chars={len(text)})")
                return text
            except Exception as e:
                last_error = e
                if attempt == max_retries - 1:
                    raise
                print(f"[Gemini] Retry ({attempt + 1}/{max_retries}): {e}")
                time.sleep(attempt + 1)

        raise last_error  # type: ignore[misc]
