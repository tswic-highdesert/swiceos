#!/usr/bin/env bash
# Deny edits to core paths unless this is the author's control-plane machine.
set -uo pipefail
IN=$(cat)
REPO="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

# Control-plane machines may edit core freely.
if [ -f "$REPO/local/role" ] && grep -qi 'control-plane' "$REPO/local/role"; then exit 0; fi

FILE=""
if command -v jq >/dev/null 2>&1; then FILE=$(echo "$IN" | jq -r '.tool_input.file_path // empty'); fi
[ -z "$FILE" ] && exit 0

# Allow edits inside local/ and team/; block everything else under the repo.
case "$FILE" in
  "$REPO"/local/*|"$REPO"/team/*) exit 0 ;;
  "$REPO"/*)
    echo "Blocked by core-guard: that file is part of the shared OS (core). Put your change in local/ instead. Core updates itself, so edits here would be overwritten." >&2
    exit 2 ;;
esac
exit 0
