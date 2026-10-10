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
//  Comprehensive testbench for the General Instrument AY-3-8910
//  programmable sound generator implementation.
//
//  Verifies the registers through the chip bus: writes, reads with the
//  unused bits masked, and the reset values of R0 and R7; the three tone
//  generators, the rate set by the period and period 0; the noise shift
//  register and the rate set by the noise period; the mixer with tone,
//  noise, both and neither; the D/A levels on AOUT; the envelope shapes,
//  hold and restart; each channel and the sum on AOUT; and register writes
//  while a channel plays.
//
//  DUT:
//    uut - x8910, the full chip on the bus
//  CLK has a 10 ns period. CEN is driven only by the bench: one pulse is
//  two CLK, CEN high on the second.
//
//  Test Organization:
//    REG Section A:   Writes and reads of R0 and R7, the read masks of R1,
//                     R3, R5, R6, R8-R10 and R13, the reset values of R0
//                     and R7
//    TONE Section B:  Each tone generator toggling, period 1 faster than
//                     period 4, period 0
//    NOISE Section C: The shift register running, the noise output
//                     changing, noise period 1 faster than 16
//    MIX Section D:   Tone and noise off, tone only, noise only, both, and
//                     amplitude 0
//    AMP Section E:   Level 15 on each channel, all off, levels 11, 7 and 1
//    ENV Section F:   Shapes $00, $04 and $08-$0F, restart, a slow period
//    OUT Section G:   Three channels at level 15, all off, each channel
//                     alone, A and B
//    WRITE Section H: Amplitude, period and envelope mode writes while a
//                     channel plays
//
//  Usage (from the IP root):
//    vlib work
//    vlog -quiet hdl/*.v sim/tb_x8910.v
//    vsim -quiet -c tb_x8910 -do "run -all; quit -f"
//
//  Reference: AY-3-8910/8912 Programmable Sound Generator Data Manual,
//             Basic Functional Blocks [p.7-11], Operation [p.18-29].
//============================================================================

