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
//  General Instrument AY-3-8910 programmable sound generator: three tone
//  generators, a noise generator, a mixer, an envelope generator and three
//  D/A converters, set through sixteen registers [p.7-11]. The tone
//  generators (x8910_tone), the noise generator (x8910_noise) and the
//  envelope generator (x8910_envelope) are instantiated internally.
//
//  Clocking:
//    CEN is one pulse per input clock (CLOCK). A /8 prescaler gives
//    pre_cen, which steps the tone, noise and envelope period counters
//    (AY-3-8910 die schematic); with the /2 of each counter output, a tone
//    is f = f_CLOCK / (16 TP) [p.18]. CLK is the system clock.
//
//  Pins:
//    - A0: register address (0) or data (1), in place of the BDIR, BC2
//      and BC1 bus control decode [p.15-17]
//    - WRn: write, active low; each CLK it is low writes DIN to the
//      address latch (A0 = 0) or to the latched register (A0 = 1)
//    - RDn: read, active low; with A0 = 0 DOUT is the latched register,
//      otherwise $FF
//    - DIN, DOUT: DA0-DA7 split into input and output
//    - IOA_IN, IOB_IN: the I/O port pin levels; IOA_OUT, IOB_OUT: R14 and
//      R15; IOA_OE, IOB_OE: R7 bits 6 and 7, output mode [p.10], [p.28]
//    - RESETn: RESET, active low [p.13]
//    - AOUT_A, AOUT_B, AOUT_C: the three D/A outputs, 10 bits each [p.34]
//    - AOUT: their sum, 12 bits unsigned
//
//  Chip Select:
//    An address write loads the address latch only when DIN[7:4] is 0000,
//    the chip's address; any other value deselects the chip and keeps the
//    address. A deselected chip ignores data writes and reads $FF; reset
//    deselects it (AY-3-8910 die schematic). A8 and /A9 are not modeled:
//    the board's decode drives WRn and RDn.
//
//  Registers:
//    R0-R5 tone periods, R6 noise period, R7 mixer and I/O enable, R8-R10
//    amplitudes, R11-R12 envelope period, R13 envelope shape, R14-R15 I/O
//    port data (Figure 2 [p.8]). Registers are numbered in decimal here;
//    GI numbers them in octal (R0-R17). RESETn clears every register
//    [p.13]. A write to R13 restarts the envelope [p.25].
//
//  I/O Ports:
//    A port reads its pins, IOx_IN, in either mode. In output mode
//    (IOx_OE = 1) a pin is pulled low where its IOx_OUT bit is 0 and is
//    released where it is 1; the board pulls it up (AY-3-8910 die
//    schematic). In input mode every pin is released.
//
//  Audio Output:
//    Each channel is its D/A level while the mixer output is high and 0
//    while it is low. AOUT_A, AOUT_B and AOUT_C are the three levels and
//    AOUT is their sum, all registered.
//
//  Reference: AY-3-8910/8912 Programmable Sound Generator Data Manual,
//             Basic Functional Blocks [p.7-11], Pin Functions [p.13], Bus
//             Timing [p.15], State Timing [p.16-17], Tone Generator
//             Control [p.18], Noise Generator Control [p.20], Mixer
//             Control [p.21], Amplitude Control [p.22], Envelope Generator
//             Control [p.24-25], I/O Port Data Store [p.28], D/A
//             Converter Operation [p.29], Audio Output Interface [p.34].
//             AY-3-8910 die schematic.
//============================================================================

