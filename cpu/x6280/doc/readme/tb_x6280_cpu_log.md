# x6280 CPU Regression Log

Full output of the `tb_x6280_cpu` testbench (466 tests). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  x6280 CPU Testbench
  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware and
             Software Manuals (Hudson Soft)
=============================================================

=============================================================
 CPU SECTION A: Reset
=============================================================

=== CPU SECTION A.1: Power-up Values and the Power-up Reset Sequence ===

PASS: power-up P (I and bit 4 set, T and D clear) = 0000000000000014
PASS: power-up S = 0000000000000000
PASS: power-up A, X, Y = 0000000000000000
PASS: power-up MPR7-MPR0 = 0000000000ffffff
PASS: power-up MPR3-MPR0 = 00000000ffffffff
PASS: power-up speed (low) = 0000000000000000
PASS: power-up runs the reset sequence to the vector at FFFE

=== CPU SECTION A.2: First Reset: Bus Sequence, Vector FFFE, S - 3, MPRs ===

PASS: reset reaches the fetch at E000
PASS: reset vector reads have vp_n high
PASS: vector low read at FFFE (physical 001FFE)
PASS: vector high read at FFFF
PASS: then one internal cycle at FFFF
PASS: then the fetch at E000
PASS: three stack reads before the vector
PASS: no write in the reset sequence = 0000000000000000
PASS: S after reset (S - 3) = 00000000000000fa
PASS: P after reset: I set, D and T clear = 0000000000000004
PASS: MPR7-MPR4 after reset = 0000000000ffffff
PASS: MPR3-MPR0 after reset = 00000000ffffffff

=== CPU SECTION A.3: Warm Reset Keeps A, X, Y; Clears D, T and the Speed; Sets I; MPRs ===

PASS: program reaches the loop
PASS: speed before reset (CSH) = 0000000000000001
PASS: warm reset reaches E000
PASS: A, X, Y kept = 0000000000036677
PASS: P: I set, D clear, T clear = 0000000000000004
PASS: speed low after reset = 0000000000000000
PASS: MPRs after reset = 00ffffffffffffff
PASS: S after warm reset (S - 3) = 00000000000000fc

=== CPU SECTION A.4: Bus while RES Is Low ===

PASS: address held with R/W high while RES is low
PASS: no write while RES is low = 0000000000000000
PASS: restart after RES high

=== CPU SECTION A.5: RES Sampled at cen Only ===

PASS: a RES pulse between enables is not seen

=============================================================
 BUS SECTION B: Every Opcode
=============================================================

=== BUS SECTION B.1: Instruction Vectors, Every Opcode Cycle by Cycle ===

