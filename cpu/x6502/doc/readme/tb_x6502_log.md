# x6502 Regression Log

Full output of the `tb_x6502` testbench (564 tests across 36 sections). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  x6502 Comprehensive Testbench
  Reference: MOS Technology MCS6500 Hardware Manual
=============================================================

=== SECTION 1: Reset Sequence ===

PASS: Reset PC = $1000 = 00001000
PASS: Reset I = 1 = 00000001
PASS: Reset D = 0 = 00000000
PASS: Reset S = $FD = 000000fd

=== SECTION 2: Implied Mode ===

PASS: NOP timing = 2 cycles
PASS: NOP: PC advanced = 00001101
PASS: CLC timing = 2 cycles
PASS: CLC: C = 0 = 00000000
PASS: SEC timing = 2 cycles
PASS: SEC: C = 1 = 00000001
PASS: CLI timing = 2 cycles
PASS: CLI: I = 0 = 00000000
PASS: SEI timing = 2 cycles
PASS: SEI: I = 1 = 00000001
PASS: CLV timing = 2 cycles
PASS: CLV: V = 0 = 00000000
PASS: CLD timing = 2 cycles
PASS: CLD: D = 0 = 00000000
PASS: SED timing = 2 cycles
PASS: SED: D = 1 = 00000001
PASS: INX timing = 2 cycles
PASS: INX: X = $80 = 00000080
PASS: INX: N = 1 = 00000001
PASS: INX: $FF -> $00 = 00000000
PASS: INX: Z = 1 = 00000001
PASS: INY timing = 2 cycles
PASS: INY: Y = $42 = 00000042
PASS: DEX timing = 2 cycles
PASS: DEX: X = $00 = 00000000
PASS: DEX: Z = 1 = 00000001
PASS: DEY timing = 2 cycles
PASS: DEY: $00 -> $FF = 000000ff
PASS: DEY: N = 1 = 00000001
PASS: TAX timing = 2 cycles
PASS: TAX: X = A = 00000055
PASS: TAY timing = 2 cycles
PASS: TAY: Y = A = 000000aa
PASS: TAY: N = 1 = 00000001
PASS: TXA timing = 2 cycles
PASS: TXA: A = X = 00000033
PASS: TYA timing = 2 cycles
PASS: TYA: A = Y = 00000000
PASS: TYA: Z = 1 = 00000001
PASS: TSX timing = 2 cycles
PASS: TSX: X = S = 000000c0
PASS: TXS timing = 2 cycles
PASS: TXS: S = X = 00000000
PASS: TXS: Z unchanged = 00000000

=== SECTION 3: Immediate Mode ===

PASS: LDA # timing = 2 cycles
PASS: LDA #$42 = 00000042
PASS: LDX # timing = 2 cycles
PASS: LDX #$99 = 00000099
PASS: LDX #$99: N = 1 = 00000001
PASS: LDY # timing = 2 cycles
PASS: LDY #$00 = 00000000
PASS: LDY #$00: Z = 1 = 00000001
PASS: ADC # timing = 2 cycles
PASS: ADC #$10: A = $30 = 00000030
PASS: ADC: C = 0 = 00000000
PASS: ADC: V = 0 = 00000000
PASS: ADC #$01: $7F+$01 = 00000080
PASS: ADC overflow: V = 1 = 00000001
PASS: SBC # timing = 2 cycles
PASS: SBC #$05: A = $0B = 0000000b
PASS: SBC: C = 1 = 00000001
PASS: CMP # timing = 2 cycles
PASS: CMP equal: Z = 1 = 00000001
PASS: CMP equal: C = 1 = 00000001
PASS: AND #$0F: A = $0B = 0000000b
PASS: ORA #$F0: A = $FF = 000000ff
PASS: EOR #$FF: A = $AA = 000000aa
PASS: CPX # timing = 2 cycles
PASS: CPX: X >= operand, C = 1 = 00000001
PASS: CPY # timing = 2 cycles
PASS: CPY: Y < operand, C = 0 = 00000000
PASS: CPY: N = 1 = 00000001

=== SECTION 4: Zero Page Reads ===

