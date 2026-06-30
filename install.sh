#!/usr/bin/env bash
# One-time setup for a machine. Normally invoked by tools/bootstrap.sh (which a
# new person's Claude runs for them), but safe to run directly and to re-run.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
ROLE="${1:-operator}"   # pass 'control-plane' on the author's machine

# 1. private ring
mkdir -p "$REPO/local/knowledge/meetings"
[ -f "$REPO/local/role" ] || echo "$ROLE" > "$REPO/local/role"
[ -f "$REPO/local/groups" ] || : > "$REPO/local/groups"   # team access tags, one per line
cp -n "$REPO"/local.example/* "$REPO/local/" 2>/dev/null || true

# 2. commit-time backstop (survives clone via core.hooksPath)
git -C "$REPO" config core.hooksPath .githooks || true

# 3. make tools/hooks executable
chmod +x "$REPO"/hooks/*.sh "$REPO"/tools/*.sh "$REPO"/.githooks/* 2>/dev/null || true

# 4. live the OS in every project (symlink skills/agents to user scope)
"$REPO/tools/link.sh"

# 5. register the safety hooks in ~/.claude/settings.json (auto-merge, idempotent)
SETTINGS="$HOME/.claude/settings.json"
FRAG="$REPO/settings.fragment.json"
mkdir -p "$HOME/.claude"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
if command -v jq >/dev/null 2>&1; then
  tmp="$(mktemp)"
  # For each hook event in the fragment, drop any prior SwiceOS entries (matched
  # by the $CLAUDE_PROJECT_DIR/hooks/ marker) and append the current ones. This
  # leaves unrelated hooks untouched and is safe to run repeatedly.
  if jq --slurpfile frag "$FRAG" '
        (.hooks //= {})
        | reduce ($frag[0].hooks | keys[]) as $evt (.;
            .hooks[$evt] = (
              ((.hooks[$evt] // []) | map(select(
                ([.hooks[]?.command // ""] | any(contains("CLAUDE_PROJECT_DIR/hooks/"))) | not
              )))
              + $frag[0].hooks[$evt]
            )
          )
      ' "$SETTINGS" > "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
    mv "$tmp" "$SETTINGS"
    echo "Safety hooks registered in $SETTINGS"
  else
    rm -f "$tmp"
    echo "WARNING: could not auto-merge hooks. Merge settings.fragment.json into $SETTINGS by hand."
  fi
else
  echo "jq not found, so hooks were not auto-registered."
  echo "Install jq and re-run, or merge settings.fragment.json into $SETTINGS by hand."
fi

echo "Role set to: $ROLE"
echo "Done."