PASS: vector file loaded
PASS: op 00: 40 records, every cycle, final registers, MPRs and memory
PASS: op 01: 64 records, every cycle, final registers, MPRs and memory
PASS: op 02: 40 records, every cycle, final registers, MPRs and memory
PASS: op 03: 40 records, every cycle, final registers, MPRs and memory
PASS: op 04: 40 records, every cycle, final registers, MPRs and memory
PASS: op 05: 64 records, every cycle, final registers, MPRs and memory
PASS: op 06: 40 records, every cycle, final registers, MPRs and memory
PASS: op 07: 40 records, every cycle, final registers, MPRs and memory
PASS: op 08: 40 records, every cycle, final registers, MPRs and memory
PASS: op 09: 64 records, every cycle, final registers, MPRs and memory
PASS: op 0a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 0b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 0c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 0d: 64 records, every cycle, final registers, MPRs and memory
PASS: op 0e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 0f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 10: 40 records, every cycle, final registers, MPRs and memory
PASS: op 11: 64 records, every cycle, final registers, MPRs and memory
PASS: op 12: 64 records, every cycle, final registers, MPRs and memory
PASS: op 13: 40 records, every cycle, final registers, MPRs and memory
PASS: op 14: 40 records, every cycle, final registers, MPRs and memory
PASS: op 15: 64 records, every cycle, final registers, MPRs and memory
PASS: op 16: 40 records, every cycle, final registers, MPRs and memory
PASS: op 17: 40 records, every cycle, final registers, MPRs and memory
PASS: op 18: 40 records, every cycle, final registers, MPRs and memory
PASS: op 19: 64 records, every cycle, final registers, MPRs and memory
PASS: op 1a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 1b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 1c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 1d: 64 records, every cycle, final registers, MPRs and memory
PASS: op 1e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 1f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 20: 40 records, every cycle, final registers, MPRs and memory
PASS: op 21: 64 records, every cycle, final registers, MPRs and memory
PASS: op 22: 40 records, every cycle, final registers, MPRs and memory
PASS: op 23: 40 records, every cycle, final registers, MPRs and memory
PASS: op 24: 40 records, every cycle, final registers, MPRs and memory
PASS: op 25: 64 records, every cycle, final registers, MPRs and memory
PASS: op 26: 40 records, every cycle, final registers, MPRs and memory
PASS: op 27: 40 records, every cycle, final registers, MPRs and memory
PASS: op 28: 40 records, every cycle, final registers, MPRs and memory
PASS: op 29: 64 records, every cycle, final registers, MPRs and memory
PASS: op 2a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 2b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 2c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 2d: 64 records, every cycle, final registers, MPRs and memory
PASS: op 2e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 2f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 30: 40 records, every cycle, final registers, MPRs and memory
PASS: op 31: 64 records, every cycle, final registers, MPRs and memory
PASS: op 32: 64 records, every cycle, final registers, MPRs and memory
PASS: op 33: 40 records, every cycle, final registers, MPRs and memory
PASS: op 34: 40 records, every cycle, final registers, MPRs and memory
PASS: op 35: 64 records, every cycle, final registers, MPRs and memory
PASS: op 36: 40 records, every cycle, final registers, MPRs and memory
PASS: op 37: 40 records, every cycle, final registers, MPRs and memory
PASS: op 38: 40 records, every cycle, final registers, MPRs and memory
PASS: op 39: 64 records, every cycle, final registers, MPRs and memory
PASS: op 3a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 3b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 3c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 3d: 64 records, every cycle, final registers, MPRs and memory
PASS: op 3e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 3f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 40: 40 records, every cycle, final registers, MPRs and memory
PASS: op 41: 64 records, every cycle, final registers, MPRs and memory
PASS: op 42: 40 records, every cycle, final registers, MPRs and memory
PASS: op 43: 40 records, every cycle, final registers, MPRs and memory
PASS: op 44: 40 records, every cycle, final registers, MPRs and memory
PASS: op 45: 64 records, every cycle, final registers, MPRs and memory
PASS: op 46: 40 records, every cycle, final registers, MPRs and memory
PASS: op 47: 40 records, every cycle, final registers, MPRs and memory
PASS: op 48: 40 records, every cycle, final registers, MPRs and memory
PASS: op 49: 64 records, every cycle, final registers, MPRs and memory
PASS: op 4a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 4b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 4c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 4d: 64 records, every cycle, final registers, MPRs and memory
PASS: op 4e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 4f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 50: 40 records, every cycle, final registers, MPRs and memory
PASS: op 51: 64 records, every cycle, final registers, MPRs and memory
PASS: op 52: 64 records, every cycle, final registers, MPRs and memory
PASS: op 53: 40 records, every cycle, final registers, MPRs and memory
PASS: op 54: 40 records, every cycle, final registers, MPRs and memory
PASS: op 55: 64 records, every cycle, final registers, MPRs and memory
PASS: op 56: 40 records, every cycle, final registers, MPRs and memory
PASS: op 57: 40 records, every cycle, final registers, MPRs and memory
PASS: op 58: 40 records, every cycle, final registers, MPRs and memory
PASS: op 59: 64 records, every cycle, final registers, MPRs and memory
PASS: op 5a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 5b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 5c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 5d: 64 records, every cycle, final registers, MPRs and memory
PASS: op 5e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 5f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 60: 40 records, every cycle, final registers, MPRs and memory
PASS: op 61: 80 records, every cycle, final registers, MPRs and memory
PASS: op 62: 40 records, every cycle, final registers, MPRs and memory
PASS: op 63: 40 records, every cycle, final registers, MPRs and memory
PASS: op 64: 40 records, every cycle, final registers, MPRs and memory
PASS: op 65: 80 records, every cycle, final registers, MPRs and memory
PASS: op 66: 40 records, every cycle, final registers, MPRs and memory
PASS: op 67: 40 records, every cycle, final registers, MPRs and memory
PASS: op 68: 40 records, every cycle, final registers, MPRs and memory
PASS: op 69: 80 records, every cycle, final registers, MPRs and memory
PASS: op 6a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 6b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 6c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 6d: 80 records, every cycle, final registers, MPRs and memory
PASS: op 6e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 6f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 70: 40 records, every cycle, final registers, MPRs and memory
PASS: op 71: 80 records, every cycle, final registers, MPRs and memory
PASS: op 72: 80 records, every cycle, final registers, MPRs and memory
PASS: op 73: 40 records, every cycle, final registers, MPRs and memory
PASS: op 74: 40 records, every cycle, final registers, MPRs and memory
PASS: op 75: 80 records, every cycle, final registers, MPRs and memory
PASS: op 76: 40 records, every cycle, final registers, MPRs and memory
PASS: op 77: 40 records, every cycle, final registers, MPRs and memory
PASS: op 78: 40 records, every cycle, final registers, MPRs and memory
PASS: op 79: 80 records, every cycle, final registers, MPRs and memory
PASS: op 7a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 7b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 7c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 7d: 80 records, every cycle, final registers, MPRs and memory
PASS: op 7e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 7f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 80: 40 records, every cycle, final registers, MPRs and memory
PASS: op 81: 40 records, every cycle, final registers, MPRs and memory
PASS: op 82: 40 records, every cycle, final registers, MPRs and memory
PASS: op 83: 40 records, every cycle, final registers, MPRs and memory
PASS: op 84: 40 records, every cycle, final registers, MPRs and memory
PASS: op 85: 40 records, every cycle, final registers, MPRs and memory
PASS: op 86: 40 records, every cycle, final registers, MPRs and memory
PASS: op 87: 40 records, every cycle, final registers, MPRs and memory
PASS: op 88: 40 records, every cycle, final registers, MPRs and memory
PASS: op 89: 40 records, every cycle, final registers, MPRs and memory
PASS: op 8a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 8b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 8c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 8d: 40 records, every cycle, final registers, MPRs and memory
PASS: op 8e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 8f: 40 records, every cycle, final registers, MPRs and memory
PASS: op 90: 40 records, every cycle, final registers, MPRs and memory
PASS: op 91: 40 records, every cycle, final registers, MPRs and memory
PASS: op 92: 40 records, every cycle, final registers, MPRs and memory
PASS: op 93: 40 records, every cycle, final registers, MPRs and memory
PASS: op 94: 40 records, every cycle, final registers, MPRs and memory
PASS: op 95: 40 records, every cycle, final registers, MPRs and memory
PASS: op 96: 40 records, every cycle, final registers, MPRs and memory
PASS: op 97: 40 records, every cycle, final registers, MPRs and memory
PASS: op 98: 40 records, every cycle, final registers, MPRs and memory
PASS: op 99: 40 records, every cycle, final registers, MPRs and memory
PASS: op 9a: 40 records, every cycle, final registers, MPRs and memory
PASS: op 9b: 40 records, every cycle, final registers, MPRs and memory
PASS: op 9c: 40 records, every cycle, final registers, MPRs and memory
PASS: op 9d: 40 records, every cycle, final registers, MPRs and memory
PASS: op 9e: 40 records, every cycle, final registers, MPRs and memory
PASS: op 9f: 40 records, every cycle, final registers, MPRs and memory
PASS: op a0: 40 records, every cycle, final registers, MPRs and memory
PASS: op a1: 40 records, every cycle, final registers, MPRs and memory
PASS: op a2: 40 records, every cycle, final registers, MPRs and memory
PASS: op a3: 40 records, every cycle, final registers, MPRs and memory
PASS: op a4: 40 records, every cycle, final registers, MPRs and memory
PASS: op a5: 40 records, every cycle, final registers, MPRs and memory
PASS: op a6: 40 records, every cycle, final registers, MPRs and memory
PASS: op a7: 40 records, every cycle, final registers, MPRs and memory
PASS: op a8: 40 records, every cycle, final registers, MPRs and memory
PASS: op a9: 40 records, every cycle, final registers, MPRs and memory
PASS: op aa: 40 records, every cycle, final registers, MPRs and memory
PASS: op ab: 40 records, every cycle, final registers, MPRs and memory
PASS: op ac: 40 records, every cycle, final registers, MPRs and memory
PASS: op ad: 40 records, every cycle, final registers, MPRs and memory
PASS: op ae: 40 records, every cycle, final registers, MPRs and memory
PASS: op af: 40 records, every cycle, final registers, MPRs and memory
PASS: op b0: 40 records, every cycle, final registers, MPRs and memory
PASS: op b1: 40 records, every cycle, final registers, MPRs and memory
PASS: op b2: 40 records, every cycle, final registers, MPRs and memory
PASS: op b3: 40 records, every cycle, final registers, MPRs and memory
PASS: op b4: 40 records, every cycle, final registers, MPRs and memory
PASS: op b5: 40 records, every cycle, final registers, MPRs and memory
PASS: op b6: 40 records, every cycle, final registers, MPRs and memory
PASS: op b7: 40 records, every cycle, final registers, MPRs and memory
PASS: op b8: 40 records, every cycle, final registers, MPRs and memory
PASS: op b9: 40 records, every cycle, final registers, MPRs and memory
PASS: op ba: 40 records, every cycle, final registers, MPRs and memory
PASS: op bb: 40 records, every cycle, final registers, MPRs and memory
PASS: op bc: 40 records, every cycle, final registers, MPRs and memory
PASS: op bd: 40 records, every cycle, final registers, MPRs and memory
PASS: op be: 40 records, every cycle, final registers, MPRs and memory
PASS: op bf: 40 records, every cycle, final registers, MPRs and memory
PASS: op c0: 40 records, every cycle, final registers, MPRs and memory
PASS: op c1: 40 records, every cycle, final registers, MPRs and memory
PASS: op c2: 40 records, every cycle, final registers, MPRs and memory
PASS: op c3: 40 records, every cycle, final registers, MPRs and memory
PASS: op c4: 40 records, every cycle, final registers, MPRs and memory
PASS: op c5: 40 records, every cycle, final registers, MPRs and memory
PASS: op c6: 40 records, every cycle, final registers, MPRs and memory
PASS: op c7: 40 records, every cycle, final registers, MPRs and memory
PASS: op c8: 40 records, every cycle, final registers, MPRs and memory
PASS: op c9: 40 records, every cycle, final registers, MPRs and memory
PASS: op ca: 40 records, every cycle, final registers, MPRs and memory
PASS: op cb: 40 records, every cycle, final registers, MPRs and memory
PASS: op cc: 40 records, every cycle, final registers, MPRs and memory
PASS: op cd: 40 records, every cycle, final registers, MPRs and memory
PASS: op ce: 40 records, every cycle, final registers, MPRs and memory
PASS: op cf: 40 records, every cycle, final registers, MPRs and memory
PASS: op d0: 40 records, every cycle, final registers, MPRs and memory
PASS: op d1: 40 records, every cycle, final registers, MPRs and memory
PASS: op d2: 40 records, every cycle, final registers, MPRs and memory
PASS: op d3: 40 records, every cycle, final registers, MPRs and memory
PASS: op d4: 40 records, every cycle, final registers, MPRs and memory
PASS: op d5: 40 records, every cycle, final registers, MPRs and memory
PASS: op d6: 40 records, every cycle, final registers, MPRs and memory
PASS: op d7: 40 records, every cycle, final registers, MPRs and memory
PASS: op d8: 40 records, every cycle, final registers, MPRs and memory
PASS: op d9: 40 records, every cycle, final registers, MPRs and memory
PASS: op da: 40 records, every cycle, final registers, MPRs and memory
PASS: op db: 40 records, every cycle, final registers, MPRs and memory
PASS: op dc: 40 records, every cycle, final registers, MPRs and memory
PASS: op dd: 40 records, every cycle, final registers, MPRs and memory
PASS: op de: 40 records, every cycle, final registers, MPRs and memory
PASS: op df: 40 records, every cycle, final registers, MPRs and memory
PASS: op e0: 40 records, every cycle, final registers, MPRs and memory
PASS: op e1: 56 records, every cycle, final registers, MPRs and memory
PASS: op e2: 40 records, every cycle, final registers, MPRs and memory
PASS: op e3: 40 records, every cycle, final registers, MPRs and memory
PASS: op e4: 40 records, every cycle, final registers, MPRs and memory
PASS: op e5: 56 records, every cycle, final registers, MPRs and memory
PASS: op e6: 40 records, every cycle, final registers, MPRs and memory
PASS: op e7: 40 records, every cycle, final registers, MPRs and memory
PASS: op e8: 40 records, every cycle, final registers, MPRs and memory
PASS: op e9: 56 records, every cycle, final registers, MPRs and memory
PASS: op ea: 40 records, every cycle, final registers, MPRs and memory
PASS: op eb: 40 records, every cycle, final registers, MPRs and memory
PASS: op ec: 40 records, every cycle, final registers, MPRs and memory
PASS: op ed: 56 records, every cycle, final registers, MPRs and memory
PASS: op ee: 40 records, every cycle, final registers, MPRs and memory
PASS: op ef: 40 records, every cycle, final registers, MPRs and memory
PASS: op f0: 40 records, every cycle, final registers, MPRs and memory
PASS: op f1: 56 records, every cycle, final registers, MPRs and memory
PASS: op f2: 56 records, every cycle, final registers, MPRs and memory
PASS: op f3: 40 records, every cycle, final registers, MPRs and memory
PASS: op f4: 40 records, every cycle, final registers, MPRs and memory
PASS: op f5: 56 records, every cycle, final registers, MPRs and memory
PASS: op f6: 40 records, every cycle, final registers, MPRs and memory
PASS: op f7: 40 records, every cycle, final registers, MPRs and memory
PASS: op f8: 40 records, every cycle, final registers, MPRs and memory
PASS: op f9: 56 records, every cycle, final registers, MPRs and memory
PASS: op fa: 40 records, every cycle, final registers, MPRs and memory
PASS: op fb: 40 records, every cycle, final registers, MPRs and memory
PASS: op fc: 40 records, every cycle, final registers, MPRs and memory
PASS: op fd: 56 records, every cycle, final registers, MPRs and memory
PASS: op fe: 40 records, every cycle, final registers, MPRs and memory
PASS: op ff: 40 records, every cycle, final registers, MPRs and memory
PASS: op codes without records = 0000000000000000
PASS: all 11392 records
PASS: CE7 / CEK accesses in the records (each one extra enable): 228

