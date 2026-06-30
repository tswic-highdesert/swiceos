#!/usr/bin/env bash
# Mount team repos listed in team.manifest.json into team/.
# Reads this machine's groups from local/groups (one per line). Clones every
# manifest entry whose group is in that list; entries with no group are always
# mounted. Idempotent: clone if missing, fast-forward pull if already present.
# Never fails the session: a repo the person has no access to is just skipped.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"; cd "$REPO"
MAN="$REPO/team.manifest.json"
[ -f "$MAN" ] || { echo "No team.manifest.json; nothing to mount."; exit 0; }

if ! command -v jq >/dev/null 2>&1; then
  echo "hydrate needs jq. Install jq, then re-run tools/hydrate.sh."; exit 0
fi

GROUPS_FILE="$REPO/local/groups"
mkdir -p "$REPO/team"

in_groups() {
  local g="$1"
  if [ -z "$g" ] || [ "$g" = "null" ]; then return 0; fi   # no group = everyone
  [ -f "$GROUPS_FILE" ] || return 1
  grep -qxF "$g" "$GROUPS_FILE"
}

count=$(jq '.repos | length' "$MAN" 2>/dev/null || echo 0)
if [ "${count:-0}" -eq 0 ]; then
  echo "team.manifest.json has no repos yet. Nothing to mount."; exit 0
fi

i=0
while [ "$i" -lt "$count" ]; do
  name=$(jq -r ".repos[$i].name // empty" "$MAN")
  remote=$(jq -r ".repos[$i].remote // empty" "$MAN")
  group=$(jq -r ".repos[$i].group // \"\"" "$MAN")
  i=$((i+1))
  [ -z "$name" ] && continue
  [ -z "$remote" ] && { echo "  (skipped $name: no remote in manifest)"; continue; }
  in_groups "$group" || continue
  dest="$REPO/team/$name"
  if [ -d "$dest/.git" ]; then
    echo "Updating team/$name"
    git -C "$dest" pull --ff-only --quiet 2>/dev/null || echo "  (could not fast-forward team/$name, leaving as-is)"
  else
    echo "Mounting team/$name"
    git clone --quiet "$remote" "$dest" 2>/dev/null || echo "  (skipped team/$name: no access or clone failed)"
  fi
done
echo "Team folder hydrated."
