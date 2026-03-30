#!/usr/bin/env python3
"""
Convert all VGZ/VGM files in output/vgm/ to a single combined playlist
hex file for the x8910 VGM playback testbench.

Usage:
    python scripts/vgm2hex.py

Output:
    output/vgm_hex/playlist.hex  - Combined hex command file
    output/vgm_hex/tracklist.txt - Track index (number -> name mapping)

Playlist format (32-bit hex words for $readmemh):
    3_CC_CC_CC  = Track start marker, lower 24 bits = AY clock / 44100
    1_RR_00_VV  = Write register RR with value VV
    2_WW_WW_WW  = Wait WWWWWW samples (at 44100 Hz)
    0_00_00_00  = End of track
    F_00_00_00  = End of playlist

Reference: VGM file format specification v1.51+
"""

import sys
import gzip
import struct
import os
import glob


def parse_vgm(data):
    """Parse VGM data, return (ay_clock, commands) where commands is list of
    (type, reg, val, wait) tuples."""
    version = struct.unpack_from('<I', data, 0x08)[0]
    data_offset = struct.unpack_from('<I', data, 0x34)[0] + 0x34 if version >= 0x150 else 0x40

    ay_clock_raw = struct.unpack_from('<I', data, 0x74)[0]
    ay_clock = ay_clock_raw & 0x3FFFFFFF

    # Loop info
    loop_offset_raw = struct.unpack_from('<I', data, 0x1C)[0]
    has_loop = loop_offset_raw != 0
    loop_abs = (0x1C + loop_offset_raw) if has_loop else 0

    commands = []
    pos = data_offset
    pending_wait = 0
    seen_loop_point = False

    while pos < len(data):
        if has_loop and pos == loop_abs and seen_loop_point:
            if pending_wait > 0:
                commands.append(('wait', 0, 0, pending_wait))
            break
        if has_loop and pos == loop_abs and not seen_loop_point:
            seen_loop_point = True

        cmd = data[pos]

        if cmd == 0xA0:
            reg = data[pos + 1] & 0x7F
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
            if pending_wait > 0:
                commands.append(('wait', 0, 0, pending_wait))
            break
        else:
            pos += 1

    return ay_clock, commands


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

            # Strip number prefix and extension for clean name
            name_base = os.path.splitext(filename)[0]
            # Convert to lowercase with underscores for wav naming
            clean_name = name_base.lower().replace(' ', '_')

            # Load VGZ or VGM
            try:
                with gzip.open(filepath, 'rb') as f:
                    data = f.read()
            except gzip.BadGzipFile:
                with open(filepath, 'rb') as f:
                    data = f.read()

            if data[0:4] != b'Vgm ':
                print(f"  Skipping {filename} (not a valid VGM file)")
                continue

            ay_clock, commands = parse_vgm(data)
            total_writes = sum(1 for c in commands if c[0] == 'write')
            total_wait = sum(c[3] for c in commands if c[0] == 'wait')
            duration = total_wait / 44100

            # Track start marker: 3_CC_CC_CC
            # Lower 24 bits = CEN ticks per sample (AY_CLOCK / 44100)
            cen_per_sample = ay_clock // 44100
            marker = (3 << 28) | (cen_per_sample & 0x0FFFFFFF)
            pf.write(f"{marker:08X}\n")

            # Write commands
            for cmd_type, reg, val, wait in commands:
                if cmd_type == 'write':
                    word = (1 << 28) | (reg << 16) | val
                    pf.write(f"{word:08X}\n")
                elif cmd_type == 'wait':
                    word = (2 << 28) | (wait & 0x0FFFFFFF)
                    pf.write(f"{word:08X}\n")

            # End of track
            pf.write("00000000\n")

            num_cmds = total_writes + sum(1 for c in commands if c[0] == 'wait') + 2
            total_commands += num_cmds
            track_entries.append((track_num, clean_name, duration, ay_clock))

            print(f"  [{track_num:02d}] {filename:40s} {duration:6.2f}s  "
                  f"(clock={ay_clock:,} Hz, writes={total_writes})")

        # End of playlist
        pf.write("F0000000\n")
        total_commands += 1

    # Write tracklist index
    with open(tracklist_file, 'w') as tf:
        for track_num, name, duration, clock in track_entries:
            tf.write(f"{track_num:02d} {name} {duration:.2f} {clock}\n")

    print(f"\nPlaylist: {playlist_file} ({total_commands:,} commands)")
    print(f"Tracklist: {tracklist_file} ({len(track_entries)} tracks)")
    print(f"Total duration: {sum(e[2] for e in track_entries):.1f} seconds")


if __name__ == "__main__":
    main()
