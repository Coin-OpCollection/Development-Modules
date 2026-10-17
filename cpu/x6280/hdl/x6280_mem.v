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
//  Address decode and read-data multiplexer for the HuC6280 microprocessor.
//
//  Implements the on-chip address map documented in the HuC6280 Hardware
//  Manual section 2.9. The decoder uses the upper bits of the 21-bit
//  physical address to select between RAM, the internal-I/O page, and
//  external memory. Within the internal-I/O page (phys[20:13] = $FF),
//  bits phys[12:10] select the on-chip block.
//
//  The IO_BUF byte-wide register tracks the last data observed on the
//  internal I/O bus. It supplies the open-bus / mirrored upper bits when
//  partial-width registers are read (Timer = 7 bits, IRQ = 3 bits) so
//  the upper bits behave as on real hardware.
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual,
//             section 2.9 [p.HB-24]
//
//  Memory Map (phys_addr):
//    $1F0000-$1F7FFF  On-chip RAM region (pages F8-FB)  -> CER_N
//    $1FE000-$1FE3FF  HuC6270 VDC                       -> CE7_N
//    $1FE400-$1FE7FF  HuC6260 VCE                       -> CEK_N
//    $1FE800-$1FEBFF  PSG
//    $1FEC00-$1FEFFF  Timer
//    $1FF000-$1FF3FF  Port K / Port O
//    $1FF400-$1FF7FF  Interrupt registers
//    $1FF800-$1FFFFF  Reserved
//
//  Read-Data Mux Priority:
//    iop_sel : Port K input
//    int_sel : { io_buf[7:3], int_mask } at A[1:0] = 10
//              { io_buf[7:3], int_irr  } at A[1:0] = 11
//              { io_buf[7:0]           } otherwise
//    tmr_sel : { io_buf[7], tmr_value[6:0] }
//    psg_sel : 8'h00
//    else    : ext_din (external bus)
//============================================================================

`timescale 1ns/1ps

module x6280_mem (
    // Clock and Reset
    input  wire        clk,
    input  wire        rst_n,
    input  wire        cen,

    // CPU Bus Interface
    input  wire [20:0] phys_addr,
    input  wire        we_n,
    input  wire  [7:0] cpu_dout,

    // External Data Bus
    input  wire  [7:0] ext_din,

    // On-Chip Block Read Data
    input  wire  [2:0] int_mask,
    input  wire  [2:0] int_irr,
    input  wire  [6:0] tmr_value,
    input  wire  [7:0] iop_dout,

    // Chip-Select
    output wire        vdc_sel,
    output wire        vce_sel,
    output wire        psg_sel,
    output wire        tmr_sel,
    output wire        iop_sel,
    output wire        int_sel,
    output wire        ram_sel,

    // External Chip-Select
    output wire        ce7_n,
    output wire        cek_n,
    output wire        cer_n,

    // CPU Read Data
    output reg   [7:0] cpu_din
);

//------------------------------------------------------------------------
// Page Decode:
// io_page asserts when the upper 8 bits of phys_addr are $FF (i.e.
// $1FE000-$1FFFFF). io_blk selects between the seven internal blocks.
// ram_sel covers pages F8-FB ($1F0000-$1F7FFF).
//------------------------------------------------------------------------
wire       io_page = (phys_addr[20:13] == 8'hFF);
wire [2:0] io_blk  = phys_addr[12:10];

assign vdc_sel = io_page & (io_blk == 3'b000);
assign vce_sel = io_page & (io_blk == 3'b001);
assign psg_sel = io_page & (io_blk == 3'b010);
assign tmr_sel = io_page & (io_blk == 3'b011);
assign iop_sel = io_page & (io_blk == 3'b100);
assign int_sel = io_page & (io_blk == 3'b101);
assign ram_sel = (phys_addr[20:15] == 6'b111110);

assign ce7_n = ~vdc_sel;
assign cek_n = ~vce_sel;
assign cer_n = ~ram_sel;

wire io_sel = iop_sel | int_sel | tmr_sel | psg_sel;

//------------------------------------------------------------------------
// IO_BUF Latch:
// Captures the last byte seen on the internal I/O bus (write data on
// writes, mux output on reads). Supplies the mirrored upper bits when
// partial-width registers are read.
//------------------------------------------------------------------------
reg [7:0] io_buf;

always @(posedge clk) begin
    if(!rst_n) begin
        io_buf <= 8'hFF;
    end else if(cen && io_sel) begin
        if(!we_n)
            io_buf <= cpu_dout;
        else
            io_buf <= cpu_din;
    end
end

//------------------------------------------------------------------------
// CPU Data Input Mux:
// Routes the selected on-chip block read data to the CPU. Partial-width
// registers (timer, interrupt) are merged with io_buf to preserve the
// open-bus mirroring of the upper bits.
// The PSG registers are write-only; a PSG read returns io_buf and leaves
// it unchanged.
//------------------------------------------------------------------------
always @(*) begin
    if(iop_sel) begin
        cpu_din = iop_dout;
    end else if(int_sel) begin
        case(phys_addr[1:0])
            2'b10:   cpu_din = {io_buf[7:3], int_mask};
            2'b11:   cpu_din = {io_buf[7:3], int_irr};
            default: cpu_din = io_buf;
        endcase
    end else if(tmr_sel) begin
        cpu_din = {io_buf[7], tmr_value};
    end else if(psg_sel) begin
        cpu_din = io_buf;
    end else begin
        cpu_din = ext_din;
    end
end

endmodule
