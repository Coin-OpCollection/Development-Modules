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
//  VGM playback bench for the General Instrument AY-3-8910 programmable
//  sound generator implementation.
//
//  Plays the AY-3-8910 register writes of VGM files through the full chip
//  (x8910) on its bus and writes, per track, the 44.1 kHz AOUT stream. The
//  playlist comes from sim/scripts/vgm2hex.py and sim/scripts/wav_batch.py
//  turns the streams into WAV files.
//
//  DUT:
//    uut - x8910, the full chip on the bus
//
//  Usage (VGM/VGZ files in sim/output/vgm/, from the IP root):
//    python sim/scripts/vgm2hex.py
//    vlib work
//    vlog -quiet hdl/*.v sim/tb_x8910_vgm.v
//    vsim -quiet -c tb_x8910_vgm -do "run -all; quit -f"
//    python sim/scripts/wav_batch.py
//
//  Playlist (32-bit words, one per line, sim/output/vgm_hex/playlist.hex):
//    3_CCCCCCC  track start: C = CEN pulses per 44.1 kHz sample, the chip
//               clock of the VGM header over 44100, rounded down
//    1_RR_00VV  register write: VV to register RR
//    2_WWWWWWW  wait W samples
//    0_0000000  end of track
//    F_0000000  end of playlist
//
//  Each track starts from reset. At its end the three amplitudes are set to
//  0 and 256 more samples run. A CEN pulse is two CLK.
//
//  Reference: VGM File Format Specification 1.71, command 0xA0.
//============================================================================

`timescale 1ns/1ps

module tb_x8910_vgm;

//=========================================================================
// Configuration:
//=========================================================================
localparam MAX_CMDS  = 262144;
localparam DRAIN_LEN = 256;

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

initial CLK = 1'b0;
always #5 CLK = ~CLK;

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
// Helper Tasks:
//=========================================================================

//-------------------------------------------------------------------------
// One CEN Pulse:
//-------------------------------------------------------------------------
task cycle;
    begin
        @(posedge CLK);
        #1 CEN = 1'b1;
        @(posedge CLK);
        #1 CEN = 1'b0;
    end
endtask

//-------------------------------------------------------------------------
// Register Write:
// The address latch, then the data, each a one-CLK write.
//-------------------------------------------------------------------------
task write_reg;
    input [3:0] reg_addr;
    input [7:0] data;
    begin
        @(posedge CLK);
        #1;
        A0 = 1'b0;
        DIN = {4'd0, reg_addr};
        WRn = 1'b0;
        @(posedge CLK);
        #1;
        WRn = 1'b1;

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
// Chip Reset:
//-------------------------------------------------------------------------
task reset_system;
    begin
        RESETn = 1'b0;
        CEN = 1'b0;
        A0 = 1'b0;
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
// One Sample:
// cen_per_sample CEN pulses, then AOUT to the track's stream.
//-------------------------------------------------------------------------
integer fd;
integer total_samples;
integer cen_per_sample;
integer cen_count;

task play_sample;
    begin
        for(cen_count = 0; cen_count < cen_per_sample; cen_count = cen_count + 1)
            cycle();
        $fwrite(fd, "%c", AOUT);
        total_samples = total_samples + 1;
    end
endtask

//=========================================================================
// Playlist:
//=========================================================================
reg [31:0] playlist [0:MAX_CMDS-1];

integer cmd_idx;
integer track_num;
integer wait_samples;
integer s;
integer done;
integer track_active;

reg    [3:0] cmd_type;
reg [1023:0] raw_filename;

initial begin
    $display("=============================================================");
    $display("  x8910 (AY-3-8910) VGM Playlist Testbench");
    $display("=============================================================\n");

    $readmemh("sim/output/vgm_hex/playlist.hex", playlist);

    cmd_idx = 0;
    track_num = 0;
    done = 0;
    fd = 0;

    while(!done && cmd_idx < MAX_CMDS) begin
        cmd_type = playlist[cmd_idx][31:28];

        case(cmd_type)
            // End of playlist
            4'hF : done = 1;

            // Track start
            4'h3 : begin
                track_num = track_num + 1;
                cen_per_sample = playlist[cmd_idx][27:0];
                $display("  [Track %0d] CEN/sample=%0d", track_num, cen_per_sample);

                $sformat(raw_filename, "sim/output/wav/track_%02d.raw", track_num);
                fd = $fopen(raw_filename, "wb");

                if(fd == 0) begin
                    $display("    ERROR: Could not open output file");
                    while(cmd_idx < MAX_CMDS && playlist[cmd_idx][31:28] != 4'h0)
                        cmd_idx = cmd_idx + 1;
                end else begin
                    reset_system();
                    total_samples = 0;
                    track_active = 1;

                    while(track_active && cmd_idx < MAX_CMDS - 1) begin
                        cmd_idx = cmd_idx + 1;
                        cmd_type = playlist[cmd_idx][31:28];

                        case(cmd_type)
                            // End of track: amplitudes to 0, then the drain
                            4'h0 : begin
                                write_reg(4'd8, 8'h00);
                                write_reg(4'd9, 8'h00);
                                write_reg(4'd10, 8'h00);
                                for(s = 0; s < DRAIN_LEN; s = s + 1)
                                    play_sample();

                                $fclose(fd);
                                fd = 0;
                                $display("    -> %0d samples (%0d.%0d sec)",
                                         total_samples, total_samples / 44100,
                                         (total_samples % 44100) * 10 / 44100);
                                track_active = 0;
                            end

                            // Register write
                            4'h1 : write_reg(playlist[cmd_idx][19:16], playlist[cmd_idx][7:0]);

                            // Wait
                            4'h2 : begin
                                wait_samples = playlist[cmd_idx][27:0];
                                for(s = 0; s < wait_samples; s = s + 1)
                                    play_sample();
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
