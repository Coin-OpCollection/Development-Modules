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
//  Central Processing Unit for the Hudson Soft HuC6280.
//
//  Programming Model:
//    - A, X, Y, S and PC; P stores N, V, T, D, I, Z and C. B exists only
//      in a pushed copy of P: PHP and BRK push 1, interrupts push 0
//      [p.HB-4], [p.HB-5].
//    - Eight mapping registers MPR0-MPR7 turn the 16-bit logical address
//      into the 21-bit physical address [p.HB-7]. Zero page is logical
//      20xx and the stack 21xx [p.HB-3], [p.SB-11].
//    - Vectors: RESET FFFE, NMI FFFC, timer FFFA, IRQ1 FFF8, IRQ2 and BRK
//      FFF6 [p.HB-13].
//    - The 234 opcodes of the instruction map [p.HB-25]; the 22 blank
//      opcodes are 2-cycle, 1-byte NOPs.
//
//  Bus Cycle Model:
//    - addr, rw_n, sync, intc and dout are registered at the enable that
//      starts a cycle and hold for the whole cycle; din is used at the
//      enable that ends it.
//    - Cycle counts are those of the instruction map [p.HB-25]; branches
//      add 2 when taken, decimal ADC / SBC add 1, AND / ORA / EOR / ADC
//      after SET add 3 [p.SB-17]-[p.SB-33]; no count depends on a page
//      crossing.
//    - Cycles shared with the R65C02 keep its bus (operand and dummy
//      reads, read-modify-write read, read, write). Each added cycle is an
//      internal cycle (intc high): the address of the cycle before is held
//      and no data moves. Added cycles sit before a zero-page operand
//      access, an absolute or pointer data access, and the opcode fetch at
//      a new program counter; a page-cross dummy cycle takes the place of
//      the added one.
//    - CSH and CSL: opcode fetch, read of the next byte, then one internal
//      cycle at the new speed [US5483659, Fig. 5].
//    - Block transfers: 17 + 6 cycles per byte [p.HB-6]; Y, A and X are
//      pushed before the loop and pulled after it [US5034886, Fig. 4].
//
//  Clock Enables:
//    - One cen per bus cycle. A cycle lasts until an enable with rdy high;
//      a CE7 / CEK access (physical 1FE000-1FE7FF) lasts one more enable
//      when CE_WAIT = 1. bus_ce marks the enable that ends a cycle.
//    - RES, IRQ and NMI are sampled at cen only.
//
//  Reset:
//    - One cen with rst_n low resets: MPR7 = 00, MPR0-MPR6 = FF, low
//      speed, T = 0 [p.HB-18]. After release, two cycles at the held
//      address, three stack reads, FFFE and FFFF, one internal cycle;
//      I is set and D cleared.
//
//  Interrupts:
//    - IRQ (with I clear) and a latched NMI edge are polled at the enable
//      that starts an instruction's last cycle [p.HB-12]. irq_vec (00
//      IRQ2, 01 IRQ1, 10 timer) is latched when the entry starts.
//    - Entry pushes PCH, PCL and P, reads the vector, sets I and clears D
//      and T [p.HB-12]-[p.HB-17]; an interrupt that arrives during BRK or
//      an entry is taken after the handler's first instruction.
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual and
//             Software Manual (Hudson Soft); US patents 5483659 and
//             5034886; Rockwell R65C02 Datasheet, Rev. 6, June 1987 (the
//             shared cycles)
//============================================================================

