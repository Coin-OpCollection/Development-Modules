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
//  Bus controller and control registers for the Texas Instruments SN76489AN
//  digital complex sound generator. The CPU writes the chip through D0-D7
//  with CE and WE; each byte takes about 32 clocks to load, and READY is low
//  from the leading edge of CE until it is loaded [p.5]. A latch byte
//  selects one of eight registers and loads its low bits, and a data byte
//  loads the latched register again [p.3-4].
//
//  Write Transfer:
//    A transfer starts on the first clk on which cs_n and wr_n are both low,
//    and din is taken on that clk. The byte is loaded on the clk of the 32nd
//    cen pulse of the transfer. ready is low while cs_n is low, until the
//    byte is loaded, and high while cs_n is high (Table 5 [p.5]). A write
//    held 32 more cen pulses after its byte is loaded starts another with
//    the byte then on din (SN76494/SN76496 Data Sheet, WE, p. 4-40).
//
//    The chip needs CE and WE held until READY rises; taking din at the
//    start lets a shorter write complete, as the data latch of that data
//    sheet's Figure 4, Note 4 (p. 4-44) does. A write that starts while a
//    transfer runs waits and starts as it ends; a later one replaces it. On
//    the die a two-stage timer on the prescaled clock times the transfer
//    (TI SN76489AN die schematic, DATA WRITE CONTROL); here it is exactly 32
//    cen pulses.
//
//  Registers:
//    A latch byte (din[7] = 1) loads latch_reg from R0-R2 and the low bits of
//    the register it selects. A data byte (din[7] = 0) loads F0-F5 of a
//    latched tone frequency, A0-A3 of a latched attenuation, or FB, NF0 and
//    NF1 of the latched noise control; on the die every byte strobes the
//    latched register (TI SN76489AN die schematic, DATA WRITE CONTROL). A
//    byte to the noise control register raises restart for one clk [p.3].
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             CPU to SN76489AN Interface [p.3], Control Registers, Table 4,
//             Data Formats [p.4], Data Transfer, Figure 1, Table 5 [p.5].
//             TI SN76494, SN76494A, SN76496, SN76496A Data Sheet D2801,
//             WE and READY, p. 4-40; Figure 4, p. 4-44.
//             TI SN76489AN die schematic, DATA WRITE CONTROL.
//============================================================================

`timescale 1ns/1ps

module x76489_host (
    // Clock and Reset
    input  wire       clk,
    input  wire       rst,
    input  wire       cen,

    // Control Interface
    input  wire [7:0] din,
    input  wire       cs_n,
    input  wire       wr_n,
    output wire       ready,

    // Register Interface
    output wire [9:0] tone0,
    output wire [9:0] tone1,
    output wire [9:0] tone2,
    output wire [3:0] attn0,
    output wire [3:0] attn1,
    output wire [3:0] attn2,
    output wire [3:0] attn3,
    output reg  [2:0] noise_ctrl,
    output reg        restart
);

localparam XFER_CEN = 32;

localparam S_IDLE = 2'd0;
localparam S_XFER = 2'd1;
localparam S_HELD = 2'd2;

//========================================================================
// Write Transfer:
// S_XFER counts the cen pulses of a transfer, and load is high on the
// 32nd; S_HELD counts the cen pulses of a write held after its byte is
// loaded. A write that starts in S_XFER is kept in pend_data.
//========================================================================
wire strobe = ~cs_n & ~wr_n;

reg [1:0] state;
reg [4:0] xfer_cnt;
reg [7:0] wr_data;
reg [7:0] pend_data;
reg       pend_v;
reg       strobe_q;

wire start = strobe & ~strobe_q;
wire load  = (state == S_XFER) & cen & (xfer_cnt == XFER_CEN - 1);

always @(posedge clk) begin
    if(rst) begin
        state <= S_IDLE;
        xfer_cnt <= 5'd0;
        wr_data <= 8'h00;
        pend_data <= 8'h00;
        pend_v <= 1'b0;
        strobe_q <= 1'b0;
    end else begin
        strobe_q <= strobe;
        case(state)
            S_IDLE : begin
                if(strobe) begin
                    wr_data <= din;
                    xfer_cnt <= 5'd0;
                    state <= S_XFER;
                end
            end
            S_XFER : begin
                if(start) begin
                    pend_data <= din;
                    pend_v <= 1'b1;
                end
                if(load) begin
                    xfer_cnt <= 5'd0;
                    if(start || pend_v) begin
                        wr_data <= start ? din : pend_data;
                        pend_v <= 1'b0;
                    end else begin
                        state <= strobe ? S_HELD : S_IDLE;
                    end
                end else if(cen) begin
                    xfer_cnt <= xfer_cnt + 5'd1;
                end
            end
            S_HELD : begin
                if(!strobe) begin
                    state <= S_IDLE;
                end else if(cen) begin
                    if(xfer_cnt == XFER_CEN - 1) begin
                        wr_data <= din;
                        xfer_cnt <= 5'd0;
                        state <= S_XFER;
                    end else begin
                        xfer_cnt <= xfer_cnt + 5'd1;
                    end
                end
            end
            default : state <= S_IDLE;
        endcase
    end
end

assign ready = cs_n | (state == S_HELD);

//========================================================================
// Control Registers:
//   000 tone 1 frequency    001 tone 1 attenuation
//   010 tone 2 frequency    011 tone 2 attenuation
//   100 tone 3 frequency    101 tone 3 attenuation
//   110 noise control       111 noise attenuation
// tone_freq holds F0-F9, F9 in bit 0, and noise_ctrl {FB, NF0, NF1}.
//========================================================================
reg [2:0] latch_reg;
reg [9:0] tone_freq [0:2];
reg [3:0] ch_attn   [0:3];

always @(posedge clk) begin
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
        restart <= 1'b0;
    end else begin
        restart <= 1'b0;
        if(load) begin
            if(wr_data[7]) begin
                latch_reg <= wr_data[6:4];
                case(wr_data[6:4])
                    3'b000 : tone_freq[0][3:0] <= wr_data[3:0];
                    3'b001 : ch_attn[0] <= wr_data[3:0];
                    3'b010 : tone_freq[1][3:0] <= wr_data[3:0];
                    3'b011 : ch_attn[1] <= wr_data[3:0];
                    3'b100 : tone_freq[2][3:0] <= wr_data[3:0];
                    3'b101 : ch_attn[2] <= wr_data[3:0];
                    3'b110 : begin
                        noise_ctrl <= wr_data[2:0];
                        restart <= 1'b1;
                    end
                    3'b111 : ch_attn[3] <= wr_data[3:0];
                endcase
            end else begin
                case(latch_reg)
                    3'b000 : tone_freq[0][9:4] <= wr_data[5:0];
                    3'b001 : ch_attn[0] <= wr_data[3:0];
                    3'b010 : tone_freq[1][9:4] <= wr_data[5:0];
                    3'b011 : ch_attn[1] <= wr_data[3:0];
                    3'b100 : tone_freq[2][9:4] <= wr_data[5:0];
                    3'b101 : ch_attn[2] <= wr_data[3:0];
                    3'b110 : begin
                        noise_ctrl <= wr_data[2:0];
                        restart <= 1'b1;
                    end
                    3'b111 : ch_attn[3] <= wr_data[3:0];
                endcase
            end
        end
    end
end

assign tone0 = tone_freq[0];
assign tone1 = tone_freq[1];
assign tone2 = tone_freq[2];
assign attn0 = ch_attn[0];
assign attn1 = ch_attn[1];
assign attn2 = ch_attn[2];
assign attn3 = ch_attn[3];

endmodule
