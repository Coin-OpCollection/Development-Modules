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
//  Comprehensive testbench for the Texas Instruments SN76489AN digital
//  complex sound generator implementation.
//
//  Verifies the control registers through the chip bus: the attenuators
//  after reset, latch and data bytes for the tone frequencies, latch bytes
//  for the attenuations and the noise control; the three tone generators
//  and the rate set by the period; the noise generator in white and
//  periodic mode, the reseed on a noise control write and the tone 3 shift
//  source; the attenuators on AOUT; each channel alone on AOUT; and
//  attenuation and frequency writes while a tone plays.
//
//  DUT:
//    uut - x76489, the full chip on the bus
//  CLK has a 10 ns period. CEN is driven only by the bench: one pulse is
//  two CLK, CEN high on the first. A write holds CSn and WRn low with CEN
//  high for one CLK.
//
//  Test Organization:
//    REG Section A:   Attenuators after reset, tone frequency and
//                     attenuation writes, noise control write
//    TONE Section B:  Each tone generator toggling, period 1 faster than
//                     period 8
//    NOISE Section C: White and periodic noise, the reseed on a noise
//                     control write, tone 3 as the shift source
//    ATTN Section D:  All channels OFF, one channel at 0 dB, then OFF
//    MIX Section E:   Each channel alone on AOUT
//    WRITE Section F: Attenuation and frequency writes while a tone plays
//
//  Usage (from the IP root):
//    vlib work
//    vlog -quiet hdl/*.v sim/tb_x76489.v
//    vsim -quiet -c tb_x76489 -do "run -all; quit -f"
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Operation [p.2-5].
//============================================================================

