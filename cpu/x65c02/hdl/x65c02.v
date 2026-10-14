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
//  Central Processing Unit for the Rockwell R65C02 microprocessor.
//
//  Programming Model:
//    - A, X, Y, S and PC; P stores N, V, D, I, Z and C. Bits 5 and 4
//      exist only in a pushed copy of P: PHP and BRK push 1 and 1, IRQ
//      and NMI push 1 and 0, PLP and RTI drop both.
//    - Stack at $0100 + S; vectors NMI $FFFA, RES $FFFC and IRQ / BRK
//      $FFFE [p.1-12].
//    - The 210 opcodes of the R65C02 matrix [p.1-11], including the bit
//      instructions RMB, SMB, BBR and BBS; the other 46 opcodes are NOPs
//      [p.1-10].
//
//  Bus Cycle Model:
//    - addr, rw_n, sync and dout are registered at the enable that starts
//      a cycle and hold for the whole cycle; din is used at the enable
//      that ends it.
//    - A page cross of abs,X / abs,Y repeats the read of PC+2, the last
//      instruction byte [p.1-10]; an abs,X / abs,Y store or INC / DEC
//      abs,X without a cross reads the effective address first; ASL, ROL,
//      LSR and ROR abs,X without a cross have no extra cycle. A (zp),Y
//      store, and a (zp),Y read across a page, repeat the read of zp+1,
//      the pointer high byte. zp,X, zp,Y and (zp,X) read PC+1 again
//      before the indexed access.
//    - Read-modify-write reads the operand twice, then writes the result
//      [p.1-10].
//    - ADC and SBC in decimal mode add one cycle that reads the next
//      instruction's address; the result is written at its end [p.1-10],
//      [p.1-11].
//    - JMP (abs) and JMP (abs,X) read PC+2 again, then the pointer and
//      the carried pointer + 1 [p.1-10].
//    - A taken branch reads PC+2; on a page cross it reads PC+2 again
//      before the fetch at the carried target. BBR and BBS read the
//      zero-page byte twice, then the offset; a taken branch reads PC+3,
//      twice on a page cross.
//    - Undefined opcodes: x3 and xB (except CB) take 1 cycle; CB and the
//      x2 NOPs 2; 44 reads zp; 54, D4 and F4 read PC+1 again and zp+X;
//      DC and FC read PC+1, PC+2 and {AH, AL}; 5C reads PC+1, PC+2,
//      {$FF, AL}, then $FFFF four times.
//
//  Clock Enables:
//    - HALF_CYCLE = 0: one cen per bus cycle (the falling clock edge that
//      starts the cycle); dout_oe covers the whole write cycle.
//    - HALF_CYCLE = 1: cen_p2 marks the rising edge inside the cycle;
//      dout_oe covers phase 2 of a write cycle and SO is sampled at
//      cen_p2 [p.1-4]. cen_p2 is not read when HALF_CYCLE = 0.
//    - RES, RDY, IRQ and NMI are sampled at cen only; nothing is captured
//      between enables.
//
//  Reset:
//    - One cen with rst_n low resets. The cycle in progress keeps its
//      write; the next cycle runs without write or SYNC, then the bus
//      holds the program counter with writes inhibited. RES low again
//      restarts the sequence.
//    - After release the sequence lasts seven cycles [p.1-6]: two at the
//      held address with SYNC on the first, three stack reads, then
//      $FFFC and $FFFD. I is set and D cleared [p.1-6], [p.1-10]; S
//      drops by 3 as the first instance of the third stack read ends; A,
//      X, Y and the other flags keep their values (NMOS timing).
//
//  Interrupts:
//    - IRQ (with I clear) and a latched NMI edge are polled at the enable
//      that starts an instruction's last cycle, with RDY high [p.1-4]. A
//      1-cycle NOP is polled at the enable that starts it. Branches,
//      BBR and BBS poll at the start of the offset read, and of the
//      fixup on a page cross (NMOS timing).
//    - CLI, SEI and PLP change I at the next opcode fetch; RTI at the
//      start of its fifth cycle (NMOS timing).
//    - The vector is chosen when the entry starts; an interrupt that
//      arrives during BRK or an entry is taken after the handler's first
//      instruction [p.1-10]. I is set and D cleared with the second
//      vector read [p.1-10]; a pending NMI is consumed there by an NMI
//      entry, and absorbed by the reset sequence when pending at its
//      third stack read (NMOS timing).
//
//  RDY and SO:
//    - RDY low at the end of any cycle, read or write, repeats it with
//      the same address, R/W and data [p.1-4], [p.1-6]; the cycle after
//      RES was first seen low does not wait.
//    - A falling edge on SO sets V [p.1-4] one cycle later; the V load of
//      ADC, SBC, BIT, PLP, RTI and CLV wins a collision, and CLV clears V
//      again at each RDY repeat of the opcode fetch after it. A branch
//      tests the flags as they are at the start of its second cycle (all
//      NMOS timing).
//    - vp_n is not an R65C02 pin: it is low during the two vector reads
//      of IRQ, NMI and BRK entries.
//
//  Reference: Rockwell R65C02 / R65C102 / R65C112 CPU Datasheet, Rev. 6,
//             June 1987, [p.1-3]-[p.1-12]; MOS Technology MCS6500
//             Microcomputer Family Hardware Manual, January 1976 (NMOS
//             bus cycles); bus recordings of an R65C02P2 (extra-cycle
//             addresses; the cycles of shift abs,X and NOP 5C).
//============================================================================