PASS: LDA zp timing = 3 cycles
PASS: LDA $20: A = $77 = 00000077
PASS: LDX zp timing = 3 cycles
PASS: LDX $21: X = $88 = 00000088
PASS: LDX $21: N = 1 = 00000001
PASS: LDY zp timing = 3 cycles
PASS: LDY $22: Y = $00 = 00000000
PASS: LDY $22: Z = 1 = 00000001
PASS: ADC zp timing = 3 cycles
PASS: ADC $30: A = $15 = 00000015
PASS: SBC zp timing = 3 cycles
PASS: SBC $31: A = $1B = 0000001b
PASS: AND $32: A = $F0 = 000000f0
PASS: ORA $33: A = $FF = 000000ff
PASS: EOR $34: A = $FF = 000000ff
PASS: CMP zp timing = 3 cycles
PASS: CMP zp equal: Z = 1 = 00000001
PASS: CPX zp timing = 3 cycles
PASS: CPX zp equal: Z = 1 = 00000001
PASS: CPY zp timing = 3 cycles
PASS: CPY zp: Y > op, C = 1 = 00000001
PASS: BIT zp timing = 3 cycles
PASS: BIT $38: N from b[7] = 00000001
PASS: BIT $38: V from b[6] = 00000001
PASS: BIT $38: Z = 0 = 00000000

=== SECTION 5: Zero Page Writes ===

PASS: STA zp timing = 3 cycles
PASS: STA $40: RAM = $AB = 000000ab
PASS: STX zp timing = 3 cycles
PASS: STX $41: RAM = $CD = 000000cd
PASS: STY zp timing = 3 cycles
PASS: STY $42: RAM = $EF = 000000ef

=== SECTION 6: Conditional Branches ===

PASS: BPL not taken timing = 2 cycles
PASS: BPL not taken: PC advances 2 = 00001102
PASS: BPL taken timing = 3 cycles
PASS: BPL taken: PC = $1112 = 00001112
PASS: BMI taken timing = 3 cycles
PASS: BMI taken: PC = $1107 = 00001107
PASS: BVC taken timing = 3 cycles
PASS: BVC taken: PC = $110A = 0000110a
PASS: BVS taken timing = 3 cycles
PASS: BVS taken: PC = $1106 = 00001106
PASS: BCC taken timing = 3 cycles
PASS: BCC taken: PC = $110C = 0000110c
PASS: BCS taken timing = 3 cycles
PASS: BCS taken: PC = $1104 = 00001104
PASS: BNE backward timing = 3 cycles
PASS: BNE -2: PC = $1100 = 00001100
PASS: BEQ taken timing = 3 cycles
PASS: BEQ taken: PC = $1107 = 00001107
PASS: BEQ page cross timing = 4 cycles
PASS: BEQ +32: PC = $1112 = 00001112
PASS: BEQ neg cross timing = 4 cycles
PASS: BEQ -32: PC = $10F2 = 000010f2

=== SECTION 7: JMP Absolute ===

PASS: JMP abs timing = 3 cycles
PASS: JMP $1234: PC = $1234 = 00001234
PASS: JMP abs timing 2 = 3 cycles
PASS: JMP $1500: PC = $1500 = 00001500

=== SECTION 8: Absolute Reads ===

PASS: LDA abs timing = 4 cycles
PASS: LDA $0050: A = $44 = 00000044
PASS: LDX abs timing = 4 cycles
PASS: LDX $0051: X = $99 = 00000099
PASS: LDX abs: N = 1 = 00000001
PASS: LDY abs timing = 4 cycles
PASS: LDY $0052: Y = $00 = 00000000
PASS: LDY abs: Z = 1 = 00000001
PASS: ADC abs timing = 4 cycles
PASS: ADC $0053: A = $15 = 00000015
PASS: SBC abs timing = 4 cycles
PASS: SBC $0054: A = $1B = 0000001b
PASS: AND abs timing = 4 cycles
PASS: AND $0055: A = $0F = 0000000f
PASS: ORA abs timing = 4 cycles
PASS: ORA $0056: A = $FF = 000000ff
PASS: EOR abs timing = 4 cycles
PASS: EOR $0057: A = $FF = 000000ff
PASS: CMP abs timing = 4 cycles
PASS: CMP abs equal: Z = 1 = 00000001
PASS: CMP abs equal: C = 1 = 00000001
PASS: CPX abs timing = 4 cycles
PASS: CPX abs: X >= mem, C = 1 = 00000001
PASS: CPY abs timing = 4 cycles
PASS: CPY abs: Y < mem, C = 0 = 00000000
PASS: BIT abs timing = 4 cycles
PASS: BIT abs: N from b[7] = 00000001
PASS: BIT abs: V from b[6] = 00000001
PASS: BIT abs: Z = 0 = 00000000

