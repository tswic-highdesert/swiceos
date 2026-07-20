# Plane REST API reference

Live-verified against the Norristown instance (Plane v1.3.x). Base, slug, and
field names below are confirmed. Items marked [INFERRED] follow standard REST
and the documented URL map but were not each opened live. Items marked [FLAG]
are ambiguous in the public docs and should be confirmed empirically.

## 1. Base, versioning, path shape

- Base = instance origin + `/api/v1/...`. Norristown:
  `https://plane-production-ee4d.up.railway.app/api/v1/...`, slug
  `norristown-capital-ai`.
- Most paths are workspace-scoped:
  `/api/v1/workspaces/{workspace_slug}/...`. Use the **slug**, even where a doc
  page labels the segment `workspace_id`.
- **Trailing slash is required** on every path (Django style). Omitting it can
  404 or redirect.
- Only `v1` exists today.
- Shorthand below: `{ws}` = `/api/v1/workspaces/{slug}`,
  `{wp}` = `{ws}/projects/{project_id}`,
  `{wpi}` = `{wp}/work-items/{work_item_id}`.

## 2. Authentication

- Personal Access Token (PAT). Header on every request: `X-API-Key: <token>`.
  `GET /api/v1/users/me/` returns 200 with a valid key, 401 without.
- Mint a PAT in the UI under Profile Settings, Personal Access Tokens, Add
  personal access token. PATs are user and workspace scoped, not per-project.
  Use a dedicated low-privilege service user for integrations.
- OAuth apps instead use `Authorization: Bearer <oauth-access-token>` with
  per-endpoint scopes. For a plain PAT, scopes follow the token owner's
  permissions.

## 3. Rate limits

- **60 requests/min per API key.** Over-limit returns 429. Sleep about 1.05s
  between writes in any loop.
- Response headers: `X-RateLimit-Remaining`, `X-RateLimit-Reset` (UTC epoch).

## 4. Pagination (cursor based)

- Query params: `cursor` (format `value:offset:is_prev`, e.g. `20:1:0`) and
  `per_page` (max 100).
- The default `per_page` is ambiguous in the docs (one page says 20, another
  says 100). **Always pass `per_page` explicitly.** [FLAG]
- Envelope fields: `results[]`, `next_cursor`, `prev_cursor`, `count`,
  `total_pages`, `total_count`, `total_results`, `next_page_results` (bool),
  `prev_page_results` (bool). Work-item lists add `grouped_by`, `sub_grouped_by`,
  `extra_stats`. There is no `next`/`previous` URL; pass `next_cursor` back as
  `?cursor=`.

## 5. Global query params on most GETs

- `fields` = comma-separated allowlist of fields to return
  (e.g. `fields=id,name,priority`). Invalid names return an error naming the bad
  field.
- `expand` = comma-separated related resources to inline as readable objects
  instead of bare UUIDs. For work-items: `expand=state,assignees,labels,modules`.
  With `expand=state,labels,assignees`, `state` inflates to
  `{id, name, color, group}`, `labels` to full label objects, `assignees` to
  member objects.

## 6. Issues vs work-items naming

- Plane renamed "issues" to **work-items**. Author against `/work-items/`. The
  top-level `/issues/` collection is deprecated (end of support 2026-03-31),
  though both still return 200 on this version.
- Nested association segments keep the word `issues` and are NOT deprecated:
  `cycle-issues`, `module-issues`, `transfer-issues`.

## 7. Projects

| Op | Method | Path | Key fields |
|---|---|---|---|
| List | GET | `{ws}/projects/` | pagination, `fields`, `expand` |
| Create | POST | `{ws}/projects/` | required `name`, `identifier`; optional `description`, `network` (0=Secret, 2=Public) |
| Create from template | POST | `{ws}/projects/` | `name`, `identifier`, `template_id` |
| Retrieve | GET | `{ws}/projects/{project_id}/` | |
| Update | PATCH | `{ws}/projects/{project_id}/` | `name`, `description`, `emoji`, `cover_image`, view toggles |
| Archive | POST | `{ws}/projects/{project_id}/archive/` | |
| Unarchive | POST | `{ws}/projects/{project_id}/unarchive/` | |
| Delete | DELETE | `{ws}/projects/{project_id}/` | irreversible, confirm first |

