# x76489 Regression Log

Full output of the `tb_x76489` testbench (81 tests across 24 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
============================================================
  tb_x76489 - TI SN76489AN Comprehensive Testbench
============================================================

=== REG SECTION A.1: Reset Values ===

PASS: A.1 tone 1 attenuation OFF = f
PASS: A.1 tone 2 attenuation OFF = f
PASS: A.1 tone 3 attenuation OFF = f
PASS: A.1 noise attenuation OFF = f
PASS: A.1 tone 1 period 1 = 1
PASS: A.1 tone 2 period 1 = 1
PASS: A.1 tone 3 period 1 = 1
PASS: A.1 noise control white, N/512 = 4
PASS: A.1 address latch 000 = 0
PASS: A.1 READY high = 1

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

=== REG SECTION A.5: Data Byte to an Attenuation ===

PASS: A.5 data byte loads the latched tone 2 attenuation = 9

=== REG SECTION A.6: Data Byte to the Noise Control ===

PASS: A.6 register off the seed before the data byte
PASS: A.6 data byte loads the latched noise control = 3
PASS: A.6 data byte reseeds the shift register = 1
PASS: A.6 register at the seed 4000H = 4000

=== TONE SECTION B.1: Tone Generators ===

PASS: B.1 tone 1 toggling, period 1
PASS: B.1 tone 2 toggling, period 4
PASS: B.1 tone 3 toggling, period 8

=== TONE SECTION B.2: Period and Rate ===

PASS: B.2 period 1 faster than period 8

=== TONE SECTION B.3: Half Periods ===

PASS: B.3 n = 1 holds 16 CEN pulses = 10
PASS: B.3 n = 2 holds 32 CEN pulses = 20
PASS: B.3 n = 5 holds 80 CEN pulses = 50
PASS: B.3 n = 0 holds 16384 CEN pulses (1024 steps) = 4000

=== NOISE SECTION C.1: White Noise ===

PASS: C.1 register shifted from the seed
PASS: C.1 white noise output changing

=== NOISE SECTION C.2: Periodic Noise ===

PASS: C.2 periodic noise output changing

=== NOISE SECTION C.3: Reseed ===

PASS: C.3 noise control write reseeds 4000H = 4000

=== NOISE SECTION C.4: Tone 3 Shift Source ===

PASS: C.4 noise shifted by tone 3

=== NOISE SECTION C.5: Shift Rates ===

PASS: C.5 N/512 shifts every 512 CEN pulses = 200
PASS: C.5 N/1024 shifts every 1024 CEN pulses = 400
PASS: C.5 N/2048 shifts every 2048 CEN pulses = 800

=== NOISE SECTION C.6: Sequence Lengths ===

PASS: C.6 white noise repeats after 32767 shifts = 7fff
PASS: C.6 periodic noise repeats after 15 shifts = f
PASS: C.6 periodic noise output high for one shift in 15 = 1

=== ATTN SECTION D.1: Attenuators on AOUT ===

PASS: D.1 all channels OFF, AOUT 0 = 0
PASS: D.1 tone 1 at 0 dB, AOUT active
PASS: D.1 tone 1 OFF, AOUT 0 = 0

=== ATTN SECTION D.2: Attenuation Levels ===

PASS: D.2 attenuation 0 (0 dB) peaks at 63 = 3f
PASS: D.2 attenuation 1 (2 dB) peaks at 50 = 32
PASS: D.2 attenuation 2 (4 dB) peaks at 40 = 28
PASS: D.2 attenuation 3 (6 dB) peaks at 32 = 20
PASS: D.2 attenuation 4 (8 dB) peaks at 25 = 19
PASS: D.2 attenuation 5 (10 dB) peaks at 20 = 14
PASS: D.2 attenuation 6 (12 dB) peaks at 16 = 10
PASS: D.2 attenuation 7 (14 dB) peaks at 12 = c
PASS: D.2 attenuation 8 (16 dB) peaks at 10 = a
PASS: D.2 attenuation 9 (18 dB) peaks at 8 = 8
PASS: D.2 attenuation 10 (20 dB) peaks at 6 = 6
PASS: D.2 attenuation 11 (22 dB) peaks at 5 = 5
PASS: D.2 attenuation 12 (24 dB) peaks at 4 = 4
PASS: D.2 attenuation 13 (26 dB) peaks at 3 = 3
PASS: D.2 attenuation 14 (28 dB) peaks at 2 = 2
PASS: D.2 attenuation 15 (OFF) peaks at 0 = 0

=== MIX SECTION E.1: Channels Alone ===

PASS: E.1 tone 1 alone, AOUT active
PASS: E.1 tone 2 alone, AOUT active
PASS: E.1 tone 3 alone, AOUT active
PASS: E.1 noise alone, AOUT active

=== WRITE SECTION F.1: Attenuation While Playing ===

PASS: F.1 attenuation write while playing

=== WRITE SECTION F.2: Frequency While Playing ===

PASS: F.2 frequency write while playing

=== XFER SECTION G.1: READY and the Load ===

PASS: G.1 READY low as the write starts = 0
PASS: G.1 attenuation unchanged before the 32nd CEN pulse = f
PASS: G.1 READY high after 32 CEN pulses = 20
PASS: G.1 byte loaded as READY rises = 3

=== XFER SECTION G.2: One-CLK Write ===

PASS: G.2 READY high once CSn rises = 1
PASS: G.2 attenuation unchanged after 31 CEN pulses = 3
PASS: G.2 one-CLK write loaded the byte taken as it started = 5

=== XFER SECTION G.3: Held Write ===

PASS: G.3 READY high 40 CEN pulses into the held write = 1
PASS: G.3 READY low 70 CEN pulses in, the second transfer = 0
PASS: G.3 write held 100 CEN pulses loads twice = 2
PASS: G.3 second load 64 CEN pulses after the first = 40
PASS: G.3 READY high after the write is released = 1

=== XFER SECTION G.4: Write During a Transfer ===

PASS: G.4 first write loaded on its 32nd CEN pulse = 1
PASS: G.4 second write waiting = f
PASS: G.4 second write loaded 32 CEN pulses later = 2

=========================================================
  tb_x76489 results: 81 / 81 passed (0 failed)
=========================================================
  ALL TESTS PASSED
```
