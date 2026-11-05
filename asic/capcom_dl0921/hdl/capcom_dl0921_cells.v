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
//  Ricoh A5C cell library of the CAPCOM DL-0921 (CPS-B-21) netlist: the
//  74 cell types capcom_dl0921 instantiates.
//
//  Pins are p<number> as in the A5C symbol library. Functions follow the
//  library symbols and the zoo drawings; where a drawing gives the
//  polarity it is followed: L8G loads while LE is low, L8GH and L8 while
//  it is high; R42 / R52 give Q = NOT ~D and ~S sets; M198C modes follow
//  M198C-doc; MUX8GLH selects come out inverted (index = 7 - S); PRIO
//  follows PRIO-doc.
//
//  Tri-State Outputs:
//    each one a value pin pN and an enable pin pN_oe, high while the
//    cell drives
//
//  Latches as Registers:
//    L8G_FF loads on the rise of p1; L8GH_BUF passes its input; together
//    they replace an L8G / L8GH pair on one enable
//    L8GH_HOLD passes its input while p1 is high, else what it took on the
//    fall of p1, for an L8GH alone on its enable
//    R42_HOLD / R52_HOLD pass their input while p1 is high, else what they
//    took on the fall of p1; a low p2 presets them
//    L_HOLD / L8_HOLD pass their input while p1 is high, else what they took
//    on the fall of p1
//    L8L_HOLD passes its input while p1 is high, else what it took on the
//    fall of p1; its outputs inverted, as the L8L
//    RSLT_HOLD is 1 while p1 is high and 0 while p2 is high, else what its
//    register took on the last ck with en high
//
//  Registers with Enables:
//    <cell>_EN loads only on the CLK rises where en is high; in the
//    pass-and-hold cells the register is on ck
//
//  Delays, in simulation only:
//    `NL_D    every gate output, 0.1 ns, so latch loops and ripple chains
//             settle in order with zero wire delay
//    `NL_Q    clock to output of the registers, 2 ns
//    `NL_QE   the same in <cell>_EN, plus CKD tenths of a ns, where its
//             clock arrives in the netlist after the CLK rise
//    `NL_MPW  asynchronous clears and sets, 1 ns inertial
//============================================================================

`timescale 1ns/1ps

`ifdef SIMULATION
`define NL_D #0.1
`define NL_Q #2
`define NL_QE #(2.0 + CKD / 10.0)
`define NL_MPW #1
`else
`define NL_D
`define NL_Q
`define NL_QE
`define NL_MPW
`endif

//========================================================================
// Buffers:
//========================================================================
module capcom_dl0921_INV01 (
    input  wire p1,
    output wire p2
);

assign `NL_D p2 = ~p1;

endmodule

module capcom_dl0921_BUF01 (
    input  wire p1,
    output wire p2
);

assign `NL_D p2 = p1;

endmodule

module capcom_dl0921_BUF12 (
    input  wire p1,
    output wire p2
);

assign `NL_D p2 = p1;

endmodule

module capcom_dl0921_NBUF02 (
    input  wire p1,
    output wire p2
);

assign `NL_D p2 = ~p1;

endmodule

module capcom_dl0921_NBUF03 (
    input  wire p1,
    output wire p2
);

assign `NL_D p2 = ~p1;

endmodule

module capcom_dl0921_DBUF (
    input  wire p2,
    output wire p3,
    output wire p4
);

assign `NL_D p3 = ~p2;
assign `NL_D p4 = p2;

endmodule

module capcom_dl0921_8BUF11 (
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    output wire p11,
    output wire p12,
    output wire p13,
    output wire p14,
    output wire p15,
    output wire p16,
    output wire p17,
    output wire p18
);

assign `NL_D {p11, p12, p13, p14, p15, p16, p17, p18} = {p9, p8, p7, p6, p5, p4, p3, p2};

endmodule

//========================================================================
// Gates:
//========================================================================
module capcom_dl0921_AND02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `NL_D p3 = p1 & p2;

endmodule

module capcom_dl0921_AND03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `NL_D p4 = p1 & p2 & p3;

endmodule

module capcom_dl0921_AND04 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `NL_D p5 = p1 & p2 & p3 & p4;

endmodule

module capcom_dl0921_OR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `NL_D p3 = p1 | p2;

endmodule

module capcom_dl0921_OR03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `NL_D p4 = p1 | p2 | p3;

endmodule

module capcom_dl0921_OR04 (
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p1
);

assign `NL_D p1 = p2 | p3 | p4 | p5;

endmodule

module capcom_dl0921_NAND02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `NL_D p3 = ~(p1 & p2);

endmodule

module capcom_dl0921_NAND03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `NL_D p4 = ~(p1 & p2 & p3);

endmodule

module capcom_dl0921_NAND04 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `NL_D p5 = ~(p1 & p2 & p3 & p4);

endmodule

module capcom_dl0921_NAND05 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p6
);

assign `NL_D p6 = ~(p1 & p2 & p3 & p4 & p5);

endmodule

module capcom_dl0921_NAND06 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p9
);

assign `NL_D p9 = ~(p1 & p2 & p3 & p4 & p5 & p6);

endmodule

module capcom_dl0921_NAND08 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    output wire p9
);

assign `NL_D p9 = ~(p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8);

endmodule

module capcom_dl0921_NAND13 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    output wire p14
);

assign `NL_D p14 = ~(p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8 & p9 & p10 & p11 & p12 & p13);

endmodule

module capcom_dl0921_NOR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `NL_D p3 = ~(p1 | p2);

endmodule

module capcom_dl0921_NOR03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `NL_D p4 = ~(p1 | p2 | p3);

endmodule

module capcom_dl0921_NOR04 (
    output wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5
);

assign `NL_D p1 = ~(p2 | p3 | p4 | p5);

endmodule

module capcom_dl0921_NOR05 (
    output wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6
);

assign `NL_D p1 = ~(p2 | p3 | p4 | p5 | p6);

endmodule

module capcom_dl0921_XOR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `NL_D p3 = p1 ^ p2;

endmodule