- `identifier` must be short, uppercase, unique per workspace. It prefixes human
  ids (`OPS-12`). Create returns 201 with `{id, ...}`.
- Live identifier to id map: `NORRI` `1a928d0b-3d5b-4088-891a-db3a3632a2a9`,
  `OPS` `38120345-a576-44e3-b627-1b8f5155b40d`,
  `WCAP` `5e75bca7-2618-409a-9fed-80adac1e6cce`,
  `ALLY` `fe71a9f4-2cd4-4622-9e40-000b584490b4`,
  `BPES` `0eb45e51-fc0b-499b-912f-a05085304db4`.

## 8. Work-items (issues)

| Op | Method | Path | Notes |
|---|---|---|---|
| List | GET | `{wp}/work-items/` | query params below |
| Create | POST | `{wp}/work-items/` | returns 201 with `id`, `sequence_id` |
| Retrieve (UUID) | GET | `{wp}/work-items/{work_item_id}/` | |
| Retrieve by human id | GET | `{ws}/work-items/{IDENT}-{number}/` | workspace-scoped, no project_id, e.g. `.../work-items/OPS-12/` [from docs] |
| Update | PATCH | `{wp}/work-items/{work_item_id}/` | partial |
| Delete | DELETE | `{wp}/work-items/{work_item_id}/` | confirm first |
| Search (simple) | GET | `{ws}/work-items/search/` | `search` (req), `limit`, `project_id`, `workspace_search` |
| Search (advanced) | POST | `{ws}/work-items/advanced-search/` | body `query`, `filters`, `limit`, `project_id` |

**Create / update body fields:**

- `name` (string, required) is the title. The field is `name`, NOT `title`.
- `description_html` for rich text body, and/or `description_stripped` for plain.
- `priority` enum: `urgent | high | medium | low | none`. Anything else errors.
- `state` (state UUID), `assignees` (array of user UUIDs), `labels` (array of
  label UUIDs), `parent` (work-item UUID, how sub-issues are modeled).
- `start_date`, `target_date`, `estimate_point` / `point`, `type_id` / `type`,
  `is_draft`, `sort_order`.
- `external_source` + `external_id` for idempotent imports and dedupe.
- Object keys returned: `id, name, sequence_id, description_html, priority,
  state, labels, assignees, project, workspace, parent, type, point,
  start_date, target_date, completed_at, is_draft, sort_order, external_id,
  external_source, created_at, updated_at, created_by, archived_at, deleted_at`.
  `sequence_id` is the integer behind `OPS-12`.

**List query params:** `cursor`, `per_page`, `expand`, `fields`, `order_by`
(prefix `-` for descending, e.g. `order_by=-created_at`), `external_id`,
`external_source`. Documented list-level filtering is limited to `external_*`.
For real filtering by state, assignee, label, or priority, use
`advanced-search`. [FLAG] the `filters` grammar is not enumerated in the public
docs; discover it empirically.

**Simple search** `GET {ws}/work-items/search/`: returns
`{"issues":[{id, name, sequence_id, project__identifier, project_id, workspace__slug}]}`.

**Parent / sub-issues:** there is no dedicated sub-issues endpoint. Parent/child
is modeled only via the `parent` field. To list children, filter via
advanced-search. [INFERRED]

## 9. States

| Op | Method | Path |
|---|---|---|
| List | GET | `{wp}/states/` |
| Create | POST | `{wp}/states/` |
| Retrieve | GET | `{wp}/states/{state_id}/` [INFERRED] |
| Update | PATCH | `{wp}/states/{state_id}/` [INFERRED] |
| Delete | DELETE | `{wp}/states/{state_id}/` [INFERRED] |

- Create body: `name` (req), `color` (req), optional `description`, `group`,
  `sequence`, `default` (bool), `is_triage` (bool), `external_source`,
  `external_id`.
