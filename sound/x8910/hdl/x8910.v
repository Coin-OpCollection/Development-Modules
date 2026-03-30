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
//  Fully synchronous implementation of the General Instrument AY-3-8910
//  Programmable Sound Generator with register file, mixer, and D/A output.
//
//  The design integrates all functional blocks found in the original device:
//  three tone generators, noise generator, envelope generator, mixer, and
//  D/A converters connected via an internal register bus.
//
//  Reference: GI AY-3-8910/8912 Datasheet (8 pages)
//             GI AY-3-8910/8912 PSG Data Manual (62 pages, Feb 1979)
//             lvd Reverse Engineered AY-3-8910 Schematic (2019)
//
//  Submodules:
//    x8910_tone     - 12-bit period square wave tone generator. Three
//                     instances produce channels A, B, and C.
//
//    x8910_noise    - 5-bit period counter driving a 17-bit LFSR for
//                     pseudo-random noise generation.
//
//    x8910_envelope - 16-bit period envelope generator with 4-bit
//                     amplitude counter and 10 shape configurations.
//
//    x8910_edge     - Single-cycle rising edge detector utility.
//============================================================================

module x8910 (
    input  wire       clk,   // System clock
    input  wire       cen,   // Clock enable at PSG input rate
    input  wire       reset, // Reset
    input  wire       a0,    // Address/data select (0=address, 1=data)
    input  wire       wr,    // Write enable
    input  wire       rd,    // Read enable
    input  wire [7:0] din,   // Data bus input
    output reg  [7:0] dout,  // Data bus output (register read)
    output reg  [7:0] sndout // Mixed audio output (unsigned 8-bit)
);

//=========================================================================
// D/A Converter Logarithmic Volume Lookup
//=========================================================================
// Reference GI Data Manual, Section 3.7 - D/A Converter Operation:
//   - Logarithmic steps, normalized voltage 0 to 1V
//   - Each step is 1/sqrt(2) of the previous (~3.01 dB per step)
//   - Diagram Fig. 9 shows measured levels from silicon
//   - Level 0 = OFF (silence)
//   - Level 15 = maximum output (1.0V normalized)
//
// Pre-computed: floor(1023 * (1/sqrt(2))^(15-N)) for 10-bit resolution
// Idealized sqrt(2) curve; Fig. 9 silicon measurements differ slightly
//=========================================================================
function [9:0] dac_vol;
    input [3:0] level;
    case(level)
        4'd15: dac_vol = 10'd1023; // 1.000V  (full volume)
        4'd14: dac_vol = 10'd723;  // 0.707V  (-3 dB)
        4'd13: dac_vol = 10'd512;  // 0.500V  (-6 dB)
        4'd12: dac_vol = 10'd362;  // 0.354V  (-9 dB)
        4'd11: dac_vol = 10'd256;  // 0.250V  (-12 dB)
        4'd10: dac_vol = 10'd181;  // 0.177V  (-15 dB)
        4'd9:  dac_vol = 10'd128;  // 0.125V  (-18 dB)
        4'd8:  dac_vol = 10'd91;   // 0.089V  (-21 dB)
        4'd7:  dac_vol = 10'd64;   // 0.063V  (-24 dB)
        4'd6:  dac_vol = 10'd45;   // 0.044V  (-27 dB)
        4'd5:  dac_vol = 10'd32;   // 0.031V  (-30 dB)
        4'd4:  dac_vol = 10'd23;   // 0.022V  (-33 dB)
        4'd3:  dac_vol = 10'd16;   // 0.016V  (-36 dB)
        4'd2:  dac_vol = 10'd11;   // 0.011V  (-39 dB)
        4'd1:  dac_vol = 10'd8;    // 0.008V  (-42 dB)
        4'd0:  dac_vol = 10'd0;    //  OFF
    endcase
endfunction

