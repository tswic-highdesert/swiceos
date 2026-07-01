#!/usr/bin/env python3
"""Step 1 — extract audio from a video/audio file to 16kHz mono WAV (optimal
for transcription). Portable: paths are explicit, no project layout assumed.

Usage:
    python extract_audio.py <input.mp4> --out <output.wav>
"""
import argparse
import subprocess
import sys
from pathlib import Path


def extract_audio(input_path: Path, output_path: Path) -> Path:
    if output_path.exists():
        print(f"  Skipping (already exists): {output_path}")
        return output_path
    output_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg", "-i", str(input_path),
        "-vn",                   # drop video
        "-acodec", "pcm_s16le",  # 16-bit PCM
        "-ar", "16000",          # 16kHz
        "-ac", "1",              # mono
        "-y", str(output_path),
    ]
    print(f"  Extracting audio: {input_path.name} -> {output_path.name}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ERROR: ffmpeg failed for {input_path.name}", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        sys.exit(1)
    size_mb = output_path.stat().st_size / (1024 * 1024)
    print(f"  Done: {size_mb:.1f} MB")
    return output_path


def main():
    p = argparse.ArgumentParser(description="Extract audio for transcription")
    p.add_argument("input", help="Path to a video or audio file")
    p.add_argument("--out", required=True, help="Output WAV path")
    args = p.parse_args()
    extract_audio(Path(args.input).resolve(), Path(args.out).resolve())


if __name__ == "__main__":
    main()
