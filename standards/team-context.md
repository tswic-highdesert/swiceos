---
type: process
title: Team context (per-team CLAUDE.md and home repo)
---

# Team context

Each team can carry its own operating context: workflows, which secrets
manager project to use, the CRM/PMT and other third-party tools, deliverable
standards, links. This is the middle layer between core and local:

- **core** CLAUDE.md: universal OS behavior, shared with everyone.
- **team/<team>/CLAUDE.md**: how THIS team works. Shared only with that team.
- **local/CLAUDE.md**: personal, per-machine tweaks.

## Where it lives

The per-team context lives in a small **home repo** for that team, mounted at
the team root. In `team.manifest.json` (or `local/team.manifest.json`), mark it
with `"home": true` so hydrate clones it to `team/<team>/` instead of a
subfolder. Its `CLAUDE.md` then sits above every repo in that team.

```
team/
  norristown/           <- the norristown home repo (home: true)
    CLAUDE.md           <- team context, loaded for all norristown work
    standards/          <- optional team standards, skills, agents
    whitecap/           <- a normal team repo (subfolder)
    bp-waste/
```

The home repo should `.gitignore` the sibling repo folders (e.g. `whitecap/`),
since those are separate clones living inside its working tree.

## How it loads

Claude Code auto-loads CLAUDE.md from the working directory up the tree, so
`team/<team>/CLAUDE.md` applies automatically whenever anyone works inside that
team's folder. To make it apply at the swiceos root too (not only when you cd
into the team folder), add one line to your `local/CLAUDE.md`:

```
@team/norristown/CLAUDE.md
```

That import is per-machine, so it only switches on for that team's people.

## Secrets: point, never paste

A team CLAUDE.md may say WHERE secrets live, never what they are. Reference the
Infisical project and how to inject; the secrets-guard hook still blocks real
values. See the global secrets rules.

## Template

Copy this into a team home repo as `CLAUDE.md` and fill it in:

```markdown
# <Team> operating context

You are working on <Team> material. This adds to the core SwiceOS rules.

## What this team does
<one or two lines: mission, who it serves, what we deliver>

## Workflows
- <the recurring jobs and how we run them>

## Secrets
Secrets live in Infisical project `<project>` (env `prod`). Inject at runtime:
`infisical run --env prod -- <cmd>`. Never hardcode or paste values.

## Tools we use
- CRM: <name> — <how Claude should use it, MCP server if any>
- PMT: <name> — <boards/projects, conventions>
- Other: <email, storage, dashboards, links>

## Repos in this team
- <repo> — <what it is>

## Standards
- <naming, deliverable format, tone, anything team-specific>
```
