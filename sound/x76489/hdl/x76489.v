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
//  Fully synchronous implementation of the Texas Instruments SN76489AN
//  Complex Sound Generator with register file, attenuators, and output.
//
//  The design integrates all functional blocks found in the original device:
//  three tone generators, noise generator, four attenuators, and output
//  summing connected via an internal register bus.
//
//  Reference: TI SN76489AN Datasheet (9 pages)
//             SN76489 Reverse Engineered Schematic (emu-russia, 2023)
//
//  Submodules:
//    x76489_tone  - 10-bit period down counter with toggle flip-flop.
//                   Three instances produce channels 1, 2, and 3.
//
//    x76489_noise - 15-bit LFSR with configurable feedback taps and
//                   selectable shift rate (N/512, N/1024, N/2048, or
//                   driven by tone channel 3).
//
//    x76489_edge  - Single-cycle rising edge detector utility.
//============================================================================

module x76489 (
    input wire       clk,   // System clock
    input wire       cen,   // Clock enable (typ 3.579MHz PSG master rate)
    input wire       reset, // Reset
    input wire       ce,    // Chip enable
    input wire       we,    // Write enable
    input wire [7:0] data,  // Data bus (D0=MSB per TI convention, active high)
    output reg [7:0] sndout // Mixed audio output (unsigned 8-bit)
);

//=========================================================================
// Attenuation Lookup
//=========================================================================
// Reference TI SN76489AN datasheet, Table 1 - Attenuation Control:
//   - 4 control bits (A0-A3) with weights: A3=2dB, A2=4dB, A1=8dB, A0=16dB
//   - Multiple bits may be set simultaneously, max attenuation = 28dB
//   - All bits set (1111) = OFF (silence)
//   - Measured accuracy per datasheet page 6: 2dB step typ ±1dB
//
// Pre-computed: floor(1023 * 10^(-0.1 * step)) for 10-bit resolution
// Each step = -2dB voltage attenuation (10^(-0.1) ratio per step)
//=========================================================================
function [9:0] attn_vol;
    input [3:0] ctrl;
    case(ctrl)
        4'd0:  attn_vol = 10'd1023; //   0 dB  (full volume)
        4'd1:  attn_vol = 10'd812;  //  -2 dB
        4'd2:  attn_vol = 10'd645;  //  -4 dB
        4'd3:  attn_vol = 10'd512;  //  -6 dB
        4'd4:  attn_vol = 10'd407;  //  -8 dB
        4'd5:  attn_vol = 10'd323;  // -10 dB
        4'd6:  attn_vol = 10'd256;  // -12 dB
        4'd7:  attn_vol = 10'd204;  // -14 dB
        4'd8:  attn_vol = 10'd162;  // -16 dB
        4'd9:  attn_vol = 10'd128;  // -18 dB
        4'd10: attn_vol = 10'd102;  // -20 dB
        4'd11: attn_vol = 10'd81;   // -22 dB
        4'd12: attn_vol = 10'd64;   // -24 dB
        4'd13: attn_vol = 10'd51;   // -26 dB
        4'd14: attn_vol = 10'd40;   // -28 dB  (max attenuation)
        4'd15: attn_vol = 10'd0;    //  OFF
    endcase
endfunction

