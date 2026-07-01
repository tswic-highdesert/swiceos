---
name: sw-produce-newsletter
description: Turn source content (a podcast episode, transcript, article, meeting notes, or a topic brief) into a ~600-900 word newsletter draft in the user's voice, with illustration markers, saved to local/. Publishing to a specific platform (Ghost, Substack, Beehiiv, ...) is an extension pack, not part of this skill. Use when the user asks to write a newsletter, an email essay, or a written cut of a piece of content.
---

# Produce a newsletter draft

Turn a piece of source material into one standalone ~600-900 word newsletter
draft in the user's voice, ready for them to review and send. This skill does
the authoring; publishing to a platform is a separate extension pack (bottom).

The deliverable is a markdown file in the user's `local/` ring. Do not publish
anything anywhere.

## Inputs (any one)

- A podcast episode (script + notes) — the classic "written cut" of an episode.
- A transcript or meeting note.
- An article, a doc, or a rough topic brief.
Read the source, find the 1-2 points worth landing, and write from those.

## Step 1 — Write the cut

A newsletter is a **standalone read**, not a transcript and not bare show notes.
Someone who never saw the source should get the whole point from the draft alone.

- **Length:** ~600-900 words. One clear throughline; land 1-2 points, not ten.
- **Voice:** the user's own voice — conversational, concrete, first person where
  it fits. Open with a real moment or observation, not a summary. Use short
  paragraphs. Earn each section; cut filler.
- **Standards:** follow `standards/writing-standards.md` (no em dashes, ever).
  Strip AI-sounding tells (no "in today's fast-paced world", no throat-clearing).
- **Confidentiality:** do not name clients, companies, or third parties unless
  the user has cleared it. The user's own name is fine.
- **Structure:** a strong opening, 2-4 short movements (a `##` subhead where a
  turn earns one), and a landing that leaves the reader with the single idea.

## Illustration blocks (optional, 2-3 max)

Where a diagram genuinely clarifies a concept (a flow, a before/after, a
comparison) — not decoration — drop a block where the image should appear:

    ::: illustration
    prompt: <schematic diagram description; name the EXACT on-image labels in quotes>
    caption: <one-line caption shown under the image>
    alt: <accessibility / email alt text>
    :::

Order in the file is the illustration number. Keep the prompt specific about
exact on-image text so a downstream renderer produces readable labels. Rendering
the actual PNGs is an extension-pack job, not this skill's.

## Output

Save the draft as markdown in the user's local ring, e.g.
`local/newsletters/<slug>.md` (or alongside the source when an active project
pipeline expects it there). Markdown body only. Hand the path back to the user.

## Publishing (extension packs)

This skill stops at the draft. Anything platform- or stack-specific lives in an
extension pack under `team/<org>/extensions/produce-newsletter/`, NOT here:
- rendering the illustration PNGs (image provider),
- pushing the draft to a newsletter platform (Ghost / Substack / Beehiiv / ...),
- wiring in a podcast "Listen" link or a feature image.

Concrete example: the LevelUp pack turns these drafts into Ghost drafts, renders
illustrations, and embeds a Transistor player. That rig stays in team, so this
core skill works for anyone regardless of their publishing stack.

**Hook point** (run the matching extension directive if present):
- `post-draft` — after Step 1 (render illustrations, publish to the platform).