=== SECTION 9: Absolute Writes ===

PASS: STA abs timing = 4 cycles
PASS: STA $0060: RAM = $AB = 000000ab
PASS: STX abs timing = 4 cycles
PASS: STX $0061: RAM = $CD = 000000cd
PASS: STY abs timing = 4 cycles
PASS: STY $0062: RAM = $EF = 000000ef

=== SECTION 10: Accumulator Shifts ===

PASS: ASL A timing = 2 cycles
PASS: ASL A: $81 -> $02 = 00000002
PASS: ASL A: C from bit 7 = 00000001
PASS: ASL A: N = 0 = 00000000
PASS: LSR A timing = 2 cycles
PASS: LSR A: $81 -> $40 = 00000040
PASS: LSR A: C from bit 0 = 00000001
PASS: LSR A: N always 0 = 00000000
PASS: ROL A timing = 2 cycles
PASS: ROL A: $81 + C=1 -> $03 = 00000003
PASS: ROL A: old bit 7 -> C = 00000001
PASS: ROR A timing = 2 cycles
PASS: ROR A: $01 + C=1 -> $80 = 00000080
PASS: ROR A: old bit 0 -> C = 00000001
PASS: ROR A: N from new bit 7 = 00000001

=== SECTION 11: Stack Push / Pull ===

PASS: PHA timing = 3 cycles
PASS: PHA: stack[$01FD] = $7E = 0000007e
PASS: PHA: S decremented to $FC = 000000fc
PASS: PHP timing = 3 cycles
PASS: PHP: stack[$01FC] = P|$30 = 000000f3
PASS: PHP: S decremented to $FB = 000000fb
PASS: PLA timing = 4 cycles
PASS: PLA: A = $82 = 00000082
PASS: PLA: S incremented to $FC = 000000fc
PASS: PLA: N = 1 = 00000001
PASS: PLA: Z = 0 = 00000000
PASS: PLA zero: A = $00 = 00000000
PASS: PLA zero: Z = 1 = 00000001
PASS: PLP timing = 4 cycles
PASS: PLP: P = $EF (bit4 cleared, bit5 set) = 000000ef
PASS: PLP: S incremented to $FC = 000000fc
PASS: PLP zero pull: P = $20 (bit5 forced) = 00000020

=== SECTION 12: JMP Indirect ===

PASS: JMP ind timing = 5 cycles
PASS: JMP ($0030): PC = $1522 = 00001522
PASS: JMP ind timing 2 = 5 cycles
PASS: JMP ($0100): PC = $1744 = 00001744
PASS: JMP ind page-wrap timing = 5 cycles
PASS: JMP ($00FF): NMOS bug -> $1377 = 00001377

=== SECTION 13: Zero Page Indexed Reads ===

PASS: LDA zp,X timing = 4 cycles
PASS: LDA $70,X (X=5): A = $33 = 00000033
PASS: LDA zp,X wrap timing = 4 cycles
PASS: LDA $FF,X (X=9): wrap to $08 = 00000099
PASS: LDY zp,X timing = 4 cycles
PASS: LDY $70,X (X=0): Y = $22 = 00000022
PASS: LDX zp,Y timing = 4 cycles
PASS: LDX $80,Y (Y=2): X = $11 = 00000011
PASS: ADC zp,X timing = 4 cycles
PASS: ADC $70,X (X=5): A = $43 = 00000043
PASS: SBC zp,X timing = 4 cycles
PASS: SBC $70,X (X=5): A = $1D = 0000001d
PASS: AND zp,X timing = 4 cycles
PASS: AND $75,X (X=5): A = $F0 = 000000f0
PASS: ORA zp,X timing = 4 cycles
PASS: ORA $70,X (X=0): A = $2F = 0000002f
PASS: EOR zp,X timing = 4 cycles
PASS: EOR $75,X (X=5): A = $0F = 0000000f
PASS: CMP zp,X timing = 4 cycles
PASS: CMP zp,X equal: Z = 1 = 00000001

