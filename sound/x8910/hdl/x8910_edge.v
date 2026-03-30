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
//  Single-cycle rising edge detector for the AY-3-8910 implementation.
//
//  Generates a one-clock-cycle pulse on the rising edge of the input
//  signal. Used by the noise and envelope generators to trigger state
//  changes on the rising edge of their respective period counter toggles.
//============================================================================

module x8910_edge (
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire on_posedge
);

reg prev;

always @(posedge clk) begin
    if(reset)
        prev <= 1'b0;
    else
        prev <= signal_in;
end

assign on_posedge = (prev != signal_in) & signal_in;

endmodule