=============================================================
 ALU SECTION D: Arithmetic and Logic
=============================================================

=== ALU SECTION D.1: Every Operation, Every Input, C and D, Other Flags Passed Through ===

PASS: ORA: 262144 input combinations
PASS: AND: 262144 input combinations
PASS: EOR: 262144 input combinations
PASS: ADC: 262144 input combinations
PASS: EQ1: 262144 input combinations
PASS: EQ2: 262144 input combinations
PASS: CMP: 262144 input combinations
PASS: SBC: 262144 input combinations
PASS: ASL: 262144 input combinations
PASS: ROL: 262144 input combinations
PASS: LSR: 262144 input combinations
PASS: ROR: 262144 input combinations
PASS: BIT/TST: 262144 input combinations
PASS: DEC: 262144 input combinations
PASS: INC: 262144 input combinations
PASS: TSB: 262144 input combinations
PASS: TRB: 262144 input combinations

=============================================================
 CPU SECTION E: HuC6280 Instructions
=============================================================

=== CPU SECTION E.1: T Cleared by Every Instruction Kind ===

PASS: SET, NOP, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, LDY #00, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, STY 20, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, BIT #00, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, BRA +0, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, INY, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, STZ 30, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, BBR0 30, +0, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, TST #01, 30, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, CSH, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, SEI, ADC #01: ADC on A (A = 21, 2010 unchanged)
PASS: SET, CLV, ADC #01: ADC on A (A = 21, 2010 unchanged)

