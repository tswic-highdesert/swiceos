#!/usr/bin/env bash
# Scaffold a new portco repo in the standard SwiceOS layout and wire it into the
# team so every teammate's hydrate mounts it.
#
# Usage: scaffold-portco.sh <slug> "<Display Name>" [group]
#   slug          kebab-case folder/repo name, e.g. total-environmental
#   Display Name  human name, e.g. "Total Environmental"
#   group         team group (default: norristown)
#
# Does NOT create the Gitea remote (push-to-create is disabled for the org) and
# does NOT push. It prints the remaining manual steps at the end.
set -euo pipefail

SLUG="${1:-}"; NAME="${2:-}"; GROUP="${3:-norristown}"
if [ -z "$SLUG" ] || [ -z "$NAME" ]; then
  echo "usage: scaffold-portco.sh <slug> \"<Display Name>\" [group]" >&2
  exit 2
fi
if ! printf '%s' "$SLUG" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "slug must be kebab-case (lowercase, digits, dashes): got '$SLUG'" >&2
  exit 2
fi

REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
GITEA_HOST="ssh://git@samson-1.tail7839d6.ts.net:2222"
# Capitalize the first letter for the Gitea org name (portable; macOS bash 3.2 has no ${x^}).
ORG="$(printf '%s' "$GROUP" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
REMOTE="$GITEA_HOST/$ORG/$SLUG.git"   # e.g. .../Norristown/<slug>.git
DEST="$REPO/team/$GROUP/$SLUG"

if [ -e "$DEST" ]; then
  echo "refusing to overwrite existing $DEST" >&2
  exit 1
fi

echo "Scaffolding $NAME at team/$GROUP/$SLUG ..."
mkdir -p "$DEST/brain/_source" "$DEST/video" "$DEST/meetings/notes"
: > "$DEST/meetings/notes/.gitkeep"

cat > "$DEST/CLAUDE.md" <<EOF
# $NAME - Project Context

## Organization

- **$NAME** is a <what the business does>.
- <ownership / family / how it relates to sibling portcos; do not conflate>.

## Key People

- **<Sponsor>** - <role>. Sponsor of this engagement.
- **<Operating contact>** - <role, email, phone>.
- **Tal, Garth** - Norristown Capital, driving the AI enablement.

## Engagement Status (as of $(date +%Y-%m-%d))

- Onboarded from kickoff material. Summarize what arrived and the asks.

## AI Opportunity Areas (initial hypothesis)

- <opportunity 1>
- <opportunity 2>

## Operating Principles

- Inherits the broader team context from \`../CLAUDE.md\`.
- The AI brain in \`brain/\` is the source of truth for this company's domain
  knowledge. Keep it in OKF markdown and preserve originals under \`brain/_source/\`.
EOF

cat > "$DEST/README.md" <<EOF
# $NAME

Portfolio-company workspace for **$NAME**.

Start with \`CLAUDE.md\` for the who/what/status. Then:

- \`brain/\` - the AI brain: this company's domain knowledge base. Originals in \`brain/_source/\`.
- \`video/\` - the AI video pipeline: the ask, current drafts, chosen engine.
- \`meetings/notes/\` - meeting notes as they happen (OKF format).

Onboarded $(date +%Y-%m-%d) via the \`sw-onboard-portco\` skill.
EOF

cat > "$DEST/brain/README.md" <<EOF
# $NAME AI Brain

The domain knowledge base for $NAME. Source of truth for how the business's
market works, so sales and ops can act fast.

## Contents

- \`<topic>.md\` - OKF notes, one concept per file.
- \`_source/\` - the original documents, preserved unchanged.

## Provenance

Seeded <date> from <who>. Keep it current: treat these as living notes.

## Note on frontmatter type

Domain reference notes use \`type: reference\`. The core OKF vocabulary does not
include it, so per \`standards/okf-frontmatter.md\` this is the one-line decision
record: a portco brain may use \`type: reference\` for domain reference material.
EOF

cat > "$DEST/video/README.md" <<EOF
# $NAME AI Video Pipeline

## The ask

<who> wants <what: evergreen hero video, repeatable pipeline, ...>.

## Current state

- Draft(s): <links>

## Recommended path

- Hero video (one-off, high polish): lock script/message first, then produce.
- Repeatable pipeline: \`/hyperframes\` for brand-controlled reusable video, or
  HeyGen for fast presenter output, usually a blend.

## Next actions

- [ ] Confirm hero-video content/message with the sponsor (blocking).
- [ ] Choose the pipeline engine against the recurring formats wanted.
- [ ] Pull brand assets (logo, colors, fonts) into a template.
EOF

cat > "$DEST/.gitignore" <<EOF
.DS_Store
.venv/
__pycache__/
*.env
secrets.env
*.key
.tmp/
EOF

echo "Committing initial scaffold ..."
git -C "$DEST" init -q -b main
git -C "$DEST" add -A
git -C "$DEST" -c user.name="SwiceOS" -c user.email="ops@norristowncapital.com" \
  commit -q -m "Onboard $NAME portco: standard scaffold (sw-onboard-portco)"
git -C "$DEST" remote add origin "$REMOTE"

# --- wire into the team ---
MAN="$REPO/local/team.manifest.json"
if command -v jq >/dev/null 2>&1 && [ -f "$MAN" ] && ! jq -e --arg n "$SLUG" '.repos[]|select(.name==$n)' "$MAN" >/dev/null 2>&1; then
  jq --arg n "$SLUG" --arg r "$REMOTE" --arg g "$GROUP" \
    '.repos += [{"name":$n,"remote":$r,"group":$g}]' "$MAN" > "$MAN.tmp" && mv "$MAN.tmp" "$MAN"
  echo "Added $SLUG to local/team.manifest.json"
fi

GI="$REPO/team/$GROUP/.gitignore"
if [ -f "$GI" ] && ! grep -qxF "/$SLUG/" "$GI"; then
  printf '/%s/\n' "$SLUG" >> "$GI"
  echo "Added /$SLUG/ to team/$GROUP/.gitignore"
fi

echo
echo "Done. Remaining manual steps:"
echo "  1. Create the empty repo in the Gitea org ($ORG): web UI 'New Repository',"
echo "     or POST /api/v1/orgs/$ORG/repos on the ${GROUP}capital.com tailscale profile."
echo "  2. Push:   git -C team/$GROUP/$SLUG push -u origin main"
echo "  3. Grant teammates access to the matching Gitea team (so hydrate mounts it)."
echo "  4. Fill in $DEST/CLAUDE.md, brain/, and video/ from the intake."
