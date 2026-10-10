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
//  Rising edge detector for the General Instrument AY-3-8910 noise and
//  envelope generators: rise is high for one clk when sig is high and was
//  low on the clk before. The noise shift register and the envelope step
//  counter advance on each rising edge of their period counter outputs.
//
//  Reset sets prev to 1, as the period counter outputs, so reset and an
//  envelope restart make no edge: the first noise shift and the first
//  envelope step come a full period later (AY-3-8910 die schematic).
//
//  Reference: AY-3-8910 die schematic.
//============================================================================

`timescale 1ns/1ps

module x8910_edge (
    // Clock and Reset
    input  wire clk,
    input  wire rst,

    // Edge Interface
    input  wire sig,
    output wire rise
);

reg prev;

always @(posedge clk) begin
    if(rst) prev <= 1'b1;
    else prev <= sig;
end

assign rise = sig & ~prev;

endmodule
