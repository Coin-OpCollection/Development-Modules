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
//  Hitachi HM53461 64K x 4 multiport video DRAM: a behavioral model of one
//  row of chips of a CPS1 sprite frame-buffer bank, 13 data bits wide (D0-3
//  from the B-board, D4-12 from the CPS-A-01), for the system testbench.
//
//  The strobes are taken as edges, with no system clock, as the gate-level
//  netlists drive them. Not for synthesis.
//
//  Cycle types, as the Hitachi data sheet:
//    - ~DT/OE high at the ~RAS fall: random access; ~WE low at the ~RAS
//      fall selects the write-mask mode (I/O at the fall = mask); a ~WE
//      fall while ~CAS is low writes the column (late write)
//    - ~DT/OE low at the ~RAS fall: transfer; ~WE high is a read transfer,
//      the row to the SAM at the ~DT/OE rising edge; ~WE low is a write
//      transfer (~SOE low) or a pseudo transfer (~SOE high), counted only
//    - ~CAS low at the ~RAS fall: CAS-before-RAS refresh
//
//  Serial port: an SC rising edge advances the pointer, the first after a
//  transfer putting out the start column; SD is driven while ~SOE is low,
//  +sdacc ns (default 35) after ~SOE / SC.
//
//  Counters: each cycle type, and reads with ~DT/OE low (a bus fight with
//  the CPS-A-01, which always drives D4-12).
//
//  Parameters:
//    NAME - the row's name in the write log (+wlog: wlog_<NAME>.txt)
//============================================================================

`timescale 1ns/1ps

module hitachi_hm53461 #(
    parameter NAME = "row"
) (
    // Strobes
    input  wire        RASn,
    input  wire        CASn,
    input  wire        WEn,
    input  wire        DTOEn,
    input  wire        SC,
    input  wire        SOEn,

    // Address and Data
    input  wire  [7:0] A,
    input  wire [12:0] D,
    output wire [12:0] SD
);

//========================================================================
// Array:
//========================================================================
reg [12:0] mem [0:65535];
reg [12:0] sam [0:255];

integer i;

initial begin
    for(i = 0; i < 65536; i = i + 1) mem[i] = 13'h1fff;
    for(i = 0; i < 256; i = i + 1) sam[i] = 13'h1fff;
end

//========================================================================
// Counters:
//========================================================================
integer n_ras = 0;
integer n_xread = 0;
integer n_xwrite = 0;
integer n_pseudo = 0;
integer n_cbr = 0;
integer n_write = 0;
integer n_read = 0;
integer n_fight = 0;
integer n_xfer_done = 0;
integer n_mask = 0;

//========================================================================
// Cycle Type:
//========================================================================
reg  [7:0] row = 8'd0;
reg        cbr = 1'b0;
reg        xfer = 1'b0;
reg        xread = 1'b0;
reg        masked = 1'b0;
reg [12:0] mask = 13'h1fff;

always @(negedge RASn) begin
    n_ras = n_ras + 1;
    row = A;
    cbr = !CASn;
    xfer = !DTOEn && CASn;
    xread = WEn;
    masked = !DTOEn ? 1'b0 : !WEn;
    mask = (DTOEn && !WEn) ? D : 13'h1fff;
    if(cbr) n_cbr = n_cbr + 1;
    else if(xfer) begin
        if(WEn) n_xread = n_xread + 1;
        else if(!SOEn) n_xwrite = n_xwrite + 1;
        else n_pseudo = n_pseudo + 1;
    end
    else if(masked) n_mask = n_mask + 1;
end

//========================================================================
// Random Access:
//========================================================================
integer logfd = 0;

reg [7:0] start = 8'd0;
reg [7:0] col_l = 8'd0;

initial begin
    if($test$plusargs("wlog")) logfd = $fopen({"wlog_", NAME, ".txt"}, "w");
end

task wr(input [7:0] col);
    begin
        if(logfd) $fdisplay(logfd, "%0t %s row %02x col %02x d %04x mask %04x", $time, NAME, row, col, D, mask);
        mem[{row, col}] = (mem[{row, col}] & ~mask) | (D & mask);
        n_write = n_write + 1;
    end
endtask

always @(negedge CASn) begin
    if(!RASn && !cbr) begin
        if(xfer) start = A;
        else if(!WEn) wr(A);
        else begin
            n_read = n_read + 1;
            if(!DTOEn) n_fight = n_fight + 1;
        end
    end
end

always @(negedge CASn) begin
    col_l = A;
end

always @(negedge WEn) begin
    if(!RASn && !CASn && !cbr && !xfer) wr(col_l);
end

//========================================================================
// Read Transfer:
//========================================================================
reg [7:0] ptr = 8'd0;

always @(posedge DTOEn) begin
    if(!RASn && xfer && xread) begin
        for(i = 0; i < 256; i = i + 1) sam[i] = mem[{row, i[7:0]}];
        ptr = start - 8'd1;
        n_xfer_done = n_xfer_done + 1;
    end
end

//========================================================================
// Serial Port:
//========================================================================
integer tsd = 35;

wire [12:0] sd_now = SOEn ? 13'bz : sam[ptr];
reg  [12:0] sd_d = 13'bz;

initial begin
    if($value$plusargs("sdacc=%d", tsd)) ;
end

always @(posedge SC) begin
    ptr = ptr + 1;
end

always @(sd_now) begin
    sd_d <= #(tsd) sd_now;
end

assign SD = sd_d;

endmodule
