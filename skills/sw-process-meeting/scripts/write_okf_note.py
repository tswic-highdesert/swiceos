#!/usr/bin/env python3
"""Step 4 — write the canonical deliverable: one OKF `meeting-note` markdown
file under local/knowledge/meetings/<company>/.

This is the source of truth for the knowledge layer. The transcript JSON and
processed JSON are kept as provenance (they cost API $ to regenerate) — this
script does not touch them.

Usage:
    python write_okf_note.py <processed.json> --slug MM-DD-YY-firstnames-topic \
        [--company norristown] [--knowledge-dir <path>] [--date YYYY-MM-DD] \
        [--source <relative/path/to/recording-or-transcript>] [--recording-url URL]
"""
import argparse
import json
import re
from pathlib import Path

DATE_PREFIX = re.compile(r"^(\d{2})-(\d{2})-(\d{2})-")   # MM-DD-YY-
ISO_PREFIX = re.compile(r"^(\d{4})-(\d{2})-(\d{2})")     # YYYY-MM-DD


def date_from_slug(slug: str) -> str | None:
    m = DATE_PREFIX.match(slug)
    if m:
        mo, d, yy = m.groups()
        return f"20{yy}-{mo}-{d}"
    m = ISO_PREFIX.match(slug)
    if m:
        return "-".join(m.groups())
    return None


def title_from_slug(slug: str) -> str:
    body = DATE_PREFIX.sub("", slug)
    body = ISO_PREFIX.sub("", body).lstrip("-")
    return " ".join(w.capitalize() for w in body.split("-")) or slug


def yaml_str(s: str) -> str:
    return '"' + str(s).replace('"', "'") + '"'


def attendees_from(processed: dict) -> list:
    """Real first names of people who actually spoke (from speaker_map),
    skipping Unknowns."""
    names = []
    for v in processed.get("speaker_map", {}).values():
        v = str(v).strip()
        if v and not v.startswith("Unknown"):
            names.append(v.split()[0].lower())
    seen, out = set(), []
    for n in names:
        if n not in seen:
            seen.add(n)
            out.append(n)
    return out


def build_body(processed: dict) -> str:
    lines = []
    summary = processed.get("summary")
    if summary:
        lines += ["## Summary", summary, ""]

    actions = processed.get("action_items", [])
    if actions:
        lines.append("## Action Items")
        for a in actions:
            owner = a.get("owner", "unassigned")
            deadline = a.get("deadline")
            tail = f" (by {deadline})" if deadline else ""
            lines.append(f"- [ ] **{owner}**: {a.get('task', '')}{tail}")
        lines.append("")

    topics = processed.get("key_topics", [])
    if topics:
        lines.append("## Key Topics")
        for t in topics:
            lines.append(f"### {t.get('topic', 'Untitled')}")
            lines.append(t.get("context", ""))
            lines.append("")

    decisions = processed.get("decisions_made", [])
    if decisions:
        lines.append("## Decisions Made")
        lines += [f"- {d}" for d in decisions]
        lines.append("")

    people = processed.get("people", [])
    if people:
        lines.append("## People")
        for p in people:
            lines.append(f"- **{p.get('name', 'Unknown')}** — {p.get('role_context', '')}")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def main():
    p = argparse.ArgumentParser(description="Write an OKF meeting-note")
    p.add_argument("input", help="Path to a processed JSON")
    p.add_argument("--slug", required=True, help="MM-DD-YY-firstnames-topic")
    p.add_argument("--company", default="", help="Company-of-record tag (e.g. norristown, stategov)")
    p.add_argument("--knowledge-dir", default="local/knowledge/meetings",
                   help="Base knowledge dir; the note lands under <dir>/<company>/")
    p.add_argument("--date", help="Override ISO date (else derived from slug)")
    p.add_argument("--source", help="Provenance path (recording or transcript)")
    p.add_argument("--recording-url", help="Watch link to embed in frontmatter")
    args = p.parse_args()

    processed = json.loads(Path(args.input).read_text())
    iso = args.date or date_from_slug(args.slug)
    title = processed.get("_meta", {}).get("wiki_title") or title_from_slug(args.slug)
    attendees = attendees_from(processed)
    tags = ([args.company] if args.company else []) + ["meeting"] + attendees

    fm = ["---", "type: meeting-note", f"title: {yaml_str(title)}"]
    if iso:
        fm.append(f"timestamp: {iso}")
    fm.append("tags: [" + ", ".join(tags) + "]")
    if attendees:
        fm.append("attendees: [" + ", ".join(attendees) + "]")
    if args.recording_url:
        fm.append(f"resource: {args.recording_url}")
    if args.source:
        fm.append(f"source: {args.source}")
    fm.append("---")

    out_dir = Path(args.knowledge_dir)
    if args.company:
        out_dir = out_dir / args.company
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{args.slug}.md"
    out_path.write_text("\n".join(fm) + "\n\n" + build_body(processed))
    print(f"  Wrote OKF meeting-note -> {out_path}")


if __name__ == "__main__":
    main()
