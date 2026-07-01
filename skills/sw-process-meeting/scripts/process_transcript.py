#!/usr/bin/env python3
"""Step 3 — LLM analysis of a transcript into structured JSON (summary, action
items, key topics, decisions, people, speaker_map, suggested_filename).

Provider is swappable (config.llm_provider):
  - openrouter (default): OpenAI-compatible. Key: OPENROUTER_API_KEY.
  - anthropic: native Anthropic SDK. Key: ANTHROPIC_API_KEY.

The speaker-identification guidance below is universal. Anything
company-specific (a known-names roster, a workspace label) is injected at
runtime via --roster / --attendees, never hardcoded here.

Usage:
    python process_transcript.py <transcript.json> --out <processed.json>
        [--provider openrouter|anthropic] [--model ID]
        [--attendees "Tal,Garth"] [--roster "Tal,Garth,Misty,..."]
"""
import argparse
import json
import re
import sys
from pathlib import Path

import config

SYSTEM_PROMPT = """You are an expert meeting analyst. Given a meeting transcript, produce a structured JSON analysis.

Return ONLY valid JSON with these fields:
{
  "summary": "2-3 paragraph overview of the meeting — what was discussed, key outcomes, overall tone",
  "action_items": [
    {"owner": "the owner's speaker_map name — including an 'Unknown (Speaker X)' value — or 'unassigned' only if no owner is discernible at all", "task": "description", "deadline": "if mentioned, else null"}
  ],
  "key_topics": [
    {"topic": "short title", "context": "1-2 sentence explanation of what was discussed about this topic"}
  ],
  "decisions_made": ["concise description of each decision"],
  "people": [
    {"name": "real name (or 'Unknown (Speaker X)' if unmappable)", "role_context": "their role or why they were mentioned", "speaker_label": "transcript label (A, B, ...) if this person spoke, else null"}
  ],
  "speaker_map": {"A": "real name", "B": "real name", "...": "..."},
  "suggested_filename": "firstname-firstname-main-topic (kebab-case, no date — first names of IDENTIFIED attendees + 2-3 word topic, e.g. 'tal-james-ai-onboarding'; if an attendee could not be identified, omit them rather than writing 'unknown')"
}

Be thorough but concise. Extract every action item — even implicit ones. For people, include anyone mentioned by name.
Attribute every action item, decision, and summary statement to a speaker_map name. The ONLY acceptable
non-name values are 'unassigned' (a task with no discernible owner) and an 'Unknown (Speaker X)' value for a
speaker who genuinely cannot be identified. Never leave a bare "Speaker A" / "Speaker B" as if it were a name —
but "Unknown (Speaker B)" IS the correct, expected value for an unidentified speaker; use it, do not downgrade
their owned action items to 'unassigned'.

SPEAKER IDENTIFICATION — read carefully, this is the most common and most damaging error.
The transcript prefixes every utterance with a speaker label (e.g. "A:", "B:", "SPEAKER_00:"). You must map each
label to a real name and populate the "speaker_map" field. A name spoken aloud plays one of two roles — tell them apart:

  1. DIRECT ADDRESS (vocative) — the speaker is talking TO someone by name.
     Examples: "Garth, just so I know...", "Thanks, Tal.", "...you know what I mean, Garth?", "Hey Rusty—"
     A vocative name belongs to the LISTENER (the OTHER speaker), NOT the one currently talking.
  2. REFERENCE — the speaker is talking ABOUT someone in the third person.
     Examples: "Chris is the CFO", "I'll ask Cody about that." A referenced name usually belongs to a
     non-speaker, or to a speaker described in third person — it does NOT identify the current speaker.

A speaker almost never says their own name. So when label B's utterance contains a name, that is overwhelmingly
B addressing that person — meaning that person is the OTHER label. In a 2-person meeting, identifying one speaker
by their vocative immediately fixes the other by elimination.

Before finalizing, VERIFY:
- Every speaker label has exactly one name in speaker_map; no two labels share a name.
- You did not assign a name to a speaker merely because that name appeared inside their own utterance
  (it was probably a vocative addressed TO them).
- action_item owners, decisions, and the summary all use the speaker_map names, consistent with the people list.
If a speaker truly cannot be identified, set their speaker_map value to "Unknown (Speaker X)" — never guess.

If the user message provides a "Known attendees" list, those are the confirmed real names of the people in
this meeting. Map the speaker labels onto exactly those names — work out which label is which using vocatives,
self-reference, and who-knows-what context. This list resolves speakers the transcript never names aloud.
"""


def validate_speaker_mapping(result: dict, transcript_speakers: list) -> list:
    """Deterministic sanity-check of the LLM's speaker identification. Surfaces
    problems (it cannot fix the mapping — that needs the LLM) so they are not
    shipped silently."""
    warnings = []
    speaker_map = result.get("speaker_map", {})
    for label in transcript_speakers:
        if label not in speaker_map:
            warnings.append(f"speaker_map missing label '{label}'")
    seen = {}
    for label, name in speaker_map.items():
        if name in seen and not str(name).startswith("Unknown"):
            warnings.append(f"labels '{seen[name]}' and '{label}' both map to '{name}'")
        seen[name] = label

    def has_bare_label(text) -> bool:
        return isinstance(text, str) and re.search(r"(?<!\()\bSpeaker [A-Z0-9]\b", text) is not None

    for a in result.get("action_items", []):
        if has_bare_label(a.get("owner")):
            warnings.append(f"action item owner is a bare speaker label: {a.get('owner')!r}")
    for p in result.get("people", []):
        if has_bare_label(p.get("name")):
            warnings.append(f"person name is a bare speaker label: {p.get('name')!r}")
    return warnings


