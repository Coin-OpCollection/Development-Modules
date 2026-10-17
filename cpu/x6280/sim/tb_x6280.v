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
//  Chip-level testbench for the x6280 integrator.
//
//  Runs real HuC6280 programs on x6280 with an external 2 MB memory and
//  checks the parts around the CPU: external strobes and chip enables,
//  the interrupt controller, the timer, the I/O ports, the PSG register
//  path and level, the CSL / CSH enable, RDY and the CE7 / CEK wait.
//
//  DUTs:
//    uut   - x6280 with the defaults (CE_WAIT = 1, INT_RD = 0, PSG = 1)
//    uutr  - INT_RD = 1, PSG = 0 (rd_n in internal cycles; no PSG)
//    upsg  - x6280_psg driven from its register port (Section 5)
//  uut and uutr run the same program from their own memory copy.
//
//  Test Organization:
//    Section 1  External strobes and chip enables
//    Section 2  Interrupt controller
//    Section 3  Timer
//    Section 4  I/O ports
//    Section 5  PSG
//    Section 6  CSL / CSH enable
//    Section 7  RDY and the CE7 / CEK wait
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual and
//             Programmable Sound Generator Manual (Hudson Soft)
//============================================================================

`timescale 1ns/1ps

module tb_x6280;

reg        clk;
reg        cen;
reg        rst_n;
reg        rdy;
reg        nmi_n;
reg        irq1_n;
reg        irq2_n;
reg  [7:0] k;

integer total_tests;
integer passed_tests;
integer failed_tests;
integer q;
integer n;
reg [8*160-1:0] nm;

initial clk = 1'b0;
always #5 clk = ~clk;

// one enable every 2 clk
reg en_ph;
always @(posedge clk) begin
    en_ph <= ~en_ph;
    cen <= #1 en_ph;
end

//=========================================================================
// DUTs and Memory
//=========================================================================
wire [20:0]        a;
wire  [7:0]        dout;
wire               rd_n;
wire               wr_n;
wire               sync;
wire               vp_n;
wire               ce;
wire               cek_n;
wire               ce7_n;
wire               cer_n;
wire               hsm;
wire  [7:0]        o;
wire signed [23:0] aud_l;
wire signed [23:0] aud_r;

wire [20:0]        a_r;
wire  [7:0]        dout_r;
wire               rd_n_r;
wire               wr_n_r;
wire               ce_r;
wire signed [23:0] aud_l_r;

reg  [7:0] mem [0:2097151];
reg  [7:0] mem_r [0:2097151];
wire [7:0] di   = mem[a];
wire [7:0] di_r = mem_r[a_r];

x6280 uut (
    .clk       ( clk    ),
    .rst_n     ( rst_n  ),
    .cen       ( cen    ),
    .rdy       ( rdy    ),
    .a         ( a      ),
    .di        ( di     ),
    .dout      ( dout   ),
    .rd_n      ( rd_n   ),
    .wr_n      ( wr_n   ),
    .sync      ( sync   ),
    .vp_n      ( vp_n   ),
    .nmi_n     ( nmi_n  ),
    .irq1_n    ( irq1_n ),
    .irq2_n    ( irq2_n ),
    .ce        ( ce     ),
    .cek_n     ( cek_n  ),
    .ce7_n     ( ce7_n  ),
    .cer_n     ( cer_n  ),
    .pre_rd    (        ),
    .pre_wr    (        ),
    .hsm       ( hsm    ),
    .k         ( k      ),
    .o         ( o      ),
    .aud_ldata ( aud_l  ),
    .aud_rdata ( aud_r  )
);

x6280 #(
    .INT_RD ( 1 ),
    .PSG    ( 0 )
) uutr (
    .clk       ( clk     ),
    .rst_n     ( rst_n   ),
    .cen       ( cen     ),
    .rdy       ( rdy     ),
    .a         ( a_r     ),
    .di        ( di_r    ),
    .dout      ( dout_r  ),
    .rd_n      ( rd_n_r  ),
    .wr_n      ( wr_n_r  ),
    .sync      (         ),
    .vp_n      (         ),
    .nmi_n     ( nmi_n   ),
    .irq1_n    ( irq1_n  ),
    .irq2_n    ( irq2_n  ),
    .ce        ( ce_r    ),
    .cek_n     (         ),
    .ce7_n     (         ),
    .cer_n     (         ),
    .pre_rd    (         ),
    .pre_wr    (         ),
    .hsm       (         ),
    .k         ( k       ),
    .o         (         ),
    .aud_ldata ( aud_l_r ),
    .aud_rdata (         )
);

// external writes at the enable that ends the cycle
integer wr_ext;
always @(posedge clk) begin
    if(ce && !wr_n) begin
        mem[a] <= dout;
        wr_ext <= wr_ext + 1;
    end
    if(ce_r && !wr_n_r)
        mem_r[a_r] <= dout_r;
end

//=========================================================================
// Cycle Recorder:
// One entry per CPU cycle at the enable that ends it (ce):
//   [20:0] a  [21] rd_n  [22] wr_n  [23] sync  [24] intc  [25] ce7_n
//   [26] cek_n  [27] cer_n  [28] rd_n of uutr  [31:29] 0  [39:32] data
//   [47:40] enables in the cycle  [48] hsm
//=========================================================================
localparam TRN = 65536;
reg  [48:0] trb [0:TRN-1];
integer     tr_n;
integer     en_cnt;
wire  [7:0] en_rec = en_cnt + 1;

always @(posedge clk) begin
    if(cen) begin
        if(ce) begin
            trb[tr_n % TRN] <= {hsm, en_rec, (!wr_n) ? dout : di, 3'b000, rd_n_r, cer_n, cek_n, ce7_n,
                                uut.cpu_intc, sync, wr_n, rd_n, a};
            tr_n <= tr_n + 1;
            en_cnt <= 0;
        end else
            en_cnt <= en_cnt + 1;
    end
end

function [20:0] t_a;   input integer i; begin t_a   = trb[i % TRN][20:0];  end endfunction
function        t_rd;  input integer i; begin t_rd  = trb[i % TRN][21];    end endfunction
function        t_wr;  input integer i; begin t_wr  = trb[i % TRN][22];    end endfunction
function        t_sy;  input integer i; begin t_sy  = trb[i % TRN][23];    end endfunction
function        t_ic;  input integer i; begin t_ic  = trb[i % TRN][24];    end endfunction
function        t_ce7; input integer i; begin t_ce7 = trb[i % TRN][25];    end endfunction
function        t_cek; input integer i; begin t_cek = trb[i % TRN][26];    end endfunction
function        t_cer; input integer i; begin t_cer = trb[i % TRN][27];    end endfunction
function        t_rdr; input integer i; begin t_rdr = trb[i % TRN][28];    end endfunction
function  [7:0] t_d;   input integer i; begin t_d   = trb[i % TRN][39:32]; end endfunction
function  [7:0] t_en;  input integer i; begin t_en  = trb[i % TRN][47:40]; end endfunction
function        t_hsm; input integer i; begin t_hsm = trb[i % TRN][48];    end endfunction

//=========================================================================
// Reporting and Program Helpers
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
    input [31:0]      got;
    input [31:0]      exp;
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

integer pc_put;

task put;
    input [7:0] d;
    begin
        mem[{8'h00, pc_put[12:0]}] = d;
        mem_r[{8'h00, pc_put[12:0]}] = d;
        pc_put = pc_put + 1;
    end
endtask

task org;
    input [15:0] la;
    begin
        pc_put = la;
    end
endtask

task clear_mem;
    integer i;
    begin
        for(i = 0; i < 2097152; i = i + 1) begin
            mem[i] = 8'h00;
            mem_r[i] = 8'h00;
        end
    end
endtask

// MPR0 = FF (I/O), MPR1 = F8 (RAM), MPR2 = 01, MPR7 = 00; S = FF
task std_map;
    begin
        put(8'hA9); put(8'hFF); put(8'h53); put(8'h01);
        put(8'hA9); put(8'hF8); put(8'h53); put(8'h02);
        put(8'hA9); put(8'h01); put(8'h53); put(8'h04);
        put(8'hA2); put(8'hFF); put(8'h9A);
    end
endtask

task vectors;
    begin
        mem[21'h001FFE] = 8'h00; mem[21'h001FFF] = 8'hE0;  // RESET
        mem[21'h001FF6] = 8'h00; mem[21'h001FF7] = 8'hE8;  // IRQ2 / BRK
        mem[21'h001FF8] = 8'h10; mem[21'h001FF9] = 8'hE8;  // IRQ1
        mem[21'h001FFA] = 8'h20; mem[21'h001FFB] = 8'hE8;  // timer
        mem[21'h001FFC] = 8'h30; mem[21'h001FFD] = 8'hE8;  // NMI
        mem_r[21'h001FFE] = 8'h00; mem_r[21'h001FFF] = 8'hE0;
    end
endtask

task boot;
    begin
        rst_n = 1'b0;
        repeat(8) @(posedge clk);
        rst_n = 1'b1;
    end
endtask

task run_to;
    input [15:0] la;
    input integer limit;
    output  ok;
    integer i;
    begin
        ok = 1'b0;
        i = 0;
        while(!ok && i < limit) begin
            @(posedge clk);
            if(cen) begin
                i = i + 1;
                #1;
                if(sync && a == {8'h00, la[12:0]} && en_cnt == 0)
                    ok = 1'b1;
            end
        end
    end
endtask

function integer find_a;
    input integer i0;
    input [20:0] ad;
    integer      i;
    begin
        find_a = -1;
        for(i = i0; i < tr_n && find_a < 0; i = i + 1)
            if(t_a(i) == ad && !t_ic(i))
                find_a = i;
    end
endfunction

//=========================================================================
// Section 1: External Strobes and Chip Enables
//=========================================================================
task sec1;
    reg     ok;
    integer i0;
    integer i;
    integer mark;
    integer bad;
    integer badr;
    integer nic;
    begin
        $display("");
        $display("=============================================================");
        $display(" Section 1: External Strobes and Chip Enables");
        $display("=============================================================");
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hD4);                                   // CSH
        put(8'hAD); put(8'h00); put(8'h00);           // LDA 0000 (1FE000 VDC)
        put(8'hA9); put(8'h5C);
        put(8'h8D); put(8'h02); put(8'h00);           // STA 0002 (1FE002 VDC)
        put(8'hAD); put(8'h04); put(8'h04);           // LDA 0404 (1FE404 VCE)
        put(8'h8D); put(8'h02); put(8'h04);           // STA 0402 (1FE402 VCE)
        put(8'h8D); put(8'h00); put(8'h08);           // STA 0800 (1FE800 PSG)
        put(8'hAD); put(8'h00); put(8'h0C);           // LDA 0C00 (timer)
        put(8'hAD); put(8'h00); put(8'h10);           // LDA 1000 (port K)
        put(8'hAD); put(8'h02); put(8'h14);           // LDA 1402 (interrupt disable)
        put(8'hAD); put(8'h00); put(8'h20);           // LDA 2000 (1F0000 RAM)
        put(8'h8D); put(8'h01); put(8'h20);           // STA 2001
        put(8'hAD); put(8'h00); put(8'h40);           // LDA 4000 (002000)
        mark = pc_put;
        put(8'h80); put(8'hFE);
        boot;
        run_to(16'hE00F, 4000, ok);
        i0 = tr_n;
        run_to(mark, 4000, ok);
        check("program runs to the end", ok);

        i = find_a(i0, 21'h1FE000);
        check("read 1FE000: rd_n low, ce7_n low, cek_n high, 2 enables (CE wait)",
              i >= 0 && !t_rd(i) && t_wr(i) && !t_ce7(i) && t_cek(i) && t_en(i) == 8'd2);
        i = find_a(i0, 21'h1FE002);
        check("write 1FE002: wr_n low, ce7_n low, data in the external memory",
              i >= 0 && !t_wr(i) && t_rd(i) && !t_ce7(i) && mem[21'h1FE002] == 8'h5C);
        i = find_a(i0, 21'h1FE404);
        check("read 1FE404: rd_n low, cek_n low, ce7_n high", i >= 0 && !t_rd(i) && !t_cek(i) && t_ce7(i));
        i = find_a(i0, 21'h1FE402);
        check("write 1FE402: wr_n low, cek_n low", i >= 0 && !t_wr(i) && !t_cek(i));
        i = find_a(i0, 21'h1FE800);
        check("write 1FE800 (PSG): no external strobe", i >= 0 && t_wr(i) && t_rd(i) && mem[21'h1FE800] == 8'h00);
        i = find_a(i0, 21'h1FEC00);
        check("read 1FEC00 (timer): no external strobe", i >= 0 && t_rd(i));
        i = find_a(i0, 21'h1FF000);
        check("read 1FF000 (port K): no external strobe", i >= 0 && t_rd(i));
        i = find_a(i0, 21'h1FF402);
        check("read 1FF402 (interrupt registers): no external strobe", i >= 0 && t_rd(i));
        i = find_a(i0, 21'h1F0000);
        check("read 1F0000: rd_n low, cer_n low", i >= 0 && !t_rd(i) && !t_cer(i));
        i = find_a(i0, 21'h1F0001);
        check("write 1F0001: wr_n low, cer_n low", i >= 0 && !t_wr(i) && !t_cer(i));
        i = find_a(i0, 21'h002000);
        check("read 002000: rd_n low, no chip enable", i >= 0 && !t_rd(i) && t_cer(i) && t_ce7(i) && t_cek(i));

        bad = 0;
        badr = 0;
        nic = 0;
        for(i = i0; i < tr_n; i = i + 1)
            if(t_ic(i)) begin
                nic = nic + 1;
                if(!t_rd(i) || !t_wr(i))
                    bad = bad + 1;
                if(t_rdr(i))
                    badr = badr + 1;
            end
        $sformat(nm, "internal cycles (%0d): rd_n and wr_n high (INT_RD = 0)", nic);
        check(nm, nic > 8 && bad == 0);
        check_eq("internal cycles with rd_n high in uutr (INT_RD = 1)", badr, 0);
    end
endtask

//=========================================================================
// Section 2: Interrupt Controller
//=========================================================================
task sec2;
    reg     ok;
    integer mark;
    begin
        $display("");
        $display("=============================================================");
        $display(" Section 2: Interrupt Controller");
        $display("=============================================================");
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hD4);                                   // CSH
        put(8'hA9); put(8'h05); put(8'h8D); put(8'h02); put(8'h14);   // IDR = 05
        put(8'hAD); put(8'h02); put(8'h14); put(8'h85); put(8'h80);   // 2080 = IDR
        put(8'hAD); put(8'h03); put(8'h14); put(8'h85); put(8'h81);   // 2081 = IRR (IRQ1 low)
        put(8'hA9); put(8'h02); put(8'h8D); put(8'h02); put(8'h14);   // IDR = 02 (IRQ1 off)
        put(8'h58);                                   // CLI
        put(8'hEA); put(8'hEA); put(8'hEA); put(8'hEA);
        put(8'hA5); put(8'h90); put(8'h85); put(8'h82);   // 2082 = 2090 (handler marker: 00 if none)
        put(8'hA9); put(8'h00); put(8'h8D); put(8'h02); put(8'h14);   // IDR = 00
        put(8'hEA); put(8'hEA); put(8'hEA);
        put(8'hA5); put(8'h90); put(8'h85); put(8'h83);   // 2083 = 2090
        mark = pc_put;
        put(8'h80); put(8'hFE);
        org(16'hE810);                                // IRQ1: marker 11, mask IRQ1, RTI
        put(8'hA9); put(8'h11); put(8'h85); put(8'h90);
        put(8'hA9); put(8'h02); put(8'h8D); put(8'h02); put(8'h14);
        put(8'h40);
        org(16'hE800);                                // IRQ2: marker 22, mask IRQ2, RTI
        put(8'hA9); put(8'h22); put(8'h85); put(8'h90);
        put(8'hA9); put(8'h03); put(8'h8D); put(8'h02); put(8'h14);
        put(8'h40);
        irq1_n = 1'b0;
        irq2_n = 1'b1;
        boot;
        run_to(mark, 6000, ok);
        check("program runs to the end", ok);
        check_eq("interrupt disable register read back (low 3 bits)", mem[21'h1F0080] & 8'h07, 8'h05);
        check_eq("request register: IRQ1 pin low -> bit 1", mem[21'h1F0081] & 8'h07, 8'h02);
        check_eq("IRQ1 disabled by IDR bit 1: no entry", mem[21'h1F0082], 8'h00);
        check_eq("IRQ1 enabled: entry through FFF8", mem[21'h1F0083], 8'h11);

        // IRQ1 before IRQ2
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hD4);
        put(8'hA9); put(8'h00); put(8'h8D); put(8'h02); put(8'h14);   // IDR = 00
        put(8'h58);
        put(8'hEA); put(8'hEA); put(8'hEA); put(8'hEA); put(8'hEA); put(8'hEA);
        mark = pc_put;
        put(8'h80); put(8'hFE);
        org(16'hE810);                                // IRQ1: append 11 to the log at 2091, X
        put(8'hA9); put(8'h11); put(8'h85); put(8'h91);
        put(8'hA9); put(8'h02); put(8'h8D); put(8'h02); put(8'h14);   // mask IRQ1
        put(8'h40);
        org(16'hE800);                                // IRQ2: 2092 = 22 only after IRQ1
        put(8'hA5); put(8'h91); put(8'h85); put(8'h92);
        put(8'hA9); put(8'h03); put(8'h8D); put(8'h02); put(8'h14);
        put(8'h40);
        irq1_n = 1'b0;
        irq2_n = 1'b0;
        boot;
        run_to(mark, 6000, ok);
        check_eq("IRQ1 and IRQ2 low: IRQ1 first, then IRQ2", {mem[21'h1F0091], mem[21'h1F0092]}, 16'h1111);
        irq1_n = 1'b1;
        irq2_n = 1'b1;
    end
endtask

//=========================================================================
// Section 3: Timer
//=========================================================================
task sec3;
    reg     ok;
    integer mark;
    integer c0;
    integer c1;
    integer c2;
    integer cc;
    integer mstart;
    reg     pv;
    begin
        $display("");
        $display("=============================================================");
        $display(" Section 3: Timer");
        $display("=============================================================");
        check_eq("timer stopped and TIQ clear after reset", {uut.u_timer.tmr_en, uut.u_timer.tmr_irq}, 2'b00);
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hA9); put(8'h00); put(8'h8D); put(8'h02); put(8'h14);   // IDR = 00
        put(8'hA9); put(8'h02); put(8'h8D); put(8'h00); put(8'h0C);   // reload = 02
        put(8'hA9); put(8'h01);
        mstart = pc_put;
        put(8'h8D); put(8'h01); put(8'h0C);           // start
        put(8'h58);
        mark = pc_put;
        put(8'h80); put(8'hFE);
        org(16'hE820);                                // timer: count entries in 2093, ack, RTI
        put(8'hE6); put(8'h93);
        put(8'h8D); put(8'h03); put(8'h14);           // write IRR: TIQ acknowledge
        put(8'h40);
        boot;
        run_to(mstart, 6000, ok);
        cc = 0;
        c0 = -1;
        c1 = -1;
        c2 = -1;
        pv = 1'b0;
        while(cc < 20000 && c2 < 0) begin
            @(posedge clk);
            if(cen) begin
                cc = cc + 1;
                if(c0 < 0 && uut.u_timer.tmr_en)
                    c0 = cc;
                if(c1 < 0 && c0 >= 0 && uut.u_timer.tmr_irq)
                    c1 = cc;
                else if(c1 >= 0 && c2 < 0 && !pv && uut.u_timer.tmr_irq)
                    c2 = cc;
                pv = uut.u_timer.tmr_irq;
            end
        end
        check_eq("first borrow (TIQ) after start: (reload + 1) x 1024 enables", c1 - c0, 3 * 1024);
        check_eq("next borrow after the reload", c2 - c1, 3 * 1024);
        repeat(800) @(posedge clk);
        check_eq("timer interrupt entries through FFFA, acknowledged by an IRR write", mem[21'h1F0093], 8'h02);

        // stop resets the prescaler; low speed does not change the timer
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'h54);                                   // CSL
        put(8'hA9); put(8'h00); put(8'h8D); put(8'h01); put(8'h0C);   // stop
        put(8'hA9); put(8'h01); put(8'h8D); put(8'h00); put(8'h0C);   // reload = 01
        put(8'hA9); put(8'h01);
        mstart = pc_put;
        put(8'h8D); put(8'h01); put(8'h0C);           // start
        mark = pc_put;
        put(8'h80); put(8'hFE);
        boot;
        run_to(mstart, 6000, ok);
        cc = 0;
        c0 = -1;
        c1 = -1;
        while(cc < 20000 && c1 < 0) begin
            @(posedge clk);
            if(cen) begin
                cc = cc + 1;
                if(c0 < 0 && uut.u_timer.tmr_en)
                    c0 = cc;
                if(c1 < 0 && c0 >= 0 && uut.u_timer.tmr_irq)
                    c1 = cc;
            end
        end
        check_eq("low speed: borrow after (1 + 1) x 1024 enables", c1 - c0, 2 * 1024);
    end
endtask

//=========================================================================
// Section 4: I/O Ports
//=========================================================================
task sec4;
    reg     ok;
    integer mark;
    begin
        $display("");
        $display("=============================================================");
        $display(" Section 4: I/O Ports");
        $display("=============================================================");
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        mark = pc_put + 8;
        put(8'hD4);
        put(8'hAD); put(8'h00); put(8'h10); put(8'h85); put(8'h84);   // 2084 = K
        put(8'h80); put(8'hFE);
        boot;
        @(posedge clk);
        #1;
        check_eq("port O after reset", o, 8'hFF);
        run_to(mark - 2, 4000, ok);
        check_eq("port K read at 1FF000", mem[21'h1F0084], 8'h5A);
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hA9); put(8'h3C); put(8'h8D); put(8'h00); put(8'h10);   // O = 3C
        mark = pc_put;
        put(8'h80); put(8'hFE);
        boot;
        run_to(mark, 4000, ok);
        check_eq("port O written at 1FF000", o, 8'h3C);
    end
endtask

//=========================================================================
// Section 5: PSG
//=========================================================================
// upsg: a second PSG written straight through its register port, for the
// waveform stepping and LFO tests [p.PB-6]-[p.PB-9]
reg                p_rst_n;
reg                p_we;
reg          [3:0] p_a;
reg          [7:0] p_di;
wire signed [23:0] p_l;

x6280_psg upsg (
    .clk       ( clk     ),
    .rst_n     ( p_rst_n ),
    .clken     ( cen     ),
    .we        ( p_we    ),
    .a         ( p_a     ),
    .di        ( p_di    ),
    .dac_latch ( 1'b1    ),
    .ldata     ( p_l     ),
    .rdata     (         )
);

// one register write
task pw;
    input [3:0] ra;
    input [7:0] d;
    begin
        @(posedge clk);
        #1;
        p_we = 1'b1;
        p_a = ra;
        p_di = d;
        @(posedge clk);
        #1;
        p_we = 1'b0;
    end
endtask

// fill a channel's waveform RAM from address 0: kind 0 = ramp 00-1F,
// 1 = every word v, 2 = $18 in words 0-15 and $08 in words 16-31
task pload;
    input [2:0] ch;
    input [1:0] kind;
    input [4:0] v;
    integer     w;
    begin
        pw(4'h0, {5'd0, ch});
        pw(4'h4, 8'h40);
        pw(4'h4, 8'h00);
        for(w = 0; w < 32; w = w + 1)
            pw(4'h6, (kind == 2'd0) ? w : (kind == 2'd1) ? {3'd0, v} : (w < 16) ? 8'h18 : 8'h08);
    end
endtask

// channel on in waveform output mode at frequency f, full level
task ptone;
    input  [2:0] ch;
    input [11:0] f;
    begin
        pw(4'h0, {5'd0, ch});
        pw(4'h2, f[7:0]);
        pw(4'h3, {4'h0, f[11:8]});
        pw(4'h5, 8'hFF);
        pw(4'h4, 8'h9F);
    end
endtask

// enables between waveform address steps of a channel: the first step
// syncs, then n intervals are measured
task pstep;
    input   [2:0] ch;
    input integer n;
    output integer lo;
    output integer hi;
    integer        c;
    integer        t;
    integer        j;
    reg      [4:0] last;
    begin
        lo = 32'h7FFFFFFF;
        hi = 0;
        for(j = 0; j <= n; j = j + 1) begin
            last = upsg.ch_wf_addr[ch];
            c = 0;
            t = 0;
            while(upsg.ch_wf_addr[ch] == last && t < 4000000) begin
                @(posedge clk);
                if(cen)
                    c = c + 1;
                t = t + 1;
                #1;
            end
            if(j > 0) begin
                if(c < lo)
                    lo = c;
                if(c > hi)
                    hi = c;
            end
        end
    end
endtask

// channel 1 holds every word v; channel 0 steps at 2 x (F + ((v - $10) << s))
task pmod;
    input   [4:0] v;
    input   [1:0] ctl;
    input integer exp;
    integer       lo;
    integer       hi;
    begin
        pload(3'd1, 2'd1, v);
        ptone(3'd1, 12'h001);
        pw(4'h9, {6'd0, ctl});
        pstep(3'd0, 3, lo, hi);
        $sformat(nm, "LF CTL %0d, channel 1 data %h: channel 0 steps every %0d enables", ctl, v, exp);
        check(nm, lo == exp && hi == exp);
    end
endtask

task psg_level;
    input          [7:0] al;
    input          [7:0] dda;
    output signed [23:0] lvl;
    reg                  ok;
    integer              mark;
    begin
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hD4);
        put(8'hA9); put(8'h00); put(8'h8D); put(8'h00); put(8'h08);   // R0 = ch0
        put(8'hA9); put(8'hFF); put(8'h8D); put(8'h01); put(8'h08);   // R1 = FF
        put(8'hA9); put(8'hFF); put(8'h8D); put(8'h05); put(8'h08);   // R5 = FF
        put(8'hA9); put(8'hC0 | al); put(8'h8D); put(8'h04); put(8'h08);   // R4 = on, DDA, AL
        put(8'hA9); put(dda); put(8'h8D); put(8'h06); put(8'h08);     // R6 = DDA data
        mark = pc_put;
        put(8'h80); put(8'hFE);
        boot;
        run_to(mark, 6000, ok);
        repeat(400) @(posedge clk);
        lvl = aud_l;
    end
endtask

task sec5;
    reg signed [23:0] l1;
    reg signed [23:0] l2;
    reg signed [23:0] l3;
    reg               ok;
    integer           mark;
    integer           lo;
    integer           hi;
    integer           j;
    integer           t;
    reg         [4:0] a1;
    reg               all_ok;
    reg               seen_hi;
    reg               seen_lo;
    reg         [5:0] on_mask;
    begin
        $display("");
        $display("=============================================================");
        $display(" Section 5: PSG");
        $display("=============================================================");
        psg_level(8'h1F, 8'h1F, l1);
        check("DDA 1F at full level: output above zero", l1 > 0);
        check_eq("PSG = 0 instance: output", aud_l_r, 24'd0);
        psg_level(8'h02, 8'h1F, l2);
        check("attenuation index 29 (AL = 02, LMAL = LAL = F): output above zero", l2 > 0);
        psg_level(8'h01, 8'h1F, l3);
        check_eq("attenuation index 30 (45 dB): silent", l3, 24'd0);

        // PSG read: the registers are write-only; the read returns the I/O buffer
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hD4);
        put(8'hA9); put(8'h5A); put(8'h8D); put(8'h02); put(8'h08);   // STA $0802: I/O buffer = 5A
        put(8'hA9); put(8'h00);                                       // A = 00
        put(8'hAD); put(8'h00); put(8'h08);                           // LDA $0800 (PSG)
        put(8'h8D); put(8'h00); put(8'h40);                           // STA $4000
        mark = pc_put;
        put(8'h80); put(8'hFE);
        boot;
        run_to(mark, 6000, ok);
        check_eq("PSG read returns the I/O buffer (5A)", mem[21'h002000], 8'h5A);

        // waveform stepping and the LFO, on upsg
        p_rst_n = 1'b0;
        repeat(4) @(posedge clk);
        #1;
        p_rst_n = 1'b1;
        check("reset: every waveform address 0",
              upsg.ch_wf_addr[0] == 5'd0 && upsg.ch_wf_addr[1] == 5'd0 && upsg.ch_wf_addr[2] == 5'd0 &&
              upsg.ch_wf_addr[3] == 5'd0 && upsg.ch_wf_addr[4] == 5'd0 && upsg.ch_wf_addr[5] == 5'd0);
        check("volume curve entries 5, 6, 9, 12, 14, 15 = round(2048 x 10^(-1.5 i / 20))",
              upsg.vol_lut[5] == 12'd864 && upsg.vol_lut[6] == 12'd727 && upsg.vol_lut[9] == 12'd433 &&
              upsg.vol_lut[12] == 12'd258 && upsg.vol_lut[14] == 12'd183 && upsg.vol_lut[15] == 12'd154);
        pw(4'h1, 8'hFF);
        pload(3'd2, 2'd0, 5'd0);
        ptone(3'd2, 12'h011);
        pstep(3'd2, 4, lo, hi);
        check("LFO off: channel 2 steps every 2 x F = 34 enables", lo == 34 && hi == 34);

        // LFO rate: channel 1 steps every 2 x F x FLF enables
        pload(3'd0, 2'd0, 5'd0);
        ptone(3'd0, 12'h200);
        pload(3'd1, 2'd0, 5'd0);
        ptone(3'd1, 12'h003);
        pw(4'h8, 8'h05);
        pw(4'h9, 8'h01);
        pstep(3'd1, 3, lo, hi);
        check("LFO on: channel 1 steps every 2 x F x FLF = 30 enables", lo == 30 && hi == 30);
        pstep(3'd2, 3, lo, hi);
        check("LFO on: channel 2 still steps every 34 enables", lo == 34 && hi == 34);
        pw(4'h8, 8'h00);
        pstep(3'd1, 2, lo, hi);
        check("LFO frequency 0 counts 256: channel 1 steps every 1536 enables", lo == 1536 && hi == 1536);

        // modulation depth: channel 0 at F = $200
        pw(4'h8, 8'h03);
        pmod(5'h00, 2'd1, 992);
        pmod(5'h00, 2'd2, 896);
        pmod(5'h00, 2'd3, 512);
        pmod(5'h1F, 2'd3, 1504);
        pmod(5'h10, 2'd3, 1024);

        // channel 0 follows channel 1's waveform: +8 in words 0-15, -8 in 16-31
        pload(3'd1, 2'd2, 5'd0);
        ptone(3'd1, 12'h004);
        pw(4'h8, 8'h10);
        ptone(3'd0, 12'h100);
        pw(4'h9, 8'h01);
        all_ok = 1'b1;
        seen_hi = 1'b0;
        seen_lo = 1'b0;
        for(j = 0; j < 30; j = j + 1) begin
            pstep(3'd0, 1, lo, hi);
            if(lo == 528)
                seen_hi = 1'b1;
            else if(lo == 496)
                seen_lo = 1'b1;
            else
                all_ok = 1'b0;
        end
        check("channel 0 follows channel 1's waveform: periods 528 and 496 only, both seen",
              all_ok && seen_hi && seen_lo);

        // LF TRG: channel 1 to address 0 and held; channel 0 modulated by word 0
        pload(3'd1, 2'd0, 5'd0);
        ptone(3'd1, 12'h002);
        pw(4'h8, 8'h03);
        pw(4'h9, 8'h01);
        t = 0;
        while(upsg.ch_wf_addr[1] < 5'd5 && t < 100000) begin
            @(posedge clk);
            #1;
            t = t + 1;
        end
        pw(4'h9, 8'h81);
        repeat(4) @(posedge clk);
        #1;
        a1 = upsg.ch_wf_addr[1];
        repeat(2000) @(posedge clk);
        #1;
        check("LF TRG: channel 1 returns to address 0 and holds there", a1 == 5'd0 && upsg.ch_wf_addr[1] == 5'd0);
        pstep(3'd0, 2, lo, hi);
        check("LF TRG: channel 0 modulated by channel 1 word 0 (-16): 480 enables", lo == 480 && hi == 480);
        pw(4'h9, 8'h01);
        pstep(3'd1, 3, lo, hi);
        check("LF TRG cleared: channel 1 steps every 12 enables again", lo == 12 && hi == 12);

        // channel 1 off: channel 0 unmodulated, channel 1 does not run
        pw(4'h0, 8'h01);
        pw(4'h4, 8'h1F);
        pstep(3'd0, 2, lo, hi);
        check("channel 1 off: channel 0 unmodulated, 2 x F = 512 enables", lo == 512 && hi == 512);
        a1 = upsg.ch_wf_addr[1];
        repeat(2000) @(posedge clk);
        #1;
        check("channel 1 off: its waveform address does not run", upsg.ch_wf_addr[1] == a1);

        // DDA holds the waveform address at 0
        pload(3'd3, 2'd0, 5'd0);
        ptone(3'd3, 12'h011);
        pstep(3'd3, 1, lo, hi);
        pw(4'h0, 8'h03);
        pw(4'h4, 8'hDF);
        repeat(200) @(posedge clk);
        #1;
        check("DDA set: waveform address 0 and held", upsg.ch_wf_addr[3] == 5'd0);

        // noise takes priority over DDA on channel 4
        pw(4'h0, 8'h04);
        pw(4'h4, 8'hDF);
        pw(4'h6, 8'h07);
        pw(4'h7, 8'h9F);
        repeat(200) @(posedge clk);
        #1;
        check("channel 4 with NE and DDA set: noise output, not the DDA latch",
              upsg.ch_gl_out[4] == 5'h00 || upsg.ch_gl_out[4] == 5'h1F);

        // channel 1 stays audible while it runs the LFO
        for(j = 0; j < 6; j = j + 1) begin
            pw(4'h0, j);
            pw(4'h7, 8'h00);
            pw(4'h4, 8'h00);
        end
        pload(3'd1, 2'd1, 5'h1F);
        ptone(3'd1, 12'h004);
        pw(4'h9, 8'h01);
        repeat(200) @(posedge clk);
        #1;
        check_eq("channel 1 audible while it runs the LFO: data 1F at full scale", p_l, 24'h007800);

        // LFO off: channel 1 back to 2 x F
        pw(4'h9, 8'h00);
        pstep(3'd1, 2, lo, hi);
        check("LFO off: channel 1 steps every 2 x F = 8 enables", lo == 8 && hi == 8);

        // R0 = 6 or 7 selects no channel
        on_mask = {upsg.ch_chon[5], upsg.ch_chon[4], upsg.ch_chon[3], upsg.ch_chon[2], upsg.ch_chon[1], upsg.ch_chon[0]};
        pw(4'h0, 8'h06);
        pw(4'h4, 8'h9F);
        pw(4'h0, 8'h07);
        pw(4'h4, 8'h9F);
        check("R0 = 6 or 7: R4 writes reach no channel",
              {upsg.ch_chon[5], upsg.ch_chon[4], upsg.ch_chon[3], upsg.ch_chon[2], upsg.ch_chon[1], upsg.ch_chon[0]} == on_mask);
    end
endtask

//=========================================================================
// Section 6: CSL / CSH Enable
//=========================================================================
task sec6;
    reg     ok;
    integer mark;
    integer i;
    integer i0;
    integer k;
    integer lo4;
    integer hi1;
    begin
        $display("");
        $display("=============================================================");
        $display(" Section 6: CSL / CSH Enable");
        $display("=============================================================");
        clear_mem;
        vectors;
        org(16'hE000);
        put(8'hEA); put(8'hEA);                       // E000 low speed
        put(8'hD4);                                   // CSH (E002)
        put(8'hEA); put(8'hEA);                       // E003 high speed
        put(8'h54);                                   // CSL (E005)
        put(8'hEA);                                   // E006 low speed
        mark = pc_put;
        put(8'h80); put(8'hFE);
        boot;
        i0 = tr_n;
        run_to(mark, 400, ok);
        lo4 = 1;
        hi1 = 1;
        for(i = i0; i < tr_n; i = i + 1) begin
            if(t_a(i) == 21'h000000 && t_sy(i) && (t_en(i) != 8'd4 || t_hsm(i))) lo4 = 0;
            if(t_a(i) == 21'h000003 && t_sy(i) && (t_en(i) != 8'd1 || !t_hsm(i))) hi1 = 0;
        end
        check("after reset: 4 enables per cycle, hsm low", lo4);
        check("after CSH: 1 enable per cycle, hsm high", hi1);
        i = i0;
        while(i < tr_n && !(t_a(i) == 21'h000006 && t_sy(i))) i = i + 1;
        check("after CSL: 4 enables per cycle, hsm low", i < tr_n && t_en(i) == 8'd4 && !t_hsm(i));

        // CSL after 0-3 NOPs at high speed: its third cycle and the cycles after it last 4 enables
        for(k = 0; k < 4; k = k + 1) begin
            clear_mem;
            vectors;
            org(16'hE000);
            put(8'hD4);                               // CSH (E000)
            for(i = 0; i < k; i = i + 1)
                put(8'hEA);                           // NOP
            put(8'h54);                               // CSL
            put(8'hEA);                               // NOP
            mark = pc_put;
            put(8'h80); put(8'hFE);
            boot;
            run_to(16'hE000, 400, ok);
            i0 = tr_n;
            run_to(mark, 400, ok);
            i = i0;
            while(i < tr_n && !(t_a(i) == 21'h000001 + k && t_sy(i))) i = i + 1;
            $sformat(nm, "CSL after %0d NOPs: cycles 1-2 one enable, cycle 3 and the NOP after it 4 enables each", k);
            check(nm, ok && i + 4 < tr_n && t_en(i) == 8'd1 && t_en(i + 1) == 8'd1 && t_en(i + 2) == 8'd4 &&
                  t_en(i + 3) == 8'd4 && t_en(i + 4) == 8'd4);
        end
    end
endtask

//=========================================================================
// Section 7: RDY and the CE7 / CEK Wait
//=========================================================================
task sec7;
    reg     ok;
    integer mark;
    integer i;
    integer i0;
    integer w0;
    begin
        $display("");
        $display("=============================================================");
        $display(" Section 7: RDY and the CE7 / CEK Wait");
        $display("=============================================================");
        clear_mem;
        vectors;
        org(16'hE000);
        std_map;
        put(8'hD4);                                   // CSH (E00F)
        put(8'hA9); put(8'h77);                       // E010
        put(8'h8D); put(8'h00); put(8'h40);           // STA 4000 (E012)
        put(8'hAD); put(8'h00); put(8'h00);           // LDA 0000 (E015)
        mark = pc_put;
        put(8'h80); put(8'hFE);
        boot;
        run_to(16'hE012, 4000, ok);
        i0 = tr_n;
        w0 = wr_ext;
        repeat(4) begin
            @(posedge clk);
            while(!cen) @(posedge clk);
        end
        #1;
        rdy = 1'b0;
        repeat(6) begin
            @(posedge clk);
            while(!cen) @(posedge clk);
        end
        #1;
        rdy = 1'b1;
        run_to(mark, 400, ok);
        i = find_a(i0, 21'h002000);
        check("write held by RDY: one cycle of several enables, one external write",
              i >= 0 && t_en(i) > 8'd1 && !t_wr(i) && (wr_ext - w0 == 1) && mem[21'h002000] == 8'h77);
        i = find_a(i0, 21'h1FE000);
        check_eq("read of 1FE000 at high speed: enables", t_en(i), 8'd2);
    end
endtask

//=========================================================================
// Main Sequence
//=========================================================================
initial begin
    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;
    en_ph = 1'b0;
    cen = 1'b0;
    rst_n = 1'b0;
    rdy = 1'b1;
    nmi_n = 1'b1;
    irq1_n = 1'b1;
    irq2_n = 1'b1;
    k = 8'h5A;
    p_rst_n = 1'b0;
    p_we = 1'b0;
    p_a = 4'h0;
    p_di = 8'h00;
    wr_ext = 0;
    tr_n = 0;
    en_cnt = 0;

    $display("=============================================================");
    $display("  x6280 Chip-Level Testbench");
    $display("=============================================================");

    sec1;
    sec2;
    sec3;
    sec4;
    sec5;
    sec6;
    sec7;

    $display("");
    $display("=============================================================");
    $display("  x6280 Chip Test Results");
    $display("=============================================================");
    $display("  Total Tests:  %0d", total_tests);
    $display("  Passed:       %0d", passed_tests);
    $display("  Failed:       %0d", failed_tests);
    $display("=============================================================");
    if(failed_tests == 0) begin
        $display("  *** ALL TESTS PASSED ***");
    end else begin
        $display("  *** SOME TESTS FAILED ***");
    end
    $display("=============================================================");
    $finish;
end

endmodule
