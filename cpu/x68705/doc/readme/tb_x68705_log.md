# x68705 Regression Log

Full output of the `tb_x68705` testbench (156 tests across 19 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  MC68705P3 Comprehensive MCU Testbench
  Reference: M6805/M146805 CMOS Family User's Manual
=============================================================

=== SECTION 1: Inherent Mode Control Instructions ===

PASS: NOP timing = 2 cycles
PASS: TAX timing = 2 cycles
PASS: TAX: X = A = 00000042
PASS: TXA timing = 2 cycles
PASS: TXA: A = X = 00000099
PASS: CLC timing = 2 cycles
PASS: CLC: C = 0 = 00000000
PASS: SEC timing = 2 cycles
PASS: SEC: C = 1 = 00000001
PASS: CLI timing = 2 cycles
PASS: CLI: I = 0 = 00000000
PASS: SEI timing = 2 cycles
PASS: SEI: I = 1 = 00000001
PASS: RSP timing = 2 cycles
PASS: RSP: SP = $3F = 0000003f

=== SECTION 2: Accumulator RMW Instructions ===

PASS: INCA timing = 3 cycles
PASS: INCA: A = $80 = 00000080
PASS: INCA: N = 1 = 00000001
PASS: DECA timing = 3 cycles
PASS: DECA: A = $00 = 00000000
PASS: DECA: Z = 1 = 00000001
PASS: CLRA timing = 3 cycles
PASS: CLRA: A = $00 = 00000000
PASS: COMA timing = 3 cycles
PASS: COMA: A = $AA = 000000aa
PASS: NEGA timing = 3 cycles
PASS: NEGA: A = $FF = 000000ff
PASS: LSRA timing = 3 cycles
PASS: LSRA: A = $41 = 00000041
PASS: LSRA: C = 0 = 00000000
PASS: RORA timing = 3 cycles
PASS: RORA: A = $80 = 00000080
PASS: RORA: C = 1 = 00000001
PASS: ASRA timing = 3 cycles
PASS: ASRA: A = $C1 = 000000c1
PASS: LSLA timing = 3 cycles
PASS: LSLA: A = $02 = 00000002
PASS: LSLA: C = 1 = 00000001
PASS: ROLA timing = 3 cycles
PASS: ROLA: A = $03 = 00000003
PASS: TSTA timing = 3 cycles
PASS: TSTA: Z = 1 = 00000001

=== SECTION 3: Index Register RMW Instructions ===

PASS: INCX timing = 3 cycles
PASS: INCX: X = $FF = 000000ff
PASS: DECX timing = 3 cycles
PASS: DECX: X = $00 = 00000000
PASS: CLRX timing = 3 cycles
PASS: CLRX: X = $00 = 00000000

=== SECTION 4: Immediate Addressing Mode ===

PASS: LDA #imm timing = 2 cycles
PASS: LDA #$42 = 00000042
PASS: LDX #imm timing = 2 cycles
PASS: LDX #$99 = 00000099
PASS: ADD #imm timing = 2 cycles
PASS: ADD #$10: A = $30 = 00000030
PASS: SUB #imm timing = 2 cycles
PASS: SUB #$05: A = $0B = 0000000b
PASS: CMP #imm timing = 2 cycles
PASS: CMP #$42: Z = 1 = 00000001
PASS: AND #imm timing = 2 cycles
PASS: AND #$0F: A = $0B = 0000000b
PASS: ORA #imm timing = 2 cycles
PASS: ORA #$F0: A = $FF = 000000ff
PASS: EOR #imm timing = 2 cycles
PASS: EOR #$FF: A = $AA = 000000aa

=== SECTION 5: Direct Addressing Mode ===

PASS: LDA dir timing = 3 cycles
PASS: LDA $20: A = $77 = 00000077
PASS: STA dir timing = 4 cycles
PASS: STA $25: RAM = $AB = 000000ab
PASS: ADD dir timing = 3 cycles
PASS: ADD $30: A = $15 = 00000015

=== SECTION 6: Extended Addressing Mode ===

PASS: LDA ext timing = 4 cycles
PASS: LDA $0150: A = $CD = 000000cd
PASS: STA ext timing = 5 cycles
PASS: STA $0040: RAM = $EF = 000000ef

=== SECTION 7: Indexed Addressing Modes ===

PASS: LDA ,X timing = 3 cycles
PASS: LDA ,X: A = $11 = 00000011
PASS: STA ,X timing = 4 cycles
PASS: STA ,X: RAM = $22 = 00000022
PASS: LDA off,X timing = 4 cycles
PASS: LDA $10,X: A = $33 = 00000033
PASS: STA off,X timing = 5 cycles
PASS: STA $05,X: RAM = $44 = 00000044
PASS: LDA off16,X timing = 5 cycles
PASS: LDA $0100,X: A = $55 = 00000055
PASS: STA off16,X timing = 6 cycles
PASS: STA $0040,X: RAM = $66 = 00000066

=== SECTION 8: Branch Instructions ===

PASS: BRA timing = 3 cycles
PASS: BRA +16: PC = $0112 = 00000112
PASS: BEQ taken timing = 3 cycles
PASS: BEQ taken: PC = $0107 = 00000107
PASS: BEQ not taken timing = 3 cycles
PASS: BEQ not taken: PC = $0102 = 00000102
PASS: BNE timing = 3 cycles
PASS: BNE -2: PC = $0100 = 00000100

=== SECTION 9: Bit Set/Clear Instructions ===

PASS: BSET0 timing = 5 cycles
PASS: BSET0 $30: bit 0 set = 00000001
PASS: BCLR7 timing = 5 cycles
PASS: BCLR7 $30: bit 7 clear = 0000007f

=== SECTION 10: Bit Test and Branch Instructions ===

PASS: BRSET0 timing = 5 cycles
PASS: BRSET0 taken: PC = $0113 = 00000113
PASS: BRCLR7 timing = 5 cycles
PASS: BRCLR7 taken: PC = $0108 = 00000108

=== SECTION 11: Direct RMW Instructions ===

PASS: INC dir timing = 5 cycles
PASS: INC $30: RAM = $11 = 00000011
PASS: DEC dir timing = 5 cycles
PASS: DEC $30: RAM = $0F = 0000000f
PASS: CLR dir timing = 5 cycles
PASS: CLR $30: RAM = $00 = 00000000
PASS: TST dir timing = 4 cycles
PASS: TST $30: N = 1 = 00000001

=== SECTION 12: Indexed RMW Instructions ===

PASS: INC ,X timing = 5 cycles
PASS: INC ,X: RAM = $21 = 00000021
PASS: INC off,X timing = 6 cycles
PASS: INC $05,X: RAM = $31 = 00000031
PASS: TST ,X timing = 4 cycles
PASS: TST ,X: Z = 1 = 00000001
PASS: TST off,X timing = 5 cycles
PASS: TST $10,X: N = 1 = 00000001

=== SECTION 13: Jump Instructions ===

PASS: JMP dir timing = 2 cycles
PASS: JMP $50: PC = $0050 = 00000050
PASS: JMP ext timing = 3 cycles
PASS: JMP $0200: PC = $0200 = 00000200
PASS: JMP ,X timing = 2 cycles
PASS: JMP ,X: PC = $0080 = 00000080

=== SECTION 14: Subroutine Instructions ===

PASS: JSR dir timing = 5 cycles
PASS: JSR $50: PC = $0050 = 00000050
PASS: JSR: SP decremented by 2 = 0000003d
PASS: JSR ext timing = 6 cycles
PASS: JSR $0200: PC = $0200 = 00000200
PASS: BSR timing = 6 cycles
PASS: BSR +16: PC = $0112 = 00000112
PASS: RTS timing = 6 cycles
PASS: RTS: PC = $0150 = 00000150
PASS: RTS: SP restored = 0000003f

=== SECTION 15: Interrupt Instructions ===

PASS: SWI timing = 10 cycles
PASS: SWI: PC = $0200 = 00000200
PASS: SWI: I = 1 = 00000001
PASS: SWI: SP = $3A (5 pushed) = 0000003a
PASS: RTI timing = 9 cycles
PASS: RTI: PC = $0150 = 00000150
PASS: RTI: A = $AA = 000000aa
PASS: RTI: X = $55 = 00000055
PASS: RTI: SP = $3F = 0000003f

=== SECTION 16: Hardware Interrupts ===

PASS: IRQ: PC = $0300 (ISR) = 00000300
PASS: IRQ: I = 1 = 00000001
PASS: IRQ masked: PC = $0101 = 00000101
PASS: IRQ masked: A = $11 (INCA ran) = 00000011
PASS: TIRQ: PC = $0400 (Timer ISR) = 00000400
PASS: Priority: TIRQ > IRQ = 00000400

=== SECTION 17: I/O Port Operations ===

PASS: DDRA = $FF = 000000ff
PASS: Port A output = $A5 = 000000a5
PASS: Port B read = $5A = 0000005a

=== SECTION 18: Timer Operations ===

PASS: TDR = $80 = 00000080
PASS: TCR read = $C5 = 000000c5

=== SECTION 19: Memory Boundaries ===

PASS: RAM[$10] = $11 = 00000011
PASS: RAM[$7F] = $7F = 0000007f

=============================================================
  MC68705P3 Comprehensive Test Results
=============================================================
  Total Tests:  156
  Passed:       156
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
  Cycle-accurate to M6805 CMOS Manual
=============================================================
```
