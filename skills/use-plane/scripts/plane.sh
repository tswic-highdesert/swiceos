#!/usr/bin/env bash
# Plane REST API helper (Norristown self-hosted Plane, open-source PM tool).
#
# Config resolution (all overridable by env):
#   PLANE_BASE_URL   default https://plane-production-ee4d.up.railway.app
#   PLANE_WORKSPACE  default norristown-capital-ai
#   PLANE_API_KEY    if unset, decrypted from the age vault, else Infisical
#
# Auth: every request sends "X-API-Key: <PAT>". The key is never printed.
# Rate limit: 60 requests/min per key. Write loops sleep ~1.05s.
#
# Usage: plane.sh <command> [args]   (run with no args for help)

set -euo pipefail

DEFAULT_BASE="https://plane-production-ee4d.up.railway.app"
DEFAULT_WS="norristown-capital-ai"

if [[ -n "${PLANE_BASE_URL:-}" ]]; then
  PLANE_BASE_URL_SET=1
else
  PLANE_BASE_URL="$DEFAULT_BASE"
fi
WS="${PLANE_WORKSPACE:-$DEFAULT_WS}"
PLANE_BASE_URL="${PLANE_BASE_URL%/}"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

command -v python3 >/dev/null 2>&1 || die "python3 is required."
command -v curl >/dev/null 2>&1 || die "curl is required."

# --- secret resolution (never printed) -------------------------------------
# Order: PLANE_API_KEY env -> age vault (Tal's machine) -> Infisical
# (norristown project, prod env). The key value is never echoed.
load_secrets() {
  [[ -n "${PLANE_API_KEY:-}" ]] && return 0

  # 1) age vault, if this machine has it
  local idfile="$HOME/.config/age/key.txt" vault="$HOME/secrets/secrets.env.age"
  if [[ -f "$idfile" && -f "$vault" ]] && command -v age >/dev/null 2>&1; then
    local decrypted
    if decrypted=$(age -d -i "$idfile" "$vault" 2>/dev/null); then
      PLANE_API_KEY=$(printf '%s\n' "$decrypted" | grep '^PLANE_API_KEY=' | cut -d= -f2- || true)
      if [[ -z "${PLANE_BASE_URL_SET:-}" ]]; then
        local vbase
        vbase=$(printf '%s\n' "$decrypted" | grep '^PLANE_BASE_URL=' | cut -d= -f2- || true)
        [[ -n "$vbase" ]] && PLANE_BASE_URL="${vbase%/}"
      fi
      decrypted=""
      unset decrypted
      [[ -n "$PLANE_API_KEY" ]] && return 0
    fi
  fi

  # 2) Infisical (norristown project). Requires a prior `infisical login`.
  #    Project resolves from .infisical.json (via `infisical init`) or
  #    INFISICAL_PROJECT_ID in the environment.
  if command -v infisical >/dev/null 2>&1; then
    local iargs=(secrets get PLANE_API_KEY --env prod --plain --silent)
    [[ -n "${INFISICAL_PROJECT_ID:-}" ]] && iargs+=(--projectId "$INFISICAL_PROJECT_ID")
    PLANE_API_KEY=$(infisical "${iargs[@]}" 2>/dev/null || true)
    [[ -n "$PLANE_API_KEY" ]] && return 0
  fi

  die "PLANE_API_KEY not found. Export it, install the age vault, or log in to Infisical (norristown project) and retry."
}

# --- low-level request ------------------------------------------------------
# _request METHOD PATH [JSON_BODY]
_request() {
  load_secrets
  local method="$1" path="$2" body="${3:-}"
  local url="${PLANE_BASE_URL}${path}"
  if [[ -n "$body" ]]; then
    curl -sS -X "$method" "$url" \
      -H "X-API-Key: ${PLANE_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$body"
  else
    curl -sS -X "$method" "$url" \
      -H "X-API-Key: ${PLANE_API_KEY}"
  fi
}

pretty() { python3 -m json.tool 2>/dev/null || cat; }