module capcom_dl0921_XNOR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `NL_D p3 = ~(p1 ^ p2);

endmodule

//========================================================================
// AND-OR and OR-AND Gates:
//========================================================================
module capcom_dl0921_AO22 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `NL_D p5 = (p1 & p3) | (p2 & p4);

endmodule

module capcom_dl0921_AOI21 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `NL_D p4 = ~((p1 & p2) | p3);

endmodule

module capcom_dl0921_AOI22 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `NL_D p5 = ~((p1 & p3) | (p2 & p4));

endmodule

module capcom_dl0921_AOI33 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    input  wire p10,
    output wire p4
);

assign `NL_D p4 = ~((p1 & p5 & p8) | (p2 & p6 & p9) | (p3 & p7 & p10));

endmodule

module capcom_dl0921_AOI41 (
    input  wire p1,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p2
);

assign `NL_D p2 = ~((p1 & p3 & p4 & p5) | p6);

endmodule

module capcom_dl0921_OAI21 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `NL_D p4 = ~(p1 & (p2 | p3));

endmodule

module capcom_dl0921_OAI211 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `NL_D p5 = ~(p1 & p2 & (p3 | p4));

endmodule

module capcom_dl0921_OAI23 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p7
);

assign `NL_D p7 = ~((p1 | p4) & (p2 | p5) & (p3 | p6));

endmodule

module capcom_dl0921_OAI41 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p6
);

assign `NL_D p6 = ~(p1 & (p2 | p3 | p4 | p5));

endmodule

//========================================================================
// Tri-State Drivers:
//========================================================================
module capcom_dl0921_M125C (
    input  wire p1,
    input  wire p2,
    output wire p3,
    output wire p3_oe
);

assign `NL_D p3 = p2;
assign `NL_D p3_oe = ~p1;

endmodule

module capcom_dl0921_M125C_X6 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    output wire p13,
    output wire p14,
    output wire p15,
    output wire p16,
    output wire p17,
    output wire p18,
    output wire p13_oe,
    output wire p14_oe,
    output wire p15_oe,
    output wire p16_oe,
    output wire p17_oe,
    output wire p18_oe
);

assign `NL_D {p13, p14, p15, p16, p17, p18} = {p7, p6, p5, p4, p3, p2};
assign `NL_D {p13_oe, p14_oe, p15_oe, p16_oe, p17_oe, p18_oe} = {6{~p1}};

endmodule

module capcom_dl0921_OUTTRI (
    input  wire p1,
    input  wire p2,
    output wire p3,
    output wire p3_oe
);

assign `NL_D p3 = p2;
assign `NL_D p3_oe = ~p1;

endmodule

module capcom_dl0921_TINVBF (
    input  wire p1,
    input  wire p2,
    output wire p3,
    output wire p3_oe
);

assign `NL_D p3 = ~p2;
assign `NL_D p3_oe = ~p1;

endmodule

module capcom_dl0921_M367C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p18,
    output wire p17,
    output wire p16,
    output wire p15,
    output wire p15_oe,
    output wire p16_oe,
    output wire p17_oe,
    output wire p18_oe
);

assign `NL_D {p15, p16, p17, p18} = {p5, p4, p3, p2};
assign `NL_D {p15_oe, p16_oe, p17_oe, p18_oe} = {4{~p1}};

endmodule

module capcom_dl0921_M368C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p18,
    output wire p17,
    output wire p16,
    output wire p15,
    output wire p15_oe,
    output wire p16_oe,
    output wire p17_oe,
    output wire p18_oe
);

assign `NL_D {p15, p16, p17, p18} = ~{p5, p4, p3, p2};
assign `NL_D {p15_oe, p16_oe, p17_oe, p18_oe} = {4{~p1}};

endmodule

module capcom_dl0921_M541C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    output wire p11,
    output wire p12,
    output wire p13,
    output wire p14,
    output wire p15,
    output wire p16,
    output wire p17,
    output wire p18,
    output wire p11_oe,
    output wire p12_oe,
    output wire p13_oe,
    output wire p14_oe,
    output wire p15_oe,
    output wire p16_oe,
    output wire p17_oe,
    output wire p18_oe
);

assign `NL_D {p11, p12, p13, p14, p15, p16, p17, p18} = {p9, p8, p7, p6, p5, p4, p3, p2};
assign `NL_D {p11_oe, p12_oe, p13_oe, p14_oe, p15_oe, p16_oe, p17_oe, p18_oe} = {8{~p1}};

endmodule

//========================================================================
// Multiplexers:
//========================================================================
module capcom_dl0921_MUX2H (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `NL_D p4 = p1 ? p2 : p3;

endmodule

module capcom_dl0921_MUX4H (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p7
);

wire [3:0] x = {p4, p3, p2, p1};

assign `NL_D p7 = x[{p6, p5}];

endmodule

module capcom_dl0921_MUX24H (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    output wire p5,
    output wire p6,
    output wire p7,
    output wire p8
);

wire [3:0] a = {p1, p2, p3, p4};
wire [3:0] b = {p10, p11, p12, p13};

assign `NL_D {p8, p7, p6, p5} = p9 ? b : a;

endmodule

module capcom_dl0921_MUX25H (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    input  wire p15,
    input  wire p16,
    output wire p6,
    output wire p7,
    output wire p8,
    output wire p9,
    output wire p10
);

wire [4:0] a = {p2, p1, p3, p4, p5};
wire [4:0] b = {p13, p12, p14, p15, p16};

assign `NL_D {p10, p9, p8, p7, p6} = p11 ? b : a;

endmodule

module capcom_dl0921_MUX26H (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p19,
    output wire p13,
    output wire p14,
    output wire p15,
    output wire p16,
    output wire p17,
    output wire p18
);

wire [5:0] a = {p6, p5, p4, p3, p2, p1};
wire [5:0] b = {p12, p11, p10, p9, p8, p7};

assign `NL_D {p18, p17, p16, p15, p14, p13} = p19 ? b : a;

endmodule

module capcom_dl0921_MUX28H (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    input  wire p15,
    input  wire p16,
    input  wire p25,
    output wire p17,
    output wire p18,
    output wire p19,
    output wire p20,
    output wire p21,
    output wire p22,
    output wire p23,
    output wire p24
);

wire [7:0] a = {p6, p7, p8, p5, p4, p3, p2, p1};
wire [7:0] b = {p15, p13, p16, p14, p12, p11, p10, p9};

assign `NL_D {p24, p21, p23, p22, p20, p19, p18, p17} = p25 ? b : a;

endmodule

module capcom_dl0921_MUX8GLH (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p7,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    input  wire p15,
    output wire p5,
    output wire p6,
    output wire p5_oe,
    output wire p6_oe
);

wire [7:0] i = {p12, p13, p14, p15, p1, p2, p3, p4};
wire [2:0] s = ~{p9, p10, p11};
wire       q = i[s];

assign `NL_D p5 = ~q;
assign `NL_D p5_oe = ~p7;
assign `NL_D p6 = q;
assign `NL_D p6_oe = ~p7;

endmodule

module capcom_dl0921_M151C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p7,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    input  wire p15,
    output wire p5
);