=== SECTION 14: Zero Page Indexed Writes ===

PASS: STA zp,X timing = 4 cycles
PASS: STA $90,X (X=5): RAM[$95] = $12 = 00000012
PASS: STY zp,X timing = 4 cycles
PASS: STY $90,X (X=6): RAM[$96] = $34 = 00000034
PASS: STX zp,Y timing = 4 cycles
PASS: STX $90,Y (Y=7): RAM[$97] = $56 = 00000056
PASS: STA zp,X wrap timing = 4 cycles
PASS: STA $FE,X (X=5): wrap to RAM[$03] = 00000078

=== SECTION 15: Absolute Indexed Reads ===

PASS: LDA abs,X no cross timing = 4 cycles
PASS: LDA $1E00,X (X=5): A = $BB = 000000bb
PASS: LDA abs,X cross timing = 5 cycles
PASS: LDA $1EFF,X (X=4): A = $77 = 00000077
PASS: LDA abs,Y no cross timing = 4 cycles
PASS: LDA $1E00,Y (Y=5): A = $BB = 000000bb
PASS: LDA abs,Y cross timing = 5 cycles
PASS: LDA $1EFF,Y (Y=4): A = $77 = 00000077
PASS: LDX abs,Y timing = 4 cycles
PASS: LDX $1E00,Y (Y=$10): X = $33 = 00000033
PASS: LDY abs,X timing = 4 cycles
PASS: LDY $1E00,X (X=$20): Y = $44 = 00000044
PASS: ADC abs,X timing = 4 cycles
PASS: ADC $1E05,X: A = $CB = 000000cb
PASS: CMP abs,Y cross timing = 5 cycles
PASS: CMP abs,Y cross: Z = 1 = 00000001

=== SECTION 16: Absolute Indexed Writes ===

PASS: STA abs,X no cross timing = 5 cycles
PASS: STA $0000,X (X=$30): RAM = $9C = 0000009c
PASS: STA abs,X cross timing = 5 cycles
PASS: STA $00FF,X (X=5): RAM[$0104] = $7E = 0000007e
PASS: STA abs,Y no cross timing = 5 cycles
PASS: STA $0040,Y (Y=$10): RAM = $21 = 00000021
PASS: STA abs,Y cross timing = 5 cycles
PASS: STA $00C0,Y (Y=$50): RAM[$0110] = $43 = 00000043

=== SECTION 17: Indexed Indirect (ZP,X) ===

PASS: LDA (ZP,X) timing = 6 cycles
PASS: LDA ($40,X=0): A = $AA = 000000aa
PASS: LDA (ZP,X) X=2 timing = 6 cycles
PASS: LDA ($40,X=2): A = $BB = 000000bb
PASS: ADC (ZP,X) timing = 6 cycles
PASS: ADC ($40,X=0): A = $BB = 000000bb
PASS: SBC (ZP,X) timing = 6 cycles
PASS: SBC ($40,X=2): A = $05 = 00000005
PASS: AND (ZP,X) timing = 6 cycles
PASS: AND ($40,X=0): A = $A0 = 000000a0
PASS: ORA (ZP,X) timing = 6 cycles
PASS: ORA ($40,X=0): A = $AF = 000000af
PASS: EOR (ZP,X) timing = 6 cycles
PASS: EOR ($40,X=0): A = $55 = 00000055
PASS: CMP (ZP,X) timing = 6 cycles
PASS: CMP ($40,X=0) equal: Z = 1 = 00000001
PASS: LDA (ZP,X) wrap timing = 6 cycles
PASS: LDA ($FE,X=3): wrap to $01 -> $5A = 0000005a
PASS: STA (ZP,X) timing = 6 cycles
PASS: STA ($40,X=4): RAM[$0080] = $7E = 0000007e

=== SECTION 18: Indirect Indexed (ZP),Y ===

