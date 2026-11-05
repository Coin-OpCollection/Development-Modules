"""
Reference CPS1 renderer for a MAME frame dump (dump_frames.lua), following MAME src/mame/capcom/cps1_v.cpp:

    python ref_render.py <dump prefix> <gfx.bin> <game> <out prefix> [star frame number]

The game's mapper, CPS-B register offsets and layer enable masks come from games.py.

Writes <out>_spr.png, _s1.png, _s2.png, _s3.png (each layer alone, 384x224 visible area, transparent = magenta)
and <out>_luta.txt: per visible pixel and layer, the LUTA value the layer would put out (fff = transparent),
<out>_grp.txt: the priority group of each scroll pixel, and <out>_stars.txt: the star layers' LUTA per visible pixel
(fff = no star; the 0xa00 layer drawn over the 0x800 one, both under every other layer). The stars blink with MAME's
frame number, taken from the dump prefix (_fNNNNN) unless given.
The per-layer views are the targets for the gate-level frame buffer and the CPS-B layer outputs.

Sprites: MAME draws the buffered OBJ table last entry first, so earlier entries win; block sprites wrap the tile
x within a 16-tile row. Scroll 1 is 8x8 (even columns use the left half of the 16-pixel ROM row, odd the right),
scroll 2 16x16 with row scroll (video control bit 0), scroll 3 32x32. Visible area x 64-447, y 16-239.
"""
import struct
import sys

from PIL import Image

from games import GAMES     # per game: MAME mapper, CPS-B register offsets and layer enable masks
SHIFT = {1: 1, 2: 0, 4: 1, 8: 3}


