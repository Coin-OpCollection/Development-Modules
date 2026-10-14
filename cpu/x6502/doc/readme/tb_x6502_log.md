# x6502 Regression Log

Full output of the `tb_x6502` testbench (996 tests across 52 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  x6502 Comprehensive Testbench
  Reference: MOS Technology MCS6500 Hardware Manual
=============================================================

=========================================================
 CPU SECTION A: Reset
=========================================================

=== CPU SECTION A.1: Power-up Values ===

PASS: A.1 power-up A X Y = 00 00 00 = 00000000
PASS: A.1 power-up S = 00 = 00000000
PASS: A.1 power-up P = 34 (I = 1, D = 0, bits 5 and 4 read 1) = 00000034
PASS: A.1 power-up PC = 0000 = 00000000
PASS: A.1 power-up IR = 00 = 00000000
PASS: A.1 power-up jam = 0 = 00000000
PASS: A.1 power-up R/W = 1, dout_oe = 0 = 00000002
PASS: A.1 power-up: no output is X (uut, cen_p2 unconnected) = 00000000
PASS: A.1 power-up: no output is X (uuth) = 00000000
PASS: A.1 power-up: uuth outputs equal uut = 00000001

=== CPU SECTION A.2: First Reset after Power-up ===

PASS: A.2 first fetch at the RES vector 0400 = 00000001
PASS: A.2 first fetch 9 cycles after the release (cycle s+8) = 00000009
PASS: A.2 no write cycle from power-up to the first fetch (both CPUs) = 00000000
PASS: A.2 s+3 reads 0100 (0100+S, S = 00) = 00000001
PASS: A.2 s+4 reads 01FF (S-1 wraps) = 00000001
PASS: A.2 s+5 reads 01FE = 00000001
PASS: A.2 s+6 reads FFFC = 00000001
PASS: A.2 s+7 reads FFFD = 00000001
PASS: A.2 one SYNC cycle between s and the first fetch = 00000001
PASS: A.2 SYNC = 1 in s+1 = 00000001
PASS: A.2 vp_n = 1 and dout_oe = 0 in every cycle of the sequence = 00000000
PASS: A.2 readout complete = 00000001
PASS: A.2 after the first reset: A X Y S on the bus (uut) = 000000fd
PASS: A.2 after the first reset: P pushed by PHP (uut) = 00000034
PASS: A.2 after the first reset: A X Y S on the bus (uuth) = 000000fd
PASS: A.2 after the first reset: P pushed by PHP (uuth) = 00000034
PASS: A.2 after the first reset: dbg_a dbg_x dbg_y dbg_s = 000000fd
PASS: A.2 after the first reset: dbg_p = 00000034
PASS: A.2 after the first reset: uuth dbg_* equal uut = 00000001
PASS: A.2 dbg_pc = 0400 at the first fetch = 00000400

=== CPU SECTION A.3: Registers Kept by a Warm Reset ===

PASS: A.3 ratio 2: reset handler reached = 00000001
PASS: A.3 ratio 2: kept A X Y N V D Z C, S = 80 - 3, I = 1: A X Y S on the bus (uut) = 805ac37d
PASS: A.3 ratio 2: kept A X Y N V D Z C, S = 80 - 3, I = 1: P pushed by PHP (uut) = 000000fd
PASS: A.3 ratio 2: kept A X Y N V D Z C, S = 80 - 3, I = 1: A X Y S on the bus (uuth) = 805ac37d
PASS: A.3 ratio 2: kept A X Y N V D Z C, S = 80 - 3, I = 1: P pushed by PHP (uuth) = 000000fd
PASS: A.3 ratio 2: kept A X Y N V D Z C, S = 80 - 3, I = 1: dbg_a dbg_x dbg_y dbg_s = 805ac37d
PASS: A.3 ratio 2: kept A X Y N V D Z C, S = 80 - 3, I = 1: dbg_p = 000000fd
PASS: A.3 ratio 2: kept A X Y N V D Z C, S = 80 - 3, I = 1: uuth dbg_* equal uut = 00000001
PASS: A.3 ratio 5: reset handler reached = 00000001
PASS: A.3 ratio 5: kept A X Y N V D Z C, S = 80 - 3, I = 1: A X Y S on the bus (uut) = 805ac37d
PASS: A.3 ratio 5: kept A X Y N V D Z C, S = 80 - 3, I = 1: P pushed by PHP (uut) = 000000fd
PASS: A.3 ratio 5: kept A X Y N V D Z C, S = 80 - 3, I = 1: A X Y S on the bus (uuth) = 805ac37d
PASS: A.3 ratio 5: kept A X Y N V D Z C, S = 80 - 3, I = 1: P pushed by PHP (uuth) = 000000fd
PASS: A.3 ratio 5: kept A X Y N V D Z C, S = 80 - 3, I = 1: dbg_a dbg_x dbg_y dbg_s = 805ac37d
PASS: A.3 ratio 5: kept A X Y N V D Z C, S = 80 - 3, I = 1: dbg_p = 000000fd
PASS: A.3 ratio 5: kept A X Y N V D Z C, S = 80 - 3, I = 1: uuth dbg_* equal uut = 00000001

=== CPU SECTION A.4: Stack Reads and S - 3 ===

PASS: A.4 s+3 reads 0101 = 00000001
PASS: A.4 s+4 reads 0100 = 00000001
PASS: A.4 s+5 reads 01FF = 00000001
PASS: A.4 S = 01 - 3 = FE = 000000fe
PASS: A.4 dbg_s = FE at the first fetch = 000000fe

=== CPU SECTION A.5: Bus while RES Is Low and the Held PC ===

PASS: A.5 RES from LDA cycle 0: r+1 shows 0400, R/W = 1, SYNC = 0 = 00000001
PASS: A.5 RES from LDA cycle 0: r+2 .. s+2 hold H = 0400, SYNC only at s+1 = 00000000
PASS: A.5 RES from LDA cycle 0: stack reads 01FF 01FE 01FD, then FFFC FFFD = 00000001
PASS: A.5 RES from LDA cycle 0: no write and no dout_oe from r+1 to the vector fetch = 00000000
PASS: A.5 RES from LDA cycle 0: A = 11 (abandoned): A X Y S on the bus (uut) = 112233fc
PASS: A.5 RES from LDA cycle 0: A = 11 (abandoned): P pushed by PHP (uut) = 00000034
PASS: A.5 RES from LDA cycle 0: A = 11 (abandoned): A X Y S on the bus (uuth) = 112233fc
PASS: A.5 RES from LDA cycle 0: A = 11 (abandoned): P pushed by PHP (uuth) = 00000034
PASS: A.5 RES from LDA cycle 0: A = 11 (abandoned): dbg_a dbg_x dbg_y dbg_s = 112233fc
PASS: A.5 RES from LDA cycle 0: A = 11 (abandoned): dbg_p = 00000034
PASS: A.5 RES from LDA cycle 0: A = 11 (abandoned): uuth dbg_* equal uut = 00000001
PASS: A.5 RES from LDA cycle 1: r+1 shows 0401, R/W = 1, SYNC = 0 = 00000001
PASS: A.5 RES from LDA cycle 1: r+2 .. s+2 hold H = 0401, SYNC only at s+1 = 00000000
PASS: A.5 RES from LDA cycle 1: stack reads 01FF 01FE 01FD, then FFFC FFFD = 00000001
PASS: A.5 RES from LDA cycle 1: no write and no dout_oe from r+1 to the vector fetch = 00000000
PASS: A.5 RES from LDA cycle 1: A = 11 (abandoned): A X Y S on the bus (uut) = 112233fc
PASS: A.5 RES from LDA cycle 1: A = 11 (abandoned): P pushed by PHP (uut) = 00000034
PASS: A.5 RES from LDA cycle 1: A = 11 (abandoned): A X Y S on the bus (uuth) = 112233fc
PASS: A.5 RES from LDA cycle 1: A = 11 (abandoned): P pushed by PHP (uuth) = 00000034
PASS: A.5 RES from LDA cycle 1: A = 11 (abandoned): dbg_a dbg_x dbg_y dbg_s = 112233fc
PASS: A.5 RES from LDA cycle 1: A = 11 (abandoned): dbg_p = 00000034
PASS: A.5 RES from LDA cycle 1: A = 11 (abandoned): uuth dbg_* equal uut = 00000001
PASS: A.5 RES from LDA cycle 2: r+1 shows 0402, R/W = 1, SYNC = 0 = 00000001
PASS: A.5 RES from LDA cycle 2: r+2 .. s+2 hold H = 0402, SYNC only at s+1 = 00000000
PASS: A.5 RES from LDA cycle 2: stack reads 01FF 01FE 01FD, then FFFC FFFD = 00000001
PASS: A.5 RES from LDA cycle 2: no write and no dout_oe from r+1 to the vector fetch = 00000000
PASS: A.5 RES from LDA cycle 2: A = 11 (abandoned): A X Y S on the bus (uut) = 112233fc
PASS: A.5 RES from LDA cycle 2: A = 11 (abandoned): P pushed by PHP (uut) = 00000034
PASS: A.5 RES from LDA cycle 2: A = 11 (abandoned): A X Y S on the bus (uuth) = 112233fc
PASS: A.5 RES from LDA cycle 2: A = 11 (abandoned): P pushed by PHP (uuth) = 00000034
PASS: A.5 RES from LDA cycle 2: A = 11 (abandoned): dbg_a dbg_x dbg_y dbg_s = 112233fc
PASS: A.5 RES from LDA cycle 2: A = 11 (abandoned): dbg_p = 00000034
PASS: A.5 RES from LDA cycle 2: A = 11 (abandoned): uuth dbg_* equal uut = 00000001
PASS: A.5 RES from LDA cycle 3: r+1 shows 1234, R/W = 1, SYNC = 0 = 00000001
PASS: A.5 RES from LDA cycle 3: r+2 .. s+2 hold H = 0403, SYNC only at s+1 = 00000000
PASS: A.5 RES from LDA cycle 3: stack reads 01FF 01FE 01FD, then FFFC FFFD = 00000001
PASS: A.5 RES from LDA cycle 3: no write and no dout_oe from r+1 to the vector fetch = 00000000
PASS: A.5 RES from LDA cycle 3: A =    80 (loaded): A X Y S on the bus (uut) = 802233fc
PASS: A.5 RES from LDA cycle 3: A =    80 (loaded): P pushed by PHP (uut) = 000000b4
PASS: A.5 RES from LDA cycle 3: A =    80 (loaded): A X Y S on the bus (uuth) = 802233fc
PASS: A.5 RES from LDA cycle 3: A =    80 (loaded): P pushed by PHP (uuth) = 000000b4
PASS: A.5 RES from LDA cycle 3: A =    80 (loaded): dbg_a dbg_x dbg_y dbg_s = 802233fc
PASS: A.5 RES from LDA cycle 3: A =    80 (loaded): dbg_p = 000000b4
PASS: A.5 RES from LDA cycle 3: A =    80 (loaded): uuth dbg_* equal uut = 00000001
PASS: A.5 RES from LDA cycle 4: r+1 shows 0403, R/W = 1, SYNC = 0 = 00000001
PASS: A.5 RES from LDA cycle 4: r+2 .. s+2 hold H = 0403, SYNC only at s+1 = 00000000
PASS: A.5 RES from LDA cycle 4: stack reads 01FF 01FE 01FD, then FFFC FFFD = 00000001
PASS: A.5 RES from LDA cycle 4: no write and no dout_oe from r+1 to the vector fetch = 00000000
PASS: A.5 RES from LDA cycle 4: A =    80 (loaded): A X Y S on the bus (uut) = 802233fc
PASS: A.5 RES from LDA cycle 4: A =    80 (loaded): P pushed by PHP (uut) = 000000b4
PASS: A.5 RES from LDA cycle 4: A =    80 (loaded): A X Y S on the bus (uuth) = 802233fc
PASS: A.5 RES from LDA cycle 4: A =    80 (loaded): P pushed by PHP (uuth) = 000000b4
PASS: A.5 RES from LDA cycle 4: A =    80 (loaded): dbg_a dbg_x dbg_y dbg_s = 802233fc
PASS: A.5 RES from LDA cycle 4: A =    80 (loaded): dbg_p = 000000b4
PASS: A.5 RES from LDA cycle 4: A =    80 (loaded): uuth dbg_* equal uut = 00000001

=== CPU SECTION A.6: RES Sampled at cen Only ===

PASS: A.6 RES low between two cen: no reset (fetch 0406) = 00000001
PASS: A.6 RES, IRQ, NMI and RDY pulses while the enables are stopped: no reset, no entry = 00000000
PASS: A.6 enables stopped: the NOP stream continues where it stopped = 00000000
PASS: A.6 RES low across exactly one cen: full reset, fetch at s+8 = 00000001
PASS: A.6 one-edge RES: FFFC read at s+6 = 00000001

=== CPU SECTION A.7: Writes in the Cycle RES Falls ===

PASS: A.7 STA, RES first low the cycle before: cycle r+1 reads 1234, no write = 00000001
PASS: A.7 STA: no write from cycle r on = 00000000
PASS: A.7 STA, RES first low at its write cycle: the write of 5A happens = 00000001
PASS: A.7 STA: no write after cycle r = 00000000
PASS: A.7 INC, RES first low at the data read: neither write happens = 00000000
PASS: A.7 INC: cycle r+1 shows 1234 as a read = 00000001
PASS: A.7 INC, RES first low at the first write: the unmodified write of 41 happens = 00000001
PASS: A.7 INC: the modified write does not happen = 00000000
PASS: A.7 INC, RES first low at the second write: the modified write of 42 happens = 00000001
PASS: A.7 INC: no write after cycle r = 00000000

=== CPU SECTION A.8: RES Timing Exceptions ===

PASS: A.8 (a) taken branch cut at cycle 3: r+1 fetches 0412 with SYNC = 00000001
PASS: A.8 (a) r+2 = s+2: SYNC = 0 = 00000001
PASS: A.8 (a) stack reads from r+3, FFFC at r+6 (one cycle early) = 00000001
PASS: A.8 (a) vector fetch at r+8 = 00000008
PASS: A.8 (b) RMW: r+1 is the data read of 1234 = 00000001
PASS: A.8 (b) RMW: r+2 and r+3 are reads, SYNC in r+2 = 00000001
PASS: A.8 (b) RMW: s+1 = r+4 with SYNC = 00000001
PASS: A.8 (b) RMW: stack reads from r+6, FFFC at r+9 = 00000001
PASS: A.8 (b) RMW: no write = 00000000

=== CPU SECTION A.9: RES at Every Cycle (netlist scenarios) ===

PASS: A.9 RES in 16 contexts, ratio 4: 384 scenarios, 28564 cycles run = 00000001
PASS: A.9 RES in 16 contexts, ratio 4: address, R/W and SYNC mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 4: write data mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 4: dout_oe mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 4: held PC while RES is low, mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 4: dbg_* mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 4: CYCLE/HALF lockstep mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 2: 384 scenarios, 28564 cycles run = 00000001
PASS: A.9 RES in 16 contexts, ratio 2: address, R/W and SYNC mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 2: write data mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 2: dout_oe mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 2: held PC while RES is low, mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 2: dbg_* mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 2: CYCLE/HALF lockstep mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 5: 384 scenarios, 28564 cycles run = 00000001
PASS: A.9 RES in 16 contexts, ratio 5: address, R/W and SYNC mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 5: write data mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 5: dout_oe mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 5: held PC while RES is low, mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 5: dbg_* mismatches = 00000000
PASS: A.9 RES in 16 contexts, ratio 5: CYCLE/HALF lockstep mismatches = 00000000
PASS: A.9 RES in every opcode variant, ratio 4: 539 scenarios, 37257 cycles run = 00000001
PASS: A.9 RES in every opcode variant, ratio 4: address, R/W and SYNC mismatches = 00000000
PASS: A.9 RES in every opcode variant, ratio 4: write data mismatches = 00000000
PASS: A.9 RES in every opcode variant, ratio 4: dout_oe mismatches = 00000000
PASS: A.9 RES in every opcode variant, ratio 4: held PC while RES is low, mismatches = 00000000
PASS: A.9 RES in every opcode variant, ratio 4: dbg_* mismatches = 00000000
PASS: A.9 RES in every opcode variant, ratio 4: CYCLE/HALF lockstep mismatches = 00000000

=== CPU SECTION A.10: RDY during the RES Protocol (netlist scenarios) ===

PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 4: 168 scenarios, 9813 cycles run = 00000001
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 4: address, R/W and SYNC mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 4: write data mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 4: dout_oe mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 4: held PC while RES is low, mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 4: dbg_* mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 4: CYCLE/HALF lockstep mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 2: 168 scenarios, 9813 cycles run = 00000001
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 2: address, R/W and SYNC mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 2: write data mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 2: dout_oe mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 2: held PC while RES is low, mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 2: dbg_* mismatches = 00000000
PASS: A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio 2: CYCLE/HALF lockstep mismatches = 00000000

=== CPU SECTION A.11: RES inside a Running Reset Sequence (netlist scenarios) ===

PASS: A.11 second RES at every cycle of a reset sequence, ratio 4: 36 scenarios, 2223 cycles run = 00000001
PASS: A.11 second RES at every cycle of a reset sequence, ratio 4: address, R/W and SYNC mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 4: write data mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 4: dout_oe mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 4: held PC while RES is low, mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 4: dbg_* mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 4: CYCLE/HALF lockstep mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 2: 36 scenarios, 2223 cycles run = 00000001
PASS: A.11 second RES at every cycle of a reset sequence, ratio 2: address, R/W and SYNC mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 2: write data mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 2: dout_oe mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 2: held PC while RES is low, mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 2: dbg_* mismatches = 00000000
PASS: A.11 second RES at every cycle of a reset sequence, ratio 2: CYCLE/HALF lockstep mismatches = 00000000

=== CPU SECTION A.12: RES and RDY at a Reset Sequence End (netlist scenarios) ===

PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 4: 228 scenarios, 14158 cycles run = 00000001
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 4: address, R/W and SYNC mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 4: write data mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 4: dout_oe mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 4: held PC while RES is low, mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 4: dbg_* mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 4: CYCLE/HALF lockstep mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 2: 228 scenarios, 14158 cycles run = 00000001
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 2: address, R/W and SYNC mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 2: write data mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 2: dout_oe mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 2: held PC while RES is low, mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 2: dbg_* mismatches = 00000000
PASS: A.12 RES and RDY at the last edges of a reset sequence, ratio 2: CYCLE/HALF lockstep mismatches = 00000000

===  SECTION A.13: S and the Vector Read of a Cut Reset Sequence (netlist scenarios) ===

PASS: A.13 S and the vector low read of a cut reset sequence, ratio 4: 512 scenarios, 44054 cycles run = 00000001
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 4: address, R/W and SYNC mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 4: write data mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 4: dout_oe mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 4: held PC while RES is low, mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 4: dbg_* mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 4: CYCLE/HALF lockstep mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 2: 512 scenarios, 44054 cycles run = 00000001
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 2: address, R/W and SYNC mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 2: write data mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 2: dout_oe mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 2: held PC while RES is low, mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 2: dbg_* mismatches = 00000000
PASS: A.13 S and the vector low read of a cut reset sequence, ratio 2: CYCLE/HALF lockstep mismatches = 00000000

=========================================================
 BUS SECTION B: Bus Cycles per Addressing Mode
=========================================================

=== BUS SECTION B.1: Every Opcode Variant (netlist scenarios) ===

PASS: B.1 opcode scenarios: 690 scenarios, 45870 cycles run = 00000001
PASS: B.1 opcode scenarios: address, R/W and SYNC mismatches = 00000000
PASS: B.1 opcode scenarios: write data mismatches = 00000000
PASS: B.1 opcode scenarios: dout_oe mismatches = 00000000
PASS: B.1 opcode scenarios: vp_n mismatches = 00000000
PASS: B.1 opcode scenarios: dbg_* mismatches = 00000000
PASS: B.1 opcode scenarios: CYCLE/HALF lockstep mismatches = 00000000

=== BUS SECTION B.2: Addressing Mode Groups ===

PASS: B.2 implied and accumulator: 28 opcodes, 56 scenarios: mismatches = 00000000
PASS: B.2 immediate: 24 opcodes, 48 scenarios: mismatches = 00000000
PASS: B.2 zero page: 32 opcodes, 64 scenarios: mismatches = 00000000
PASS: B.2 zero page indexed: 32 opcodes, 64 scenarios: mismatches = 00000000
PASS: B.2 absolute: 30 opcodes, 60 scenarios: mismatches = 00000000
PASS: B.2 absolute indexed: 48 opcodes, 192 scenarios: mismatches = 00000000
PASS: B.2 (zero page,X): 16 opcodes, 32 scenarios: mismatches = 00000000
PASS: B.2 (zero page),Y: 16 opcodes, 64 scenarios: mismatches = 00000000
PASS: B.2 relative (branches): 8 opcodes, 64 scenarios: mismatches = 00000000
PASS: B.2 stack (PHA PHP PLA PLP): 4 opcodes, 8 scenarios: mismatches = 00000000
PASS: B.2 JSR RTS RTI BRK: 4 opcodes, 8 scenarios: mismatches = 00000000
PASS: B.2 JMP absolute and indirect: 2 opcodes, 6 scenarios: mismatches = 00000000
PASS: B.2 JAM: 12 opcodes, 24 scenarios: mismatches = 00000000

=== BUS SECTION B.3: Data Bus Drive Window ===

PASS: B.3 STA 1234 uut: R/W = 0, dout 5A in both halves, dout_oe = 1 in both halves = 00000001
PASS: B.3 STA 1234 uuth: dout 5A in both halves, dout_oe = 0 in phi1, 1 in phi2 = 00000001
PASS: B.3 STA cycle 3 (read): dout_oe = 0 (uut) = 00000001
PASS: B.3 STA cycle 3 (read): dout_oe = 0 (uuth) = 00000001
PASS: B.3 INC 1235: writes 41 (unmodified) then 42, uut = 00000001
PASS: B.3 INC 1235: writes 41 then 42, uuth dout_oe in phi2 only = 00000001

=========================================================
 CPU SECTION C: All 256 Opcodes
=========================================================

=== CPU SECTION C.1: Opcodes 00-FF (netlist scenarios of B.1) ===

PASS: C.1 $00 BRK impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $01 ORA (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $02 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $03 slo (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $04 nop zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $05 ORA zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $06 ASL zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $07 slo zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $08 PHP impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $09 ORA #: 2 scenarios: mismatches = 00000000
PASS: C.1 $0a ASL A: 2 scenarios: mismatches = 00000000
PASS: C.1 $0b anc #: 2 scenarios: mismatches = 00000000
PASS: C.1 $0c nop abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $0d ORA abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $0e ASL abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $0f slo abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $10 BPL rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $11 ORA (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $12 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $13 slo (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $14 nop zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $15 ORA zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $16 ASL zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $17 slo zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $18 CLC impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $19 ORA abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $1a nop impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $1b slo abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $1c nop abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $1d ORA abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $1e ASL abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $1f slo abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $20 JSR abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $21 AND (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $22 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $23 rla (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $24 BIT zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $25 AND zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $26 ROL zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $27 rla zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $28 PLP impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $29 AND #: 2 scenarios: mismatches = 00000000
PASS: C.1 $2a ROL A: 2 scenarios: mismatches = 00000000
PASS: C.1 $2b anc #: 2 scenarios: mismatches = 00000000
PASS: C.1 $2c BIT abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $2d AND abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $2e ROL abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $2f rla abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $30 BMI rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $31 AND (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $32 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $33 rla (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $34 nop zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $35 AND zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $36 ROL zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $37 rla zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $38 SEC impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $39 AND abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $3a nop impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $3b rla abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $3c nop abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $3d AND abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $3e ROL abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $3f rla abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $40 RTI impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $41 EOR (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $42 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $43 sre (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $44 nop zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $45 EOR zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $46 LSR zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $47 sre zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $48 PHA impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $49 EOR #: 2 scenarios: mismatches = 00000000
PASS: C.1 $4a LSR A: 2 scenarios: mismatches = 00000000
PASS: C.1 $4b alr #: 2 scenarios: mismatches = 00000000
PASS: C.1 $4c JMP abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $4d EOR abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $4e LSR abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $4f sre abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $50 BVC rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $51 EOR (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $52 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $53 sre (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $54 nop zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $55 EOR zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $56 LSR zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $57 sre zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $58 CLI impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $59 EOR abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $5a nop impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $5b sre abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $5c nop abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $5d EOR abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $5e LSR abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $5f sre abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $60 RTS impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $61 ADC (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $62 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $63 rra (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $64 nop zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $65 ADC zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $66 ROR zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $67 rra zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $68 PLA impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $69 ADC #: 2 scenarios: mismatches = 00000000
PASS: C.1 $6a ROR A: 2 scenarios: mismatches = 00000000
PASS: C.1 $6b arr #: 2 scenarios: mismatches = 00000000
PASS: C.1 $6c JMP (abs): 4 scenarios: mismatches = 00000000
PASS: C.1 $6d ADC abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $6e ROR abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $6f rra abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $70 BVS rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $71 ADC (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $72 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $73 rra (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $74 nop zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $75 ADC zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $76 ROR zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $77 rra zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $78 SEI impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $79 ADC abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $7a nop impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $7b rra abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $7c nop abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $7d ADC abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $7e ROR abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $7f rra abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $80 nop #: 2 scenarios: mismatches = 00000000
PASS: C.1 $81 STA (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $82 nop #: 2 scenarios: mismatches = 00000000
PASS: C.1 $83 sax (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $84 STY zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $85 STA zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $86 STX zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $87 sax zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $88 DEY impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $89 nop #: 2 scenarios: mismatches = 00000000
PASS: C.1 $8a TXA impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $8b ane #: 2 scenarios: mismatches = 00000000
PASS: C.1 $8c STY abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $8d STA abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $8e STX abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $8f sax abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $90 BCC rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $91 STA (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $92 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $93 sha (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $94 STY zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $95 STA zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $96 STX zp,Y: 2 scenarios: mismatches = 00000000
PASS: C.1 $97 sax zp,Y: 2 scenarios: mismatches = 00000000
PASS: C.1 $98 TYA impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $99 STA abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $9a TXS impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $9b tas abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $9c shy abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $9d STA abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $9e shx abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $9f sha abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $a0 LDY #: 2 scenarios: mismatches = 00000000
PASS: C.1 $a1 LDA (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $a2 LDX #: 2 scenarios: mismatches = 00000000
PASS: C.1 $a3 lax (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $a4 LDY zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $a5 LDA zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $a6 LDX zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $a7 lax zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $a8 TAY impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $a9 LDA #: 2 scenarios: mismatches = 00000000
PASS: C.1 $aa TAX impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $ab lxa #: 2 scenarios: mismatches = 00000000
PASS: C.1 $ac LDY abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $ad LDA abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $ae LDX abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $af lax abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $b0 BCS rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $b1 LDA (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $b2 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $b3 lax (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $b4 LDY zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $b5 LDA zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $b6 LDX zp,Y: 2 scenarios: mismatches = 00000000
PASS: C.1 $b7 lax zp,Y: 2 scenarios: mismatches = 00000000
PASS: C.1 $b8 CLV impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $b9 LDA abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $ba TSX impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $bb las abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $bc LDY abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $bd LDA abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $be LDX abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $bf lax abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $c0 CPY #: 2 scenarios: mismatches = 00000000
PASS: C.1 $c1 CMP (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $c2 nop #: 2 scenarios: mismatches = 00000000
PASS: C.1 $c3 dcp (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $c4 CPY zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $c5 CMP zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $c6 DEC zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $c7 dcp zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $c8 INY impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $c9 CMP #: 2 scenarios: mismatches = 00000000
PASS: C.1 $ca DEX impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $cb sbx #: 2 scenarios: mismatches = 00000000
PASS: C.1 $cc CPY abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $cd CMP abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $ce DEC abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $cf dcp abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $d0 BNE rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $d1 CMP (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $d2 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $d3 dcp (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $d4 nop zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $d5 CMP zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $d6 DEC zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $d7 dcp zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $d8 CLD impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $d9 CMP abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $da nop impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $db dcp abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $dc nop abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $dd CMP abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $de DEC abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $df dcp abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $e0 CPX #: 2 scenarios: mismatches = 00000000
PASS: C.1 $e1 SBC (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $e2 nop #: 2 scenarios: mismatches = 00000000
PASS: C.1 $e3 isc (zp,X): 2 scenarios: mismatches = 00000000
PASS: C.1 $e4 CPX zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $e5 SBC zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $e6 INC zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $e7 isc zp: 2 scenarios: mismatches = 00000000
PASS: C.1 $e8 INX impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $e9 SBC #: 2 scenarios: mismatches = 00000000
PASS: C.1 $ea NOP impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $eb usbc #: 2 scenarios: mismatches = 00000000
PASS: C.1 $ec CPX abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $ed SBC abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $ee INC abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $ef isc abs: 2 scenarios: mismatches = 00000000
PASS: C.1 $f0 BEQ rel: 8 scenarios: mismatches = 00000000
PASS: C.1 $f1 SBC (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $f2 jam impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $f3 isc (zp),Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $f4 nop zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $f5 SBC zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $f6 INC zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $f7 isc zp,X: 2 scenarios: mismatches = 00000000
PASS: C.1 $f8 SED impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $f9 SBC abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $fa nop impl: 2 scenarios: mismatches = 00000000
PASS: C.1 $fb isc abs,Y: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $fc nop abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $fd SBC abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $fe INC abs,X: 4 scenarios (2 page cross): mismatches = 00000000
PASS: C.1 $ff isc abs,X: 4 scenarios (2 page cross): mismatches = 00000000

=== CPU SECTION C.2: Random Instruction Streams (netlist scenarios) ===

PASS: C.2 random documented streams: 8 scenarios, 2896 cycles run = 00000001
PASS: C.2 random documented streams: address, R/W and SYNC mismatches = 00000000
PASS: C.2 random documented streams: write data mismatches = 00000000
PASS: C.2 random documented streams: dout_oe mismatches = 00000000
PASS: C.2 random documented streams: vp_n mismatches = 00000000
PASS: C.2 random documented streams: dbg_* mismatches = 00000000
PASS: C.2 random documented streams: CYCLE/HALF lockstep mismatches = 00000000

=========================================================
 ALU SECTION D: Arithmetic and Logic
=========================================================

=== ALU SECTION D.1: Every Operation, Every Input ===

PASS: D.1 ORA: q = a OR b, N Z; V D I C kept (131072 inputs): mismatches = 00000000
PASS: D.1 AND: q = a AND b, N Z (131072 inputs): mismatches = 00000000
PASS: D.1 EOR: q = a XOR b, N Z (131072 inputs): mismatches = 00000000
PASS: D.1 ADC: binary and decimal, N V Z C (262144 inputs): mismatches = 00000000
PASS: D.1 SBC: binary and decimal, N V Z C (262144 inputs): mismatches = 00000000
PASS: D.1 CMP: C = a >= b, N Z of a - b, D ignored (131072 inputs): mismatches = 00000000
PASS: D.1 BIT: N = b7, V = b6, Z = (a AND b) = 0 (131072 inputs): mismatches = 00000000
PASS: D.1 ASL (512 inputs): mismatches = 00000000
PASS: D.1 ROL (512 inputs): mismatches = 00000000
PASS: D.1 LSR (512 inputs): mismatches = 00000000
PASS: D.1 ROR (512 inputs): mismatches = 00000000
PASS: D.1 INC (512 inputs): mismatches = 00000000
PASS: D.1 DEC (512 inputs): mismatches = 00000000
PASS: D.1 ADC D=1 99 + 01: 00, N V Z C = 1 0 0 1 (Z of binary 9A) = 00000009
PASS: D.1 ADC D=1 80 + 80: 60, V = 1, Z = 1, C = 1 = 00000607
PASS: D.1 SBC D=1 00 - 01: 99, N = 1, C = 0 = 00000998

=== ALU SECTION D.2: Decimal Mode through the CPU, Every Input ===

PASS: D.2 ADC with D = 1: cases run = 00020000
PASS: D.2 ADC with D = 1: A and N V Z C mismatches = 00000000
PASS: D.2 SBC with D = 1: cases run = 00020000
PASS: D.2 SBC with D = 1: A and N V Z C mismatches = 00000000
PASS: D.2 $EB with D = 1: cases run = 00020000
PASS: D.2 $EB with D = 1: A and N V Z C mismatches = 00000000
PASS: D.2 ISC with D = 1: cases run = 00020000
PASS: D.2 ISC with D = 1: A and N V Z C mismatches = 00000000
PASS: D.2 RRA with D = 1: cases run = 00020000
PASS: D.2 RRA with D = 1: A and N V Z C mismatches = 00000000

=========================================================
 CPU SECTION E: Undocumented Opcodes
=========================================================

=== CPU SECTION E.1: ANE and LXA (constant EE) ===

PASS: E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE: A X Y S on the bus (uut) = eeff00ff
PASS: E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE: P pushed by PHP (uut) = 000000b4
PASS: E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE: A X Y S on the bus (uuth) = eeff00ff
PASS: E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE: P pushed by PHP (uuth) = 000000b4
PASS: E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE: dbg_a dbg_x dbg_y dbg_s = eeff00ff
PASS: E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE: dbg_p = 000000b4
PASS: E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE: uuth dbg_* equal uut = 00000001
PASS: E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1: A X Y S on the bus (uut) = 000f00ff
PASS: E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1: P pushed by PHP (uut) = 00000036
PASS: E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1: A X Y S on the bus (uuth) = 000f00ff
PASS: E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1: P pushed by PHP (uuth) = 00000036
PASS: E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1: dbg_a dbg_x dbg_y dbg_s = 000f00ff
PASS: E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1: dbg_p = 00000036
PASS: E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1: uuth dbg_* equal uut = 00000001
PASS: E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE: A X Y S on the bus (uut) = eeee00ff
PASS: E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE: P pushed by PHP (uut) = 000000b4
PASS: E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE: A X Y S on the bus (uuth) = eeee00ff
PASS: E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE: P pushed by PHP (uuth) = 000000b4
PASS: E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE: dbg_a dbg_x dbg_y dbg_s = eeee00ff
PASS: E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE: dbg_p = 000000b4
PASS: E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE: uuth dbg_* equal uut = 00000001
PASS: E.1 LXA #0F, A = 11: A = X = 0F: A X Y S on the bus (uut) = 0f0f00ff
PASS: E.1 LXA #0F, A = 11: A = X = 0F: P pushed by PHP (uut) = 00000034
PASS: E.1 LXA #0F, A = 11: A = X = 0F: A X Y S on the bus (uuth) = 0f0f00ff
PASS: E.1 LXA #0F, A = 11: A = X = 0F: P pushed by PHP (uuth) = 00000034
PASS: E.1 LXA #0F, A = 11: A = X = 0F: dbg_a dbg_x dbg_y dbg_s = 0f0f00ff
PASS: E.1 LXA #0F, A = 11: A = X = 0F: dbg_p = 00000034
PASS: E.1 LXA #0F, A = 11: A = X = 0F: uuth dbg_* equal uut = 00000001

=== CPU SECTION E.2: ANC, ALR, ARR ===

PASS: E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1: A X Y S on the bus (uut) = 800000ff
PASS: E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1: P pushed by PHP (uut) = 000000b5
PASS: E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1: A X Y S on the bus (uuth) = 800000ff
PASS: E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1: P pushed by PHP (uuth) = 000000b5
PASS: E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1: dbg_a dbg_x dbg_y dbg_s = 800000ff
PASS: E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1: dbg_p = 000000b5
PASS: E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1: uuth dbg_* equal uut = 00000001
PASS: E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0: A X Y S on the bus (uut) = 000000ff
PASS: E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0: P pushed by PHP (uut) = 00000036
PASS: E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0: A X Y S on the bus (uuth) = 000000ff
PASS: E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0: P pushed by PHP (uuth) = 00000036
PASS: E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0: dbg_a dbg_x dbg_y dbg_s = 000000ff
PASS: E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0: dbg_p = 00000036
PASS: E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0: uuth dbg_* equal uut = 00000001
PASS: E.2 ALR #03, A = FF: t = 03, A = 01, C = 1: A X Y S on the bus (uut) = 010000ff
PASS: E.2 ALR #03, A = FF: t = 03, A = 01, C = 1: P pushed by PHP (uut) = 00000035
PASS: E.2 ALR #03, A = FF: t = 03, A = 01, C = 1: A X Y S on the bus (uuth) = 010000ff
PASS: E.2 ALR #03, A = FF: t = 03, A = 01, C = 1: P pushed by PHP (uuth) = 00000035
PASS: E.2 ALR #03, A = FF: t = 03, A = 01, C = 1: dbg_a dbg_x dbg_y dbg_s = 010000ff
PASS: E.2 ALR #03, A = FF: t = 03, A = 01, C = 1: dbg_p = 00000035
PASS: E.2 ALR #03, A = FF: t = 03, A = 01, C = 1: uuth dbg_* equal uut = 00000001
PASS: E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0: A X Y S on the bus (uut) = 000000ff
PASS: E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0: P pushed by PHP (uut) = 00000036
PASS: E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0: A X Y S on the bus (uuth) = 000000ff
PASS: E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0: P pushed by PHP (uuth) = 00000036
PASS: E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0: dbg_a dbg_x dbg_y dbg_s = 000000ff
PASS: E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0: dbg_p = 00000036
PASS: E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0: uuth dbg_* equal uut = 00000001
PASS: E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0: A X Y S on the bus (uut) = ff0000ff
PASS: E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0: P pushed by PHP (uut) = 000000b5
PASS: E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0: A X Y S on the bus (uuth) = ff0000ff
PASS: E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0: P pushed by PHP (uuth) = 000000b5
PASS: E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0: dbg_a dbg_x dbg_y dbg_s = ff0000ff
PASS: E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0: dbg_p = 000000b5
PASS: E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0: uuth dbg_* equal uut = 00000001
PASS: E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0: A X Y S on the bus (uut) = 200000ff
PASS: E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0: P pushed by PHP (uut) = 00000074
PASS: E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0: A X Y S on the bus (uuth) = 200000ff
PASS: E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0: P pushed by PHP (uuth) = 00000074
PASS: E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0: dbg_a dbg_x dbg_y dbg_s = 200000ff
PASS: E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0: dbg_p = 00000074
PASS: E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0: uuth dbg_* equal uut = 00000001
PASS: E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1: A X Y S on the bus (uut) = d50000ff
PASS: E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1: P pushed by PHP (uut) = 0000003d
PASS: E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1: A X Y S on the bus (uuth) = d50000ff
PASS: E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1: P pushed by PHP (uuth) = 0000003d
PASS: E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1: dbg_a dbg_x dbg_y dbg_s = d50000ff
PASS: E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1: dbg_p = 0000003d
PASS: E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1: uuth dbg_* equal uut = 00000001
PASS: E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0: A X Y S on the bus (uut) = 890000ff
PASS: E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0: P pushed by PHP (uut) = 000000bc
PASS: E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0: A X Y S on the bus (uuth) = 890000ff
PASS: E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0: P pushed by PHP (uuth) = 000000bc
PASS: E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0: dbg_a dbg_x dbg_y dbg_s = 890000ff
PASS: E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0: dbg_p = 000000bc
PASS: E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0: uuth dbg_* equal uut = 00000001

=== CPU SECTION E.3: SBX, USBC, LAS ===

PASS: E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1: A X Y S on the bus (uut) = f02000ff
PASS: E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1: P pushed by PHP (uut) = 00000035
PASS: E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1: A X Y S on the bus (uuth) = f02000ff
PASS: E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1: P pushed by PHP (uuth) = 00000035
PASS: E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1: dbg_a dbg_x dbg_y dbg_s = f02000ff
PASS: E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1: dbg_p = 00000035
PASS: E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1: uuth dbg_* equal uut = 00000001
PASS: E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored): A X Y S on the bus (uut) = f0f000ff
PASS: E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored): P pushed by PHP (uut) = 000000b4
PASS: E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored): A X Y S on the bus (uuth) = f0f000ff
PASS: E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored): P pushed by PHP (uuth) = 000000b4
PASS: E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored): dbg_a dbg_x dbg_y dbg_s = f0f000ff
PASS: E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored): dbg_p = 000000b4
PASS: E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored): uuth dbg_* equal uut = 00000001
PASS: E.3 SBC #01 at EB, A = 05, C = 1: A = 04: A X Y S on the bus (uut) = 040000ff
PASS: E.3 SBC #01 at EB, A = 05, C = 1: A = 04: P pushed by PHP (uut) = 00000035
PASS: E.3 SBC #01 at EB, A = 05, C = 1: A = 04: A X Y S on the bus (uuth) = 040000ff
PASS: E.3 SBC #01 at EB, A = 05, C = 1: A = 04: P pushed by PHP (uuth) = 00000035
PASS: E.3 SBC #01 at EB, A = 05, C = 1: A = 04: dbg_a dbg_x dbg_y dbg_s = 040000ff
PASS: E.3 SBC #01 at EB, A = 05, C = 1: A = 04: dbg_p = 00000035
PASS: E.3 SBC #01 at EB, A = 05, C = 1: A = 04: uuth dbg_* equal uut = 00000001
PASS: E.3 SBC #01 at EB, D = 1, A = 10: A = 09: A X Y S on the bus (uut) = 090000ff
PASS: E.3 SBC #01 at EB, D = 1, A = 10: A = 09: P pushed by PHP (uut) = 0000003d
PASS: E.3 SBC #01 at EB, D = 1, A = 10: A = 09: A X Y S on the bus (uuth) = 090000ff
PASS: E.3 SBC #01 at EB, D = 1, A = 10: A = 09: P pushed by PHP (uuth) = 0000003d
PASS: E.3 SBC #01 at EB, D = 1, A = 10: A = 09: dbg_a dbg_x dbg_y dbg_s = 090000ff
PASS: E.3 SBC #01 at EB, D = 1, A = 10: A = 09: dbg_p = 0000003d
PASS: E.3 SBC #01 at EB, D = 1, A = 10: A = 09: uuth dbg_* equal uut = 00000001
PASS: E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53: A X Y S on the bus (uut) = 53530053
PASS: E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53: P pushed by PHP (uut) = 00000034
PASS: E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53: A X Y S on the bus (uuth) = 53530053
PASS: E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53: P pushed by PHP (uuth) = 00000034
PASS: E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53: dbg_a dbg_x dbg_y dbg_s = 53530053
PASS: E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53: dbg_p = 00000034
PASS: E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53: uuth dbg_* equal uut = 00000001
PASS: E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1: A X Y S on the bus (uut) = 80800080
PASS: E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1: P pushed by PHP (uut) = 000000b4
PASS: E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1: A X Y S on the bus (uuth) = 80800080
PASS: E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1: P pushed by PHP (uuth) = 000000b4
PASS: E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1: dbg_a dbg_x dbg_y dbg_s = 80800080
PASS: E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1: dbg_p = 000000b4
PASS: E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1: uuth dbg_* equal uut = 00000001

=== CPU SECTION E.4: SHA, SHX, SHY, TAS ===

PASS: E.4 SHX 1234,Y, X = 0F, Y = 01 (no cross): writes X AND 13 = 03 at 1235 = 00000001
PASS: E.4 SHX 12FF,Y, X = 0F, Y = 02 (cross): writes 03 at (13 AND 0F)01 = 0301 = 00000001
PASS: E.4 SHY 12FF,X, Y = F0, X = 02 (cross): writes 10 at 1001 = 00000001
PASS: E.4 SHA 12FF,Y, A AND X = 33 (cross): writes 13 at 1301 = 00000001
PASS: E.4 SHA (70),Y, pointer 12FF, A AND X = 30 (cross): writes 10 at 1001 = 00000001
PASS: E.4 TAS 12FF,Y, A AND X = 77 (cross): writes 13 at 1301 = 00000001
PASS: E.4 TAS: S = A AND X = 77 = 00000077
PASS: E.4 SHX 1234,Y, RDY holds cycle 4: writes X = 0F at 1235 = 00000001
PASS: E.4 SHX 12FF,Y (cross), RDY holds cycle 4: writes X = 0F, address still 0301 = 00000001
PASS: E.4 SHX cross, held: cycle 4 reads 1201, the held repeat reads the write address 0301 = 00000001
PASS: E.4 SHA (70),Y (cross), RDY holds cycle 5: writes A AND X = 30 at 1001 = 00000001
PASS: E.4 SHA (zp),Y cross, held: cycle 5 reads 1201, the held repeat reads 1001 = 00000001
PASS: E.4 SHX 1234,Y, RDY holds cycle 3: AND term kept, 03 at 1235 = 00000001
PASS: E.4 SHX 12FF,Y (cross), RDY holds cycle 3: 03 at 0301 = 00000001

=========================================================
 INT SECTION F: Interrupts
=========================================================

=== INT SECTION F.1: Recognition at the Last Cycle ===

PASS: F.1 IRQ falling in phi1 of cycle 1 of the NOP: entry replaces the fetch at 0401, pushes PC 0401 and P 20 = 00000001
PASS: F.1 IRQ falling in phi2 of cycle 1 of the NOP: entry replaces the fetch at 0401, pushes PC 0401 and P 20 = 00000001
PASS: F.1 IRQ falling in phi1 of cycle 2 of the NOP: entry replaces the fetch at 0402, pushes PC 0402 and P 20 = 00000001
PASS: F.1 NMI falling in phi1 of cycle 1 of the NOP: entry replaces the fetch at 0401, pushes PC 0401 and P 24 = 00000001
PASS: F.1 NMI falling in phi2 of cycle 1 of the NOP: entry replaces the fetch at 0401, pushes PC 0401 and P 24 = 00000001
PASS: F.1 NMI falling in phi1 of cycle 2 of the NOP: entry replaces the fetch at 0402, pushes PC 0402 and P 24 = 00000001

=== INT SECTION F.2: Branch Interrupt Delay ===

PASS: F.2 BNE taken (no cross), IRQ low at the edge that starts cycle 2: entry at the target 0404 = 00000001
PASS: F.2 BNE taken (no cross), IRQ first low at cycle 3: one more instruction, entry at 0405 = 00000001
PASS: F.2 BEQ not taken, IRQ low at the edge that starts cycle 2: entry at 0402 = 00000001
PASS: F.2 BNE across a page, IRQ first low at cycle 4: entry at the target 0512 = 00000001
PASS: F.2 taken branch across a page, IRQ low only at the edge that starts cycle 3: not taken = 00000000

=== INT SECTION F.3: CLI, SEI, PLP and RTI Latency ===

PASS: F.3 CLI with IRQ held: the NOP after CLI runs, entry at 0402, pushed I = 0 = 00000001
PASS: F.3 SEI with IRQ low at its last cycle: entry at 0401, pushed I = 1 = 00000001
PASS: F.3 PLP pulling I = 0 with IRQ held: the NOP after PLP runs, entry at 0402 = 00000001
PASS: F.3 PLP pulling I = 1 with IRQ low at its last cycle: entry at 0401, pushed I = 1 = 00000001
PASS: F.3 RTI restoring I = 0 with IRQ held: entry at the return address 0500, no delay = 00000001

=== INT SECTION F.4: Entry Sequence, B Bit and Pushed P ===

PASS: F.4 BRK with P = C3: reads 0401, pushes PC+2 = 0402 and P OR 30 = F3, vector FFFE = 00000001
PASS: F.4 BRK: dbg_p at the handler fetch = C3 with I = 1 = 000000f7
PASS: F.4 uuth dbg_ir equal uut at the handler fetch = 00000001
PASS: F.4 BRK with D = 1: pushes 38 = 00000001
PASS: F.4 BRK with D = 1: D still 1 and I = 1 in the handler = 0000003c
PASS: F.4 uuth dbg_ir equal uut at the handler fetch = 00000001
PASS: F.4 IRQ with P = C3: pushes E3 (bit 4 = 0, bit 5 = 1) = 00000001
PASS: F.4 uuth dbg_ir equal uut at the handler fetch = 00000001
PASS: F.4 NMI with P = C7 (I = 1): pushes E7, vector FFFA = 00000001
PASS: F.4 uuth dbg_ir equal uut at the handler fetch = 00000001

=== INT SECTION F.5: NMI Hijack ===

PASS: F.5 NMI falling in phi1 of BRK cycle 4: hijack, vector FFFA, B = 1 pushed = 00000001
PASS: F.5 NMI falling in phi2 of BRK cycle 4: hijack, vector FFFA, B = 1 pushed = 00000001
PASS: F.5 NMI falling in BRK cycle 5: BRK completes, handler's first NOP runs, NMI entry at 0701 = 00000001
PASS: F.5 NMI falling in IRQ entry cycle 4: hijack, vector FFFA, B = 0 pushed = 00000001
PASS: F.5 IRQ and NMI together: NMI vector, B = 0 = 00000001
PASS: F.5 NMI low only at the edges of BRK cycles 6 and 7: lost, BRK handler runs, no NMI entry = 00000001

=== INT SECTION F.6: NMI Edge Latch and NMI across RES ===

PASS: F.6 NMI held low for 40 cycles: one NMI entry = 00000001
PASS: F.6 NMI high at one edge, then low: a second NMI entry = 00000001
PASS: F.6 NMI falling while RES is low and held: absorbed by the reset, never taken = 00000001

=== INT SECTION F.7: Interrupt Sweeps (netlist scenarios) ===

PASS: F.7 IRQ or NMI at every row of 38 contexts: 190 scenarios, 15580 cycles run = 00000001
PASS: F.7 IRQ or NMI at every row of 38 contexts: address, R/W and SYNC mismatches = 00000000
PASS: F.7 IRQ or NMI at every row of 38 contexts: write data mismatches = 00000000
PASS: F.7 IRQ or NMI at every row of 38 contexts: dout_oe mismatches = 00000000
PASS: F.7 IRQ or NMI at every row of 38 contexts: vp_n mismatches = 00000000
PASS: F.7 IRQ or NMI at every row of 38 contexts: dbg_* mismatches = 00000000
PASS: F.7 IRQ or NMI at every row of 38 contexts: CYCLE/HALF lockstep mismatches = 00000000
PASS: F.7 one-edge IRQ/NMI at every edge of every branch variant: 160 scenarios, 11520 cycles run = 00000001
PASS: F.7 one-edge IRQ/NMI at every edge of every branch variant: address, R/W and SYNC mismatches = 00000000
PASS: F.7 one-edge IRQ/NMI at every edge of every branch variant: write data mismatches = 00000000
PASS: F.7 one-edge IRQ/NMI at every edge of every branch variant: dout_oe mismatches = 00000000
PASS: F.7 one-edge IRQ/NMI at every edge of every branch variant: vp_n mismatches = 00000000
PASS: F.7 one-edge IRQ/NMI at every edge of every branch variant: dbg_* mismatches = 00000000
PASS: F.7 one-edge IRQ/NMI at every edge of every branch variant: CYCLE/HALF lockstep mismatches = 00000000
PASS: F.7 branch chains and CLI/SEI/PLP/RTI sequences: 72 scenarios, 6624 cycles run = 00000001
PASS: F.7 branch chains and CLI/SEI/PLP/RTI sequences: address, R/W and SYNC mismatches = 00000000
PASS: F.7 branch chains and CLI/SEI/PLP/RTI sequences: write data mismatches = 00000000
PASS: F.7 branch chains and CLI/SEI/PLP/RTI sequences: dout_oe mismatches = 00000000
PASS: F.7 branch chains and CLI/SEI/PLP/RTI sequences: vp_n mismatches = 00000000
PASS: F.7 branch chains and CLI/SEI/PLP/RTI sequences: dbg_* mismatches = 00000000
PASS: F.7 branch chains and CLI/SEI/PLP/RTI sequences: CYCLE/HALF lockstep mismatches = 00000000
PASS: F.7 second NMI edges and high windows: 50 scenarios, 5100 cycles run = 00000001
PASS: F.7 second NMI edges and high windows: address, R/W and SYNC mismatches = 00000000
PASS: F.7 second NMI edges and high windows: write data mismatches = 00000000
PASS: F.7 second NMI edges and high windows: dout_oe mismatches = 00000000
PASS: F.7 second NMI edges and high windows: vp_n mismatches = 00000000
PASS: F.7 second NMI edges and high windows: dbg_* mismatches = 00000000
PASS: F.7 second NMI edges and high windows: CYCLE/HALF lockstep mismatches = 00000000
PASS: F.7 hijack windows of BRK and IRQ entries: 102 scenarios, 9384 cycles run = 00000001
PASS: F.7 hijack windows of BRK and IRQ entries: address, R/W and SYNC mismatches = 00000000
PASS: F.7 hijack windows of BRK and IRQ entries: write data mismatches = 00000000
PASS: F.7 hijack windows of BRK and IRQ entries: dout_oe mismatches = 00000000
PASS: F.7 hijack windows of BRK and IRQ entries: vp_n mismatches = 00000000
PASS: F.7 hijack windows of BRK and IRQ entries: dbg_* mismatches = 00000000
PASS: F.7 hijack windows of BRK and IRQ entries: CYCLE/HALF lockstep mismatches = 00000000
PASS: F.7 NMI around RES: 49 scenarios, 4998 cycles run = 00000001
PASS: F.7 NMI around RES: address, R/W and SYNC mismatches = 00000000
PASS: F.7 NMI around RES: write data mismatches = 00000000
PASS: F.7 NMI around RES: dout_oe mismatches = 00000000
PASS: F.7 NMI around RES: held PC while RES is low, mismatches = 00000000
PASS: F.7 NMI around RES: dbg_* mismatches = 00000000
PASS: F.7 NMI around RES: CYCLE/HALF lockstep mismatches = 00000000

=== INT SECTION F.8: Held Last Cycle of CLI and SEI (netlist scenarios) ===

PASS: F.8 CLI and SEI with the last cycle held, IRQ at every row: 96 scenarios, 5769 cycles run = 00000001
PASS: F.8 CLI and SEI with the last cycle held, IRQ at every row: address, R/W and SYNC mismatches = 00000000
PASS: F.8 CLI and SEI with the last cycle held, IRQ at every row: write data mismatches = 00000000
PASS: F.8 CLI and SEI with the last cycle held, IRQ at every row: dout_oe mismatches = 00000000
PASS: F.8 CLI and SEI with the last cycle held, IRQ at every row: vp_n mismatches = 00000000
PASS: F.8 CLI and SEI with the last cycle held, IRQ at every row: dbg_* mismatches = 00000000
PASS: F.8 CLI and SEI with the last cycle held, IRQ at every row: CYCLE/HALF lockstep mismatches = 00000000

=========================================================
 BUS SECTION G: RDY
=========================================================

=== BUS SECTION G.1: Held Reads and Held Writes ===

PASS: G.1 LDA 1234 held two cycles: cycle 4 repeats at 1234, next fetch at cycle 7 = 00000001
PASS: G.1 LDA held: A = the byte of the last repeat (33) = 00000033
PASS: G.1 LDA held: A = 33 (uuth) = 00000033
PASS: G.1 STA, RDY low at the end of its write cycle: the write of 5A happens = 00000001
PASS: G.1 STA: the next fetch is held one cycle, SYNC kept on the repeat = 00000001
PASS: G.1 JSR, RDY low only across its two writes: no hold, fetch at 0500 in cycle 7 = 00000001

=== BUS SECTION G.2: Held Dummy Reads Show the Next Address ===

PASS: G.2 LDA 12F0,X (X = 20) held at the dummy read 1210: repeats read 1310 (carried) = 00000001
PASS: G.2 BNE forward across a page held at the fixup 0412: repeats read 0512 = 00000001
PASS: G.2 BNE backward across a page held at the fixup 05F4: repeats keep 05F4 = 00000001

=== BUS SECTION G.3: Interrupts during Holds ===

PASS: G.3 IRQ low only at the edge of one held repeat of LDA's last cycle: taken after LDA = 00000001
PASS: G.3 IRQ low only during a hold of cycle 3 (not polled): lost = 00000001
PASS: G.3 NMI falling and rising during a hold of cycle 3: latched, taken after LDA = 00000001

=== BUS SECTION G.4: RDY Sweeps (netlist scenarios) ===

PASS: G.4 RDY low 1-6 half cycles from every row of 13 contexts: 78 scenarios, 6396 cycles run = 00000001
PASS: G.4 RDY low 1-6 half cycles from every row of 13 contexts: address, R/W and SYNC mismatches = 00000000
PASS: G.4 RDY low 1-6 half cycles from every row of 13 contexts: write data mismatches = 00000000
PASS: G.4 RDY low 1-6 half cycles from every row of 13 contexts: dout_oe mismatches = 00000000
PASS: G.4 RDY low 1-6 half cycles from every row of 13 contexts: vp_n mismatches = 00000000
PASS: G.4 RDY low 1-6 half cycles from every row of 13 contexts: dbg_* mismatches = 00000000
PASS: G.4 RDY low 1-6 half cycles from every row of 13 contexts: CYCLE/HALF lockstep mismatches = 00000000
PASS: G.4 RDY on uncarried dummy reads and branch fixups: 140 scenarios, 10080 cycles run = 00000001
PASS: G.4 RDY on uncarried dummy reads and branch fixups: address, R/W and SYNC mismatches = 00000000
PASS: G.4 RDY on uncarried dummy reads and branch fixups: write data mismatches = 00000000
PASS: G.4 RDY on uncarried dummy reads and branch fixups: dout_oe mismatches = 00000000
PASS: G.4 RDY on uncarried dummy reads and branch fixups: vp_n mismatches = 00000000
PASS: G.4 RDY on uncarried dummy reads and branch fixups: dbg_* mismatches = 00000000
PASS: G.4 RDY on uncarried dummy reads and branch fixups: CYCLE/HALF lockstep mismatches = 00000000
PASS: G.4 IRQ, NMI and SO pulses inside RDY holds: 45 scenarios, 3690 cycles run = 00000001
PASS: G.4 IRQ, NMI and SO pulses inside RDY holds: address, R/W and SYNC mismatches = 00000000
PASS: G.4 IRQ, NMI and SO pulses inside RDY holds: write data mismatches = 00000000
PASS: G.4 IRQ, NMI and SO pulses inside RDY holds: dout_oe mismatches = 00000000
PASS: G.4 IRQ, NMI and SO pulses inside RDY holds: vp_n mismatches = 00000000
PASS: G.4 IRQ, NMI and SO pulses inside RDY holds: dbg_* mismatches = 00000000
PASS: G.4 IRQ, NMI and SO pulses inside RDY holds: CYCLE/HALF lockstep mismatches = 00000000
PASS: G.4 every read cycle of every opcode variant held 1 and 2 cycles: 345 scenarios, 24840 cycles run = 00000001
PASS: G.4 every read cycle of every opcode variant held 1 and 2 cycles: address, R/W and SYNC mismatches = 00000000
PASS: G.4 every read cycle of every opcode variant held 1 and 2 cycles: write data mismatches = 00000000
PASS: G.4 every read cycle of every opcode variant held 1 and 2 cycles: dout_oe mismatches = 00000000
PASS: G.4 every read cycle of every opcode variant held 1 and 2 cycles: vp_n mismatches = 00000000
PASS: G.4 every read cycle of every opcode variant held 1 and 2 cycles: dbg_* mismatches = 00000000
PASS: G.4 every read cycle of every opcode variant held 1 and 2 cycles: CYCLE/HALF lockstep mismatches = 00000000

=== BUS SECTION G.5: Held Vector Reads of an Entry (netlist scenarios) ===

PASS: G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset: 280 scenarios, 17516 cycles run = 00000001
PASS: G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset: address, R/W and SYNC mismatches = 00000000
PASS: G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset: write data mismatches = 00000000
PASS: G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset: dout_oe mismatches = 00000000
PASS: G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset: vp_n mismatches = 00000000
PASS: G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset: dbg_* mismatches = 00000000
PASS: G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset: CYCLE/HALF lockstep mismatches = 00000000

=========================================================
 CPU SECTION H: SO (Set Overflow)
=========================================================

=== CPU SECTION H.1: Sampling Point in Both Clock Modes ===

PASS: H.1 SO falling in phi2 of a NOP's cycle 1: V = 1 at the next fetch, both modes = 0000003c
PASS: H.1 SO falling in phi1 of cycle 2: V at the next fetch in HALF mode, one cycle later in CYCLE mode = 0000001c
PASS: H.1 SO low for one sample only: V set, both modes = 0000003c

=== CPU SECTION H.2: A New Edge Needs SO High ===

PASS: H.2 SO held low: V set once, CLV clears it, no new edge while SO stays low = 00000008
PASS: H.2 SO high at one sample, then low: V set again = 00000003

=== CPU SECTION H.3: Collisions with V Loads ===

PASS: H.3 ADC #00, SO set at the edge of cycle base+2: V = 0 at base+4 = 00000000
PASS: H.3 ADC #00, SO set at the edge of cycle base+3: V = 0 at base+4 = 00000000
PASS: H.3 ADC #00, SO set at the edge of cycle base+4: V = 1 at base+4 = 00000003
PASS: H.3 CLV, SO set at the edge of cycle base+2: V = 0 at base+4 = 00000000
PASS: H.3 CLV, SO set at the edge of cycle base+3: V = 0 at base+4 = 00000000
PASS: H.3 CLV, SO set at the edge of cycle base+4: V = 1 at base+4 = 00000003

=== CPU SECTION H.4: SO during a RDY Hold ===

PASS: H.4 SO falling while LDA is held: V set during the hold, seen at the next fetch = 00000007

=== CPU SECTION H.5: SO Sweeps (netlist scenarios) ===

PASS: H.5 SO at every row of 7 contexts, widths 1, 2 and held: 79 scenarios, 5688 cycles run = 00000001
PASS: H.5 SO at every row of 7 contexts, widths 1, 2 and held: address, R/W and SYNC mismatches = 00000000
PASS: H.5 SO at every row of 7 contexts, widths 1, 2 and held: write data mismatches = 00000000
PASS: H.5 SO at every row of 7 contexts, widths 1, 2 and held: dout_oe mismatches = 00000000
PASS: H.5 SO at every row of 7 contexts, widths 1, 2 and held: vp_n mismatches = 00000000
PASS: H.5 SO at every row of 7 contexts, widths 1, 2 and held: dbg_* mismatches = 00000000
PASS: H.5 SO at every row of 7 contexts, widths 1, 2 and held: CYCLE/HALF lockstep mismatches = 00000000
PASS: H.5 SO at every row of every V-writing opcode: 98 scenarios, 7056 cycles run = 00000001
PASS: H.5 SO at every row of every V-writing opcode: address, R/W and SYNC mismatches = 00000000
PASS: H.5 SO at every row of every V-writing opcode: write data mismatches = 00000000
PASS: H.5 SO at every row of every V-writing opcode: dout_oe mismatches = 00000000
PASS: H.5 SO at every row of every V-writing opcode: vp_n mismatches = 00000000
PASS: H.5 SO at every row of every V-writing opcode: dbg_* mismatches = 00000000
PASS: H.5 SO at every row of every V-writing opcode: CYCLE/HALF lockstep mismatches = 00000000

=== CPU SECTION H.6: SO before BVC and BVS (netlist scenarios) ===

PASS: H.6 BVC and BVS with SO at every row around cycle 2: 96 scenarios, 6048 cycles run = 00000001
PASS: H.6 BVC and BVS with SO at every row around cycle 2: address, R/W and SYNC mismatches = 00000000
PASS: H.6 BVC and BVS with SO at every row around cycle 2: write data mismatches = 00000000
PASS: H.6 BVC and BVS with SO at every row around cycle 2: dout_oe mismatches = 00000000
PASS: H.6 BVC and BVS with SO at every row around cycle 2: vp_n mismatches = 00000000
PASS: H.6 BVC and BVS with SO at every row around cycle 2: dbg_* mismatches = 00000000
PASS: H.6 BVC and BVS with SO at every row around cycle 2: CYCLE/HALF lockstep mismatches = 00000000

=== CPU SECTION H.7: CLV with the Next Fetch Held (netlist scenarios) ===

PASS: H.7 CLV, next fetch held 0-3 cycles, SO at every row: 40 scenarios, 2230 cycles run = 00000001
PASS: H.7 CLV, next fetch held 0-3 cycles, SO at every row: address, R/W and SYNC mismatches = 00000000
PASS: H.7 CLV, next fetch held 0-3 cycles, SO at every row: write data mismatches = 00000000
PASS: H.7 CLV, next fetch held 0-3 cycles, SO at every row: dout_oe mismatches = 00000000
PASS: H.7 CLV, next fetch held 0-3 cycles, SO at every row: vp_n mismatches = 00000000
PASS: H.7 CLV, next fetch held 0-3 cycles, SO at every row: dbg_* mismatches = 00000000
PASS: H.7 CLV, next fetch held 0-3 cycles, SO at every row: CYCLE/HALF lockstep mismatches = 00000000

=========================================================
 CPU SECTION I: JAM
=========================================================

=== CPU SECTION I.1: Bus Pattern and jam Output ===

PASS: I.1 JAM $02: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $02: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $12: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $12: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $22: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $22: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $32: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $32: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $42: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $42: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $52: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $52: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $62: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $62: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $72: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $72: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $92: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $92: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $b2: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $b2: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $d2: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $d2: dbg_pc = 0402 while halted = 00000402
PASS: I.1 JAM $f2: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3 = 00000000
PASS: I.1 JAM $f2: dbg_pc = 0402 while halted = 00000402

=== CPU SECTION I.2: Interrupts Ignored, Recovery by RES ===

PASS: I.2 IRQ low (I = 0) and an NMI edge during the JAM: FFFF reads continue, no entry = 00000000
PASS: I.2 RES (four edges) leaves the JAM: reset vector fetch at s+8 = 00000001
PASS: I.2 cycle r+1 still reads FFFF = 00000001
PASS: I.2 cycles r+2 .. s+2 hold the PC 0402 (opcode address + 2), SYNC only at s+1 = 00000000
PASS: I.2 stack reads from 01FF, FFFC at s+6 = 00000001
PASS: I.2 jam = 0 at the reset vector fetch = 00000000
PASS: I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed: A X Y S on the bus (uut) = 112233fc
PASS: I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed: P pushed by PHP (uut) = 00000034
PASS: I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed: A X Y S on the bus (uuth) = 112233fc
PASS: I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed: P pushed by PHP (uuth) = 00000034
PASS: I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed: dbg_a dbg_x dbg_y dbg_s = 112233fc
PASS: I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed: dbg_p = 00000034
PASS: I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed: uuth dbg_* equal uut = 00000001

=== CPU SECTION I.3: JAM Sweeps (netlist scenarios) ===

PASS: I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES: 36 scenarios, 2472 cycles run = 00000001
PASS: I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES: address, R/W and SYNC mismatches = 00000000
PASS: I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES: write data mismatches = 00000000
PASS: I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES: dout_oe mismatches = 00000000
PASS: I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES: held PC while RES is low, mismatches = 00000000
PASS: I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES: dbg_* mismatches = 00000000
PASS: I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES: CYCLE/HALF lockstep mismatches = 00000000

=========================================================
 BUS SECTION J: SYNC and vp_n
=========================================================

=== BUS SECTION J.1: SYNC on Opcode Fetches Only ===

PASS: J.1 LDA STA INC PHA PLA JSR RTS: 7 SYNC cycles in 33 cycles = 00000007
PASS: J.1 cycle count 4 + 4 + 6 + 3 + 4 + 6 + 6 = 00000021
PASS: J.1 SYNC never in a write cycle = 00000000

=== BUS SECTION J.2: vp_n ===

PASS: J.2 BRK: vp_n = 0 in cycles 6 and 7 (FFFE, FFFF) only = 00000000
PASS: J.2 JMP (FFFE) reads FFFE and FFFF with vp_n = 1 = 00000000
PASS: J.2 LDA FFFA: vp_n = 1 = 00000000
PASS: J.2 IRQ entry: vp_n = 0 in cycles 6 and 7 only = 00000000
PASS: J.2 NMI entry: vp_n = 0 in cycles 6 and 7 (FFFA, FFFB) only = 00000000
PASS: J.2 reset sequence (FFFC, FFFD read): vp_n = 1 = 00000000

=========================================================
 CLK SECTION K: Clock Modes and Enables
=========================================================

=== CLK SECTION K.1: Enable Ratios ===

PASS: K.1 opcode scenarios at ratio 1 (CYCLE mode only): 345 scenarios, 22935 cycles run = 00000001
PASS: K.1 opcode scenarios at ratio 1 (CYCLE mode only): address, R/W and SYNC mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 1 (CYCLE mode only): write data mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 1 (CYCLE mode only): dout_oe mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 1 (CYCLE mode only): vp_n mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 1 (CYCLE mode only): dbg_* mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 1 (CYCLE mode only): CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 2: 345 scenarios, 22935 cycles run = 00000001
PASS: K.1 opcode scenarios at ratio 2: address, R/W and SYNC mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 2: write data mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 2: dout_oe mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 2: vp_n mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 2: dbg_* mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 2: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 2: 48 scenarios, 3936 cycles run = 00000001
PASS: K.1 interrupt scenarios at ratio 2: address, R/W and SYNC mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 2: write data mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 2: dout_oe mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 2: vp_n mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 2: dbg_* mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 2: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 3: 345 scenarios, 22935 cycles run = 00000001
PASS: K.1 opcode scenarios at ratio 3: address, R/W and SYNC mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 3: write data mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 3: dout_oe mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 3: vp_n mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 3: dbg_* mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 3: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 3: 48 scenarios, 3936 cycles run = 00000001
PASS: K.1 interrupt scenarios at ratio 3: address, R/W and SYNC mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 3: write data mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 3: dout_oe mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 3: vp_n mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 3: dbg_* mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 3: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 5: 345 scenarios, 22935 cycles run = 00000001
PASS: K.1 opcode scenarios at ratio 5: address, R/W and SYNC mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 5: write data mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 5: dout_oe mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 5: vp_n mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 5: dbg_* mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 5: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 5: 48 scenarios, 3936 cycles run = 00000001
PASS: K.1 interrupt scenarios at ratio 5: address, R/W and SYNC mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 5: write data mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 5: dout_oe mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 5: vp_n mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 5: dbg_* mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 5: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 16: 173 scenarios, 11486 cycles run = 00000001
PASS: K.1 opcode scenarios at ratio 16: address, R/W and SYNC mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 16: write data mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 16: dout_oe mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 16: vp_n mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 16: dbg_* mismatches = 00000000
PASS: K.1 opcode scenarios at ratio 16: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 16: 48 scenarios, 3936 cycles run = 00000001
PASS: K.1 interrupt scenarios at ratio 16: address, R/W and SYNC mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 16: write data mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 16: dout_oe mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 16: vp_n mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 16: dbg_* mismatches = 00000000
PASS: K.1 interrupt scenarios at ratio 16: CYCLE/HALF lockstep mismatches = 00000000

=== CLK SECTION K.2: Random Stops between Enables ===

PASS: K.2 opcode scenarios, ratio 3 with stops: 230 scenarios, 15305 cycles run = 00000001
PASS: K.2 opcode scenarios, ratio 3 with stops: address, R/W and SYNC mismatches = 00000000
PASS: K.2 opcode scenarios, ratio 3 with stops: write data mismatches = 00000000
PASS: K.2 opcode scenarios, ratio 3 with stops: dout_oe mismatches = 00000000
PASS: K.2 opcode scenarios, ratio 3 with stops: vp_n mismatches = 00000000
PASS: K.2 opcode scenarios, ratio 3 with stops: dbg_* mismatches = 00000000
PASS: K.2 opcode scenarios, ratio 3 with stops: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.2 interrupt scenarios, ratio 3 with stops: 38 scenarios, 3116 cycles run = 00000001
PASS: K.2 interrupt scenarios, ratio 3 with stops: address, R/W and SYNC mismatches = 00000000
PASS: K.2 interrupt scenarios, ratio 3 with stops: write data mismatches = 00000000
PASS: K.2 interrupt scenarios, ratio 3 with stops: dout_oe mismatches = 00000000
PASS: K.2 interrupt scenarios, ratio 3 with stops: vp_n mismatches = 00000000
PASS: K.2 interrupt scenarios, ratio 3 with stops: dbg_* mismatches = 00000000
PASS: K.2 interrupt scenarios, ratio 3 with stops: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.2 RDY dummy-read scenarios, ratio 3 with stops: 35 scenarios, 2520 cycles run = 00000001
PASS: K.2 RDY dummy-read scenarios, ratio 3 with stops: address, R/W and SYNC mismatches = 00000000
PASS: K.2 RDY dummy-read scenarios, ratio 3 with stops: write data mismatches = 00000000
PASS: K.2 RDY dummy-read scenarios, ratio 3 with stops: dout_oe mismatches = 00000000
PASS: K.2 RDY dummy-read scenarios, ratio 3 with stops: vp_n mismatches = 00000000
PASS: K.2 RDY dummy-read scenarios, ratio 3 with stops: dbg_* mismatches = 00000000
PASS: K.2 RDY dummy-read scenarios, ratio 3 with stops: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.2 SO scenarios, ratio 3 with stops: 20 scenarios, 1440 cycles run = 00000001
PASS: K.2 SO scenarios, ratio 3 with stops: address, R/W and SYNC mismatches = 00000000
PASS: K.2 SO scenarios, ratio 3 with stops: write data mismatches = 00000000
PASS: K.2 SO scenarios, ratio 3 with stops: dout_oe mismatches = 00000000
PASS: K.2 SO scenarios, ratio 3 with stops: vp_n mismatches = 00000000
PASS: K.2 SO scenarios, ratio 3 with stops: dbg_* mismatches = 00000000
PASS: K.2 SO scenarios, ratio 3 with stops: CYCLE/HALF lockstep mismatches = 00000000
PASS: K.2 RES scenarios, ratio 3 with stops: 96 scenarios, 6805 cycles run = 00000001
PASS: K.2 RES scenarios, ratio 3 with stops: address, R/W and SYNC mismatches = 00000000
PASS: K.2 RES scenarios, ratio 3 with stops: write data mismatches = 00000000
PASS: K.2 RES scenarios, ratio 3 with stops: dout_oe mismatches = 00000000
PASS: K.2 RES scenarios, ratio 3 with stops: held PC while RES is low, mismatches = 00000000
PASS: K.2 RES scenarios, ratio 3 with stops: dbg_* mismatches = 00000000
PASS: K.2 RES scenarios, ratio 3 with stops: CYCLE/HALF lockstep mismatches = 00000000

=== CLK SECTION K.3: Lockstep and Output Timing ===

PASS: K.3 CYCLE/HALF lockstep over every scenario run in both modes (7963 scenarios, 576739 cycles) = 00000000
PASS: K.3 uut outputs changed only at cen edges: violations = 00000000
PASS: K.3 uuth outputs changed only at cen and cen_p2 edges: violations = 00000000
PASS: K.3 uut outputs never X (cen_p2 unconnected): clk edges with an X = 00000000
PASS: K.3 uuth outputs never X: clk edges with an X = 00000000

=============================================================
  x6502 Test Results
=============================================================
  Total Tests:  996
  Passed:       996
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
  Cycle-accurate to the MCS6500 Hardware Manual and the NMOS 6502 netlist
=============================================================
```