`timescale 1ns/1ps

module tb_x76489;

//=========================================================================
// Test Signals:
// Clock, the clock enable and the chip pins.
//=========================================================================
reg        CLK;
reg        RESETn;
reg        CEN;
reg  [7:0] DIN;
reg        CSn;
reg        WRn;
wire [7:0] AOUT;

initial CLK = 1'b0;
always #5 CLK = ~CLK;

//=========================================================================
// Test Statistics:
//=========================================================================
integer total_tests;
integer passed_tests;
integer failed_tests;
integer i;

//=========================================================================
// Chip DUT:
//=========================================================================
x76489 uut (
    // Clock and Reset
    .CLK    ( CLK    ),
    .RESETn ( RESETn ),
    .CEN    ( CEN    ),

    // Control Interface
    .DIN    ( DIN    ),
    .CSn    ( CSn    ),
    .WRn    ( WRn    ),

    // Audio Output
    .AOUT   ( AOUT   )
);

//=========================================================================
// Helper Tasks:
//=========================================================================

//-------------------------------------------------------------------------
// Check Tasks:
// chk passes on a true condition; check compares two values and prints
// them in hex.
//-------------------------------------------------------------------------
task chk;
    input             cond;
    input [8*160-1:0] name;
    begin
        total_tests = total_tests + 1;
        if(cond === 1'b1) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s", name);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s", name);
        end
    end
endtask

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
// Clock Tasks:
// cycle is one CEN pulse; run_cycles is n of them.
//-------------------------------------------------------------------------
task cycle;
    begin
        @(posedge CLK);
        #1;
        CEN = 1'b1;
        @(posedge CLK);
        #1;
        CEN = 1'b0;
    end
endtask

task run_cycles;
    input integer n;
    integer c;
    begin
        for(c = 0; c < n; c = c + 1) cycle();
    end
endtask

//-------------------------------------------------------------------------
// Bus Tasks:
// write_byte holds CSn and WRn low with CEN high for one CLK.
// write_tone_freq is a latch byte [1 R0 R1 R2 F6 F7 F8 F9] and a data
// byte [0 x F0-F5] for tone 1-3 (channel 0-2); write_attn a latch byte
// [1 R0 R1 R2 A0-A3] for channel 0-3, 3 the noise; write_noise_ctrl a
// latch byte [1 1 1 0 x FB NF0 NF1] [p.4].
//-------------------------------------------------------------------------
task write_byte;
    input [7:0] d;
    begin
        @(posedge CLK);
        #1;
        DIN = d;
        CSn = 1'b0;
        WRn = 1'b0;
        CEN = 1'b1;
        @(posedge CLK);
        #1;
        CSn = 1'b1;
        WRn = 1'b1;
        CEN = 1'b0;
    end
endtask

task write_tone_freq;
    input [1:0] channel;
    input [9:0] freq;
    begin
        write_byte({1'b1, channel, 1'b0, freq[3:0]});
        write_byte({1'b0, 1'b0, freq[9:4]});
    end
endtask

task write_attn;
    input [1:0] channel;
    input [3:0] attn;
    begin
        if(channel == 2'd3) write_byte({1'b1, 3'b111, attn});
        else write_byte({1'b1, channel, 1'b1, attn});
    end
endtask

task write_noise_ctrl;
    input [2:0] ctrl; // {FB, NF0, NF1}
    begin
        write_byte({1'b1, 3'b110, 1'b0, ctrl});
    end
endtask

//-------------------------------------------------------------------------
// Chip Reset:
// RESETn low for 100 ns, then one CEN pulse.
//-------------------------------------------------------------------------
task reset_system;
    begin
        RESETn = 1'b0;
        CEN = 1'b0;
        CSn = 1'b1;
        WRn = 1'b1;
        DIN = 8'h00;
        #100;
        RESETn = 1'b1;
        #50;
        cycle();
    end
endtask

//=========================================================================
// Test Execution:
//=========================================================================
initial begin
    //---------------------------------------------------------------------
    // Initialize Stimulus:
    //---------------------------------------------------------------------
    total_tests  = 0;
    passed_tests = 0;
    failed_tests = 0;

    $display("============================================================");
    $display("  tb_x76489 - TI SN76489AN Comprehensive Testbench");
    $display("============================================================");

    //=====================================================================
    // REG SECTION A.1: Attenuators After Reset
    // Every attenuator is OFF after reset.
    //=====================================================================
    $display("\n=== REG SECTION A.1: Attenuators After Reset ===\n");

    reset_system();

    check(uut.ch_attn[0], 4'hF, "A.1 tone 1 attenuation OFF");
    check(uut.ch_attn[1], 4'hF, "A.1 tone 2 attenuation OFF");
    check(uut.ch_attn[2], 4'hF, "A.1 tone 3 attenuation OFF");
    check(uut.ch_attn[3], 4'hF, "A.1 noise attenuation OFF");

    //=====================================================================
    // REG SECTION A.2: Tone Frequency
    // A latch byte and a data byte load the 10-bit register.
    //=====================================================================
    $display("\n=== REG SECTION A.2: Tone Frequency ===\n");

    write_tone_freq(2'd0, 10'h1AB);
    check(uut.tone_freq[0], 10'h1AB, "A.2 tone 1 frequency 1ABH");

    write_tone_freq(2'd1, 10'h0FF);
    check(uut.tone_freq[1], 10'h0FF, "A.2 tone 2 frequency 0FFH");

    write_tone_freq(2'd2, 10'h200);
    check(uut.tone_freq[2], 10'h200, "A.2 tone 3 frequency 200H");

    //=====================================================================
    // REG SECTION A.3: Attenuation
    //=====================================================================
    $display("\n=== REG SECTION A.3: Attenuation ===\n");

    write_attn(2'd0, 4'd0);
    check(uut.ch_attn[0], 4'd0, "A.3 tone 1 attenuation 0 dB");

    write_attn(2'd1, 4'd5);
    check(uut.ch_attn[1], 4'd5, "A.3 tone 2 attenuation 10 dB");

    write_attn(2'd3, 4'd15);
    check(uut.ch_attn[3], 4'd15, "A.3 noise attenuation OFF");

    //=====================================================================
    // REG SECTION A.4: Noise Control
    //=====================================================================
    $display("\n=== REG SECTION A.4: Noise Control ===\n");

    write_noise_ctrl(3'b100);
    check(uut.noise_ctrl, 3'b100, "A.4 noise control white, N/512");

    //=====================================================================
    // TONE SECTION B.1: Tone Generators
    // Each tone output toggles with periods 1, 4 and 8.
    //=====================================================================
    $display("\n=== TONE SECTION B.1: Tone Generators ===\n");

    reset_system();

    write_tone_freq(2'd0, 10'd1);
    write_attn(2'd0, 4'd0);

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
        chk(toggled, "B.1 tone 1 toggling, period 1");
    end

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
        chk(toggled, "B.1 tone 2 toggling, period 4");
    end

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
        chk(toggled, "B.1 tone 3 toggling, period 8");
    end

    //=====================================================================
    // TONE SECTION B.2: Period and Rate
    // Period 1 toggles more often than period 8 over the same time.
    //=====================================================================
    $display("\n=== TONE SECTION B.2: Period and Rate ===\n");

    reset_system();
    write_tone_freq(2'd0, 10'd1);
    write_tone_freq(2'd2, 10'd8);
    write_attn(2'd0, 4'd0);
    write_attn(2'd2, 4'd0);
    run_cycles(32);
    begin : tone_rate
        integer toggles_1;
        integer toggles_3;
        reg prev_1;
        reg prev_3;
        toggles_1 = 0;
        toggles_3 = 0;
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
        chk(toggles_1 > toggles_3, "B.2 period 1 faster than period 8");
    end

    //=====================================================================
    // NOISE SECTION C.1: White Noise
    // At N/512 the register shifts every 512 CEN pulses.
    //=====================================================================
    $display("\n=== NOISE SECTION C.1: White Noise ===\n");

    reset_system();

    write_noise_ctrl(3'b100);
    write_attn(2'd3, 4'd0);

    run_cycles(2048);
    chk(uut.u_noise.lfsr != (1 << 14), "C.1 register shifted from the seed");

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
        chk(changed, "C.1 white noise output changing");
    end

    //=====================================================================
    // NOISE SECTION C.2: Periodic Noise
    //=====================================================================
    $display("\n=== NOISE SECTION C.2: Periodic Noise ===\n");

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
        chk(changed, "C.2 periodic noise output changing");
    end

    //=====================================================================
    // NOISE SECTION C.3: Reseed
    // A noise control write reseeds the register to 100...0, which the
    // data sheet calls clearing it [p.3].
    //=====================================================================
    $display("\n=== NOISE SECTION C.3: Reseed ===\n");

    write_noise_ctrl(3'b100);
    run_cycles(4);
    check(uut.u_noise.lfsr, 15'h4000, "C.3 noise control write reseeds 4000H");

    //=====================================================================
    // NOISE SECTION C.4: Tone 3 Shift Source
    // NF0, NF1 = 11 shifts the register on the tone 3 output.
    //=====================================================================
    $display("\n=== NOISE SECTION C.4: Tone 3 Shift Source ===\n");

    reset_system();
    write_tone_freq(2'd2, 10'd2);
    write_noise_ctrl(3'b111);
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
        chk(changed, "C.4 noise shifted by tone 3");
    end

    //=====================================================================
    // ATTN SECTION D.1: Attenuators on AOUT
    // All OFF is silence; tone 1 at 0 dB reaches AOUT; OFF again silences
    // it.
    //=====================================================================
    $display("\n=== ATTN SECTION D.1: Attenuators on AOUT ===\n");

    reset_system();

    run_cycles(32);
    check(AOUT, 8'd0, "D.1 all channels OFF, AOUT 0");

    write_tone_freq(2'd0, 10'd1);
    write_attn(2'd0, 4'd0);
    run_cycles(64);
    begin : attn_full
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(AOUT != 8'd0) seen_nonzero = 1;
        end
        chk(seen_nonzero, "D.1 tone 1 at 0 dB, AOUT active");
    end

    write_attn(2'd0, 4'd15);
    run_cycles(32);
    check(AOUT, 8'd0, "D.1 tone 1 OFF, AOUT 0");

    //=====================================================================
    // MIX SECTION E.1: Channels Alone
    // Each channel alone at 0 dB reaches AOUT.
    //=====================================================================
    $display("\n=== MIX SECTION E.1: Channels Alone ===\n");

    reset_system();

    write_tone_freq(2'd0, 10'd1);
    write_attn(2'd0, 4'd0);
    run_cycles(64);
    begin : iso_ch0
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(AOUT != 8'd0) seen_nonzero = 1;
        end
        chk(seen_nonzero, "E.1 tone 1 alone, AOUT active");
    end

    reset_system();
    write_tone_freq(2'd1, 10'd1);
    write_attn(2'd1, 4'd0);
    run_cycles(64);
    begin : iso_ch1
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(AOUT != 8'd0) seen_nonzero = 1;
        end
        chk(seen_nonzero, "E.1 tone 2 alone, AOUT active");
    end

    reset_system();
    write_tone_freq(2'd2, 10'd1);
    write_attn(2'd2, 4'd0);
    run_cycles(64);
    begin : iso_ch2
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(AOUT != 8'd0) seen_nonzero = 1;
        end
        chk(seen_nonzero, "E.1 tone 3 alone, AOUT active");
    end

    reset_system();
    write_noise_ctrl(3'b100);
    write_attn(2'd3, 4'd0);
    run_cycles(2048);
    begin : iso_noise
        reg seen_nonzero;
        seen_nonzero = 0;
        for(i = 0; i < 8192; i = i + 1) begin
            cycle();
            if(AOUT != 8'd0) seen_nonzero = 1;
        end
        chk(seen_nonzero, "E.1 noise alone, AOUT active");
    end

    //=====================================================================
    // WRITE SECTION F.1: Attenuation While Playing
    //=====================================================================
    $display("\n=== WRITE SECTION F.1: Attenuation While Playing ===\n");

    reset_system();

    write_tone_freq(2'd0, 10'd4);
    write_attn(2'd0, 4'd0);
    run_cycles(128);
    write_attn(2'd0, 4'd15);
    run_cycles(64);
    begin : wwa_attn
        reg seen_zero;
        seen_zero = 0;
        for(i = 0; i < 64; i = i + 1) begin
            cycle();
            if(AOUT == 8'd0) seen_zero = 1;
        end
        chk(seen_zero, "F.1 attenuation write while playing");
    end

    //=====================================================================
    // WRITE SECTION F.2: Frequency While Playing
    //=====================================================================
    $display("\n=== WRITE SECTION F.2: Frequency While Playing ===\n");

    write_attn(2'd0, 4'd0);
    run_cycles(64);
    write_tone_freq(2'd0, 10'd1);
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
        chk(toggled, "F.2 frequency write while playing");
    end

    //---------------------------------------------------------------------
    // Summary
    //---------------------------------------------------------------------
    $display("\n=========================================================");
    $display("  tb_x76489 results: %0d / %0d passed (%0d failed)",
             passed_tests, total_tests, failed_tests);
    $display("=========================================================");
    if(failed_tests == 0) $display("  ALL TESTS PASSED");
    else                  $display("  *** %0d FAILURE(S) ***", failed_tests);
    $display("");
    $stop;
end

endmodule
