#!/usr/bin/env bash
# One-time white-glove install. Run by the person setting up a machine.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
ROLE="${1:-operator}"   # pass 'control-plane' on the author's machine

# 1. private ring
mkdir -p "$REPO/local/knowledge"
[ -f "$REPO/local/role" ] || echo "$ROLE" > "$REPO/local/role"
[ -d "$REPO/local/knowledge/meetings" ] || mkdir -p "$REPO/local/knowledge/meetings"
cp -n "$REPO"/local.example/* "$REPO/local/" 2>/dev/null || true

# 2. commit-time backstop (survives clone via core.hooksPath)
git -C "$REPO" config core.hooksPath .githooks || true

# 3. make tools/hooks executable
chmod +x "$REPO"/hooks/*.sh "$REPO"/tools/*.sh "$REPO"/.githooks/* 2>/dev/null || true

# 4. live the OS in every project (symlink skills/agents to user scope)
"$REPO/tools/link.sh"

# 5. register hooks in user settings (manual step for now)
echo
echo "Almost done. Add this folder's hooks to ~/.claude/settings.json by merging"
echo "the contents of settings.fragment.json (replace \$CLAUDE_PROJECT_DIR with"
echo "$REPO). A jq auto-merge will be wired in a later pass."
echo
echo "Role set to: $ROLE"
echo "Done."
