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
//  four attenuators, summed into one audio output [p.1-3]. The tone
//  generators (x76489_tone) and the noise generator (x76489_noise) are
//  instantiated internally.
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
//    - RESETn: the chip has no reset pin [p.6]; RESETn sets each tone
//      register to 1, each attenuation to OFF and the noise control to
//      white noise at N/512
//    - AOUT: AUDIO OUT, the four channels summed, 8 bits unsigned
//
//  Write Timing:
//    A byte is taken on a CLK with CEN high while CSn and WRn are both
//    low. The chip takes about 32 clocks to load a byte and holds READY
//    low meanwhile [p.5]; here the byte is loaded at once and READY is not
//    provided.
//
//  Registers:
//    A latch byte (D0 = 1) selects one of eight registers by R0-R2 and
//    loads its low bits; a data byte (D0 = 0) loads F0-F5 of a latched
//    tone frequency or A0-A3 of a latched attenuation, so a frequency can
//    be swept with data bytes alone [p.3-4].
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
//    (Tables 2 and 3 [p.3]). A latch byte to the noise control register
//    reseeds it [p.3].
//
//  Audio Output:
//    Each channel is its attenuated level while its output is high and 0
//    while it is low. AOUT is bits 11-4 of the sum of the four levels,
//    registered; one channel at 0 dB gives 63. On the chip each channel
//    drives a current into the output amplifier, so there silence is a DC
//    level [p.3], [p.8]; here it is 0.
//
//  The data sheet gives the formats, the rates and the attenuation weights:
//  n = 0, data bytes to an attenuation, the shift register taps, its seed
//  and the periodic mode come from the die (TI SN76489AN die schematic,
//  TONE, NOISE and DATA WRITE CONTROL).
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Features [p.1], Operation [p.2-5], Pin Assignment [p.6],
//             Electrical Characteristics [p.7], External Audio Output
//             Interface [p.8], Switching Characteristics [p.9], Block
//             Diagram [p.10], Figure 4 [p.11].
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
// Control Registers:
// A latch byte (DIN[7] = 1) loads latch_reg from R0-R2 and the low bits
// of the register it selects; a data byte loads F0-F5 of a latched tone
// frequency (Data Formats [p.4]) or A0-A3 of a latched attenuation, which
// the data sheet does not show: on the die every byte strobes the latched
// register (TI SN76489AN die schematic, DATA WRITE CONTROL). Register
// select (Table 4 [p.4]):
//   000 tone 1 frequency    001 tone 1 attenuation
//   010 tone 2 frequency    011 tone 2 attenuation
//   100 tone 3 frequency    101 tone 3 attenuation
//   110 noise control       111 noise attenuation
// tone_freq holds F0-F9, F9 in bit 0, and noise_ctrl {FB, NF0, NF1}. A
// latch byte to the noise control register raises restart_noise for one
// CLK.
//========================================================================
reg [2:0] latch_reg;
reg [9:0] tone_freq [0:2];
reg [3:0] ch_attn [0:3];
reg [2:0] noise_ctrl;
reg       restart_noise;

always @(posedge CLK) begin
    if(rst) begin
        latch_reg <= 3'd0;
        tone_freq[0] <= 10'd1;
        tone_freq[1] <= 10'd1;
        tone_freq[2] <= 10'd1;
        ch_attn[0] <= 4'hF;
        ch_attn[1] <= 4'hF;
        ch_attn[2] <= 4'hF;
        ch_attn[3] <= 4'hF;
        noise_ctrl <= 3'b100;
        restart_noise <= 1'b0;
    end else begin
        restart_noise <= 1'b0;
        if(CEN && !CSn && !WRn) begin
            if(DIN[7]) begin
                latch_reg <= DIN[6:4];
                case(DIN[6:4])
                    3'b000 : tone_freq[0][3:0] <= DIN[3:0];
                    3'b001 : ch_attn[0] <= DIN[3:0];
                    3'b010 : tone_freq[1][3:0] <= DIN[3:0];
                    3'b011 : ch_attn[1] <= DIN[3:0];
                    3'b100 : tone_freq[2][3:0] <= DIN[3:0];
                    3'b101 : ch_attn[2] <= DIN[3:0];
                    3'b110 : begin
                        noise_ctrl <= DIN[2:0];
                        restart_noise <= 1'b1;
                    end
                    3'b111 : ch_attn[3] <= DIN[3:0];
                endcase
            end else begin
                case(latch_reg)
                    3'b000 : tone_freq[0][9:4] <= DIN[5:0];
                    3'b001 : ch_attn[0] <= DIN[3:0];
                    3'b010 : tone_freq[1][9:4] <= DIN[5:0];
                    3'b011 : ch_attn[1] <= DIN[3:0];
                    3'b100 : tone_freq[2][9:4] <= DIN[5:0];
                    3'b101 : ch_attn[2] <= DIN[3:0];
                    3'b111 : ch_attn[3] <= DIN[3:0];
                    default : ;
                endcase
            end
        end
    end
end

//========================================================================
// Tone Generators:
// Tone 1-3 from tone_freq [p.2].
//========================================================================
wire tone_out [0:2];

x76489_tone u_tone0 (
    // Clock and Reset
    .clk     ( CLK          ),
    .rst     ( rst          ),
    .pre_cen ( pre_cen      ),

    // Tone Interface
    .period  ( tone_freq[0] ),
    .out     ( tone_out[0]  )
);

x76489_tone u_tone1 (
    // Clock and Reset
    .clk     ( CLK          ),
    .rst     ( rst          ),
    .pre_cen ( pre_cen      ),

    // Tone Interface
    .period  ( tone_freq[1] ),
    .out     ( tone_out[1]  )
);

x76489_tone u_tone2 (
    // Clock and Reset
    .clk     ( CLK          ),
    .rst     ( rst          ),
    .pre_cen ( pre_cen      ),

    // Tone Interface
    .period  ( tone_freq[2] ),
    .out     ( tone_out[2]  )
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
wire [9:0] vol0 = tone_out[0] ? attn_vol(ch_attn[0]) : 10'd0;
wire [9:0] vol1 = tone_out[1] ? attn_vol(ch_attn[1]) : 10'd0;
wire [9:0] vol2 = tone_out[2] ? attn_vol(ch_attn[2]) : 10'd0;
wire [9:0] vol3 = noise_out ? attn_vol(ch_attn[3]) : 10'd0;

wire [11:0] master_sum = vol0 + vol1 + vol2 + vol3;

always @(posedge CLK) begin
    if(rst) AOUT <= 8'd0;
    else AOUT <= master_sum[11:4];
end

endmodule
