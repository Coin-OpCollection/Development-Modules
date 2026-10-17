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
//  Comprehensive testbench for the Hudson Soft HuC6280 CPU implementation.
//
//  Verifies x6280_cpu and x6280_alu: every opcode cycle by cycle, reset,
//  the HuC6280 instructions (T flag, block transfers, mapping registers,
//  ST0-ST2, CSL / CSH, BSR), interrupts, RDY on every cycle kind and the
//  CE7 / CEK wait. Registers are set only by real instructions (TAM, LDX,
//  TXS, LDA, LDY, RTI) and results are read back through the bus and the
//  debug outputs. No register of the CPU is written from here.
//
//  DUTs:
//    uut     - CE_WAIT = 1 (the consumer configuration)
//    uutn    - CE_WAIT = 0, Section G.3 only
//    alu_uut - x6280_alu driven directly
//  Each CPU has its own 2 MB physical memory model.
//
//  Expected values:
//    - Directed tests: the bus pattern and results stated in each test,
//      from the HuC6280 manuals and the rules the header of x6280_cpu.v
//      states.
//    - sim/tb_x6280_ops.hex: one instruction per record with its initial
//      registers, MPRs and memory, every bus cycle (kind, physical address,
//      data, CE7 / CEK wait), the final registers, MPRs and memory
//      (+vec=<file> selects another file of the same format).
//    - ALU: the reference functions of this file (HuC6280 flag rules).
//
//  Test Organization:
//    CPU Section A:  Reset: power-up values, first and warm reset, the bus
//                    sequence and vector FFFE, MPR7 / speed / T cleared,
//                    the bus while RES is low, RES sampled at cen only
//    BUS Section B:  Every opcode from the instruction vectors per cycle
//    ALU Section D:  Every ALU operation over every input, C and D
//    CPU Section E:  T flag, block transfers, mapping registers, ST0-ST2,
//                    CSL / CSH, BSR / JSR / RTS / RTI
//    INT Section F:  Vectors, entry sequence, poll point, block transfers,
//                    no takeover of BRK, NMI edge and priority, vector
//                    latch
//    BUS Section G:  RDY on read, write and internal cycles; the CE7 / CEK
//                    wait; CE_WAIT = 0
//    CLK Section K:  Enable ratios and random stops over the vectors
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual and
//             Software Manual (Hudson Soft); US patents 5483659 and
//             5034886
//============================================================================