merge_json() {
  # merge_json BASE_JSON [EXTRA_JSON]
  python3 -c 'import sys,json
a=json.loads(sys.argv[1]); b=json.loads(sys.argv[2] or "{}"); a.update(b); print(json.dumps(a))' "$1" "${2:-}"
}

# resolve_project_id IDENTIFIER  ->  prints UUID
resolve_project_id() {
  local ident="$1" out
  out=$(_request GET "/api/v1/workspaces/${WS}/projects/?per_page=100")
  printf '%s' "$out" | python3 -c 'import sys,json
ident=sys.argv[1]
d=json.load(sys.stdin)
for p in d.get("results", []):
    if str(p.get("identifier","")).upper()==ident.upper():
        print(p["id"]); break
else:
    sys.exit(3)' "$ident" || die "no project with identifier ${ident}"
}

# resolve_issue IDENTIFIER-NUM  ->  prints "PROJECT_ID ISSUE_ID"
resolve_issue() {
  local human="$1"
  [[ "$human" == *-* ]] || die "expected ISSUE id like OPS-12, got '${human}'"
  local ident="${human%-*}" num="${human##*-}"
  local pid; pid=$(resolve_project_id "$ident")
  local cursor="" out found more
  while :; do
    local path="/api/v1/workspaces/${WS}/projects/${pid}/work-items/?per_page=100"
    [[ -n "$cursor" ]] && path="${path}&cursor=${cursor}"
    out=$(_request GET "$path")
    found=$(printf '%s' "$out" | python3 -c 'import sys,json
n=int(sys.argv[1]); d=json.load(sys.stdin)
print(next((i["id"] for i in d.get("results",[]) if i.get("sequence_id")==n), ""))' "$num")
    if [[ -n "$found" ]]; then printf '%s %s\n' "$pid" "$found"; return 0; fi
    more=$(printf '%s' "$out" | python3 -c 'import sys,json;d=json.load(sys.stdin);print("1" if d.get("next_page_results") else "")')
    cursor=$(printf '%s' "$out" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("next_cursor") or "")')
    [[ -z "$more" || -z "$cursor" ]] && break
  done
  die "no work-item ${human}"
}

usage() {
  cat <<'USAGE'
plane.sh - Plane REST API helper

Config (env, all optional):
  PLANE_BASE_URL    default https://plane-production-ee4d.up.railway.app
  PLANE_WORKSPACE   default norristown-capital-ai
  PLANE_API_KEY     if unset, read from the age vault, else Infisical (norristown)

Read commands (safe):
  whoami                         auth smoke test (GET /users/me/)
  projects                       list projects in the workspace
  project IDENT                  show one project by identifier (e.g. OPS)
  issues IDENT                   list work-items in a project (state/labels expanded)
  issue IDENT-NUM                show one work-item by human id (e.g. OPS-12)
  labels IDENT                   list labels in a project
  states IDENT                   list states in a project
  members                        list workspace members
  api METHOD PATH [JSON]         raw passthrough, e.g. api GET /api/v1/users/me/

Write commands (confirm intent first; 1.05s sleep between bulk writes):
  create-project NAME IDENT                  identifier = short uppercase key
  create-label IDENT NAME COLOR              color is hex, e.g. #EF4444
  create-issue IDENT "name" [JSON]           JSON merges extra fields onto {name}
  update-issue IDENT-NUM JSON                PATCH a work-item
  comment IDENT-NUM "text"                   add a comment
  seed FILE.json                             bulk create projects + labels + issues

Notes:
  - Field is "name" (not title). Rich text via description_html.
  - priority enum: urgent | high | medium | low | none.
  - No em dashes in any name or description (house rule).
  - Reads are safe; deletes are intentionally not exposed here.
USAGE
}

cmd="${1:-}"; [[ $# -gt 0 ]] && shift || true

case "$cmd" in
  ""|-h|--help|help)
    usage
    ;;

  whoami)
    _request GET "/api/v1/users/me/" | pretty
    ;;

  projects)
    _request GET "/api/v1/workspaces/${WS}/projects/?per_page=100" | pretty
    ;;

  project)
    [[ $# -ge 1 ]] || die "usage: project IDENT"
    pid=$(resolve_project_id "$1")
    _request GET "/api/v1/workspaces/${WS}/projects/${pid}/" | pretty
    ;;

  issues)
    [[ $# -ge 1 ]] || die "usage: issues IDENT"
    pid=$(resolve_project_id "$1")
    _request GET "/api/v1/workspaces/${WS}/projects/${pid}/work-items/?per_page=100&expand=state,labels,assignees" | pretty
    ;;

  issue)
    [[ $# -ge 1 ]] || die "usage: issue IDENT-NUM"
    read -r pid iid < <(resolve_issue "$1")
    _request GET "/api/v1/workspaces/${WS}/projects/${pid}/work-items/${iid}/?expand=state,labels,assignees" | pretty
    ;;

  labels)
    [[ $# -ge 1 ]] || die "usage: labels IDENT"
    pid=$(resolve_project_id "$1")
    _request GET "/api/v1/workspaces/${WS}/projects/${pid}/labels/?per_page=100" | pretty
    ;;

  states)
    [[ $# -ge 1 ]] || die "usage: states IDENT"
    pid=$(resolve_project_id "$1")
    _request GET "/api/v1/workspaces/${WS}/projects/${pid}/states/?per_page=100" | pretty
    ;;

  members)
    _request GET "/api/v1/workspaces/${WS}/members/?per_page=100" | pretty
    ;;

  create-project)
    [[ $# -ge 2 ]] || die "usage: create-project NAME IDENT"
    body=$(python3 -c 'import sys,json;print(json.dumps({"name":sys.argv[1],"identifier":sys.argv[2].upper()}))' "$1" "$2")
    _request POST "/api/v1/workspaces/${WS}/projects/" "$body" | pretty
    ;;

  create-label)
    [[ $# -ge 3 ]] || die "usage: create-label IDENT NAME COLOR"
    pid=$(resolve_project_id "$1")
    body=$(python3 -c 'import sys,json;print(json.dumps({"name":sys.argv[1],"color":sys.argv[2]}))' "$2" "$3")
    _request POST "/api/v1/workspaces/${WS}/projects/${pid}/labels/" "$body" | pretty
    ;;

  create-issue)
    [[ $# -ge 2 ]] || die "usage: create-issue IDENT \"name\" [JSON]"
    pid=$(resolve_project_id "$1")
    base=$(python3 -c 'import sys,json;print(json.dumps({"name":sys.argv[1]}))' "$2")
    body=$(merge_json "$base" "${3:-}")
    _request POST "/api/v1/workspaces/${WS}/projects/${pid}/work-items/" "$body" | pretty
    ;;

  update-issue)
    [[ $# -ge 2 ]] || die "usage: update-issue IDENT-NUM JSON"
    read -r pid iid < <(resolve_issue "$1")
    _request PATCH "/api/v1/workspaces/${WS}/projects/${pid}/work-items/${iid}/" "$2" | pretty
    ;;

  comment)
    [[ $# -ge 2 ]] || die "usage: comment IDENT-NUM \"text\""
    read -r pid iid < <(resolve_issue "$1")
    body=$(python3 -c 'import sys,json;print(json.dumps({"comment_html":"<p>%s</p>"%sys.argv[1]}))' "$2")
    _request POST "/api/v1/workspaces/${WS}/projects/${pid}/work-items/${iid}/comments/" "$body" | pretty
    ;;

  api)
    [[ $# -ge 2 ]] || die "usage: api METHOD PATH [JSON]"
    _request "$1" "$2" "${3:-}" | pretty
    ;;

  seed)
    [[ $# -ge 1 ]] || die "usage: seed FILE.json"
    [[ -f "$1" ]] || die "seed file not found: $1"
    load_secrets
    PLANE_BASE_URL="$PLANE_BASE_URL" PLANE_WORKSPACE="$WS" PLANE_API_KEY="$PLANE_API_KEY" \
      python3 - "$1" <<'PYEOF'
import os, sys, json, time, urllib.request, urllib.error

BASE = os.environ["PLANE_BASE_URL"].rstrip("/")
WS   = os.environ["PLANE_WORKSPACE"]
KEY  = os.environ["PLANE_API_KEY"]
SLEEP = 1.05  # 60 req/min per key

def req(method, path, body=None):
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(url, data=data, method=method)
    r.add_header("X-API-Key", KEY)
    if data is not None:
        r.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(r) as resp:
            raw = resp.read()
            return resp.status, (json.loads(raw) if raw else None)
    except urllib.error.HTTPError as e:
        raw = e.read()
        try:
            return e.code, json.loads(raw)
        except Exception:
            return e.code, raw.decode("utf-8", "replace")

def list_all(path):
    items, cursor = [], ""
    while True:
        sep = "&" if "?" in path else "?"
        p = path + (f"{sep}cursor={cursor}" if cursor else f"{sep}per_page=100")
        st, d = req("GET", p)
        if st != 200 or not isinstance(d, dict):
            break
        items += d.get("results", [])
        if d.get("next_page_results") and d.get("next_cursor"):
            cursor = d["next_cursor"]
        else:
            break
    return items

spec = json.load(open(sys.argv[1]))
projects = spec.get("projects", [])
if not projects:
    print("seed file has no 'projects' array", file=sys.stderr); sys.exit(1)

existing_projects = {str(p.get("identifier","")).upper(): p["id"]
                     for p in list_all(f"/api/v1/workspaces/{WS}/projects/")}

for proj in projects:
    name = proj["name"]
    ident = str(proj["identifier"]).upper()
    pid = existing_projects.get(ident)
    if pid:
        print(f"project {ident} exists, reusing {pid}")
    else:
        st, d = req("POST", f"/api/v1/workspaces/{WS}/projects/",
                    {"name": name, "identifier": ident})
        time.sleep(SLEEP)
        if st not in (200, 201) or not isinstance(d, dict) or "id" not in d:
            print(f"FAILED project {ident}: {st} {d}", file=sys.stderr); continue
        pid = d["id"]
        print(f"created project {ident} -> {pid}")

    # labels (upsert by name)
    label_ids = {l["name"]: l["id"]
                 for l in list_all(f"/api/v1/workspaces/{WS}/projects/{pid}/labels/")}
    for lab in proj.get("labels", []):
        lname = lab["name"]
        if lname in label_ids:
            continue
        st, d = req("POST", f"/api/v1/workspaces/{WS}/projects/{pid}/labels/",
                    {"name": lname, "color": lab.get("color", "#6B7280")})
        time.sleep(SLEEP)
        if st in (200, 201) and isinstance(d, dict) and "id" in d:
            label_ids[lname] = d["id"]
            print(f"  label {lname} -> {d['id']}")
        else:
            print(f"  FAILED label {lname}: {st} {d}", file=sys.stderr)

    # issues (skip if a work-item with the same name already exists)
    existing_names = {i.get("name") for i in
                      list_all(f"/api/v1/workspaces/{WS}/projects/{pid}/work-items/")}
    for issue in proj.get("issues", []):
        iname = issue["name"]
        if iname in existing_names:
            print(f"  issue exists, skipping: {iname}")
            continue
        body = {"name": iname}
        if issue.get("description_html"):
            body["description_html"] = issue["description_html"]
        if issue.get("priority"):
            body["priority"] = issue["priority"]
        names = issue.get("labels", [])
        ids = [label_ids[n] for n in names if n in label_ids]
        missing = [n for n in names if n not in label_ids]
        if missing:
            print(f"  WARN unknown labels on '{iname}': {missing}", file=sys.stderr)
        if ids:
            body["labels"] = ids
        st, d = req("POST", f"/api/v1/workspaces/{WS}/projects/{pid}/work-items/", body)
        time.sleep(SLEEP)
        if st in (200, 201) and isinstance(d, dict):
            print(f"  issue {ident}-{d.get('sequence_id','?')} {iname}")
        else:
            print(f"  FAILED issue '{iname}': {st} {d}", file=sys.stderr)

print("seed complete")
PYEOF
    ;;

  *)
    die "unknown command: ${cmd}. Run 'plane.sh help'."
    ;;
esac