PASS: LDA (ZP),Y no cross timing = 5 cycles
PASS: LDA ($60),Y=5: A = $BB = 000000bb
PASS: LDA (ZP),Y cross timing = 6 cycles
PASS: LDA ($62),Y=$13: A = $77 = 00000077
PASS: ADC (ZP),Y timing = 5 cycles
PASS: ADC ($60),Y=5: A = $CC = 000000cc
PASS: SBC (ZP),Y timing = 5 cycles
PASS: SBC ($60),Y=5: A = $05 = 00000005
PASS: AND (ZP),Y timing = 5 cycles
PASS: AND ($60),Y=0: A = $A0 = 000000a0
PASS: ORA (ZP),Y timing = 5 cycles
PASS: ORA ($60),Y=0: A = $AF = 000000af
PASS: EOR (ZP),Y timing = 5 cycles
PASS: EOR ($60),Y=0: A = $55 = 00000055
PASS: CMP (ZP),Y timing = 5 cycles
PASS: CMP ($60),Y=0 equal: Z = 1 = 00000001
PASS: LDA (ZP),Y ZP wrap timing = 5 cycles
PASS: LDA ($FF),Y=0: ZP-wrap ptr -> $7B = 0000007b
PASS: STA (ZP),Y no cross timing = 6 cycles
PASS: STA ($64),Y=$70: RAM[$0070] = $99 = 00000099
PASS: STA (ZP),Y cross timing = 6 cycles
PASS: STA ($66),Y=$60 cross: RAM[$0120] = $AB = 000000ab

=== SECTION 19: JSR / RTS ===

PASS: JSR timing = 6 cycles
PASS: JSR $1500: PC = $1500 = 00001500
PASS: JSR: S decremented by 2 to $FB = 000000fb
PASS: JSR: stack[$01FD] = PCH = $11 = 00000011
PASS: JSR: stack[$01FC] = PCL = $02 = 00000002
PASS: RTS timing = 6 cycles
PASS: RTS: PC = $1103 (popped + 1) = 00001103
PASS: RTS: S restored to $FD = 000000fd
PASS: Round trip: JSR landed at $1200 = 00001200
PASS: Round trip: RTS returned to $1103 = 00001103
PASS: Round trip: S restored = 000000fd

=== SECTION 20: RMW Zero Page ===

PASS: ASL zp timing = 5 cycles
PASS: ASL $50: $41 -> $82 = 00000082
PASS: ASL zp: C from old bit 7 = 0 = 00000000
PASS: ASL zp: N from new bit 7 = 1 = 00000001
PASS: LSR zp timing = 5 cycles
PASS: LSR $51: $81 -> $40 = 00000040
PASS: LSR zp: C from old bit 0 = 1 = 00000001
PASS: ROL zp timing = 5 cycles
PASS: ROL $52: $81 + C -> $03 = 00000003
PASS: ROL zp: old bit 7 -> C = 00000001
PASS: ROR zp timing = 5 cycles
PASS: ROR $53: $01 + C -> $80 = 00000080
PASS: ROR zp: N = 1 = 00000001
PASS: INC zp timing = 5 cycles
PASS: INC $54: $FF -> $00 = 00000000
PASS: INC zp: Z = 1 = 00000001
PASS: DEC zp timing = 5 cycles
PASS: DEC $55: $01 -> $00 = 00000000
PASS: DEC zp: Z = 1 = 00000001

=== SECTION 21: RMW zp,X / abs / abs,X ===

PASS: ASL zp,X timing = 6 cycles
PASS: ASL $50,X (X=4): $22 -> $44 = 00000044
PASS: INC zp,X timing = 6 cycles
PASS: INC $50,X (X=5): $0F -> $10 = 00000010
PASS: LSR abs timing = 6 cycles
PASS: LSR $0040: $81 -> $40 = 00000040
PASS: LSR abs: C = old bit 0 = 00000001
PASS: INC abs timing = 6 cycles
PASS: INC $0041: $7F -> $80 = 00000080
PASS: INC abs: N = 1 = 00000001
PASS: DEC abs timing = 6 cycles
PASS: DEC $0042: $00 -> $FF = 000000ff
PASS: DEC abs: N = 1 = 00000001
PASS: ASL abs,X no cross timing = 7 cycles
PASS: ASL $0040,X (X=5): $11 -> $22 = 00000022
PASS: INC abs,X cross timing = 7 cycles
PASS: INC $00C0,X (X=$50): $05 -> $06 = 00000006
PASS: ROL abs,X timing = 7 cycles
PASS: ROL $0040,X (X=6): $7F + C -> $FF = 000000ff
PASS: ROL abs,X: old bit 7 = 0 -> C = 0 = 00000000

