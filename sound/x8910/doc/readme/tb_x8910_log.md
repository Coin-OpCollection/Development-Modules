# x8910 Regression Log

Full output of the `tb_x8910` testbench (59 tests across 8 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  AY-3-8910 Comprehensive PSG Testbench
  Reference: GI AY-3-8910/8912 PSG Data Manual
=============================================================

=== SECTION 1: Register Bus Protocol ===

PASS: R0 write/read = $AB = 000000ab
PASS: R1 read mask [3:0] = 0000000f
PASS: R3 read mask [3:0] = 0000000f
PASS: R5 read mask [3:0] = 0000000f
PASS: R6 read mask [4:0] = 0000001f
PASS: R7 write/read = $A5 = 000000a5
PASS: R8 read mask [4:0] = 0000001f
PASS: R9 read mask [4:0] = 0000001f
PASS: R10 read mask [4:0] = 0000001f
PASS: R13 read mask [3:0] = 0000000f
PASS: R7 reset default = $FF = 000000ff
PASS: R0 reset default = $00 = 00000000

=== SECTION 2: Tone Generator ===

PASS: Tone A toggling (period=1) = 00000001
PASS: Tone B toggling (period=2) = 00000001
PASS: Tone C toggling (period=4) = 00000001
PASS: Period 1 faster than period 4 = 00000001
PASS: Period 0 produces output = 00000001

=== SECTION 3: Noise Generator ===

PASS: LFSR active (non-zero) = 00000001
PASS: Noise output changing = 00000001
PASS: Noise: period 1 faster than 16 = 00000001

=== SECTION 4: Mixer Logic ===

PASS: Mixer: both dis -> bypass = 00000001
PASS: Mixer: tone only -> active = 00000001
PASS: Mixer: noise only -> active = 00000001
PASS: Mixer: tone+noise -> active = 00000001
PASS: Mixer: all amp=0 -> silence = 00000000

=== SECTION 5: Amplitude Control ===

PASS: DAC: A=15 -> 63 = 0000003f
PASS: DAC: B=15 -> 63 = 0000003f
PASS: DAC: C=15 -> 63 = 0000003f
PASS: DAC: all off -> 0 = 00000000
PASS: DAC: level 11 -> 16 = 00000010
PASS: DAC: level 7 -> 4 = 00000004
PASS: DAC: level 1 -> 0 = 00000000

=== SECTION 6: Envelope Generator ===

PASS: Shape $00: stopped = 00000001
PASS: Shape $00: held at 0 = 00000000
PASS: Shape $04: stopped = 00000001
PASS: Shape $08: repeating (output changes) = 00000001
PASS: Shape $09: hold stopped = 00000001
PASS: Shape $0A: alternating (output changes) = 00000001
PASS: Shape $0B: hold stopped = 00000001
PASS: Shape $0B: held at max = 0000000f
PASS: Shape $0C: attack (invert=0) = 00000000
PASS: Shape $0C: not stopped (repeat) = 00000000
PASS: Shape $0D: hold stopped = 00000001
PASS: Shape $0D: held at max = 0000000f
PASS: Shape $0E: alternating (output changes) = 00000001
PASS: Shape $0F: hold stopped = 00000001
PASS: Shape $0F: held at 0 = 00000000
PASS: Restart: stopped before = 00000001
PASS: Restart: clears stop = 00000000
PASS: Slow period: counter < 8 = 00000001

=== SECTION 7: Master Output ===

PASS: 3ch max -> 191 = 000000bf
PASS: All off -> 0 = 00000000
PASS: A only -> 63 = 0000003f
PASS: B only -> 63 = 0000003f
PASS: C only -> 63 = 0000003f
PASS: A+B -> 127 = 0000007f

=== SECTION 8: Write-While-Active ===

PASS: Amp change while active = 00000001
PASS: Period change while active = 00000001
PASS: Env switch while active = 00000000

=============================================================
  AY-3-8910 Comprehensive Test Results
=============================================================
  Total Tests:  59
  Passed:       59
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
=============================================================
```
