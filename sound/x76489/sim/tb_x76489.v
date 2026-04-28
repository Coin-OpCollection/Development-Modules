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
//  Comprehensive testbench for the SN76489AN PSG implementation.
//
//  Verifies register access, tone generation, noise generation,
//  attenuation, and audio output against the TI SN76489AN datasheet.
//
//  Test Organization:
//    Section 1:  Register bus protocol (latch byte, data byte, addressing)
//    Section 2:  Tone generator (period, frequency, all 3 channels)
//    Section 3:  Noise generator (LFSR, white/periodic, shift rates)
//    Section 4:  Attenuation (2dB steps, OFF state)
//    Section 5:  Master output (channel summing, isolation)
//    Section 6:  Register write-while-active behavior
//
//  Reference: TI SN76489AN Datasheet (9 pages)
//============================================================================
`timescale 1ns/1ps

module tb_x76489;

//=========================================================================
// Test Signals
//=========================================================================
reg        clk;
reg        cen;
reg        reset;
reg        ce;
reg        we;
reg  [7:0] data;
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
x76489 uut (
    .clk    ( clk    ),
    .cen    ( cen    ),
    .reset  ( reset  ),
    .ce     ( ce     ),
    .we     ( we     ),
    .data   ( data   ),
    .sndout ( sndout )
);

//=========================================================================
// Clock Generation
//=========================================================================
initial clk = 0;
always #5 clk = ~clk;

//=========================================================================
// Helper Tasks
//=========================================================================

task cycle;
    begin
        @(posedge clk);
        #1 cen = 1;
        @(posedge clk);
        #1 cen = 0;
    end
endtask

task run_cycles;
    input integer n;
    integer c;
    begin
        for(c = 0; c < n; c = c + 1)
            cycle();
    end
endtask

//-------------------------------------------------------------------------
// Write Byte to SN76489:
// Set data, assert ce+we for one cen cycle.
//-------------------------------------------------------------------------
task write_byte;
    input [7:0] d;
    begin
        @(posedge clk);
        #1;
        data = d;
        ce = 1'b1;
        we = 1'b1;
        cen = 1'b1;
        @(posedge clk);
        #1;
        ce = 1'b0;
        we = 1'b0;
        cen = 1'b0;
    end
endtask

//-------------------------------------------------------------------------
// Write Tone Frequency (double byte):
// Channel 0-2, 10-bit frequency value.
//-------------------------------------------------------------------------
task write_tone_freq;
    input [1:0] channel;
    input [9:0] freq;
    begin
        // Latch byte: [1|R0 R1 R2|F6 F7 F8 F9]
        write_byte({1'b1, channel, 1'b0, freq[3:0]});
        // Data byte: [0|x|F0 F1 F2 F3 F4 F5]
        write_byte({1'b0, 1'b0, freq[9:4]});
    end
endtask

//-------------------------------------------------------------------------
// Write Attenuation (single byte):
// Channel 0-3, 4-bit attenuation.
//-------------------------------------------------------------------------
task write_attn;
    input [1:0] channel;
    input [3:0] attn;
    begin
        if(channel == 2'd3)
            write_byte({1'b1, 3'b111, attn}); // Noise attenuation
        else
            write_byte({1'b1, channel, 1'b1, attn});
    end
endtask

//-------------------------------------------------------------------------
// Write Noise Control:
//-------------------------------------------------------------------------
task write_noise_ctrl;
    input [2:0] ctrl; // {FB, NF1, NF0}
    begin
        write_byte({1'b1, 3'b110, 1'b0, ctrl});
    end
endtask

task reset_system;
    begin
        reset = 1;
        cen = 0;
        ce = 0;
        we = 0;
        data = 8'h00;
        #100;
        reset = 0;
        #50;
        cycle();
    end
endtask

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

//=========================================================================
// Main Test Sequence
//=========================================================================
initial begin
    $display("=============================================================");
    $display("  SN76489AN Comprehensive PSG Testbench");
    $display("  Reference: TI SN76489AN Datasheet");
    $display("=============================================================\n");

    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;

    //=====================================================================
    // SECTION 1: Register Bus Protocol
    //=====================================================================
    $display("\n=== SECTION 1: Register Bus Protocol ===\n");

    reset_system();

    // All attenuators should be OFF ($F) after reset
    check(uut.ch_attn[0], 4'hF, "Reset: ch0 attn = $F");
    check(uut.ch_attn[1], 4'hF, "Reset: ch1 attn = $F");
    check(uut.ch_attn[2], 4'hF, "Reset: ch2 attn = $F");
    check(uut.ch_attn[3], 4'hF, "Reset: ch3 attn = $F");

    // Write tone 1 frequency
    write_tone_freq(2'd0, 10'h1AB);
    check(uut.tone_freq[0], 10'h1AB, "Tone 1 freq = $1AB");

    // Write tone 2 frequency
    write_tone_freq(2'd1, 10'h0FF);
    check(uut.tone_freq[1], 10'h0FF, "Tone 2 freq = $0FF");

    // Write tone 3 frequency
    write_tone_freq(2'd2, 10'h200);
    check(uut.tone_freq[2], 10'h200, "Tone 3 freq = $200");

    // Write attenuations
    write_attn(2'd0, 4'd0);
    check(uut.ch_attn[0], 4'd0, "Ch0 attn = 0 (full)");

    write_attn(2'd1, 4'd5);
    check(uut.ch_attn[1], 4'd5, "Ch1 attn = 5 (-10dB)");

    write_attn(2'd3, 4'd15);
    check(uut.ch_attn[3], 4'd15, "Noise attn = $F (OFF)");

    // Write noise control
    write_noise_ctrl(3'b100); // White noise, N/512
    check(uut.noise_ctrl, 3'b100, "Noise ctrl = $4 (white)");

    //=====================================================================
    // SECTION 2: Tone Generator
    //=====================================================================
    $display("\n=== SECTION 2: Tone Generator ===\n");

    reset_system();

    // Tone 1 period 1 (fastest)
    write_tone_freq(2'd0, 10'd1);
    write_attn(2'd0, 4'd0); // Full volume

    run_cycles(64);
    begin : tone1_check
        reg prev_state;
        reg toggled;
        prev_state = uut.u_tone0.state;
        toggled = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(uut.u_tone0.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone0.state;
            end
        end
        check(toggled, 1, "Tone 1 toggling (period=1)");
    end

    // Tone 2 period 4
    write_tone_freq(2'd1, 10'd4);
    write_attn(2'd1, 4'd0);

    run_cycles(64);
    begin : tone2_check
        reg prev_state;
        reg toggled;
        prev_state = uut.u_tone1.state;
        toggled = 0;
        for(i = 0; i < 128; i = i + 1) begin
            cycle();
            if(uut.u_tone1.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone1.state;
            end
        end
        check(toggled, 1, "Tone 2 toggling (period=4)");
    end

    // Tone 3 period 8
    write_tone_freq(2'd2, 10'd8);
    write_attn(2'd2, 4'd0);

    run_cycles(64);
    begin : tone3_check
        reg prev_state;
        reg toggled;
        prev_state = uut.u_tone2.state;
        toggled = 0;
        for(i = 0; i < 256; i = i + 1) begin
            cycle();
            if(uut.u_tone2.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone2.state;
            end
        end
        check(toggled, 1, "Tone 3 toggling (period=8)");
    end

    // Period affects rate
    reset_system();
    write_tone_freq(2'd0, 10'd1);
    write_tone_freq(2'd2, 10'd8);
    write_attn(2'd0, 4'd0);
    write_attn(2'd2, 4'd0);
    run_cycles(32);
    begin : tone_rate
        integer toggles_1, toggles_3;
        reg prev_1, prev_3;
        toggles_1 = 0; toggles_3 = 0;
        prev_1 = uut.u_tone0.state;
        prev_3 = uut.u_tone2.state;
        for(i = 0; i < 512; i = i + 1) begin
            cycle();
            if(uut.u_tone0.state != prev_1) begin
                toggles_1 = toggles_1 + 1;
                prev_1 = uut.u_tone0.state;
            end
            if(uut.u_tone2.state != prev_3) begin
                toggles_3 = toggles_3 + 1;
                prev_3 = uut.u_tone2.state;
            end
        end
        check(toggles_1 > toggles_3, 1, "Period 1 faster than period 8");
    end

    //=====================================================================
    // SECTION 3: Noise Generator
    //=====================================================================
    $display("\n=== SECTION 3: Noise Generator ===\n");

    reset_system();

    // White noise, N/512 (needs many cycles: /16 prescaler * /32 counter = /512)
    write_noise_ctrl(3'b100);
    write_attn(2'd3, 4'd0);

    run_cycles(2048);
    // LFSR should not be at reset value
    check(uut.u_noise.lfsr != (1 << 14), 1, "LFSR shifted from reset");

    // Verify noise output changes
    begin : noise_change
        reg prev_out;
        reg changed;
        prev_out = uut.u_noise.out;
        changed = 0;
        for(i = 0; i < 8192; i = i + 1) begin
            cycle();
            if(uut.u_noise.out != prev_out) begin
                changed = 1;
                prev_out = uut.u_noise.out;
            end
        end
        check(changed, 1, "White noise output changing");
    end

    // Periodic noise
    write_noise_ctrl(3'b000);
    run_cycles(2048);
    begin : periodic_check
        reg prev_out;
        reg changed;
        prev_out = uut.u_noise.out;
        changed = 0;
        for(i = 0; i < 8192; i = i + 1) begin
            cycle();
            if(uut.u_noise.out != prev_out) begin
                changed = 1;
                prev_out = uut.u_noise.out;
            end
        end
        check(changed, 1, "Periodic noise output changing");
    end

    // LFSR restart on noise register write
    write_noise_ctrl(3'b100);
    run_cycles(4);
    check(uut.u_noise.lfsr, 15'h4000, "LFSR reset on write");

    // Noise driven by tone 3
    reset_system();
    write_tone_freq(2'd2, 10'd2); // Tone 3 fast period
    write_noise_ctrl(3'b111); // White noise, driven by tone 3
    write_attn(2'd3, 4'd0);
    run_cycles(1024);
    begin : noise_tone3
        reg prev_out;
        reg changed;
        prev_out = uut.u_noise.out;
        changed = 0;
        for(i = 0; i < 4096; i = i + 1) begin
            cycle();
            if(uut.u_noise.out != prev_out) begin
                changed = 1;
                prev_out = uut.u_noise.out;
            end
        end
        check(changed, 1, "Noise driven by tone 3");
    end

    //=====================================================================
    // SECTION 4: Attenuation
    //=====================================================================
    $display("\n=== SECTION 4: Attenuation ===\n");

    reset_system();

    // All channels OFF (attn=15): silence
    run_cycles(32);
    check(sndout, 8'd0, "All OFF -> silence");

    // Channel 0 full volume, others OFF, tone disabled -> mixer bypassed
    // Need tone toggling to produce output
    write_tone_freq(2'd0, 10'd1);
    write_attn(2'd0, 4'd0); // 0dB
    run_cycles(64);
    begin : attn_full
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(sndout != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "Ch0 0dB -> output active");
    end

    // Channel 0 OFF
    write_attn(2'd0, 4'd15);
    run_cycles(32);
    check(sndout, 8'd0, "Ch0 OFF -> silence");

    //=====================================================================
    // SECTION 5: Master Output
    //=====================================================================
    $display("\n=== SECTION 5: Master Output ===\n");

    reset_system();

    // Channel isolation: only ch0
    write_tone_freq(2'd0, 10'd1);
    write_attn(2'd0, 4'd0);
    run_cycles(64);
    begin : iso_ch0
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(sndout != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "Ch0 only -> active");
    end

    // Channel isolation: only ch1
    reset_system();
    write_tone_freq(2'd1, 10'd1);
    write_attn(2'd1, 4'd0);
    run_cycles(64);
    begin : iso_ch1
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(sndout != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "Ch1 only -> active");
    end

    // Channel isolation: only ch2
    reset_system();
    write_tone_freq(2'd2, 10'd1);
    write_attn(2'd2, 4'd0);
    run_cycles(64);
    begin : iso_ch2
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(sndout != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "Ch2 only -> active");
    end

    // Channel isolation: only noise
    reset_system();
    write_noise_ctrl(3'b100);
    write_attn(2'd3, 4'd0);
    run_cycles(2048);
    begin : iso_noise
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 8192; i = i + 1) begin
            cycle();
            if(sndout != 8'd0) seen_nonzero = 1;
        end
        check(seen_nonzero, 1, "Noise only -> active");
    end

    //=====================================================================
    // SECTION 6: Write-While-Active
    //=====================================================================
    $display("\n=== SECTION 6: Write-While-Active ===\n");

    reset_system();

    // Start tone, then change attenuation while running
    write_tone_freq(2'd0, 10'd4);
    write_attn(2'd0, 4'd0);
    run_cycles(128);
    write_attn(2'd0, 4'd15); // OFF
    run_cycles(64);
    begin : wwa_attn
        reg seen_zero;
        seen_zero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(sndout == 8'd0) seen_zero = 1;
        end
        check(seen_zero, 1, "Attn change while active");
    end

    // Change frequency while running
    write_attn(2'd0, 4'd0);
    run_cycles(64);
    write_tone_freq(2'd0, 10'd1); // Faster
    run_cycles(32);
    begin : wwa_freq
        reg toggled;
        reg prev_state;
        prev_state = uut.u_tone0.state;
        toggled = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(uut.u_tone0.state != prev_state) begin
                toggled = 1;
                prev_state = uut.u_tone0.state;
            end
        end
        check(toggled, 1, "Freq change while active");
    end

    //=====================================================================
    // Final Test Summary
    //=====================================================================
    $display("\n=============================================================");
    $display("  SN76489AN Comprehensive Test Results");
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
