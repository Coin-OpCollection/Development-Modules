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
//  Noise generator for the General Instrument AY-3-8910 programmable sound
//  generator: a 5-bit period counter built as the tone counter, and a
//  17-bit shift register that shifts on each rising edge of the counter
//  output. The noise frequency is f = f_CLOCK / (16 NP) for a noise period
//  NP [p.20].
//
//  Period Counter:
//    The counter steps up on pre_cen, compares with greater-or-equal and
//    restarts at 1, so a period of 0 acts as 1 (AY-3-8910 die schematic).
//
//  Shift Register:
//    lfsr shifts toward bit 0 and takes in the XOR of bits 0 and 3, or a 1
//    while every stage is 0, so it leaves the all-zero state that reset
//    loads. out is the inverse of bit 0 (AY-3-8910 die schematic).
//
//  Parameters:
//    LFSR_BITS - register length, 17
//    LFSR_TAP0 - first feedback tap, 0 (the last stage)
//    LFSR_TAP1 - second feedback tap, 3
//
//  Reference: AY-3-8910/8912 Programmable Sound Generator Data Manual,
//             Noise Generator Control [p.20].
//             AY-3-8910 die schematic.
//============================================================================

`timescale 1ns/1ps

module x8910_noise #(
    parameter LFSR_BITS = 17,
    parameter LFSR_TAP0 = 0,
    parameter LFSR_TAP1 = 3
)(
    // Clock and Reset
    input  wire       clk,
    input  wire       rst,
    input  wire       pre_cen,

    // Noise Interface
    input  wire [4:0] period,
    output wire       out
);

//========================================================================
// Period Counter:
// At or past period the counter returns to 1 and toggle changes.
//========================================================================
reg [4:0] counter;
reg       toggle;

always @(posedge clk) begin
    if(rst) begin
        counter <= 5'd1;
        toggle <= 1'b1;
    end else if(pre_cen) begin
        if(counter >= period) begin
            counter <= 5'd1;
            toggle <= ~toggle;
        end else begin
            counter <= counter + 5'd1;
        end
    end
end

wire shift;

x8910_edge u_edge (
    // Clock and Reset
    .clk  ( clk    ),
    .rst  ( rst    ),

    // Edge Interface
    .sig  ( toggle ),
    .rise ( shift  )
);

//========================================================================
// Shift Register:
//========================================================================
reg [LFSR_BITS-1:0] lfsr;

wire lfsr_zero = (lfsr == {LFSR_BITS{1'b0}});
wire lfsr_in   = (lfsr[LFSR_TAP0] ^ lfsr[LFSR_TAP1]) | lfsr_zero;

always @(posedge clk) begin
    if(rst) lfsr <= {LFSR_BITS{1'b0}};
    else if(shift) lfsr <= {lfsr_in, lfsr[LFSR_BITS-1:1]};
end

assign out = ~lfsr[0];

endmodule