`timescale 1ns/1ps

module tb_x8910;

//=========================================================================
// Test Signals:
// Clock, the clock enable and the chip pins.
//=========================================================================
reg        CLK;
reg        RESETn;
reg        CEN;
reg  [7:0] DIN;
wire [7:0] DOUT;
reg        RDn;
reg        WRn;
reg        A0;
wire [7:0] AOUT;

//=========================================================================
// Test Infrastructure:
//=========================================================================
integer total_tests;
integer passed_tests;
integer failed_tests;
integer i;

//=========================================================================
// DUT:
//=========================================================================
x8910 uut (
    // Clock and Reset
    .CLK    ( CLK    ),
    .RESETn ( RESETn ),
    .CEN    ( CEN    ),

    // Control Interface
    .DIN    ( DIN    ),
    .DOUT   ( DOUT   ),
    .RDn    ( RDn    ),
    .WRn    ( WRn    ),
    .A0     ( A0     ),

    // Audio Output
    .AOUT   ( AOUT   )
);

//=========================================================================
// Clock Generation:
// 10ns period (100MHz) for fast simulation.
//=========================================================================
initial CLK = 0;
always #5 CLK = ~CLK;

//=========================================================================
// Helper Tasks:
//=========================================================================

//-------------------------------------------------------------------------
// Single Clock Cycle with CEN:
//-------------------------------------------------------------------------
task cycle;
    begin
        @(posedge CLK);
        #1 CEN = 1;
        @(posedge CLK);
        #1 CEN = 0;
    end
endtask

//-------------------------------------------------------------------------
// Multiple Cycles:
//-------------------------------------------------------------------------
task run_cycles;
    input integer n;
    integer c;
    begin
        for(c = 0; c < n; c = c + 1)
            cycle();
    end
endtask

//-------------------------------------------------------------------------
// Write Register:
// Two-step bus protocol: latch address, then write data.
//-------------------------------------------------------------------------
task write_reg;
    input [3:0] reg_addr;
    input [7:0] data;
    begin
        // Latch address
        @(posedge CLK);
        #1;
        A0 = 1'b0;
        DIN = {4'd0, reg_addr};
        WRn = 1'b0;
        @(posedge CLK);
        #1;
        WRn = 1'b1;

        // Write data
        @(posedge CLK);
        #1;
        A0 = 1'b1;
        DIN = data;
        WRn = 1'b0;
        @(posedge CLK);
        #1;
        WRn = 1'b1;
        A0 = 1'b0;
    end
endtask

//-------------------------------------------------------------------------
// Read Register:
// Latch address, then read data.
//-------------------------------------------------------------------------
task read_reg;
    input [3:0] reg_addr;
    output [7:0] data;
    begin
        // Latch address
        @(posedge CLK);
        #1;
        A0 = 1'b0;
        DIN = {4'd0, reg_addr};
        WRn = 1'b0;
        @(posedge CLK);
        #1;
        WRn = 1'b1;

        // Read data
        @(posedge CLK);
        #1;
        A0 = 1'b0;
        RDn = 1'b0;
        @(posedge CLK);
        #1;
        data = DOUT;
        RDn = 1'b1;
    end
endtask

//-------------------------------------------------------------------------
// System Reset:
//-------------------------------------------------------------------------
task reset_system;
    begin
        RESETn = 1'b0;
        CEN = 0;
        A0 = 0;
        WRn = 1'b1;
        RDn = 1'b1;
        DIN = 8'h00;
        #100;
        RESETn = 1'b1;
        #50;
        cycle();
    end
endtask

//-------------------------------------------------------------------------
// Value Check:
//-------------------------------------------------------------------------
task check;
    input [31:0]      got;
    input [31:0]      expected;
    input [8*160-1:0] name;
    begin
        total_tests = total_tests + 1;
        if(got === expected) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s = %0h", name, got);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s - Expected: %0h, Got: %0h", name, expected, got);
        end
    end
endtask

//-------------------------------------------------------------------------
// Count Tone Toggles:
// Counts how many times the tone state toggles over N cycles.
//-------------------------------------------------------------------------
task count_toggles;
    input integer n_cycles;
    output integer toggles;
    reg prev_state;
    integer c;
    begin
        prev_state = uut.u_tone_a.state;
        toggles = 0;
        for(c = 0; c < n_cycles; c = c + 1) begin
            cycle();
            if(uut.u_tone_a.state != prev_state) begin
                toggles = toggles + 1;
                prev_state = uut.u_tone_a.state;
            end
        end
    end
endtask

//=========================================================================
// Main Test Sequence:
//=========================================================================
initial begin
    $display("============================================================");
    $display("  tb_x8910 - GI AY-3-8910 Comprehensive Testbench");
    $display("============================================================");

    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;

    reset_system();

    //=====================================================================
    // REG SECTION A.1: Register Bus Protocol
    // Verify latch/write/read protocol and register bit masking.
    //=====================================================================
    $display("\n=== REG SECTION A.1: Register Bus Protocol ===\n");

    // Write and read back R0 (full 8-bit)
    write_reg(4'd0, 8'hAB);
    begin : read_r0
        reg [7:0] rdata;
        read_reg(4'd0, rdata);
        check(rdata, 8'hAB, "A.1 R0 write/read = $AB");
    end

    // Write and read R1 (only [3:0] valid, upper bits masked)
    write_reg(4'd1, 8'hFF);
    begin : read_r1
        reg [7:0] rdata;
        read_reg(4'd1, rdata);
        check(rdata, 8'h0F, "A.1 R1 read mask [3:0]");
    end

    // R3 mask (same as R1)
    write_reg(4'd3, 8'hFF);
    begin : read_r3
        reg [7:0] rdata;
        read_reg(4'd3, rdata);
        check(rdata, 8'h0F, "A.1 R3 read mask [3:0]");
    end

    // R5 mask (same as R1)
    write_reg(4'd5, 8'hFF);
    begin : read_r5
        reg [7:0] rdata;
        read_reg(4'd5, rdata);
        check(rdata, 8'h0F, "A.1 R5 read mask [3:0]");
    end

    // Write and read R6 (only [4:0] valid)
    write_reg(4'd6, 8'hFF);
    begin : read_r6
        reg [7:0] rdata;
        read_reg(4'd6, rdata);
        check(rdata, 8'h1F, "A.1 R6 read mask [4:0]");
    end

    // R7 full 8-bit read/write
    write_reg(4'd7, 8'hA5);
    begin : read_r7_wr
        reg [7:0] rdata;
        read_reg(4'd7, rdata);
        check(rdata, 8'hA5, "A.1 R7 write/read = $A5");
    end

    // R8 mask (only [4:0] valid)
    write_reg(4'd8, 8'hFF);
    begin : read_r8
        reg [7:0] rdata;
        read_reg(4'd8, rdata);
        check(rdata, 8'h1F, "A.1 R8 read mask [4:0]");
    end

    // R9 mask
    write_reg(4'd9, 8'hFF);
    begin : read_r9
        reg [7:0] rdata;
        read_reg(4'd9, rdata);
        check(rdata, 8'h1F, "A.1 R9 read mask [4:0]");
    end

    // R10 mask
    write_reg(4'd10, 8'hFF);
    begin : read_r10
        reg [7:0] rdata;
        read_reg(4'd10, rdata);
        check(rdata, 8'h1F, "A.1 R10 read mask [4:0]");
    end

    // R13 mask (only [3:0] valid)
    write_reg(4'd13, 8'hFF);
    begin : read_r13
        reg [7:0] rdata;
        read_reg(4'd13, rdata);
        check(rdata, 8'h0F, "A.1 R13 read mask [3:0]");
    end

    // R7 default after reset (all disabled = $FF)
    reset_system();
    begin : read_r7_rst
        reg [7:0] rdata;
        read_reg(4'd7, rdata);
        check(rdata, 8'hFF, "A.1 R7 reset default = $FF");
    end

    // R0 default after reset (should be 0)
    begin : read_r0_rst
        reg [7:0] rdata;
        read_reg(4'd0, rdata);
        check(rdata, 8'h00, "A.1 R0 reset default = $00");
    end

    //=====================================================================
    // TONE SECTION B.1: Tone Generators
    // Verify tone counter toggles and period affects toggle rate.
    // f_T = f_clock / (16 * TP), master /8 + toggle /2 = /16
    //=====================================================================
    $display("\n=== TONE SECTION B.1: Tone Generators ===\n");

    reset_system();

    // Channel A period 1 (fastest)
    write_reg(4'd0, 8'h01);
    write_reg(4'd1, 8'h00);
    write_reg(4'd7, 8'h3E);  // Enable tone A only
    write_reg(4'd8, 8'h0F);

    run_cycles(32);
    begin : tone_a_check
        reg prev_state;
        reg toggled;
        prev_state = uut.u_tone_a.state;
        toggled = 0;
        for(i = 0; i < 32; i = i + 1) begin
            cycle();
            if(uut.u_tone_a.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_a.state;
            end
        end
        check(toggled, 1, "B.1 Tone A toggling (period=1)");
    end

    // Channel B period 2
    write_reg(4'd2, 8'h02);
    write_reg(4'd3, 8'h00);
    write_reg(4'd7, 8'h3D);  // Enable tone B
    write_reg(4'd9, 8'h0F);

    run_cycles(32);
    begin : tone_b_check
        reg prev_state;
        reg toggled;
        prev_state = uut.u_tone_b.state;
        toggled = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(uut.u_tone_b.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_b.state;
            end
        end
        check(toggled, 1, "B.1 Tone B toggling (period=2)");
    end

    // Channel C period 4
    write_reg(4'd4, 8'h04);
    write_reg(4'd5, 8'h00);
    write_reg(4'd7, 8'h3B);  // Enable tone C
    write_reg(4'd10, 8'h0F);

    run_cycles(32);
    begin : tone_c_check
        reg prev_state;
        reg toggled;
        prev_state = uut.u_tone_c.state;
        toggled = 0;
        for(i = 0; i < 128; i = i + 1) begin
            cycle();
            if(uut.u_tone_c.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_c.state;
            end
        end
        check(toggled, 1, "B.1 Tone C toggling (period=4)");
    end

    // Period affects rate: period 1 should toggle faster than period 4
    // Count toggles over same window for A (period=1) vs C (period=4)
    reset_system();
    write_reg(4'd0, 8'h01);  // A period = 1
    write_reg(4'd1, 8'h00);
    write_reg(4'd4, 8'h04);  // C period = 4
    write_reg(4'd5, 8'h00);
    write_reg(4'd7, 8'h38);  // Enable all tone
    write_reg(4'd8, 8'h0F);
    write_reg(4'd10, 8'h0F);

    run_cycles(16); // Let generators stabilize
    begin : tone_rate_check
        integer toggles_a, toggles_c;
        reg prev_a, prev_c;
        toggles_a = 0;
        toggles_c = 0;
        prev_a = uut.u_tone_a.state;
        prev_c = uut.u_tone_c.state;
        for(i = 0; i < 256; i = i + 1) begin
            cycle();
            if(uut.u_tone_a.state != prev_a) begin
                toggles_a = toggles_a + 1;
                prev_a = uut.u_tone_a.state;
            end
            if(uut.u_tone_c.state != prev_c) begin
                toggles_c = toggles_c + 1;
                prev_c = uut.u_tone_c.state;
            end
        end
        check(toggles_a > toggles_c, 1, "B.1 Period 1 faster than period 4");
    end

    // Period 0 same as period 1 (per datasheet)
    reset_system();
    write_reg(4'd0, 8'h00);  // Period = 0
    write_reg(4'd1, 8'h00);
    write_reg(4'd7, 8'h3E);
    write_reg(4'd8, 8'h0F);
    run_cycles(16);
    begin : tone_p0_check
        reg prev_state;
        reg toggled;
        prev_state = uut.u_tone_a.state;
        toggled = 0;
        for(i = 0; i < 32; i = i + 1) begin
            cycle();
            if(uut.u_tone_a.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_a.state;
            end
        end
        check(toggled, 1, "B.1 Period 0 produces output");
    end

    //=====================================================================
    // NOISE SECTION C.1: Noise Generator
    // Verify LFSR activity and period control.
    //=====================================================================
    $display("\n=== NOISE SECTION C.1: Noise Generator ===\n");

    reset_system();

    // Set noise period to 1 (fastest)
    write_reg(4'd6, 8'h01);
    write_reg(4'd7, 8'h07);  // Disable all tone, enable all noise
    write_reg(4'd8, 8'h0F);

    // Run enough cycles for LFSR to shift
    run_cycles(256);

    // LFSR should not be zero after running
    check(uut.u_noise.lfsr != 17'd0, 1, "C.1 LFSR active (non-zero)");

    // Verify noise output changes over time
    begin : noise_change
        reg prev_out;
        reg changed;
        prev_out = uut.u_noise.out;
        changed = 0;
        for(i = 0; i < 512; i = i + 1) begin
            cycle();
            if(uut.u_noise.out != prev_out) begin
                changed = 1;
                prev_out = uut.u_noise.out;
            end
        end
        check(changed, 1, "C.1 Noise output changing");
    end

    // Noise period affects rate: period 1 should shift faster than period 16
    reset_system();
    write_reg(4'd6, 8'h01);  // Period = 1
    write_reg(4'd7, 8'h07);
    write_reg(4'd8, 8'h0F);
    run_cycles(64);
    begin : noise_rate
        integer changes_fast, changes_slow;
        reg prev_out;

        // Count changes at period 1
        prev_out = uut.u_noise.out;
        changes_fast = 0;
        for(i = 0; i < 512; i = i + 1) begin
            cycle();
            if(uut.u_noise.out != prev_out) begin
                changes_fast = changes_fast + 1;
                prev_out = uut.u_noise.out;
            end
        end

        // Switch to period 16
        write_reg(4'd6, 8'h10);
        run_cycles(64);
        prev_out = uut.u_noise.out;
        changes_slow = 0;
        for(i = 0; i < 512; i = i + 1) begin
            cycle();
            if(uut.u_noise.out != prev_out) begin
                changes_slow = changes_slow + 1;
                prev_out = uut.u_noise.out;
            end
        end

        check(changes_fast > changes_slow, 1, "C.1 Noise: period 1 faster than 16");
    end

    //=====================================================================
    // MIX SECTION D.1: Mixer
    // Verify all tone/noise enable/disable combinations.
    // Mixer: (ToneOn | ToneDisable) & (NoiseOn | NoiseDisable)
    //=====================================================================
    $display("\n=== MIX SECTION D.1: Mixer ===\n");

    reset_system();

    // Both disabled (tone_dis=1, noise_dis=1): output HIGH (bypass)
    write_reg(4'd7, 8'h3F);  // All disabled
    write_reg(4'd8, 8'h0F);  // Channel A max
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(AOUT != 8'd0, 1, "D.1 Mixer: both dis -> bypass");

    // Tone only enabled (tone_dis=0, noise_dis=1)
    write_reg(4'd0, 8'h01);
    write_reg(4'd1, 8'h00);
    write_reg(4'd7, 8'h38);  // Tone enabled, noise disabled
    run_cycles(64);
    check(AOUT != 8'd0, 1, "D.1 Mixer: tone only -> active");

    // Noise only enabled (tone_dis=1, noise_dis=0)
    reset_system();
    write_reg(4'd6, 8'h01);
    write_reg(4'd7, 8'h07);  // Tone disabled, noise enabled
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(256);
    begin : mixer_noise_only
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 256; i = i + 1) begin
            cycle();
            if(AOUT != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "D.1 Mixer: noise only -> active");
    end

    // Both enabled (tone_dis=0, noise_dis=0): AND of tone and noise
    reset_system();
    write_reg(4'd0, 8'h01);
    write_reg(4'd1, 8'h00);
    write_reg(4'd6, 8'h01);
    write_reg(4'd7, 8'h00);  // All enabled
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(256);
    begin : mixer_both
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 256; i = i + 1) begin
            cycle();
            if(AOUT != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "D.1 Mixer: tone+noise -> active");
    end

    // All disabled, amplitude 0: silence
    reset_system();
    write_reg(4'd7, 8'h3F);
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(AOUT, 8'd0, "D.1 Mixer: all amp=0 -> silence");

    //=====================================================================
    // AMP SECTION E.1: D/A Levels
    // Verify fixed amplitude levels and per-channel DAC output.
    //=====================================================================
    $display("\n=== AMP SECTION E.1: D/A Levels ===\n");

    reset_system();
    write_reg(4'd7, 8'h3F);  // All disabled -> mixer bypass

    // Channel A level 15 (max), B and C off
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(AOUT, 8'd63, "E.1 DAC: A=15 -> 63");

    // Channel A off, B level 15
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h0F);
    run_cycles(16);
    check(AOUT, 8'd63, "E.1 DAC: B=15 -> 63");

    // Channel B off, C level 15
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h0F);
    run_cycles(16);
    check(AOUT, 8'd63, "E.1 DAC: C=15 -> 63");

    // All channels off
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(AOUT, 8'd0, "E.1 DAC: all off -> 0");

    // Level 11 (256 -> 16)
    write_reg(4'd8, 8'h0B);
    run_cycles(16);
    check(AOUT, 8'd16, "E.1 DAC: level 11 -> 16");

    // Level 7 (64 -> 4)
    write_reg(4'd8, 8'h07);
    run_cycles(16);
    check(AOUT, 8'd4, "E.1 DAC: level 7 -> 4");

    // Level 1 (8 -> 0, below rounding threshold)
    write_reg(4'd8, 8'h01);
    run_cycles(16);
    check(AOUT, 8'd0, "E.1 DAC: level 1 -> 0");

    //=====================================================================
    // ENV SECTION F.1: Envelope Generator
    // Verify all 10 envelope shapes and restart behavior.
    // Envelope shapes per Data Manual Fig. 7.
    //=====================================================================
    $display("\n=== ENV SECTION F.1: Envelope Generator ===\n");

    reset_system();
    write_reg(4'd11, 8'h01);  // Envelope period = 1 (fastest)
    write_reg(4'd12, 8'h00);
    write_reg(4'd7, 8'h3F);   // Mixer bypass
    write_reg(4'd8, 8'h10);   // Channel A uses envelope (M=1)
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);

    // Shape $00: Continue=0, Attack=0 -> decay, hold at 0 (\___)
    write_reg(4'd13, 8'h00);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "F.1 Shape $00: stopped");
    check(uut.u_envelope.out, 4'd0, "F.1 Shape $00: held at 0");

    // Shape $04: Continue=0, Attack=1 -> attack, hold at 0 (/___)
    write_reg(4'd13, 8'h04);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "F.1 Shape $04: stopped");

    // Shape $08: Continue=1, Attack=0, Alt=0, Hold=0 -> repeating decay (\\\\)
    write_reg(4'd13, 8'h08);
    run_cycles(64);
    begin : shape_08
        reg [3:0] prev_env;
        reg changed;
        prev_env = uut.u_envelope.out;
        changed = 0;
        for(i = 0; i < 512; i = i + 1) begin
            cycle();
            if(uut.u_envelope.out != prev_env) begin
                changed = 1;
                prev_env = uut.u_envelope.out;
            end
        end
        check(changed, 1, "F.1 Shape $08: repeating (output changes)");
    end

    // Shape $09: Continue=1, Attack=0, Alt=0, Hold=1 -> decay, hold at 0 (\___)
    write_reg(4'd13, 8'h09);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "F.1 Shape $09: hold stopped");

    // Shape $0A: Continue=1, Attack=0, Alt=1, Hold=0 -> alternating (\\/\\/)
    write_reg(4'd13, 8'h0A);
    run_cycles(64);
    begin : shape_0a
        reg [3:0] prev_env;
        reg changed;
        prev_env = uut.u_envelope.out;
        changed = 0;
        for(i = 0; i < 512; i = i + 1) begin
            cycle();
            if(uut.u_envelope.out != prev_env) begin
                changed = 1;
                prev_env = uut.u_envelope.out;
            end
        end
        check(changed, 1, "F.1 Shape $0A: alternating (output changes)");
    end

    // Shape $0B: Continue=1, Attack=0, Alt=1, Hold=1 -> decay, hold at max (\---)
    write_reg(4'd13, 8'h0B);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "F.1 Shape $0B: hold stopped");
    // After decay+hold at max, invert should have toggled
    check(uut.u_envelope.out, 4'd15, "F.1 Shape $0B: held at max");

    // Shape $0C: Continue=1, Attack=1, Alt=0, Hold=0 -> repeating attack (////)
    write_reg(4'd13, 8'h0C);
    run_cycles(16);
    check(uut.u_envelope.invert, 1'b0, "F.1 Shape $0C: attack (invert=0)");
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b0, "F.1 Shape $0C: not stopped (repeat)");

    // Shape $0D: Continue=1, Attack=1, Alt=0, Hold=1 -> attack, hold at max (/---)
    write_reg(4'd13, 8'h0D);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "F.1 Shape $0D: hold stopped");
    check(uut.u_envelope.out, 4'd15, "F.1 Shape $0D: held at max");

    // Shape $0E: Continue=1, Attack=1, Alt=1, Hold=0 -> alternating (/\\/\\)
    write_reg(4'd13, 8'h0E);
    run_cycles(64);
    begin : shape_0e
        reg [3:0] prev_env;
        reg changed;
        prev_env = uut.u_envelope.out;
        changed = 0;
        for(i = 0; i < 512; i = i + 1) begin
            cycle();
            if(uut.u_envelope.out != prev_env) begin
                changed = 1;
                prev_env = uut.u_envelope.out;
            end
        end
        check(changed, 1, "F.1 Shape $0E: alternating (output changes)");
    end

    // Shape $0F: Continue=1, Attack=1, Alt=1, Hold=1 -> attack, hold at 0 (/___)
    write_reg(4'd13, 8'h0F);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "F.1 Shape $0F: hold stopped");
    check(uut.u_envelope.out, 4'd0, "F.1 Shape $0F: held at 0");

    // Restart: writing R13 clears stop flag
    write_reg(4'd13, 8'h09);  // Hold shape
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "F.1 Restart: stopped before");
    write_reg(4'd13, 8'h09);  // Write again
    run_cycles(4);
    check(uut.u_envelope.stop, 1'b0, "F.1 Restart: clears stop");

    // Envelope with different period (slower stepping)
    reset_system();
    write_reg(4'd11, 8'h10);  // Period = 16
    write_reg(4'd12, 8'h00);
    write_reg(4'd7, 8'h3F);
    write_reg(4'd8, 8'h10);   // M=1
    write_reg(4'd13, 8'h0C);  // Repeating attack
    run_cycles(16);
    begin : env_slow
        // Counter should still be near 0 with slow period
        check(uut.u_envelope.step < 4'd8, 1, "F.1 Slow period: counter < 8");
    end

    //=====================================================================
    // OUT SECTION G.1: Audio Output
    // Verify channel summing, isolation, and output range.
    //=====================================================================
    $display("\n=== OUT SECTION G.1: Audio Output ===\n");

    reset_system();
    write_reg(4'd7, 8'h3F);  // Mixer bypass

    // All 3 channels at max = 191
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h0F);
    write_reg(4'd10, 8'h0F);
    run_cycles(16);
    check(AOUT, 8'd191, "G.1 3ch max -> 191");

    // All channels off = 0
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(AOUT, 8'd0, "G.1 All off -> 0");

    // Channel isolation: only A contributes
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    begin : iso_a
        reg [7:0] a_only;
        a_only = AOUT;
        check(a_only, 8'd63, "G.1 A only -> 63");
    end

    // Channel isolation: only B contributes
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h0F);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(AOUT, 8'd63, "G.1 B only -> 63");

    // Channel isolation: only C contributes
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h0F);
    run_cycles(16);
    check(AOUT, 8'd63, "G.1 C only -> 63");

    // Two channels summed
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h0F);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    // Expected: 2 * 1023 = 2046, 2046 >> 4 = 127
    check(AOUT, 8'd127, "G.1 A+B -> 127");

    //=====================================================================
    // WRITE SECTION H.1: Writes While Active
    // Verify registers can be updated during active generation.
    //=====================================================================
    $display("\n=== WRITE SECTION H.1: Writes While Active ===\n");

    reset_system();

    // Start with tone A at period 4, max volume
    write_reg(4'd0, 8'h04);
    write_reg(4'd1, 8'h00);
    write_reg(4'd7, 8'h3E);
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(64);

    // Change amplitude while running
    write_reg(4'd8, 8'h00);
    run_cycles(32);
    begin : wwa_amp
        // After setting amp to 0, when tone is low output should be 0
        reg seen_zero;
        seen_zero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(AOUT == 8'd0) seen_zero = 1;
        end
        check(seen_zero, 1, "H.1 Amp change while active");
    end

    // Change period while running
    write_reg(4'd8, 8'h0F);  // Restore amplitude
    run_cycles(32);
    write_reg(4'd0, 8'h01);  // Change period to 1
    run_cycles(16);
    begin : wwa_period
        reg toggled;
        reg prev_state;
        prev_state = uut.u_tone_a.state;
        toggled = 0;
        for(i = 0; i < 32; i = i + 1) begin
            cycle();
            if(uut.u_tone_a.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_a.state;
            end
        end
        check(toggled, 1, "H.1 Period change while active");
    end

    // Switch from fixed to envelope while running
    write_reg(4'd11, 8'h01);
    write_reg(4'd12, 8'h00);
    write_reg(4'd13, 8'h0C);  // Repeating attack
    write_reg(4'd8, 8'h10);   // Switch to envelope
    run_cycles(64);
    check(uut.u_envelope.stop, 1'b0, "H.1 Env switch while active");

    //---------------------------------------------------------------------
    // Summary
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display("  tb_x8910 results: %0d / %0d passed (%0d failed)",
             passed_tests, total_tests, failed_tests);
    $display("=========================================================");
    if(failed_tests == 0) $display("  ALL TESTS PASSED");
    else                  $display("  *** %0d FAILURE(S) ***", failed_tests);
    $display("");
    $stop;
end

endmodule