=== CPU SECTION E.2: T Memory Operation, PHP, PLP ===

PASS: SET; ADC #05: 2010 = 07 + 05, A unchanged
PASS: PHP after SET: bit 5 (T) 0, bit 4 (B) 1 = 0000000000000010
PASS: PLP with bit 5 set, ORA zp: memory operation on 2010 = 000000000000003c
PASS: A unchanged by the memory ORA = 0000000000000040

=== CPU SECTION E.3: Block Transfers, Every Op, Lengths 1-16 ===

PASS: 73 length 1: data, 23 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 1: data, 23 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 1: data, 23 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 1: data, 23 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 1: data, 23 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 2: data, 29 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 2: data, 29 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 2: data, 29 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 2: data, 29 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 2: data, 29 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 3: data, 35 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 3: data, 35 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 3: data, 35 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 3: data, 35 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 3: data, 35 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 4: data, 41 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 4: data, 41 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 4: data, 41 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 4: data, 41 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 4: data, 41 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 5: data, 47 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 5: data, 47 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 5: data, 47 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 5: data, 47 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 5: data, 47 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 6: data, 53 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 6: data, 53 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 6: data, 53 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 6: data, 53 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 6: data, 53 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 7: data, 59 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 7: data, 59 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 7: data, 59 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 7: data, 59 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 7: data, 59 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 8: data, 65 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 8: data, 65 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 8: data, 65 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 8: data, 65 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 8: data, 65 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 9: data, 71 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 9: data, 71 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 9: data, 71 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 9: data, 71 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 9: data, 71 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 10: data, 77 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 10: data, 77 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 10: data, 77 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 10: data, 77 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 10: data, 77 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 11: data, 83 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 11: data, 83 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 11: data, 83 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 11: data, 83 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 11: data, 83 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 12: data, 89 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 12: data, 89 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 12: data, 89 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 12: data, 89 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 12: data, 89 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 13: data, 95 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 13: data, 95 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 13: data, 95 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 13: data, 95 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 13: data, 95 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 14: data, 101 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 14: data, 101 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 14: data, 101 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 14: data, 101 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 14: data, 101 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 15: data, 107 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 15: data, 107 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 15: data, 107 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 15: data, 107 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 15: data, 107 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: 73 length 16: data, 113 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: c3 length 16: data, 113 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: d3 length 16: data, 113 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: e3 length 16: data, 113 cycles, A X Y restored, S unchanged, Y A X pushed
PASS: f3 length 16: data, 113 cycles, A X Y restored, S unchanged, Y A X pushed

