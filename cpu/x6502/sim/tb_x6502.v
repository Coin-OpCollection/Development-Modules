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
//  Comprehensive testbench for the NMOS 6502 CPU implementation.
//
//  Verifies x6502 and x6502_alu: every opcode and addressing-mode variant
//  cycle by cycle in both halves of the cycle, reset, interrupts, RDY, SO,
//  JAM, SYNC and vp_n, decimal mode over every input, both clock modes and
//  several enable ratios. Registers are set only by real instructions (a
//  preamble LDX #s; TXS; LDA #p; PHA; LDA #a; LDX #x; LDY #y; PLP; JMP)
//  and results are read back through the bus (PHP and stores) and the
//  debug outputs. No register of the CPU is written from here.
//
//  DUTs:
//    uut     - HALF_CYCLE = 0: one cen per bus cycle, cen_p2 unconnected
//    uuth    - HALF_CYCLE = 1: cen and cen_p2 (rising clock edge)
//    alu_uut - x6502_alu driven directly
//  Both CPUs share clock, enables and inputs, each with its own 64 KB
//  memory model. Enables: tb_ratio clk per bus cycle, cen_p2 halfway,
//  optional random stops between enables.
//
//  Expected values:
//    - Directed tests: the bus pattern and results stated in each test.
//    - sim/tb_x6502_ops.hex: scenarios recorded on the transistor-level
//      netlist of the NMOS 6502: program, register state, input changes
//      on given half cycles, and the expected pins of every bus cycle
//      (+vec=<file> selects another file of the same format).
//    - Decimal mode: the NMOS digit sequences in the reference functions;
//      +q03=<file> also compares with a recorded table of every case.
//
//  Test Organization:
//    CPU Section A:  Reset: power-up values, first and warm reset, the
//                    stack reads and S - 3, the bus while RES is low,
//                    RES sampled only at cen, writes in the cycle RES
//                    falls, the two timing exceptions, RES at every
//                    cycle (netlist scenarios, ratios 4, 2 and 5), RDY
//                    during the RES protocol, RES inside a running reset
//                    sequence and the S it leaves
//    BUS Section B:  Every opcode variant per cycle and per half cycle,
//                    addressing-mode groups, data bus drive window
//    CPU Section C:  All 256 opcodes (results, flags, cycle counts),
//                    random instruction streams
//    ALU Section D:  Every ALU operation over every input; decimal ADC,
//                    SBC, SBC $EB, ISC and RRA through the CPU over every
//                    A x operand x C
//    CPU Section E:  Undocumented: ANE/LXA constant, ANC, ALR, ARR, SBX,
//                    LAS, SHA/SHX/SHY/TAS with page cross and RDY
//    INT Section F:  Recognition point, branch delay, CLI/SEI/PLP/RTI
//                    latency, entry sequence and B bit, NMI hijack, NMI
//                    edge latch, NMI across RES, interrupt sweeps, held
//                    last cycle of CLI and SEI
//    BUS Section G:  RDY: held reads, writes not held, held dummy reads,
//                    interrupts during holds, RDY sweeps, NMI during held
//                    vector and stack reads of an entry
//    CPU Section H:  SO: sampling point in both modes, width, collisions
//                    with V loads, during RDY holds, SO sweeps, SO before
//                    BVC and BVS, CLV with the next fetch held
//    CPU Section I:  JAM: bus pattern, jam output, PC + 2, interrupts
//                    ignored, recovery by RES
//    BUS Section J:  SYNC on opcode fetches only, vp_n on entry vectors
//    CLK Section K:  Enable ratios 1-16, random stops, CYCLE/HALF
//                    lockstep, outputs change only at enables, no X
//
//  Reference: MOS Technology MCS6500 Microcomputer Family Hardware Manual,
//             January 1976, system timing [p.028]-[p.030], interrupts
//             [p.036]-[p.040], RDY, RES, IRQ and NMI [p.050]-[p.053],
//             pins and SYNC [p.055]-[p.058], Appendix A [p.168]-[p.180].
//============================================================================

