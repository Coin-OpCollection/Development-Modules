# x76489 Regression Log

Full output of the `tb_x76489` testbench (29 tests across 6 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  SN76489AN Comprehensive PSG Testbench
  Reference: TI SN76489AN Datasheet
=============================================================

=== SECTION 1: Register Bus Protocol ===

PASS: Reset: ch0 attn = $F = 0000000f
PASS: Reset: ch1 attn = $F = 0000000f
PASS: Reset: ch2 attn = $F = 0000000f
PASS: Reset: ch3 attn = $F = 0000000f
PASS: Tone 1 freq = $1AB = 000001ab
PASS: Tone 2 freq = $0FF = 000000ff
PASS: Tone 3 freq = $200 = 00000200
PASS: Ch0 attn = 0 (full) = 00000000
PASS: Ch1 attn = 5 (-10dB) = 00000005
PASS: Noise attn = $F (OFF) = 0000000f
PASS: Noise ctrl = $4 (white) = 00000004

=== SECTION 2: Tone Generator ===

PASS: Tone 1 toggling (period=1) = 00000001
PASS: Tone 2 toggling (period=4) = 00000001
PASS: Tone 3 toggling (period=8) = 00000001
PASS: Period 1 faster than period 8 = 00000001

=== SECTION 3: Noise Generator ===

PASS: LFSR shifted from reset = 00000001
PASS: White noise output changing = 00000001
PASS: Periodic noise output changing = 00000001
PASS: LFSR reset on write = 00004000
PASS: Noise driven by tone 3 = 00000001

=== SECTION 4: Attenuation ===

PASS: All OFF -> silence = 00000000
PASS: Ch0 0dB -> output active = 00000001
PASS: Ch0 OFF -> silence = 00000000

=== SECTION 5: Master Output ===

PASS: Ch0 only -> active = 00000001
PASS: Ch1 only -> active = 00000001
PASS: Ch2 only -> active = 00000001
PASS: Noise only -> active = 00000001

=== SECTION 6: Write-While-Active ===

PASS: Attn change while active = 00000001
PASS: Freq change while active = 00000001

=============================================================
  SN76489AN Comprehensive Test Results
=============================================================
  Total Tests:  29
  Passed:       29
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
=============================================================
```
