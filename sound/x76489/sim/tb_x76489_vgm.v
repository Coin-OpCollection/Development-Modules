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
//  VGM playback bench for the Texas Instruments SN76489AN digital complex
//  sound generator implementation.
//
//  Plays the SN76489 writes of VGM files through the full chip (x76489) on
//  its bus and writes, per track, the 44.1 kHz AOUT stream. The playlist
//  comes from sim/scripts/vgm2hex.py and sim/scripts/wav_batch.py turns
//  the streams into WAV files.
//
//  DUT:
//    uut - x76489
//
//  Usage (from the IP root, VGM/VGZ files in sim/output/vgm/):
//    python sim/scripts/vgm2hex.py
//    vlib work
//    vlog -quiet hdl/*.v sim/tb_x76489_vgm.v
//    vsim -quiet -c tb_x76489_vgm -do "run -all; quit -f"
//    python sim/scripts/wav_batch.py
//
//  Playlist (32-bit words, one per line, sim/output/vgm_hex/):
//    3_CCCCCCC  track start: C = CEN pulses per 44.1 kHz sample, the chip
//               clock of the VGM header over 44100, rounded down (81,
//               3.58 MHz, when the header gives no clock)
//    1_00000DD  write the byte DD
//    2_WWWWWWW  wait W samples
//    0_0000000  end of track
//    F_0000000  end of playlist
//
//  Clocking:
//    CLK has a 10 ns period. CEN is driven only by the bench: one pulse is
//    two CLK, CEN high on the first. Each 44.1 kHz sample is C CEN pulses,
//    so the chip runs at 44100 x C input clocks per second.
//
//  Write Timing:
//    A write holds CSn and WRn low with CEN high for one CLK, so each write
//    takes one CEN pulse outside the sample count.
//
//  Track Start and End:
//    Each track starts with RESETn low for 100 ns and one CEN pulse after
//    it. At the end of a track every channel is set OFF and DRAIN_LEN
//    (256) more samples run.
//
//  Outputs (per track NN, in sim/output/wav/):
//    track_NN.raw - one unsigned 8-bit AOUT sample per 44.1 kHz period: the
//                   value after its last CEN pulse
//
//  Reference: TI SN76489AN Data Sheet, Advanced Circuits, November 1981,
//             Data Formats [p.4].
//             VGM file format specification 1.71 (header offset 0CH,
//             command 50H).
//============================================================================

`timescale 1ns/1ps

module tb_x76489_vgm;

//=========================================================================
// Bench Parameters:
//=========================================================================
localparam MAX_CMDS  = 262144;
localparam DRAIN_LEN = 256;

//=========================================================================
// Test Signals:
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
// cycle is one CEN pulse; write_byte one write; reset_system the reset at
// a track start.
//=========================================================================
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
// Playlist and Playback:
//=========================================================================
reg [31:0] playlist [0:MAX_CMDS-1];

integer fd;
integer cmd_idx;
integer track_num;
integer total_samples;
integer cen_per_sample;
integer wait_samples;
integer cen_count;
integer s;
integer done;
integer track_active;

reg    [3:0] cmd_type;
reg [1023:0] raw_filename;

initial begin
    $display("=============================================================");
    $display("  x76489 (SN76489AN) VGM Playlist Testbench");
    $display("=============================================================\n");

    $readmemh("sim/output/vgm_hex/playlist.hex", playlist);

    cmd_idx   = 0;
    track_num = 0;
    done      = 0;
    fd        = 0;

    while(!done && cmd_idx < MAX_CMDS) begin
        cmd_type = playlist[cmd_idx][31:28];

        case(cmd_type)
            // end of playlist
            4'hF : begin
                done = 1;
            end

            // track start
            4'h3 : begin
                track_num = track_num + 1;
                cen_per_sample = playlist[cmd_idx][27:0];
                $display("  [Track %0d] CEN/sample=%0d (clock=%0d Hz)",
                         track_num, cen_per_sample, cen_per_sample * 44100);

                $sformat(raw_filename, "sim/output/wav/track_%02d.raw", track_num);
                fd = $fopen(raw_filename, "wb");

                if(fd == 0) begin
                    $display("    ERROR: Could not open output file");
                    while(cmd_idx < MAX_CMDS && playlist[cmd_idx][31:28] != 4'h0) cmd_idx = cmd_idx + 1;
                end else begin
                    reset_system();
                    total_samples = 0;
                    track_active = 1;

                    while(track_active && cmd_idx < MAX_CMDS - 1) begin
                        cmd_idx = cmd_idx + 1;
                        cmd_type = playlist[cmd_idx][31:28];

                        case(cmd_type)
                            // end of track: every channel set OFF, then the
                            // drain
                            4'h0 : begin
                                write_byte(8'h9F);
                                write_byte(8'hBF);
                                write_byte(8'hDF);
                                write_byte(8'hFF);
                                for(s = 0; s < DRAIN_LEN; s = s + 1) begin
                                    for(cen_count = 0; cen_count < cen_per_sample; cen_count = cen_count + 1) cycle();
                                    $fwrite(fd, "%c", AOUT);
                                    total_samples = total_samples + 1;
                                end

                                $fclose(fd);
                                fd = 0;
                                $display("    -> %0d samples (%0d.%0d sec)",
                                         total_samples, total_samples / 44100,
                                         (total_samples % 44100) * 10 / 44100);
                                track_active = 0;
                            end

                            // byte write
                            4'h1 : begin
                                write_byte(playlist[cmd_idx][7:0]);
                            end

                            // wait
                            4'h2 : begin
                                wait_samples = playlist[cmd_idx][27:0];
                                for(s = 0; s < wait_samples; s = s + 1) begin
                                    for(cen_count = 0; cen_count < cen_per_sample; cen_count = cen_count + 1) cycle();
                                    $fwrite(fd, "%c", AOUT);
                                    total_samples = total_samples + 1;
                                end
                            end

                            default : ;
                        endcase
                    end
                end
            end

            default : ;
        endcase

        cmd_idx = cmd_idx + 1;
    end

    $display("\n=============================================================");
    $display("  Playlist complete: %0d track(s)", track_num);
    $display("  Run: python sim/scripts/wav_batch.py");
    $display("=============================================================\n");

    $stop;
end

endmodule
