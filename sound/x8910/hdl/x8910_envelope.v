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
//  Envelope generator for the General Instrument AY-3-8910 programmable
//  sound generator: a 16-bit period counter built as the tone counter, and
//  a 4-bit step counter that advances on each rising edge of the period
//  counter output. One step lasts 16 EP input clocks for an envelope
//  period EP, so a 16-step cycle is f = f_CLOCK / (256 EP) [p.24]. shape
//  is R13, {Continue, Attack, Alternate, Hold} [p.25].
//
//  Step Counter:
//    step counts 0 to 15; out is step, or 15 - step while invert is set.
//    invert starts as the inverse of Attack and changes at the end of each
//    cycle while Alternate is set. With Hold set the count stops after one
//    cycle, at the cycle's last level, or at its first level with Alternate
//    also set (AY-3-8910 die schematic).
//
//  Continue = 0:
//    Shapes 00xx act as 1001 and shapes 01xx as 1111: one cycle, then 0
//    [p.25].
//
//  restart, a write to R13, and reset return both counters to the start
//  of a cycle.
//
//  Reference: AY-3-8910/8912 Programmable Sound Generator Data Manual,
//             Envelope Period Control [p.24], Envelope Shape/Cycle Control
//             [p.25].
//             AY-3-8910 die schematic.
//============================================================================

`timescale 1ns/1ps

module x8910_envelope (
    // Clock and Reset
    input  wire        clk,
    input  wire        rst,
    input  wire        pre_cen,

    // Envelope Interface
    input  wire        restart,
    input  wire [15:0] period,
    input  wire [3:0]  shape,
    output wire [3:0]  out
);

wire env_rst = rst | restart;

wire cont      = shape[3];
wire attack    = shape[2];
wire alternate = shape[1];
wire hold      = shape[0];

//========================================================================
// Period Counter:
// At or past period the counter returns to 1 and toggle changes.
//========================================================================
reg [15:0] counter;
reg        toggle;

always @(posedge clk) begin
    if(env_rst) begin
        counter <= 16'd1;
        toggle <= 1'b1;
    end else if(pre_cen) begin
        if(counter >= period) begin
            counter <= 16'd1;
            toggle <= ~toggle;
        end else begin
            counter <= counter + 16'd1;
        end
    end
end

wire step_en;

x8910_edge u_edge (
    // Clock and Reset
    .clk  ( clk     ),
    .rst  ( env_rst ),

    // Edge Interface
    .sig  ( toggle  ),
    .rise ( step_en )
);

//========================================================================
// Shape:
// Continue = 0 maps to Hold = 1 with Alternate = Attack; with Hold set,
// the sense of Alternate is inverted for the change of invert at the end
// of the cycle.
//========================================================================
wire hold_eff  = hold | ~cont;
wire alt_eff   = cont ? alternate : attack;
wire alt_final = hold_eff ? ~alt_eff : alt_eff;

//========================================================================
// Step Counter:
//========================================================================
reg [3:0] step;
reg       stop;
reg       invert;

always @(posedge clk) begin
    if(env_rst) begin
        step <= 4'd0;
        stop <= 1'b0;
    end else if(step_en) begin
        if(!(hold_eff & stop)) {stop, step} <= step + 5'd1;
    end
end

always @(posedge clk) begin
    if(env_rst) invert <= ~attack;
    else if(step_en && step == 4'd15 && alt_final) invert <= ~invert;
end

assign out = invert ? (4'd15 - step) : step;

endmodule