`timescale 1ns/1ps

module tb_x6502;

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
wire        jam_u;
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
wire        jam_h;
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
x6502 #(
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
    .jam     ( jam_u  ),
    .dbg_pc  ( dpc_u  ),
    .dbg_a   ( da_u   ),
    .dbg_x   ( dx_u   ),
    .dbg_y   ( dy_u   ),
    .dbg_s   ( ds_u   ),
    .dbg_p   ( dp_u   ),
    .dbg_ir  ( dir_u  )
);

x6502 #(
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
    .jam     ( jam_h  ),
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

x6502_alu alu_uut (
    .a     ( alu_a    ),
    .b     ( alu_b    ),
    .op    ( alu_op   ),
    .p_in  ( alu_pin  ),
    .q     ( alu_q    ),
    .p_out ( alu_pout )
);

//-------------------------------------------------------------------------
// ALU Operation Codes:
// The codes of the x6502_alu op input that Section D drives.
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
    ALU_INC = 5'h0E;

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
//        and sync unchanged from phi1  [31] jam  [39:32] phi1 dout
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
wire [94:0] outs_u = {addr_u, dout_u, rw_u, sync_u, vp_u, oe_u, jam_u, dbg_u};
wire [94:0] outs_h = {addr_h, dout_h, rw_h, sync_h, vp_h, oe_h, jam_h, dbg_h};

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
        trb_u[tr_n[12:0]] <= {^outs_u === 1'bx, p1d_u, jam_u,
                              p1v && (p1a_u === addr_u) && (p1rw_u === rw_u) && (p1sy_u === sync_u),
                              p1oe_u, p1v, vp_u, oe_u, sync_u, rw_u, (rw_u === 1'b0) ? dout_u : din_u, addr_u};
        trb_h[tr_n[12:0]] <= {^outs_h === 1'bx, p1d_h, jam_h,
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
// Mnemonic and addressing mode of every opcode (lower case =
// undocumented) and its group in Section B.
//=========================================================================
reg [8*14-1:0] op_name [0:255];
reg  [3:0] op_grp [0:255];
reg [8*28-1:0] grp_name [0:13];

initial begin
    op_name[8'h00] = "BRK impl";
    op_grp[8'h00] = 4'd11;
    op_name[8'h01] = "ORA (zp,X)";
    op_grp[8'h01] = 4'd7;
    op_name[8'h02] = "jam impl";
    op_grp[8'h02] = 4'd13;
    op_name[8'h03] = "slo (zp,X)";
    op_grp[8'h03] = 4'd7;
    op_name[8'h04] = "nop zp";
    op_grp[8'h04] = 4'd3;
    op_name[8'h05] = "ORA zp";
    op_grp[8'h05] = 4'd3;
    op_name[8'h06] = "ASL zp";
    op_grp[8'h06] = 4'd3;
    op_name[8'h07] = "slo zp";
    op_grp[8'h07] = 4'd3;
    op_name[8'h08] = "PHP impl";
    op_grp[8'h08] = 4'd10;
    op_name[8'h09] = "ORA #";
    op_grp[8'h09] = 4'd2;
    op_name[8'h0A] = "ASL A";
    op_grp[8'h0A] = 4'd1;
    op_name[8'h0B] = "anc #";
    op_grp[8'h0B] = 4'd2;
    op_name[8'h0C] = "nop abs";
    op_grp[8'h0C] = 4'd5;
    op_name[8'h0D] = "ORA abs";
    op_grp[8'h0D] = 4'd5;
    op_name[8'h0E] = "ASL abs";
    op_grp[8'h0E] = 4'd5;
    op_name[8'h0F] = "slo abs";
    op_grp[8'h0F] = 4'd5;
    op_name[8'h10] = "BPL rel";
    op_grp[8'h10] = 4'd9;
    op_name[8'h11] = "ORA (zp),Y";
    op_grp[8'h11] = 4'd8;
    op_name[8'h12] = "jam impl";
    op_grp[8'h12] = 4'd13;
    op_name[8'h13] = "slo (zp),Y";
    op_grp[8'h13] = 4'd8;
    op_name[8'h14] = "nop zp,X";
    op_grp[8'h14] = 4'd4;
    op_name[8'h15] = "ORA zp,X";
    op_grp[8'h15] = 4'd4;
    op_name[8'h16] = "ASL zp,X";
    op_grp[8'h16] = 4'd4;
    op_name[8'h17] = "slo zp,X";
    op_grp[8'h17] = 4'd4;
    op_name[8'h18] = "CLC impl";
    op_grp[8'h18] = 4'd1;
    op_name[8'h19] = "ORA abs,Y";
    op_grp[8'h19] = 4'd6;
    op_name[8'h1A] = "nop impl";
    op_grp[8'h1A] = 4'd1;
    op_name[8'h1B] = "slo abs,Y";
    op_grp[8'h1B] = 4'd6;
    op_name[8'h1C] = "nop abs,X";
    op_grp[8'h1C] = 4'd6;
    op_name[8'h1D] = "ORA abs,X";
    op_grp[8'h1D] = 4'd6;
    op_name[8'h1E] = "ASL abs,X";
    op_grp[8'h1E] = 4'd6;
    op_name[8'h1F] = "slo abs,X";
    op_grp[8'h1F] = 4'd6;
    op_name[8'h20] = "JSR abs";
    op_grp[8'h20] = 4'd11;
    op_name[8'h21] = "AND (zp,X)";
    op_grp[8'h21] = 4'd7;
    op_name[8'h22] = "jam impl";
    op_grp[8'h22] = 4'd13;
    op_name[8'h23] = "rla (zp,X)";
    op_grp[8'h23] = 4'd7;
    op_name[8'h24] = "BIT zp";
    op_grp[8'h24] = 4'd3;
    op_name[8'h25] = "AND zp";
    op_grp[8'h25] = 4'd3;
    op_name[8'h26] = "ROL zp";
    op_grp[8'h26] = 4'd3;
    op_name[8'h27] = "rla zp";
    op_grp[8'h27] = 4'd3;
    op_name[8'h28] = "PLP impl";
    op_grp[8'h28] = 4'd10;
    op_name[8'h29] = "AND #";
    op_grp[8'h29] = 4'd2;
    op_name[8'h2A] = "ROL A";
    op_grp[8'h2A] = 4'd1;
    op_name[8'h2B] = "anc #";
    op_grp[8'h2B] = 4'd2;
    op_name[8'h2C] = "BIT abs";
    op_grp[8'h2C] = 4'd5;
    op_name[8'h2D] = "AND abs";
    op_grp[8'h2D] = 4'd5;
    op_name[8'h2E] = "ROL abs";
    op_grp[8'h2E] = 4'd5;
    op_name[8'h2F] = "rla abs";
    op_grp[8'h2F] = 4'd5;
    op_name[8'h30] = "BMI rel";
    op_grp[8'h30] = 4'd9;
    op_name[8'h31] = "AND (zp),Y";
    op_grp[8'h31] = 4'd8;
    op_name[8'h32] = "jam impl";
    op_grp[8'h32] = 4'd13;
    op_name[8'h33] = "rla (zp),Y";
    op_grp[8'h33] = 4'd8;
    op_name[8'h34] = "nop zp,X";
    op_grp[8'h34] = 4'd4;
    op_name[8'h35] = "AND zp,X";
    op_grp[8'h35] = 4'd4;
    op_name[8'h36] = "ROL zp,X";
    op_grp[8'h36] = 4'd4;
    op_name[8'h37] = "rla zp,X";
    op_grp[8'h37] = 4'd4;
    op_name[8'h38] = "SEC impl";
    op_grp[8'h38] = 4'd1;
    op_name[8'h39] = "AND abs,Y";
    op_grp[8'h39] = 4'd6;
    op_name[8'h3A] = "nop impl";
    op_grp[8'h3A] = 4'd1;
    op_name[8'h3B] = "rla abs,Y";
    op_grp[8'h3B] = 4'd6;
    op_name[8'h3C] = "nop abs,X";
    op_grp[8'h3C] = 4'd6;
    op_name[8'h3D] = "AND abs,X";
    op_grp[8'h3D] = 4'd6;
    op_name[8'h3E] = "ROL abs,X";
    op_grp[8'h3E] = 4'd6;
    op_name[8'h3F] = "rla abs,X";
    op_grp[8'h3F] = 4'd6;
    op_name[8'h40] = "RTI impl";
    op_grp[8'h40] = 4'd11;
    op_name[8'h41] = "EOR (zp,X)";
    op_grp[8'h41] = 4'd7;
    op_name[8'h42] = "jam impl";
    op_grp[8'h42] = 4'd13;
    op_name[8'h43] = "sre (zp,X)";
    op_grp[8'h43] = 4'd7;
    op_name[8'h44] = "nop zp";
    op_grp[8'h44] = 4'd3;
    op_name[8'h45] = "EOR zp";
    op_grp[8'h45] = 4'd3;
    op_name[8'h46] = "LSR zp";
    op_grp[8'h46] = 4'd3;
    op_name[8'h47] = "sre zp";
    op_grp[8'h47] = 4'd3;
    op_name[8'h48] = "PHA impl";
    op_grp[8'h48] = 4'd10;
    op_name[8'h49] = "EOR #";
    op_grp[8'h49] = 4'd2;
    op_name[8'h4A] = "LSR A";
    op_grp[8'h4A] = 4'd1;
    op_name[8'h4B] = "alr #";
    op_grp[8'h4B] = 4'd2;
    op_name[8'h4C] = "JMP abs";
    op_grp[8'h4C] = 4'd12;
    op_name[8'h4D] = "EOR abs";
    op_grp[8'h4D] = 4'd5;
    op_name[8'h4E] = "LSR abs";
    op_grp[8'h4E] = 4'd5;
    op_name[8'h4F] = "sre abs";
    op_grp[8'h4F] = 4'd5;
    op_name[8'h50] = "BVC rel";
    op_grp[8'h50] = 4'd9;
    op_name[8'h51] = "EOR (zp),Y";
    op_grp[8'h51] = 4'd8;
    op_name[8'h52] = "jam impl";
    op_grp[8'h52] = 4'd13;
    op_name[8'h53] = "sre (zp),Y";
    op_grp[8'h53] = 4'd8;
    op_name[8'h54] = "nop zp,X";
    op_grp[8'h54] = 4'd4;
    op_name[8'h55] = "EOR zp,X";
    op_grp[8'h55] = 4'd4;
    op_name[8'h56] = "LSR zp,X";
    op_grp[8'h56] = 4'd4;
    op_name[8'h57] = "sre zp,X";
    op_grp[8'h57] = 4'd4;
    op_name[8'h58] = "CLI impl";
    op_grp[8'h58] = 4'd1;
    op_name[8'h59] = "EOR abs,Y";
    op_grp[8'h59] = 4'd6;
    op_name[8'h5A] = "nop impl";
    op_grp[8'h5A] = 4'd1;
    op_name[8'h5B] = "sre abs,Y";
    op_grp[8'h5B] = 4'd6;
    op_name[8'h5C] = "nop abs,X";
    op_grp[8'h5C] = 4'd6;
    op_name[8'h5D] = "EOR abs,X";
    op_grp[8'h5D] = 4'd6;
    op_name[8'h5E] = "LSR abs,X";
    op_grp[8'h5E] = 4'd6;
    op_name[8'h5F] = "sre abs,X";
    op_grp[8'h5F] = 4'd6;
    op_name[8'h60] = "RTS impl";
    op_grp[8'h60] = 4'd11;
    op_name[8'h61] = "ADC (zp,X)";
    op_grp[8'h61] = 4'd7;
    op_name[8'h62] = "jam impl";
    op_grp[8'h62] = 4'd13;
    op_name[8'h63] = "rra (zp,X)";
    op_grp[8'h63] = 4'd7;
    op_name[8'h64] = "nop zp";
    op_grp[8'h64] = 4'd3;
    op_name[8'h65] = "ADC zp";
    op_grp[8'h65] = 4'd3;
    op_name[8'h66] = "ROR zp";
    op_grp[8'h66] = 4'd3;
    op_name[8'h67] = "rra zp";
    op_grp[8'h67] = 4'd3;
    op_name[8'h68] = "PLA impl";
    op_grp[8'h68] = 4'd10;
    op_name[8'h69] = "ADC #";
    op_grp[8'h69] = 4'd2;
    op_name[8'h6A] = "ROR A";
    op_grp[8'h6A] = 4'd1;
    op_name[8'h6B] = "arr #";
    op_grp[8'h6B] = 4'd2;
    op_name[8'h6C] = "JMP (abs)";
    op_grp[8'h6C] = 4'd12;
    op_name[8'h6D] = "ADC abs";
    op_grp[8'h6D] = 4'd5;
    op_name[8'h6E] = "ROR abs";
    op_grp[8'h6E] = 4'd5;
    op_name[8'h6F] = "rra abs";
    op_grp[8'h6F] = 4'd5;
    op_name[8'h70] = "BVS rel";
    op_grp[8'h70] = 4'd9;
    op_name[8'h71] = "ADC (zp),Y";
    op_grp[8'h71] = 4'd8;
    op_name[8'h72] = "jam impl";
    op_grp[8'h72] = 4'd13;
    op_name[8'h73] = "rra (zp),Y";
    op_grp[8'h73] = 4'd8;
    op_name[8'h74] = "nop zp,X";
    op_grp[8'h74] = 4'd4;
    op_name[8'h75] = "ADC zp,X";
    op_grp[8'h75] = 4'd4;
    op_name[8'h76] = "ROR zp,X";
    op_grp[8'h76] = 4'd4;
    op_name[8'h77] = "rra zp,X";
    op_grp[8'h77] = 4'd4;
    op_name[8'h78] = "SEI impl";
    op_grp[8'h78] = 4'd1;
    op_name[8'h79] = "ADC abs,Y";
    op_grp[8'h79] = 4'd6;
    op_name[8'h7A] = "nop impl";
    op_grp[8'h7A] = 4'd1;
    op_name[8'h7B] = "rra abs,Y";
    op_grp[8'h7B] = 4'd6;
    op_name[8'h7C] = "nop abs,X";
    op_grp[8'h7C] = 4'd6;
    op_name[8'h7D] = "ADC abs,X";
    op_grp[8'h7D] = 4'd6;
    op_name[8'h7E] = "ROR abs,X";
    op_grp[8'h7E] = 4'd6;
    op_name[8'h7F] = "rra abs,X";
    op_grp[8'h7F] = 4'd6;
    op_name[8'h80] = "nop #";
    op_grp[8'h80] = 4'd2;
    op_name[8'h81] = "STA (zp,X)";
    op_grp[8'h81] = 4'd7;
    op_name[8'h82] = "nop #";
    op_grp[8'h82] = 4'd2;
    op_name[8'h83] = "sax (zp,X)";
    op_grp[8'h83] = 4'd7;
    op_name[8'h84] = "STY zp";
    op_grp[8'h84] = 4'd3;
    op_name[8'h85] = "STA zp";
    op_grp[8'h85] = 4'd3;
    op_name[8'h86] = "STX zp";
    op_grp[8'h86] = 4'd3;
    op_name[8'h87] = "sax zp";
    op_grp[8'h87] = 4'd3;
    op_name[8'h88] = "DEY impl";
    op_grp[8'h88] = 4'd1;
    op_name[8'h89] = "nop #";
    op_grp[8'h89] = 4'd2;
    op_name[8'h8A] = "TXA impl";
    op_grp[8'h8A] = 4'd1;
    op_name[8'h8B] = "ane #";
    op_grp[8'h8B] = 4'd2;
    op_name[8'h8C] = "STY abs";
    op_grp[8'h8C] = 4'd5;
    op_name[8'h8D] = "STA abs";
    op_grp[8'h8D] = 4'd5;
    op_name[8'h8E] = "STX abs";
    op_grp[8'h8E] = 4'd5;
    op_name[8'h8F] = "sax abs";
    op_grp[8'h8F] = 4'd5;
    op_name[8'h90] = "BCC rel";
    op_grp[8'h90] = 4'd9;
    op_name[8'h91] = "STA (zp),Y";
    op_grp[8'h91] = 4'd8;
    op_name[8'h92] = "jam impl";
    op_grp[8'h92] = 4'd13;
    op_name[8'h93] = "sha (zp),Y";
    op_grp[8'h93] = 4'd8;
    op_name[8'h94] = "STY zp,X";
    op_grp[8'h94] = 4'd4;
    op_name[8'h95] = "STA zp,X";
    op_grp[8'h95] = 4'd4;
    op_name[8'h96] = "STX zp,Y";
    op_grp[8'h96] = 4'd4;
    op_name[8'h97] = "sax zp,Y";
    op_grp[8'h97] = 4'd4;
    op_name[8'h98] = "TYA impl";
    op_grp[8'h98] = 4'd1;
    op_name[8'h99] = "STA abs,Y";
    op_grp[8'h99] = 4'd6;
    op_name[8'h9A] = "TXS impl";
    op_grp[8'h9A] = 4'd1;
    op_name[8'h9B] = "tas abs,Y";
    op_grp[8'h9B] = 4'd6;
    op_name[8'h9C] = "shy abs,X";
    op_grp[8'h9C] = 4'd6;
    op_name[8'h9D] = "STA abs,X";
    op_grp[8'h9D] = 4'd6;
    op_name[8'h9E] = "shx abs,Y";
    op_grp[8'h9E] = 4'd6;
    op_name[8'h9F] = "sha abs,Y";
    op_grp[8'h9F] = 4'd6;
    op_name[8'hA0] = "LDY #";
    op_grp[8'hA0] = 4'd2;
    op_name[8'hA1] = "LDA (zp,X)";
    op_grp[8'hA1] = 4'd7;
    op_name[8'hA2] = "LDX #";
    op_grp[8'hA2] = 4'd2;
    op_name[8'hA3] = "lax (zp,X)";
    op_grp[8'hA3] = 4'd7;
    op_name[8'hA4] = "LDY zp";
    op_grp[8'hA4] = 4'd3;
    op_name[8'hA5] = "LDA zp";
    op_grp[8'hA5] = 4'd3;
    op_name[8'hA6] = "LDX zp";
    op_grp[8'hA6] = 4'd3;
    op_name[8'hA7] = "lax zp";
    op_grp[8'hA7] = 4'd3;
    op_name[8'hA8] = "TAY impl";
    op_grp[8'hA8] = 4'd1;
    op_name[8'hA9] = "LDA #";
    op_grp[8'hA9] = 4'd2;
    op_name[8'hAA] = "TAX impl";
    op_grp[8'hAA] = 4'd1;
    op_name[8'hAB] = "lxa #";
    op_grp[8'hAB] = 4'd2;
    op_name[8'hAC] = "LDY abs";
    op_grp[8'hAC] = 4'd5;
    op_name[8'hAD] = "LDA abs";
    op_grp[8'hAD] = 4'd5;
    op_name[8'hAE] = "LDX abs";
    op_grp[8'hAE] = 4'd5;
    op_name[8'hAF] = "lax abs";
    op_grp[8'hAF] = 4'd5;
    op_name[8'hB0] = "BCS rel";
    op_grp[8'hB0] = 4'd9;
    op_name[8'hB1] = "LDA (zp),Y";
    op_grp[8'hB1] = 4'd8;
    op_name[8'hB2] = "jam impl";
    op_grp[8'hB2] = 4'd13;
    op_name[8'hB3] = "lax (zp),Y";
    op_grp[8'hB3] = 4'd8;
    op_name[8'hB4] = "LDY zp,X";
    op_grp[8'hB4] = 4'd4;
    op_name[8'hB5] = "LDA zp,X";
    op_grp[8'hB5] = 4'd4;
    op_name[8'hB6] = "LDX zp,Y";
    op_grp[8'hB6] = 4'd4;
    op_name[8'hB7] = "lax zp,Y";
    op_grp[8'hB7] = 4'd4;
    op_name[8'hB8] = "CLV impl";
    op_grp[8'hB8] = 4'd1;
    op_name[8'hB9] = "LDA abs,Y";
    op_grp[8'hB9] = 4'd6;
    op_name[8'hBA] = "TSX impl";
    op_grp[8'hBA] = 4'd1;
    op_name[8'hBB] = "las abs,Y";
    op_grp[8'hBB] = 4'd6;
    op_name[8'hBC] = "LDY abs,X";
    op_grp[8'hBC] = 4'd6;
    op_name[8'hBD] = "LDA abs,X";
    op_grp[8'hBD] = 4'd6;
    op_name[8'hBE] = "LDX abs,Y";
    op_grp[8'hBE] = 4'd6;
    op_name[8'hBF] = "lax abs,Y";
    op_grp[8'hBF] = 4'd6;
    op_name[8'hC0] = "CPY #";
    op_grp[8'hC0] = 4'd2;
    op_name[8'hC1] = "CMP (zp,X)";
    op_grp[8'hC1] = 4'd7;
    op_name[8'hC2] = "nop #";
    op_grp[8'hC2] = 4'd2;
    op_name[8'hC3] = "dcp (zp,X)";
    op_grp[8'hC3] = 4'd7;
    op_name[8'hC4] = "CPY zp";
    op_grp[8'hC4] = 4'd3;
    op_name[8'hC5] = "CMP zp";
    op_grp[8'hC5] = 4'd3;
    op_name[8'hC6] = "DEC zp";
    op_grp[8'hC6] = 4'd3;
    op_name[8'hC7] = "dcp zp";
    op_grp[8'hC7] = 4'd3;
    op_name[8'hC8] = "INY impl";
    op_grp[8'hC8] = 4'd1;
    op_name[8'hC9] = "CMP #";
    op_grp[8'hC9] = 4'd2;
    op_name[8'hCA] = "DEX impl";
    op_grp[8'hCA] = 4'd1;
    op_name[8'hCB] = "sbx #";
    op_grp[8'hCB] = 4'd2;
    op_name[8'hCC] = "CPY abs";
    op_grp[8'hCC] = 4'd5;
    op_name[8'hCD] = "CMP abs";
    op_grp[8'hCD] = 4'd5;
    op_name[8'hCE] = "DEC abs";
    op_grp[8'hCE] = 4'd5;
    op_name[8'hCF] = "dcp abs";
    op_grp[8'hCF] = 4'd5;
    op_name[8'hD0] = "BNE rel";
    op_grp[8'hD0] = 4'd9;
    op_name[8'hD1] = "CMP (zp),Y";
    op_grp[8'hD1] = 4'd8;
    op_name[8'hD2] = "jam impl";
    op_grp[8'hD2] = 4'd13;
    op_name[8'hD3] = "dcp (zp),Y";
    op_grp[8'hD3] = 4'd8;
    op_name[8'hD4] = "nop zp,X";
    op_grp[8'hD4] = 4'd4;
    op_name[8'hD5] = "CMP zp,X";
    op_grp[8'hD5] = 4'd4;
    op_name[8'hD6] = "DEC zp,X";
    op_grp[8'hD6] = 4'd4;
    op_name[8'hD7] = "dcp zp,X";
    op_grp[8'hD7] = 4'd4;
    op_name[8'hD8] = "CLD impl";
    op_grp[8'hD8] = 4'd1;
    op_name[8'hD9] = "CMP abs,Y";
    op_grp[8'hD9] = 4'd6;
    op_name[8'hDA] = "nop impl";
    op_grp[8'hDA] = 4'd1;
    op_name[8'hDB] = "dcp abs,Y";
    op_grp[8'hDB] = 4'd6;
    op_name[8'hDC] = "nop abs,X";
    op_grp[8'hDC] = 4'd6;
    op_name[8'hDD] = "CMP abs,X";
    op_grp[8'hDD] = 4'd6;
    op_name[8'hDE] = "DEC abs,X";
    op_grp[8'hDE] = 4'd6;
    op_name[8'hDF] = "dcp abs,X";
    op_grp[8'hDF] = 4'd6;
    op_name[8'hE0] = "CPX #";
    op_grp[8'hE0] = 4'd2;
    op_name[8'hE1] = "SBC (zp,X)";
    op_grp[8'hE1] = 4'd7;
    op_name[8'hE2] = "nop #";
    op_grp[8'hE2] = 4'd2;
    op_name[8'hE3] = "isc (zp,X)";
    op_grp[8'hE3] = 4'd7;
    op_name[8'hE4] = "CPX zp";
    op_grp[8'hE4] = 4'd3;
    op_name[8'hE5] = "SBC zp";
    op_grp[8'hE5] = 4'd3;
    op_name[8'hE6] = "INC zp";
    op_grp[8'hE6] = 4'd3;
    op_name[8'hE7] = "isc zp";
    op_grp[8'hE7] = 4'd3;
    op_name[8'hE8] = "INX impl";
    op_grp[8'hE8] = 4'd1;
    op_name[8'hE9] = "SBC #";
    op_grp[8'hE9] = 4'd2;
    op_name[8'hEA] = "NOP impl";
    op_grp[8'hEA] = 4'd1;
    op_name[8'hEB] = "usbc #";
    op_grp[8'hEB] = 4'd2;
    op_name[8'hEC] = "CPX abs";
    op_grp[8'hEC] = 4'd5;
    op_name[8'hED] = "SBC abs";
    op_grp[8'hED] = 4'd5;
    op_name[8'hEE] = "INC abs";
    op_grp[8'hEE] = 4'd5;
    op_name[8'hEF] = "isc abs";
    op_grp[8'hEF] = 4'd5;
    op_name[8'hF0] = "BEQ rel";
    op_grp[8'hF0] = 4'd9;
    op_name[8'hF1] = "SBC (zp),Y";
    op_grp[8'hF1] = 4'd8;
    op_name[8'hF2] = "jam impl";
    op_grp[8'hF2] = 4'd13;
    op_name[8'hF3] = "isc (zp),Y";
    op_grp[8'hF3] = 4'd8;
    op_name[8'hF4] = "nop zp,X";
    op_grp[8'hF4] = 4'd4;
    op_name[8'hF5] = "SBC zp,X";
    op_grp[8'hF5] = 4'd4;
    op_name[8'hF6] = "INC zp,X";
    op_grp[8'hF6] = 4'd4;
    op_name[8'hF7] = "isc zp,X";
    op_grp[8'hF7] = 4'd4;
    op_name[8'hF8] = "SED impl";
    op_grp[8'hF8] = 4'd1;
    op_name[8'hF9] = "SBC abs,Y";
    op_grp[8'hF9] = 4'd6;
    op_name[8'hFA] = "nop impl";
    op_grp[8'hFA] = 4'd1;
    op_name[8'hFB] = "isc abs,Y";
    op_grp[8'hFB] = 4'd6;
    op_name[8'hFC] = "nop abs,X";
    op_grp[8'hFC] = 4'd6;
    op_name[8'hFD] = "SBC abs,X";
    op_grp[8'hFD] = 4'd6;
    op_name[8'hFE] = "INC abs,X";
    op_grp[8'hFE] = 4'd6;
    op_name[8'hFF] = "isc abs,X";
    op_grp[8'hFF] = 4'd6;
    grp_name[1] = "implied and accumulator";
    grp_name[2] = "immediate";
    grp_name[3] = "zero page";
    grp_name[4] = "zero page indexed";
    grp_name[5] = "absolute";
    grp_name[6] = "absolute indexed";
    grp_name[7] = "(zero page,X)";
    grp_name[8] = "(zero page),Y";
    grp_name[9] = "relative (branches)";
    grp_name[10] = "stack (PHA PHP PLA PLP)";
    grp_name[11] = "JSR RTS RTI BRK";
    grp_name[12] = "JMP absolute and indirect";
    grp_name[13] = "JAM";
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
// Scenario Vectors:
// sim/tb_x6502_ops.hex holds netlist scenarios: a program and register
// state set by the 22-cycle preamble LDX #s; TXS; LDA #p; PHA; LDA #a;
// LDX #x; LDY #y; PLP; JMP pc at 0200, input changes on given half
// cycles, and the expected pins of every bus cycle from the 0200 fetch
// on. +vec=<file> selects another file of the same format. Record:
//   W0 {A5, family, cycles listed}  W1 {pc, fill, flags}
//   W2 {opcode, variant, name words, events}  W3 {s, p, a, x}
//   W4 {y, flags2, 0000}, name, events {row, pin, level}, memory runs
//   {addr, len} + bytes, the debug check (flags b3) and one word per cycle:
//   [15:0] address, [23:16] data, [24] R/W, [25] SYNC, [26] CPU drives D
//   in phi2, [27] vp_n = 0, [28] address = held PC while RES is low,
//   [29] address not specified. flags: b0 compare uut, b1 compare uuth,
//   b2 RES event, b3 debug check, b4/b5 reset-content and D2 classes,
//   b6 SO change in phi1. flags2: b0 standard vectors and handlers,
//   b1 preamble cycles formed here. Event row d = 2 * cycle + phase,
//   relative to the opcode fetch at pc (pins 0 RES, 1 RDY, 2 IRQ, 3 NMI,
//   4 SO).
//=========================================================================
localparam VEC_MAX = 2200000;
localparam REC_MAX = 30000;
reg  [31:0] vec [0:VEC_MAX-1];
integer     rec_ptr [0:REC_MAX-1];
integer     rec_cnt;
reg [8*256-1:0] vec_file;
reg         vec_found;

integer     r_fam;
integer     r_ncyc;
reg  [15:0] r_pc;
reg   [7:0] r_fill;
reg   [7:0] r_flags;
reg   [7:0] r_flags2;
reg   [7:0] r_op;
reg   [7:0] r_var;
integer     r_nname;
integer     r_nev;
reg   [7:0] r_s;
reg   [7:0] r_p;
reg   [7:0] r_a;
reg   [7:0] r_x;
reg   [7:0] r_y;
reg [8*48-1:0] r_name;
integer     r_ev_d [0:63];
integer     r_ev_pin [0:63];
integer     r_ev_lvl [0:63];
integer     r_runs;
integer     r_cyc0;
integer     r_next;
integer     r_dbg_idx;
reg  [15:0] r_dbg_pc;
reg  [31:0] r_dbg_axys;
reg   [7:0] r_dbg_p;
reg   [7:0] r_dbg_ir;

task vec_try;
    input [8*256-1:0] f;
    integer           fd;
    begin
        if(!vec_found) begin
            fd = $fopen(f, "r");
            if(fd != 0) begin
                $fclose(fd);
                vec_file = f;
                vec_found = 1'b1;
            end
        end
    end
endtask

task vec_load;
    integer p;
    integer q;
    integer nr;
    integer ln;
    begin
        vec_found = 1'b0;
        if($value$plusargs("vec=%s", vec_file))
            vec_try(vec_file);
        vec_try("sim/tb_x6502_ops.hex");
        vec_try("../sim/tb_x6502_ops.hex");
        vec_try("tb_x6502_ops.hex");
        rec_cnt = 0;
        if(vec_found) begin
            $readmemh(vec_file, vec);
            p = 0;
            while((vec[p] !== 32'hFFFFFFFF) && (vec[p][31:24] === 8'hA5) && (rec_cnt < REC_MAX)) begin
                rec_ptr[rec_cnt] = p;
                rec_cnt = rec_cnt + 1;
                q = p + 5 + vec[p + 2][15:8] + vec[p + 2][7:0];
                nr = vec[q][31:16];
                q = q + 1;
                while(nr > 0) begin
                    ln = vec[q][15:0];
                    q = q + 1 + (ln + 3) / 4;
                    nr = nr - 1;
                end
                if(vec[p + 1][3])
                    q = q + 3;
                p = q + vec[p][15:0];
            end
        end
    end
endtask

task vec_decode;
    input integer p;
    integer    q;
    integer    kk;
    integer    bb;
    reg [31:0] w;
    begin
        w = vec[p];
        r_fam = w[23:16];
        r_ncyc = w[15:0];
        w = vec[p + 1];
        r_pc = w[31:16];
        r_fill = w[15:8];
        r_flags = w[7:0];
        w = vec[p + 2];
        r_op = w[31:24];
        r_var = w[23:16];
        r_nname = w[15:8];
        r_nev = w[7:0];
        w = vec[p + 3];
        r_s = w[31:24];
        r_p = w[23:16];
        r_a = w[15:8];
        r_x = w[7:0];
        w = vec[p + 4];
        r_y = w[31:24];
        r_flags2 = w[23:16];
        q = p + 5;
        r_name = 0;
        for(kk = 0; kk < r_nname; kk = kk + 1) begin
            w = vec[q + kk];
            for(bb = 3; bb >= 0; bb = bb - 1)
                if(w[8 * bb +: 8] != 8'h00)
                    r_name = {r_name[8*47-1:0], w[8 * bb +: 8]};
        end
        q = q + r_nname;
        for(kk = 0; kk < r_nev; kk = kk + 1) begin
            w = vec[q + kk];
            r_ev_d[kk] = w[31] ? (w[31:16] - 65536) : w[31:16];
            r_ev_pin[kk] = w[15:8];
            r_ev_lvl[kk] = w[7:0];
        end
        q = q + r_nev;
        r_runs = q;
        kk = vec[q][31:16];
        q = q + 1;
        while(kk > 0) begin
            q = q + 1 + (vec[q][15:0] + 3) / 4;
            kk = kk - 1;
        end
        r_dbg_idx = -1;
        if(r_flags[3]) begin
            r_dbg_idx = vec[q][31:16];
            r_dbg_pc = vec[q][15:0];
            r_dbg_axys = vec[q + 1];
            r_dbg_p = vec[q + 2][31:24];
            r_dbg_ir = vec[q + 2][23:16];
            q = q + 3;
        end
        r_cyc0 = q;
        r_next = q + r_ncyc;
    end
endtask

// observation code of the standard handlers: PHP; STA w; STX w+1; STY w+2;
// TSX; STX w+3; NOP; NOP; NOP; JMP to itself
task put_obs;
    input [15:0] a;
    input [15:0] w;
    begin
        org(a);
        pb(8'h08);
        pb3(8'h8D, w[7:0], w[15:8]);
        pb3(8'h8E, w[7:0] + 8'd1, w[15:8]);
        pb3(8'h8C, w[7:0] + 8'd2, w[15:8]);
        pb(8'hBA);
        pb3(8'h8E, w[7:0] + 8'd3, w[15:8]);
        pb3(8'hEA, 8'hEA, 8'hEA);
        tmp16 = a + 16'd17;
        pb3(8'h4C, tmp16[7:0], tmp16[15:8]);
    end
endtask

task vec_image;
    integer    q;
    integer    nr;
    integer    ln;
    integer    kk;
    reg [15:0] a;
    begin
        mem_new(r_fill);
        org(16'h0200);
        pb2(8'hA2, r_s);
        pb(8'h9A);
        pb2(8'hA9, r_p);
        pb(8'h48);
        pb2(8'hA9, r_a);
        pb2(8'hA2, r_x);
        pb2(8'hA0, r_y);
        pb(8'h28);
        pb3(8'h4C, r_pc[7:0], r_pc[15:8]);
        if(r_flags2[0]) begin
            put(16'hFFFA, 8'hA0);
            put(16'hFFFB, 8'h03);
            put(16'hFFFC, 8'h50);
            put(16'hFFFD, 8'h07);
            put(16'hFFFE, 8'h30);
            put(16'hFFFF, 8'h03);
            put_obs(16'h0330, 16'h0610);
            put_obs(16'h03A0, 16'h0620);
            put_obs(16'h0750, 16'h0630);
        end
        q = r_runs;
        nr = vec[q][31:16];
        q = q + 1;
        while(nr > 0) begin
            a = vec[q][31:16];
            ln = vec[q][15:0];
            q = q + 1;
            for(kk = 0; kk < ln; kk = kk + 1)
                put(a + kk, vec[q + kk / 4][8 * (3 - kk % 4) +: 8]);
            q = q + (ln + 3) / 4;
            nr = nr - 1;
        end
    end
endtask

// expected word of preamble cycle idx (0 = the fetch at 0200)
function [31:0] pre_word;
    input integer idx;
    input  [7:0] s;
    input  [7:0] p;
    reg   [15:0] a;
    reg          sy;
    reg          w;
    begin
        sy = 1'b0;
        w = 1'b0;
        case(idx)
            0:  begin a = 16'h0200; sy = 1'b1; end
            1:  a = 16'h0201;
            2:  begin a = 16'h0202; sy = 1'b1; end
            3:  a = 16'h0203;
            4:  begin a = 16'h0203; sy = 1'b1; end
            5:  a = 16'h0204;
            6:  begin a = 16'h0205; sy = 1'b1; end
            7:  a = 16'h0206;
            8:  begin a = {8'h01, s}; w = 1'b1; end
            9:  begin a = 16'h0206; sy = 1'b1; end
            10: a = 16'h0207;
            11: begin a = 16'h0208; sy = 1'b1; end
            12: a = 16'h0209;
            13: begin a = 16'h020A; sy = 1'b1; end
            14: a = 16'h020B;
            15: begin a = 16'h020C; sy = 1'b1; end
            16: a = 16'h020D;
            17: a = {8'h01, s - 8'd1};
            18: a = {8'h01, s};
            19: begin a = 16'h020D; sy = 1'b1; end
            20: a = 16'h020E;
            default: a = 16'h020F;
        endcase
        pre_word = {5'd0, w, sy, ~w, w ? p : 8'h00, a};
    end
endfunction

//-------------------------------------------------------------------------
// Per-Run Counters:
// c_* count the mismatches of one scenario, f_*[family] the totals of a
// family run; fm_* hold the first mismatch of the scenario for the INFO
// line.
//-------------------------------------------------------------------------
integer     c_bus;
integer     c_held;
integer     c_data;
integer     c_oe;
integer     c_vp;
integer     c_dbg;
integer     c_lock;
integer     c_harn;
integer     f_n [0:31];
integer     f_cyc [0:31];
integer     f_bus [0:31];
integer     f_held [0:31];
integer     f_data [0:31];
integer     f_oe [0:31];
integer     f_vp [0:31];
integer     f_dbg [0:31];
integer     f_lock [0:31];
integer     f_harn [0:31];
integer     f_bad [0:31];
integer     op_n [0:255];
integer     op_mm [0:255];
integer     op_cx [0:255];
reg         fm_set;
integer     fm_idx;
reg [8*16-1:0] fm_what;
reg         fm_dut;
reg  [31:0] fm_exp;
reg  [40:0] fm_got;
integer     info_left;
integer     g_both;
integer     g_lock;
integer     g_cyc;

task vec_clear_counts;
    integer kk;
    begin
        for(kk = 0; kk < 32; kk = kk + 1) begin
            f_n[kk] = 0;
            f_cyc[kk] = 0;
            f_bus[kk] = 0;
            f_held[kk] = 0;
            f_data[kk] = 0;
            f_oe[kk] = 0;
            f_vp[kk] = 0;
            f_dbg[kk] = 0;
            f_lock[kk] = 0;
            f_harn[kk] = 0;
            f_bad[kk] = 0;
        end
        for(kk = 0; kk < 256; kk = kk + 1) begin
            op_n[kk] = 0;
            op_mm[kk] = 0;
            op_cx[kk] = 0;
        end
    end
endtask

task mm_note;
    input [8*16-1:0] what;
    input            dut;
    input integer    idx;
    input [31:0] e;
    input [40:0] g;
    begin
        if(!fm_set) begin
            fm_set = 1'b1;
            fm_what = what;
            fm_dut = dut;
            fm_idx = idx;
            fm_exp = e;
            fm_got = g;
        end
    end
endtask

// compare one CPU's record of cycle idx with the expected word e
task vec_cmp;
    input dut;
    input integer idx;
    input [31:0] e;
    reg   [40:0] g;
    reg   [63:0] dg;
    begin
        g = dut ? rec_h(0) : rec_u(0);
        dg = dut ? recd_h(0) : recd_u(0);
        if(g[40]) begin
            c_bus = c_bus + 1;
            mm_note("X on an output", dut, idx, e, g);
        end
        if(!e[29]) begin
            if(g[15:0] !== e[15:0]) begin
                if(e[28]) begin
                    c_held = c_held + 1;
                    mm_note("held PC", dut, idx, e, g);
                end else begin
                    c_bus = c_bus + 1;
                    mm_note("address", dut, idx, e, g);
                end
            end
        end
        if((g[24] !== e[24]) || (g[25] !== e[25])) begin
            c_bus = c_bus + 1;
            mm_note("R/W or SYNC", dut, idx, e, g);
        end
        if(g[28] && !g[30]) begin
            c_bus = c_bus + 1;
            mm_note("pin in phi1", dut, idx, e, g);
        end
        if(!e[24]) begin
            if(g[23:16] !== e[23:16]) begin
                c_data = c_data + 1;
                mm_note("write data", dut, idx, e, g);
            end
            if(g[28] && (g[39:32] !== e[23:16])) begin
                c_data = c_data + 1;
                mm_note("phi1 dout", dut, idx, e, g);
            end
        end
        if(g[26] !== e[26]) begin
            c_oe = c_oe + 1;
            mm_note("dout_oe phi2", dut, idx, e, g);
        end
        if(g[28] && (g[29] !== (dut ? 1'b0 : e[26]))) begin
            c_oe = c_oe + 1;
            mm_note("dout_oe phi1", dut, idx, e, g);
        end
        if(!r_flags[2] && (g[27] !== !e[27])) begin
            c_vp = c_vp + 1;
            mm_note("vp_n", dut, idx, e, g);
        end
        if(!r_flags[2] && e[25] && (dg[63:48] !== g[15:0])) begin
            c_dbg = c_dbg + 1;
            mm_note("dbg_pc at SYNC", dut, idx, e, g);
        end
        if((idx == r_dbg_idx) && ((dg[63:48] !== r_dbg_pc) || (dg[47:16] !== r_dbg_axys) ||
                                  (dg[15:8] !== r_dbg_p) || (dg[7:0] !== r_dbg_ir))) begin
            c_dbg = c_dbg + 1;
            mm_note("dbg_* results", dut, idx, {r_dbg_pc, r_dbg_p, r_dbg_ir}, {dg[63:48], dg[15:8], dg[7:0]});
        end
    end
endtask

task vec_events;
    input integer d;
    integer kk;
    begin
        for(kk = 0; kk < r_nev; kk = kk + 1)
            if(r_ev_d[kk] == d)
                case(r_ev_pin[kk])
                    0: rst_n = r_ev_lvl[kk];
                    1: rdy = r_ev_lvl[kk];
                    2: irq_n = r_ev_lvl[kk];
                    3: nmi_n = r_ev_lvl[kk];
                    4: so_n = r_ev_lvl[kk];
                endcase
    end
endtask

// one scenario
task vec_run;
    input integer rp;
    integer    idx;
    integer    ntot;
    integer    npre;
    integer    rel;
    integer    kk;
    reg [31:0] e;
    reg        cu;
    reg        ch;
    begin
        ntot = 0;
        vec_decode(rp);
        c_bus = 0;
        c_held = 0;
        c_data = 0;
        c_oe = 0;
        c_vp = 0;
        c_dbg = 0;
        c_lock = 0;
        c_harn = 0;
        fm_set = 1'b0;
        cu = r_flags[0];
        ch = r_flags[1] && (tb_ratio > 1);
        inputs_idle();
        wait_cen();
        rst_n = 1'b0;
        cycles(3);
        vec_image();
        boot_vec = 16'h0200;
        boot = 1'b1;
        rst_n = 1'b1;
        run_to_fetch(16'h0200, 0, 40);
        boot = 1'b0;
        if(!found || (ch && !((sync_h === 1'b1) && (addr_h === 16'h0200)))) begin
            c_harn = 1;
            mm_note("boot", 1'b0, 0, 32'h0, {25'h0, addr_u});
        end else begin
            npre = r_flags2[1] ? 22 : 0;
            ntot = npre + r_ncyc;
            for(kk = 0; kk < r_nev; kk = kk + 1)
                if(r_ev_d[kk] < -44)
                    vec_events(r_ev_d[kk]);
            for(idx = 0; idx < ntot; idx = idx + 1) begin
                rel = idx - 22;
                vec_events(2 * rel);
                to_phi2();
                vec_events(2 * rel + 1);
                wait_cen();
                if(idx < npre)
                    e = pre_word(idx, r_s, r_p);
                else
                    e = vec[r_cyc0 + idx - npre];
                if(cu)
                    vec_cmp(1'b0, idx, e);
                if(ch)
                    vec_cmp(1'b1, idx, e);
                if(cu && ch) begin
                    if((rec_u(0) & 41'h0_00_8B_FFFFFF) !== (rec_h(0) & 41'h0_00_8B_FFFFFF)) begin
                        c_lock = c_lock + 1;
                        mm_note("lockstep", 1'b1, idx, e, rec_h(0));
                    end
                    if(e[25] && (idx >= 22) && !r_flags[6] && (recd_u(0) !== recd_h(0))) begin
                        c_lock = c_lock + 1;
                        mm_note("lockstep dbg", 1'b1, idx, e, rec_h(0));
                    end
                end
            end
        end
        inputs_idle();
        if(cu && ch) begin
            g_both = g_both + 1;
            g_lock = g_lock + c_lock;
            g_cyc = g_cyc + ntot;
        end
        f_n[r_fam] = f_n[r_fam] + 1;
        f_cyc[r_fam] = f_cyc[r_fam] + ntot;
        f_bus[r_fam] = f_bus[r_fam] + c_bus;
        f_held[r_fam] = f_held[r_fam] + c_held;
        f_data[r_fam] = f_data[r_fam] + c_data;
        f_oe[r_fam] = f_oe[r_fam] + c_oe;
        f_vp[r_fam] = f_vp[r_fam] + c_vp;
        f_dbg[r_fam] = f_dbg[r_fam] + c_dbg;
        f_lock[r_fam] = f_lock[r_fam] + c_lock;
        f_harn[r_fam] = f_harn[r_fam] + c_harn;
        if(fm_set) begin
            f_bad[r_fam] = f_bad[r_fam] + 1;
            if(info_left > 0) begin
                info_left = info_left - 1;
                $display("INFO: %0s (%0s) cycle %0d: %0s - expected %h %s%s %h, got %h %s%s %h", r_name,
                         fm_dut ? "uuth" : "uut", fm_idx - 22, fm_what, fm_exp[15:0], fm_exp[24] ? "R" : "W",
                         fm_exp[25] ? "*" : " ", fm_exp[23:16], fm_got[15:0], fm_got[24] ? "R" : "W",
                         fm_got[25] ? "*" : " ", fm_got[23:16]);
            end
        end
        if(r_fam == 1) begin
            op_n[r_op] = op_n[r_op] + 1;
            if(r_var == 1)
                op_cx[r_op] = op_cx[r_op] + 1;
            op_mm[r_op] = op_mm[r_op] + c_bus + c_held + c_data + c_oe + c_vp + c_dbg + c_lock + c_harn;
        end
    end
endtask

// every scenario of family fam (every stride-th one), at most max
task vec_run_fam;
    input integer fam;
    input integer stride;
    input integer max;
    integer rr;
    integer seen;
    integer done;
    begin
        seen = 0;
        done = 0;
        for(rr = 0; (rr < rec_cnt) && (done < max); rr = rr + 1)
            if(vec[rec_ptr[rr]][23:16] == fam) begin
                if((seen % stride) == 0) begin
                    vec_run(rec_ptr[rr]);
                    done = done + 1;
                end
                seen = seen + 1;
            end
    end
endtask

// result lines of a family run
task vec_report;
    input integer         fam;
    input [8*72-1:0] label;
    input            with_res;
    begin
        $sformat(nm, "%0s: %0d scenarios, %0d cycles run", label, f_n[fam], f_cyc[fam]);
        check(f_n[fam] > 0, 1, nm);
        $sformat(nm, "%0s: address, R/W and SYNC mismatches", label);
        check_mm(f_bus[fam] + f_harn[fam], nm);
        $sformat(nm, "%0s: write data mismatches", label);
        check_mm(f_data[fam], nm);
        $sformat(nm, "%0s: dout_oe mismatches", label);
        check_mm(f_oe[fam], nm);
        if(with_res) begin
            $sformat(nm, "%0s: held PC while RES is low, mismatches", label);
            check_mm(f_held[fam], nm);
        end else begin
            $sformat(nm, "%0s: vp_n mismatches", label);
            check_mm(f_vp[fam], nm);
        end
        $sformat(nm, "%0s: dbg_* mismatches", label);
        check_mm(f_dbg[fam], nm);
        $sformat(nm, "%0s: CYCLE/HALF lockstep mismatches", label);
        check_mm(f_lock[fam], nm);
    end
endtask

//=========================================================================
// Reference Functions:
// Result and flags of the arithmetic instructions, written from the
// instruction definitions: binary ADC/SBC, and decimal mode (D = 1) by the
// NMOS sequences: ADC forms the low digit AL, the result from the binary
// high digits plus AL with a 60 adjust, N and V from the signed high
// digits plus AL, Z from the binary sum; SBC forms the result digit by
// digit and takes N, V, Z and C from the binary subtraction.
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
            t = (a + m + c) & 255;
            q = s1 & 255;
            ref_adc = {q, (s2 & 128) != 0, (s2 < -128) || (s2 > 127), t == 0, s1 >= 256};
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
    reg   [11:0] b;
    begin
        b = ref_adc(a, ~m, c, 1'b0);
        if(!d) begin
            ref_sbc = b;
        end else begin
            al = (a & 15) - (m & 15) + c - 1;
            if(al < 0)
                al = ((al - 6) & 15) - 16;
            s3 = (a & 240) - (m & 240) + al;
            if(s3 < 0)
                s3 = s3 - 96;
            ref_sbc = {s3[7:0], b[3:0]};
        end
    end
endfunction

//=========================================================================
// Decimal Sweep Checker:
// While dec_on = 1, a write of uut to F000 (the result A) followed by the
// next stack write (P pushed by PHP) closes one case. Cases run C outer, A
// middle, operand inner (index (C << 16) | (A << 8) | operand). dec_kind:
// 0 ADC #, 1 SBC #, 2 SBC #$EB form, 3 ISC zp, 4 RRA zp (operand = the byte
// before the read-modify-write). With +q03=<file> (records [A, pushed P]
// of the same cases, six blocks of 131,072 in the order ADC, SBC, SBC $EB,
// ISC, RRA, ARR) the results are also compared with that table, and the
// reference with the table.
//=========================================================================
reg         dec_on;
integer     dec_kind;
integer     dec_case;
integer     dec_mm;
integer     dec_tmm;
integer     dec_rmm;
reg   [7:0] dec_a;
reg         dec_have_a;
reg         q03_loaded;
reg   [7:0] q03 [0:1572863];
reg  [11:0] dec_e;
reg   [7:0] dec_r;
reg   [7:0] dec_ep;
reg   [7:0] dec_ta;
reg   [7:0] dec_tp;
integer     dec_ti;

always @(posedge clk) begin
    if(dec_on && cen && (rw_u === 1'b0)) begin
        if(addr_u === 16'hF000) begin
            dec_a = dout_u;
            dec_have_a = 1'b1;
        end else if((addr_u[15:8] === 8'h01) && dec_have_a) begin
            case(dec_kind)
                0: dec_e = ref_adc(dec_case[15:8], dec_case[7:0], dec_case[16], 1'b1);
                1, 2: dec_e = ref_sbc(dec_case[15:8], dec_case[7:0], dec_case[16], 1'b1);
                3: begin
                    dec_r = dec_case[7:0] + 8'd1;
                    dec_e = ref_sbc(dec_case[15:8], dec_r, dec_case[16], 1'b1);
                end
                default: begin
                    dec_r = {dec_case[16], dec_case[7:1]};
                    dec_e = ref_adc(dec_case[15:8], dec_r, dec_case[0], 1'b1);
                end
            endcase
            dec_ep = {dec_e[3], dec_e[2], 1'b1, 1'b1, 1'b1, 1'b0, dec_e[1], dec_e[0]};
            if((dec_a !== dec_e[11:4]) || ((dout_u & 8'hFB) !== dec_ep))
                dec_mm = dec_mm + 1;
            if(q03_loaded) begin
                dec_ti = 2 * (dec_kind * 131072 + dec_case);
                dec_ta = q03[dec_ti];
                dec_tp = q03[dec_ti + 1];
                if((dec_a !== dec_ta) || ((dout_u & 8'hC3) !== (dec_tp & 8'hC3)))
                    dec_tmm = dec_tmm + 1;
                if((dec_e[11:4] !== dec_ta) || ((dec_ep & 8'hC3) !== (dec_tp & 8'hC3)))
                    dec_rmm = dec_rmm + 1;
            end
            dec_case = dec_case + 1;
            dec_have_a = 1'b0;
        end
    end
end

task q03_load;
    reg [8*256-1:0] f;
    integer         fd;
    integer         r;
    begin
        q03_loaded = 1'b0;
        if($value$plusargs("q03=%s", f)) begin
            fd = $fopen(f, "rb");
            if(fd != 0) begin
                r = $fread(q03, fd);
                $fclose(fd);
                q03_loaded = (r == 1572864);
            end
        end
    end
endtask

//=========================================================================
// Main Test Sequence:
//=========================================================================
initial begin
    $display("=============================================================");
    $display("  x6502 Comprehensive Testbench");
    $display("  Reference: MOS Technology MCS6500 Hardware Manual");
    $display("=============================================================");

    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;
    seed = 32'h6502;
    en_seed = 32'h1976;
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

    //---------------------------------------------------------------------
    // CPU SECTION A: Reset
    // Power-up values, the reset sequence and what it keeps, the bus while
    // RES is low, one-edge RES and RES sampled only at cen, writes in the
    // cycle RES falls, the two timing exceptions, the register rule for a
    // cut instruction, and the netlist RES sweeps at three enable ratios.
    // [p.041], [p.053], [p.159]
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
    check(jam_u, 1'b0, "A.1 power-up jam = 0");
    check({rw_u, oe_u}, 2'b10, "A.1 power-up R/W = 1, dout_oe = 0");
    check(^outs_u === 1'bx, 1'b0, "A.1 power-up: no output is X (uut, cen_p2 unconnected)");
    check(^outs_h === 1'bx, 1'b0, "A.1 power-up: no output is X (uuth)");
    check(outs_h === outs_u, 1'b1, "A.1 power-up: uuth outputs equal uut");

    //---------------------------------------------------------------------
    // A.2 First reset: RES held low from power-up while the enables start,
    // released in phi1 of cycle c: s = c + 1, stack reads at s+3..s+5
    // (0100+S, S-1, S-2 with S = 00), FFFC/FFFD at s+6/s+7, first fetch
    // at s+8; no write since power-up; SYNC only at s+1.
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
    // A.3 A warm reset keeps A, X, Y, N, V, D, Z, C, lowers S by 3 and sets
    // I; RES low across one cen only. Program: CLD; CLC; LDA #40; ADC #40;
    // LDX #80; TXS; LDX #5A; LDY #C3; SEC; SED; JMP self. Ratios 2 and 5.
    //---------------------------------------------------------------------
    section("CPU SECTION A.3: Registers Kept by a Warm Reset");
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
        $sformat(nm, "A.3 ratio %0d: kept A X Y N V D Z C, S = 80 - 3, I = 1", tb_ratio);
        check_regs(8'h80, 8'h5A, 8'hC3, 8'h7D, 8'hCD, nm);
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
    // the held PC H with SYNC only at s+1; no write after cycle r. The LDA
    // loads A only when its last cycle is r or r+1 (register rule).
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
        $sformat(nm, "A.5 RES from LDA cycle %0d: r+2 .. s+2 hold H = %h, SYNC only at s+1", n, tmp32[15:0]);
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
    // (A = 5A) and INC 1234 (byte 41), RES held for three edges.
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
                check(writes_in(k, k + 9), 0, "A.7 INC, RES first low at the data read: neither write happens");
                check(bus_is(k + 1, 16'h1234, 1'b1, 1'b0), 1'b1, "A.7 INC: cycle r+1 shows 1234 as a read");
            end
            5: begin
                check(bus_is(k, 16'h1234, 1'b0, 1'b0) && (ra_u(k) & 41'h0_00_00_FF0000) === 41'h0_00_00_410000, 1'b1,
                      "A.7 INC, RES first low at the first write: the unmodified write of 41 happens");
                check(writes_in(k + 1, k + 9), 0, "A.7 INC: the modified write does not happen");
            end
            default: begin
                check(bus_is(k, 16'h1234, 1'b0, 1'b0) && (ra_u(k) & 41'h0_00_00_FF0000) === 41'h0_00_00_420000, 1'b1,
                      "A.7 INC, RES first low at the second write: the modified write of 42 happens");
                check(writes_in(k + 1, k + 9), 0, "A.7 INC: no write after cycle r");
            end
        endcase
    end

    //---------------------------------------------------------------------
    // A.8 The two timing exceptions. (a) RES low at the edge that starts
    // cycle 3 of a taken branch without page cross, one edge: cycle r+1
    // is the fetch at the target with SYNC (it is s+1), FFFC at r+6.
    // (b) RES low at one edge whose cycle r+1 is the data read of a
    // read-modify-write: the two write cycles follow as reads (SYNC in the
    // first), cycle r+3 counts as s, FFFC at r+9.
    //---------------------------------------------------------------------
    section("CPU SECTION A.8: RES Timing Exceptions");
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
    check(bus_is(k + 1, 16'h0412, 1'b1, 1'b1), 1'b1, "A.8 (a) taken branch cut at cycle 3: r+1 fetches 0412 with SYNC");
    check(bus_rs(k + 2, 1'b1, 1'b0), 1'b1, "A.8 (a) r+2 = s+2: SYNC = 0");
    check(bus_is(k + 3, 16'h01FF, 1'b1, 1'b0) && bus_is(k + 6, 16'hFFFC, 1'b1, 1'b0), 1'b1,
          "A.8 (a) stack reads from r+3, FFFC at r+6 (one cycle early)");
    check(fetch_cyc, 8, "A.8 (a) vector fetch at r+8");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0600);
    put(16'h1234, 8'h41);
    org(16'h0400);
    pb3(8'hEE, 8'h34, 8'h12);
    start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    base = tr_n;
    cycles(1);
    rst_n = 1'b0;
    wait_cen();
    rst_n = 1'b1;
    run_to_fetch(16'h0500, 0, 30);
    k = base + 2;
    check(bus_is(k + 1, 16'h1234, 1'b1, 1'b0), 1'b1, "A.8 (b) RMW: r+1 is the data read of 1234");
    check(bus_rs(k + 2, 1'b1, 1'b1) && bus_rs(k + 3, 1'b1, 1'b0), 1'b1,
          "A.8 (b) RMW: r+2 and r+3 are reads, SYNC in r+2");
    check(bus_rs(k + 4, 1'b1, 1'b1) && bus_rs(k + 5, 1'b1, 1'b0), 1'b1, "A.8 (b) RMW: s+1 = r+4 with SYNC");
    check(bus_is(k + 6, 16'h01FF, 1'b1, 1'b0) && bus_is(k + 9, 16'hFFFC, 1'b1, 1'b0), 1'b1,
          "A.8 (b) RMW: stack reads from r+6, FFFC at r+9");
    check(writes_in(k, k + 10), 0, "A.8 (b) RMW: no write");

    //---------------------------------------------------------------------
    // A.9 Netlist RES sweeps: RES falling at every row of 16 contexts
    // (widths 1-16 half cycles), and RES across 1, 2 and 8 edges from every
    // cycle of every opcode variant; at ratios 4, 2 and 5. The address in
    // cycles r+2 .. s+2 is x6502's held PC.
    //---------------------------------------------------------------------
    section("CPU SECTION A.9: RES at Every Cycle (netlist scenarios)");
    for(t = 0; t < 3; t = t + 1) begin
        tb_ratio = (t == 0) ? 4 : (t == 1) ? 2 : 5;
        vec_clear_counts();
        info_left = 3;
        vec_run_fam(11, 1, 100000);
        $sformat(nm, "A.9 RES in 16 contexts, ratio %0d", tb_ratio);
        vec_report(11, nm, 1'b1);
    end
    tb_ratio = 4;
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(13, 1, 100000);
    vec_report(13, "A.9 RES in every opcode variant, ratio 4", 1'b1);

    //---------------------------------------------------------------------
    // A.10 RDY during the RES protocol: RES across 1 or 2 edges in NOPs, a
    // taken branch (its third cycle) and INC zp (its data read), RDY low 1
    // or 2 edges from the edge RES is first seen low to three edges after
    // release. A hold at the end of the cycle RES was first seen low
    // repeats that cycle as the next one; the cycle that starts with RES
    // high waits for RDY; the branch target fetch with SYNC and the data
    // read of the read-modify-write repeat while RDY is low. The address
    // in cycles r+2 .. s+2 is not compared. Ratios 4 and 2. [p.050], [p.053]
    //---------------------------------------------------------------------
    section("CPU SECTION A.10: RDY during the RES Protocol (netlist scenarios)");
    for(t = 0; t < 2; t = t + 1) begin
        tb_ratio = (t == 0) ? 4 : 2;
        vec_clear_counts();
        info_left = 3;
        vec_run_fam(18, 1, 100000);
        $sformat(nm, "A.10 RES with RDY in NOPs, a taken branch and INC zp, ratio %0d", tb_ratio);
        vec_report(18, nm, 1'b1);
    end

    //---------------------------------------------------------------------
    // A.11 RES first seen low inside a running reset sequence: a second RES
    // of 1 or 2 edges at every cycle from s+1 to s+8 of the first sequence,
    // without RDY or with RDY low at the next edge or at the RES edge and
    // the next. At s+5 the sequence ends after the $FFFC read at {byte,
    // $FD} (one more read while RES is still low); at s+6 RES has no
    // effect; elsewhere a new sequence runs. Ratios 4 and 2. [p.053]
    //---------------------------------------------------------------------
    section("CPU SECTION A.11: RES inside a Running Reset Sequence (netlist scenarios)");
    for(t = 0; t < 2; t = t + 1) begin
        tb_ratio = (t == 0) ? 4 : 2;
        vec_clear_counts();
        info_left = 3;
        vec_run_fam(19, 1, 100000);
        $sformat(nm, "A.11 second RES at every cycle of a reset sequence, ratio %0d", tb_ratio);
        vec_report(19, nm, 1'b1);
    end
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // A.12 End of a running reset sequence with RES and RDY at its last
    // edges: every combination of RES at the edges that start the third
    // stack read, the $FFFC read, the $FFFD read and the fetch, with RDY
    // at the four edges from the one that starts the $FFFC read. RES
    // first seen at the third stack read ends the sequence after the
    // $FFFC read at {byte, $FD}, or {byte, $FC} when first seen at a RDY
    // repeat of that read; RES at the start of the last instance of the
    // $FFFC read decides the extra read there. Ratios 4 and 2. [p.050],
    // [p.053]
    //---------------------------------------------------------------------
    section("CPU SECTION A.12: RES and RDY at a Reset Sequence End (netlist scenarios)");
    for(t = 0; t < 2; t = t + 1) begin
        tb_ratio = (t == 0) ? 4 : 2;
        vec_clear_counts();
        info_left = 3;
        vec_run_fam(24, 1, 100000);
        $sformat(nm, "A.12 RES and RDY at the last edges of a reset sequence, ratio %0d", tb_ratio);
        vec_report(24, nm, 1'b1);
    end
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // A.13 S and the vector low read of a reset sequence cut by RES under
    // RDY: the grid of A.12 after a first RES at the second cycle of a NOP
    // (the sequence at the held PC 0403 or 0417). S drops by 3 when the
    // first instance of the third stack read ends, also when RES then
    // starts a new sequence. RES first seen at the $FFFC read with RDY
    // low at the next edge ends the sequence after that read at {byte,
    // held PC low byte with bit 1 cleared}. Ratios 4 and 2. [p.050],
    // [p.053]
    //---------------------------------------------------------------------
    section("CPU SECTION A.13: S and the Vector Read of a Cut Reset Sequence (netlist scenarios)");
    for(t = 0; t < 2; t = t + 1) begin
        tb_ratio = (t == 0) ? 4 : 2;
        vec_clear_counts();
        info_left = 3;
        vec_run_fam(25, 1, 100000);
        $sformat(nm, "A.13 S and the vector low read of a cut reset sequence, ratio %0d", tb_ratio);
        vec_report(25, nm, 1'b1);
    end
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // BUS SECTION B: Bus Cycles per Addressing Mode
    // Every opcode in every variant (page cross or not; branch not taken,
    // taken, crossing forward and backward; JMP (abs) at a page end) run
    // from netlist scenarios: address, R/W and SYNC of every cycle in both
    // halves, write data, dout_oe (whole write cycle in CYCLE mode, phi2
    // only in HALF mode), vp_n, and the results the observation code then
    // writes. [p.168]-[p.180]
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" BUS SECTION B: Bus Cycles per Addressing Mode");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;

    section("BUS SECTION B.1: Every Opcode Variant (netlist scenarios)");
    tb_ratio = 4;
    vec_clear_counts();
    info_left = 6;
    vec_run_fam(1, 1, 100000);
    vec_report(1, "B.1 opcode scenarios", 1'b0);

    section("BUS SECTION B.2: Addressing Mode Groups");
    for(k = 1; k <= 13; k = k + 1) begin
        n = 0;
        t = 0;
        errs = 0;
        for(j = 0; j < 256; j = j + 1)
            if(op_grp[j] == k) begin
                n = n + 1;
                t = t + op_n[j];
                errs = errs + op_mm[j] + ((op_n[j] == 0) ? 1 : 0);
            end
        $sformat(nm, "B.2 %0s: %0d opcodes, %0d scenarios: mismatches", grp_name[k], n, t);
        check_mm(errs, nm);
    end

    //---------------------------------------------------------------------
    // B.3 Data bus window of one write (STA 1234, A = 5A) and of the two
    // writes of a read-modify-write (INC 1235 on 41: 41 then 42).
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
    check(({ra_u(base + 8), ra_u(base + 9)} & {41'h0_00_3F_FFFFFF, 41'h0_00_3F_FFFFFF}) ===
          {9'h0, 8'b00111100, 8'h41, 16'h1235, 9'h0, 8'b00111100, 8'h42, 16'h1235}, 1'b1,
          "B.3 INC 1235: writes 41 (unmodified) then 42, uut");
    check(({ra_h(base + 8), ra_h(base + 9)} & {41'h0_00_3F_FFFFFF, 41'h0_00_3F_FFFFFF}) ===
          {9'h0, 8'b00011100, 8'h41, 16'h1235, 9'h0, 8'b00011100, 8'h42, 16'h1235}, 1'b1,
          "B.3 INC 1235: writes 41 then 42, uuth dout_oe in phi2 only");

    //---------------------------------------------------------------------
    // CPU SECTION C: All 256 Opcodes
    // Per opcode, the scenarios of B.1: every cycle and the results (P, A,
    // X, Y and S written by the observation code, dbg_* at the next fetch).
    // Then random documented instruction streams. Contention and unstable
    // opcodes follow the recorded choices (Section E).
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CPU SECTION C: All 256 Opcodes");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;

    section("CPU SECTION C.1: Opcodes 00-FF (netlist scenarios of B.1)");
    for(j = 0; j < 256; j = j + 1) begin
        if(op_cx[j] > 0)
            $sformat(nm, "C.1 $%h %0s: %0d scenarios (%0d page cross): mismatches", j[7:0], op_name[j], op_n[j],
                     op_cx[j]);
        else
            $sformat(nm, "C.1 $%h %0s: %0d scenarios: mismatches", j[7:0], op_name[j], op_n[j]);
        check_mm(op_mm[j] + ((op_n[j] == 0) ? 1 : 0), nm);
    end

    section("CPU SECTION C.2: Random Instruction Streams (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(2, 1, 100000);
    vec_report(2, "C.2 random documented streams", 1'b0);

    //---------------------------------------------------------------------
    // ALU SECTION D: Arithmetic and Logic
    // D.1 drives x6502_alu directly over every operand pair and carry in,
    // D = 0 and 1 for ADC and SBC; D.2 runs decimal ADC, SBC, SBC $EB, ISC
    // and RRA through the CPU over every A x operand x C (131,072 cases
    // each) and checks the stored A and the pushed P.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" ALU SECTION D: Arithmetic and Logic");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    q03_load();
    if(q03_loaded)
        info("D: decimal results also compared with the recorded table (+q03)");

    section("ALU SECTION D.1: Every Operation, Every Input");
    for(k = 0; k < 13; k = k + 1) begin
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
            default: alu_op = ALU_DEC;
        endcase
        errs = 0;
        errs2 = 0;
        n = 0;
        for(i = 0; i < 256; i = i + 1)
            for(j = 0; j < ((k >= 7) ? 1 : 256); j = j + 1)
                for(t = 0; t < ((k == 3) || (k == 4) ? 4 : 2); t = t + 1) begin
                    alu_a = i;
                    alu_b = (k >= 7) ? $random(seed) : j;
                    tmp8 = $random(seed);
                    alu_pin = {tmp8[7:6], 2'b11, (k == 3) || (k == 4) ? t[1] : tmp8[3], tmp8[2:1], t[0]};
                    #1;
                    // expected {q, N, V, Z, C}; tmp32[16] = q compared
                    case(k)
                        0: tmp16 = {alu_a | alu_b, 8'h00};
                        1: tmp16 = {alu_a & alu_b, 8'h00};
                        2: tmp16 = {alu_a ^ alu_b, 8'h00};
                        default: tmp16 = 16'h0000;
                    endcase
                    tmp8b = alu_pin;
                    if(k <= 2) begin
                        tmp32 = {7'h0, 1'b1, tmp16[15:8], tmp16[15], alu_pin[6], tmp16[15:8] == 8'h00, alu_pin[0]};
                    end else if(k == 3) begin
                        tmp16 = ref_adc(alu_a, alu_b, alu_pin[0], alu_pin[3]);
                        tmp32 = {7'h0, 1'b1, tmp16[11:0]};
                    end else if(k == 4) begin
                        tmp16 = ref_sbc(alu_a, alu_b, alu_pin[0], alu_pin[3]);
                        tmp32 = {7'h0, 1'b1, tmp16[11:0]};
                    end else if(k == 5) begin
                        tmp16 = ref_adc(alu_a, ~alu_b, 1'b1, 1'b0);
                        tmp32 = {7'h0, 1'b0, tmp16[11:4], tmp16[3], alu_pin[6], tmp16[1], tmp16[0]};
                    end else if(k == 6) begin
                        tmp32 = {7'h0, 1'b0, 8'h00, alu_b[7], alu_b[6], (alu_a & alu_b) == 8'h00, alu_pin[0]};
                    end else begin
                        case(k)
                            7: tmp16 = {alu_a[6:0], 1'b0, 7'h0, alu_a[7]};
                            8: tmp16 = {alu_a[6:0], alu_pin[0], 7'h0, alu_a[7]};
                            9: tmp16 = {1'b0, alu_a[7:1], 7'h0, alu_a[0]};
                            10: tmp16 = {alu_pin[0], alu_a[7:1], 7'h0, alu_a[0]};
                            11: tmp16 = {alu_a + 8'd1, 7'h0, alu_pin[0]};
                            default: tmp16 = {alu_a - 8'd1, 7'h0, alu_pin[0]};
                        endcase
                        tmp32 = {7'h0, 1'b1, tmp16[15:8], tmp16[15], alu_pin[6], tmp16[15:8] == 8'h00, tmp16[0]};
                    end
                    n = n + 1;
                    if((tmp32[12] && (alu_q !== tmp32[11:4])) ||
                       ({alu_pout[7:6], alu_pout[3:0]} !== {tmp32[3:2], alu_pin[3:2], tmp32[1:0]})) begin
                        errs = errs + 1;
                        if(errs <= 2)
                            $display("INFO: D.1 op %h a %h b %h p_in %h: q %h p_out %h, expected q %h NVZC %b",
                                     alu_op, alu_a, alu_b, alu_pin, alu_q, alu_pout, tmp32[11:4], tmp32[3:0]);
                    end
                    if(q03_loaded && ((k == 3) || (k == 4)) && alu_pin[3]) begin
                        tmp32 = 2 * ((k - 3) * 131072 + alu_pin[0] * 65536 + alu_a * 256 + alu_b);
                        if((alu_q !== q03[tmp32]) || ((alu_pout & 8'hC3) !== (q03[tmp32 + 1] & 8'hC3)))
                            errs2 = errs2 + 1;
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
            default: $sformat(nm, "D.1 DEC (%0d inputs): mismatches", n);
        endcase
        check_mm(errs, nm);
        if(q03_loaded && ((k == 3) || (k == 4))) begin
            $sformat(nm, "D.1 %0s decimal against the recorded table (131072 inputs): mismatches", (k == 3) ? "ADC" : "SBC");
            check_mm(errs2, nm);
        end
    end
    // a few named decimal points
    alu_op = ALU_ADC;
    alu_a = 8'h99; alu_b = 8'h01; alu_pin = 8'h38; #1;
    check({alu_q, alu_pout[7:6], alu_pout[1:0]}, {8'h00, 4'b1001}, "D.1 ADC D=1 99 + 01: 00, N V Z C = 1 0 0 1 (Z of binary 9A)");
    alu_a = 8'h80; alu_b = 8'h80; alu_pin = 8'h38; #1;
    check({alu_q, alu_pout[7:6], alu_pout[1:0]}, {8'h60, 4'b0111}, "D.1 ADC D=1 80 + 80: 60, V = 1, Z = 1, C = 1");
    alu_op = ALU_SBC;
    alu_a = 8'h00; alu_b = 8'h01; alu_pin = 8'h39; #1;
    check({alu_q, alu_pout[7:6], alu_pout[1:0]}, {8'h99, 4'b1000}, "D.1 SBC D=1 00 - 01: 99, N = 1, C = 0");

    //---------------------------------------------------------------------
    // D.2 Decimal mode through the CPU, ratio 1 (uut). The program at 0400
    // loops C, A and the operand, sets C with LSR, runs the instruction
    // with D = 1, stores A to F000 and pushes P.
    //---------------------------------------------------------------------
    section("ALU SECTION D.2: Decimal Mode through the CPU, Every Input");
    tb_ratio = 1;
    for(k = 0; k < 5; k = k + 1) begin
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
        if(k <= 2)
            pb3(8'h8D, 8'h18, 8'h04);
        else
            pb3(8'h8D, 8'h13, 8'h00);
        pb2(8'hA5, 8'h12);
        pb(8'h4A);
        pb2(8'hA5, 8'h11);
        case(k)
            0: pb2(8'h69, 8'h00);
            1: pb2(8'hE9, 8'h00);
            2: pb2(8'hEB, 8'h00);
            3: pb2(8'hE7, 8'h13);
            default: pb2(8'h67, 8'h13);
        endcase
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
        dec_tmm = 0;
        dec_rmm = 0;
        dec_have_a = 1'b0;
        boot_to(16'h0400);
        dec_on = 1'b1;
        guard = 0;
        while((dec_case < 131072) && (guard < 700)) begin
            #100000;
            guard = guard + 1;
        end
        dec_on = 1'b0;
        case(k)
            0: tmp32 = "ADC";
            1: tmp32 = "SBC";
            2: tmp32 = "$EB";
            3: tmp32 = "ISC";
            default: tmp32 = "RRA";
        endcase
        $sformat(nm, "D.2 %0s with D = 1: cases run", tmp32);
        check(dec_case, 131072, nm);
        $sformat(nm, "D.2 %0s with D = 1: A and N V Z C mismatches", tmp32);
        check_mm(dec_mm, nm);
        if(q03_loaded) begin
            $sformat(nm, "D.2 %0s with D = 1: mismatches against the recorded table", tmp32);
            check_mm(dec_tmm, nm);
            $sformat(nm, "D.2 %0s with D = 1: reference against the recorded table", tmp32);
            check_mm(dec_rmm, nm);
        end
    end
    tb_ratio = 4;

    //---------------------------------------------------------------------
    // CPU SECTION E: Undocumented Opcodes
    // Named cases of the immediate group (ANE and LXA with the constant EE,
    // ANC, ALR, ARR in binary and decimal mode, SBX, the SBC copy at EB),
    // LAS, and SHA, SHX, SHY, TAS with and without a page cross and with
    // RDY holding the cycle before the write. Every opcode and variant is
    // also run in Sections B and C.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CPU SECTION E: Undocumented Opcodes");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    tb_ratio = 4;

    section("CPU SECTION E.1: ANE and LXA (constant EE)");
    mem_new(8'hEA);
    vectors(16'h0600, 16'h0500, 16'h0700);
    run1(8'h8B, 8'hFF, 8'hEA, 8'hFF, 8'h04, 8'h00, 8'hFF, 8'h00);
    check_regs(8'hEE, 8'hFF, 8'h00, 8'hFF, 8'h84, "E.1 ANE #FF, A = 00, X = FF: A = (A OR EE) AND X AND imm = EE");
    mem_new(8'hEA);
    run1(8'h8B, 8'hF0, 8'hEA, 8'hFF, 8'h04, 8'hFF, 8'h0F, 8'h00);
    check_regs(8'h00, 8'h0F, 8'h00, 8'hFF, 8'h06, "E.1 ANE #F0, A = FF, X = 0F: A = 00, Z = 1");
    mem_new(8'hEA);
    run1(8'hAB, 8'hFF, 8'hEA, 8'hFF, 8'h04, 8'h00, 8'h55, 8'h00);
    check_regs(8'hEE, 8'hEE, 8'h00, 8'hFF, 8'h84, "E.1 LXA #FF, A = 00: A = X = (A OR EE) AND imm = EE");
    mem_new(8'hEA);
    run1(8'hAB, 8'h0F, 8'hEA, 8'hFF, 8'h04, 8'h11, 8'h99, 8'h00);
    check_regs(8'h0F, 8'h0F, 8'h00, 8'hFF, 8'h04, "E.1 LXA #0F, A = 11: A = X = 0F");

    section("CPU SECTION E.2: ANC, ALR, ARR");
    mem_new(8'hEA);
    run1(8'h0B, 8'h8F, 8'hEA, 8'hFF, 8'h04, 8'hF0, 8'h00, 8'h00);
    check_regs(8'h80, 8'h00, 8'h00, 8'hFF, 8'h85, "E.2 ANC (0B) #8F, A = F0: A = 80, N = C = 1");
    mem_new(8'hEA);
    run1(8'h2B, 8'hF0, 8'hEA, 8'hFF, 8'h05, 8'h0F, 8'h00, 8'h00);
    check_regs(8'h00, 8'h00, 8'h00, 8'hFF, 8'h06, "E.2 ANC (2B) #F0, A = 0F, C = 1: A = 00, Z = 1, C = 0");
    mem_new(8'hEA);
    run1(8'h4B, 8'h03, 8'hEA, 8'hFF, 8'h04, 8'hFF, 8'h00, 8'h00);
    check_regs(8'h01, 8'h00, 8'h00, 8'hFF, 8'h05, "E.2 ALR #03, A = FF: t = 03, A = 01, C = 1");
    mem_new(8'hEA);
    run1(8'h4B, 8'hFE, 8'hEA, 8'hFF, 8'h05, 8'h01, 8'h00, 8'h00);
    check_regs(8'h00, 8'h00, 8'h00, 8'hFF, 8'h06, "E.2 ALR #FE, A = 01: A = 00, Z = 1, C = 0");
    mem_new(8'hEA);
    run1(8'h6B, 8'hFF, 8'hEA, 8'hFF, 8'h05, 8'hFF, 8'h00, 8'h00);
    check_regs(8'hFF, 8'h00, 8'h00, 8'hFF, 8'h85, "E.2 ARR #FF, A = FF, C = 1, D = 0: A = FF, N = 1, C = 1, V = 0");
    mem_new(8'hEA);
    run1(8'h6B, 8'h40, 8'hEA, 8'hFF, 8'h04, 8'hFF, 8'h00, 8'h00);
    check_regs(8'h20, 8'h00, 8'h00, 8'hFF, 8'h44, "E.2 ARR #40, A = FF, C = 0, D = 0: A = 20, V = 1, C = 0");
    mem_new(8'hEA);
    run1(8'h6B, 8'hFF, 8'hEA, 8'hFF, 8'h0C, 8'hFF, 8'h00, 8'h00);
    check_regs(8'hD5, 8'h00, 8'h00, 8'hFF, 8'h0D, "E.2 ARR #FF, A = FF, C = 0, D = 1: A = D5, C = 1");
    mem_new(8'hEA);
    run1(8'h6B, 8'hFF, 8'hEA, 8'hFF, 8'h0D, 8'h12, 8'h00, 8'h00);
    check_regs(8'h89, 8'h00, 8'h00, 8'hFF, 8'h8C, "E.2 ARR #FF, A = 12, C = 1, D = 1: A = 89, N = 1, C = 0");

    section("CPU SECTION E.3: SBX, USBC, LAS");
    mem_new(8'hEA);
    run1(8'hCB, 8'h10, 8'hEA, 8'hFF, 8'h04, 8'hF0, 8'h3C, 8'h00);
    check_regs(8'hF0, 8'h20, 8'h00, 8'hFF, 8'h05, "E.3 SBX #10, A = F0, X = 3C: X = (A AND X) - 10 = 20, C = 1");
    mem_new(8'hEA);
    run1(8'hCB, 8'h40, 8'hEA, 8'hFF, 8'h05, 8'hF0, 8'h3C, 8'h00);
    check_regs(8'hF0, 8'hF0, 8'h00, 8'hFF, 8'h84, "E.3 SBX #40: X = F0, N = 1, C = 0 (carry in ignored)");
    mem_new(8'hEA);
    run1(8'hEB, 8'h01, 8'hEA, 8'hFF, 8'h05, 8'h05, 8'h00, 8'h00);
    check_regs(8'h04, 8'h00, 8'h00, 8'hFF, 8'h05, "E.3 SBC #01 at EB, A = 05, C = 1: A = 04");
    mem_new(8'hEA);
    run1(8'hEB, 8'h01, 8'hEA, 8'hFF, 8'h0D, 8'h10, 8'h00, 8'h00);
    check_regs(8'h09, 8'h00, 8'h00, 8'hFF, 8'h0D, "E.3 SBC #01 at EB, D = 1, A = 10: A = 09");
    mem_new(8'hEA);
    put(16'h1234, 8'hF3);
    run1(8'hBB, 8'h34, 8'h12, 8'h5F, 8'h04, 8'h00, 8'h00, 8'h00);
    check_regs(8'h53, 8'h53, 8'h00, 8'h53, 8'h04, "E.3 LAS 1234,Y, M = F3, S = 5F: A = X = S = 53");
    mem_new(8'hEA);
    put(16'h1234, 8'h80);
    run1(8'hBB, 8'h34, 8'h12, 8'hFF, 8'h04, 8'h00, 8'h00, 8'h00);
    check_regs(8'h80, 8'h80, 8'h00, 8'h80, 8'h84, "E.3 LAS 1234,Y, M = 80, S = FF: A = X = S = 80, N = 1");

    //---------------------------------------------------------------------
    // E.4 SHA, SHX, SHY, TAS: value V AND (H + 1); on a page cross the high
    // byte of the address is (H + 1) AND V. RDY holding cycle 4 (cycle 5
    // for 93) drops the AND term; the held repeat shows the write address.
    //---------------------------------------------------------------------
    section("CPU SECTION E.4: SHA, SHX, SHY, TAS");
    for(n = 0; n < 11; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        put(16'h0070, 8'hFF);
        put(16'h0071, 8'h12);
        org(16'h0400);
        case(n)
            0, 6, 9: pb3(8'h9E, 8'h34, 8'h12);
            1, 7, 10: pb3(8'h9E, 8'hFF, 8'h12);
            2: pb3(8'h9C, 8'hFF, 8'h12);
            3: pb3(8'h9F, 8'hFF, 8'h12);
            4, 8: pb2(8'h93, 8'h70);
            default: pb3(8'h9B, 8'hFF, 8'h12);
        endcase
        case(n)
            0, 6, 9: start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h0F, 8'h01);
            1, 7, 10: start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h0F, 8'h02);
            2: start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'h00, 8'h02, 8'hF0);
            3: start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'hFF, 8'h33, 8'h02);
            4, 8: start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'hF0, 8'h3F, 8'h02);
            default: start_at(16'h0400, 16'h0200, 8'hFF, 8'h04, 8'hF7, 8'h7F, 8'h02);
        endcase
        base = tr_n;
        if((n >= 6) && (n <= 8)) begin
            cycles((n == 8) ? 4 : 3);
            rdy = 1'b0;
            wait_cen();
            rdy = 1'b1;
        end else if(n >= 9) begin
            cycles(2);
            rdy = 1'b0;
            wait_cen();
            rdy = 1'b1;
        end
        run_to_fetch(16'h0000, 1'b1, 20);
        case(n)
            0: begin
                tmp32 = {16'h1235, 8'h03};
                k = base + 4;
                nm = "E.4 SHX 1234,Y, X = 0F, Y = 01 (no cross): writes X AND 13 = 03 at 1235";
            end
            1: begin
                tmp32 = {16'h0301, 8'h03};
                k = base + 4;
                nm = "E.4 SHX 12FF,Y, X = 0F, Y = 02 (cross): writes 03 at (13 AND 0F)01 = 0301";
            end
            2: begin
                tmp32 = {16'h1001, 8'h10};
                k = base + 4;
                nm = "E.4 SHY 12FF,X, Y = F0, X = 02 (cross): writes 10 at 1001";
            end
            3: begin
                tmp32 = {16'h1301, 8'h13};
                k = base + 4;
                nm = "E.4 SHA 12FF,Y, A AND X = 33 (cross): writes 13 at 1301";
            end
            4: begin
                tmp32 = {16'h1001, 8'h10};
                k = base + 5;
                nm = "E.4 SHA (70),Y, pointer 12FF, A AND X = 30 (cross): writes 10 at 1001";
            end
            5: begin
                tmp32 = {16'h1301, 8'h13};
                k = base + 4;
                nm = "E.4 TAS 12FF,Y, A AND X = 77 (cross): writes 13 at 1301";
            end
            6: begin
                tmp32 = {16'h1235, 8'h0F};
                k = base + 5;
                nm = "E.4 SHX 1234,Y, RDY holds cycle 4: writes X = 0F at 1235";
            end
            7: begin
                tmp32 = {16'h0301, 8'h0F};
                k = base + 5;
                nm = "E.4 SHX 12FF,Y (cross), RDY holds cycle 4: writes X = 0F, address still 0301";
            end
            8: begin
                tmp32 = {16'h1001, 8'h30};
                k = base + 6;
                nm = "E.4 SHA (70),Y (cross), RDY holds cycle 5: writes A AND X = 30 at 1001";
            end
            9: begin
                tmp32 = {16'h1235, 8'h03};
                k = base + 5;
                nm = "E.4 SHX 1234,Y, RDY holds cycle 3: AND term kept, 03 at 1235";
            end
            default: begin
                tmp32 = {16'h0301, 8'h03};
                k = base + 5;
                nm = "E.4 SHX 12FF,Y (cross), RDY holds cycle 3: 03 at 0301";
            end
        endcase
        check(bus_is(k, tmp32[23:8], 1'b0, 1'b0) && (wbyte(k) === tmp32[7:0]) &&
              (writes_in(base, k - 1) == 0), 1'b1, nm);
        if(n == 5) begin
            readout(addr_u);
            check(ro_s_u, 8'h77, "E.4 TAS: S = A AND X = 77");
        end
        if(n == 7)
            check(bus_is(base + 3, 16'h1201, 1'b1, 1'b0) && bus_is(base + 4, 16'h0301, 1'b1, 1'b0), 1'b1,
                  "E.4 SHX cross, held: cycle 4 reads 1201, the held repeat reads the write address 0301");
        if(n == 8)
            check(bus_is(base + 4, 16'h1201, 1'b1, 1'b0) && bus_is(base + 5, 16'h1001, 1'b1, 1'b0), 1'b1,
                  "E.4 SHA (zp),Y cross, held: cycle 5 reads 1201, the held repeat reads 1001");
    end

    //---------------------------------------------------------------------
    // INT SECTION F: Interrupts
    // Recognition at the edge that starts an instruction's last cycle,
    // the branch delay, I-flag timing of CLI, SEI, PLP and RTI, the entry
    // sequence with B and the pushed P, NMI hijacking BRK and IRQ, the NMI
    // edge latch, NMI across RES, and the netlist interrupt sweeps.
    // [p.036]-[p.040], [p.051]-[p.053], [p.178]
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
    // F.4 B bit and pushed P: BRK pushes P OR 30 and PC+2, IRQ and NMI push
    // (P AND EF) OR 20; D is not changed by an entry; I = 1 after it.
    //---------------------------------------------------------------------
    section("INT SECTION F.4: Entry Sequence, B Bit and Pushed P");
    for(n = 0; n < 4; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0400);
        if(n <= 1)
            pb2(8'h00, 8'h5A);
        start_at(16'h0400, 16'h0200, 8'hFF, (n == 1) ? 8'h08 : (n == 3) ? 8'hC7 : 8'hC3, 8'h00, 8'h00, 8'h00);
        base = tr_n;
        if(n == 2)
            irq_n = 1'b0;
        if(n == 3)
            nmi_n = 1'b0;
        run_to_fetch((n == 3) ? 16'h0600 : 16'h0700, 1'b0, 30);
        irq_n = 1'b1;
        nmi_n = 1'b1;
        tmp8 = dp_u;
        tmp8b = (dir_u === dir_h);
        case(n)
            0: begin
                chk_entry(base, 1'b1, 16'h0400, 16'h0402, 8'hFF, 8'hF3, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "F.4 BRK with P = C3: reads 0401, pushes PC+2 = 0402 and P OR 30 = F3, vector FFFE");
                check(tmp8, 8'hF7, "F.4 BRK: dbg_p at the handler fetch = C3 with I = 1");
            end
            1: begin
                chk_entry(base, 1'b1, 16'h0400, 16'h0402, 8'hFF, 8'h38, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "F.4 BRK with D = 1: pushes 38");
                check(tmp8, 8'h3C, "F.4 BRK with D = 1: D still 1 and I = 1 in the handler");
            end
            2: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'hE3, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "F.4 IRQ with P = C3: pushes E3 (bit 4 = 0, bit 5 = 1)");
            end
            default: begin
                chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'hE7, 16'hFFFA, 16'h0600);
                check(ent_ok, 1'b1, "F.4 NMI with P = C7 (I = 1): pushes E7, vector FFFA");
            end
        endcase
        check(tmp8b[0], 1'b1, "F.4 uuth dbg_ir equal uut at the handler fetch");
    end

    //---------------------------------------------------------------------
    // F.5 NMI hijack: NMI low at the edge that starts cycle 5 of a BRK or
    // IRQ entry (falling by phi2 of cycle 4) takes the NMI vector with the
    // pushed B of the original entry. Later, the handler's first
    // instruction runs first. NMI low at the edges of cycles 6 and 7 only is
    // lost. IRQ and NMI together: NMI vector, B = 0.
    //---------------------------------------------------------------------
    section("INT SECTION F.5: NMI Hijack");
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
        if(n == 5) begin
            cycles(24);
            check(bus_is(base + 7, 16'h0700, 1'b1, 1'b1) && (reads_of(base, base + 29, 16'hFFFA) == 0), 1'b1,
                  "F.5 NMI low only at the edges of BRK cycles 6 and 7: lost, BRK handler runs, no NMI entry");
        end else begin
            run_to_fetch(16'h0600, 1'b0, 40);
            irq_n = 1'b1;
            nmi_n = 1'b1;
            case(n)
                0: begin
                    chk_entry(base, 1'b1, 16'h0400, 16'h0402, 8'hFF, 8'h30, 16'hFFFA, 16'h0600);
                    nm = "F.5 NMI falling in phi1 of BRK cycle 4: hijack, vector FFFA, B = 1 pushed";
                end
                1: begin
                    chk_entry(base, 1'b1, 16'h0400, 16'h0402, 8'hFF, 8'h30, 16'hFFFA, 16'h0600);
                    nm = "F.5 NMI falling in phi2 of BRK cycle 4: hijack, vector FFFA, B = 1 pushed";
                end
                2: begin
                    chk_entry(base + 9, 1'b0, 16'h0701, 16'h0701, 8'hFC, 8'h24, 16'hFFFA, 16'h0600);
                    nm = "F.5 NMI falling in BRK cycle 5: BRK completes, handler's first NOP runs, NMI entry at 0701";
                end
                3: begin
                    chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'h20, 16'hFFFA, 16'h0600);
                    nm = "F.5 NMI falling in IRQ entry cycle 4: hijack, vector FFFA, B = 0 pushed";
                end
                default: begin
                    chk_entry(base + 2, 1'b0, 16'h0401, 16'h0401, 8'hFF, 8'h20, 16'hFFFA, 16'h0600);
                    nm = "F.5 IRQ and NMI together: NMI vector, B = 0";
                end
            endcase
            check(ent_ok, 1'b1, nm);
        end
    end

    //---------------------------------------------------------------------
    // F.6 NMI edge latch: a held NMI is taken once; high at one edge and low
    // again is a new edge. NMI falling while RES is low and held is absorbed
    // by the reset.
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

    //---------------------------------------------------------------------
    // F.7 Netlist interrupt sweeps.
    //---------------------------------------------------------------------
    section("INT SECTION F.7: Interrupt Sweeps (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(3, 1, 100000);
    vec_report(3, "F.7 IRQ or NMI at every row of 38 contexts", 1'b0);
    info_left = 3;
    vec_run_fam(16, 1, 100000);
    vec_report(16, "F.7 one-edge IRQ/NMI at every edge of every branch variant", 1'b0);
    info_left = 3;
    vec_run_fam(17, 1, 100000);
    vec_report(17, "F.7 branch chains and CLI/SEI/PLP/RTI sequences", 1'b0);
    info_left = 3;
    vec_run_fam(4, 1, 100000);
    vec_report(4, "F.7 second NMI edges and high windows", 1'b0);
    info_left = 3;
    vec_run_fam(5, 1, 100000);
    vec_report(5, "F.7 hijack windows of BRK and IRQ entries", 1'b0);
    info_left = 3;
    vec_run_fam(10, 1, 100000);
    vec_report(10, "F.7 NMI around RES", 1'b1);

    //---------------------------------------------------------------------
    // F.8 RDY holding the last cycle of CLI (I = 1 before) or SEI (I = 0
    // before) for 1 or 2 edges, IRQ falling at every row around it (one
    // edge or held): the first repeat writes I, and every repeat polls with
    // the new I, so after CLI an IRQ low at a repeat is taken at the next
    // opcode fetch, and after SEI one first low at a repeat is masked.
    //---------------------------------------------------------------------
    section("INT SECTION F.8: Held Last Cycle of CLI and SEI (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(21, 1, 100000);
    vec_report(21, "F.8 CLI and SEI with the last cycle held, IRQ at every row", 1'b0);

    //---------------------------------------------------------------------
    // BUS SECTION G: RDY
    // A read cycle repeats while RDY is low at the edge that ends it; the
    // byte of the last repeat is used; writes are never held; a held
    // uncarried dummy read shows the carried address (a backward branch
    // fixup keeps its own); interrupts are sampled during holds, IRQ
    // polled only on held repeats of a polled cycle. [p.050], [p.122]-
    // [p.130], [p.168]
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
    // STA 1234 with RDY low from its write cycle: the write happens, the fetch after it is held
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
    run_to_fetch(16'h0404, 1'b0, 10);
    check(bus_is(base + 3, 16'h1234, 1'b0, 1'b0) && (wbyte(base + 3) === 8'h5A), 1'b1,
          "G.1 STA, RDY low at the end of its write cycle: the write of 5A happens");
    check(bus_is(base + 4, 16'h0403, 1'b1, 1'b1) && bus_is(base + 5, 16'h0403, 1'b1, 1'b1) &&
          bus_is(base + 6, 16'h0404, 1'b1, 1'b0), 1'b1,
          "G.1 STA: the next fetch is held one cycle, SYNC kept on the repeat");
    // JSR with RDY low only at the ends of its two write cycles: no cycle lost
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
    check(bus_is(base + 3, 16'h01FF, 1'b0, 1'b0) && bus_is(base + 4, 16'h01FE, 1'b0, 1'b0) &&
          bus_is(base + 5, 16'h0402, 1'b1, 1'b0) && now_is(16'h0500, 1'b1, 1'b1) && (tr_n == base + 6), 1'b1,
          "G.1 JSR, RDY low only across its two writes: no hold, fetch at 0500 in cycle 7");

    section("BUS SECTION G.2: Held Dummy Reads Show the Next Address");
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
            0: check(bus_is(base + 3, 16'h1210, 1'b1, 1'b0) && bus_is(base + 4, 16'h1310, 1'b1, 1'b0) &&
                     bus_is(base + 5, 16'h1310, 1'b1, 1'b0) && bus_is(base + 6, 16'h1310, 1'b1, 1'b0) &&
                     now_is(16'h0403, 1'b1, 1'b1) && (tr_n == base + 7), 1'b1,
                     "G.2 LDA 12F0,X (X = 20) held at the dummy read 1210: repeats read 1310 (carried)");
            1: check(bus_is(base + 3, 16'h0412, 1'b1, 1'b0) && bus_is(base + 4, 16'h0512, 1'b1, 1'b0) &&
                     bus_is(base + 5, 16'h0512, 1'b1, 1'b0) && now_is(16'h0512, 1'b1, 1'b1) && (tr_n == base + 6), 1'b1,
                     "G.2 BNE forward across a page held at the fixup 0412: repeats read 0512");
            default: check(bus_is(base + 3, 16'h05F4, 1'b1, 1'b0) && bus_is(base + 4, 16'h05F4, 1'b1, 1'b0) &&
                           bus_is(base + 5, 16'h05F4, 1'b1, 1'b0) && now_is(16'h04F4, 1'b1, 1'b1) &&
                           (tr_n == base + 6), 1'b1,
                           "G.2 BNE backward across a page held at the fixup 05F4: repeats keep 05F4");
        endcase
    end

    section("BUS SECTION G.3: Interrupts during Holds");
    for(n = 0; n < 3; n = n + 1) begin
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        put(16'h1234, 8'h11);
        org(16'h0400);
        pb3(8'hAD, 8'h34, 8'h12);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
        base = tr_n;
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
        case(n)
            0: begin
                chk_entry(base + 7, 1'b0, 16'h0403, 16'h0403, 8'hFF, 8'h20, 16'hFFFE, 16'h0700);
                check(ent_ok, 1'b1, "G.3 IRQ low only at the edge of one held repeat of LDA's last cycle: taken after LDA");
            end
            1: check(bus_is(base + 6, 16'h1234, 1'b1, 1'b0) && bus_is(base + 7, 16'h0403, 1'b1, 1'b1) &&
                     bus_is(base + 8, 16'h0404, 1'b1, 1'b0) &&
                     (reads_of(base, base + 15, 16'hFFFE) == 0), 1'b1,
                     "G.3 IRQ low only during a hold of cycle 3 (not polled): lost");
            default: begin
                chk_entry(base + 7, 1'b0, 16'h0403, 16'h0403, 8'hFF, 8'h20, 16'hFFFA, 16'h0600);
                check(ent_ok, 1'b1, "G.3 NMI falling and rising during a hold of cycle 3: latched, taken after LDA");
            end
        endcase
    end

    section("BUS SECTION G.4: RDY Sweeps (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(7, 1, 100000);
    vec_report(7, "G.4 RDY low 1-6 half cycles from every row of 13 contexts", 1'b0);
    info_left = 3;
    vec_run_fam(8, 1, 100000);
    vec_report(8, "G.4 RDY on uncarried dummy reads and branch fixups", 1'b0);
    info_left = 3;
    vec_run_fam(9, 1, 100000);
    vec_report(9, "G.4 IRQ, NMI and SO pulses inside RDY holds", 1'b0);
    info_left = 3;
    vec_run_fam(14, 1, 100000);
    vec_report(14, "G.4 every read cycle of every opcode variant held 1 and 2 cycles", 1'b0);

    //---------------------------------------------------------------------
    // G.5 Held vector reads of an entry: BRK, an IRQ entry, an NMI entry and
    // the reset sequence with RDY holding the vector high read (cycle 7)
    // for 1 or 2 edges, and the reset sequence also with its third stack
    // read (cycle 5) held; NMI falling at every row around them (one edge
    // or held). Every edge that starts a repeat of cycle 7 is a poll edge:
    // I is already set, so a latched NMI turns the handler's first opcode
    // fetch into the NMI entry. Every edge that starts a repeat of the
    // third stack read of the reset sequence samples NMI for the vector
    // again: an NMI latched there is absorbed by the reset. [p.050], [p.052]
    //---------------------------------------------------------------------
    section("BUS SECTION G.5: Held Vector Reads of an Entry (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(23, 1, 100000);
    vec_report(23, "G.5 NMI during held vector and stack reads of BRK, IRQ, NMI and reset", 1'b0);

    //---------------------------------------------------------------------
    // CPU SECTION H: SO (Set Overflow)
    // A falling SO edge sets V at the second falling clock edge after the
    // sample; HALF mode samples at cen_p2 (end of phi1), CYCLE mode at cen,
    // so a fall in phi1 is seen one cycle later in CYCLE mode. One low
    // sample suffices; a new edge needs SO high again; an instruction's V
    // load wins; SO works during RDY holds. V is read from dbg_p at opcode
    // fetches. [p.055], [p.057]
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
    // H.3 Collisions: ADC # at 0400 (A = 00, C = 0, result V = 0) loads V at
    // the edge that starts the second cycle of the next instruction (cycle
    // base+3); CLV at 0400 clears V at the edges of base+2 and base+3. An SO
    // set at or before those edges is lost; at base+4 it stays.
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

    section("CPU SECTION H.5: SO Sweeps (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(6, 1, 100000);
    vec_report(6, "H.5 SO at every row of 7 contexts, widths 1, 2 and held", 1'b0);
    info_left = 3;
    vec_run_fam(15, 1, 100000);
    vec_report(15, "H.5 SO at every row of every V-writing opcode", 1'b0);

    //---------------------------------------------------------------------
    // H.6 SO before BVC and BVS: both opcodes taken in page, V = 0 and 1
    // before, SO low for one sample from 5 rows before the fetch to 6 after
    // it, cycle 2 held 0 or 1 edge. The branch takes V as it is at the edge
    // that starts cycle 2, an SO set at that edge included, and again at the
    // edge that starts each RDY repeat of cycle 2. SO changes in phase 1
    // are compared in HALF mode only.
    //---------------------------------------------------------------------
    section("CPU SECTION H.6: SO before BVC and BVS (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(20, 1, 100000);
    vec_report(20, "H.6 BVC and BVS with SO at every row around cycle 2", 1'b0);

    //---------------------------------------------------------------------
    // H.7 CLV (V = 1 before) with the next opcode fetch held 0-3 edges and
    // SO low for one sample at every row of the fetch and the hold: CLV
    // clears V at the edge that starts the fetch, at every edge that
    // starts a repeat of it and at the edge that ends it, so only an SO set
    // after that is seen. PHP after three NOPs shows V. SO changes in
    // phase 1 are compared in HALF mode only.
    //---------------------------------------------------------------------
    section("CPU SECTION H.7: CLV with the Next Fetch Held (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(22, 1, 100000);
    vec_report(22, "H.7 CLV, next fetch held 0-3 cycles, SO at every row", 1'b0);

    //---------------------------------------------------------------------
    // CPU SECTION I: JAM
    // The twelve JAM opcodes: fetch, PC+1, FFFF, FFFE, FFFE, then FFFF on
    // every cycle, never a write or SYNC; jam = 1 from cycle 3; the PC holds
    // the opcode address + 2; IRQ and NMI are ignored; RES leaves the JAM
    // with the held address PC+2 on the bus, A X Y D kept and S - 3.
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display(" CPU SECTION I: JAM");
    $display("=========================================================");
    en_run = 1'b1;
    mon_on = 1'b1;
    tb_ratio = 4;

    section("CPU SECTION I.1: Bus Pattern and jam Output");
    for(n = 0; n < 12; n = n + 1) begin
        case(n)
            0: tmp8 = 8'h02;
            1: tmp8 = 8'h12;
            2: tmp8 = 8'h22;
            3: tmp8 = 8'h32;
            4: tmp8 = 8'h42;
            5: tmp8 = 8'h52;
            6: tmp8 = 8'h62;
            7: tmp8 = 8'h72;
            8: tmp8 = 8'h92;
            9: tmp8 = 8'hB2;
            10: tmp8 = 8'hD2;
            default: tmp8 = 8'hF2;
        endcase
        mem_new(8'hEA);
        vectors(16'h0600, 16'h0500, 16'h0700);
        org(16'h0400);
        pb2(tmp8, 8'h5A);
        start_at(16'h0400, 16'h0200, 8'hFF, 8'h00, 8'h11, 8'h22, 8'h33);
        base = tr_n;
        cycles(16);
        errs = 0;
        for(j = 0; j < 16; j = j + 1) begin
            case(j)
                0: tmp16 = 16'h0400;
                1: tmp16 = 16'h0401;
                2: tmp16 = 16'hFFFF;
                3, 4: tmp16 = 16'hFFFE;
                default: tmp16 = 16'hFFFF;
            endcase
            if(!bus_is(base + j, tmp16, 1'b1, (j == 0)))
                errs = errs + 1;
            tmp32 = ra_u(base + j);
            if(tmp32[31] !== (j >= 2))
                errs = errs + 1;
            tmp32 = ra_h(base + j);
            if(tmp32[31] !== (j >= 2))
                errs = errs + 1;
            if(((ra_u(base + j) | ra_h(base + j)) & 41'h0_00_24_000000) !== 41'h0)
                errs = errs + 1;
        end
        $sformat(nm, "I.1 JAM $%h: 0400 0401 FFFF FFFE FFFE FFFF..., no SYNC after the fetch, jam = 1 from cycle 3", tmp8);
        check(errs, 0, nm);
        $sformat(nm, "I.1 JAM $%h: dbg_pc = 0402 while halted", tmp8);
        tmp32 = rad_u(base + 15) >> 48;
        check(tmp32[15:0], 16'h0402, nm);
    end

    section("CPU SECTION I.2: Interrupts Ignored, Recovery by RES");
    // IRQ held low with I = 0 and an NMI edge during the JAM change nothing
    irq_n = 1'b0;
    wait_cen();
    nmi_n = 1'b0;
    base = tr_n;
    cycles(12);
    errs = 0;
    for(j = 0; j < 12; j = j + 1)
        if(!bus_is(base + j, 16'hFFFF, 1'b1, 1'b0))
            errs = errs + 1;
    check(errs, 0, "I.2 IRQ low (I = 0) and an NMI edge during the JAM: FFFF reads continue, no entry");
    irq_n = 1'b1;
    nmi_n = 1'b1;
    wait_cen();
    rst_n = 1'b0;
    wait_cen();
    base = tr_n;
    cycles(3);
    rst_n = 1'b1;
    run_to_fetch(16'h0500, 1'b0, 30);
    check(found && (fetch_cyc == 9), 1'b1, "I.2 RES (four edges) leaves the JAM: reset vector fetch at s+8");
    errs = 0;
    for(j = 2; j <= 6; j = j + 1)
        if(!bus_is(base + j, 16'h0402, 1'b1, (j == 5)))
            errs = errs + 1;
    check(bus_is(base + 1, 16'hFFFF, 1'b1, 1'b0), 1'b1, "I.2 cycle r+1 still reads FFFF");
    check(errs, 0, "I.2 cycles r+2 .. s+2 hold the PC 0402 (opcode address + 2), SYNC only at s+1");
    check(bus_is(base + 7, 16'h01FF, 1'b1, 1'b0) && bus_is(base + 10, 16'hFFFC, 1'b1, 1'b0), 1'b1,
          "I.2 stack reads from 01FF, FFFC at s+6");
    check({jam_u, jam_h}, 2'b00, "I.2 jam = 0 at the reset vector fetch");
    readout(16'h0500);
    check_regs(8'h11, 8'h22, 8'h33, 8'hFC, 8'h04, "I.2 after RES: A X Y kept, S = FF - 3, I = 1, the NMI edge absorbed");

    section("CPU SECTION I.3: JAM Sweeps (netlist scenarios)");
    vec_clear_counts();
    info_left = 3;
    vec_run_fam(12, 1, 100000);
    vec_report(12, "I.3 the 12 JAMs alone, with IRQ, with NMI, recovered by RES", 1'b1);

    //---------------------------------------------------------------------
    // BUS SECTION J: SYNC and vp_n
    // SYNC marks exactly the opcode fetch cycles, including the replaced
    // fetch of an interrupt entry and cycle s+1 of the reset sequence.
    // vp_n (an extension, not a 6502 pin) is low only in cycles 6 and 7 of
    // IRQ, NMI and BRK entries. [p.057], [p.058]
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
    // The scenario families again at other enable ratios (1 = CYCLE mode
    // only, 2, 3, 5, 16) and with random stops between enables; CYCLE/HALF
    // lockstep over every scenario run; outputs change only at enable edges
    // and are never X.
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
        vec_run_fam(1, (t == 4) ? 4 : 2, 100000);
        $sformat(nm, "K.1 opcode scenarios at ratio %0d%0s", tb_ratio, (t == 0) ? " (CYCLE mode only)" : "");
        vec_report(1, nm, 1'b0);
        if(t != 0) begin
            vec_clear_counts();
            info_left = 3;
            vec_run_fam(3, 4, 100000);
            $sformat(nm, "K.1 interrupt scenarios at ratio %0d", tb_ratio);
            vec_report(3, nm, 1'b0);
        end
    end

    section("CLK SECTION K.2: Random Stops between Enables");
    tb_ratio = 3;
    en_stall = 1'b1;
    for(t = 0; t < 5; t = t + 1) begin
        vec_clear_counts();
        info_left = 3;
        case(t)
            0: begin
                vec_run_fam(1, 3, 100000);
                vec_report(1, "K.2 opcode scenarios, ratio 3 with stops", 1'b0);
            end
            1: begin
                vec_run_fam(3, 5, 100000);
                vec_report(3, "K.2 interrupt scenarios, ratio 3 with stops", 1'b0);
            end
            2: begin
                vec_run_fam(8, 4, 100000);
                vec_report(8, "K.2 RDY dummy-read scenarios, ratio 3 with stops", 1'b0);
            end
            3: begin
                vec_run_fam(6, 4, 100000);
                vec_report(6, "K.2 SO scenarios, ratio 3 with stops", 1'b0);
            end
            default: begin
                vec_run_fam(11, 4, 100000);
                vec_report(11, "K.2 RES scenarios, ratio 3 with stops", 1'b1);
            end
        endcase
    end
    en_stall = 1'b0;
    tb_ratio = 4;

    section("CLK SECTION K.3: Lockstep and Output Timing");
    $sformat(nm, "K.3 CYCLE/HALF lockstep over every scenario run in both modes (%0d scenarios, %0d cycles)", g_both,
             g_cyc);
    check_mm(g_lock + ((g_both == 0) ? 1 : 0), nm);
    check_mm(mon_viol_u, "K.3 uut outputs changed only at cen edges: violations");
    check_mm(mon_viol_h, "K.3 uuth outputs changed only at cen and cen_p2 edges: violations");
    check_mm(mon_x_u, "K.3 uut outputs never X (cen_p2 unconnected): clk edges with an X");
    check_mm(mon_x_h, "K.3 uuth outputs never X: clk edges with an X");

    //---------------------------------------------------------------------
    // Final Test Summary
    //---------------------------------------------------------------------
    $display("\n=============================================================");
    $display("  x6502 Test Results");
    $display("=============================================================");
    $display("  Total Tests:  %0d", total_tests);
    $display("  Passed:       %0d", passed_tests);
    $display("  Failed:       %0d", failed_tests);
    $display("=============================================================");

    if(failed_tests == 0) begin
        $display("  *** ALL TESTS PASSED ***");
        $display("  Cycle-accurate to the MCS6500 Hardware Manual and the NMOS 6502 netlist");
    end else begin
        $display("  *** SOME TESTS FAILED ***");
    end

    $display("=============================================================\n");

    $stop;
end

endmodule
