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
//  Comprehensive testbench for the Rockwell R65C02 CPU implementation.
//
//  Verifies x65c02 and x65c02_alu: every opcode cycle by cycle, the
//  R65C02 bus changes (two reads and one write in read-modify-write, the
//  read of the last instruction byte on indexed page crossings and
//  stores, the decimal-mode cycle, JMP (abs) and JMP (abs,X), BBR and
//  BBS, the undefined NOPs), reset, interrupts, RDY on reads and writes,
//  SO, SYNC and vp_n, decimal mode over every input, both clock modes and
//  several enable ratios. Registers are set only by real instructions (a
//  preamble LDX #s; TXS; LDA #p; PHA; LDA #a; LDX #x; LDY #y; PLP; JMP,
//  or LDX #s-3; TXS; LDA #a; LDX #x; LDY #y; RTI for the instruction
//  vectors) and results are read back through the bus (PHP and stores)
//  and the debug outputs. No register of the CPU is written from here.
//
//  DUTs:
//    uut     - HALF_CYCLE = 0: one cen per bus cycle, cen_p2 unconnected
//    uuth    - HALF_CYCLE = 1: cen and cen_p2 (rising clock edge)
//    alu_uut - x65c02_alu driven directly
//  Both CPUs share clock, enables and inputs, each with its own 64 KB
//  memory model. Enables: tb_ratio clk per bus cycle, cen_p2 halfway,
//  optional random stops between enables.
//
//  Expected values:
//    - Directed tests: the bus pattern and results stated in each test,
//      from the datasheet and the rules the header of x65c02.v states.
//    - sim/tb_x65c02_ops.hex: one instruction per record with its initial
//      registers and memory, every bus cycle and the final registers and
//      memory (+vec=<file> selects another file of the same format).
//    - Decimal mode: the 65C02 digit sequences in the reference functions.
//
//  Test Organization:
//    CPU Section A:  Reset: power-up values, first and warm reset, the
//                    stack reads and S - 3, I set and D cleared, the bus
//                    while RES is low, RES sampled only at cen, writes in
//                    the cycle RES falls, RES at every cycle, RES inside a
//                    running reset sequence, RDY during the RES protocol
//    BUS Section B:  Every opcode from the instruction vectors per cycle,
//                    addressing-mode groups, data bus drive window
//    CPU Section C:  All 256 opcodes (results, flags, cycle counts),
//                    random instruction streams in both clock modes
//    ALU Section D:  Every ALU operation over every input; decimal ADC
//                    and SBC through the CPU over every A x operand x C
//    CPU Section E:  R65C02 bus: read-modify-write, indexed extra cycles,
//                    decimal cycle, JMP (abs) and JMP (abs,X), BBR and BBS,
//                    BRA, the undefined NOPs, shift abs,X, BIT #, TSB, TRB,
//                    RMB, SMB, STZ
//    INT Section F:  Recognition point, branch delay, CLI/SEI/PLP/RTI
//                    latency, entry sequence, B bit and D cleared, no
//                    takeover of BRK or an entry, NMI edge latch, NMI
//                    across RES, the poll point of every instruction kind
//    BUS Section G:  RDY: held reads, held writes, held fetches, held dummy
//                    reads, interrupts only with RDY high, RDY sweeps
//    CPU Section H:  SO: sampling point in both modes, width, collisions
//                    with V loads, during RDY holds, before BVC, CLV with
//                    the next fetch held
//    BUS Section J:  SYNC on opcode fetches only, vp_n on entry vectors
//    CLK Section K:  Enable ratios 1-16, random stops, CYCLE/HALF
//                    lockstep, outputs change only at enables, no X
//
//  Reference: Rockwell R65C02 / R65C102 / R65C112 CPU Datasheet, Rev. 6,
//             June 1987, pins [p.1-4]-[p.1-6], enhancements [p.1-10],
//             op code matrix [p.1-11], instruction summary [p.1-12]; bus
//             recordings of an R65C02P2 (extra-cycle addresses; the
//             cycles of shift abs,X and NOP 5C).
//============================================================================

