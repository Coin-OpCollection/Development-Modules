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
//  Noise generator module for the SN76489AN Complex Sound Generator.
//
//  Implements a 15-bit Linear Feedback Shift Register (LFSR) with
//  configurable feedback and selectable shift rate. The LFSR produces
//  either periodic or white noise depending on the feedback mode.
//
//  Reference TI SN76489AN datasheet, Section 2 and Figure 4:
//    - 15-bit LFSR with configurable feedback taps
//    - Default taps (0,1) match SN76489AN / SG-1000 / Colecovision
//    - Shift rate derived from master_clock/16, then further divided:
//        NF=00: /32  (N/512 total)    NF=01: /64  (N/1024 total)
//        NF=10: /128 (N/2048 total)   NF=11: Tone Generator #3 output
//    - White noise (FB=1): XOR feedback prevents lock-up
//    - Periodic noise (FB=0): Direct feedback, produces regular pattern
//    - LFSR reset to 100...0 whenever noise control register is written
//============================================================================

module x76489_noise #(
    parameter LFSR_BITS = 15,
    parameter LFSR_TAP0 = 0,
    parameter LFSR_TAP1 = 1
) (
    input  wire       clk,
    input  wire       enable,
    input  wire       reset,
    input  wire       restart_noise,
    input  wire [2:0] control,        // {FB, NF0, NF1}
    input  wire       driven_by_tone,
    output wire       out
);

//------------------------------------------------------------------------
// Noise Type Select (Table 2):
// FB=0: periodic noise (direct feedback from bit 0)
// FB=1: white noise (XOR feedback from tapped bits)
//------------------------------------------------------------------------
wire is_white_noise = control[2];

//------------------------------------------------------------------------
// Shift Rate Counter (Table 3):
// Internal counter provides fixed shift rates after /16 prescaler.
// counter[4]=/32, counter[5]=/64, counter[6]=/128
//------------------------------------------------------------------------
reg [6:0] counter;

always @(posedge clk) begin
    if(reset)
        counter <= 7'd0;
    else if(enable)
        counter <= counter + 7'd1;
end

//------------------------------------------------------------------------
// Shift Rate Source Selection (Table 3):
// NF=00: N/512   NF=01: N/1024   NF=10: N/2048
// NF=11: Driven by Tone Generator #3 output
//------------------------------------------------------------------------
reg trigger;
always @(*) begin
    case(control[1:0])
        2'b00: trigger = counter[4];     // N/512
        2'b01: trigger = counter[5];     // N/1024
        2'b10: trigger = counter[6];     // N/2048
        2'b11: trigger = driven_by_tone; // Tone channel 3
        default: trigger = counter[4];
    endcase
end

//------------------------------------------------------------------------
// Trigger Edge Detection:
// LFSR shifts on rising edge of selected shift rate source.
//------------------------------------------------------------------------
wire trigger_edge;

x76489_edge u_edge (
    .clk        ( clk          ),
    .reset      ( reset        ),
    .signal_in  ( trigger      ),
    .on_posedge ( trigger_edge )
);

//------------------------------------------------------------------------
// 15-bit LFSR:
// Configurable feedback taps. White noise uses XOR of tapped bits.
// Periodic noise uses direct feedback from tap 0. LFSR reset to
// 100...0 on noise control register write (prevents zero lock-up).
//------------------------------------------------------------------------
wire reset_lfsr = reset | restart_noise;

reg [LFSR_BITS-1:0] lfsr;

always @(posedge clk) begin
    if(reset_lfsr)
        lfsr <= 1'b1 << (LFSR_BITS - 1); // Reset to 100...0
    else if(trigger_edge) begin
        if(is_white_noise)
            lfsr <= {lfsr[LFSR_TAP0] ^ lfsr[LFSR_TAP1], lfsr[LFSR_BITS-1:1]}; // XOR feedback
        else
            lfsr <= {lfsr[LFSR_TAP0], lfsr[LFSR_BITS-1:1]}; // Direct feedback
    end
end

assign out = lfsr[0];

endmodule