//=========================================================================
// Master Clock Divider (/8)
//=========================================================================
// Reference GI Data Manual Section 3.1, lvd RE schematic:
//   - AY-3-8910 divides input clock by 8 for tone/noise/envelope base
//   - (YM2149 variant divides by 16 instead)
//   - All generators share this single divided clock enable
//   - Additional /2 in tone/noise from toggle, /2x16 in envelope
//=========================================================================
reg [2:0] clk_div;
wire master_en = (clk_div == 3'd0) & cen;

always @(posedge clk) begin
    if(reset)
        clk_div <= 3'd0;
    else if(cen)
        clk_div <= clk_div + 3'd1;
end

//=========================================================================
// Register File and Bus Interface
//=========================================================================
// Reference GI Datasheet, Architecture section:
//   - 16 registers addressed via 4-bit latch
//   - Bus protocol: BDIR/BC1 decode (simplified to a0/wr/rd here)
//     a0=0, wr: Latch register address from din[3:0]
//     a0=1, wr: Write din to latched register
//     a0=0, rd: Read data from latched register
//     a0=1, rd: Read latched address
//
// Reference GI Data Manual, Section 3 - Operation:
//   R0,R1:   Channel A Tone Period (12-bit: R1[3:0],R0[7:0])
//   R2,R3:   Channel B Tone Period (12-bit: R3[3:0],R2[7:0])
//   R4,R5:   Channel C Tone Period (12-bit: R5[3:0],R4[7:0])
//   R6:      Noise Period (5-bit: R6[4:0])
//   R7:      Mixer Control / I/O Enable
//             [5:3] = Noise enable (inverted): C,B,A
//             [2:0] = Tone enable (inverted): C,B,A
//             [7:6] = I/O port direction (not implemented)
//   R8:      Channel A Amplitude: {M, L3-L0}
//   R9:      Channel B Amplitude: {M, L3-L0}
//   R10:     Channel C Amplitude: {M, L3-L0}
//   R11,R12: Envelope Period (16-bit: R12[7:0],R11[7:0])
//   R13:     Envelope Shape/Cycle: {Continue, Attack, Alternate, Hold}
//   R14:     I/O Port A Data (not implemented)
//   R15:     I/O Port B Data (not implemented)
//=========================================================================
reg [3:0]  latched_reg;
reg [7:0]  regfile [0:15];
reg        restart_envelope;

always @(posedge clk) begin
    if(reset) begin
        latched_reg <= 4'd0;
        regfile[0]  <= 8'd0;
        regfile[1]  <= 8'd0;
        regfile[2]  <= 8'd0;
        regfile[3]  <= 8'd0;
        regfile[4]  <= 8'd0;
        regfile[5]  <= 8'd0;
        regfile[6]  <= 8'd0;
        regfile[7]  <= 8'hff; // All channels disabled at reset
        regfile[8]  <= 8'd0;
        regfile[9]  <= 8'd0;
        regfile[10] <= 8'd0;
        regfile[11] <= 8'd0;
        regfile[12] <= 8'd0;
        regfile[13] <= 8'd0;
        regfile[14] <= 8'd0;
        regfile[15] <= 8'd0;
        restart_envelope <= 1'b0;
    end else begin
        restart_envelope <= 1'b0;
        if(wr) begin
            if(!a0) begin
                // Latch register address
                latched_reg <= din[3:0];
            end else begin
                // Write data to latched register
                regfile[latched_reg] <= din;
                // Writing R13 always restarts the envelope generator
                // (Data Manual Section 3.5, datasheet: envelope restarts on write)
                if(latched_reg == 4'd13)
                    restart_envelope <= 1'b1;
            end
        end
    end
end

//=========================================================================
// Register Read
//=========================================================================
// Reference GI Datasheet, Bus Control Decode:
//   a0=0: Read data from currently latched register
//   a0=1: Read latched register address
// Register read masks per datasheet (unused bits read as 0):
//   R1,R3,R5: [7:4] unused    R6: [7:5] unused
//   R8-R10:   [7:5] unused    R13: [7:4] unused
//=========================================================================
always @(*) begin
    if(!a0) begin
        case(latched_reg)
            4'd1,4'd3,4'd5:  dout = {4'd0, regfile[latched_reg][3:0]};
            4'd6:            dout = {3'd0, regfile[6][4:0]};
            4'd8,4'd9,4'd10: dout = {3'd0, regfile[latched_reg][4:0]};
            4'd13:           dout = {4'd0, regfile[13][3:0]};
            default: dout = regfile[latched_reg];
        endcase
    end else begin
        dout = {4'd0, latched_reg};
    end
end

//=========================================================================
// Decode Register Fields
//=========================================================================
wire [11:0] tone_period_A = {regfile[1][3:0], regfile[0]};
wire [11:0] tone_period_B = {regfile[3][3:0], regfile[2]};
wire [11:0] tone_period_C = {regfile[5][3:0], regfile[4]};
wire  [4:0] noise_period  = regfile[6][4:0];

wire tone_dis_A  = regfile[7][0]; // Tone disable (active high = disabled)
wire tone_dis_B  = regfile[7][1];
wire tone_dis_C  = regfile[7][2];
wire noise_dis_A = regfile[7][3]; // Noise disable (active high = disabled)
wire noise_dis_B = regfile[7][4];
wire noise_dis_C = regfile[7][5];

wire       env_en_A = regfile[8][4];    // M bit: 1=envelope, 0=fixed
wire [3:0] amp_A    = regfile[8][3:0];  // Fixed amplitude level
wire       env_en_B = regfile[9][4];
wire [3:0] amp_B    = regfile[9][3:0];
wire       env_en_C = regfile[10][4];
wire [3:0] amp_C    = regfile[10][3:0];

wire [15:0] env_period    = {regfile[12], regfile[11]};
wire        env_continue  = regfile[13][3];
wire        env_attack    = regfile[13][2];
wire        env_alternate = regfile[13][1];
wire        env_hold      = regfile[13][0];

//=========================================================================
// Tone Generators (3 channels)
//=========================================================================
// Reference GI Data Manual, Section 3.1:
//   - 12-bit period counter, counts UP at master_en rate
//   - Counter resets to 1 and toggles output when counter >= period
//   - Output frequency: f_T = f_clock / (16 * TP)
//   - Period 0 and 1 produce the same frequency (divide by 1)
//   - Confirmed by lvd RE: counters count UP with first FF reset to 1
//=========================================================================
wire tone_A, tone_B, tone_C;

x8910_tone #(.PERIOD_BITS(12)) u_tone_A (
    .clk    ( clk           ),
    .enable ( master_en     ),
    .reset  ( reset         ),
    .period ( tone_period_A ),
    .out    ( tone_A        )
);