`timescale 1ns/1ps

module x65c02 #(
    parameter HALF_CYCLE = 0 // 0 = one enable per bus cycle, 1 = cen_p2 adds phase 2
)(
    // Clock and Reset
    input  wire        clk,             // System clock
    input  wire        cen,             // Clock enable (one bus cycle per pulse)
    input  wire        rst_n,           // Active-low reset (RES pin)
    input  wire        rdy,             // Active-high ready (RDY pin)

    // Interrupt Inputs
    input  wire        irq_n,           // IRQ
    input  wire        nmi_n,           // NMI
    input  wire        so_n,            // Set-Overflow

    // CPU Bus Interface
    output reg  [15:0] addr = 16'h0000, // Address bus
    input  wire  [7:0] din,             // Data in
    output reg   [7:0] dout = 8'h00,    // Data out
    output reg         rw_n = 1'b1,     // R/W (high=read, low=write)
    output reg         sync = 1'b0,     // High during opcode fetch cycle
    output reg         vp_n = 1'b1,     // Vector Pull (low during IRQ/NMI/BRK vector reads)

    // Half-Cycle Mode
    input  wire        cen_p2,          // Phase 2 enable (read only when HALF_CYCLE = 1)
    output reg         dout_oe = 1'b0,  // CPU drives the data bus

    // Debug
    output wire [15:0] dbg_pc,          // Program counter
    output wire  [7:0] dbg_a,           // Accumulator
    output wire  [7:0] dbg_x,           // X index
    output wire  [7:0] dbg_y,           // Y index
    output wire  [7:0] dbg_s,           // Stack pointer
    output wire  [7:0] dbg_p,           // Processor status (bits 5 and 4 read 1)
    output wire  [7:0] dbg_ir           // Instruction register
);

//========================================================================
// FSM State Encoding:
// One state per bus cycle, except ST_NP4 (cycles 4-7 of NOP 5C); a
// trailing digit is the cycle number within the instruction (1 = opcode
// fetch).
//========================================================================
localparam [5:0]
    ST_FETCH   = 6'd0,
    ST_IMP     = 6'd1,
    ST_IMM     = 6'd2,
    ST_ZP1     = 6'd3,
    ST_ZPI2    = 6'd4,
    ST_IZX4    = 6'd5,
    ST_IZX5    = 6'd6,
    ST_IZY3    = 6'd7,
    ST_IZY4    = 6'd8,
    ST_ABS1    = 6'd9,
    ST_ABS2    = 6'd10,
    ST_IDX     = 6'd11,
    ST_RD      = 6'd12,
    ST_WR      = 6'd13,
    ST_RMW_RD  = 6'd14,
    ST_RMW_RR  = 6'd15,
    ST_RMW_WR  = 6'd16,
    ST_JMP3    = 6'd17,
    ST_JMI5    = 6'd18,
    ST_NP4     = 6'd19,
    ST_JMI6    = 6'd20,
    ST_JMX4    = 6'd21,
    ST_BR2     = 6'd22,
    ST_BR3     = 6'd23,
    ST_BR4     = 6'd24,
    ST_BB3     = 6'd25,
    ST_BB4     = 6'd26,
    ST_JSR2    = 6'd27,
    ST_JSR3    = 6'd28,
    ST_JSR4    = 6'd29,
    ST_JSR5    = 6'd30,
    ST_JSR6    = 6'd31,
    ST_STK2    = 6'd32,
    ST_STK3    = 6'd33,
    ST_PUL4    = 6'd34,
    ST_RTS4    = 6'd35,
    ST_RTS5    = 6'd36,
    ST_RTS6    = 6'd37,
    ST_RTI4    = 6'd38,
    ST_RTI5    = 6'd39,
    ST_RTI6    = 6'd40,
    ST_PSH2    = 6'd41,
    ST_PSH3    = 6'd42,
    ST_INT2    = 6'd43,
    ST_INT3    = 6'd44,
    ST_INT4    = 6'd45,
    ST_INT5    = 6'd46,
    ST_INT6    = 6'd47,
    ST_INT7    = 6'd48,
    ST_DEC     = 6'd49,
    ST_RES_LOW = 6'd50,
    ST_RES_S   = 6'd51;

//========================================================================
// Addressing Mode and Access Kind:
// Decoded from the opcode at the fetch; the kind picks the cycle that
// follows the effective-address cycles.
//========================================================================
localparam [4:0]
    AM_IMP = 5'd0,
    AM_IMM = 5'd1,
    AM_ZP  = 5'd2,
    AM_ZPX = 5'd3,
    AM_ZPY = 5'd4,
    AM_ABS = 5'd5,
    AM_ABX = 5'd6,
    AM_ABY = 5'd7,
    AM_IZX = 5'd8,
    AM_IZY = 5'd9,
    AM_REL = 5'd10,
    AM_JSR = 5'd11,
    AM_RTS = 5'd12,
    AM_RTI = 5'd13,
    AM_PSH = 5'd14,
    AM_PUL = 5'd15,
    AM_JMP = 5'd16,
    AM_JMI = 5'd17,
    AM_BRK = 5'd18,
    AM_IZP = 5'd19,
    AM_JMX = 5'd20,
    AM_BBX = 5'd21,
    AM_NP1 = 5'd22,
    AM_NP3 = 5'd23;

localparam [1:0]
    AK_R = 2'd0, // read
    AK_W = 2'd1, // write
    AK_M = 2'd2; // read-modify-write

//========================================================================
// ALU Operation Codes:
// Match the encoding in x65c02_alu.v.
//========================================================================
localparam [4:0]
    ALU_OR  = 5'h00,
    ALU_AND = 5'h01,
    ALU_EOR = 5'h02,
    ALU_ADC = 5'h03,
    ALU_EQ1 = 5'h04,
    ALU_EQ2 = 5'h05,
    ALU_CMP = 5'h06,
    ALU_SBC = 5'h07,
    ALU_ASL = 5'h08,
    ALU_ROL = 5'h09,
    ALU_LSR = 5'h0A,
    ALU_ROR = 5'h0B,
    ALU_BIT = 5'h0C,
    ALU_DEC = 5'h0D,
    ALU_INC = 5'h0E,
    ALU_BIM = 5'h0F,
    ALU_TSB = 5'h10,
    ALU_TRB = 5'h11;

//========================================================================
// Processor Status Register Bit Positions:
// Bits 5 and 4 are held at 1 so that reg_p reads as PHP would push it.
//========================================================================
localparam FLAG_C = 0;
localparam FLAG_Z = 1;
localparam FLAG_I = 2;
localparam FLAG_D = 3;
localparam FLAG_B = 4;
localparam FLAG_1 = 5;
localparam FLAG_V = 6;
localparam FLAG_N = 7;

//========================================================================
// CPU Registers:
// Power-up values: A = X = Y = S = 00, D = 0, I = 1; the first reset
// leaves S = FD.
//========================================================================
reg  [7:0] reg_a  = 8'h00;    // Accumulator
reg  [7:0] reg_x  = 8'h00;    // X index
reg  [7:0] reg_y  = 8'h00;    // Y index
reg  [7:0] reg_s  = 8'h00;    // Stack pointer (low byte; high byte is $01)
reg  [7:0] reg_p  = 8'h34;    // Processor status
reg [15:0] reg_pc = 16'h0000; // Program counter (next instruction-stream byte)
reg  [7:0] ir     = 8'h00;    // Instruction register (current opcode)
reg  [4:0] am     = AM_IMP;   // Addressing mode of ir
reg  [1:0] ak     = AK_R;     // Access kind of ir
reg  [5:0] state  = ST_RES_LOW;

//========================================================================
// Addressing Scratch:
// Effective address halves, data latch and per-instruction flags.
//========================================================================
reg [7:0] ad        = 8'h00; // Address low byte (operand, AL + index)
reg [7:0] bah       = 8'h00; // Address high byte (AH, BH, branch target)
reg [7:0] dl        = 8'h00; // Data latch (pointer, offset, vector, result)
reg       idx_cross = 1'b0;  // Indexed low byte carried out
reg       br_take   = 1'b0;  // Branch condition
reg       rmw_c     = 1'b0;  // Carry out of the modify step
reg       rmw_z     = 1'b0;  // Z of A AND M (TSB, TRB)
reg [1:0] np_cnt    = 2'd0;  // Cycle count of NOP 5C

//========================================================================
// Interrupt State:
// nmig = NMI pending, nmil = NMI blocked until the line is high again,
// intg = interrupt recognized for the next fetch, poll_f = poll result
// at the start of the opcode fetch (1-cycle NOPs).
//========================================================================
reg nmig    = 1'b0;
reg nmil    = 1'b0;
reg intg    = 1'b0;
reg poll_f  = 1'b0;
reg vec_nmi = 1'b0; // Entry uses the NMI vector (reset: NMI absorbed)
reg ent_brk = 1'b0; // Entry is a BRK
reg ent_res = 1'b1; // Entry is the reset sequence

//========================================================================
// V Flag Timing:
// SO edge pending for the next enable, and the second V load of ADC,
// SBC and CLV one cycle after the instruction.
//========================================================================
reg so_prev = 1'b1;
reg so_pend = 1'b0;
reg v_pipe  = 1'b0;
reg v_val   = 1'b0;

//========================================================================
// Reset State:
// res_pend = RES was low at the last enable; res_r1 = this cycle is the
// one after it; res_rel = RES was high again at the start of this cycle;
// rep = the current cycle is a RDY repeat.
//========================================================================
reg res_pend = 1'b0;
reg res_r1   = 1'b0;
reg res_rel  = 1'b0;
reg rep      = 1'b0;

//========================================================================
// Next-Cycle Values:
// Built inside the clocked block for the cycle that starts at this
// enable, then registered.
//========================================================================
reg  [5:0] ns;
reg [15:0] na;
reg  [7:0] ndo;
reg        nrw;
reg        nsy;
reg        nvp;

//========================================================================
// Opcode Decode:
// Addressing mode and access kind from the opcode bit fields, with the
// R65C02 additions and the undefined NOPs.
//========================================================================
function [4:0] f_am;
    input [7:0] op;
    begin
        case(op[1:0])
            2'b00: begin
                case(op[4:2])
                    3'b000: begin
                        if(op == 8'h80) f_am = AM_REL;
                        else if(op[7]) f_am = AM_IMM;
                        else if(op[6:5] == 2'b00) f_am = AM_BRK;
                        else if(op[6:5] == 2'b01) f_am = AM_JSR;
                        else if(op[6:5] == 2'b10) f_am = AM_RTI;
                        else f_am = AM_RTS;
                    end
                    3'b001: f_am = AM_ZP;
                    3'b010: f_am = op[7] ? AM_IMP : (op[5] ? AM_PUL : AM_PSH);
                    3'b011: f_am = (op[7:5] == 3'b010) ? AM_JMP : (op[7:5] == 3'b011) ? AM_JMI : AM_ABS;
                    3'b100: f_am = AM_REL;
                    3'b101: f_am = (op[7:5] == 3'b000) ? AM_ZP : AM_ZPX;
                    3'b110: f_am = AM_IMP;
                    default: begin
                        case(op[7:5])
                            3'b000, 3'b100 : f_am = AM_ABS; // TRB abs, STZ abs
                            3'b011 : f_am = AM_JMX; // JMP (abs,X)
                            3'b010, 3'b110, 3'b111 : f_am = AM_NP3; // NOP
                            default : f_am = AM_ABX;
                        endcase
                    end
                endcase
            end
            2'b10: begin
                case(op[4:2])
                    3'b000: f_am = AM_IMM;
                    3'b001: f_am = AM_ZP;
                    3'b010: f_am = AM_IMP;
                    3'b011: f_am = AM_ABS;
                    3'b100: f_am = AM_IZP;
                    3'b101: f_am = (op[7:6] == 2'b10) ? AM_ZPY : AM_ZPX;
                    3'b110: begin
                        case(op[7:5])
                            3'b010, 3'b110 : f_am = AM_PSH; // PHY, PHX
                            3'b011, 3'b111 : f_am = AM_PUL; // PLY, PLX
                            default : f_am = AM_IMP;
                        endcase
                    end
                    default: f_am = (op[7:5] == 3'b101) ? AM_ABY : AM_ABX;
                endcase
            end
            2'b01: begin
                case(op[4:2])
                    3'b000: f_am = AM_IZX;
                    3'b001: f_am = AM_ZP;
                    3'b010: f_am = AM_IMM;
                    3'b011: f_am = AM_ABS;
                    3'b100: f_am = AM_IZY;
                    3'b101: f_am = AM_ZPX;
                    3'b110: f_am = AM_ABY;
                    default: f_am = AM_ABX;
                endcase
            end
            default: begin
                if(op[3:0] == 4'h7) f_am = AM_ZP; // RMB, SMB
                else if(op[3:0] == 4'hF) f_am = AM_BBX; // BBR, BBS
                else if(op == 8'hCB) f_am = AM_IMP; // NOP
                else f_am = AM_NP1; // NOP
            end
        endcase
    end
endfunction

function [1:0] f_ak;
    input [7:0] op;
    begin
        if((op == 8'h64) || (op == 8'h74) || (op == 8'h92) ||
           ((op[7:5] == 3'b100) && (op[1:0] != 2'b11) && (op[0] ? (op != 8'h89) : op[2])))
            f_ak = AK_W;
        else if((op[3:0] == 4'h7) ||
                ((op[1:0] == 2'b10) && op[2] && (op[7:6] != 2'b10)) ||
                ((op[1:0] == 2'b00) && (op[7:5] == 3'b000) && op[2]))
            f_ak = AK_M;
        else
            f_ak = AK_R;
    end
endfunction

//------------------------------------------------------------------------
// ADC and SBC:
// The instructions that add the decimal-mode cycle.
//------------------------------------------------------------------------
function f_adsb;
    input [7:0] op;
    begin
        f_adsb = ((op[1:0] == 2'b01) && (op[6:5] == 2'b11)) || (op == 8'h72) || (op == 8'hF2);
    end
endfunction

//------------------------------------------------------------------------
// Branch Condition:
// op[7:6] selects N, V, C or Z; op[5] is the value that takes the branch.
// BRA always branches.
//------------------------------------------------------------------------
function f_cond;
    input [7:0] op;
    input [7:0] p;
    begin
        if(op == 8'h80)
            f_cond = 1'b1;
        else begin
            case(op[7:6])
                2'b00: f_cond = (p[FLAG_N] == op[5]);
                2'b01: f_cond = (p[FLAG_V] == op[5]);
                2'b10: f_cond = (p[FLAG_C] == op[5]);
                default: f_cond = (p[FLAG_Z] == op[5]);
            endcase
        end
    end
endfunction

//------------------------------------------------------------------------
// Poll Cycles:
// The interrupt poll runs at the enable that starts one of these cycles.
//------------------------------------------------------------------------
function st_poll;
    input [5:0] st;
    begin
        case(st)
            ST_IMP, ST_IMM, ST_RD, ST_WR, ST_RMW_WR, ST_JMP3, ST_JMI6, ST_BR2, ST_BR4,
            ST_JSR6, ST_RTS6, ST_RTI6, ST_PSH3, ST_PUL4, ST_DEC: st_poll = 1'b1;
            default: st_poll = 1'b0;
        endcase
    end
endfunction

//========================================================================
// Half-Cycle Enable:
// cen_p2 is read only when HALF_CYCLE = 1.
//========================================================================
wire p2_en;

generate
    if(HALF_CYCLE != 0) begin : g_half
        assign p2_en = cen_p2;
    end else begin : g_cycle
        assign p2_en = 1'b0;
    end
endgenerate

//========================================================================
// Datapath Wires:
// Decode of din at the fetch, the index register, write data and the
// indexed, branch, pointer and entry address arithmetic.
//========================================================================
wire  [4:0] dec_am   = f_am(din);
wire  [1:0] dec_ak   = f_ak(din);
wire  [7:0] idx      = (am == AM_ZPY || am == AM_ABY || am == AM_IZY) ? reg_y : reg_x;
wire        k_wr     = (ak == AK_W);
wire  [5:0] st_k     = (ak == AK_R) ? ST_RD : (ak == AK_W) ? ST_WR : ST_RMW_RD;
wire  [8:0] lo_sum   = {1'b0, ad} + {1'b0, idx};
wire        g01      = (ir[1:0] == 2'b01) || (ir[4:0] == 5'b10010);
wire        is_stz   = (ir == 8'h64) || (ir == 8'h74) || (ir == 8'h9C) || (ir == 8'h9E);
wire  [7:0] w_dat    = is_stz ? 8'h00 : g01 ? reg_a : (ir[1:0] == 2'b10) ? reg_x : reg_y;
wire  [7:0] ea_hi    = idx_cross ? (bah + 8'd1) : bah;
wire [15:0] ptr_inc  = {bah, ad} + 16'd1;
wire  [7:0] bit_m    = 8'h01 << ir[6:4];
wire  [8:0] br_sum   = {1'b0, reg_pc[7:0]} + {1'b0, dl};
wire        br_cross = br_sum[8] ^ dl[7];
wire  [7:0] br_hi    = dl[7] ? (reg_pc[15:8] - 8'd1) : (reg_pc[15:8] + 8'd1);
wire [15:0] ent_ret  = ent_brk ? (reg_pc + 16'd2) : reg_pc;

//------------------------------------------------------------------------
// Decimal Cycle:
// dec_x = the current ADC or SBC adds the decimal cycle; dec_n = the same
// for the instruction whose cycle starts at this enable.
//------------------------------------------------------------------------
wire dec_x = f_adsb(ir) & reg_p[FLAG_D];
wire dec_n = f_adsb((state == ST_FETCH) ? din : ir) & reg_p[FLAG_D];

//------------------------------------------------------------------------
// Flags at This Enable:
// A pending SO edge sets V unless the second V load of the previous
// instruction lands on the same enable.
//------------------------------------------------------------------------
wire       v_cur = v_pipe ? v_val : (so_pend | reg_p[FLAG_V]);
wire [7:0] p_cur = {reg_p[7], v_cur, reg_p[5:0]};

//========================================================================
// Cycle Control:
// prot = RES protocol cycle; hold = RDY repeats this cycle (not the
// cycle after RES was seen low); last = last cycle of an instruction;
// run = the state machine advances.
//========================================================================
reg last;

always @(*) begin
    case(state)
        ST_IMP, ST_WR, ST_RMW_WR, ST_JMP3, ST_JMI6, ST_BR4, ST_JSR6, ST_RTS6, ST_RTI6,
        ST_PSH3, ST_PUL4, ST_DEC: last = 1'b1;
        ST_IMM, ST_RD: last = ~dec_x;
        ST_BR2: last = ~br_take;
        ST_BR3: last = ~br_cross;
        default: last = 1'b0;
    endcase
end

wire prot  = (state == ST_RES_LOW) || (state == ST_RES_S);
wire hold  = ~rdy & ~prot & ~res_r1 & ~res_pend;
wire run   = ~prot & ~hold & (~res_r1 | last);
wire at_e7 = run & (state == ST_INT6);

//------------------------------------------------------------------------
// NMI Latch and Poll:
// nmil clears when NMI is high; nmig sets when NMI is low and not
// blocked, and an NMI entry clears it at the second vector read.
//------------------------------------------------------------------------
wire nmil_c = nmi_n ? 1'b0 : nmil;
wire nmig_c = (at_e7 & vec_nmi) ? 1'b0 : ((~nmi_n & ~nmil_c) | nmig);
wire poll_v = nmig_c | (~irq_n & ~reg_p[FLAG_I]);

//========================================================================
// ALU Wires and Drive Registers:
// alu_c is the carry the ALU sees; the read-modify-write flag step uses
// the carry out of its modify step.
//========================================================================
reg  [7:0] alu_a;
reg  [7:0] alu_b;
reg  [4:0] alu_op_sel;
reg        alu_c;
wire [7:0] alu_pin = {reg_p[7], v_cur, 2'b11, reg_p[3:1], alu_c};
wire [7:0] alu_q;
wire [7:0] alu_p;

x65c02_alu u_alu (
    .a     ( alu_a      ),
    .b     ( alu_b      ),
    .op    ( alu_op_sel ),
    .p_in  ( alu_pin    ),
    .q     ( alu_q      ),
    .p_out ( alu_p      )
);

//========================================================================
// Combinational ALU Input Drive:
// Operands and op for the cycle that ends at this enable, from the
// state and the latched opcode.
//========================================================================
always @(*) begin
    alu_a = reg_a;
    alu_b = din;
    alu_op_sel = ALU_EQ1;
    alu_c = reg_p[FLAG_C];

    case(state)
        //----------------------------------------------------------------
        // Implied / Accumulator:
        // Register increments, transfers and accumulator shifts.
        //----------------------------------------------------------------
        ST_IMP: begin
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
                8'h1A : alu_op_sel = ALU_INC; // INC A
                8'h3A : alu_op_sel = ALU_DEC; // DEC A
                8'h0A : alu_op_sel = ALU_ASL; // ASL A
                8'h2A : alu_op_sel = ALU_ROL; // ROL A
                8'h4A : alu_op_sel = ALU_LSR; // LSR A
                8'h6A : alu_op_sel = ALU_ROR; // ROR A
                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // Immediate and Memory Reads:
        // The operand is on din; op from the opcode group.
        //----------------------------------------------------------------
        ST_IMM,
        ST_RD: begin
            if(g01) begin
                case(ir[7:5])
                    3'b000 : alu_op_sel = ALU_OR; // ORA
                    3'b001 : alu_op_sel = ALU_AND; // AND
                    3'b010 : alu_op_sel = ALU_EOR; // EOR
                    3'b011 : alu_op_sel = ALU_ADC; // ADC
                    3'b101 : begin alu_a = din; alu_op_sel = ALU_EQ2; end // LDA
                    3'b110 : alu_op_sel = ALU_CMP; // CMP
                    3'b111 : alu_op_sel = ALU_SBC; // SBC
                    default : alu_op_sel = ALU_BIM; // BIT #
                endcase
            end else if(ir[1:0] == 2'b10) begin
                alu_a = din; // LDX
                alu_op_sel = ALU_EQ2;
            end else begin
                case(ir[7:5])
                    3'b101 : begin alu_a = din; alu_op_sel = ALU_EQ2; end // LDY
                    3'b110 : begin alu_a = reg_y; alu_op_sel = ALU_CMP; end // CPY
                    3'b111 : begin alu_a = reg_x; alu_op_sel = ALU_CMP; end // CPX
                    default : alu_op_sel = ALU_BIT; // BIT
                endcase
            end
        end

        //----------------------------------------------------------------
        // Decimal Cycle:
        // ADC or SBC on the operand latched at the read before.
        //----------------------------------------------------------------
        ST_DEC: begin
            alu_b = dl;
            alu_op_sel = ir[7] ? ALU_SBC : ALU_ADC;
        end

        //----------------------------------------------------------------
        // Pull:
        // PLA, PLX and PLY update N and Z from the pulled byte.
        //----------------------------------------------------------------
        ST_PUL4: begin
            alu_a = din;
            alu_op_sel = ALU_EQ2;
        end

        //----------------------------------------------------------------
        // Read-Modify-Write Data Read:
        // The modify step on the byte just read.
        //----------------------------------------------------------------
        ST_RMW_RD: begin
            if(ir[3:0] == 4'h7) begin
                alu_a = ir[7] ? (din | bit_m) : (din & ~bit_m); // SMB, RMB
                alu_op_sel = ALU_EQ1;
            end else if(ir[1:0] == 2'b00) begin
                alu_op_sel = ir[4] ? ALU_TRB : ALU_TSB; // TRB, TSB
            end else begin
                alu_a = din;
                case(ir[7:5])
                    3'b000 : alu_op_sel = ALU_ASL; // ASL
                    3'b001 : alu_op_sel = ALU_ROL; // ROL
                    3'b010 : alu_op_sel = ALU_LSR; // LSR
                    3'b011 : alu_op_sel = ALU_ROR; // ROR
                    3'b110 : alu_op_sel = ALU_DEC; // DEC
                    default : alu_op_sel = ALU_INC; // INC
                endcase
            end
        end

        //----------------------------------------------------------------
        // Read-Modify-Write Last Cycle:
        // N and Z of the modified value, C of the modify step.
        //----------------------------------------------------------------
        ST_RMW_WR: begin
            alu_a = dl;
            alu_b = dl;
            alu_c = rmw_c;
            alu_op_sel = ALU_EQ2;
        end

        default : ;
    endcase
end

//========================================================================
// Read Result Destinations:
// Registers written at the end of an immediate or memory read.
//========================================================================
reg rd_wa;
reg rd_wx;
reg rd_wy;
reg rd_wp;
reg rd_vp;

always @(*) begin
    rd_wa = 1'b0;
    rd_wx = 1'b0;
    rd_wy = 1'b0;
    rd_wp = 1'b0;
    rd_vp = 1'b0;

    if(g01) begin
        rd_wp = (ir[7:5] != 3'b100) || (ir == 8'h89);
        rd_wa = (ir[7:5] != 3'b100) && (ir[7:5] != 3'b110);
        rd_vp = (ir[6:5] == 2'b11);
    end else if(ir[1:0] == 2'b10) begin
        rd_wx = (ir[7:5] == 3'b101);
        rd_wp = (ir[7:5] == 3'b101);
    end else if(ir[1:0] == 2'b00) begin
        rd_wy = (ir[7:5] == 3'b101);
        rd_wp = (ir[7:5] == 3'b101) ||
                (ir[7:6] == 2'b11 && (ir[4:2] == 3'b000 || ir[4:2] == 3'b001 || ir[4:2] == 3'b011)) ||
                (ir[7:5] == 3'b001 && ir[2]);
    end
end

//========================================================================
// Main State Machine:
// Every state change happens at cen. The case builds the next cycle's
// bus values; RES, RDY and the interrupt poll act on them afterwards.
//========================================================================
always @(posedge clk) begin
    if(cen) begin
        // Flags, NMI latch and SO at every enable
        reg_p <= p_cur;
        rep <= hold;
        v_pipe <= 1'b0;
        nmig <= nmig_c;
        nmil <= (at_e7 & vec_nmi & ~nmi_n) | nmil_c;

        if(HALF_CYCLE == 0) begin
            so_prev <= so_n;
            so_pend <= so_prev & ~so_n;
        end else
            so_pend <= 1'b0;

        // Next cycle defaults to the current one (RDY hold)
        ns = state;
        na = addr;
        ndo = dout;
        nrw = rw_n;
        nsy = sync;
        nvp = vp_n;

        if(run) begin
            nrw = 1'b1;
            nsy = 1'b0;
            nvp = 1'b1;

            case(state)
                //--------------------------------------------------------
                // Opcode Fetch (cycle 1):
                // A recognized interrupt or the reset sequence discards the
                // opcode and runs the BRK entry with PC unchanged; its
                // vector is fixed here. A 1-cycle NOP ends here.
                //--------------------------------------------------------
                ST_FETCH: begin
                    if(intg || ent_res) begin
                        intg <= 1'b0;
                        ir <= 8'h00;
                        vec_nmi <= nmig_c;
                        na = reg_pc;
                        ns = ST_INT2;
                    end else begin
                        ir <= din;
                        am <= dec_am;
                        ak <= dec_ak;
                        br_take <= f_cond(din, p_cur);

                        if(dec_am == AM_BRK) begin
                            ent_brk <= 1'b1;
                            vec_nmi <= 1'b0;
                            na = reg_pc + 16'd1;
                            ns = ST_INT2;
                        end else begin
                            reg_pc <= reg_pc + 16'd1;
                            na = reg_pc + 16'd1;

                            case(dec_am)
                                AM_IMP : ns = ST_IMP;
                                AM_IMM : ns = ST_IMM;
                                AM_ZP, AM_ZPX, AM_ZPY, AM_IZX, AM_IZY, AM_IZP, AM_BBX : ns = ST_ZP1;
                                AM_ABS, AM_ABX, AM_ABY, AM_JMP, AM_JMI, AM_JMX, AM_NP3 : ns = ST_ABS1;
                                AM_REL : ns = ST_BR2;
                                AM_JSR : ns = ST_JSR2;
                                AM_RTS, AM_RTI, AM_PUL : ns = ST_STK2;
                                AM_PSH : ns = ST_PSH2;
                                default : begin
                                    if(poll_f) intg <= 1'b1;
                                    nsy = 1'b1;
                                    ns = ST_FETCH;
                                end
                            endcase
                        end
                    end
                end

                //--------------------------------------------------------
                // Implied / Accumulator (cycle 2):
                // Dummy read of PC+1; the result is written as the next
                // opcode fetch starts.
                //--------------------------------------------------------
                ST_IMP: begin
                    case(ir)
                        8'h18 : reg_p[FLAG_C] <= 1'b0; // CLC
                        8'h38 : reg_p[FLAG_C] <= 1'b1; // SEC
                        8'h58 : reg_p[FLAG_I] <= 1'b0; // CLI
                        8'h78 : reg_p[FLAG_I] <= 1'b1; // SEI
                        8'hD8 : reg_p[FLAG_D] <= 1'b0; // CLD
                        8'hF8 : reg_p[FLAG_D] <= 1'b1; // SED
                        8'hB8 : begin // CLV
                            reg_p[FLAG_V] <= 1'b0;
                            v_pipe <= 1'b1;
                            v_val <= 1'b0;
                        end
                        8'h9A : reg_s <= reg_x; // TXS
                        8'hE8, 8'hCA, 8'hAA, 8'hBA : begin // INX DEX TAX TSX
                            reg_x <= alu_q;
                            reg_p <= alu_p;
                        end
                        8'hC8, 8'h88, 8'hA8 : begin // INY DEY TAY
                            reg_y <= alu_q;
                            reg_p <= alu_p;
                        end
                        8'h8A, 8'h98, 8'h1A, 8'h3A, 8'h0A, 8'h2A, 8'h4A, 8'h6A : begin // TXA TYA INC DEC ASL ROL LSR ROR
                            reg_a <= alu_q;
                            reg_p <= alu_p;
                        end
                        default : ; // NOP
                    endcase

                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Immediate (cycle 2) and Memory Read (last cycle):
                // ALU result to its registers; ADC and SBC load V again
                // one cycle later. In decimal mode ADC and SBC latch the
                // operand and read the next instruction's address.
                //--------------------------------------------------------
                ST_IMM,
                ST_RD: begin
                    if(state == ST_IMM)
                        reg_pc <= reg_pc + 16'd1;

                    if(dec_x) begin
                        dl <= din;
                        na = (state == ST_IMM) ? (reg_pc + 16'd1) : reg_pc;
                        ns = ST_DEC;
                    end else begin
                        if(rd_wa) reg_a <= alu_q;
                        if(rd_wx) reg_x <= alu_q;
                        if(rd_wy) reg_y <= alu_q;
                        if(rd_wp) reg_p <= alu_p;
                        if(rd_vp) begin
                            v_pipe <= 1'b1;
                            v_val <= alu_p[FLAG_V];
                        end

                        na = (state == ST_IMM) ? (reg_pc + 16'd1) : reg_pc;
                        nsy = 1'b1;
                        ns = ST_FETCH;
                    end
                end

                //--------------------------------------------------------
                // Decimal Cycle (last cycle of ADC and SBC with D = 1):
                // The result is written at its end [p.1-10].
                //--------------------------------------------------------
                ST_DEC: begin
                    reg_a <= alu_q;
                    reg_p <= alu_p;
                    v_pipe <= 1'b1;
                    v_val <= alu_p[FLAG_V];
                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Zero Page Operand (cycle 2):
                // zp, (zp),Y, (zp), BBR and BBS read 00:zp next; zp,X, zp,Y
                // and (zp,X) read PC+1 again.
                //--------------------------------------------------------
                ST_ZP1: begin
                    ad <= din;
                    reg_pc <= reg_pc + 16'd1;
                    na = {8'h00, din};

                    case(am)
                        AM_ZP : begin
                            ns = st_k;
                            nrw = ~k_wr;
                            ndo = w_dat;
                        end
                        AM_IZY, AM_IZP : ns = ST_IZY3;
                        AM_BBX : ns = ST_BB3;
                        default : begin
                            na = addr;
                            ns = ST_ZPI2;
                        end
                    endcase
                end

                //--------------------------------------------------------
                // Zero Page Indexed Dummy Read (cycle 3):
                // The index is added within page 0.
                //--------------------------------------------------------
                ST_ZPI2: begin
                    if(am == AM_IZX) begin
                        na = {8'h00, ad + reg_x};
                        ns = ST_IZX4;
                    end else begin
                        na = {8'h00, ad + idx};
                        ns = st_k;
                        nrw = ~k_wr;
                        ndo = w_dat;
                    end
                end

                //--------------------------------------------------------
                // (zp,X) Pointer (cycles 4 and 5):
                // Low byte at 00:zp+X, high byte at 00:zp+X+1.
                //--------------------------------------------------------
                ST_IZX4: begin
                    dl <= din;
                    na = {8'h00, ad + reg_x + 8'd1};
                    ns = ST_IZX5;
                end

                ST_IZX5: begin
                    na = {din, dl};
                    ns = st_k;
                    nrw = ~k_wr;
                    ndo = w_dat;
                end

                //--------------------------------------------------------
                // (zp),Y and (zp) Pointer (cycles 3 and 4):
                // BL + Y is formed as BL arrives; a page cross and every
                // (zp),Y store read zp+1 again before the carried address.
                //--------------------------------------------------------
                ST_IZY3: begin
                    {idx_cross, ad} <= {1'b0, din} + {1'b0, (am == AM_IZY) ? reg_y : 8'h00};
                    na = {8'h00, ad + 8'd1};
                    ns = ST_IZY4;
                end

                ST_IZY4: begin
                    bah <= din;
                    if(am == AM_IZP) begin
                        na = {din, ad};
                        ns = st_k;
                        nrw = ~k_wr;
                        ndo = w_dat;
                    end else if(ak == AK_R && !idx_cross) begin
                        na = {din, ad};
                        ns = ST_RD;
                    end else
                        ns = ST_IDX;
                end

                //--------------------------------------------------------
                // Absolute Operand (cycles 2 and 3):
                // AL, then AH; indexed modes add the index to AL only. A
                // page cross reads PC+2 again; without a cross, a read or
                // a shift goes to the effective address, and a store or
                // INC / DEC abs,X reads it first; JMP (abs) and JMP
                // (abs,X) read PC+2 again.
                //--------------------------------------------------------
                ST_ABS1: begin
                    ad <= din;
                    reg_pc <= reg_pc + 16'd1;
                    na = reg_pc + 16'd1;
                    ns = (am == AM_JMP) ? ST_JMP3 : ST_ABS2;
                end

                ST_ABS2: begin
                    reg_pc <= reg_pc + 16'd1;

                    case(am)
                        AM_ABX, AM_ABY : begin
                            bah <= din;
                            ad <= lo_sum[7:0];
                            idx_cross <= lo_sum[8];
                            if(lo_sum[8])
                                ns = ST_IDX;
                            else if(ak == AK_R) begin
                                na = {din, lo_sum[7:0]};
                                ns = ST_RD;
                            end else if(ak == AK_M && ir[7:6] != 2'b11) begin
                                na = {din, lo_sum[7:0]};
                                ns = ST_RMW_RD;
                            end else begin
                                na = {din, lo_sum[7:0]};
                                ns = ST_IDX;
                            end
                        end
                        AM_JMI, AM_JMX : begin
                            {bah, ad} <= {din, ad} + ((am == AM_JMX) ? {8'h00, reg_x} : 16'h0000);
                            ns = ST_JMX4;
                        end
                        AM_NP3 : begin
                            if(ir[7]) begin
                                na = {din, ad};
                                ns = ST_RD;
                            end else begin
                                np_cnt <= 2'd0;
                                na = {8'hFF, ad};
                                ns = ST_NP4;
                            end
                        end
                        default : begin
                            bah <= din;
                            na = {din, ad};
                            ns = st_k;
                            nrw = ~k_wr;
                            ndo = w_dat;
                        end
                    endcase
                end

                //--------------------------------------------------------
                // NOP 5C (cycles 4-7):
                // {$FF, AL}, then $FFFF; the last read of $FFFF follows as
                // the read cycle.
                //--------------------------------------------------------
                ST_NP4: begin
                    np_cnt <= np_cnt + 2'd1;
                    na = 16'hFFFF;
                    ns = (np_cnt == 2'd3) ? ST_RD : ST_NP4;
                end

                //--------------------------------------------------------
                // Indexed Extra Read (abs,X / abs,Y cycle 4, (zp),Y cycle 5):
                // The address before is read again: PC+2 of abs,X / abs,Y
                // across a page [p.1-10], zp+1 of (zp),Y; an abs,X / abs,Y
                // store or INC / DEC abs,X without a cross reads the
                // effective address here. The next cycle uses the carried
                // address.
                //--------------------------------------------------------
                ST_IDX: begin
                    na = {ea_hi, ad};
                    ns = st_k;
                    nrw = ~k_wr;
                    ndo = w_dat;
                end

                //--------------------------------------------------------
                // Memory Write (last cycle)
                //--------------------------------------------------------
                ST_WR: begin
                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Read-Modify-Write (two reads, then the write):
                // The second read repeats the address; the modified byte is
                // written last [p.1-10]. TSB and TRB set Z from A AND M;
                // RMB and SMB change no flag.
                //--------------------------------------------------------
                ST_RMW_RD: begin
                    dl <= alu_q;
                    rmw_c <= alu_p[FLAG_C];
                    rmw_z <= alu_p[FLAG_Z];
                    ns = ST_RMW_RR;
                end

                ST_RMW_RR: begin
                    nrw = 1'b0;
                    ndo = dl;
                    ns = ST_RMW_WR;
                end

                ST_RMW_WR: begin
                    if(ir[1:0] == 2'b00)
                        reg_p[FLAG_Z] <= rmw_z;
                    else if(ir[3:0] != 4'h7)
                        reg_p <= alu_p;

                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // JMP Absolute, Indirect and Indexed Indirect:
                // JMP (abs) and JMP (abs,X) read PC+2 again, then the pointer
                // and the carried pointer + 1 [p.1-10].
                //--------------------------------------------------------
                ST_JMP3: begin
                    reg_pc <= {din, ad};
                    na = {din, ad};
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                ST_JMX4: begin
                    na = {bah, ad};
                    ns = ST_JMI5;
                end

                ST_JMI5: begin
                    dl <= din;
                    na = ptr_inc;
                    ns = ST_JMI6;
                end

                ST_JMI6: begin
                    reg_pc <= {din, dl};
                    na = {din, dl};
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Branches:
                // The offset cycle reads the offset; a taken branch reads
                // the next address, and on a page cross reads it again.
                //--------------------------------------------------------
                ST_BR2: begin
                    dl <= din;
                    reg_pc <= reg_pc + 16'd1;
                    na = reg_pc + 16'd1;
                    if(br_take)
                        ns = ST_BR3;
                    else begin
                        nsy = 1'b1;
                        ns = ST_FETCH;
                    end
                end

                ST_BR3: begin
                    if(!br_cross) begin
                        reg_pc <= {reg_pc[15:8], br_sum[7:0]};
                        na = {reg_pc[15:8], br_sum[7:0]};
                        nsy = 1'b1;
                        ns = ST_FETCH;
                    end else begin
                        reg_pc[7:0] <= br_sum[7:0];
                        bah <= br_hi;
                        ns = ST_BR4;
                    end
                end

                ST_BR4: begin
                    reg_pc[15:8] <= bah;
                    na = {bah, reg_pc[7:0]};
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // BBR and BBS (cycles 3 and 4):
                // The zero-page byte, read twice; the bit test decides the
                // branch, whose offset is read next at PC+2.
                //--------------------------------------------------------
                ST_BB3: begin
                    br_take <= (din[ir[6:4]] == ir[7]);
                    ns = ST_BB4;
                end

                ST_BB4: begin
                    na = reg_pc;
                    ns = ST_BR2;
                end

                //--------------------------------------------------------
                // JSR:
                // AL, dummy stack read, push PCH and PCL of PC+2, then AH.
                //--------------------------------------------------------
                ST_JSR2: begin
                    ad <= din;
                    reg_pc <= reg_pc + 16'd1;
                    na = {8'h01, reg_s};
                    ns = ST_JSR3;
                end

                ST_JSR3: begin
                    nrw = 1'b0;
                    ndo = reg_pc[15:8];
                    ns = ST_JSR4;
                end

                ST_JSR4: begin
                    na = {8'h01, reg_s - 8'd1};
                    nrw = 1'b0;
                    ndo = reg_pc[7:0];
                    ns = ST_JSR5;
                end

                ST_JSR5: begin
                    na = reg_pc;
                    ns = ST_JSR6;
                end

                ST_JSR6: begin
                    reg_pc <= {din, ad};
                    reg_s <= reg_s - 8'd2;
                    na = {din, ad};
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Stack Reads (pulls, RTS, RTI cycles 2 and 3):
                // Dummy reads of PC+1 and 0100+S, then 0100+S+1.
                //--------------------------------------------------------
                ST_STK2: begin
                    na = {8'h01, reg_s};
                    ns = ST_STK3;
                end

                ST_STK3: begin
                    na = {8'h01, reg_s + 8'd1};
                    ns = (am == AM_PUL) ? ST_PUL4 : (am == AM_RTS) ? ST_RTS4 : ST_RTI4;
                end

                ST_PUL4: begin
                    case(ir)
                        8'h68 : begin // PLA
                            reg_a <= alu_q;
                            reg_p <= alu_p;
                        end
                        8'h7A : begin // PLY
                            reg_y <= alu_q;
                            reg_p <= alu_p;
                        end
                        8'hFA : begin // PLX
                            reg_x <= alu_q;
                            reg_p <= alu_p;
                        end
                        default : reg_p <= {din[7:6], 2'b11, din[3:0]}; // PLP
                    endcase
                    reg_s <= reg_s + 8'd1;
                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // RTS:
                // PCL, PCH, dummy read of the pulled address, fetch at +1.
                //--------------------------------------------------------
                ST_RTS4: begin
                    dl <= din;
                    na = {8'h01, reg_s + 8'd2};
                    ns = ST_RTS5;
                end

                ST_RTS5: begin
                    reg_pc <= {din, dl};
                    na = {din, dl};
                    ns = ST_RTS6;
                end

                ST_RTS6: begin
                    reg_pc <= reg_pc + 16'd1;
                    reg_s <= reg_s + 8'd2;
                    na = reg_pc + 16'd1;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // RTI:
                // P is loaded as cycle 5 starts, then PCL and PCH.
                //--------------------------------------------------------
                ST_RTI4: begin
                    if(!res_pend)
                        reg_p <= {din[7:6], 2'b11, din[3:0]};
                    na = {8'h01, reg_s + 8'd2};
                    ns = ST_RTI5;
                end

                ST_RTI5: begin
                    dl <= din;
                    na = {8'h01, reg_s + 8'd3};
                    ns = ST_RTI6;
                end

                ST_RTI6: begin
                    reg_pc <= {din, dl};
                    reg_s <= reg_s + 8'd3;
                    na = {din, dl};
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // PHA, PHP, PHX, PHY:
                // PHP pushes P with bits 5 and 4 set.
                //--------------------------------------------------------
                ST_PSH2: begin
                    na = {8'h01, reg_s};
                    nrw = 1'b0;
                    case(ir)
                        8'h48 : ndo = reg_a; // PHA
                        8'h5A : ndo = reg_y; // PHY
                        8'hDA : ndo = reg_x; // PHX
                        default : ndo = p_cur | 8'h30; // PHP
                    endcase
                    ns = ST_PSH3;
                end

                ST_PSH3: begin
                    reg_s <= reg_s - 8'd1;
                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // BRK, IRQ, NMI and Reset Entry (cycles 2-7):
                // Pushes PCH, PCL and P (reads for reset), then the vector.
                // The reset sequence takes a pending NMI as it reads its
                // third stack byte (absorbed) and lowers S by 3 as that
                // read ends. I is set and D cleared with the second vector
                // read [p.1-10].
                //--------------------------------------------------------
                ST_INT2: begin
                    na = {8'h01, reg_s};
                    nrw = ent_res;
                    ndo = ent_ret[15:8];
                    ns = ST_INT3;
                end

                ST_INT3: begin
                    na = {8'h01, reg_s - 8'd1};
                    nrw = ent_res;
                    ndo = ent_ret[7:0];
                    ns = ST_INT4;
                end

                ST_INT4: begin
                    if(ent_res)
                        vec_nmi <= nmig_c;
                    na = {8'h01, reg_s - 8'd2};
                    nrw = ent_res;
                    ndo = ent_brk ? (p_cur | 8'h30) : {p_cur[7:6], 2'b10, p_cur[3:0]};
                    ns = ST_INT5;
                end

                ST_INT5: begin
                    if(ent_res && !rep)
                        reg_s <= reg_s - 8'd3;
                    na = ent_res ? 16'hFFFC : vec_nmi ? 16'hFFFA : 16'hFFFE;
                    nvp = ent_res;
                    ns = ST_INT6;
                end

                ST_INT6: begin
                    dl <= din;
                    reg_p[FLAG_I] <= 1'b1;
                    reg_p[FLAG_D] <= 1'b0;
                    na = {addr[15:1], 1'b1};
                    nvp = ent_res;
                    ns = ST_INT7;
                end

                ST_INT7: begin
                    reg_pc <= {din, dl};
                    if(!ent_res)
                        reg_s <= reg_s - 8'd3;
                    ent_brk <= 1'b0;
                    ent_res <= 1'b0;
                    na = {din, dl};
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                default : ;
            endcase
        end

        //----------------------------------------------------------------
        // RES Protocol:
        // Held program counter while RES is low; the cycle that starts
        // with RES high, then the entry with SYNC on its first cycle.
        //----------------------------------------------------------------
        if(prot) begin
            na = reg_pc;
            nrw = 1'b1;
            nvp = 1'b1;

            if(state == ST_RES_LOW) begin
                nsy = 1'b0;
                ns = rst_n ? ST_RES_S : ST_RES_LOW;
            end else begin
                nsy = 1'b1;
                ns = ST_FETCH;
                res_pend <= ~rst_n;
            end
        end

        //----------------------------------------------------------------
        // End of the Cycle After RES Was Seen Low:
        // The instruction applies its results only when this was its last
        // cycle; otherwise it is dropped and its next stream address held.
        // When RES was high again at its start, this cycle counts as the
        // one that starts with RES high.
        //----------------------------------------------------------------
        else if(res_r1) begin
            res_r1 <= 1'b0;
            intg <= 1'b0;
            v_pipe <= 1'b0;
            ent_brk <= 1'b0;
            ent_res <= 1'b1;

            if(!last)
                na = reg_pc;

            nrw = 1'b1;
            nvp = 1'b1;

            if(res_rel) begin
                nsy = 1'b1;
                ns = ST_FETCH;
            end else begin
                nsy = 1'b0;
                ns = rst_n ? ST_RES_S : ST_RES_LOW;
            end

            res_pend <= ~rst_n & res_rel;
        end

        //----------------------------------------------------------------
        // RDY Hold:
        // The cycle repeats with its address, R/W and data. A held branch
        // offset cycle takes its condition again, CLV clears V again
        // while the next fetch is held, and the third stack read of the
        // reset sequence samples NMI for absorption again (and lowers S
        // at its first instance).
        //----------------------------------------------------------------
        else if(hold) begin
            if(state == ST_BR2 && am == AM_REL)
                br_take <= f_cond(ir, p_cur);
            if(state == ST_FETCH && ir == 8'hB8) begin
                v_pipe <= 1'b1;
                v_val <= 1'b0;
            end
            if(state == ST_INT5 && ent_res) begin
                vec_nmi <= nmig_c;
                if(!rep)
                    reg_s <= reg_s - 8'd3;
            end
            res_pend <= ~rst_n;
        end

        //----------------------------------------------------------------
        // Cycle After RES Was Seen Low:
        // Runs as the instruction would, with no write and SYNC low.
        //----------------------------------------------------------------
        else if(res_pend) begin
            res_pend <= 1'b0;
            res_r1 <= 1'b1;
            res_rel <= rst_n;
            nrw = 1'b1;
            nsy = 1'b0;
        end

        //----------------------------------------------------------------
        // Normal Advance:
        // Poll at the start of an instruction's last cycle (the decimal
        // cycle for ADC and SBC with D = 1), and at the start of every
        // opcode fetch for a 1-cycle NOP.
        //----------------------------------------------------------------
        else begin
            if(st_poll(ns) && !(dec_n && (ns == ST_IMM || ns == ST_RD)) && poll_v)
                intg <= 1'b1;
            if(ns == ST_FETCH)
                poll_f <= poll_v;
            res_pend <= ~rst_n;
        end

        state <= ns;
        addr <= na;
        rw_n <= nrw;
        sync <= nsy;
        vp_n <= nvp;
        if(!nrw)
            dout <= ndo;
        dout_oe <= (HALF_CYCLE == 0) && !nrw;
    end

    //--------------------------------------------------------------------
    // Phase 2 Enable (HALF_CYCLE = 1):
    // SO sampled at the end of phase 1; data bus driven in phase 2 of a
    // write cycle.
    //--------------------------------------------------------------------
    if(p2_en) begin
        so_prev <= so_n;
        so_pend <= so_prev & ~so_n;
        dout_oe <= ~rw_n;
    end
end

//========================================================================
// Debug Outputs:
// Architectural registers; in an opcode fetch cycle they hold the state
// after the previous instruction.
//========================================================================
assign dbg_pc = reg_pc;
assign dbg_a  = reg_a;
assign dbg_x  = reg_x;
assign dbg_y  = reg_y;
assign dbg_s  = reg_s;
assign dbg_p  = reg_p;
assign dbg_ir = ir;

endmodule
