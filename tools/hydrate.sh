#!/usr/bin/env bash
# Mount team repos into team/, from two manifests:
#   team.manifest.json        - shared in core (keep it generic; no private lists)
#   local/team.manifest.json  - private to this machine (gitignored); put real
#                               private repo lists here so they never reach core.
#
# Layout: repos mount under their team, at team/<group>/<name>. An entry marked
# "home": true mounts at the team root (team/<group>/) instead, so that repo can
# carry team/<group>/CLAUDE.md and team standards that apply across the whole
# team subtree. Home repos are cloned first so the team root is empty for them.
#
# Reads this machine's groups from local/groups (one tag per line). Clones every
# entry whose group is in that list; entries with no group are always mounted
# (flat, at team/<name>). Idempotent: clone if missing, fast-forward if present.
# Never fails the session: a repo the person has no access to is just skipped.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"; cd "$REPO"

if ! command -v jq >/dev/null 2>&1; then
  echo "hydrate needs jq. Install jq, then re-run tools/hydrate.sh."; exit 0
fi

GROUPS_FILE="$REPO/local/groups"
MANIFESTS=("$REPO/team.manifest.json" "$REPO/local/team.manifest.json")
mkdir -p "$REPO/team"

in_groups() {
  local g="$1"
  if [ -z "$g" ] || [ "$g" = "null" ]; then return 0; fi   # no group = everyone
  [ -f "$GROUPS_FILE" ] || return 1
  grep -qxF "$g" "$GROUPS_FILE"
}

# dest path for an entry, honoring group subfolder + home-at-root
dest_for() {
  local name="$1" group="$2" home="$3"
  if [ -z "$group" ] || [ "$group" = "null" ]; then echo "$REPO/team/$name"; return; fi
  if [ "$home" = "true" ]; then echo "$REPO/team/$group"; else echo "$REPO/team/$group/$name"; fi
}

clone_or_update() {
  local remote="$1" dest="$2" label="$3"
  if [ -d "$dest/.git" ]; then
    echo "Updating $label"
    git -C "$dest" pull --ff-only --quiet 2>/dev/null || echo "  (could not fast-forward $label, leaving as-is)"
  else
    echo "Mounting $label"
    git clone --quiet "$remote" "$dest" 2>/dev/null || echo "  (skipped $label: no access or clone failed)"
  fi
}

# Pass over every manifest entry; only_home=1 processes home repos, 0 the rest.
process_pass() {
  local only_home="$1" man count i name remote group home dest label
  for man in "${MANIFESTS[@]}"; do
    [ -f "$man" ] || continue
    count=$(jq '.repos | length' "$man" 2>/dev/null || echo 0)
    [ "${count:-0}" -eq 0 ] && continue
    i=0
    while [ "$i" -lt "$count" ]; do
      name=$(jq -r ".repos[$i].name // empty" "$man")
      remote=$(jq -r ".repos[$i].remote // empty" "$man")
      group=$(jq -r ".repos[$i].group // \"\"" "$man")
      home=$(jq -r ".repos[$i].home // false" "$man")
      i=$((i+1))
      [ "$home" = "true" ] && [ "$only_home" != "1" ] && continue
      [ "$home" != "true" ] && [ "$only_home" = "1" ] && continue
      [ -z "$name" ] && [ "$home" != "true" ] && continue
      [ -z "$remote" ] && { echo "  (skipped ${name:-home}: no remote in manifest)"; continue; }
      in_groups "$group" || continue
      dest=$(dest_for "${name:-home}" "$group" "$home")
      label="team/${dest#"$REPO"/team/}"
      MOUNTED=1
      clone_or_update "$remote" "$dest" "$label"
    done
  done
}

MOUNTED=0
process_pass 1   # home repos first (team root must be empty to clone into)
process_pass 0   # then the rest, into subfolders
if [ "$MOUNTED" -eq 0 ]; then
  echo "No team repos listed yet (core or local/ manifest). Nothing to mount."
else
  echo "Team folder hydrated."
fi
