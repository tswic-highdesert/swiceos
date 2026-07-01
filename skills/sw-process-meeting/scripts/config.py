#!/usr/bin/env python3
"""Shared config + provider resolution for the meeting pipeline.

Secrets come from the environment. Supply them however this machine manages
secrets: a secrets manager that injects env vars (Infisical, direnv, Doppler,
...), the shell environment, or a local `.env` in the current directory (honored
only as a fallback). Never hardcode a key here.
"""
import os
import sys
from pathlib import Path


def load_env() -> None:
    """Best-effort: load a .env from CWD if python-dotenv is present.

    Env vars injected by a secrets manager already live in os.environ, so this
    is only a fallback. Silently does nothing if dotenv is absent or no .env.
    """
    try:
        from dotenv import load_dotenv
    except ImportError:
        return
    for candidate in (Path.cwd() / ".env", Path.cwd().parent / ".env"):
        if candidate.exists():
            load_dotenv(candidate)
            return


def require_env(*names: str) -> str:
    """Return the first env var that is set among `names`, or exit with a clear
    message naming all the accepted keys. Accepting several names lets the
    universal scripts stay compatible with older project-specific key names."""
    for n in names:
        val = os.getenv(n)
        if val:
            return val
    joined = " / ".join(names)
    sys.exit(
        f"ERROR: none of these env vars are set: {joined}\n"
        f"       Provide one via your secrets manager or shell environment."
    )


def transcribe_provider(cli_value: str | None = None) -> str:
    """assemblyai (default) or whisper-local. CLI flag > env > default."""
    return (cli_value or os.getenv("TRANSCRIBE_PROVIDER") or "assemblyai").strip().lower()


def llm_provider(cli_value: str | None = None) -> str:
    """openrouter (default) or anthropic. CLI flag > env > default."""
    return (cli_value or os.getenv("LLM_PROVIDER") or "openrouter").strip().lower()


def llm_model(cli_value: str | None = None) -> str:
    """Model id for the chosen LLM provider. CLI flag > env > provider default."""
    if cli_value:
        return cli_value
    env = os.getenv("LLM_MODEL")
    if env:
        return env
    prov = llm_provider()
    return {
        "openrouter": "anthropic/claude-sonnet-4-6",
        "anthropic": "claude-sonnet-4-6",
    }.get(prov, "anthropic/claude-sonnet-4-6")
