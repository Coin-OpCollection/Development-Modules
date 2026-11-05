"""
Compare a system testbench palette dump (<cap>_pal_f<N>.txt) with the palette MAME's frame dump implies:

    python pal_check.py <cap prefix> <frame> <dump prefix> <game> <gfx.bin>

Prints the number of matching entries per 0x200 page and the first mismatches.
"""
import os
import sys

from ref_render import Ref

cap, frame, dump, game, gfx = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5]
ref = Ref(dump, gfx, game).palette()
sim = [int(l, 16) if "x" not in l else -1 for l in open("%s_pal_f%d.txt" % (cap, frame)).read().split()]
for page in range(6):
    r = range(0x200 * page, 0x200 * page + 0x200)
    ok = sum(1 for i in r if sim[i] == ref[i])
    nx = sum(1 for i in r if i + 1 < 0xc00 and sim[i] == ref[i + 1] and sim[i] != ref[i])
    print("page %d: %3d / 512 match, %3d equal the next entry" % (page, ok, nx))
bad = [i for i in range(0xc00) if sim[i] != ref[i]]
print("first mismatches:", " ".join("%03x:%04x/%04x" % (i, sim[i] & 0xffff, ref[i]) for i in bad[:12]))
