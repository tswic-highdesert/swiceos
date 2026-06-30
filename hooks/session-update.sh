#!/usr/bin/env bash
# Auto-pull the shared OS (stable) once a day. Silent unless something changed.
# Never blocks the session: always exits 0.
set -uo pipefail

REPO="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$REPO" 2>/dev/null || exit 0

# Control-plane machines (the author) do not auto-pull; they are upstream.
if [ -f "$REPO/local/role" ] && grep -qi 'control-plane' "$REPO/local/role"; then
  exit 0
fi

STATE="$REPO/.os-state"; mkdir -p "$STATE"
STAMP="$STATE/last-update"
NOW=$(date +%s)
if [ -f "$STAMP" ]; then
  LAST=$(cat "$STAMP" 2>/dev/null || echo 0)
  # 86400s = 1 day
  if [ $(( NOW - LAST )) -lt 86400 ]; then exit 0; fi
fi
echo "$NOW" > "$STAMP"

BEFORE=$(git rev-parse HEAD 2>/dev/null || echo none)
git fetch --quiet origin stable 2>/dev/null || exit 0
git pull --ff-only --quiet origin stable 2>/dev/null || exit 0
AFTER=$(git rev-parse HEAD 2>/dev/null || echo none)

if [ "$BEFORE" != "$AFTER" ]; then
  # relink any new skills/agents into user scope (best effort)
  [ -x "$REPO/tools/link.sh" ] && "$REPO/tools/link.sh" >/dev/null 2>&1 || true
  COUNT=$(git rev-list --count "$BEFORE".."$AFTER" 2>/dev/null || echo "")
  MSG="SwiceOS Updated"
  [ -n "$COUNT" ] && MSG="SwiceOS Updated ($COUNT change(s))"
  # Surface a one-line note to the session.
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$MSG"
fi
exit 0
