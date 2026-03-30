#!/usr/bin/env python3
"""
Batch convert raw PCM files from VGM testbench to named WAV files.

Usage:
    python scripts/wav_batch.py

Reads track_NN.raw files from output/wav/, uses output/vgm_hex/tracklist.txt
to map track numbers to song names, and writes named WAV files. Raw files
are deleted after successful conversion. A 512-sample fade to WAV center
(128) is applied at the end of each track to prevent end-of-file pops.
"""

import wave
import os
import glob

SAMPLE_RATE = 44100
WAV_DIR = "output/wav"
TRACKLIST = "output/vgm_hex/tracklist.txt"
FADE_LEN = 512


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

        raw_data = bytearray(open(raw_file, "rb").read())
        num_samples = len(raw_data)
        duration = num_samples / SAMPLE_RATE

        # Fade last samples to WAV center (128) to avoid pop
        fade = min(FADE_LEN, num_samples)
        for i in range(fade):
            idx = num_samples - fade + i
            t = i / fade
            raw_data[idx] = int(raw_data[idx] * (1.0 - t) + 128 * t)

        with wave.open(wav_file, "w") as wav:
            wav.setnchannels(1)
            wav.setsampwidth(1)
            wav.setframerate(SAMPLE_RATE)
            wav.writeframes(bytes(raw_data))

        # Remove raw file after successful conversion
        os.remove(raw_file)

        print(f"  {wav_name:40s} {duration:6.2f}s  ({num_samples:>8,} samples)")

    print(f"\nDone. {len(raw_files)} WAV files written to {WAV_DIR}/")


if __name__ == "__main__":
    main()