`timescale 1ns/1ps

module x8910 (
    // Clock and Reset
    input  wire        CLK,
    input  wire        RESETn,
    input  wire        CEN,

    // Control Interface
    input  wire  [7:0] DIN,
    output reg   [7:0] DOUT,
    input  wire        RDn,
    input  wire        WRn,
    input  wire        A0,

    // I/O Ports
    input  wire  [7:0] IOA_IN,
    output wire  [7:0] IOA_OUT,
    output wire        IOA_OE,
    input  wire  [7:0] IOB_IN,
    output wire  [7:0] IOB_OUT,
    output wire        IOB_OE,

    // Audio Output
    output reg   [9:0] AOUT_A,
    output reg   [9:0] AOUT_B,
    output reg   [9:0] AOUT_C,
    output reg  [11:0] AOUT
);

wire rst = ~RESETn;
wire wr  = ~WRn;

//========================================================================
// D/A Converter:
// Ideal 3 dB steps, 1023 x (1 / sqrt(2))^(15 - level) rounded down, level
// 0 OFF. The die gives no device sizes for the real levels; the measured
// curve of Figure 9 [p.29] differs from these at levels 12 and 10.
//========================================================================
function [9:0] dac_vol;
    input [3:0] level;
    case(level)
        4'd15 : dac_vol = 10'd1023; // 0 dB
        4'd14 : dac_vol = 10'd723;  // -3 dB
        4'd13 : dac_vol = 10'd512;  // -6 dB
        4'd12 : dac_vol = 10'd362;  // -9 dB
        4'd11 : dac_vol = 10'd256;  // -12 dB
        4'd10 : dac_vol = 10'd181;  // -15 dB
        4'd9  : dac_vol = 10'd128;  // -18 dB
        4'd8  : dac_vol = 10'd91;   // -21 dB
        4'd7  : dac_vol = 10'd64;   // -24 dB
        4'd6  : dac_vol = 10'd45;   // -27 dB
        4'd5  : dac_vol = 10'd32;   // -30 dB
        4'd4  : dac_vol = 10'd23;   // -33 dB
        4'd3  : dac_vol = 10'd16;   // -36 dB
        4'd2  : dac_vol = 10'd11;   // -39 dB
        4'd1  : dac_vol = 10'd8;    // -42 dB
        4'd0  : dac_vol = 10'd0;    // OFF
    endcase
endfunction

//========================================================================
// Prescaler:
// pre_cen is one CEN pulse in 8 (AY-3-8910 die schematic).
//========================================================================
reg [2:0] pre_cnt;

wire pre_cen = CEN & (pre_cnt == 3'd0);

always @(posedge CLK) begin
    if(rst) pre_cnt <= 3'd0;
    else if(CEN) pre_cnt <= pre_cnt + 3'd1;
end

//========================================================================
// Registers:
// A write with A0 = 0 loads the address latch from DIN[3:0] and selects
// the chip when DIN[7:4] is 0000, or deselects it; a write with A0 = 1
// loads the latched register of a selected chip [p.15-17].
//========================================================================
reg [3:0] latch_reg;
reg [7:0] regfile [0:15];
reg       selected;
reg       restart_env;

integer r;

always @(posedge CLK) begin
    if(rst) begin
        latch_reg <= 4'd0;
        for(r = 0; r < 16; r = r + 1) regfile[r] <= 8'h00;
        selected <= 1'b0;
        restart_env <= 1'b0;
    end else begin
        restart_env <= 1'b0;
        if(wr) begin
            if(!A0) begin
                if(DIN[7:4] == 4'd0) begin
                    latch_reg <= DIN[3:0];
                    selected <= 1'b1;
                end else begin
                    selected <= 1'b0;
                end
            end else if(selected) begin
                regfile[latch_reg] <= DIN;
                if(latch_reg == 4'd13) restart_env <= 1'b1;
            end
        end
    end
end

//========================================================================
// Register Read:
// RDn low with A0 = 0 reads the latched register of a selected chip, its
// unused bits as 0 (Figure 2 [p.8]) and R14, R15 as the port pins;
// otherwise DOUT is $FF.
//========================================================================
always @(*) begin
    if(!RDn && !A0 && selected) begin
        case(latch_reg)
            4'd1, 4'd3, 4'd5 : DOUT = {4'd0, regfile[latch_reg][3:0]};
            4'd6 : DOUT = {3'd0, regfile[6][4:0]};
            4'd8, 4'd9, 4'd10 : DOUT = {3'd0, regfile[latch_reg][4:0]};
            4'd13 : DOUT = {4'd0, regfile[13][3:0]};
            4'd14 : DOUT = IOA_IN;
            4'd15 : DOUT = IOB_IN;
            default : DOUT = regfile[latch_reg];
        endcase
    end else begin
        DOUT = 8'hFF;
    end
end

//========================================================================
// I/O Ports:
// R7 bit 6 sets port A to output mode, bit 7 port B [p.28].
//========================================================================
assign IOA_OUT = regfile[14];
assign IOA_OE  = regfile[7][6];
assign IOB_OUT = regfile[15];
assign IOB_OE  = regfile[7][7];

//========================================================================
// Register Fields:
//========================================================================
wire [11:0] tone_period_a = {regfile[1][3:0], regfile[0]};
wire [11:0] tone_period_b = {regfile[3][3:0], regfile[2]};
wire [11:0] tone_period_c = {regfile[5][3:0], regfile[4]};
wire  [4:0] noise_period  = regfile[6][4:0];

wire tone_off_a  = regfile[7][0];
wire tone_off_b  = regfile[7][1];
wire tone_off_c  = regfile[7][2];
wire noise_off_a = regfile[7][3];
wire noise_off_b = regfile[7][4];
wire noise_off_c = regfile[7][5];

wire [15:0] env_period = {regfile[12], regfile[11]};

//========================================================================
// Tone Generators:
// Channels A, B and C [p.18].
//========================================================================
wire tone_a;
wire tone_b;
wire tone_c;

x8910_tone #(
    .PERIOD_BITS ( 12 )
) u_tone_a (
    // Clock and Reset
    .clk     ( CLK           ),
    .rst     ( rst           ),
    .pre_cen ( pre_cen       ),

    // Tone Interface
    .period  ( tone_period_a ),
    .out     ( tone_a        )
);

x8910_tone #(
    .PERIOD_BITS ( 12 )
) u_tone_b (
    // Clock and Reset
    .clk     ( CLK           ),
    .rst     ( rst           ),
    .pre_cen ( pre_cen       ),

    // Tone Interface
    .period  ( tone_period_b ),
    .out     ( tone_b        )
);

x8910_tone #(
    .PERIOD_BITS ( 12 )
) u_tone_c (
    // Clock and Reset
    .clk     ( CLK           ),
    .rst     ( rst           ),
    .pre_cen ( pre_cen       ),

    // Tone Interface
    .period  ( tone_period_c ),
    .out     ( tone_c        )
);

//========================================================================
// Noise Generator:
// One noise source for all three channels [p.20].
//========================================================================
wire noise_out;

x8910_noise u_noise (
    // Clock and Reset
    .clk     ( CLK          ),
    .rst     ( rst          ),
    .pre_cen ( pre_cen      ),

    // Noise Interface
    .period  ( noise_period ),
    .out     ( noise_out    )
);

//========================================================================
// Envelope Generator:
// R13 sets the shape and a write to it restarts the envelope [p.24-25].
//========================================================================
wire [3:0] envelope;

x8910_envelope u_envelope (
    // Clock and Reset
    .clk     ( CLK               ),
    .rst     ( rst               ),
    .pre_cen ( pre_cen           ),

    // Envelope Interface
    .restart ( restart_env       ),
    .period  ( env_period        ),
    .shape   ( regfile[13][3:0]  ),
    .out     ( envelope          )
);

//========================================================================
// Mixer:
// A channel is high while its tone, or a tone turned off, and the noise,
// or a noise turned off, are high; with both off it stays high [p.21].
//========================================================================
wire mix_a = (tone_a | tone_off_a) & (noise_out | noise_off_a);
wire mix_b = (tone_b | tone_off_b) & (noise_out | noise_off_b);
wire mix_c = (tone_c | tone_off_c) & (noise_out | noise_off_c);

//========================================================================
// Amplitude:
// M = 1 takes the envelope, M = 0 the fixed level L3-L0 [p.22].
//========================================================================
wire [3:0] level_a = regfile[8][4] ? envelope : regfile[8][3:0];
wire [3:0] level_b = regfile[9][4] ? envelope : regfile[9][3:0];
wire [3:0] level_c = regfile[10][4] ? envelope : regfile[10][3:0];

//========================================================================
// Audio Output:
// Each channel is its D/A level while its mixer output is high; AOUT is
// the sum of the three, registered with them [p.34].
//========================================================================
wire [9:0] vol_a = mix_a ? dac_vol(level_a) : 10'd0;
wire [9:0] vol_b = mix_b ? dac_vol(level_b) : 10'd0;
wire [9:0] vol_c = mix_c ? dac_vol(level_c) : 10'd0;

always @(posedge CLK) begin
    if(rst) begin
        AOUT_A <= 10'd0;
        AOUT_B <= 10'd0;
        AOUT_C <= 10'd0;
        AOUT <= 12'd0;
    end else begin
        AOUT_A <= vol_a;
        AOUT_B <= vol_b;
        AOUT_C <= vol_c;
        AOUT <= vol_a + vol_b + vol_c;
    end
end

endmodule
