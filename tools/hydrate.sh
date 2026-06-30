#!/usr/bin/env bash
# Mount team repos into team/, from two manifests:
#   team.manifest.json        - shared in core (keep it generic; no private lists)
#   local/team.manifest.json  - private to this machine (gitignored); put real
#                               private repo lists here so they never reach core.
# Reads this machine's groups from local/groups (one tag per line). Clones every
# entry whose group is in that list; entries with no group are always mounted.
# Idempotent: clone if missing, fast-forward pull if present. Never fails the
# session: a repo the person has no access to is just skipped.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"; cd "$REPO"

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

mount_one() {
  local name="$1" remote="$2" group="$3"
  [ -z "$name" ] && return 0
  [ -z "$remote" ] && { echo "  (skipped $name: no remote in manifest)"; return 0; }
  in_groups "$group" || return 0
  local dest="$REPO/team/$name"
  if [ -d "$dest/.git" ]; then
    echo "Updating team/$name"
    git -C "$dest" pull --ff-only --quiet 2>/dev/null || echo "  (could not fast-forward team/$name, leaving as-is)"
  else
    echo "Mounting team/$name"
    git clone --quiet "$remote" "$dest" 2>/dev/null || echo "  (skipped team/$name: no access or clone failed)"
  fi
}

process_manifest() {
  local man="$1"
  [ -f "$man" ] || return 0
  local count; count=$(jq '.repos | length' "$man" 2>/dev/null || echo 0)
  [ "${count:-0}" -eq 0 ] && return 0
  local i=0 name remote group
  while [ "$i" -lt "$count" ]; do
    name=$(jq -r ".repos[$i].name // empty" "$man")
    remote=$(jq -r ".repos[$i].remote // empty" "$man")
    group=$(jq -r ".repos[$i].group // \"\"" "$man")
    i=$((i+1))
    mount_one "$name" "$remote" "$group"
  done
}

found=0
for man in "$REPO/team.manifest.json" "$REPO/local/team.manifest.json"; do
  [ -f "$man" ] || continue
  [ "$(jq '.repos | length' "$man" 2>/dev/null || echo 0)" -gt 0 ] && found=1
  process_manifest "$man"
done
if [ "$found" -eq 0 ]; then
  echo "No team repos listed yet (core or local/ manifest). Nothing to mount."
else
  echo "Team folder hydrated."
fi
