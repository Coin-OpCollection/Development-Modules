#!/usr/bin/env python3
"""
Convert all VGZ/VGM files in sim/output/vgm/ to a single combined playlist
hex file for the x76489 (TI SN76489AN) VGM playback testbench.

Usage:
    python sim/scripts/vgm2hex.py            (run from the x76489 IP root)

Output:
    sim/output/vgm_hex/playlist.hex   - combined hex command stream
    sim/output/vgm_hex/tracklist.txt  - track index (number -> name mapping)

Playlist format (32-bit hex words for $readmemh):
    3_CC_CC_CC  = Track start marker, lower 28 bits = chip clock / 44100
                  (81, 3.58 MHz, when the header gives no clock)
    1_00_00_DD  = Write the byte DD
    2_WW_WW_WW  = Wait WWWWWW samples (at 44100 Hz)
    0_00_00_00  = End of track
    F_00_00_00  = End of playlist

VGM commands consumed (file format spec 1.71):
    0x50 dd     SN76489 write dd (clock at header offset 0x0C)
    0x61 nn nn  wait nn samples     0x62 wait 735   0x63 wait 882
    0x70-0x7F   wait (n&0xF)+1 samples              0x66 end of data
"""

import sys
import gzip
import struct
import os
import glob

# Resolve I/O directories relative to this script so the CWD does not matter.
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SIM_DIR    = os.path.dirname(SCRIPT_DIR)
VGM_DIR    = os.path.join(SIM_DIR, "output", "vgm")
HEX_DIR    = os.path.join(SIM_DIR, "output", "vgm_hex")


def parse_vgm(data):
    """Parse VGM data for SN76489 commands, return (clock, commands)."""
    version = struct.unpack_from('<I', data, 0x08)[0]
    data_offset = struct.unpack_from('<I', data, 0x34)[0] + 0x34 if version >= 0x150 else 0x40

    # SN76489 clock at offset 0x0C
    sn_clock = struct.unpack_from('<I', data, 0x0C)[0] & 0x3FFFFFFF

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
                commands.append(('wait', 0, pending_wait))
            break
        if has_loop and pos == loop_abs and not seen_loop_point:
            seen_loop_point = True

        cmd = data[pos]

        if cmd == 0x50:  # SN76489 write
            val = data[pos + 1]
            if pending_wait > 0:
                commands.append(('wait', 0, pending_wait))
                pending_wait = 0
            commands.append(('write', val, 0))
            pos += 2
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
                commands.append(('wait', 0, pending_wait))
            break
        elif cmd == 0x67:
            # Data block - skip
            block_size = struct.unpack_from('<I', data, pos + 3)[0]
            pos += 7 + block_size
        elif 0xA0 <= cmd <= 0xBF:
            pos += 3  # Skip other 2-byte chip writes
        elif 0x51 <= cmd <= 0x5F:
            pos += 3  # Skip other FM chip writes
        elif 0xC0 <= cmd <= 0xCF:
            pos += 4
        elif 0xE0 <= cmd <= 0xEF:
            pos += 5
        else:
            pos += 1

    return sn_clock, commands


def main():
    playlist_file = os.path.join(HEX_DIR, "playlist.hex")
    tracklist_file = os.path.join(HEX_DIR, "tracklist.txt")

    os.makedirs(HEX_DIR, exist_ok=True)

    vgz_files = sorted(glob.glob(os.path.join(VGM_DIR, "*.vgz")))
    vgm_files = sorted(glob.glob(os.path.join(VGM_DIR, "*.vgm")))
    all_files = sorted(vgz_files + vgm_files)

    if not all_files:
        print(f"No VGZ/VGM files found in {VGM_DIR}/")
        sys.exit(1)

    print(f"Found {len(all_files)} track(s) in {VGM_DIR}/\n")

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

            sn_clock, commands = parse_vgm(data)
            total_writes = sum(1 for c in commands if c[0] == 'write')
            total_wait = sum(c[2] for c in commands if c[0] == 'wait')
            duration = total_wait / 44100

            if total_writes == 0:
                print(f"  Skipping {filename} (no SN76489 data)")
                continue

            # CEN ticks per VGM sample: SN_CLOCK / 44100
            cen_per_sample = sn_clock // 44100
            if cen_per_sample == 0:
                cen_per_sample = 81  # Fallback: 3579545/44100 ~= 81

            marker = (3 << 28) | (cen_per_sample & 0x0FFFFFFF)
            pf.write(f"{marker:08X}\n")

            for cmd_type, val, wait in commands:
                if cmd_type == 'write':
                    word = (1 << 28) | (val & 0xFF)
                    pf.write(f"{word:08X}\n")
                elif cmd_type == 'wait':
                    word = (2 << 28) | (wait & 0x0FFFFFFF)
                    pf.write(f"{word:08X}\n")

            pf.write("00000000\n")

            num_cmds = total_writes + sum(1 for c in commands if c[0] == 'wait') + 2
            total_commands += num_cmds
            track_entries.append((track_num, clean_name, duration, sn_clock))

            print(f"  [{track_num:02d}] {filename:40s} {duration:6.2f}s  "
                  f"(clock={sn_clock:,} Hz, writes={total_writes})")

        pf.write("F0000000\n")
        total_commands += 1

    with open(tracklist_file, 'w') as tf:
        for track_num, name, duration, clock in track_entries:
            tf.write(f"{track_num:02d} {name} {duration:.2f} {clock}\n")

    print(f"\nPlaylist: {playlist_file} ({total_commands:,} commands)")
    print(f"Tracklist: {tracklist_file} ({len(track_entries)} track(s))")
    print(f"Total duration: {sum(e[2] for e in track_entries):.1f} seconds")


if __name__ == "__main__":
    main()