=== SECTION 22: BRK + RTI ===

PASS: BRK timing = 7 cycles
PASS: BRK: PC = IRQ vector $1300 = 00001300
PASS: BRK: stack[$01FD] = PCH = $11 = 00000011
PASS: BRK: stack[$01FC] = PCL = $02 = 00000002
PASS: BRK: stack[$01FB] = P with B=1 = $34 = 00000034
PASS: BRK: I forced 1 = 00000001
PASS: BRK: S decremented by 3 = 000000fa
PASS: RTI timing = 6 cycles
PASS: RTI: PC = popped (no +1) = $1102 = 00001102
PASS: RTI: P with bit 4 cleared = $24 = 00000024
PASS: RTI: S restored to $FD = 000000fd
PASS: BRK round trip: at IRQ vector = 00001300
PASS: BRK round trip: RTI back to $1102 = 00001102
PASS: BRK round trip: S restored = 000000fd

=== SECTION 23: IRQ Injection ===

PASS: IRQ injection timing = 7 cycles
PASS: IRQ: PC = vector $1300 = 00001300
PASS: IRQ: stack[$01FD] = PCH = $11 = 00000011
PASS: IRQ: stack[$01FC] = PCL = $00 (next instr) = 00000000
PASS: IRQ: stack[$01FB] = P with B=0 = $20 = 00000020
PASS: IRQ: I forced 1 = 00000001
PASS: IRQ masked: NOP runs normally = 2 cycles
PASS: IRQ masked: PC = $1101 (NOP advanced) = 00001101

=== SECTION 24: NMI Injection ===

PASS: NMI injection timing = 7 cycles
PASS: NMI: PC = vector $1400 = 00001400
PASS: NMI: stack[$01FD] = PCH = $11 = 00000011
PASS: NMI: stack[$01FC] = PCL = $00 = 00000000
PASS: NMI: stack[$01FB] = P with B=0 = $24 = 00000024
PASS: NMI: I forced 1 = 00000001
PASS: NMI: latch cleared after ack = 00000000

=== SECTION 25: ALU Logical Operations ===

PASS: ORA $0F | $F0 q = ff
PASS: ORA N=1 = 1
PASS: ORA Z=0 = 0
PASS: ORA $00 | $00 q = 00
PASS: ORA N=0 = 0
PASS: ORA Z=1 = 1
PASS: AND $FF & $0F q = 0f
PASS: AND N=0 = 0
PASS: AND Z=0 = 0
PASS: AND $80 & $80 q = 80
PASS: AND N=1 = 1
PASS: AND $55 & $AA q = 00
PASS: AND Z=1 = 1
PASS: EOR $FF ^ $0F q = f0
PASS: EOR N=1 = 1
PASS: EOR $55 ^ $55 q = 00
PASS: EOR Z=1 = 1
PASS: ORA preserves C=1 preserved (1)
PASS: ORA preserves C=0 preserved (0)

=== SECTION 26: ALU Pass-through ===

PASS: EQ1 pass $42 q = 42
PASS: EQ1 N preserved preserved (1)
PASS: EQ1 Z preserved preserved (1)
PASS: EQ1 C preserved preserved (1)
PASS: EQ1 V preserved preserved (1)
PASS: EQ2 pass $80 q = 80
PASS: EQ2 N=1 (from $80) = 1
PASS: EQ2 Z=0 = 0
PASS: EQ2 pass $00 q = 00
PASS: EQ2 N=0 = 0
PASS: EQ2 Z=1 (from $00) = 1
PASS: EQ2 C preserved preserved (1)
PASS: EQ2 V preserved preserved (1)

=== SECTION 27: ALU Increment / Decrement ===

PASS: INC $7F q = 80
PASS: INC N=1 ($7F->$80) = 1
PASS: INC Z=0 = 0
PASS: INC $FF q = 00
PASS: INC Z=1 ($FF->$00) = 1
PASS: INC $00 q = 01
PASS: DEC $01 q = 00
PASS: DEC Z=1 ($01->$00) = 1
PASS: DEC $00 q = ff
PASS: DEC N=1 ($00->$FF) = 1
PASS: INC preserves C preserved (1)

