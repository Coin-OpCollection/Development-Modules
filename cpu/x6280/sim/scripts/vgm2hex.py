#!/usr/bin/env python3
"""
Convert all VGZ/VGM files in output/vgm/ to a single combined playlist
hex file for the x6280 (HuC6280 PSG) VGM playback testbench.

Usage:
    python scripts/vgm2hex.py

Output:
    output/vgm_hex/playlist.hex  - Combined hex command file
    output/vgm_hex/tracklist.txt - Track index (number -> name mapping)

Playlist format (32-bit hex words for $readmemh):
    3_CC_CC_CC  = Track start marker, lower 24 bits = CEN ticks per sample
    1_00_RR_DD  = Write data DD to PSG register RR ($1FE800 + RR)
    2_WW_WW_WW  = Wait WWWWWW samples (at 44100 Hz)
    0_00_00_00  = End of track
    F_00_00_00  = End of playlist

The HuC6280 PSG uses VGM command 0xB9 (3-byte: 0xB9, register, data).
HuC6280 PSG clock is at VGM header offset 0xA4 (added in VGM 1.61).

Reference: VGM file format specification
           HuC6280 CMOS 8-bit Microprocessor PSG Manual
"""

import sys
import gzip
import struct
import os
import glob

# Number of total passes through the loop body for files that carry a
# loop header. 1 = intro + loop body once, 2 = intro + loop body twice
# (matches typical VGM player behavior, including vgmrips' web preview).
# Files without a loop header are always parsed once.
LOOP_COUNT = 2


def parse_vgm(data, loop_count=2):
    """Parse VGM data for HuC6280 PSG commands, return (clock, commands).

    loop_count selects how many total passes through the loop body to emit
    (1 = intro + loop body once, 2 = intro + loop body twice, etc.). Files
    without a loop header are always parsed once.
    """
    version = struct.unpack_from('<I', data, 0x08)[0]
    data_offset = struct.unpack_from('<I', data, 0x34)[0] + 0x34 if version >= 0x150 else 0x40

    # HuC6280 PSG clock at offset 0xA4 (added in VGM 1.61)
    huc_clock = 0
    if version >= 0x161 and len(data) >= 0xA8:
        huc_clock = struct.unpack_from('<I', data, 0xA4)[0] & 0x3FFFFFFF

    # Loop info
    loop_offset_raw = struct.unpack_from('<I', data, 0x1C)[0]
    has_loop = loop_offset_raw != 0
    loop_abs = (0x1C + loop_offset_raw) if has_loop else 0

    commands = []
    pos = data_offset
    pending_wait = 0
    loops_remaining = max(loop_count - 1, 0)  # Additional passes after the first

    while pos < len(data):
        cmd = data[pos]

        if cmd == 0xB9:  # HuC6280 PSG write: 0xB9 RR DD
            reg = data[pos + 1] & 0x0F
            val = data[pos + 2]
            if pending_wait > 0:
                commands.append(('wait', 0, 0, pending_wait))
                pending_wait = 0
            commands.append(('write', reg, val, 0))
            pos += 3
        elif cmd == 0x61:
            pending_wait += struct.unpack_from('<H', data, pos + 1)[0]
            pos += 3
        elif cmd == 0x62:
            pending_wait += 735
            pos += 1
        elif cmd == 0x63:
            pending_wait += 882
            pos += 1
        elif 0x70 <= cmd <= 0x7F:
            pending_wait += (cmd - 0x6F)
            pos += 1
        elif cmd == 0x66:
            # End of sound data. If file has a loop point and we have loop
            # passes remaining, jump back and replay the loop body.
            if pending_wait > 0:
                commands.append(('wait', 0, 0, pending_wait))
                pending_wait = 0
            if has_loop and loops_remaining > 0:
                pos = loop_abs
                loops_remaining -= 1
                continue
            break
        elif cmd == 0x67:
            # Data block - skip
            block_size = struct.unpack_from('<I', data, pos + 3)[0]
            pos += 7 + block_size
        elif cmd == 0x50:
            pos += 2  # SN76489 (2-byte)
        elif 0x51 <= cmd <= 0x5F:
            pos += 3  # FM chip writes (2-byte payload)
        elif 0xA0 <= cmd <= 0xBF:
            pos += 3  # Other AY/PSG-class writes
        elif 0xC0 <= cmd <= 0xCF:
            pos += 4
        elif 0xD0 <= cmd <= 0xDF:
            pos += 4
        elif 0xE0 <= cmd <= 0xEF:
            pos += 5
        else:
            pos += 1

    return huc_clock, commands


