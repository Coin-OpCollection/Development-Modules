"""Side-by-side MAME snapshot vs simulated frame: python compare.py mame.png sim.png out.png"""
import sys
from PIL import Image, ImageDraw
m = Image.open(sys.argv[1]).convert("RGB")
s = Image.open(sys.argv[2]).convert("RGB")
w = m.width + s.width + 8
h = max(m.height, s.height) + 14
out = Image.new("RGB", (w, h), (40, 40, 40))
out.paste(m, (0, 14)); out.paste(s, (m.width + 8, 14))
d = ImageDraw.Draw(out)
d.text((2, 1), "MAME", fill=(255, 255, 0)); d.text((m.width + 10, 1), "gate-level sim", fill=(255, 255, 0))
out = out.resize((w * 2, h * 2), Image.NEAREST)
out.save(sys.argv[3]); print(sys.argv[3], out.size)
