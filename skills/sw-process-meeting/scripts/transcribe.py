#!/usr/bin/env python3
"""Step 2 — transcribe audio to a speaker-labeled JSON transcript.

Provider is swappable (config.transcribe_provider):
  - assemblyai (default): cloud, real speaker diarization in one pass.
    Key: ASSEMBLYAI_API_KEY (or legacy ASSEMBLY_AI).
  - whisper-local: offline/free, no diarization (all turns map to one speaker
    "A"). Use when there is no AssemblyAI credit or the audio must stay local.

Both emit the SAME schema so Step 3 consumes either unchanged:
  {source_file, language, duration_seconds, diarized, speakers[], full_text, segments[]}

Usage:
    python transcribe.py <audio.wav> --out <transcript.json> [--provider assemblyai|whisper-local]
"""
import argparse
import json
import sys
import time
from pathlib import Path

import config


def _write(result: dict, output_path: Path) -> dict:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    return result


def transcribe_assemblyai(audio_path: Path) -> dict:
    import assemblyai as aai

    aai.settings.api_key = config.require_env("ASSEMBLYAI_API_KEY", "ASSEMBLY_AI")
    transcriber = aai.Transcriber()
    cfg = aai.TranscriptionConfig(speaker_labels=True, language_code="en")
    start = time.time()
    transcript = transcriber.transcribe(str(audio_path), config=cfg)
    if transcript.status == aai.TranscriptStatus.error:
        sys.exit(f"  ERROR: {transcript.error}")

    segments = [
        {
            "start": round(u.start / 1000, 2),
            "end": round(u.end / 1000, 2),
            "speaker": u.speaker,
            "text": u.text.strip(),
        }
        for u in transcript.utterances
    ]
    full_text = "\n\n".join(f"{s['speaker']}: {s['text']}" for s in segments)
    speakers = sorted({s["speaker"] for s in segments})
    return {
        "source_file": audio_path.name,
        "language": "en",
        "duration_seconds": round(transcript.audio_duration or 0, 1),
        "transcription_time_seconds": round(time.time() - start, 1),
        "diarized": True,
        "speakers": speakers,
        "full_text": full_text,
        "segments": segments,
    }


def transcribe_whisper_local(audio_path: Path) -> dict:
    """Offline transcription via openai-whisper. No diarization: everything is
    attributed to a single speaker label 'A'. The LLM step still extracts
    summary/actions/topics; it just cannot separate speakers."""
    try:
        import whisper
    except ImportError:
        sys.exit(
            "  ERROR: whisper-local needs the 'openai-whisper' package.\n"
            "         pip install openai-whisper  (or use --provider assemblyai)."
        )
    import os

    model_name = os.getenv("WHISPER_MODEL", "base")
    start = time.time()
    model = whisper.load_model(model_name)
    out = model.transcribe(str(audio_path), language="en")
    segments = [
        {
            "start": round(s["start"], 2),
            "end": round(s["end"], 2),
            "speaker": "A",
            "text": s["text"].strip(),
        }
        for s in out.get("segments", [])
    ]
    full_text = "\n\n".join(f"A: {s['text']}" for s in segments) or out.get("text", "")
    duration = segments[-1]["end"] if segments else 0
    return {
        "source_file": audio_path.name,
        "language": "en",
        "duration_seconds": round(duration, 1),
        "transcription_time_seconds": round(time.time() - start, 1),
        "diarized": False,
        "speakers": ["A"],
        "full_text": full_text,
        "segments": segments,
    }


def main():
    p = argparse.ArgumentParser(description="Transcribe meeting audio")
    p.add_argument("input", help="Path to an audio file (WAV)")
    p.add_argument("--out", required=True, help="Output transcript JSON path")
    p.add_argument("--provider", help="assemblyai (default) or whisper-local")
    args = p.parse_args()

    config.load_env()
    audio_path = Path(args.input).resolve()
    output_path = Path(args.out).resolve()
    if output_path.exists():
        print(f"  Skipping (already exists): {output_path}")
        return

    provider = config.transcribe_provider(args.provider)
    size_mb = audio_path.stat().st_size / (1024 * 1024)
    print(f"  Transcribing ({provider}): {audio_path.name} ({size_mb:.0f} MB)")

    if provider == "assemblyai":
        result = transcribe_assemblyai(audio_path)
    elif provider == "whisper-local":
        result = transcribe_whisper_local(audio_path)
    else:
        sys.exit(f"  ERROR: unknown TRANSCRIBE_PROVIDER '{provider}'")

    _write(result, output_path)
    dur = result["duration_seconds"]
    print(
        f"  Done: {dur/60:.1f} min, {len(result['speakers'])} speaker(s), "
        f"diarized={result['diarized']} -> {output_path.name}"
    )


if __name__ == "__main__":
    main()
