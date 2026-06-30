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
Shared within a group, never shipped to everyone. Lives in its own shared git
repo checked out at `team/`. Only create it for a group that genuinely needs
both private and group-shared content at once. Solo users skip it entirely.

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
