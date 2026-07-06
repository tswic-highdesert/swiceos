---
name: sw-onboard-portco
description: Stand up a new portfolio company on SwiceOS from an intake (a sponsor email, forwarded docs, a brief). Creates the company's own git repo, scaffolds the standard portco layout, seeds its AI brain from the source docs, wires it into the team so every teammate's machine mounts it, and sets up the AI video pipeline. Use when the user says "onboard a portco", "new portco", "create a repo for <company>", "set up <company> on the OS", or forwards kickoff material for a new portfolio company.
---

# Onboard a portfolio company

One repeatable protocol for standing up a new portco, so Tal and Garth do it the
same way every time. The output is a new company repo that mounts under
`team/<group>/<slug>` on every teammate's machine, seeded with whatever the
sponsor sent.

Default group is `norristown`. The concrete Gitea details below are Norristown's;
swap the org/remote for another team.

## When to use

- A sponsor (e.g. Andy McNeill) forwards kickoff material for a new company.
- The user asks to "create a repo for <company>" or "onboard <company>".
- You have context on a new portco and nowhere standard to put it yet.

## The standard portco layout

Every portco repo looks the same so anyone can navigate any of them:

```
<slug>/
  CLAUDE.md              # the portco context: org, people, engagement, AI opportunities
  README.md              # one-screen orientation + pointer into the folders
  brain/                 # the AI brain: the company's domain knowledge base
    README.md            # index + provenance
    <topic>.md           # OKF markdown notes (one concept per file)
    _source/             # original documents, preserved unchanged
  video/                 # AI video pipeline: the ask, current drafts, chosen engine
    README.md
  meetings/notes/        # meeting notes as they happen (OKF meeting-note format)
```

## Protocol

### 0. Intake — capture everything the sponsor sent

- Read the source emails. Download every attachment (use `gog gmail attachment
  <messageId> <attachmentId> --out <file>`) and note any links (video drafts,
  drives, dashboards).
- Identify: the legal/brand name, domain, what the business does, the sponsor,
  the operating contact, and the specific asks.
- Decide the `<slug>` (kebab-case, e.g. `total-environmental`). Confirm it is
  genuinely a new entity and not a subfolder of an existing portco.

### 1. Scaffold the repo

Run the scaffolder, which creates the standard layout under the team folder and
`git init`s it:

```
skills/sw-onboard-portco/scripts/scaffold-portco.sh <slug> "<Display Name>" [group]
# e.g.
skills/sw-onboard-portco/scripts/scaffold-portco.sh total-environmental "Total Environmental" norristown
```

Then fill in `CLAUDE.md` (org, people, engagement status, AI opportunity areas)
from the intake. Keep house style: no em dashes (`standards/writing-standards.md`).

### 2. Seed the AI brain

- Convert each source doc into a clean OKF markdown note in `brain/`
  (`standards/okf-frontmatter.md`): one concept per file, YAML frontmatter with
  `type` and `title`. Domain reference material uses `type: reference` (record
  that one-line decision in `brain/README.md`).
- Preserve the untouched originals in `brain/_source/`.
- Write `brain/README.md` as the index + provenance (who sent it, when, "for the
  AI brain for <company>").

### 3. Set up the video pipeline (if the sponsor wants video)

- Capture the ask and link any existing drafts (e.g. a HeyGen hero video) in
  `video/README.md`.
- Recommend the engine: `/hyperframes` for a brand-controlled, repeatable
  pipeline; HeyGen for fast presenter/avatar output; usually a blend. Do not
  build the whole pipeline here, tee up the decision and the first hero video.

### 4. Create the remote and wire it into the team

The scaffolder already added the repo to `local/team.manifest.json`, added
`/<slug>/` to `team/<group>/.gitignore`, and added the entry to the team
onboarding doc. You still must create the empty remote, because push-to-create
is disabled for the Norristown org:

- **Create the empty repo** in the Gitea org. The API/web is tailnet-only, so
  either use the Gitea web UI (New Repository under org `Norristown`) or, on the
  `norristowncapital.com` tailscale profile, `POST /api/v1/orgs/Norristown/repos`
  with a token. Git over SSH (port 2222) already works from any profile.
- **Push:** `git -C team/<group>/<slug> push -u origin main`.
- **Grant access:** add teammates to the matching Gitea team so their
  `tools/hydrate.sh` clones it (org Norristown -> Teams -> Add Member).
- **Secrets:** if the company needs its own keys, create a per-company Infisical
  project (env `prod`) and point the repo's `.infisical.json` at it. Never paste
  secret values into chat or commits.

### 5. Commit and hand off

- Commit the new company repo (done by the scaffolder's first commit; push it).
- Commit the team wiring: `team/<group>/.gitignore` (the norristown-home repo)
  and push it so teammates mount the new repo on next hydrate.
- Tell the user the one manual step that remains if the remote could not be
  created automatically (web-UI repo creation), and confirm what landed.

## Standardization notes

- This skill is the single source of truth for portco onboarding. Tal and Garth
  both run it, so every portco ends up with the same shape.
- Garth can run everything except the two admin steps that need owner rights:
  creating the Gitea repo and adding team access. Flag those for Tal.
- New portco content is team-ring by default (`team/<group>/`), never core.
  Promoting anything into core is a separate, deliberate step.

## Reference

- Portco context template and examples: any existing `team/norristown/<co>/CLAUDE.md`
  (e.g. `bp-waste`, `whitecap`).
- Mounting mechanism: `tools/hydrate.sh` + `local/team.manifest.json`.
- Gitea specifics: Norristown org on `samson-1` (git `:2222`), see the team's
  onboarding doc.
- Knowledge format: `standards/okf-frontmatter.md`. Voice: `standards/writing-standards.md`.
