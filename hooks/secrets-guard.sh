#!/usr/bin/env bash
# Block obvious secret writes/echoes/commits. First pass; tune patterns over time.
set -uo pipefail
IN=$(cat)
have_jq() { command -v jq >/dev/null 2>&1; }
field() { if have_jq; then echo "$IN" | jq -r "$1 // empty"; else echo ""; fi; }

CMD=$(field '.tool_input.command')
FILE=$(field '.tool_input.file_path')
CONTENT=$(field '.tool_input.content')
HAYSTACK="$CMD $FILE $CONTENT"

# Patterns: common secret shapes + committing a decrypted secrets file
if echo "$HAYSTACK" | grep -Eiq '(sk-[a-z0-9]{20,}|AKIA[0-9A-Z]{12,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[0-9A-Za-z-]+|secrets\.env)'; then
  echo "Blocked by secrets-guard: this looks like a secret. Store it in Infisical or the age vault, never in a file, command, or commit." >&2
  exit 2
fi
exit 0
