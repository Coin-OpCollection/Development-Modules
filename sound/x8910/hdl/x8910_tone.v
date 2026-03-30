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
//  Tone generator module for the AY-3-8910 Programmable Sound Generator.
//
//  Implements a square wave generator with configurable period. The counter
//  counts up at the base enable rate and toggles the output when the count
//  reaches the programmed period, producing a 50% duty cycle square wave.
//
//  Reference GI Data Manual, Section 3.1:
//    - Counts UP at base enable rate (f_clock / 8)
//    - Toggles output and resets counter to 1 when counter >= period
//    - Period 0 and 1 both produce divide-by-1 (highest frequency)
//    - Output is a square wave at f_clock / (16 * period)
//
//  Reference lvd RE schematic:
//    - Real AY-3-8910 counts UP (not down as stated in GI manual)
//    - First flip-flop has UP_RST(0), resetting counter to 1 not 0
//    - Changing period takes effect immediately (no reload delay)
//============================================================================

module x8910_tone #(
    parameter PERIOD_BITS = 12
) (
    input  wire clk,
    input  wire enable,
    input  wire reset,
    input  wire [PERIOD_BITS-1:0] period,
    output wire out
);

reg [PERIOD_BITS-1:0] counter;
reg state;

always @(posedge clk) begin
    if(reset) begin
        counter <= {{PERIOD_BITS-1{1'b0}}, 1'b1};     // Reset to 1 (per lvd RE: UP_RST)
        state <= 1'b1;                                // Flip-flop set to 1 at reset
    end else if(enable) begin
        if(counter >= period) begin
            counter <= {{PERIOD_BITS-1{1'b0}}, 1'b1}; // Reset to 1
            state <= ~state;                          // Toggle output
        end else begin
            counter <= counter + 1'b1;                // Count up
        end
    end
end

assign out = state;

endmodule
