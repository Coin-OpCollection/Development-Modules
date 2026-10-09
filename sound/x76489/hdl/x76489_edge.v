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
//  Rising edge detector for the Texas Instruments SN76489AN noise
//  generator: rise is high for one clk when sig is high and was low on the
//  clk before. The noise shift register shifts on each rising edge of its
//  selected shift-rate source.
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Figure 4 [p.11].
//============================================================================

`timescale 1ns/1ps

module x76489_edge (
    // Clock and Reset
    input  wire clk,
    input  wire rst,

    // Edge Interface
    input  wire sig,
    output wire rise
);

reg prev;

always @(posedge clk) begin
    if(rst) prev <= 1'b0;
    else prev <= sig;
end

assign rise = sig & ~prev;

endmodule
