#!/usr/bin/env bash
# Validate the install and offer recovery.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"; cd "$REPO"
echo "Repo: $REPO"
echo "Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
echo "Role: $(cat local/role 2>/dev/null || echo 'operator (default)')"
[ -d local ] && echo "local/ present" || echo "WARNING: local/ missing"
echo "If core looks broken, recover with: git reset --hard origin/stable"
echo "(safe: it does not touch your gitignored local/ or team/)"
