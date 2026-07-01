---
name: sw-process-meeting
description: Turn a meeting recording, transcript, or raw notes into one clean OKF meeting-note (summary, decisions, action items, key topics, people) in local/knowledge. Bundled, provider-swappable pipeline. Use when the user shares a recording, a transcript, or messy notes, or asks to summarize or process a meeting.
---

# Process a meeting

Universal pipeline: recording or transcript or raw notes -> a single OKF
`meeting-note` in `local/knowledge/meetings/`. The reliability lives in the
deterministic scripts under `scripts/`; your job is to route, supply inputs,
and handle the few judgment calls. Company-specific steps (publishing, tagging,
feedback docs) are NOT in here — they live in extension packs (see the bottom).

## Inputs (pick the entry point)

- **Video/audio file** -> start at Step 1.
- **Existing transcript** (e.g. Google Meet / Gemini, already diarized with real
  names) -> skip Steps 1-2, start at Step 3 with the transcript JSON.
- **Just raw notes, no transcript** -> skip to Step 4 reasoning: extract a short
  summary + action items yourself and hand `write_okf_note.py` a minimal
  processed JSON. Do not fabricate a transcript.

## Setup

The scripts need a few Python packages (see `scripts/requirements.txt`). Install
once into an isolated venv, then run the pipeline with that interpreter:
`uv venv .venv && uv pip install --python .venv/bin/python -r scripts/requirements.txt`.

## Secrets

Never hardcode a key. The scripts read provider keys from the environment; on
Tal's machines that is injected by Infisical. Run the pipeline under:
`infisical run --env prod -- python scripts/<script>.py ...`. As a fallback the
scripts also load a `.env` from the working directory if one is present.

## Providers (swappable, good defaults)

Set via env (or `--provider` / `--model` flags). Defaults in parentheses.
- Transcription `TRANSCRIBE_PROVIDER`: `assemblyai` (default, real diarization,
  key `ASSEMBLYAI_API_KEY`/`ASSEMBLY_AI`) or `whisper-local` (offline/free, no
  diarization — all turns map to one speaker; `WHISPER_MODEL` picks size).
- LLM `LLM_PROVIDER`: `openrouter` (default, key `OPENROUTER_API_KEY`) or
  `anthropic` (key `ANTHROPIC_API_KEY`). `LLM_MODEL` overrides the model.

## Pipeline

All scripts take explicit paths, so run them from anywhere. Keep intermediates
in a scratch dir (e.g. `.tmp/meeting/`); only the OKF note is canonical.

### Step 1 — Extract audio
`python scripts/extract_audio.py <input.mp4> --out .tmp/meeting/<stem>.wav`
Skips if the WAV already exists.

### Step 2 — Transcribe + diarize
`python scripts/transcribe.py .tmp/meeting/<stem>.wav --out transcripts/<stem>.json`
Emits a speaker-labeled transcript. Preserve this JSON — it costs $ to redo.

### Step 3 — LLM analysis
`python scripts/process_transcript.py transcripts/<stem>.json --out processed/<stem>.json [--attendees "Tal,Garth"] [--roster "Tal,Garth,..."]`
- Pass `--attendees` when you know the room (filename, calendar, context). It
  resolves speakers the transcript never names aloud.
- Pass `--roster` with a workspace's common names so close matches snap to the
  canonical spelling. The roster is company config — supply it from the calling
  context/extension pack, it is NOT baked into the prompt.
- **Watch the speaker map.** The script prints `Speakers: A=Name, B=Name` on
  success, or `⚠ SPEAKER MAPPING WARNINGS`. Most damaging silent error is a
  **vocative** ("Garth, just so I know…" means the *listener* is Garth) or a
  fully-inverted 2-speaker map. Cross-check against a known fact (who owns/built
  the thing being discussed). Fix the processed JSON before Step 4.

### Step 4 — Write the OKF note (canonical deliverable)
`python scripts/write_okf_note.py processed/<stem>.json --slug MM-DD-YY-firstnames-topic --company <tag> --source <provenance-path> [--recording-url URL]`
- Slug: `MM-DD-YY-<firstnames>-<2-3-word-topic>` (from `suggested_filename` +
  date). `--company` becomes a tag and a subfolder under
  `local/knowledge/meetings/<company>/`.
- Writes frontmatter (`type: meeting-note`, title, timestamp, tags, attendees,
  source) + body (Summary, Action Items, Key Topics, Decisions, People).

### Step 5 — Preserve provenance
Keep `transcripts/<stem>.json` and `processed/<stem>.json` (expensive to
regenerate; downstream tools consume the structured data). The WAV is
regenerable — delete it. Do not publish anything; this writes to `local/` only.

## Edge cases worth knowing

- **Pre-roll / false start** — a short (<5 min) single-speaker recording that is
  just "let me share the link / start recording" is not a meeting. Stop after
  Step 2, skip the LLM, flag it for the user.
- **Multi-meeting recording** — one file with 2+ meetings: find the boundary by
  a large gap in `segments`, split the transcript, process each part separately.
- **whisper-local has no diarization** — `diarized: false` flows into the
  processed `_meta`. Speaker separation will be weak; lean on `--attendees`.

## Extension packs (company-specific steps)

This core skill stops at the OKF note. Company-specific behavior plugs in via
extension directives, kept in that company's `team/` repo, NOT here:

- `team/norristown/extensions/process-meeting/` — portco-of-record tagging,
  AI-in-Action flagging, Skool/YouTube publishing, portco-wiki feed.
- `team/stategov/extensions/process-meeting/` — the `beta-feedback/<slug>.md`
  product-concerns doc that feeds the StateGov app backlog.

**Hook points** (run the matching extension directives if present):
- `post-transcript` — after Step 3 (e.g. AI-in-Action time check).
- `post-note` — after Step 4 (tagging, publishing, feedback docs).

Follow `standards/writing-standards.md` everywhere (no em dashes).
