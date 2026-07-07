# Company profile — the one file you customize

This is the only file you need to edit to make the skill yours. The skill reads
it first and uses these values wherever the rubric says "the Company," "home
state," or "standard position." Ship it as-is and the skill works out of the
box in generic mode; fill it in to sharpen the findings for your business.

Leave a value as `[unset]` and the skill falls back to a safe generic default
(noted per line). No code changes required — this is plain Markdown.

---

## Identity

- **Company name:** the Company
  <!-- The party you are protecting (the one signing as the sub / trade contractor).
       Generic default: "the Company." -->
- **Role you sign as:** Trade Contractor / Subcontractor
  <!-- What the counterparty's form calls you. Generic default: "Trade Contractor." -->
- **Tier position:** first-tier subcontractor
  <!-- "first-tier subcontractor" or "sub-of-sub." If sub-of-sub, the skill escalates
       every flow-down, payment-contingency, and notice provision one severity level.
       Generic default: first-tier (no auto-escalation). -->

## Venue & governing law

- **Home state / preferred venue:** [unset]
  <!-- The state whose courts you prefer, pinned at signing. Generic default: if unset,
       treat ANY venue that isn't neutral/mutually-agreed as a flag and tell the reviewer
       to pin venue before signing. Set this and the skill greens your home state. -->
- **Acceptable neutral venues:** mutually agreed neutral
  <!-- Any additional venues you'll accept. -->

## Business context (sharpens scope, warranty, and specialty provisions)

- **Industry / trade:** general construction / trade
  <!-- e.g., clean-room build-out, mechanical, electrical, data center, waste/environmental
       services, landscaping. Generic default: general construction/trade. -->
- **Specialty / critical-environment scope:** none
  <!-- If your work delivers a measurable environmental or performance result the owner's
       own operations can defeat (clean room ISO class, data-center uptime, controlled
       temp/humidity), name it here. Drives the performance-guarantee, commissioning, and
       site-readiness rows. Generic default: treat as ordinary workmanship scope. -->
- **Long-lead / self-funded materials:** unknown
  <!-- "yes" if you front large vendor deposits or buy long-lead equipment. Turns on the
       deposit + stored-materials + escalation cluster escalation. Generic default: off. -->

## Negotiating posture

- **Standard redline source:** generic fallback language (as written in the rubric)
  <!-- The rubric ships proven/standard/draft redline language. If you have your own
       vetted standard positions, note where they live and the skill will prefer them. -->
- **Rubric owner:** [assign — the person who approves rubric changes]
  <!-- All rubric edits route through this person. -->

---

### How to adapt this skill to a different contract type

The default rubric is tuned for **construction subcontractor / trade agreements**.
To reuse the same pipeline for a different agreement type (service agreement,
vendor MSA, reseller agreement):

1. Keep `SKILL.md` — the pipeline (intake → completeness gate → law lookup →
   score every clause → verify citations → escalate → memo) is contract-agnostic.
2. Replace the provision rows in `rubric/subcontract_rubric.md` with the
   provisions that matter for your contract type, same format (Green/Yellow/Red
   rule, detection cues, redline).
3. Update `rubric/executive_triggers.md` buckets and
   `rubric/state_law_checklist.md` research topics to match.
4. Bump the version and changelog in `README.md`.

Do this in your own copy (your `local/` or `team/` ring), not in core.
