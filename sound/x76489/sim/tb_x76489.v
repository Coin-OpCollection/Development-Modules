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
//  Verifies the control registers through the chip bus: the reset values,
//  latch and data bytes for the tone frequencies, latch bytes for the
//  attenuations and the noise control, and data bytes to an attenuation and
//  to the noise control; the three tone generators, the rate set by the
//  period and the exact half periods, n = 0 included; the noise generator
//  in white and periodic mode, the reseed, the tone 3 shift source, the
//  three shift rates and the sequence lengths; every attenuation level on
//  AOUT; each channel alone on AOUT; writes while a tone plays; and the
//  write transfer: READY, the load on the 32nd CEN pulse of the write, a
//  one-CLK write, a held write and a write during a transfer.
//
//  DUT:
//    uut - x76489, the full chip on the bus
//  CLK has a 10 ns period. CEN is driven only by the bench: one pulse is
//  two CLK, CEN high on the first. write_byte holds CSn and WRn low until
//  READY rises, as a CPU on the WAIT line does.
//
//  Test Organization:
//    REG Section A:   Reset values, tone frequency and attenuation writes,
//                     noise control write, a data byte to an attenuation
//                     and to the noise control
//    TONE Section B:  Each tone generator toggling, period 1 faster than
//                     period 8, half periods of n = 1, 2, 5 and 0
//    NOISE Section C: White and periodic noise, the reseed on a noise
//                     control write, tone 3 as the shift source, the
//                     N/512, N/1024 and N/2048 rates, the 32767 and 15
//                     shift sequences
//    ATTN Section D:  All channels OFF, one channel at 0 dB, then OFF; the
//                     AOUT peak of every attenuation
//    MIX Section E:   Each channel alone on AOUT
//    WRITE Section F: Attenuation and frequency writes while a tone plays
//    XFER Section G:  READY and the load on the 32nd CEN pulse of a write,
//                     a one-CLK write, a held write, a write during a
//                     transfer
//
//  Usage (from the IP root):
//    vlib work
//    vlog -quiet hdl/*.v sim/tb_x76489.v
//    vsim -quiet -c tb_x76489 -do "run -all; quit -f"
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Operation [p.2-5].
//             TI SN76494, SN76494A, SN76496, SN76496A Data Sheet D2801,
//             WE and READY, p. 4-40.
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
wire       READY;
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
integer n;
reg [8*160-1:0] tname;

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
    .READY  ( READY  ),

    // Audio Output
    .AOUT   ( AOUT   )
);

//=========================================================================
// Monitors:
// cen_total counts the CEN pulses of cycle(); shift_n counts the noise
// shifts, shift_gap is the CEN pulses between the last two; restart_n
// counts the noise reseeds the bus controller raises, restart_gap is the
// CEN pulses between the last two.
//=========================================================================
integer cen_total;
integer shift_n;
integer shift_gap;
integer shift_last;
integer restart_n;
integer restart_gap;
integer restart_last;

initial begin
    cen_total = 0;
    shift_n = 0;
    shift_gap = 0;
    shift_last = 0;
    restart_n = 0;
    restart_gap = 0;
    restart_last = 0;
end

always @(posedge CLK) begin
    if(uut.u_noise.shift) begin
        shift_gap = cen_total - shift_last;
        shift_last = cen_total;
        shift_n = shift_n + 1;
    end
    if(uut.u_host.restart) begin
        restart_gap = cen_total - restart_last;
        restart_last = cen_total;
        restart_n = restart_n + 1;
    end
