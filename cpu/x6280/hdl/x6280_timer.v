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
//  Timer module for the HuC6280 microprocessor.
//
//  Implements the on-chip 7-bit downcounter described in the HuC6280
//  Hardware Manual section 2.7. Structure (Fig. 2-7-1):
//
//      OSC1 -+- 3 -> PPS3 -+- 1024 -> Downcounter (7 bit) -> TIQ
//                                       |
//                                       reload from 7-bit reload register
//                                       on Start/Stop 0 -> 1 transition,
//                                       and on borrow.
//
//  TIQ is set when the downcounter underflows. The IRQ controller
//  acknowledges TIQ via the tmr_irq_ack pulse, generated on a CPU write
//  to the Interrupt Request Register at $1FF403.
//
//  TIMER_SCALE applies a multiplicative factor to the prescaler reload
//  value: TIMER_SCALE = 1 produces the standard 1024-tick prescaler;
//  TIMER_SCALE = 2 produces a 2048-tick prescaler.
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual,
//             section 2.7 [p.HB-20]-[p.HB-22]
//
//  Register Map:
//    $1FEC00  A[0]=0  Reload Register / Downcounter
//                     Write : data[6:0] -> reload register
//                     Read  : downcounter[6:0]
//
//    $1FEC01  A[0]=1  Timer Control Register
//                     Write : data[0] = Start/Stop flag
//                              0 stops the timer and resets the prescaler
//                              0 to 1 transition reloads the downcounter
//                              from the reload register and starts count
//                     Read  : returns downcounter (not defined by manual)
//============================================================================

`timescale 1ns/1ps

module x6280_timer #(
    parameter TIMER_SCALE = 1
) (
    // Clock and Reset
    input  wire       clk,
    input  wire       rst_n,
    input  wire       cen,

    // Register Bus Interface
    input  wire       tmr_sel,
    input  wire       cer,
    input  wire       we_n,
    input  wire       addr_lo,
    input  wire [7:0] din,

    // IRQ Acknowledge
    input  wire       tmr_irq_ack,

    // Read Data
    output wire [6:0] tmr_value,

    // IRQ Output
    output reg        tmr_irq
);

//------------------------------------------------------------------------
// Internal Registers:
// reload_reg holds the 7-bit reload value written via $1FEC00. counter
// is the live downcounter. tmr_en is the Start/Stop flag. prescaler is
// the 11-bit divider that gates downcounter ticks. reload_pending defers
// the reload action by one IO tick after underflow.
//------------------------------------------------------------------------
reg  [6:0] reload_reg;
reg  [6:0] counter;
reg        tmr_en;
reg [10:0] prescaler;
reg        reload_pending;

localparam [10:0] PRESCALE_LOAD = (1024 * TIMER_SCALE) - 1;

//------------------------------------------------------------------------
// Timer Operation:
// Bus writes occur on the access strobe regardless of cen. Counting
// runs only on cen ticks: prescaler decrements each tick and pulses the
// counter when it reaches zero. Underflow sets tmr_irq and arms a
// one-tick deferred reload of the counter from the reload register.
//------------------------------------------------------------------------
always @(posedge clk) begin
    if(!rst_n) begin
        reload_reg <= 7'd0;
        counter <= 7'd0;
        tmr_en <= 1'b0;
        prescaler <= PRESCALE_LOAD;
        reload_pending <= 1'b0;
        tmr_irq <= 1'b0;
    end else begin

        if(tmr_sel && cer && !we_n) begin
            if(!addr_lo) begin
                reload_reg <= din[6:0];
            end else begin
                if(din[0] && !tmr_en) begin
                    counter <= reload_reg;
                    prescaler <= PRESCALE_LOAD;
                end
                tmr_en <= din[0];
            end
        end

        if(tmr_irq_ack)
            tmr_irq <= 1'b0;

        if(cen) begin
            reload_pending <= 1'b0;

            if(tmr_en) begin
                if(prescaler == 11'd0) begin
                    prescaler <= PRESCALE_LOAD;
                    counter <= counter - 7'd1;
                    if(counter == 7'd0) begin
                        reload_pending <= 1'b1;
                        tmr_irq <= 1'b1;
                    end
                end else begin
                    prescaler <= prescaler - 11'd1;
                end
            end

            if(reload_pending)
                counter <= reload_reg;
        end
    end
end

assign tmr_value = counter;

endmodule
