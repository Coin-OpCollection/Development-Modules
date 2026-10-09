# x76489 Regression Log

Full output of the `tb_x76489` testbench (29 tests across 14 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
============================================================
  tb_x76489 - TI SN76489AN Comprehensive Testbench
============================================================

=== REG SECTION A.1: Attenuators After Reset ===

PASS: A.1 tone 1 attenuation OFF = f
PASS: A.1 tone 2 attenuation OFF = f
PASS: A.1 tone 3 attenuation OFF = f
PASS: A.1 noise attenuation OFF = f

=== REG SECTION A.2: Tone Frequency ===

PASS: A.2 tone 1 frequency 1ABH = 1ab
PASS: A.2 tone 2 frequency 0FFH = ff
PASS: A.2 tone 3 frequency 200H = 200

=== REG SECTION A.3: Attenuation ===

PASS: A.3 tone 1 attenuation 0 dB = 0
PASS: A.3 tone 2 attenuation 10 dB = 5
PASS: A.3 noise attenuation OFF = f

=== REG SECTION A.4: Noise Control ===

PASS: A.4 noise control white, N/512 = 4

=== TONE SECTION B.1: Tone Generators ===

PASS: B.1 tone 1 toggling, period 1
PASS: B.1 tone 2 toggling, period 4
PASS: B.1 tone 3 toggling, period 8

=== TONE SECTION B.2: Period and Rate ===

PASS: B.2 period 1 faster than period 8

=== NOISE SECTION C.1: White Noise ===

PASS: C.1 register shifted from the seed
PASS: C.1 white noise output changing

=== NOISE SECTION C.2: Periodic Noise ===

PASS: C.2 periodic noise output changing

=== NOISE SECTION C.3: Reseed ===

PASS: C.3 noise control write reseeds 4000H = 4000

=== NOISE SECTION C.4: Tone 3 Shift Source ===

PASS: C.4 noise shifted by tone 3

=== ATTN SECTION D.1: Attenuators on AOUT ===

PASS: D.1 all channels OFF, AOUT 0 = 0
PASS: D.1 tone 1 at 0 dB, AOUT active
PASS: D.1 tone 1 OFF, AOUT 0 = 0

=== MIX SECTION E.1: Channels Alone ===

PASS: E.1 tone 1 alone, AOUT active
PASS: E.1 tone 2 alone, AOUT active
PASS: E.1 tone 3 alone, AOUT active
PASS: E.1 noise alone, AOUT active

=== WRITE SECTION F.1: Attenuation While Playing ===

PASS: F.1 attenuation write while playing

=== WRITE SECTION F.2: Frequency While Playing ===

PASS: F.2 frequency write while playing

=========================================================
  tb_x76489 results: 29 / 29 passed (0 failed)
=========================================================
  ALL TESTS PASSED
```