=== CPU SECTION E.4: Block Transfer of Length 0 (65536 Bytes) ===

PASS: TIN length 0: cycles (17 + 6 x 65536) = 0000000000060011
PASS: last byte moved is logical FFFF (physical 001FFF) = 00000000000000e0

=== CPU SECTION E.5: Mapping Registers, TAM, TMA, ST0-ST2 ===

PASS: program ends
PASS: TAM #48 loads MPR3 and MPR6; MPR7-MPR0 = 002204032211f801
PASS: TMA #04 = 0000000000000011
PASS: TMA #08 = 0000000000000022
PASS: TMA #0C (OR of MPR2 and MPR3) = 0000000000000033
PASS: TMA #00 (last TAM value) = 0000000000000022
PASS: TMA #00 after TAM #00 (TAM #00 changes nothing) = 0000000000000022
PASS: LDA 4534 reads physical (MPR2 = 11) = 0000000000022534
PASS: LDA 6756 reads physical (MPR3 = 22) = 0000000000044756
PASS: ST0 writes 41 to 1FE000 with MPR0 = 01
PASS: ST1 writes 42 to 1FE002
PASS: ST2 writes 43 to 1FE003
PASS: no write to bank 01 at 0000-0003

=== CPU SECTION E.6: CSL and CSH: the Speed Changes at the Start of Cycle 3 ===

