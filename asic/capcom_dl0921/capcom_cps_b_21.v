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
//  Top-level wrapper for the CAPCOM DL-0921 (CPS-B-21) netlist.
//
//  capcom_dl0921 is the gate-level CPS-B-21: 1809 Ricoh A5C cells on the
//  160 pads, the pads as the die bonds them; the wrapper takes its
//  synchronous netlist (hdl/).
//
//  The wrapper exposes the system integration surface:
//    - the chip pins by name, active-low pins with an n suffix
//    - CD and APD / BPD / CPD / DPD as input, output and output enable
//    - the power pads tied
//
//  Clocking: CLK is the system clock, at least twice the chip's 16 MHz,
//  and clocks every register; CEN is high on the CLK cycles where the
//  chip's clock rises and CEN_F where it falls. ~CLK8M, /CK10, CK500 and
//  the 4 MHz clocks are made inside.
//
//  Bidirectional pins: each pad an input, an output and an output enable;
//  CD_OE and XPD_OE are the CD0 and APD0 pad enables (each bus shares
//  one).
//============================================================================

`timescale 1ns/1ps

module capcom_cps_b_21 (
    // Clock and Reset
    input  wire        CLK,
    input  wire        CEN,
    input  wire        CEN_F,
    input  wire        RESETIn,

    // CPU Bus
    input  wire        CSn,
    input  wire        RDn,
    input  wire        WRn,
    input  wire  [5:1] CA,
    input  wire [15:0] CD_IN,
    output wire [15:0] CD_OUT,
    output wire        CD_OE,

    // CPS-A-01 Interface
    input  wire  [4:0] XS,
    input  wire        XSEL,
    input  wire  [4:0] CB,
    input  wire  [1:0] CPC,
    input  wire        CDEN,
    input  wire        FLIP,
    input  wire        FRAME,
    input  wire        OBJEO,
    input  wire        FI,
    input  wire        LI,
    input  wire        LUTPRO,
    input  wire        WSTROMn,
    input  wire        WSTLUT,
    output wire        REWENn,
    output wire        OBJUPn,

    // Frame Buffer
    input  wire  [8:0] ASD,
    input  wire  [8:0] BSD,
    output wire  [3:0] FAD,
    output wire  [3:0] FBD,

    // Graphics ROM
    input  wire  [7:0] APD_IN,
    input  wire  [7:0] BPD_IN,
    input  wire  [7:0] CPD_IN,
    input  wire  [7:0] DPD_IN,
    output wire  [7:0] APD_OUT,
    output wire  [7:0] BPD_OUT,
    output wire  [7:0] CPD_OUT,
    output wire  [7:0] DPD_OUT,
    output wire        XPD_OE,
    output wire        ROMOEn,
    output wire        CK500n,

    // Palette
    output wire [11:0] LUTA,
    output wire        LUTOEn,
    output wire        LUTWRn,

    // Video
    output wire        CLK8Mn,
    output wire        CK10n,
    output wire        HSYNC,
    output wire        HBLANKn,
    output wire        VSYNC,
    output wire        VBLANKn,

    // Configuration
    input  wire        SEC_STROBE,
    input  wire        SEC_E1n,
    input  wire        SEC_E2,
    input  wire        SEC_MODE0,
    input  wire        SEC_MODE1,
    input  wire        VBAT,

    // Test
    input  wire  [3:0] TI,
    output wire [11:0] TD
);

//========================================================================
// Bidirectional Pins:
//========================================================================
wire [15:0] cd_oe;
wire [31:0] xpd_in;
wire [31:0] xpd_out;
wire [31:0] xpd_oe;

assign xpd_in = {DPD_IN, CPD_IN, BPD_IN, APD_IN};

assign CD_OE = cd_oe[0];

assign {DPD_OUT, CPD_OUT, BPD_OUT, APD_OUT} = xpd_out;

assign XPD_OE = xpd_oe[0];

//========================================================================
// DL-0921:
//========================================================================
wire vcc = 1'b1;
wire gnd = 1'b0;

capcom_dl0921 u_dl0921 (
    // Clock and Reset
    .P103__RESETI   ( RESETIn     ),
    .P110_CLK       ( CLK         ),
    .CEN            ( CEN         ),
    .CEN_F          ( CEN_F       ),

    // CPU Bus
    .P61_CD0_IN     ( CD_IN[0]    ),
    .P61_CD0_OUT    ( CD_OUT[0]   ),
    .P61_CD0_OE     ( cd_oe[0]    ),
    .P62_CD1_IN     ( CD_IN[1]    ),
    .P62_CD1_OUT    ( CD_OUT[1]   ),
    .P62_CD1_OE     ( cd_oe[1]    ),
    .P63_CD2_IN     ( CD_IN[2]    ),
    .P63_CD2_OUT    ( CD_OUT[2]   ),
    .P63_CD2_OE     ( cd_oe[2]    ),
    .P64_CD3_IN     ( CD_IN[3]    ),
    .P64_CD3_OUT    ( CD_OUT[3]   ),
    .P64_CD3_OE     ( cd_oe[3]    ),
    .P65_CD4_IN     ( CD_IN[4]    ),
    .P65_CD4_OUT    ( CD_OUT[4]   ),
    .P65_CD4_OE     ( cd_oe[4]    ),
    .P66_CD5_IN     ( CD_IN[5]    ),
    .P66_CD5_OUT    ( CD_OUT[5]   ),
    .P66_CD5_OE     ( cd_oe[5]    ),
    .P67_CD6_IN     ( CD_IN[6]    ),
    .P67_CD6_OUT    ( CD_OUT[6]   ),
    .P67_CD6_OE     ( cd_oe[6]    ),
    .P68_CD7_IN     ( CD_IN[7]    ),
    .P68_CD7_OUT    ( CD_OUT[7]   ),
    .P68_CD7_OE     ( cd_oe[7]    ),
    .P69_CD8_IN     ( CD_IN[8]    ),
    .P69_CD8_OUT    ( CD_OUT[8]   ),
    .P69_CD8_OE     ( cd_oe[8]    ),
    .P70_CD9_IN     ( CD_IN[9]    ),
    .P70_CD9_OUT    ( CD_OUT[9]   ),
    .P70_CD9_OE     ( cd_oe[9]    ),
    .P71_CD10_IN    ( CD_IN[10]   ),
    .P71_CD10_OUT   ( CD_OUT[10]  ),
    .P71_CD10_OE    ( cd_oe[10]   ),
    .P72_CD11_IN    ( CD_IN[11]   ),
    .P72_CD11_OUT   ( CD_OUT[11]  ),
    .P72_CD11_OE    ( cd_oe[11]   ),
    .P73_CD12_IN    ( CD_IN[12]   ),
    .P73_CD12_OUT   ( CD_OUT[12]  ),
    .P73_CD12_OE    ( cd_oe[12]   ),
    .P74_CD13_IN    ( CD_IN[13]   ),
    .P74_CD13_OUT   ( CD_OUT[13]  ),
    .P74_CD13_OE    ( cd_oe[13]   ),
    .P75_CD14_IN    ( CD_IN[14]   ),
    .P75_CD14_OUT   ( CD_OUT[14]  ),
    .P75_CD14_OE    ( cd_oe[14]   ),
    .P76_CD15_IN    ( CD_IN[15]   ),
    .P76_CD15_OUT   ( CD_OUT[15]  ),
    .P76_CD15_OE    ( cd_oe[15]   ),
    .P78_CA1        ( CA[1]       ),
    .P79_CA2        ( CA[2]       ),
    .P80_CA3        ( CA[3]       ),
    .P81_CA4        ( CA[4]       ),
    .P82_CA5        ( CA[5]       ),
    .P83__CS        ( CSn         ),
    .P84__RD        ( RDn         ),
    .P85__WR        ( WRn         ),

    // CPS-A-01 Interface
    .P1_XSEL        ( XSEL        ),
    .P2_XS0         ( XS[0]       ),
    .P3_XS1         ( XS[1]       ),
    .P4_XS2         ( XS[2]       ),
    .P5_XS3         ( XS[3]       ),
    .P6_XS4         ( XS[4]       ),
    .P56_OBJEO      ( OBJEO       ),
    .P57__OBJUP     ( OBJUPn      ),
    .P58_FRAME      ( FRAME       ),
    .P59__REWEN     ( REWENn      ),
    .P86__WSTROM    ( WSTROMn     ),
    .P87_LUTPRO     ( LUTPRO      ),
    .P88_WSTLUT     ( WSTLUT      ),
    .P113_FI        ( FI          ),
    .P114_LI        ( LI          ),
    .P115_FLIP      ( FLIP        ),
    .P153_CB0       ( CB[0]       ),
    .P154_CB1       ( CB[1]       ),
    .P155_CB2       ( CB[2]       ),
    .P156_CB3       ( CB[3]       ),
    .P157_CB4       ( CB[4]       ),
    .P158_CPC0      ( CPC[0]      ),
    .P159_CPC1      ( CPC[1]      ),
    .P160_CDEN      ( CDEN        ),

    // Frame Buffer
    .P22_ASD0       ( ASD[0]      ),
    .P23_ASD1       ( ASD[1]      ),
    .P24_ASD2       ( ASD[2]      ),
    .P25_ASD3       ( ASD[3]      ),
    .P26_ASD4       ( ASD[4]      ),
    .P27_ASD5       ( ASD[5]      ),
    .P28_ASD6       ( ASD[6]      ),
    .P29_ASD7       ( ASD[7]      ),
    .P30_ASD8       ( ASD[8]      ),
    .P31_BSD0       ( BSD[0]      ),
    .P32_BSD1       ( BSD[1]      ),
    .P33_BSD2       ( BSD[2]      ),
    .P34_BSD3       ( BSD[3]      ),
    .P35_BSD4       ( BSD[4]      ),
    .P36_BSD5       ( BSD[5]      ),
    .P37_BSD6       ( BSD[6]      ),
    .P38_BSD7       ( BSD[7]      ),
    .P39_BSD8       ( BSD[8]      ),
    .P48_FAD0       ( FAD[0]      ),
    .P49_FAD1       ( FAD[1]      ),
    .P50_FAD2       ( FAD[2]      ),
    .P51_FAD3       ( FAD[3]      ),
    .P52_FBD0       ( FBD[0]      ),
    .P53_FBD1       ( FBD[1]      ),
    .P54_FBD2       ( FBD[2]      ),
    .P55_FBD3       ( FBD[3]      ),

    // Graphics ROM
    .P7__ROMOE      ( ROMOEn      ),
    .P108__CK500    ( CK500n      ),
    .P121_APD0_IN   ( xpd_in[0]   ),
    .P121_APD0_OUT  ( xpd_out[0]  ),
    .P121_APD0_OE   ( xpd_oe[0]   ),
    .P122_APD1_IN   ( xpd_in[1]   ),
    .P122_APD1_OUT  ( xpd_out[1]  ),
    .P122_APD1_OE   ( xpd_oe[1]   ),
    .P123_APD2_IN   ( xpd_in[2]   ),
    .P123_APD2_OUT  ( xpd_out[2]  ),
    .P123_APD2_OE   ( xpd_oe[2]   ),
    .P124_APD3_IN   ( xpd_in[3]   ),
    .P124_APD3_OUT  ( xpd_out[3]  ),
    .P124_APD3_OE   ( xpd_oe[3]   ),
    .P125_APD4_IN   ( xpd_in[4]   ),
    .P125_APD4_OUT  ( xpd_out[4]  ),
    .P125_APD4_OE   ( xpd_oe[4]   ),
    .P126_APD5_IN   ( xpd_in[5]   ),
    .P126_APD5_OUT  ( xpd_out[5]  ),
    .P126_APD5_OE   ( xpd_oe[5]   ),
    .P127_APD6_IN   ( xpd_in[6]   ),
    .P127_APD6_OUT  ( xpd_out[6]  ),
    .P127_APD6_OE   ( xpd_oe[6]   ),
    .P128_APD7_IN   ( xpd_in[7]   ),
    .P128_APD7_OUT  ( xpd_out[7]  ),
    .P128_APD7_OE   ( xpd_oe[7]   ),
    .P129_BPD0_IN   ( xpd_in[8]   ),
    .P129_BPD0_OUT  ( xpd_out[8]  ),
    .P129_BPD0_OE   ( xpd_oe[8]   ),
    .P130_BPD1_IN   ( xpd_in[9]   ),
    .P130_BPD1_OUT  ( xpd_out[9]  ),
    .P130_BPD1_OE   ( xpd_oe[9]   ),
    .P131_BPD2_IN   ( xpd_in[10]  ),
    .P131_BPD2_OUT  ( xpd_out[10] ),
    .P131_BPD2_OE   ( xpd_oe[10]  ),
    .P132_BPD3_IN   ( xpd_in[11]  ),
    .P132_BPD3_OUT  ( xpd_out[11] ),
    .P132_BPD3_OE   ( xpd_oe[11]  ),
    .P133_BPD4_IN   ( xpd_in[12]  ),
    .P133_BPD4_OUT  ( xpd_out[12] ),
    .P133_BPD4_OE   ( xpd_oe[12]  ),
    .P134_BPD5_IN   ( xpd_in[13]  ),
    .P134_BPD5_OUT  ( xpd_out[13] ),
    .P134_BPD5_OE   ( xpd_oe[13]  ),
    .P135_BPD6_IN   ( xpd_in[14]  ),
    .P135_BPD6_OUT  ( xpd_out[14] ),
    .P135_BPD6_OE   ( xpd_oe[14]  ),
    .P136_BPD7_IN   ( xpd_in[15]  ),
    .P136_BPD7_OUT  ( xpd_out[15] ),
    .P136_BPD7_OE   ( xpd_oe[15]  ),
    .P137_CPD0_IN   ( xpd_in[16]  ),
    .P137_CPD0_OUT  ( xpd_out[16] ),
    .P137_CPD0_OE   ( xpd_oe[16]  ),
    .P138_CPD1_IN   ( xpd_in[17]  ),
    .P138_CPD1_OUT  ( xpd_out[17] ),
    .P138_CPD1_OE   ( xpd_oe[17]  ),
    .P139_CPD2_IN   ( xpd_in[18]  ),
    .P139_CPD2_OUT  ( xpd_out[18] ),
    .P139_CPD2_OE   ( xpd_oe[18]  ),
    .P140_CPD3_IN   ( xpd_in[19]  ),
    .P140_CPD3_OUT  ( xpd_out[19] ),
    .P140_CPD3_OE   ( xpd_oe[19]  ),
    .P141_CPD4_IN   ( xpd_in[20]  ),
    .P141_CPD4_OUT  ( xpd_out[20] ),
    .P141_CPD4_OE   ( xpd_oe[20]  ),
    .P142_CPD5_IN   ( xpd_in[21]  ),
    .P142_CPD5_OUT  ( xpd_out[21] ),
    .P142_CPD5_OE   ( xpd_oe[21]  ),
    .P143_CPD6_IN   ( xpd_in[22]  ),
    .P143_CPD6_OUT  ( xpd_out[22] ),
    .P143_CPD6_OE   ( xpd_oe[22]  ),
    .P144_CPD7_IN   ( xpd_in[23]  ),
    .P144_CPD7_OUT  ( xpd_out[23] ),
    .P144_CPD7_OE   ( xpd_oe[23]  ),
    .P145_DPD0_IN   ( xpd_in[24]  ),
    .P145_DPD0_OUT  ( xpd_out[24] ),
    .P145_DPD0_OE   ( xpd_oe[24]  ),
    .P146_DPD1_IN   ( xpd_in[25]  ),
    .P146_DPD1_OUT  ( xpd_out[25] ),
    .P146_DPD1_OE   ( xpd_oe[25]  ),
    .P147_DPD2_IN   ( xpd_in[26]  ),
    .P147_DPD2_OUT  ( xpd_out[26] ),
    .P147_DPD2_OE   ( xpd_oe[26]  ),
    .P148_DPD3_IN   ( xpd_in[27]  ),
    .P148_DPD3_OUT  ( xpd_out[27] ),
    .P148_DPD3_OE   ( xpd_oe[27]  ),
    .P149_DPD4_IN   ( xpd_in[28]  ),
    .P149_DPD4_OUT  ( xpd_out[28] ),
    .P149_DPD4_OE   ( xpd_oe[28]  ),
    .P150_DPD5_IN   ( xpd_in[29]  ),
    .P150_DPD5_OUT  ( xpd_out[29] ),
    .P150_DPD5_OE   ( xpd_oe[29]  ),
    .P151_DPD6_IN   ( xpd_in[30]  ),
    .P151_DPD6_OUT  ( xpd_out[30] ),
    .P151_DPD6_OE   ( xpd_oe[30]  ),
    .P152_DPD7_IN   ( xpd_in[31]  ),
    .P152_DPD7_OUT  ( xpd_out[31] ),
    .P152_DPD7_OE   ( xpd_oe[31]  ),

    // Palette
    .P89_LUTA0      ( LUTA[0]     ),
    .P90_LUTA1      ( LUTA[1]     ),
    .P91_LUTA2      ( LUTA[2]     ),
    .P92_LUTA3      ( LUTA[3]     ),
    .P93_LUTA4      ( LUTA[4]     ),
    .P94_LUTA5      ( LUTA[5]     ),
    .P95_LUTA6      ( LUTA[6]     ),
    .P96_LUTA7      ( LUTA[7]     ),
    .P97_LUTA8      ( LUTA[8]     ),
    .P98_LUTA9      ( LUTA[9]     ),
    .P99_LUTA10     ( LUTA[10]    ),
    .P100_LUTA11    ( LUTA[11]    ),
    .P101__LUTOE    ( LUTOEn      ),
    .P102__LUTWR    ( LUTWRn      ),

    // Video
    .P104__CLK8M    ( CLK8Mn      ),
    .P106__CK10     ( CK10n       ),
    .P116_HSYNC     ( HSYNC       ),
    .P117__HBLANK   ( HBLANKn     ),
    .P118_VSYNC     ( VSYNC       ),
    .P119__VBLANK   ( VBLANKn     ),

    // Configuration
    .P40_VBAT       ( VBAT        ),
    .P42_SEC_STROBE ( SEC_STROBE  ),
    .P43_SEC__E1    ( SEC_E1n     ),
    .P44_SEC_E2     ( SEC_E2      ),
    .P45_SEC_MODE0  ( SEC_MODE0   ),
    .P46_SEC_MODE1  ( SEC_MODE1   ),

    // Test
    .P9_TD0         ( TD[0]       ),
    .P10_TD1        ( TD[1]       ),
    .P11_TD2        ( TD[2]       ),
    .P12_TD3        ( TD[3]       ),
    .P13_TD4        ( TD[4]       ),
    .P14_TD5        ( TD[5]       ),
    .P15_TD6        ( TD[6]       ),
    .P16_TD7        ( TD[7]       ),
    .P17_TD8        ( TD[8]       ),
    .P18_TD9        ( TD[9]       ),
    .P19_TD10       ( TD[10]      ),
    .P20_TD11       ( TD[11]      ),
    .P107_TI0       ( TI[0]       ),
    .P109_TI1       ( TI[1]       ),
    .P111_TI2       ( TI[2]       ),
    .P112_TI3       ( TI[3]       ),

    // Power
    .P8_VCC         ( vcc         ),
    .P21_GND        ( gnd         ),
    .P41_GND        ( gnd         ),
    .P47_GND        ( gnd         ),
    .P60_VCC        ( vcc         ),
    .P77_GND        ( gnd         ),
    .P105_VCC       ( vcc         ),
    .P120_GND       ( gnd         )
);

endmodule
