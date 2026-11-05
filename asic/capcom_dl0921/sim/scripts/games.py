"""
The supported romsets' CPS1 configuration (games.json), for the system testbench and the reference renderer: the
graphics mapper, the CPS-B register offsets (layer control, priority masks, palette control), the scroll layer enable
masks and, for a set run with its configuration key, the key.

    python games.py args <set> <mapper file>      the testbench's plusargs; the set's mapper written to <mapper file>
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

GAMES = {}
for _name, _g in json.load(open(os.path.join(HERE, "games.json"))).items():
    _g["prio"], _g["enables"] = tuple(_g["prio"]), tuple(_g["enables"])
    _g["mapper"] = (tuple(_g["mapper"][0]), [tuple(r) for r in _g["mapper"][1]])
    _g["key"] = bytes.fromhex(_g["key"]) if _g.get("key") else None
    GAMES[_name] = _g


def mapper_lines(game):
    """one line per range: type mask, start, end, byte base of the bank in the gfx region, address mask"""
    sizes, ranges = GAMES[game]["mapper"]
    out = []
    for t, s, e, bank in ranges:
        base = sum(sizes[:bank]) * 64
        out.append("%02x %05x %05x %06x %05x" % (t, s, e, base, sizes[bank] - 1))
    return out


def plusargs(game, mapper):
    """the testbench's plusargs for the set, with its mapper written to the file mapper"""
    g = GAMES[game]
    with open(mapper, "w") as f:
        f.write("\n".join(mapper_lines(game)) + "\n")
    a = ["+mapper=" + mapper.replace("\\", "/"), "+rlayer=%02x" % g["layer"],
         "+rprio=" + "".join("%02x" % p for p in g["prio"]), "+rpal=%02x" % g["pal"]]
    if g["mode"] == "key" and g["key"]:
        a.append("+key=" + "".join("%02x" % b for b in g["key"]))
    return a


if __name__ == "__main__":
    if len(sys.argv) == 4 and sys.argv[1] == "args":
        print(" ".join(plusargs(sys.argv[2], sys.argv[3])))
    else:
        sys.exit(__doc__)
