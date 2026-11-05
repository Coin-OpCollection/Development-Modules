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
//  Delays:
//    `D    every gate output, 0.1 ns, so latch loops and ripple chains
//          settle in order with zero wire delay
//    `Q    clock to output of the registers, 2 ns
//    `MPW  asynchronous clears and sets, 1 ns inertial
//============================================================================

`timescale 1ns/1ps

`define D #0.1
`define Q #2
`define MPW #1

//========================================================================
// Buffers:
//========================================================================
module capcom_dl0921_INV01 (
    input  wire p1,
    output wire p2
);

assign `D p2 = ~p1;

endmodule

module capcom_dl0921_BUF01 (
    input  wire p1,
    output wire p2
);

assign `D p2 = p1;

endmodule

module capcom_dl0921_BUF12 (
    input  wire p1,
    output wire p2
);

assign `D p2 = p1;

endmodule

module capcom_dl0921_NBUF02 (
    input  wire p1,
    output wire p2
);

assign `D p2 = ~p1;

endmodule

module capcom_dl0921_NBUF03 (
    input  wire p1,
    output wire p2
);

assign `D p2 = ~p1;

endmodule

module capcom_dl0921_DBUF (
    input  wire p2,
    output wire p3,
    output wire p4
);

assign `D p3 = ~p2;
assign `D p4 = p2;

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

assign `D {p11, p12, p13, p14, p15, p16, p17, p18} = {p9, p8, p7, p6, p5, p4, p3, p2};

endmodule

//========================================================================
// Gates:
//========================================================================
module capcom_dl0921_AND02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 & p2;

endmodule

module capcom_dl0921_AND03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = p1 & p2 & p3;

endmodule

module capcom_dl0921_AND04 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `D p5 = p1 & p2 & p3 & p4;

endmodule

module capcom_dl0921_OR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 | p2;

endmodule

module capcom_dl0921_OR03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = p1 | p2 | p3;

endmodule

module capcom_dl0921_OR04 (
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p1
);

assign `D p1 = p2 | p3 | p4 | p5;

endmodule

module capcom_dl0921_NAND02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = ~(p1 & p2);

endmodule

module capcom_dl0921_NAND03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = ~(p1 & p2 & p3);

endmodule

module capcom_dl0921_NAND04 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `D p5 = ~(p1 & p2 & p3 & p4);

endmodule

module capcom_dl0921_NAND05 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p6
);

assign `D p6 = ~(p1 & p2 & p3 & p4 & p5);

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

assign `D p9 = ~(p1 & p2 & p3 & p4 & p5 & p6);

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

assign `D p9 = ~(p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8);

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

assign `D p14 = ~(p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8 & p9 & p10 & p11 & p12 & p13);

endmodule

module capcom_dl0921_NOR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = ~(p1 | p2);

endmodule

module capcom_dl0921_NOR03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = ~(p1 | p2 | p3);

endmodule

module capcom_dl0921_NOR04 (
    output wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5
);

assign `D p1 = ~(p2 | p3 | p4 | p5);

endmodule

module capcom_dl0921_NOR05 (
    output wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6
);

assign `D p1 = ~(p2 | p3 | p4 | p5 | p6);

endmodule

module capcom_dl0921_XOR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 ^ p2;

endmodule

module capcom_dl0921_XNOR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = ~(p1 ^ p2);

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

assign `D p5 = (p1 & p3) | (p2 & p4);

endmodule

module capcom_dl0921_AOI21 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = ~((p1 & p2) | p3);

endmodule

module capcom_dl0921_AOI22 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `D p5 = ~((p1 & p3) | (p2 & p4));

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

assign `D p4 = ~((p1 & p5 & p8) | (p2 & p6 & p9) | (p3 & p7 & p10));

endmodule

module capcom_dl0921_AOI41 (
    input  wire p1,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    output wire p2
);

assign `D p2 = ~((p1 & p3 & p4 & p5) | p6);

endmodule

module capcom_dl0921_OAI21 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = ~(p1 & (p2 | p3));

endmodule

module capcom_dl0921_OAI211 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    output wire p5
);

assign `D p5 = ~(p1 & p2 & (p3 | p4));

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

assign `D p7 = ~((p1 | p4) & (p2 | p5) & (p3 | p6));

endmodule

module capcom_dl0921_OAI41 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p6
);

assign `D p6 = ~(p1 & (p2 | p3 | p4 | p5));

endmodule

//========================================================================
// Tri-State Drivers:
//========================================================================
module capcom_dl0921_M125C (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 ? 1'bz : p2;

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
    output wire p18
);

assign `D {p13, p14, p15, p16, p17, p18} = p1 ? 6'bz : {p7, p6, p5, p4, p3, p2};

endmodule

module capcom_dl0921_OUTTRI (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 ? 1'bz : p2;

endmodule

module capcom_dl0921_TINVBF (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 ? 1'bz : ~p2;

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
    output wire p15
);

assign `D {p15, p16, p17, p18} = p1 ? 4'bz : {p5, p4, p3, p2};

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
    output wire p15
);

