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
//  Parallel I/O ports module for the HuC6280 microprocessor.
//
//  Implements the two on-chip I/O ports documented in the HuC6280
//  Hardware Manual section 2.6. Both ports share the same physical
//  address range; a read returns the Port K input bus and a write
//  latches data onto the Port O output drivers.
//
//    Port K  - 8-bit TTL input with internal pull-up. Read at $1FF000-
//              $1FF3FF.
//    Port O  - 8-bit latched output (CMOS, complementary drive). Written
//              at $1FF000-$1FF3FF. Reset state is $FF on every pin per
//              the system reset list in section 2.5.
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual,
//             sections 2.5 and 2.6 [p.HB-18], [p.HB-19]
//
//  Register Map:
//    $1FF000  Port K (read) / Port O (write)
//============================================================================

`timescale 1ns/1ps

module x6280_io (
    // Clock and Reset
    input  wire       clk,
    input  wire       rst_n,
    input  wire       cen,

    // Register Bus Interface
    input  wire       iop_sel,
    input  wire       cer,
    input  wire       we_n,
    input  wire [7:0] din,

    // Port Interface
    input  wire [7:0] port_k,
    output reg  [7:0] port_o,

    // Read Data Interface
    output wire [7:0] iop_dout
);

//------------------------------------------------------------------------
// Output Latch:
// Synchronous write captures din into port_o on a CPU access strobe.
// Reset value is $FF on every pin per the documented system reset state.
//------------------------------------------------------------------------
always @(posedge clk) begin
    if(!rst_n) begin
        port_o <= 8'hFF;
    end else if(cen && iop_sel && cer && !we_n) begin
        port_o <= din;
    end
end

assign iop_dout = port_k;

endmodule
