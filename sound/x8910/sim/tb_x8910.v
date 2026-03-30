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
//  Comprehensive testbench for the AY-3-8910 PSG implementation.
//
//  Verifies register access, tone generation, noise generation, envelope
//  shapes, mixer logic, and D/A output against the GI AY-3-8910/8912
//  PSG Data Manual and lvd reverse-engineered schematic.
//
//  Test Organization:
//    Section 1:  Register bus protocol (latch, write, read, masking)
//    Section 2:  Tone generator (period, frequency, all 3 channels)
//    Section 3:  Noise generator (LFSR activity, period control)
//    Section 4:  Mixer logic (all tone/noise combinations)
//    Section 5:  Amplitude control (fixed levels, per-channel DAC)
//    Section 6:  Envelope generator (all 10 shapes, restart)
//    Section 7:  Master output (channel summing, isolation)
//    Section 8:  Register write-while-active behavior
//
//  Reference: GI AY-3-8910/8912 Datasheet (8 pages)
//             GI AY-3-8910/8912 PSG Data Manual (62 pages, Feb 1979)
//             lvd Reverse Engineered AY-3-8910 Schematic (2019)
//============================================================================
`timescale 1ns/1ps

module tb_x8910;

//=========================================================================
// Test Signals
//=========================================================================
reg        clk;
reg        cen;
reg        reset;
reg        a0;
reg        wr;
reg        rd;
reg  [7:0] din;
wire [7:0] dout;
wire [7:0] sndout;

//=========================================================================
// Test Infrastructure
//=========================================================================
integer total_tests;
integer passed_tests;
integer failed_tests;
integer i;

//=========================================================================
// DUT Instantiation
//=========================================================================
x8910 uut (
    .clk    ( clk    ),
    .cen    ( cen    ),
    .reset  ( reset  ),
    .a0     ( a0     ),
    .wr     ( wr     ),
    .rd     ( rd     ),
    .din    ( din    ),
    .dout   ( dout   ),
    .sndout ( sndout )
);

//=========================================================================
// Clock Generation:
// 10ns period (100MHz) for fast simulation.
//=========================================================================
initial clk = 0;
always #5 clk = ~clk;

//=========================================================================
// Helper Tasks
//=========================================================================

//-------------------------------------------------------------------------
// Single Clock Cycle with CEN:
//-------------------------------------------------------------------------
task cycle;
    begin
        @(posedge clk);
        #1 cen = 1;
        @(posedge clk);
        #1 cen = 0;
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
        @(posedge clk);
        #1;
        a0 = 1'b0;
        din = {4'd0, reg_addr};
        wr = 1'b1;
        @(posedge clk);
        #1;
        wr = 1'b0;

        // Write data
        @(posedge clk);
        #1;
        a0 = 1'b1;
        din = data;
        wr = 1'b1;
        @(posedge clk);
        #1;
        wr = 1'b0;
        a0 = 1'b0;
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
        @(posedge clk);
        #1;
        a0 = 1'b0;
        din = {4'd0, reg_addr};
        wr = 1'b1;
        @(posedge clk);
        #1;
        wr = 1'b0;

        // Read data
        @(posedge clk);
        #1;
        a0 = 1'b0;
        rd = 1'b1;
        @(posedge clk);
        #1;
        data = dout;
        rd = 1'b0;
    end
endtask

//-------------------------------------------------------------------------
// System Reset:
//-------------------------------------------------------------------------
task reset_system;
    begin
        reset = 1;
        cen = 0;
        a0 = 0;
        wr = 0;
        rd = 0;
        din = 8'h00;
        #100;
        reset = 0;
        #50;
        cycle();
    end
endtask

//-------------------------------------------------------------------------
// Value Check:
//-------------------------------------------------------------------------
task check;
    input [31:0] actual;
    input [31:0] expected;
    input [255:0] name;
    begin
        total_tests = total_tests + 1;
        if(actual === expected) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s = %h", name, actual);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s - Expected: %h, Got: %h", name, expected, actual);
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
        prev_state = uut.u_tone_A.state;
        toggles = 0;
        for(c = 0; c < n_cycles; c = c + 1) begin
            cycle();
            if(uut.u_tone_A.state != prev_state) begin
                toggles = toggles + 1;
                prev_state = uut.u_tone_A.state;
            end
        end
    end
endtask

//=========================================================================
// Main Test Sequence
//=========================================================================
initial begin
    $display("=============================================================");
    $display("  AY-3-8910 Comprehensive PSG Testbench");
    $display("  Reference: GI AY-3-8910/8912 PSG Data Manual");
    $display("=============================================================\n");

    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;

    reset_system();

    //=====================================================================
    // SECTION 1: Register Bus Protocol
    // Verify latch/write/read protocol and register bit masking.
    //=====================================================================
    $display("\n=== SECTION 1: Register Bus Protocol ===\n");

    // Write and read back R0 (full 8-bit)
    write_reg(4'd0, 8'hAB);
    begin : read_r0
        reg [7:0] rdata;
        read_reg(4'd0, rdata);
        check(rdata, 8'hAB, "R0 write/read = $AB");
    end

    // Write and read R1 (only [3:0] valid, upper bits masked)
    write_reg(4'd1, 8'hFF);
    begin : read_r1
        reg [7:0] rdata;
        read_reg(4'd1, rdata);
        check(rdata, 8'h0F, "R1 read mask [3:0]");
    end

    // R3 mask (same as R1)
    write_reg(4'd3, 8'hFF);
    begin : read_r3
        reg [7:0] rdata;
        read_reg(4'd3, rdata);
        check(rdata, 8'h0F, "R3 read mask [3:0]");
    end

    // R5 mask (same as R1)
    write_reg(4'd5, 8'hFF);
    begin : read_r5
        reg [7:0] rdata;
        read_reg(4'd5, rdata);
        check(rdata, 8'h0F, "R5 read mask [3:0]");
    end

    // Write and read R6 (only [4:0] valid)
    write_reg(4'd6, 8'hFF);
    begin : read_r6
        reg [7:0] rdata;
        read_reg(4'd6, rdata);
        check(rdata, 8'h1F, "R6 read mask [4:0]");
    end

    // R7 full 8-bit read/write
    write_reg(4'd7, 8'hA5);
    begin : read_r7_wr
        reg [7:0] rdata;
        read_reg(4'd7, rdata);
        check(rdata, 8'hA5, "R7 write/read = $A5");
    end

    // R8 mask (only [4:0] valid)
    write_reg(4'd8, 8'hFF);
    begin : read_r8
        reg [7:0] rdata;
        read_reg(4'd8, rdata);
        check(rdata, 8'h1F, "R8 read mask [4:0]");
    end

    // R9 mask
    write_reg(4'd9, 8'hFF);
    begin : read_r9
        reg [7:0] rdata;
        read_reg(4'd9, rdata);
        check(rdata, 8'h1F, "R9 read mask [4:0]");
    end

    // R10 mask
    write_reg(4'd10, 8'hFF);
    begin : read_r10
        reg [7:0] rdata;
        read_reg(4'd10, rdata);
        check(rdata, 8'h1F, "R10 read mask [4:0]");
    end

    // R13 mask (only [3:0] valid)
    write_reg(4'd13, 8'hFF);
    begin : read_r13
        reg [7:0] rdata;
        read_reg(4'd13, rdata);
        check(rdata, 8'h0F, "R13 read mask [3:0]");
    end

    // R7 default after reset (all disabled = $FF)
    reset_system();
    begin : read_r7_rst
        reg [7:0] rdata;
        read_reg(4'd7, rdata);
        check(rdata, 8'hFF, "R7 reset default = $FF");
    end

    // R0 default after reset (should be 0)
    begin : read_r0_rst
        reg [7:0] rdata;
        read_reg(4'd0, rdata);
        check(rdata, 8'h00, "R0 reset default = $00");
    end

    //=====================================================================
    // SECTION 2: Tone Generator
    // Verify tone counter toggles and period affects toggle rate.
    // f_T = f_clock / (16 * TP), master /8 + toggle /2 = /16
    //=====================================================================
    $display("\n=== SECTION 2: Tone Generator ===\n");

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
        prev_state = uut.u_tone_A.state;
        toggled = 0;
        for(i = 0; i < 32; i = i + 1) begin
            cycle();
            if(uut.u_tone_A.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_A.state;
            end
        end
        check(toggled, 1, "Tone A toggling (period=1)");
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
        prev_state = uut.u_tone_B.state;
        toggled = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(uut.u_tone_B.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_B.state;
            end
        end
        check(toggled, 1, "Tone B toggling (period=2)");
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
        prev_state = uut.u_tone_C.state;
        toggled = 0;
        for(i = 0; i < 128; i = i + 1) begin
            cycle();
            if(uut.u_tone_C.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_C.state;
            end
        end
        check(toggled, 1, "Tone C toggling (period=4)");
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
        prev_a = uut.u_tone_A.state;
        prev_c = uut.u_tone_C.state;
        for(i = 0; i < 256; i = i + 1) begin
            cycle();
            if(uut.u_tone_A.state != prev_a) begin
                toggles_a = toggles_a + 1;
                prev_a = uut.u_tone_A.state;
            end
            if(uut.u_tone_C.state != prev_c) begin
                toggles_c = toggles_c + 1;
                prev_c = uut.u_tone_C.state;
            end
        end
        check(toggles_a > toggles_c, 1, "Period 1 faster than period 4");
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
        prev_state = uut.u_tone_A.state;
        toggled = 0;
        for(i = 0; i < 32; i = i + 1) begin
            cycle();
            if(uut.u_tone_A.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_A.state;
            end
        end
        check(toggled, 1, "Period 0 produces output");
    end

    //=====================================================================
    // SECTION 3: Noise Generator
    // Verify LFSR activity and period control.
    //=====================================================================
    $display("\n=== SECTION 3: Noise Generator ===\n");

    reset_system();

    // Set noise period to 1 (fastest)
    write_reg(4'd6, 8'h01);
    write_reg(4'd7, 8'h07);  // Disable all tone, enable all noise
    write_reg(4'd8, 8'h0F);

    // Run enough cycles for LFSR to shift
    run_cycles(256);

    // LFSR should not be zero after running
    check(uut.u_noise.lfsr != 17'd0, 1, "LFSR active (non-zero)");

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
        check(changed, 1, "Noise output changing");
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

        check(changes_fast > changes_slow, 1, "Noise: period 1 faster than 16");
    end

    //=====================================================================
    // SECTION 4: Mixer Logic
    // Verify all tone/noise enable/disable combinations.
    // Mixer: (ToneOn | ToneDisable) & (NoiseOn | NoiseDisable)
    //=====================================================================
    $display("\n=== SECTION 4: Mixer Logic ===\n");

    reset_system();

    // Both disabled (tone_dis=1, noise_dis=1): output HIGH (bypass)
    write_reg(4'd7, 8'h3F);  // All disabled
    write_reg(4'd8, 8'h0F);  // Channel A max
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(sndout != 8'd0, 1, "Mixer: both dis -> bypass");

    // Tone only enabled (tone_dis=0, noise_dis=1)
    write_reg(4'd0, 8'h01);
    write_reg(4'd1, 8'h00);
    write_reg(4'd7, 8'h38);  // Tone enabled, noise disabled
    run_cycles(64);
    check(sndout != 8'd0, 1, "Mixer: tone only -> active");

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
            if(sndout != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "Mixer: noise only -> active");
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
            if(sndout != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "Mixer: tone+noise -> active");
    end

    // All disabled, amplitude 0: silence
    reset_system();
    write_reg(4'd7, 8'h3F);
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(sndout, 8'd0, "Mixer: all amp=0 -> silence");

    //=====================================================================
    // SECTION 5: Amplitude Control
    // Verify fixed amplitude levels and per-channel DAC output.
    //=====================================================================
    $display("\n=== SECTION 5: Amplitude Control ===\n");

    reset_system();
    write_reg(4'd7, 8'h3F);  // All disabled -> mixer bypass

    // Channel A level 15 (max), B and C off
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(sndout, 8'd63, "DAC: A=15 -> 63");

    // Channel A off, B level 15
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h0F);
    run_cycles(16);
    check(sndout, 8'd63, "DAC: B=15 -> 63");

    // Channel B off, C level 15
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h0F);
    run_cycles(16);
    check(sndout, 8'd63, "DAC: C=15 -> 63");

    // All channels off
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(sndout, 8'd0, "DAC: all off -> 0");

    // Level 11 (256 -> 16)
    write_reg(4'd8, 8'h0B);
    run_cycles(16);
    check(sndout, 8'd16, "DAC: level 11 -> 16");

    // Level 7 (64 -> 4)
    write_reg(4'd8, 8'h07);
    run_cycles(16);
    check(sndout, 8'd4, "DAC: level 7 -> 4");

    // Level 1 (8 -> 0, below rounding threshold)
    write_reg(4'd8, 8'h01);
    run_cycles(16);
    check(sndout, 8'd0, "DAC: level 1 -> 0");

    //=====================================================================
    // SECTION 6: Envelope Generator
    // Verify all 10 envelope shapes and restart behavior.
    // Envelope shapes per Data Manual Fig. 7.
    //=====================================================================
    $display("\n=== SECTION 6: Envelope Generator ===\n");

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
    check(uut.u_envelope.stop, 1'b1, "Shape $00: stopped");
    check(uut.u_envelope.out, 4'd0, "Shape $00: held at 0");

    // Shape $04: Continue=0, Attack=1 -> attack, hold at 0 (/___)
    write_reg(4'd13, 8'h04);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "Shape $04: stopped");

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
        check(changed, 1, "Shape $08: repeating (output changes)");
    end

    // Shape $09: Continue=1, Attack=0, Alt=0, Hold=1 -> decay, hold at 0 (\___)
    write_reg(4'd13, 8'h09);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "Shape $09: hold stopped");

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
        check(changed, 1, "Shape $0A: alternating (output changes)");
    end

    // Shape $0B: Continue=1, Attack=0, Alt=1, Hold=1 -> decay, hold at max (\---)
    write_reg(4'd13, 8'h0B);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "Shape $0B: hold stopped");
    // After decay+hold at max, invert should have toggled
    check(uut.u_envelope.out, 4'd15, "Shape $0B: held at max");

    // Shape $0C: Continue=1, Attack=1, Alt=0, Hold=0 -> repeating attack (////)
    write_reg(4'd13, 8'h0C);
    run_cycles(16);
    check(uut.u_envelope.invert, 1'b0, "Shape $0C: attack (invert=0)");
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b0, "Shape $0C: not stopped (repeat)");

    // Shape $0D: Continue=1, Attack=1, Alt=0, Hold=1 -> attack, hold at max (/---)
    write_reg(4'd13, 8'h0D);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "Shape $0D: hold stopped");
    check(uut.u_envelope.out, 4'd15, "Shape $0D: held at max");

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
        check(changed, 1, "Shape $0E: alternating (output changes)");
    end

    // Shape $0F: Continue=1, Attack=1, Alt=1, Hold=1 -> attack, hold at 0 (/___)
    write_reg(4'd13, 8'h0F);
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "Shape $0F: hold stopped");
    check(uut.u_envelope.out, 4'd0, "Shape $0F: held at 0");

    // Restart: writing R13 clears stop flag
    write_reg(4'd13, 8'h09);  // Hold shape
    run_cycles(512);
    check(uut.u_envelope.stop, 1'b1, "Restart: stopped before");
    write_reg(4'd13, 8'h09);  // Write again
    run_cycles(4);
    check(uut.u_envelope.stop, 1'b0, "Restart: clears stop");

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
        check(uut.u_envelope.env_counter < 4'd8, 1, "Slow period: counter < 8");
    end

    //=====================================================================
    // SECTION 7: Master Output
    // Verify channel summing, isolation, and output range.
    //=====================================================================
    $display("\n=== SECTION 7: Master Output ===\n");

    reset_system();
    write_reg(4'd7, 8'h3F);  // Mixer bypass

    // All 3 channels at max = 191
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h0F);
    write_reg(4'd10, 8'h0F);
    run_cycles(16);
    check(sndout, 8'd191, "3ch max -> 191");

    // All channels off = 0
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(sndout, 8'd0, "All off -> 0");

    // Channel isolation: only A contributes
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    begin : iso_a
        reg [7:0] a_only;
        a_only = sndout;
        check(a_only, 8'd63, "A only -> 63");
    end

    // Channel isolation: only B contributes
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h0F);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    check(sndout, 8'd63, "B only -> 63");

    // Channel isolation: only C contributes
    write_reg(4'd8, 8'h00);
    write_reg(4'd9, 8'h00);
    write_reg(4'd10, 8'h0F);
    run_cycles(16);
    check(sndout, 8'd63, "C only -> 63");

    // Two channels summed
    write_reg(4'd8, 8'h0F);
    write_reg(4'd9, 8'h0F);
    write_reg(4'd10, 8'h00);
    run_cycles(16);
    // Expected: 2 * 1023 = 2046, 2046 >> 4 = 127
    check(sndout, 8'd127, "A+B -> 127");

    //=====================================================================
    // SECTION 8: Register Write-While-Active
    // Verify registers can be updated during active generation.
    //=====================================================================
    $display("\n=== SECTION 8: Write-While-Active ===\n");

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
            if(sndout == 8'd0) seen_zero = 1;
        end
        check(seen_zero, 1, "Amp change while active");
    end

    // Change period while running
    write_reg(4'd8, 8'h0F);  // Restore amplitude
    run_cycles(32);
    write_reg(4'd0, 8'h01);  // Change period to 1
    run_cycles(16);
    begin : wwa_period
        reg toggled;
        reg prev_state;
        prev_state = uut.u_tone_A.state;
        toggled = 0;
        for(i = 0; i < 32; i = i + 1) begin
            cycle();
            if(uut.u_tone_A.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone_A.state;
            end
        end
        check(toggled, 1, "Period change while active");
    end

    // Switch from fixed to envelope while running
    write_reg(4'd11, 8'h01);
    write_reg(4'd12, 8'h00);
    write_reg(4'd13, 8'h0C);  // Repeating attack
    write_reg(4'd8, 8'h10);   // Switch to envelope
    run_cycles(64);
    check(uut.u_envelope.stop, 1'b0, "Env switch while active");

    //=====================================================================
    // Final Test Summary
    //=====================================================================
    $display("\n=============================================================");
    $display("  AY-3-8910 Comprehensive Test Results");
    $display("=============================================================");
    $display("  Total Tests:  %0d", total_tests);
    $display("  Passed:       %0d", passed_tests);
    $display("  Failed:       %0d", failed_tests);
    $display("=============================================================");

    if(failed_tests == 0) begin
        $display("  *** ALL TESTS PASSED ***");
    end else begin
        $display("  *** SOME TESTS FAILED ***");
    end

    $display("=============================================================\n");

    $stop;
end

endmodule
