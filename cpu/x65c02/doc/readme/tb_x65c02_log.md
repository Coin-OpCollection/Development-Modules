# x65c02 Regression Log

Full output of the `tb_x65c02` testbench (687 tests across 48 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  x65c02 Comprehensive Testbench
  Reference: Rockwell R65C02 Datasheet, R65C02P2 bus recordings
=============================================================
INFO: vector file loaded

=========================================================
 CPU SECTION A: Reset
=========================================================

=== CPU SECTION A.1: Power-up Values ===

PASS: A.1 power-up A X Y = 00 00 00 = 00000000
PASS: A.1 power-up S = 00 = 00000000
PASS: A.1 power-up P = 34 (I = 1, D = 0, bits 5 and 4 read 1) = 00000034
PASS: A.1 power-up PC = 0000 = 00000000
PASS: A.1 power-up IR = 00 = 00000000
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

=== CPU SECTION A.3: Registers Kept by a Warm Reset, D Cleared ===

PASS: A.3 ratio 2: reset handler reached = 00000001
PASS: A.3 ratio 2: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: A X Y S on the bus (uut) = 805ac37d
PASS: A.3 ratio 2: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: P pushed by PHP (uut) = 000000f5
PASS: A.3 ratio 2: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: A X Y S on the bus (uuth) = 805ac37d
PASS: A.3 ratio 2: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: P pushed by PHP (uuth) = 000000f5
PASS: A.3 ratio 2: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: dbg_a dbg_x dbg_y dbg_s = 805ac37d
PASS: A.3 ratio 2: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: dbg_p = 000000f5
PASS: A.3 ratio 2: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: uuth dbg_* equal uut = 00000001
PASS: A.3 ratio 5: reset handler reached = 00000001
PASS: A.3 ratio 5: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: A X Y S on the bus (uut) = 805ac37d
PASS: A.3 ratio 5: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: P pushed by PHP (uut) = 000000f5
PASS: A.3 ratio 5: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: A X Y S on the bus (uuth) = 805ac37d
PASS: A.3 ratio 5: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: P pushed by PHP (uuth) = 000000f5
PASS: A.3 ratio 5: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: dbg_a dbg_x dbg_y dbg_s = 805ac37d
PASS: A.3 ratio 5: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: dbg_p = 000000f5
PASS: A.3 ratio 5: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0: uuth dbg_* equal uut = 00000001

=== CPU SECTION A.4: Stack Reads and S - 3 ===

PASS: A.4 s+3 reads 0101 = 00000001
PASS: A.4 s+4 reads 0100 = 00000001
PASS: A.4 s+5 reads 01FF = 00000001
PASS: A.4 S = 01 - 3 = FE = 000000fe
PASS: A.4 dbg_s = FE at the first fetch = 000000fe

=== CPU SECTION A.5: Bus while RES Is Low and the Held PC ===

PASS: A.5 RES from LDA cycle 0: r+1 shows 0400, R/W = 1, SYNC = 0 = 00000001
PASS: A.5 RES from LDA cycle 0: r+2 .. s+2 hold 0400, SYNC only at s+1 = 00000000
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
PASS: A.5 RES from LDA cycle 1: r+2 .. s+2 hold 0401, SYNC only at s+1 = 00000000
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
PASS: A.5 RES from LDA cycle 2: r+2 .. s+2 hold 0402, SYNC only at s+1 = 00000000
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
PASS: A.5 RES from LDA cycle 3: r+2 .. s+2 hold 0403, SYNC only at s+1 = 00000000
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
PASS: A.5 RES from LDA cycle 4: r+2 .. s+2 hold 0403, SYNC only at s+1 = 00000000
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
PASS: A.7 INC, RES first low at the data read: no write = 00000000
PASS: A.7 INC: cycle r+1 is the second read of 1234 = 00000001
PASS: A.7 INC, RES first low at the second read: cycle r+1 (the write cycle) runs as a read = 00000001
PASS: A.7 INC: the write of 42 does not happen = 00000000
PASS: A.7 INC, RES first low at its write cycle: the write of 42 happens = 00000001
PASS: A.7 INC: no write after cycle r = 00000000

=== CPU SECTION A.8: One-edge RES at a Branch and a Read-Modify-Write ===

PASS: A.8 branch cut at cycle 3: r+1 shows the target 0412, SYNC = 0 = 00000001
PASS: A.8 branch: s+1 = r+2 with SYNC and s+2 hold 0412 = 00000001
PASS: A.8 branch: stack reads from r+4, FFFC at r+7, fetch at the vector at r+9 = 00000001
PASS: A.8 INC cut at the data read: r+1 is the second read of 1234 = 00000001
PASS: A.8 INC: s+1 = r+2 at the held PC 0403 with SYNC, s+2 at 0403 = 00000001
PASS: A.8 INC: FFFC at r+7, fetch at the vector at r+9 = 00000001
PASS: A.8 INC: no write = 00000000

=== CPU SECTION A.9: RES at Every Cycle of Every Instruction Kind ===

PASS: A.9 RES in NOP at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in LDA # at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in LDA abs at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in STA abs at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in INC abs at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in INC abs,X at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in ASL abs,X at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in ADC # (D = 1) at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in ADC abs (D = 1) at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in LDA (zp),Y cross at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in STA (zp),Y at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in JMP abs at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in JMP (abs) at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in JMP (abs,X) at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in BNE taken at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in BNE taken, page cross at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in BRA at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in BBS0 taken at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in BBR0 not taken at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in JSR at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in RTS at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in RTI at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in PHA at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in PLA at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in BRK at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in NOP 03 (1 cycle) at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in TSB abs at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in RMB3 zp at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in PHX at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000
PASS: A.9 RES in PLY at cycles 2-11, 1 and 3 edges (20 runs): mismatches = 00000000

=== CPU SECTION A.10: RES inside a Running Reset Sequence ===

PASS: A.10 second RES at s+1: new sequence (fetch 9 cycles later, no write), S = 7d = 017d7d04
PASS: A.10 second RES at s+2: new sequence (fetch 9 cycles later, no write), S = 7d = 017d7d04
PASS: A.10 second RES at s+3: new sequence (fetch 9 cycles later, no write), S = 7d = 017d7d04
PASS: A.10 second RES at s+4: new sequence (fetch 9 cycles later, no write), S = 7d = 017d7d04
PASS: A.10 second RES at s+5: new sequence (fetch 9 cycles later, no write), S = 7a = 017a7a04
PASS: A.10 second RES at s+6: new sequence (fetch 9 cycles later, no write), S = 7a = 017a7a04
PASS: A.10 second RES at s+7: new sequence (fetch 9 cycles later, no write), S = 7a = 017a7a04
PASS: A.10 second RES at s+8: new sequence (fetch 9 cycles later, no write), S = 7a = 017a7a04

=== CPU SECTION A.11: RDY during the RES Protocol ===

PASS: A.11 RES 3 edges, RDY low 0 edges after r: s+1 at r+4, fetch at the vector at r+11 = 00000001
PASS: A.11 RES 3 edges, RDY low 4 edges after r: s+1 at r+4, fetch at the vector at r+11 = 00000001
PASS: A.11 RES 3 edges, RDY low 5 edges after r: s+1 at r+4 held once, fetch at the vector at r+12 = 00000001
PASS: A.11 STA held by RDY, RES first low at a held repeat: the held write completes (5A at 1234), then no write = 00000001

=========================================================
 BUS SECTION B: Bus Cycles per Addressing Mode
=========================================================

=== BUS SECTION B.1: Every Opcode (instruction vectors) ===

PASS: B.1 instruction vectors, ratio 4: 1130 tests, failing = 00000000

=== BUS SECTION B.2: Addressing Mode Groups ===

PASS: B.2 implied and accumulator: 24 opcodes, 96 tests: mismatches = 00000000
PASS: B.2 immediate: 12 opcodes, 48 tests: mismatches = 00000000
PASS: B.2 zero page: 24 opcodes, 96 tests: mismatches = 00000000
PASS: B.2 zero page indexed: 20 opcodes, 80 tests: mismatches = 00000000
PASS: B.2 absolute: 24 opcodes, 96 tests: mismatches = 00000000
PASS: B.2 absolute indexed: 26 opcodes, 146 tests: mismatches = 00000000
PASS: B.2 (zero page,X): 8 opcodes, 32 tests: mismatches = 00000000
PASS: B.2 (zero page),Y: 8 opcodes, 46 tests: mismatches = 00000000
PASS: B.2 (zero page): 8 opcodes, 32 tests: mismatches = 00000000
PASS: B.2 relative (branches, BRA): 9 opcodes, 54 tests: mismatches = 00000000
PASS: B.2 stack (PHA PHP PLA PLP PHX PHY PLX PLY): 8 opcodes, 32 tests: mismatches = 00000000
PASS: B.2 JSR RTS RTI BRK: 4 opcodes, 16 tests: mismatches = 00000000
PASS: B.2 JMP abs, (abs), (abs,X): 3 opcodes, 12 tests: mismatches = 00000000
PASS: B.2 RMB SMB BBR BBS: 32 opcodes, 160 tests: mismatches = 00000000
PASS: B.2 undefined NOPs: 46 opcodes, 184 tests: mismatches = 00000000

=== BUS SECTION B.3: Data Bus Drive Window ===

PASS: B.3 STA 1234 uut: R/W = 0, dout 5A in both halves, dout_oe = 1 in both halves = 00000001
PASS: B.3 STA 1234 uuth: dout 5A in both halves, dout_oe = 0 in phi1, 1 in phi2 = 00000001
PASS: B.3 STA cycle 3 (read): dout_oe = 0 (uut) = 00000001
PASS: B.3 STA cycle 3 (read): dout_oe = 0 (uuth) = 00000001
PASS: B.3 INC 1235: reads 41 twice, no data bus drive, uut = 00000001
PASS: B.3 INC 1235: then writes 42 once, dout_oe = 1, uut = 00000001
PASS: B.3 INC 1235: reads 41 twice, writes 42 with dout_oe in phi2 only, uuth = 00000001

=========================================================
 CPU SECTION C: All 256 Opcodes
=========================================================

=== CPU SECTION C.1: Opcodes 00-FF (instruction vectors of B.1) ===

PASS: C.1 $00 BRK impl: 4 tests: mismatches = 00000000
PASS: C.1 $01 ORA (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $02 nop? 02: 4 tests: mismatches = 00000000
PASS: C.1 $03 nop? 03: 4 tests: mismatches = 00000000
PASS: C.1 $04 TSB zp: 4 tests: mismatches = 00000000
PASS: C.1 $05 ORA zp: 4 tests: mismatches = 00000000
PASS: C.1 $06 ASL zp: 4 tests: mismatches = 00000000
PASS: C.1 $07 RMB0 zp: 4 tests: mismatches = 00000000
PASS: C.1 $08 PHP impl: 4 tests: mismatches = 00000000
PASS: C.1 $09 ORA #: 4 tests: mismatches = 00000000
PASS: C.1 $0a ASL A: 4 tests: mismatches = 00000000
PASS: C.1 $0b nop? 0B: 4 tests: mismatches = 00000000
PASS: C.1 $0c TSB abs: 4 tests: mismatches = 00000000
PASS: C.1 $0d ORA abs: 4 tests: mismatches = 00000000
PASS: C.1 $0e ASL abs: 4 tests: mismatches = 00000000
PASS: C.1 $0f BBR0 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $10 BPL rel: 6 tests (3 by decision): mismatches = 00000000
PASS: C.1 $11 ORA (zp),Y: 6 tests (3 by decision): mismatches = 00000000
PASS: C.1 $12 ORA (zp): 4 tests: mismatches = 00000000
PASS: C.1 $13 nop? 13: 4 tests: mismatches = 00000000
PASS: C.1 $14 TRB zp: 4 tests: mismatches = 00000000
PASS: C.1 $15 ORA zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $16 ASL zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $17 RMB1 zp: 4 tests: mismatches = 00000000
PASS: C.1 $18 CLC impl: 4 tests: mismatches = 00000000
PASS: C.1 $19 ORA abs,Y: 6 tests: mismatches = 00000000
PASS: C.1 $1a INC A: 4 tests: mismatches = 00000000
PASS: C.1 $1b nop? 1B: 4 tests: mismatches = 00000000
PASS: C.1 $1c TRB abs: 4 tests: mismatches = 00000000
PASS: C.1 $1d ORA abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $1e ASL abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $1f BBR1 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $20 JSR abs: 4 tests: mismatches = 00000000
PASS: C.1 $21 AND (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $22 nop? 22: 4 tests: mismatches = 00000000
PASS: C.1 $23 nop? 23: 4 tests: mismatches = 00000000
PASS: C.1 $24 BIT zp: 4 tests: mismatches = 00000000
PASS: C.1 $25 AND zp: 4 tests: mismatches = 00000000
PASS: C.1 $26 ROL zp: 4 tests: mismatches = 00000000
PASS: C.1 $27 RMB2 zp: 4 tests: mismatches = 00000000
PASS: C.1 $28 PLP impl: 4 tests: mismatches = 00000000
PASS: C.1 $29 AND #: 4 tests: mismatches = 00000000
PASS: C.1 $2a ROL A: 4 tests: mismatches = 00000000
PASS: C.1 $2b nop? 2B: 4 tests: mismatches = 00000000
PASS: C.1 $2c BIT abs: 4 tests: mismatches = 00000000
PASS: C.1 $2d AND abs: 4 tests: mismatches = 00000000
PASS: C.1 $2e ROL abs: 4 tests: mismatches = 00000000
PASS: C.1 $2f BBR2 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $30 BMI rel: 6 tests: mismatches = 00000000
PASS: C.1 $31 AND (zp),Y: 6 tests (3 by decision): mismatches = 00000000
PASS: C.1 $32 AND (zp): 4 tests: mismatches = 00000000
PASS: C.1 $33 nop? 33: 4 tests: mismatches = 00000000
PASS: C.1 $34 BIT zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $35 AND zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $36 ROL zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $37 RMB3 zp: 4 tests: mismatches = 00000000
PASS: C.1 $38 SEC impl: 4 tests: mismatches = 00000000
PASS: C.1 $39 AND abs,Y: 6 tests: mismatches = 00000000
PASS: C.1 $3a DEC A: 4 tests: mismatches = 00000000
PASS: C.1 $3b nop? 3B: 4 tests: mismatches = 00000000
PASS: C.1 $3c BIT abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $3d AND abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $3e ROL abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $3f BBR3 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $40 RTI impl: 4 tests: mismatches = 00000000
PASS: C.1 $41 EOR (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $42 nop? 42: 4 tests: mismatches = 00000000
PASS: C.1 $43 nop? 43: 4 tests: mismatches = 00000000
PASS: C.1 $44 nop? 44: 4 tests: mismatches = 00000000
PASS: C.1 $45 EOR zp: 4 tests: mismatches = 00000000
PASS: C.1 $46 LSR zp: 4 tests: mismatches = 00000000
PASS: C.1 $47 RMB4 zp: 4 tests: mismatches = 00000000
PASS: C.1 $48 PHA impl: 4 tests: mismatches = 00000000
PASS: C.1 $49 EOR #: 4 tests: mismatches = 00000000
PASS: C.1 $4a LSR A: 4 tests: mismatches = 00000000
PASS: C.1 $4b nop? 4B: 4 tests: mismatches = 00000000
PASS: C.1 $4c JMP abs: 4 tests: mismatches = 00000000
PASS: C.1 $4d EOR abs: 4 tests: mismatches = 00000000
PASS: C.1 $4e LSR abs: 4 tests: mismatches = 00000000
PASS: C.1 $4f BBR4 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $50 BVC rel: 6 tests (1 by decision): mismatches = 00000000
PASS: C.1 $51 EOR (zp),Y: 6 tests (4 by decision): mismatches = 00000000
PASS: C.1 $52 EOR (zp): 4 tests: mismatches = 00000000
PASS: C.1 $53 nop? 53: 4 tests: mismatches = 00000000
PASS: C.1 $54 nop? 54: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $55 EOR zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $56 LSR zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $57 RMB5 zp: 4 tests: mismatches = 00000000
PASS: C.1 $58 CLI impl: 4 tests: mismatches = 00000000
PASS: C.1 $59 EOR abs,Y: 6 tests: mismatches = 00000000
PASS: C.1 $5a PHY impl: 4 tests: mismatches = 00000000
PASS: C.1 $5b nop? 5B: 4 tests: mismatches = 00000000
PASS: C.1 $5c nop? 5C: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $5d EOR abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $5e LSR abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $5f BBR5 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $60 RTS impl: 4 tests: mismatches = 00000000
PASS: C.1 $61 ADC (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $62 nop? 62: 4 tests: mismatches = 00000000
PASS: C.1 $63 nop? 63: 4 tests: mismatches = 00000000
PASS: C.1 $64 STZ zp: 4 tests: mismatches = 00000000
PASS: C.1 $65 ADC zp: 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $66 ROR zp: 4 tests: mismatches = 00000000
PASS: C.1 $67 RMB6 zp: 4 tests: mismatches = 00000000
PASS: C.1 $68 PLA impl: 4 tests: mismatches = 00000000
PASS: C.1 $69 ADC #: 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $6a ROR A: 4 tests: mismatches = 00000000
PASS: C.1 $6b nop? 6B: 4 tests: mismatches = 00000000
PASS: C.1 $6c JMP (abs): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $6d ADC abs: 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $6e ROR abs: 4 tests: mismatches = 00000000
PASS: C.1 $6f BBR6 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $70 BVS rel: 6 tests: mismatches = 00000000
PASS: C.1 $71 ADC (zp),Y: 6 tests (4 by decision): mismatches = 00000000
PASS: C.1 $72 ADC (zp): 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $73 nop? 73: 4 tests: mismatches = 00000000
PASS: C.1 $74 STZ zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $75 ADC zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $76 ROR zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $77 RMB7 zp: 4 tests: mismatches = 00000000
PASS: C.1 $78 SEI impl: 4 tests: mismatches = 00000000
PASS: C.1 $79 ADC abs,Y: 6 tests (2 by decision): mismatches = 00000000
PASS: C.1 $7a PLY impl: 4 tests: mismatches = 00000000
PASS: C.1 $7b nop? 7B: 4 tests: mismatches = 00000000
PASS: C.1 $7c JMP (abs,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $7d ADC abs,X: 6 tests (3 by decision): mismatches = 00000000
PASS: C.1 $7e ROR abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $7f BBR7 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $80 BRA rel: 6 tests (2 by decision): mismatches = 00000000
PASS: C.1 $81 STA (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $82 nop? 82: 4 tests: mismatches = 00000000
PASS: C.1 $83 nop? 83: 4 tests: mismatches = 00000000
PASS: C.1 $84 STY zp: 4 tests: mismatches = 00000000
PASS: C.1 $85 STA zp: 4 tests: mismatches = 00000000
PASS: C.1 $86 STX zp: 4 tests: mismatches = 00000000
PASS: C.1 $87 SMB0 zp: 4 tests: mismatches = 00000000
PASS: C.1 $88 DEY impl: 4 tests: mismatches = 00000000
PASS: C.1 $89 BIT #: 4 tests: mismatches = 00000000
PASS: C.1 $8a TXA impl: 4 tests: mismatches = 00000000
PASS: C.1 $8b nop? 8B: 4 tests: mismatches = 00000000
PASS: C.1 $8c STY abs: 4 tests: mismatches = 00000000
PASS: C.1 $8d STA abs: 4 tests: mismatches = 00000000
PASS: C.1 $8e STX abs: 4 tests: mismatches = 00000000
PASS: C.1 $8f BBS0 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $90 BCC rel: 6 tests (1 by decision): mismatches = 00000000
PASS: C.1 $91 STA (zp),Y: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $92 STA (zp): 4 tests: mismatches = 00000000
PASS: C.1 $93 nop? 93: 4 tests: mismatches = 00000000
PASS: C.1 $94 STY zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $95 STA zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $96 STX zp,Y: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $97 SMB1 zp: 4 tests: mismatches = 00000000
PASS: C.1 $98 TYA impl: 4 tests: mismatches = 00000000
PASS: C.1 $99 STA abs,Y: 4 tests: mismatches = 00000000
PASS: C.1 $9a TXS impl: 4 tests: mismatches = 00000000
PASS: C.1 $9b nop? 9B: 4 tests: mismatches = 00000000
PASS: C.1 $9c STZ abs: 4 tests: mismatches = 00000000
PASS: C.1 $9d STA abs,X: 4 tests (3 by decision): mismatches = 00000000
PASS: C.1 $9e STZ abs,X: 4 tests (3 by decision): mismatches = 00000000
PASS: C.1 $9f BBS1 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $a0 LDY #: 4 tests: mismatches = 00000000
PASS: C.1 $a1 LDA (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $a2 LDX #: 4 tests: mismatches = 00000000
PASS: C.1 $a3 nop? A3: 4 tests: mismatches = 00000000
PASS: C.1 $a4 LDY zp: 4 tests: mismatches = 00000000
PASS: C.1 $a5 LDA zp: 4 tests: mismatches = 00000000
PASS: C.1 $a6 LDX zp: 4 tests: mismatches = 00000000
PASS: C.1 $a7 SMB2 zp: 4 tests: mismatches = 00000000
PASS: C.1 $a8 TAY impl: 4 tests: mismatches = 00000000
PASS: C.1 $a9 LDA #: 4 tests: mismatches = 00000000
PASS: C.1 $aa TAX impl: 4 tests: mismatches = 00000000
PASS: C.1 $ab nop? AB: 4 tests: mismatches = 00000000
PASS: C.1 $ac LDY abs: 4 tests: mismatches = 00000000
PASS: C.1 $ad LDA abs: 4 tests: mismatches = 00000000
PASS: C.1 $ae LDX abs: 4 tests: mismatches = 00000000
PASS: C.1 $af BBS2 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $b0 BCS rel: 6 tests: mismatches = 00000000
PASS: C.1 $b1 LDA (zp),Y: 6 tests (4 by decision): mismatches = 00000000
PASS: C.1 $b2 LDA (zp): 4 tests: mismatches = 00000000
PASS: C.1 $b3 nop? B3: 4 tests: mismatches = 00000000
PASS: C.1 $b4 LDY zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $b5 LDA zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $b6 LDX zp,Y: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $b7 SMB3 zp: 4 tests: mismatches = 00000000
PASS: C.1 $b8 CLV impl: 4 tests: mismatches = 00000000
PASS: C.1 $b9 LDA abs,Y: 6 tests: mismatches = 00000000
PASS: C.1 $ba TSX impl: 4 tests: mismatches = 00000000
PASS: C.1 $bb nop? BB: 4 tests: mismatches = 00000000
PASS: C.1 $bc LDY abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $bd LDA abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $be LDX abs,Y: 6 tests: mismatches = 00000000
PASS: C.1 $bf BBS3 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $c0 CPY #: 4 tests: mismatches = 00000000
PASS: C.1 $c1 CMP (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $c2 nop? C2: 4 tests: mismatches = 00000000
PASS: C.1 $c3 nop? C3: 4 tests: mismatches = 00000000
PASS: C.1 $c4 CPY zp: 4 tests: mismatches = 00000000
PASS: C.1 $c5 CMP zp: 4 tests: mismatches = 00000000
PASS: C.1 $c6 DEC zp: 4 tests: mismatches = 00000000
PASS: C.1 $c7 SMB4 zp: 4 tests: mismatches = 00000000
PASS: C.1 $c8 INY impl: 4 tests: mismatches = 00000000
PASS: C.1 $c9 CMP #: 4 tests: mismatches = 00000000
PASS: C.1 $ca DEX impl: 4 tests: mismatches = 00000000
PASS: C.1 $cb nop? CB: 4 tests: mismatches = 00000000
PASS: C.1 $cc CPY abs: 4 tests: mismatches = 00000000
PASS: C.1 $cd CMP abs: 4 tests: mismatches = 00000000
PASS: C.1 $ce DEC abs: 4 tests: mismatches = 00000000
PASS: C.1 $cf BBS4 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $d0 BNE rel: 6 tests (1 by decision): mismatches = 00000000
PASS: C.1 $d1 CMP (zp),Y: 6 tests (4 by decision): mismatches = 00000000
PASS: C.1 $d2 CMP (zp): 4 tests: mismatches = 00000000
PASS: C.1 $d3 nop? D3: 4 tests: mismatches = 00000000
PASS: C.1 $d4 nop? D4: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $d5 CMP zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $d6 DEC zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $d7 SMB5 zp: 4 tests: mismatches = 00000000
PASS: C.1 $d8 CLD impl: 4 tests: mismatches = 00000000
PASS: C.1 $d9 CMP abs,Y: 6 tests: mismatches = 00000000
PASS: C.1 $da PHX impl: 4 tests: mismatches = 00000000
PASS: C.1 $db nop? DB: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $dc nop? DC: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $dd CMP abs,X: 6 tests: mismatches = 00000000
PASS: C.1 $de DEC abs,X: 4 tests (3 by decision): mismatches = 00000000
PASS: C.1 $df BBS5 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $e0 CPX #: 4 tests: mismatches = 00000000
PASS: C.1 $e1 SBC (zp,X): 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $e2 nop? E2: 4 tests: mismatches = 00000000
PASS: C.1 $e3 nop? E3: 4 tests: mismatches = 00000000
PASS: C.1 $e4 CPX zp: 4 tests: mismatches = 00000000
PASS: C.1 $e5 SBC zp: 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $e6 INC zp: 4 tests: mismatches = 00000000
PASS: C.1 $e7 SMB6 zp: 4 tests: mismatches = 00000000
PASS: C.1 $e8 INX impl: 4 tests: mismatches = 00000000
PASS: C.1 $e9 SBC #: 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $ea NOP impl: 4 tests: mismatches = 00000000
PASS: C.1 $eb nop? EB: 4 tests: mismatches = 00000000
PASS: C.1 $ec CPX abs: 4 tests: mismatches = 00000000
PASS: C.1 $ed SBC abs: 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $ee INC abs: 4 tests: mismatches = 00000000
PASS: C.1 $ef BBS6 zp,rel: 6 tests: mismatches = 00000000
PASS: C.1 $f0 BEQ rel: 6 tests (2 by decision): mismatches = 00000000
PASS: C.1 $f1 SBC (zp),Y: 6 tests (5 by decision): mismatches = 00000000
PASS: C.1 $f2 SBC (zp): 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $f3 nop? F3: 4 tests: mismatches = 00000000
PASS: C.1 $f4 nop? F4: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $f5 SBC zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $f6 INC zp,X: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $f7 SMB7 zp: 4 tests: mismatches = 00000000
PASS: C.1 $f8 SED impl: 4 tests: mismatches = 00000000
PASS: C.1 $f9 SBC abs,Y: 6 tests (3 by decision): mismatches = 00000000
PASS: C.1 $fa PLX impl: 4 tests: mismatches = 00000000
PASS: C.1 $fb nop? FB: 4 tests: mismatches = 00000000
PASS: C.1 $fc nop? FC: 4 tests (4 by decision): mismatches = 00000000
PASS: C.1 $fd SBC abs,X: 6 tests (4 by decision): mismatches = 00000000
PASS: C.1 $fe INC abs,X: 4 tests (2 by decision): mismatches = 00000000
PASS: C.1 $ff BBS7 zp,rel: 6 tests: mismatches = 00000000

=== CPU SECTION C.2: Random Instruction Streams (CYCLE and HALF lockstep) ===

PASS: C.2 16 random streams (24000 cycles): cycles where uut and uuth pins differ or an output is X = 00000000
PASS: C.2 16 random streams: cycles where uut and uuth dbg_* differ = 00000000

=========================================================
 ALU SECTION D: Arithmetic and Logic
=========================================================

=== ALU SECTION D.1: Every Operation, Every Input ===

PASS: D.1 ORA: q = a OR b, N Z; V D I C kept (131072 inputs): mismatches = 00000000
PASS: D.1 AND: q = a AND b, N Z (131072 inputs): mismatches = 00000000
PASS: D.1 EOR: q = a XOR b, N Z (131072 inputs): mismatches = 00000000
PASS: D.1 ADC: binary and decimal, N V Z C (262144 inputs): mismatches = 00000000
PASS: D.1 SBC: binary and decimal, N V Z C (262144 inputs): mismatches = 00000000
PASS: D.1 CMP: C = a >= b, N Z of a - b, D ignored (262144 inputs): mismatches = 00000000
PASS: D.1 BIT: N = b7, V = b6, Z = (a AND b) = 0 (131072 inputs): mismatches = 00000000
PASS: D.1 ASL (512 inputs): mismatches = 00000000
PASS: D.1 ROL (512 inputs): mismatches = 00000000
PASS: D.1 LSR (512 inputs): mismatches = 00000000
PASS: D.1 ROR (512 inputs): mismatches = 00000000
PASS: D.1 INC (512 inputs): mismatches = 00000000
PASS: D.1 DEC (512 inputs): mismatches = 00000000
PASS: D.1 BIT #: Z = (a AND b) = 0 only (131072 inputs): mismatches = 00000000
PASS: D.1 TSB: q = a OR b, Z = (a AND b) = 0 only (131072 inputs): mismatches = 00000000
PASS: D.1 TRB: q = NOT a AND b, Z = (a AND b) = 0 only (131072 inputs): mismatches = 00000000
PASS: D.1 ADC D=1 99 + 01: 00, N V Z C = 0 0 1 1 (Z of the result) = 00000003
PASS: D.1 ADC D=1 80 + 80: 60, V = 1, Z = 0, C = 1 = 00000605
PASS: D.1 SBC D=1 00 - 01: 99, N = 1, C = 0 = 00000998
PASS: D.1 SBC D=1 00 - 0B (invalid BCD): 8F, N = 1, C = 0 = 000008f8

=== ALU SECTION D.2: Decimal Mode through the CPU, Every Input ===

PASS: D.2 ADC # with D = 1: cases run = 00020000
PASS: D.2 ADC # with D = 1: A and N V Z C mismatches = 00000000
PASS: D.2 SBC # with D = 1: cases run = 00020000
PASS: D.2 SBC # with D = 1: A and N V Z C mismatches = 00000000

=========================================================
 CPU SECTION E: R65C02 Bus and Instructions
=========================================================

=== CPU SECTION E.1: Read-Modify-Write, Two Reads and One Write ===

PASS: E.1 INC 1234 (41): 0400 0401 0402, reads 41 twice, writes 42 = 00000000
PASS: E.1 DEC 20 (0F): reads 0F twice, writes 0E = 00000000
PASS: E.1 ASL 1F,X (X = 1): PC+1 again, reads 0F twice at 0020, writes 1E = 00000000
PASS: E.1 ROR 1233,X (X = 1, C = 0, no page cross): 6 cycles, reads 41 twice, writes 20 = 00000000
PASS: E.1 TSB 1234 (A = 5A): reads 41 twice, writes 5B = 00000000
PASS: E.1 TRB 20 (A = 5A): reads 0F twice, writes 05 = 00000000
PASS: E.1 RMB3 20: reads 0F twice, writes 07 = 00000000
PASS: E.1 SMB5 20: reads 0F twice, writes 2F = 00000000

=== CPU SECTION E.2: Extra Cycles of Indexed Modes ===

PASS: E.2 LDA 12F0,X (X = 20, cross): 0402 again, then 1310 = 00000000
PASS: E.2 LDA 1230,X (X = 04, no cross): 4 cycles = 00000000
PASS: E.2 STA 1230,X (no cross): reads 1234, then writes it = 00000000
PASS: E.2 STA 1230,Y (no cross): reads 1234, then writes it = 00000000
PASS: E.2 STZ 1230,X (no cross): reads 1234, then writes 00 to it = 00000000
PASS: E.2 LDA (30),Y (Y = 20, cross): 0031 again, then 1310 = 00000000
PASS: E.2 STA (30),Y (Y = 04, no cross): 0031 again, write 12F4 = 00000000
PASS: E.2 DEC 1230,X (no cross): 7 cycles, 1234 read three times = 00000000
PASS: E.2 ASL 1230,X (no cross): 6 cycles = 00000000
PASS: E.2 ROL 1230,X (no cross, C = 0): 6 cycles = 00000000
PASS: E.2 LSR 1230,X (no cross): 6 cycles = 00000000
PASS: E.2 ROR 1230,X (no cross, C = 0): 6 cycles = 00000000
PASS: E.2 BIT 12F0,X (X = 20, cross): 0402 again, then 1310 = 00000000

=== CPU SECTION E.3: Decimal-Mode Cycle of ADC and SBC ===

PASS: E.3 ADC #19 (D = 1): 0400 0401 0402, A = 24 = 00000000
PASS: E.3 case 0: A = 24 = 00000024
PASS: E.3 ADC #19 (D = 0): 2 cycles, A = 1E = 00000000
PASS: E.3 case 1: A = 1e = 0000001e
PASS: E.3 SBC 20 (D = 1, 05 - 0F - 1, operand not BCD): then 0402, A = 8F = 00000000
PASS: E.3 case 2: A = 8f = 0000008f
PASS: E.3 ADC (30) (D = 1): 12F0, then 0402, A = 24 = 00000000
PASS: E.3 case 3: A = 24 = 00000024
PASS: E.3 ADC 12F0,X (X = 20, cross, D = 1): 1310, then 0403, A = 24 = 00000000
PASS: E.3 case 4: A = 24 = 00000024
PASS: E.3 SBC (30,X) (X = 0, D = 1, 05 - 19 - 1): PC+1 again, 12F0, then 0402, A = 85 = 00000000
PASS: E.3 case 5: A = 85 = 00000085
PASS: E.3 SBC (30),Y (Y = 20, cross, D = 1): 0031 again, 1310, then 0402 = 00000000
PASS: E.3 case 6: A = 85 = 00000085

=== CPU SECTION E.4: JMP (abs) and JMP (abs,X) ===

PASS: E.4 JMP (12FF): 0402 again, 12FF, 1300; fetch 0534 = 00000000
PASS: E.4 JMP (1230,X) (X = 4): 0402 again, 1234, 1235; fetch 0600 = 00000000
PASS: E.4 JMP (12FE,X) (X = 1): 12FF, then 1300 (carried); fetch 0534 = 00000000

=== CPU SECTION E.5: BBR, BBS and BRA ===

PASS: E.5 BBR0 20 (bit 0 = 1): not taken, 5 cycles, fetch 0403 = 00000000
PASS: E.5 BBS0 20 (bit 0 = 1): taken, 6 cycles, fetch 0413 = 00000000
PASS: E.5 BBS7 20 (bit 7 = 0): not taken, 5 cycles, fetch 04F3 = 00000000
PASS: E.5 BBR7 20 (bit 7 = 0): taken across a page, PC+3 twice, fetch 0513 = 00000000
PASS: E.5 BRA +10: 3 cycles, fetch 0412 = 00000000
PASS: E.5 BRA +20 across a page: 04F2 twice; fetch 0512 = 00000000

=== CPU SECTION E.6: Undefined Op Codes ===

PASS: E.6 46 undefined op codes: bytes, cycles, bus and unchanged state: failing op codes = 00000000

=== CPU SECTION E.7: BIT #, TSB, TRB, RMB, SMB and STZ ===

PASS: E.7 BIT #F0 with A = 0F, N = V = 1 before: Z = 1, N and V unchanged = 000000f6
PASS: E.7 BIT #0F with A = 0F: Z = 0, N and V unchanged = 000000f4
PASS: E.7 TSB 1234 (41) with A = A0: Z = 1 (A AND M = 0), writes E1, V C kept = 000073e1
PASS: E.7 TRB 20 (0F) with A = 0F: Z = 0 (A AND M = 0F), writes 00, V C kept = 00007100
PASS: E.7 RMB0 20 (0F): writes 0E, no flag changed (Z stays 1) = 0000730e
PASS: E.7 SMB7 20 (0F): writes 8F, no flag changed (N stays 0) = 0000738f
PASS: E.7 STZ 20 writes 00 = 00000000
PASS: E.7 STZ 1F,X (X = 1) writes 00 to 0020 = 00000000
PASS: E.7 STZ 1234 writes 00 = 00000000

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

=== INT SECTION F.4: Entry Sequence, B Bit, Pushed P and D Cleared ===

PASS: F.4 BRK with P = C3: reads 0401, pushes PC+2 = 0402 and P OR 30 = F3, vector FFFE = 00000001
PASS: F.4 BRK: dbg_p at the handler fetch = C3 with I = 1 = 000000f7
PASS: F.4 uuth dbg_ir and dbg_p equal uut at the handler fetch = 00000001
PASS: F.4 BRK with D = 1: pushes 38 (D as it was) = 00000001
PASS: F.4 BRK with D = 1: D = 0 and I = 1 in the handler = 00000034
PASS: F.4 uuth dbg_ir and dbg_p equal uut at the handler fetch = 00000001
PASS: F.4 IRQ with P = C3: pushes E3 (bit 4 = 0, bit 5 = 1) = 00000001
PASS: F.4 uuth dbg_ir and dbg_p equal uut at the handler fetch = 00000001
PASS: F.4 NMI with P = C7 (I = 1): pushes E7, vector FFFA = 00000001
PASS: F.4 uuth dbg_ir and dbg_p equal uut at the handler fetch = 00000001
PASS: F.4 IRQ with D = 1: pushes 2B = 00000001
PASS: F.4 IRQ with D = 1: D = 0 and I = 1 in the handler = 00000037
PASS: F.4 uuth dbg_ir and dbg_p equal uut at the handler fetch = 00000001
PASS: F.4 NMI with D = 1: pushes 2C = 00000001
PASS: F.4 NMI with D = 1: D = 0 and I = 1 in the handler = 00000034
PASS: F.4 uuth dbg_ir and dbg_p equal uut at the handler fetch = 00000001

=== INT SECTION F.5: No Takeover of BRK or an Entry ===

PASS: F.5 NMI falling in phi1 of BRK cycle 4: BRK completes (FFFE, B = 1), handler NOP, NMI at 0701 = 00000001
PASS: F.5 NMI falling in phi2 of BRK cycle 4: BRK completes, handler NOP, NMI at 0701 = 00000001
PASS: F.5 NMI falling in BRK cycle 5: BRK completes, handler NOP, NMI at 0701 = 00000001
PASS: F.5 NMI falling in IRQ entry cycle 4: IRQ entry completes (FFFE), handler NOP, NMI at 0701 = 00000001
PASS: F.5 IRQ and NMI together: NMI vector, B = 0 = 00000001
PASS: F.5 NMI low only at the edges of BRK cycles 6 and 7: latched, taken at 0701 after the NOP = 00000001

=== INT SECTION F.6: NMI Edge Latch and NMI across RES ===

PASS: F.6 NMI held low for 40 cycles: one NMI entry = 00000001
PASS: F.6 NMI high at one edge, then low: a second NMI entry = 00000001
PASS: F.6 second NMI edge inside the NMI entry (before its second vector read): merged, one entry = 00000001
PASS: F.6 NMI falling while RES is low and held: absorbed by the reset, never taken = 00000001
PASS: F.6 NMI first low at the start of the third stack read of the reset sequence: absorbed = 00000000
PASS: F.6 NMI first low at the FFFC read: taken after the reset handler's first NOP (entry at 0501) = 00000001

=== INT SECTION F.7: Poll Point of Every Instruction Kind ===

PASS: F.7 NOP (2 cycles, last poll at the start of cycle 2): mismatches = 00000000
PASS: F.7 LDA # (2 cycles, last poll at the start of cycle 2): mismatches = 00000000
PASS: F.7 LDA abs (4 cycles, last poll at the start of cycle 4): mismatches = 00000000
PASS: F.7 STA abs (4 cycles, last poll at the start of cycle 4): mismatches = 00000000
PASS: F.7 INC abs (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 INC abs,X (7 cycles, last poll at the start of cycle 7): mismatches = 00000000
PASS: F.7 ASL abs,X (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 ADC # (D = 1) (3 cycles, last poll at the start of cycle 3): mismatches = 00000000
PASS: F.7 ADC abs (D = 1) (5 cycles, last poll at the start of cycle 5): mismatches = 00000000
PASS: F.7 LDA (zp),Y cross (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 STA (zp),Y (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 JMP abs (3 cycles, last poll at the start of cycle 3): mismatches = 00000000
PASS: F.7 JMP (abs) (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 JMP (abs,X) (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 BNE taken (3 cycles, last poll at the start of cycle 2): mismatches = 00000000
PASS: F.7 BNE taken, page cross (4 cycles, last poll at the start of cycle 4): mismatches = 00000000
PASS: F.7 BRA (3 cycles, last poll at the start of cycle 2): mismatches = 00000000
PASS: F.7 BBS0 taken (6 cycles, last poll at the start of cycle 5): mismatches = 00000000
PASS: F.7 BBR0 not taken (5 cycles, last poll at the start of cycle 5): mismatches = 00000000
PASS: F.7 JSR (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 RTS (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 RTI (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 PHA (3 cycles, last poll at the start of cycle 3): mismatches = 00000000
PASS: F.7 PLA (4 cycles, last poll at the start of cycle 4): mismatches = 00000000
PASS: F.7 BRK (7 cycles, last poll at the start of cycle 7): mismatches = 00000000
PASS: F.7 NOP 03 (1 cycle) (1 cycles, last poll at the start of cycle 1): mismatches = 00000000
PASS: F.7 TSB abs (6 cycles, last poll at the start of cycle 6): mismatches = 00000000
PASS: F.7 RMB3 zp (5 cycles, last poll at the start of cycle 5): mismatches = 00000000
PASS: F.7 PHX (3 cycles, last poll at the start of cycle 3): mismatches = 00000000
PASS: F.7 PLY (4 cycles, last poll at the start of cycle 4): mismatches = 00000000

=== INT SECTION F.8: 1-cycle NOP Poll ===

PASS: F.8 IRQ first low at the start of the 1-cycle NOP: entry replaces the fetch right after it (0402) = 00000001

=========================================================
 BUS SECTION G: RDY
=========================================================

=== BUS SECTION G.1: Held Reads and Held Writes ===

PASS: G.1 LDA 1234 held two cycles: cycle 4 repeats at 1234, next fetch at cycle 7 = 00000001
PASS: G.1 LDA held: A = the byte of the last repeat (33) = 00000033
PASS: G.1 LDA held: A = 33 (uuth) = 00000033
PASS: G.1 STA, RDY low at the end of its write cycle for two edges: the write of 5A to 1234 repeats twice = 00000001
PASS: G.1 STA held: dout_oe = 1 through the held write (uut); phi2 only in each repeat (uuth) = 00000001
PASS: G.1 JSR, RDY low across two edges of its first push: 01FF written three times, fetch at 0500 in cycle 9 = 00000001
PASS: G.1 opcode fetch held two edges: repeats at 0400 with SYNC = 1 [p.1-6] = 00000001

=== BUS SECTION G.2: Held Dummy Reads Repeat Their Own Address ===

PASS: G.2 LDA 12F0,X (X = 20) held at the dummy read of 0402: repeats read 0402, then 1310 = 00000001
PASS: G.2 BNE forward across a page held at the fixup (04F2 again): repeats read 04F2 = 00000001
PASS: G.2 BNE backward across a page held at the fixup (0504 again): repeats read 0504 = 00000001

=== BUS SECTION G.3: Interrupts Only with RDY High ===

PASS: G.3 IRQ low only at the edge of a held repeat of LDA's last cycle: not recognized [p.1-4] = 00000000
PASS: G.3 IRQ low only during a hold of cycle 3: not recognized = 00000001
PASS: G.3 NMI falling and rising during a hold of cycle 3: latched, taken after LDA = 00000001
PASS: G.3 IRQ low through a hold of cycle 3: recognized when RDY is high at the edge into cycle 4 = 00000001

=== BUS SECTION G.4: Every Cycle of Every Instruction Kind Held ===

PASS: G.4 NOP: 2 cycles held 1 and 2 edges (4 runs): mismatches = 00000000
PASS: G.4 LDA #: 2 cycles held 1 and 2 edges (4 runs): mismatches = 00000000
PASS: G.4 LDA abs: 4 cycles held 1 and 2 edges (8 runs): mismatches = 00000000
PASS: G.4 STA abs: 4 cycles held 1 and 2 edges (8 runs): mismatches = 00000000
PASS: G.4 INC abs: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 INC abs,X: 7 cycles held 1 and 2 edges (14 runs): mismatches = 00000000
PASS: G.4 ASL abs,X: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 ADC # (D = 1): 3 cycles held 1 and 2 edges (6 runs): mismatches = 00000000
PASS: G.4 ADC abs (D = 1): 5 cycles held 1 and 2 edges (10 runs): mismatches = 00000000
PASS: G.4 LDA (zp),Y cross: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 STA (zp),Y: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 JMP abs: 3 cycles held 1 and 2 edges (6 runs): mismatches = 00000000
PASS: G.4 JMP (abs): 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 JMP (abs,X): 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 BNE taken: 3 cycles held 1 and 2 edges (6 runs): mismatches = 00000000
PASS: G.4 BNE taken, page cross: 4 cycles held 1 and 2 edges (8 runs): mismatches = 00000000
PASS: G.4 BRA: 3 cycles held 1 and 2 edges (6 runs): mismatches = 00000000
PASS: G.4 BBS0 taken: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 BBR0 not taken: 5 cycles held 1 and 2 edges (10 runs): mismatches = 00000000
PASS: G.4 JSR: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 RTS: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 RTI: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 PHA: 3 cycles held 1 and 2 edges (6 runs): mismatches = 00000000
PASS: G.4 PLA: 4 cycles held 1 and 2 edges (8 runs): mismatches = 00000000
PASS: G.4 BRK: 7 cycles held 1 and 2 edges (14 runs): mismatches = 00000000
PASS: G.4 NOP 03 (1 cycle): 1 cycles held 1 and 2 edges (2 runs): mismatches = 00000000
PASS: G.4 TSB abs: 6 cycles held 1 and 2 edges (12 runs): mismatches = 00000000
PASS: G.4 RMB3 zp: 5 cycles held 1 and 2 edges (10 runs): mismatches = 00000000
PASS: G.4 PHX: 3 cycles held 1 and 2 edges (6 runs): mismatches = 00000000
PASS: G.4 PLY: 4 cycles held 1 and 2 edges (8 runs): mismatches = 00000000

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

=== CPU SECTION H.5: SO before BVS ===

PASS: H.5 SO set at the edge that starts BVS cycle 2: taken, fetch 0405 = 00000001
PASS: H.5 SO falling in BVS cycle 2: not taken, fetch 0403 = 00000001

=== CPU SECTION H.6: CLV with the Next Fetch Held ===

PASS: H.6 CLV, next fetch held two edges, SO falling in the first repeat: lost, V = 0 = 00000000
PASS: H.6 CLV, next fetch not held, SO falling one cycle after it: V = 1 (control) = 00000003

=========================================================
 BUS SECTION J: SYNC and vp_n
=========================================================

=== BUS SECTION J.1: SYNC on Opcode Fetches Only ===

PASS: J.1 LDA STA INC PHA PLA JSR RTS: 7 SYNC cycles in 33 cycles = 00000007
PASS: J.1 cycle count 4 + 4 + 6 + 3 + 4 + 6 + 6 = 00000021
PASS: J.1 SYNC never in a write cycle = 00000000
PASS: J.1 three 1-cycle NOPs: SYNC on four consecutive cycles 0400-0403 = 00000001

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

PASS: K.1 instruction vectors at ratio 1 (CYCLE mode only): 565 tests, failing = 00000000
PASS: K.1 instruction vectors at ratio 2: 565 tests, failing = 00000000
PASS: K.1 instruction vectors at ratio 3: 565 tests, failing = 00000000
PASS: K.1 instruction vectors at ratio 5: 565 tests, failing = 00000000
PASS: K.1 instruction vectors at ratio 16: 283 tests, failing = 00000000
PASS: K.1 one-edge RES at cycle 4 of every third sweep instruction, ratio 2: mismatches = 00000000
PASS: K.1 one-edge RES at cycle 4 of every third sweep instruction, ratio 5: mismatches = 00000000

=== CLK SECTION K.2: Random Stops between Enables ===

PASS: K.2 instruction vectors, ratio 3 with stops: 377 tests, failing = 00000000
PASS: K.2 IRQ entry with random stops: replaces the fetch at 0401 = 00000001

=== CLK SECTION K.3: Lockstep and Output Timing ===

PASS: K.3 CYCLE/HALF lockstep over every vector run in both modes (3485 runs, 13689 cycles) = 00000000
PASS: K.3 uut outputs changed only at cen edges: violations = 00000000
PASS: K.3 uuth outputs changed only at cen and cen_p2 edges: violations = 00000000
PASS: K.3 uut outputs never X (cen_p2 unconnected): clk edges with an X = 00000000
PASS: K.3 uuth outputs never X: clk edges with an X = 00000000

=============================================================
  x65c02 Test Results
=============================================================
  Total Tests:  687
  Passed:       687
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
  Cycle-accurate to the Rockwell R65C02 datasheet and R65C02P2 bus recordings
=============================================================
```