//=========================================================================
// Clock Divider (/16)
//=========================================================================
// Reference TI SN76489AN datasheet, Figure 4 (schelogic):
//   - REF CLOCK (pin 14) feeds a /16 prescaler
//   - Prescaler output clocks all 3 tone counters and noise shift rate
//   - SN76494N variant uses /2 instead of /16
//=========================================================================
reg [3:0] clk_counter;
wire tone_en = (clk_counter == 4'd0) & cen;

always @(posedge clk) begin
    if(reset)
        clk_counter <= 4'd0;
    else if(cen)
        clk_counter <= clk_counter + 4'd1;
end

//=========================================================================
// Control Registers
//=========================================================================
// Reference TI SN76489AN datasheet, Section 5 and Table 4:
//   - 8 internal registers addressed by 3-bit field (R0,R1,R2)
//   - First byte always has bit[7]=1 (latch byte), updates address latch
//   - Second byte has bit[7]=0 (data byte), writes to latched register
//
// Register Address Field (Table 4):
//   000 = Tone 1 Frequency      001 = Tone 1 Attenuation
//   010 = Tone 2 Frequency      011 = Tone 2 Attenuation
//   100 = Tone 3 Frequency      101 = Tone 3 Attenuation
//   110 = Noise Control         111 = Noise Attenuation
//
// Data Formats (Section 6):
//   Frequency (double byte): First  [1|R0 R1 R2|F6 F7 F8 F9]
//                            Second [0| x|F0 F1 F2 F3 F4 F5]
//   Noise control:           [1|1 1 0| x|FB|NF0 NF1]
//   Attenuation:             [1|R0 R1 R2|A0 A1 A2 A3]
//
// CPU Interface (Section 4):
//   - Frequency update requires double byte transfer
//   - Attenuator update requires single byte transfer
//   - Register address latched on chip, data continues to same register
//   - ~32 clock cycles to load data (READY held low)
//=========================================================================
reg [2:0] latch_reg;
reg [9:0] tone_freq[0:2];
reg [3:0] ch_attn[0:3];
reg [2:0] noise_ctrl;
reg       restart_noise;

always @(posedge clk) begin
    if(reset) begin
        latch_reg <= 3'd0;
        tone_freq[0] <= 10'd1;
        tone_freq[1] <= 10'd1;
        tone_freq[2] <= 10'd1;
        ch_attn[0] <= 4'hF; // All channels OFF at reset
        ch_attn[1] <= 4'hF;
        ch_attn[2] <= 4'hF;
        ch_attn[3] <= 4'hF;
        noise_ctrl <= 3'b100; // White noise, N/512
        restart_noise <= 1'b0;
    end else begin
        restart_noise <= 1'b0;
        if(cen & ce & we) begin
            if(data[7]) begin
                // Latch byte: update register address and low data bits
                latch_reg <= data[6:4];
                case(data[6:4])
                    3'b000: tone_freq[0][3:0] <= data[3:0]; // Tone 1 freq low (F6-F9)
                    3'b010: tone_freq[1][3:0] <= data[3:0]; // Tone 2 freq low
                    3'b100: tone_freq[2][3:0] <= data[3:0]; // Tone 3 freq low
                    3'b110: begin
                                noise_ctrl<= data[2:0];     // {FB, NF0, NF1}
                                restart_noise <= 1'b1;      // LFSR reset on noise reg write
                            end
                    3'b001: ch_attn[0] <= data[3:0];        // Tone 1 attenuation
                    3'b011: ch_attn[1] <= data[3:0];        // Tone 2 attenuation
                    3'b101: ch_attn[2] <= data[3:0];        // Tone 3 attenuation
                    3'b111: ch_attn[3] <= data[3:0];        // Noise attenuation
                    default: ;
                endcase
            end else begin
                // Data byte: write to latched register (frequency high bits F0-F5)
                case(latch_reg)
                    3'b000: tone_freq[0][9:4] <= data[5:0];
                    3'b010: tone_freq[1][9:4] <= data[5:0];
                    3'b100: tone_freq[2][9:4] <= data[5:0];
                    3'b001: ch_attn[0] <= data[3:0];
                    3'b011: ch_attn[1] <= data[3:0];
                    3'b101: ch_attn[2] <= data[3:0];
                    3'b111: ch_attn[3] <= data[3:0];
                    default: ;
                endcase
            end
        end
    end
end

//=========================================================================
// Tone Generators (3 channels)
//=========================================================================
// Reference TI SN76489AN datasheet, Section 1 and Figure 4:
//   - Each channel: /N counter -> /2 toggle flip-flop -> attenuator
//   - Counter decrements at master_clock/16 rate (tone_en)
//   - Borrow at zero reloads counter and toggles output
//   - Output frequency: f = master_clock / (2 * 16 * N) = clock / (32*N)
//   - N=0 treated as N=1024 (counter wraps), producing lowest frequency
//=========================================================================
wire tone_out [0:2];

x76489_tone u_tone0 (
    .clk     ( clk          ),
    .enable  ( tone_en      ),
    .reset   ( reset        ),
    .compare ( tone_freq[0] ),
    .out     ( tone_out[0]  )
);

x76489_tone u_tone1 (
    .clk     ( clk          ),
    .enable  ( tone_en      ),
    .reset   ( reset        ),
    .compare ( tone_freq[1] ),
    .out     ( tone_out[1]  )
);

x76489_tone u_tone2 (
    .clk     ( clk          ),
    .enable  ( tone_en      ),
    .reset   ( reset        ),
    .compare ( tone_freq[2] ),
    .out     ( tone_out[2]  )
);

//=========================================================================
// Noise Generator
//=========================================================================
// Reference TI SN76489AN datasheet, Section 2 and Tables 2-3:
//   - Shift register with XOR feedback (Table 2: FB=0 periodic, FB=1 white)
//   - LFSR cleared when noise control register is written
//   - Shift rate selected by NF bits (Table 3):
//       NF=00: N/512   NF=01: N/1024   NF=10: N/2048
//       NF=11: Driven by Tone Generator #3 output
//   - Noise output feeds into channel 4 attenuator
//=========================================================================
wire noise_out;

x76489_noise u_noise (
    .clk            ( clk           ),
    .enable         ( tone_en       ),
    .reset          ( reset         ),
    .restart_noise  ( restart_noise ),
    .control        ( noise_ctrl    ),
    .driven_by_tone ( tone_out[2]   ),
    .out            ( noise_out     )
);

//=========================================================================
// Channel Volume (attenuated tone/noise gating)
//=========================================================================
// Output = attenuated volume when channel high, zero when low
// Each channel independently gated by its tone or noise output state
//=========================================================================
wire [9:0] vol0 = tone_out[0] ? attn_vol(ch_attn[0]) : 10'd0;
wire [9:0] vol1 = tone_out[1] ? attn_vol(ch_attn[1]) : 10'd0;
wire [9:0] vol2 = tone_out[2] ? attn_vol(ch_attn[2]) : 10'd0;
wire [9:0] vol3 = noise_out   ? attn_vol(ch_attn[3]) : 10'd0;

//=========================================================================
// Master Output
//=========================================================================
// Reference TI SN76489AN datasheet, Section 3:
//   - Op-amp summing circuit combines 3 tone + noise channels
//   - Max sum: 4 * 1023 = 4092 (12 bits), top 8 bits -> 0-255 unsigned
//=========================================================================
wire [11:0] master_sum = vol0 + vol1 + vol2 + vol3;

always @(posedge clk) begin
    if(reset)
        sndout <= 8'd0;
    else
        sndout <= master_sum[11:4];
end

endmodule
