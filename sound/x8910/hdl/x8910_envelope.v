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
//  Envelope generator module for the AY-3-8910 Programmable Sound Generator.
//
//  Implements the 16-bit period envelope with 4-bit amplitude counter and
//  10 shape configurations controlled by R13 (Continue, Attack, Alternate,
//  Hold). Writing R13 always restarts the envelope cycle.
//
//  Reference GI Data Manual, Section 3.5 and Datasheet Fig. 1:
//    - 16-bit period counter (same count-up-toggle as tone)
//    - 4-bit envelope counter (E3-E0) steps on rising edge of toggle
//    - Shape controlled by 4 bits from R13: Continue, Attack, Alternate, Hold
//    - Writing R13 restarts envelope (counter reset, shape reloaded)
//
//  Implementation (per lvd RE schematic):
//    - Counter always counts 0->15 (up)
//    - An 'invert' flag determines output direction:
//      invert=0: output = counter (attack/rising)
//      invert=1: output = 15-counter (decay/falling)
//    - 'invert' initialized to !attack on restart
//    - 'invert' toggles on counter overflow when alternate is active
//    - 'stop' flag prevents further counting when hold is active
//
//  Continue=0 mapping (duplicated behavior, per datasheet):
//    00xx -> 1001: decay, hold at 0
//    01xx -> 1111: attack, hold at 0
//============================================================================

module x8910_envelope (
    input  wire        clk,
    input  wire        enable,
    input  wire        reset,
    input  wire        restart, // Restart envelope (R13 written)
    input  wire [15:0] period,
    input  wire        continue_,
    input  wire        attack,
    input  wire        alternate,
    input  wire        hold,
    output wire [3:0]  out
);

wire env_reset = reset | restart;

//------------------------------------------------------------------------
// Period Counter:
// 16-bit counter counts up at enable rate. Toggles output and resets
// to 1 when counter reaches programmed period value.
//------------------------------------------------------------------------
reg [15:0] period_counter;
reg        period_toggle;

always @(posedge clk) begin
    if(env_reset) begin
        period_counter <= 16'd1;
        period_toggle <= 1'b1;
    end else if(enable) begin
        if(period_counter >= period) begin
            period_counter <= 16'd1;
            period_toggle <= ~period_toggle;
        end else begin
            period_counter <= period_counter + 16'd1;
        end
    end
end

//------------------------------------------------------------------------
// Rising Edge Detection:
// Envelope counter steps on rising edge of period counter toggle.
//------------------------------------------------------------------------
wire step_edge;

x8910_edge u_step_edge (
    .clk        ( clk           ),
    .reset      ( env_reset     ),
    .signal_in  ( period_toggle ),
    .on_posedge ( step_edge     )
);

//------------------------------------------------------------------------
// Continue=0 Mapping:
// Handle Continue=0 by mapping to equivalent Continue=1 patterns.
// Reference Datasheet Fig. 1 and lvd RE:
//   00xx -> 1001: Hold'=1, Alternate'=Attack=0   (\___)
//   01xx -> 1111: Hold'=1, Alternate'=Attack=1   (/___)
//------------------------------------------------------------------------
wire hold_eff = hold | ~continue_;
wire alternate_eff = continue_ ? alternate : attack;

// Handle Hold interaction with Alternate
// When Hold=1 and Alternate=1: counter resets to initial then holds
// Implementation: invert alternate sense when hold is active
wire hold_final = hold_eff;
wire alternate_final = hold_eff ? ~alternate_eff : alternate_eff;

//------------------------------------------------------------------------
// 4-bit Envelope Counter:
// Counts 0->15 with stop flag for hold behavior. Steps on rising
// edge of period counter toggle output.
//------------------------------------------------------------------------
reg [3:0] env_counter;
reg       stop;

always @(posedge clk) begin
    if(env_reset) begin
        env_counter <= 4'd0;
        stop <= 1'b0;
    end else begin
        if(step_edge) begin
            if(!(hold_final & stop))
                {stop, env_counter} <= env_counter + 5'd1;
        end
    end
end

//------------------------------------------------------------------------
// Invert Control:
// Determines output direction (attack vs decay). Initialized to
// !attack on restart. Toggles at counter overflow when alternate
// is active.
//------------------------------------------------------------------------
reg invert;

always @(posedge clk) begin
    if(env_reset)
        invert <= ~attack;
    else begin
        if(step_edge && env_counter == 4'd15) begin
            if(alternate_final)
                invert <= ~invert;
        end
    end
end

//------------------------------------------------------------------------
// Envelope Output:
// Counter value, optionally inverted for decay direction.
//------------------------------------------------------------------------
assign out = invert ? (4'd15 - env_counter) : env_counter;

endmodule
