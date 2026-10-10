#!/usr/bin/env python3
"""
Convert all VGZ/VGM files in sim/output/vgm/ to a single combined playlist
hex file for the x8910 (GI AY-3-8910) VGM playback testbench.

Usage:
    python sim/scripts/vgm2hex.py            (run from the x8910 IP root)

Output:
    sim/output/vgm_hex/playlist.hex   - combined hex command stream
    sim/output/vgm_hex/tracklist.txt  - track index (number -> name mapping)

Playlist format (32-bit hex words for $readmemh):
    3_CC_CC_CC  = Track start marker, lower 28 bits = chip clock in Hz
    1_00_RR_VV  = Write VV to register RR (0-15)
    2_WW_WW_WW  = Wait WWWWWW samples (at 44100 Hz)
    0_00_00_00  = End of track
    F_00_00_00  = End of playlist

VGM commands consumed (file format spec 1.71):
    0xA0 aa dd  AY-3-8910 write dd to register aa (clock at header 0x74)
    0x61 nn nn  wait nn samples     0x62 wait 735   0x63 wait 882
    0x70-0x7F   wait (n&0xF)+1      0x80-0x8F wait n&0xF   0x66 end of data
Every other command is skipped by its operand length. Writes to the second
chip of a dual-chip file (aa bit 7) and to registers above 15 are skipped
and counted. A file plays once, to 0x66.

Header check: the x8910 is the GI AY-3-8910. A file whose AY type (0x78,
version 1.51 and later) is not an AY-3-8910, AY-3-8912 or AY-3-8913 (0x00,
0x01, 0x02), such as the AY8930 or the YM2149 family, is skipped with the
reason. Before version 1.51 the type is taken as the AY-3-8910.

The playlist must fit the bench's MAX_CMDS (262144 words); a longer one
stops with an error.
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
MAX_CMDS   = 262144                       # tb_x8910_vgm.v playlist size
AY_TYPES   = {0x00: "AY-3-8910", 0x01: "AY-3-8912", 0x02: "AY-3-8913"}


def operand_len(cmd, data, pos, version):
    """Bytes after the command byte, per the VGM 1.71 specification."""
    if 0x30 <= cmd <= 0x3F or cmd in (0x4F, 0x50, 0x94):
        return 1
    if 0x40 <= cmd <= 0x4E:
        return 2 if version >= 0x160 else 1
    if 0x51 <= cmd <= 0x5F or 0xA0 <= cmd <= 0xBF or cmd == 0x61:
        return 2
    if cmd == 0x64 or 0xC0 <= cmd <= 0xDF:
        return 3
    if 0xE0 <= cmd <= 0xFF or cmd in (0x90, 0x91, 0x95):
        return 4
    if cmd == 0x92:
        return 5
    if cmd == 0x93:
        return 10
    if cmd == 0x68:
        return 11
    if cmd == 0x67:                      # data block: 0x66 tt ss(4) + data
        return 6 + (struct.unpack_from('<I', data, pos + 3)[0] & 0x7FFFFFFF)
    return 0


def variant_problem(data, version):
    """Why the header describes a part the x8910 does not model, or None."""
    if version >= 0x151 and len(data) > 0x78:
        ay_type = data[0x78]
        if ay_type not in AY_TYPES:
            return "AY type 0x%02X" % ay_type
    return None


def parse_vgm(data):
    """Parse VGM data, return (ay_clock, commands, skipped writes)."""
    version = struct.unpack_from('<I', data, 0x08)[0]
    data_offset = struct.unpack_from('<I', data, 0x34)[0] + 0x34 if version >= 0x150 else 0x40

    # AY-3-8910 clock at offset 0x74; bit 30 marks a second chip
    ay_clock = struct.unpack_from('<I', data, 0x74)[0] & 0x3FFFFFFF

    commands = []
    pos = data_offset
    pending_wait = 0
    skipped = 0

    while pos < len(data):
        cmd = data[pos]

        if cmd == 0xA0:
            aa, val = data[pos + 1], data[pos + 2]
            pos += 3
            if aa & 0x80 or aa > 0x0F:
                skipped += 1
                continue
            if pending_wait > 0:
                commands.append(('wait', 0, 0, pending_wait))
                pending_wait = 0
            commands.append(('write', aa, val, 0))
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
            pending_wait += (cmd & 0x0F) + 1
            pos += 1
        elif 0x80 <= cmd <= 0x8F:
            pending_wait += cmd & 0x0F
            pos += 1
        elif cmd == 0x66:
            if pending_wait > 0:
                commands.append(('wait', 0, 0, pending_wait))
            break
        else:
            pos += 1 + operand_len(cmd, data, pos, version)

    return ay_clock, commands, skipped


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

    print(f"Found {len(all_files)} file(s) in {VGM_DIR}/\n")

    total_commands = 0
    track_entries = []

    with open(playlist_file, 'w') as pf:
        for filepath in all_files:
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

            version = struct.unpack_from('<I', data, 0x08)[0]
            problem = variant_problem(data, version)
            if problem:
                print(f"  Skipping {filename} (not an AY-3-8910: {problem})")
                continue

            ay_clock, commands, skipped = parse_vgm(data)
            total_writes = sum(1 for c in commands if c[0] == 'write')
            total_wait = sum(c[3] for c in commands if c[0] == 'wait')
            duration = total_wait / 44100

            if total_writes == 0 or ay_clock == 0:
                print(f"  Skipping {filename} (no AY-3-8910 data)")
                continue

            track_num = len(track_entries) + 1

            marker = (3 << 28) | (ay_clock & 0x0FFFFFFF)
            pf.write(f"{marker:08X}\n")

            for cmd_type, reg, val, wait in commands:
                if cmd_type == 'write':
                    word = (1 << 28) | (reg << 8) | val
                    pf.write(f"{word:08X}\n")
                elif cmd_type == 'wait':
                    word = (2 << 28) | (wait & 0x0FFFFFFF)
                    pf.write(f"{word:08X}\n")

            pf.write("00000000\n")

            num_cmds = total_writes + sum(1 for c in commands if c[0] == 'wait') + 2
            total_commands += num_cmds
            track_entries.append((track_num, clean_name, duration, ay_clock))

            note = f", {skipped} second-chip or unknown writes skipped" if skipped else ""
            print(f"  [{track_num:02d}] {filename:40s} {duration:6.2f}s  "
                  f"(clock={ay_clock:,} Hz, writes={total_writes}{note})")

        pf.write("F0000000\n")
        total_commands += 1

    if total_commands > MAX_CMDS:
        sys.exit(f"Playlist has {total_commands:,} words, more than the bench's "
                 f"{MAX_CMDS:,}; split the VGM files into smaller batches")

    with open(tracklist_file, 'w') as tf:
        for track_num, name, duration, clock in track_entries:
            tf.write(f"{track_num:02d} {name} {duration:.2f} {clock}\n")

    print(f"\nPlaylist: {playlist_file} ({total_commands:,} commands)")
    print(f"Tracklist: {tracklist_file} ({len(track_entries)} track(s))")
    print(f"Total duration: {sum(e[2] for e in track_entries):.1f} seconds")


if __name__ == "__main__":
    main()