wire [7:0] i = {p12, p13, p14, p15, p1, p2, p3, p4};

assign `NL_D p5 = p7 ? 1'b0 : i[{p9, p10, p11}];

endmodule

module capcom_dl0921_M152C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    input  wire p15,
    output wire p5
);

wire [7:0] i = {p12, p13, p14, p15, p1, p2, p3, p4};

assign `NL_D p5 = ~i[{p9, p10, p11}];

endmodule

module capcom_dl0921_M157C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    output wire p5,
    output wire p6,
    output wire p7,
    output wire p8
);

wire [3:0] a = {p1, p2, p3, p4};
wire [3:0] b = {p10, p11, p12, p13};

assign `NL_D {p8, p7, p6, p5} = p14 ? 4'b0 : (p9 ? b : a);

endmodule

module capcom_dl0921_M258C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    output wire p5,
    output wire p6,
    output wire p7,
    output wire p8,
    output wire p8_oe,
    output wire p7_oe,
    output wire p6_oe,
    output wire p5_oe
);

wire [3:0] a = {p1, p2, p3, p4};
wire [3:0] b = {p10, p11, p12, p13};

assign `NL_D {p8, p7, p6, p5} = ~(p9 ? b : a);
assign `NL_D {p8_oe, p7_oe, p6_oe, p5_oe} = {4{~p14}};

endmodule

//========================================================================
// Decoders:
//========================================================================
module capcom_dl0921_D24GL (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p7,
    output wire p6,
    output wire p5,
    output wire p4
);

wire [3:0] o = p3 ? 4'hf : ~(4'b1 << {p2, p1});

assign `NL_D {p4, p5, p6, p7} = o;

endmodule

module capcom_dl0921_D24L (
    input  wire p1,
    input  wire p2,
    output wire p3,
    output wire p4,
    output wire p5,
    output wire p6
);

assign `NL_D p6 = ~(~p2 & ~p1);
assign `NL_D p5 = ~(~p2 & p1);
assign `NL_D p4 = ~(p2 & ~p1);
assign `NL_D p3 = ~(p2 & p1);

endmodule

module capcom_dl0921_D38GL (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p15,
    output wire p14,
    output wire p13,
    output wire p12,
    output wire p11,
    output wire p10,
    output wire p9,
    output wire p7
);

