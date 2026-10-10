#!/usr/bin/env python3
"""
Batch convert raw unsigned 8-bit mono PCM files from the x76489 (TI
SN76489AN) VGM testbench to named 8-bit mono WAV files.

Usage:
    python sim/scripts/wav_batch.py          (run from the x76489 IP root)

Reads track_NN.raw files from sim/output/wav/, uses
sim/output/vgm_hex/tracklist.txt to map track numbers to song names, and
writes named WAV files. Raw files are deleted after successful conversion.
No fade is applied: each track ends with the bench's drain, every channel
OFF, at the IP's silence of 0.

Raw stream format (per sample, 1 byte):
    AOUT   (8-bit unsigned, mono mix)

WAV output: 44100 Hz, 8-bit PCM, mono.
"""

import wave
import os
import glob

SAMPLE_RATE = 44100
SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
SIM_DIR     = os.path.dirname(SCRIPT_DIR)
WAV_DIR     = os.path.join(SIM_DIR, "output", "wav")
TRACKLIST   = os.path.join(SIM_DIR, "output", "vgm_hex", "tracklist.txt")


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

    print(f"Converting {len(raw_files)} track(s) at {SAMPLE_RATE} Hz")
    if tracklist:
        print(f"Using tracklist: {TRACKLIST}\n")
    else:
        print(f"No tracklist found, using sequential names\n")

    for raw_file in raw_files:
        basename = os.path.basename(raw_file)
        track_num = int(basename.replace("track_", "").replace(".raw", ""))

        if track_num in tracklist:
            wav_name = tracklist[track_num] + ".wav"
        else:
            wav_name = basename.replace(".raw", ".wav")

        wav_file = os.path.join(WAV_DIR, wav_name)

        raw_data = bytearray(open(raw_file, "rb").read())
        num_samples = len(raw_data)
        duration = num_samples / SAMPLE_RATE

        with wave.open(wav_file, "w") as wav:
            wav.setnchannels(1)
            wav.setsampwidth(1)
            wav.setframerate(SAMPLE_RATE)
            wav.writeframes(bytes(raw_data))

        os.remove(raw_file)

        print(f"  {wav_name:40s} {duration:6.2f}s  ({num_samples:>8,} samples)")

    print(f"\nDone. {len(raw_files)} WAV files written to {WAV_DIR}/")


if __name__ == "__main__":
    main()
