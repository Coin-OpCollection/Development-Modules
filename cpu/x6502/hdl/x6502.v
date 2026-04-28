/*
* <-- Coin-Op Collection -->
* https://coinopcollection.org
* https://github.com/Coin-OpCollection/
*
* Author: atrac17 (https://twitter.com/_atrac17)
* Copyright © 2026 Coin-Op Collection
*
* This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/.
*
* You may use, share, and modify this code for non-commercial purposes, provided that proper credit is given.
*/

//============================================================================
//  Central Processing Unit for the NMOS 6502 microprocessor.
//
//  The CPU is implemented as an explicit per-cycle state machine without
//  microcode. Each FSM state corresponds to one bus cycle. Outputs (addr,
//  dout, rw_n, sync) are registered: each state's clocked update sets the
//  bus signals that the NEXT bus cycle will present.
//
//  Architecture Overview:
//    - 8-bit data bus, 16-bit address bus
//    - Six programmer-visible registers: A, X, Y, S, P, PC
//    - 151 documented opcodes, 13 addressing modes
//    - Stack page fixed at $0100 - $01FF
//    - Reset / IRQ / NMI vectors at $FFFA - $FFFF
//    - BCD support via the ALU when D flag is set
//
//  Instruction Sections (matching opcode map):
//    Section 1:  Registers and Reset
//    Section 2:  Instruction Fetch Cycle
//    Section 3:  Instruction Decode (Addressing-Mode Dispatch)
//    Section 4:  Implied / Inherent Operations (NOP, CLC, SEC, CLI, SEI, CLV, CLD, SED, INX, INY, DEX, DEY, TAX, TAY, TXA, TYA, TSX, TXS, ASL A, LSR A, ROL A, ROR A)
//    Section 5:  Immediate Addressing (LDA #, LDX #, LDY #, ADC #, SBC #, AND #, ORA #, EOR #, CMP #, CPX #, CPY #)
//    Section 6:  Zero Page Reads / Writes (LDA, LDX, LDY, ADC, SBC, AND, ORA, EOR, CMP, CPX, CPY, BIT, STA, STX, STY)
//    Section 7:  Zero Page Indexed Reads / Writes (LDA/LDY zp,X; LDX zp,Y; ADC/SBC/AND/ORA/EOR/CMP zp,X; STA/STY zp,X; STX zp,Y)
//    Section 8:  Absolute Reads / Writes (LDA, LDX, LDY, ADC, SBC, AND, ORA, EOR, CMP, CPX, CPY, BIT, STA, STX, STY)
//    Section 9:  Absolute Indexed Reads / Writes (LDA abs,X/Y; LDY abs,X; LDX abs,Y; ADC/SBC/AND/ORA/EOR/CMP abs,X/Y; STA abs,X/Y)
//    Section 10: Indexed Indirect (ZP,X) Operations (LDA, ADC, SBC, AND, ORA, EOR, CMP, STA)
//    Section 11: Indirect Indexed (ZP),Y Operations (LDA, ADC, SBC, AND, ORA, EOR, CMP, STA)
//    Section 12: Stack Push / Pull (PHA, PHP, PLA, PLP)
//    Section 13: Subroutine Instructions (JSR absolute, RTS)
//    Section 14: Read-Modify-Write (ASL, LSR, ROL, ROR, INC, DEC on zp / zp,X / abs / abs,X)
//    Section 15: Conditional Branches (BPL, BMI, BVC, BVS, BCC, BCS, BNE, BEQ)
//    Section 16: Unconditional Jumps (JMP absolute, JMP indirect with NMOS page-wrap bug)
//    Section 17: Interrupt Instructions (BRK, RTI, IRQ injection, NMI injection)
//
//  Cycle Timing (NMOS 6502, MCS6500 Hardware Manual):
//    Implied / accumulator : 2 cycles
//    Immediate             : 2 cycles
//    Zero page read        : 3 cycles
//    Zero page write       : 3 cycles
//    Zero page,X/Y read    : 4 cycles
//    Zero page,X/Y write   : 4 cycles
//    Absolute read         : 4 cycles
//    Absolute write        : 4 cycles
//    Absolute,X/Y read     : 4 cycles (+1 if page cross)
//    Absolute,X/Y write    : 5 cycles
//    (ZP,X) read / write   : 6 cycles
//    (ZP),Y read           : 5 cycles (+1 if page cross)
//    (ZP),Y write          : 6 cycles
//    Stack push (PHA/PHP)  : 3 cycles
//    Stack pull (PLA/PLP)  : 4 cycles
//    JSR / RTS             : 6 cycles
//    RMW zp                : 5 cycles
//    RMW zp,X              : 6 cycles
//    RMW abs               : 6 cycles
//    RMW abs,X             : 7 cycles (fixed)
//    BRK / IRQ / NMI       : 7 cycles
//    RTI                   : 6 cycles
//    Branch not taken      : 2 cycles
//    Branch taken          : 3 cycles (+1 if page cross)
//    JMP absolute          : 3 cycles
//    JMP indirect          : 5 cycles
//    Reset                 : 7 internal cycles + first opcode fetch
//
//  Bus Signal Timing:
//    Each FSM state sets addr / dout / rw_n / sync to the values the bus
//    must show during the NEXT cycle. Inputs (din, irq_n, nmi_n, so_n,
//    rdy) are sampled at the rising clock edge of the cycle they appear
//    on the bus. The CPU advances one bus cycle per cen pulse.
//
//  Reference: MOS Technology MCS6500 Microcomputer Family Hardware Manual,
//             January 1976
//============================================================================

