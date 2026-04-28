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
//  Tone generator module for the SN76489AN Complex Sound Generator.
//
//  Implements a 10-bit down counter with toggle flip-flop output. The
//  counter decrements at the prescaled clock rate and toggles the output
//  on borrow (reaching zero), producing a 50% duty cycle square wave.
//
//  Reference TI SN76489AN datasheet, Section 1:
//    - 10-bit down counter, decremented at master_clock/16 rate
//    - Borrow signal at zero toggles frequency flip-flop and reloads counter
//    - Period of desired frequency = 2 * counter period (due to /2 toggle)
//    - Frequency formula: f = clock / (32 * N) where N = 10-bit register
//    - N=0 wraps to max period (1024 tone_en cycles), matching real hardware
//============================================================================

module x76489_tone #(
    parameter COUNTER_BITS = 10
) (
    input  wire                    clk,
    input  wire                    enable,
    input  wire                    reset,
    input  wire [COUNTER_BITS-1:0] compare,
    output wire                    out
);

reg [COUNTER_BITS-1:0] counter;
reg                    state;

always @(posedge clk) begin
    if(reset) begin
        counter <= {COUNTER_BITS{1'b0}};
        state <= 1'b0;
    end else if(enable) begin
        if(counter == {COUNTER_BITS{1'b0}}) begin
            counter <= compare - 1'b1; // Reload on borrow
            state <= ~state; // Toggle output (/2)
        end else begin
            counter <= counter - 1'b1; // Decrement
        end
    end
end

assign out = state;

endmodule
