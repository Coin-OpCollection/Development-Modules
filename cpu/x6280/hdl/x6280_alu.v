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
//  Purely combinational 8-bit arithmetic logic unit for the HuC6280.
//
//  Operations:
//    - Logical (ORA, AND, EOR), arithmetic (ADC, SBC, CMP), shift and
//      rotate (ASL, LSR, ROL, ROR), increment and decrement (INC, DEC), and
//      the pass-through ops EQ1 (no flags) and EQ2 (N and Z).
//    - BIT, TST, TSB and TRB: N and V from memory bits 7 and 6, Z from
//      a AND b [p.HB-5].
//
//  Flags:
//    - ADC in decimal mode (D = 1) corrects each nibble; C comes from the
//      high-nibble correction.
//    - SBC in decimal mode subtracts $60 when the binary difference is
//      negative and $06 when the low-nibble difference is negative; C is the
//      binary one.
//    - ADC and SBC leave V unchanged in decimal mode [p.HB-4], [p.SB-17];
//      N and Z follow the result in both modes.
//    - CMP ignores D and the carry in.
//
//  Reference: HuC6280 CMOS 8-bit Microprocessor Hardware Manual and
//             Software Manual (Hudson Soft)
//============================================================================

`timescale 1ns/1ps

module x6280_alu (
    // Operand Interface
    input  wire [7:0] a,    // BusA: accumulator, register, or memory
    input  wire [7:0] b,    // BusB: memory data input

    // Control Interface
    input  wire [4:0] op,   // ALU operation select
    input  wire [7:0] p_in, // Processor status register input

    // Result Interface
    output reg  [7:0] q,    // Result
    output reg  [7:0] p_out // Updated processor status register
);

//------------------------------------------------------------------------
// ALU Operation Codes:
// 5-bit encoding. The CPU state machine drives op based on the decoded
// opcode.
//------------------------------------------------------------------------
localparam [4:0]
    ALU_OR  = 5'h00, // a | b
    ALU_AND = 5'h01, // a & b
    ALU_EOR = 5'h02, // a ^ b
    ALU_ADC = 5'h03, // a + b + C, binary or BCD per D flag
    ALU_EQ1 = 5'h04, // pass a, leave flags unchanged
    ALU_EQ2 = 5'h05, // pass a, update N and Z
    ALU_CMP = 5'h06, // a - b, update N, Z, C only
    ALU_SBC = 5'h07, // a - b - !C, binary or BCD per D flag
    ALU_ASL = 5'h08, // shift left, bit 7 -> C
    ALU_ROL = 5'h09, // rotate left through C
    ALU_LSR = 5'h0A, // shift right, bit 0 -> C
    ALU_ROR = 5'h0B, // rotate right through C
    ALU_BIT = 5'h0C, // a & b, N from b[7], V from b[6], Z from (a & b)
    ALU_DEC = 5'h0D, // a - 1
    ALU_INC = 5'h0E, // a + 1
    ALU_TSB = 5'h10, // a | b, N and V from b, Z from (a & b)
    ALU_TRB = 5'h11; // ~a & b, N and V from b, Z from (a & b)

//------------------------------------------------------------------------
// Processor Status Register Layout:
//   0 : C  carry
//   1 : Z  zero
//   2 : I  interrupt mask
//   3 : D  decimal
//   4 : B  (only in a pushed copy of P)
//   5 : T  memory operation
//   6 : V  overflow
//   7 : N  negative
//------------------------------------------------------------------------
localparam FLAG_C = 0;
localparam FLAG_Z = 1;
localparam FLAG_I = 2;
localparam FLAG_D = 3;
localparam FLAG_B = 4;
localparam FLAG_T = 5;
localparam FLAG_V = 6;
localparam FLAG_N = 7;

//------------------------------------------------------------------------
// ADC Pre-compute Registers:
// Half-adders per nibble produce binary intermediates that the BCD
// adjustment step refines when D=1. C reflects the post-adjust carry.
//------------------------------------------------------------------------
reg [6:0] adc_al;   // low nibble half-add (carry, 4 data bits, alignment)
reg [6:0] adc_ah;   // high nibble half-add
reg       adc_cmid; // carry from low to high nibble
reg       adc_z;
reg       adc_c;
reg       adc_v;
reg       adc_n;
reg [7:0] adc_q;

//------------------------------------------------------------------------
// SBC and CMP Pre-compute Registers:
// Carry-in is forced high for CMP so the same subtractor serves both.
// The decimal result is the binary difference less $60 and $06 per the
// high and low borrows.
//------------------------------------------------------------------------
wire       sbc_cin = (op == ALU_SBC) ? p_in[FLAG_C] : 1'b1;
wire [8:0] sbc_d   = {1'b0, a} - {1'b0, b} - {8'h00, ~sbc_cin};
wire [4:0] sbc_dl  = {1'b0, a[3:0]} - {1'b0, b[3:0]} - {4'h0, ~sbc_cin};
reg        sbc_z;
reg        sbc_c;
reg        sbc_v;
reg        sbc_n;
reg  [7:0] sbc_q;

//------------------------------------------------------------------------
// Op Mux Working Register:
// Holds the result before assignment to q so the flag block can read
// it without forming a feedback loop on q.
//------------------------------------------------------------------------
reg [7:0] op_q;

//========================================================================
// ADC Path:
// Computes a + b + C with optional decimal correction. In decimal mode
// N and Z are taken from the corrected result.
//========================================================================
always @(*) begin
    // Low nibble half-add: (a[3:0], C) + (b[3:0], 1)
    adc_al = {1'b0, a[3:0], p_in[FLAG_C]} + {1'b0, b[3:0], 1'b1};

    // Preliminary high nibble half-add for the binary Z flag
    adc_ah = {1'b0, a[7:4], adc_al[5]} + {1'b0, b[7:4], 1'b1};

    adc_z = (adc_al[4:1] == 4'h0) && (adc_ah[4:1] == 4'h0);

    // BCD low nibble adjust: if low (with carry) > 9, add 6
    if(p_in[FLAG_D] && (adc_al[5:1] > 5'd9))
        adc_al[6:1] = adc_al[6:1] + 6'd6;

    adc_cmid = adc_al[6] | adc_al[5];

    // High nibble half-add using the mid-carry
    adc_ah = {1'b0, a[7:4], adc_cmid} + {1'b0, b[7:4], 1'b1};

    // N and V from the high nibble before its decimal adjust
    adc_n = adc_ah[4];
    adc_v = (adc_ah[4] ^ a[7]) & ~(a[7] ^ b[7]);

    // BCD high nibble adjust: if high > 9, add 6
    if(p_in[FLAG_D] && (adc_ah[5:1] > 5'd9))
        adc_ah[6:1] = adc_ah[6:1] + 6'd6;

    adc_c = adc_ah[6] | adc_ah[5];
    adc_q = {adc_ah[4:1], adc_al[4:1]};

    // Decimal mode: N and Z from the corrected result
    if(p_in[FLAG_D]) begin
        adc_n = adc_q[7];
        adc_z = (adc_q == 8'h00);
    end
end

//========================================================================
// SBC and CMP Path:
// Computes a - b - !cin. C and V come from the binary difference; CMP
// uses the binary path regardless of D.
//========================================================================
always @(*) begin
    sbc_c = ~sbc_d[8];
    sbc_v = (sbc_d[7] ^ a[7]) & (a[7] ^ b[7]);
    sbc_q = sbc_d[7:0];

    // Decimal adjust: $60 for a negative difference, $06 for a negative
    // low-nibble difference
    if(p_in[FLAG_D] && (op == ALU_SBC))
        sbc_q = sbc_d[7:0] - (sbc_d[8] ? 8'h60 : 8'h00) - (sbc_dl[4] ? 8'h06 : 8'h00);

    sbc_n = sbc_q[7];
    sbc_z = (sbc_q == 8'h00);
end

//========================================================================
// Op Mux:
// Selects the result and updates only the flag bits each instruction
// touches. Unchanged bits pass through from p_in. BIT, TSB and TRB take
// N and V from memory and Z from (a & b) == 0; EQ1 leaves all flags
// alone; everything else updates N from result bit 7 and Z from result
// equal to zero.
//========================================================================
always @(*) begin
    op_q = a;
    p_out = p_in;

    case(op)
        ALU_OR : op_q = a | b;
        ALU_AND : op_q = a & b;
        ALU_EOR : op_q = a ^ b;

        ALU_ADC : begin
            op_q = adc_q;
            if(!p_in[FLAG_D])
                p_out[FLAG_V] = adc_v;
            p_out[FLAG_C] = adc_c;
        end

        ALU_CMP : begin
            // Result not written back; flag-only
            p_out[FLAG_C] = sbc_c;
        end

        ALU_SBC : begin
            op_q = sbc_q;
            if(!p_in[FLAG_D])
                p_out[FLAG_V] = sbc_v;
            p_out[FLAG_C] = sbc_c;
        end

        ALU_ASL : begin
            op_q = {a[6:0], 1'b0};
            p_out[FLAG_C] = a[7];
        end

        ALU_ROL : begin
            op_q = {a[6:0], p_in[FLAG_C]};
            p_out[FLAG_C] = a[7];
        end

        ALU_LSR : begin
            op_q = {1'b0, a[7:1]};
            p_out[FLAG_C] = a[0];
        end

        ALU_ROR : begin
            op_q = {p_in[FLAG_C], a[7:1]};
            p_out[FLAG_C] = a[0];
        end

        ALU_DEC : op_q = a - 8'h01;
        ALU_INC : op_q = a + 8'h01;
        ALU_TSB : op_q = a | b;
        ALU_TRB : op_q = ~a & b;

        // ALU_EQ1, ALU_EQ2, ALU_BIT: op_q remains a; flags handled below
        default : ;
    endcase

    // Flag block: N, V and Z
    case(op)
        ALU_ADC : begin
            p_out[FLAG_N] = adc_n;
            p_out[FLAG_Z] = adc_z;
        end

        ALU_CMP, ALU_SBC : begin
            p_out[FLAG_N] = sbc_n;
            p_out[FLAG_Z] = sbc_z;
        end

        ALU_BIT, ALU_TSB, ALU_TRB : begin
            p_out[FLAG_N] = b[7];
            p_out[FLAG_V] = b[6];
            p_out[FLAG_Z] = ((a & b) == 8'h00);
        end

        ALU_EQ1 : begin
            // No N/Z update (stores and branches)
        end

        default : begin
            p_out[FLAG_N] = op_q[7];
            p_out[FLAG_Z] = (op_q == 8'h00);
        end
    endcase

    q = op_q;
end

endmodule
