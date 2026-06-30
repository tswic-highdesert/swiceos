#!/usr/bin/env bash
# Manual safe updater: fast-forward-only pull of stable, then relink.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"; cd "$REPO"
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Core has uncommitted changes. Move your work into local/ first."; exit 1
fi
git fetch origin stable && git pull --ff-only origin stable
[ -x "$REPO/tools/link.sh" ] && "$REPO/tools/link.sh" || true
echo "Up to date."
