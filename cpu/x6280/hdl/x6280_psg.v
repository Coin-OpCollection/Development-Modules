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
//  Programmable sound generator for the HuC6280 microprocessor.
//
//  Six-channel waveform-memory PSG with on-chip noise generators on
//  channels 4 and 5 and a low-frequency oscillator (LFO). With the LFO on,
//  channel 1's waveform modulates channel 0's frequency, and R8 joins
//  channel 1's frequency divider so channel 1 steps at the LFO rate
//  [p.PB-6], [p.PB-9]. Channel 1 stays audible [p.PB-6].
//
//  Volume Pipeline:
//  The R4 AL field (5 bits) attenuates by
//  1.5 dB per step; R1 LMAL/RMAL (4 bits) and R5 LAL/RAL (4 bits) each
//  attenuate by 3.0 dB per step. Combining all three fields in 1.5 dB
//  units yields a 7-bit attenuation index in the range 0..91:
//
//      atten = 91 - AL - 2 * LMAL - 2 * LAL
//
//  This is clipped to the 0..31 range used by the 32-entry exponential
//  volume curve; 45 dB below full scale (index 30) and more is silent
//  [p.PB-10]:
//
//      vol_lut[i] = round(2048 * 10^(-1.5 * i / 20))    for i = 0..29
//      vol_lut[30] = vol_lut[31] = 0
//
//  The curve is initialised in an unrolled initial block; no external
//  voltab is required.
//
//  Mix Pipeline:
//  A small state machine walks the six channels round-robin. For each
//  channel the L and R attenuation indices are computed separately; the
//  channel's 5-bit DAC sample (offset binary, mid = $10) is converted to
//  signed via MSB-XOR, multiplied by the looked-up volume, and accumulated
//  into LACC / RACC. After channel 5 the accumulators are latched to
//  ldata / rdata outputs.
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Programmable Sound
//             Generator Manual [p.PB-2]-[p.PB-10]
//
//  Register Map (PSG block at $1FE800-$1FE80F, A[3:0] selects):
//    R0  $1FE800  Channel select (CHSEL[2:0])                    (write)
//    R1  $1FE801  Main amplitude: LMAL[7:4], RMAL[3:0]           (write)
//    R2  $1FE802  Frequency low byte (FRQ[7:0])                  (write)
//    R3  $1FE803  Frequency high nibble (FRQ[11:8])              (write)
//    R4  $1FE804  ChON[7], DDA[6], AL[4:0]                       (write)
//    R5  $1FE805  Channel pan: LAL[7:4], RAL[3:0]                (write)
//    R6  $1FE806  Waveform / DDA data (5 bits)                   (write)
//    R7  $1FE807  Noise enable[7] / Noise FRQ[4:0] (ch4/ch5)     (write)
//    R8  $1FE808  LFO frequency                                  (write)
//    R9  $1FE809  LFTRG[7] / LFCTL[1:0]                          (write)
//============================================================================