- `group` enum: `backlog | unstarted | started | completed | cancelled |
  triage`. Default states map as: Backlog -> backlog, Todo -> unstarted,
  In Progress -> started, Done -> completed, Cancelled -> cancelled. Use `group`
  for status logic, not the display name.

## 10. Labels

| Op | Method | Path |
|---|---|---|
| List | GET | `{wp}/labels/` |
| Create | POST | `{wp}/labels/` |
| Retrieve | GET | `{wp}/labels/{label_id}/` [INFERRED] |
| Update | PATCH | `{wp}/labels/{label_id}/` [INFERRED] |
| Delete | DELETE | `{wp}/labels/{label_id}/` [INFERRED] |

- Create body: `name` (req), `color` (hex, e.g. `#EF4444`), optional
  `description`, `parent` (label UUID for nesting), `sort_order`,
  `external_source`, `external_id`. Returns 201 with `{id, name, color, ...}`.

## 11. Cycles

| Op | Method | Path | Notes |
|---|---|---|---|
| List | GET | `{wp}/cycles/` | |
| Create | POST | `{wp}/cycles/` | `name` (req); `description`, `start_date`, `end_date`, `owned_by` |
| Retrieve | GET | `{wp}/cycles/{cycle_id}/` | |
| Update | PATCH | `{wp}/cycles/{cycle_id}/` | |
| Delete | DELETE | `{wp}/cycles/{cycle_id}/` | |
| List cycle work-items | GET | `{wp}/cycles/{cycle_id}/cycle-issues/` | |
| Add work-items | POST | `{wp}/cycles/{cycle_id}/cycle-issues/` | body `{"issues":["<uuid>"]}` |
| Remove work-item | DELETE | `{wp}/cycles/{cycle_id}/cycle-issues/{work_item_id}/` | |
| Transfer incomplete | POST | `{wp}/cycles/{cycle_id}/transfer-issues/` | body `{"new_cycle_id":"<uuid>"}` |
| Archive / Unarchive / List archived | POST / POST / GET | `{wp}/cycles/{cycle_id}/archive/`, `.../unarchive/`, `{wp}/cycles/archived-cycles/` | [FLAG] exact archive slugs inferred |

Note the add body uses `issues` (UUIDs), not `work_items`, despite the rename.

## 12. Modules

| Op | Method | Path | Notes |
|---|---|---|---|
| List | GET | `{wp}/modules/` | |
| Create | POST | `{wp}/modules/` | `name` (req); `description`, `start_date`, `target_date`, `status`, `lead`, `members` |
| Retrieve | GET | `{wp}/modules/{module_id}/` | |
| Update | PATCH | `{wp}/modules/{module_id}/` | |
| Delete | DELETE | `{wp}/modules/{module_id}/` | |
| List module work-items | GET | `{wp}/modules/{module_id}/module-issues/` | |
| Add work-items | POST | `{wp}/modules/{module_id}/module-issues/` | body `{"issues":["<uuid>"]}` |
| Remove work-item | DELETE | `{wp}/modules/{module_id}/module-issues/{work_item_id}/` | |
| Archive / Unarchive / List archived | POST / POST / GET | `{wp}/modules/{module_id}/archive/`, `.../unarchive/`, `{wp}/modules/archived-modules/` | [FLAG] inferred |

`status` enum: `backlog | planned | in-progress | paused | completed |
cancelled`. Create returns 201.

## 13. Members

| Op | Method | Path | Notes |
|---|---|---|---|
| List workspace members | GET | `{ws}/members/` | |
| Remove workspace member | DELETE | `{ws}/members/{member_id}/` | [INFERRED] |
| List project members | GET | `{wp}/project-members/` | note `project-members` |
| Add project member | POST | `{wp}/project-members/` | body `member` (user UUID, req), `role` (int) |
| Get / Update / Delete project member | GET / PATCH / DELETE | `{wp}/project-members/{member_id}/` | [INFERRED] |

- `role` enum (integers): 20 = Admin, 15 = Member, 5 = Guest.
- Workspace member object: `id, email, first_name, last_name, display_name,
  role, avatar, avatar_url`. Resolve user UUIDs from the workspace members list
  before adding project members.