x8910_tone #(.PERIOD_BITS(12)) u_tone_B (
    .clk    ( clk           ),
    .enable ( master_en     ),
    .reset  ( reset         ),
    .period ( tone_period_B ),
    .out    ( tone_B        )
);

x8910_tone #(.PERIOD_BITS(12)) u_tone_C (
    .clk    ( clk           ),
    .enable ( master_en     ),
    .reset  ( reset         ),
    .period ( tone_period_C ),
    .out    ( tone_C        )
);

//=========================================================================
// Noise Generator
//=========================================================================
// Reference GI Data Manual, Section 3.2:
//   - 5-bit period counter (same structure as tone generator)
//   - 17-bit LFSR with taps at bits 0 and 3 (per lvd RE)
//   - LFSR shifts on rising edge of period counter toggle
//   - LFSR includes zero-detect: feedback = (tap0 XOR tap1) OR lfsr_is_zero
//   - Output: inverted lfsr[0]
//   - Noise frequency: f_N = f_clock / (16 * NP)
//=========================================================================
wire noise_out;

x8910_noise u_noise (
    .clk    ( clk          ),
    .enable ( master_en    ),
    .reset  ( reset        ),
    .period ( noise_period ),
    .out    ( noise_out    )
);

//=========================================================================
// Envelope Generator
//=========================================================================
// Reference GI Data Manual, Section 3.5 and Datasheet Fig. 1:
//   - 16-bit period counter (same structure as tone)
//   - 4-bit envelope counter (E3-E0), 16 steps per cycle
//   - Steps on rising edge of period counter toggle
//   - Envelope frequency: f_E = f_clock / (256 * EP)
//   - Shape controlled by R13 bits: Continue, Attack, Alternate, Hold
//   - Writing R13 always restarts the envelope
//
//   Envelope shapes (Datasheet Fig. 1, Data Manual Fig. 7):
//     Continue Attack Alternate Hold
//        0       0      x       x    \___  (decay, hold at 0)
//        0       1      x       x    /___  (attack, hold at 0)
//        1       0      0       0    \\\\  (repeating decay)
//        1       0      0       1    \___  (single decay, hold at 0)
//        1       0      1       0    \/\/  (decay-attack alternating)
//        1       0      1       1    \‾‾‾  (single decay, hold at max)
//        1       1      0       0    ////  (repeating attack)
//        1       1      0       1    /‾‾‾  (single attack, hold at max)
//        1       1      1       0    /\/\  (attack-decay alternating)
//        1       1      1       1    /___  (single attack, hold at 0)
//=========================================================================
wire [3:0] envelope;