PASS: CSH: cycle 2 low speed, cycle 3 (internal) high speed
PASS: CSL: cycle 2 high speed, cycle 3 (internal) low speed

=== CPU SECTION E.7: BSR, JSR, RTS Round Trips ===

PASS: BSR and JSR return to the next instruction
PASS: BSR pushes PCH of BSR + 1 = 00000000000000e0
PASS: BSR pushes PCL of BSR + 1 = 0000000000000022
PASS: JSR pushes PCL of its last byte = 0000000000000025
PASS: X and Y from the subroutines = 0000000000000001

=== CPU SECTION E.8: Block Transfer over Its Saved Registers ===

PASS: program reaches the end
PASS: X, A, Y pulled from 21FD, 21FE, 21FF as the transfer left them = 0000000000a1a2a3

=============================================================
 INT SECTION F: Interrupts
=============================================================

=== INT SECTION F.1: Vectors and B of Every Source ===

PASS: IRQ2: vector FFF6, B = 0
PASS:   handler fetch: I set, D and T clear = 0000000000000004
PASS: IRQ1: vector FFF8, B = 0
PASS:   handler fetch: I set, D and T clear = 0000000000000004
PASS: timer: vector FFFA, B = 0
PASS:   handler fetch: I set, D and T clear = 0000000000000004
PASS: NMI: vector FFFC, B = 0
PASS:   handler fetch: I set, D and T clear = 0000000000000004
PASS: BRK: vector FFF6, B = 1
PASS:   handler fetch: I set, D and T clear = 0000000000000004

