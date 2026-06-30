---
type: process
title: Knowledge file format (OKF house style)
---

# Knowledge file format

Every knowledge file is one concept, one markdown file, with YAML frontmatter.
This follows the Open Knowledge Format convention (markdown + frontmatter in
git). We use the convention, not any external tooling.

## Required frontmatter

```
---
type: <one of the locked vocabulary below>
title: <short human title>
---
```

Optional: `tags`, `timestamp`, `resource`, `owner`.

## Locked type vocabulary

- `portco` (a company)
- `runbook` (a repeatable how-to with steps)
- `process` (how we do a thing, narrative)
- `meeting-note` (output of a meeting)
- `roadmap-item` (planned work)
- `person` (a stakeholder)
- `decision` (a decision record)

Adding a new type requires a one-line decision record. Keep the list short so
the bundle stays queryable.
