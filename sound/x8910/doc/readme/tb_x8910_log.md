# x8910 Regression Log

Full output of the `tb_x8910` testbench (59 tests across 8 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
============================================================
  tb_x8910 - GI AY-3-8910 Comprehensive Testbench
============================================================

=== REG SECTION A.1: Register Bus Protocol ===

PASS: A.1 R0 write/read = $AB = ab
PASS: A.1 R1 read mask [3:0] = f
PASS: A.1 R3 read mask [3:0] = f
PASS: A.1 R5 read mask [3:0] = f
PASS: A.1 R6 read mask [4:0] = 1f
PASS: A.1 R7 write/read = $A5 = a5
PASS: A.1 R8 read mask [4:0] = 1f
PASS: A.1 R9 read mask [4:0] = 1f
PASS: A.1 R10 read mask [4:0] = 1f
PASS: A.1 R13 read mask [3:0] = f
PASS: A.1 R7 reset default = $FF = ff
PASS: A.1 R0 reset default = $00 = 0

=== TONE SECTION B.1: Tone Generators ===

PASS: B.1 Tone A toggling (period=1) = 1
PASS: B.1 Tone B toggling (period=2) = 1
PASS: B.1 Tone C toggling (period=4) = 1
PASS: B.1 Period 1 faster than period 4 = 1
PASS: B.1 Period 0 produces output = 1

=== NOISE SECTION C.1: Noise Generator ===

PASS: C.1 LFSR active (non-zero) = 1
PASS: C.1 Noise output changing = 1
PASS: C.1 Noise: period 1 faster than 16 = 1

=== MIX SECTION D.1: Mixer ===

PASS: D.1 Mixer: both dis -> bypass = 1
PASS: D.1 Mixer: tone only -> active = 1
PASS: D.1 Mixer: noise only -> active = 1
PASS: D.1 Mixer: tone+noise -> active = 1
PASS: D.1 Mixer: all amp=0 -> silence = 0

=== AMP SECTION E.1: D/A Levels ===

PASS: E.1 DAC: A=15 -> 63 = 3f
PASS: E.1 DAC: B=15 -> 63 = 3f
PASS: E.1 DAC: C=15 -> 63 = 3f
PASS: E.1 DAC: all off -> 0 = 0
PASS: E.1 DAC: level 11 -> 16 = 10
PASS: E.1 DAC: level 7 -> 4 = 4
PASS: E.1 DAC: level 1 -> 0 = 0

=== ENV SECTION F.1: Envelope Generator ===

PASS: F.1 Shape $00: stopped = 1
PASS: F.1 Shape $00: held at 0 = 0
PASS: F.1 Shape $04: stopped = 1
PASS: F.1 Shape $08: repeating (output changes) = 1
PASS: F.1 Shape $09: hold stopped = 1
PASS: F.1 Shape $0A: alternating (output changes) = 1
PASS: F.1 Shape $0B: hold stopped = 1
PASS: F.1 Shape $0B: held at max = f
PASS: F.1 Shape $0C: attack (invert=0) = 0
PASS: F.1 Shape $0C: not stopped (repeat) = 0
PASS: F.1 Shape $0D: hold stopped = 1
PASS: F.1 Shape $0D: held at max = f
PASS: F.1 Shape $0E: alternating (output changes) = 1
PASS: F.1 Shape $0F: hold stopped = 1
PASS: F.1 Shape $0F: held at 0 = 0
PASS: F.1 Restart: stopped before = 1
PASS: F.1 Restart: clears stop = 0
PASS: F.1 Slow period: counter < 8 = 1

=== OUT SECTION G.1: Audio Output ===

PASS: G.1 3ch max -> 191 = bf
PASS: G.1 All off -> 0 = 0
PASS: G.1 A only -> 63 = 3f
PASS: G.1 B only -> 63 = 3f
PASS: G.1 C only -> 63 = 3f
PASS: G.1 A+B -> 127 = 7f

=== WRITE SECTION H.1: Writes While Active ===

PASS: H.1 Amp change while active = 1
PASS: H.1 Period change while active = 1
PASS: H.1 Env switch while active = 0

=========================================================
  tb_x8910 results: 59 / 59 passed (0 failed)
=========================================================
  ALL TESTS PASSED
```
