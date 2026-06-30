---
name: sw-process-meeting
description: Turn raw meeting notes or a transcript into one clean OKF meeting-note file plus a short list of action items. Use when the user shares messy notes or asks to summarize or process a meeting.
---

# Process a meeting

Given raw notes or a transcript:

1. Write one clean meeting-note markdown file under `local/knowledge/meetings/`
   using the OKF format (`type: meeting-note`), with the date and attendees in
   the frontmatter.
2. Body: a short summary, key decisions, and a clearly labeled "Action items"
   list with an owner per item where known.
3. Follow `standards/writing-standards.md` (no em dashes).
4. Do not publish anything anywhere. This writes to the user's `local/` only.
