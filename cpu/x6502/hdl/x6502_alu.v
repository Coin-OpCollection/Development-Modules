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
//  Purely combinational 8-bit arithmetic logic unit for the NMOS 6502.
//
//  The ALU receives two 8-bit operands (a, b), a 4-bit operation select,
//  and the current processor status register P. It produces an 8-bit
//  result and the updated P flags. Flag behaviour follows the NMOS 6502
//  silicon, including binary-coded-decimal (BCD) operation when the D
//  flag is set during ADC and SBC.
//
//  Supported operations include logical (ORA, AND, EOR, BIT), arithmetic
//  (ADC, SBC, CMP), shift and rotate (ASL, LSR, ROL, ROR), and increment
//  and decrement (INC, DEC). Pass-through ops (EQ1, EQ2) move data
//  without ALU work; EQ1 leaves flags unchanged for stores, EQ2 updates
//  N and Z for loads and transfers.
//
//  Reference: MOS Technology MCS6500 Microcomputer Family Hardware Manual,
//             January 1976
//============================================================================

`timescale 1ns/1ps

module x6502_alu (
    // Operand Interface
    input  wire [7:0] a,    // BusA: accumulator, register, or memory
    input  wire [7:0] b,    // BusB: memory data input

    // Control Interface
    input  wire [3:0] op,   // ALU operation select
    input  wire [7:0] p_in, // Processor status register input

    // Result Interface
    output reg  [7:0] q,    // Result
    output reg  [7:0] p_out // Updated processor status register
);

//------------------------------------------------------------------------
// ALU Operation Codes:
// 4-bit encoding holds 15 distinct operations. The CPU state machine
// drives op based on the decoded opcode.
//------------------------------------------------------------------------
localparam [3:0]
    ALU_OR  = 4'h0, // a | b
    ALU_AND = 4'h1, // a & b
    ALU_EOR = 4'h2, // a ^ b
    ALU_ADC = 4'h3, // a + b + C, binary or BCD per D flag
    ALU_EQ1 = 4'h4, // pass a, leave flags unchanged (stores, branches)
    ALU_EQ2 = 4'h5, // pass a, update N and Z (loads, transfers)
    ALU_CMP = 4'h6, // a - b, update N, Z, C only
    ALU_SBC = 4'h7, // a - b - !C, binary or BCD per D flag
    ALU_ASL = 4'h8, // shift left, bit 7 -> C
    ALU_ROL = 4'h9, // rotate left through C
    ALU_LSR = 4'hA, // shift right, bit 0 -> C
    ALU_ROR = 4'hB, // rotate right through C
    ALU_BIT = 4'hC, // a & b, N from b[7], V from b[6], Z from (a & b)
    ALU_DEC = 4'hD, // a - 1
    ALU_INC = 4'hE; // a + 1

//------------------------------------------------------------------------
// Processor Status Register Layout:
// Bit positions match the 6502 P register.
//   0 : C  carry
//   1 : Z  zero
//   2 : I  interrupt mask
//   3 : D  decimal
//   4 : B  break (only meaningful when pushed to stack)
//   5 : 1  always reads as 1 on NMOS
//   6 : V  overflow
//   7 : N  negative
//------------------------------------------------------------------------
localparam FLAG_C = 0;
localparam FLAG_Z = 1;
localparam FLAG_I = 2;
localparam FLAG_D = 3;
localparam FLAG_B = 4;
localparam FLAG_1 = 5;
localparam FLAG_V = 6;
localparam FLAG_N = 7;

//------------------------------------------------------------------------
// ADC Pre-compute Registers:
// Half-adders per nibble produce binary intermediates that the BCD
// adjustment step refines when D=1. C reflects the post-adjust carry.
// N and V come from the binary intermediate, which matches NMOS
// behaviour where these flags are not meaningful in decimal mode but
// are still produced by the silicon.
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
// Same structure as the ADC path. Carry-in is forced high for CMP so
// the same adder serves both subtract and compare. BCD adjust subtracts
// 6 from any nibble that produced a borrow.
//------------------------------------------------------------------------
wire       sbc_cin = (op == ALU_SBC) ? p_in[FLAG_C] : 1'b1;
reg  [6:0] sbc_al;
reg  [5:0] sbc_ah;
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
// Computes a + b + C with optional decimal correction. Z is taken from
// the full binary intermediate before any BCD adjust because the NMOS
// silicon evaluates Z on the binary path.
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

    // N and V from the binary high nibble (NMOS decimal-mode behaviour)
    adc_n = adc_ah[4];
    adc_v = (adc_ah[4] ^ a[7]) & ~(a[7] ^ b[7]);

    // BCD high nibble adjust: if high > 9, add 6
    if(p_in[FLAG_D] && (adc_ah[5:1] > 5'd9))
        adc_ah[6:1] = adc_ah[6:1] + 6'd6;

    adc_c = adc_ah[6] | adc_ah[5];
    adc_q = {adc_ah[4:1], adc_al[4:1]};
end

//========================================================================
// SBC and CMP Path:
// Computes a - b - !cin. Carry-in is driven from p_in[C] for SBC and
// forced 1 for CMP. BCD adjust applies only when D=1; CMP only consumes
// flags computed on the binary intermediate, so CMP behaves correctly
// even with D set.
//========================================================================
always @(*) begin
    // Low nibble half-subtract
    sbc_al = {1'b0, a[3:0], sbc_cin} - {1'b0, b[3:0], 1'b1};

    // High nibble half-subtract using low borrow
    sbc_ah = {1'b0, a[7:4], 1'b0} - {1'b0, b[7:4], sbc_al[5]};

    // Flags from the binary intermediate
    sbc_z = (sbc_al[4:1] == 4'h0) && (sbc_ah[4:1] == 4'h0);
    sbc_n = sbc_ah[4];
    sbc_c = ~sbc_ah[5];
    sbc_v = (sbc_ah[4] ^ a[7]) & (a[7] ^ b[7]);

    // BCD adjust: subtract 6 from any nibble that borrowed
    if(p_in[FLAG_D]) begin
        if(sbc_al[5])
            sbc_al[5:1] = sbc_al[5:1] - 5'd6;
        sbc_ah = {1'b0, a[7:4], 1'b0} - {1'b0, b[7:4], sbc_al[6]};
        if(sbc_ah[5])
            sbc_ah[5:1] = sbc_ah[5:1] - 5'd6;
    end

    sbc_q = {sbc_ah[4:1], sbc_al[4:1]};
end

//========================================================================
// Op Mux:
// Selects the result and updates only the flag bits each instruction
// is documented to touch. Unchanged bits pass through from p_in. ADC,
// SBC, and CMP take N and Z from the binary intermediate; BIT takes N
// from memory bit 7 and Z from (a & b) == 0; EQ1 leaves all flags
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
            p_out[FLAG_V] = adc_v;
            p_out[FLAG_C] = adc_c;
        end

        ALU_CMP : begin
            // Result not written back; flag-only
            p_out[FLAG_C] = sbc_c;
        end

        ALU_SBC : begin
            op_q = sbc_q;
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

        ALU_BIT : begin
            // V from memory bit 6; N and Z handled in flag block below
            p_out[FLAG_V] = b[6];
        end

        ALU_DEC : op_q = a - 8'h01;
        ALU_INC : op_q = a + 8'h01;

        // ALU_EQ1, ALU_EQ2: op_q remains a; flags handled below
        default : ;
    endcase

    // Flag block: N and Z
    case(op)
        ALU_ADC : begin
            p_out[FLAG_N] = adc_n;
            p_out[FLAG_Z] = adc_z;
        end

        ALU_CMP, ALU_SBC : begin
            p_out[FLAG_N] = sbc_n;
            p_out[FLAG_Z] = sbc_z;
        end

        ALU_BIT : begin
            p_out[FLAG_N] = b[7];
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
