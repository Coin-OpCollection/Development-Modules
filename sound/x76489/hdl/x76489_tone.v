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
//  Tone generator for the Texas Instruments SN76489AN digital complex
//  sound generator. A 10-bit down counter steps on pre_cen; when it
//  reaches zero it reloads with period - 1 and toggles out, so out stays
//  high or low for period steps and the tone is f = N / 32n for an input
//  clock N and a period n [p.2].
//
//  Period 0:
//    The data sheet does not define n = 0 [p.2]. On the die the counter
//    reloads as it reaches zero and a loaded 0 counts on through 1023, so
//    n = 0 holds out for 1024 steps (TI SN76489AN die schematic, TONE);
//    here period - 1 reloads 1023.
//
//  Parameters:
//    COUNTER_BITS - counter and period width, 10 [p.2]
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Tone Generators [p.2].
//             TI SN76489AN die schematic, TONE.
//============================================================================

`timescale 1ns/1ps

module x76489_tone #(
    parameter COUNTER_BITS = 10
)(
    // Clock and Reset
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    pre_cen,

    // Tone Interface
    input  wire [COUNTER_BITS-1:0] period,
    output wire                    out
);

//========================================================================
// Counter:
// The borrow at zero reloads the counter and toggles state.
//========================================================================
reg [COUNTER_BITS-1:0] counter;
reg                    state;

always @(posedge clk) begin
    if(rst) begin
        counter <= {COUNTER_BITS{1'b0}};
        state <= 1'b0;
    end else if(pre_cen) begin
        if(counter == {COUNTER_BITS{1'b0}}) begin
            counter <= period - 1'b1;
            state <= ~state;
        end else begin
            counter <= counter - 1'b1;
        end
    end
end

assign out = state;

endmodule
