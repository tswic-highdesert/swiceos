#!/usr/bin/env bash
# Symlink core skills and agents into ~/.claude so the OS is live in every
# project. Falls back to copy on platforms without symlinks (e.g. some Windows).
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/agents"
link_one() { ln -sfn "$1" "$2" 2>/dev/null || cp -R "$1" "$2"; }
for d in "$REPO"/skills/*/; do [ -d "$d" ] && link_one "$d" "$HOME/.claude/skills/$(basename "$d")"; done
for f in "$REPO"/agents/*.md; do [ -f "$f" ] && link_one "$f" "$HOME/.claude/agents/$(basename "$f")"; done