x8910_envelope u_envelope (
    .clk       ( clk              ),
    .enable    ( master_en        ),
    .reset     ( reset            ),
    .restart   ( restart_envelope ),
    .period    ( env_period       ),
    .continue_ ( env_continue     ),
    .attack    ( env_attack       ),
    .alternate ( env_alternate    ),
    .hold      ( env_hold         ),
    .out       ( envelope         )
);

//=========================================================================
// Mixer (3 channels)
//=========================================================================
// Reference GI Datasheet and Data Manual Section 3.3:
//   - Each channel: (ToneOn | ToneDisable) & (NoiseOn | NoiseDisable)
//   - When both tone and noise are disabled, output is HIGH (always 1)
//   - This allows direct amplitude modulation for PCM/DAC effects
//   - The R7 disable bits are active high (1 = source disabled/bypassed)
//=========================================================================
wire mix_A = (tone_A | tone_dis_A) & (noise_out | noise_dis_A);
wire mix_B = (tone_B | tone_dis_B) & (noise_out | noise_dis_B);
wire mix_C = (tone_C | tone_dis_C) & (noise_out | noise_dis_C);

//=========================================================================
// Channel Volume (mixer-gated amplitude through D/A lookup)
//=========================================================================
// Reference GI Data Manual, Section 3.4 and 3.7:
//   - Amplitude source: fixed (L3-L0) when M=0, envelope (E3-E0) when M=1
//   - D/A converter applies logarithmic curve to 4-bit amplitude
//   - Mixer output gates the channel: 1=output at amplitude, 0=silence
//=========================================================================
wire [3:0] level_A = env_en_A ? envelope : amp_A;
wire [3:0] level_B = env_en_B ? envelope : amp_B;
wire [3:0] level_C = env_en_C ? envelope : amp_C;

wire [9:0] vol_A = mix_A ? dac_vol(level_A) : 10'd0;
wire [9:0] vol_B = mix_B ? dac_vol(level_B) : 10'd0;
wire [9:0] vol_C = mix_C ? dac_vol(level_C) : 10'd0;

//=========================================================================
// Master Output
//=========================================================================
// Reference GI Datasheet, Section 3.7 (Fig. 9, 10-13):
//   - Three analog channels summed to produce final output
//   - Max sum: 3 * 1023 = 3069 (12 bits), top 8 bits -> unsigned 8-bit
//=========================================================================
wire [11:0] master_sum = vol_A + vol_B + vol_C;

always @(posedge clk) begin
    if(reset)
        sndout <= 8'd0;
    else
        sndout <= master_sum[11:4];
end

endmodule