=== SECTION 28: ALU Shift / Rotate ===

PASS: ASL $80 q = 00
PASS: ASL C=1 (bit 7 set) = 1
PASS: ASL Z=1 = 1
PASS: ASL N=0 = 0
PASS: ASL $40 q = 80
PASS: ASL C=0 (bit 7 clear) = 0
PASS: ASL N=1 = 1
PASS: LSR $01 q = 00
PASS: LSR C=1 = 1
PASS: LSR Z=1 = 1
PASS: LSR N=0 (always after LSR) = 0
PASS: LSR $80 q = 40
PASS: LSR C=0 = 0
PASS: LSR N=0 = 0
PASS: ROL $80, C in=0 q = 00
PASS: ROL C out=1 = 1
PASS: ROL Z=1 = 1
PASS: ROL $40, C in=1 q = 81
PASS: ROL C out=0 = 0
PASS: ROL N=1 = 1
PASS: ROR $01, C in=0 q = 00
PASS: ROR C out=1 = 1
PASS: ROR Z=1 = 1
PASS: ROR $02, C in=1 q = 81
PASS: ROR C out=0 = 0
PASS: ROR N=1 = 1

=== SECTION 29: ALU ADC Binary Mode ===

PASS: ADC $00 + $00 + 0 q = 00
PASS: ADC C=0 = 0
PASS: ADC Z=1 = 1
PASS: ADC V=0 = 0
PASS: ADC N=0 = 0
PASS: ADC $7F + $01 + 0 q = 80
PASS: ADC V=1 (signed overflow) = 1
PASS: ADC N=1 = 1
PASS: ADC C=0 = 0
PASS: ADC $FF + $01 + 0 q = 00
PASS: ADC C=1 (carry out) = 1
PASS: ADC Z=1 = 1
PASS: ADC V=0 = 0
PASS: ADC $7F + $00 + 1 q = 80
PASS: ADC V=1 = 1
PASS: ADC $80 + $80 + 0 q = 00
PASS: ADC C=1 = 1
PASS: ADC V=1 (neg overflow) = 1
PASS: ADC $40 + $40 + 0 q = 80
PASS: ADC V=1 (pos overflow) = 1
PASS: ADC $50 + $30 + 0 q = 80
PASS: ADC V=1 (pos+pos=neg) = 1
PASS: ADC $50 + $10 + 0 q = 60
PASS: ADC V=0 (no overflow) = 0

=== SECTION 30: ALU ADC Decimal Mode ===

PASS: ADC BCD $09 + $01 q = 10
PASS: ADC BCD C=0 = 0
PASS: ADC BCD $49 + $49 q = 98
PASS: ADC BCD C=0 = 0
PASS: ADC BCD $50 + $50 q = 00
PASS: ADC BCD C=1 (high carry) = 1
PASS: ADC BCD $99 + $01 q = 00
PASS: ADC BCD C=1 (rollover) = 1
PASS: ADC BCD $99 + $99 q = 98
PASS: ADC BCD C=1 = 1
PASS: ADC BCD $25 + $25 + 1 q = 51
PASS: ADC BCD C=0 = 0

=== SECTION 31: ALU SBC Binary Mode ===

PASS: SBC $50 - $30 (C=1) q = 20
PASS: SBC C=1 (no borrow) = 1
PASS: SBC V=0 = 0
PASS: SBC N=0 = 0
PASS: SBC $50 - $30 - 1 (C=0) q = 1f
PASS: SBC C=1 = 1
PASS: SBC $00 - $01 (C=1) q = ff
PASS: SBC C=0 (borrow) = 0
PASS: SBC N=1 = 1
PASS: SBC $80 - $01 q = 7f
PASS: SBC V=1 (neg-pos=pos) = 1
PASS: SBC $7F - $FF q = 80
PASS: SBC V=1 (pos-neg=neg) = 1
PASS: SBC $42 - $42 q = 00
PASS: SBC Z=1 = 1
PASS: SBC C=1 = 1

=== SECTION 32: ALU SBC Decimal Mode ===

