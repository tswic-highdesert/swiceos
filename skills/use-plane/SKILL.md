---
name: use-plane
description: >
  Operate Plane, the open-source project management tool, against any
  self-hosted instance and by default the Norristown Plane workspace. Create and
  inspect projects, labels, states, work-items (issues), cycles, modules,
  members, and comments, run the REST API directly, and bulk-seed curated
  portco project boards. Use this skill whenever the user mentions Plane,
  Norristown project management, portco or company project boards, work-items,
  issues, rocks, sprints, cycles, modules, or seeding and curating a board, even
  if they do not say "Plane" explicitly.
allowed-tools: Bash(curl:*), Bash(age:*), Bash(python3:*), Bash(grep:*), Bash(cut:*), Bash(sleep:*), Bash(infisical:*)
---

# Use Plane

Plane is an open-source project management tool (Jira/Linear style). This skill
drives its REST API. It defaults to the Norristown self-hosted instance but works
against any instance via env config.

The helper for everything below is `scripts/plane.sh`. Run `scripts/plane.sh help`
for the full verb list. The script resolves config and auth, pretty-prints JSON,
and never echoes the API key.

## Plane resource model

- **Workspace** is the top scope. Norristown slug: `norristown-capital-ai`.
- **Project** is a board under a workspace. Has `{id, name, identifier}`, where
  `identifier` is a short uppercase key (`OPS`, `WCAP`) that prefixes human issue
  ids like `OPS-12`.
- **Label** is project-scoped `{id, name, color}`. Norristown reuses one shared
  6-label taxonomy in every project.
- **State** is a workflow column. Use the `group` field (`backlog`, `unstarted`,
  `started`, `completed`, `cancelled`, `triage`) for status logic, not the
  display name, since names are renameable.
- **Work-item (issue)** is the unit of work. The title field is `name` (NOT
  `title`). Rich body is `description_html`. `priority` is an enum
  (`urgent|high|medium|low|none`). `labels` and `assignees` are arrays of UUIDs.
  Create returns `{id, sequence_id}`. Plane is migrating "issues" to
  "work-items"; both `/issues/` and `/work-items/` return 200 on this version,
  and the script standardizes on `/work-items/`.
- **Cycle** is a time-boxed sprint. **Module** is a feature grouping. Both can
  hold work-items.

## Auth and config

Every request sends the header `X-API-Key: <PAT>`. The script resolves config in
this order:

1. `PLANE_BASE_URL` (default `https://plane-production-ee4d.up.railway.app`)
2. `PLANE_WORKSPACE` (default `norristown-capital-ai`)
3. `PLANE_API_KEY`, resolved in order and never printed:
   1. the env var, if set;
   2. the age vault `[plane]` section, if this machine has
      `~/.config/age/key.txt` and `~/secrets/secrets.env.age` (Tal's machine);
   3. Infisical: `infisical secrets get PLANE_API_KEY --env prod --plain`
      against the `plane` project (id baked into the script; override with
      `INFISICAL_PROJECT_ID`). Requires a prior `infisical login`. This is
      the path on machines without the age vault (Garth's machine).

Never hardcode, echo, or paste the PAT. To point at a different Plane instance,
export `PLANE_BASE_URL`, `PLANE_WORKSPACE`, and `PLANE_API_KEY` before calling
the script.

### Preflight: smoke-test auth before any write

```bash
scripts/plane.sh whoami      # GET /api/v1/users/me/ -> 200 with key, 401 without
```

## Common quick operations

Handle these without loading a reference:

```bash
scripts/plane.sh whoami                       # auth check
scripts/plane.sh projects                     # list projects in the workspace
scripts/plane.sh project OPS                   # one project by identifier
scripts/plane.sh issues OPS                    # work-items in a project (expanded)
scripts/plane.sh issue OPS-12                  # one work-item by human id
scripts/plane.sh labels OPS                    # labels in a project
scripts/plane.sh states OPS                    # states in a project
scripts/plane.sh members                       # workspace members
scripts/plane.sh create-project "WhiteCap Waste" WCAP
scripts/plane.sh create-label OPS rock '#8B5CF6'
scripts/plane.sh create-issue OPS "Wire SMTP" '{"priority":"high"}'
scripts/plane.sh update-issue OPS-12 '{"priority":"urgent"}'
scripts/plane.sh comment OPS-12 "Owner confirmed, in progress."
scripts/plane.sh api GET /api/v1/users/me/     # raw passthrough escape hatch
```

## Routing

For anything beyond the quick operations, load the reference that matches the
intent. One reference is usually enough, two at most.

| Intent | Reference | Use for |
|---|---|---|
| **Seed or curate a board** ("seed WCAP", "set up a portco board", "add the taxonomy") | [recipes.md](references/recipes.md) | Copy-paste recipes: smoke test, create project, create the 6 labels, write a curated issue with Source/Owner, bulk-seed from a JSON spec, update state, add a comment, plus the no-dump rules |
| **API mechanics and gotchas** ("what is the endpoint for", "filter by state", "pagination", "cycles/modules/members/links/attachments") | [api.md](references/api.md) | Full REST reference: auth, projects, work-items with filter/expand, labels, states, cycles, modules, members, comments, links, attachments, pagination cursors, rate limits, field names |

## Norristown conventions (enforce these)

- **Shared 6-label taxonomy**, reused in every project, exact hex:
  `rock` `#8B5CF6`, `issue` `#EF4444`, `to-do` `#3B82F6`, `blocker` `#DC2626`,
  `data-quality` `#F59E0B`, `client-ask` `#10B981`.
- **No em dashes** in any name or description. Use commas, periods, or
  parentheses instead.
- **No-dump curation.** Seed only open, current, source-cited work. Never
  bulk-import stale or machine-generated snapshots. Every work-item description
  carries a `Source:` line and an `Owner:` line. Name owners in the description
  until they are confirmed workspace members and can be real assignees.
- **Existing seeded projects:** `OPS` (Norristown Ops), `WCAP` (WhiteCap Waste),
  `ALLY` (Alloy Group), `BPES` (BP Environmental). `NORRI` is Plane's
  auto-seeded demo project. Leave `NORRI` untouched; do not seed into it.
- **Reference-only, never seed from:** the EOSClaw "Mission Control" rig output
  at `~/.openclaw/mission-control/` is stale and machine-generated. Curate from
  fresh human docs under `~/Desktop/Projects/norristown/`.

## Execution rules

1. Smoke-test auth (`whoami`) before any mutation.
2. Pull the PAT from the vault `[plane]` section. Never inline or echo it.
3. Sleep about 1.05s between writes in any loop (60 requests/min per key).
4. Reuse the shared 6-label taxonomy. Resolve label ids per project before
   attaching them to issues.
5. No em dashes anywhere.
6. No-dump: only open, current, source-cited work, with `Source:` and `Owner:`
   lines in every issue description.
7. Read back created ids and sequence ids after writes.

## Safety: confirm-first and never-auto

Reads are safe. Confirm intent and state the impact before any of these:

| Action | Why |
|---|---|
| Delete a project, work-item, label, or state | Irreversible board data loss |
| Bulk-import from stale or machine-generated snapshots | Violates no-dump curation |
| Change instance god-mode, signup, or auth settings | Security and auth scope |

Deletes are intentionally not exposed as convenience verbs in the script. If a
delete is truly needed, use the `api DELETE <path>` passthrough only after the
user confirms.

## Response format

Return: what was done, the result (ids, identifiers, counts), and what is next.
Keep it concise.
