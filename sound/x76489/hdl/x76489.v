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
//  Texas Instruments SN76489AN digital complex sound generator: three
//  programmable tone generators, a white and periodic noise generator and
//  four attenuators, summed into one audio output [p.1-3]. The bus
//  controller and control registers (x76489_host), the tone generators
//  (x76489_tone) and the noise generator (x76489_noise) are instantiated
//  internally.
//
//  Clocking:
//    CEN is one pulse per input clock (CLOCK, 3.579 MHz typ, 4 MHz max
//    [p.9]). A /16 prescaler gives pre_cen, which steps the tone counters
//    and the noise shift-rate divider (Block Diagram [p.10], Figure 4
//    [p.11]). CLK is the system clock.
//
//  Pins:
//    - CSn, WRn: CE and WE, active low [p.5-6]
//    - DIN: D0-D7. TI numbers D0 as the MSB, so DIN[7] is D0 (pin 3), the
//      latch flag, and DIN[0] is D7 (pin 10) [p.4], [p.6]
//    - READY: READY, low while CSn is low until the byte loads [p.5-6]; on
//      the chip an open collector output, here driven both ways
//    - RESETn: the chip has no reset pin [p.6]; RESETn sets each tone
//      register to 1, each attenuation to OFF and the noise control to
//      white noise at N/512
//    - AOUT: AUDIO OUT, the four channels summed, 8 bits unsigned
//
//  Write Timing:
//    A write starts on the first CLK on which CSn and WRn are both low,
//    and the byte on DIN is taken then. It is loaded on the CLK of the 32nd
//    CEN pulse of the write; READY is low while CSn is low until then
//    [p.5]. A write held 32 more CEN pulses after its byte is loaded starts
//    another (SN76494/SN76496 Data Sheet, p. 4-40), and a write that starts
//    during a transfer loads after it.
//
//  Registers:
//    A latch byte (D0 = 1) selects one of eight registers by R0-R2 and
//    loads its low bits; a data byte (D0 = 0) loads F0-F5 of a latched
//    tone frequency, A0-A3 of a latched attenuation or FB, NF0 and NF1 of
//    the latched noise control, so a frequency can be swept with data
//    bytes alone [p.3-4].
//
//  Tone Generators:
//    Each 10-bit counter steps on pre_cen; at zero it reloads with n - 1
//    and toggles its output, so the output holds for n steps and a tone is
//    f = N / 32n for an input clock N [p.2]. n = 0 reloads 1023 and counts
//    1024.
//
//  Noise Generator:
//    A 15-stage shift register shifted at N/512, N/1024, N/2048 or on the
//    tone 3 output, giving white noise (FB = 1) or periodic noise (FB = 0)
//    (Tables 2 and 3 [p.3]). A byte to the noise control register reseeds
//    it [p.3].
//
//  Audio Output:
//    Each channel is its attenuated level while its output is high and 0
//    while it is low. AOUT is bits 11-4 of the sum of the four levels,
//    registered; one channel at 0 dB gives 63. On the chip each channel
//    drives a current into the output amplifier, so there silence is a DC
//    level [p.3], [p.8]; here it is 0.
//
//  The data sheet gives the formats, the rates and the attenuation weights:
//  n = 0, data bytes to an attenuation or the noise control, the shift
//  register taps, its seed and the periodic mode come from the die (TI
//  SN76489AN die schematic, TONE, NOISE and DATA WRITE CONTROL).
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Features [p.1], Operation [p.2-5], Pin Assignment [p.6],
//             Electrical Characteristics [p.7], External Audio Output
//             Interface [p.8], Switching Characteristics [p.9], Block
//             Diagram [p.10], Figure 4 [p.11].
//             TI SN76494, SN76494A, SN76496, SN76496A Data Sheet D2801, WE,
//             p. 4-40.
//             TI SN76489AN die schematic, TONE, NOISE.
//============================================================================