def words(path):
    b = open(path, "rb").read()
    return list(struct.unpack(">%dH" % (len(b) // 2), b))


class Ref:
    def __init__(self, prefix, gfx, game):
        self.ram = words(prefix + "_gfxram.bin")
        self.a = words(prefix + "_cpsa.bin")
        self.b = words(prefix + "_cpsb.bin")
        self.gfx = open(gfx, "rb").read()
        self.cfg = GAMES[game]
        self.groups = {}
        self.sizes, self.ranges = self.cfg["mapper"]

    def base(self, reg):
        """word offset in GFX RAM (MAME cps1_base): the base aligned down to its boundary, 0x4000 for the scroll layers,
        0x800 for OBJ and row scroll, 0x400 for the palette (slammast puts scroll 3 at 0x9120, used as 0x9100)"""
        align = {0: 0x800, 1: 0x4000, 2: 0x4000, 3: 0x4000, 4: 0x800, 5: 0x400}[reg]
        return (((self.a[reg] << 8) & ~(align - 1)) & 0x3ffff) >> 1

    def mapper(self, typ, code):
        u = code << SHIFT[typ]
        for t, s, e, bank in self.ranges:
            if s <= u <= e and t & typ:
                return (sum(self.sizes[:bank]) + (u & (self.sizes[bank] - 1))) >> SHIFT[typ]
        return -1

    def row(self, unit64, half):
        """4 pens of one 8-pixel half row: byte k = plane k (planes 24, 16, 8, 0 -> pen bits 3..0 at bytes 0..3)"""
        o = unit64 * 8 + half * 4
        if o + 4 > len(self.gfx):
            return [15] * 8
        b = self.gfx[o:o + 4]
        # MAME layout planes { 24, 16, 8, 0 } list the pen MSB first: pen bit 3 = bit offset 24 (byte 3), bit 0 =
        # byte 0; x offsets STEP8(0, 1) put pixel 0 in bit 7 of each byte
        return [((b[0] >> (7 - x)) & 1) | (((b[1] >> (7 - x)) & 1) << 1) | (((b[2] >> (7 - x)) & 1) << 2)
                | (((b[3] >> (7 - x)) & 1) << 3) for x in range(8)]

    def tile_pixel(self, typ, code, px, py):
        """pen of pixel (px, py) inside a tile of the layer type, code already mapped"""
        if typ == 1 or typ == 4:                          # 16x16: 128 bytes, row = 8 bytes
            return self.row(code * 16 + py, px >> 3)[px & 7]
        if typ == 8:                                      # 32x32: 512 bytes, row = 16 bytes
            return self.row(code * 64 + py * 2 + (px >> 4), (px >> 3) & 1)[px & 7]
        raise ValueError

    # ---- sprites -----------------------------------------------------------------------------------------
    def sprites(self):
        buf = [[None] * 512 for _ in range(256)]
        obj = self.base(0)
        ents = []
        for i in range(0, 0x400, 4):                      # 256 entries max
            x, y, code, attr = self.ram[obj + i:obj + i + 4]
            if attr & 0xff00 == 0xff00:
                break
            ents.append((x, y, code, attr))
        for x, y, code, attr in reversed(ents):           # last first: earlier entries overwrite
            col = attr & 0x1f
            fx, fy = (attr >> 5) & 1, (attr >> 6) & 1
            if attr & 0xff00:
                nx, ny = ((attr >> 8) & 0xf) + 1, ((attr >> 12) & 0xf) + 1
            else:
                nx = ny = 1
            for nys in range(ny):
                for nxs in range(nx):
                    tx = (nx - 1 - nxs) if fx else nxs
                    ty = (ny - 1 - nys) if fy else nys
                    c = (code & ~0xf) + ((code + tx) & 0xf) + 0x10 * ty
                    m = self.mapper(1, c)
                    if m < 0:
                        continue
                    sx, sy = (x + nxs * 16) & 0x1ff, (y + nys * 16) & 0x1ff
                    for py in range(16):
                        for px in range(16):
                            pen = self.tile_pixel(1, m, 15 - px if fx else px, 15 - py if fy else py)
                            if pen != 15:
                                X, Y = (sx + px) & 0x1ff, (sy + py) & 0x1ff
                                if Y < 256:
                                    buf[Y][X] = col * 16 + pen
        return buf, ents

    # ---- scroll layers ---------------------------------------------------------------------------------
    def scroll(self, n):
        """LUTA per screen pixel (512 x 256 bitmap) for scroll layer n (1-3), None where transparent"""
        base = self.base(n)
        tsz = {1: 8, 2: 16, 3: 32}[n]
        typ = {1: 2, 2: 4, 3: 8}[n]
        sx0 = self.a[6 + 2 * (n - 1)]
        sy0 = self.a[7 + 2 * (n - 1)]
        rowscroll = n == 2 and (self.a[0x11] & 1)
        other = self.base(4)
        roff = self.a[0x10]
        W = 64 * tsz
        out = [[None] * 512 for _ in range(256)]
        self.groups[n] = grp = [[None] * 512 for _ in range(256)]
        for Y in range(16, 240):
            ty = (Y + sy0) & (W - 1)
            sx = sx0
            if rowscroll:                                 # MAME: screen line i -> other[(i + offset) & 0x3ff]
                sx = sx0 + self.ram[other + ((Y + roff) & 0x3ff)]
            for X in range(64, 448):
                tx = (X + sx) & (W - 1)
                col, row = tx // tsz, ty // tsz
                if n == 1:
                    ti = (row & 0x1f) + ((col & 0x3f) << 5) + ((row & 0x20) << 6)
                elif n == 2:
                    ti = (row & 0x0f) + ((col & 0x3f) << 4) + ((row & 0x30) << 6)
                else:
                    ti = (row & 0x07) + ((col & 0x3f) << 3) + ((row & 0x38) << 6)
                code, attr = self.ram[base + 2 * ti], self.ram[base + 2 * ti + 1]
                m = self.mapper(typ, code)
                if m < 0:
                    continue
                px, py = tx % tsz, ty % tsz
                if attr & 0x20:
                    px = tsz - 1 - px
                if attr & 0x40:
                    py = tsz - 1 - py
                if n == 1:
                    pen = self.row(m * 8 + py, (ti >> 5) & 1)[px]
                else:
                    pen = self.tile_pixel(typ, m, px, py)
                if pen != 15:
                    out[Y][X] = (0x200 * n) + (attr & 0x1f) * 16 + pen
                    grp[Y][X] = (attr >> 7) & 3                   # priority group (cps1_v.cpp tile category)
        return out

    # ---- stars -------------------------------------------------------------------------------------------------
    def stars(self, frame_number):
        """the two star layers as MAME draws them (cps1_v.cpp cps1_render_stars): {"a": LUTA 0xa00 layer (ROM byte
        8 * offs + 4, stars-2 scroll), "8": LUTA 0x800 layer (byte 8 * offs, stars-1 scroll)}, 512 x 256 each, None where
        there is no star; the blink step is (frame_number / 16) % (15 if col bit 7 else 16). Star ROM: 0x8000 bytes of
        the gfx region from the game's "stars" offset in games.py (MAME's ROM_COPY: forgottn 0x200000, strider 0),
        0x1000 entries."""
        lc = self.b[self.cfg["layer"] // 2]
        ena = self.cfg["enables"]
        out = {}
        for key, byte, sxr, syr, base, mask in (("a", 4, 0x1c // 2, 0x1e // 2, 0xa00, ena[3] if len(ena) > 3 else 0),
                                               ("8", 0, 0x18 // 2, 0x1a // 2, 0x800, ena[4] if len(ena) > 4 else 0)):
            lay = [[None] * 512 for _ in range(256)]
            out[key] = lay
            if not (lc & mask):
                continue
            for offs in range(0x1000):
                col = self.gfx[self.cfg.get("stars", 0) + 8 * offs + byte]
                if (col & 0x1f) == 0x0f:
                    continue
                sx = ((offs // 256) * 32 - self.a[sxr] + (col & 0x1f)) & 0x1ff
                sy = ((offs % 256) - self.a[syr]) & 0xff
                if self.a[0x11] & 0x8000:                 # MAME: 512 - x / 256 - y, drawn only inside the bitmap
                    sx, sy = 512 - sx, 256 - sy
                    if sx > 511 or sy > 255:
                        continue
                cnt = (frame_number // 16) % (15 if col & 0x80 else 16)
                lay[sy][sx] = base + ((col & 0xe0) >> 1) + cnt
        return out

    def palette(self):
        pal = [0] * 0xc00
        pb = self.base(5)
        ctrl = self.b[self.cfg["pal"] // 2]
        p = pb
        for page in range(6):
            if (ctrl >> page) & 1:
                for o in range(0x200):
                    pal[0x200 * page + o] = self.ram[p]
                    p += 1
            elif p != pb:
                p += 0x200
        return pal


# The A-board RGB DAC (89626A-3 / 89626A-4 sheet 5), level per [brightness][color]. Each color has an R089 color
# network (bits 3-0 on 220, 470, 1k, 2.2k through the 74LS367) and an R089 brightness network (bits 3-0 on 100, 220,
# 470, 1k, pulled to GND by the 74LS07 when 0) on one node; resistor values measured on the 89626A-4 DASH board.
DAC = [
    [  0,   5,  10,  15,  22,  27,  32,  37,  45,  50,  55,  60,  67,  72,  78,  82],  # brightness 0
    [  0,   5,  11,  16,  23,  28,  34,  39,  47,  52,  58,  63,  70,  75,  81,  86],  # brightness 1
    [  0,   5,  11,  17,  24,  29,  35,  41,  49,  54,  61,  66,  73,  79,  85,  90],  # brightness 2
    [  0,   5,  12,  17,  25,  30,  37,  42,  51,  57,  64,  69,  77,  82,  89,  95],  # brightness 3
    [  0,   6,  13,  18,  26,  32,  39,  45,  55,  61,  67,  73,  82,  88,  95, 100],  # brightness 4
    [  0,   6,  13,  19,  28,  34,  41,  47,  58,  64,  71,  77,  86,  92, 100, 106],  # brightness 5
    [  0,   6,  14,  21,  30,  36,  44,  50,  61,  68,  75,  82,  91,  98, 106, 112],  # brightness 6
    [  0,   7,  15,  22,  31,  38,  46,  53,  65,  72,  80,  87,  97, 104, 112, 119],  # brightness 7
    [  0,   8,  16,  24,  34,  42,  51,  58,  71,  78,  87,  95, 106, 114, 123, 130],  # brightness 8
    [  0,   8,  17,  26,  37,  45,  54,  62,  76,  84,  94, 102, 113, 122, 131, 140],  # brightness 9
    [  0,   9,  19,  28,  40,  48,  59,  67,  82,  91, 101, 110, 123, 132, 142, 151],  # brightness A
    [  0,   9,  20,  30,  43,  52,  63,  73,  89,  98, 110, 119, 133, 143, 154, 164],  # brightness B
    [  0,  10,  23,  33,  47,  58,  70,  81,  99, 109, 122, 133, 148, 159, 171, 182],  # brightness C
    [  0,  11,  25,  36,  52,  64,  77,  89, 109, 120, 134, 146, 163, 175, 189, 201],  # brightness D
    [  0,  13,  28,  41,  58,  71,  87,  99, 122, 135, 151, 164, 183, 197, 212, 226],  # brightness E
    [  0,  14,  31,  46,  66,  80,  97, 112, 138, 153, 170, 185, 207, 222, 240, 255],  # brightness F
]


def rgb(w):
    row = DAC[w >> 12]
    return (row[(w >> 8) & 0x0f], row[(w >> 4) & 0x0f], row[w & 0x0f])


def save(layer, pal, path):
    im = Image.new("RGB", (384, 224), (255, 0, 255))
    for y in range(224):
        for x in range(384):
            v = layer[y + 16][x + 64]
            if v is not None:
                im.putpixel((x, y), rgb(pal[v]))
    im.save(path)


if __name__ == "__main__":
    prefix, gfx, game, out = sys.argv[1:5]
    import re
    m = re.search(r"_f(\d+)$", prefix)
    star_frame = int(sys.argv[5]) if len(sys.argv) > 5 else (int(m.group(1)) if m else 0)
    r = Ref(prefix, gfx, game)
    pal = r.palette()
    spr, ents = r.sprites()
    print("%d sprite entries" % len(ents))
    layers = {"spr": spr}
    # scroll layers the layer-control register leaves disabled are not drawn (cps1_v.cpp: layer_enable_mask)
    lc = r.b[r.cfg["layer"] // 2]
    for n in (1, 2, 3):
        on = lc & r.cfg["enables"][n - 1]
        layers["s%d" % n] = r.scroll(n) if on else [[None] * 512 for _ in range(256)]
        if not on:
            print("scroll %d disabled (layer control %04x)" % (n, lc))
    # flip screen (CPS-A video control bit 15): MAME flips every tilemap around the center of the visible area
    # (tilemap.cpp draw_common, extents 64 + 447 + 1 and 16 + 239 + 1) and draws each sprite at 512-16-x / 256-16-y
    # with its flip bits toggled, i.e. the whole picture turns 180 degrees: bitmap (X, Y) shows the unflipped
    # (511 - X, 255 - Y), which maps the visible window onto itself
    if r.a[0x11] & 0x8000:
        print("flip screen")
        turn = lambda b: [[b[255 - Y][511 - X] for X in range(512)] for Y in range(256)]
        layers = {k: turn(v) for k, v in layers.items()}
        r.groups = {n: turn(g) for n, g in r.groups.items()}
    for k, v in layers.items():
        save(v, pal, "%s_%s.png" % (out, k))
    # composite in the layer-control order (cps1_v.cpp screen_update_cps1, without the high-layer priority masks):
    # l0..l3 = layer control bits 6-7, 8-9, 10-11, 12-13; 0 = sprites, 1-3 = scroll 1-3; backdrop pen 0xbff
    order = [("spr", "s1", "s2", "s3")[(lc >> s) & 3] for s in (6, 8, 10, 12)]
    stars = r.stars(star_frame)                       # MAME draws the stars first, over the backdrop
    stl = [[stars["a"][y][x] if stars["a"][y][x] is not None else stars["8"][y][x] for x in range(512)] for y in range(256)]
    comp = [[0xbff if stl[y][x] is None else stl[y][x] for x in range(512)] for y in range(256)]
    for k in order:
        for y in range(256):
            for x in range(512):
                if layers[k][y][x] is not None:
                    comp[y][x] = layers[k][y][x]
    save(comp, pal, "%s_comp.png" % out)
    print("layer order", order)
    with open(out + "_luta.txt", "w") as f:
        f.write("# y x spr s1 s2 s3 (LUTA, fff = transparent), visible area\n")
        for y in range(224):
            f.write(" ".join("".join("%03x" % (layers[k][y + 16][x + 64] if layers[k][y + 16][x + 64] is not None
                                              else 0xfff) for k in ("spr", "s1", "s2", "s3")) for x in range(384)) + "\n")
    with open(out + "_stars.txt", "w") as f:
        f.write("# y x: LUTA of the star layers (0xa00 layer over the 0x800 one), fff = no star; star frame %d\n" % star_frame)
        for y in range(224):
            f.write(" ".join("%03x" % (stl[y + 16][x + 64] if stl[y + 16][x + 64] is not None else 0xfff)
                             for x in range(384)) + "\n")
    # tile priority group of each visible scroll pixel (s1 s2 s3, "-" = none), for tools/prio_check.py
    with open(out + "_grp.txt", "w") as f:
        f.write("# y x: priority group of the s1 s2 s3 pixel (attribute bits 7-8), - = transparent or disabled\n")
        for y in range(224):
            f.write(" ".join("".join("-" if r.groups.get(n) is None or r.groups[n][y + 16][x + 64] is None
                                     or layers["s%d" % n][y + 16][x + 64] is None else str(r.groups[n][y + 16][x + 64])
                                     for n in (1, 2, 3)) for x in range(384)) + "\n")
    print("wrote", out + "_*.png")