- The add-member body field is `member` (the user UUID).

## 14. Work-item comments

| Op | Method | Path |
|---|---|---|
| List | GET | `{wpi}/comments/` |
| Create | POST | `{wpi}/comments/` |
| Retrieve | GET | `{wpi}/comments/{comment_id}/` |
| Update | PATCH | `{wpi}/comments/{comment_id}/` |
| Delete | DELETE | `{wpi}/comments/{comment_id}/` |

Create body: `comment_html` (rich text) and/or `comment_json` (object), `access`
(`INTERNAL` | `EXTERNAL`), `parent` (threaded reply), `external_source`,
`external_id`.

## 15. Work-item links

| Op | Method | Path |
|---|---|---|
| List | GET | `{wpi}/links/` |
| Create | POST | `{wpi}/links/` |
| Retrieve | GET | `{wpi}/links/{link_id}/` |
| Update | PATCH | `{wpi}/links/{link_id}/` |
| Delete | DELETE | `{wpi}/links/{link_id}/` |

Create body: `url` (req), `title` (optional). `metadata` is auto-extracted and
returned, not submitted.

## 16. Work-item attachments (3-step S3 flow)

Attachments are not a single multipart POST.

1. Get upload credentials: `POST {wpi}/attachments/` with body `name`
   (filename, req), `size` (bytes, req), `type` (MIME, optional). Returns the
   asset record plus presigned upload data (an `upload_data` object with S3
   `url` and form `fields`, plus an asset id). [FLAG] the doc render of this
   response is truncated; confirm the exact field names live.
2. Upload bytes with the presigned PUT/POST to the S3 URL. This goes to object
   storage, not the Plane API, and does NOT use `X-API-Key`.
3. Complete: `PATCH {wpi}/attachments/{attachment_id}/` with
   `{"is_uploaded": true}`. Returns 204.

Other ops: `GET {wpi}/attachments/` (list), `GET .../{attachment_id}/`,
`PATCH .../{attachment_id}/`, `DELETE .../{attachment_id}/` [INFERRED delete].
Work-item activity is read-only history at `{wpi}/activities/` [INFERRED path].

## 17. Beyond core

The reference also documents, with the same `{ws}/...` shape: Work Item Types,
Custom Properties and Property Values, Pages, Intake (inbox), Time Tracking,
Initiatives (and Initiative Labels/Projects/Epics), Customers, Teamspaces,
Stickies, and User (`GET /api/v1/users/me/`). Pull these per-resource as needed.

## 18. Gotchas (encode these)

- Use `/work-items/`, not `/issues/`. Nested
  `cycle-issues`/`module-issues`/`transfer-issues` segments stay as is.
- Create field is `name`, not `title`. Rich body via `description_html`.
- `priority` enum is exactly `urgent|high|medium|low|none`.
- Project `identifier` is short, uppercase, unique per workspace; it prefixes
  human ids.
- Trailing slashes are required on every path.
- Paths use the workspace slug, even where a doc labels it `workspace_id`.
- 60 requests/min, 100 max `per_page`; loop writes with about 1.05s sleeps.
- `per_page` default is ambiguous; always pass it.
- Association add takes `{"issues":[...]}` (UUIDs), not `work_items`.
- Member add uses `member` (user UUID) plus integer `role` (20/15/5).
- Attachments are a 3-step flow and the upload-credentials response shape is
  under-documented; verify live.
- No public sub-issue endpoint; parent/child is just the `parent` UUID field.

## 19. Operational gotchas (Norristown instance)

- Cold-start 502s on the API are normal (single gunicorn worker). Retry.
- The Plane web app registers a Workbox service worker (`/sw.js`) that can cache
  a broken shell during cold-start 502s and replay it in the browser that first
  hit it. The engine is fine. Fix: unregister the service worker at
  `about:serviceworkers` or clear site data and hard reload; confirm in a
  private window.
- Open signup is currently ON and the URL is public, and SMTP is not yet wired
  (invites and magic links will not email). Surface this as a caveat; do not
  change god-mode or signup settings without confirmation.
