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
//  Fully synchronous implementation of the Hudson Soft HuC6280: CPU, MPR
//  translator, interrupt controller, timer, I/O ports, internal-page
//  decode and six-channel PSG.
//
//  Clocking:
//    - cen is the OSC1 / 3 enable (7.16 MHz with a 21.48 MHz OSC1). CSH
//      runs the CPU on every cen, CSL on one in four [US5483659].
//    - The timer and the PSG run on every cen regardless of the speed
//      [p.HB-20].
//    - rdy low stretches the current CPU cycle, read, write or internal;
//      ce marks the enable that ends a CPU cycle.
//
//  External Bus:
//    - rd_n and wr_n are low for the whole cycle of a read or write to an
//      external address, CE7 and CEK (VDC, VCE) included [p.HB-9]; none in
//      an internal cycle (INT_RD = 1: rd_n low there too). Accesses to the
//      PSG, timer, I/O ports and interrupt registers stay on chip.
//
//  Submodules:
//    x6280_cpu    - CPU core with the mapping registers and the vector
//                   select.
//    x6280_alu    - 8-bit ALU.
//    x6280_mem    - internal-page decode, chip enables and read mux.
//    x6280_int    - interrupt disable and request registers.
//    x6280_timer  - 7-bit timer with the 1024 prescaler.
//    x6280_io     - port K input and port O output.
//    x6280_psg    - programmable sound generator (PSG = 1).
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual and
//             Programmable Sound Generator Manual (Hudson Soft)
//============================================================================

