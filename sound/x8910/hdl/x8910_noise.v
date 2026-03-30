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
//  Noise generator module for the AY-3-8910 Programmable Sound Generator.
//
//  Implements a pseudo-random noise source using a 17-bit Linear Feedback
//  Shift Register (LFSR) clocked by a 5-bit period counter. The period
//  counter uses the same count-up-toggle structure as the tone generator.
//
//  Reference GI Data Manual, Section 3.2:
//    - 5-bit period counter (same count-up-toggle as tone generator)
//    - 17-bit LFSR (Linear Feedback Shift Register)
//    - Taps at bits 0 and 3 (confirmed by lvd RE schematic)
//    - LFSR shifts on rising edge of period counter toggle
//    - Zero-detect: when LFSR is all zeros, feedback forces a 1
//    - Output: inverted lfsr[0]
//    - Noise frequency: f_N = f_clock / (16 * NP)
//
//  Reference lvd RE schematic:
//    - LFSR initialized to 0, zero-detect prevents lock-up
//    - Full LFSR cycle: 131071 states (2^17 - 1, maximal length)
//============================================================================

module x8910_noise #(
    parameter LFSR_BITS = 17,
    parameter LFSR_TAP0 = 0,
    parameter LFSR_TAP1 = 3
) (
    input  wire       clk,
    input  wire       enable,
    input  wire       reset,
    input  wire [4:0] period,
    output wire       out
);

//------------------------------------------------------------------------
// Period Counter:
// 5-bit counter counts up at enable rate. Toggles output and resets
// to 1 when counter reaches programmed period value.
//------------------------------------------------------------------------
reg [4:0] counter;
reg       toggle;

always @(posedge clk) begin
    if(reset) begin
        counter <= 5'd1;
        toggle <= 1'b1;
    end else if(enable) begin
        if(counter >= period) begin
            counter <= 5'd1;
            toggle <= ~toggle;
        end else begin
            counter <= counter + 5'd1;
        end
    end
end

//------------------------------------------------------------------------
// Rising Edge Detection:
// LFSR shifts on rising edge of period counter toggle output.
//------------------------------------------------------------------------
wire trigger_edge;

x8910_edge u_edge (
    .clk        ( clk          ),
    .reset      ( reset        ),
    .signal_in  ( toggle       ),
    .on_posedge ( trigger_edge )
);

//------------------------------------------------------------------------
// 17-bit LFSR:
// Shift register with taps at bits 0 and 3. Zero-detect feedback
// prevents lock-up when all bits are zero. Output is inverted bit 0.
//------------------------------------------------------------------------
reg [LFSR_BITS-1:0] lfsr;
wire lfsr_is_zero = (lfsr == {LFSR_BITS{1'b0}});
wire lfsr_feedback = (lfsr[LFSR_TAP0] ^ lfsr[LFSR_TAP1]) | lfsr_is_zero;

always @(posedge clk) begin
    if(reset)
        lfsr <= {LFSR_BITS{1'b0}};                    // Reset to 0 (per lvd RE)
    else if(trigger_edge)
        lfsr <= {lfsr_feedback, lfsr[LFSR_BITS-1:1]}; // Shift right, feedback in MSB
end

assign out = ~lfsr[0]; // Output is inverted lfsr[0]

endmodule