end

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
        cen_total = cen_total + 1;
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
// write_byte holds CSn and WRn low, running CEN, until READY rises.
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
        #1;
        while(READY !== 1'b1) cycle();
        @(posedge CLK);
        #1;
        CSn = 1'b1;
        WRn = 1'b1;
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
// Measure Tasks:
// tone_half writes tone 1 period p, lets two toggles pass and returns in
// n the CEN pulses between the next two; noise_gap waits three noise
// shifts and returns in n the CEN pulses between the last two.
//-------------------------------------------------------------------------
task tone_half;
    input [9:0] p;
    reg prev;
    begin
        write_tone_freq(2'd0, p);
        prev = uut.u_tone0.state;
        while(uut.u_tone0.state == prev) cycle();
        prev = uut.u_tone0.state;
        while(uut.u_tone0.state == prev) cycle();
        prev = uut.u_tone0.state;
        n = 0;
        while(uut.u_tone0.state == prev) begin
            cycle();
            n = n + 1;
        end
    end
endtask

task noise_gap;
    integer s0;
    begin
        s0 = shift_n;
        while(shift_n < s0 + 3) cycle();
        n = shift_gap;
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
    // REG SECTION A.1: Reset Values
    // Every attenuator is OFF, each tone register 1, the noise control
    // white noise at N/512 and the address latch 000 after reset.
    //=====================================================================
    $display("\n=== REG SECTION A.1: Reset Values ===\n");

    reset_system();

    check(uut.u_host.ch_attn[0], 4'hF, "A.1 tone 1 attenuation OFF");
    check(uut.u_host.ch_attn[1], 4'hF, "A.1 tone 2 attenuation OFF");
    check(uut.u_host.ch_attn[2], 4'hF, "A.1 tone 3 attenuation OFF");
    check(uut.u_host.ch_attn[3], 4'hF, "A.1 noise attenuation OFF");
    check(uut.u_host.tone_freq[0], 10'd1, "A.1 tone 1 period 1");
    check(uut.u_host.tone_freq[1], 10'd1, "A.1 tone 2 period 1");
    check(uut.u_host.tone_freq[2], 10'd1, "A.1 tone 3 period 1");
    check(uut.u_host.noise_ctrl, 3'b100, "A.1 noise control white, N/512");
    check(uut.u_host.latch_reg, 3'b000, "A.1 address latch 000");
    check(READY, 1'b1, "A.1 READY high");

    //=====================================================================
    // REG SECTION A.2: Tone Frequency
    // A latch byte and a data byte load the 10-bit register.
    //=====================================================================
    $display("\n=== REG SECTION A.2: Tone Frequency ===\n");

    write_tone_freq(2'd0, 10'h1AB);
    check(uut.u_host.tone_freq[0], 10'h1AB, "A.2 tone 1 frequency 1ABH");

    write_tone_freq(2'd1, 10'h0FF);
    check(uut.u_host.tone_freq[1], 10'h0FF, "A.2 tone 2 frequency 0FFH");

    write_tone_freq(2'd2, 10'h200);
    check(uut.u_host.tone_freq[2], 10'h200, "A.2 tone 3 frequency 200H");

    //=====================================================================
    // REG SECTION A.3: Attenuation
    //=====================================================================
    $display("\n=== REG SECTION A.3: Attenuation ===\n");

    write_attn(2'd0, 4'd0);
    check(uut.u_host.ch_attn[0], 4'd0, "A.3 tone 1 attenuation 0 dB");

    write_attn(2'd1, 4'd5);
    check(uut.u_host.ch_attn[1], 4'd5, "A.3 tone 2 attenuation 10 dB");

    write_attn(2'd3, 4'd15);
    check(uut.u_host.ch_attn[3], 4'd15, "A.3 noise attenuation OFF");

    //=====================================================================
    // REG SECTION A.4: Noise Control
    //=====================================================================
    $display("\n=== REG SECTION A.4: Noise Control ===\n");

    write_noise_ctrl(3'b100);
    check(uut.u_host.noise_ctrl, 3'b100, "A.4 noise control white, N/512");

    //=====================================================================
    // REG SECTION A.5: Data Byte to an Attenuation
    // On the die every byte strobes the latched register.
    //=====================================================================
    $display("\n=== REG SECTION A.5: Data Byte to an Attenuation ===\n");

    write_attn(2'd1, 4'd5);
    write_byte(8'h09);
    check(uut.u_host.ch_attn[1], 4'd9, "A.5 data byte loads the latched tone 2 attenuation");

    //=====================================================================
    // REG SECTION A.6: Data Byte to the Noise Control
    // A data byte with the noise control latched loads FB, NF0 and NF1 and
    // reseeds the shift register.
    //=====================================================================
    $display("\n=== REG SECTION A.6: Data Byte to the Noise Control ===\n");

    write_noise_ctrl(3'b100);
    run_cycles(1100);
    chk(uut.u_noise.lfsr != 15'h4000, "A.6 register off the seed before the data byte");
    n = restart_n;
    write_byte(8'h03);
    run_cycles(1);
    check(uut.u_host.noise_ctrl, 3'b011, "A.6 data byte loads the latched noise control");
    check(restart_n - n, 1, "A.6 data byte reseeds the shift register");
    check(uut.u_noise.lfsr, 15'h4000, "A.6 register at the seed 4000H");

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
    // TONE SECTION B.3: Half Periods
    // The output holds for n prescaler steps, 16n CEN pulses; n = 0 holds
    // it for 1024 steps [p.2].
    //=====================================================================
    $display("\n=== TONE SECTION B.3: Half Periods ===\n");

    reset_system();
    tone_half(10'd1);
    check(n, 16, "B.3 n = 1 holds 16 CEN pulses");
    tone_half(10'd2);
    check(n, 32, "B.3 n = 2 holds 32 CEN pulses");
    tone_half(10'd5);
    check(n, 80, "B.3 n = 5 holds 80 CEN pulses");
    tone_half(10'd0);
    check(n, 16384, "B.3 n = 0 holds 16384 CEN pulses (1024 steps)");

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
    // NOISE SECTION C.5: Shift Rates
    // NF0, NF1 = 00, 01 and 10 shift every 512, 1024 and 2048 CEN pulses
    // (Table 3 [p.3]).
    //=====================================================================
    $display("\n=== NOISE SECTION C.5: Shift Rates ===\n");

    reset_system();
    write_noise_ctrl(3'b100);
    noise_gap();
    check(n, 512, "C.5 N/512 shifts every 512 CEN pulses");
    write_noise_ctrl(3'b101);
    noise_gap();
    check(n, 1024, "C.5 N/1024 shifts every 1024 CEN pulses");
    write_noise_ctrl(3'b110);
    noise_gap();
    check(n, 2048, "C.5 N/2048 shifts every 2048 CEN pulses");

    //=====================================================================
    // NOISE SECTION C.6: Sequence Lengths
    // From the seed, white noise returns to it after 32767 shifts and
    // periodic noise after 15, with the output high for one of them. Tone
    // 3 at n = 1 shifts the register every 32 CEN pulses.
    //=====================================================================
    $display("\n=== NOISE SECTION C.6: Sequence Lengths ===\n");

    reset_system();
    write_tone_freq(2'd2, 10'd1);
    write_noise_ctrl(3'b111);
    run_cycles(1);
    begin : white_len
        integer s0;
        s0 = shift_n;
        cycle();
        while(!(shift_n > s0 && uut.u_noise.lfsr == 15'h4000)) cycle();
        check(shift_n - s0, 32767, "C.6 white noise repeats after 32767 shifts");
    end

    write_noise_ctrl(3'b011);
    run_cycles(1);
    begin : periodic_len
        integer s0;
        integer last;
        integer ones;
        s0 = shift_n;
        last = shift_n;
        ones = 0;
        cycle();
        while(!(shift_n > s0 && uut.u_noise.lfsr == 15'h4000)) begin
            if(shift_n != last) begin
                last = shift_n;
                ones = ones + uut.u_noise.out;
            end
            cycle();
        end
        ones = ones + uut.u_noise.out;
        check(shift_n - s0, 15, "C.6 periodic noise repeats after 15 shifts");
        check(ones, 1, "C.6 periodic noise output high for one shift in 15");
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
    // ATTN SECTION D.2: Attenuation Levels
    // Tone 1 alone at every attenuation: AOUT peaks at its level, bits 9-4
    // of 1023 x 10^(-step / 10).
    //=====================================================================
    $display("\n=== ATTN SECTION D.2: Attenuation Levels ===\n");

    reset_system();
    write_tone_freq(2'd0, 10'd1);
    begin : attn_levels
        reg [7:0] peak [0:15];
        reg [7:0] mx;
        integer code;
        peak[0] = 8'd63;  peak[1] = 8'd50;  peak[2] = 8'd40;  peak[3] = 8'd32;
        peak[4] = 8'd25;  peak[5] = 8'd20;  peak[6] = 8'd16;  peak[7] = 8'd12;
        peak[8] = 8'd10;  peak[9] = 8'd8;   peak[10] = 8'd6;  peak[11] = 8'd5;
        peak[12] = 8'd4;  peak[13] = 8'd3;  peak[14] = 8'd2;  peak[15] = 8'd0;
        for(code = 0; code < 16; code = code + 1) begin
            write_attn(2'd0, code[3:0]);
            run_cycles(4);
            mx = 8'd0;
            for(i = 0; i < 64; i = i + 1) begin
                cycle();
                if(AOUT > mx) mx = AOUT;
            end
            if(code == 15) $sformat(tname, "D.2 attenuation 15 (OFF) peaks at %0d", peak[code]);
            else $sformat(tname, "D.2 attenuation %0d (%0d dB) peaks at %0d", code, code * 2, peak[code]);
            check(mx, peak[code], tname);
        end
    end

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

    //=====================================================================
    // XFER SECTION G.1: READY and the Load
    // READY falls as the write starts and rises with the byte loaded on
    // the 32nd CEN pulse of the write [p.5].
    //=====================================================================
    $display("\n=== XFER SECTION G.1: READY and the Load ===\n");

    reset_system();
    @(posedge CLK);
    #1;
    DIN = 8'h93;
    CSn = 1'b0;
    WRn = 1'b0;
    #1;
    check(READY, 1'b0, "G.1 READY low as the write starts");
    n = 0;
    while(READY !== 1'b1) begin
        if(n == 31) check(uut.u_host.ch_attn[0], 4'hF, "G.1 attenuation unchanged before the 32nd CEN pulse");
        cycle();
        n = n + 1;
    end
    check(n, 32, "G.1 READY high after 32 CEN pulses");
    @(posedge CLK);
    #1;
    CSn = 1'b1;
    WRn = 1'b1;
    check(uut.u_host.ch_attn[0], 4'd3, "G.1 byte loaded as READY rises");

    //=====================================================================
    // XFER SECTION G.2: One-CLK Write
    // A write released before its byte loads still loads the byte taken as
    // it started, 32 CEN pulses later; READY is high while CSn is high.
    //=====================================================================
    $display("\n=== XFER SECTION G.2: One-CLK Write ===\n");

    @(posedge CLK);
    #1;
    DIN = 8'h95;
    CSn = 1'b0;
    WRn = 1'b0;
    @(posedge CLK);
    #1;
    CSn = 1'b1;
    WRn = 1'b1;
    DIN = 8'h9A;
    #1;
    check(READY, 1'b1, "G.2 READY high once CSn rises");
    run_cycles(31);
    check(uut.u_host.ch_attn[0], 4'd3, "G.2 attenuation unchanged after 31 CEN pulses");
    run_cycles(1);
    check(uut.u_host.ch_attn[0], 4'd5, "G.2 one-CLK write loaded the byte taken as it started");

    //=====================================================================
    // XFER SECTION G.3: Held Write
    // A write held 32 CEN pulses after its byte loads starts another
    // (SN76494/SN76496 Data Sheet, p. 4-40): held 100 pulses, a noise
    // control byte loads on pulses 32 and 96. READY is high from pulse 32
    // and low again from pulse 64.
    //=====================================================================
    $display("\n=== XFER SECTION G.3: Held Write ===\n");

    n = restart_n;
    @(posedge CLK);
    #1;
    DIN = 8'hE4;
    CSn = 1'b0;
    WRn = 1'b0;
    begin : held_write
        reg ready_40;
        reg ready_70;
        for(i = 1; i <= 100; i = i + 1) begin
            cycle();
            if(i == 40) ready_40 = READY;
            if(i == 70) ready_70 = READY;
        end
        check(ready_40, 1'b1, "G.3 READY high 40 CEN pulses into the held write");
        check(ready_70, 1'b0, "G.3 READY low 70 CEN pulses in, the second transfer");
    end
    @(posedge CLK);
    #1;
    CSn = 1'b1;
    WRn = 1'b1;
    run_cycles(2);
    check(restart_n - n, 2, "G.3 write held 100 CEN pulses loads twice");
    check(restart_gap, 64, "G.3 second load 64 CEN pulses after the first");
    check(READY, 1'b1, "G.3 READY high after the write is released");

    //=====================================================================
    // XFER SECTION G.4: Write During a Transfer
    // A write that starts while a transfer runs loads when the transfer
    // ends and its own 32 CEN pulses have passed.
    //=====================================================================
    $display("\n=== XFER SECTION G.4: Write During a Transfer ===\n");

    reset_system();
    @(posedge CLK);
    #1;
    DIN = 8'h91;
    CSn = 1'b0;
    WRn = 1'b0;
    @(posedge CLK);
    #1;
    CSn = 1'b1;
    WRn = 1'b1;
    run_cycles(10);
    @(posedge CLK);
    #1;
    DIN = 8'hB2;
    CSn = 1'b0;
    WRn = 1'b0;
    @(posedge CLK);
    #1;
    CSn = 1'b1;
    WRn = 1'b1;
    DIN = 8'h00;
    run_cycles(22);
    check(uut.u_host.ch_attn[0], 4'd1, "G.4 first write loaded on its 32nd CEN pulse");
    check(uut.u_host.ch_attn[1], 4'hF, "G.4 second write waiting");
    run_cycles(32);
    check(uut.u_host.ch_attn[1], 4'd2, "G.4 second write loaded 32 CEN pulses later");

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
