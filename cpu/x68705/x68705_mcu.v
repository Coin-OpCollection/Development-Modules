/*
* <-- Coin-Op Collection -->
* https://coinopcollection.org
* https://github.com/Coin-OpCollection/
*
* Author: atrac17 (https://twitter.com/_atrac17)
* Copyright © 2025 Coin-Op Collection
*
* This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/.
*
* You may use, share, and modify this code for non-commercial purposes, provided that proper credit is given.
*/

//============================================================================
//  Top-level MCU wrapper for the MC68705P3 microcomputer.
//
//  This module provides the system integration layer between the x68705
//  core and external ROM. The primary function is reading the Mask Option
//  Register (MOR) from EPROM during reset and passing it to the timer
//  for hardware configuration.
//
//  The MC68705P3 is an EPROM-based device that can emulate various mask
//  ROM versions (MC6805P2, MC6805P4) depending on MOR configuration.
//  EPROM devices contain all zeros after UV erasure; MOR must be
//  programmed along with user code.
//
//  MOR Location: $784 (Px parts), contains timer and oscillator options
//  MOR Bit Definitions:
//    [7] CLK  - Clock oscillator type (1=RC, 0=Crystal)
//    [6] TOPT - Timer option (1=HMOS fixed, 0=software programmable)
//    [5] CLS  - Timer clock source (1=external, 0=internal)
//    [4] TIE  - Timer input enable (sets initial TCR TIE if TOPT=0)
//    [3]      - Not used
//    [2:0]    - Prescaler division (000=1, 001=2, ... 111=128)
//
//  When TOPT=1, timer emulates MC6805P2/P4 with fixed mask options.
//  When TOPT=0, TCR bits 5,4,2,1,0 are software controllable after
//  initialization from MOR values.
//
//  Reference: MC68705P3 8-BIT EPROM Micro Computer Unit Data Sheet and
//             M6805/M146805 CMOS Family User's Manual, Second Edition
//============================================================================

module x68705_mcu (
    input  wire        clk,
    input  wire        rst,
    input  wire        cen, // Active High

    // ROM Interface
    output wire [10:0] rom_addr,
    input  wire  [7:0] rom_data,
    output wire        rom_cs,

    // I/O Port Interface
    input  wire [7:0] pa_i,
    output wire [7:0] pa_o,
    input  wire [7:0] pb_i,
    output wire [7:0] pb_o,
    input  wire [3:0] pc_i,
    output wire [3:0] pc_o,

    // Interrupt Interface
    input  wire       irq,
    output wire       irq_ack, // Interrupt acknowledge

    // Timer External Input
    input  wire timer_in
);

//------------------------------------------------------------------------
// MOR (Mask Option Register) Address:
// Located at $784 in MC68705P3 EPROM address space. The MOR is read
// during reset to configure timer options before program execution
// begins. On Rx/Ux parts, MOR is at $F38 instead.
//------------------------------------------------------------------------
localparam [10:0] MOR_ADDR = 11'h784;

//------------------------------------------------------------------------
// ROM Address Multiplexer:
// During reset, force ROM address to MOR location to read configuration.
// After reset releases, pass through address from CPU core for normal
// instruction and data fetch operations.
//------------------------------------------------------------------------
wire [10:0] core_rom_addr;

assign rom_addr = rst ? MOR_ADDR : core_rom_addr;

//------------------------------------------------------------------------
// MOR Latch:
// Capture MOR value from ROM data bus while reset is asserted. This
// latched value is held stable and passed to the timer module for
// the duration of operation. MOR configures:
//   - Oscillator mode (crystal vs RC)
//   - Timer mode (fixed HMOS emulation vs software programmable)
//   - Prescaler division ratio
//   - Timer clock source selection
//------------------------------------------------------------------------
reg [7:0] mor;

always @(posedge clk) begin
    if(rst)
        mor <= rom_data;
end

//------------------------------------------------------------------------
// x68705 Core Instance:
// The x68705 core contains the complete MC68705P3 implementation:
//   - CPU with 88 instructions, 8 addressing modes
//   - 8-bit ALU with arithmetic, logic, shift/rotate operations
//   - 112 bytes internal RAM with stack at $60-$7F
//   - Three parallel I/O ports (A, B, C)
//   - 8-bit timer with 7-bit prescaler
// The MOR value controls timer behavior per MC68705P3 datasheet.
//------------------------------------------------------------------------
x68705 u_core (
    .clk      ( clk           ),
    .rst      ( rst           ),
    .cen      ( cen           ),
    .rom_addr ( core_rom_addr ),
    .rom_data ( rom_data      ),
    .rom_cs   ( rom_cs        ),
    .pa_i     ( pa_i          ),
    .pa_o     ( pa_o          ),
    .pb_i     ( pb_i          ),
    .pb_o     ( pb_o          ),
    .pc_i     ( pc_i          ),
    .pc_o     ( pc_o          ),
    .irq      ( irq           ),
    .irq_ack  ( irq_ack       ),
    .timer_in ( timer_in      ),
    .mor      ( mor           )
);

endmodule