`timescale 1ns/1ps

module tb_x65c02;

//=========================================================================
// Test Signals:
// Clock, the two shared enables and the shared CPU inputs.
//=========================================================================
reg clk;
reg cen;
reg cen_p2;
reg rst_n;
reg rdy;
reg irq_n;
reg nmi_n;
reg so_n;

//=========================================================================
// Test Statistics:
//=========================================================================
integer     total_tests;
integer     passed_tests;
integer     failed_tests;
integer     i;
integer     j;
integer     k;
integer     n;
integer     t;
integer     guard;
integer     seed;
integer     errs;
integer     errs2;
integer     cyc;
integer     base;
reg   [7:0] tmp8;
reg   [7:0] tmp8b;
reg  [15:0] tmp16;
reg  [31:0] tmp32;
reg [8*160-1:0] nm;

//=========================================================================
// Enable Generator:
// tb_ratio clk per bus cycle: cen on phase 0 (falling clk0 edge, start of a
// cycle), cen_p2 on phase tb_ratio / 2 (rising clk0 edge), each one clk
// wide and driven 1 ns after the clk edge; ratio 1 has no cen_p2. en_run = 0
// stops both enables; en_stall inserts random stops of 1-16 clk between
// enables.
//=========================================================================
integer     tb_ratio;
reg         en_run;
reg         en_stall;
integer     en_ph;
integer     en_hold;
integer     en_seed;
reg  [31:0] cen_cnt;

always @(posedge clk) begin
    if(!en_run) begin
        cen <= #1 1'b0;
        cen_p2 <= #1 1'b0;
    end else if(en_hold > 0) begin
        cen <= #1 1'b0;
        cen_p2 <= #1 1'b0;
        en_hold <= en_hold - 1;
    end else begin
        cen <= #1 (en_ph == 0);
        cen_p2 <= #1 (tb_ratio > 1) && (en_ph == (tb_ratio / 2));
        if(en_ph + 1 >= tb_ratio)
            en_ph <= 0;
        else
            en_ph <= en_ph + 1;
        if(en_stall && (($random(en_seed) & 7) == 0))
            en_hold <= 1 + ($random(en_seed) & 15);
    end
    if(cen)
        cen_cnt <= cen_cnt + 1;
end

initial clk = 1'b0;
always #5 clk = ~clk;

//=========================================================================
// DUT Signals:
// _u = uut (HALF_CYCLE = 0), _h = uuth (HALF_CYCLE = 1).
//=========================================================================
wire [15:0] addr_u;
wire  [7:0] din_u;
wire  [7:0] dout_u;
wire        rw_u;
wire        sync_u;
wire        vp_u;
wire        oe_u;
wire [15:0] dpc_u;
wire  [7:0] da_u;
wire  [7:0] dx_u;
wire  [7:0] dy_u;
wire  [7:0] ds_u;
wire  [7:0] dp_u;
wire  [7:0] dir_u;

wire [15:0] addr_h;
wire  [7:0] din_h;
wire  [7:0] dout_h;
wire        rw_h;
wire        sync_h;
wire        vp_h;
wire        oe_h;
wire [15:0] dpc_h;
wire  [7:0] da_h;
wire  [7:0] dx_h;
wire  [7:0] dy_h;
wire  [7:0] ds_h;
wire  [7:0] dp_h;
wire  [7:0] dir_h;

//=========================================================================
// DUT Instantiation:
// uut is the consumer contract: CYCLE mode with cen_p2 left unconnected.
// uuth runs the same stimulus in HALF mode.
//=========================================================================
x65c02 #(
    .HALF_CYCLE ( 0 )
) uut (
    .clk     ( clk    ),
    .cen     ( cen    ),
    .rst_n   ( rst_n  ),
    .rdy     ( rdy    ),
    .irq_n   ( irq_n  ),
    .nmi_n   ( nmi_n  ),
    .so_n    ( so_n   ),
    .addr    ( addr_u ),
    .din     ( din_u  ),
    .dout    ( dout_u ),
    .rw_n    ( rw_u   ),
    .sync    ( sync_u ),
    .vp_n    ( vp_u   ),
    .cen_p2  (        ),
    .dout_oe ( oe_u   ),
    .dbg_pc  ( dpc_u  ),
    .dbg_a   ( da_u   ),
    .dbg_x   ( dx_u   ),
    .dbg_y   ( dy_u   ),
    .dbg_s   ( ds_u   ),
    .dbg_p   ( dp_u   ),
    .dbg_ir  ( dir_u  )
);

x65c02 #(
    .HALF_CYCLE ( 1 )
) uuth (
    .clk     ( clk    ),
    .cen     ( cen    ),
    .rst_n   ( rst_n  ),
    .rdy     ( rdy    ),
    .irq_n   ( irq_n  ),
    .nmi_n   ( nmi_n  ),
    .so_n    ( so_n   ),
    .addr    ( addr_h ),
    .din     ( din_h  ),
    .dout    ( dout_h ),
    .rw_n    ( rw_h   ),
    .sync    ( sync_h ),
    .vp_n    ( vp_h   ),
    .cen_p2  ( cen_p2 ),
    .dout_oe ( oe_h   ),
    .dbg_pc  ( dpc_h  ),
    .dbg_a   ( da_h   ),
    .dbg_x   ( dx_h   ),
    .dbg_y   ( dy_h   ),
    .dbg_s   ( ds_h   ),
    .dbg_p   ( dp_h   ),
    .dbg_ir  ( dir_h  )
);

//=========================================================================
// Standalone ALU Instance:
// Combinational; driven directly by Section D.
//=========================================================================
reg  [7:0] alu_a;
reg  [7:0] alu_b;
reg  [4:0] alu_op;
reg  [7:0] alu_pin;
wire [7:0] alu_q;
wire [7:0] alu_pout;

x65c02_alu alu_uut (
    .a     ( alu_a    ),
    .b     ( alu_b    ),
    .op    ( alu_op   ),
    .p_in  ( alu_pin  ),
    .q     ( alu_q    ),
    .p_out ( alu_pout )
);

//-------------------------------------------------------------------------
// ALU Operation Codes:
// The codes of the x65c02_alu op input that Section D drives.
//-------------------------------------------------------------------------
localparam [4:0]
    ALU_OR  = 5'h00,
    ALU_AND = 5'h01,
    ALU_EOR = 5'h02,
    ALU_ADC = 5'h03,
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

//=========================================================================
// Memory Model:
// One 64 KB memory per CPU. A byte belongs to the current image when its
// tag equals img; any other address reads fill. While boot = 1 the reads of
// FFFC/FFFD return boot_vec. A write cycle commits at the cen that ends it.
// cap_* capture the observation stores to FFF0-FFF3 and the first stack
// write after cap_arm.
//=========================================================================
reg   [7:0] mem_u [0:65535];
reg   [7:0] mem_h [0:65535];
reg  [31:0] tag_u [0:65535];
reg  [31:0] tag_h [0:65535];
reg  [31:0] img;
reg   [7:0] fill;
reg         boot;
reg  [15:0] boot_vec;

function [7:0] rd_u;
    input [15:0] a;
    begin
        if(^a === 1'bx)
            rd_u = fill;
        else if(boot && (a == 16'hFFFC))
            rd_u = boot_vec[7:0];
        else if(boot && (a == 16'hFFFD))
            rd_u = boot_vec[15:8];
        else if(tag_u[a] == img)
            rd_u = mem_u[a];
        else
            rd_u = fill;
    end
endfunction

function [7:0] rd_h;
    input [15:0] a;
    begin
        if(^a === 1'bx)
            rd_h = fill;
        else if(boot && (a == 16'hFFFC))
            rd_h = boot_vec[7:0];
        else if(boot && (a == 16'hFFFD))
            rd_h = boot_vec[15:8];
        else if(tag_h[a] == img)
            rd_h = mem_h[a];
        else
            rd_h = fill;
    end
endfunction

// mem_gen counts every memory change so that din follows it
reg   [7:0] din_u_r;
reg   [7:0] din_h_r;
reg  [31:0] mem_gen;
always @(addr_u or mem_gen or img or fill or boot or boot_vec) din_u_r = rd_u(addr_u);
always @(addr_h or mem_gen or img or fill or boot or boot_vec) din_h_r = rd_h(addr_h);
assign din_u = din_u_r;
assign din_h = din_h_r;

reg         cap_arm;
reg   [7:0] cap_p_u;
reg   [7:0] cap_p_h;
reg   [3:0] cap_got_u;
reg   [3:0] cap_got_h;
reg         cap_pgot_u;
reg         cap_pgot_h;
reg  [31:0] cap_reg_u;
reg  [31:0] cap_reg_h;
integer     wr_cnt_u;
integer     wr_cnt_h;

always @(posedge clk) begin
    if(cen && (rw_u === 1'b0) && (^addr_u !== 1'bx)) begin
        mem_u[addr_u] <= dout_u;
        tag_u[addr_u] <= img;
        wr_cnt_u <= wr_cnt_u + 1;
        if(cap_arm && (addr_u[15:8] == 8'h01) && !cap_pgot_u) begin
            cap_p_u <= dout_u;
            cap_pgot_u <= 1'b1;
        end
        if(cap_arm && (addr_u[15:2] == 14'h3FFC)) begin
            cap_reg_u[8 * (3 - addr_u[1:0]) +: 8] <= dout_u;
            cap_got_u[addr_u[1:0]] <= 1'b1;
        end
    end
    if(cen && (rw_h === 1'b0) && (^addr_h !== 1'bx)) begin
        mem_h[addr_h] <= dout_h;
        tag_h[addr_h] <= img;
        wr_cnt_h <= wr_cnt_h + 1;
        if(cap_arm && (addr_h[15:8] == 8'h01) && !cap_pgot_h) begin
            cap_p_h <= dout_h;
            cap_pgot_h <= 1'b1;
        end
        if(cap_arm && (addr_h[15:2] == 14'h3FFC)) begin
            cap_reg_h[8 * (3 - addr_h[1:0]) +: 8] <= dout_h;
            cap_got_h[addr_h[1:0]] <= 1'b1;
        end
    end
    if(cen && ((rw_u === 1'b0) || (rw_h === 1'b0)))
        mem_gen <= mem_gen + 1;
end

//=========================================================================
// Bus Recorder:
// At each cen the cycle that ends there is stored at tr_n (circular,
// TRN entries): the pins as they were during the cycle (sampled before the
// edge updates them), the byte on the data bus (din on reads, dout on
// writes) and the debug outputs. At cen_p2 the phi1 half of the cycle is
// sampled; ratio 1 has no phi1 sample (p1 valid = 0).
//   trb  [15:0] addr  [23:16] data  [24] rw_n  [25] sync  [26] dout_oe
//        [27] vp_n  [28] phi1 valid  [29] phi1 dout_oe  [30] addr, rw_n
//        and sync unchanged from phi1  [31] 0  [39:32] phi1 dout
//        [40] an output was X
//   trd  {dbg_pc, dbg_a, dbg_x, dbg_y, dbg_s, dbg_p, dbg_ir}
//=========================================================================
localparam TRN = 8192;
reg  [40:0] trb_u [0:TRN-1];
reg  [40:0] trb_h [0:TRN-1];
reg  [63:0] trd_u [0:TRN-1];
reg  [63:0] trd_h [0:TRN-1];
reg  [31:0] tr_n;

reg         p1v;
reg  [15:0] p1a_u;
reg  [15:0] p1a_h;
reg         p1rw_u;
reg         p1rw_h;
reg         p1sy_u;
reg         p1sy_h;
reg         p1oe_u;
reg         p1oe_h;
reg   [7:0] p1d_u;
reg   [7:0] p1d_h;

wire [63:0] dbg_u  = {dpc_u, da_u, dx_u, dy_u, ds_u, dp_u, dir_u};
wire [63:0] dbg_h  = {dpc_h, da_h, dx_h, dy_h, ds_h, dp_h, dir_h};
wire [94:0] outs_u = {addr_u, dout_u, rw_u, sync_u, vp_u, oe_u, 1'b0, dbg_u};
wire [94:0] outs_h = {addr_h, dout_h, rw_h, sync_h, vp_h, oe_h, 1'b0, dbg_h};

always @(posedge clk) begin
    if(cen_p2) begin
        p1v <= 1'b1;
        p1a_u <= addr_u;
        p1a_h <= addr_h;
        p1rw_u <= rw_u;
        p1rw_h <= rw_h;
        p1sy_u <= sync_u;
        p1sy_h <= sync_h;
        p1oe_u <= oe_u;
        p1oe_h <= oe_h;
        p1d_u <= dout_u;
        p1d_h <= dout_h;
    end
    if(cen) begin
        trb_u[tr_n[12:0]] <= {^outs_u === 1'bx, p1d_u, 1'b0,
                              p1v && (p1a_u === addr_u) && (p1rw_u === rw_u) && (p1sy_u === sync_u),
                              p1oe_u, p1v, vp_u, oe_u, sync_u, rw_u, (rw_u === 1'b0) ? dout_u : din_u, addr_u};
        trb_h[tr_n[12:0]] <= {^outs_h === 1'bx, p1d_h, 1'b0,
                              p1v && (p1a_h === addr_h) && (p1rw_h === rw_h) && (p1sy_h === sync_h),
                              p1oe_h, p1v, vp_h, oe_h, sync_h, rw_h, (rw_h === 1'b0) ? dout_h : din_h, addr_h};
        trd_u[tr_n[12:0]] <= dbg_u;
        trd_h[tr_n[12:0]] <= dbg_h;
        p1v <= 1'b0;
        tr_n <= tr_n + 1;
    end
end

//=========================================================================
// Output Monitors:
// Outputs may change only at an enable edge: uut at cen, uuth at cen and
// cen_p2. Counted from the first enable on; an X on any output is counted
// from time 0.
//=========================================================================
reg  [94:0] mon_prev_u;
reg  [94:0] mon_prev_h;
reg         mon_q_u;
reg         mon_q_h;
reg         mon_on;
integer     mon_viol_u;
integer     mon_viol_h;
integer     mon_x_u;
integer     mon_x_h;

always @(posedge clk) begin
    if(mon_on && mon_q_u && (outs_u !== mon_prev_u))
        mon_viol_u <= mon_viol_u + 1;
    if(mon_on && mon_q_h && (outs_h !== mon_prev_h))
        mon_viol_h <= mon_viol_h + 1;
    if(^outs_u === 1'bx)
        mon_x_u <= mon_x_u + 1;
    if(^outs_h === 1'bx)
        mon_x_h <= mon_x_h + 1;
    mon_prev_u <= outs_u;
    mon_prev_h <= outs_h;
    mon_q_u <= !cen;
    mon_q_h <= !(cen || cen_p2);
end

//=========================================================================
// Opcode Table:
// Mnemonic and addressing mode of every opcode (nop? = undefined) and
// its group in Section B.
//=========================================================================
reg [8*14-1:0] op_name [0:255];
reg  [3:0] op_grp [0:255];
reg [8*40-1:0] grp_name [0:15];

initial begin
    op_name[8'h00] = "BRK impl";
    op_grp[8'h00] = 4'd12;
    op_name[8'h01] = "ORA (zp,X)";
    op_grp[8'h01] = 4'd7;
    op_name[8'h02] = "nop? 02";
    op_grp[8'h02] = 4'd15;
    op_name[8'h03] = "nop? 03";
    op_grp[8'h03] = 4'd15;
    op_name[8'h04] = "TSB zp";
    op_grp[8'h04] = 4'd3;
    op_name[8'h05] = "ORA zp";
    op_grp[8'h05] = 4'd3;
    op_name[8'h06] = "ASL zp";
    op_grp[8'h06] = 4'd3;
    op_name[8'h07] = "RMB0 zp";
    op_grp[8'h07] = 4'd14;
    op_name[8'h08] = "PHP impl";
    op_grp[8'h08] = 4'd11;
    op_name[8'h09] = "ORA #";
    op_grp[8'h09] = 4'd2;
    op_name[8'h0A] = "ASL A";
    op_grp[8'h0A] = 4'd1;
    op_name[8'h0B] = "nop? 0B";
    op_grp[8'h0B] = 4'd15;
    op_name[8'h0C] = "TSB abs";
    op_grp[8'h0C] = 4'd5;
    op_name[8'h0D] = "ORA abs";
    op_grp[8'h0D] = 4'd5;
    op_name[8'h0E] = "ASL abs";
    op_grp[8'h0E] = 4'd5;
    op_name[8'h0F] = "BBR0 zp,rel";
    op_grp[8'h0F] = 4'd14;
    op_name[8'h10] = "BPL rel";
    op_grp[8'h10] = 4'd10;
    op_name[8'h11] = "ORA (zp),Y";
    op_grp[8'h11] = 4'd8;
    op_name[8'h12] = "ORA (zp)";
    op_grp[8'h12] = 4'd9;
    op_name[8'h13] = "nop? 13";
    op_grp[8'h13] = 4'd15;
    op_name[8'h14] = "TRB zp";
    op_grp[8'h14] = 4'd3;
    op_name[8'h15] = "ORA zp,X";
    op_grp[8'h15] = 4'd4;
    op_name[8'h16] = "ASL zp,X";
    op_grp[8'h16] = 4'd4;
    op_name[8'h17] = "RMB1 zp";
    op_grp[8'h17] = 4'd14;
    op_name[8'h18] = "CLC impl";
    op_grp[8'h18] = 4'd1;
    op_name[8'h19] = "ORA abs,Y";
    op_grp[8'h19] = 4'd6;
    op_name[8'h1A] = "INC A";
    op_grp[8'h1A] = 4'd1;
    op_name[8'h1B] = "nop? 1B";
    op_grp[8'h1B] = 4'd15;
    op_name[8'h1C] = "TRB abs";
    op_grp[8'h1C] = 4'd5;
    op_name[8'h1D] = "ORA abs,X";
    op_grp[8'h1D] = 4'd6;
    op_name[8'h1E] = "ASL abs,X";
    op_grp[8'h1E] = 4'd6;
    op_name[8'h1F] = "BBR1 zp,rel";
    op_grp[8'h1F] = 4'd14;
    op_name[8'h20] = "JSR abs";
    op_grp[8'h20] = 4'd12;
    op_name[8'h21] = "AND (zp,X)";
    op_grp[8'h21] = 4'd7;
    op_name[8'h22] = "nop? 22";
    op_grp[8'h22] = 4'd15;
    op_name[8'h23] = "nop? 23";
    op_grp[8'h23] = 4'd15;
    op_name[8'h24] = "BIT zp";
    op_grp[8'h24] = 4'd3;
    op_name[8'h25] = "AND zp";
    op_grp[8'h25] = 4'd3;
    op_name[8'h26] = "ROL zp";
    op_grp[8'h26] = 4'd3;
    op_name[8'h27] = "RMB2 zp";
    op_grp[8'h27] = 4'd14;
    op_name[8'h28] = "PLP impl";
    op_grp[8'h28] = 4'd11;
    op_name[8'h29] = "AND #";
    op_grp[8'h29] = 4'd2;
    op_name[8'h2A] = "ROL A";
    op_grp[8'h2A] = 4'd1;
    op_name[8'h2B] = "nop? 2B";
    op_grp[8'h2B] = 4'd15;
    op_name[8'h2C] = "BIT abs";
    op_grp[8'h2C] = 4'd5;
    op_name[8'h2D] = "AND abs";
    op_grp[8'h2D] = 4'd5;
    op_name[8'h2E] = "ROL abs";
    op_grp[8'h2E] = 4'd5;
    op_name[8'h2F] = "BBR2 zp,rel";
    op_grp[8'h2F] = 4'd14;
    op_name[8'h30] = "BMI rel";
    op_grp[8'h30] = 4'd10;
    op_name[8'h31] = "AND (zp),Y";
    op_grp[8'h31] = 4'd8;
    op_name[8'h32] = "AND (zp)";
    op_grp[8'h32] = 4'd9;
    op_name[8'h33] = "nop? 33";
    op_grp[8'h33] = 4'd15;
    op_name[8'h34] = "BIT zp,X";
    op_grp[8'h34] = 4'd4;
    op_name[8'h35] = "AND zp,X";
    op_grp[8'h35] = 4'd4;
    op_name[8'h36] = "ROL zp,X";
    op_grp[8'h36] = 4'd4;
    op_name[8'h37] = "RMB3 zp";
    op_grp[8'h37] = 4'd14;
    op_name[8'h38] = "SEC impl";
    op_grp[8'h38] = 4'd1;
    op_name[8'h39] = "AND abs,Y";
    op_grp[8'h39] = 4'd6;
    op_name[8'h3A] = "DEC A";
    op_grp[8'h3A] = 4'd1;
    op_name[8'h3B] = "nop? 3B";
    op_grp[8'h3B] = 4'd15;
    op_name[8'h3C] = "BIT abs,X";
    op_grp[8'h3C] = 4'd6;
    op_name[8'h3D] = "AND abs,X";
    op_grp[8'h3D] = 4'd6;
    op_name[8'h3E] = "ROL abs,X";
    op_grp[8'h3E] = 4'd6;
    op_name[8'h3F] = "BBR3 zp,rel";
    op_grp[8'h3F] = 4'd14;
    op_name[8'h40] = "RTI impl";
    op_grp[8'h40] = 4'd12;
    op_name[8'h41] = "EOR (zp,X)";
    op_grp[8'h41] = 4'd7;
    op_name[8'h42] = "nop? 42";
    op_grp[8'h42] = 4'd15;
    op_name[8'h43] = "nop? 43";
    op_grp[8'h43] = 4'd15;
    op_name[8'h44] = "nop? 44";
    op_grp[8'h44] = 4'd15;
    op_name[8'h45] = "EOR zp";
    op_grp[8'h45] = 4'd3;
    op_name[8'h46] = "LSR zp";
    op_grp[8'h46] = 4'd3;
    op_name[8'h47] = "RMB4 zp";
    op_grp[8'h47] = 4'd14;
    op_name[8'h48] = "PHA impl";
    op_grp[8'h48] = 4'd11;
    op_name[8'h49] = "EOR #";
    op_grp[8'h49] = 4'd2;
    op_name[8'h4A] = "LSR A";
    op_grp[8'h4A] = 4'd1;
    op_name[8'h4B] = "nop? 4B";
    op_grp[8'h4B] = 4'd15;
    op_name[8'h4C] = "JMP abs";
    op_grp[8'h4C] = 4'd13;
    op_name[8'h4D] = "EOR abs";
    op_grp[8'h4D] = 4'd5;
    op_name[8'h4E] = "LSR abs";
    op_grp[8'h4E] = 4'd5;
    op_name[8'h4F] = "BBR4 zp,rel";
    op_grp[8'h4F] = 4'd14;
    op_name[8'h50] = "BVC rel";
    op_grp[8'h50] = 4'd10;
    op_name[8'h51] = "EOR (zp),Y";
    op_grp[8'h51] = 4'd8;
    op_name[8'h52] = "EOR (zp)";
    op_grp[8'h52] = 4'd9;
    op_name[8'h53] = "nop? 53";
    op_grp[8'h53] = 4'd15;
    op_name[8'h54] = "nop? 54";
    op_grp[8'h54] = 4'd15;
    op_name[8'h55] = "EOR zp,X";
    op_grp[8'h55] = 4'd4;
    op_name[8'h56] = "LSR zp,X";
    op_grp[8'h56] = 4'd4;
    op_name[8'h57] = "RMB5 zp";
    op_grp[8'h57] = 4'd14;
    op_name[8'h58] = "CLI impl";
    op_grp[8'h58] = 4'd1;
    op_name[8'h59] = "EOR abs,Y";
    op_grp[8'h59] = 4'd6;
    op_name[8'h5A] = "PHY impl";
    op_grp[8'h5A] = 4'd11;
    op_name[8'h5B] = "nop? 5B";
    op_grp[8'h5B] = 4'd15;
    op_name[8'h5C] = "nop? 5C";
    op_grp[8'h5C] = 4'd15;
    op_name[8'h5D] = "EOR abs,X";
    op_grp[8'h5D] = 4'd6;
    op_name[8'h5E] = "LSR abs,X";
    op_grp[8'h5E] = 4'd6;
    op_name[8'h5F] = "BBR5 zp,rel";
    op_grp[8'h5F] = 4'd14;
    op_name[8'h60] = "RTS impl";
    op_grp[8'h60] = 4'd12;
    op_name[8'h61] = "ADC (zp,X)";
    op_grp[8'h61] = 4'd7;
    op_name[8'h62] = "nop? 62";
    op_grp[8'h62] = 4'd15;
    op_name[8'h63] = "nop? 63";
    op_grp[8'h63] = 4'd15;
    op_name[8'h64] = "STZ zp";
    op_grp[8'h64] = 4'd3;
    op_name[8'h65] = "ADC zp";
    op_grp[8'h65] = 4'd3;
    op_name[8'h66] = "ROR zp";
    op_grp[8'h66] = 4'd3;
    op_name[8'h67] = "RMB6 zp";
    op_grp[8'h67] = 4'd14;
    op_name[8'h68] = "PLA impl";
    op_grp[8'h68] = 4'd11;
    op_name[8'h69] = "ADC #";
    op_grp[8'h69] = 4'd2;
    op_name[8'h6A] = "ROR A";
    op_grp[8'h6A] = 4'd1;
    op_name[8'h6B] = "nop? 6B";
    op_grp[8'h6B] = 4'd15;
    op_name[8'h6C] = "JMP (abs)";
    op_grp[8'h6C] = 4'd13;
    op_name[8'h6D] = "ADC abs";
    op_grp[8'h6D] = 4'd5;
    op_name[8'h6E] = "ROR abs";
    op_grp[8'h6E] = 4'd5;
    op_name[8'h6F] = "BBR6 zp,rel";
    op_grp[8'h6F] = 4'd14;
    op_name[8'h70] = "BVS rel";
    op_grp[8'h70] = 4'd10;
    op_name[8'h71] = "ADC (zp),Y";
    op_grp[8'h71] = 4'd8;
    op_name[8'h72] = "ADC (zp)";
    op_grp[8'h72] = 4'd9;
    op_name[8'h73] = "nop? 73";
    op_grp[8'h73] = 4'd15;
    op_name[8'h74] = "STZ zp,X";
    op_grp[8'h74] = 4'd4;
    op_name[8'h75] = "ADC zp,X";
    op_grp[8'h75] = 4'd4;
    op_name[8'h76] = "ROR zp,X";
    op_grp[8'h76] = 4'd4;
    op_name[8'h77] = "RMB7 zp";
    op_grp[8'h77] = 4'd14;
    op_name[8'h78] = "SEI impl";
    op_grp[8'h78] = 4'd1;
    op_name[8'h79] = "ADC abs,Y";
    op_grp[8'h79] = 4'd6;
    op_name[8'h7A] = "PLY impl";
    op_grp[8'h7A] = 4'd11;
    op_name[8'h7B] = "nop? 7B";
    op_grp[8'h7B] = 4'd15;
    op_name[8'h7C] = "JMP (abs,X)";
    op_grp[8'h7C] = 4'd13;
    op_name[8'h7D] = "ADC abs,X";
    op_grp[8'h7D] = 4'd6;
    op_name[8'h7E] = "ROR abs,X";
    op_grp[8'h7E] = 4'd6;
    op_name[8'h7F] = "BBR7 zp,rel";
    op_grp[8'h7F] = 4'd14;
    op_name[8'h80] = "BRA rel";
    op_grp[8'h80] = 4'd10;
    op_name[8'h81] = "STA (zp,X)";
    op_grp[8'h81] = 4'd7;
    op_name[8'h82] = "nop? 82";
    op_grp[8'h82] = 4'd15;
    op_name[8'h83] = "nop? 83";
    op_grp[8'h83] = 4'd15;
    op_name[8'h84] = "STY zp";
    op_grp[8'h84] = 4'd3;
    op_name[8'h85] = "STA zp";
    op_grp[8'h85] = 4'd3;
    op_name[8'h86] = "STX zp";
    op_grp[8'h86] = 4'd3;
    op_name[8'h87] = "SMB0 zp";
    op_grp[8'h87] = 4'd14;
    op_name[8'h88] = "DEY impl";
    op_grp[8'h88] = 4'd1;
    op_name[8'h89] = "BIT #";
    op_grp[8'h89] = 4'd2;
    op_name[8'h8A] = "TXA impl";
    op_grp[8'h8A] = 4'd1;
    op_name[8'h8B] = "nop? 8B";
    op_grp[8'h8B] = 4'd15;
    op_name[8'h8C] = "STY abs";
    op_grp[8'h8C] = 4'd5;
    op_name[8'h8D] = "STA abs";
    op_grp[8'h8D] = 4'd5;
    op_name[8'h8E] = "STX abs";
    op_grp[8'h8E] = 4'd5;
    op_name[8'h8F] = "BBS0 zp,rel";
    op_grp[8'h8F] = 4'd14;
    op_name[8'h90] = "BCC rel";
    op_grp[8'h90] = 4'd10;
    op_name[8'h91] = "STA (zp),Y";
    op_grp[8'h91] = 4'd8;
    op_name[8'h92] = "STA (zp)";
    op_grp[8'h92] = 4'd9;
    op_name[8'h93] = "nop? 93";
    op_grp[8'h93] = 4'd15;
    op_name[8'h94] = "STY zp,X";
    op_grp[8'h94] = 4'd4;
    op_name[8'h95] = "STA zp,X";
    op_grp[8'h95] = 4'd4;
    op_name[8'h96] = "STX zp,Y";
    op_grp[8'h96] = 4'd4;
    op_name[8'h97] = "SMB1 zp";
    op_grp[8'h97] = 4'd14;
    op_name[8'h98] = "TYA impl";
    op_grp[8'h98] = 4'd1;
    op_name[8'h99] = "STA abs,Y";
    op_grp[8'h99] = 4'd6;
    op_name[8'h9A] = "TXS impl";
    op_grp[8'h9A] = 4'd1;
    op_name[8'h9B] = "nop? 9B";
    op_grp[8'h9B] = 4'd15;
    op_name[8'h9C] = "STZ abs";
    op_grp[8'h9C] = 4'd5;
    op_name[8'h9D] = "STA abs,X";
    op_grp[8'h9D] = 4'd6;
    op_name[8'h9E] = "STZ abs,X";
    op_grp[8'h9E] = 4'd6;
    op_name[8'h9F] = "BBS1 zp,rel";
    op_grp[8'h9F] = 4'd14;
    op_name[8'hA0] = "LDY #";
    op_grp[8'hA0] = 4'd2;
    op_name[8'hA1] = "LDA (zp,X)";
    op_grp[8'hA1] = 4'd7;
    op_name[8'hA2] = "LDX #";
    op_grp[8'hA2] = 4'd2;
    op_name[8'hA3] = "nop? A3";
    op_grp[8'hA3] = 4'd15;
    op_name[8'hA4] = "LDY zp";
    op_grp[8'hA4] = 4'd3;
    op_name[8'hA5] = "LDA zp";
    op_grp[8'hA5] = 4'd3;
    op_name[8'hA6] = "LDX zp";
    op_grp[8'hA6] = 4'd3;
    op_name[8'hA7] = "SMB2 zp";
    op_grp[8'hA7] = 4'd14;
    op_name[8'hA8] = "TAY impl";
    op_grp[8'hA8] = 4'd1;
    op_name[8'hA9] = "LDA #";
    op_grp[8'hA9] = 4'd2;
    op_name[8'hAA] = "TAX impl";
    op_grp[8'hAA] = 4'd1;
    op_name[8'hAB] = "nop? AB";
    op_grp[8'hAB] = 4'd15;
    op_name[8'hAC] = "LDY abs";
    op_grp[8'hAC] = 4'd5;
    op_name[8'hAD] = "LDA abs";
    op_grp[8'hAD] = 4'd5;
    op_name[8'hAE] = "LDX abs";
    op_grp[8'hAE] = 4'd5;
    op_name[8'hAF] = "BBS2 zp,rel";
    op_grp[8'hAF] = 4'd14;
    op_name[8'hB0] = "BCS rel";
    op_grp[8'hB0] = 4'd10;
    op_name[8'hB1] = "LDA (zp),Y";
    op_grp[8'hB1] = 4'd8;
    op_name[8'hB2] = "LDA (zp)";
    op_grp[8'hB2] = 4'd9;
    op_name[8'hB3] = "nop? B3";
    op_grp[8'hB3] = 4'd15;
    op_name[8'hB4] = "LDY zp,X";
    op_grp[8'hB4] = 4'd4;
    op_name[8'hB5] = "LDA zp,X";
    op_grp[8'hB5] = 4'd4;
    op_name[8'hB6] = "LDX zp,Y";
    op_grp[8'hB6] = 4'd4;
    op_name[8'hB7] = "SMB3 zp";
    op_grp[8'hB7] = 4'd14;
    op_name[8'hB8] = "CLV impl";
    op_grp[8'hB8] = 4'd1;
    op_name[8'hB9] = "LDA abs,Y";
    op_grp[8'hB9] = 4'd6;
    op_name[8'hBA] = "TSX impl";
    op_grp[8'hBA] = 4'd1;
    op_name[8'hBB] = "nop? BB";
    op_grp[8'hBB] = 4'd15;
    op_name[8'hBC] = "LDY abs,X";
    op_grp[8'hBC] = 4'd6;
    op_name[8'hBD] = "LDA abs,X";
    op_grp[8'hBD] = 4'd6;
    op_name[8'hBE] = "LDX abs,Y";
    op_grp[8'hBE] = 4'd6;
    op_name[8'hBF] = "BBS3 zp,rel";
    op_grp[8'hBF] = 4'd14;
    op_name[8'hC0] = "CPY #";
    op_grp[8'hC0] = 4'd2;
    op_name[8'hC1] = "CMP (zp,X)";
    op_grp[8'hC1] = 4'd7;
    op_name[8'hC2] = "nop? C2";
    op_grp[8'hC2] = 4'd15;
    op_name[8'hC3] = "nop? C3";
    op_grp[8'hC3] = 4'd15;
    op_name[8'hC4] = "CPY zp";
    op_grp[8'hC4] = 4'd3;
    op_name[8'hC5] = "CMP zp";
    op_grp[8'hC5] = 4'd3;
    op_name[8'hC6] = "DEC zp";
    op_grp[8'hC6] = 4'd3;
    op_name[8'hC7] = "SMB4 zp";
    op_grp[8'hC7] = 4'd14;
    op_name[8'hC8] = "INY impl";
    op_grp[8'hC8] = 4'd1;
    op_name[8'hC9] = "CMP #";
    op_grp[8'hC9] = 4'd2;
    op_name[8'hCA] = "DEX impl";
    op_grp[8'hCA] = 4'd1;
    op_name[8'hCB] = "nop? CB";
    op_grp[8'hCB] = 4'd15;
    op_name[8'hCC] = "CPY abs";
    op_grp[8'hCC] = 4'd5;
    op_name[8'hCD] = "CMP abs";
    op_grp[8'hCD] = 4'd5;
    op_name[8'hCE] = "DEC abs";
    op_grp[8'hCE] = 4'd5;
    op_name[8'hCF] = "BBS4 zp,rel";
    op_grp[8'hCF] = 4'd14;
    op_name[8'hD0] = "BNE rel";
    op_grp[8'hD0] = 4'd10;
    op_name[8'hD1] = "CMP (zp),Y";
    op_grp[8'hD1] = 4'd8;
    op_name[8'hD2] = "CMP (zp)";
    op_grp[8'hD2] = 4'd9;
    op_name[8'hD3] = "nop? D3";
    op_grp[8'hD3] = 4'd15;
    op_name[8'hD4] = "nop? D4";
    op_grp[8'hD4] = 4'd15;
    op_name[8'hD5] = "CMP zp,X";
    op_grp[8'hD5] = 4'd4;
    op_name[8'hD6] = "DEC zp,X";
    op_grp[8'hD6] = 4'd4;
    op_name[8'hD7] = "SMB5 zp";
    op_grp[8'hD7] = 4'd14;
    op_name[8'hD8] = "CLD impl";
    op_grp[8'hD8] = 4'd1;
    op_name[8'hD9] = "CMP abs,Y";
    op_grp[8'hD9] = 4'd6;
    op_name[8'hDA] = "PHX impl";
    op_grp[8'hDA] = 4'd11;
    op_name[8'hDB] = "nop? DB";
    op_grp[8'hDB] = 4'd15;
    op_name[8'hDC] = "nop? DC";
    op_grp[8'hDC] = 4'd15;
    op_name[8'hDD] = "CMP abs,X";
    op_grp[8'hDD] = 4'd6;
    op_name[8'hDE] = "DEC abs,X";
    op_grp[8'hDE] = 4'd6;
    op_name[8'hDF] = "BBS5 zp,rel";
    op_grp[8'hDF] = 4'd14;
    op_name[8'hE0] = "CPX #";
    op_grp[8'hE0] = 4'd2;
    op_name[8'hE1] = "SBC (zp,X)";
    op_grp[8'hE1] = 4'd7;
    op_name[8'hE2] = "nop? E2";
    op_grp[8'hE2] = 4'd15;
    op_name[8'hE3] = "nop? E3";
    op_grp[8'hE3] = 4'd15;
    op_name[8'hE4] = "CPX zp";
    op_grp[8'hE4] = 4'd3;
    op_name[8'hE5] = "SBC zp";
    op_grp[8'hE5] = 4'd3;
    op_name[8'hE6] = "INC zp";
    op_grp[8'hE6] = 4'd3;
    op_name[8'hE7] = "SMB6 zp";
    op_grp[8'hE7] = 4'd14;
    op_name[8'hE8] = "INX impl";
    op_grp[8'hE8] = 4'd1;
    op_name[8'hE9] = "SBC #";
    op_grp[8'hE9] = 4'd2;
    op_name[8'hEA] = "NOP impl";
    op_grp[8'hEA] = 4'd1;
    op_name[8'hEB] = "nop? EB";
    op_grp[8'hEB] = 4'd15;
    op_name[8'hEC] = "CPX abs";
    op_grp[8'hEC] = 4'd5;
    op_name[8'hED] = "SBC abs";
    op_grp[8'hED] = 4'd5;
    op_name[8'hEE] = "INC abs";
    op_grp[8'hEE] = 4'd5;
    op_name[8'hEF] = "BBS6 zp,rel";
    op_grp[8'hEF] = 4'd14;
    op_name[8'hF0] = "BEQ rel";
    op_grp[8'hF0] = 4'd10;
    op_name[8'hF1] = "SBC (zp),Y";
    op_grp[8'hF1] = 4'd8;
    op_name[8'hF2] = "SBC (zp)";
    op_grp[8'hF2] = 4'd9;
    op_name[8'hF3] = "nop? F3";
    op_grp[8'hF3] = 4'd15;
    op_name[8'hF4] = "nop? F4";
    op_grp[8'hF4] = 4'd15;
    op_name[8'hF5] = "SBC zp,X";
    op_grp[8'hF5] = 4'd4;
    op_name[8'hF6] = "INC zp,X";
    op_grp[8'hF6] = 4'd4;
    op_name[8'hF7] = "SMB7 zp";
    op_grp[8'hF7] = 4'd14;
    op_name[8'hF8] = "SED impl";
    op_grp[8'hF8] = 4'd1;
    op_name[8'hF9] = "SBC abs,Y";
    op_grp[8'hF9] = 4'd6;
    op_name[8'hFA] = "PLX impl";
    op_grp[8'hFA] = 4'd11;
    op_name[8'hFB] = "nop? FB";
    op_grp[8'hFB] = 4'd15;
    op_name[8'hFC] = "nop? FC";
    op_grp[8'hFC] = 4'd15;
    op_name[8'hFD] = "SBC abs,X";
    op_grp[8'hFD] = 4'd6;
    op_name[8'hFE] = "INC abs,X";
    op_grp[8'hFE] = 4'd6;
    op_name[8'hFF] = "BBS7 zp,rel";
    op_grp[8'hFF] = 4'd14;
    grp_name[1] = "implied and accumulator";
    grp_name[2] = "immediate";
    grp_name[3] = "zero page";
    grp_name[4] = "zero page indexed";
    grp_name[5] = "absolute";
    grp_name[6] = "absolute indexed";
    grp_name[7] = "(zero page,X)";
    grp_name[8] = "(zero page),Y";
    grp_name[9] = "(zero page)";
    grp_name[10] = "relative (branches, BRA)";
    grp_name[11] = "stack (PHA PHP PLA PLP PHX PHY PLX PLY)";
    grp_name[12] = "JSR RTS RTI BRK";
    grp_name[13] = "JMP abs, (abs), (abs,X)";
    grp_name[14] = "RMB SMB BBR BBS";
    grp_name[15] = "undefined NOPs";
end

//=========================================================================
// Helper Tasks:
//=========================================================================

//-------------------------------------------------------------------------
// Value Checks:
// check compares with ===; check_mm reports a mismatch count that must be
// zero.
//-------------------------------------------------------------------------
task check;
    input [31:0]      actual;
    input [31:0]      expected;
    input [8*160-1:0] name;
    begin
        total_tests = total_tests + 1;
        if(actual === expected) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s = %h", name, actual);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s - Expected: %h, Got: %h", name, expected, actual);
        end
    end
endtask

task check_mm;
    input integer     count;
    input [8*160-1:0] name;
    begin
        check(count, 0, name);
    end
endtask

task info;
    input [8*200-1:0] text;
    begin
        $display("INFO: %0s", text);
    end
endtask

task section;
    input [8*80-1:0] text;
    begin
        $display("\n=== %0s ===\n", text);
    end
endtask

//-------------------------------------------------------------------------
// Enable Stepping:
// wait_cen and wait_cenp2 return 2 ns after the next clk edge that carries
// cen / cen_p2; the outputs of the new cycle (or half) are then valid and
// the record of the cycle that ended is in the recorder. cycles waits n
// cen.
//-------------------------------------------------------------------------
task wait_cen;
    begin
        @(posedge clk);
        while(cen !== 1'b1) @(posedge clk);
        #2;
    end
endtask

task wait_cenp2;
    begin
        @(posedge clk);
        while(cen_p2 !== 1'b1) @(posedge clk);
        #2;
    end
endtask

task cycles;
    input integer cnt;
    integer r;
    begin
        for(r = 0; r < cnt; r = r + 1) wait_cen();
    end
endtask

// phi2 of the current cycle: after cen_p2 (ratio 1: at once)
task to_phi2;
    begin
        if(tb_ratio > 1) wait_cenp2();
    end
endtask

//-------------------------------------------------------------------------
// Recorder Access:
// rec_u(back) / rec_h(back) return the record of the cycle that ended
// back cycles before the last one (0 = the cycle that ended at the last
// cen).
//-------------------------------------------------------------------------
function [40:0] rec_u;
    input integer back;
    reg [31:0] ix;
    begin
        ix = tr_n - 1 - back;
        rec_u = trb_u[ix[12:0]];
    end
endfunction

function [40:0] rec_h;
    input integer back;
    reg [31:0] ix;
    begin
        ix = tr_n - 1 - back;
        rec_h = trb_h[ix[12:0]];
    end
endfunction

function [63:0] recd_u;
    input integer back;
    reg [31:0] ix;
    begin
        ix = tr_n - 1 - back;
        recd_u = trd_u[ix[12:0]];
    end
endfunction

function [63:0] recd_h;
    input integer back;
    reg [31:0] ix;
    begin
        ix = tr_n - 1 - back;
        recd_h = trd_h[ix[12:0]];
    end
endfunction

// absolute record index (tr_n at the cen that started the cycle)
function [40:0] ra_u;
    input integer ix;
    reg [31:0] q;
    begin
        q = ix;
        ra_u = trb_u[q[12:0]];
    end
endfunction

function [40:0] ra_h;
    input integer ix;
    reg [31:0] q;
    begin
        q = ix;
        ra_h = trb_h[q[12:0]];
    end
endfunction

function [63:0] rad_u;
    input integer ix;
    reg [31:0] q;
    begin
        q = ix;
        rad_u = trd_u[q[12:0]];
    end
endfunction

function [63:0] rad_h;
    input integer ix;
    reg [31:0] q;
    begin
        q = ix;
        rad_h = trd_h[q[12:0]];
    end
endfunction

// V as dbg_p showed it in record ix
function vbu;
    input integer ix;
    reg [63:0] d;
    begin
        d = rad_u(ix);
        vbu = d[14];
    end
endfunction

function vbh;
    input integer ix;
    reg [63:0] d;
    begin
        d = rad_h(ix);
        vbh = d[14];
    end
endfunction

// count of records from ix0 to ix1 whose address is a (uut)
function integer reads_of;
    input integer ix0;
    input integer ix1;
    input [15:0] a;
    integer      q;
    reg   [40:0] g;
    begin
        reads_of = 0;
        for(q = ix0; q <= ix1; q = q + 1) begin
            g = ra_u(q);
            if(g[15:0] === a)
                reads_of = reads_of + 1;
        end
    end
endfunction

// address, R/W and SYNC of record ix of both CPUs equal {a, rw, sync}
// (uuth only when tb_ratio > 1); returns 1 when equal
function bus_is;
    input integer ix;
    input [15:0] a;
    input        rw;
    input        sy;
    reg   [40:0] gu;
    reg   [40:0] gh;
    begin
        gu = ra_u(ix);
        gh = ra_h(ix);
        bus_is = (gu[15:0] === a) && (gu[24] === rw) && (gu[25] === sy) &&
                 ((tb_ratio == 1) || ((gh[15:0] === a) && (gh[24] === rw) && (gh[25] === sy)));
    end
endfunction

// the cycle in progress (2 ns after its cen) on both CPUs
function now_is;
    input [15:0] a;
    input        rw;
    input        sy;
    begin
        now_is = (addr_u === a) && (rw_u === rw) && (sync_u === sy) &&
                 ((tb_ratio == 1) || ((addr_h === a) && (rw_h === rw) && (sync_h === sy)));
    end
endfunction

// R/W and SYNC only (address not compared)
function bus_rs;
    input integer ix;
    input        rw;
    input        sy;
    reg   [40:0] gu;
    reg   [40:0] gh;
    begin
        gu = ra_u(ix);
        gh = ra_h(ix);
        bus_rs = (gu[24] === rw) && (gu[25] === sy) && ((tb_ratio == 1) || ((gh[24] === rw) && (gh[25] === sy)));
    end
endfunction

//-------------------------------------------------------------------------
// Memory Image:
// mem_new starts an empty image (every address reads the fill byte);
// put writes one byte into both memories; org / pb place a program byte by
// byte.
//-------------------------------------------------------------------------
reg  [15:0] pp;

task mem_new;
    input [7:0] f;
    begin
        img = img + 1;
        fill = f;
    end
endtask

task put;
    input [15:0] a;
    input  [7:0] d;
    begin
        mem_u[a] = d;
        mem_h[a] = d;
        tag_u[a] = img;
        tag_h[a] = img;
        mem_gen = mem_gen + 1;
    end
endtask

task org;
    input [15:0] a;
    begin
        pp = a;
    end
endtask

task pb;
    input [7:0] d;
    begin
        put(pp, d);
        pp = pp + 1;
    end
endtask

task pb2;
    input [7:0] d0;
    input [7:0] d1;
    begin
        pb(d0);
        pb(d1);
    end
endtask

task pb3;
    input [7:0] d0;
    input [7:0] d1;
    input [7:0] d2;
    begin
        pb(d0);
        pb(d1);
        pb(d2);
    end
endtask

task put16;
    input [15:0] a;
    input [15:0] w;
    begin
        put(a, w[7:0]);
        put(a + 16'd1, w[15:8]);
    end
endtask

task vectors;
    input [15:0] vnmi;
    input [15:0] vres;
    input [15:0] virq;
    begin
        put16(16'hFFFA, vnmi);
        put16(16'hFFFC, vres);
        put16(16'hFFFE, virq);
    end
endtask

// count of records from ix0 to ix1 (inclusive) with R/W = 0 on either CPU
function integer writes_in;
    input integer ix0;
    input integer ix1;
    integer    q;
    reg [40:0] gu;
    reg [40:0] gh;
    begin
        writes_in = 0;
        for(q = ix0; q <= ix1; q = q + 1) begin
            gu = ra_u(q);
            gh = ra_h(q);
            if((gu[24] !== 1'b1) || ((tb_ratio > 1) && (gh[24] !== 1'b1)))
                writes_in = writes_in + 1;
        end
    end
endfunction

// count of records from ix0 to ix1 with SYNC = 1 on uut
function integer syncs_in;
    input integer ix0;
    input integer ix1;
    integer    q;
    reg [40:0] gu;
    begin
        syncs_in = 0;
        for(q = ix0; q <= ix1; q = q + 1) begin
            gu = ra_u(q);
            if(gu[25] !== 1'b0)
                syncs_in = syncs_in + 1;
        end
    end
endfunction

//-------------------------------------------------------------------------
// Input Idle:
//-------------------------------------------------------------------------
task inputs_idle;
    begin
        rdy = 1'b1;
        irq_n = 1'b1;
        nmi_n = 1'b1;
        so_n = 1'b1;
    end
endtask

//-------------------------------------------------------------------------
// Boot:
// boot_to holds RES low for three cycles with the enables running, then
// releases it; FFFC/FFFD read the vector v until the first opcode fetch at
// v. Returns 2 ns after the cen that starts that fetch (both CPUs must be
// there; boot_ok = 0 otherwise). The image is not touched.
//-------------------------------------------------------------------------
reg     boot_ok;
integer boot_cyc;

task boot_to;
    input [15:0] v;
    integer      g;
    begin
        inputs_idle();
        wait_cen();
        rst_n = 1'b0;
        cycles(3);
        boot_vec = v;
        boot = 1'b1;
        rst_n = 1'b1;
        g = 0;
        wait_cen();
        while(!((sync_u === 1'b1) && (addr_u === v)) && (g < 40)) begin
            wait_cen();
            g = g + 1;
        end
        boot_cyc = g + 1;
        boot_ok = (g < 40) && (((sync_h === 1'b1) && (addr_h === v)) || (tb_ratio == 1));
        boot = 1'b0;
    end
endtask

//-------------------------------------------------------------------------
// Fetch Search:
// run_to_fetch stops 2 ns after the cen that starts the next opcode fetch
// of uut at address a (any address when any = 1); fetch_cyc counts the
// cycles. found = 0 after max cycles.
//-------------------------------------------------------------------------
integer fetch_cyc;
reg     found;

task run_to_fetch;
    input [15:0] a;
    input        any;
    input integer max;
    integer g;
    begin
        g = 0;
        found = 1'b0;
        wait_cen();
        g = 1;
        while(!((sync_u === 1'b1) && (any || (addr_u === a))) && (g < max)) begin
            wait_cen();
            g = g + 1;
        end
        found = (sync_u === 1'b1) && (any || (addr_u === a));
        fetch_cyc = g;
    end
endtask

//-------------------------------------------------------------------------
// Register Readout through the Bus:
// Called 2 ns after the cen that starts an opcode fetch at address a: the
// bytes PHP; STA FFF0; STX FFF1; STY FFF2; TSX; STX FFF3; JMP self are
// placed at a and run. ro_* hold what both CPUs wrote: P (as PHP pushes it,
// bits 5 and 4 = 1), A, X, Y and S (the S before PHP). ro_ok = 1 when all
// writes arrived on both CPUs (uut only at ratio 1).
//-------------------------------------------------------------------------
reg   [7:0] ro_p_u;
reg   [7:0] ro_a_u;
reg   [7:0] ro_x_u;
reg   [7:0] ro_y_u;
reg   [7:0] ro_s_u;
reg   [7:0] ro_p_h;
reg   [7:0] ro_a_h;
reg   [7:0] ro_x_h;
reg   [7:0] ro_y_h;
reg   [7:0] ro_s_h;
reg         ro_ok;
reg  [63:0] ro_dbg_u;
reg  [63:0] ro_dbg_h;

task readout;
    input [15:0] a;
    integer      g;
    begin
        ro_dbg_u = dbg_u;
        ro_dbg_h = dbg_h;
        org(a);
        pb(8'h08);
        pb3(8'h8D, 8'hF0, 8'hFF);
        pb3(8'h8E, 8'hF1, 8'hFF);
        pb3(8'h8C, 8'hF2, 8'hFF);
        pb(8'hBA);
        pb3(8'h8E, 8'hF3, 8'hFF);
        pb3(8'h4C, pp[7:0], pp[15:8]);
        cap_got_u = 4'h0;
        cap_got_h = 4'h0;
        cap_pgot_u = 1'b0;
        cap_pgot_h = 1'b0;
        cap_arm = 1'b1;
        g = 0;
        while(!((cap_got_u == 4'hF) && ((cap_got_h == 4'hF) || (tb_ratio == 1))) && (g < 40)) begin
            wait_cen();
            g = g + 1;
        end
        cap_arm = 1'b0;
        ro_ok = (cap_got_u == 4'hF) && cap_pgot_u && (((cap_got_h == 4'hF) && cap_pgot_h) || (tb_ratio == 1));
        ro_p_u = cap_p_u;
        ro_a_u = cap_reg_u[31:24];
        ro_x_u = cap_reg_u[23:16];
        ro_y_u = cap_reg_u[15:8];
        ro_s_u = cap_reg_u[7:0] + 8'd1;
        ro_p_h = cap_p_h;
        ro_a_h = cap_reg_h[31:24];
        ro_x_h = cap_reg_h[23:16];
        ro_y_h = cap_reg_h[15:8];
        ro_s_h = cap_reg_h[7:0] + 8'd1;
    end
endtask

// readout checks against expected values (both CPUs, dbg_* at the fetch too)
task check_regs;
    input [7:0]       ea;
    input [7:0]       ex;
    input [7:0]       ey;
    input [7:0]       es;
    input [7:0]       ep;
    input [8*120-1:0] tag;
    begin
        $sformat(nm, "%0s: A X Y S on the bus (uut)", tag);
        check({ro_a_u, ro_x_u, ro_y_u, ro_s_u}, {ea, ex, ey, es}, nm);
        $sformat(nm, "%0s: P pushed by PHP (uut)", tag);
        check(ro_p_u, ep | 8'h30, nm);
        if(tb_ratio > 1) begin
            $sformat(nm, "%0s: A X Y S on the bus (uuth)", tag);
            check({ro_a_h, ro_x_h, ro_y_h, ro_s_h}, {ea, ex, ey, es}, nm);
            $sformat(nm, "%0s: P pushed by PHP (uuth)", tag);
            check(ro_p_h, ep | 8'h30, nm);
        end
        $sformat(nm, "%0s: dbg_a dbg_x dbg_y dbg_s", tag);
        check(ro_dbg_u[47:16], {ea, ex, ey, es}, nm);
        $sformat(nm, "%0s: dbg_p", tag);
        check(ro_dbg_u[15:8], ep | 8'h30, nm);
        if(tb_ratio > 1) begin
            $sformat(nm, "%0s: uuth dbg_* equal uut", tag);
            check(ro_dbg_h === ro_dbg_u, 1, nm);
        end
    end
endtask

//-------------------------------------------------------------------------
// Entry Sequence Check:
// Records e .. e+7 of an IRQ/NMI entry (brk = 0: cycle 2 reads PC again)
// or a BRK (brk = 1: cycle 2 reads PC+1): SYNC fetch at a, the second
// read, writes of PCH, PCL and P at 0100+s, s-1, s-2, the vector reads at
// v and v+1 with vp_n = 0, and the fetch at the handler h. ent_ok = 1 when
// every pin of both CPUs matches.
//-------------------------------------------------------------------------
reg ent_ok;

task chk_entry;
    input integer e;
    input        brk;
    input [15:0] a;
    input [15:0] ret;
    input  [7:0] s;
    input  [7:0] pp;
    input [15:0] v;
    input [15:0] h;
    reg   [40:0] g;
    integer      q;
    begin
        while(tr_n <= e + 7)
            wait_cen();
        ent_ok = bus_is(e, a, 1'b1, 1'b1) && bus_is(e + 1, brk ? a + 16'd1 : a, 1'b1, 1'b0) &&
                 bus_is(e + 2, {8'h01, s}, 1'b0, 1'b0) && bus_is(e + 3, {8'h01, s - 8'd1}, 1'b0, 1'b0) &&
                 bus_is(e + 4, {8'h01, s - 8'd2}, 1'b0, 1'b0) && bus_is(e + 5, v, 1'b1, 1'b0) &&
                 bus_is(e + 6, v + 16'd1, 1'b1, 1'b0) && bus_is(e + 7, h, 1'b1, 1'b1);
        g = ra_u(e + 2);
        ent_ok = ent_ok && (g[23:16] === ret[15:8]);
        g = ra_u(e + 3);
        ent_ok = ent_ok && (g[23:16] === ret[7:0]);
        g = ra_u(e + 4);
        ent_ok = ent_ok && (g[23:16] === pp);
        for(q = 0; q <= 7; q = q + 1) begin
            g = ra_u(e + q);
            ent_ok = ent_ok && (g[27] === ((q == 5) || (q == 6) ? 1'b0 : 1'b1));
            g = ra_h(e + q);
            if(tb_ratio > 1)
                ent_ok = ent_ok && (g[27] === ((q == 5) || (q == 6) ? 1'b0 : 1'b1));
        end
    end
endtask

// byte written in record ix (uut)
function [7:0] wbyte;
    input integer ix;
    reg [40:0] g;
    begin
        g = ra_u(ix);
        wbyte = g[23:16];
    end
endfunction

//-------------------------------------------------------------------------
// One Instruction:
// run1 places op, b1, b2 at 0400 (the image is set up by the caller),
// sets the registers with the preamble at 0200, runs the instruction and
// reads the registers out through the bus at the next fetch (r1_next, after
// r1_cyc cycles). r1_base = record index of the instruction's cycle 1.
//-------------------------------------------------------------------------
reg  [15:0] r1_next;
integer     r1_cyc;
integer     r1_base;

task run1;
    input [7:0] op;
    input [7:0] b1;
    input [7:0] b2;
    input [7:0] rs;
    input [7:0] rp;
    input [7:0] ra;
    input [7:0] rx;
    input [7:0] ry;
    begin
        org(16'h0400);
        pb3(op, b1, b2);
        start_at(16'h0400, 16'h0200, rs, rp, ra, rx, ry);
        r1_base = tr_n;
        run_to_fetch(16'h0000, 1'b1, 30);
        r1_cyc = fetch_cyc;
        r1_next = addr_u;
        readout(addr_u);
    end
endtask

//-------------------------------------------------------------------------
// Program Start:
// start_at builds nothing; it boots to the program at a with the registers
// set by real instructions: the preamble LDX #s; TXS; LDA #p; PHA;
// LDA #a; LDX #x; LDY #y; PLP; JMP a placed at pre (22 cycles). Returns at
// the cen that starts the fetch at a.
//-------------------------------------------------------------------------
task start_at;
    input [15:0] a;
    input [15:0] pre;
    input  [7:0] rs;
    input  [7:0] rp;
    input  [7:0] ra;
    input  [7:0] rx;
    input  [7:0] ry;
    begin
        org(pre);
        pb2(8'hA2, rs);
        pb(8'h9A);
        pb2(8'hA9, rp);
        pb(8'h48);
        pb2(8'hA9, ra);
        pb2(8'hA2, rx);
        pb2(8'hA0, ry);
        pb(8'h28);
        pb3(8'h4C, a[7:0], a[15:8]);
        boot_to(pre);
        run_to_fetch(a, 0, 40);
    end
endtask

//=========================================================================
// Instruction Vectors:
// One instruction per record (gen_vectors.py): initial registers and
// memory, every bus cycle (address, R/W, data), final registers and
// memory. The registers are set by the preamble of start_at at 0200 (0300
// when the instruction lies near 0200); at the cen that starts the fetch
// of the instruction the image is replaced by the record's memory (every
// other address reads 00). The instruction then runs to the next opcode
// fetch: every cycle is compared on uut, and on uuth when tb_ratio > 1
// (also with uut: lockstep), SYNC only in the first cycle, vp_n low only
// in BRK cycles 6 and 7; then dbg_* (P with bits 5 and 4 reading 1) and
// the record's final memory.
//   W0 {A5, op, dec, ncyc}  W1 {idx, pc}  W2 {s, p, a, x}  W3 {y, nram,
//   nfin, 00}  W4 {fpc, fs, fp}  W5 {fa, fx, fy, 00}, then nram and nfin
//   words {00, addr, data}, ncyc words {rw, addr, data}; end FFFFFFFF.
//=========================================================================
localparam VECN = 65536;
reg  [31:0] vec [0:VECN-1];
integer     vec_words;
integer     op_n [0:255];
integer     op_mm [0:255];
integer     op_dec [0:255];
integer     vec_tests;
integer     vec_fail;
integer     info_left;
integer     g_both;
integer     g_lock;
integer     g_cyc;

task vec_load;
    reg [8*256-1:0] f;
    integer         q;
    begin
        for(q = 0; q < VECN; q = q + 1)
            vec[q] = 32'hFFFFFFFF;
        if(!$value$plusargs("vec=%s", f))
            f = "tb_x65c02_ops.hex";
        $readmemh(f, vec);
        vec_words = 0;
        while((vec_words < VECN) && (vec[vec_words] !== 32'hFFFFFFFF))
            vec_words = vec_words + 1;
    end
endtask

task vec_clear_counts;
    integer q;
    begin
        for(q = 0; q < 256; q = q + 1) begin
            op_n[q] = 0;
            op_mm[q] = 0;
            op_dec[q] = 0;
        end
        vec_tests = 0;
        vec_fail = 0;
    end
endtask

//-------------------------------------------------------------------------
// One Record:
// vec_one runs the record at word w and returns the next record's word
// index in vec_next; vec_mm = mismatching fields of this test.
//-------------------------------------------------------------------------
integer vec_next;
integer vec_mm;
reg [8*200-1:0] vec_why;

task vec_one;
    input integer w;
    integer    q;
    integer    nr;
    integer    nf;
    integer    nc;
    integer    rb;
    integer    ri;
    integer    fi;
    integer    ci;
    reg  [7:0] op;
    reg [15:0] pc;
    reg [15:0] pre;
    reg [40:0] gu;
    reg [40:0] gh;
    reg [31:0] e;
    reg [63:0] du;
    reg [63:0] dh;
    reg        vpx;
    begin
        op = vec[w][23:16];
        nc = vec[w][7:0];
        pc = vec[w + 1][15:0];
        nr = vec[w + 3][23:16];
        nf = vec[w + 3][15:8];
        ri = w + 6;
        fi = ri + nr;
        ci = fi + nf;
        vec_next = ci + nc;
        vec_mm = 0;
        vec_why = "";

        // registers by the preamble, away from the instruction
        mem_new(8'h00);
        vectors(16'h0000, 16'h0000, 16'h0000);
        pre = ((pc >= 16'h01E0) && (pc < 16'h0230)) ? 16'h0300 : 16'h0200;
        start_at(pc, pre, vec[w + 2][31:24], vec[w + 2][23:16], vec[w + 2][15:8], vec[w + 2][7:0],
                 vec[w + 3][31:24]);
        if(!found) begin
            vec_mm = vec_mm + 1;
            vec_why = "preamble did not reach the instruction";
        end

        // the record's memory from the fetch on
        mem_new(8'h00);
        for(q = 0; q < nr; q = q + 1)
            put(vec[ri + q][23:8], vec[ri + q][7:0]);
        rb = tr_n;
        run_to_fetch(16'h0000, 1'b1, 64);
        if(!found || (tr_n - rb != nc)) begin
            vec_mm = vec_mm + 1;
            $sformat(vec_why, "cycles %0d, expected %0d", tr_n - rb, nc);
        end

        // every cycle
        for(q = 0; (q < nc) && (q < tr_n - rb); q = q + 1) begin
            e = vec[ci + q];
            gu = ra_u(rb + q);
            gh = ra_h(rb + q);
            vpx = (op == 8'h00) && ((q == 5) || (q == 6)) ? 1'b0 : 1'b1;
            if((gu[15:0] !== e[23:8]) || (gu[24] !== e[24]) || (gu[23:16] !== e[7:0]) ||
               (gu[25] !== (q == 0)) || (gu[27] !== vpx)) begin
                if(vec_mm == 0)
                    $sformat(vec_why, "uut cycle %0d: %h %0s %h sync %b vp %b, expected %h %0s %h", q, gu[15:0],
                             gu[24] ? "r" : "w", gu[23:16], gu[25], gu[27], e[23:8], e[24] ? "r" : "w", e[7:0]);
                vec_mm = vec_mm + 1;
            end
            if(tb_ratio > 1) begin
                if((gh[15:0] !== e[23:8]) || (gh[24] !== e[24]) || (gh[23:16] !== e[7:0]) ||
                   (gh[25] !== (q == 0)) || (gh[27] !== vpx)) begin
                    if(vec_mm == 0)
                        $sformat(vec_why, "uuth cycle %0d: %h %0s %h, expected %h %0s %h", q, gh[15:0],
                                 gh[24] ? "r" : "w", gh[23:16], e[23:8], e[24] ? "r" : "w", e[7:0]);
                    vec_mm = vec_mm + 1;
                end
                if(gu[27:0] !== gh[27:0])
                    g_lock = g_lock + 1;
            end
        end
        if(tb_ratio > 1) begin
            g_both = g_both + 1;
            g_cyc = g_cyc + tr_n - rb;
        end

        // registers at the next fetch
        du = dbg_u;
        dh = dbg_h;
        if((du[63:48] !== vec[w + 4][31:16]) || (du[47:40] !== vec[w + 5][31:24]) ||
           (du[39:32] !== vec[w + 5][23:16]) || (du[31:24] !== vec[w + 5][15:8]) ||
           (du[23:16] !== vec[w + 4][15:8]) || ((du[15:8] & 8'hCF) !== (vec[w + 4][7:0] & 8'hCF)) ||
           ((du[15:8] & 8'h30) !== 8'h30)) begin
            if(vec_mm == 0)
                $sformat(vec_why, "registers pc %h a %h x %h y %h s %h p %h, expected %h %h %h %h %h %h", du[63:48],
                         du[47:40], du[39:32], du[31:24], du[23:16], du[15:8], vec[w + 4][31:16],
                         vec[w + 5][31:24], vec[w + 5][23:16], vec[w + 5][15:8], vec[w + 4][15:8], vec[w + 4][7:0]);
            vec_mm = vec_mm + 1;
        end
        if((tb_ratio > 1) && (dh[63:8] !== du[63:8])) begin
            if(vec_mm == 0)
                vec_why = "uuth registers differ from uut";
            vec_mm = vec_mm + 1;
        end

        // final memory
        for(q = 0; q < nf; q = q + 1) begin
            if((tag_u[vec[fi + q][23:8]] !== img) || (mem_u[vec[fi + q][23:8]] !== vec[fi + q][7:0]) ||
               ((tb_ratio > 1) && ((tag_h[vec[fi + q][23:8]] !== img) ||
                                   (mem_h[vec[fi + q][23:8]] !== vec[fi + q][7:0])))) begin
                if(vec_mm == 0)
                    $sformat(vec_why, "memory %h = %h, expected %h", vec[fi + q][23:8], mem_u[vec[fi + q][23:8]],
                             vec[fi + q][7:0]);
                vec_mm = vec_mm + 1;
            end
        end
    end
endtask

//-------------------------------------------------------------------------
// Record Loops:
// vec_run runs every stride-th record from the first (at most max);
// vec_run_op the records of one opcode. Per opcode: tests, failing tests,
// tests whose expected values come from a decision.
//-------------------------------------------------------------------------
task vec_account;
    input integer w;
    reg [7:0] op;
    begin
        op = vec[w][23:16];
        op_n[op] = op_n[op] + 1;
        if(vec[w][15:8] != 0)
            op_dec[op] = op_dec[op] + 1;
        vec_tests = vec_tests + 1;
        if(vec_mm != 0) begin
            op_mm[op] = op_mm[op] + 1;
            vec_fail = vec_fail + 1;
            if(info_left > 0) begin
                info_left = info_left - 1;
                $display("INFO: vector $%h test %0d (pc %h): %0s", op, vec[w + 1][31:16], vec[w + 1][15:0], vec_why);
            end
        end
    end
endtask

task vec_run;
    input integer stride;
    input integer max;
    integer w;
    integer r;
    integer cnt;
    begin
        w = 0;
        r = 0;
        cnt = 0;
        while((w < vec_words) && (vec[w][31:24] == 8'hA5) && (cnt < max)) begin
            vec_one_skip(w);
            if((r % stride) == 0) begin
                vec_one(w);
                vec_account(w);
                cnt = cnt + 1;
            end
            w = vec_next;
            r = r + 1;
        end
    end
endtask

// vec_next for the record at w without running it
task vec_one_skip;
    input integer w;
    begin
        vec_next = w + 6 + vec[w + 3][23:16] + vec[w + 3][15:8] + vec[w][7:0];
    end
endtask

task vec_report;
    input [8*160-1:0] name;
    begin
        $sformat(nm, "%0s: %0d tests, failing", name, vec_tests);
        check_mm(vec_fail + ((vec_tests == 0) ? 1 : 0), nm);
    end
endtask
//=========================================================================
// Reference Functions:
// Result and flags of the arithmetic instructions, written from the
// instruction definitions: binary ADC/SBC, and decimal mode (D = 1) by
// the 65C02 sequences: ADC forms the low digit AL, the result from the
// binary high digits plus AL with a 60 adjust, V from the signed high
// digits plus AL; SBC subtracts in binary, then 60 when the difference
// is negative and 06 when the low-digit difference is negative, with V
// and C of the binary subtraction. N and Z follow the result [p.1-10].
// Return value {result[7:0], N, V, Z, C}.
//=========================================================================
function [11:0] ref_adc;
    input [7:0] a;
    input [7:0] m;
    input       c;
    input       d;
    integer     t;
    integer     al;
    integer     s1;
    integer     s2;
    integer     sa;
    integer     sm;
    reg   [7:0] q;
    begin
        if(!d) begin
            t = a + m + c;
            q = t & 255;
            ref_adc = {q, q[7], (((a ^ q) & (m ^ q)) & 8'h80) != 8'h00, q == 8'h00, t > 255};
        end else begin
            al = (a & 15) + (m & 15) + c;
            if(al >= 10)
                al = ((al + 6) & 15) + 16;
            s1 = (a & 240) + (m & 240) + al;
            if(s1 >= 160)
                s1 = s1 + 96;
            sa = a & 240;
            if(sa >= 128)
                sa = sa - 256;
            sm = m & 240;
            if(sm >= 128)
                sm = sm - 256;
            s2 = sa + sm + al;
            q = s1 & 255;
            ref_adc = {q, q[7], (s2 < -128) || (s2 > 127), q == 8'h00, s1 >= 256};
        end
    end
endfunction

function [11:0] ref_sbc;
    input  [7:0] a;
    input  [7:0] m;
    input        c;
    input        d;
    integer      al;
    integer      s3;
    reg    [7:0] q;
    reg   [11:0] b;
    begin
        b = ref_adc(a, ~m, c, 1'b0);
        if(!d) begin
            ref_sbc = b;
        end else begin
            al = (a & 15) - (m & 15) + c - 1;
            s3 = a - m + c - 1;
            if(s3 < 0)
                s3 = s3 - 96;
            if(al < 0)
                s3 = s3 - 6;
            q = s3 & 255;
            ref_sbc = {q, q[7], b[2], q == 8'h00, b[0]};
        end
    end
endfunction

//=========================================================================
// Decimal Sweep Checker:
// While dec_on = 1, a write of uut to F000 (the result A) followed by the
// next stack write (P pushed by PHP) closes one case. Cases run C outer, A
// middle, operand inner (index (C << 16) | (A << 8) | operand). dec_kind:
// 0 ADC #, 1 SBC #.
//=========================================================================
reg         dec_on;
integer     dec_kind;
integer     dec_case;
integer     dec_mm;
reg   [7:0] dec_a;
reg         dec_have_a;
reg  [11:0] dec_e;
reg   [7:0] dec_ep;

always @(posedge clk) begin
    if(dec_on && cen && (rw_u === 1'b0)) begin
        if(addr_u === 16'hF000) begin
            dec_a = dout_u;
            dec_have_a = 1'b1;
        end else if((addr_u[15:8] === 8'h01) && dec_have_a) begin
            if(dec_kind == 0)
                dec_e = ref_adc(dec_case[15:8], dec_case[7:0], dec_case[16], 1'b1);
            else
                dec_e = ref_sbc(dec_case[15:8], dec_case[7:0], dec_case[16], 1'b1);
            dec_ep = {dec_e[3], dec_e[2], 1'b1, 1'b1, 1'b1, 1'b0, dec_e[1], dec_e[0]};
            if((dec_a !== dec_e[11:4]) || ((dout_u & 8'hFB) !== dec_ep))
                dec_mm = dec_mm + 1;
            dec_case = dec_case + 1;
            dec_have_a = 1'b0;
        end
    end
end
//=========================================================================
// Instruction Set for the Sweeps:
// sw_mem builds the common image (fill EA, so a stream continues with
// NOPs): 0010/0011 = pointer 1234, 1234 = 41, 1235 = EA, 0020 = 0F;
// vectors NMI 0600, RES 0500, IRQ/BRK 0700. sw_setup(t) adds instruction
// t at 0400 and starts it with its registers; it returns at the cen that
// starts the fetch at 0400. sw_name is the instruction's text, sw_len its
// cycle count without interrupts or RDY.
//=========================================================================
reg [8*24-1:0] sw_name;
integer sw_len;
localparam SWN = 30;

task sw_mem;
    begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        put16(16'h0010, 16'h1234);
        put(16'h1234, 8'h41);
        put(16'h0020, 8'h0F);
    end
endtask

task sw_setup;
    input integer t;
    reg [7:0] p;
    reg [7:0] x;
    reg [7:0] y;
    begin
        sw_mem();
        p = 8'h04;
        x = 8'h01;
        y = 8'h01;
        org(16'h0400);
        case(t)
            0: begin pb(8'hEA); sw_name = "NOP"; sw_len = 2; end
            1: begin pb2(8'hA9, 8'h55); sw_name = "LDA #"; sw_len = 2; end
            2: begin pb3(8'hAD, 8'h34, 8'h12); sw_name = "LDA abs"; sw_len = 4; end
            3: begin pb3(8'h8D, 8'h34, 8'h12); sw_name = "STA abs"; sw_len = 4; end
            4: begin pb3(8'hEE, 8'h34, 8'h12); sw_name = "INC abs"; sw_len = 6; end
            5: begin pb3(8'hFE, 8'h33, 8'h12); sw_name = "INC abs,X"; sw_len = 7; end
            6: begin pb3(8'h1E, 8'h33, 8'h12); sw_name = "ASL abs,X"; sw_len = 6; end
            7: begin pb2(8'h69, 8'h19); p = 8'h0C; sw_name = "ADC # (D = 1)"; sw_len = 3; end
            8: begin pb3(8'h6D, 8'h34, 8'h12); p = 8'h0C; sw_name = "ADC abs (D = 1)"; sw_len = 5; end
            9: begin pb2(8'hB1, 8'h10); y = 8'hF0; sw_name = "LDA (zp),Y cross"; sw_len = 6; end
            10: begin pb2(8'h91, 8'h10); sw_name = "STA (zp),Y"; sw_len = 6; end
            11: begin pb3(8'h4C, 8'h00, 8'h06); sw_name = "JMP abs"; sw_len = 3; end
            12: begin pb3(8'h6C, 8'h34, 8'h12); sw_name = "JMP (abs)"; sw_len = 6; end
            13: begin pb3(8'h7C, 8'h33, 8'h12); sw_name = "JMP (abs,X)"; sw_len = 6; end
            14: begin pb2(8'hD0, 8'h10); sw_name = "BNE taken"; sw_len = 3; end
            15: begin pb2(8'hD0, 8'hF0); sw_name = "BNE taken, page cross"; sw_len = 4; end
            16: begin pb2(8'h80, 8'h10); sw_name = "BRA"; sw_len = 3; end
            17: begin pb3(8'h8F, 8'h20, 8'h10); sw_name = "BBS0 taken"; sw_len = 6; end
            18: begin pb3(8'h0F, 8'h20, 8'h10); sw_name = "BBR0 not taken"; sw_len = 5; end
            19: begin pb3(8'h20, 8'h00, 8'h06); sw_name = "JSR"; sw_len = 6; end
            20: begin pb(8'h60); sw_name = "RTS"; sw_len = 6; end
            21: begin pb(8'h40); sw_name = "RTI"; sw_len = 6; end
            22: begin pb(8'h48); sw_name = "PHA"; sw_len = 3; end
            23: begin pb(8'h68); sw_name = "PLA"; sw_len = 4; end
            24: begin pb2(8'h00, 8'h00); sw_name = "BRK"; sw_len = 7; end
            25: begin pb(8'h03); sw_name = "NOP 03 (1 cycle)"; sw_len = 1; end
            26: begin pb3(8'h0C, 8'h34, 8'h12); sw_name = "TSB abs"; sw_len = 6; end
            27: begin pb2(8'h37, 8'h20); sw_name = "RMB3 zp"; sw_len = 5; end
            28: begin pb(8'hDA); sw_name = "PHX"; sw_len = 3; end
            default: begin pb(8'h7A); sw_name = "PLY"; sw_len = 4; end
        endcase
        start_at(16'h0400, 16'h0200, 8'hFF, p, 8'h5A, x, y);
    end
endtask

//-------------------------------------------------------------------------
// RES Protocol Check:
// k = record of cycle r (the cycle the first low RES sample starts), f =
// record index of the fetch at the RES vector, w = RES low edges. Counts
// the rules that fail: no write from r+1, one SYNC (at s+1 = r+1+w), the
// held address from r+2 to s+2, three page-1 stack reads counting down,
// FFFC, FFFD, the fetch at s+8; uuth equal to uut.
//-------------------------------------------------------------------------
function integer a9_check;
    input integer k;
    input integer f;
    input integer w;
    integer    q;
    integer    j;
    reg [40:0] g;
    reg [15:0] h;
    reg [15:0] st;
    begin
        a9_check = 0;
        j = k + 1 + w;
        if(writes_in(k + 1, f - 1) != 0)
            a9_check = a9_check + 1;
        if((syncs_in(k + 1, f - 1) != 1) || !bus_rs(j, 1'b1, 1'b1))
            a9_check = a9_check + 1;
        if(f - j != 7)
            a9_check = a9_check + 1;
        g = ra_u(j);
        h = g[15:0];
        for(q = k + 2; q <= j + 1; q = q + 1) begin
            g = ra_u(q);
            if(g[15:0] !== h)
                a9_check = a9_check + 1;
        end
        g = ra_u(j + 2);
        st = g[15:0];
        if((st[15:8] !== 8'h01) || !bus_is(j + 2, st, 1'b1, 1'b0) ||
           !bus_is(j + 3, {8'h01, st[7:0] - 8'd1}, 1'b1, 1'b0) || !bus_is(j + 4, {8'h01, st[7:0] - 8'd2}, 1'b1, 1'b0))
            a9_check = a9_check + 1;
        if(!bus_is(j + 5, 16'hFFFC, 1'b1, 1'b0) || !bus_is(j + 6, 16'hFFFD, 1'b1, 1'b0))
            a9_check = a9_check + 1;
        if(tb_ratio > 1)
            for(q = k; q < f; q = q + 1)
                if((ra_u(q) & 41'h0_00_0F_FFFFFF) !== (ra_h(q) & 41'h0_00_0F_FFFFFF))
                    a9_check = a9_check + 1;
    end
endfunction

//-------------------------------------------------------------------------
// Reference Runs:
// ref_capture stores records ix0 .. ix1-1 of uut as the reference
// sequence (address, R/W, data, SYNC: bits [25:0]); ref_n entries.
//-------------------------------------------------------------------------
reg  [25:0] ref_seq [0:63];
integer     ref_n;

task ref_capture;
    input integer ix0;
    input integer ix1;
    integer    q;
    reg [40:0] g;
    begin
        ref_n = 0;
        for(q = ix0; (q < ix1) && (ref_n < 64); q = q + 1) begin
            g = ra_u(q);
            ref_seq[ref_n] = g[25:0];
            ref_n = ref_n + 1;
        end
    end
endtask

//-------------------------------------------------------------------------
// Expected Bus Sequences:
// ex_clear starts a sequence; ex_r (read, address only), ex_rd (read
// with its byte) and ex_wr (write with its byte) append one cycle each.
// ex_go starts the program at a with the registers, runs it to the next
// opcode fetch and keeps the record index of its cycle 1 (ex_base) and
// the fetch address (ex_next). ex_check counts the cycles of both CPUs
// that differ (address, R/W, data where given, SYNC only in cycle 1),
// plus 1 when the cycle count differs.
//-------------------------------------------------------------------------
reg  [15:0] ex_a [0:15];
reg         ex_w [0:15];
reg   [7:0] ex_d [0:15];
reg         ex_dv [0:15];
integer     ex_n;
integer     ex_base;
reg  [15:0] ex_next;

task ex_clear;
    begin
        ex_n = 0;
    end
endtask

task ex_r;
    input [15:0] a;
    begin
        ex_a[ex_n] = a;
        ex_w[ex_n] = 1'b0;
        ex_dv[ex_n] = 1'b0;
        ex_n = ex_n + 1;
    end
endtask

task ex_rd;
    input [15:0] a;
    input  [7:0] d;
    begin
        ex_a[ex_n] = a;
        ex_w[ex_n] = 1'b0;
        ex_d[ex_n] = d;
        ex_dv[ex_n] = 1'b1;
        ex_n = ex_n + 1;
    end
endtask

task ex_wr;
    input [15:0] a;
    input  [7:0] d;
    begin
        ex_a[ex_n] = a;
        ex_w[ex_n] = 1'b1;
        ex_d[ex_n] = d;
        ex_dv[ex_n] = 1'b1;
        ex_n = ex_n + 1;
    end
endtask

task ex_go;
    input [15:0] a;
    input  [7:0] rp;
    input  [7:0] ra;
    input  [7:0] rx;
    input  [7:0] ry;
    begin
        start_at(a, 16'h0200, 8'hFF, rp, ra, rx, ry);
        ex_base = tr_n;
        run_to_fetch(16'h0000, 1'b1, 40);
        ex_next = addr_u;
    end
endtask

function integer ex_check;
    input        dummy;
    integer      q;
    reg   [40:0] gu;
    reg   [40:0] gh;
    begin
        ex_check = (tr_n - ex_base != ex_n) ? 1 : 0;
        for(q = 0; q < ex_n; q = q + 1) begin
            gu = ra_u(ex_base + q);
            gh = ra_h(ex_base + q);
            if((gu[15:0] !== ex_a[q]) || (gu[24] !== !ex_w[q]) || (gu[25] !== (q == 0)) ||
               (ex_dv[q] && (gu[23:16] !== ex_d[q])))
                ex_check = ex_check + 1;
            if((tb_ratio > 1) && ((gh[15:0] !== ex_a[q]) || (gh[24] !== !ex_w[q]) || (gh[25] !== (q == 0)) ||
                                  (ex_dv[q] && (gh[23:16] !== ex_d[q]))))
                ex_check = ex_check + 1;
        end
        if((ex_check != 0) && (info_left > 0)) begin
            info_left = info_left - 1;
            for(q = 0; (q < ex_n) || (q < tr_n - ex_base); q = q + 1) begin
                gu = ra_u(ex_base + q);
                $display("INFO:   cycle %0d: got %h %0s %h sync %b, expected %h %0s", q + 1, gu[15:0],
                         gu[24] ? "r" : "w", gu[23:16], gu[25], (q < ex_n) ? ex_a[q] : 16'hxxxx,
                         (q < ex_n) ? (ex_w[q] ? "w" : "r") : "-");
            end
        end
    end
endfunction

//-------------------------------------------------------------------------
// Record Dump:
// dump_recs prints n records of uut from ix0 (address, R/W, data, SYNC).
//-------------------------------------------------------------------------
task dump_recs;
    input integer ix0;
    input integer n;
    integer    q;
    reg [40:0] g;
    begin
        for(q = ix0; q < ix0 + n; q = q + 1) begin
            g = ra_u(q);
            $display("INFO:   rec +%0d: %h %0s %h sync %b", q - ix0, g[15:0], g[24] ? "r" : "w", g[23:16], g[25]);
        end
    end
endtask
//=========================================================================
// Main Test Sequence:
//=========================================================================
initial begin
    $display("=============================================================");
    $display("  x65c02 Comprehensive Testbench");
    $display("  Reference: Rockwell R65C02 Datasheet, R65C02P2 bus recordings");
    $display("=============================================================");

    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;
    seed = 32'h65C0;
    en_seed = 32'h1987;
    tb_ratio = 4;
    en_run = 1'b0;
    en_stall = 1'b0;
    en_ph = 0;
    en_hold = 0;
    cen_cnt = 0;
    cen = 1'b0;
    cen_p2 = 1'b0;
    rst_n = 1'b0;
    inputs_idle();
    img = 1;
    fill = 8'hEA;
    boot = 1'b0;
    boot_vec = 16'h0000;
    mem_gen = 0;
    tr_n = 0;
    p1v = 1'b0;
    cap_arm = 1'b0;
    cap_got_u = 4'h0;
    cap_got_h = 4'h0;
    cap_pgot_u = 1'b0;
    cap_pgot_h = 1'b0;
    wr_cnt_u = 0;
    wr_cnt_h = 0;
    mon_on = 1'b0;
    mon_viol_u = 0;
    mon_viol_h = 0;
    mon_x_u = 0;
    mon_x_h = 0;
    info_left = 0;
    g_both = 0;
    g_lock = 0;
    g_cyc = 0;
    dec_on = 1'b0;
    for(i = 0; i < 65536; i = i + 1) begin
        mem_u[i] = 8'h00;
        mem_h[i] = 8'h00;
        tag_u[i] = 0;
        tag_h[i] = 0;
    end
    vec_load();
    vec_clear_counts();
    info("vector file loaded");

    //---------------------------------------------------------------------
    // CPU SECTION A: Reset
    // Power-up values, the reset sequence and what it keeps or clears, the
    // bus while RES is low, one-edge RES and RES sampled only at cen,
    // writes in the cycle RES falls, RES at every cycle of every kind of
    // instruction, RES inside a running reset sequence, RDY during the RES
    // protocol. [p.1-6], [p.1-10]
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CPU SECTION A: Reset");
    $display("=========================================================");

    //---------------------------------------------------------------------
    // A.1 Power-up values: declaration initializers, before any enable.
    //---------------------------------------------------------------------
    section("CPU SECTION A.1: Power-up Values");
    #1;
    check({da_u, dx_u, dy_u}, 24'h000000, "A.1 power-up A X Y = 00 00 00");
    check(ds_u, 8'h00, "A.1 power-up S = 00");
    check(dp_u, 8'h34, "A.1 power-up P = 34 (I = 1, D = 0, bits 5 and 4 read 1)");
    check(dpc_u, 16'h0000, "A.1 power-up PC = 0000");
    check(dir_u, 8'h00, "A.1 power-up IR = 00");
    check({rw_u, oe_u}, 2'b10, "A.1 power-up R/W = 1, dout_oe = 0");
    check(^outs_u === 1'bx, 1'b0, "A.1 power-up: no output is X (uut, cen_p2 unconnected)");
    check(^outs_h === 1'bx, 1'b0, "A.1 power-up: no output is X (uuth)");
    check(outs_h === outs_u, 1'b1, "A.1 power-up: uuth outputs equal uut");

    //---------------------------------------------------------------------
    // A.2 First reset: RES held low from power-up while the enables start,
    // released in phi1 of cycle c: s = c + 1, stack reads at s+3..s+5
    // (0100+S, S-1, S-2 with S = 00), FFFC/FFFD at s+6/s+7, first fetch at
    // s+8 (seven cycles s+1..s+7 [p.1-6]); no write; SYNC only at s+1.
    //---------------------------------------------------------------------
    section("CPU SECTION A.2: First Reset after Power-up");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0400, 16'h0500);
    tb_ratio = 4;
    en_run = 1'b1;
    wait_cen();
    mon_on = 1'b1;
    cycles(4);
    base = tr_n;
    rst_n = 1'b1;
    run_to_fetch(16'h0400, 0, 30);
    check(found, 1'b1, "A.2 first fetch at the RES vector 0400");
    check(fetch_cyc, 9, "A.2 first fetch 9 cycles after the release (cycle s+8)");
    check(wr_cnt_u + wr_cnt_h, 0, "A.2 no write cycle from power-up to the first fetch (both CPUs)");
    check(bus_is(base + 4, 16'h0100, 1'b1, 1'b0), 1'b1, "A.2 s+3 reads 0100 (0100+S, S = 00)");
    check(bus_is(base + 5, 16'h01FF, 1'b1, 1'b0), 1'b1, "A.2 s+4 reads 01FF (S-1 wraps)");
    check(bus_is(base + 6, 16'h01FE, 1'b1, 1'b0), 1'b1, "A.2 s+5 reads 01FE");
    check(bus_is(base + 7, 16'hFFFC, 1'b1, 1'b0), 1'b1, "A.2 s+6 reads FFFC");
    check(bus_is(base + 8, 16'hFFFD, 1'b1, 1'b0), 1'b1, "A.2 s+7 reads FFFD");
    check(syncs_in(base + 1, base + 8), 1, "A.2 one SYNC cycle between s and the first fetch");
    check(bus_rs(base + 2, 1'b1, 1'b1), 1'b1, "A.2 SYNC = 1 in s+1");
    tmp32 = 0;
    for(k = 0; k <= 8; k = k + 1) begin
        if((ra_u(base + k) & 41'h0_00_0C_000000) !== 41'h0_00_08_000000)
            tmp32 = tmp32 + 1;
        if((tb_ratio > 1) && ((ra_h(base + k) & 41'h0_00_0C_000000) !== 41'h0_00_08_000000))
            tmp32 = tmp32 + 1;
    end
    check(tmp32, 0, "A.2 vp_n = 1 and dout_oe = 0 in every cycle of the sequence");
    readout(16'h0400);
    check(ro_ok, 1'b1, "A.2 readout complete");
    check_regs(8'h00, 8'h00, 8'h00, 8'hFD, 8'h04, "A.2 after the first reset");
    check(ro_dbg_u[63:48], 16'h0400, "A.2 dbg_pc = 0400 at the first fetch");

    //---------------------------------------------------------------------
    // A.3 A warm reset keeps A, X, Y, N, V, Z, C, lowers S by 3, sets I and
    // clears D [p.1-6]; RES low across one cen only. Program: CLD; CLC;
    // LDA #40; ADC #40; LDX #80; TXS; LDX #5A; LDY #C3; SEC; SED; JMP
    // self. Ratios 2 and 5.
    //---------------------------------------------------------------------
    section("CPU SECTION A.3: Registers Kept by a Warm Reset, D Cleared");
    for(t = 0; t < 2; t = t + 1) begin
        tb_ratio = (t == 0) ? 2 : 5;
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0600);
        org(16'h0400);
        pb(8'hD8);
        pb(8'h18);
        pb2(8'hA9, 8'h40);
        pb2(8'h69, 8'h40);
        pb2(8'hA2, 8'h80);
        pb(8'h9A);
        pb2(8'hA2, 8'h5A);
        pb2(8'hA0, 8'hC3);
        pb(8'h38);
        pb(8'hF8);
        pb3(8'h4C, 8'h0F, 8'h04);
        boot_to(16'h0400);
        run_to_fetch(16'h040F, 0, 60);
        cycles(4);
        rst_n = 1'b0;
        wait_cen();
        rst_n = 1'b1;
        run_to_fetch(16'h0500, 0, 30);
        $sformat(nm, "A.3 ratio %0d: reset handler reached", tb_ratio);
        check(found, 1'b1, nm);
        readout(16'h0500);
        $sformat(nm, "A.3 ratio %0d: kept A X Y N V Z C, S = 80 - 3, I = 1, D = 0", tb_ratio);
        check_regs(8'h80, 8'h5A, 8'hC3, 8'h7D, 8'hC5, nm);
    end
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // A.4 S - 3 wraps and moves the three stack reads: S = 01 gives reads
    // at 0101, 0100, 01FF and S = FE after.
    //---------------------------------------------------------------------
    section("CPU SECTION A.4: Stack Reads and S - 3");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0600);
    org(16'h0400);
    pb2(8'hA2, 8'h01);
    pb(8'h9A);
    pb3(8'h4C, 8'h03, 8'h04);
    boot_to(16'h0400);
    run_to_fetch(16'h0403, 0, 20);
    cycles(1);
    rst_n = 1'b0;
    wait_cen();
    base = tr_n;
    rst_n = 1'b1;
    run_to_fetch(16'h0500, 0, 30);
    check(bus_is(base + 4, 16'h0101, 1'b1, 1'b0), 1'b1, "A.4 s+3 reads 0101");
    check(bus_is(base + 5, 16'h0100, 1'b1, 1'b0), 1'b1, "A.4 s+4 reads 0100");
    check(bus_is(base + 6, 16'h01FF, 1'b1, 1'b0), 1'b1, "A.4 s+5 reads 01FF");
    readout(16'h0500);
    check(ro_s_u, 8'hFE, "A.4 S = 01 - 3 = FE");
    check(ro_dbg_u[23:16], 8'hFE, "A.4 dbg_s = FE at the first fetch");

    //---------------------------------------------------------------------
    // A.5 Bus while RES is low. NOP at 03FF, LDA 1234 at 0400; RES first
    // sampled low at the edge that starts cycle n of the LDA (n = 0: the
    // NOP's last cycle), held for four edges. Cycle r+1 shows the address
    // the instruction would present (R/W = 1, SYNC = 0); r+2 .. s+2 show
    // the held PC with SYNC only at s+1; no write after cycle r. The LDA
    // loads A only when its last cycle is r or r+1.
    //---------------------------------------------------------------------
    section("CPU SECTION A.5: Bus while RES Is Low and the Held PC");
    for(n = 0; n <= 4; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0600);
        put(16'h1234, 8'h80);
        org(16'h03FF);
        pb(8'hEA);
        pb3(8'hAD, 8'h34, 8'h12);
        start_at(16'h03FF, 16'h0200, 8'hFF, 8'h04, 8'h11, 8'h22, 8'h33);
        base = tr_n;
        cycles(n);
        rst_n = 1'b0;
        cycles(4);
        rst_n = 1'b1;
        run_to_fetch(16'h0500, 0, 30);
        k = base + 1 + n;
        case(n)
            0: begin tmp16 = 16'h0400; tmp32 = 16'h0400; end
            1: begin tmp16 = 16'h0401; tmp32 = 16'h0401; end
            2: begin tmp16 = 16'h0402; tmp32 = 16'h0402; end
            3: begin tmp16 = 16'h1234; tmp32 = 16'h0403; end
            default: begin tmp16 = 16'h0403; tmp32 = 16'h0403; end
        endcase
        $sformat(nm, "A.5 RES from LDA cycle %0d: r+1 shows %h, R/W = 1, SYNC = 0", n, tmp16);
        check(bus_is(k + 1, tmp16, 1'b1, 1'b0), 1'b1, nm);
        errs = 0;
        for(j = 2; j <= 6; j = j + 1)
            if(!bus_is(k + j, tmp32[15:0], 1'b1, (j == 5)))
                errs = errs + 1;
        $sformat(nm, "A.5 RES from LDA cycle %0d: r+2 .. s+2 hold %h, SYNC only at s+1", n, tmp32[15:0]);
        check(errs, 0, nm);
        $sformat(nm, "A.5 RES from LDA cycle %0d: stack reads 01FF 01FE 01FD, then FFFC FFFD", n);
        check(bus_is(k + 7, 16'h01FF, 1'b1, 1'b0) && bus_is(k + 8, 16'h01FE, 1'b1, 1'b0) &&
              bus_is(k + 9, 16'h01FD, 1'b1, 1'b0) && bus_is(k + 10, 16'hFFFC, 1'b1, 1'b0) &&
              bus_is(k + 11, 16'hFFFD, 1'b1, 1'b0), 1'b1, nm);
        $sformat(nm, "A.5 RES from LDA cycle %0d: no write and no dout_oe from r+1 to the vector fetch", n);
        tmp8 = 0;
        for(j = 1; j <= 11; j = j + 1)
            if(((ra_u(k + j) & 41'h0_00_05_000000) !== 41'h0_00_01_000000) ||
               ((ra_h(k + j) & 41'h0_00_05_000000) !== 41'h0_00_01_000000))
                tmp8 = tmp8 + 1;
        check(tmp8, 0, nm);
        readout(16'h0500);
        $sformat(nm, "A.5 RES from LDA cycle %0d: A = %s", n, (n >= 3) ? "80 (loaded)" : "11 (abandoned)");
        check_regs((n >= 3) ? 8'h80 : 8'h11, 8'h22, 8'h33, 8'hFC, (n >= 3) ? 8'h84 : 8'h04, nm);
    end

    //---------------------------------------------------------------------
    // A.6 RES is sampled only at cen: a low pulse between two cen does
    // nothing, also with the enables stopped; RES low across one cen is a
    // full reset. Ratio 5, NOPs from 0400.
    //---------------------------------------------------------------------
    section("CPU SECTION A.6: RES Sampled at cen Only");
    tb_ratio = 5;
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0600);
    put(16'h0400, 8'h58);
    boot_to(16'h0400);
    base = tr_n;
    cycles(3);
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;
    cycles(9);
    check(now_is(16'h0406, 1'b1, 1'b1) && (tr_n == base + 12), 1'b1, "A.6 RES low between two cen: no reset (fetch 0406)");
    en_run = 1'b0;
    #50;
    rst_n = 1'b0;
    irq_n = 1'b0;
    nmi_n = 1'b0;
    rdy = 1'b0;
    #100;
    rst_n = 1'b1;
    irq_n = 1'b1;
    nmi_n = 1'b1;
    rdy = 1'b1;
    #50;
    en_run = 1'b1;
    base = tr_n;
    cycles(12);
    tmp32 = 0;
    for(j = 0; j < 12; j = j + 1)
        if((ra_u(base + j) & 41'h0_00_00_00FFF0) === 41'h0_00_00_00FFF0)
            tmp32 = tmp32 + 1;
    check(tmp32, 0, "A.6 RES, IRQ, NMI and RDY pulses while the enables are stopped: no reset, no entry");
    errs = 0;
    tmp16 = 16'h0000;
    for(j = 0; j < 12; j = j + 1)
        if(ra_u(base + j) & 41'h0_00_02_000000) begin
            if((tmp16 != 16'h0000) && (ra_u(base + j) & 41'h0_00_00_00FFFF) !== tmp16 + 16'd1)
                errs = errs + 1;
            tmp16 = ra_u(base + j);
        end
    check(errs, 0, "A.6 enables stopped: the NOP stream continues where it stopped");
    rst_n = 1'b0;
    wait_cen();
    base = tr_n;
    rst_n = 1'b1;
    run_to_fetch(16'h0500, 0, 30);
    check(found && (fetch_cyc == 9), 1'b1, "A.6 RES low across exactly one cen: full reset, fetch at s+8");
    check(bus_is(base + 7, 16'hFFFC, 1'b1, 1'b0), 1'b1, "A.6 one-edge RES: FFFC read at s+6");
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // A.7 Writes: cycle r performs its write, cycle r+1 does not. STA 1234
    // (A = 5A), and INC 1234 (byte 41: read, read, write 42), RES held for
    // three edges from the edge that starts cycle n.
    //---------------------------------------------------------------------
    section("CPU SECTION A.7: Writes in the Cycle RES Falls");
    for(n = 3; n <= 4; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0600);
        org(16'h0400);
        pb3(8'h8D, 8'h34, 8'h12);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h5A, 8'h00, 8'h00);
        base = tr_n;
        cycles(n - 2);
        rst_n = 1'b0;
        cycles(3);
        rst_n = 1'b1;
        run_to_fetch(16'h0500, 0, 30);
        k = base + n - 1;
        if(n == 4) begin
            check(bus_is(k, 16'h1234, 1'b0, 1'b0) && (ra_u(k) & 41'h0_00_00_FF0000) === 41'h0_00_00_5A0000, 1'b1,
                  "A.7 STA, RES first low at its write cycle: the write of 5A happens");
            check(writes_in(k + 1, k + 9), 0, "A.7 STA: no write after cycle r");
        end else begin
            check(bus_is(k + 1, 16'h1234, 1'b1, 1'b0), 1'b1,
                  "A.7 STA, RES first low the cycle before: cycle r+1 reads 1234, no write");
            check(writes_in(k, k + 9), 0, "A.7 STA: no write from cycle r on");
        end
    end
    for(n = 4; n <= 6; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0600);
        put(16'h1234, 8'h41);
        org(16'h0400);
        pb3(8'hEE, 8'h34, 8'h12);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        cycles(n - 2);
        rst_n = 1'b0;
        cycles(3);
        rst_n = 1'b1;
        run_to_fetch(16'h0500, 0, 30);
        k = base + n - 1;
        case(n)
            4: begin
                check(writes_in(k, k + 9), 0, "A.7 INC, RES first low at the data read: no write");
                check(bus_is(k + 1, 16'h1234, 1'b1, 1'b0), 1'b1, "A.7 INC: cycle r+1 is the second read of 1234");
            end
            5: begin
                check(bus_is(k, 16'h1234, 1'b1, 1'b0) && bus_is(k + 1, 16'h1234, 1'b1, 1'b0), 1'b1,
                      "A.7 INC, RES first low at the second read: cycle r+1 (the write cycle) runs as a read");
                check(writes_in(k, k + 9), 0, "A.7 INC: the write of 42 does not happen");
            end
            default: begin
                check(bus_is(k, 16'h1234, 1'b0, 1'b0) && (ra_u(k) & 41'h0_00_00_FF0000) === 41'h0_00_00_420000, 1'b1,
                      "A.7 INC, RES first low at its write cycle: the write of 42 happens");
                check(writes_in(k + 1, k + 9), 0, "A.7 INC: no write after cycle r");
            end
        endcase
    end

    //---------------------------------------------------------------------
    // A.8 No timing exceptions. One-edge RES at the edge that starts cycle
    // 3 of a taken branch (BNE +10 at 0400, its last cycle): cycle r+1 is
    // the fetch address 0412 with SYNC = 0 and counts as s, s+1 (SYNC) and
    // s+2 hold 0412, FFFC at r+7. One-edge RES at the data read of INC
    // 1234: r+1 is the second read of 1234, s+1 at the held PC 0403 with
    // SYNC, no write.
    //---------------------------------------------------------------------
    section("CPU SECTION A.8: One-edge RES at a Branch and a Read-Modify-Write");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0600);
    org(16'h0400);
    pb2(8'hD0, 8'h10);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    cycles(1);
    rst_n = 1'b0;
    wait_cen();
    rst_n = 1'b1;
    run_to_fetch(16'h0500, 0, 30);
    k = base + 2;
    check(bus_is(k + 1, 16'h0412, 1'b1, 1'b0), 1'b1, "A.8 branch cut at cycle 3: r+1 shows the target 0412, SYNC = 0");
    check(bus_is(k + 2, 16'h0412, 1'b1, 1'b1) && bus_is(k + 3, 16'h0412, 1'b1, 1'b0), 1'b1,
          "A.8 branch: s+1 = r+2 with SYNC and s+2 hold 0412");
    check(bus_is(k + 4, 16'h01FF, 1'b1, 1'b0) && bus_is(k + 7, 16'hFFFC, 1'b1, 1'b0) &&
          bus_is(k + 8, 16'hFFFD, 1'b1, 1'b0) && now_is(16'h0500, 1'b1, 1'b1) && (tr_n == k + 9), 1'b1,
          "A.8 branch: stack reads from r+4, FFFC at r+7, fetch at the vector at r+9");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0600);
    put(16'h1234, 8'h41);
    org(16'h0400);
    pb3(8'hEE, 8'h34, 8'h12);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    cycles(2);
    rst_n = 1'b0;
    wait_cen();
    rst_n = 1'b1;
    run_to_fetch(16'h0500, 0, 30);
    k = base + 3;
    check(bus_is(k, 16'h1234, 1'b1, 1'b0) && bus_is(k + 1, 16'h1234, 1'b1, 1'b0), 1'b1,
          "A.8 INC cut at the data read: r+1 is the second read of 1234");
    check(bus_is(k + 2, 16'h0403, 1'b1, 1'b1) && bus_is(k + 3, 16'h0403, 1'b1, 1'b0), 1'b1,
          "A.8 INC: s+1 = r+2 at the held PC 0403 with SYNC, s+2 at 0403");
    check(bus_is(k + 7, 16'hFFFC, 1'b1, 1'b0) && now_is(16'h0500, 1'b1, 1'b1) && (tr_n == k + 9), 1'b1,
          "A.8 INC: FFFC at r+7, fetch at the vector at r+9");
    check(writes_in(k, k + 8), 0, "A.8 INC: no write");

    //---------------------------------------------------------------------
    // A.9 RES at every cycle: RES first low at the edge that starts cycle n
    // (2-11) of 30 instructions of every kind (the stream continues with
    // NOPs), for 1 and 3 edges. From cycle r+1 to the fetch at the vector:
    // no write, one SYNC (s+1, w+1 cycles after r), the held address from
    // r+2 to s+2, three page-1 stack reads counting down, FFFC, FFFD; then
    // I = 1 and D = 0.
    //---------------------------------------------------------------------
    section("CPU SECTION A.9: RES at Every Cycle of Every Instruction Kind");
    for(t = 0; t < SWN; t = t + 1) begin
        errs = 0;
        n = 0;
        for(i = 2; i <= 11; i = i + 1)
            for(j = 1; j <= 3; j = j + 2) begin
                sw_setup(t);
                base = tr_n;
                cycles(i - 2);
                rst_n = 1'b0;
                cycles(j);
                rst_n = 1'b1;
                run_to_fetch(16'h0500, 0, 40);
                k = base + i - 1;
                errs = errs + (found ? a9_check(k, tr_n, j) : 1);
                readout(16'h0500);
                if(!ro_ok || ((ro_p_u & 8'h0C) !== 8'h04))
                    errs = errs + 1;
                n = n + 1;
            end
        $sformat(nm, "A.9 RES in %0s at cycles 2-11, 1 and 3 edges (%0d runs): mismatches", sw_name, n);
        check_mm(errs, nm);
    end

    //---------------------------------------------------------------------
    // A.10 RES inside a running reset sequence: after a one-edge RES (S =
    // 80 before), a second one-edge RES at the edge that starts cycle s+k
    // (k = 1-8) of that sequence starts a new sequence; S drops by 3 for
    // the first sequence only when its third stack read (s+5) ended, so S
    // = 7A for k >= 5 and 7D otherwise.
    //---------------------------------------------------------------------
    section("CPU SECTION A.10: RES inside a Running Reset Sequence");
    for(n = 1; n <= 8; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0600);
        org(16'h0400);
        pb2(8'hA2, 8'h80);
        pb(8'h9A);
        pb3(8'h4C, 8'h03, 8'h04);
        boot_to(16'h0400);
        run_to_fetch(16'h0403, 0, 20);
        rst_n = 1'b0;
        wait_cen();
        rst_n = 1'b1;
        base = tr_n;
        cycles(n);
        rst_n = 1'b0;
        wait_cen();
        rst_n = 1'b1;
        // the fetch at the vector follows the FFFD read (the held PC of the new sequence may be 0500 too)
        fetch_cyc = 0;
        found = 1'b0;
        while(!found && (fetch_cyc < 30)) begin
            wait_cen();
            fetch_cyc = fetch_cyc + 1;
            found = now_is(16'h0500, 1'b1, 1'b1) && bus_is(tr_n - 1, 16'hFFFD, 1'b1, 1'b0);
        end
        tmp8 = (fetch_cyc == 9) && (writes_in(base, tr_n - 1) == 0) && bus_is(tr_n - 2, 16'hFFFC, 1'b1, 1'b0);
        readout(16'h0500);
        $sformat(nm, "A.10 second RES at s+%0d: new sequence (fetch 9 cycles later, no write), S = %h", n,
                 (n >= 5) ? 8'h7A : 8'h7D);
        check({tmp8[0], ro_s_u, ro_s_h, (ro_p_u & 8'h0C)}, {1'b1, (n >= 5) ? 8'h7A : 8'h7D,
              (n >= 5) ? 8'h7A : 8'h7D, 8'h04}, nm);
    end

    //---------------------------------------------------------------------
    // A.11 RES overrides RDY. RES low for 3 edges from the edge that starts
    // cycle 3 of a NOP stream, RDY low from the next edge for 4 or 5 edges:
    // r+1, the RES-low cycles and cycle s do not wait; s+1 (the SYNC
    // cycle) repeats while RDY is low (the fetch at the vector one cycle
    // later with 5 edges). STA 1234 with its write held by RDY and RES
    // first low at a held repeat: the held write completes, then no write.
    //---------------------------------------------------------------------
    section("CPU SECTION A.11: RDY during the RES Protocol");
    for(n = 0; n < 3; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0600);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        cycles(1);
        rst_n = 1'b0;
        wait_cen();
        if(n > 0)
            rdy = 1'b0;
        cycles(2);
        rst_n = 1'b1;
        cycles((n == 2) ? 3 : 2);
        rdy = 1'b1;
        run_to_fetch(16'h0500, 0, 30);
        k = base + 2;
        tmp32 = (n == 2) ? 1 : 0;
        $sformat(nm, "A.11 RES 3 edges, RDY low %0d edges after r: s+1 at r+4%0s, fetch at the vector at r+%0d",
                 (n == 0) ? 0 : (n == 1) ? 4 : 5, (n == 2) ? " held once" : "", 11 + tmp32);
        check(bus_rs(k + 4, 1'b1, 1'b1) && ((n != 2) || bus_rs(k + 5, 1'b1, 1'b1)) &&
              bus_is(k + 9 + tmp32, 16'hFFFC, 1'b1, 1'b0) && now_is(16'h0500, 1'b1, 1'b1) && (tr_n == k + 11 + tmp32) &&
              (writes_in(k, k + 10 + tmp32) == 0), 1'b1, nm);
    end
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0600);
    org(16'h0400);
    pb3(8'h8D, 8'h34, 8'h12);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h5A, 8'h00, 8'h00);
    base = tr_n;
    cycles(3);
    rdy = 1'b0;
    cycles(2);
    rst_n = 1'b0;
    wait_cen();
    rst_n = 1'b1;
    cycles(3);
    rdy = 1'b1;
    run_to_fetch(16'h0500, 0, 30);
    k = base + 3;
    check(bus_is(k, 16'h1234, 1'b0, 1'b0) && bus_is(k + 1, 16'h1234, 1'b0, 1'b0) && bus_is(k + 2, 16'h1234, 1'b0, 1'b0) &&
          bus_is(k + 3, 16'h1234, 1'b0, 1'b0) && (writes_in(k + 4, k + 14) == 0) && (mem_u[16'h1234] === 8'h5A), 1'b1,
          "A.11 STA held by RDY, RES first low at a held repeat: the held write completes (5A at 1234), then no write");
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // BUS SECTION B: Bus Cycles per Addressing Mode
    // Every opcode from the instruction vectors (page cross or not; branch
    // not taken, taken, crossing; decimal or binary): address, R/W, data
    // and SYNC of every cycle, vp_n, and the results. Then the data bus
    // drive window of a write and of a read-modify-write. [p.1-10],
    // [p.1-11]
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" BUS SECTION B: Bus Cycles per Addressing Mode");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;

    section("BUS SECTION B.1: Every Opcode (instruction vectors)");
    tb_ratio = 4;
    vec_clear_counts();
    info_left = 6;
    vec_run(1, 100000);
    vec_report("B.1 instruction vectors, ratio 4");

    section("BUS SECTION B.2: Addressing Mode Groups");
    for(k = 1; k <= 15; k = k + 1) begin
        n = 0;
        t = 0;
        errs = 0;
        for(j = 0; j < 256; j = j + 1)
            if(op_grp[j] == k) begin
                n = n + 1;
                t = t + op_n[j];
                errs = errs + op_mm[j] + ((op_n[j] == 0) ? 1 : 0);
            end
        $sformat(nm, "B.2 %0s: %0d opcodes, %0d tests: mismatches", grp_name[k], n, t);
        check_mm(errs, nm);
    end

    //---------------------------------------------------------------------
    // B.3 Data bus window of one write (STA 1234, A = 5A) and of a
    // read-modify-write (INC 1235 on 41: two reads of 41, then the write
    // of 42) [p.1-10].
    //---------------------------------------------------------------------
    section("BUS SECTION B.3: Data Bus Drive Window");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0600);
    put(16'h1235, 8'h41);
    org(16'h0400);
    pb3(8'h8D, 8'h34, 8'h12);
    pb3(8'hEE, 8'h35, 8'h12);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h5A, 8'h00, 8'h00);
    base = tr_n;
    run_to_fetch(16'h0406, 0, 20);
    check((ra_u(base + 3) & 41'h1_FF_3F_FFFFFF) === {1'b0, 8'h5A, 8'b00111100, 8'h5A, 16'h1234}, 1'b1,
          "B.3 STA 1234 uut: R/W = 0, dout 5A in both halves, dout_oe = 1 in both halves");
    check((ra_h(base + 3) & 41'h1_FF_3F_FFFFFF) === {1'b0, 8'h5A, 8'b00011100, 8'h5A, 16'h1234}, 1'b1,
          "B.3 STA 1234 uuth: dout 5A in both halves, dout_oe = 0 in phi1, 1 in phi2");
    check((ra_u(base + 2) & 41'h0_00_24_000000) === 41'h0, 1'b1, "B.3 STA cycle 3 (read): dout_oe = 0 (uut)");
    check((ra_h(base + 2) & 41'h0_00_24_000000) === 41'h0, 1'b1, "B.3 STA cycle 3 (read): dout_oe = 0 (uuth)");
    run_to_fetch(16'h0409, 0, 20);
    check(({ra_u(base + 7), ra_u(base + 8)} & {41'h0_00_3F_FFFFFF, 41'h0_00_3F_FFFFFF}) ===
          {9'h0, 8'b00011001, 8'h41, 16'h1235, 9'h0, 8'b00011001, 8'h41, 16'h1235}, 1'b1,
          "B.3 INC 1235: reads 41 twice, no data bus drive, uut");
    check((ra_u(base + 9) & 41'h0_00_3F_FFFFFF) === {9'h0, 8'b00111100, 8'h42, 16'h1235}, 1'b1,
          "B.3 INC 1235: then writes 42 once, dout_oe = 1, uut");
    check(({ra_h(base + 7), ra_h(base + 8), ra_h(base + 9)} &
           {41'h0_00_3F_FFFFFF, 41'h0_00_3F_FFFFFF, 41'h0_00_3F_FFFFFF}) ===
          {9'h0, 8'b00011001, 8'h41, 16'h1235, 9'h0, 8'b00011001, 8'h41, 16'h1235,
           9'h0, 8'b00011100, 8'h42, 16'h1235}, 1'b1,
          "B.3 INC 1235: reads 41 twice, writes 42 with dout_oe in phi2 only, uuth");

    //---------------------------------------------------------------------
    // CPU SECTION C: All 256 Opcodes
    // Per opcode, the instruction vectors of B.1: every cycle and the
    // results (registers at the next fetch, memory). Then random streams
    // of defined instructions in both clock modes, compared cycle by
    // cycle, with registers read out through the bus at the end.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CPU SECTION C: All 256 Opcodes");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;

    section("CPU SECTION C.1: Opcodes 00-FF (instruction vectors of B.1)");
    for(j = 0; j < 256; j = j + 1) begin
        if(op_dec[j] > 0)
            $sformat(nm, "C.1 $%h %0s: %0d tests (%0d by decision): mismatches", j[7:0], op_name[j], op_n[j],
                     op_dec[j]);
        else
            $sformat(nm, "C.1 $%h %0s: %0d tests: mismatches", j[7:0], op_name[j], op_n[j]);
        check_mm(op_mm[j] + ((op_n[j] == 0) ? 1 : 0), nm);
    end

    //---------------------------------------------------------------------
    // C.2 Random streams: 16 images with random bytes in pages 00-01 and
    // 04-13 and every vector at 0400 (every byte is an R65C02 op code or a
    // NOP, so any stream runs), random registers, 1,500 cycles at ratio 4
    // and 3. Both CPUs must agree on every pin and on dbg_* at every
    // cycle, and no output may be X.
    //---------------------------------------------------------------------
    section("CPU SECTION C.2: Random Instruction Streams (CYCLE and HALF lockstep)");
    errs = 0;
    errs2 = 0;
    n = 0;
    for(t = 0; t < 16; t = t + 1) begin
        tb_ratio = (t < 8) ? 4 : 3;
        mem_new(8'hEA);
        for(j = 0; j < 16'h1400; j = j + 1)
            if((j < 16'h0200) || (j >= 16'h0400))
                put(j, $random(seed));
        vectors(16'h0400, 16'h0400, 16'h0400);
        start_at(16'h0400, 16'h0200, 8'hFF, $random(seed) & 8'hCB, $random(seed), $random(seed), $random(seed));
        base = tr_n;
        cycles(1500);
        for(j = base; j < tr_n; j = j + 1) begin
            if((ra_u(j) & 41'h1_00_0F_FFFFFF) !== (ra_h(j) & 41'h1_00_0F_FFFFFF))
                errs = errs + 1;
            if(rad_u(j) !== rad_h(j))
                errs2 = errs2 + 1;
            n = n + 1;
        end
    end
    $sformat(nm, "C.2 16 random streams (%0d cycles): cycles where uut and uuth pins differ or an output is X", n);
    check_mm(errs, nm);
    check_mm(errs2, "C.2 16 random streams: cycles where uut and uuth dbg_* differ");
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // ALU SECTION D: Arithmetic and Logic
    // D.1 drives x65c02_alu directly over every operand pair and carry in,
    // D = 0 and 1 for ADC and SBC; D.2 runs decimal ADC # and SBC # through
    // the CPU over every A x operand x C (131,072 cases each) and checks
    // the stored A and the pushed P. [p.1-10], [p.1-12]
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" ALU SECTION D: Arithmetic and Logic");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;

    section("ALU SECTION D.1: Every Operation, Every Input");
    for(k = 0; k < 16; k = k + 1) begin
        case(k)
            0: alu_op = ALU_OR;
            1: alu_op = ALU_AND;
            2: alu_op = ALU_EOR;
            3: alu_op = ALU_ADC;
            4: alu_op = ALU_SBC;
            5: alu_op = ALU_CMP;
            6: alu_op = ALU_BIT;
            7: alu_op = ALU_ASL;
            8: alu_op = ALU_ROL;
            9: alu_op = ALU_LSR;
            10: alu_op = ALU_ROR;
            11: alu_op = ALU_INC;
            12: alu_op = ALU_DEC;
            13: alu_op = ALU_BIM;
            14: alu_op = ALU_TSB;
            default: alu_op = ALU_TRB;
        endcase
        errs = 0;
        n = 0;
        for(i = 0; i < 256; i = i + 1)
            for(j = 0; j < (((k >= 7) && (k <= 12)) ? 1 : 256); j = j + 1)
                for(t = 0; t < ((k == 3) || (k == 4) || (k == 5) ? 4 : 2); t = t + 1) begin
                    alu_a = i;
                    alu_b = ((k >= 7) && (k <= 12)) ? $random(seed) : j;
                    tmp8 = $random(seed);
                    alu_pin = {tmp8[7:6], 2'b11, (k >= 3) && (k <= 5) ? t[1] : tmp8[3], tmp8[2:1], t[0]};
                    #1;
                    // expected {q, N, V, Z, C}; tmp32[12] = q compared
                    case(k)
                        0: tmp16 = {alu_a | alu_b, 8'h00};
                        1: tmp16 = {alu_a & alu_b, 8'h00};
                        2: tmp16 = {alu_a ^ alu_b, 8'h00};
                        default: tmp16 = 16'h0000;
                    endcase
                    if(k <= 2) begin
                        tmp32 = {19'h0, 1'b1, tmp16[15:8], tmp16[15], alu_pin[6], tmp16[15:8] == 8'h00, alu_pin[0]};
                    end else if(k == 3) begin
                        tmp16 = ref_adc(alu_a, alu_b, alu_pin[0], alu_pin[3]);
                        tmp32 = {19'h0, 1'b1, tmp16[11:0]};
                    end else if(k == 4) begin
                        tmp16 = ref_sbc(alu_a, alu_b, alu_pin[0], alu_pin[3]);
                        tmp32 = {19'h0, 1'b1, tmp16[11:0]};
                    end else if(k == 5) begin
                        tmp16 = ref_adc(alu_a, ~alu_b, 1'b1, 1'b0);
                        tmp32 = {19'h0, 1'b0, tmp16[11:4], tmp16[3], alu_pin[6], tmp16[1], tmp16[0]};
                    end else if(k == 6) begin
                        tmp32 = {19'h0, 1'b0, 8'h00, alu_b[7], alu_b[6], (alu_a & alu_b) == 8'h00, alu_pin[0]};
                    end else if(k == 13) begin
                        tmp32 = {19'h0, 1'b0, 8'h00, alu_pin[7], alu_pin[6], (alu_a & alu_b) == 8'h00, alu_pin[0]};
                    end else if(k == 14) begin
                        tmp32 = {19'h0, 1'b1, alu_a | alu_b, alu_pin[7], alu_pin[6], (alu_a & alu_b) == 8'h00,
                                 alu_pin[0]};
                    end else if(k == 15) begin
                        tmp32 = {19'h0, 1'b1, ~alu_a & alu_b, alu_pin[7], alu_pin[6], (alu_a & alu_b) == 8'h00,
                                 alu_pin[0]};
                    end else begin
                        case(k)
                            7: tmp16 = {alu_a[6:0], 1'b0, 7'h0, alu_a[7]};
                            8: tmp16 = {alu_a[6:0], alu_pin[0], 7'h0, alu_a[7]};
                            9: tmp16 = {1'b0, alu_a[7:1], 7'h0, alu_a[0]};
                            10: tmp16 = {alu_pin[0], alu_a[7:1], 7'h0, alu_a[0]};
                            11: tmp16 = {alu_a + 8'd1, 7'h0, alu_pin[0]};
                            default: tmp16 = {alu_a - 8'd1, 7'h0, alu_pin[0]};
                        endcase
                        tmp32 = {19'h0, 1'b1, tmp16[15:8], tmp16[15], alu_pin[6], tmp16[15:8] == 8'h00, tmp16[0]};
                    end
                    n = n + 1;
                    if((tmp32[12] && (alu_q !== tmp32[11:4])) ||
                       ({alu_pout[7:6], alu_pout[3:0]} !== {tmp32[3:2], alu_pin[3:2], tmp32[1:0]})) begin
                        errs = errs + 1;
                        if(errs <= 2)
                            $display("INFO: D.1 op %h a %h b %h p_in %h: q %h p_out %h, expected q %h NVZC %b",
                                     alu_op, alu_a, alu_b, alu_pin, alu_q, alu_pout, tmp32[11:4], tmp32[3:0]);
                    end
                end
        case(k)
            0: $sformat(nm, "D.1 ORA: q = a OR b, N Z; V D I C kept (%0d inputs): mismatches", n);
            1: $sformat(nm, "D.1 AND: q = a AND b, N Z (%0d inputs): mismatches", n);
            2: $sformat(nm, "D.1 EOR: q = a XOR b, N Z (%0d inputs): mismatches", n);
            3: $sformat(nm, "D.1 ADC: binary and decimal, N V Z C (%0d inputs): mismatches", n);
            4: $sformat(nm, "D.1 SBC: binary and decimal, N V Z C (%0d inputs): mismatches", n);
            5: $sformat(nm, "D.1 CMP: C = a >= b, N Z of a - b, D ignored (%0d inputs): mismatches", n);
            6: $sformat(nm, "D.1 BIT: N = b7, V = b6, Z = (a AND b) = 0 (%0d inputs): mismatches", n);
            7: $sformat(nm, "D.1 ASL (%0d inputs): mismatches", n);
            8: $sformat(nm, "D.1 ROL (%0d inputs): mismatches", n);
            9: $sformat(nm, "D.1 LSR (%0d inputs): mismatches", n);
            10: $sformat(nm, "D.1 ROR (%0d inputs): mismatches", n);
            11: $sformat(nm, "D.1 INC (%0d inputs): mismatches", n);
            12: $sformat(nm, "D.1 DEC (%0d inputs): mismatches", n);
            13: $sformat(nm, "D.1 BIT #: Z = (a AND b) = 0 only (%0d inputs): mismatches", n);
            14: $sformat(nm, "D.1 TSB: q = a OR b, Z = (a AND b) = 0 only (%0d inputs): mismatches", n);
            default: $sformat(nm, "D.1 TRB: q = NOT a AND b, Z = (a AND b) = 0 only (%0d inputs): mismatches", n);
        endcase
        check_mm(errs, nm);
    end
    // a few named decimal points
    alu_op = ALU_ADC;
    alu_a = 8'h99; alu_b = 8'h01; alu_pin = 8'h38; #1;
    check({alu_q, alu_pout[7:6], alu_pout[1:0]}, {8'h00, 4'b0011}, "D.1 ADC D=1 99 + 01: 00, N V Z C = 0 0 1 1 (Z of the result)");
    alu_a = 8'h80; alu_b = 8'h80; alu_pin = 8'h38; #1;
    check({alu_q, alu_pout[7:6], alu_pout[1:0]}, {8'h60, 4'b0101}, "D.1 ADC D=1 80 + 80: 60, V = 1, Z = 0, C = 1");
    alu_op = ALU_SBC;
    alu_a = 8'h00; alu_b = 8'h01; alu_pin = 8'h39; #1;
    check({alu_q, alu_pout[7:6], alu_pout[1:0]}, {8'h99, 4'b1000}, "D.1 SBC D=1 00 - 01: 99, N = 1, C = 0");
    alu_a = 8'h00; alu_b = 8'h0B; alu_pin = 8'h39; #1;
    check({alu_q, alu_pout[7:6], alu_pout[1:0]}, {8'h8F, 4'b1000}, "D.1 SBC D=1 00 - 0B (invalid BCD): 8F, N = 1, C = 0");

    //---------------------------------------------------------------------
    // D.2 Decimal mode through the CPU, ratio 1 (uut). The program at 0400
    // loops C, A and the operand, sets C with LSR, runs ADC # or SBC # with
    // D = 1 (the operand stored into the instruction), stores A to F000 and
    // pushes P.
    //---------------------------------------------------------------------
    section("ALU SECTION D.2: Decimal Mode through the CPU, Every Input");
    tb_ratio = 1;
    for(k = 0; k < 2; k = k + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0600);
        org(16'h0400);
        pb(8'hF8);
        pb2(8'hA9, 8'h00);
        pb2(8'h85, 8'h12);
        pb2(8'hA9, 8'h00);
        pb2(8'h85, 8'h11);
        pb2(8'hA9, 8'h00);
        pb2(8'h85, 8'h10);
        pb2(8'hA5, 8'h10);
        pb3(8'h8D, 8'h18, 8'h04);
        pb2(8'hA5, 8'h12);
        pb(8'h4A);
        pb2(8'hA5, 8'h11);
        if(k == 0)
            pb2(8'h69, 8'h00);
        else
            pb2(8'hE9, 8'h00);
        pb3(8'h8D, 8'h00, 8'hF0);
        pb(8'h08);
        pb(8'h68);
        pb2(8'hE6, 8'h10);
        pb2(8'hD0, 8'hEB);
        pb2(8'hE6, 8'h11);
        pb2(8'hD0, 8'hE3);
        pb2(8'hE6, 8'h12);
        pb2(8'hA5, 8'h12);
        pb2(8'hC9, 8'h02);
        pb2(8'hD0, 8'hD7);
        pb3(8'h4C, 8'h2E, 8'h04);
        dec_kind = k;
        dec_case = 0;
        dec_mm = 0;
        dec_have_a = 1'b0;
        boot_to(16'h0400);
        dec_on = 1'b1;
        guard = 0;
        while((dec_case < 131072) && (guard < 700)) begin
            #100000;
            guard = guard + 1;
        end
        dec_on = 1'b0;
        $sformat(nm, "D.2 %0s # with D = 1: cases run", (k == 0) ? "ADC" : "SBC");
        check(dec_case, 131072, nm);
        $sformat(nm, "D.2 %0s # with D = 1: A and N V Z C mismatches", (k == 0) ? "ADC" : "SBC");
        check_mm(dec_mm, nm);
    end
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // CPU SECTION E: R65C02 Bus and Instructions
    // Read-modify-write as two reads and one write, the extra cycles of
    // indexed modes, the decimal cycle, JMP (abs) across a page and JMP
    // (abs,X), BBR and BBS, BRA, the 46 undefined NOPs, shift abs,X in 6
    // cycles without a page cross, and the flags of BIT #,
    // TSB, TRB, RMB, SMB and STZ. Cycle by cycle on both CPUs. [p.1-10],
    // [p.1-11], [p.1-12]
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CPU SECTION E: R65C02 Bus and Instructions");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    tb_ratio = 4;
    info_left = 6;

    //---------------------------------------------------------------------
    // E.1 Read-modify-write: the operand is read twice at its address, then
    // the result is written once (no write of the unmodified byte).
    // 1234 = 41, 0020 = 0F, A = 5A, X = 01.
    //---------------------------------------------------------------------
    section("CPU SECTION E.1: Read-Modify-Write, Two Reads and One Write");
    for(n = 0; n < 8; n = n + 1) begin
        sw_mem();
        org(16'h0400);
        ex_clear();
        ex_r(16'h0400);
        ex_r(16'h0401);
        case(n)
            0: begin
                pb3(8'hEE, 8'h34, 8'h12);
                ex_r(16'h0402); ex_rd(16'h1234, 8'h41); ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h42);
                nm = "E.1 INC 1234 (41): 0400 0401 0402, reads 41 twice, writes 42";
            end
            1: begin
                pb2(8'hC6, 8'h20);
                ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_wr(16'h0020, 8'h0E);
                nm = "E.1 DEC 20 (0F): reads 0F twice, writes 0E";
            end
            2: begin
                pb2(8'h16, 8'h1F);
                ex_rd(16'h0401, 8'h1F); ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_wr(16'h0020, 8'h1E);
                nm = "E.1 ASL 1F,X (X = 1): PC+1 again, reads 0F twice at 0020, writes 1E";
            end
            3: begin
                pb3(8'h7E, 8'h33, 8'h12);
                ex_r(16'h0402); ex_rd(16'h1234, 8'h41); ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h20);
                nm = "E.1 ROR 1233,X (X = 1, C = 0, no page cross): 6 cycles, reads 41 twice, writes 20";
            end
            4: begin
                pb3(8'h0C, 8'h34, 8'h12);
                ex_r(16'h0402); ex_rd(16'h1234, 8'h41); ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h5B);
                nm = "E.1 TSB 1234 (A = 5A): reads 41 twice, writes 5B";
            end
            5: begin
                pb2(8'h14, 8'h20);
                ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_wr(16'h0020, 8'h05);
                nm = "E.1 TRB 20 (A = 5A): reads 0F twice, writes 05";
            end
            6: begin
                pb2(8'h37, 8'h20);
                ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_wr(16'h0020, 8'h07);
                nm = "E.1 RMB3 20: reads 0F twice, writes 07";
            end
            default: begin
                pb2(8'hD7, 8'h20);
                ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_wr(16'h0020, 8'h2F);
                nm = "E.1 SMB5 20: reads 0F twice, writes 2F";
            end
        endcase
        ex_go(16'h0400, 8'h04, 8'h5A, 8'h01, 8'h01);
        check_mm(ex_check(0), nm);
    end

    //---------------------------------------------------------------------
    // E.2 Extra cycles of indexed modes: a page cross of abs,X / abs,Y
    // reads PC+2 again [p.1-10], of (zp),Y reads zp+1 again; stores and
    // INC / DEC abs,X without a cross read the effective address first;
    // ASL ROL LSR ROR abs,X without a cross take 6 cycles. 0030/0031 =
    // pointer 12F0.
    //---------------------------------------------------------------------
    section("CPU SECTION E.2: Extra Cycles of Indexed Modes");
    for(n = 0; n < 13; n = n + 1) begin
        sw_mem();
        put16(16'h0030, 16'h12F0);
        org(16'h0400);
        ex_clear();
        ex_r(16'h0400);
        ex_r(16'h0401);
        case(n)
            0: begin
                pb3(8'hBD, 8'hF0, 8'h12); ex_r(16'h0402); ex_r(16'h0402); ex_r(16'h1310);
                tmp8 = 8'h20; nm = "E.2 LDA 12F0,X (X = 20, cross): 0402 again, then 1310";
            end
            1: begin
                pb3(8'hBD, 8'h30, 8'h12); ex_r(16'h0402); ex_r(16'h1234);
                tmp8 = 8'h04; nm = "E.2 LDA 1230,X (X = 04, no cross): 4 cycles";
            end
            2: begin
                pb3(8'h9D, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h5A);
                tmp8 = 8'h04; nm = "E.2 STA 1230,X (no cross): reads 1234, then writes it";
            end
            3: begin
                pb3(8'h99, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h5A);
                tmp8 = 8'h04; nm = "E.2 STA 1230,Y (no cross): reads 1234, then writes it";
            end
            4: begin
                pb3(8'h9E, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h00);
                tmp8 = 8'h04; nm = "E.2 STZ 1230,X (no cross): reads 1234, then writes 00 to it";
            end
            5: begin
                pb2(8'hB1, 8'h30); ex_r(16'h0030); ex_r(16'h0031); ex_rd(16'h0031, 8'h12); ex_r(16'h1310);
                tmp8 = 8'h20; nm = "E.2 LDA (30),Y (Y = 20, cross): 0031 again, then 1310";
            end
            6: begin
                pb2(8'h91, 8'h30); ex_r(16'h0030); ex_r(16'h0031); ex_rd(16'h0031, 8'h12); ex_wr(16'h12F4, 8'h5A);
                tmp8 = 8'h04; nm = "E.2 STA (30),Y (Y = 04, no cross): 0031 again, write 12F4";
            end
            7: begin
                pb3(8'hDE, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41); ex_rd(16'h1234, 8'h41);
                ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h40);
                tmp8 = 8'h04; nm = "E.2 DEC 1230,X (no cross): 7 cycles, 1234 read three times";
            end
            8: begin
                pb3(8'h1E, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41);
                ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h82);
                tmp8 = 8'h04; nm = "E.2 ASL 1230,X (no cross): 6 cycles";
            end
            9: begin
                pb3(8'h3E, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41);
                ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h82);
                tmp8 = 8'h04; nm = "E.2 ROL 1230,X (no cross, C = 0): 6 cycles";
            end
            10: begin
                pb3(8'h5E, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41);
                ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h20);
                tmp8 = 8'h04; nm = "E.2 LSR 1230,X (no cross): 6 cycles";
            end
            11: begin
                pb3(8'h7E, 8'h30, 8'h12); ex_r(16'h0402); ex_rd(16'h1234, 8'h41);
                ex_rd(16'h1234, 8'h41); ex_wr(16'h1234, 8'h20);
                tmp8 = 8'h04; nm = "E.2 ROR 1230,X (no cross, C = 0): 6 cycles";
            end
            default: begin
                pb3(8'h3C, 8'hF0, 8'h12); ex_r(16'h0402); ex_r(16'h0402); ex_r(16'h1310);
                tmp8 = 8'h20; nm = "E.2 BIT 12F0,X (X = 20, cross): 0402 again, then 1310";
            end
        endcase
        ex_go(16'h0400, 8'h04, 8'h5A, tmp8, tmp8);
        check_mm(ex_check(0), nm);
    end

    //---------------------------------------------------------------------
    // E.3 Decimal cycle: ADC and SBC with D = 1 add one cycle that reads
    // the next instruction's address, and the result is written at its
    // end [p.1-10], [p.1-11]. A = 05, C = 0; 0020 = 0F (not valid BCD),
    // 12F0 = 19, 1310 = 19; the next instruction is a NOP (EA).
    //---------------------------------------------------------------------
    section("CPU SECTION E.3: Decimal-Mode Cycle of ADC and SBC");
    for(n = 0; n < 7; n = n + 1) begin
        sw_mem();
        put16(16'h0030, 16'h12F0);
        put(16'h12F0, 8'h19);
        put(16'h1310, 8'h19);
        org(16'h0400);
        ex_clear();
        ex_r(16'h0400);
        ex_r(16'h0401);
        tmp8 = 8'h00;
        case(n)
            0: begin
                pb2(8'h69, 8'h19); ex_rd(16'h0402, 8'hEA);
                tmp8b = 8'h24; nm = "E.3 ADC #19 (D = 1): 0400 0401 0402, A = 24";
            end
            1: begin
                pb2(8'h69, 8'h19);
                tmp8b = 8'h1E; nm = "E.3 ADC #19 (D = 0): 2 cycles, A = 1E";
            end
            2: begin
                pb2(8'hE5, 8'h20); ex_rd(16'h0020, 8'h0F); ex_rd(16'h0402, 8'hEA);
                tmp8b = 8'h8F; nm = "E.3 SBC 20 (D = 1, 05 - 0F - 1, operand not BCD): then 0402, A = 8F";
            end
            3: begin
                pb2(8'h72, 8'h30); ex_r(16'h0030); ex_r(16'h0031); ex_rd(16'h12F0, 8'h19); ex_rd(16'h0402, 8'hEA);
                tmp8b = 8'h24; nm = "E.3 ADC (30) (D = 1): 12F0, then 0402, A = 24";
            end
            4: begin
                pb3(8'h7D, 8'hF0, 8'h12); ex_r(16'h0402); ex_r(16'h0402); ex_rd(16'h1310, 8'h19);
                ex_rd(16'h0403, 8'hEA);
                tmp8 = 8'h20; tmp8b = 8'h24; nm = "E.3 ADC 12F0,X (X = 20, cross, D = 1): 1310, then 0403, A = 24";
            end
            5: begin
                pb2(8'hE1, 8'h30); ex_rd(16'h0401, 8'h30); ex_r(16'h0030); ex_r(16'h0031); ex_rd(16'h12F0, 8'h19);
                ex_rd(16'h0402, 8'hEA);
                tmp8b = 8'h85; nm = "E.3 SBC (30,X) (X = 0, D = 1, 05 - 19 - 1): PC+1 again, 12F0, then 0402, A = 85";
            end
            default: begin
                pb2(8'hF1, 8'h30); ex_r(16'h0030); ex_r(16'h0031); ex_rd(16'h0031, 8'h12); ex_rd(16'h1310, 8'h19);
                ex_rd(16'h0402, 8'hEA);
                tmp8 = 8'h20; tmp8b = 8'h85; nm = "E.3 SBC (30),Y (Y = 20, cross, D = 1): 0031 again, 1310, then 0402";
            end
        endcase
        ex_go(16'h0400, (n == 1) ? 8'h04 : 8'h0C, 8'h05, tmp8, tmp8);
        check_mm(ex_check(0), nm);
        readout(ex_next);
        $sformat(nm, "E.3 case %0d: A = %h", n, tmp8b);
        check(ro_a_u, tmp8b, nm);
    end

    //---------------------------------------------------------------------
    // E.4 JMP (abs) and JMP (abs,X) read PC+2 again, then the pointer and
    // the carried pointer + 1 [p.1-10]: JMP (12FF) reads 12FF and 1300 (not
    // 1200); JMP (1230,X) reads 1234 and 1235; JMP (12FE,X) with X = 1
    // carries into 1300.
    //---------------------------------------------------------------------
    section("CPU SECTION E.4: JMP (abs) and JMP (abs,X)");
    for(n = 0; n < 3; n = n + 1) begin
        sw_mem();
        put(16'h12FF, 8'h34);
        put(16'h1200, 8'h99);
        put(16'h1300, 8'h05);
        put16(16'h1234, 16'h0600);
        org(16'h0400);
        ex_clear();
        ex_r(16'h0400);
        ex_r(16'h0401);
        ex_r(16'h0402);
        case(n)
            0: begin
                pb3(8'h6C, 8'hFF, 8'h12); ex_rd(16'h0402, 8'h12); ex_rd(16'h12FF, 8'h34); ex_rd(16'h1300, 8'h05);
                tmp16 = 16'h0534; tmp8 = 8'h00; nm = "E.4 JMP (12FF): 0402 again, 12FF, 1300; fetch 0534";
            end
            1: begin
                pb3(8'h7C, 8'h30, 8'h12); ex_rd(16'h0402, 8'h12); ex_rd(16'h1234, 8'h00); ex_rd(16'h1235, 8'h06);
                tmp16 = 16'h0600; tmp8 = 8'h04; nm = "E.4 JMP (1230,X) (X = 4): 0402 again, 1234, 1235; fetch 0600";
            end
            default: begin
                pb3(8'h7C, 8'hFE, 8'h12); ex_rd(16'h0402, 8'h12); ex_rd(16'h12FF, 8'h34); ex_rd(16'h1300, 8'h05);
                tmp16 = 16'h0534; tmp8 = 8'h01; nm = "E.4 JMP (12FE,X) (X = 1): 12FF, then 1300 (carried); fetch 0534";
            end
        endcase
        ex_go(16'h0400, 8'h04, 8'h00, tmp8, 8'h00);
        check_mm(ex_check(0) + ((ex_next !== tmp16) ? 1 : 0), nm);
    end

    //---------------------------------------------------------------------
    // E.5 BBR and BBS (0020 = 0F) and BRA: the zero-page byte is read
    // twice, then the offset; a taken branch reads PC+3, and PC+3 again on
    // a page cross. BRA as a taken branch, its page cross reading PC+2
    // again.
    //---------------------------------------------------------------------
    section("CPU SECTION E.5: BBR, BBS and BRA");
    for(n = 0; n < 6; n = n + 1) begin
        sw_mem();
        ex_clear();
        case(n)
            0: begin
                org(16'h0400); pb3(8'h0F, 8'h20, 8'h10);
                ex_r(16'h0400); ex_r(16'h0401); ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_r(16'h0402);
                tmp16 = 16'h0403; k = 16'h0400; nm = "E.5 BBR0 20 (bit 0 = 1): not taken, 5 cycles, fetch 0403";
            end
            1: begin
                org(16'h0400); pb3(8'h8F, 8'h20, 8'h10);
                ex_r(16'h0400); ex_r(16'h0401); ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_r(16'h0402);
                ex_r(16'h0403);
                tmp16 = 16'h0413; k = 16'h0400; nm = "E.5 BBS0 20 (bit 0 = 1): taken, 6 cycles, fetch 0413";
            end
            2: begin
                org(16'h04F0); pb3(8'hFF, 8'h20, 8'h20);
                ex_r(16'h04F0); ex_r(16'h04F1); ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_r(16'h04F2);
                tmp16 = 16'h04F3; k = 16'h04F0; nm = "E.5 BBS7 20 (bit 7 = 0): not taken, 5 cycles, fetch 04F3";
            end
            3: begin
                org(16'h04F0); pb3(8'h7F, 8'h20, 8'h20);
                ex_r(16'h04F0); ex_r(16'h04F1); ex_rd(16'h0020, 8'h0F); ex_rd(16'h0020, 8'h0F); ex_r(16'h04F2);
                ex_r(16'h04F3); ex_r(16'h04F3);
                tmp16 = 16'h0513; k = 16'h04F0; nm = "E.5 BBR7 20 (bit 7 = 0): taken across a page, PC+3 twice, fetch 0513";
            end
            4: begin
                org(16'h0400); pb2(8'h80, 8'h10);
                ex_r(16'h0400); ex_r(16'h0401); ex_r(16'h0402);
                tmp16 = 16'h0412; k = 16'h0400; nm = "E.5 BRA +10: 3 cycles, fetch 0412";
            end
            default: begin
                org(16'h04F0); pb2(8'h80, 8'h20);
                ex_r(16'h04F0); ex_r(16'h04F1); ex_r(16'h04F2); ex_r(16'h04F2);
                tmp16 = 16'h0512; k = 16'h04F0; nm = "E.5 BRA +20 across a page: 04F2 twice; fetch 0512";
            end
        endcase
        ex_go(k, 8'h04, 8'h00, 8'h00, 8'h00);
        check_mm(ex_check(0) + ((ex_next !== tmp16) ? 1 : 0) + writes_in(ex_base, tr_n - 1), nm);
    end

    //---------------------------------------------------------------------
    // E.6 The 46 undefined op codes are NOPs [p.1-10]: x3 and xB (DB
    // included, except CB) 1 byte, 1 cycle; CB 1 byte, 2 cycles; 02 22 42
    // 62 82 C2 E2 2 bytes, 2 cycles; 44 reads zp; 54 D4 F4 read PC+1 again
    // and zp+X; DC FC read PC+1, PC+2 and {AH, AL}; 5C reads PC+1, PC+2,
    // {FF, AL} and FFFF four times. Registers, flags and memory unchanged
    // (A = 5A, X = 01, Y = 02, P = C3).
    //---------------------------------------------------------------------
    section("CPU SECTION E.6: Undefined Op Codes");
    errs = 0;
    n = 0;
    for(j = 0; j < 256; j = j + 1)
        if(op_grp[j] == 15) begin
            sw_mem();
            org(16'h0400);
            pb3(j, 8'h20, 8'h12);
            ex_clear();
            ex_r(16'h0400);
            tmp16 = 16'h0401;
            if(j[1:0] == 2'b11) begin
                if(j == 8'hCB)
                    ex_r(16'h0401);
            end else if(j[3:0] == 4'h2) begin
                ex_r(16'h0401);
                tmp16 = 16'h0402;
            end else if(j == 8'h44) begin
                ex_r(16'h0401); ex_r(16'h0020);
                tmp16 = 16'h0402;
            end else if(j[3:0] == 4'h4) begin
                ex_r(16'h0401); ex_r(16'h0401); ex_r(16'h0021);
                tmp16 = 16'h0402;
            end else if(j == 8'h5C) begin
                ex_r(16'h0401); ex_r(16'h0402); ex_r(16'hFF20);
                ex_r(16'hFFFF); ex_r(16'hFFFF); ex_r(16'hFFFF); ex_r(16'hFFFF);
                tmp16 = 16'h0403;
            end else begin
                ex_r(16'h0401); ex_r(16'h0402); ex_r(16'h1220);
                tmp16 = 16'h0403;
            end
            ex_go(16'h0400, 8'hC3, 8'h5A, 8'h01, 8'h02);
            tmp32 = ex_check(0) + ((ex_next !== tmp16) ? 1 : 0) + writes_in(ex_base, tr_n - 1);
            readout(ex_next);
            if(!ro_ok || ({ro_a_u, ro_x_u, ro_y_u, ro_s_u, ro_p_u} !== {8'h5A, 8'h01, 8'h02, 8'hFF, 8'hF3}))
                tmp32 = tmp32 + 1;
            if(tmp32 != 0) begin
                errs = errs + 1;
                $display("INFO: E.6 op %h: %0d mismatches, next fetch %h (expected %h)", j[7:0], tmp32, ex_next, tmp16);
            end
            n = n + 1;
        end
    $sformat(nm, "E.6 %0d undefined op codes: bytes, cycles, bus and unchanged state: failing op codes", n);
    check_mm(errs + ((n != 46) ? 1 : 0), nm);

    //---------------------------------------------------------------------
    // E.7 Flags: BIT # changes only Z (note 6 [p.1-12]); TSB and TRB set Z
    // from A AND M only; RMB and SMB change no flag; STZ writes 00 in all
    // four modes.
    //---------------------------------------------------------------------
    section("CPU SECTION E.7: BIT #, TSB, TRB, RMB, SMB and STZ");
    for(n = 0; n < 9; n = n + 1) begin
        sw_mem();
        org(16'h0400);
        case(n)
            0: begin pb2(8'h89, 8'hF0); tmp8 = 8'hC4; tmp8b = 8'h0F; end
            1: begin pb2(8'h89, 8'h0F); tmp8 = 8'hC4; tmp8b = 8'h0F; end
            2: begin pb3(8'h0C, 8'h34, 8'h12); tmp8 = 8'h41; tmp8b = 8'hA0; end
            3: begin pb2(8'h14, 8'h20); tmp8 = 8'h43; tmp8b = 8'h0F; end
            4: begin pb2(8'h07, 8'h20); tmp8 = 8'h43; tmp8b = 8'h0F; end
            5: begin pb2(8'hF7, 8'h20); tmp8 = 8'h43; tmp8b = 8'h0F; end
            6: begin pb2(8'h64, 8'h20); tmp8 = 8'h04; tmp8b = 8'h0F; end
            7: begin pb2(8'h74, 8'h1F); tmp8 = 8'h04; tmp8b = 8'h0F; end
            default: begin pb3(8'h9C, 8'h34, 8'h12); tmp8 = 8'h04; tmp8b = 8'h0F; end
        endcase
        ex_go(16'h0400, tmp8, tmp8b, 8'h01, 8'h00);
        readout(ex_next);
        case(n)
            0: check(ro_p_u, 8'hF6, "E.7 BIT #F0 with A = 0F, N = V = 1 before: Z = 1, N and V unchanged");
            1: check(ro_p_u, 8'hF4, "E.7 BIT #0F with A = 0F: Z = 0, N and V unchanged");
            2: check({ro_p_u, mem_u[16'h1234]}, {8'h73, 8'hE1}, "E.7 TSB 1234 (41) with A = A0: Z = 1 (A AND M = 0), writes E1, V C kept");
            3: check({ro_p_u, mem_u[16'h0020]}, {8'h71, 8'h00}, "E.7 TRB 20 (0F) with A = 0F: Z = 0 (A AND M = 0F), writes 00, V C kept");
            4: check({ro_p_u, mem_u[16'h0020]}, {8'h73, 8'h0E}, "E.7 RMB0 20 (0F): writes 0E, no flag changed (Z stays 1)");
            5: check({ro_p_u, mem_u[16'h0020]}, {8'h73, 8'h8F}, "E.7 SMB7 20 (0F): writes 8F, no flag changed (N stays 0)");
            6: check(mem_u[16'h0020], 8'h00, "E.7 STZ 20 writes 00");
            7: check(mem_u[16'h0020], 8'h00, "E.7 STZ 1F,X (X = 1) writes 00 to 0020");
            default: check(mem_u[16'h1234], 8'h00, "E.7 STZ 1234 writes 00");
        endcase
    end

    //---------------------------------------------------------------------
    // INT SECTION F: Interrupts
    // Recognition at the edge that starts an instruction's last cycle
    // [p.1-4], the branch delay, I-flag timing of CLI, SEI, PLP and RTI,
    // the entry sequence with B, the pushed P and D cleared [p.1-10], no
    // takeover of BRK or of an entry (the interrupt follows the handler's
    // first instruction) [p.1-10], the NMI edge latch, NMI across RES, the
    // poll point of every kind of instruction, the 1-cycle NOP and the
    // decimal cycle.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" INT SECTION F: Interrupts");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // F.1 IRQ and NMI recognition after a NOP at 0400 (cycle 1 = fetch,
    // cycle 2 = last cycle). Low at the edge that starts cycle 2 (falling
    // in cycle 1, either phase): the entry replaces the fetch at 0401.
    // Falling in cycle 2: taken one instruction later (fetch at 0402).
    //---------------------------------------------------------------------
    section("INT SECTION F.1: Recognition at the Last Cycle");
    for(n = 0; n < 6; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        start_at(16'h0400, 16'h0200, 8'hFF, (n < 3) ? 8'h00 : 8'h04, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        case(n % 3)
            0: ;
            1: to_phi2();
            default: wait_cen();
        endcase
        if(n < 3)
            irq_n = 1'b0;
        else
            nmi_n = 1'b0;
        run_to_fetch((n < 3) ? 16'h0700 : 16'h0600, 1'b0, 30);
        irq_n = 1'b1;
        nmi_n = 1'b1;
        tmp16 = ((n % 3) == 2) ? 16'h0402 : 16'h0401;
        chk_entry(base + (((n % 3) == 2) ? 4 : 2), 1'b0, tmp16, tmp16, 8'hFF, (n < 3) ? 8'h20 : 8'h24,
                  (n < 3) ? 16'hFFFE : 16'hFFFA, (n < 3) ? 16'h0700 : 16'h0600);
        $sformat(nm, "F.1 %0s falling in %0s of the NOP: entry replaces the fetch at %h, pushes PC %h and P %h",
                 (n < 3) ? "IRQ" : "NMI", ((n % 3) == 0) ? "phi1 of cycle 1" : ((n % 3) == 1) ? "phi2 of cycle 1" :
                 "phi1 of cycle 2", tmp16, tmp16, (n < 3) ? 8'h20 : 8'h24);
        check(ent_ok, 1'b1, nm);
    end

    //---------------------------------------------------------------------
    // F.2 Branches are polled at the edge that starts cycle 2 (and cycle 4
    // when a taken branch crosses a page).
    //---------------------------------------------------------------------
    section("INT SECTION F.2: Branch Interrupt Delay");
    for(n = 0; n < 5; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        if(n <= 1) begin
            org(16'h0400);
            pb2(8'hD0, 8'h02);
            start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
        end else if(n == 2) begin
            org(16'h0400);
            pb2(8'hF0, 8'h02);
            start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
        end else begin
            org(16'h04F0);
            pb2(8'hD0, 8'h20);
            start_at(16'h04F0, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
        end
        base = tr_n;
        case(n)
            0, 2: irq_n = 1'b0;
            1: begin
                wait_cen();
                irq_n = 1'b0;
            end
            3: begin
                cycles(2);
                irq_n = 1'b0;
            end
            default: begin
                wait_cen();
                irq_n = 1'b0;
                wait_cen();
                irq_n = 1'b1;
            end
        endcase
        if(n == 4) begin
            cycles(12);
            check(reads_of(base, base + 13, 16'hFFFE), 0,
                  "F.2 taken branch across a page, IRQ low only at the edge that starts cycle 3: not taken");
        end else begin
            run_to_fetch(16'h0700, 1'b0, 30);
            irq_n = 1'b1;
            case(n)
                0: begin
                    chk_entry(base + 3, 1'b0, 16'h0404, 16'h0404, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
                    nm = "F.2 BNE taken (no cross), IRQ low at the edge that starts cycle 2: entry at the target 0404";
                end
                1: begin
                    chk_entry(base + 5, 1'b0, 16'h0405, 16'h0405, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
                    nm = "F.2 BNE taken (no cross), IRQ first low at cycle 3: one more instruction, entry at 0405";
                end
                2: begin
                    chk_entry(base + 2, 1'b0, 16'h0402, 16'h0402, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
                    nm = "F.2 BEQ not taken, IRQ low at the edge that starts cycle 2: entry at 0402";
                end
                default: begin
                    chk_entry(base + 4, 1'b0, 16'h0512, 16'h0512, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
                    nm = "F.2 BNE across a page, IRQ first low at cycle 4: entry at the target 0512";
                end
            endcase
            check(ent_ok, 1'b1, nm);
        end
    end

    //---------------------------------------------------------------------
    // F.3 I-flag timing with IRQ held low: CLI and PLP clearing I take
    // effect after the next instruction; SEI and PLP setting I still let
    // an IRQ low at their last cycle in (I = 1 pushed); RTI has no delay.
    //---------------------------------------------------------------------
    section("INT SECTION F.3: CLI, SEI, PLP and RTI Latency");
    for(n = 0; n < 5; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0400);
        case(n)
            0: pb(8'h58);
            1: pb(8'h78);
            2, 3: pb(8'h28);
            default: pb(8'h40);
        endcase
        put(16'h01F1, (n == 3) ? 8'h04 : 8'h00);
        put(16'h01F2, 8'h00);
        put(16'h01F3, 8'h05);
        start_at(16'h0400, 16'h0200, 8'hF0, ((n == 1) || (n == 3)) ? 8'h00 : 8'h04, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        irq_n = 1'b0;
        run_to_fetch(16'h0700, 1'b0, 30);
        irq_n = 1'b1;
        case(n)
            0: begin
                chk_entry(base + 4, 1'b0, 16'h0402, 16'h0402, 8'hF0, 8'h20, 16'hFFFE, 16'h0700);
                nm = "F.3 CLI with IRQ held: the NOP after CLI runs, entry at 0402, pushed I = 0";
            end
            1: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hF0, 8'h24, 16'hFFFE, 16'h0700);
                nm = "F.3 SEI with IRQ low at its last cycle: entry at 0401, pushed I = 1";
            end
            2: begin
                chk_entry(base + 6, 1'b0, 16'h0402, 16'h0402, 8'hF1, 8'h20, 16'hFFFE, 16'h0700);
                nm = "F.3 PLP pulling I = 0 with IRQ held: the NOP after PLP runs, entry at 0402";
            end
            3: begin
                chk_entry(base + 4, 1'b0, 16'h0401, 16'h0401, 8'hF1, 8'h24, 16'hFFFE, 16'h0700);
                nm = "F.3 PLP pulling I = 1 with IRQ low at its last cycle: entry at 0401, pushed I = 1";
            end
            default: begin
                chk_entry(base + 6, 1'b0, 16'h0500, 16'h0500, 8'hF3, 8'h20, 16'hFFFE, 16'h0700);
                nm = "F.3 RTI restoring I = 0 with IRQ held: entry at the return address 0500, no delay";
            end
        endcase
        check(ent_ok, 1'b1, nm);
    end

    //---------------------------------------------------------------------
    // F.4 B bit, pushed P and D: BRK pushes P OR 30 and PC+2, IRQ and NMI
    // push (P AND EF) OR 20; the pushed P carries D as it was; in the
    // handler I = 1 and D = 0 [p.1-10].
    //---------------------------------------------------------------------
    section("INT SECTION F.4: Entry Sequence, B Bit, Pushed P and D Cleared");
    for(n = 0; n < 6; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0400);
        if(n <= 1)
            pb2(8'h00, 8'h5A);
        case(n)
            0: tmp8 = 8'hC3;
            1: tmp8 = 8'h08;
            2: tmp8 = 8'hC3;
            3: tmp8 = 8'hC7;
            4: tmp8 = 8'h0B;
            default: tmp8 = 8'h0C;
        endcase
        start_at(16'h0400, 16'h0200, 8'hFF, tmp8, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        if((n == 2) || (n == 4))
            irq_n = 1'b0;
        if((n == 3) || (n == 5))
            nmi_n = 1'b0;
        run_to_fetch(((n == 3) || (n == 5)) ? 16'h0600 : 16'h0700, 1'b0, 30);
        irq_n = 1'b1;
        nmi_n = 1'b1;
        tmp8b = dp_u;
        tmp32 = (dir_u === dir_h) && (dp_h === dp_u);
        case(n)
            0: begin
                chk_entry(base, 1'b1, 16'h0400, 16'h0402, 8'hFF, 8'hF3, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "F.4 BRK with P = C3: reads 0401, pushes PC+2 = 0402 and P OR 30 = F3, vector FFFE");
                check(tmp8b, 8'hF7, "F.4 BRK: dbg_p at the handler fetch = C3 with I = 1");
            end
            1: begin
                chk_entry(base, 1'b1, 16'h0400, 16'h0402, 8'hFF, 8'h38, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "F.4 BRK with D = 1: pushes 38 (D as it was)");
                check(tmp8b, 8'h34, "F.4 BRK with D = 1: D = 0 and I = 1 in the handler");
            end
            2: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'hE3, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "F.4 IRQ with P = C3: pushes E3 (bit 4 = 0, bit 5 = 1)");
            end
            3: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'hE7, 16'hFFFA, 16'h0600);
                check(ent_ok, 1'b1, "F.4 NMI with P = C7 (I = 1): pushes E7, vector FFFA");
            end
            4: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'h2B, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "F.4 IRQ with D = 1: pushes 2B");
                check(tmp8b, 8'h37, "F.4 IRQ with D = 1: D = 0 and I = 1 in the handler");
            end
            default: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'h2C, 16'hFFFA, 16'h0600);
                check(ent_ok, 1'b1, "F.4 NMI with D = 1: pushes 2C");
                check(tmp8b, 8'h34, "F.4 NMI with D = 1: D = 0 and I = 1 in the handler");
            end
        endcase
        check(tmp32[0], 1'b1, "F.4 uuth dbg_ir and dbg_p equal uut at the handler fetch");
    end

    //---------------------------------------------------------------------
    // F.5 No takeover: an NMI that arrives during BRK (cycle 4, 5, or only
    // at the edges of cycles 6 and 7) or during an IRQ entry leaves the
    // entry as it is (vector FFFE, B as pushed); the NMI is taken after the
    // handler's first instruction (a NOP at 0700) [p.1-10]. IRQ and NMI
    // together at the start: NMI vector, B = 0.
    //---------------------------------------------------------------------
    section("INT SECTION F.5: No Takeover of BRK or an Entry");
    for(n = 0; n < 6; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0400);
        if(n <= 2 || n == 5)
            pb2(8'h00, 8'h5A);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        case(n)
            0: begin
                cycles(3);
                nmi_n = 1'b0;
            end
            1: begin
                cycles(3);
                to_phi2();
                nmi_n = 1'b0;
            end
            2: begin
                cycles(4);
                nmi_n = 1'b0;
            end
            3: begin
                irq_n = 1'b0;
                cycles(5);
                nmi_n = 1'b0;
            end
            4: begin
                irq_n = 1'b0;
                nmi_n = 1'b0;
            end
            default: begin
                cycles(4);
                nmi_n = 1'b0;
                cycles(2);
                nmi_n = 1'b1;
            end
        endcase
        run_to_fetch(16'h0600, 1'b0, 40);
        irq_n = 1'b1;
        nmi_n = 1'b1;
        case(n)
            0, 1, 2, 5: begin
                chk_entry(base, 1'b1, 16'h0400, 16'h0402, 8'hFF, 8'h30, 16'hFFFE, 16'h0700);
                tmp32 = ent_ok;
                chk_entry(base + 9, 1'b0, 16'h0701, 16'h0701, 8'hFC, 8'h24, 16'hFFFA, 16'h0600);
                case(n)
                    0: nm = "F.5 NMI falling in phi1 of BRK cycle 4: BRK completes (FFFE, B = 1), handler NOP, NMI at 0701";
                    1: nm = "F.5 NMI falling in phi2 of BRK cycle 4: BRK completes, handler NOP, NMI at 0701";
                    2: nm = "F.5 NMI falling in BRK cycle 5: BRK completes, handler NOP, NMI at 0701";
                    default: nm = "F.5 NMI low only at the edges of BRK cycles 6 and 7: latched, taken at 0701 after the NOP";
                endcase
                check(tmp32[0] && ent_ok, 1'b1, nm);
            end
            3: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
                tmp32 = ent_ok;
                chk_entry(base + 11, 1'b0, 16'h0701, 16'h0701, 8'hFC, 8'h24, 16'hFFFA, 16'h0600);
                check(tmp32[0] && ent_ok, 1'b1,
                      "F.5 NMI falling in IRQ entry cycle 4: IRQ entry completes (FFFE), handler NOP, NMI at 0701");
            end
            default: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'h20, 16'hFFFA, 16'h0600);
                check(ent_ok, 1'b1, "F.5 IRQ and NMI together: NMI vector, B = 0");
            end
        endcase
    end

    //---------------------------------------------------------------------
    // F.6 NMI edge latch: a held NMI is taken once; high at one edge and low
    // again is a new edge; a second edge before the second vector read of
    // the NMI entry merges with the first. NMI falling while RES is low is
    // absorbed by the reset; NMI first low at the third stack read of the
    // reset sequence (s+5) is absorbed, at s+6 it is taken after the reset
    // handler's first instruction.
    //---------------------------------------------------------------------
    section("INT SECTION F.6: NMI Edge Latch and NMI across RES");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    nmi_n = 1'b0;
    cycles(40);
    check(reads_of(base, base + 39, 16'hFFFA), 1, "F.6 NMI held low for 40 cycles: one NMI entry");
    nmi_n = 1'b1;
    wait_cen();
    nmi_n = 1'b0;
    base = tr_n;
    cycles(20);
    nmi_n = 1'b1;
    check(reads_of(base, base + 19, 16'hFFFA), 1, "F.6 NMI high at one edge, then low: a second NMI entry");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    nmi_n = 1'b0;
    cycles(2);
    nmi_n = 1'b1;
    wait_cen();
    nmi_n = 1'b0;
    cycles(2);
    nmi_n = 1'b1;
    cycles(30);
    check(reads_of(base, base + 33, 16'hFFFA), 1,
          "F.6 second NMI edge inside the NMI entry (before its second vector read): merged, one entry");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    boot_to(16'h0400);
    rst_n = 1'b0;
    cycles(2);
    nmi_n = 1'b0;
    cycles(2);
    rst_n = 1'b1;
    run_to_fetch(16'h0500, 1'b0, 30);
    base = tr_n;
    cycles(30);
    nmi_n = 1'b1;
    check(found && (reads_of(base, base + 29, 16'hFFFA) == 0), 1'b1,
          "F.6 NMI falling while RES is low and held: absorbed by the reset, never taken");
    for(n = 0; n < 2; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        boot_to(16'h0400);
        cycles(3);
        rst_n = 1'b0;
        wait_cen();
        rst_n = 1'b1;
        base = tr_n;
        cycles(5 + n);
        nmi_n = 1'b0;
        cycles(30);
        nmi_n = 1'b1;
        if(n == 0)
            check(reads_of(base, base + 34, 16'hFFFA), 0,
                  "F.6 NMI first low at the start of the third stack read of the reset sequence: absorbed");
        else
            check(bus_is(base + 11, 16'h0501, 1'b1, 1'b1) && bus_is(base + 16, 16'hFFFA, 1'b1, 1'b0), 1'b1,
                  "F.6 NMI first low at the FFFC read: taken after the reset handler's first NOP (entry at 0501)");
    end

    //---------------------------------------------------------------------
    // F.7 Poll point of every kind of instruction: NMI held low from the
    // edge that starts cycle m + 1 (m = 1 .. L + 1) of 30 instructions. The
    // entry follows the instruction when NMI is low at its last poll edge
    // (the start of the last cycle; the decimal cycle of ADC; cycle 2 of a
    // branch and cycle 4 of a crossing one; the offset read of BBR and
    // BBS; the fetch of the 1-cycle NOP), else it follows the next NOP. BRK:
    // after the handler's first NOP.
    //---------------------------------------------------------------------
    section("INT SECTION F.7: Poll Point of Every Instruction Kind");
    for(t = 0; t < SWN; t = t + 1) begin
        errs = 0;
        sw_setup(t);
        n = sw_len;
        case(t)
            14, 16: j = 1;
            15: j = 3;
            17: j = 4;
            25: j = 0;
            default: j = n - 1;
        endcase
        for(i = 1; i <= ((t == 24) ? 8 : n + 1); i = i + 1) begin
            sw_setup(t);
            base = tr_n;
            cycles(i - 1);
            nmi_n = 1'b0;
            cycles(n + 16);
            k = -1;
            for(guard = base; (guard < tr_n) && (k < 0); guard = guard + 1)
                if((ra_u(guard) & 41'h0_00_01_00FFFF) === 41'h0_00_01_00FFFA)
                    k = guard - 5;
            nmi_n = 1'b1;
            cycles(2);
            if(t == 24)
                tmp32 = base + 9;
            else
                tmp32 = (i <= j) ? base + n : base + n + 2;
            if(k != tmp32) begin
                errs = errs + 1;
                if(info_left > 0) begin
                    info_left = info_left - 1;
                    $display("INFO: F.7 %0s, NMI from cycle %0d: entry at record +%0d, expected +%0d", sw_name, i + 1,
                             k - base, tmp32 - base);
                end
            end
        end
        $sformat(nm, "F.7 %0s (%0d cycles, last poll at the start of cycle %0d): mismatches", sw_name, n, j + 1);
        check_mm(errs, nm);
    end

    //---------------------------------------------------------------------
    // F.8 The 1-cycle NOP is polled at the edge that starts it: NOP; NOP
    // 03; NOP at 0400 with IRQ first low at the edge that starts the fetch
    // of 03: the entry replaces the fetch at 0402.
    //---------------------------------------------------------------------
    section("INT SECTION F.8: 1-cycle NOP Poll");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    put(16'h0401, 8'h03);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    wait_cen();
    irq_n = 1'b0;
    run_to_fetch(16'h0700, 1'b0, 30);
    irq_n = 1'b1;
    chk_entry(base + 3, 1'b0, 16'h0402, 16'h0402, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
    check(ent_ok, 1'b1, "F.8 IRQ first low at the start of the 1-cycle NOP: entry replaces the fetch right after it (0402)");

    //---------------------------------------------------------------------
    // BUS SECTION G: RDY
    // RDY low at the edge that ends a cycle repeats it, read or write
    // [p.1-4], [p.1-6]: the address, R/W, data, SYNC and dout_oe are held
    // and the byte of the last repeat is used; every held cycle shows its
    // own address; interrupts are recognized only with RDY high [p.1-4],
    // while NMI edges are still latched during a hold.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" BUS SECTION G: RDY");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    tb_ratio = 4;

    section("BUS SECTION G.1: Held Reads and Held Writes");
    // LDA 1234 held in cycle 4 for two repeats; the byte changes during the hold
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    put(16'h1234, 8'h11);
    org(16'h0400);
    pb3(8'hAD, 8'h34, 8'h12);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    cycles(3);
    rdy = 1'b0;
    wait_cen();
    put(16'h1234, 8'h22);
    wait_cen();
    put(16'h1234, 8'h33);
    rdy = 1'b1;
    run_to_fetch(16'h0403, 1'b0, 10);
    check(bus_is(base + 3, 16'h1234, 1'b1, 1'b0) && bus_is(base + 4, 16'h1234, 1'b1, 1'b0) &&
          bus_is(base + 5, 16'h1234, 1'b1, 1'b0) && now_is(16'h0403, 1'b1, 1'b1) && (tr_n == base + 6), 1'b1,
          "G.1 LDA 1234 held two cycles: cycle 4 repeats at 1234, next fetch at cycle 7");
    readout(16'h0403);
    check(ro_a_u, 8'h33, "G.1 LDA held: A = the byte of the last repeat (33)");
    check(ro_a_h, 8'h33, "G.1 LDA held: A = 33 (uuth)");
    // STA 1234 with RDY low at the end of its write cycle for two edges: the write repeats
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    org(16'h0400);
    pb3(8'h8D, 8'h34, 8'h12);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h5A, 8'h00, 8'h00);
    base = tr_n;
    cycles(3);
    rdy = 1'b0;
    cycles(2);
    rdy = 1'b1;
    run_to_fetch(16'h0403, 1'b0, 10);
    check(bus_is(base + 3, 16'h1234, 1'b0, 1'b0) && bus_is(base + 4, 16'h1234, 1'b0, 1'b0) &&
          bus_is(base + 5, 16'h1234, 1'b0, 1'b0) && (wbyte(base + 3) === 8'h5A) && (wbyte(base + 4) === 8'h5A) &&
          (wbyte(base + 5) === 8'h5A) && (tr_n == base + 6), 1'b1,
          "G.1 STA, RDY low at the end of its write cycle for two edges: the write of 5A to 1234 repeats twice");
    check(((ra_u(base + 4) & 41'h0_00_24_000000) === 41'h0_00_24_000000) &&
          ((ra_h(base + 4) & 41'h0_00_24_000000) === 41'h0_00_04_000000), 1'b1,
          "G.1 STA held: dout_oe = 1 through the held write (uut); phi2 only in each repeat (uuth)");
    // JSR with RDY low at the ends of its first write: the push of PCH repeats
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    org(16'h0400);
    pb3(8'h20, 8'h00, 8'h05);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    cycles(3);
    rdy = 1'b0;
    cycles(2);
    rdy = 1'b1;
    run_to_fetch(16'h0500, 1'b0, 12);
    check(bus_is(base + 3, 16'h01FF, 1'b0, 1'b0) && bus_is(base + 4, 16'h01FF, 1'b0, 1'b0) &&
          bus_is(base + 5, 16'h01FF, 1'b0, 1'b0) && bus_is(base + 6, 16'h01FE, 1'b0, 1'b0) &&
          bus_is(base + 7, 16'h0402, 1'b1, 1'b0) && now_is(16'h0500, 1'b1, 1'b1) && (tr_n == base + 8), 1'b1,
          "G.1 JSR, RDY low across two edges of its first push: 01FF written three times, fetch at 0500 in cycle 9");
    // RDY low at the end of an opcode fetch: the fetch repeats with SYNC
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    rdy = 1'b0;
    cycles(2);
    rdy = 1'b1;
    cycles(2);
    check(bus_is(base, 16'h0400, 1'b1, 1'b1) && bus_is(base + 1, 16'h0400, 1'b1, 1'b1) &&
          bus_is(base + 2, 16'h0400, 1'b1, 1'b1) && bus_is(base + 3, 16'h0401, 1'b1, 1'b0), 1'b1,
          "G.1 opcode fetch held two edges: repeats at 0400 with SYNC = 1 [p.1-6]");

    section("BUS SECTION G.2: Held Dummy Reads Repeat Their Own Address");
    for(n = 0; n < 3; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        case(n)
            0: begin
                org(16'h0400);
                pb3(8'hBD, 8'hF0, 8'h12);
                start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h20, 8'h00);
            end
            1: begin
                org(16'h04F0);
                pb2(8'hD0, 8'h20);
                start_at(16'h04F0, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
            end
            default: begin
                org(16'h0502);
                pb2(8'hD0, 8'hF0);
                start_at(16'h0502, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
            end
        endcase
        base = tr_n;
        cycles(3);
        rdy = 1'b0;
        cycles(2);
        rdy = 1'b1;
        run_to_fetch(16'h0000, 1'b1, 10);
        case(n)
            0: check(bus_is(base + 3, 16'h0402, 1'b1, 1'b0) && bus_is(base + 4, 16'h0402, 1'b1, 1'b0) &&
                     bus_is(base + 5, 16'h0402, 1'b1, 1'b0) && bus_is(base + 6, 16'h1310, 1'b1, 1'b0) &&
                     now_is(16'h0403, 1'b1, 1'b1) && (tr_n == base + 7), 1'b1,
                     "G.2 LDA 12F0,X (X = 20) held at the dummy read of 0402: repeats read 0402, then 1310");
            1: check(bus_is(base + 3, 16'h04F2, 1'b1, 1'b0) && bus_is(base + 4, 16'h04F2, 1'b1, 1'b0) &&
                     bus_is(base + 5, 16'h04F2, 1'b1, 1'b0) && now_is(16'h0512, 1'b1, 1'b1) && (tr_n == base + 6), 1'b1,
                     "G.2 BNE forward across a page held at the fixup (04F2 again): repeats read 04F2");
            default: check(bus_is(base + 3, 16'h0504, 1'b1, 1'b0) && bus_is(base + 4, 16'h0504, 1'b1, 1'b0) &&
                           bus_is(base + 5, 16'h0504, 1'b1, 1'b0) && now_is(16'h04F4, 1'b1, 1'b1) &&
                           (tr_n == base + 6), 1'b1,
                           "G.2 BNE backward across a page held at the fixup (0504 again): repeats read 0504");
        endcase
    end

    section("BUS SECTION G.3: Interrupts Only with RDY High");
    for(n = 0; n < 4; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        put(16'h1234, 8'h11);
        org(16'h0400);
        pb3(8'hAD, 8'h34, 8'h12);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        if(n == 3) begin
            cycles(2);
            rdy = 1'b0;
            irq_n = 1'b0;
            cycles(2);
            rdy = 1'b1;
            run_to_fetch(16'h0700, 1'b0, 20);
            irq_n = 1'b1;
        end else begin
            cycles((n == 0) ? 3 : 2);
            rdy = 1'b0;
            wait_cen();
            if(n == 2)
                nmi_n = 1'b0;
            else
                irq_n = 1'b0;
            wait_cen();
            irq_n = 1'b1;
            nmi_n = 1'b1;
            wait_cen();
            rdy = 1'b1;
            cycles(12);
        end
        case(n)
            0: check(reads_of(base, base + 18, 16'hFFFE), 0,
                     "G.3 IRQ low only at the edge of a held repeat of LDA's last cycle: not recognized [p.1-4]");
            1: check(bus_is(base + 6, 16'h1234, 1'b1, 1'b0) && bus_is(base + 7, 16'h0403, 1'b1, 1'b1) &&
                     bus_is(base + 8, 16'h0404, 1'b1, 1'b0) &&
                     (reads_of(base, base + 15, 16'hFFFE) == 0), 1'b1,
                     "G.3 IRQ low only during a hold of cycle 3: not recognized");
            2: begin
                chk_entry(base + 7, 1'b0, 16'h0403, 16'h0403, 8'hFF, 8'h20, 16'hFFFA, 16'h0600);
                check(ent_ok, 1'b1, "G.3 NMI falling and rising during a hold of cycle 3: latched, taken after LDA");
            end
            default: begin
                chk_entry(base + 6, 1'b0, 16'h0403, 16'h0403, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "G.3 IRQ low through a hold of cycle 3: recognized when RDY is high at the edge into cycle 4");
            end
        endcase
    end

    //---------------------------------------------------------------------
    // G.4 RDY sweep: every cycle of 30 instructions held 1 and 2 edges
    // against the run without RDY: the same cycles with the held one
    // repeated (address, R/W, data, SYNC), the same next fetch and the
    // same registers read out through the bus.
    //---------------------------------------------------------------------
    section("BUS SECTION G.4: Every Cycle of Every Instruction Kind Held");
    for(t = 0; t < SWN; t = t + 1) begin
        errs = 0;
        n = 0;
        sw_setup(t);
        base = tr_n;
        run_to_fetch(16'h0000, 1'b1, 40);
        j = tr_n - base;
        ref_capture(base, tr_n);
        tmp16 = addr_u;
        readout(tmp16);
        tmp32 = {ro_a_u, ro_x_u, ro_y_u, ro_p_u};
        tmp8 = ro_s_u;
        for(i = 1; i <= j; i = i + 1)
            for(k = 1; k <= 2; k = k + 1) begin
                sw_setup(t);
                base = tr_n;
                cycles(i - 1);
                rdy = 1'b0;
                cycles(k);
                rdy = 1'b1;
                run_to_fetch(16'h0000, 1'b1, 40);
                errs2 = (tr_n - base != j + k) || (addr_u !== tmp16);
                for(guard = 0; guard < j + k; guard = guard + 1) begin
                    cyc = (guard < i) ? guard : (guard < i + k) ? i - 1 : guard - k;
                    if(((ra_u(base + guard) & 41'h0_00_03_FFFFFF) !== {15'h0, ref_seq[cyc]}) ||
                       ((ra_h(base + guard) & 41'h0_00_03_FFFFFF) !== {15'h0, ref_seq[cyc]}))
                        errs2 = errs2 + 1;
                end
                readout(addr_u);
                if(({ro_a_u, ro_x_u, ro_y_u, ro_p_u} !== tmp32) || (ro_s_u !== tmp8))
                    errs2 = errs2 + 1;
                if(errs2 != 0) begin
                    errs = errs + 1;
                    if(info_left > 0) begin
                        info_left = info_left - 1;
                        $display("INFO: G.4 %0s, cycle %0d held %0d edges: %0d mismatches", sw_name, i, k, errs2);
                    end
                end
                n = n + 1;
            end
        $sformat(nm, "G.4 %0s: %0d cycles held 1 and 2 edges (%0d runs): mismatches", sw_name, j, n);
        check_mm(errs, nm);
    end

    //---------------------------------------------------------------------
    // CPU SECTION H: SO (Set Overflow)
    // A falling SO edge sets V at the enable after the sample; HALF mode
    // samples at cen_p2 (before the rising edge of phi2 [p.1-4]), CYCLE
    // mode at cen, so a fall in phi1 is seen one cycle later in CYCLE
    // mode. One low sample suffices; a new edge needs SO high again; an
    // instruction's V load wins; SO works during RDY holds; a branch reads
    // V as it is at the start of its cycle 2; CLV clears V again while the
    // next fetch is held. V is read from dbg_p at opcode fetches.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CPU SECTION H: SO (Set Overflow)");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    tb_ratio = 4;

    section("CPU SECTION H.1: Sampling Point in Both Clock Modes");
    for(n = 0; n < 3; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        case(n)
            0: begin
                to_phi2();
                so_n = 1'b0;
            end
            1: begin
                wait_cen();
                so_n = 1'b0;
            end
            default: begin
                to_phi2();
                so_n = 1'b0;
                wait_cen();
                to_phi2();
                so_n = 1'b1;
            end
        endcase
        cycles(6);
        so_n = 1'b1;
        tmp8 = {vbu(base), vbh(base), vbu(base + 2), vbh(base + 2),
                vbu(base + 4), vbh(base + 4), 2'b00};
        case(n)
            0: check(tmp8, 8'b00111100, "H.1 SO falling in phi2 of a NOP's cycle 1: V = 1 at the next fetch, both modes");
            1: check(tmp8, 8'b00011100,
                     "H.1 SO falling in phi1 of cycle 2: V at the next fetch in HALF mode, one cycle later in CYCLE mode");
            default: check(tmp8, 8'b00111100, "H.1 SO low for one sample only: V set, both modes");
        endcase
    end

    section("CPU SECTION H.2: A New Edge Needs SO High");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    put(16'h0401, 8'hB8);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    to_phi2();
    so_n = 1'b0;
    cycles(9);
    check({vbu(base + 2), vbu(base + 6), vbh(base + 6), vbu(base + 8)}, 4'b1000,
          "H.2 SO held low: V set once, CLV clears it, no new edge while SO stays low");
    so_n = 1'b1;
    wait_cen();
    to_phi2();
    so_n = 1'b0;
    base = tr_n;
    cycles(6);
    so_n = 1'b1;
    check({vbu(base + 4), vbh(base + 4)}, 2'b11, "H.2 SO high at one sample, then low: V set again");

    //---------------------------------------------------------------------
    // H.3 Collisions: ADC # at 0400 (A = 00, C = 0, result V = 0, binary)
    // loads V at the edge that starts the second cycle of the next
    // instruction (cycle base+3); CLV at 0400 clears V at the edges of
    // base+2 and base+3. An SO set at or before those edges is lost; at
    // base+4 it stays.
    //---------------------------------------------------------------------
    section("CPU SECTION H.3: Collisions with V Loads");
    for(n = 0; n < 6; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0400);
        if(n < 3)
            pb2(8'h69, 8'h00);
        else
            pb(8'hB8);
        start_at(16'h0400, 16'h0200, 8'hFF, (n < 3) ? 8'h04 : 8'h44, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        cycles(n % 3);
        to_phi2();
        so_n = 1'b0;
        cycles(8 - (n % 3));
        so_n = 1'b1;
        tmp8 = {6'h00, vbu(base + 4), vbh(base + 4)};
        $sformat(nm, "H.3 %0s, SO set at the edge of cycle base+%0d: V = %0d at base+4", (n < 3) ? "ADC #00" : "CLV",
                 2 + (n % 3), ((n % 3) == 2) ? 1 : 0);
        check(tmp8, ((n % 3) == 2) ? 8'h03 : 8'h00, nm);
    end

    section("CPU SECTION H.4: SO during a RDY Hold");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    org(16'h0400);
    pb3(8'hAD, 8'h34, 8'h12);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    cycles(3);
    rdy = 1'b0;
    wait_cen();
    to_phi2();
    so_n = 1'b0;
    wait_cen();
    wait_cen();
    rdy = 1'b1;
    cycles(3);
    so_n = 1'b1;
    check({bus_is(base + 7, 16'h0403, 1'b1, 1'b1), vbu(base + 7), vbh(base + 7)}, 3'b111,
          "H.4 SO falling while LDA is held: V set during the hold, seen at the next fetch");

    //---------------------------------------------------------------------
    // H.5 SO before BVS (V = 0): NOP at 0400, BVS +02 at 0401. SO low in
    // phi2 of the NOP's cycle 2 sets V at the edge that starts BVS cycle 2:
    // taken (fetch 0405), both modes. SO low in phi2 of BVS cycle 2: V is
    // set after the decision: not taken (fetch 0403), both modes.
    //---------------------------------------------------------------------
    section("CPU SECTION H.5: SO before BVS");
    for(n = 0; n < 2; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0401);
        pb2(8'h70, 8'h02);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        cycles((n == 0) ? 1 : 3);
        to_phi2();
        so_n = 1'b0;
        run_to_fetch(16'h0000, 1'b1, 10);
        if(n == 0)
            run_to_fetch(16'h0000, 1'b1, 10);
        so_n = 1'b1;
        if(n == 0)
            check(now_is(16'h0405, 1'b1, 1'b1), 1'b1, "H.5 SO set at the edge that starts BVS cycle 2: taken, fetch 0405");
        else
            check(now_is(16'h0403, 1'b1, 1'b1), 1'b1, "H.5 SO falling in BVS cycle 2: not taken, fetch 0403");
    end

    //---------------------------------------------------------------------
    // H.6 CLV with the next fetch held: CLV at 0400 (V = 1 before), the
    // fetch at 0401 held two edges, SO falling in the first repeat (its
    // set lands at a repeat or at the edge that ends the fetch): CLV
    // clears V there, so V = 0 at the following fetch, both modes. Control
    // without the hold: SO falling at the same cycle count sets V.
    //---------------------------------------------------------------------
    section("CPU SECTION H.6: CLV with the Next Fetch Held");
    for(n = 0; n < 2; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        put(16'h0400, 8'hB8);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h44, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        cycles(2);
        if(n == 0)
            rdy = 1'b0;
        wait_cen();
        so_n = 1'b0;
        wait_cen();
        rdy = 1'b1;
        cycles(2);
        so_n = 1'b1;
        run_to_fetch(16'h0000, 1'b1, 10);
        if(n == 0)
            check({dp_u[6], dp_h[6]}, 2'b00, "H.6 CLV, next fetch held two edges, SO falling in the first repeat: lost, V = 0");
        else
            check({dp_u[6], dp_h[6]}, 2'b11, "H.6 CLV, next fetch not held, SO falling one cycle after it: V = 1 (control)");
    end

    //---------------------------------------------------------------------
    // BUS SECTION J: SYNC and vp_n
    // SYNC marks exactly the opcode fetch cycles, including the replaced
    // fetch of an interrupt entry and cycle s+1 of the reset sequence
    // [p.1-6]. vp_n (an extension, not an R65C02 pin) is low only in
    // cycles 6 and 7 of IRQ, NMI and BRK entries.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" BUS SECTION J: SYNC and vp_n");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    tb_ratio = 4;

    section("BUS SECTION J.1: SYNC on Opcode Fetches Only");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    put(16'h1234, 8'h01);
    org(16'h0400);
    pb3(8'hAD, 8'h34, 8'h12);
    pb3(8'h8D, 8'h35, 8'h12);
    pb3(8'hEE, 8'h35, 8'h12);
    pb(8'h48);
    pb(8'h68);
    pb3(8'h20, 8'h20, 8'h04);
    org(16'h0420);
    pb(8'h60);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    run_to_fetch(16'h040E, 1'b0, 60);
    k = tr_n - base;
    check(syncs_in(base, base + k - 1), 7, "J.1 LDA STA INC PHA PLA JSR RTS: 7 SYNC cycles in 33 cycles");
    check(k, 33, "J.1 cycle count 4 + 4 + 6 + 3 + 4 + 6 + 6");
    tmp32 = 0;
    for(j = 0; j < k; j = j + 1)
        if(((ra_u(j + base) & 41'h0_00_03_000000) === 41'h0_00_02_000000))
            tmp32 = tmp32 + 1;
    check(tmp32, 0, "J.1 SYNC never in a write cycle");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    org(16'h0400);
    pb(8'h03);
    pb(8'h0B);
    pb(8'h13);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    cycles(4);
    check(bus_is(base, 16'h0400, 1'b1, 1'b1) && bus_is(base + 1, 16'h0401, 1'b1, 1'b1) &&
          bus_is(base + 2, 16'h0402, 1'b1, 1'b1) && bus_is(base + 3, 16'h0403, 1'b1, 1'b1), 1'b1,
          "J.1 three 1-cycle NOPs: SYNC on four consecutive cycles 0400-0403");

    section("BUS SECTION J.2: vp_n");
    for(n = 0; n < 5; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0400);
        case(n)
            0: pb2(8'h00, 8'h5A);
            1: pb3(8'h6C, 8'hFE, 8'hFF);
            2: pb3(8'hAD, 8'hFA, 8'hFF);
            default: ;
        endcase
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        if(n == 3)
            irq_n = 1'b0;
        if(n == 4)
            nmi_n = 1'b0;
        cycles(12);
        irq_n = 1'b1;
        nmi_n = 1'b1;
        errs = 0;
        for(j = 0; j < 12; j = j + 1) begin
            case(n)
                0: tmp8 = ((j == 5) || (j == 6)) ? 8'h00 : 8'h01;
                3, 4: tmp8 = ((j == 7) || (j == 8)) ? 8'h00 : 8'h01;
                default: tmp8 = 8'h01;
            endcase
            tmp32 = ra_u(base + j);
            if(tmp32[27] !== tmp8[0])
                errs = errs + 1;
            tmp32 = ra_h(base + j);
            if(tmp32[27] !== tmp8[0])
                errs = errs + 1;
        end
        case(n)
            0: nm = "J.2 BRK: vp_n = 0 in cycles 6 and 7 (FFFE, FFFF) only";
            1: nm = "J.2 JMP (FFFE) reads FFFE and FFFF with vp_n = 1";
            2: nm = "J.2 LDA FFFA: vp_n = 1";
            3: nm = "J.2 IRQ entry: vp_n = 0 in cycles 6 and 7 only";
            default: nm = "J.2 NMI entry: vp_n = 0 in cycles 6 and 7 (FFFA, FFFB) only";
        endcase
        check(errs, 0, nm);
    end
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    boot_to(16'h0400);
    rst_n = 1'b0;
    wait_cen();
    base = tr_n;
    rst_n = 1'b1;
    cycles(10);
    tmp32 = 0;
    for(j = 0; j < 10; j = j + 1)
        if((ra_u(base + j) & ra_h(base + j) & 41'h0_00_08_000000) !== 41'h0_00_08_000000)
            tmp32 = tmp32 + 1;
    check(tmp32, 0, "J.2 reset sequence (FFFC, FFFD read): vp_n = 1");

    //---------------------------------------------------------------------
    // CLK SECTION K: Clock Modes and Enables
    // The instruction vectors again at other enable ratios (1 = CYCLE mode
    // only, 2, 3, 5, 16) and with random stops between enables; RES and
    // RDY sweeps at ratios 2 and 5; CYCLE/HALF lockstep over every vector
    // run in both modes; outputs change only at enable edges and are never
    // X.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CLK SECTION K: Clock Modes and Enables");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;

    section("CLK SECTION K.1: Enable Ratios");
    for(t = 0; t < 5; t = t + 1) begin
        case(t)
            0: tb_ratio = 1;
            1: tb_ratio = 2;
            2: tb_ratio = 3;
            3: tb_ratio = 5;
            default: tb_ratio = 16;
        endcase
        vec_clear_counts();
        info_left = 3;
        vec_run((t == 4) ? 4 : 2, 100000);
        $sformat(nm, "K.1 instruction vectors at ratio %0d%0s", tb_ratio, (t == 0) ? " (CYCLE mode only)" : "");
        vec_report(nm);
    end
    for(t = 0; t < 2; t = t + 1) begin
        tb_ratio = (t == 0) ? 2 : 5;
        errs = 0;
        for(n = 0; n < SWN; n = n + 3) begin
            sw_setup(n);
            base = tr_n;
            cycles(2);
            rst_n = 1'b0;
            wait_cen();
            rst_n = 1'b1;
            run_to_fetch(16'h0500, 0, 40);
            errs = errs + (found ? a9_check(base + 3, tr_n, 1) : 1);
        end
        $sformat(nm, "K.1 one-edge RES at cycle 4 of every third sweep instruction, ratio %0d: mismatches", tb_ratio);
        check_mm(errs, nm);
    end

    section("CLK SECTION K.2: Random Stops between Enables");
    tb_ratio = 3;
    en_stall = 1'b1;
    vec_clear_counts();
    info_left = 3;
    vec_run(3, 100000);
    vec_report("K.2 instruction vectors, ratio 3 with stops");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    irq_n = 1'b0;
    run_to_fetch(16'h0700, 1'b0, 30);
    irq_n = 1'b1;
    chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
    check(ent_ok, 1'b1, "K.2 IRQ entry with random stops: replaces the fetch at 0401");
    en_stall = 1'b0;
    tb_ratio = 4;

    section("CLK SECTION K.3: Lockstep and Output Timing");
    $sformat(nm, "K.3 CYCLE/HALF lockstep over every vector run in both modes (%0d runs, %0d cycles)", g_both, g_cyc);
    check_mm(g_lock + ((g_both == 0) ? 1 : 0), nm);
    check_mm(mon_viol_u, "K.3 uut outputs changed only at cen edges: violations");
    check_mm(mon_viol_h, "K.3 uuth outputs changed only at cen and cen_p2 edges: violations");
    check_mm(mon_x_u, "K.3 uut outputs never X (cen_p2 unconnected): clk edges with an X");
    check_mm(mon_x_h, "K.3 uuth outputs never X: clk edges with an X");

    //---------------------------------------------------------------------
    // Final Test Summary
    //---------------------------------------------------------------------
    $display("\n=============================================================");
    $display("  x65c02 Test Results");
    $display("=============================================================");
    $display("  Total Tests:  %0d", total_tests);
    $display("  Passed:       %0d", passed_tests);
    $display("  Failed:       %0d", failed_tests);
    $display("=============================================================");

    if(failed_tests == 0) begin
        $display("  *** ALL TESTS PASSED ***");
        $display("  Cycle-accurate to the Rockwell R65C02 datasheet and R65C02P2 bus recordings");
    end else begin
        $display("  *** SOME TESTS FAILED ***");
    end

    $display("=============================================================\n");

    $stop;
end

endmodule