assign `D {p15, p16, p17, p18} = p1 ? 4'bz : ~{p5, p4, p3, p2};

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
    output wire p18
);

assign `D {p11, p12, p13, p14, p15, p16, p17, p18} = p1 ? 8'bz : {p9, p8, p7, p6, p5, p4, p3, p2};

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

assign `D p4 = p1 ? p2 : p3;

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

assign `D p7 = x[{p6, p5}];

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

assign `D {p8, p7, p6, p5} = p9 ? b : a;

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

assign `D {p10, p9, p8, p7, p6} = p11 ? b : a;

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

assign `D {p18, p17, p16, p15, p14, p13} = p19 ? b : a;

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

assign `D {p24, p21, p23, p22, p20, p19, p18, p17} = p25 ? b : a;

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
    output wire p6
);

wire [7:0] i = {p12, p13, p14, p15, p1, p2, p3, p4};
wire [2:0] s = ~{p9, p10, p11};
wire       q = i[s];

assign `D p5 = p7 ? 1'bz : ~q;
assign `D p6 = p7 ? 1'bz : q;

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

assign `D p5 = p7 ? 1'b0 : i[{p9, p10, p11}];

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

assign `D p5 = ~i[{p9, p10, p11}];

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

assign `D {p8, p7, p6, p5} = p14 ? 4'b0 : (p9 ? b : a);

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
    output wire p8
);

wire [3:0] a = {p1, p2, p3, p4};
wire [3:0] b = {p10, p11, p12, p13};

assign `D {p8, p7, p6, p5} = p14 ? 4'bz : ~(p9 ? b : a);

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

assign `D {p4, p5, p6, p7} = o;

endmodule

module capcom_dl0921_D24L (
    input  wire p1,
    input  wire p2,
    output wire p3,
    output wire p4,
    output wire p5,
    output wire p6
);

assign `D p6 = ~(~p2 & ~p1);
assign `D p5 = ~(~p2 & p1);
assign `D p4 = ~(p2 & ~p1);
assign `D p3 = ~(p2 & p1);

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

assign `D {p7, p9, p10, p11, p12, p13, p14, p15} = o;

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

assign `D p8 = ~(e & x[0]);
assign `D p9 = ~(e & x[1] & ~x[0]);
assign `D p10 = ~(e & x[2] & ~|x[1:0]);
assign `D p11 = ~(e & x[3] & ~|x[2:0]);
assign `D p12 = ~(e & x[4] & ~|x[3:0]);
assign `D p13 = ~(e & x[5] & ~|x[4:0]);
assign `D p14 = ~(~e | ~|x);

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
    p3 <= `Q p2;
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

assign `MPW c = p4;

always @(posedge p1 or negedge c) begin
    if(!c) p3 <= `Q 1'b0;
    else p3 <= `Q p2;
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

assign `MPW c = p4;

always @(posedge p1 or negedge c) begin
    if(!c) p3 <= `Q 1'b1;
    else p3 <= `Q p2;
end

endmodule

module capcom_dl0921_DFGOO (
    input  wire p1,
    input  wire p2,
    input  wire p5,
    output wire p3
);

reg q = 1'b0;

always @(posedge p1) begin
    q <= `Q p2;
end

assign `D p3 = p5 ? 1'bz : q;

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
    q <= `Q {q[6:0], p1};
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
            2'b01: q <= `Q {q[6:0], p8};
            2'b10: q <= `Q {p18, q[7:1]};
            2'b11: q <= `Q l;
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

assign `MPW c = p1;

always @(posedge p11 or negedge c) begin
    if(!c) {p19, p16, p15, p12, p9, p6, p5, p2} <= `Q 8'b0;
    else {p19, p16, p15, p12, p9, p6, p5, p2} <= `Q {p18, p17, p14, p13, p8, p7, p4, p3};
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
    output wire p19
);

reg [7:0] q = 8'b0;

always @(posedge p11) begin
    q <= `Q {p18, p17, p14, p13, p8, p7, p4, p3};
end

assign `D {p19, p16, p15, p12, p9, p6, p5, p2} = p1 ? 8'bz : q;

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
    output wire p17
);

reg [7:0] q = 8'b0;

always @* begin
    if(!p1) q = {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign `D {p3, p5, p7, p9, p11, p13, p15, p17} = p18 ? 8'bz : q;

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
    output wire p17
);

reg [7:0] q = 8'b0;

always @* begin
    if(p1) q = {p2, p4, p6, p8, p10, p12, p14, p16};
end

assign `D {p3, p5, p7, p9, p11, p13, p15, p17} = p18 ? 8'bz : q;

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

assign `MPW c = p2;

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

assign `MPW c = p2;

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
    output wire p69
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

assign {p53, p52, p51, p50, p49, p48, p47, p46, p45, p44, p43, p42, p41, p40, p39, p38} = p70 ? 16'bz : p[15:0];
assign {p69, p68, p67, p66, p65, p64, p63, p62, p61, p60, p59, p58, p57, p56, p55, p54} = p71 ? 16'bz : p[31:16];

endmodule
