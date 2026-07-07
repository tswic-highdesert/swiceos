---
name: sw-portco-worklog
description: The standing rule for logging portfolio-company work to Plane. Every time you work on a portco (Whitecap, Alloy, BP, Matador, Angstrom, AMMCO, EAS, Total Environmental, Free Arkansas, or any new one), log the issues you hit, the blockers, and the next steps to that portco's Plane project so nothing lives only in a doc or a dashboard tab. Use at the START of a portco session (pull the board for open items) and at the END (write back new issues, next steps, and status changes). Also use when the user says "log this to Plane", "add to the portco board", "audit the portco to-do items", or "what's open for <company>".
---

# Portco work log (Plane is the record)

One rule, applied every time we touch a portfolio company: **issues and next
steps live in Plane, under that company's project.** Not in a dashboard tab, not
only in a markdown doc, not only in chat. Docs and dashboards can hold detail,
but the tracked, current worklist is on the board so Tal and Garth both see the
same thing.

This is a standing SOP, not a one-off. It is referenced from
`team/norristown/CLAUDE.md` so it applies to all portco work.

## When to apply

- **Start of a portco session:** pull the board so you know what is already
  open before you start. `scripts/plane.sh issues <IDENTIFIER>` (see the
  `use-plane` skill for the helper and auth).
- **End of a portco session, and whenever something changes:** write back.
  - A new problem you hit or a data gap you found -> a work-item.
  - A concrete next action -> a work-item.
  - Something you finished or that got unblocked -> update the existing item's
    state (and add a short comment), do not leave it stale-open.
- The user asks to log something, audit the board, or asks "what's open".

## Portco -> Plane project map

Workspace: `norristown-capital-ai`. Projects:

| Portco | Plane identifier |
|---|---|
| Whitecap Waste | `WCAP` |
| Alloy Group | `ALLY` |
| BP Environmental | `BPES` |
| Matador Gas | `MTDR` |
| Angstrom Technology | `ANGS` |
| Magazine Capital (AMMCO) | `MCM` |
| Endpoint Automation Solutions | `EAS` |
| Free Arkansas | `FREEARKANS` |
| Norristown internal / platform | `OPS` |

If a portco has no project yet, create one (`scripts/plane.sh create-project
"<Name>" <IDENT>`) and seed the shared label taxonomy before logging.

## How to log (conventions, enforced)

Follow the `use-plane` skill for the mechanics. The non-negotiables:

- **Shared 6-label taxonomy**, reused in every project, exact hex:
  `rock` `#8B5CF6`, `issue` `#EF4444`, `to-do` `#3B82F6`, `blocker` `#DC2626`,
  `data-quality` `#F59E0B`, `client-ask` `#10B981`.
- **Every work-item description carries a `Source:` line and an `Owner:` line.**
  Name the owner in the description until they are a confirmed workspace member.
- **No em dashes** anywhere (names or descriptions). Commas or periods.
- **No dumping.** Only open, current, source-cited work. Do not bulk-import a
  stale machine snapshot. When you migrate items out of a doc or a dashboard,
  migrate only the unaddressed ones and cite where they came from.
- Choose labels by what the item is: a client-provided-data gap is
  `client-ask` (+ `blocker` if it stops downstream work), a numbers/mapping
  problem is `data-quality`, an action we own is `to-do`, a quarter-goal is
  `rock`.
- Priority reflects value and urgency, not noise. Most items are `medium`.

## Audit (do this periodically, and when asked)

To audit a portco's board: `scripts/plane.sh issues <IDENTIFIER>`, then check:
- Open items still current, or resolved-but-left-open (close them).
- Every open item has `Source:` and `Owner:`.
- No test junk or duplicate of the public roadmap layer.
- Blockers actually still blocked (owners may have unblocked them).

To audit **all** boards at once, loop the identifiers above. Report per project:
open count by state, items missing Source/Owner, and anything stale.

## Why this exists

Whitecap proved the failure mode: issues lived in a dashboard "Open Items" tab
and a markdown log, so they were invisible to whoever was not looking at that
file. Moving them to Plane (WCAP) made the worklist shared and current. We do
this for every portco now so the board is always the single source of truth for
what is open and what is next.