def _build_user_message(full_text: str, attendees: list | None, roster: list | None) -> str:
    parts = []
    if roster:
        parts.append(
            "Names commonly seen in this workspace (use these spellings if you encounter a close "
            f"match): {', '.join(roster)}.\n"
        )
    if attendees:
        parts.append(
            "Known attendees (confirmed real names of the people in this meeting): "
            f"{', '.join(attendees)}\n"
        )
    parts.append(f"Analyze this meeting transcript:\n\n{full_text}")
    return "\n".join(parts)


def _call_openrouter(model: str, full_text: str, attendees, roster) -> str:
    from openai import OpenAI

    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=config.require_env("OPENROUTER_API_KEY"),
    )
    resp = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": _build_user_message(full_text, attendees, roster)},
        ],
        temperature=0.2,
        # Cap the output reservation. Without this OpenRouter reserves the model's
        # full max output up front and 402s when the key's remaining credit is
        # below that, even though the actual JSON output is only ~4-5k tokens.
        max_tokens=16000,
    )
    return (resp.choices[0].message.content or "").strip()


def _call_anthropic(model: str, full_text: str, attendees, roster) -> str:
    import anthropic

    client = anthropic.Anthropic(api_key=config.require_env("ANTHROPIC_API_KEY"))
    resp = client.messages.create(
        model=model,
        max_tokens=16000,
        temperature=0.2,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": _build_user_message(full_text, attendees, roster)}],
    )
    return "".join(block.text for block in resp.content if block.type == "text").strip()


def process_transcript(transcript_path: Path, output_path: Path, provider: str, model: str,
                       attendees=None, roster=None) -> dict:
    if output_path.exists():
        print(f"  Skipping (already exists): {output_path}")
        with open(output_path) as f:
            return json.load(f)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(transcript_path) as f:
        transcript = json.load(f)
    full_text = transcript["full_text"]
    duration_min = transcript.get("duration_seconds", 0) / 60

    max_chars = 100_000
    if len(full_text) > max_chars:
        full_text = full_text[:max_chars] + "\n\n[TRANSCRIPT TRUNCATED]"

    hint = f" — attendee hint: {', '.join(attendees)}" if attendees else ""
    print(f"  Processing ({provider}/{model}): {transcript_path.name} "
          f"({duration_min:.0f} min, {len(full_text):,} chars){hint}")

    if provider == "openrouter":
        result_text = _call_openrouter(model, full_text, attendees, roster)
    elif provider == "anthropic":
        result_text = _call_anthropic(model, full_text, attendees, roster)
    else:
        sys.exit(f"  ERROR: unknown LLM_PROVIDER '{provider}'")

    # Tolerate markdown fences / stray prose around the JSON.
    fence = re.search(r"```(?:json)?\s*(\{.*\})\s*```", result_text, re.DOTALL)
    if fence:
        result_text = fence.group(1)
    else:
        start, end = result_text.find("{"), result_text.rfind("}")
        if start != -1 and end > start:
            result_text = result_text[start:end + 1]
    try:
        result = json.loads(result_text)
    except json.JSONDecodeError as e:
        snippet = result_text[:300].replace("\n", " ")
        sys.exit(f"  ✗ LLM did not return valid JSON ({e}). First 300 chars:\n      {snippet}")

    result["_meta"] = {
        "source_transcript": transcript_path.name,
        "duration_minutes": round(duration_min, 1),
        "provider": provider,
        "model": model,
        "input_chars": len(full_text),
        "diarized": transcript.get("diarized", True),
    }
    with open(output_path, "w") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"  Done: {len(result.get('action_items', []))} action items, "
          f"{len(result.get('key_topics', []))} topics -> {output_path.name}")
    warnings = validate_speaker_mapping(result, transcript.get("speakers", []))
    if warnings:
        print("  ⚠ SPEAKER MAPPING WARNINGS — review before using:")
        for w in warnings:
            print(f"      - {w}")
    else:
        smap = result.get("speaker_map", {})
        print(f"  Speakers: {', '.join(f'{k}={v}' for k, v in smap.items())}")
    return result


def _split(value: str | None) -> list | None:
    return [x.strip() for x in value.split(",") if x.strip()] if value else None


def main():
    p = argparse.ArgumentParser(description="LLM analysis of a meeting transcript")
    p.add_argument("input", help="Path to a transcript JSON")
    p.add_argument("--out", required=True, help="Output processed JSON path")
    p.add_argument("--provider", help="openrouter (default) or anthropic")
    p.add_argument("--model", help="Model id (defaults per provider)")
    p.add_argument("--attendees", help="Comma-separated confirmed attendee names")
    p.add_argument("--roster", help="Comma-separated known-names roster for this workspace")
    args = p.parse_args()

    config.load_env()
    provider = config.llm_provider(args.provider)
    model = config.llm_model(args.model)
    process_transcript(
        Path(args.input).resolve(), Path(args.out).resolve(), provider, model,
        attendees=_split(args.attendees), roster=_split(args.roster),
    )


if __name__ == "__main__":
    main()