=== INT SECTION F.2: Entry Sequence: 8 Cycles ===

PASS: discarded fetch, read of PC, PCH, PCL, P, vector low and high, internal cycle

=== INT SECTION F.3: Poll at the Start of the Last Cycle (LDA abs) ===

PASS: IRQ low at the start of cycle 5: taken after LDA (pushed E023) = 000000000000e023
PASS: IRQ low after the start of cycle 5: taken after the next NOP (pushed E024) = 000000000000e024

=== INT SECTION F.4: Block Transfer Holds Interrupts to Its End ===

PASS: IRQ during TII is taken after it, before the NOP (pushed E027) = 000000000000e027

=== INT SECTION F.5: No Takeover of BRK; NMI before IRQ; NMI Edge ===

PASS: NMI during the BRK entry: BRK handler's first instruction runs first
PASS: NMI and IRQ together: NMI first
PASS: NMI held low: one entry (edge) = 0000000000000001

=== INT SECTION F.6: Vector Select Latched When the Entry Starts ===

PASS: irq_vec changed during the entry: IRQ1 vector kept

=== INT SECTION F.7: T across an Interrupt ===

PASS: IRQ after SET: pushed P has T
PASS: handler ADC #01 on A (T clear in the handler) = 0000000000000021
PASS: after RTI, ADC #05 is the memory operation (2010 = 05) = 0000000000000005
PASS: A unchanged by it = 0000000000000020

=== INT SECTION F.8: T Cleared by the Entry (Handler Starts with ORA #) ===

PASS: handler ORA #01 operates on A (2083 = 21) = 0000000000000021
PASS: after RTI, ADC #05 is the memory operation (2010 = 05) = 0000000000000005
PASS: A from the handler (2081 = 21) = 0000000000000021

=== INT SECTION F.9: Poll in the Internal Cycle before the Fetch (JMP) ===

PASS: IRQ low at the JMP fetch: taken after JMP (pushed E030) = 000000000000e030

=============================================================
 BUS SECTION G: RDY and the CE7 / CEK Wait
=============================================================

=== BUS SECTION G.1: RDY Holds Reads, Writes and Internal Cycles ===

PASS: read cycle held 5 enables: one cycle, address and data kept
PASS: internal cycle held 5 enables
PASS: write cycle held 5 enables: one write

=== BUS SECTION G.2: CE7 / CEK Accesses Last One More Enable ===

PASS: read of 1FE000: enables = 0000000000000002
PASS: the internal cycle before it: one enable
PASS: read of 1FE404: enables = 0000000000000002
PASS: read of 1FE800 (PSG): enables = 0000000000000001
PASS: write of 1FE002: enables = 0000000000000002
PASS: ST0: write of 1FE000 with 2 enables, instruction 5 enables

=== BUS SECTION G.3: CE_WAIT = 0 ===

PASS: uutn: enables without a cycle end over the same program = 0000000000000000

=============================================================
 CLK SECTION K: Enable Ratios and Random Stops
=============================================================

=== CLK SECTION K.1: Every 5th Record at 3 clk per Enable ===

PASS: 2279 records at ratio 3

=== CLK SECTION K.2: Every 7th Record at 1 clk per Enable with Random Stops ===

PASS: 1628 records at ratio 1 with random stops

=============================================================
  x6280 CPU Test Results
=============================================================
  Total Tests:  466
  Passed:       466
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
  Cycle-accurate to the HuC6280 Hardware and Software Manuals
=============================================================
```
