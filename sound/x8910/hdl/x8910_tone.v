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
//  Tone generator for the General Instrument AY-3-8910 programmable sound
//  generator. A 12-bit counter steps up on pre_cen, the input clock / 8;
//  when it reaches or passes period it returns to 1 and toggles out, so
//  out holds for period steps and the tone is f = f_CLOCK / (16 TP) for a
//  tone period TP [p.18].
//
//  Counter:
//    The counter counts up, compares with greater-or-equal and restarts
//    at 1, so a period of 0 acts as 1 and a period written below the
//    count takes effect on the next step (AY-3-8910 die schematic). Reset
//    sets the counter to 1 and out to 1.
//
//  Parameters:
//    PERIOD_BITS - counter and period width, 12 [p.18]
//
//  Reference: AY-3-8910/8912 Programmable Sound Generator Data Manual,
//             Tone Generator Control [p.18].
//             AY-3-8910 die schematic.
//============================================================================

`timescale 1ns/1ps

module x8910_tone #(
    parameter PERIOD_BITS = 12
)(
    // Clock and Reset
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   pre_cen,

    // Tone Interface
    input  wire [PERIOD_BITS-1:0] period,
    output wire                   out
);

//========================================================================
// Counter:
// At or past period the counter returns to 1 and state toggles.
//========================================================================
reg [PERIOD_BITS-1:0] counter;

reg state;

always @(posedge clk) begin
    if(rst) begin
        counter <= {{PERIOD_BITS-1{1'b0}}, 1'b1};
        state <= 1'b1;
    end else if(pre_cen) begin
        if(counter >= period) begin
            counter <= {{PERIOD_BITS-1{1'b0}}, 1'b1};
            state <= ~state;
        end else begin
            counter <= counter + 1'b1;
        end
    end
end

assign out = state;

endmodule
