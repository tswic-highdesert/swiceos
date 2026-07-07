#!/usr/bin/env bash
# Package this Claude Skill into an upload-ready .zip (for Claude Team/Enterprise org upload).
# Usage: ./package.sh   (run from inside the skill folder)
#
# Produces dist/sw-review-subcontract.zip whose top-level entry is the skill folder
# with SKILL.md inside — the structure Claude Team/Enterprise expects on upload.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$(basename "$HERE")"
PARENT="$(dirname "$HERE")"
DIST="$HERE/dist"

if [[ ! -f "$HERE/SKILL.md" ]]; then
  echo "ERROR: $HERE/SKILL.md not found. Run this from inside the skill folder." >&2
  exit 1
fi

mkdir -p "$DIST"
ZIP="$DIST/$SKILL.zip"
rm -f "$ZIP"

# Zip from the parent so the archive contains "<skill>/SKILL.md ...".
# Exclude OS cruft, the dist folder itself, and the (large) diagrams if not needed.
( cd "$PARENT" && zip -r -q "$ZIP" "$SKILL" -x "*.DS_Store" -x "__MACOSX/*" -x "$SKILL/dist/*" )

echo "Built: $ZIP"
echo "Contents:"
unzip -l "$ZIP"
