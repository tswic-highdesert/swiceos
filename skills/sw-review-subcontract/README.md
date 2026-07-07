# Subcontractor Agreement Review — Skill

A Claude **Agent Skill**. A reviewer uploads a subcontractor / trade contractor agreement PDF and gets a fully cited Green/Yellow/Red risk review, executive-escalation flags, governing-law/venue findings, and suggested redline language — with an exportable memo on request. **Decision-support, not legal advice.**

Built to be **portfolio-agnostic**: it works out of the box in generic mode, and each company tailors it by editing one file (`config.md`) — no code changes.

> NDAs are a **separate** skill. This skill is sub agreements only.

## Make it yours (2 minutes)

Edit **`config.md`** — the only file you need to touch. Set your company name, home state / preferred venue, tier position (first-tier vs sub-of-sub), and any specialty scope. Leave it as-is and the skill runs in generic mode. That's it.

To adapt the pipeline to a different contract type (service agreement, vendor MSA), see the "How to adapt" section at the bottom of `config.md`. Do that in your own `local/` or `team/` copy, not in core.

## Bundle structure
```
sw-review-subcontract/
├── SKILL.md                       # orchestration brain (the pipeline)
├── config.md                      # THE ONE FILE YOU EDIT — company profile
├── rubric/
│   ├── subcontract_rubric.md      # ~50 provisions — SINGLE SOURCE OF TRUTH (edit here)
│   ├── executive_triggers.md      # the 4 auto-escalation buckets
│   ├── state_law_checklist.md     # Step 2 governing-law/venue research
│   └── nda_rubric.md              # stub (NDA is a separate skill)
├── templates/
│   └── review_memo.md             # exportable memo layout
├── diagrams/
│   └── subcontract-review-flow.excalidraw   # how-it-works diagram
├── package.sh                     # build the org-upload .zip
└── README.md                      # this file
```

---

## Deploying to a Claude Team/Enterprise org (so a team can use it)

Org-wide Skills provisioning is available on **Team and Enterprise** plans (not Pro/Max). One-time setup is done by an **Organization Owner / Primary Owner**.

**Prerequisites (Owner does these once):**
1. **Organization settings → Skills** → enable **"Code execution and file creation"** and **"Skills."**
2. **Admin settings → Capabilities** → enable **Web search** (separate toggle; required for the state-law research step — Step 2). Note: web search is billed separately (~$10 per 1,000 searches).

**Deploy:**
1. Fill in `config.md` for the company.
2. Build the upload artifact: run `./package.sh` → produces `dist/sw-review-subcontract.zip`.
3. **Organization settings → Skills** → upload the `.zip`. It becomes available to all members by default; individuals can toggle it on/off.
4. Each reviewer: **Customize → Skills**, confirm the skill appears with a team indicator, toggle it on.

**Use:** start a chat, turn on the skill, upload the agreement PDF, ask for a review. For the state-law step, the reviewer must have **web search** on in that chat (search icon in the chat input).

---

## How changes/tweaks get executed after it's live

The most common edit is to the **rubric** (`rubric/subcontract_rubric.md`) — it's plain Markdown, so anyone on the team can read and propose edits without code. Pushing a change to a live org skill is an Owner action:

1. **Edit the source** in your Git repo (rubric row, redline language, a new provision, a threshold).
2. **Bump the version** below and add a changelog line.
3. **Re-package** (`./package.sh`) and **re-upload** the `.zip` via **Organization settings → Skills** (replaces the old version).
4. **Tell the team** it's updated — there is **no automatic update notification** and **no built-in versioning/rollback** in the org UI. This Git repo *is* the version history and rollback (re-upload the prior tagged zip to revert).
5. Before promoting a rubric change, re-run your **acceptance test** (below) so an edit doesn't silently break a known-good review.

There is **no approval workflow** on org upload — a replacement goes live immediately for everyone. Keep edits in Git, reviewed by the rubric owner, before they ship.

**Rubric owner:** set in `config.md`. All rubric changes route through this person.

---

## Validation / acceptance test

Before the team relies on it, run it against a **seeded golden case** — a real, already-reviewed agreement with a human answer key — and confirm **zero missed Reds**:
- Keep 1-3 reviewed agreements as golden cases with their expected Reds documented.
- Gates: zero missed Reds on the never-auto-Green provisions; ≥90% recall on Yellow/Red; ≥95% citation accuracy; the completeness warning fires when the Prime isn't attached.

---

## Runtime caveats
- **Network/web access varies** by org and user settings — if Step 2 can't search, it degrades to "could not verify — counsel to confirm" rather than guessing.
- **No hardcoded secrets** anywhere in the bundle (none here).
- Keep the active skill count focused so Claude reliably picks the right one.

---

## Changelog
- **1.0.0** — Portfolio-agnostic core release. ~50-provision construction subcontract rubric, completeness gate, state-law/venue step, analytical passes, citation self-check, memo template, and a one-file (`config.md`) customization surface. Generalized from a company-specific original: company identity, home-state venue, tier position, and specialty (critical-environment) scope are now config-driven rather than hardcoded.
