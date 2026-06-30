#!/usr/bin/env bash
# Zero-touch onboarding. A new person's Claude runs this once on a fresh
# machine; it is safe to re-run any time. Sets up the private local/ ring,
# registers the safety hooks, links the OS into every project, and mounts any
# shared team/ repos this person has access to. The human never types a command.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
ROLE="${1:-operator}"   # pass 'control-plane' only on the author's machine

"$REPO/install.sh" "$ROLE"
"$REPO/tools/hydrate.sh"

echo
echo "SwiceOS is ready. Just ask for what you need in plain English."
