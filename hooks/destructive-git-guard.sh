#!/usr/bin/env bash
# Block irreversible git operations. First pass.
set -uo pipefail
IN=$(cat)
CMD=""
if command -v jq >/dev/null 2>&1; then CMD=$(echo "$IN" | jq -r '.tool_input.command // empty'); fi

if echo "$CMD" | grep -Eiq 'git +push +.*(--force|-f)( |$)|git +reset +--hard|git +clean +-[a-z]*f[a-z]*d|git +branch +-D|git +checkout +--orphan|filter-repo'; then
  echo "Blocked by destructive-git-guard: that git command can destroy work. If you really mean it, do it by hand outside the OS." >&2
  exit 2
fi
exit 0
