"""
Layer composite and priority masks against MAME's rules:

    python prio_check.py <capture prefix> <frame> <dump prefix> <ref prefix> <game> [diff.png] [--summary]

The reference composite is built per simulated pixel from the per-layer reference (mame/ref_render.py: _luta.txt,
_grp.txt), each layer taken at the simulation's own alignment (the x offset luta_diff finds for that layer), so a
layer offset does not count here. MAME's rules (cps1_v.cpp
screen_update_cps1): layers drawn bottom to top in the layer-control order (bits 6-7, 8-9, 10-11, 12-13; 0 =
sprites), scroll layers whose enable bit is clear left out; the layer drawn just below the sprites is the "high"
layer: where its pixel's pen bit is set in the priority mask of the tile's group (attribute bits 7-8, CPS-B
priority registers), sprites do not cover it. Backdrop 0xbff.

Prints the pixel counts: composite exact, and the misses split into those the priority rule explains (the sim shows
the high layer where MAME's composite without masks would show a sprite, or the reverse) and the rest.
--summary prints one line instead: composite <exact> / <compared> exact (priority mask applied on <n>).
"""
import os
import struct
import sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from luta_diff import sim_luta, ref_luta, best_offset, ref_stars
from games import GAMES

DEFAULT_DX = {0: 0, 1: 0, 2: 0, 3: 0}            # every layer at MAME's alignment since DL-0921 N10


def offsets(sim, ref):
    """each layer's x offset (reference x = sim x + dx), as luta_diff finds it; default for an empty layer"""
    dx = {}
    for L in range(4):
        x, y, n = best_offset(sim, ref, L, 0x200 * L, 0x200 * (L + 1))
        dx[L] = x if n > 0 else DEFAULT_DX[L]
    return dx


def groups(prefix):
    rows = []
    for l in open(prefix + "_grp.txt"):
        if l.startswith("#"):
            continue
        rows.append([[None] + [None if c == "-" else int(c) for c in t] for t in l.split()])
    return rows


def main():
    summary = "--summary" in sys.argv
    argv = [a for a in sys.argv if a != "--summary"]
    cap, frame, dump, refp, game = argv[1], int(argv[2]), argv[3], argv[4], argv[5]
    g = GAMES[game]
    b = open(dump + "_cpsb.bin", "rb").read()
    reg = lambda off: struct.unpack_from(">H", b, off)[0]
    lc = reg(g["layer"])
    prio = [reg(o) for o in g["prio"]]
    order = [(lc >> s) & 3 for s in (6, 8, 10, 12)]
    on = {0: True, 1: bool(lc & g["enables"][0]), 2: bool(lc & g["enables"][1]), 3: bool(lc & g["enables"][2])}
    k = order.index(0)
    high = order[k - 1] if k > 0 else None
    if not summary:
        print("%s layer control %04x order %s (bottom to top), high layer %s, priority masks %s" % (
            game, lc, order, high, " ".join("%04x" % p for p in prio)))
    sim, ref, grp = sim_luta(cap, frame), ref_luta(refp), groups(refp)
    st = ref_stars(refp)                         # stars under every layer (MAME draws them first), else the backdrop
    DX = offsets(sim, ref)
    stat = Counter()
    bad = []
    for y in range(min(len(sim), len(ref))):
        for x in range(len(sim[y])):
            if not all(0 <= x + DX[L] < 384 for L in DX):
                continue
            px = {L: ref[y][x + DX[L]][L] for L in DX}
            plain = masked = st[y][x] if st is not None and st[y][x] != 0xfff else 0xbff
            covered_by_high = False
            for L in order:
                if not on[L] or px[L] == 0xfff:
                    continue
                plain = px[L]
                if L == 0 and covered_by_high:
                    continue
                masked = px[L]
                if L == high:
                    gr = grp[y][x + DX[L]][L]
                    covered_by_high = gr is not None and (prio[gr] >> (px[L] & 15)) & 1 == 1
                elif L != 0:
                    covered_by_high = False
            s = sim[y][x]
            if st is not None and 0x800 <= masked < 0xbff and 0x800 <= s < 0xbff and s >> 4 == masked >> 4:
                masked = plain = s                       # a star: the blink step follows each machine's own frame count
            if s == masked:
                stat["exact" if masked == plain else "exact, priority mask applied"] += 1
            elif s == plain:
                stat["sim ignores the priority mask"] += 1
                bad.append((x, y, s, masked, plain))
            else:
                stat["other"] += 1
                bad.append((x, y, s, masked, plain))
    if summary:
        exact = stat["exact"] + stat["exact, priority mask applied"]
        print("composite %d / %d exact (priority mask applied on %d)" % (exact, sum(stat.values()),
                                                                        stat["exact, priority mask applied"]))
    else:
        for k2, v in stat.most_common():
            print("  %-32s %6d" % (k2, v))
        for x, y, s, m, p in bad[:12]:
            print("  (%3d,%3d) sim %03x  MAME %03x  (without masks %03x)" % (x, y, s, m, p))
    if len(argv) > 6 and bad:
        from PIL import Image
        im = Image.new("RGB", (384, 224), (0, 0, 0))
        for x, y, s, m, p in bad:
            im.putpixel((x, y), (255, 60, 60) if s == p else (255, 255, 0))
        im.save(argv[6])


if __name__ == "__main__":
    main()
