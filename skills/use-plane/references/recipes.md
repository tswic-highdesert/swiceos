# Plane recipes

Copy-paste recipes for the Norristown Plane instance. All use
`scripts/plane.sh`, which resolves config and auth and never prints the key. For
raw curl, every request needs the header `X-API-Key: <PAT>` and a trailing
slash on the path.

Conventions to keep in every recipe:

- No em dashes anywhere. Use commas, periods, or parentheses.
- No-dump curation: only open, current, source-cited work. Every issue
  description carries a `Source:` line and an `Owner:` line.
- Sleep about 1.05s between writes in any loop (60 requests/min per key).

## 1. Smoke test (auth)

```bash
scripts/plane.sh whoami
```

200 with a body means the key resolved. A 401 means the key is missing or wrong;
check the vault `[plane]` section or `PLANE_API_KEY`.

## 2. List and create a project

```bash
scripts/plane.sh projects                       # see what exists first
scripts/plane.sh project WCAP                    # one project by identifier
scripts/plane.sh create-project "WhiteCap Waste" WCAP
```

`identifier` must be short, uppercase, and unique. It becomes the human-id
prefix (`WCAP-1`). Create returns `{id, ...}`.

## 3. Create the shared 6-label taxonomy

Reuse the exact same six labels in every project. Note the 1.05s sleeps.

```bash
IDENT=WCAP
for pair in \
  "rock #8B5CF6" \
  "issue #EF4444" \
  "to-do #3B82F6" \
  "blocker #DC2626" \
  "data-quality #F59E0B" \
  "client-ask #10B981"; do
  name=${pair%% *}; color=${pair##* }
  scripts/plane.sh create-label "$IDENT" "$name" "$color"
  sleep 1.05
done

scripts/plane.sh labels "$IDENT"                 # read back the ids
```

## 4. Create one curated issue (Source + Owner, no em dashes)

Every issue body carries a `Source:` line and an `Owner:` line. Owners are named
in the description, not set as assignees, until they are confirmed workspace
members. The field is `name` (not title); rich body is `description_html`.

```bash
scripts/plane.sh create-issue WCAP "Reconcile Navusoft disposal tonnage for Jan" '{
  "priority": "high",
  "description_html": "<p>Jan disposal tonnage in the dashboard does not match the Navusoft export. Confirm the earned-period revenue figure.</p><p>Source: WhiteCap ISSUES.md (2026-06-17).</p><p>Owner: Garth.</p>"
}'
```

To attach labels, resolve their ids first (`scripts/plane.sh labels WCAP`), then
pass `"labels": ["<label_uuid>", ...]` in the JSON. The seed flow (recipe 5)
resolves label names to ids for you.

## 5. Bulk-seed from a JSON spec

The seed verb creates projects, then the 6 labels, then issues, with rate-limit
sleeps. It is idempotent: it reuses an existing project by identifier, skips
labels that already exist by name, and skips issues whose `name` already exists.
Labels on issues are given by name and resolved to ids automatically.

Spec shape (`seed-wcap.json`):

```json
{
  "projects": [
    {
      "name": "WhiteCap Waste",
      "identifier": "WCAP",
      "labels": [
        { "name": "rock",         "color": "#8B5CF6" },
        { "name": "issue",        "color": "#EF4444" },
        { "name": "to-do",        "color": "#3B82F6" },
        { "name": "blocker",      "color": "#DC2626" },
        { "name": "data-quality", "color": "#F59E0B" },
        { "name": "client-ask",   "color": "#10B981" }
      ],
      "issues": [
        {
          "name": "Reconcile Navusoft disposal tonnage for Jan",
          "priority": "high",
          "labels": ["data-quality"],
          "description_html": "<p>Jan tonnage in the dashboard does not match the Navusoft export.</p><p>Source: WhiteCap ISSUES.md (2026-06-17).</p><p>Owner: Garth.</p>"
        },
        {
          "name": "Wire per-customer phone and email for SMS",
          "priority": "medium",
          "labels": ["to-do"],
          "description_html": "<p>Customer phone and email are the remaining gap for O1 SMS.</p><p>Source: whitecap-customer-data-location memory.</p><p>Owner: Tal.</p>"
        }
      ]
    }
  ]
}
```

Run it:

```bash
scripts/plane.sh seed seed-wcap.json
```

The output lists created ids and human ids (`WCAP-1`, ...). Re-running is safe;
existing projects, labels, and same-name issues are skipped.

## 6. Update an issue's state or priority

State changes need the target state UUID. List states, pick the one whose
`group` matches the column you want (`started` = In Progress, `completed` =
Done), then patch.

```bash
scripts/plane.sh states WCAP                      # find the state UUID by group
scripts/plane.sh update-issue WCAP-1 '{"state":"<state_uuid>"}'
scripts/plane.sh update-issue WCAP-1 '{"priority":"urgent"}'
```

Use the `group` field for status logic, not the display name, since names are
renameable.

## 7. Add a comment

```bash
scripts/plane.sh comment WCAP-1 "Owner confirmed. Pulling the Navusoft export now."
```

For richer or threaded comments use the passthrough:

```bash
# resolve project_id and work_item_id first via 'scripts/plane.sh issue WCAP-1'
scripts/plane.sh api POST \
  "/api/v1/workspaces/norristown-capital-ai/projects/<pid>/work-items/<iid>/comments/" \
  '{"comment_html":"<p>Internal note.</p>","access":"INTERNAL"}'
```

## 8. Filter and report on work-items

Documented list filtering is limited to `external_*`. For real filtering by
state, label, assignee, or priority, use advanced-search (the `filters` grammar
is not publicly enumerated; discover it live).

```bash
# expanded list for a readable status view
scripts/plane.sh issues WCAP

# simple text search across the workspace
scripts/plane.sh api GET \
  "/api/v1/workspaces/norristown-capital-ai/work-items/search/?search=tonnage"

# advanced search (discover the filters grammar empirically)
scripts/plane.sh api POST \
  "/api/v1/workspaces/norristown-capital-ai/work-items/advanced-search/" \
  '{"query":"","project_id":"<pid>","limit":50}'
```

## No-dump curation guidance

Before seeding any board:

- Seed only open, current work that has a real human source. If it is closed,
  stale, or speculative, leave it out.
- Never bulk-import machine-generated snapshots. The EOSClaw "Mission Control"
  output at `~/.openclaw/mission-control/` is reference-only and stale. Curate
  from fresh human docs (meeting notes, WhiteCap ISSUES.md, Alloy
  onboarding-checklist, BP Open Perm brief) under
  `~/Desktop/Projects/norristown/`.
- Every issue description gets a `Source:` line (where it came from) and an
  `Owner:` line (who holds it). Owners stay in the description until they are
  confirmed workspace members and can be set as real assignees.
- Leave `NORRI` (Plane's auto-seeded demo project) untouched.
- Held from round 1 as too thin, stale, or mis-categorized: Matador Gas,
  Angstrom, EAS/Scanco (thin/flagged sources); PRN Healthcare (a prospect, not a
  portco); Magazine Capital, EPG, AMMCO (team, not portcos).
