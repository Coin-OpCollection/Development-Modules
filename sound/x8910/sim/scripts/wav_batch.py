#!/usr/bin/env python3
"""
Batch convert the AOUT streams of the x8910 VGM testbench to named WAV
files.

Usage:
    python sim/scripts/wav_batch.py          (run from the x8910 IP root)

Reads track_NN.raw files from sim/output/wav/ (16-bit little-endian
samples, AOUT x 8), uses sim/output/vgm_hex/tracklist.txt to map track
numbers to song names, and writes named 16-bit mono WAV files. Raw files are
deleted after successful conversion. No fade is applied: each track ends
with the bench's drain, every amplitude 0, at the IP's silence of 0.
"""

import wave
import os
import glob

# Resolve I/O directories relative to this script so the CWD does not matter.
SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
SIM_DIR     = os.path.dirname(SCRIPT_DIR)
WAV_DIR     = os.path.join(SIM_DIR, "output", "wav")
TRACKLIST   = os.path.join(SIM_DIR, "output", "vgm_hex", "tracklist.txt")
SAMPLE_RATE = 44100


def load_tracklist():
    """Load track index: {track_num: name}"""
    tracks = {}
    if os.path.exists(TRACKLIST):
        with open(TRACKLIST) as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 2:
                    num = int(parts[0])
                    name = parts[1]
                    tracks[num] = name
    return tracks


def main():
    raw_files = sorted(glob.glob(os.path.join(WAV_DIR, "track_*.raw")))

    if not raw_files:
        print(f"No track_*.raw files found in {WAV_DIR}/")
        print("Run the ModelSim simulation first.")
        return

    tracklist = load_tracklist()

    print(f"Converting {len(raw_files)} tracks at {SAMPLE_RATE} Hz")
    if tracklist:
        print(f"Using tracklist: {TRACKLIST}\n")
    else:
        print(f"No tracklist found, using sequential names\n")

    for raw_file in raw_files:
        # Extract track number from filename
        basename = os.path.basename(raw_file)
        track_num = int(basename.replace("track_", "").replace(".raw", ""))

        # Determine output name from tracklist
        if track_num in tracklist:
            wav_name = tracklist[track_num] + ".wav"
        else:
            wav_name = basename.replace(".raw", ".wav")

        wav_file = os.path.join(WAV_DIR, wav_name)

        raw_data = open(raw_file, "rb").read()
        num_samples = len(raw_data) // 2
        duration = num_samples / SAMPLE_RATE

        with wave.open(wav_file, "w") as wav:
            wav.setnchannels(1)
            wav.setsampwidth(2)
            wav.setframerate(SAMPLE_RATE)
            wav.writeframes(raw_data[:num_samples * 2])

        # Remove raw file after successful conversion
        os.remove(raw_file)

        print(f"  {wav_name:40s} {duration:6.2f}s  ({num_samples:>8,} samples)")

    print(f"\nDone. {len(raw_files)} WAV files written to {WAV_DIR}/")


if __name__ == "__main__":
    main()