wire       en = p4 & ~p5 & ~p6;
wire [2:0] s = {p3, p2, p1};
wire [7:0] o = en ? ~(8'b1 << s) : 8'hff;

assign `NL_D {p7, p9, p10, p11, p12, p13, p14, p15} = o;

endmodule

module capcom_dl0921_PRIO (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    output wire p8,
    output wire p9,
    output wire p10,
    output wire p11,
    output wire p12,
    output wire p13,
    output wire p14
);

wire [5:0] x = ~{p6, p5, p4, p3, p2, p1};
wire       e = ~p7;

assign `NL_D p8 = ~(e & x[0]);
assign `NL_D p9 = ~(e & x[1] & ~x[0]);
assign `NL_D p10 = ~(e & x[2] & ~|x[1:0]);
assign `NL_D p11 = ~(e & x[3] & ~|x[2:0]);
assign `NL_D p12 = ~(e & x[4] & ~|x[3:0]);
assign `NL_D p13 = ~(e & x[5] & ~|x[4:0]);
assign `NL_D p14 = ~(~e | ~|x);

endmodule

//========================================================================
// Flip-Flops:
//========================================================================
module capcom_dl0921_DFFCOO (
    input  wire p1,
    input  wire p2,
    output reg  p3,
    output wire p5
);

initial p3 = 1'b0;

always @(posedge p1) begin
    p3 <= `NL_Q p2;
end

assign p5 = ~p3;

endmodule

module capcom_dl0921_DFFCOR (
    input  wire p1,
    input  wire p2,
    input  wire p4,
    output reg  p3,
    output wire p5
);

wire c;

initial p3 = 1'b0;

assign `NL_MPW c = p4;

always @(posedge p1 or negedge c) begin
    if(!c) p3 <= `NL_Q 1'b0;
    else p3 <= `NL_Q p2;
end

assign p5 = ~p3;

endmodule

module capcom_dl0921_DFFCOS (
    input  wire p1,
    input  wire p2,
    input  wire p4,
    output reg  p3
);

wire c;

initial p3 = 1'b0;

assign `NL_MPW c = p4;

always @(posedge p1 or negedge c) begin
    if(!c) p3 <= `NL_Q 1'b1;
    else p3 <= `NL_Q p2;
end

endmodule

module capcom_dl0921_DFGOO (
    input  wire p1,
    input  wire p2,
    input  wire p5,
    output wire p3,
    output wire p3_oe
);

reg q = 1'b0;

always @(posedge p1) begin
    q <= `NL_Q p2;
end

assign `NL_D p3 = q;
assign `NL_D p3_oe = ~p5;

endmodule

//========================================================================
// Registers:
//========================================================================
module capcom_dl0921_M164C (
    input  wire p1,
    input  wire p8,
    output wire p3,
    output wire p4,
    output wire p5,
    output wire p6,
    output wire p10,
    output wire p11,
    output wire p12,
    output wire p13
);

reg [7:0] q = 8'b0;

always @(posedge p8) begin
    q <= `NL_Q {q[6:0], p1};
end

assign {p13, p12, p11, p10, p6, p5, p4, p3} = q;

endmodule

module capcom_dl0921_M198C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p9,
    input  wire p8,
    input  wire p18,
    input  wire p19,
    input  wire p20,
    input  wire p21,
    input  wire p22,
    output wire p10,
    output wire p11,
    output wire p12,
    output wire p13,
    output wire p14,
    output wire p15,
    output wire p16,
    output wire p17
);

reg  [7:0] q = 8'b0;
wire [7:0] l = {p9, p7, p6, p5, p4, p3, p2, p1};

always @(posedge p19) begin
    if(p22) begin
        case({p20, p21})
            2'b01: q <= `NL_Q {q[6:0], p8};
            2'b10: q <= `NL_Q {p18, q[7:1]};
            2'b11: q <= `NL_Q l;
            default: ;
        endcase
    end
end

assign {p17, p16, p15, p14, p13, p12, p11, p10} = q;

endmodule

module capcom_dl0921_M273C (
    input  wire p1,
    input  wire p3,
    input  wire p4,
    input  wire p7,
    input  wire p8,
    input  wire p11,
    input  wire p13,
    input  wire p14,
    input  wire p17,
    input  wire p18,
    output reg  p2,
    output reg  p5,
    output reg  p6,
    output reg  p9,
    output reg  p12,
    output reg  p15,
    output reg  p16,
    output reg  p19
);

wire c;

initial {p2, p5, p6, p9, p12, p15, p16, p19} = 8'b0;

assign `NL_MPW c = p1;

always @(posedge p11 or negedge c) begin
    if(!c) {p19, p16, p15, p12, p9, p6, p5, p2} <= `NL_Q 8'b0;
    else {p19, p16, p15, p12, p9, p6, p5, p2} <= `NL_Q {p18, p17, p14, p13, p8, p7, p4, p3};
end

endmodule

module capcom_dl0921_M273CG (
    input  wire p1,
    input  wire p3,
    input  wire p4,
    input  wire p7,
    input  wire p8,
    input  wire p11,
    input  wire p13,
    input  wire p14,
    input  wire p17,
    input  wire p18,
    output wire p2,
    output wire p5,
    output wire p6,
    output wire p9,
    output wire p12,
    output wire p15,
    output wire p16,
    output wire p19,
    output wire p19_oe,
    output wire p16_oe,
    output wire p15_oe,
    output wire p12_oe,
    output wire p9_oe,
    output wire p6_oe,
    output wire p5_oe,
    output wire p2_oe
);

reg [7:0] q = 8'b0;

always @(posedge p11) begin
    q <= `NL_Q {p18, p17, p14, p13, p8, p7, p4, p3};
end

assign `NL_D {p19, p16, p15, p12, p9, p6, p5, p2} = q;
assign `NL_D {p19_oe, p16_oe, p15_oe, p12_oe, p9_oe, p6_oe, p5_oe, p2_oe} = {8{~p1}};

endmodule

//========================================================================
// Latches:
//========================================================================
module capcom_dl0921_L (
    input  wire p1,
    input  wire p2,
    output reg  p3
);

initial p3 = 1'b0;

always @* begin
    if(p1) p3 = p2;
end

endmodule

module capcom_dl0921_L8 (
    input  wire p1,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17
);

reg [7:0] q = 8'b0;

always @* begin
    if(p1) q = {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign {p3, p5, p7, p9, p11, p13, p15, p17} = q;

endmodule

module capcom_dl0921_L8G (
    input  wire p1,
    input  wire p18,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17,
    output wire p3_oe,
    output wire p5_oe,
    output wire p7_oe,
    output wire p9_oe,
    output wire p11_oe,
    output wire p13_oe,
    output wire p15_oe,
    output wire p17_oe
);

reg [7:0] q = 8'b0;

always @* begin
    if(!p1) q = {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign `NL_D {p3, p5, p7, p9, p11, p13, p15, p17} = q;
assign `NL_D {p3_oe, p5_oe, p7_oe, p9_oe, p11_oe, p13_oe, p15_oe, p17_oe} = {8{~p18}};

endmodule

module capcom_dl0921_L8GH (
    input  wire p1,
    input  wire p18,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17,
    output wire p3_oe,
    output wire p5_oe,
    output wire p7_oe,
    output wire p9_oe,
    output wire p11_oe,
    output wire p13_oe,
    output wire p15_oe,
    output wire p17_oe
);

reg [7:0] q = 8'b0;

always @* begin
    if(p1) q = {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign `NL_D {p3, p5, p7, p9, p11, p13, p15, p17} = q;
assign `NL_D {p3_oe, p5_oe, p7_oe, p9_oe, p11_oe, p13_oe, p15_oe, p17_oe} = {8{~p18}};

endmodule

module capcom_dl0921_L8L (
    input  wire p1,
    input  wire p16,
    input  wire p14,
    input  wire p12,
    input  wire p10,
    input  wire p8,
    input  wire p6,
    input  wire p4,
    input  wire p2,
    output wire p17,
    output wire p15,
    output wire p13,
    output wire p11,
    output wire p9,
    output wire p7,
    output wire p5,
    output wire p3
);

reg [7:0] q = 8'b0;

always @* begin
    if(p1) q = {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign {p3, p5, p7, p9, p11, p13, p15, p17} = ~q;

endmodule

module capcom_dl0921_R42 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p7,
    output wire p8,
    output wire p9,
    output wire p10
);

reg  [3:0] q = 4'b0;
wire       c;

assign `NL_MPW c = p2;

always @* begin
    if(!c) q = 4'hf;
    else if(p1) q = ~{p6, p5, p4, p3};
end

assign {p10, p9, p8, p7} = q;

endmodule

module capcom_dl0921_R52 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    output wire p8,
    output wire p9,
    output wire p10,
    output wire p11,
    output wire p12
);

reg  [4:0] q = 5'b0;
wire       c;

assign `NL_MPW c = p2;

always @* begin
    if(!c) q = 5'h1f;
    else if(p1) q = ~{p7, p6, p5, p4, p3};
end

assign {p12, p11, p10, p9, p8} = q;

endmodule

module capcom_dl0921_RSLT (
    input  wire p1,
    input  wire p2,
    output reg  p3
);

initial p3 = 1'b0;

always @* begin
    if(p1) p3 = 1'b1;
    else if(p2) p3 = 1'b0;
end

endmodule

//========================================================================
// Multiplier:
//========================================================================
module capcom_dl0921_MULT (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    input  wire p15,
    input  wire p16,
    input  wire p17,
    input  wire p18,
    input  wire p19,
    input  wire p20,
    input  wire p21,
    input  wire p22,
    input  wire p23,
    input  wire p24,
    input  wire p25,
    input  wire p26,
    input  wire p27,
    input  wire p28,
    input  wire p29,
    input  wire p30,
    input  wire p31,
    input  wire p32,
    input  wire p33,
    input  wire p34,
    input  wire p35,
    input  wire p36,
    input  wire p37,
    input  wire p70,
    input  wire p71,
    input  wire p72,
    output wire p38,
    output wire p39,
    output wire p40,
    output wire p41,
    output wire p42,
    output wire p43,
    output wire p44,
    output wire p45,
    output wire p46,
    output wire p47,
    output wire p48,
    output wire p49,
    output wire p50,
    output wire p51,
    output wire p52,
    output wire p53,
    output wire p54,
    output wire p55,
    output wire p56,
    output wire p57,
    output wire p58,
    output wire p59,
    output wire p60,
    output wire p61,
    output wire p62,
    output wire p63,
    output wire p64,
    output wire p65,
    output wire p66,
    output wire p67,
    output wire p68,
    output wire p69,
    output wire p53_oe,
    output wire p52_oe,
    output wire p51_oe,
    output wire p50_oe,
    output wire p49_oe,
    output wire p48_oe,
    output wire p47_oe,
    output wire p46_oe,
    output wire p45_oe,
    output wire p44_oe,
    output wire p43_oe,
    output wire p42_oe,
    output wire p41_oe,
    output wire p40_oe,
    output wire p39_oe,
    output wire p38_oe,
    output wire p69_oe,
    output wire p68_oe,
    output wire p67_oe,
    output wire p66_oe,
    output wire p65_oe,
    output wire p64_oe,
    output wire p63_oe,
    output wire p62_oe,
    output wire p61_oe,
    output wire p60_oe,
    output wire p59_oe,
    output wire p58_oe,
    output wire p57_oe,
    output wire p56_oe,
    output wire p55_oe,
    output wire p54_oe
);

reg [15:0] x = 0;
reg [15:0] y = 0;
reg [31:0] p = 0;

always @(posedge p35) begin
    x <= {p16, p15, p14, p13, p12, p11, p10, p9, p8, p7, p6, p5, p4, p3, p2, p1};
end

always @(posedge p36) begin
    y <= {p32, p31, p30, p29, p28, p27, p26, p25, p24, p23, p22, p21, p20, p19, p18, p17};
end

always @(posedge p37) begin
    p <= x * y;
end

assign {p53, p52, p51, p50, p49, p48, p47, p46, p45, p44, p43, p42, p41, p40, p39, p38} = p[15:0];
assign {p53_oe, p52_oe, p51_oe, p50_oe, p49_oe, p48_oe, p47_oe, p46_oe,
        p45_oe, p44_oe, p43_oe, p42_oe, p41_oe, p40_oe, p39_oe, p38_oe} = {16{~p70}};
assign {p69, p68, p67, p66, p65, p64, p63, p62, p61, p60, p59, p58, p57, p56, p55, p54} = p[31:16];
assign {p69_oe, p68_oe, p67_oe, p66_oe, p65_oe, p64_oe, p63_oe, p62_oe,
        p61_oe, p60_oe, p59_oe, p58_oe, p57_oe, p56_oe, p55_oe, p54_oe} = {16{~p71}};

endmodule

//========================================================================
// Latches as Registers:
//========================================================================
module capcom_dl0921_L8G_FF (
    input  wire p1,
    input  wire p18,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17,
    output wire p3_oe,
    output wire p5_oe,
    output wire p7_oe,
    output wire p9_oe,
    output wire p11_oe,
    output wire p13_oe,
    output wire p15_oe,
    output wire p17_oe
);

reg [7:0] q = 8'b0;

always @(posedge p1) begin
    q <= `NL_Q {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign `NL_D {p3, p5, p7, p9, p11, p13, p15, p17} = q;
assign `NL_D {p3_oe, p5_oe, p7_oe, p9_oe, p11_oe, p13_oe, p15_oe, p17_oe} = {8{~p18}};

endmodule

module capcom_dl0921_L8GH_BUF (
    input  wire p1,
    input  wire p18,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17,
    output wire p3_oe,
    output wire p5_oe,
    output wire p7_oe,
    output wire p9_oe,
    output wire p11_oe,
    output wire p13_oe,
    output wire p15_oe,
    output wire p17_oe
);

wire [7:0] q;

assign q = {p2, p4, p6, p8, p10, p12, p14, p16};

assign `NL_D {p3, p5, p7, p9, p11, p13, p15, p17} = q;
assign `NL_D {p3_oe, p5_oe, p7_oe, p9_oe, p11_oe, p13_oe, p15_oe, p17_oe} = {8{~p18}};

endmodule

module capcom_dl0921_L8GH_HOLD (
    input  wire p1,
    input  wire p18,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17,
    output wire p3_oe,
    output wire p5_oe,
    output wire p7_oe,
    output wire p9_oe,
    output wire p11_oe,
    output wire p13_oe,
    output wire p15_oe,
    output wire p17_oe
);

wire [7:0] d;
reg  [7:0] h = 8'b0;
wire [7:0] q;

assign d = {p2, p4, p6, p8, p10, p12, p14, p16};

always @(negedge p1) begin
    h <= d;
end

assign q = p1 ? d : h;

assign `NL_D {p3, p5, p7, p9, p11, p13, p15, p17} = q;
assign `NL_D {p3_oe, p5_oe, p7_oe, p9_oe, p11_oe, p13_oe, p15_oe, p17_oe} = {8{~p18}};

endmodule

module capcom_dl0921_R42_HOLD (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p7,
    output wire p8,
    output wire p9,
    output wire p10
);

reg  [3:0] h = 4'b0;
wire [3:0] d;
wire [3:0] q;

wire c;

assign `NL_MPW c = p2;

assign d = ~{p6, p5, p4, p3};

always @(negedge p1 or negedge c) begin
    if(!c) h <= 4'hf;
    else h <= d;
end

assign q = !c ? 4'hf : p1 ? d : h;

assign {p10, p9, p8, p7} = q;

endmodule

module capcom_dl0921_R52_HOLD (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    output wire p8,
    output wire p9,
    output wire p10,
    output wire p11,
    output wire p12
);

reg  [4:0] h = 5'b0;
wire [4:0] d;
wire [4:0] q;

wire c;

assign `NL_MPW c = p2;

assign d = ~{p7, p6, p5, p4, p3};

always @(negedge p1 or negedge c) begin
    if(!c) h <= 5'h1f;
    else h <= d;
end

assign q = !c ? 5'h1f : p1 ? d : h;

assign {p12, p11, p10, p9, p8} = q;

endmodule

module capcom_dl0921_L_HOLD (
    input  wire p1,
    input  wire p2,
    output wire p3
);

reg h = 1'b0;

always @(negedge p1) begin
    h <= p2;
end

assign p3 = p1 ? p2 : h;

endmodule

module capcom_dl0921_L8_HOLD (
    input  wire p1,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17
);

wire [7:0] d;
reg  [7:0] h = 8'b0;
wire [7:0] q;

assign d = {p2, p4, p6, p8, p10, p12, p14, p16};

always @(negedge p1) begin
    h <= d;
end

assign q = p1 ? d : h;

assign {p3, p5, p7, p9, p11, p13, p15, p17} = q;

endmodule

module capcom_dl0921_L8L_HOLD (
    input  wire p1,
    input  wire p16,
    input  wire p14,
    input  wire p12,
    input  wire p10,
    input  wire p8,
    input  wire p6,
    input  wire p4,
    input  wire p2,
    output wire p17,
    output wire p15,
    output wire p13,
    output wire p11,
    output wire p9,
    output wire p7,
    output wire p5,
    output wire p3
);

wire [7:0] d;
reg  [7:0] h = 8'b0;
wire [7:0] q;

assign d = {p2, p4, p6, p8, p10, p12, p14, p16};

always @(negedge p1) begin
    h <= d;
end

assign q = p1 ? d : h;

assign {p3, p5, p7, p9, p11, p13, p15, p17} = ~q;

endmodule

module capcom_dl0921_RSLT_HOLD (
    input  wire ck,
    input  wire en,
    input  wire p1,
    input  wire p2,
    output wire p3
);

reg h = 1'b0;

always @(posedge ck) begin
    if(en) h <= p3;
end

assign p3 = p1 ? 1'b1 : p2 ? 1'b0 : h;

endmodule

//========================================================================
// Registers with Enables:
//========================================================================
module capcom_dl0921_MULT_EN (
    input  wire ck,
    input  wire en35,
    input  wire en36,
    input  wire en37,
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    input  wire p15,
    input  wire p16,
    input  wire p17,
    input  wire p18,
    input  wire p19,
    input  wire p20,
    input  wire p21,
    input  wire p22,
    input  wire p23,
    input  wire p24,
    input  wire p25,
    input  wire p26,
    input  wire p27,
    input  wire p28,
    input  wire p29,
    input  wire p30,
    input  wire p31,
    input  wire p32,
    input  wire p33,
    input  wire p34,
    input  wire p35,
    input  wire p36,
    input  wire p37,
    input  wire p70,
    input  wire p71,
    input  wire p72,
    output wire p38,
    output wire p39,
    output wire p40,
    output wire p41,
    output wire p42,
    output wire p43,
    output wire p44,
    output wire p45,
    output wire p46,
    output wire p47,
    output wire p48,
    output wire p49,
    output wire p50,
    output wire p51,
    output wire p52,
    output wire p53,
    output wire p54,
    output wire p55,
    output wire p56,
    output wire p57,
    output wire p58,
    output wire p59,
    output wire p60,
    output wire p61,
    output wire p62,
    output wire p63,
    output wire p64,
    output wire p65,
    output wire p66,
    output wire p67,
    output wire p68,
    output wire p69,
    output wire p53_oe,
    output wire p52_oe,
    output wire p51_oe,
    output wire p50_oe,
    output wire p49_oe,
    output wire p48_oe,
    output wire p47_oe,
    output wire p46_oe,
    output wire p45_oe,
    output wire p44_oe,
    output wire p43_oe,
    output wire p42_oe,
    output wire p41_oe,
    output wire p40_oe,
    output wire p39_oe,
    output wire p38_oe,
    output wire p69_oe,
    output wire p68_oe,
    output wire p67_oe,
    output wire p66_oe,
    output wire p65_oe,
    output wire p64_oe,
    output wire p63_oe,
    output wire p62_oe,
    output wire p61_oe,
    output wire p60_oe,
    output wire p59_oe,
    output wire p58_oe,
    output wire p57_oe,
    output wire p56_oe,
    output wire p55_oe,
    output wire p54_oe
);

reg [15:0] x = 0;
reg [15:0] y = 0;
reg [31:0] p = 0;

always @(posedge ck) begin
    if(en35) x <= {p16, p15, p14, p13, p12, p11, p10, p9, p8, p7, p6, p5, p4, p3, p2, p1};
    if(en36) y <= {p32, p31, p30, p29, p28, p27, p26, p25, p24, p23, p22, p21, p20, p19, p18, p17};
    if(en37) p <= x * y;
end

assign {p53, p52, p51, p50, p49, p48, p47, p46, p45, p44, p43, p42, p41, p40, p39, p38} = p[15:0];
assign {p53_oe, p52_oe, p51_oe, p50_oe, p49_oe, p48_oe, p47_oe, p46_oe,
        p45_oe, p44_oe, p43_oe, p42_oe, p41_oe, p40_oe, p39_oe, p38_oe} = {16{~p70}};
assign {p69, p68, p67, p66, p65, p64, p63, p62, p61, p60, p59, p58, p57, p56, p55, p54} = p[31:16];
assign {p69_oe, p68_oe, p67_oe, p66_oe, p65_oe, p64_oe, p63_oe, p62_oe,
        p61_oe, p60_oe, p59_oe, p58_oe, p57_oe, p56_oe, p55_oe, p54_oe} = {16{~p71}};

endmodule

module capcom_dl0921_DFFCOO_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p2,
    output reg  p3,
    output wire p5
);

parameter CKD = 0;

initial p3 = 1'b0;

always @(posedge p1) begin
    if(en) p3 <= `NL_QE p2;
end

assign p5 = ~p3;

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    p3 <= `NL_Q p2;
end
`endif

endmodule

module capcom_dl0921_DFFCOR_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p2,
    input  wire p4,
    output reg  p3,
    output wire p5
);

parameter CKD = 0;

wire c;

initial p3 = 1'b0;

assign `NL_MPW c = p4;

always @(posedge p1 or negedge c) begin
    if(!c) p3 <= `NL_Q 1'b0;
    else if(en) p3 <= `NL_QE p2;
end

assign p5 = ~p3;

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    if(!c) p3 <= `NL_Q 1'b0;
    else p3 <= `NL_Q p2;
end
`endif

endmodule

module capcom_dl0921_DFFCOS_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p2,
    input  wire p4,
    output reg  p3
);

parameter CKD = 0;

wire c;

initial p3 = 1'b0;

assign `NL_MPW c = p4;

always @(posedge p1 or negedge c) begin
    if(!c) p3 <= `NL_Q 1'b1;
    else if(en) p3 <= `NL_QE p2;
end

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    if(!c) p3 <= `NL_Q 1'b1;
    else p3 <= `NL_Q p2;
end
`endif

endmodule

module capcom_dl0921_DFGOO_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p2,
    input  wire p5,
    output wire p3,
    output wire p3_oe
);

parameter CKD = 0;

reg q = 1'b0;

always @(posedge p1) begin
    if(en) q <= `NL_QE p2;
end

assign `NL_D p3 = q;
assign `NL_D p3_oe = ~p5;

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    q <= `NL_Q p2;
end
`endif

endmodule

module capcom_dl0921_L8GH_HOLD_EN (
    input  wire ck,
    input  wire en,
    input  wire p1,
    input  wire p18,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17,
    output wire p3_oe,
    output wire p5_oe,
    output wire p7_oe,
    output wire p9_oe,
    output wire p11_oe,
    output wire p13_oe,
    output wire p15_oe,
    output wire p17_oe
);

wire [7:0] d;
reg  [7:0] h = 8'b0;
wire [7:0] q;

assign d = {p2, p4, p6, p8, p10, p12, p14, p16};

always @(posedge ck) begin
    if(en) h <= d;
end

assign q = p1 ? d : h;

assign `NL_D {p3, p5, p7, p9, p11, p13, p15, p17} = q;
assign `NL_D {p3_oe, p5_oe, p7_oe, p9_oe, p11_oe, p13_oe, p15_oe, p17_oe} = {8{~p18}};

`ifdef SIMULATION
always @(negedge p1) if($time < 20) begin
    h <= d;
end
`endif

endmodule

module capcom_dl0921_L8G_FF_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p18,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17,
    output wire p3_oe,
    output wire p5_oe,
    output wire p7_oe,
    output wire p9_oe,
    output wire p11_oe,
    output wire p13_oe,
    output wire p15_oe,
    output wire p17_oe
);

parameter CKD = 0;

reg [7:0] q = 8'b0;

always @(posedge p1) begin
    if(en) q <= `NL_QE {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign `NL_D {p3, p5, p7, p9, p11, p13, p15, p17} = q;
assign `NL_D {p3_oe, p5_oe, p7_oe, p9_oe, p11_oe, p13_oe, p15_oe, p17_oe} = {8{~p18}};

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    q <= `NL_Q {p2, p4, p6, p8, p10, p12, p14, p16};
end
`endif

endmodule

module capcom_dl0921_L8L_HOLD_EN (
    input  wire ck,
    input  wire en,
    input  wire p1,
    input  wire p16,
    input  wire p14,
    input  wire p12,
    input  wire p10,
    input  wire p8,
    input  wire p6,
    input  wire p4,
    input  wire p2,
    output wire p17,
    output wire p15,
    output wire p13,
    output wire p11,
    output wire p9,
    output wire p7,
    output wire p5,
    output wire p3
);

wire [7:0] d;
reg  [7:0] h = 8'b0;
wire [7:0] q;

assign d = {p2, p4, p6, p8, p10, p12, p14, p16};

always @(posedge ck) begin
    if(en) h <= d;
end

assign q = p1 ? d : h;

assign {p3, p5, p7, p9, p11, p13, p15, p17} = ~q;

`ifdef SIMULATION
always @(negedge p1) if($time < 20) begin
    h <= d;
end
`endif

endmodule

module capcom_dl0921_L8_HOLD_EN (
    input  wire ck,
    input  wire en,
    input  wire p1,
    input  wire p2,
    input  wire p4,
    input  wire p6,
    input  wire p8,
    input  wire p10,
    input  wire p12,
    input  wire p14,
    input  wire p16,
    output wire p3,
    output wire p5,
    output wire p7,
    output wire p9,
    output wire p11,
    output wire p13,
    output wire p15,
    output wire p17
);

wire [7:0] d;
reg  [7:0] h = 8'b0;
wire [7:0] q;

assign d = {p2, p4, p6, p8, p10, p12, p14, p16};

always @(posedge ck) begin
    if(en) h <= d;
end

assign q = p1 ? d : h;

assign {p3, p5, p7, p9, p11, p13, p15, p17} = q;

`ifdef SIMULATION
always @(negedge p1) if($time < 20) begin
    h <= d;
end
`endif

endmodule

module capcom_dl0921_L_HOLD_EN (
    input  wire ck,
    input  wire en,
    input  wire p1,
    input  wire p2,
    output wire p3
);

reg h = 1'b0;

always @(posedge ck) begin
    if(en) h <= p2;
end

assign p3 = p1 ? p2 : h;

`ifdef SIMULATION
always @(negedge p1) if($time < 20) begin
    h <= p2;
end
`endif

endmodule

module capcom_dl0921_M164C_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p8,
    output wire p3,
    output wire p4,
    output wire p5,
    output wire p6,
    output wire p10,
    output wire p11,
    output wire p12,
    output wire p13
);

parameter CKD = 0;

reg [7:0] q = 8'b0;

always @(posedge p8) begin
    if(en) q <= `NL_QE {q[6:0], p1};
end

assign {p13, p12, p11, p10, p6, p5, p4, p3} = q;

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    q <= `NL_Q {q[6:0], p1};
end
`endif

endmodule

module capcom_dl0921_M198C_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p9,
    input  wire p8,
    input  wire p18,
    input  wire p19,
    input  wire p20,
    input  wire p21,
    input  wire p22,
    output wire p10,
    output wire p11,
    output wire p12,
    output wire p13,
    output wire p14,
    output wire p15,
    output wire p16,
    output wire p17
);

parameter CKD = 0;

reg  [7:0] q = 8'b0;
wire [7:0] l = {p9, p7, p6, p5, p4, p3, p2, p1};

always @(posedge p19) begin
    if(en && p22) begin
        case({p20, p21})
            2'b01: q <= `NL_QE {q[6:0], p8};
            2'b10: q <= `NL_QE {p18, q[7:1]};
            2'b11: q <= `NL_QE l;
            default: ;
        endcase
    end
end

assign {p17, p16, p15, p14, p13, p12, p11, p10} = q;

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    if(p22) begin
        case({p20, p21})
            2'b01: q <= `NL_Q {q[6:0], p8};
            2'b10: q <= `NL_Q {p18, q[7:1]};
            2'b11: q <= `NL_Q l;
            default: ;
        endcase
    end
end
`endif

endmodule

module capcom_dl0921_M273C_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p3,
    input  wire p4,
    input  wire p7,
    input  wire p8,
    input  wire p11,
    input  wire p13,
    input  wire p14,
    input  wire p17,
    input  wire p18,
    output reg  p2,
    output reg  p5,
    output reg  p6,
    output reg  p9,
    output reg  p12,
    output reg  p15,
    output reg  p16,
    output reg  p19
);

parameter CKD = 0;

wire c;

initial {p2, p5, p6, p9, p12, p15, p16, p19} = 8'b0;

assign `NL_MPW c = p1;

always @(posedge p11 or negedge c) begin
    if(!c) {p19, p16, p15, p12, p9, p6, p5, p2} <= `NL_Q 8'b0;
    else if(en) {p19, p16, p15, p12, p9, p6, p5, p2} <= `NL_QE {p18, p17, p14, p13, p8, p7, p4, p3};
end

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    if(!c) {p19, p16, p15, p12, p9, p6, p5, p2} <= `NL_Q 8'b0;
    else {p19, p16, p15, p12, p9, p6, p5, p2} <= `NL_Q {p18, p17, p14, p13, p8, p7, p4, p3};
end
`endif

endmodule

module capcom_dl0921_M273CG_EN (
    input  wire en,
    input  wire pclk,
    input  wire p1,
    input  wire p3,
    input  wire p4,
    input  wire p7,
    input  wire p8,
    input  wire p11,
    input  wire p13,
    input  wire p14,
    input  wire p17,
    input  wire p18,
    output wire p2,
    output wire p5,
    output wire p6,
    output wire p9,
    output wire p12,
    output wire p15,
    output wire p16,
    output wire p19,
    output wire p19_oe,
    output wire p16_oe,
    output wire p15_oe,
    output wire p12_oe,
    output wire p9_oe,
    output wire p6_oe,
    output wire p5_oe,
    output wire p2_oe
);

parameter CKD = 0;

reg [7:0] q = 8'b0;

always @(posedge p11) begin
    if(en) q <= `NL_QE {p18, p17, p14, p13, p8, p7, p4, p3};
end

assign `NL_D {p19, p16, p15, p12, p9, p6, p5, p2} = q;
assign `NL_D {p19_oe, p16_oe, p15_oe, p12_oe, p9_oe, p6_oe, p5_oe, p2_oe} = {8{~p1}};

`ifdef SIMULATION
always @(posedge pclk) if($time < 20) begin
    q <= `NL_Q {p18, p17, p14, p13, p8, p7, p4, p3};
end
`endif

endmodule

module capcom_dl0921_R42_HOLD_EN (
    input  wire ck,
    input  wire en,
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p7,
    output wire p8,
    output wire p9,
    output wire p10
);

reg  [3:0] h = 4'b0;
wire [3:0] d;
wire [3:0] q;

wire c;

assign `NL_MPW c = p2;

assign d = ~{p6, p5, p4, p3};

always @(posedge ck or negedge c) begin
    if(!c) h <= 4'hf;
    else if(en) h <= d;
end

assign q = !c ? 4'hf : p1 ? d : h;

assign {p10, p9, p8, p7} = q;

`ifdef SIMULATION
always @(negedge p1) if($time < 20) begin
    if(!c) h <= 4'hf;
    else h <= d;
end
`endif

endmodule

module capcom_dl0921_R52_HOLD_EN (
    input  wire ck,
    input  wire en,
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    output wire p8,
    output wire p9,
    output wire p10,
    output wire p11,
    output wire p12
);

reg  [4:0] h = 5'b0;
wire [4:0] d;
wire [4:0] q;

wire c;

assign `NL_MPW c = p2;

assign d = ~{p7, p6, p5, p4, p3};

always @(posedge ck or negedge c) begin
    if(!c) h <= 5'h1f;
    else if(en) h <= d;
end

assign q = !c ? 5'h1f : p1 ? d : h;

assign {p12, p11, p10, p9, p8} = q;

`ifdef SIMULATION
always @(negedge p1) if($time < 20) begin
    if(!c) h <= 5'h1f;
    else h <= d;
end
`endif

endmodule
