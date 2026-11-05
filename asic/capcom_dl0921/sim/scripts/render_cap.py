"""
Render a system testbench capture: python render_cap.py <cap prefix> <frame> <out.png>

Each capture line (one per LI) holds 4 hex digits per CLK: LUTA (3) and {~HBLANK, ~VBLANK, HSYNC, VSYNC} (1).
A pixel lasts 2 CLK. The CPS-B's ~HBLANK pin goes active one CLK before LUTA moves to the first pixel and inactive
one CLK before the last pixel ends, so the pixels are the samples 1, 3, 5, ... CLK after the ~HBLANK edge (384 per
line); a line is visible when ~VBLANK is active inside that window (~VBLANK changes during horizontal blanking, so a
line with ~VBLANK only in its blanking part is not one). Colored through the palette RAM captured at the same FI
with the A-board DAC (mame/ref_render.py rgb: the board's measured resistor networks).
"""
import os
import sys

from PIL import Image

from ref_render import rgb  # noqa: E402


def load(prefix, frame):
    lines = []
    for l in open("%s_f%d.txt" % (prefix, frame)):
        p = l.split()
        if len(p) == 2:
            lines.append((int(p[0]), p[1]))
    merged = []                                   # LI glitches split a line in two; join pieces < 30 us apart
    for t, s in lines:
        if merged and t - merged[-1][0] < 3000000:
            merged[-1] = (merged[-1][0], merged[-1][1] + s)
        else:
            merged.append((t, s))
    pal = [int(l, 16) for l in open("%s_pal_f%d.txt" % (prefix, frame + 1))]
    return merged, pal


def pixel_rows(lines):
    """[(line time, [LUTA per pixel])] for the visible lines of a capture (see the module notes)"""
    rows = []
    for t, s in lines:
        n = len(s) // 4
        flags = [int(s[4 * i + 3], 16) if s[4 * i + 3] in "0123456789abcdef" else 0 for i in range(n)]
        win = [i for i in range(n) if flags[i] & 8]
        if not win or not any(flags[i] & 4 for i in win):
            continue
        h0, h1 = win[0], win[-1]
        rows.append((t, [int(s[4 * i:4 * i + 3], 16) for i in range(h0 + 1, h1 + 1, 2)]))
    return rows


def render(prefix, frame, out):
    lines, pal = load(prefix, frame)
    rows = [r for t, r in pixel_rows(lines)]
    w = max((len(r) for r in rows), default=0)
    im = Image.new("RGB", (w, len(rows)), (255, 0, 255))
    for y, r in enumerate(rows):
        for x, a in enumerate(r):
            im.putpixel((x, y), rgb(pal[a]) if a != 0xfff or pal[a] else (255, 0, 255))
    im.save(out)
    print(out, im.size)
    return im


if __name__ == "__main__":
    render(sys.argv[1], int(sys.argv[2]), sys.argv[3])