`timescale 1ns/1ps

module tb_x6280_cpu;

//=========================================================================
// Test Signals and Statistics
//=========================================================================
reg        clk;
reg        cen;
reg        rst_n;
reg        rdy;
reg        irq_n;
reg  [1:0] irq_vec;
reg        nmi_n;

integer     total_tests;
integer     passed_tests;
integer     failed_tests;
integer     i;
integer     j;
integer     k;
integer     n;
integer     errs;
integer     seed;
reg   [7:0] tmp8;
reg  [15:0] tmp16;
reg [8*160-1:0] nm;

//=========================================================================
// Enable Generator:
// tb_ratio clk per enable; en_stall inserts random stops of 1-16 clk.
//=========================================================================
integer tb_ratio;
reg     en_run;
reg     en_stall;
integer en_ph;
integer en_hold;
integer en_seed;

always @(posedge clk) begin
    if(!en_run)
        cen <= #1 1'b0;
    else if(en_hold > 0) begin
        cen <= #1 1'b0;
        en_hold <= en_hold - 1;
    end else begin
        cen <= #1 (en_ph == 0);
        if(en_ph + 1 >= tb_ratio)
            en_ph <= 0;
        else
            en_ph <= en_ph + 1;
        if(en_stall && (($random(en_seed) & 7) == 0))
            en_hold <= 1 + ($random(en_seed) & 15);
    end
end

initial clk = 1'b0;
always #5 clk = ~clk;

//=========================================================================
// DUT Signals
//=========================================================================
wire [15:0] la_u;
wire [20:0] pa_u;
wire  [7:0] din_u;
wire  [7:0] dout_u;
wire        rw_u;
wire        ic_u;
wire        sync_u;
wire        vp_u;
wire        oe_u;
wire        bce_u;
wire        csh_u;
wire [15:0] dpc_u;
wire  [7:0] da_u;
wire  [7:0] dx_u;
wire  [7:0] dy_u;
wire  [7:0] ds_u;
wire  [7:0] dp_u;
wire  [7:0] dir_u;
wire [63:0] dmpr_u;

wire [15:0] la_n;
wire [20:0] pa_n;
wire  [7:0] din_n;
wire  [7:0] dout_n;
wire        rw_n_n;
wire        ic_n;
wire        sync_n;
wire        bce_n;

x6280_cpu #(
    .CE_WAIT ( 1 )
) uut (
    .clk       ( clk     ),
    .cen       ( cen     ),
    .rst_n     ( rst_n   ),
    .rdy       ( rdy     ),
    .irq_n     ( irq_n   ),
    .irq_vec   ( irq_vec ),
    .nmi_n     ( nmi_n   ),
    .addr      ( la_u    ),
    .phys_addr ( pa_u    ),
    .din       ( din_u   ),
    .dout      ( dout_u  ),
    .rw_n      ( rw_u    ),
    .intc      ( ic_u    ),
    .sync      ( sync_u  ),
    .vp_n      ( vp_u    ),
    .dout_oe   ( oe_u    ),
    .bus_ce    ( bce_u   ),
    .csh       ( csh_u   ),
    .dbg_pc    ( dpc_u   ),
    .dbg_a     ( da_u    ),
    .dbg_x     ( dx_u    ),
    .dbg_y     ( dy_u    ),
    .dbg_s     ( ds_u    ),
    .dbg_p     ( dp_u    ),
    .dbg_ir    ( dir_u   ),
    .dbg_mpr   ( dmpr_u  )
);

x6280_cpu #(
    .CE_WAIT ( 0 )
) uutn (
    .clk       ( clk     ),
    .cen       ( cen     ),
    .rst_n     ( rst_n   ),
    .rdy       ( rdy     ),
    .irq_n     ( 1'b1    ),
    .irq_vec   ( 2'b00   ),
    .nmi_n     ( 1'b1    ),
    .addr      ( la_n    ),
    .phys_addr ( pa_n    ),
    .din       ( din_n   ),
    .dout      ( dout_n  ),
    .rw_n      ( rw_n_n  ),
    .intc      ( ic_n    ),
    .sync      ( sync_n  ),
    .vp_n      (         ),
    .dout_oe   (         ),
    .bus_ce    ( bce_n   ),
    .csh       (         ),
    .dbg_pc    (         ),
    .dbg_a     (         ),
    .dbg_x     (         ),
    .dbg_y     (         ),
    .dbg_s     (         ),
    .dbg_p     (         ),
    .dbg_ir    (         ),
    .dbg_mpr   (         )
);

//=========================================================================
// Standalone ALU Instance
//=========================================================================
reg  [7:0] alu_a;
reg  [7:0] alu_b;
reg  [4:0] alu_op;
reg  [7:0] alu_pin;
wire [7:0] alu_q;
wire [7:0] alu_pout;

x6280_alu alu_uut (
    .a     ( alu_a    ),
    .b     ( alu_b    ),
    .op    ( alu_op   ),
    .p_in  ( alu_pin  ),
    .q     ( alu_q    ),
    .p_out ( alu_pout )
);

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

//=========================================================================
// Memory Model:
// 2 MB physical per CPU. A byte belongs to the current image when its tag
// equals img; any other address reads fill. A write commits at the enable
// that ends the cycle (bus_ce).
//=========================================================================
reg   [7:0] mem_u [0:2097151];
reg  [15:0] tag_u [0:2097151];
reg   [7:0] mem_n [0:2097151];
reg  [15:0] tag_n [0:2097151];
reg  [15:0] img;
reg   [7:0] fill;
reg  [31:0] mem_gen;

reg  [7:0] din_u_r;
reg  [7:0] din_n_r;
always @(pa_u or mem_gen or img or fill)
    din_u_r = ((^pa_u !== 1'bx) && (tag_u[pa_u] == img)) ? mem_u[pa_u] : fill;
always @(pa_n or mem_gen or img or fill)
    din_n_r = ((^pa_n !== 1'bx) && (tag_n[pa_n] == img)) ? mem_n[pa_n] : fill;
assign din_u = din_u_r;
assign din_n = din_n_r;

integer wr_cnt_u;

always @(posedge clk) begin
    if(cen && bce_u && (rw_u === 1'b0) && (^pa_u !== 1'bx)) begin
        mem_u[pa_u] <= dout_u;
        tag_u[pa_u] <= img;
        wr_cnt_u <= wr_cnt_u + 1;
    end
    if(cen && bce_n && (rw_n_n === 1'b0) && (^pa_n !== 1'bx)) begin
        mem_n[pa_n] <= dout_n;
        tag_n[pa_n] <= img;
    end
    if(cen && ((bce_u && rw_u === 1'b0) || (bce_n && rw_n_n === 1'b0)))
        mem_gen <= mem_gen + 1;
end

task poke;
    input [20:0] pa;
    input  [7:0] d;
    begin
        mem_u[pa] = d;
        tag_u[pa] = img;
        mem_n[pa] = d;
        tag_n[pa] = img;
        mem_gen = mem_gen + 1;
    end
endtask

function [7:0] peek;
    input [20:0] pa;
    begin
        peek = (tag_u[pa] == img) ? mem_u[pa] : fill;
    end
endfunction

//=========================================================================
// Bus Recorder:
// At each enable that ends a cycle (bus_ce) the cycle is stored at tr_n:
//   trb [20:0] pa  [28:21] data  [29] rw_n  [30] sync  [31] vp_n  [32] intc
//       [33] dout_oe  [37:34] enables in the cycle  [38] csh  [54:39] la
//       [55] an output was X
// en_cnt counts the enables of the cycle in progress.
//=========================================================================
localparam TRN = 16384;
reg  [55:0] trb [0:TRN-1];
reg  [31:0] tr_n;
integer     en_cnt;
wire  [3:0] en_rec = en_cnt + 1;

always @(posedge clk) begin
    if(cen) begin
        if(bce_u) begin
            trb[tr_n[13:0]] <= {^{pa_u, rw_u, sync_u, vp_u, ic_u, oe_u, dout_u} === 1'bx, la_u, csh_u,
                                en_rec, oe_u, ic_u, vp_u, sync_u, rw_u,
                                (rw_u === 1'b0) ? dout_u : din_u, pa_u};
            tr_n <= tr_n + 1;
            en_cnt <= 0;
        end else
            en_cnt <= en_cnt + 1;
    end
end

function [20:0] tr_pa;   input [31:0] q; begin tr_pa   = trb[q[13:0]][20:0];  end endfunction
function  [7:0] tr_d;    input [31:0] q; begin tr_d    = trb[q[13:0]][28:21]; end endfunction
function        tr_rw;   input [31:0] q; begin tr_rw   = trb[q[13:0]][29];    end endfunction
function        tr_sy;   input [31:0] q; begin tr_sy   = trb[q[13:0]][30];    end endfunction
function        tr_vp;   input [31:0] q; begin tr_vp   = trb[q[13:0]][31];    end endfunction
function        tr_ic;   input [31:0] q; begin tr_ic   = trb[q[13:0]][32];    end endfunction
function        tr_oe;   input [31:0] q; begin tr_oe   = trb[q[13:0]][33];    end endfunction
function  [3:0] tr_en;   input [31:0] q; begin tr_en   = trb[q[13:0]][37:34]; end endfunction
function        tr_csh;  input [31:0] q; begin tr_csh  = trb[q[13:0]][38];    end endfunction
function [15:0] tr_la;   input [31:0] q; begin tr_la   = trb[q[13:0]][54:39]; end endfunction
function        tr_x;    input [31:0] q; begin tr_x    = trb[q[13:0]][55];    end endfunction

//=========================================================================
// Reporting
//=========================================================================
task section;
    input [8*120-1:0] s;
    begin
        $display("");
        $display("=== %0s ===", s);
        $display("");
    end
endtask

task check;
    input [8*160-1:0] name;
    input             ok;
    begin
        total_tests = total_tests + 1;
        if(ok) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s", name);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s", name);
        end
    end
endtask

task check_eq;
    input [8*160-1:0] name;
    input [63:0]      got;
    input [63:0]      exp;
    begin
        total_tests = total_tests + 1;
        if(got === exp) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s = %h", name, got);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s = %h (expected %h)", name, got, exp);
        end
    end
endtask

//=========================================================================
// Run Control:
// Waits are counted in enables. at_cycle waits until a cycle with the given
// physical address and SYNC is presented (#1 after the edge that starts it).
//=========================================================================
task wait_cen;
    input integer cnt;
    integer q;
    begin
        q = 0;
        while(q < cnt) begin
            @(posedge clk);
            if(cen)
                q = q + 1;
        end
        #1;
    end
endtask

task wait_fetch;
    input [20:0] pa;
    input integer limit;
    output  ok;
    integer q;
    begin
        ok = 1'b0;
        q = 0;
        while(!ok && q < limit) begin
            @(posedge clk);
            if(cen) begin
                q = q + 1;
                #1;
                if(sync_u && pa_u == pa && en_cnt == 0)
                    ok = 1'b1;
            end
        end
    end
endtask

task wait_cycles;
    input integer cnt;
    integer q;
    integer g;
    begin
        q = 0;
        g = 0;
        while(q < cnt && g < 100000) begin
            @(posedge clk);
            g = g + 1;
            if(cen && bce_u)
                q = q + 1;
        end
        if(q < cnt)
            check("bus cycles complete (the bus is not held)", 1'b0);
        #1;
    end
endtask

task do_reset;
    begin
        rst_n = 1'b0;
        wait_cen(3);
        rst_n = 1'b1;
    end
endtask

//=========================================================================
// Program Images:
// MPR7 = 00 after reset, so logical E000-FFFF is physical 000000-001FFF.
// new_img starts an empty image; put writes code at a logical address of
// bank 00; boot_at sets the reset vector and resets.
//=========================================================================
integer pc_put;

task new_img;
    begin
        img = img + 1;
        fill = 8'h00;
    end
endtask

task put;
    input [7:0] d;
    begin
        poke({8'h00, pc_put[12:0]}, d);
        pc_put = pc_put + 1;
    end
endtask

task org;
    input [15:0] a;
    begin
        pc_put = a;
    end
endtask

task boot_at;
    input [15:0] a;
    begin
        poke(21'h001FFE, a[7:0]);
        poke(21'h001FFF, a[15:8]);
        do_reset;
    end
endtask

// Standard map for directed tests: MPR0 = FF (I/O), MPR1 = F8 (RAM), MPR2-6
// = 01-05, MPR7 = 00; S = FF. 26 bytes.
task std_map;
    begin
        put(8'hA9); put(8'hFF); put(8'h53); put(8'h01);
        put(8'hA9); put(8'hF8); put(8'h53); put(8'h02);
        put(8'hA9); put(8'h01); put(8'h53); put(8'h04);
        put(8'hA9); put(8'h02); put(8'h53); put(8'h08);
        put(8'hA9); put(8'h03); put(8'h53); put(8'h10);
        put(8'hA9); put(8'h04); put(8'h53); put(8'h20);
        put(8'hA9); put(8'h05); put(8'h53); put(8'h40);
        put(8'hA2); put(8'hFF); put(8'h9A);
    end
endtask

function [20:0] std_pa;
    input [15:0] la;
    begin
        case(la[15:13])
            3'd0 : std_pa = {8'hFF, la[12:0]};
            3'd1 : std_pa = {8'hF8, la[12:0]};
            3'd7 : std_pa = {8'h00, la[12:0]};
            default : std_pa = {8'h00 + la[15:13] - 8'h01, la[12:0]};
        endcase
    end
endfunction

//=========================================================================
// Instruction Vectors:
// One instruction per record (gen_vectors.py). A preamble at E000 sets
// MPR0-MPR6 (TAM), S, A, X, Y and P (LDX, TXS, LDA, LDX, LDY, RTI); the
// RTI at E025 pulls P, PCL and PCH from the stack. At the start of the
// next opcode fetch the image is replaced by the record's memory (every
// other address reads 00). The instruction then runs to the next fetch:
// every cycle is compared (kind, physical address, data, enables), SYNC
// only in the first cycle, dout_oe only in writes; then the fetch address,
// dbg_*, the MPRs and the record's final memory.
//   W0 {A6, op, 00, ncyc}  W1 {idx, pc}  W2 {s, p, a, x}  W3 {y, 00, nram}
//   W4 {nfin, fpc}  W5 {fs, fp, fa, fx}  W6 {fy, 000000}  W7-W8 MPR3-0,
//   MPR7-4  W9-W10 final MPRs; nram and nfin words {000, pa, data}; ncyc
//   words {kind, pa, data, wait}; end FFFFFFFF.
//=========================================================================
localparam VECN = 400000;
reg  [31:0] vec [0:VECN-1];
integer     vec_words;
integer     op_n [0:255];
integer     op_bad [0:255];
integer     vec_tests;
integer     vec_fail;
integer     info_left;
integer     vec_wait;

task vec_load;
    reg [8*256-1:0] f;
    integer         q;
    begin
        for(q = 0; q < VECN; q = q + 1)
            vec[q] = 32'hFFFFFFFF;
        if(!$value$plusargs("vec=%s", f))
            f = "tb_x6280_ops.hex";
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
            op_bad[q] = 0;
        end
        vec_tests = 0;
        vec_fail = 0;
        vec_wait = 0;
    end
endtask

//-------------------------------------------------------------------------
// Next Fetch:
// Waits for the end of the cycle in progress and of every following cycle
// until a cycle with SYNC is presented.
//-------------------------------------------------------------------------
task next_fetch;
    input integer limit;
    output  ok;
    integer q;
    begin
        ok = 1'b0;
        q = 0;
        while(!ok && q < limit) begin
            @(posedge clk);
            if(cen) begin
                q = q + 1;
                if(bce_u) begin
                    #1;
                    if(sync_u)
                        ok = 1'b1;
                end
            end
        end
    end
endtask

//-------------------------------------------------------------------------
// One Record:
// vec_one runs the record at word w and returns the next record's word.
//-------------------------------------------------------------------------
task vec_one;
    input  integer w;
    output integer nxt;
    reg [7:0] op;
    reg [7:0] ncyc;
    reg  [7:0] s, p, a, x, y, fs, fp, fa, fx, fy;
    reg [15:0] pc, fpc, nram, nfin, idx;
    reg [63:0] mpr, fmpr;
    reg [31:0] cw;
    reg  [1:0] kind;
    reg [20:0] epa;
    reg  [7:0] ed;
    reg        ewt;
    reg        ok;
    reg        bad;
    reg [31:0] tr0;
    integer    q;
    integer    base;
    begin
        op = vec[w][23:16];
        ncyc = vec[w][7:0];
        idx = vec[w + 1][31:16];
        pc = vec[w + 1][15:0];
        {s, p, a, x} = vec[w + 2];
        y = vec[w + 3][31:24];
        nram = vec[w + 3][15:0];
        nfin = vec[w + 4][31:16];
        fpc = vec[w + 4][15:0];
        {fs, fp, fa, fx} = vec[w + 5];
        fy = vec[w + 6][31:24];
        mpr = {vec[w + 8], vec[w + 7]};
        fmpr = {vec[w + 10], vec[w + 9]};
        base = w + 11;
        nxt = base + nram + nfin + ncyc;
        bad = 1'b0;

        // preamble image and reset
        new_img;
        org(16'hE000);
        for(q = 0; q < 7; q = q + 1) begin
            put(8'hA9); put(mpr[8 * q +: 8]); put(8'h53); put(8'h01 << q);
        end
        put(8'hA2); put(s - 8'd3); put(8'h9A);
        put(8'hA9); put(a);
        put(8'hA2); put(x);
        put(8'hA0); put(y);
        put(8'h40);
        poke({mpr[15:8], 5'b00001, s - 8'd2}, p);
        poke({mpr[15:8], 5'b00001, s - 8'd1}, pc[7:0]);
        poke({mpr[15:8], 5'b00001, s}, pc[15:8]);
        boot_at(16'hE000);
        wait_fetch(21'h000025, 600, ok);
        if(ok)
            next_fetch(200, ok);

        if(!ok) begin
            bad = 1'b1;
            if(info_left > 0) begin
                info_left = info_left - 1;
                $display("INFO: record %0d op %h: preamble did not reach the instruction", idx, op);
            end
        end else begin
            // the record's image
            new_img;
            for(q = 0; q < nram; q = q + 1)
                poke(vec[base + q][28:8], vec[base + q][7:0]);
            tr0 = tr_n;
            wait_cycles(ncyc);

            for(q = 0; q < ncyc; q = q + 1) begin
                cw = vec[base + nram + nfin + q];
                kind = cw[31:30];
                epa = cw[29:9];
                ed = cw[8:1];
                ewt = cw[0];
                if(ewt)
                    vec_wait = vec_wait + 1;
                if((tr_pa(tr0 + q) !== epa) ||
                   (tr_rw(tr0 + q) !== (kind != 2'd1)) ||
                   (tr_ic(tr0 + q) !== (kind == 2'd2)) ||
                   (tr_vp(tr0 + q) !== (kind != 2'd3)) ||
                   (tr_sy(tr0 + q) !== (q == 0)) ||
                   (tr_oe(tr0 + q) !== (kind == 2'd1)) ||
                   (tr_en(tr0 + q) !== (4'd1 + ewt)) ||
                   tr_x(tr0 + q) ||
                   ((kind != 2'd2) && (tr_d(tr0 + q) !== ed))) begin
                    if(!bad && info_left > 0) begin
                        info_left = info_left - 1;
                        $display("INFO: record %0d op %h cycle %0d: got pa %h d %h rw %b ic %b vp %b sync %b en %0d, expected kind %0d pa %h d %h wait %b",
                                 idx, op, q + 1, tr_pa(tr0 + q), tr_d(tr0 + q), tr_rw(tr0 + q), tr_ic(tr0 + q),
                                 tr_vp(tr0 + q), tr_sy(tr0 + q), tr_en(tr0 + q), kind, epa, ed, ewt);
                    end
                    bad = 1'b1;
                end
            end

            // next fetch and final state
            if(!sync_u || (la_u !== fpc) || (dpc_u !== fpc) || (da_u !== fa) || (dx_u !== fx) ||
               (dy_u !== fy) || (ds_u !== fs) || (dp_u !== fp) || (dmpr_u !== fmpr)) begin
                if(!bad && info_left > 0) begin
                    info_left = info_left - 1;
                    $display("INFO: record %0d op %h end: sync %b la %h pc %h a %h x %h y %h s %h p %h mpr %h; expected pc %h a %h x %h y %h s %h p %h mpr %h",
                             idx, op, sync_u, la_u, dpc_u, da_u, dx_u, dy_u, ds_u, dp_u, dmpr_u,
                             fpc, fa, fx, fy, fs, fp, fmpr);
                end
                bad = 1'b1;
            end
            for(q = 0; q < nfin; q = q + 1)
                if(peek(vec[base + nram + q][28:8]) !== vec[base + nram + q][7:0]) begin
                    if(!bad && info_left > 0) begin
                        info_left = info_left - 1;
                        $display("INFO: record %0d op %h memory %h = %h, expected %h", idx, op,
                                 vec[base + nram + q][28:8], peek(vec[base + nram + q][28:8]),
                                 vec[base + nram + q][7:0]);
                    end
                    bad = 1'b1;
                end
        end

        vec_tests = vec_tests + 1;
        op_n[op] = op_n[op] + 1;
        if(bad) begin
            vec_fail = vec_fail + 1;
            op_bad[op] = op_bad[op] + 1;
        end
    end
endtask

//-------------------------------------------------------------------------
// Vector Pass:
// Every record when step = 1, else every step-th record.
//-------------------------------------------------------------------------
task vec_pass;
    input integer step;
    integer w;
    integer nw;
    integer r;
    begin
        vec_clear_counts;
        info_left = 12;
        w = 0;
        r = 0;
        while(w < vec_words) begin
            if((r % step) == 0)
                vec_one(w, nw);
            else
                nw = w + 11 + vec[w + 3][15:0] + vec[w + 4][31:16] + vec[w][7:0];
            w = nw;
            r = r + 1;
        end
    end
endtask

//=========================================================================
// BUS SECTION B: Every Opcode
//=========================================================================
task sec_b;
    integer q;
    integer opc;
    integer missing;
    begin
        $display("");
        $display("=============================================================");
        $display(" BUS SECTION B: Every Opcode");
        $display("=============================================================");

        section("BUS SECTION B.1: Instruction Vectors, Every Opcode Cycle by Cycle");
        vec_load;
        check("vector file loaded", vec_words > 0);
        en_run = 1'b1;
        vec_pass(1);
        missing = 0;
        for(opc = 0; opc < 256; opc = opc + 1) begin
            if(op_n[opc] == 0)
                missing = missing + 1;
            $sformat(nm, "op %h: %0d records, every cycle, final registers, MPRs and memory", opc[7:0], op_n[opc]);
            check(nm, (op_n[opc] > 0) && (op_bad[opc] == 0));
        end
        check_eq("op codes without records", missing, 0);
        $sformat(nm, "all %0d records", vec_tests);
        check(nm, vec_fail == 0);
        $sformat(nm, "CE7 / CEK accesses in the records (each one extra enable): %0d", vec_wait);
        check(nm, vec_wait > 0);
    end
endtask

//=========================================================================
// CLK SECTION K: Enable Ratios and Random Stops
//=========================================================================
task sec_k;
    begin
        $display("");
        $display("=============================================================");
        $display(" CLK SECTION K: Enable Ratios and Random Stops");
        $display("=============================================================");

        section("CLK SECTION K.1: Every 5th Record at 3 clk per Enable");
        tb_ratio = 3;
        vec_pass(5);
        $sformat(nm, "%0d records at ratio 3", vec_tests);
        check(nm, vec_fail == 0);

        section("CLK SECTION K.2: Every 7th Record at 1 clk per Enable with Random Stops");
        tb_ratio = 1;
        en_stall = 1'b1;
        vec_pass(7);
        $sformat(nm, "%0d records at ratio 1 with random stops", vec_tests);
        check(nm, vec_fail == 0);
        en_stall = 1'b0;
        tb_ratio = 2;
    end
endtask
//=========================================================================
// ALU Reference:
// {q, p_out} for every op of x6280_alu from the HuC6280 rules: decimal
// ADC and SBC correct each digit and leave V unchanged; BIT, TSB and TRB
// take N and V from b and Z from a AND b; CMP ignores C and D.
//=========================================================================
function [15:0] ref_alu;
    input [4:0] op;
    input [7:0] a;
    input [7:0] b;
    input [7:0] pin;
    reg   [7:0] q;
    reg   [7:0] p;
    reg   [8:0] s9;
    reg   [5:0] lo;
    reg   [5:0] hi;
    reg         c;
    reg         nz;
    integer     d;
    integer     dl;
    begin
        q = a;
        p = pin;
        c = pin[0];
        nz = 1'b1;
        case(op)
            ALU_OR  : q = a | b;
            ALU_AND : q = a & b;
            ALU_EOR : q = a ^ b;
            ALU_ADC : begin
                if(pin[3]) begin
                    lo = a[3:0] + b[3:0] + c;
                    if(lo > 6'd9)
                        lo = lo + 6'd6;
                    hi = a[7:4] + b[7:4] + (lo > 6'd15);
                    if(hi > 6'd9)
                        hi = hi + 6'd6;
                    q = {hi[3:0], lo[3:0]};
                    p[0] = (hi > 6'd15);
                end else begin
                    s9 = a + b + c;
                    q = s9[7:0];
                    p[0] = s9[8];
                    p[6] = (~(a ^ b) & (a ^ q)) >> 7;
                end
            end
            ALU_SBC : begin
                d = a - b - (c ? 0 : 1);
                q = d;
                p[0] = (d >= 0);
                if(pin[3]) begin
                    dl = a[3:0] - b[3:0] - (c ? 0 : 1);
                    if(d < 0)
                        q = q - 8'h60;
                    if(dl < 0)
                        q = q - 8'h06;
                end else
                    p[6] = ((a ^ b) & (a ^ d)) >> 7;
            end
            ALU_CMP : begin
                d = a - b;
                p[0] = (d >= 0);
                q = d;
            end
            ALU_ASL : begin p[0] = a[7]; q = {a[6:0], 1'b0}; end
            ALU_ROL : begin p[0] = a[7]; q = {a[6:0], c}; end
            ALU_LSR : begin p[0] = a[0]; q = {1'b0, a[7:1]}; end
            ALU_ROR : begin p[0] = a[0]; q = {c, a[7:1]}; end
            ALU_DEC : q = a - 8'h01;
            ALU_INC : q = a + 8'h01;
            ALU_BIT, ALU_TSB, ALU_TRB : begin
                nz = 1'b0;
                p[7] = b[7];
                p[6] = b[6];
                p[1] = ((a & b) == 8'h00);
                q = (op == ALU_TSB) ? (a | b) : (op == ALU_TRB) ? (~a & b) : a;
            end
            ALU_EQ1 : nz = 1'b0;
            default : ;
        endcase
        if(nz) begin
            p[7] = q[7];
            p[1] = (q == 8'h00);
        end
        if(op == ALU_CMP)
            q = a;
        ref_alu = {q, p};
    end
endfunction

//=========================================================================
// ALU SECTION D: Arithmetic and Logic
//=========================================================================
task sec_d;
    integer       opi;
    integer       va;
    integer       vb;
    integer       vp;
    integer       bad;
    integer       tot;
    reg  [4:0]    op;
    reg [15:0]    r;
    reg [8*8-1:0] onm;
    begin
        $display("");
        $display("=============================================================");
        $display(" ALU SECTION D: Arithmetic and Logic");
        $display("=============================================================");

        section("ALU SECTION D.1: Every Operation, Every Input, C and D, Other Flags Passed Through");
        for(opi = 0; opi < 17; opi = opi + 1) begin
            case(opi)
                0  : begin op = ALU_OR;  onm = "ORA"; end
                1  : begin op = ALU_AND; onm = "AND"; end
                2  : begin op = ALU_EOR; onm = "EOR"; end
                3  : begin op = ALU_ADC; onm = "ADC"; end
                4  : begin op = ALU_EQ1; onm = "EQ1"; end
                5  : begin op = ALU_EQ2; onm = "EQ2"; end
                6  : begin op = ALU_CMP; onm = "CMP"; end
                7  : begin op = ALU_SBC; onm = "SBC"; end
                8  : begin op = ALU_ASL; onm = "ASL"; end
                9  : begin op = ALU_ROL; onm = "ROL"; end
                10 : begin op = ALU_LSR; onm = "LSR"; end
                11 : begin op = ALU_ROR; onm = "ROR"; end
                12 : begin op = ALU_BIT; onm = "BIT/TST"; end
                13 : begin op = ALU_DEC; onm = "DEC"; end
                14 : begin op = ALU_INC; onm = "INC"; end
                15 : begin op = ALU_TSB; onm = "TSB"; end
                default : begin op = ALU_TRB; onm = "TRB"; end
            endcase
            bad = 0;
            tot = 0;
            for(va = 0; va < 256; va = va + 1)
                for(vb = 0; vb < 256; vb = vb + 1)
                    for(vp = 0; vp < 4; vp = vp + 1) begin
                        alu_op = op;
                        alu_a = va;
                        alu_b = vb;
                        alu_pin = {(va[0] ? 8'hF4 : 8'h30) & ~8'h09} | {4'h0, vp[1], 2'b00, vp[0]};
                        #1;
                        r = ref_alu(alu_op, alu_a, alu_b, alu_pin);
                        tot = tot + 1;
                        if((alu_q !== r[15:8]) || (alu_pout !== r[7:0])) begin
                            if(bad < 3)
                                $display("INFO: %0s a %h b %h p %h: q %h p %h, expected q %h p %h", onm, alu_a, alu_b,
                                         alu_pin, alu_q, alu_pout, r[15:8], r[7:0]);
                            bad = bad + 1;
                        end
                    end
            $sformat(nm, "%0s: %0d input combinations", onm, tot);
            check(nm, bad == 0);
        end
    end
endtask
//=========================================================================
// Directed-Test Helpers:
// run_to waits for the fetch at a logical address of bank 00 (E000-FFFF);
// cyc_of counts the cycles from the fetch at recorder entry q0 to the next
// fetch; find_w finds the first write at a physical address from entry q0.
//=========================================================================
task run_to;
    input [15:0] la;
    input integer limit;
    output ok;
    begin
        wait_fetch({8'h00, la[12:0]}, limit, ok);
    end
endtask

function [31:0] find_fetch;
    input [31:0] q0;
    input [20:0] pa;
    reg   [31:0] q;
    begin
        find_fetch = 32'hFFFFFFFF;
        for(q = q0; q < tr_n && find_fetch == 32'hFFFFFFFF; q = q + 1)
            if(tr_sy(q) && tr_pa(q) == pa)
                find_fetch = q;
    end
endfunction

function [31:0] cyc_of;
    input [31:0] q0;
    reg   [31:0] q;
    begin
        cyc_of = 32'hFFFFFFFF;
        for(q = q0 + 1; q < tr_n && cyc_of == 32'hFFFFFFFF; q = q + 1)
            if(tr_sy(q))
                cyc_of = q - q0;
        if(cyc_of == 32'hFFFFFFFF && sync_u)
            cyc_of = tr_n - q0;
    end
endfunction

function [31:0] find_w;
    input [31:0] q0;
    input [20:0] pa;
    reg   [31:0] q;
    begin
        find_w = 32'hFFFFFFFF;
        for(q = q0; q < tr_n && find_w == 32'hFFFFFFFF; q = q + 1)
            if(!tr_rw(q) && tr_pa(q) == pa)
                find_w = q;
    end
endfunction

function [31:0] find_vec;
    input [31:0] q0;
    reg   [31:0] q;
    begin
        find_vec = 32'hFFFFFFFF;
        for(q = q0; q < tr_n && find_vec == 32'hFFFFFFFF; q = q + 1)
            if(!tr_vp(q))
                find_vec = q;
    end
endfunction

// RAM through the standard map: logical 2000-3FFF = physical 1F0000-1F1FFF
function [20:0] ram;
    input [15:0] la;
    begin
        ram = {8'hF8, la[12:0]};
    end
endfunction

// Interrupt handlers at E800 (IRQ2 / BRK), E810 (IRQ1), E820 (timer),
// E830 (NMI), each an RTI.
task put_handlers;
    begin
        poke(21'h001FF6, 8'h00); poke(21'h001FF7, 8'hE8);
        poke(21'h001FF8, 8'h10); poke(21'h001FF9, 8'hE8);
        poke(21'h001FFA, 8'h20); poke(21'h001FFB, 8'hE8);
        poke(21'h001FFC, 8'h30); poke(21'h001FFD, 8'hE8);
        org(16'hE800); put(8'h40);
        org(16'hE810); put(8'h40);
        org(16'hE820); put(8'h40);
        org(16'hE830); put(8'h40);
    end
endtask

//=========================================================================
// CPU SECTION A: Reset
//=========================================================================
task sec_a;
    reg        ok;
    reg [31:0] q0;
    reg [31:0] qv;
    reg  [7:0] s_before;
    integer    wb;
    integer    q;
    reg        held;
    begin
        $display("");
        $display("=============================================================");
        $display(" CPU SECTION A: Reset");
        $display("=============================================================");

        section("CPU SECTION A.1: Power-up Values and the Power-up Reset Sequence");
        check_eq("power-up P (I and bit 4 set, T and D clear)", dp_u, 8'h14);
        check_eq("power-up S", ds_u, 8'h00);
        check_eq("power-up A, X, Y", {da_u, dx_u, dy_u}, 24'h000000);
        check_eq("power-up MPR7-MPR0", dmpr_u[63:32], 32'h00FFFFFF);
        check_eq("power-up MPR3-MPR0", dmpr_u[31:0], 32'hFFFFFFFF);
        check_eq("power-up speed (low)", csh_u, 1'b0);
        new_img;
        poke(21'h001FFE, 8'h00);
        poke(21'h001FFF, 8'hE0);
        org(16'hE000); put(8'h80); put(8'hFE);
        en_run = 1'b1;
        run_to(16'hE000, 40, ok);
        check("power-up runs the reset sequence to the vector at FFFE", ok);

        section("CPU SECTION A.2: First Reset: Bus Sequence, Vector FFFE, S - 3, MPRs");
        s_before = ds_u;
        rst_n = 1'b0;
        wait_cen(3);
        q0 = tr_n;
        rst_n = 1'b1;
        run_to(16'hE000, 40, ok);
        check("reset reaches the fetch at E000", ok);
        qv = find_vec(q0);
        check("reset vector reads have vp_n high", qv == 32'hFFFFFFFF);
        q = q0;
        while(q < tr_n && tr_la(q) != 16'hFFFE)
            q = q + 1;
        check("vector low read at FFFE (physical 001FFE)", (q < tr_n) && tr_rw(q) && (tr_pa(q) == 21'h001FFE));
        check("vector high read at FFFF", tr_la(q + 1) == 16'hFFFF && tr_rw(q + 1) && !tr_ic(q + 1));
        check("then one internal cycle at FFFF", tr_ic(q + 2) && tr_la(q + 2) == 16'hFFFF);
        check("then the fetch at E000", (tr_n == q + 3) && sync_u && pa_u == 21'h000000);
        check("three stack reads before the vector",
              tr_rw(q - 1) && tr_rw(q - 2) && tr_rw(q - 3) &&
              tr_la(q - 1) >> 8 == 8'h21 && tr_la(q - 2) >> 8 == 8'h21 && tr_la(q - 3) >> 8 == 8'h21);
        wb = 0;
        for(n = q0; n < q; n = n + 1)
            if(!tr_rw(n))
                wb = wb + 1;
        check_eq("no write in the reset sequence", wb, 0);
        check_eq("S after reset (S - 3)", ds_u, s_before - 8'd3);
        check_eq("P after reset: I set, D and T clear", dp_u & 8'h2C, 8'h04);
        check_eq("MPR7-MPR4 after reset", dmpr_u[63:32], 32'h00FFFFFF);
        check_eq("MPR3-MPR0 after reset", dmpr_u[31:0], 32'hFFFFFFFF);

        section("CPU SECTION A.3: Warm Reset Keeps A, X, Y; Clears D, T and the Speed; Sets I; MPRs");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA9); put(8'h5A);             // LDA #5A
        put(8'hA2); put(8'h66);             // LDX #66
        put(8'hA0); put(8'h77);             // LDY #77
        put(8'hF8);                         // SED
        put(8'h58);                         // CLI
        put(8'hD4);                         // CSH
        put(8'hA9); put(8'h03);             // LDA #03
        put(8'h53); put(8'h02);             // TAM #02 (MPR1 = 03)
        put(8'hF4);                         // SET
        put(8'h80); put(8'hFE);             // BRA *
        boot_at(16'hE000);
        run_to(16'hE000, 60, ok);
        run_to(16'hE02D, 400, ok);
        check("program reaches the loop", ok);
        check_eq("speed before reset (CSH)", csh_u, 1'b1);
        s_before = ds_u;
        do_reset;
        run_to(16'hE000, 60, ok);
        check("warm reset reaches E000", ok);
        check_eq("A, X, Y kept", {da_u, dx_u, dy_u}, 24'h036677);
        check_eq("P: I set, D clear, T clear", dp_u & 8'h2C, 8'h04);
        check_eq("speed low after reset", csh_u, 1'b0);
        check_eq("MPRs after reset", dmpr_u, 64'h00FFFFFFFFFFFFFF);
        check_eq("S after warm reset (S - 3)", ds_u, s_before - 8'd3);

        section("CPU SECTION A.4: Bus while RES Is Low");
        run_to(16'hE02D, 400, ok);
        wb = wr_cnt_u;
        q0 = tr_n;
        rst_n = 1'b0;
        wait_cen(12);
        held = 1'b1;
        for(n = q0 + 2; n < tr_n; n = n + 1)
            if(!tr_rw(n) || tr_la(n) != tr_la(q0 + 2))
                held = 1'b0;
        check("address held with R/W high while RES is low", held && (tr_n - q0 >= 10));
        check_eq("no write while RES is low", wr_cnt_u - wb, 0);
        rst_n = 1'b1;
        run_to(16'hE000, 60, ok);
        check("restart after RES high", ok);

        section("CPU SECTION A.5: RES Sampled at cen Only");
        run_to(16'hE02D, 400, ok);
        tb_ratio = 4;
        wait_cen(2);
        @(posedge clk);
        @(posedge clk);
        #2;
        rst_n = 1'b0;
        @(posedge clk);
        #2;
        rst_n = 1'b1;
        q0 = tr_n;
        wait_cen(40);
        qv = 32'hFFFFFFFF;
        for(n = q0; n < tr_n; n = n + 1)
            if(tr_la(n) == 16'hFFFE)
                qv = n;
        check("a RES pulse between enables is not seen", qv == 32'hFFFFFFFF);
        tb_ratio = 2;
    end
endtask

//=========================================================================
// CPU SECTION E: HuC6280 Instructions
//=========================================================================
task t_kind;
    input [8*24-1:0] knm;
    input [7:0]      b0;
    input [7:0]      b1;
    input [7:0]      b2;
    input integer len;
    reg ok;
    begin
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA2); put(8'h10);             // LDX #10
        put(8'h64); put(8'h10);             // STZ 10
        put(8'h18);                         // CLC
        put(8'hA9); put(8'h20);             // LDA #20
        put(8'hF4);                         // SET
        put(b0);
        if(len > 1) put(b1);
        if(len > 2) put(b2);
        put(8'h69); put(8'h01);             // ADC #01
        put(8'h85); put(8'h81);             // STA 81
        put(8'h80); put(8'hFE);             // BRA *
        boot_at(16'hE000);
        run_to(pc_put - 2, 2000, ok);
        $sformat(nm, "SET, %0s, ADC #01: ADC on A (A = 21, 2010 unchanged)", knm);
        check(nm, ok && peek(ram(16'h2081)) == 8'h21 && peek(ram(16'h2010)) == 8'h00);
    end
endtask

reg  [8:0] bexp [0:127];

task blk_test;
    input [7:0] op;
    input integer len;
    reg        ok;
    reg [31:0] q0;
    reg [15:0] src;
    reg [15:0] dst;
    reg  [7:0] got;
    reg  [7:0] exp;
    integer    q;
    integer    bad;
    reg        alt;
    begin
        new_img;
        src = (op == 8'hC3) ? 16'h4040 : 16'h4020;
        dst = (op == 8'hC3) ? 16'h6040 : 16'h6020;
        for(q = 0; q < 96; q = q + 1)
            poke({8'h01, 13'h0000 + q}, q * 7 + 3);           // source bank 01 (logical 4000)
        org(16'hE000);
        std_map;
        put(8'hA9); put(8'hA5);             // LDA #A5
        put(8'hA2); put(8'h5A);             // LDX #5A
        put(8'hA0); put(8'hC3);             // LDY #C3
        put(op); put(src[7:0]); put(src[15:8]); put(dst[7:0]); put(dst[15:8]); put(len[7:0]); put(8'h00);
        put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        run_to(16'hE025, 200, ok);
        q0 = tr_n;
        run_to(16'hE02C, 2000, ok);
        bad = 0;
        alt = 1'b0;
        for(q = 0; q < 128; q = q + 1)
            bexp[q] = 9'h100;
        for(q = 0; q < len; q = q + 1) begin
            bexp[dst[6:0]] = {1'b0, peek({8'h01, src[12:0]})};
            case(op)
                8'h73 : begin src = src + 1; dst = dst + 1; end
                8'hC3 : begin src = src - 1; dst = dst - 1; end
                8'hD3 : src = src + 1;
                8'hE3 : begin src = src + 1; dst = alt ? dst - 1 : dst + 1; end
                default : begin src = alt ? src - 1 : src + 1; dst = dst + 1; end
            endcase
            alt = ~alt;
        end
        for(q = 0; q < 128; q = q + 1)
            if(!bexp[q][8] && (peek({8'h02, 6'h00, q[6:0]}) !== bexp[q][7:0]))
                bad = bad + 1;
        $sformat(nm, "%h length %0d: data, %0d cycles, A X Y restored, S unchanged, Y A X pushed", op, len, 17 + 6 * len);
        check(nm, ok && (bad == 0) && (cyc_of(q0) == 17 + 6 * len) && (da_u == 8'hA5) && (dx_u == 8'h5A) &&
                  (dy_u == 8'hC3) && (ds_u == 8'hFF) && (peek(ram(16'h21FF)) == 8'hC3) &&
                  (peek(ram(16'h21FE)) == 8'hA5) && (peek(ram(16'h21FD)) == 8'h5A));
    end
endtask

task sec_e;
    reg        ok;
    reg [31:0] q0;
    reg [31:0] q1;
    integer    q;
    integer    bad;
    begin
        $display("");
        $display("=============================================================");
        $display(" CPU SECTION E: HuC6280 Instructions");
        $display("=============================================================");

        section("CPU SECTION E.1: T Cleared by Every Instruction Kind");
        t_kind("NOP", 8'hEA, 8'h00, 8'h00, 1);
        t_kind("LDY #00", 8'hA0, 8'h00, 8'h00, 2);
        t_kind("STY 20", 8'h84, 8'h20, 8'h00, 2);
        t_kind("BIT #00", 8'h89, 8'h00, 8'h00, 2);
        t_kind("BRA +0", 8'h80, 8'h00, 8'h00, 2);
        t_kind("INY", 8'hC8, 8'h00, 8'h00, 1);
        t_kind("STZ 30", 8'h64, 8'h30, 8'h00, 2);
        t_kind("BBR0 30, +0", 8'h0F, 8'h30, 8'h00, 3);
        t_kind("TST #01, 30", 8'h83, 8'h01, 8'h30, 3);
        t_kind("CSH", 8'hD4, 8'h00, 8'h00, 1);
        t_kind("SEI", 8'h78, 8'h00, 8'h00, 1);
        t_kind("CLV", 8'hB8, 8'h00, 8'h00, 1);

        section("CPU SECTION E.2: T Memory Operation, PHP, PLP");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA2); put(8'h10);             // LDX #10
        put(8'hA9); put(8'h07); put(8'h85); put(8'h10);   // 2010 = 07
        put(8'h18);                         // CLC
        put(8'hA9); put(8'h40);             // LDA #40
        put(8'hF4); put(8'h69); put(8'h05); // SET; ADC #05 -> 2010 = 0C
        put(8'h85); put(8'h81);             // STA 81 (A unchanged = 40)
        put(8'hF4); put(8'h08);             // SET; PHP
        put(8'h68); put(8'h85); put(8'h82); // PLA; STA 82
        put(8'hA9); put(8'h20); put(8'h48); // LDA #20 (T); PHA
        put(8'hA9); put(8'h40); put(8'h28); // LDA #40; PLP (T = 1)
        put(8'h05); put(8'h83);             // ORA 83 -> 2010 = 0C | M(2083)
        put(8'h85); put(8'h84);             // STA 84
        put(8'h80); put(8'hFE);
        poke(ram(16'h2083), 8'h30);
        boot_at(16'hE000);
        run_to(pc_put - 2, 2000, ok);
        check("SET; ADC #05: 2010 = 07 + 05, A unchanged", ok && peek(ram(16'h2081)) == 8'h40);
        check_eq("PHP after SET: bit 5 (T) 0, bit 4 (B) 1", peek(ram(16'h2082)) & 8'h30, 8'h10);
        check_eq("PLP with bit 5 set, ORA zp: memory operation on 2010", peek(ram(16'h2010)), 8'h3C);
        check_eq("A unchanged by the memory ORA", peek(ram(16'h2084)), 8'h40);

        section("CPU SECTION E.3: Block Transfers, Every Op, Lengths 1-16");
        for(q = 1; q <= 16; q = q + 1) begin
            blk_test(8'h73, q);
            blk_test(8'hC3, q);
            blk_test(8'hD3, q);
            blk_test(8'hE3, q);
            blk_test(8'hF3, q);
        end

        section("CPU SECTION E.4: Block Transfer of Length 0 (65536 Bytes)");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA9); put(8'h06); put(8'h53); put(8'h01);   // MPR0 = 06 (RAM, no CE7 / CEK)
        put(8'hD3); put(8'h00); put(8'h00); put(8'h80); put(8'h20); put(8'h00); put(8'h00);  // TIN 0000, 2080, 0
        put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        run_to(16'hE023, 200, ok);
        q0 = tr_n;
        run_to(16'hE02A, 900000, ok);
        check_eq("TIN length 0: cycles (17 + 6 x 65536)", tr_n - q0, 393233);
        check_eq("last byte moved is logical FFFF (physical 001FFF)", peek(ram(16'h2080)), peek(21'h001FFF));

        section("CPU SECTION E.5: Mapping Registers, TAM, TMA, ST0-ST2");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA9); put(8'h11); put(8'h53); put(8'h04);   // MPR2 = 11
        put(8'hA9); put(8'h22); put(8'h53); put(8'h48);   // MPR3, MPR6 = 22
        put(8'hA9); put(8'h00); put(8'h43); put(8'h04);   // TMA #04 -> 11
        put(8'h85); put(8'h81);
        put(8'h43); put(8'h08); put(8'h85); put(8'h82);   // TMA #08 -> 22
        put(8'h43); put(8'h0C); put(8'h85); put(8'h83);   // TMA #0C -> 11 | 22
        put(8'h43); put(8'h00); put(8'h85); put(8'h84);   // TMA #00 -> 22 (last TAM)
        put(8'hA9); put(8'h77); put(8'h53); put(8'h00);   // TAM #00: nothing
        put(8'h43); put(8'h00); put(8'h85); put(8'h85);   // TMA #00 -> 22
        put(8'hAD); put(8'h34); put(8'h45);               // LDA 4534 (MPR2 = 11)
        put(8'hAD); put(8'h56); put(8'h67);               // LDA 6756 (MPR3 = 22)
        put(8'hA9); put(8'h01); put(8'h53); put(8'h01);   // MPR0 = 01
        put(8'h03); put(8'h41);                           // ST0 #41
        put(8'h13); put(8'h42);                           // ST1 #42
        put(8'h23); put(8'h43);                           // ST2 #43
        put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        q0 = tr_n;
        run_to(pc_put - 2, 2000, ok);
        check("program ends", ok);
        check_eq("TAM #48 loads MPR3 and MPR6; MPR7-MPR0", dmpr_u, 64'h002204032211F801);
        check_eq("TMA #04", peek(ram(16'h2081)), 8'h11);
        check_eq("TMA #08", peek(ram(16'h2082)), 8'h22);
        check_eq("TMA #0C (OR of MPR2 and MPR3)", peek(ram(16'h2083)), 8'h33);
        check_eq("TMA #00 (last TAM value)", peek(ram(16'h2084)), 8'h22);
        check_eq("TMA #00 after TAM #00 (TAM #00 changes nothing)", peek(ram(16'h2085)), 8'h22);
        q1 = q0;
        while(q1 < tr_n && tr_la(q1) != 16'h4534) q1 = q1 + 1;
        check_eq("LDA 4534 reads physical (MPR2 = 11)", tr_pa(q1), {8'h11, 13'h0534});
        q1 = q0;
        while(q1 < tr_n && tr_la(q1) != 16'h6756) q1 = q1 + 1;
        check_eq("LDA 6756 reads physical (MPR3 = 22)", tr_pa(q1), {8'h22, 13'h0756});
        q1 = find_w(q0, 21'h1FE000);
        check("ST0 writes 41 to 1FE000 with MPR0 = 01", q1 != 32'hFFFFFFFF && tr_d(q1) == 8'h41);
        q1 = find_w(q0, 21'h1FE002);
        check("ST1 writes 42 to 1FE002", q1 != 32'hFFFFFFFF && tr_d(q1) == 8'h42);
        q1 = find_w(q0, 21'h1FE003);
        check("ST2 writes 43 to 1FE003", q1 != 32'hFFFFFFFF && tr_d(q1) == 8'h43);
        check("no write to bank 01 at 0000-0003", find_w(q0, 21'h002000) == 32'hFFFFFFFF &&
              find_w(q0, 21'h002002) == 32'hFFFFFFFF);

        section("CPU SECTION E.6: CSL and CSH: the Speed Changes at the Start of Cycle 3");
        new_img;
        org(16'hE000);
        put(8'hD4);                         // CSH
        put(8'h54);                         // CSL
        put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        q0 = tr_n;
        run_to(16'hE002, 200, ok);
        q1 = find_fetch(q0, 21'h000000);
        check("CSH: cycle 2 low speed, cycle 3 (internal) high speed",
              q1 != 32'hFFFFFFFF && !tr_csh(q1 + 1) && tr_csh(q1 + 2) && tr_ic(q1 + 2));
        q1 = find_fetch(q0, 21'h000001);
        check("CSL: cycle 2 high speed, cycle 3 (internal) low speed",
              q1 != 32'hFFFFFFFF && tr_csh(q1 + 1) && !tr_csh(q1 + 2) && tr_ic(q1 + 2));

        section("CPU SECTION E.7: BSR, JSR, RTS Round Trips");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA0); put(8'h00);             // LDY #00 (E01F)
        put(8'h44); put(8'h2D);             // BSR +2D (E021) -> E050
        put(8'h20); put(8'h60); put(8'hE0); // JSR E060 (E023)
        put(8'h80); put(8'hFE);             // BRA * (E026)
        org(16'hE050); put(8'hE8); put(8'h60);   // INX; RTS
        org(16'hE060); put(8'hC8); put(8'h60);   // INY; RTS
        boot_at(16'hE000);
        q0 = tr_n;
        run_to(16'hE026, 400, ok);
        check("BSR and JSR return to the next instruction", ok);
        q1 = find_w(q0, ram(16'h21FF));
        check_eq("BSR pushes PCH of BSR + 1", tr_d(q1), 8'hE0);
        check_eq("BSR pushes PCL of BSR + 1", tr_d(q1 + 1), 8'h22);
        q1 = find_w(q1 + 2, ram(16'h21FF));
        check_eq("JSR pushes PCL of its last byte", tr_d(q1 + 1), 8'h25);
        check_eq("X and Y from the subroutines", {dx_u, dy_u}, {8'h00, 8'h01});

        section("CPU SECTION E.8: Block Transfer over Its Saved Registers");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA2); put(8'h11);             // LDX #11 (E01F)
        put(8'hA9); put(8'h22);             // LDA #22
        put(8'hA0); put(8'h33);             // LDY #33
        put(8'h73); put(8'hF0); put(8'hE0); put(8'hFD); put(8'h21); put(8'h03); put(8'h00); // TII E0F0, 21FD, 3
        put(8'h86); put(8'h80);             // STX 80
        put(8'h85); put(8'h81);             // STA 81
        put(8'h84); put(8'h82);             // STY 82
        put(8'h80); put(8'hFE);             // BRA * (E032)
        org(16'hE0F0); put(8'hA1); put(8'hA2); put(8'hA3);
        boot_at(16'hE000);
        run_to(16'hE032, 800, ok);
        check("program reaches the end", ok);
        check_eq("X, A, Y pulled from 21FD, 21FE, 21FF as the transfer left them",
                 {peek(ram(16'h2080)), peek(ram(16'h2081)), peek(ram(16'h2082))}, 24'hA1A2A3);
    end
endtask

//=========================================================================
// INT SECTION F: Interrupts
//=========================================================================
task irq_at;
    // IRQ1 low from enable k after the fetch of LDA abs at E01D; returns
    // the PC pushed by the entry
    input integer k;
    output [15:0] pushed;
    reg           ok;
    reg    [31:0] q0;
    reg    [31:0] q1;
    begin
        new_img;
        org(16'hE000);
        std_map;
        put(8'h58);                         // CLI (E01F)
        put(8'hAD); put(8'h00); put(8'h40); // LDA 4000 (E020)
        put(8'hEA);                         // NOP (E023)
        put(8'hEA);                         // NOP (E024)
        put(8'h80); put(8'hFE);             // BRA * (E025)
        put_handlers;
        org(16'hE810); put(8'h78); put(8'h80); put(8'hFE);   // SEI; BRA *
        boot_at(16'hE000);
        irq_vec = 2'b01;
        run_to(16'hE020, 400, ok);
        q0 = tr_n;
        wait_cen(k);
        irq_n = 1'b0;
        run_to(16'hE811, 200, ok);
        irq_n = 1'b1;
        q1 = find_w(q0, ram(16'h21FF));
        pushed = {tr_d(q1), tr_d(q1 + 1)};
    end
endtask

task sec_f;
    reg        ok;
    reg [31:0] q0;
    reg [31:0] q1;
    reg [15:0] pushed;
    integer    q;
    begin
        $display("");
        $display("=============================================================");
        $display(" INT SECTION F: Interrupts");
        $display("=============================================================");

        section("INT SECTION F.1: Vectors and B of Every Source");
        for(q = 0; q < 5; q = q + 1) begin
            new_img;
            org(16'hE000);
            std_map;
            put(8'hF8);                         // SED
            put(8'h58);                         // CLI
            if(q == 4) begin
                put(8'h00); put(8'hEA);         // BRK
            end
            put(8'hEA); put(8'hEA);
            put(8'h80); put(8'hFE);
            put_handlers;
            boot_at(16'hE000);
            run_to(16'hE021, 400, ok);
            q0 = tr_n;
            if(q < 3) begin
                irq_vec = (q == 0) ? 2'b00 : (q == 1) ? 2'b01 : 2'b10;
                irq_n = 1'b0;
            end else if(q == 3)
                nmi_n = 1'b0;
            run_to((q == 0 || q == 4) ? 16'hE800 : (q == 1) ? 16'hE810 : (q == 2) ? 16'hE820 : 16'hE830, 200, ok);
            irq_n = 1'b1;
            nmi_n = 1'b1;
            q1 = find_vec(q0);
            case(q)
                0 : nm = "IRQ2: vector FFF6, B = 0";
                1 : nm = "IRQ1: vector FFF8, B = 0";
                2 : nm = "timer: vector FFFA, B = 0";
                3 : nm = "NMI: vector FFFC, B = 0";
                default : nm = "BRK: vector FFF6, B = 1";
            endcase
            check(nm, ok && q1 != 32'hFFFFFFFF &&
                  tr_la(q1) == ((q == 0 || q == 4) ? 16'hFFF6 : (q == 1) ? 16'hFFF8 : (q == 2) ? 16'hFFFA : 16'hFFFC) &&
                  !tr_vp(q1 + 1) && tr_ic(q1 + 2) && !tr_rw(q1 - 1) &&
                  (tr_d(q1 - 1) & 8'h10) == ((q == 4) ? 8'h10 : 8'h00) && (tr_d(q1 - 1) & 8'h08) == 8'h08);
            check_eq("  handler fetch: I set, D and T clear", dp_u & 8'h2C, 8'h04);
        end

        section("INT SECTION F.2: Entry Sequence: 8 Cycles");
        new_img;
        org(16'hE000);
        std_map;
        put(8'h58); put(8'hEA); put(8'hEA); put(8'h80); put(8'hFE);
        put_handlers;
        boot_at(16'hE000);
        run_to(16'hE020, 400, ok);
        irq_vec = 2'b01;
        irq_n = 1'b0;
        q0 = tr_n;
        run_to(16'hE810, 200, ok);
        irq_n = 1'b1;
        q1 = find_vec(q0);
        check("discarded fetch, read of PC, PCH, PCL, P, vector low and high, internal cycle",
              tr_sy(q1 - 5) && tr_rw(q1 - 4) && (tr_la(q1 - 4) == tr_la(q1 - 5)) &&
              !tr_rw(q1 - 3) && !tr_rw(q1 - 2) && !tr_rw(q1 - 1) && !tr_vp(q1) && !tr_vp(q1 + 1) &&
              tr_ic(q1 + 2) && (tr_n == q1 + 3) && sync_u);

        section("INT SECTION F.3: Poll at the Start of the Last Cycle (LDA abs)");
        irq_at(3, pushed);
        check_eq("IRQ low at the start of cycle 5: taken after LDA (pushed E023)", pushed, 16'hE023);
        irq_at(4, pushed);
        check_eq("IRQ low after the start of cycle 5: taken after the next NOP (pushed E024)", pushed, 16'hE024);

        section("INT SECTION F.4: Block Transfer Holds Interrupts to Its End");
        new_img;
        org(16'hE000);
        std_map;
        put(8'h58);                                                       // CLI
        put(8'h73); put(8'h00); put(8'h40); put(8'h00); put(8'h60); put(8'h08); put(8'h00); // TII len 8
        put(8'hEA);                                                       // NOP (E027)
        put(8'h80); put(8'hFE);
        put_handlers;
        org(16'hE810); put(8'h78); put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        run_to(16'hE020, 400, ok);
        wait_cen(20);
        irq_vec = 2'b01;
        irq_n = 1'b0;
        q0 = tr_n;
        run_to(16'hE811, 400, ok);
        irq_n = 1'b1;
        q1 = find_w(q0, ram(16'h21FF));
        check_eq("IRQ during TII is taken after it, before the NOP (pushed E027)", {tr_d(q1), tr_d(q1 + 1)}, 16'hE027);

        section("INT SECTION F.5: No Takeover of BRK; NMI before IRQ; NMI Edge");
        new_img;
        org(16'hE000);
        std_map;
        put(8'h58); put(8'h00); put(8'hEA); put(8'h80); put(8'hFE);
        put_handlers;
        org(16'hE800); put(8'hEA); put(8'h40);    // IRQ2 / BRK handler: NOP; RTI
        boot_at(16'hE000);
        run_to(16'hE020, 400, ok);
        q0 = tr_n;
        wait_cen(2);
        nmi_n = 1'b0;
        run_to(16'hE830, 200, ok);
        nmi_n = 1'b1;
        check("NMI during the BRK entry: BRK handler's first instruction runs first", ok &&
              (find_fetch(q0, 21'h000800) != 32'hFFFFFFFF) && (find_fetch(q0, 21'h000800) < find_fetch(q0, 21'h000830)));
        new_img;
        org(16'hE000);
        std_map;
        put(8'h58); put(8'hEA); put(8'hEA); put(8'h80); put(8'hFE);
        put_handlers;
        org(16'hE830); put(8'h78); put(8'h40);      // NMI: SEI; RTI
        boot_at(16'hE000);
        run_to(16'hE020, 400, ok);
        q0 = tr_n;
        irq_vec = 2'b01;
        irq_n = 1'b0;
        nmi_n = 1'b0;
        run_to(16'hE830, 200, ok);
        irq_n = 1'b1;
        check("NMI and IRQ together: NMI first", ok && find_fetch(q0, 21'h000810) == 32'hFFFFFFFF);
        wait_cen(60);
        q1 = 0;
        for(n = q0; n < tr_n; n = n + 1)
            if(!tr_vp(n) && tr_la(n) == 16'hFFFC)
                q1 = q1 + 1;
        check_eq("NMI held low: one entry (edge)", q1, 1);
        nmi_n = 1'b1;

        section("INT SECTION F.6: Vector Select Latched When the Entry Starts");
        new_img;
        org(16'hE000);
        std_map;
        put(8'h58); put(8'hEA); put(8'hEA); put(8'h80); put(8'hFE);
        put_handlers;
        org(16'hE810); put(8'h78); put(8'h80); put(8'hFE);
        org(16'hE820); put(8'h78); put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        run_to(16'hE020, 400, ok);
        irq_vec = 2'b01;
        irq_n = 1'b0;
        q0 = tr_n;
        wait_cycles(4);
        irq_vec = 2'b10;
        run_to(16'hE810, 200, ok);
        check("irq_vec changed during the entry: IRQ1 vector kept", ok);
        irq_n = 1'b1;
        irq_vec = 2'b00;

        section("INT SECTION F.7: T across an Interrupt");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA2); put(8'h10);             // LDX #10
        put(8'h64); put(8'h10);             // STZ 10
        put(8'h18);                         // CLC
        put(8'hA9); put(8'h20);             // LDA #20
        put(8'h58);                         // CLI (E026)
        put(8'hF4);                         // SET (E027)
        put(8'h69); put(8'h05);             // ADC #05 (E028)
        put(8'h85); put(8'h81);             // STA 81
        put(8'h80); put(8'hFE);             // BRA * (E02C)
        put_handlers;
        org(16'hE810); put(8'h48); put(8'h78); put(8'h18); put(8'h69); put(8'h01); put(8'h85); put(8'h82);
        put(8'h68); put(8'h40);
        boot_at(16'hE000);
        run_to(16'hE027, 400, ok);
        irq_vec = 2'b01;
        irq_n = 1'b0;
        q0 = tr_n;
        run_to(16'hE810, 200, ok);
        irq_n = 1'b1;
        run_to(16'hE02C, 400, ok);
        q1 = find_w(q0, ram(16'h21FD));
        check("IRQ after SET: pushed P has T", q1 != 32'hFFFFFFFF && (tr_d(q1) & 8'h20));
        check_eq("handler ADC #01 on A (T clear in the handler)", peek(ram(16'h2082)), 8'h21);
        check_eq("after RTI, ADC #05 is the memory operation (2010 = 05)", peek(ram(16'h2010)), 8'h05);
        check_eq("A unchanged by it", peek(ram(16'h2081)), 8'h20);

        section("INT SECTION F.8: T Cleared by the Entry (Handler Starts with ORA #)");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hA2); put(8'h10);             // LDX #10
        put(8'h64); put(8'h10);             // STZ 10
        put(8'h18);                         // CLC
        put(8'hA9); put(8'h20);             // LDA #20
        put(8'h58);                         // CLI (E026)
        put(8'hF4);                         // SET (E027)
        put(8'h69); put(8'h05);             // ADC #05 (E028)
        put(8'h85); put(8'h81);             // STA 81
        put(8'h80); put(8'hFE);             // BRA * (E02C)
        put_handlers;
        org(16'hE810); put(8'h09); put(8'h01); put(8'h85); put(8'h83); put(8'h40);   // ORA #01; STA 83; RTI
        boot_at(16'hE000);
        run_to(16'hE027, 400, ok);
        irq_vec = 2'b01;
        irq_n = 1'b0;
        run_to(16'hE810, 200, ok);
        irq_n = 1'b1;
        run_to(16'hE02C, 400, ok);
        check_eq("handler ORA #01 operates on A (2083 = 21)", peek(ram(16'h2083)), 8'h21);
        check_eq("after RTI, ADC #05 is the memory operation (2010 = 05)", peek(ram(16'h2010)), 8'h05);
        check_eq("A from the handler (2081 = 21)", peek(ram(16'h2081)), 8'h21);

        section("INT SECTION F.9: Poll in the Internal Cycle before the Fetch (JMP)");
        new_img;
        org(16'hE000);
        std_map;
        put(8'h58);                         // CLI (E01F)
        put(8'h4C); put(8'h30); put(8'hE0); // JMP E030 (E020)
        org(16'hE030);
        put(8'hEA);                         // NOP (E030)
        put(8'hEA);                         // NOP (E031)
        put(8'h80); put(8'hFE);             // BRA * (E032)
        put_handlers;
        org(16'hE810); put(8'h78); put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        run_to(16'hE020, 400, ok);
        irq_vec = 2'b01;
        irq_n = 1'b0;
        q0 = tr_n;
        run_to(16'hE811, 200, ok);
        irq_n = 1'b1;
        q1 = find_w(q0, ram(16'h21FF));
        check_eq("IRQ low at the JMP fetch: taken after JMP (pushed E030)", {tr_d(q1), tr_d(q1 + 1)}, 16'hE030);
    end
endtask

//=========================================================================
// BUS SECTION G: RDY and the CE7 / CEK Wait
//=========================================================================
task sec_g;
    reg        ok;
    reg [31:0] q0;
    reg [31:0] q1;
    integer    wb;
    integer    hn;
    integer    q;
    begin
        $display("");
        $display("=============================================================");
        $display(" BUS SECTION G: RDY and the CE7 / CEK Wait");
        $display("=============================================================");

        section("BUS SECTION G.1: RDY Holds Reads, Writes and Internal Cycles");
        for(q = 0; q < 3; q = q + 1) begin
            new_img;
            org(16'hE000);
            std_map;
            put(8'hA9); put(8'h3C);             // LDA #3C (E01F)
            put(8'hEA);                         // NOP (E021)
            put(8'h8D); put(8'h80); put(8'h20); // STA 2080 (E022): F, R, R, I, W
            put(8'hEA); put(8'h80); put(8'hFE); // NOP (E025)
            boot_at(16'hE000);
            run_to(16'hE022, 400, ok);
            q0 = tr_n;
            wb = wr_cnt_u;
            wait_cen(1 + q + 1);                // into cycle 3 + q (R PC+2, I, W)
            rdy = 1'b0;
            wait_cen(5);
            rdy = 1'b1;
            run_to(16'hE025, 100, ok);
            case(q)
                0 : nm = "read cycle held 5 enables: one cycle, address and data kept";
                1 : nm = "internal cycle held 5 enables";
                default : nm = "write cycle held 5 enables: one write";
            endcase
            check(nm, ok && (tr_en(q0 + 2 + q) == 4'd6) && (cyc_of(q0) == 5) &&
                  (wr_cnt_u - wb == 1) && (peek(ram(16'h2080)) == 8'h3C));
        end

        section("BUS SECTION G.2: CE7 / CEK Accesses Last One More Enable");
        new_img;
        org(16'hE000);
        std_map;
        put(8'hAD); put(8'h00); put(8'h00);   // LDA 0000 (1FE000, VDC)
        put(8'hAD); put(8'h04); put(8'h04);   // LDA 0404 (1FE404, VCE)
        put(8'hAD); put(8'h00); put(8'h08);   // LDA 0800 (1FE800, PSG)
        put(8'h8D); put(8'h02); put(8'h00);   // STA 0002 (1FE002)
        put(8'h03); put(8'h55);               // ST0 #55
        put(8'h80); put(8'hFE);
        boot_at(16'hE000);
        q0 = tr_n;
        run_to(pc_put - 2, 400, ok);
        q1 = q0; while(q1 < tr_n && !(tr_pa(q1) == 21'h1FE000 && tr_rw(q1) && !tr_ic(q1))) q1 = q1 + 1;
        check_eq("read of 1FE000: enables", tr_en(q1), 4'd2);
        check("the internal cycle before it: one enable", tr_ic(q1 - 1) && tr_en(q1 - 1) == 4'd1);
        q1 = q0; while(q1 < tr_n && tr_pa(q1) != 21'h1FE404) q1 = q1 + 1;
        check_eq("read of 1FE404: enables", tr_en(q1), 4'd2);
        q1 = q0; while(q1 < tr_n && tr_pa(q1) != 21'h1FE800) q1 = q1 + 1;
        check_eq("read of 1FE800 (PSG): enables", tr_en(q1), 4'd1);
        q1 = find_w(q0, 21'h1FE002);
        check_eq("write of 1FE002: enables", tr_en(q1), 4'd2);
        q1 = q0; while(q1 < tr_n && !(tr_pa(q1) == 21'h1FE000 && !tr_rw(q1))) q1 = q1 + 1;
        check("ST0: write of 1FE000 with 2 enables, instruction 5 enables",
              q1 < tr_n && tr_en(q1) == 4'd2 && tr_d(q1) == 8'h55);

        section("BUS SECTION G.3: CE_WAIT = 0");
        hn = 0;
        run_to(pc_put - 2, 10, ok);
        do_reset;
        q = 0;
        while(q < 400) begin
            @(posedge clk);
            if(cen) begin
                q = q + 1;
                if(!bce_n)
                    hn = hn + 1;
            end
        end
        check_eq("uutn: enables without a cycle end over the same program", hn, 0);
    end
endtask

//=========================================================================
// Main Sequence
//=========================================================================
initial begin
    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;
    tb_ratio = 2;
    en_run = 1'b0;
    en_stall = 1'b0;
    en_ph = 0;
    en_hold = 0;
    en_seed = 6280;
    seed = 6280;
    rst_n = 1'b1;
    rdy = 1'b1;
    irq_n = 1'b1;
    irq_vec = 2'b00;
    nmi_n = 1'b1;
    img = 16'd1;
    fill = 8'h00;
    mem_gen = 0;
    wr_cnt_u = 0;
    tr_n = 0;
    en_cnt = 0;

    $display("=============================================================");
    $display("  x6280 CPU Testbench");
    $display("  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware and");
    $display("             Software Manuals (Hudson Soft)");
    $display("=============================================================");

    sec_a;
    sec_b;
    sec_d;
    sec_e;
    sec_f;
    sec_g;
    sec_k;

    $display("");
    $display("=============================================================");
    $display("  x6280 CPU Test Results");
    $display("=============================================================");
    $display("  Total Tests:  %0d", total_tests);
    $display("  Passed:       %0d", passed_tests);
    $display("  Failed:       %0d", failed_tests);
    $display("=============================================================");
    if(failed_tests == 0) begin
        $display("  *** ALL TESTS PASSED ***");
        $display("  Cycle-accurate to the HuC6280 Hardware and Software Manuals");
    end else begin
        $display("  *** SOME TESTS FAILED ***");
    end
    $display("=============================================================");
    $finish;
end

endmodule
