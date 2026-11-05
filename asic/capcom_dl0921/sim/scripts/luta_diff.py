"""
Compare a system testbench capture with ref_render.py's per-layer LUTA reference:

    python luta_diff.py <cap prefix> <frame> <ref prefix> <out.png>

The sim picture is the active area (CPS-B ~HBLANK / ~VBLANK), one LUTA per pixel. For each layer the script finds
the (dx, dy) offset that best lines up the sim pixels of that layer (LUTA range 0x000 / 0x200 / 0x400 / 0x600)
with the reference, then counts exact LUTA matches. The diff image shows, per pixel of the reference sprite
layer: green = sim equal, red = sim shows a different sprite LUTA, blue = sim shows no sprite there; and
yellow where the sim shows a sprite pixel the reference does not have. With a <ref prefix>_stars.txt holding stars, a
fifth line compares the star pixels (LUTA 0x800-0xbfe, offset (0, 0)): exact, and with the blink step (low 4 bits,
which follow each machine's own frame counter) left out.
"""
import sys

from PIL import Image

sys.path.insert(0, ".")


def sim_luta(prefix, frame):
    from render_cap import load, pixel_rows
    lines, _ = load(prefix, frame)
    return [r for t, r in pixel_rows(lines)]


def ref_luta(prefix):
    rows = []
    for l in open(prefix + "_luta.txt"):
        if l.startswith("#"):
            continue
        rows.append([tuple(int(c[3 * k:3 * k + 3], 16) for k in range(4)) for c in l.split()])
    return rows


def ref_stars(prefix):
    """the star layers' LUTA per visible pixel (ref_render.py _stars.txt; 0xfff = none), or None without the file"""
    import os
    if not os.path.exists(prefix + "_stars.txt"):
        return None
    return [[int(c, 16) for c in l.split()] for l in open(prefix + "_stars.txt") if not l.startswith("#")]


def best_offset(sim, ref, layer, lo, hi, rng=24):
    pts = [(x, y, v) for y, r in enumerate(sim) for x, v in enumerate(r) if lo <= v < hi]
    best = (0, 0, -1)
    if not pts:
        return best
    # (0, 0) first, so an offset that only ties it (a layer of a few repeating tiles) is not taken
    for dy, dx in [(0, 0)] + [(dy, dx) for dy in range(-rng, rng + 1) for dx in range(-rng, rng + 1)]:
        n = 0
        for x, y, v in pts[::7]:
            X, Y = x + dx, y + dy
            if 0 <= Y < len(ref) and 0 <= X < len(ref[Y]) and ref[Y][X][layer] == v:
                n += 1
        if n > best[2]:
            best = (dx, dy, n)
    return best


if __name__ == "__main__":
    cap, frame, refp, out = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
    sim = sim_luta(cap, frame)
    ref = ref_luta(refp)
    names = ("sprites", "scroll1", "scroll2", "scroll3")
    for layer in range(4):
        lo = 0x200 * layer
        dx, dy, n = best_offset(sim, ref, layer, lo, lo + 0x200)
        simn = sum(1 for r in sim for v in r if lo <= v < lo + 0x200)
        refn = sum(1 for r in ref for p in r if p[layer] != 0xfff)
        match = sum(1 for y, r in enumerate(sim) for x, v in enumerate(r) if lo <= v < lo + 0x200
                    and 0 <= y + dy < len(ref) and 0 <= x + dx < 384 and ref[y + dy][x + dx][layer] == v)
        print("%-8s sim pixels %6d  ref pixels %6d  offset (%d, %d)  exact LUTA matches %6d" %
              (names[layer], simn, refn, dx, dy, match))
        if layer == 0:
            sdx, sdy = dx, dy
    st = ref_stars(refp)
    if st is not None and any(v != 0xfff for r in st for v in r):
        pts = [(x, y, v) for y, r in enumerate(sim) for x, v in enumerate(r) if 0x800 <= v < 0xbff]
        refn = sum(1 for r in st for v in r if v != 0xfff)
        ok = sum(1 for x, y, v in pts if y < len(st) and st[y][x] == v)
        ok4 = sum(1 for x, y, v in pts if y < len(st) and st[y][x] != 0xfff and st[y][x] >> 4 == v >> 4)
        print("%-8s sim pixels %6d  ref pixels %6d  offset (0, 0)  exact LUTA matches %6d  without blink step %6d" %
              ("stars", len(pts), refn, ok, ok4))
    im = Image.new("RGB", (384, 224), (0, 0, 0))
    for Y in range(224):
        for X in range(384):
            r = ref[Y][X][0]
            y, x = Y - sdy, X - sdx
            v = sim[y][x] if 0 <= y < len(sim) and 0 <= x < len(sim[y]) else 0xfff
            sv = v if v < 0x200 else None
            if r != 0xfff:
                im.putpixel((X, Y), (0, 200, 0) if sv == r else (220, 0, 0) if sv is not None else (0, 0, 220))
            elif sv is not None:
                im.putpixel((X, Y), (230, 230, 0))
    im.resize((768, 448), Image.NEAREST).save(out)
    print(out)
