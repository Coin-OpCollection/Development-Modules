/*
* <-- Coin-Op Collection -->
* https://coinopcollection.org
* https://github.com/Coin-OpCollection/
*
* Author: atrac17 (https://twitter.com/_atrac17)
* Copyright (c) 2026 Coin-Op Collection
*
* This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/.
*
* You may use, share, and modify this code for non-commercial purposes, provided that proper credit is given.
*/

//============================================================================
//  x68705 Cycle Table Testbench
//
//  Runs each of the 207 defined opcodes from $100 after a reset and counts
//  the machine cycles from its decode to the next decode, then the /INT
//  entry from the decode that takes it to the first decode of the handler.
//  The counts are checked against the User's Manual opcode map: the HMOS
//  column with HMOS = 1, the CMOS column with HMOS = 0. The interrupt entry
//  is 11 or 10 cycles (Appendix G, Tables G2 and G1).
//
//  Reference: M6805/M146805 CMOS Family User's Manual, Second Edition,
//             opcode map and Appendix G.
//============================================================================

`timescale 1ns / 1ps

module tb_x68705_cycles;

parameter HMOS = 1;

reg clk = 1'b0;
always #5 clk = ~clk;

reg rst = 1'b1;
reg [1:0] div = 2'd0;
wire cen = (div == 2'd3);

always @(posedge clk) div <= div + 2'd1;

reg  [7:0] rom [0:2047];
reg  [7:0] rom_q;
wire [10:0] rom_addr;

always @(posedge clk) rom_q <= rom[rom_addr];

reg irq = 1'b0;

x68705_mcu #(
    .HMOS ( HMOS )
) dut (
    .clk      ( clk      ),
    .rst      ( rst      ),
    .cen      ( cen      ),
    .rom_addr ( rom_addr ),
    .rom_data ( rom_q    ),
    .rom_cs   (          ),
    .pa_i     ( 8'hFF    ),
    .pa_o     (          ),
    .pb_i     ( 8'hFF    ),
    .pb_o     (          ),
    .pc_i     ( 4'hF     ),
    .pc_o     (          ),
    .irq      ( irq      ),
    .irq_ack  (          ),
    .timer_in ( 1'b0     )
);

wire fetch = cen & (dut.u_core.u_cpu.state == 5'd3);

integer ncen = 0;
integer errors = 0;
integer checks = 0;
integer i;
integer t0;

always @(posedge clk) if(cen) ncen = ncen + 1;

task load(input [7:0] b0, input [7:0] b1, input [7:0] b2);
begin
    for(i = 0; i < 2048; i = i + 1) rom[i] = 8'h9D;
    rom[11'h7F8] = 8'h04; rom[11'h7F9] = 8'h00;
    rom[11'h7FA] = 8'h02; rom[11'h7FB] = 8'h00;
    rom[11'h7FC] = 8'h03; rom[11'h7FD] = 8'h00;
    rom[11'h7FE] = 8'h01; rom[11'h7FF] = 8'h00;
    rom[11'h100] = b0; rom[11'h101] = b1; rom[11'h102] = b2;
end
endtask

task check(input integer got, input integer hmos_n, input integer cmos_n, input [8*16-1:0] name);
    integer want;
begin
    want = HMOS ? hmos_n : cmos_n;
    checks = checks + 1;
    if(got != want) begin
        errors = errors + 1;
        $display("  FAIL  %0s: %0d cycles, expected %0d", name, got, want);
    end
end
endtask

task run_op(input [7:0] b0, input [7:0] b1, input [7:0] b2, input integer hmos_n, input integer cmos_n,
            input [8*16-1:0] name);
begin
    load(b0, b1, b2);
    rst = 1'b1; repeat(12) @(posedge clk); rst = 1'b0;
    @(posedge clk); while(!(fetch && dut.u_core.u_cpu.reg_pc == 13'h100)) @(posedge clk);
    t0 = ncen;
    @(posedge clk); while(!fetch) @(posedge clk);
    check(ncen - t0, hmos_n, cmos_n, name);
end
endtask

initial begin
    $display("=== tb_x68705_cycles, HMOS = %0d ===", HMOS);
    run_op(8'h00, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h01, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h02, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h03, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h04, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h05, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h06, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h07, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h08, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h09, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h0A, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h0B, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h0C, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h0D, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h0E, 8'h40, 8'h00, 10,  5, "BRSET");
    run_op(8'h0F, 8'h40, 8'h00, 10,  5, "BRCLR");
    run_op(8'h10, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h11, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h12, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h13, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h14, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h15, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h16, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h17, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h18, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h19, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h1A, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h1B, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h1C, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h1D, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h1E, 8'h40, 8'h9D,  7,  5, "BSET");
    run_op(8'h1F, 8'h40, 8'h9D,  7,  5, "BCLR");
    run_op(8'h20, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h21, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h22, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h23, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h24, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h25, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h26, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h27, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h28, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h29, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h2A, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h2B, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h2C, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h2D, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h2E, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h2F, 8'h00, 8'h9D,  4,  3, "Bcc");
    run_op(8'h30, 8'h40, 8'h9D,  6,  5, "NEG dir");
    run_op(8'h33, 8'h40, 8'h9D,  6,  5, "COM dir");
    run_op(8'h34, 8'h40, 8'h9D,  6,  5, "LSR dir");
    run_op(8'h36, 8'h40, 8'h9D,  6,  5, "ROR dir");
    run_op(8'h37, 8'h40, 8'h9D,  6,  5, "ASR dir");
    run_op(8'h38, 8'h40, 8'h9D,  6,  5, "LSL dir");
    run_op(8'h39, 8'h40, 8'h9D,  6,  5, "ROL dir");
    run_op(8'h3A, 8'h40, 8'h9D,  6,  5, "DEC dir");
    run_op(8'h3C, 8'h40, 8'h9D,  6,  5, "INC dir");
    run_op(8'h3D, 8'h40, 8'h9D,  6,  4, "TST dir");
    run_op(8'h3F, 8'h40, 8'h9D,  6,  5, "CLR dir");
    run_op(8'h40, 8'h9D, 8'h9D,  4,  3, "NEGA");
    run_op(8'h43, 8'h9D, 8'h9D,  4,  3, "COMA");
    run_op(8'h44, 8'h9D, 8'h9D,  4,  3, "LSRA");
    run_op(8'h46, 8'h9D, 8'h9D,  4,  3, "RORA");
    run_op(8'h47, 8'h9D, 8'h9D,  4,  3, "ASRA");
    run_op(8'h48, 8'h9D, 8'h9D,  4,  3, "LSLA");
    run_op(8'h49, 8'h9D, 8'h9D,  4,  3, "ROLA");
    run_op(8'h4A, 8'h9D, 8'h9D,  4,  3, "DECA");
    run_op(8'h4C, 8'h9D, 8'h9D,  4,  3, "INCA");
    run_op(8'h4D, 8'h9D, 8'h9D,  4,  3, "TSTA");
    run_op(8'h4F, 8'h9D, 8'h9D,  4,  3, "CLRA");
    run_op(8'h50, 8'h9D, 8'h9D,  4,  3, "NEGX");
    run_op(8'h53, 8'h9D, 8'h9D,  4,  3, "COMX");
    run_op(8'h54, 8'h9D, 8'h9D,  4,  3, "LSRX");
    run_op(8'h56, 8'h9D, 8'h9D,  4,  3, "RORX");
    run_op(8'h57, 8'h9D, 8'h9D,  4,  3, "ASRX");
    run_op(8'h58, 8'h9D, 8'h9D,  4,  3, "LSLX");
    run_op(8'h59, 8'h9D, 8'h9D,  4,  3, "ROLX");
    run_op(8'h5A, 8'h9D, 8'h9D,  4,  3, "DECX");
    run_op(8'h5C, 8'h9D, 8'h9D,  4,  3, "INCX");
    run_op(8'h5D, 8'h9D, 8'h9D,  4,  3, "TSTX");
    run_op(8'h5F, 8'h9D, 8'h9D,  4,  3, "CLRX");
    run_op(8'h60, 8'h40, 8'h9D,  7,  6, "NEG ix1");
    run_op(8'h63, 8'h40, 8'h9D,  7,  6, "COM ix1");
    run_op(8'h64, 8'h40, 8'h9D,  7,  6, "LSR ix1");
    run_op(8'h66, 8'h40, 8'h9D,  7,  6, "ROR ix1");
    run_op(8'h67, 8'h40, 8'h9D,  7,  6, "ASR ix1");
    run_op(8'h68, 8'h40, 8'h9D,  7,  6, "LSL ix1");
    run_op(8'h69, 8'h40, 8'h9D,  7,  6, "ROL ix1");
    run_op(8'h6A, 8'h40, 8'h9D,  7,  6, "DEC ix1");
    run_op(8'h6C, 8'h40, 8'h9D,  7,  6, "INC ix1");
    run_op(8'h6D, 8'h40, 8'h9D,  7,  5, "TST ix1");
    run_op(8'h6F, 8'h40, 8'h9D,  7,  6, "CLR ix1");
    run_op(8'h70, 8'h9D, 8'h9D,  6,  5, "NEG ix");
    run_op(8'h73, 8'h9D, 8'h9D,  6,  5, "COM ix");
    run_op(8'h74, 8'h9D, 8'h9D,  6,  5, "LSR ix");
    run_op(8'h76, 8'h9D, 8'h9D,  6,  5, "ROR ix");
    run_op(8'h77, 8'h9D, 8'h9D,  6,  5, "ASR ix");
    run_op(8'h78, 8'h9D, 8'h9D,  6,  5, "LSL ix");
    run_op(8'h79, 8'h9D, 8'h9D,  6,  5, "ROL ix");
    run_op(8'h7A, 8'h9D, 8'h9D,  6,  5, "DEC ix");
    run_op(8'h7C, 8'h9D, 8'h9D,  6,  5, "INC ix");
    run_op(8'h7D, 8'h9D, 8'h9D,  6,  4, "TST ix");
    run_op(8'h7F, 8'h9D, 8'h9D,  6,  5, "CLR ix");
    run_op(8'h80, 8'h9D, 8'h9D,  9,  9, "RTI");
    run_op(8'h81, 8'h9D, 8'h9D,  6,  6, "RTS");
    run_op(8'h83, 8'h9D, 8'h9D, 11, 10, "SWI");
    run_op(8'h97, 8'h9D, 8'h9D,  2,  2, "TAX");
    run_op(8'h98, 8'h9D, 8'h9D,  2,  2, "CLC");
    run_op(8'h99, 8'h9D, 8'h9D,  2,  2, "SEC");
    run_op(8'h9A, 8'h9D, 8'h9D,  2,  2, "CLI");
    run_op(8'h9B, 8'h9D, 8'h9D,  2,  2, "SEI");
    run_op(8'h9C, 8'h9D, 8'h9D,  2,  2, "RSP");
    run_op(8'h9D, 8'h9D, 8'h9D,  2,  2, "NOP");
    run_op(8'h9F, 8'h9D, 8'h9D,  2,  2, "TXA");
    run_op(8'hA0, 8'h40, 8'h9D,  2,  2, "SUB imm");
    run_op(8'hA1, 8'h40, 8'h9D,  2,  2, "CMP imm");
    run_op(8'hA2, 8'h40, 8'h9D,  2,  2, "SBC imm");
    run_op(8'hA3, 8'h40, 8'h9D,  2,  2, "CPX imm");
    run_op(8'hA4, 8'h40, 8'h9D,  2,  2, "AND imm");
    run_op(8'hA5, 8'h40, 8'h9D,  2,  2, "BIT imm");
    run_op(8'hA6, 8'h40, 8'h9D,  2,  2, "LDA imm");
    run_op(8'hA8, 8'h40, 8'h9D,  2,  2, "EOR imm");
    run_op(8'hA9, 8'h40, 8'h9D,  2,  2, "ADC imm");
    run_op(8'hAA, 8'h40, 8'h9D,  2,  2, "ORA imm");
    run_op(8'hAB, 8'h40, 8'h9D,  2,  2, "ADD imm");
    run_op(8'hAD, 8'h00, 8'h9D,  8,  6, "BSR");
    run_op(8'hAE, 8'h40, 8'h9D,  2,  2, "LDX imm");
    run_op(8'hB0, 8'h40, 8'h9D,  4,  3, "SUB dir");
    run_op(8'hB1, 8'h40, 8'h9D,  4,  3, "CMP dir");
    run_op(8'hB2, 8'h40, 8'h9D,  4,  3, "SBC dir");
    run_op(8'hB3, 8'h40, 8'h9D,  4,  3, "CPX dir");
    run_op(8'hB4, 8'h40, 8'h9D,  4,  3, "AND dir");
    run_op(8'hB5, 8'h40, 8'h9D,  4,  3, "BIT dir");
    run_op(8'hB6, 8'h40, 8'h9D,  4,  3, "LDA dir");
    run_op(8'hB7, 8'h40, 8'h9D,  5,  4, "STA dir");
    run_op(8'hB8, 8'h40, 8'h9D,  4,  3, "EOR dir");
    run_op(8'hB9, 8'h40, 8'h9D,  4,  3, "ADC dir");
    run_op(8'hBA, 8'h40, 8'h9D,  4,  3, "ORA dir");
    run_op(8'hBB, 8'h40, 8'h9D,  4,  3, "ADD dir");
    run_op(8'hBC, 8'h40, 8'h9D,  3,  2, "JMP dir");
    run_op(8'hBD, 8'h40, 8'h9D,  7,  5, "JSR dir");
    run_op(8'hBE, 8'h40, 8'h9D,  4,  3, "LDX dir");
    run_op(8'hBF, 8'h40, 8'h9D,  5,  4, "STX dir");
    run_op(8'hC0, 8'h00, 8'h40,  5,  4, "SUB ext");
    run_op(8'hC1, 8'h00, 8'h40,  5,  4, "CMP ext");
    run_op(8'hC2, 8'h00, 8'h40,  5,  4, "SBC ext");
    run_op(8'hC3, 8'h00, 8'h40,  5,  4, "CPX ext");
    run_op(8'hC4, 8'h00, 8'h40,  5,  4, "AND ext");
    run_op(8'hC5, 8'h00, 8'h40,  5,  4, "BIT ext");
    run_op(8'hC6, 8'h00, 8'h40,  5,  4, "LDA ext");
    run_op(8'hC7, 8'h00, 8'h40,  6,  5, "STA ext");
    run_op(8'hC8, 8'h00, 8'h40,  5,  4, "EOR ext");
    run_op(8'hC9, 8'h00, 8'h40,  5,  4, "ADC ext");
    run_op(8'hCA, 8'h00, 8'h40,  5,  4, "ORA ext");
    run_op(8'hCB, 8'h00, 8'h40,  5,  4, "ADD ext");
    run_op(8'hCC, 8'h00, 8'h40,  4,  3, "JMP ext");
    run_op(8'hCD, 8'h00, 8'h40,  8,  6, "JSR ext");
    run_op(8'hCE, 8'h00, 8'h40,  5,  4, "LDX ext");
    run_op(8'hCF, 8'h00, 8'h40,  6,  5, "STX ext");
    run_op(8'hD0, 8'h00, 8'h40,  6,  5, "SUB ix2");
    run_op(8'hD1, 8'h00, 8'h40,  6,  5, "CMP ix2");
    run_op(8'hD2, 8'h00, 8'h40,  6,  5, "SBC ix2");
    run_op(8'hD3, 8'h00, 8'h40,  6,  5, "CPX ix2");
    run_op(8'hD4, 8'h00, 8'h40,  6,  5, "AND ix2");
    run_op(8'hD5, 8'h00, 8'h40,  6,  5, "BIT ix2");
    run_op(8'hD6, 8'h00, 8'h40,  6,  5, "LDA ix2");
    run_op(8'hD7, 8'h00, 8'h40,  7,  6, "STA ix2");
    run_op(8'hD8, 8'h00, 8'h40,  6,  5, "EOR ix2");
    run_op(8'hD9, 8'h00, 8'h40,  6,  5, "ADC ix2");
    run_op(8'hDA, 8'h00, 8'h40,  6,  5, "ORA ix2");
    run_op(8'hDB, 8'h00, 8'h40,  6,  5, "ADD ix2");
    run_op(8'hDC, 8'h00, 8'h40,  5,  4, "JMP ix2");
    run_op(8'hDD, 8'h00, 8'h40,  9,  7, "JSR ix2");
    run_op(8'hDE, 8'h00, 8'h40,  6,  5, "LDX ix2");
    run_op(8'hDF, 8'h00, 8'h40,  7,  6, "STX ix2");
    run_op(8'hE0, 8'h40, 8'h9D,  5,  4, "SUB ix1");
    run_op(8'hE1, 8'h40, 8'h9D,  5,  4, "CMP ix1");
    run_op(8'hE2, 8'h40, 8'h9D,  5,  4, "SBC ix1");
    run_op(8'hE3, 8'h40, 8'h9D,  5,  4, "CPX ix1");
    run_op(8'hE4, 8'h40, 8'h9D,  5,  4, "AND ix1");
    run_op(8'hE5, 8'h40, 8'h9D,  5,  4, "BIT ix1");
    run_op(8'hE6, 8'h40, 8'h9D,  5,  4, "LDA ix1");
    run_op(8'hE7, 8'h40, 8'h9D,  6,  5, "STA ix1");
    run_op(8'hE8, 8'h40, 8'h9D,  5,  4, "EOR ix1");
    run_op(8'hE9, 8'h40, 8'h9D,  5,  4, "ADC ix1");
    run_op(8'hEA, 8'h40, 8'h9D,  5,  4, "ORA ix1");
    run_op(8'hEB, 8'h40, 8'h9D,  5,  4, "ADD ix1");
    run_op(8'hEC, 8'h40, 8'h9D,  4,  3, "JMP ix1");
    run_op(8'hED, 8'h40, 8'h9D,  8,  6, "JSR ix1");
    run_op(8'hEE, 8'h40, 8'h9D,  5,  4, "LDX ix1");
    run_op(8'hEF, 8'h40, 8'h9D,  6,  5, "STX ix1");
    run_op(8'hF0, 8'h9D, 8'h9D,  4,  3, "SUB ix");
    run_op(8'hF1, 8'h9D, 8'h9D,  4,  3, "CMP ix");
    run_op(8'hF2, 8'h9D, 8'h9D,  4,  3, "SBC ix");
    run_op(8'hF3, 8'h9D, 8'h9D,  4,  3, "CPX ix");
    run_op(8'hF4, 8'h9D, 8'h9D,  4,  3, "AND ix");
    run_op(8'hF5, 8'h9D, 8'h9D,  4,  3, "BIT ix");
    run_op(8'hF6, 8'h9D, 8'h9D,  4,  3, "LDA ix");
    run_op(8'hF7, 8'h9D, 8'h9D,  5,  4, "STA ix");
    run_op(8'hF8, 8'h9D, 8'h9D,  4,  3, "EOR ix");
    run_op(8'hF9, 8'h9D, 8'h9D,  4,  3, "ADC ix");
    run_op(8'hFA, 8'h9D, 8'h9D,  4,  3, "ORA ix");
    run_op(8'hFB, 8'h9D, 8'h9D,  4,  3, "ADD ix");
    run_op(8'hFC, 8'h9D, 8'h9D,  3,  2, "JMP ix");
    run_op(8'hFD, 8'h9D, 8'h9D,  7,  5, "JSR ix");
    run_op(8'hFE, 8'h9D, 8'h9D,  4,  3, "LDX ix");
    run_op(8'hFF, 8'h9D, 8'h9D,  5,  4, "STX ix");

    // /INT entry
    load(8'h9A, 8'h9D, 8'h9D);
    rst = 1'b1; repeat(12) @(posedge clk); rst = 1'b0;
    @(posedge clk); while(!(fetch && dut.u_core.u_cpu.reg_pc == 13'h101)) @(posedge clk);
    irq = 1'b1;
    @(posedge clk); while(!(fetch && !dut.u_core.u_cpu.cc_i)) @(posedge clk);
    t0 = ncen;
    @(posedge clk); while(!(fetch && dut.u_core.u_cpu.reg_pc == 13'h200)) @(posedge clk);
    check(ncen - t0, 11, 10, "IRQ entry");

    $display("=== %0d checks, %0d errors ===", checks, errors);
    if(errors == 0) $display("TB PASS"); else $display("TB FAIL");
    $finish;
end

endmodule