PASS: SBC BCD $50 - $25 q = 25
PASS: SBC BCD C=1 = 1
PASS: SBC BCD $00 - $01 q = 99
PASS: SBC BCD C=0 (borrow) = 0
PASS: SBC BCD $99 - $01 q = 98
PASS: SBC BCD C=1 = 1
PASS: SBC BCD $10 - $05 q = 05
PASS: SBC BCD C=1 = 1

=== SECTION 33: ALU CMP ===

PASS: CMP $42 == $42, Z=1 = 1
PASS: CMP C=1 (a >= b) = 1
PASS: CMP N=0 = 0
PASS: CMP $50 > $30, Z=0 = 0
PASS: CMP C=1 (a >= b) = 1
PASS: CMP N=0 = 0
PASS: CMP $30 < $50, Z=0 = 0
PASS: CMP C=0 (a < b) = 0
PASS: CMP N=1 = 1
PASS: CMP $42==$42 with p_in C=0 = 1
PASS: CMP C=1 regardless = 1
PASS: CMP preserves V preserved (1)

=== SECTION 34: ALU BIT ===

PASS: BIT N=1 (b[7]=1) = 1
PASS: BIT V=0 (b[6]=0) = 0
PASS: BIT Z=0 (a & b != 0) = 0
PASS: BIT N=1 = 1
PASS: BIT V=0 = 0
PASS: BIT Z=1 ($00 & $80 = 0) = 1
PASS: BIT N=0 (b[7]=0) = 0
PASS: BIT V=1 (b[6]=1) = 1
PASS: BIT N=1 (b[7]=1) = 1
PASS: BIT V=1 (b[6]=1) = 1
PASS: BIT N=0 = 0
PASS: BIT V=0 = 0
PASS: BIT Z=1 ($FF & $00 = 0) = 1
PASS: BIT preserves C preserved (1)

=== SECTION 35: VP_n Vector Pull ===

PASS: VP_n high during NOP = 00000001
PASS: BRK after cycle 1 VP_n=1 = 00000001
PASS: BRK after cycle 2 VP_n=1 = 00000001
PASS: BRK after cycle 3 VP_n=1 = 00000001
PASS: BRK after cycle 4 VP_n=1 = 00000001
PASS: BRK after cycle 5 VP_n=0 (vector lo coming) = 00000000
PASS: BRK after cycle 5 addr = $FFFE = 0000fffe
PASS: BRK after cycle 6 VP_n=0 (vector hi coming) = 00000000
PASS: BRK after cycle 6 addr = $FFFF = 0000ffff
PASS: BRK after cycle 7 VP_n=1 (vector done) = 00000001
PASS: BRK after cycle 7 addr = vector target = 00001300
PASS: IRQ after cycle 5 VP_n=0 = 00000000
PASS: IRQ after cycle 5 addr = $FFFE = 0000fffe
PASS: IRQ after cycle 6 VP_n=0 = 00000000
PASS: IRQ after cycle 6 addr = $FFFF = 0000ffff
PASS: IRQ after cycle 7 VP_n=1 = 00000001
PASS: NMI after cycle 5 VP_n=0 = 00000000
PASS: NMI after cycle 5 addr = $FFFA = 0000fffa
PASS: NMI after cycle 6 VP_n=0 = 00000000
PASS: NMI after cycle 6 addr = $FFFB = 0000fffb
PASS: NMI after cycle 7 VP_n=1 = 00000001
PASS: Reset vector fetch leaves VP_n high = 00000001

=== SECTION 36: RDY Stall ===

PASS: RDY=0 holds state at ST_IMM_T1 = 00000009
PASS: RDY=0 holds A unchanged = 00000000
PASS: RDY=0 second tick still holds = 00000009
PASS: RDY=0 third tick still holds = 00000009
PASS: RDY=1 resume completes LDA = 00000042
PASS: RDY=0 does not block write (RAM[$40] = $AB) = 000000ab
PASS: RDY=0 stalls operand-fetch read = 00000013
PASS: RDY released, LDA abs completes (A = $77) = 00000077

=============================================================
  x6502 Test Results
=============================================================
  Total Tests:  564
  Passed:       564
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
  Cycle-accurate to MCS6500 Hardware Manual
=============================================================
```
