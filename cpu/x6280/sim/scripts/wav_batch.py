#!/usr/bin/env python3
"""
Batch convert raw 24-bit signed stereo PCM files from the x6280 VGM
testbench to named 16-bit stereo WAV files.

Usage:
    python scripts/wav_batch.py

Reads track_NN.raw files from output/wav/, uses output/vgm_hex/tracklist.txt
to map track numbers to song names, and writes named WAV files. Raw files
are deleted after successful conversion. A 512-sample fade to zero is
applied at the end of each track to prevent end-of-file pops.

Raw stream format (per sample, 6 bytes little-endian):
    [L_lo, L_mid, L_hi, R_lo, R_mid, R_hi]   (24-bit signed, two's-complement)

WAV output: 44100 Hz, 16-bit PCM, stereo. The lower 8 bits of each 24-bit
sample are dropped (the PSG accumulators rarely reach the full 24-bit range
in practice, and 16-bit is the standard for VGM rip playback).
"""

import wave
import struct
import os
import glob

SAMPLE_RATE = 44100
WAV_DIR     = "output/wav"
TRACKLIST   = "output/vgm_hex/tracklist.txt"
FADE_LEN    = 512

# Output gain. The HuC6280 PSG produces 24-bit signed stereo, but the
# natural full-channel signal range only reaches roughly +/- 184k of the
# 24-bit +/- 8.4M range (about -33 dBFS); on real hardware the analog
# output stage adds gain. Multiplying by GAIN before truncating to 16-bit
# brings line-level WAV output to a reasonable loudness without clipping.
# Bump up if you want the WAVs hotter, drop if you see clipping.
GAIN = 64


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


def s24_le_to_s16(b0, b1, b2):
    """Convert 3-byte little-endian signed 24-bit value to signed 16-bit
    with GAIN applied. Drops low 8 bits and clips to 16-bit range."""
    raw = b0 | (b1 << 8) | (b2 << 16)
    if raw & 0x800000:
        raw -= 0x1000000
    val = (raw * GAIN) >> 8
    if val >  32767: val =  32767
    if val < -32768: val = -32768
    return val


def main():
    raw_files = sorted(glob.glob(os.path.join(WAV_DIR, "track_*.raw")))

    if not raw_files:
        print(f"No track_*.raw files found in {WAV_DIR}/")
        print("Run the ModelSim simulation first.")
        return

    tracklist = load_tracklist()

    print(f"Converting {len(raw_files)} tracks at {SAMPLE_RATE} Hz, 16-bit stereo")
    if tracklist:
        print(f"Using tracklist: {TRACKLIST}\n")
    else:
        print(f"No tracklist found, using sequential names\n")

    for raw_file in raw_files:
        basename  = os.path.basename(raw_file)
        track_num = int(basename.replace("track_", "").replace(".raw", ""))

        if track_num in tracklist:
            wav_name = tracklist[track_num] + ".wav"
        else:
            wav_name = basename.replace(".raw", ".wav")

        wav_file = os.path.join(WAV_DIR, wav_name)

        with open(raw_file, "rb") as f:
            raw_bytes = f.read()

        # 6 bytes per stereo sample (24-bit L + 24-bit R)
        num_samples = len(raw_bytes) // 6
        duration    = num_samples / SAMPLE_RATE

        # Decode into a flat list of signed 16-bit values [L0,R0, L1,R1, ...]
        samples = [0] * (num_samples * 2)
        for i in range(num_samples):
            base = i * 6
            l = s24_le_to_s16(raw_bytes[base + 0], raw_bytes[base + 1], raw_bytes[base + 2])
            r = s24_le_to_s16(raw_bytes[base + 3], raw_bytes[base + 4], raw_bytes[base + 5])
            samples[2 * i    ] = l
            samples[2 * i + 1] = r

        # Linear fade-out on the last FADE_LEN samples (each side)
        fade = min(FADE_LEN, num_samples)
        for i in range(fade):
            idx = num_samples - fade + i
            t   = i / fade
            samples[2 * idx    ] = int(samples[2 * idx    ] * (1.0 - t))
            samples[2 * idx + 1] = int(samples[2 * idx + 1] * (1.0 - t))

        # Pack as little-endian 16-bit signed
        frames = struct.pack("<" + "h" * len(samples), *samples)

        with wave.open(wav_file, "w") as wav:
            wav.setnchannels(2)
            wav.setsampwidth(2)
            wav.setframerate(SAMPLE_RATE)
            wav.writeframes(frames)

        os.remove(raw_file)

        print(f"  {wav_name:40s} {duration:6.2f}s  ({num_samples:>8,} samples)")

    print(f"\nDone. {len(raw_files)} WAV files written to {WAV_DIR}/")


if __name__ == "__main__":
    main()