`timescale 1ns/1ps

module x76489 (
    // Clock and Reset
    input  wire       CLK,
    input  wire       RESETn,
    input  wire       CEN,

    // Control Interface
    input  wire [7:0] DIN,
    input  wire       CSn,
    input  wire       WRn,
    output wire       READY,

    // Audio Output
    output reg  [7:0] AOUT
);

wire rst = ~RESETn;

//========================================================================
// Attenuation:
// A0-A3 weigh 16, 8, 4 and 2 dB and add, 0-28 dB; 1111 is OFF (Table 1
// [p.2]). The levels are ideal 2 dB steps, 1023 x 10^(-step / 10)
// rounded down; the chip holds each weight within 1 dB [p.7].
//========================================================================
function [9:0] attn_vol;
    input [3:0] ctrl;
    case(ctrl)
        4'd0  : attn_vol = 10'd1023; // 0 dB
        4'd1  : attn_vol = 10'd812;  // 2 dB
        4'd2  : attn_vol = 10'd645;  // 4 dB
        4'd3  : attn_vol = 10'd512;  // 6 dB
        4'd4  : attn_vol = 10'd407;  // 8 dB
        4'd5  : attn_vol = 10'd323;  // 10 dB
        4'd6  : attn_vol = 10'd256;  // 12 dB
        4'd7  : attn_vol = 10'd204;  // 14 dB
        4'd8  : attn_vol = 10'd162;  // 16 dB
        4'd9  : attn_vol = 10'd128;  // 18 dB
        4'd10 : attn_vol = 10'd102;  // 20 dB
        4'd11 : attn_vol = 10'd81;   // 22 dB
        4'd12 : attn_vol = 10'd64;   // 24 dB
        4'd13 : attn_vol = 10'd51;   // 26 dB
        4'd14 : attn_vol = 10'd40;   // 28 dB
        4'd15 : attn_vol = 10'd0;    // OFF
    endcase
endfunction

//========================================================================
// Prescaler:
// pre_cen is one CEN pulse in 16 (Figure 4 [p.11]).
//========================================================================
reg [3:0] pre_cnt;

wire pre_cen = CEN & (pre_cnt == 4'd0);

always @(posedge CLK) begin
    if(rst) pre_cnt <= 4'd0;
    else if(CEN) pre_cnt <= pre_cnt + 4'd1;
end

//========================================================================
// Bus Controller and Control Registers:
// Each write loads its byte on the 32nd CEN pulse after it starts, with
// READY low while CSn is low until then; the registers are the tone
// periods, the attenuations and the noise control [p.3-5].
//========================================================================
wire [9:0] tone_freq0;
wire [9:0] tone_freq1;
wire [9:0] tone_freq2;
wire [3:0] ch_attn0;
wire [3:0] ch_attn1;
wire [3:0] ch_attn2;
wire [3:0] ch_attn3;
wire [2:0] noise_ctrl;
wire       restart_noise;

x76489_host u_host (
    // Clock and Reset
    .clk        ( CLK           ),
    .rst        ( rst           ),
    .cen        ( CEN           ),

    // Control Interface
    .din        ( DIN           ),
    .cs_n       ( CSn           ),
    .wr_n       ( WRn           ),
    .ready      ( READY         ),

    // Register Interface
    .tone0      ( tone_freq0    ),
    .tone1      ( tone_freq1    ),
    .tone2      ( tone_freq2    ),
    .attn0      ( ch_attn0      ),
    .attn1      ( ch_attn1      ),
    .attn2      ( ch_attn2      ),
    .attn3      ( ch_attn3      ),
    .noise_ctrl ( noise_ctrl    ),
    .restart    ( restart_noise )
);

//========================================================================
// Tone Generators:
// Tone 1-3 from tone_freq0-tone_freq2 [p.2].
//========================================================================
wire tone_out [0:2];

x76489_tone u_tone0 (
    // Clock and Reset
    .clk     ( CLK         ),
    .rst     ( rst         ),
    .pre_cen ( pre_cen     ),

    // Tone Interface
    .period  ( tone_freq0  ),
    .out     ( tone_out[0] )
);

x76489_tone u_tone1 (
    // Clock and Reset
    .clk     ( CLK         ),
    .rst     ( rst         ),
    .pre_cen ( pre_cen     ),

    // Tone Interface
    .period  ( tone_freq1  ),
    .out     ( tone_out[1] )
);

x76489_tone u_tone2 (
    // Clock and Reset
    .clk     ( CLK         ),
    .rst     ( rst         ),
    .pre_cen ( pre_cen     ),

    // Tone Interface
    .period  ( tone_freq2  ),
    .out     ( tone_out[2] )
);

//========================================================================
// Noise Generator:
// The shift register at the rate of NF0, NF1 or on the tone 3 output,
// white or periodic by FB (Tables 2 and 3 [p.3]).
//========================================================================
wire noise_out;

x76489_noise u_noise (
    // Clock and Reset
    .clk     ( CLK           ),
    .rst     ( rst           ),
    .pre_cen ( pre_cen       ),

    // Noise Interface
    .restart ( restart_noise ),
    .ctrl    ( noise_ctrl    ),
    .tone3   ( tone_out[2]   ),
    .out     ( noise_out     )
);

//========================================================================
// Audio Output:
// Each channel is its attenuated level while its output is high; AOUT
// is bits 11-4 of the sum of the four, registered. The chip sums the
// four in its output amplifier [p.3].
//========================================================================
wire [9:0] vol0 = tone_out[0] ? attn_vol(ch_attn0) : 10'd0;
wire [9:0] vol1 = tone_out[1] ? attn_vol(ch_attn1) : 10'd0;
wire [9:0] vol2 = tone_out[2] ? attn_vol(ch_attn2) : 10'd0;
wire [9:0] vol3 = noise_out ? attn_vol(ch_attn3) : 10'd0;

wire [11:0] master_sum = vol0 + vol1 + vol2 + vol3;

always @(posedge CLK) begin
    if(rst) AOUT <= 8'd0;
    else AOUT <= master_sum[11:4];
end

endmodule
