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
    3_CC_CC_CC  = Track start marker, lower 28 bits = chip clock in Hz
                  (3579545 when the header gives no clock)
    1_00_00_DD  = Write the byte DD
    2_WW_WW_WW  = Wait WWWWWW samples (at 44100 Hz)
    0_00_00_00  = End of track
    F_00_00_00  = End of playlist

VGM commands consumed (file format spec 1.71):
    0x50 dd     SN76489 write dd (clock at header offset 0x0C)
    0x61 nn nn  wait nn samples     0x62 wait 735   0x63 wait 882
    0x70-0x7F   wait (n&0xF)+1      0x80-0x8F wait n&0xF   0x66 end of data
Every other command is skipped by its operand length, the second SN76489 of
a dual-chip file (0x30 dd) included. A file plays once, to 0x66.

Header check: the x76489 is the TI SN76489AN. A file whose header gives
another noise feedback pattern (0x28) than 0x0003 or 0x0006, another shift
register width (0x2A) than 15 or 16, XNOR noise or no /8 clock divider
(0x2B bits 4 and 3), or a T6W28 (clock bit 31) is skipped with the reason.
Before version 1.10, and where 0x28 or 0x2A is 0, the specification's
defaults apply: feedback 0x0009 and width 16, the Sega VDP PSG.

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
DEF_CLOCK  = 3579545
MAX_CMDS   = 262144                       # tb_x76489_vgm.v playlist size


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
    """Why the header describes a part the x76489 does not model, or None."""
    clock = struct.unpack_from('<I', data, 0x0C)[0]
    if clock & 0x80000000:
        return "T6W28"
    fb = struct.unpack_from('<H', data, 0x28)[0] if version >= 0x110 else 0
    width = data[0x2A] if version >= 0x110 else 0
    flags = data[0x2B] if version >= 0x151 else 0
    fb = fb or 0x0009
    width = width or 16
    if fb not in (0x0003, 0x0006):
        return "noise feedback 0x%04X" % fb
    if width not in (15, 16):
        return "shift register width %d" % width
    if flags & 0x10:
        return "XNOR noise"
    if flags & 0x08:
        return "no /8 clock divider"
    return None


def parse_vgm(data):
    """Parse VGM data for SN76489 commands, return (clock, commands)."""
    version = struct.unpack_from('<I', data, 0x08)[0]
    data_offset = struct.unpack_from('<I', data, 0x34)[0] + 0x34 if version >= 0x150 else 0x40

    # SN76489 clock at offset 0x0C
    sn_clock = struct.unpack_from('<I', data, 0x0C)[0] & 0x3FFFFFFF

    commands = []
    pos = data_offset
    pending_wait = 0

    while pos < len(data):
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
            pending_wait += (cmd & 0x0F) + 1
            pos += 1
        elif 0x80 <= cmd <= 0x8F:
            pending_wait += cmd & 0x0F
            pos += 1
        elif cmd == 0x66:
            if pending_wait > 0:
                commands.append(('wait', 0, pending_wait))
            break
        else:
            pos += 1 + operand_len(cmd, data, pos, version)

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
                print(f"  Skipping {filename} (not an SN76489AN: {problem})")
                continue

            sn_clock, commands = parse_vgm(data)
            total_writes = sum(1 for c in commands if c[0] == 'write')
            total_wait = sum(c[2] for c in commands if c[0] == 'wait')
            duration = total_wait / 44100

            if total_writes == 0:
                print(f"  Skipping {filename} (no SN76489 data)")
                continue

            clock = sn_clock if sn_clock else DEF_CLOCK
            track_num = len(track_entries) + 1

            marker = (3 << 28) | (clock & 0x0FFFFFFF)
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
            track_entries.append((track_num, clean_name, duration, clock))

            print(f"  [{track_num:02d}] {filename:40s} {duration:6.2f}s  "
                  f"(clock={clock:,} Hz, writes={total_writes})")

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