`timescale 1ns/1ps

module x6280_psg (
    // Clock and Reset
    input  wire               clk,
    input  wire               rst_n,
    input  wire               clken,

    // Register Bus Interface
    input  wire               we,
    input  wire         [3:0] a,
    input  wire         [7:0] di,

    // Mix Control
    input  wire               dac_latch,

    // Audio Output
    output reg  signed [23:0] ldata,
    output reg  signed [23:0] rdata
);

//------------------------------------------------------------------------
// Volume Lookup Table:
// 32-entry exponential curve at 1.5 dB per step. Index 0 = full scale,
// indexes 30 and 31 = silence. Values are round(2048 * 10^(-1.5*i/20)).
//------------------------------------------------------------------------
reg [11:0] vol_lut [0:31];

initial begin
    vol_lut[ 0] = 12'd2048;
    vol_lut[ 1] = 12'd1723;
    vol_lut[ 2] = 12'd1450;
    vol_lut[ 3] = 12'd1220;
    vol_lut[ 4] = 12'd1026;
    vol_lut[ 5] = 12'd 864;
    vol_lut[ 6] = 12'd 727;
    vol_lut[ 7] = 12'd 611;
    vol_lut[ 8] = 12'd 514;
    vol_lut[ 9] = 12'd 433;
    vol_lut[10] = 12'd 364;
    vol_lut[11] = 12'd 306;
    vol_lut[12] = 12'd 258;
    vol_lut[13] = 12'd 217;
    vol_lut[14] = 12'd 183;
    vol_lut[15] = 12'd 154;
    vol_lut[16] = 12'd 129;
    vol_lut[17] = 12'd 109;
    vol_lut[18] = 12'd  91;
    vol_lut[19] = 12'd  77;
    vol_lut[20] = 12'd  65;
    vol_lut[21] = 12'd  54;
    vol_lut[22] = 12'd  46;
    vol_lut[23] = 12'd  39;
    vol_lut[24] = 12'd  32;
    vol_lut[25] = 12'd  27;
    vol_lut[26] = 12'd  23;
    vol_lut[27] = 12'd  19;
    vol_lut[28] = 12'd  16;
    vol_lut[29] = 12'd  14;
    vol_lut[30] = 12'd   0;
    vol_lut[31] = 12'd   0;
end

//------------------------------------------------------------------------
// Global Registers:
// chsel selects which channel R2-R7 target. lmal and rmal are the main
// left and right amplitude attenuators applied to every channel.
//------------------------------------------------------------------------
reg [2:0] chsel;
reg [3:0] lmal;
reg [3:0] rmal;

//------------------------------------------------------------------------
// Per-Channel State:
// Frequency, mode flags, amplitude/pan, noise control, and waveform RAM
// are stored per channel. ch_lfo_freq, ch_lfctl and ch_lftrg are the one
// set of LFO registers for the whole PSG [p.PB-2]; ch_lfo_add[0] holds the
// modulation channel 1 applies to channel 0's frequency.
//------------------------------------------------------------------------
reg [11:0] ch_freq [0:5];
reg        ch_dda [0:5];
reg        ch_chon [0:5];
reg  [4:0] ch_al [0:5];
reg  [3:0] ch_lal [0:5];
reg  [3:0] ch_ral [0:5];
reg  [4:0] ch_ng_freq [0:5];
reg        ch_ne [0:5];
reg  [7:0] ch_lfo_freq;
reg  [1:0] ch_lfctl;
reg        ch_lftrg;

reg  [4:0] ch_wf_data [0:5] [0:31];
reg  [4:0] ch_wf_addr [0:5];
reg [12:0] ch_wf_cnt [0:5];
reg [17:0] ch_lfsr [0:5];
reg [11:0] ch_ng_cnt [0:5];
reg  [7:0] lfo_cnt;
reg [11:0] ch_lfo_add [0:5];

reg [4:0] ch_da_out [0:5];
reg [4:0] ch_wf_out [0:5];
reg [4:0] ch_ng_out [0:5];
reg [4:0] ch_gl_out [0:5];

reg ch_wf_inc [0:5];
reg lfo_trg_res;

integer ci;

//------------------------------------------------------------------------
// Register Write:
// Decodes R0-R9 into per-channel and global state. R2-R7 reach the
// channel R0 selects; R0 = 6 or 7 selects none. R6 writes fill waveform
// RAM unless DDA is set, load the DDA latch while the channel is on, and
// advance the waveform address in write mode (ChON = 0, DDA = 0)
// [p.PB-3]-[p.PB-5]. An R9 write with LF TRG set restarts the LFO.
//------------------------------------------------------------------------
always @(posedge clk) begin
    for(ci = 0; ci < 6; ci = ci + 1)
        ch_wf_inc[ci] <= 1'b0;
    lfo_trg_res <= 1'b0;

    if(!rst_n) begin
        chsel <= 3'd0;
        lmal <= 4'd0;
        rmal <= 4'd0;
        for(ci = 0; ci < 6; ci = ci + 1) begin
            ch_freq[ci] <= 12'd0;
            ch_dda[ci] <= 1'b0;
            ch_chon[ci] <= 1'b0;
            ch_al[ci] <= 5'd0;
            ch_lal[ci] <= 4'd0;
            ch_ral[ci] <= 4'd0;
            ch_ng_freq[ci] <= 5'd0;
            ch_ne[ci] <= 1'b0;
            ch_da_out[ci] <= 5'd0;
        end
        ch_lfo_freq <= 8'd0;
        ch_lfctl <= 2'd0;
        ch_lftrg <= 1'b0;
    end else if(we) begin
        case(a)
            4'h0: chsel <= di[2:0];
            4'h1: begin
                lmal <= di[7:4];
                rmal <= di[3:0];
            end
            4'h2: begin
                if(chsel < 3'd6)
                    ch_freq[chsel][7:0] <= di;
            end
            4'h3: begin
                if(chsel < 3'd6)
                    ch_freq[chsel][11:8] <= di[3:0];
            end
            4'h4: begin
                if(chsel < 3'd6) begin
                    ch_chon[chsel] <= di[7];
                    ch_dda[chsel] <= di[6];
                    ch_al[chsel] <= di[4:0];
                end
            end
            4'h5: begin
                if(chsel < 3'd6) begin
                    ch_lal[chsel] <= di[7:4];
                    ch_ral[chsel] <= di[3:0];
                end
            end
            4'h6: begin
                if(chsel < 3'd6) begin
                    if(!ch_dda[chsel])
                        ch_wf_data[chsel][ch_wf_addr[chsel]] <= di[4:0];
                    if(ch_chon[chsel])
                        ch_da_out[chsel] <= di[4:0];
                    if(!ch_dda[chsel] && !ch_chon[chsel])
                        ch_wf_inc[chsel] <= 1'b1;
                end
            end
            4'h7: begin
                if(chsel == 3'd4 || chsel == 3'd5) begin
                    ch_ne[chsel] <= di[7];
                    ch_ng_freq[chsel] <= di[4:0];
                end
            end
            4'h8: ch_lfo_freq <= di;
            4'h9: begin
                ch_lfctl <= di[1:0];
                ch_lftrg <= di[7];
                lfo_trg_res <= di[7];
            end
            default: ;
        endcase
    end
end

//------------------------------------------------------------------------
// LFO Divider:
// R8 extends channel 1's frequency divider while the LFO runs, so channel
// 1 steps once every 2 x F x FLF clken; FLF = 0 counts 256 [p.PB-6],
// [p.PB-9]. The LFO runs with LF CTL nonzero, LF TRG clear and channel 1
// in waveform output mode. Stopped or restarted, the divider reloads, so
// the LFO starts with a full FLF period.
//------------------------------------------------------------------------
wire lfo_on = (ch_lfctl != 2'b00);
wire lfo_run = lfo_on && !ch_lftrg && ch_chon[1] && !ch_dda[1];
wire lfo_tick = clken && (lfo_cnt == 8'd0);

always @(posedge clk) begin
    if(!rst_n)
        lfo_cnt <= 8'hFF;
    else if(!lfo_run || lfo_trg_res)
        lfo_cnt <= ch_lfo_freq - 8'd1;
    else if(clken)
        lfo_cnt <= lfo_tick ? ch_lfo_freq - 8'd1 : lfo_cnt - 8'd1;
end

//------------------------------------------------------------------------
// Per-Channel Generators:
// Steps the waveform address counter and the noise LFSR for each of the
// six channels. A channel steps through its waveform only in output mode
// (ChON = 1, DDA = 0); DDA holds the address at 0 [p.PB-3]. With the LFO
// on, channel 1 steps on the LFO divider and channel 0's period takes the
// modulation at each reload [p.PB-6]-[p.PB-8]. LF TRG resets channel 1 to
// address 0 and holds it there until LF TRG is cleared [p.PB-6]. The
// 5-bit DAC sample (ch_gl_out) is the noise output when NE is set, the
// DDA latch in DDA mode, and the waveform otherwise [p.PB-6].
//------------------------------------------------------------------------
integer i;

always @(posedge clk) begin
    for(i = 0; i < 6; i = i + 1) begin
        if(!rst_n) begin
            ch_gl_out[i] <= 5'd0;
            ch_wf_addr[i] <= 5'd0;
            ch_wf_cnt[i] <= 13'd0;
            ch_wf_out[i] <= 5'd0;
            ch_lfsr[i] <= 18'd0;
            ch_ng_cnt[i] <= 12'd0;
            ch_ng_out[i] <= 5'd0;
        end else begin
            if(ch_wf_inc[i])
                ch_wf_addr[i] <= ch_wf_addr[i] + 5'd1;

            if(!ch_chon[i] || ch_dda[i]) begin
                ch_wf_cnt[i] <= {(ch_freq[i] - 12'd1) + ch_lfo_add[i], 1'b1};
                if(ch_dda[i])
                    ch_wf_addr[i] <= 5'd0;
            end else if(i == 1 && (lfo_on || ch_lftrg)) begin
                ch_wf_out[i] <= ch_wf_data[i][ch_wf_addr[i]];
                if(lfo_run && lfo_tick) begin
                    ch_wf_cnt[i] <= ch_wf_cnt[i] - 13'd1;
                    if(ch_wf_cnt[i] == 13'd0) begin
                        ch_wf_cnt[i] <= {ch_freq[i] - 12'd1, 1'b1};
                        ch_wf_addr[i] <= ch_wf_addr[i] + 5'd1;
                    end
                end
            end else begin
                ch_wf_out[i] <= ch_wf_data[i][ch_wf_addr[i]];
                if(clken) begin
                    ch_wf_cnt[i] <= ch_wf_cnt[i] - 13'd1;
                    if(ch_wf_cnt[i] == 13'd0) begin
                        ch_wf_cnt[i] <= {(ch_freq[i] - 12'd1) + ch_lfo_add[i], 1'b1};
                        ch_wf_addr[i] <= ch_wf_addr[i] + 5'd1;
                    end
                end
            end

            if(i == 1 && lfo_trg_res) begin
                ch_wf_addr[i] <= 5'd0;
                ch_wf_cnt[i] <= {ch_freq[i] - 12'd1, 1'b1};
            end

            if(!ch_ne[i]) begin
                if(ch_ng_freq[i] == 5'b11111)
                    ch_ng_cnt[i] <= 12'b000000111111;
                else
                    ch_ng_cnt[i] <= {(~ch_ng_freq[i]) - 5'd1, 7'b1111111};
            end else begin
                if(!ch_lfsr[i][0])
                    ch_ng_out[i] <= 5'b00000;
                else
                    ch_ng_out[i] <= 5'b11111;

                if(clken) begin
                    ch_ng_cnt[i] <= ch_ng_cnt[i] - 12'd1;
                    if(ch_ng_cnt[i] == 12'd0) begin
                        if(ch_ng_freq[i] == 5'b11111)
                            ch_ng_cnt[i] <= 12'b000000111111;
                        else
                            ch_ng_cnt[i] <= {(~ch_ng_freq[i]) - 5'd1, 7'b1111111};
                        if(ch_lfsr[i] == 18'd0)
                            ch_lfsr[i][0] <= 1'b1;
                        else
                            ch_lfsr[i] <= {ch_lfsr[i][0] ^ ch_lfsr[i][1] ^ ch_lfsr[i][11] ^ ch_lfsr[i][12] ^ ch_lfsr[i][17],
                                           ch_lfsr[i][17:1]};
                    end
                end
            end

            if(!ch_chon[i])
                ch_gl_out[i] <= 5'h10;
            else if(ch_ne[i])
                ch_gl_out[i] <= ch_ng_out[i];
            else if(ch_dda[i])
                ch_gl_out[i] <= ch_da_out[i];
            else
                ch_gl_out[i] <= ch_wf_out[i];
        end
    end
end

//------------------------------------------------------------------------
// LFO Modulation:
// Channel 1's current waveform sample, less $10 (so $10 is 0, $00 is -16
// and $1F is +15) [p.PB-7], shifted left 0, 2 or 4 bits for LF CTL 1, 2
// or 3 [p.PB-8], is added to channel 0's frequency at its next reload.
// The modulation applies only while channel 1 is on [p.PB-6].
//------------------------------------------------------------------------
reg [4:0] lfo_data;
integer li;

always @(posedge clk) begin
    if(!rst_n) begin
        for(li = 0; li < 6; li = li + 1)
            ch_lfo_add[li] <= 12'd0;
    end else begin
        lfo_data = ch_wf_data[1][ch_wf_addr[1]] ^ 5'b10000;
        ch_lfo_add[0][11:8] <= {4{lfo_data[4]}};
        if(!ch_chon[1]) begin
            ch_lfo_add[0] <= 12'd0;
        end else begin
            case(ch_lfctl)
                2'b01:   ch_lfo_add[0][7:0] <= {{3{lfo_data[4]}}, lfo_data};
                2'b10:   ch_lfo_add[0][7:0] <= {lfo_data[4], lfo_data, 2'b00};
                2'b11:   ch_lfo_add[0][7:0] <= {lfo_data[3:0], 4'b0000};
                default: ch_lfo_add[0] <= 12'd0;
            endcase
        end
    end
end

//------------------------------------------------------------------------
// Mix State Machine:
// Round-robin walk through the six channels, computing left then right
// attenuation indices per channel. Channel sample (5-bit offset binary)
// is converted to signed and multiplied by the volume table value into
// mix_prod in the read state, then accumulated into lacc/racc in the
// next state. After channel 5 the accumulators latch to ldata/rdata.
//------------------------------------------------------------------------
localparam [2:0] MIX_WAIT  = 3'd0;
localparam [2:0] MIX_NEXT  = 3'd1;
localparam [2:0] MIX_LREAD = 3'd2;
localparam [2:0] MIX_LNEXT = 3'd3;
localparam [2:0] MIX_RREAD = 3'd4;
localparam [2:0] MIX_RNEXT = 3'd5;
localparam [2:0] MIX_END   = 3'd6;

reg [2:0] mix_state;
reg [2:0] mix_cnt;
reg [4:0] vt_idx;

reg signed [23:0] lacc;
reg signed [23:0] racc;
reg signed [17:0] mix_prod;

function [4:0] atten_idx;
    input [4:0] al;
    input [3:0] mal;
    input [3:0] cal;
    reg   [7:0] sum;
    begin
        sum = 8'd91 - {3'd0, al} - {3'd0, mal, 1'b0} - {3'd0, cal, 1'b0};
        atten_idx = (sum > 8'd31) ? 5'd31 : sum[4:0];
    end
endfunction

wire signed [5:0] ch_sample_signed_l = $signed({1'b0, ch_gl_out[mix_cnt]}) - 6'sd16;
wire signed [5:0] ch_sample_signed_r = ch_sample_signed_l;

wire signed [17:0] ch_prod_l = ch_sample_signed_l * $signed({1'b0, vol_lut[vt_idx]});
wire signed [17:0] ch_prod_r = ch_sample_signed_r * $signed({1'b0, vol_lut[vt_idx]});

always @(posedge clk) begin
    if(!rst_n) begin
        mix_state <= MIX_WAIT;
        mix_cnt <= 3'd0;
        vt_idx <= 5'd31;
        lacc <= 24'd0;
        racc <= 24'd0;
        mix_prod <= 18'd0;
        ldata <= 24'd0;
        rdata <= 24'd0;
    end else begin
        case(mix_state)
            MIX_WAIT: begin
                lacc <= 24'd0;
                racc <= 24'd0;
                mix_cnt <= 3'd0;
                vt_idx <= 5'd31;
                if(dac_latch)
                    mix_state <= MIX_NEXT;
            end

            MIX_NEXT: begin
                vt_idx <= atten_idx(ch_al[mix_cnt], lmal, ch_lal[mix_cnt]);
                mix_state <= MIX_LREAD;
            end

            MIX_LREAD: begin
                mix_prod <= ch_prod_l;
                mix_state <= MIX_LNEXT;
            end

            MIX_LNEXT: begin
                lacc <= lacc + {{6{mix_prod[17]}}, mix_prod};
                vt_idx <= atten_idx(ch_al[mix_cnt], rmal, ch_ral[mix_cnt]);
                mix_state <= MIX_RREAD;
            end

            MIX_RREAD: begin
                mix_prod <= ch_prod_r;
                mix_state <= MIX_RNEXT;
            end

            MIX_RNEXT: begin
                racc <= racc + {{6{mix_prod[17]}}, mix_prod};
                if(mix_cnt == 3'd5) begin
                    mix_state <= MIX_END;
                end else begin
                    mix_cnt <= mix_cnt + 3'd1;
                    mix_state <= MIX_NEXT;
                end
            end

            MIX_END: begin
                ldata <= lacc;
                rdata <= racc;
                mix_state <= MIX_WAIT;
            end

            default: mix_state <= MIX_WAIT;
        endcase
    end
end

endmodule