def main():
    vgm_dir = "output/vgm"
    hex_dir = "output/vgm_hex"
    playlist_file = os.path.join(hex_dir, "playlist.hex")
    tracklist_file = os.path.join(hex_dir, "tracklist.txt")

    os.makedirs(hex_dir, exist_ok=True)

    vgz_files = sorted(glob.glob(os.path.join(vgm_dir, "*.vgz")))
    vgm_files = sorted(glob.glob(os.path.join(vgm_dir, "*.vgm")))
    all_files = sorted(vgz_files + vgm_files)

    if not all_files:
        print(f"No VGZ/VGM files found in {vgm_dir}/")
        sys.exit(1)

    print(f"Found {len(all_files)} tracks in {vgm_dir}/\n")

    total_commands = 0
    track_entries = []

    with open(playlist_file, 'w') as pf:
        for track_num, filepath in enumerate(all_files, 1):
            filename = os.path.basename(filepath)
            name_base = os.path.splitext(filename)[0]
            clean_name = name_base.lower().replace(' ', '_')

            try:
                with gzip.open(filepath, 'rb') as f:
                    data = f.read()
            except gzip.BadGzipFile:
                with open(filepath, 'rb') as f:
                    data = f.read()

            if data[0:4] != b'Vgm ':
                print(f"  Skipping {filename} (not a valid VGM file)")
                continue

            huc_clock, commands = parse_vgm(data, loop_count=LOOP_COUNT)
            total_writes = sum(1 for c in commands if c[0] == 'write')
            total_wait = sum(c[3] for c in commands if c[0] == 'wait')
            duration = total_wait / 44100

            if total_writes == 0:
                print(f"  Skipping {filename} (no HuC6280 PSG data)")
                continue

            # CEN ticks per VGM sample: HUC_CLOCK / 44100
            # If header didn't carry a clock, fall back to standard 7.16 MHz
            cen_per_sample = huc_clock // 44100 if huc_clock else 0
            if cen_per_sample == 0:
                cen_per_sample = 162  # Fallback: 7159000/44100 ~= 162

            marker = (3 << 28) | (cen_per_sample & 0x0FFFFFFF)
            pf.write(f"{marker:08X}\n")

            for cmd_type, reg, val, wait in commands:
                if cmd_type == 'write':
                    word = (1 << 28) | ((reg & 0x0F) << 8) | (val & 0xFF)
                    pf.write(f"{word:08X}\n")
                elif cmd_type == 'wait':
                    word = (2 << 28) | (wait & 0x0FFFFFFF)
                    pf.write(f"{word:08X}\n")

            pf.write("00000000\n")

            num_cmds = total_writes + sum(1 for c in commands if c[0] == 'wait') + 2
            total_commands += num_cmds
            track_entries.append((track_num, clean_name, duration, huc_clock))

            clk_str = f"clock={huc_clock:,} Hz" if huc_clock else "clock=auto (7.16 MHz)"
            print(f"  [{track_num:02d}] {filename:40s} {duration:6.2f}s  "
                  f"({clk_str}, writes={total_writes})")

        pf.write("F0000000\n")
        total_commands += 1

    with open(tracklist_file, 'w') as tf:
        for track_num, name, duration, clock in track_entries:
            tf.write(f"{track_num:02d} {name} {duration:.2f} {clock}\n")

    print(f"\nPlaylist: {playlist_file} ({total_commands:,} commands)")
    print(f"Tracklist: {tracklist_file} ({len(track_entries)} tracks)")
    print(f"Total duration: {sum(e[2] for e in track_entries):.1f} seconds")


if __name__ == "__main__":
    main()
