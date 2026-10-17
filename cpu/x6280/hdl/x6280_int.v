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
//  Interrupt controller for the HuC6280 microprocessor.
//
//  Implements the two on-chip interrupt registers documented in the
//  HuC6280 Hardware Manual. The Interrupt Disable Register holds per-source
//  mask bits; the Interrupt Request Register exposes live status of the
//  three maskable sources. A write to the request register acknowledges
//  the timer interrupt by pulsing tmr_irq_ack to the timer module.
//
//  The mask register update is delayed by one CPU clock so a newly written
//  mask value takes effect on the cycle following the write, matching the
//  documented enable timing on real hardware.
//
//  Vector resolution priority for the maskable sources is:
//
//      Timer > IRQ1 > IRQ2
//
//  Reset, NMI, and BRK are handled directly by the CPU body. This module
//  only resolves the three maskable sources and presents:
//
//      cpu_irq_n  - combined active-low IRQ to the CPU
//      irq_vec    - 2'b10 = Timer ($FFFA / $FFFB)
//                   2'b01 = IRQ1  ($FFF8 / $FFF9)
//                   2'b00 = IRQ2  ($FFF6 / $FFF7)
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual,
//             sections 2.4.1 - 2.4.7 [p.HB-12]-[p.HB-17]
//
//  Register Map:
//    $1FF402  Interrupt Disable Register (IDR)
//             [0] IRQ2D - 1 = disable IRQ2 input
//             [1] IRQ1D - 1 = disable IRQ1 input
//             [2] TIQD  - 1 = disable timer interrupt
//             Reset value: $00 (all sources enabled)
//
//    $1FF403  Interrupt Request Register (IRR)
//             [0] IRQ2  - 1 = IRQ2 input asserted (live)
//             [1] IRQ1  - 1 = IRQ1 input asserted (live)
//             [2] TIQ   - 1 = timer interrupt latched
//             Any write acknowledges the timer interrupt.
//============================================================================

`timescale 1ns/1ps

module x6280_int (
    // Clock and Reset
    input  wire       clk,
    input  wire       rst_n,
    input  wire       cen,

    // Interrupt Interface
    input  wire       irq1_n,
    input  wire       irq2_n,
    input  wire       tmr_irq,

    // Register Bus Interface
    input  wire       int_sel,
    input  wire       cer,
    input  wire       we_n,
    input  wire [1:0] addr_lo,
    input  wire [7:0] din,

    // Read Data Interface
    output wire [2:0] int_mask,
    output wire [2:0] int_irr,

    // Timer Acknowledge
    output reg        tmr_irq_ack,

    // CPU Outputs
    output wire       cpu_irq_n,
    output wire [1:0] irq_vec
);

//------------------------------------------------------------------------
// Mask Registers:
// int_mask_pre is loaded synchronously by CPU writes to $1FF402.
// int_mask_eff is the value used by the priority encoder, copied from
// int_mask_pre on each cen pulse to introduce the documented one-cycle
// enable delay.
//------------------------------------------------------------------------
reg [2:0] int_mask_pre;
reg [2:0] int_mask_eff;

always @(posedge clk) begin
    if(!rst_n) begin
        int_mask_pre <= 3'b000;
        int_mask_eff <= 3'b000;
        tmr_irq_ack <= 1'b0;
    end else begin
        tmr_irq_ack <= 1'b0;

        if(cen)
            int_mask_eff <= int_mask_pre;

        if(int_sel && cer && !we_n) begin
            case(addr_lo)
                2'b10: int_mask_pre <= din[2:0]; // $1FF402: write IDR
                2'b11: tmr_irq_ack <= 1'b1;      // $1FF403: ack timer IRQ
                default: ;
            endcase
        end
    end
end

assign int_mask = int_mask_eff;
assign int_irr  = {tmr_irq, ~irq1_n, ~irq2_n};

//------------------------------------------------------------------------
// Per-Source Mask and Vector Select:
// Each source is gated by its mask bit; the active-low results are
// AND-combined into cpu_irq_n. Vector select follows the documented
// priority Timer > IRQ1 > IRQ2.
//------------------------------------------------------------------------
wire src_irq2_n = irq2_n   | int_mask_eff[0];
wire src_irq1_n = irq1_n   | int_mask_eff[1];
wire src_tiq_n  = ~tmr_irq | int_mask_eff[2];

assign cpu_irq_n = src_irq2_n & src_irq1_n & src_tiq_n;

assign irq_vec = !src_tiq_n  ? 2'b10 :
                 !src_irq1_n ? 2'b01 :
                               2'b00 ;

endmodule