`timescale 1ns/1ps

module x6280_cpu #(
    parameter CE_WAIT = 1 // 1 = CE7 / CEK accesses last one more enable
)(
    // Clock and Reset
    input  wire        clk,                // System clock
    input  wire        cen,                // Clock enable (one bus cycle per pulse)
    input  wire        rst_n,              // Active-low reset (RESET pin)
    input  wire        rdy,                // Active-high ready (RDY pin)

    // Interrupt Inputs
    input  wire        irq_n,              // Masked IRQ1 / IRQ2 / timer request
    input  wire  [1:0] irq_vec,            // Vector select (00 IRQ2, 01 IRQ1, 10 timer)
    input  wire        nmi_n,              // NMI

    // CPU Bus Interface
    output reg  [15:0] addr    = 16'h0000, // Logical address
    output wire [20:0] phys_addr,          // Physical address (MPR)
    input  wire  [7:0] din,                // Data in
    output reg   [7:0] dout    = 8'h00,    // Data out
    output reg         rw_n    = 1'b1,     // R/W (high=read, low=write)
    output reg         intc    = 1'b0,     // Internal cycle (no data transfer)
    output reg         sync    = 1'b0,     // High during opcode fetch cycle
    output reg         vp_n    = 1'b1,     // Vector Pull (low during IRQ/NMI/BRK vector reads)
    output reg         dout_oe = 1'b0,     // CPU drives the data bus
    output wire        bus_ce,             // Enable that ends the current cycle

    // Speed
    output reg         csh = 1'b0,         // High-speed mode (CSH / CSL)

    // Debug
    output wire [15:0] dbg_pc,             // Program counter
    output wire  [7:0] dbg_a,              // Accumulator
    output wire  [7:0] dbg_x,              // X index
    output wire  [7:0] dbg_y,              // Y index
    output wire  [7:0] dbg_s,              // Stack pointer
    output wire  [7:0] dbg_p,              // Processor status (bit 4 reads 1)
    output wire  [7:0] dbg_ir,             // Instruction register
    output wire [63:0] dbg_mpr             // MPR7-MPR0
);

//========================================================================
// FSM State Encoding:
// One state per bus cycle; ST_ICY, ST_BOP, ST_BPS and ST_BPL repeat for
// several cycles.
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
    ST_JMI6    = 6'd19,
    ST_JMX4    = 6'd20,
    ST_BR2     = 6'd21,
    ST_BR3     = 6'd22,
    ST_BR4     = 6'd23,
    ST_BB3     = 6'd24,
    ST_BB4     = 6'd25,
    ST_JSR2    = 6'd26,
    ST_JSR3    = 6'd27,
    ST_JSR4    = 6'd28,
    ST_JSR5    = 6'd29,
    ST_JSR6    = 6'd30,
    ST_STK2    = 6'd31,
    ST_STK3    = 6'd32,
    ST_PUL4    = 6'd33,
    ST_RTS4    = 6'd34,
    ST_RTS5    = 6'd35,
    ST_RTS6    = 6'd36,
    ST_RTI4    = 6'd37,
    ST_RTI5    = 6'd38,
    ST_RTI6    = 6'd39,
    ST_PSH2    = 6'd40,
    ST_PSH3    = 6'd41,
    ST_INT2    = 6'd42,
    ST_INT3    = 6'd43,
    ST_INT4    = 6'd44,
    ST_INT5    = 6'd45,
    ST_INT6    = 6'd46,
    ST_INT7    = 6'd47,
    ST_DEC     = 6'd48,
    ST_RES_LOW = 6'd49,
    ST_RES_S   = 6'd50,
    ST_ICY     = 6'd51,
    ST_TST1    = 6'd52,
    ST_STX2    = 6'd53,
    ST_MPR2    = 6'd54,
    ST_TRD     = 6'd55,
    ST_BOP     = 6'd56,
    ST_BPS     = 6'd57,
    ST_BRD     = 6'd58,
    ST_BWR     = 6'd59,
    ST_BPL     = 6'd60;

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
    AM_SWP = 5'd22,
    AM_CSX = 5'd23,
    AM_STX = 5'd24,
    AM_MPR = 5'd25,
    AM_BSR = 5'd26,
    AM_BLK = 5'd27;

localparam [1:0]
    AK_R = 2'd0, // read
    AK_W = 2'd1, // write
    AK_M = 2'd2; // read-modify-write

//========================================================================
// ALU Operation Codes:
// Match the encoding in x6280_alu.v.
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
    ALU_TSB = 5'h10,
    ALU_TRB = 5'h11;

//========================================================================
// Processor Status Register Bit Positions:
// Bit 4 is held at 1 so that reg_p reads as PHP would push it.
//========================================================================
localparam FLAG_C = 0;
localparam FLAG_Z = 1;
localparam FLAG_I = 2;
localparam FLAG_D = 3;
localparam FLAG_B = 4;
localparam FLAG_T = 5;
localparam FLAG_V = 6;
localparam FLAG_N = 7;

//========================================================================
// CPU Registers:
// Power-up values: A = X = Y = S = 00, D = T = 0, I = 1; the first reset
// leaves S = FD.
//========================================================================
reg  [7:0] reg_a  = 8'h00;      // Accumulator
reg  [7:0] reg_x  = 8'h00;      // X index
reg  [7:0] reg_y  = 8'h00;      // Y index
reg  [7:0] reg_s  = 8'h00;      // Stack pointer (low byte; high byte is $21)
reg  [7:0] reg_p  = 8'h14;      // Processor status
reg [15:0] reg_pc = 16'h0000;   // Program counter (next instruction-stream byte)
reg  [7:0] ir     = 8'h00;      // Instruction register (current opcode)
reg  [4:0] am     = AM_IMP;     // Addressing mode of ir
reg  [1:0] ak     = AK_R;       // Access kind of ir
reg  [5:0] state  = ST_RES_LOW;

//========================================================================
// Mapping Registers:
// mpr_last holds the last value TAM wrote, read back by TMA #00.
//========================================================================
reg [7:0] mpr [0:7];
reg [7:0] mpr_last = 8'h00;

reg pg_ff = 1'b0; // ST0-ST2 write cycle: physical page FF

integer mi;

initial begin
    for(mi = 0; mi < 7; mi = mi + 1)
        mpr[mi] = 8'hFF;
    mpr[7] = 8'h00;
end

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
reg [2:0] rmw_nvz   = 3'd0;  // N, V and Z of TSB / TRB
reg       t_act     = 1'b0;  // T was set at this instruction's fetch
reg       is_tst    = 1'b0;  // TST
reg [7:0] tst_imm   = 8'h00; // TST immediate operand

//========================================================================
// Block Transfer Registers:
// Source (SH, SL), destination (DH, DL) and length (LH, LL); bt_alt
// selects the alternating step of TIA and TAI.
//========================================================================
reg [15:0] bt_src = 16'h0000;
reg [15:0] bt_dst = 16'h0000;
reg [15:0] bt_len = 16'h0000;
reg        bt_alt = 1'b0;
reg  [2:0] bt_n   = 3'd0;

//========================================================================
// Internal Cycle Chain:
// The cycle the instruction would run next is held in icy_* while
// icy_cnt + 1 internal cycles run; icy_np = no poll in the chain.
//========================================================================
reg  [1:0] icy_cnt = 2'd0;
reg  [5:0] icy_ns  = ST_FETCH;
reg [15:0] icy_na  = 16'h0000;
reg  [7:0] icy_do  = 8'h00;
reg        icy_rw  = 1'b1;
reg        icy_sy  = 1'b0;
reg        icy_vp  = 1'b1;
reg        icy_ff  = 1'b0;
reg        icy_np  = 1'b0;

//========================================================================
// Interrupt State:
// nmig = NMI pending, nmil = NMI blocked until the line is high again,
// intg = interrupt recognized for the next fetch.
//========================================================================
reg       nmig    = 1'b0;
reg       nmil    = 1'b0;
reg       intg    = 1'b0;
reg       vec_nmi = 1'b0;  // Entry uses the NMI vector (reset: NMI absorbed)
reg       ent_brk = 1'b0;  // Entry is a BRK
reg       ent_res = 1'b1;  // Entry is the reset sequence
reg [1:0] ent_vec = 2'b00; // irq_vec latched when the entry starts

//========================================================================
// Reset and Wait State:
// res_pend = RES was low at the last enable; res_r1 = this cycle is the
// one after it; res_rel = RES was high again at the start of this cycle;
// cew_done = the CE7 / CEK wait of this cycle has run.
//========================================================================
reg res_pend = 1'b0;
reg res_r1   = 1'b0;
reg res_rel  = 1'b0;
reg cew_done = 1'b0;

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
reg        nic;
reg        nff;
reg  [2:0] ins;
reg        inp;
reg        pl;
reg        pl_icy;
reg        pl_np;

//========================================================================
// Opcode Decode:
// Addressing mode and access kind from the opcode bit fields, with the
// HuC6280 instructions and the blank opcodes as 2-cycle NOPs.
//========================================================================
function [4:0] f_am;
    input [7:0] op;
    begin
        case(op)
            8'h02, 8'h22, 8'h42 : f_am = AM_SWP; // SXY, SAX, SAY
            8'h54, 8'hD4 : f_am = AM_CSX; // CSL, CSH
            8'h03, 8'h13, 8'h23 : f_am = AM_STX; // ST0, ST1, ST2
            8'h43, 8'h53 : f_am = AM_MPR; // TMA, TAM
            8'h44 : f_am = AM_BSR; // BSR
            8'h73, 8'hC3, 8'hD3, 8'hE3, 8'hF3 : f_am = AM_BLK; // TII, TDD, TIN, TIA, TAI
            8'h83 : f_am = AM_ZP; // TST #, zp
            8'hA3 : f_am = AM_ZPX; // TST #, zp,X
            8'h93 : f_am = AM_ABS; // TST #, abs
            8'hB3 : f_am = AM_ABX; // TST #, abs,X
            8'h62, 8'h82, 8'hC2, 8'hF4,
            8'h33, 8'h63, 8'hE2, 8'h5C, 8'hDC, 8'hFC : f_am = AM_IMP; // CLA, CLX, CLY, SET, NOPs
            default: begin
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
                        else f_am = AM_IMP; // xB NOPs
                    end
                endcase
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
// Instruction Classes:
// ADC and SBC (decimal cycle); AND, ORA, EOR and ADC (T memory
// operation); TST; implied instructions with an internal third cycle.
//------------------------------------------------------------------------
function f_adsb;
    input [7:0] op;
    begin
        f_adsb = ((op[1:0] == 2'b01) && (op[6:5] == 2'b11)) || (op == 8'h72) || (op == 8'hF2);
    end
endfunction

function f_tcap;
    input [7:0] op;
    begin
        f_tcap = ((op[1:0] == 2'b01) || (op[4:0] == 5'b10010)) && !op[7];
    end
endfunction

function f_tst;
    input [7:0] op;
    begin
        f_tst = (op == 8'h83) || (op == 8'h93) || (op == 8'hA3) || (op == 8'hB3);
    end
endfunction

function f_imp3;
    input [7:0] op;
    begin
        f_imp3 = (op == 8'h02) || (op == 8'h22) || (op == 8'h42) || (op == 8'h54) || (op == 8'hD4);
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
// The interrupt poll runs at the enable that starts one of these cycles
// when it is the instruction's last; internal-cycle chains poll in their
// last cycle before an opcode fetch.
//------------------------------------------------------------------------
function st_poll;
    input [5:0] st;
    begin
        case(st)
            ST_IMP, ST_IMM, ST_RD, ST_WR, ST_RMW_WR, ST_BR2, ST_BR4,
            ST_PSH3, ST_PUL4, ST_DEC: st_poll = 1'b1;
            default: st_poll = 1'b0;
        endcase
    end
endfunction

//========================================================================
// Datapath Wires:
// Decode of din at the fetch, the index register, write data and the
// indexed, branch, pointer, entry and block-transfer address arithmetic.
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
wire [15:0] bsr_ret  = reg_pc - 16'd1;
wire [15:0] bsr_tgt  = reg_pc + {{8{ad[7]}}, ad};
wire  [7:0] tma_or   = (din[0] ? mpr[0] : 8'h00) | (din[1] ? mpr[1] : 8'h00) |
                       (din[2] ? mpr[2] : 8'h00) | (din[3] ? mpr[3] : 8'h00) |
                       (din[4] ? mpr[4] : 8'h00) | (din[5] ? mpr[5] : 8'h00) |
                       (din[6] ? mpr[6] : 8'h00) | (din[7] ? mpr[7] : 8'h00);

//------------------------------------------------------------------------
// Block Transfer Steps:
// TII and TIN step the source up, TDD down, TIA up; TAI alternates +1 / -1.
// The destination steps up for TII, TIA and TAI, down for TDD, alternates
// for TIA and stays for TIN.
//------------------------------------------------------------------------
wire [15:0] bt_src_n = (ir == 8'hC3) ? (bt_src - 16'd1) :
                       ((ir == 8'hF3) && bt_alt) ? (bt_src - 16'd1) : (bt_src + 16'd1);
wire [15:0] bt_dst_n = (ir == 8'hC3) ? (bt_dst - 16'd1) :
                       (ir == 8'hD3) ? bt_dst :
                       ((ir == 8'hE3) && bt_alt) ? (bt_dst - 16'd1) : (bt_dst + 16'd1);
wire [15:0] bt_len_n = bt_len - 16'd1;

//------------------------------------------------------------------------
// Decimal Cycle and Instruction Extensions:
// dec_x = the current ADC or SBC adds the decimal cycle; op_n is the
// opcode of the instruction whose cycle starts at this enable, and the
// *_n flags say whether its read cycle is followed by more cycles.
//------------------------------------------------------------------------
wire       dec_x  = f_adsb(ir) & reg_p[FLAG_D] & ~t_act;
wire [7:0] op_n   = (state == ST_FETCH) ? din : ir;
wire       tact_n = (state == ST_FETCH) ? (reg_p[FLAG_T] & f_tcap(din)) : t_act;
wire       dec_n  = f_adsb(op_n) & reg_p[FLAG_D] & ~tact_n;
wire       ext_n  = dec_n | tact_n | f_tst(op_n);

//========================================================================
// Physical Address:
// MPR selected by logical bits 15-13; the ST0-ST2 write cycle forces
// physical page FF [p.HB-8].
//========================================================================
assign phys_addr = {pg_ff ? 8'hFF : mpr[addr[15:13]], addr[12:0]};

//========================================================================
// Cycle Control:
// prot = RES protocol cycle; hold = the cycle does not end at this
// enable (RDY low, or the CE7 / CEK wait); last = last cycle of an
// instruction; run = the state machine advances.
//========================================================================
reg last;

always @(*) begin
    case(state)
        ST_ICY: last = (icy_cnt == 2'd0) && (icy_ns == ST_FETCH);
        ST_IMP: last = ~f_imp3(ir);
        ST_WR, ST_RMW_WR, ST_BR4, ST_PSH3, ST_PUL4, ST_DEC: last = 1'b1;
        ST_IMM, ST_RD: last = ~dec_x & ~t_act & ~is_tst;
        ST_BR2: last = ~br_take;
        default: last = 1'b0;
    endcase
end

wire ce_rng  = (phys_addr[20:11] == 10'b11_1111_1100);
wire hold_ce = (CE_WAIT != 0) & ce_rng & ~intc & ~cew_done;
wire prot    = (state == ST_RES_LOW) || (state == ST_RES_S);
wire hold    = (~rdy | hold_ce) & ~prot & ~res_r1 & ~res_pend;
wire run     = ~prot & ~hold & (~res_r1 | last);
wire at_e7   = run & (state == ST_INT6);

assign bus_ce = cen & ~hold;

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
wire [7:0] alu_pin = {reg_p[7:1], alu_c};
wire [7:0] alu_q;
wire [7:0] alu_p;

x6280_alu u_alu (
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
        // The operand is on din; op from the opcode group. TST ANDs its
        // immediate byte with the operand.
        //----------------------------------------------------------------
        ST_IMM,
        ST_RD: begin
            if(is_tst) begin
                alu_a = tst_imm;
                alu_op_sel = ALU_BIT;
            end else if(g01) begin
                case(ir[7:5])
                    3'b000 : alu_op_sel = ALU_OR; // ORA
                    3'b001 : alu_op_sel = ALU_AND; // AND
                    3'b010 : alu_op_sel = ALU_EOR; // EOR
                    3'b011 : alu_op_sel = ALU_ADC; // ADC
                    3'b101 : begin alu_a = din; alu_op_sel = ALU_EQ2; end // LDA
                    3'b110 : alu_op_sel = ALU_CMP; // CMP
                    3'b111 : alu_op_sel = ALU_SBC; // SBC
                    default : alu_op_sel = ALU_BIT; // BIT #
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
        // T Memory Operation:
        // The zero-page byte at X (din) with the operand latched before.
        //----------------------------------------------------------------
        ST_TRD: begin
            alu_a = din;
            alu_b = dl;
            case(ir[6:5])
                2'b00 : alu_op_sel = ALU_OR; // ORA
                2'b01 : alu_op_sel = ALU_AND; // AND
                2'b10 : alu_op_sel = ALU_EOR; // EOR
                default : alu_op_sel = ALU_ADC; // ADC
            endcase
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

always @(*) begin
    rd_wa = 1'b0;
    rd_wx = 1'b0;
    rd_wy = 1'b0;
    rd_wp = 1'b0;

    if(is_tst) begin
        rd_wp = 1'b1;
    end else if(g01) begin
        rd_wp = (ir[7:5] != 3'b100) || (ir == 8'h89);
        rd_wa = (ir[7:5] != 3'b100) && (ir[7:5] != 3'b110);
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
// bus values; internal cycles, RES, RDY and the interrupt poll act on
// them afterwards.
//========================================================================
always @(posedge clk) begin
    if(cen) begin
        // NMI latch and the CE7 / CEK wait at every enable
        nmig <= nmig_c;
        nmil <= (at_e7 & vec_nmi & ~nmi_n) | nmil_c;
        cew_done <= hold & (cew_done | hold_ce);

        // Next cycle defaults to the current one (RDY hold)
        ns = state;
        na = addr;
        ndo = dout;
        nrw = rw_n;
        nsy = sync;
        nvp = vp_n;
        nic = intc;
        nff = pg_ff;
        ins = 3'd0;
        inp = 1'b0;
        pl_icy = 1'b0;
        pl_np = 1'b0;

        if(run) begin
            nrw = 1'b1;
            nsy = 1'b0;
            nvp = 1'b1;
            nic = 1'b0;
            nff = 1'b0;

            case(state)
                //--------------------------------------------------------
                // Opcode Fetch (cycle 1):
                // A recognized interrupt or the reset sequence discards the
                // opcode and runs the BRK entry with PC unchanged; its
                // vector is fixed here. T is latched for the fetched
                // instruction and cleared.
                //--------------------------------------------------------
                ST_FETCH: begin
                    if(intg || ent_res) begin
                        intg <= 1'b0;
                        ir <= 8'h00;
                        vec_nmi <= nmig_c;
                        ent_vec <= irq_vec;
                        na = reg_pc;
                        ns = ST_INT2;
                    end else begin
                        ir <= din;
                        am <= dec_am;
                        ak <= dec_ak;
                        br_take <= f_cond(din, reg_p);
                        t_act <= tact_n;
                        is_tst <= f_tst(din);
                        reg_p[FLAG_T] <= 1'b0;

                        if(dec_am == AM_BRK) begin
                            ent_brk <= 1'b1;
                            vec_nmi <= 1'b0;
                            na = reg_pc + 16'd1;
                            ns = ST_INT2;
                        end else begin
                            reg_pc <= reg_pc + 16'd1;
                            na = reg_pc + 16'd1;

                            case(dec_am)
                                AM_IMP, AM_SWP, AM_CSX : ns = ST_IMP;
                                AM_IMM : ns = ST_IMM;
                                AM_ZP, AM_ZPX, AM_ZPY, AM_IZX, AM_IZY, AM_IZP, AM_BBX : ns = f_tst(din) ? ST_TST1 : ST_ZP1;
                                AM_ABS, AM_ABX, AM_ABY, AM_JMP, AM_JMI, AM_JMX : ns = f_tst(din) ? ST_TST1 : ST_ABS1;
                                AM_REL : ns = ST_BR2;
                                AM_JSR, AM_BSR : ns = ST_JSR2;
                                AM_RTS, AM_RTI, AM_PUL : ns = ST_STK2;
                                AM_PSH : ns = ST_PSH2;
                                AM_STX : ns = ST_STX2;
                                AM_MPR : ns = ST_MPR2;
                                default : begin // AM_BLK
                                    bt_n <= 3'd0;
                                    ns = ST_BOP;
                                end
                            endcase
                        end
                    end
                end

                //--------------------------------------------------------
                // Implied / Accumulator (cycle 2):
                // Dummy read of PC+1; the result is written as the next
                // cycle starts. SAX, SAY, SXY, CSL and CSH add an internal
                // cycle, which runs at the new speed for CSL and CSH.
                //--------------------------------------------------------
                ST_IMP: begin
                    case(ir)
                        8'h18 : reg_p[FLAG_C] <= 1'b0; // CLC
                        8'h38 : reg_p[FLAG_C] <= 1'b1; // SEC
                        8'h58 : reg_p[FLAG_I] <= 1'b0; // CLI
                        8'h78 : reg_p[FLAG_I] <= 1'b1; // SEI
                        8'hD8 : reg_p[FLAG_D] <= 1'b0; // CLD
                        8'hF8 : reg_p[FLAG_D] <= 1'b1; // SED
                        8'hB8 : reg_p[FLAG_V] <= 1'b0; // CLV
                        8'hF4 : reg_p[FLAG_T] <= 1'b1; // SET
                        8'h9A : reg_s <= reg_x; // TXS
                        8'h62 : reg_a <= 8'h00; // CLA
                        8'h82 : reg_x <= 8'h00; // CLX
                        8'hC2 : reg_y <= 8'h00; // CLY
                        8'h22 : begin // SAX
                            reg_a <= reg_x;
                            reg_x <= reg_a;
                        end
                        8'h42 : begin // SAY
                            reg_a <= reg_y;
                            reg_y <= reg_a;
                        end
                        8'h02 : begin // SXY
                            reg_x <= reg_y;
                            reg_y <= reg_x;
                        end
                        8'h54 : csh <= 1'b0; // CSL
                        8'hD4 : csh <= 1'b1; // CSH
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

                    if(f_imp3(ir))
                        ins = 3'd1;
                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Immediate (cycle 2) and Memory Read (last cycle):
                // ALU result to its registers. With T latched, AND / ORA /
                // EOR / ADC read the zero-page byte at X next; in decimal
                // mode ADC and SBC latch the operand and read the next
                // instruction's address; TST ends with two internal cycles.
                //--------------------------------------------------------
                ST_IMM,
                ST_RD: begin
                    if(state == ST_IMM)
                        reg_pc <= reg_pc + 16'd1;

                    if(t_act) begin
                        dl <= din;
                        na = {8'h20, reg_x};
                        ns = ST_TRD;
                    end else if(dec_x) begin
                        dl <= din;
                        na = (state == ST_IMM) ? (reg_pc + 16'd1) : reg_pc;
                        ns = ST_DEC;
                    end else begin
                        if(rd_wa) reg_a <= alu_q;
                        if(rd_wx) reg_x <= alu_q;
                        if(rd_wy) reg_y <= alu_q;
                        if(rd_wp) reg_p <= alu_p;

                        if(is_tst)
                            ins = 3'd2;
                        na = (state == ST_IMM) ? (reg_pc + 16'd1) : reg_pc;
                        nsy = 1'b1;
                        ns = ST_FETCH;
                    end
                end

                //--------------------------------------------------------
                // T Memory Operation (read of 20:X):
                // The result goes back to 20:X after one internal cycle
                // (two for ADC in decimal mode); A is unchanged.
                //--------------------------------------------------------
                ST_TRD: begin
                    reg_p <= alu_p;
                    nrw = 1'b0;
                    ndo = alu_q;
                    ins = (ir[6:5] == 2'b11 && reg_p[FLAG_D]) ? 3'd2 : 3'd1;
                    ns = ST_WR;
                end

                //--------------------------------------------------------
                // Decimal Cycle (last cycle of ADC and SBC with D = 1):
                // The result is written at its end.
                //--------------------------------------------------------
                ST_DEC: begin
                    reg_a <= alu_q;
                    reg_p <= alu_p;
                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // TST Immediate (cycle 2):
                // The immediate byte, then the zero-page or absolute operand.
                //--------------------------------------------------------
                ST_TST1: begin
                    tst_imm <= din;
                    reg_pc <= reg_pc + 16'd1;
                    na = reg_pc + 16'd1;
                    ns = (am == AM_ZP || am == AM_ZPX) ? ST_ZP1 : ST_ABS1;
                end

                //--------------------------------------------------------
                // ST0 / ST1 / ST2 (cycle 2):
                // The immediate byte is written to physical 1FE000 / 1FE002 /
                // 1FE003 after one internal cycle [p.HB-8].
                //--------------------------------------------------------
                ST_STX2: begin
                    reg_pc <= reg_pc + 16'd1;
                    na = {14'h0000, ir[5] | ir[4], ir[5]};
                    nrw = 1'b0;
                    ndo = din;
                    nff = 1'b1;
                    ins = 3'd1;
                    ns = ST_WR;
                end

                //--------------------------------------------------------
                // TAM / TMA (cycle 2):
                // TAM loads every selected MPR with A; TMA reads the OR of
                // the selected MPRs, or the last TAM value for mask 00.
                //--------------------------------------------------------
                ST_MPR2: begin
                    reg_pc <= reg_pc + 16'd1;
                    if(ir[4]) begin // TAM
                        for(mi = 0; mi < 8; mi = mi + 1)
                            if(din[mi])
                                mpr[mi] <= reg_a;
                        if(din != 8'h00)
                            mpr_last <= reg_a;
                        ins = 3'd3;
                    end else begin // TMA
                        reg_a <= (din == 8'h00) ? mpr_last : tma_or;
                        ins = 3'd2;
                    end
                    na = reg_pc + 16'd1;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Zero Page Operand (cycle 2):
                // zp, (zp),Y, (zp), BBR and BBS read 20:zp after an internal
                // cycle; zp,X, zp,Y and (zp,X) read PC+1 again.
                //--------------------------------------------------------
                ST_ZP1: begin
                    ad <= din;
                    reg_pc <= reg_pc + 16'd1;
                    na = {8'h20, din};

                    case(am)
                        AM_ZP : begin
                            ns = st_k;
                            nrw = ~k_wr;
                            ndo = w_dat;
                            ins = 3'd1;
                        end
                        AM_IZY, AM_IZP : begin
                            ns = ST_IZY3;
                            ins = 3'd1;
                        end
                        AM_BBX : begin
                            ns = ST_BB3;
                            ins = 3'd1;
                        end
                        default : begin
                            na = addr;
                            ns = ST_ZPI2;
                        end
                    endcase
                end

                //--------------------------------------------------------
                // Zero Page Indexed Dummy Read (cycle 3):
                // The index is added within page 20.
                //--------------------------------------------------------
                ST_ZPI2: begin
                    if(am == AM_IZX) begin
                        na = {8'h20, ad + reg_x};
                        ns = ST_IZX4;
                    end else begin
                        na = {8'h20, ad + idx};
                        ns = st_k;
                        nrw = ~k_wr;
                        ndo = w_dat;
                    end
                end

                //--------------------------------------------------------
                // (zp,X) Pointer (cycles 4 and 5):
                // Low byte at 20:zp+X, high byte at 20:zp+X+1; an internal
                // cycle before the data access.
                //--------------------------------------------------------
                ST_IZX4: begin
                    dl <= din;
                    na = {8'h20, ad + reg_x + 8'd1};
                    ns = ST_IZX5;
                end

                ST_IZX5: begin
                    na = {din, dl};
                    ns = st_k;
                    nrw = ~k_wr;
                    ndo = w_dat;
                    ins = 3'd1;
                end

                //--------------------------------------------------------
                // (zp),Y and (zp) Pointer:
                // BL + Y is formed as BL arrives. (zp) and a (zp),Y read
                // without a page cross add an internal cycle before the
                // data access; a page cross and every (zp),Y store read
                // zp+1 again before the carried address.
                //--------------------------------------------------------
                ST_IZY3: begin
                    {idx_cross, ad} <= {1'b0, din} + {1'b0, (am == AM_IZY) ? reg_y : 8'h00};
                    na = {8'h20, ad + 8'd1};
                    ns = ST_IZY4;
                end

                ST_IZY4: begin
                    bah <= din;
                    if(am == AM_IZP) begin
                        na = {din, ad};
                        ns = st_k;
                        nrw = ~k_wr;
                        ndo = w_dat;
                        ins = 3'd1;
                    end else if(ak == AK_R && !idx_cross) begin
                        na = {din, ad};
                        ns = ST_RD;
                        ins = 3'd1;
                    end else
                        ns = ST_IDX;
                end

                //--------------------------------------------------------
                // Absolute Operand (cycles 2 and 3):
                // AL, then AH; indexed modes add the index to AL only. A
                // read or shift without a page cross, and every absolute
                // access, add an internal cycle; a page cross reads PC+2
                // again; a store or INC / DEC abs,X without a cross reads
                // the effective address first; JMP (abs) and JMP (abs,X)
                // read PC+2 again.
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
                                ins = 3'd1;
                            end else if(ak == AK_M && ir[7:6] != 2'b11) begin
                                na = {din, lo_sum[7:0]};
                                ns = ST_RMW_RD;
                                ins = 3'd1;
                            end else begin
                                na = {din, lo_sum[7:0]};
                                ns = ST_IDX;
                            end
                        end
                        AM_JMI, AM_JMX : begin
                            {bah, ad} <= {din, ad} + ((am == AM_JMX) ? {8'h00, reg_x} : 16'h0000);
                            ns = ST_JMX4;
                        end
                        default : begin
                            bah <= din;
                            na = {din, ad};
                            ns = st_k;
                            nrw = ~k_wr;
                            ndo = w_dat;
                            ins = 3'd1;
                        end
                    endcase
                end

                //--------------------------------------------------------
                // Indexed Extra Read (abs,X / abs,Y cycle 4, (zp),Y cycle 6):
                // The address before is read again: PC+2 of abs,X / abs,Y
                // across a page, zp+1 of (zp),Y; an abs,X / abs,Y store or
                // INC / DEC abs,X without a cross reads the effective
                // address here. The next cycle uses the carried address.
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
                // written last. TSB and TRB set N and V from the operand and
                // Z from A AND M; RMB and SMB change no flag and add an
                // internal cycle before the write.
                //--------------------------------------------------------
                ST_RMW_RD: begin
                    dl <= alu_q;
                    rmw_c <= alu_p[FLAG_C];
                    rmw_nvz <= {alu_p[FLAG_N], alu_p[FLAG_V], alu_p[FLAG_Z]};
                    ns = ST_RMW_RR;
                end

                ST_RMW_RR: begin
                    nrw = 1'b0;
                    ndo = dl;
                    if(ir[3:0] == 4'h7)
                        ins = 3'd1;
                    ns = ST_RMW_WR;
                end

                ST_RMW_WR: begin
                    if(ir[1:0] == 2'b00) begin
                        reg_p[FLAG_N] <= rmw_nvz[2];
                        reg_p[FLAG_V] <= rmw_nvz[1];
                        reg_p[FLAG_Z] <= rmw_nvz[0];
                    end else if(ir[3:0] != 4'h7)
                        reg_p <= alu_p;

                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // JMP Absolute, Indirect and Indexed Indirect:
                // JMP (abs) and JMP (abs,X) read PC+2 again, then the pointer
                // and the carried pointer + 1; an internal cycle before the
                // fetch at the new PC.
                //--------------------------------------------------------
                ST_JMP3: begin
                    reg_pc <= {din, ad};
                    na = {din, ad};
                    nsy = 1'b1;
                    ins = 3'd1;
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
                    ins = 3'd1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Branches:
                // The offset cycle reads the offset; a taken branch reads
                // the next address, then runs an internal cycle, or reads it
                // again on a page cross.
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
                        ins = 3'd1;
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
                // BBR and BBS:
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
                // JSR and BSR:
                // AL (BSR: the offset), dummy stack read, push PCH and PCL
                // (JSR: PC+2, BSR: PC+1). JSR then reads AH and runs an
                // internal cycle; BSR runs three internal cycles before the
                // fetch at PC+2 + offset.
                //--------------------------------------------------------
                ST_JSR2: begin
                    ad <= din;
                    reg_pc <= reg_pc + 16'd1;
                    na = {8'h21, reg_s};
                    ns = ST_JSR3;
                end

                ST_JSR3: begin
                    nrw = 1'b0;
                    ndo = (am == AM_BSR) ? bsr_ret[15:8] : reg_pc[15:8];
                    ns = ST_JSR4;
                end

                ST_JSR4: begin
                    na = {8'h21, reg_s - 8'd1};
                    nrw = 1'b0;
                    ndo = (am == AM_BSR) ? bsr_ret[7:0] : reg_pc[7:0];
                    ns = ST_JSR5;
                end

                ST_JSR5: begin
                    if(am == AM_BSR) begin
                        reg_pc <= bsr_tgt;
                        reg_s <= reg_s - 8'd2;
                        na = bsr_tgt;
                        nsy = 1'b1;
                        ins = 3'd3;
                        ns = ST_FETCH;
                    end else begin
                        na = reg_pc;
                        ns = ST_JSR6;
                    end
                end

                ST_JSR6: begin
                    reg_pc <= {din, ad};
                    reg_s <= reg_s - 8'd2;
                    na = {din, ad};
                    nsy = 1'b1;
                    ins = 3'd1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Stack Reads (pulls, RTS, RTI cycles 2 and 3):
                // Dummy reads of PC+1 and 21:S, then 21:S+1.
                //--------------------------------------------------------
                ST_STK2: begin
                    na = {8'h21, reg_s};
                    ns = ST_STK3;
                end

                ST_STK3: begin
                    na = {8'h21, reg_s + 8'd1};
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
                        default : reg_p <= {din[7:5], 1'b1, din[3:0]}; // PLP
                    endcase
                    reg_s <= reg_s + 8'd1;
                    na = reg_pc;
                    nsy = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // RTS:
                // PCL, PCH, dummy read of the pulled address, internal
                // cycle, fetch at +1.
                //--------------------------------------------------------
                ST_RTS4: begin
                    dl <= din;
                    na = {8'h21, reg_s + 8'd2};
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
                    ins = 3'd1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // RTI:
                // P (T included) is loaded as cycle 5 starts, then PCL and
                // PCH, then an internal cycle.
                //--------------------------------------------------------
                ST_RTI4: begin
                    if(!res_pend)
                        reg_p <= {din[7:5], 1'b1, din[3:0]};
                    na = {8'h21, reg_s + 8'd2};
                    ns = ST_RTI5;
                end

                ST_RTI5: begin
                    dl <= din;
                    na = {8'h21, reg_s + 8'd3};
                    ns = ST_RTI6;
                end

                ST_RTI6: begin
                    reg_pc <= {din, dl};
                    reg_s <= reg_s + 8'd3;
                    na = {din, dl};
                    nsy = 1'b1;
                    ins = 3'd1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // PHA, PHP, PHX, PHY:
                // PHP pushes P with B set; T reads 0 (cleared at the fetch).
                //--------------------------------------------------------
                ST_PSH2: begin
                    na = {8'h21, reg_s};
                    nrw = 1'b0;
                    case(ir)
                        8'h48 : ndo = reg_a; // PHA
                        8'h5A : ndo = reg_y; // PHY
                        8'hDA : ndo = reg_x; // PHX
                        default : ndo = reg_p | 8'h10; // PHP
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
                // Block Transfer Operands (cycles 2-7):
                // SL, SH, DL, DH, LL, LH; then an internal cycle and the
                // push of Y.
                //--------------------------------------------------------
                ST_BOP: begin
                    case(bt_n)
                        3'd0 : bt_src[7:0] <= din;
                        3'd1 : bt_src[15:8] <= din;
                        3'd2 : bt_dst[7:0] <= din;
                        3'd3 : bt_dst[15:8] <= din;
                        3'd4 : bt_len[7:0] <= din;
                        default : bt_len[15:8] <= din;
                    endcase
                    reg_pc <= reg_pc + 16'd1;

                    if(bt_n != 3'd5) begin
                        bt_n <= bt_n + 3'd1;
                        na = reg_pc + 16'd1;
                    end else begin
                        bt_n <= 3'd0;
                        bt_alt <= 1'b0;
                        na = {8'h21, reg_s};
                        nrw = 1'b0;
                        ndo = reg_y;
                        ins = 3'd1;
                        ns = ST_BPS;
                    end
                end

                //--------------------------------------------------------
                // Block Transfer Pushes:
                // Y at 21:S, A at 21:S-1, X at 21:S-2; S itself is not
                // changed [US5034886, Fig. 4].
                //--------------------------------------------------------
                ST_BPS: begin
                    if(bt_n == 3'd0) begin
                        bt_n <= 3'd1;
                        na = {8'h21, reg_s - 8'd1};
                        nrw = 1'b0;
                        ndo = reg_a;
                    end else if(bt_n == 3'd1) begin
                        bt_n <= 3'd2;
                        na = {8'h21, reg_s - 8'd2};
                        nrw = 1'b0;
                        ndo = reg_x;
                    end else begin
                        na = bt_src;
                        ns = ST_BRD;
                    end
                end

                //--------------------------------------------------------
                // Block Transfer Byte (6 cycles):
                // Read the source, write the destination, four internal
                // cycles; after the last byte the pulls follow.
                //--------------------------------------------------------
                ST_BRD: begin
                    na = bt_dst;
                    nrw = 1'b0;
                    ndo = din;
                    ns = ST_BWR;
                end

                ST_BWR: begin
                    bt_src <= bt_src_n;
                    bt_dst <= bt_dst_n;
                    bt_len <= bt_len_n;
                    bt_alt <= ~bt_alt;
                    ins = 3'd4;

                    if(bt_len_n != 16'h0000) begin
                        na = bt_src_n;
                        ns = ST_BRD;
                    end else begin
                        bt_n <= 3'd0;
                        na = {8'h21, reg_s - 8'd2};
                        ns = ST_BPL;
                    end
                end

                //--------------------------------------------------------
                // Block Transfer Pulls:
                // X from 21:S-2, A from 21:S-1, Y from 21:S; three internal
                // cycles before the fetch.
                //--------------------------------------------------------
                ST_BPL: begin
                    if(bt_n == 3'd0) begin
                        reg_x <= din;
                        bt_n <= 3'd1;
                        na = {8'h21, reg_s - 8'd1};
                    end else if(bt_n == 3'd1) begin
                        reg_a <= din;
                        bt_n <= 3'd2;
                        na = {8'h21, reg_s};
                    end else begin
                        reg_y <= din;
                        na = reg_pc;
                        nsy = 1'b1;
                        ins = 3'd3;
                        ns = ST_FETCH;
                    end
                end

                //--------------------------------------------------------
                // BRK, IRQ, NMI and Reset Entry (cycles 2-8):
                // Pushes PCH, PCL and P (reads for reset), then the vector
                // and an internal cycle. The reset sequence takes a pending
                // NMI as it reads its third stack byte (absorbed) and
                // lowers S by 3 as that read ends. I is set and D and T
                // cleared with the second vector read.
                //--------------------------------------------------------
                ST_INT2: begin
                    na = {8'h21, reg_s};
                    nrw = ent_res;
                    ndo = ent_ret[15:8];
                    ns = ST_INT3;
                end

                ST_INT3: begin
                    na = {8'h21, reg_s - 8'd1};
                    nrw = ent_res;
                    ndo = ent_ret[7:0];
                    ns = ST_INT4;
                end

                ST_INT4: begin
                    if(ent_res)
                        vec_nmi <= nmig_c;
                    na = {8'h21, reg_s - 8'd2};
                    nrw = ent_res;
                    ndo = ent_brk ? (reg_p | 8'h10) : {reg_p[7:5], 1'b0, reg_p[3:0]};
                    ns = ST_INT5;
                end

                ST_INT5: begin
                    if(ent_res)
                        reg_s <= reg_s - 8'd3;
                    na = ent_res ? 16'hFFFE : vec_nmi ? 16'hFFFC : ent_brk ? 16'hFFF6 :
                         {12'hFFF, 3'b011 + {1'b0, ent_vec}, 1'b0};
                    nvp = ent_res;
                    ns = ST_INT6;
                end

                ST_INT6: begin
                    dl <= din;
                    reg_p[FLAG_I] <= 1'b1;
                    reg_p[FLAG_D] <= 1'b0;
                    reg_p[FLAG_T] <= 1'b0;
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
                    ins = 3'd1;
                    inp = 1'b1;
                    ns = ST_FETCH;
                end

                //--------------------------------------------------------
                // Internal Cycle Chain:
                // Holds the address with no transfer; the held cycle runs
                // after the last one.
                //--------------------------------------------------------
                ST_ICY: begin
                    if(icy_cnt == 2'd0) begin
                        ns = icy_ns;
                        na = icy_na;
                        nrw = icy_rw;
                        ndo = icy_do;
                        nsy = icy_sy;
                        nvp = icy_vp;
                        nff = icy_ff;
                    end else begin
                        icy_cnt <= icy_cnt - 2'd1;
                        nic = 1'b1;
                        pl_icy = (icy_cnt == 2'd1) && (icy_ns == ST_FETCH);
                        pl_np = icy_np;
                    end
                end

                default : ;
            endcase

            //------------------------------------------------------------
            // Internal Cycles Before the Next Cycle:
            // The cycle built above is held while ins internal cycles run.
            //------------------------------------------------------------
            if(ins != 3'd0) begin
                icy_cnt <= ins[1:0] - 2'd1;
                icy_ns <= ns;
                icy_na <= na;
                icy_do <= ndo;
                icy_rw <= nrw;
                icy_sy <= nsy;
                icy_vp <= nvp;
                icy_ff <= nff;
                icy_np <= inp;
                pl_icy = (ins == 3'd1) && (ns == ST_FETCH);
                pl_np = inp;
                ns = ST_ICY;
                na = addr;
                nrw = 1'b1;
                nsy = 1'b0;
                nvp = 1'b1;
                nic = 1'b1;
                nff = 1'b0;
            end
        end

        //----------------------------------------------------------------
        // RES Protocol:
        // Held program counter while RES is low; the cycle that starts
        // with RES high, then the entry with SYNC on its first cycle.
        // MPR7, the speed and T are reset.
        //----------------------------------------------------------------
        if(prot) begin
            na = reg_pc;
            nrw = 1'b1;
            nvp = 1'b1;
            nic = 1'b0;
            nff = 1'b0;
            for(mi = 0; mi < 7; mi = mi + 1)
                mpr[mi] <= 8'hFF;
            mpr[7] <= 8'h00;
            csh <= 1'b0;
            reg_p[FLAG_T] <= 1'b0;

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
            ent_brk <= 1'b0;
            ent_res <= 1'b1;
            for(mi = 0; mi < 7; mi = mi + 1)
                mpr[mi] <= 8'hFF;
            mpr[7] <= 8'h00;
            csh <= 1'b0;
            reg_p[FLAG_T] <= 1'b0;

            if(!last)
                na = reg_pc;

            nrw = 1'b1;
            nvp = 1'b1;
            nic = 1'b0;
            nff = 1'b0;

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
        // RDY Hold and CE7 / CEK Wait:
        // The cycle repeats with its address, R/W and data.
        //----------------------------------------------------------------
        else if(hold) begin
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
        // cycle for ADC and SBC with D = 1, the internal cycle before the
        // fetch where one is added; none in an entry).
        //----------------------------------------------------------------
        else begin
            if(ns == ST_ICY)
                pl = pl_icy & ~pl_np;
            else if(ns == ST_IMP)
                pl = ~f_imp3(op_n);
            else if(ns == ST_IMM || ns == ST_RD)
                pl = ~ext_n;
            else
                pl = st_poll(ns);

            if(pl && poll_v)
                intg <= 1'b1;
            res_pend <= ~rst_n;
        end

        state <= ns;
        addr <= na;
        rw_n <= nrw;
        sync <= nsy;
        vp_n <= nvp;
        intc <= nic;
        pg_ff <= nff;
        if(!nrw)
            dout <= ndo;
        dout_oe <= !nrw;
    end
end

//========================================================================
// Debug Outputs:
// Architectural registers; in an opcode fetch cycle they hold the state
// after the previous instruction.
//========================================================================
assign dbg_pc  = reg_pc;
assign dbg_a   = reg_a;
assign dbg_x   = reg_x;
assign dbg_y   = reg_y;
assign dbg_s   = reg_s;
assign dbg_p   = reg_p;
assign dbg_ir  = ir;
assign dbg_mpr = {mpr[7], mpr[6], mpr[5], mpr[4], mpr[3], mpr[2], mpr[1], mpr[0]};

endmodule