`timescale 1ns/1ps

module x6280 #(
    parameter TIMER_SCALE = 1, // Timer prescaler multiplier
    parameter CE_WAIT     = 1, // 1 = CE7 / CEK accesses last one more cycle
    parameter INT_RD      = 0, // 1 = rd_n low in internal cycles
    parameter PSG         = 1  // 0 = no PSG, audio outputs 0
) (
    // Clock and Reset
    input  wire               clk,
    input  wire               rst_n,
    input  wire               cen,
    input  wire               rdy,

    // External Bus
    output wire        [20:0] a,
    input  wire         [7:0] di,
    output wire         [7:0] dout,
    output wire               rd_n,
    output wire               wr_n,
    output wire               sync,
    output wire               vp_n,

    // Interrupt Inputs
    input  wire               nmi_n,
    input  wire               irq1_n,
    input  wire               irq2_n,

    // Chip-Select
    output wire               ce,
    output wire               cek_n,
    output wire               ce7_n,
    output wire               cer_n,
    output wire               pre_rd,
    output wire               pre_wr,
    output wire               hsm,

    // I/O Ports
    input  wire         [7:0] k,
    output wire         [7:0] o,

    // Audio Output
    output wire signed [23:0] aud_ldata,
    output wire signed [23:0] aud_rdata
);

//------------------------------------------------------------------------
// CPU Clock Enable:
// CSH passes every cen; CSL passes one in four. csl_cnt counts the cens
// since the last CPU enable, so every low-speed cycle lasts four cens,
// the first one after CSL included.
//------------------------------------------------------------------------
reg  [1:0] csl_cnt;
wire       cpu_csh;
wire       cpu_cen;

always @(posedge clk) begin
    if(!rst_n)
        csl_cnt <= 2'd0;
    else if(cen)
        csl_cnt <= cpu_cen ? 2'd1 : (csl_cnt + 2'd1);
end

assign cpu_cen = cen & (cpu_csh | (csl_cnt == 2'd0));
assign hsm     = cpu_csh;

//------------------------------------------------------------------------
// CPU Bus Signals:
// cpu_ce ends a CPU cycle; cpu_intc marks an internal cycle.
//------------------------------------------------------------------------
wire [15:0] cpu_la;
wire [20:0] cpu_pa;
wire        cpu_rw_n;
wire        cpu_intc;
wire        cpu_ce;
wire  [7:0] cpu_dout;
wire  [7:0] cpu_din_mux;
wire        cpu_irq_n;
wire  [1:0] cpu_irq_vec;
wire        cpu_sync;
wire        cpu_vp_n;
wire        bus_ce = cpu_ce & ~cpu_intc;

//------------------------------------------------------------------------
// Internal Page Selects and Peripheral Read Data
//------------------------------------------------------------------------
wire vdc_sel;
wire vce_sel;
wire psg_sel;
wire tmr_sel;
wire iop_sel;
wire int_sel;
wire ram_sel;

wire [2:0] int_mask;
wire [2:0] int_irr;
wire [6:0] tmr_value;
wire [7:0] iop_dout;

//------------------------------------------------------------------------
// Timer Interrupt:
// tmr_irq is set by a timer borrow and cleared by a write to the
// interrupt request register.
//------------------------------------------------------------------------
wire tmr_irq;
wire tmr_irq_ack;

//------------------------------------------------------------------------
// HuC6280 CPU Instance
//------------------------------------------------------------------------
x6280_cpu #(
    .CE_WAIT ( CE_WAIT )
) u_cpu (
    .clk       ( clk         ),
    .cen       ( cpu_cen     ),
    .rst_n     ( rst_n       ),
    .rdy       ( rdy         ),
    .irq_n     ( cpu_irq_n   ),
    .irq_vec   ( cpu_irq_vec ),
    .nmi_n     ( nmi_n       ),
    .addr      ( cpu_la      ),
    .phys_addr ( cpu_pa      ),
    .din       ( cpu_din_mux ),
    .dout      ( cpu_dout    ),
    .rw_n      ( cpu_rw_n    ),
    .intc      ( cpu_intc    ),
    .sync      ( cpu_sync    ),
    .vp_n      ( cpu_vp_n    ),
    .dout_oe   (             ),
    .bus_ce    ( cpu_ce      ),
    .csh       ( cpu_csh     ),
    .dbg_pc    (             ),
    .dbg_a     (             ),
    .dbg_x     (             ),
    .dbg_y     (             ),
    .dbg_s     (             ),
    .dbg_p     (             ),
    .dbg_ir    (             ),
    .dbg_mpr   (             )
);

//------------------------------------------------------------------------
// Memory and Address Decode Instance
//------------------------------------------------------------------------
x6280_mem u_mem (
    .clk       ( clk         ),
    .rst_n     ( rst_n       ),
    .cen       ( bus_ce      ),
    .phys_addr ( cpu_pa      ),
    .we_n      ( cpu_rw_n    ),
    .cpu_dout  ( cpu_dout    ),
    .ext_din   ( di          ),
    .int_mask  ( int_mask    ),
    .int_irr   ( int_irr     ),
    .tmr_value ( tmr_value   ),
    .iop_dout  ( iop_dout    ),
    .vdc_sel   ( vdc_sel     ),
    .vce_sel   ( vce_sel     ),
    .psg_sel   ( psg_sel     ),
    .tmr_sel   ( tmr_sel     ),
    .iop_sel   ( iop_sel     ),
    .int_sel   ( int_sel     ),
    .ram_sel   ( ram_sel     ),
    .ce7_n     ( ce7_n       ),
    .cek_n     ( cek_n       ),
    .cer_n     ( cer_n       ),
    .cpu_din   ( cpu_din_mux )
);

//------------------------------------------------------------------------
// Interrupt Controller Instance
//------------------------------------------------------------------------
x6280_int u_int (
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .cen         ( cpu_ce      ),
    .irq1_n      ( irq1_n      ),
    .irq2_n      ( irq2_n      ),
    .tmr_irq     ( tmr_irq     ),
    .int_sel     ( int_sel     ),
    .cer         ( bus_ce      ),
    .we_n        ( cpu_rw_n    ),
    .addr_lo     ( cpu_pa[1:0] ),
    .din         ( cpu_dout    ),
    .int_mask    ( int_mask    ),
    .int_irr     ( int_irr     ),
    .tmr_irq_ack ( tmr_irq_ack ),
    .cpu_irq_n   ( cpu_irq_n   ),
    .irq_vec     ( cpu_irq_vec )
);

//------------------------------------------------------------------------
// Timer Instance
//------------------------------------------------------------------------
x6280_timer #(
    .TIMER_SCALE ( TIMER_SCALE )
) u_timer (
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .cen         ( cen         ),
    .tmr_sel     ( tmr_sel     ),
    .cer         ( bus_ce      ),
    .we_n        ( cpu_rw_n    ),
    .addr_lo     ( cpu_pa[0]   ),
    .din         ( cpu_dout    ),
    .tmr_irq_ack ( tmr_irq_ack ),
    .tmr_value   ( tmr_value   ),
    .tmr_irq     ( tmr_irq     )
);

//------------------------------------------------------------------------
// I/O Ports Instance
//------------------------------------------------------------------------
x6280_io u_io (
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .cen      ( bus_ce   ),
    .iop_sel  ( iop_sel  ),
    .cer      ( bus_ce   ),
    .we_n     ( cpu_rw_n ),
    .din      ( cpu_dout ),
    .port_k   ( k        ),
    .port_o   ( o        ),
    .iop_dout ( iop_dout )
);

//------------------------------------------------------------------------
// PSG Instance:
// PSG = 0 leaves the PSG out; its register writes are ignored.
//------------------------------------------------------------------------
generate
    if(PSG != 0) begin : g_psg
        wire psg_we = psg_sel & bus_ce & ~cpu_rw_n;

        x6280_psg u_psg (
            .clk       ( clk         ),
            .rst_n     ( rst_n       ),
            .clken     ( cen         ),
            .we        ( psg_we      ),
            .a         ( cpu_pa[3:0] ),
            .di        ( cpu_dout    ),
            .dac_latch ( 1'b1        ),
            .ldata     ( aud_ldata   ),
            .rdata     ( aud_rdata   )
        );
    end else begin : g_no_psg
        assign aud_ldata = 24'sd0;
        assign aud_rdata = 24'sd0;
    end
endgenerate

//------------------------------------------------------------------------
// External Bus Strobes:
// Low for the whole cycle of an external read or write; accesses to the
// on-chip blocks and internal cycles (INT_RD = 0) leave both high.
// pre_rd and pre_wr mark the enable that ends a read or write cycle,
// on-chip blocks included.
//------------------------------------------------------------------------
wire on_chip = psg_sel | tmr_sel | iop_sel | int_sel;
wire rd_cyc  = cpu_rw_n & ((INT_RD != 0) | ~cpu_intc);

assign a      = cpu_pa;
assign dout   = cpu_dout;
assign rd_n   = ~(rd_cyc & ~on_chip);
assign wr_n   = ~(~cpu_rw_n & ~on_chip);
assign pre_rd = rd_cyc & cpu_ce & rst_n;
assign pre_wr = ~cpu_rw_n & cpu_ce & rst_n;
assign ce     = cpu_ce;
assign sync   = cpu_sync;
assign vp_n   = cpu_vp_n;

endmodule
