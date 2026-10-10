# x8910 Regression Log

Full output of the `tb_x8910` testbench (116 tests across 15 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
============================================================
  tb_x8910 - GI AY-3-8910 Comprehensive Testbench
============================================================

=== REG SECTION A.1: Register Bus Protocol ===

PASS: A.1 R0 write/read = $AB = ab
PASS: A.1 DOUT $FF while RDn is high = ff
PASS: A.1 R1 read mask [3:0] = f
PASS: A.1 R3 read mask [3:0] = f
PASS: A.1 R5 read mask [3:0] = f
PASS: A.1 R6 read mask [4:0] = 1f
PASS: A.1 R7 write/read = $A5 = a5
PASS: A.1 R8 read mask [4:0] = 1f
PASS: A.1 R9 read mask [4:0] = 1f
PASS: A.1 R10 read mask [4:0] = 1f
PASS: A.1 R13 read mask [3:0] = f
PASS: A.1 R7 reset default = $00 = 0
PASS: A.1 R0 reset default = $00 = 0

=== REG SECTION A.2: Reset Values ===

PASS: A.2 deselected after reset, reads $FF = ff
PASS: A.2 R0 reset value = 0
PASS: A.2 R1 reset value = 0
PASS: A.2 R2 reset value = 0
PASS: A.2 R3 reset value = 0
PASS: A.2 R4 reset value = 0
PASS: A.2 R5 reset value = 0
PASS: A.2 R6 reset value = 0
PASS: A.2 R7 reset value = 0
PASS: A.2 R8 reset value = 0
PASS: A.2 R9 reset value = 0
PASS: A.2 R10 reset value = 0
PASS: A.2 R11 reset value = 0
PASS: A.2 R12 reset value = 0
PASS: A.2 R13 reset value = 0
PASS: A.2 R14 reset value = ff
PASS: A.2 R15 reset value = ff

=== REG SECTION A.3: Chip Select ===

PASS: A.3 deselected chip reads $FF = ff
PASS: A.3 address kept on DIN[7:4] = 0001 = 0
PASS: A.3 data write ignored while deselected = 55

=== REG SECTION A.4: I/O Ports ===

PASS: A.4 R7 bit 6 sets port A output mode = 1
PASS: A.4 port B input mode = 0
PASS: A.4 IOA_OUT is R14 = 12
PASS: A.4 IOB_OUT is R15 = 34
PASS: A.4 R14 reads the port A pins = 5a
PASS: A.4 R15 reads the port B pins = c3

=== TONE SECTION B.1: Tone Generators ===

PASS: B.1 Tone A toggling (period=1) = 1
PASS: B.1 Tone B toggling (period=2) = 1
PASS: B.1 Tone C toggling (period=4) = 1
PASS: B.1 Period 1 faster than period 4 = 1
PASS: B.1 Period 0 produces output = 1

=== TONE SECTION B.2: Half Periods ===

PASS: B.2 TP = 1 half period 8 CEN pulses = 8
PASS: B.2 TP = 5 half period 40 CEN pulses = 28
PASS: B.2 TP = 0 half period 8 CEN pulses = 8
PASS: B.2 TP = 4095 half period 32760 CEN pulses = 7ff8

=== NOISE SECTION C.1: Noise Generator ===

PASS: C.1 LFSR active (non-zero) = 1
PASS: C.1 Noise output changing = 1
PASS: C.1 Noise: period 1 faster than 16 = 1

=== NOISE SECTION C.2: Shift Timing and Sequence ===

PASS: C.2 no shift in the first period after reset = 0
PASS: C.2 NP = 0 shift interval 16 CEN pulses = 10
PASS: C.2 NP = 5 shift interval 80 CEN pulses = 50
PASS: C.2 sequence repeats after 131071 shifts = 10000
PASS: C.2 first shift loads a 1 into the top stage = 10000

=== MIX SECTION D.1: Mixer ===

PASS: D.1 Mixer: both dis -> bypass = 1
PASS: D.1 Mixer: tone only -> active = 1
PASS: D.1 Mixer: noise only -> active = 1
PASS: D.1 Mixer: tone+noise -> active = 1
PASS: D.1 Mixer: all amp=0 -> silence = 0

=== AMP SECTION E.1: D/A Levels ===

PASS: E.1 DAC: A=15 -> 1023 = 3ff
PASS: E.1 DAC: B=15 -> 1023 = 3ff
PASS: E.1 DAC: C=15 -> 1023 = 3ff
PASS: E.1 DAC: all off -> 0 = 0
PASS: E.1 DAC: level 11 -> 256 = 100
PASS: E.1 DAC: level 7 -> 64 = 40
PASS: E.1 DAC: level 1 -> 8 = 8

=== AMP SECTION E.2: Channel Outputs ===

PASS: E.2 AOUT_A level 0 = 0 = 0
PASS: E.2 AOUT_A level 1 = 8 = 8
PASS: E.2 AOUT_A level 2 = 11 = b
PASS: E.2 AOUT_A level 3 = 16 = 10
PASS: E.2 AOUT_A level 4 = 23 = 17
PASS: E.2 AOUT_A level 5 = 32 = 20
PASS: E.2 AOUT_A level 6 = 45 = 2d
PASS: E.2 AOUT_A level 7 = 64 = 40
PASS: E.2 AOUT_A level 8 = 91 = 5b
PASS: E.2 AOUT_A level 9 = 128 = 80
PASS: E.2 AOUT_A level 10 = 181 = b5
PASS: E.2 AOUT_A level 11 = 256 = 100
PASS: E.2 AOUT_A level 12 = 362 = 16a
PASS: E.2 AOUT_A level 13 = 512 = 200
PASS: E.2 AOUT_A level 14 = 723 = 2d3
PASS: E.2 AOUT_A level 15 = 1023 = 3ff
PASS: E.2 AOUT_B level 15 = 3ff
PASS: E.2 AOUT_C level 7 = 40
PASS: E.2 AOUT is the sum of the three = 83e

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
PASS: F.1 Shape $0C: still counting (repeat) = 1
PASS: F.1 Shape $0D: hold stopped = 1
PASS: F.1 Shape $0D: held at max = f
PASS: F.1 Shape $0E: alternating (output changes) = 1
PASS: F.1 Shape $0F: hold stopped = 1
PASS: F.1 Shape $0F: held at 0 = 0
PASS: F.1 Restart: stopped before = 1
PASS: F.1 Restart: clears stop = 0
PASS: F.1 Slow period: counter < 8 = 1

=== ENV SECTION F.2: First Step ===

PASS: F.2 first step 57-64 CEN pulses after the R13 write = 1
PASS: F.2 step interval 64 CEN pulses (EP = 4) = 40

=== OUT SECTION G.1: Audio Output ===

PASS: G.1 3ch max -> 3069 = bfd
PASS: G.1 All off -> 0 = 0
PASS: G.1 A only -> 1023 = 3ff
PASS: G.1 B only -> 1023 = 3ff
PASS: G.1 C only -> 1023 = 3ff
PASS: G.1 A+B -> 2046 = 7fe

=== WRITE SECTION H.1: Writes While Active ===

PASS: H.1 Amp change while active = 1
PASS: H.1 Period change while active = 1
PASS: H.1 Env switch while active = 0

=========================================================
  tb_x8910 results: 116 / 116 passed (0 failed)
=========================================================
  ALL TESTS PASSED
```
