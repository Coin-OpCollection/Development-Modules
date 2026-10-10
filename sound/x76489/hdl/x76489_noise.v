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
//  Noise generator for the Texas Instruments SN76489AN digital complex
//  sound generator: a 15-stage shift register shifted at one of four
//  rates, giving white noise (FB = 1) or periodic noise (FB = 0) (Tables
//  2 and 3 [p.3]). ctrl is {FB, NF0, NF1}.
//
//  Shift Rate:
//    counter steps on pre_cen (N/16); its bits 4, 5 and 6 give N/512,
//    N/1024 and N/2048 for NF0, NF1 = 00, 01 and 10, and 11 takes the tone
//    3 output (Table 3 [p.3], Figure 4 [p.11]). The register shifts on
//    each rising edge of the selected source.
//
//  Shift Register:
//    lfsr shifts toward bit 0, and out is bit 0, the last stage. With FB =
//    1 the stage shifted in is the XOR of the last two stages, bits 0 and
//    1. restart, a latch or data byte to the noise control register, and
//    reset reseed lfsr to 100...0, one stage opposite to the other
//    fourteen; the data sheet calls this clearing the register [p.3]. With
//    FB = 0 the register rotates, so the seed returns every 15 shifts. The
//    die shifts a constant in and reseeds from a detector on all 15 stages,
//    which gives the same 15-shift period.
//
//  The register length is from the TI-99/4A Servicing Manual (Noise
//  Generator, p. 74) and the die; the taps, the seed and the periodic mode
//  are from the die (TI SN76489AN die schematic, NOISE).
//
//  Parameters:
//    LFSR_BITS - register length, 15
//    LFSR_TAP0 - first feedback tap, 0 (the last stage)
//    LFSR_TAP1 - second feedback tap, 1
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Noise Generator, Tables 2 and 3 [p.2-3], Figure 4 [p.11].
//             TI-99/4A Servicing Manual, Sound Generation Controller,
//             p. 74.
//             TI SN76489AN die schematic, NOISE.
//============================================================================

`timescale 1ns/1ps

module x76489_noise #(
    parameter LFSR_BITS = 15,
    parameter LFSR_TAP0 = 0,
    parameter LFSR_TAP1 = 1
)(
    // Clock and Reset
    input  wire       clk,
    input  wire       rst,
    input  wire       pre_cen,

    // Noise Interface
    input  wire       restart,
    input  wire [2:0] ctrl,
    input  wire       tone3,
    output wire       out
);

//========================================================================
// Shift Rate:
//========================================================================
reg [6:0] counter;

always @(posedge clk) begin
    if(rst) counter <= 7'd0;
    else if(pre_cen) counter <= counter + 7'd1;
end

reg trigger;

always @(*) begin
    case(ctrl[1:0])
        2'b00 : trigger = counter[4];
        2'b01 : trigger = counter[5];
        2'b10 : trigger = counter[6];
        2'b11 : trigger = tone3;
        default : trigger = counter[4];
    endcase
end

wire shift;

x76489_edge u_edge (
    // Clock and Reset
    .clk  ( clk     ),
    .rst  ( rst     ),

    // Edge Interface
    .sig  ( trigger ),
    .rise ( shift   )
);

//========================================================================
// Shift Register:
//========================================================================
reg [LFSR_BITS-1:0] lfsr;

always @(posedge clk) begin
    if(rst || restart) begin
        lfsr <= 1'b1 << (LFSR_BITS - 1);
    end else if(shift) begin
        if(ctrl[2]) lfsr <= {lfsr[LFSR_TAP0] ^ lfsr[LFSR_TAP1], lfsr[LFSR_BITS-1:1]};
        else lfsr <= {lfsr[LFSR_TAP0], lfsr[LFSR_BITS-1:1]};
    end
end

assign out = lfsr[0];

endmodule