`timescale 1ns/1ps

module x6502 (
    // Clock and Reset
    input  wire        clk,   // System clock
    input  wire        cen,   // Clock enable (one bus cycle per pulse)
    input  wire        rst_n, // Active-low reset (RES pin)
    input  wire        rdy,   // Active-high ready (RDY pin)

    // Interrupt Inputs
    input  wire        irq_n, // IRQ
    input  wire        nmi_n, // NMI
    input  wire        so_n,  // Set-Overflow

    // CPU Bus Interface
    output reg  [15:0] addr,  // Address bus
    input  wire  [7:0] din,   // Data in
    output reg   [7:0] dout,  // Data out
    output reg         rw_n,  // R/W (high=read, low=write)
    output reg         sync,  // High during opcode fetch cycle (T0)
    output reg         vp_n   // Vector Pull (low during IRQ/NMI/BRK vector fetch)
);

//------------------------------------------------------------------------
// FSM State Encoding:
// One state per bus cycle. State numbers are sequential within each
// addressing-mode group; new groups added in later phases extend this
// encoding without renumbering the existing states.
//------------------------------------------------------------------------
localparam [6:0]
    ST_RESET_0   = 7'd0,
    ST_RESET_1   = 7'd1,
    ST_RESET_2   = 7'd2,
    ST_RESET_3   = 7'd3,
    ST_RESET_4   = 7'd4,
    ST_RESET_5   = 7'd5,
    ST_RESET_6   = 7'd6,
    ST_FETCH     = 7'd7,
    ST_IMP_T1    = 7'd8,
    ST_IMM_T1    = 7'd9,
    ST_ZP_R_T1   = 7'd10,
    ST_ZP_R_T2   = 7'd11,
    ST_ZP_W_T1   = 7'd12,
    ST_ZP_W_T2   = 7'd13,
    ST_BR_T1     = 7'd14,
    ST_BR_T2     = 7'd15,
    ST_BR_T3     = 7'd16,
    ST_JMP_T1    = 7'd17,
    ST_JMP_T2    = 7'd18,
    ST_ABS_R_T1  = 7'd19,
    ST_ABS_R_T2  = 7'd20,
    ST_ABS_R_T3  = 7'd21,
    ST_ABS_W_T1  = 7'd22,
    ST_ABS_W_T2  = 7'd23,
    ST_ABS_W_T3  = 7'd24,
    ST_PUSH_T1   = 7'd25,
    ST_PUSH_T2   = 7'd26,
    ST_PULL_T1   = 7'd27,
    ST_PULL_T2   = 7'd28,
    ST_PULL_T3   = 7'd29,
    ST_JMI_T1    = 7'd30,
    ST_JMI_T2    = 7'd31,
    ST_JMI_T3    = 7'd32,
    ST_JMI_T4    = 7'd33,
    ST_ZPI_R_T1  = 7'd34,
    ST_ZPI_R_T2  = 7'd35,
    ST_ZPI_R_T3  = 7'd36,
    ST_ZPI_W_T1  = 7'd37,
    ST_ZPI_W_T2  = 7'd38,
    ST_ZPI_W_T3  = 7'd39,
    ST_AXY_R_T1  = 7'd40,
    ST_AXY_R_T2  = 7'd41,
    ST_AXY_R_T3  = 7'd42,
    ST_AXY_R_T4  = 7'd43,
    ST_AXY_W_T1  = 7'd44,
    ST_AXY_W_T2  = 7'd45,
    ST_AXY_W_T3  = 7'd46,
    ST_AXY_W_T4  = 7'd47,
    ST_INX_T1    = 7'd48,
    ST_INX_T2    = 7'd49,
    ST_INX_T3    = 7'd50,
    ST_INX_T4    = 7'd51,
    ST_INX_T5    = 7'd52,
    ST_INY_T1    = 7'd53,
    ST_INY_T2    = 7'd54,
    ST_INY_T3    = 7'd55,
    ST_INY_R_T4  = 7'd56,
    ST_INY_R_T5  = 7'd57,
    ST_INY_W_T4  = 7'd58,
    ST_INY_W_T5  = 7'd59,
    ST_JSR_T1    = 7'd60,
    ST_JSR_T2    = 7'd61,
    ST_JSR_T3    = 7'd62,
    ST_JSR_T4    = 7'd63,
    ST_JSR_T5    = 7'd64,
    ST_RTS_T1    = 7'd65,
    ST_RTS_T2    = 7'd66,
    ST_RTS_T3    = 7'd67,
    ST_RTS_T4    = 7'd68,
    ST_RTS_T5    = 7'd69,
    ST_RMW_ZP_T1 = 7'd70,
    ST_RMW_ZP_T2 = 7'd71,
    ST_RMW_ZP_T3 = 7'd72,
    ST_RMW_ZP_T4 = 7'd73,
    ST_RMW_ZX_T1 = 7'd74,
    ST_RMW_ZX_T2 = 7'd75,
    ST_RMW_ZX_T3 = 7'd76,
    ST_RMW_ZX_T4 = 7'd77,
    ST_RMW_ZX_T5 = 7'd78,
    ST_RMW_AB_T1 = 7'd79,
    ST_RMW_AB_T2 = 7'd80,
    ST_RMW_AB_T3 = 7'd81,
    ST_RMW_AB_T4 = 7'd82,
    ST_RMW_AB_T5 = 7'd83,
    ST_RMW_AX_T1 = 7'd84,
    ST_RMW_AX_T2 = 7'd85,
    ST_RMW_AX_T3 = 7'd86,
    ST_RMW_AX_T4 = 7'd87,
    ST_RMW_AX_T5 = 7'd88,
    ST_RMW_AX_T6 = 7'd89,
    ST_BRK_T1    = 7'd90,
    ST_BRK_T2    = 7'd91,
    ST_BRK_T3    = 7'd92,
    ST_BRK_T4    = 7'd93,
    ST_BRK_T5    = 7'd94,
    ST_BRK_T6    = 7'd95,
    ST_RTI_T1    = 7'd96,
    ST_RTI_T2    = 7'd97,
    ST_RTI_T3    = 7'd98,
    ST_RTI_T4    = 7'd99,
    ST_RTI_T5    = 7'd100;

//------------------------------------------------------------------------
// ALU Operation Codes:
// Match the encoding in x6502_alu.v.
//------------------------------------------------------------------------
localparam [3:0]
    ALU_OR  = 4'h0,
    ALU_AND = 4'h1,
    ALU_EOR = 4'h2,
    ALU_ADC = 4'h3,
    ALU_EQ1 = 4'h4,
    ALU_EQ2 = 4'h5,
    ALU_CMP = 4'h6,
    ALU_SBC = 4'h7,
    ALU_ASL = 4'h8,
    ALU_ROL = 4'h9,
    ALU_LSR = 4'hA,
    ALU_ROR = 4'hB,
    ALU_BIT = 4'hC,
    ALU_DEC = 4'hD,
    ALU_INC = 4'hE;

//------------------------------------------------------------------------
// Processor Status Register Bit Positions:
//   0 : C  carry
//   1 : Z  zero
//   2 : I  interrupt mask
//   3 : D  decimal
//   4 : B  break
//   5 : 1  always reads as 1 on NMOS
//   6 : V  overflow
//   7 : N  negative
//------------------------------------------------------------------------
localparam FLAG_C = 0;
localparam FLAG_Z = 1;
localparam FLAG_I = 2;
localparam FLAG_D = 3;
localparam FLAG_B = 4;
localparam FLAG_1 = 5;
localparam FLAG_V = 6;
localparam FLAG_N = 7;

//------------------------------------------------------------------------
// CPU Registers:
// Programmer-visible state plus instruction register and addressing
// scratch registers.
//------------------------------------------------------------------------
reg  [7:0] reg_a;     // Accumulator
reg  [7:0] reg_x;     // X index
reg  [7:0] reg_y;     // Y index
reg  [7:0] reg_s;     // Stack pointer (low byte; high byte is $01)
reg  [7:0] reg_p;     // Processor status
reg [15:0] reg_pc;    // Program counter
reg  [7:0] ir;        // Instruction register (current opcode)
reg  [7:0] ad;        // Addressing scratch (low byte)
reg  [7:0] bal;       // Bus address low
reg  [7:0] bah;       // Bus address high
reg  [7:0] dl;        // Data latch (also branch offset latch)
reg        idx_cross; // Indexed-absolute page-cross flag
reg  [6:0] state;     // FSM state

//------------------------------------------------------------------------
// Index Register Select:
// Most indexed opcodes use X. The exceptions LDX zp,Y / STX zp,Y on the
// zero-page side and LDA/LDX/STA/ADC/SBC/AND/ORA/EOR/CMP abs,Y on the
// absolute side use Y. Pre-decoded here so the indexed-mode states can
// share the same address calculation without a per-state opcode case.
//------------------------------------------------------------------------
wire is_idx_y_zp  = (ir == 8'hB6) | (ir == 8'h96);
wire is_idx_y_abs = (ir == 8'hB9) | (ir == 8'hBE) |
                    (ir == 8'h99) | (ir == 8'h79) |
                    (ir == 8'hF9) | (ir == 8'h39) |
                    (ir == 8'h19) | (ir == 8'h59) |
                    (ir == 8'hD9);

wire [7:0] idx_zp  = is_idx_y_zp  ? reg_y : reg_x;
wire [7:0] idx_abs = is_idx_y_abs ? reg_y : reg_x;

//------------------------------------------------------------------------
// Interrupt Sync Chain and Latches:
// nmi_n_sync, irq_n_sync, so_n_sync hold the previous-cycle values of
// the chip pins so falling edges (NMI, SO) can be detected. nmi_latch
// records the NMI request from a falling edge and is cleared by the
// CPU when the NMI is acknowledged. int_kind selects between the BRK
// instruction (00), an IRQ (01), and an NMI (10) for the shared push /
// vector-fetch sequence.
//------------------------------------------------------------------------
reg nmi_n_sync;
reg irq_n_sync;
reg so_n_sync;
reg nmi_latch;

reg [1:0] int_kind;

//------------------------------------------------------------------------
// ALU Wires and Drive Registers:
// alu_a / alu_b / alu_op_sel are driven combinationally from current
// state and ir. The ALU output (alu_q, alu_p) is available within the
// same cycle for the state machine to latch at the clock edge.
//------------------------------------------------------------------------
reg  [7:0] alu_a;
reg  [7:0] alu_b;
reg  [3:0] alu_op_sel;
wire [7:0] alu_q;
wire [7:0] alu_p;

x6502_alu u_alu (
    .a     ( alu_a      ),
    .b     ( alu_b      ),
    .op    ( alu_op_sel ),
    .p_in  ( reg_p      ),
    .q     ( alu_q      ),
    .p_out ( alu_p      )
);

//========================================================================
// Combinational ALU Input Drive:
// The ALU is consulted on cycles where an arithmetic or logical result
// is required at the clock edge. The drive selects operands and op
// based on the current state and the latched opcode.
//========================================================================
always @(*) begin
    // Defaults
    alu_a = reg_a;
    alu_b = din;
    alu_op_sel = ALU_EQ1;

    case(state)
        //----------------------------------------------------------------
        // Implied / Accumulator T1:
        // INX, INY, DEX, DEY use INC / DEC on the index register.
        // Transfers (TAX, TAY, TXA, TYA, TSX) use EQ2 to update N and Z
        // from the source value. Accumulator shifts route A through the
        // shift / rotate ops. Flag set/clear ops bypass the ALU.
        //----------------------------------------------------------------
        ST_IMP_T1: begin
            case(ir)
                8'hE8 : begin alu_a = reg_x; alu_op_sel = ALU_INC; end // INX
                8'hC8 : begin alu_a = reg_y; alu_op_sel = ALU_INC; end // INY
                8'hCA : begin alu_a = reg_x; alu_op_sel = ALU_DEC; end // DEX
                8'h88 : begin alu_a = reg_y; alu_op_sel = ALU_DEC; end // DEY
                8'hAA : begin alu_a = reg_a; alu_op_sel = ALU_EQ2; end // TAX
                8'hA8 : begin alu_a = reg_a; alu_op_sel = ALU_EQ2; end // TAY
                8'h8A : begin alu_a = reg_x; alu_op_sel = ALU_EQ2; end // TXA
                8'h98 : begin alu_a = reg_y; alu_op_sel = ALU_EQ2; end // TYA
                8'hBA : begin alu_a = reg_s; alu_op_sel = ALU_EQ2; end // TSX
                8'h0A : begin alu_a = reg_a; alu_op_sel = ALU_ASL; end // ASL A
                8'h4A : begin alu_a = reg_a; alu_op_sel = ALU_LSR; end // LSR A
                8'h2A : begin alu_a = reg_a; alu_op_sel = ALU_ROL; end // ROL A
                8'h6A : begin alu_a = reg_a; alu_op_sel = ALU_ROR; end // ROR A
                default : begin alu_a = reg_a; alu_op_sel = ALU_EQ1; end
            endcase
        end

        //----------------------------------------------------------------
        // Immediate T1:
        // The operand is on din. Decode op-class and source register
        // from the opcode.
        //----------------------------------------------------------------
        ST_IMM_T1: begin
            case(ir)
                8'hA9 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDA #
                8'hA2 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDX #
                8'hA0 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDY #
                8'h69 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_ADC; end // ADC #
                8'hE9 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_SBC; end // SBC #
                8'h29 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_AND; end // AND #
                8'h09 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_OR;  end // ORA #
                8'h49 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_EOR; end // EOR #
                8'hC9 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_CMP; end // CMP #
                8'hE0 : begin alu_a = reg_x; alu_b = din; alu_op_sel = ALU_CMP; end // CPX #
                8'hC0 : begin alu_a = reg_y; alu_b = din; alu_op_sel = ALU_CMP; end // CPY #
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // Zero Page Read T2:
        // Memory data on din. Same op-class decode as immediate.
        //----------------------------------------------------------------
        ST_ZP_R_T2: begin
            case(ir)
                8'hA5 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDA zp
                8'hA6 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDX zp
                8'hA4 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDY zp
                8'h65 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_ADC; end // ADC zp
                8'hE5 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_SBC; end // SBC zp
                8'h25 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_AND; end // AND zp
                8'h05 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_OR;  end // ORA zp
                8'h45 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_EOR; end // EOR zp
                8'hC5 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_CMP; end // CMP zp
                8'hE4 : begin alu_a = reg_x; alu_b = din; alu_op_sel = ALU_CMP; end // CPX zp
                8'hC4 : begin alu_a = reg_y; alu_b = din; alu_op_sel = ALU_CMP; end // CPY zp
                8'h24 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_BIT; end // BIT zp
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // Pull T3:
        // Stack data on din. Only PLA routes the byte through the ALU
        // (EQ2 to update N and Z); PLP latches P directly without ALU.
        //----------------------------------------------------------------
        ST_PULL_T3: begin
            case(ir)
                8'h68 : begin alu_a = din; alu_op_sel = ALU_EQ2; end // PLA
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // Absolute Read T3:
        // Effective address on the bus, memory data on din. Same op-class
        // decode as zero page read.
        //----------------------------------------------------------------
        ST_ABS_R_T3: begin
            case(ir)
                8'hAD : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDA abs
                8'hAE : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDX abs
                8'hAC : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDY abs
                8'h6D : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_ADC; end // ADC abs
                8'hED : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_SBC; end // SBC abs
                8'h2D : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_AND; end // AND abs
                8'h0D : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_OR;  end // ORA abs
                8'h4D : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_EOR; end // EOR abs
                8'hCD : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_CMP; end // CMP abs
                8'hEC : begin alu_a = reg_x; alu_b = din; alu_op_sel = ALU_CMP; end // CPX abs
                8'hCC : begin alu_a = reg_y; alu_b = din; alu_op_sel = ALU_CMP; end // CPY abs
                8'h2C : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_BIT; end // BIT abs
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // Zero Page Indexed Read T3:
        // Indexed effective address on the bus, memory data on din.
        //----------------------------------------------------------------
        ST_ZPI_R_T3: begin
            case(ir)
                8'hB5 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDA zp,X
                8'hB4 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDY zp,X
                8'hB6 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDX zp,Y
                8'h75 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_ADC; end // ADC zp,X
                8'hF5 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_SBC; end // SBC zp,X
                8'h35 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_AND; end // AND zp,X
                8'h15 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_OR;  end // ORA zp,X
                8'h55 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_EOR; end // EOR zp,X
                8'hD5 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_CMP; end // CMP zp,X
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // Absolute Indexed Read T3 / T4:
        // T3 reads from the speculative (uncrossed) address; if no page
        // cross occurred this is the final data and the ALU output is
        // latched. T4 only runs when a page cross was detected; din then
        // carries the data from the corrected address. ALU drive is
        // identical for both states because the op-class decode does not
        // depend on which state ultimately latches the result.
        //----------------------------------------------------------------
        ST_AXY_R_T3,
        ST_AXY_R_T4: begin
            case(ir)
                8'hBD, 8'hB9 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDA abs,X / abs,Y
                8'hBE        : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDX abs,Y
                8'hBC        : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDY abs,X
                8'h7D, 8'h79 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_ADC; end // ADC abs,X/Y
                8'hFD, 8'hF9 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_SBC; end // SBC abs,X/Y
                8'h3D, 8'h39 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_AND; end // AND abs,X/Y
                8'h1D, 8'h19 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_OR;  end // ORA abs,X/Y
                8'h5D, 8'h59 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_EOR; end // EOR abs,X/Y
                8'hDD, 8'hD9 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_CMP; end // CMP abs,X/Y
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // Indexed Indirect Read T5 (IND,X) and Indirect Indexed Read
        // T4/T5 (IND,Y):
        // Memory data on din at the indirect target. STA paths do not
        // route through the ALU.
        //----------------------------------------------------------------
        ST_INX_T5,
        ST_INY_R_T4,
        ST_INY_R_T5: begin
            case(ir)
                8'hA1, 8'hB1 : begin alu_a = din;   alu_op_sel = ALU_EQ2; end              // LDA
                8'h61, 8'h71 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_ADC; end // ADC
                8'hE1, 8'hF1 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_SBC; end // SBC
                8'h21, 8'h31 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_AND; end // AND
                8'h01, 8'h11 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_OR;  end // ORA
                8'h41, 8'h51 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_EOR; end // EOR
                8'hC1, 8'hD1 : begin alu_a = reg_a; alu_b = din; alu_op_sel = ALU_CMP; end // CMP
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // RMW Data-Read States:
        // Memory data on din. The ALU shift / rotate / inc / dec ops
        // produce the modified value, which the FSM latches at the end
        // of the cycle for the actual write two cycles later. The same
        // op-class decode applies to all RMW addressing modes.
        //----------------------------------------------------------------
        ST_RMW_ZP_T2,
        ST_RMW_ZX_T3,
        ST_RMW_AB_T3,
        ST_RMW_AX_T4: begin
            case(ir)
                8'h06, 8'h16, 8'h0E, 8'h1E : begin alu_a = din; alu_op_sel = ALU_ASL; end // ASL
                8'h26, 8'h36, 8'h2E, 8'h3E : begin alu_a = din; alu_op_sel = ALU_ROL; end // ROL
                8'h46, 8'h56, 8'h4E, 8'h5E : begin alu_a = din; alu_op_sel = ALU_LSR; end // LSR
                8'h66, 8'h76, 8'h6E, 8'h7E : begin alu_a = din; alu_op_sel = ALU_ROR; end // ROR
                8'hC6, 8'hD6, 8'hCE, 8'hDE : begin alu_a = din; alu_op_sel = ALU_DEC; end // DEC
                8'hE6, 8'hF6, 8'hEE, 8'hFE : begin alu_a = din; alu_op_sel = ALU_INC; end // INC
                default : ;
            endcase
        end

        default : ;
    endcase
end

//========================================================================
// Combinational Branch Decode:
// Selects the polarity-checked flag for the eight conditional branch
// opcodes. ir[7:6] selects the flag (00=N, 01=V, 10=C, 11=Z) and ir[5]
// selects the polarity (0=branch on clear, 1=branch on set).
//========================================================================
reg br_flag;
reg br_take;

always @* begin
    case(ir[7:6])
        2'b00 : br_flag = reg_p[FLAG_N];
        2'b01 : br_flag = reg_p[FLAG_V];
        2'b10 : br_flag = reg_p[FLAG_C];
        2'b11 : br_flag = reg_p[FLAG_Z];
    endcase
    br_take = (br_flag == ir[5]);
end

//========================================================================
// Branch Target Computation:
// Sign-extends the offset latched in dl and computes the new PCL plus
// page-cross direction. PCL update uses an 8-bit add; page-cross
// detection cross-checks the carry against the offset sign.
//========================================================================
wire [8:0] pcl_sum         = {1'b0, reg_pc[7:0]} + {1'b0, dl};
wire       pcl_carry       = pcl_sum[8];
wire       page_cross_pos  = (dl[7] == 1'b0) && pcl_carry;
wire       page_cross_neg  = (dl[7] == 1'b1) && (~pcl_carry);
wire       page_cross      = page_cross_pos | page_cross_neg;
wire [7:0] new_pch         = page_cross_pos ? (reg_pc[15:8] + 8'd1) : page_cross_neg ? (reg_pc[15:8] - 8'd1) : reg_pc[15:8];

//========================================================================
// Indexed Absolute Sum:
// 9-bit add of the latched low byte (ad) plus the per-mode index. The
// upper bit is the page-cross flag and the lower byte is the indexed
// low byte. Used in T2 of both ABS,X/Y read and write paths.
//========================================================================
wire [8:0] axy_lo_sum = {1'b0, ad} + {1'b0, idx_abs};

//========================================================================
// Indirect-Y Sum:
// 9-bit add of the latched pointer low byte (bal) plus Y. Used in T3
// of (ZP),Y read and write paths to derive the speculative low byte
// and the page-cross flag.
//========================================================================
wire [8:0] iny_lo_sum = {1'b0, bal} + {1'b0, reg_y};

//========================================================================
// Main State Machine:
// One always block, synchronous reset, single-process FSM. Each state
// case sets the bus signals (addr, dout, rw_n, sync) for the NEXT cycle
// and updates internal registers based on inputs sampled this cycle.
//========================================================================
always @(posedge clk) begin
    if(~rst_n) begin
        // Programmer-visible registers
        reg_a <= 8'h00;
        reg_x <= 8'h00;
        reg_y <= 8'h00;
        reg_s <= 8'h00;
        reg_p <= 8'h24; // I=1, bit 5 always 1
        reg_pc <= 16'h0000;

        // Internal state
        ir <= 8'h00;
        ad <= 8'h00;
        bal <= 8'h00;
        bah <= 8'h00;
        dl <= 8'h00;
        idx_cross <= 1'b0;
        state <= ST_RESET_0;

        // Bus outputs
        addr <= 16'h00FF;
        dout <= 8'h00;
        rw_n <= 1'b1;
        sync <= 1'b0;
        vp_n <= 1'b1;

        // Interrupt sync chain
        nmi_n_sync <= 1'b1;
        irq_n_sync <= 1'b1;
        so_n_sync <= 1'b1;
        nmi_latch <= 1'b0;
        int_kind <= 2'b00;
    end else if(cen && (rdy || ~rw_n)) begin
        // RDY-low halts the CPU on read cycles per MCS6500 manual.
        // Write cycles complete regardless of rdy so external logic
        // cannot lose a pending write. The state machine and the
        // interrupt sync chain only advance when this gate is open.
        // Sync chain advances every cen cycle
        nmi_n_sync <= nmi_n;
        irq_n_sync <= irq_n;
        so_n_sync <= so_n;

        // SO falling edge sets V
        if(so_n_sync == 1'b1 && so_n == 1'b0)
            reg_p[FLAG_V] <= 1'b1;

        // NMI falling edge latches into nmi_latch; cleared when the
        // CPU enters the BRK sequence with int_kind = NMI.
        if(nmi_n_sync == 1'b1 && nmi_n == 1'b0)
            nmi_latch <= 1'b1;

        // Default per-cycle bus output settings (overridden by state)
        sync <= 1'b0;
        rw_n <= 1'b1;
        vp_n <= 1'b1;

        case(state)
            //============================================================
            // Reset Sequence:
            // 7 internal cycles followed by vector fetch from $FFFC and
            // $FFFD. S decrements three times during the dummy push
            // cycles per the MCS6500 Hardware Manual reset behaviour.
            //============================================================
            ST_RESET_0: begin
                addr <= 16'h00FF;
                state <= ST_RESET_1;
            end

            ST_RESET_1: begin
                addr <= 16'h00FF;
                state <= ST_RESET_2;
            end

            ST_RESET_2: begin
                reg_s <= reg_s - 8'd1;
                addr <= {8'h01, reg_s};
                state <= ST_RESET_3;
            end

            ST_RESET_3: begin
                reg_s <= reg_s - 8'd1;
                addr <= {8'h01, reg_s - 8'd1};
                state <= ST_RESET_4;
            end

            ST_RESET_4: begin
                reg_s <= reg_s - 8'd1;
                addr <= 16'hFFFC;
                state <= ST_RESET_5;
            end

            ST_RESET_5: begin
                // din has PCL from $FFFC
                dl <= din;
                addr <= 16'hFFFD;
                state <= ST_RESET_6;
            end

            ST_RESET_6: begin
                // din has PCH from $FFFD; build PC and start fetching
                reg_pc <= {din, dl};
                addr <= {din, dl};
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Opcode Fetch and Dispatch (T0):
            // The opcode is on din. Latch into ir, advance PC, and route
            // to the appropriate addressing-mode start state. The
            // default address bus value is the operand byte (PC after
            // increment) which serves T1 of immediate, ZP, branch, and
            // JMP. Implied operations also use this address as a dummy
            // read target.
            //
            // Interrupt insertion: NMI takes priority over IRQ; IRQ is
            // gated by the I flag. When an interrupt is pending the
            // CPU does not latch the fetched opcode and does not
            // advance PC; it routes instead to the shared BRK push /
            // vector-fetch sequence with int_kind selecting which
            // vector to read and whether B is set in the pushed P.
            //============================================================
            ST_FETCH: begin
                if(nmi_latch) begin
                    int_kind <= 2'b10; // NMI
                    nmi_latch <= 1'b0; // ack
                    addr <= reg_pc; // dummy read target for T1
                    state <= ST_BRK_T1;
                end else if(~irq_n_sync && ~reg_p[FLAG_I]) begin
                    int_kind <= 2'b01; // IRQ
                    addr <= reg_pc;
                    state <= ST_BRK_T1;
                end else begin
                    ir <= din;
                    reg_pc <= reg_pc + 16'd1;
                    addr <= reg_pc + 16'd1;

                case(din)
                    // Implied / accumulator (2 cycles)
                    8'hEA, 8'h18, 8'h38, 8'h58, 8'h78,
                    8'hB8, 8'hD8, 8'hF8,
                    8'hE8, 8'hC8, 8'hCA, 8'h88,
                    8'hAA, 8'hA8, 8'h8A, 8'h98,
                    8'hBA, 8'h9A,
                    8'h0A, 8'h4A, 8'h2A, 8'h6A : state <= ST_IMP_T1;

                    // Immediate (2 cycles)
                    8'hA9, 8'hA2, 8'hA0,
                    8'h69, 8'hE9, 8'h29, 8'h09, 8'h49,
                    8'hC9, 8'hE0, 8'hC0 : state <= ST_IMM_T1;

                    // Zero page read (3 cycles)
                    8'hA5, 8'hA6, 8'hA4,
                    8'h65, 8'hE5, 8'h25, 8'h05, 8'h45,
                    8'hC5, 8'hE4, 8'hC4, 8'h24 : state <= ST_ZP_R_T1;

                    // Zero page write (3 cycles)
                    8'h85, 8'h86, 8'h84 : state <= ST_ZP_W_T1;

                    // Absolute read (4 cycles)
                    8'hAD, 8'hAE, 8'hAC,
                    8'h6D, 8'hED, 8'h2D, 8'h0D, 8'h4D,
                    8'hCD, 8'hEC, 8'hCC, 8'h2C : state <= ST_ABS_R_T1;

                    // Absolute write (4 cycles)
                    8'h8D, 8'h8E, 8'h8C : state <= ST_ABS_W_T1;

                    // Stack push (3 cycles)
                    8'h48, 8'h08 : state <= ST_PUSH_T1;

                    // Stack pull (4 cycles)
                    8'h68, 8'h28 : state <= ST_PULL_T1;

                    // Zero page indexed read (4 cycles)
                    8'hB5, 8'hB4, 8'hB6,
                    8'h75, 8'hF5, 8'h35, 8'h15, 8'h55,
                    8'hD5 : state <= ST_ZPI_R_T1;

                    // Zero page indexed write (4 cycles)
                    8'h95, 8'h94, 8'h96 : state <= ST_ZPI_W_T1;

                    // Absolute indexed read (4 cycles, +1 on page cross)
                    8'hBD, 8'hBC, 8'hB9, 8'hBE,
                    8'h7D, 8'h79, 8'hFD, 8'hF9,
                    8'h3D, 8'h39, 8'h1D, 8'h19,
                    8'h5D, 8'h59, 8'hDD, 8'hD9 : state <= ST_AXY_R_T1;

                    // Absolute indexed write (5 cycles, fixed)
                    8'h9D, 8'h99 : state <= ST_AXY_W_T1;

                    // Indexed indirect (ZP,X) read (6 cycles)
                    8'hA1, 8'h21, 8'h01, 8'h41,
                    8'h61, 8'hC1, 8'hE1 : state <= ST_INX_T1;

                    // Indexed indirect (ZP,X) write (6 cycles)
                    8'h81 : state <= ST_INX_T1;

                    // Indirect indexed (ZP),Y read (5 cycles, +1 page cross)
                    8'hB1, 8'h31, 8'h11, 8'h51,
                    8'h71, 8'hD1, 8'hF1 : state <= ST_INY_T1;

                    // Indirect indexed (ZP),Y write (6 cycles, fixed)
                    8'h91 : state <= ST_INY_T1;

                    // JSR absolute (6 cycles)
                    8'h20 : state <= ST_JSR_T1;

                    // RTS (6 cycles)
                    8'h60 : state <= ST_RTS_T1;

                    // RMW zero page (5 cycles)
                    8'h06, 8'h26, 8'h46, 8'h66,
                    8'hC6, 8'hE6 : state <= ST_RMW_ZP_T1;

                    // RMW zero page,X (6 cycles)
                    8'h16, 8'h36, 8'h56, 8'h76,
                    8'hD6, 8'hF6 : state <= ST_RMW_ZX_T1;

                    // RMW absolute (6 cycles)
                    8'h0E, 8'h2E, 8'h4E, 8'h6E,
                    8'hCE, 8'hEE : state <= ST_RMW_AB_T1;

                    // RMW absolute,X (7 cycles)
                    8'h1E, 8'h3E, 8'h5E, 8'h7E,
                    8'hDE, 8'hFE : state <= ST_RMW_AX_T1;

                    // Branches (2/3/4 cycles)
                    8'h10, 8'h30, 8'h50, 8'h70,
                    8'h90, 8'hB0, 8'hD0, 8'hF0 : state <= ST_BR_T1;

                    // JMP absolute (3 cycles)
                    8'h4C : state <= ST_JMP_T1;

                    // JMP indirect (5 cycles, NMOS page-wrap bug)
                    8'h6C : state <= ST_JMI_T1;

                    // BRK (7 cycles, software interrupt). PC advances
                    // an extra byte so the pushed return address is
                    // BRK_addr + 2; this is the documented NMOS BRK
                    // skip behaviour.
                    8'h00 : begin
                        int_kind <= 2'b00;
                        reg_pc <= reg_pc + 16'd2;
                        state <= ST_BRK_T1;
                    end

                    // RTI (6 cycles)
                    8'h40 : state <= ST_RTI_T1;

                    // Anything not implemented yet acts as a 2-cycle
                    // no-op so the FSM does not stall.
                    default : state <= ST_IMP_T1;
                endcase
                end  // close else (normal fetch path)
            end

            //============================================================
            // Implied / Accumulator T1:
            // Performs the operation and returns to fetch. The bus is
            // already pointed at the operand-following byte (which is
            // the next opcode for 2-cycle ops); the dummy read on this
            // cycle has no effect on register state.
            //============================================================
            ST_IMP_T1: begin
                case(ir)
                    8'h18 : reg_p[FLAG_C] <= 1'b0;                    // CLC
                    8'h38 : reg_p[FLAG_C] <= 1'b1;                    // SEC
                    8'h58 : reg_p[FLAG_I] <= 1'b0;                    // CLI
                    8'h78 : reg_p[FLAG_I] <= 1'b1;                    // SEI
                    8'hB8 : reg_p[FLAG_V] <= 1'b0;                    // CLV
                    8'hD8 : reg_p[FLAG_D] <= 1'b0;                    // CLD
                    8'hF8 : reg_p[FLAG_D] <= 1'b1;                    // SED
                    8'hE8 : begin reg_x <= alu_q; reg_p <= alu_p; end // INX
                    8'hC8 : begin reg_y <= alu_q; reg_p <= alu_p; end // INY
                    8'hCA : begin reg_x <= alu_q; reg_p <= alu_p; end // DEX
                    8'h88 : begin reg_y <= alu_q; reg_p <= alu_p; end // DEY
                    8'hAA : begin reg_x <= alu_q; reg_p <= alu_p; end // TAX
                    8'hA8 : begin reg_y <= alu_q; reg_p <= alu_p; end // TAY
                    8'h8A : begin reg_a <= alu_q; reg_p <= alu_p; end // TXA
                    8'h98 : begin reg_a <= alu_q; reg_p <= alu_p; end // TYA
                    8'hBA : begin reg_x <= alu_q; reg_p <= alu_p; end // TSX
                    8'h9A : reg_s <= reg_x;                           // TXS (no flags)
                    8'h0A : begin reg_a <= alu_q; reg_p <= alu_p; end // ASL A
                    8'h4A : begin reg_a <= alu_q; reg_p <= alu_p; end // LSR A
                    8'h2A : begin reg_a <= alu_q; reg_p <= alu_p; end // ROL A
                    8'h6A : begin reg_a <= alu_q; reg_p <= alu_p; end // ROR A
                    default : ;                                       // NOP and stubs
                endcase

                // Bus already points at next opcode; just assert sync
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Immediate T1:
            // Operand on din has been combined with the source register
            // by the ALU. Latch the result into the destination
            // register and the flags into P. Increment PC past the
            // operand, point bus at the next opcode.
            //============================================================
            ST_IMM_T1: begin
                case(ir)
                    8'hA9 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA #
                    8'hA2 : begin reg_x <= alu_q; reg_p <= alu_p; end // LDX #
                    8'hA0 : begin reg_y <= alu_q; reg_p <= alu_p; end // LDY #
                    8'h69 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC #
                    8'hE9 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC #
                    8'h29 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND #
                    8'h09 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA #
                    8'h49 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR #
                    8'hC9 : reg_p <= alu_p;                           // CMP #
                    8'hE0 : reg_p <= alu_p;                           // CPX #
                    8'hC0 : reg_p <= alu_p;                           // CPY #
                    default : ;
                endcase

                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Zero Page Read T1:
            // ZP address is on din; route bus to the ZP target. PC is
            // advanced past the operand. Read strobe stays high.
            //============================================================
            ST_ZP_R_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                state <= ST_ZP_R_T2;
            end

            //============================================================
            // Zero Page Read T2:
            // Memory data is on din; ALU has produced the result.
            // Latch destination register and flags, return to fetch.
            //============================================================
            ST_ZP_R_T2: begin
                case(ir)
                    8'hA5 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA zp
                    8'hA6 : begin reg_x <= alu_q; reg_p <= alu_p; end // LDX zp
                    8'hA4 : begin reg_y <= alu_q; reg_p <= alu_p; end // LDY zp
                    8'h65 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC zp
                    8'hE5 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC zp
                    8'h25 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND zp
                    8'h05 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA zp
                    8'h45 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR zp
                    8'hC5 : reg_p <= alu_p;                           // CMP zp
                    8'hE4 : reg_p <= alu_p;                           // CPX zp
                    8'hC4 : reg_p <= alu_p;                           // CPY zp
                    8'h24 : reg_p <= alu_p;                           // BIT zp
                    default : ;
                endcase

                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Zero Page Write T1:
            // ZP address is on din; route bus to ZP target with write
            // strobe asserted. The data byte placed on dout is selected
            // from A, X, or Y per the opcode.
            //============================================================
            ST_ZP_W_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                rw_n <= 1'b0;

                case(ir)
                    8'h85 : dout <= reg_a;   // STA zp
                    8'h86 : dout <= reg_x;   // STX zp
                    8'h84 : dout <= reg_y;   // STY zp
                    default : dout <= reg_a;
                endcase

                state <= ST_ZP_W_T2;
            end

            //============================================================
            // Zero Page Write T2:
            // Write completed during this bus cycle. Return to fetch.
            //============================================================
            ST_ZP_W_T2: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Branch T1:
            // Offset on din. PC is advanced past the offset. If the
            // branch is not taken the instruction ends here. If taken,
            // the offset is latched into dl for the page-cross logic in
            // T2 and bus is held at PC for the dummy read cycle.
            //============================================================
            ST_BR_T1: begin
                dl <= din;
                reg_pc <= reg_pc + 16'd1;

                if(~br_take) begin
                    // 2-cycle: branch not taken
                    addr <= reg_pc + 16'd1;
                    sync <= 1'b1;
                    state <= ST_FETCH;
                end else begin
                    // Taken: dummy read at unmodified PC, fix PCL in T2
                    addr <= reg_pc + 16'd1;
                    state <= ST_BR_T2;
                end
            end

            //============================================================
            // Branch T2:
            // Speculative PCL update. If no page cross the branch
            // completes; bus shows the destination for T0 of the next
            // instruction. If page cross, T3 fixes PCH.
            //============================================================
            ST_BR_T2: begin
                reg_pc[7:0] <= pcl_sum[7:0];

                if(~page_cross) begin
                    // 3-cycle taken, no page cross
                    addr <= {reg_pc[15:8], pcl_sum[7:0]};
                    sync <= 1'b1;
                    state <= ST_FETCH;
                end else begin
                    // 4-cycle taken, page cross
                    reg_pc[15:8] <= new_pch;
                    addr <= {new_pch, pcl_sum[7:0]};
                    state <= ST_BR_T3;
                end
            end

            //============================================================
            // Branch T3:
            // Page-cross fixup completed at T2's edge. T3 is a dummy
            // read at the corrected destination address; the next cycle
            // is T0 of the branch target.
            //============================================================
            ST_BR_T3: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // JMP Absolute T1:
            // Low byte of target on din. Latch and advance PC.
            //============================================================
            ST_JMP_T1: begin
                dl <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_JMP_T2;
            end

            //============================================================
            // JMP Absolute T2:
            // High byte of target on din. Build full destination, point
            // bus at it, and continue with opcode fetch.
            //============================================================
            ST_JMP_T2: begin
                reg_pc <= {din, dl};
                addr <= {din, dl};
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Absolute Read T1:
            // Low byte of effective address on din. Latch and advance PC
            // to point at the high byte for the next cycle.
            //============================================================
            ST_ABS_R_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_ABS_R_T2;
            end

            //============================================================
            // Absolute Read T2:
            // High byte of effective address on din. Form the full
            // address and present it for the data fetch in T3.
            //============================================================
            ST_ABS_R_T2: begin
                reg_pc <= reg_pc + 16'd1;
                addr <= {din, ad};
                state <= ST_ABS_R_T3;
            end

            //============================================================
            // Absolute Read T3:
            // Memory data on din; ALU has produced the result. Latch
            // destination register and flags, return to fetch.
            //============================================================
            ST_ABS_R_T3: begin
                case(ir)
                    8'hAD : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA abs
                    8'hAE : begin reg_x <= alu_q; reg_p <= alu_p; end // LDX abs
                    8'hAC : begin reg_y <= alu_q; reg_p <= alu_p; end // LDY abs
                    8'h6D : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC abs
                    8'hED : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC abs
                    8'h2D : begin reg_a <= alu_q; reg_p <= alu_p; end // AND abs
                    8'h0D : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA abs
                    8'h4D : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR abs
                    8'hCD : reg_p <= alu_p;                           // CMP abs
                    8'hEC : reg_p <= alu_p;                           // CPX abs
                    8'hCC : reg_p <= alu_p;                           // CPY abs
                    8'h2C : reg_p <= alu_p;                           // BIT abs
                    default : ;
                endcase

                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Absolute Write T1:
            // Low byte of effective address on din. Same as ABS_R_T1.
            //============================================================
            ST_ABS_W_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_ABS_W_T2;
            end

            //============================================================
            // Absolute Write T2:
            // High byte of effective address on din. Form the full
            // address, drive write strobe and source register on the
            // bus. The write completes during T3 (the next cycle).
            //============================================================
            ST_ABS_W_T2: begin
                reg_pc <= reg_pc + 16'd1;
                addr <= {din, ad};
                rw_n <= 1'b0;

                case(ir)
                    8'h8D : dout <= reg_a;   // STA abs
                    8'h8E : dout <= reg_x;   // STX abs
                    8'h8C : dout <= reg_y;   // STY abs
                    default : dout <= reg_a;
                endcase

                state <= ST_ABS_W_T3;
            end

            //============================================================
            // Absolute Write T3:
            // Write completed during this bus cycle. Return to fetch.
            //============================================================
            ST_ABS_W_T3: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Push T1 (PHA, PHP):
            // Dummy read at PC. Set up the stack write for the next
            // cycle: addr -> $0100+S, dout from A or P, rw_n low. PHP
            // forces B (bit 4) and the unused bit 5 high in the pushed
            // P value, matching NMOS software-push behaviour.
            //============================================================
            ST_PUSH_T1: begin
                addr <= {8'h01, reg_s};
                rw_n <= 1'b0;

                case(ir)
                    8'h48 : dout <= reg_a;         // PHA
                    8'h08 : dout <= reg_p | 8'h30; // PHP: B=1, bit5=1
                    default : dout <= reg_a;
                endcase

                state <= ST_PUSH_T2;
            end

            //============================================================
            // Push T2 (PHA, PHP):
            // Write to stack completes during this bus cycle. Decrement
            // S, return to fetch.
            //============================================================
            ST_PUSH_T2: begin
                reg_s <= reg_s - 8'd1;
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Pull T1 (PLA, PLP):
            // Dummy read at PC. Point the bus at the current stack
            // location for the dummy read in T2; S has not been adjusted
            // yet.
            //============================================================
            ST_PULL_T1: begin
                addr <= {8'h01, reg_s};
                state <= ST_PULL_T2;
            end

            //============================================================
            // Pull T2 (PLA, PLP):
            // Dummy read at $0100+S completed. Increment S and present
            // the new stack address for the data fetch in T3.
            //============================================================
            ST_PULL_T2: begin
                reg_s <= reg_s + 8'd1;
                addr <= {8'h01, reg_s + 8'd1};
                state <= ST_PULL_T3;
            end

            //============================================================
            // Pull T3 (PLA, PLP):
            // Pulled byte on din. PLA routes through the ALU for N and
            // Z. PLP overwrites P directly with the unused bit 5 forced
            // high and the B (bit 4) forced low because B is not a real
            // hardware flag - only the byte pushed by PHP/BRK carries
            // it. Return to fetch.
            //============================================================
            ST_PULL_T3: begin
                case(ir)
                    8'h68 : begin reg_a <= alu_q; reg_p <= alu_p; end  // PLA
                    8'h28 : reg_p <= {din[7:6], 1'b1, 1'b0, din[3:0]}; // PLP
                    default : ;
                endcase

                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // JMP Indirect T1:
            // Low byte of indirect address on din. Latch into ad and
            // advance PC to fetch the high byte.
            //============================================================
            ST_JMI_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_JMI_T2;
            end

            //============================================================
            // JMP Indirect T2:
            // High byte of indirect address on din. Latch into bah and
            // present the indirect address for the data fetch in T3.
            //============================================================
            ST_JMI_T2: begin
                bah <= din;
                addr <= {din, ad};
                state <= ST_JMI_T3;
            end

            //============================================================
            // JMP Indirect T3:
            // Low byte of target on din. Latch into dl. Address for the
            // high-byte fetch in T4 increments only the low half of the
            // indirect pointer and does not propagate carry into the
            // high half - this is the NMOS page-wrap bug, preserved for
            // bus-accurate behaviour.
            //============================================================
            ST_JMI_T3: begin
                dl <= din;
                addr <= {bah, ad + 8'd1};
                state <= ST_JMI_T4;
            end

            //============================================================
            // JMP Indirect T4:
            // High byte of target on din. Build full PC, point bus at
            // it, and continue with opcode fetch.
            //============================================================
            ST_JMI_T4: begin
                reg_pc <= {din, dl};
                addr <= {din, dl};
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Zero Page Indexed Read T1:
            // ZP base on din. Latch into ad and present the unindexed
            // ZP location for the dummy read in T2.
            //============================================================
            ST_ZPI_R_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                state <= ST_ZPI_R_T2;
            end

            //============================================================
            // Zero Page Indexed Read T2:
            // Dummy read at the unindexed location completes. Compute
            // the indexed address as an 8-bit add (wraps within zero
            // page) and present it for the data fetch in T3.
            //============================================================
            ST_ZPI_R_T2: begin
                addr <= {8'h00, ad + idx_zp};
                state <= ST_ZPI_R_T3;
            end

            //============================================================
            // Zero Page Indexed Read T3:
            // Memory data on din; ALU has produced the result. Latch
            // destination register and flags, return to fetch.
            //============================================================
            ST_ZPI_R_T3: begin
                case(ir)
                    8'hB5 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA zp,X
                    8'hB4 : begin reg_y <= alu_q; reg_p <= alu_p; end // LDY zp,X
                    8'hB6 : begin reg_x <= alu_q; reg_p <= alu_p; end // LDX zp,Y
                    8'h75 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC zp,X
                    8'hF5 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC zp,X
                    8'h35 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND zp,X
                    8'h15 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA zp,X
                    8'h55 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR zp,X
                    8'hD5 : reg_p <= alu_p;                           // CMP zp,X
                    default : ;
                endcase

                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Zero Page Indexed Write T1:
            // ZP base on din. Same setup as the indexed read; the dummy
            // read in T2 happens at the unindexed location.
            //============================================================
            ST_ZPI_W_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                state <= ST_ZPI_W_T2;
            end

            //============================================================
            // Zero Page Indexed Write T2:
            // Dummy read completes. Form the indexed write address with
            // an 8-bit add and drive the source register and write
            // strobe for the actual write in T3.
            //============================================================
            ST_ZPI_W_T2: begin
                addr <= {8'h00, ad + idx_zp};
                rw_n <= 1'b0;

                case(ir)
                    8'h95 : dout <= reg_a;   // STA zp,X
                    8'h94 : dout <= reg_y;   // STY zp,X
                    8'h96 : dout <= reg_x;   // STX zp,Y
                    default : dout <= reg_a;
                endcase

                state <= ST_ZPI_W_T3;
            end

            //============================================================
            // Zero Page Indexed Write T3:
            // Write completed during this bus cycle. Return to fetch.
            //============================================================
            ST_ZPI_W_T3: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Absolute Indexed Read T1:
            // Low byte of base on din. Latch into ad and advance PC to
            // fetch the high byte.
            //============================================================
            ST_AXY_R_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_AXY_R_T2;
            end

            //============================================================
            // Absolute Indexed Read T2:
            // High byte of base on din. Compute (low + index) as a 9-bit
            // sum; carry indicates a page cross. Save the high byte and
            // the cross flag, then issue a speculative read at the
            // uncrossed address. T3 may finalise (no cross) or extend to
            // T4 (cross) based on idx_cross.
            //============================================================
            ST_AXY_R_T2: begin
                bah <= din;
                ad <= axy_lo_sum[7:0];
                idx_cross <= axy_lo_sum[8];
                addr <= {din, axy_lo_sum[7:0]};
                reg_pc <= reg_pc + 16'd1;
                state <= ST_AXY_R_T3;
            end

            //============================================================
            // Absolute Indexed Read T3:
            // Speculative-address read completes on din. If no page
            // cross occurred, latch the ALU result and return to fetch
            // (4-cycle path). If a cross occurred, the speculative read
            // was wrong; re-issue the read at {bah+1, low} and continue
            // to T4 (5-cycle path).
            //============================================================
            ST_AXY_R_T3: begin
                if(idx_cross) begin
                    addr <= {bah + 8'd1, ad};
                    state <= ST_AXY_R_T4;
                end else begin
                    case(ir)
                        8'hBD, 8'hB9 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA
                        8'hBE        : begin reg_x <= alu_q; reg_p <= alu_p; end // LDX
                        8'hBC        : begin reg_y <= alu_q; reg_p <= alu_p; end // LDY
                        8'h7D, 8'h79 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC
                        8'hFD, 8'hF9 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC
                        8'h3D, 8'h39 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND
                        8'h1D, 8'h19 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA
                        8'h5D, 8'h59 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR
                        8'hDD, 8'hD9 : reg_p <= alu_p;                           // CMP
                        default : ;
                    endcase

                    addr <= reg_pc;
                    sync <= 1'b1;
                    state <= ST_FETCH;
                end
            end

            //============================================================
            // Absolute Indexed Read T4:
            // Corrected-address read completes. Latch the ALU result
            // and return to fetch.
            //============================================================
            ST_AXY_R_T4: begin
                case(ir)
                    8'hBD, 8'hB9 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA
                    8'hBE        : begin reg_x <= alu_q; reg_p <= alu_p; end // LDX
                    8'hBC        : begin reg_y <= alu_q; reg_p <= alu_p; end // LDY
                    8'h7D, 8'h79 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC
                    8'hFD, 8'hF9 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC
                    8'h3D, 8'h39 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND
                    8'h1D, 8'h19 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA
                    8'h5D, 8'h59 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR
                    8'hDD, 8'hD9 : reg_p <= alu_p;                           // CMP
                    default : ;
                endcase

                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Absolute Indexed Write T1:
            // Low byte of base on din. Latch into ad and advance PC.
            //============================================================
            ST_AXY_W_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_AXY_W_T2;
            end

            //============================================================
            // Absolute Indexed Write T2:
            // High byte of base on din. Compute (low + index) and the
            // page-cross flag; issue the speculative dummy read in T3.
            //============================================================
            ST_AXY_W_T2: begin
                bah <= din;
                ad <= axy_lo_sum[7:0];
                idx_cross <= axy_lo_sum[8];
                addr <= {din, axy_lo_sum[7:0]};
                reg_pc <= reg_pc + 16'd1;
                state <= ST_AXY_W_T3;
            end

            //============================================================
            // Absolute Indexed Write T3:
            // Dummy read completes. Form the corrected address (high
            // byte +1 if a page cross occurred) and drive the source
            // register with the write strobe. Writes are always 5
            // cycles - no early exit on the no-cross path.
            //============================================================
            ST_AXY_W_T3: begin
                addr <= {bah + (idx_cross ? 8'd1 : 8'd0), ad};
                rw_n <= 1'b0;

                case(ir)
                    8'h9D : dout <= reg_a;   // STA abs,X
                    8'h99 : dout <= reg_a;   // STA abs,Y
                    default : dout <= reg_a;
                endcase

                state <= ST_AXY_W_T4;
            end

            //============================================================
            // Absolute Indexed Write T4:
            // Write completed during this bus cycle. Return to fetch.
            //============================================================
            ST_AXY_W_T4: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Indexed Indirect (ZP,X) T1:
            // ZP base on din. Latch into ad and present the unindexed
            // ZP location for the dummy read in T2.
            //============================================================
            ST_INX_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                state <= ST_INX_T2;
            end

            //============================================================
            // Indexed Indirect (ZP,X) T2:
            // Dummy read at the unindexed location completes. Compute
            // (base + X) wrapped within zero page and present that for
            // the low pointer fetch in T3.
            //============================================================
            ST_INX_T2: begin
                addr <= {8'h00, ad + reg_x};
                state <= ST_INX_T3;
            end

            //============================================================
            // Indexed Indirect (ZP,X) T3:
            // Low byte of the indirect pointer on din. Latch into bal
            // and present (base + X + 1) wrapped in zero page for the
            // high pointer fetch in T4.
            //============================================================
            ST_INX_T3: begin
                bal <= din;
                addr <= {8'h00, ad + reg_x + 8'd1};
                state <= ST_INX_T4;
            end

            //============================================================
            // Indexed Indirect (ZP,X) T4:
            // High byte of the indirect pointer on din. Form the
            // effective address. STA drives the bus into write mode for
            // the cycle in T5; reads leave rw_n high.
            //============================================================
            ST_INX_T4: begin
                addr <= {din, bal};

                if(ir == 8'h81) begin
                    rw_n <= 1'b0;
                    dout <= reg_a;
                end

                state <= ST_INX_T5;
            end

            //============================================================
            // Indexed Indirect (ZP,X) T5:
            // Read path: data on din has been processed by the ALU;
            // latch result and flags. Write path: STA write completes
            // during this bus cycle. Return to fetch.
            //============================================================
            ST_INX_T5: begin
                case(ir)
                    8'hA1 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA (ZP,X)
                    8'h61 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC
                    8'hE1 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC
                    8'h21 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND
                    8'h01 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA
                    8'h41 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR
                    8'hC1 : reg_p <= alu_p;                           // CMP
                    8'h81 : ;                                         // STA: write completes
                    default : ;
                endcase

                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Indirect Indexed (ZP),Y T1:
            // ZP base on din. Latch into ad and present that location
            // for the low pointer fetch in T2.
            //============================================================
            ST_INY_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                state <= ST_INY_T2;
            end

            //============================================================
            // Indirect Indexed (ZP),Y T2:
            // Low byte of pointer on din. Latch into bal and present
            // ZP+1 (wrapping in zero page) for the high pointer fetch
            // in T3.
            //============================================================
            ST_INY_T2: begin
                bal <= din;
                addr <= {8'h00, ad + 8'd1};
                state <= ST_INY_T3;
            end

            //============================================================
            // Indirect Indexed (ZP),Y T3:
            // High byte of pointer on din. Compute the speculative
            // effective address (low + Y) and the page-cross flag, then
            // route to the read or write T4 based on opcode.
            //============================================================
            ST_INY_T3: begin
                bah <= din;
                bal <= iny_lo_sum[7:0];
                idx_cross <= iny_lo_sum[8];
                addr <= {din, iny_lo_sum[7:0]};

                if(ir == 8'h91)
                    state <= ST_INY_W_T4;
                else
                    state <= ST_INY_R_T4;
            end

            //============================================================
            // Indirect Indexed (ZP),Y Read T4:
            // Speculative-address read completes on din. If no page
            // cross, latch the ALU result and return to fetch. If a
            // cross occurred, the speculative read was wrong; re-issue
            // at {bah+1, low} and continue to T5.
            //============================================================
            ST_INY_R_T4: begin
                if(idx_cross) begin
                    addr <= {bah + 8'd1, bal};
                    state <= ST_INY_R_T5;
                end else begin
                    case(ir)
                        8'hB1 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA (ZP),Y
                        8'h71 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC
                        8'hF1 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC
                        8'h31 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND
                        8'h11 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA
                        8'h51 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR
                        8'hD1 : reg_p <= alu_p;                           // CMP
                        default : ;
                    endcase

                    addr <= reg_pc;
                    sync <= 1'b1;
                    state <= ST_FETCH;
                end
            end

            //============================================================
            // Indirect Indexed (ZP),Y Read T5:
            // Corrected-address read completes. Latch the ALU result
            // and return to fetch.
            //============================================================
            ST_INY_R_T5: begin
                case(ir)
                    8'hB1 : begin reg_a <= alu_q; reg_p <= alu_p; end // LDA (ZP),Y
                    8'h71 : begin reg_a <= alu_q; reg_p <= alu_p; end // ADC
                    8'hF1 : begin reg_a <= alu_q; reg_p <= alu_p; end // SBC
                    8'h31 : begin reg_a <= alu_q; reg_p <= alu_p; end // AND
                    8'h11 : begin reg_a <= alu_q; reg_p <= alu_p; end // ORA
                    8'h51 : begin reg_a <= alu_q; reg_p <= alu_p; end // EOR
                    8'hD1 : reg_p <= alu_p;                           // CMP
                    default : ;
                endcase

                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // Indirect Indexed (ZP),Y Write T4:
            // Speculative-address dummy read completes. Form the
            // corrected address and drive the source register with the
            // write strobe. STA (ZP),Y is always 6 cycles; no early
            // exit on the no-cross path.
            //============================================================
            ST_INY_W_T4: begin
                addr <= {bah + (idx_cross ? 8'd1 : 8'd0), bal};
                rw_n <= 1'b0;
                dout <= reg_a;
                state <= ST_INY_W_T5;
            end

            //============================================================
            // Indirect Indexed (ZP),Y Write T5:
            // Write completed during this bus cycle. Return to fetch.
            //============================================================
            ST_INY_W_T5: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // JSR T1:
            // Low byte of target on din. Latch into dl. Advance PC to
            // point at the high byte of the target (PC = JSR_addr + 2).
            // Point the bus at the stack location for the dummy read in
            // T2.
            //============================================================
            ST_JSR_T1: begin
                dl <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h01, reg_s};
                state <= ST_JSR_T2;
            end

            //============================================================
            // JSR T2:
            // Dummy stack read at $0100+S. Set up the push of PCH for
            // T3: addr stays at $0100+S, dout drives PCH, write strobe
            // asserts.
            //============================================================
            ST_JSR_T2: begin
                addr <= {8'h01, reg_s};
                dout <= reg_pc[15:8];
                rw_n <= 1'b0;
                state <= ST_JSR_T3;
            end

            //============================================================
            // JSR T3:
            // Push PCH completes during this cycle. Decrement S and set
            // up the PCL push for T4.
            //============================================================
            ST_JSR_T3: begin
                reg_s <= reg_s - 8'd1;
                addr <= {8'h01, reg_s - 8'd1};
                dout <= reg_pc[7:0];
                rw_n <= 1'b0;
                state <= ST_JSR_T4;
            end

            //============================================================
            // JSR T4:
            // Push PCL completes during this cycle. Decrement S and
            // point the bus at PC = JSR_addr + 2 to fetch the high byte
            // of the target in T5.
            //============================================================
            ST_JSR_T4: begin
                reg_s <= reg_s - 8'd1;
                addr <= reg_pc;
                state <= ST_JSR_T5;
            end

            //============================================================
            // JSR T5:
            // High byte of target on din. Build full PC, point bus at
            // it, and continue with opcode fetch.
            //============================================================
            ST_JSR_T5: begin
                reg_pc <= {din, dl};
                addr <= {din, dl};
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // RTS T1:
            // Dummy read of the byte after RTS. Point the bus at the
            // stack location for the dummy stack read in T2; S is not
            // changed yet.
            //============================================================
            ST_RTS_T1: begin
                addr <= {8'h01, reg_s};
                state <= ST_RTS_T2;
            end

            //============================================================
            // RTS T2:
            // Dummy stack read at $0100+S completes. Increment S to
            // expose PCL on the bus during T3.
            //============================================================
            ST_RTS_T2: begin
                reg_s <= reg_s + 8'd1;
                addr <= {8'h01, reg_s + 8'd1};
                state <= ST_RTS_T3;
            end

            //============================================================
            // RTS T3:
            // PCL on din. Latch into dl. Increment S so T4 reads PCH.
            //============================================================
            ST_RTS_T3: begin
                dl <= din;
                reg_s <= reg_s + 8'd1;
                addr <= {8'h01, reg_s + 8'd1};
                state <= ST_RTS_T4;
            end

            //============================================================
            // RTS T4:
            // PCH on din. Build PC from popped PCH and PCL. Point bus
            // at the popped address for the dummy read in T5.
            //============================================================
            ST_RTS_T4: begin
                reg_pc <= {din, dl};
                addr <= {din, dl};
                state <= ST_RTS_T5;
            end

            //============================================================
            // RTS T5:
            // Dummy read at the popped address. Increment PC by one
            // (RTS adjusts past the JSR last-byte address) and continue
            // with opcode fetch.
            //============================================================
            ST_RTS_T5: begin
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // RMW Zero Page T1:
            // ZP base on din. Latch into ad and present that location
            // for the data read in T2.
            //============================================================
            ST_RMW_ZP_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                state <= ST_RMW_ZP_T2;
            end

            //============================================================
            // RMW Zero Page T2:
            // Original memory data on din; the ALU has produced the
            // modified value. Latch the modified value into dl and the
            // updated flags into P. Drive dout with the original value
            // for the dummy write back in T3 and assert the write
            // strobe.
            //============================================================
            ST_RMW_ZP_T2: begin
                dl <= alu_q;
                reg_p <= alu_p;
                dout <= din;
                rw_n <= 1'b0;
                state <= ST_RMW_ZP_T3;
            end

            //============================================================
            // RMW Zero Page T3:
            // Dummy write of the original value completes. Drive dout
            // with the modified value for the actual write in T4.
            //============================================================
            ST_RMW_ZP_T3: begin
                dout <= dl;
                rw_n <= 1'b0;
                state <= ST_RMW_ZP_T4;
            end

            //============================================================
            // RMW Zero Page T4:
            // Modified value write completes. Return to fetch.
            //============================================================
            ST_RMW_ZP_T4: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // RMW Zero Page,X T1:
            // ZP base on din. Latch and present the unindexed ZP for
            // the dummy read in T2.
            //============================================================
            ST_RMW_ZX_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= {8'h00, din};
                state <= ST_RMW_ZX_T2;
            end

            //============================================================
            // RMW Zero Page,X T2:
            // Dummy read at the unindexed location completes. Compute
            // the indexed ZP address and present it for the data read
            // in T3.
            //============================================================
            ST_RMW_ZX_T2: begin
                addr <= {8'h00, ad + reg_x};
                state <= ST_RMW_ZX_T3;
            end

            //============================================================
            // RMW Zero Page,X T3:
            // Original on din; ALU result captured. Drive dummy write.
            //============================================================
            ST_RMW_ZX_T3: begin
                dl <= alu_q;
                reg_p <= alu_p;
                dout <= din;
                rw_n <= 1'b0;
                state <= ST_RMW_ZX_T4;
            end

            //============================================================
            // RMW Zero Page,X T4:
            // Dummy write completes. Drive modified value.
            //============================================================
            ST_RMW_ZX_T4: begin
                dout <= dl;
                rw_n <= 1'b0;
                state <= ST_RMW_ZX_T5;
            end

            //============================================================
            // RMW Zero Page,X T5:
            // Modified value write completes. Return to fetch.
            //============================================================
            ST_RMW_ZX_T5: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // RMW Absolute T1:
            // Low byte of effective address on din. Latch and advance
            // PC.
            //============================================================
            ST_RMW_AB_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_RMW_AB_T2;
            end

            //============================================================
            // RMW Absolute T2:
            // High byte on din. Form the full address and present it
            // for the data read in T3.
            //============================================================
            ST_RMW_AB_T2: begin
                reg_pc <= reg_pc + 16'd1;
                addr <= {din, ad};
                state <= ST_RMW_AB_T3;
            end

            //============================================================
            // RMW Absolute T3:
            // Original on din; ALU result captured. Drive dummy write.
            //============================================================
            ST_RMW_AB_T3: begin
                dl <= alu_q;
                reg_p <= alu_p;
                dout <= din;
                rw_n <= 1'b0;
                state <= ST_RMW_AB_T4;
            end

            //============================================================
            // RMW Absolute T4:
            // Dummy write completes. Drive modified value.
            //============================================================
            ST_RMW_AB_T4: begin
                dout <= dl;
                rw_n <= 1'b0;
                state <= ST_RMW_AB_T5;
            end

            //============================================================
            // RMW Absolute T5:
            // Modified value write completes. Return to fetch.
            //============================================================
            ST_RMW_AB_T5: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // RMW Absolute,X T1:
            // Low byte on din. Latch and advance PC.
            //============================================================
            ST_RMW_AX_T1: begin
                ad <= din;
                reg_pc <= reg_pc + 16'd1;
                addr <= reg_pc + 16'd1;
                state <= ST_RMW_AX_T2;
            end

            //============================================================
            // RMW Absolute,X T2:
            // High byte on din. Compute the indexed sum and the
            // page-cross flag. Present the speculative address for the
            // dummy read in T3.
            //============================================================
            ST_RMW_AX_T2: begin
                bah <= din;
                ad <= axy_lo_sum[7:0];
                idx_cross <= axy_lo_sum[8];
                addr <= {din, axy_lo_sum[7:0]};
                reg_pc <= reg_pc + 16'd1;
                state <= ST_RMW_AX_T3;
            end

            //============================================================
            // RMW Absolute,X T3:
            // Dummy read at speculative address. Always present the
            // corrected address for the data read in T4 - RMW abs,X is
            // a fixed 7 cycles and does not collapse on the no-cross
            // path.
            //============================================================
            ST_RMW_AX_T3: begin
                addr <= {bah + (idx_cross ? 8'd1 : 8'd0), ad};
                state <= ST_RMW_AX_T4;
            end

            //============================================================
            // RMW Absolute,X T4:
            // Original on din; ALU result captured. Drive dummy write.
            //============================================================
            ST_RMW_AX_T4: begin
                dl <= alu_q;
                reg_p <= alu_p;
                dout <= din;
                rw_n <= 1'b0;
                state <= ST_RMW_AX_T5;
            end

            //============================================================
            // RMW Absolute,X T5:
            // Dummy write completes. Drive modified value.
            //============================================================
            ST_RMW_AX_T5: begin
                dout <= dl;
                rw_n <= 1'b0;
                state <= ST_RMW_AX_T6;
            end

            //============================================================
            // RMW Absolute,X T6:
            // Modified value write completes. Return to fetch.
            //============================================================
            ST_RMW_AX_T6: begin
                addr <= reg_pc;
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // BRK / IRQ / NMI T1:
            // Dummy read of the operand byte (or of PC for hardware
            // interrupts). The bus signals for the PCH push in T2 are
            // set here: addr to the stack, dout to PCH, and the write
            // strobe. For BRK the PC has already been advanced to
            // BRK_addr + 2 in FETCH; for IRQ / NMI the PC was not
            // advanced and is the next instruction's address.
            //============================================================
            ST_BRK_T1: begin
                addr <= {8'h01, reg_s};
                dout <= reg_pc[15:8];
                rw_n <= 1'b0;
                state <= ST_BRK_T2;
            end

            //============================================================
            // BRK / IRQ / NMI T2:
            // PCH push completes during this cycle. Decrement S and
            // set up the PCL push for T3.
            //============================================================
            ST_BRK_T2: begin
                reg_s <= reg_s - 8'd1;
                addr <= {8'h01, reg_s - 8'd1};
                dout <= reg_pc[7:0];
                rw_n <= 1'b0;
                state <= ST_BRK_T3;
            end

            //============================================================
            // BRK / IRQ / NMI T3:
            // PCL push completes. Decrement S and set up the P push.
            // Pushed P has bit 5 forced 1; bit 4 (B) is 1 for BRK and
            // 0 for IRQ / NMI - the only externally visible difference
            // between software and hardware entry into the interrupt
            // service routine.
            //============================================================
            ST_BRK_T3: begin
                reg_s <= reg_s - 8'd1;
                addr <= {8'h01, reg_s - 8'd1};
                dout <= {reg_p[7:6], 1'b1, (int_kind == 2'b00), reg_p[3:0]};
                rw_n <= 1'b0;
                state <= ST_BRK_T4;
            end

            //============================================================
            // BRK / IRQ / NMI T4:
            // P push completes. Decrement S, mask further IRQs by
            // setting the I flag, and point the bus at the low byte
            // of the vector. NMI uses $FFFA / $FFFB; BRK and IRQ use
            // $FFFE / $FFFF.
            //============================================================
            ST_BRK_T4: begin
                reg_s <= reg_s - 8'd1;
                reg_p[FLAG_I] <= 1'b1;
                addr <= (int_kind == 2'b10) ? 16'hFFFA : 16'hFFFE;
                vp_n <= 1'b0;
                state <= ST_BRK_T5;
            end

            //============================================================
            // BRK / IRQ / NMI T5:
            // Vector low on din. Latch into dl and point the bus at
            // the high byte of the vector for T6.
            //============================================================
            ST_BRK_T5: begin
                dl <= din;
                addr <= (int_kind == 2'b10) ? 16'hFFFB : 16'hFFFF;
                vp_n <= 1'b0;
                state <= ST_BRK_T6;
            end

            //============================================================
            // BRK / IRQ / NMI T6:
            // Vector high on din. Build PC, point the bus at it, and
            // continue with opcode fetch.
            //============================================================
            ST_BRK_T6: begin
                reg_pc <= {din, dl};
                addr <= {din, dl};
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            //============================================================
            // RTI T1:
            // Dummy read of the byte after RTI. Point the bus at the
            // stack location for the dummy stack read in T2.
            //============================================================
            ST_RTI_T1: begin
                addr <= {8'h01, reg_s};
                state <= ST_RTI_T2;
            end

            //============================================================
            // RTI T2:
            // Dummy stack read at $0100+S. Increment S so T3 reads the
            // pushed P value.
            //============================================================
            ST_RTI_T2: begin
                reg_s <= reg_s + 8'd1;
                addr <= {8'h01, reg_s + 8'd1};
                state <= ST_RTI_T3;
            end

            //============================================================
            // RTI T3:
            // Pushed P on din. Force bit 5 = 1 and bit 4 (B) = 0; bit
            // 4 has no hardware backing inside P. Increment S so T4
            // reads PCL.
            //============================================================
            ST_RTI_T3: begin
                reg_p <= {din[7:6], 1'b1, 1'b0, din[3:0]};
                reg_s <= reg_s + 8'd1;
                addr <= {8'h01, reg_s + 8'd1};
                state <= ST_RTI_T4;
            end

            //============================================================
            // RTI T4:
            // PCL on din. Latch into dl. Increment S so T5 reads PCH.
            //============================================================
            ST_RTI_T4: begin
                dl <= din;
                reg_s <= reg_s + 8'd1;
                addr <= {8'h01, reg_s + 8'd1};
                state <= ST_RTI_T5;
            end

            //============================================================
            // RTI T5:
            // PCH on din. Build PC. Unlike RTS no +1 adjustment is
            // applied because the IRQ/BRK push captured the address of
            // the next instruction, not the address of the last byte
            // of the trigger.
            //============================================================
            ST_RTI_T5: begin
                reg_pc <= {din, dl};
                addr <= {din, dl};
                sync <= 1'b1;
                state <= ST_FETCH;
            end

            default: begin
                state <= ST_FETCH;
                addr <= reg_pc;
                sync <= 1'b1;
            end
        endcase
    end
end

endmodule
