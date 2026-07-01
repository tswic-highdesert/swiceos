---
type: process
title: Core, team, and local (the three rings)
---

# The three rings

The OS has three concentric rings. Each is gitignored from the ring outside
it, so nothing leaks outward by accident. Promotion outward is always a
deliberate, human-approved move.

## core
Everything tracked in this repo: skills, agents, hooks, standards, this
CLAUDE.md. It is the shared OS. It flows DOWN to everyone automatically via
the SessionStart update hook. Recipients never edit core. On the author's
control-plane machine, core is edited on `main` and promoted to `stable`.

## team/ (optional)
Shared within a group, never shipped to everyone. `team/` is a **mount point**,
not a repo of its own: it holds one or more independent repos cloned in by
name. Nothing is moved or renamed to live here, the repos keep their real names
and their existing hosts (GitHub, Norristown Gitea, Hetzner Gitea). The OS is
just a lens over them. Solo users skip `team/` entirely.

Which repos mount where is listed in a manifest. Each entry has a `group` tag.
A machine lists the groups it belongs to in `local/groups` (one tag per line,
private to that machine). `tools/hydrate.sh` reads the manifest and clones every
entry whose group the machine belongs to, so a new person's Claude mounts
exactly the repos they have access to and nothing else. Re-running it just
fast-forwards what is already there. Access is ultimately enforced by each
repo's host, a repo the person cannot read is simply skipped.

There are two manifests, both read by hydrate:
- `team.manifest.json` (in core, ships to everyone): keep it generic. Never put
  private or company repo URLs here, or they leak into the shared/open OS.
- `local/team.manifest.json` (gitignored, private to the machine): the real
  private repo lists live here. Same format. This is where, for example, a
  Norristown machine lists its Norristown Gitea repos.

Repos mount at `team/<group>/<name>`, so each team gets its own folder. A team
can carry its own operating context (workflows, secrets-manager pointer, tools,
standards) in a `team/<team>/CLAUDE.md` held by a "home" repo mounted at the
team root. See `standards/team-context.md`.

## local/
Private to one machine. The user's daily work, notes, and private skills and
agents. Its own private git repo (so it is backed up and synced) but never
connected to core. Nothing here ever flows down.

## Branches (core only)
- `main`: the author works and tests here.
- `stable`: what everyone auto-pulls. The author advances `stable` only after
  a change has proven itself. Rollback = revert `stable`; users self-heal on
  the next pull.

## Promotion
local -> team -> core (or local -> core) by moving the file and committing it
on the author's machine. A pre-push check scans for secrets and private
markers before anything reaches `stable`.
