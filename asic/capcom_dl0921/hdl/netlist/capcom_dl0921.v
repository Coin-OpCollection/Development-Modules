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
//  CAPCOM DL-0921 (CPS-B-21) gate-level netlist.
//
//  1809 Ricoh A5C cells (capcom_dl0921_cells.v) on the 160 pads, retraced
//  and corrected on the die. Pads 86 / 87 as the die bonds them.
//
//  Pads:
//    P<n>_<name>, inout, in package order; a leading _ marks an active-low
//    pin
//
//  Clocking:
//    CLK (P110) is the 16 MHz clock input; ~CLK8M, /CK10, CK500 and the
//    4 MHz clocks are made inside
//============================================================================

`timescale 1ns/1ps

module capcom_dl0921 (
    inout  wire P1_XSEL,
    inout  wire P2_XS0,
    inout  wire P3_XS1,
    inout  wire P4_XS2,
    inout  wire P5_XS3,
    inout  wire P6_XS4,
    inout  wire P7__ROMOE,
    inout  wire P8_VCC,
    inout  wire P9_TD0,
    inout  wire P10_TD1,
    inout  wire P11_TD2,
    inout  wire P12_TD3,
    inout  wire P13_TD4,
    inout  wire P14_TD5,
    inout  wire P15_TD6,
    inout  wire P16_TD7,
    inout  wire P17_TD8,
    inout  wire P18_TD9,
    inout  wire P19_TD10,
    inout  wire P20_TD11,
    inout  wire P21_GND,
    inout  wire P22_ASD0,
    inout  wire P23_ASD1,
    inout  wire P24_ASD2,
    inout  wire P25_ASD3,
    inout  wire P26_ASD4,
    inout  wire P27_ASD5,
    inout  wire P28_ASD6,
    inout  wire P29_ASD7,
    inout  wire P30_ASD8,
    inout  wire P31_BSD0,
    inout  wire P32_BSD1,
    inout  wire P33_BSD2,
    inout  wire P34_BSD3,
    inout  wire P35_BSD4,
    inout  wire P36_BSD5,
    inout  wire P37_BSD6,
    inout  wire P38_BSD7,
    inout  wire P39_BSD8,
    inout  wire P40_VBAT,
    inout  wire P41_GND,
    inout  wire P42_SEC_STROBE,
    inout  wire P43_SEC__E1,
    inout  wire P44_SEC_E2,
    inout  wire P45_SEC_MODE0,
    inout  wire P46_SEC_MODE1,
    inout  wire P47_GND,
    inout  wire P48_FAD0,
    inout  wire P49_FAD1,
    inout  wire P50_FAD2,
    inout  wire P51_FAD3,
    inout  wire P52_FBD0,
    inout  wire P53_FBD1,
    inout  wire P54_FBD2,
    inout  wire P55_FBD3,
    inout  wire P56_OBJEO,
    inout  wire P57__OBJUP,
    inout  wire P58_FRAME,
    inout  wire P59__REWEN,
    inout  wire P60_VCC,
    inout  wire P61_CD0,
    inout  wire P62_CD1,
    inout  wire P63_CD2,
    inout  wire P64_CD3,
    inout  wire P65_CD4,
    inout  wire P66_CD5,
    inout  wire P67_CD6,
    inout  wire P68_CD7,
    inout  wire P69_CD8,
    inout  wire P70_CD9,
    inout  wire P71_CD10,
    inout  wire P72_CD11,
    inout  wire P73_CD12,
    inout  wire P74_CD13,
    inout  wire P75_CD14,
    inout  wire P76_CD15,
    inout  wire P77_GND,
    inout  wire P78_CA1,
    inout  wire P79_CA2,
    inout  wire P80_CA3,
    inout  wire P81_CA4,
    inout  wire P82_CA5,
    inout  wire P83__CS,
    inout  wire P84__RD,
    inout  wire P85__WR,
    inout  wire P86__WSTROM,
    inout  wire P87_LUTPRO,
    inout  wire P88_WSTLUT,
    inout  wire P89_LUTA0,
    inout  wire P90_LUTA1,
    inout  wire P91_LUTA2,
    inout  wire P92_LUTA3,
    inout  wire P93_LUTA4,
    inout  wire P94_LUTA5,
    inout  wire P95_LUTA6,
    inout  wire P96_LUTA7,
    inout  wire P97_LUTA8,
    inout  wire P98_LUTA9,
    inout  wire P99_LUTA10,
    inout  wire P100_LUTA11,
    inout  wire P101__LUTOE,
    inout  wire P102__LUTWR,
    inout  wire P103__RESETI,
    inout  wire P104__CLK8M,
    inout  wire P105_VCC,
    inout  wire P106__CK10,
    inout  wire P107_TI0,
    inout  wire P108__CK500,
    inout  wire P109_TI1,
    inout  wire P110_CLK,
    inout  wire P111_TI2,
    inout  wire P112_TI3,
    inout  wire P113_FI,
    inout  wire P114_LI,
    inout  wire P115_FLIP,
    inout  wire P116_HSYNC,
    inout  wire P117__HBLANK,
    inout  wire P118_VSYNC,
    inout  wire P119__VBLANK,
    inout  wire P120_GND,
    inout  wire P121_APD0,
    inout  wire P122_APD1,
    inout  wire P123_APD2,
    inout  wire P124_APD3,
    inout  wire P125_APD4,
    inout  wire P126_APD5,
    inout  wire P127_APD6,
    inout  wire P128_APD7,
    inout  wire P129_BPD0,
    inout  wire P130_BPD1,
    inout  wire P131_BPD2,
    inout  wire P132_BPD3,
    inout  wire P133_BPD4,
    inout  wire P134_BPD5,
    inout  wire P135_BPD6,
    inout  wire P136_BPD7,
    inout  wire P137_CPD0,
    inout  wire P138_CPD1,
    inout  wire P139_CPD2,
    inout  wire P140_CPD3,
    inout  wire P141_CPD4,
    inout  wire P142_CPD5,
    inout  wire P143_CPD6,
    inout  wire P144_CPD7,
    inout  wire P145_DPD0,
    inout  wire P146_DPD1,
    inout  wire P147_DPD2,
    inout  wire P148_DPD3,
    inout  wire P149_DPD4,
    inout  wire P150_DPD5,
    inout  wire P151_DPD6,
    inout  wire P152_DPD7,
    inout  wire P153_CB0,
    inout  wire P154_CB1,
    inout  wire P155_CB2,
    inout  wire P156_CB3,
    inout  wire P157_CB4,
    inout  wire P158_CPC0,
    inout  wire P159_CPC1,
    inout  wire P160_CDEN
);

//========================================================================
// Nets:
//========================================================================
supply1 VCC;
supply0 GND;

wire \/APD0 ;
wire \/APD1 ;
wire \/APD2 ;
wire \/APD3 ;
wire \/APD4 ;
wire \/APD5 ;
wire \/APD6 ;
wire \/APD7 ;
wire \/ASD0 ;
wire \/ASD1 ;
wire \/ASD2 ;
wire \/ASD3 ;
wire \/ASD4 ;
wire \/ASD5 ;
wire \/ASD6 ;
wire \/ASD7 ;
wire \/ASD8 ;
wire \/BPD0 ;
wire \/BPD1 ;
wire \/BPD2 ;
wire \/BPD3 ;
wire \/BPD4 ;
wire \/BPD5 ;
wire \/BPD6 ;
wire \/BPD7 ;
wire \/BSD0 ;
wire \/BSD1 ;
wire \/BSD2 ;
wire \/BSD3 ;
wire \/BSD4 ;
wire \/BSD5 ;
wire \/BSD6 ;
wire \/BSD7 ;
wire \/BSD8 ;
wire \/CA1 ;
wire \/CA2 ;
wire \/CA3 ;
wire \/CA4 ;
wire \/CA5 ;
wire \/CB0 ;
wire \/CB1 ;
wire \/CB2 ;
wire \/CB3 ;
wire \/CB4 ;
wire \/CD10 ;
wire \/CD11 ;
wire \/CD12 ;
wire \/CD13 ;
wire \/CD14 ;
wire \/CD15 ;
wire \/CD2 ;
wire \/CD3 ;
wire \/CD4 ;
wire \/CD5 ;
wire \/CD6 ;
wire \/CD7 ;
wire \/CD8 ;
wire \/CD9 ;
wire \/CHECK1-D0 ;
wire \/CHECK1-D1 ;
wire \/CHECK1-D10 ;
wire \/CHECK1-D11 ;
wire \/CHECK1-D12 ;
wire \/CHECK1-D13 ;
wire \/CHECK1-D14 ;
wire \/CHECK1-D15 ;
wire \/CHECK1-D2 ;
wire \/CHECK1-D3 ;
wire \/CHECK1-D4 ;
wire \/CHECK1-D5 ;
wire \/CHECK1-D6 ;
wire \/CHECK1-D7 ;
wire \/CHECK1-D8 ;
wire \/CHECK1-D9 ;
wire \/CHECK2-D0 ;
wire \/CHECK2-D1 ;
wire \/CHECK2-D10 ;
wire \/CHECK2-D11 ;
wire \/CHECK2-D12 ;
wire \/CHECK2-D13 ;
wire \/CHECK2-D14 ;
wire \/CHECK2-D15 ;
wire \/CHECK2-D2 ;
wire \/CHECK2-D3 ;
wire \/CHECK2-D4 ;
wire \/CHECK2-D5 ;
wire \/CHECK2-D6 ;
wire \/CHECK2-D7 ;
wire \/CHECK2-D8 ;
wire \/CHECK2-D9 ;
wire \/CPC0 ;
wire \/CPC1 ;
wire \/CPD0 ;
wire \/CPD1 ;
wire \/CPD2 ;
wire \/CPD3 ;
wire \/CPD4 ;
wire \/CPD5 ;
wire \/CPD6 ;
wire \/CPD7 ;
wire \/DPD0 ;
wire \/DPD1 ;
wire \/DPD2 ;
wire \/DPD3 ;
wire \/DPD4 ;
wire \/DPD5 ;
wire \/DPD6 ;
wire \/DPD7 ;
wire \/FAD0 ;
wire \/FAD1 ;
wire \/FAD2 ;
wire \/FAD3 ;
wire \/FBD0 ;
wire \/FBD1 ;
wire \/FBD2 ;
wire \/FBD3 ;
wire \/LUT0 ;
wire \/LUT1 ;
wire \/LUT10 ;
wire \/LUT11 ;
wire \/LUT2 ;
wire \/LUT3 ;
wire \/LUT4 ;
wire \/LUT5 ;
wire \/LUT6 ;
wire \/LUT7 ;
wire \/LUT8 ;
wire \/LUT9 ;
wire \/TI0 ;
wire \/TI1 ;
wire \/TI2 ;
wire \/TI3 ;
wire \/XS0 ;
wire \/XS1 ;
wire \/XS2 ;
wire \/XS3 ;
wire \/XS4 ;
wire \/bus-io/MUTE-OUT ;
wire \/bus-signal-control/GFX-CHNL ;
wire \/bus-signal-control/GFX-OUT-LMSB ;
wire \/bus-signal-control/~CK10 ;
wire \/bus-signal-control/~CK500 ;
wire \/bus-signal-control/~CS ;
wire \/bus-signal-control/~RD ;
wire \/bus-signal-control/~WR ;
wire \/bus-signal-control/~WSTROM ;
wire \/counter-fi/FI ;
wire \/cps-id/CPS-ID-D0 ;
wire \/cps-id/CPS-ID-D1 ;
wire \/cps-id/CPS-ID-D10 ;
wire \/cps-id/CPS-ID-D11 ;
wire \/cps-id/CPS-ID-D12 ;
wire \/cps-id/CPS-ID-D13 ;
wire \/cps-id/CPS-ID-D14 ;
wire \/cps-id/CPS-ID-D15 ;
wire \/cps-id/CPS-ID-D2 ;
wire \/cps-id/CPS-ID-D3 ;
wire \/cps-id/CPS-ID-D4 ;
wire \/cps-id/CPS-ID-D5 ;
wire \/cps-id/~E ;
wire \/cps-id/~RESET ;
wire \/debug/td-io/OUT0 ;
wire \/debug/td-io/OUT1 ;
wire \/debug/td-io/OUT10 ;
wire \/debug/td-io/OUT11 ;
wire \/debug/td-io/OUT2 ;
wire \/debug/td-io/OUT3 ;
wire \/debug/td-io/OUT4 ;
wire \/debug/td-io/OUT5 ;
wire \/debug/td-io/OUT6 ;
wire \/debug/td-io/OUT7 ;
wire \/debug/td-io/OUT8 ;
wire \/debug/td-io/OUT9 ;
wire \/lut-assembly/BLANK ;
wire \/lut-assembly/layer-control/BUS1 ;
wire \/lut-assembly/layer-control/BUS2 ;
wire \/lut-assembly/layer-control/BUS3 ;
wire \/lut-assembly/layer-control/BUS4 ;
wire \/lut-assembly/layer-control/BUS5 ;
wire \/lut-assembly/layer-control/ROW1-S0 ;
wire \/lut-assembly/layer-control/ROW1-S1 ;
wire \/lut-assembly/layer-control/ROW2-S0 ;
wire \/lut-assembly/layer-control/ROW2-S1 ;
wire \/lut-assembly/layer-control/ROW3-S0 ;
wire \/lut-assembly/layer-control/ROW3-S1 ;
wire \/lut-assembly/layer-control/ROW4-S0 ;
wire \/lut-assembly/layer-control/ROW4-S1 ;
wire \/lut-assembly/layer-control/WR ;
wire \/lut-assembly/layer-control/~E ;
wire \/lut-assembly/layer-control/~RESET ;
wire \/lut-assembly/layer-draw-order/COL2-D0 ;
wire \/lut-assembly/layer-draw-order/COL2-D1 ;
wire \/lut-assembly/layer-draw-order/COL2-D10 ;
wire \/lut-assembly/layer-draw-order/COL2-D11 ;
wire \/lut-assembly/layer-draw-order/COL2-D2 ;
wire \/lut-assembly/layer-draw-order/COL2-D3 ;
wire \/lut-assembly/layer-draw-order/COL2-D4 ;
wire \/lut-assembly/layer-draw-order/COL2-D5 ;
wire \/lut-assembly/layer-draw-order/COL2-D6 ;
wire \/lut-assembly/layer-draw-order/COL2-D7 ;
wire \/lut-assembly/layer-draw-order/COL2-D8 ;
wire \/lut-assembly/layer-draw-order/COL2-D9 ;
wire \/lut-assembly/layer-draw-order/COL3-D0 ;
wire \/lut-assembly/layer-draw-order/COL3-D1 ;
wire \/lut-assembly/layer-draw-order/COL3-D10 ;
wire \/lut-assembly/layer-draw-order/COL3-D11 ;
wire \/lut-assembly/layer-draw-order/COL3-D2 ;
wire \/lut-assembly/layer-draw-order/COL3-D3 ;
wire \/lut-assembly/layer-draw-order/COL3-D4 ;
wire \/lut-assembly/layer-draw-order/COL3-D5 ;
wire \/lut-assembly/layer-draw-order/COL3-D6 ;
wire \/lut-assembly/layer-draw-order/COL3-D7 ;
wire \/lut-assembly/layer-draw-order/COL3-D8 ;
wire \/lut-assembly/layer-draw-order/COL3-D9 ;
wire \/lut-assembly/layer-draw-order/COL4-D0 ;
wire \/lut-assembly/layer-draw-order/COL4-D1 ;
wire \/lut-assembly/layer-draw-order/COL4-D10 ;
wire \/lut-assembly/layer-draw-order/COL4-D11 ;
wire \/lut-assembly/layer-draw-order/COL4-D2 ;
wire \/lut-assembly/layer-draw-order/COL4-D3 ;
wire \/lut-assembly/layer-draw-order/COL4-D4 ;
wire \/lut-assembly/layer-draw-order/COL4-D5 ;
wire \/lut-assembly/layer-draw-order/COL4-D6 ;
wire \/lut-assembly/layer-draw-order/COL4-D7 ;
wire \/lut-assembly/layer-draw-order/COL4-D8 ;
wire \/lut-assembly/layer-draw-order/COL4-D9 ;
wire \/lut-assembly/layer-draw-order/~R1C1 ;
wire \/lut-assembly/layer-draw-order/~R1C2 ;
wire \/lut-assembly/layer-draw-order/~R1C3 ;
wire \/lut-assembly/layer-draw-order/~R1C4 ;
wire \/lut-assembly/layer-draw-order/~R2C1 ;
wire \/lut-assembly/layer-draw-order/~R2C2 ;
wire \/lut-assembly/layer-draw-order/~R2C3 ;
wire \/lut-assembly/layer-draw-order/~R2C4 ;
wire \/lut-assembly/layer-draw-order/~R3C1 ;
wire \/lut-assembly/layer-draw-order/~R3C2 ;
wire \/lut-assembly/layer-draw-order/~R3C3 ;
wire \/lut-assembly/layer-draw-order/~R3C4 ;
wire \/lut-assembly/layer-draw-order/~R4C1 ;
wire \/lut-assembly/layer-draw-order/~R4C2 ;
wire \/lut-assembly/layer-draw-order/~R4C3 ;
wire \/lut-assembly/layer-draw-order/~R4C4 ;
wire \/lut-assembly/lut-storage/ROW5-D0 ;
wire \/lut-assembly/lut-storage/ROW5-D1 ;
wire \/lut-assembly/lut-storage/ROW5-D2 ;
wire \/lut-assembly/lut-storage/ROW5-D3 ;
wire \/lut-assembly/lut-storage/ROW5-D4 ;
wire \/lut-assembly/lut-storage/ROW5-D5 ;
wire \/lut-assembly/lut-storage/ROW5-D6 ;
wire \/lut-assembly/lut-storage/ROW6-D0 ;
wire \/lut-assembly/lut-storage/ROW6-D1 ;
wire \/lut-assembly/lut-storage/ROW6-D2 ;
wire \/lut-assembly/lut-storage/ROW6-D3 ;
wire \/lut-assembly/lut-storage/ROW6-D4 ;
wire \/lut-assembly/lut-storage/ROW6-D5 ;
wire \/lut-assembly/lut-storage/ROW6-D6 ;
wire \/lut-assembly/lut-storage/~E1 ;
wire \/lut-assembly/lut-storage/~E2 ;
wire \/lut-assembly/lut-storage/~E3 ;
wire \/lut-assembly/lut-storage/~E4 ;
wire \/lut-assembly/lut-storage/~E5 ;
wire \/lut-assembly/lut-storage/~E6 ;
wire \/lut-assembly/lut-storage/~E7 ;
wire \/lut-assembly/priority-masks/OUT ;
wire \/lut-assembly/priority-masks/ROW0 ;
wire \/lut-assembly/priority-masks/ROW1 ;
wire \/lut-assembly/priority-masks/ROW2 ;
wire \/lut-assembly/priority-masks/ROW3 ;
wire \/lut-assembly/priority-transparency/~ROW5-E ;
wire \/lut-assembly/priority-transparency/~ROW6-E ;
wire \/lut-assembly/priority-transparency/~SPRITE_R1 ;
wire \/lut-assembly/priority-transparency/~SPRITE_R2 ;
wire \/lut-assembly/priority-transparency/~SPRITE_R3 ;
wire \/lut-assembly/priority-transparency/~SPRITE_R4 ;
wire \/lut-counter/CLK4M ;
wire \/lut-counter/INC ;
wire \/lut-counter/SET10 ;
wire \/lut-counter/SET11 ;
wire \/lut-counter/SET9 ;
wire \/lut-counter/~LOAD ;
wire \/lut-io/B0 ;
wire \/lut-io/B1 ;
wire \/lut-io/B10 ;
wire \/lut-io/B11 ;
wire \/lut-io/B2 ;
wire \/lut-io/B3 ;
wire \/lut-io/B4 ;
wire \/lut-io/B5 ;
wire \/lut-io/B6 ;
wire \/lut-io/B7 ;
wire \/lut-io/B8 ;
wire \/lut-io/B9 ;
wire \/lut-io/~E ;
wire \/main-signals/CLK16M ;
wire \/main-signals/DEFAULT ;
wire \/main-signals/LI ;
wire \/main-signals/SEC-MODE0 ;
wire \/main-signals/SEC-MODE1 ;
wire \/main-signals/~CLK8M ;
wire \/main-signals/~RESETI ;
wire \/multiplier/~LSB-E ;
wire \/multiplier/~MSB-E ;
wire \/multiplier/~TC-E ;
wire \/multiplier/~X-E ;
wire \/multiplier/~Y-E ;
wire \/obj-manager/FRAME ;
wire \/obj-manager/OBJEO ;
wire \/obj-manager/SERIAL-CHNL ;
wire \/obj-manager/SERIAL-LOAD ;
wire \/obj-manager/XSEL ;
wire \/obj-manager/sd-bus/XSD0 ;
wire \/obj-manager/sd-bus/XSD1 ;
wire \/obj-manager/sd-bus/XSD2 ;
wire \/obj-manager/sd-bus/XSD3 ;
wire \/obj-manager/sd-bus/XSD4 ;
wire \/obj-manager/sd-bus/XSD5 ;
wire \/obj-manager/sd-bus/XSD6 ;
wire \/obj-manager/sd-bus/XSD7 ;
wire \/obj-manager/sd-bus/XSD8 ;
wire \/obj-manager/sd-bus/~A~B ;
wire \/obj-manager/sd-bus/~DEBUG ;
wire \/obj-manager/xpd-bus4/A ;
wire \/obj-manager/xpd-bus4/B ;
wire \/obj-manager/xpd-bus4/C ;
wire \/obj-manager/xpd-bus4/D ;
wire \/obj-manager/xpd-bus4/GFX-LOAD ;
wire \/obj-manager/xpd-bus4/XSEL-SYNC ;
wire \/obj-manager/~REWEN ;
wire \/palette-control/LUTPRO ;
wire \/palette-control/WSTLUT ;
wire \/palette-control/~E ;
wire \/palette-control/~LUT-WR ;
wire \/raster-interrupts/counter1/ENABLE ;
wire \/raster-interrupts/counter1/SET-~INC ;
wire \/raster-interrupts/counter1/~BUS0 ;
wire \/raster-interrupts/counter1/~BUS1 ;
wire \/raster-interrupts/counter1/~BUS2 ;
wire \/raster-interrupts/counter1/~BUS3 ;
wire \/raster-interrupts/counter1/~BUS4 ;
wire \/raster-interrupts/counter1/~BUS5 ;
wire \/raster-interrupts/counter1/~BUS6 ;
wire \/raster-interrupts/counter1/~BUS7 ;
wire \/raster-interrupts/counter1/~BUS8 ;
wire \/raster-interrupts/counter1/~OUT-ENABLE ;
wire \/raster-interrupts/counter1/~RESET ;
wire \/raster-interrupts/counter1/~ZERO ;
wire \/raster-interrupts/counter2/ENABLE ;
wire \/raster-interrupts/counter2/~OUT-ENABLE ;
wire \/raster-interrupts/counter2/~ZERO ;
wire \/raster-interrupts/counter3/ENABLE ;
wire \/raster-interrupts/counter3/_OUT0 ;
wire \/raster-interrupts/counter3/~OUT-ENABLE ;
wire \/raster-interrupts/counter3/~ZERO ;
wire \/raster-interrupts/~OBJUP ;
wire \/security-check/OUT ;
wire \/security-check/~E1 ;
wire \/security-check/~E2 ;
wire \/security-management/SEC-CLK ;
wire \/security-management/SEC-DATA ;
wire \/security-management/VBAT ;
wire \/security-management/addr-decoder-registry/KEY10 ;
wire \/security-management/addr-decoder-registry/KEY100 ;
wire \/security-management/addr-decoder-registry/KEY101 ;
wire \/security-management/addr-decoder-registry/KEY102 ;
wire \/security-management/addr-decoder-registry/KEY103 ;
wire \/security-management/addr-decoder-registry/KEY104 ;
wire \/security-management/addr-decoder-registry/KEY105 ;
wire \/security-management/addr-decoder-registry/KEY106 ;
wire \/security-management/addr-decoder-registry/KEY107 ;
wire \/security-management/addr-decoder-registry/KEY108 ;
wire \/security-management/addr-decoder-registry/KEY109 ;
wire \/security-management/addr-decoder-registry/KEY11 ;
wire \/security-management/addr-decoder-registry/KEY110 ;
wire \/security-management/addr-decoder-registry/KEY111 ;
wire \/security-management/addr-decoder-registry/KEY112 ;
wire \/security-management/addr-decoder-registry/KEY113 ;
wire \/security-management/addr-decoder-registry/KEY114 ;
wire \/security-management/addr-decoder-registry/KEY115 ;
wire \/security-management/addr-decoder-registry/KEY116 ;
wire \/security-management/addr-decoder-registry/KEY117 ;
wire \/security-management/addr-decoder-registry/KEY118 ;
wire \/security-management/addr-decoder-registry/KEY119 ;
wire \/security-management/addr-decoder-registry/KEY12 ;
wire \/security-management/addr-decoder-registry/KEY120 ;
wire \/security-management/addr-decoder-registry/KEY121 ;
wire \/security-management/addr-decoder-registry/KEY122 ;
wire \/security-management/addr-decoder-registry/KEY123 ;
wire \/security-management/addr-decoder-registry/KEY124 ;
wire \/security-management/addr-decoder-registry/KEY125 ;
wire \/security-management/addr-decoder-registry/KEY126 ;
wire \/security-management/addr-decoder-registry/KEY127 ;
wire \/security-management/addr-decoder-registry/KEY128 ;
wire \/security-management/addr-decoder-registry/KEY129 ;
wire \/security-management/addr-decoder-registry/KEY13 ;
wire \/security-management/addr-decoder-registry/KEY130 ;
wire \/security-management/addr-decoder-registry/KEY131 ;
wire \/security-management/addr-decoder-registry/KEY132 ;
wire \/security-management/addr-decoder-registry/KEY133 ;
wire \/security-management/addr-decoder-registry/KEY134 ;
wire \/security-management/addr-decoder-registry/KEY14 ;
wire \/security-management/addr-decoder-registry/KEY15 ;
wire \/security-management/addr-decoder-registry/KEY16 ;
wire \/security-management/addr-decoder-registry/KEY17 ;
wire \/security-management/addr-decoder-registry/KEY18 ;
wire \/security-management/addr-decoder-registry/KEY19 ;
wire \/security-management/addr-decoder-registry/KEY20 ;
wire \/security-management/addr-decoder-registry/KEY21 ;
wire \/security-management/addr-decoder-registry/KEY22 ;
wire \/security-management/addr-decoder-registry/KEY23 ;
wire \/security-management/addr-decoder-registry/KEY24 ;
wire \/security-management/addr-decoder-registry/KEY25 ;
wire \/security-management/addr-decoder-registry/KEY26 ;
wire \/security-management/addr-decoder-registry/KEY27 ;
wire \/security-management/addr-decoder-registry/KEY28 ;
wire \/security-management/addr-decoder-registry/KEY29 ;
wire \/security-management/addr-decoder-registry/KEY30 ;
wire \/security-management/addr-decoder-registry/KEY31 ;
wire \/security-management/addr-decoder-registry/KEY32 ;
wire \/security-management/addr-decoder-registry/KEY33 ;
wire \/security-management/addr-decoder-registry/KEY34 ;
wire \/security-management/addr-decoder-registry/KEY35 ;
wire \/security-management/addr-decoder-registry/KEY36 ;
wire \/security-management/addr-decoder-registry/KEY37 ;
wire \/security-management/addr-decoder-registry/KEY38 ;
wire \/security-management/addr-decoder-registry/KEY39 ;
wire \/security-management/addr-decoder-registry/KEY40 ;
wire \/security-management/addr-decoder-registry/KEY41 ;
wire \/security-management/addr-decoder-registry/KEY42 ;
wire \/security-management/addr-decoder-registry/KEY43 ;
wire \/security-management/addr-decoder-registry/KEY44 ;
wire \/security-management/addr-decoder-registry/KEY45 ;
wire \/security-management/addr-decoder-registry/KEY46 ;
wire \/security-management/addr-decoder-registry/KEY47 ;
wire \/security-management/addr-decoder-registry/KEY48 ;
wire \/security-management/addr-decoder-registry/KEY49 ;
wire \/security-management/addr-decoder-registry/KEY50 ;
wire \/security-management/addr-decoder-registry/KEY51 ;
wire \/security-management/addr-decoder-registry/KEY52 ;
wire \/security-management/addr-decoder-registry/KEY53 ;
wire \/security-management/addr-decoder-registry/KEY54 ;
wire \/security-management/addr-decoder-registry/KEY55 ;
wire \/security-management/addr-decoder-registry/KEY56 ;
wire \/security-management/addr-decoder-registry/KEY57 ;
wire \/security-management/addr-decoder-registry/KEY58 ;
wire \/security-management/addr-decoder-registry/KEY59 ;
wire \/security-management/addr-decoder-registry/KEY6 ;
wire \/security-management/addr-decoder-registry/KEY60 ;
wire \/security-management/addr-decoder-registry/KEY61 ;
wire \/security-management/addr-decoder-registry/KEY62 ;
wire \/security-management/addr-decoder-registry/KEY63 ;
wire \/security-management/addr-decoder-registry/KEY64 ;
wire \/security-management/addr-decoder-registry/KEY65 ;
wire \/security-management/addr-decoder-registry/KEY66 ;
wire \/security-management/addr-decoder-registry/KEY67 ;
wire \/security-management/addr-decoder-registry/KEY68 ;
wire \/security-management/addr-decoder-registry/KEY69 ;
wire \/security-management/addr-decoder-registry/KEY7 ;
wire \/security-management/addr-decoder-registry/KEY70 ;
wire \/security-management/addr-decoder-registry/KEY71 ;
wire \/security-management/addr-decoder-registry/KEY72 ;
wire \/security-management/addr-decoder-registry/KEY73 ;
wire \/security-management/addr-decoder-registry/KEY74 ;
wire \/security-management/addr-decoder-registry/KEY75 ;
wire \/security-management/addr-decoder-registry/KEY76 ;
wire \/security-management/addr-decoder-registry/KEY77 ;
wire \/security-management/addr-decoder-registry/KEY78 ;
wire \/security-management/addr-decoder-registry/KEY79 ;
wire \/security-management/addr-decoder-registry/KEY8 ;
wire \/security-management/addr-decoder-registry/KEY80 ;
wire \/security-management/addr-decoder-registry/KEY81 ;
wire \/security-management/addr-decoder-registry/KEY82 ;
wire \/security-management/addr-decoder-registry/KEY83 ;
wire \/security-management/addr-decoder-registry/KEY84 ;
wire \/security-management/addr-decoder-registry/KEY85 ;
wire \/security-management/addr-decoder-registry/KEY86 ;
wire \/security-management/addr-decoder-registry/KEY87 ;
wire \/security-management/addr-decoder-registry/KEY88 ;
wire \/security-management/addr-decoder-registry/KEY89 ;
wire \/security-management/addr-decoder-registry/KEY9 ;
wire \/security-management/addr-decoder-registry/KEY90 ;
wire \/security-management/addr-decoder-registry/KEY91 ;
wire \/security-management/addr-decoder-registry/KEY92 ;
wire \/security-management/addr-decoder-registry/KEY93 ;
wire \/security-management/addr-decoder-registry/KEY94 ;
wire \/security-management/addr-decoder-registry/KEY95 ;
wire \/security-management/addr-decoder-registry/KEY96 ;
wire \/security-management/addr-decoder-registry/KEY97 ;
wire \/security-management/addr-decoder-registry/KEY98 ;
wire \/security-management/addr-decoder-registry/KEY99 ;
wire \/security-management/addr-decoder-registry/~CHECK1 ;
wire \/security-management/addr-decoder-registry/~CHECK2 ;
wire \/security-management/addr-decoder-registry/~CPS-ID ;
wire \/security-management/addr-decoder-registry/~LAYER-CTRL ;
wire \/security-management/addr-decoder-registry/~MULT-LSB ;
wire \/security-management/addr-decoder-registry/~MULT-MSB ;
wire \/security-management/addr-decoder-registry/~MULT-TC ;
wire \/security-management/addr-decoder-registry/~MULT-X ;
wire \/security-management/addr-decoder-registry/~MULT-Y ;
wire \/security-management/addr-decoder-registry/~PAL-CTRL ;
wire \/security-management/addr-decoder-registry/~PRIORITY0 ;
wire \/security-management/addr-decoder-registry/~PRIORITY1 ;
wire \/security-management/addr-decoder-registry/~PRIORITY2 ;
wire \/security-management/addr-decoder-registry/~PRIORITY3 ;
wire \/security-management/addr-decoder-registry/~RASTER1 ;
wire \/security-management/addr-decoder-registry/~RASTER2 ;
wire \/security-management/addr-decoder-registry/~RASTER3 ;
wire \/security-management/addr-decoder/0x00 ;
wire \/security-management/addr-decoder/0x02 ;
wire \/security-management/addr-decoder/0x04 ;
wire \/security-management/addr-decoder/0x06 ;
wire \/security-management/addr-decoder/0x08 ;
wire \/security-management/addr-decoder/0x0A ;
wire \/security-management/addr-decoder/0x0C ;
wire \/security-management/addr-decoder/0x0E ;
wire \/security-management/addr-decoder/0x10 ;
wire \/security-management/addr-decoder/0x12 ;
wire \/security-management/addr-decoder/0x26 ;
wire \/security-management/addr-decoder/0x28 ;
wire \/security-management/addr-decoder/0x2A ;
wire \/security-management/addr-decoder/0x2C ;
wire \/security-management/addr-decoder/0x2E ;
wire \/security-management/addr-decoder/0x30 ;
wire \/security-management/addr-decoder/0x32 ;
wire \/security-management/addr-decoder/CA1 ;
wire \/security-management/addr-decoder/CA2 ;
wire \/security-management/addr-decoder/CA3 ;
wire \/security-management/addr-decoder/CA4 ;
wire \/security-management/addr-decoder/CA5 ;
wire \/security-management/addr-decoder/LE ;
wire \/security-management/bus-mux-key/KEY135 ;
wire \/security-management/bus-mux-key/KEY136 ;
wire \/security-management/bus-mux-key/KEY137 ;
wire \/security-management/bus-mux-key/LAYER-D1 ;
wire \/security-management/bus-mux-key/LAYER-D2 ;
wire \/security-management/bus-mux-key/LAYER-D3 ;
wire \/security-management/bus-mux-key/LAYER-D4 ;
wire \/security-management/bus-mux-key/LAYER-D5 ;
wire \/security-management/keyinject/CLK ;
wire \/security-management/keyinject/DATA ;
wire \/security-management/keyinject/E2 ;
wire \/security-management/keyinject/S1-STROBE ;
wire \/security-management/keyinject/STAGE-RESET ;
wire \/security-management/keyinject/STAGE2-Q ;
wire \/security-management/keyinject/STAGE3-Q ;
wire \/security-management/keyinject/~CLK ;
wire \/security-management/keyinject/~E1 ;
wire \/security-management/keyinject/~RESET ;
wire \/security-management/security-decoder/KEY0 ;
wire \/security-management/security-decoder/KEY1 ;
wire \/security-management/security-decoder/KEY138 ;
wire \/security-management/security-decoder/KEY139 ;
wire \/security-management/security-decoder/KEY140 ;
wire \/security-management/security-decoder/KEY141 ;
wire \/security-management/security-decoder/KEY142 ;
wire \/security-management/security-decoder/KEY143 ;
wire \/security-management/security-decoder/KEY2 ;
wire \/security-management/security-decoder/KEY3 ;
wire \/security-management/security-decoder/KEY4 ;
wire \/security-management/security-decoder/KEY5 ;
wire \/security-management/security-key/CLK ;
wire \/security-management/security-key/DATA ;
wire \/stars/FLIP ;
wire \/stars/counter-xs-1/LOAD ;
wire \/stars/counter-xs-1/XS0 ;
wire \/stars/counter-xs-1/XS1 ;
wire \/stars/counter-xs-1/XS2 ;
wire \/stars/counter-xs-1/XS3 ;
wire \/stars/counter-xs-1/XS4 ;
wire \/stars/counter-xs-1/~CLK8M ;
wire \/stars/counter-xs-2/XS0 ;
wire \/stars/counter-xs-2/XS1 ;
wire \/stars/counter-xs-2/XS2 ;
wire \/stars/counter-xs-2/XS3 ;
wire \/stars/counter-xs-2/XS4 ;
wire \/stars/row5-assemble/CNT0-Q0 ;
wire \/stars/row5-assemble/CNT0-Q1 ;
wire \/stars/row5-assemble/CNT0-Q2 ;
wire \/stars/row5-assemble/CNT0-Q3 ;
wire \/stars/row5-assemble/CNT1-Q0 ;
wire \/stars/row5-assemble/CNT1-Q1 ;
wire \/stars/row5-assemble/CNT1-Q2 ;
wire \/stars/row5-assemble/CNT1-Q3 ;
wire \/stars/row5-assemble/PD5 ;
wire \/stars/row5-assemble/PD6 ;
wire \/stars/row5-assemble/PD7 ;
wire \/stars/row5-assemble/PD8 ;
wire \/stars/row5-assemble/~DEBUG ;
wire \/stars/row5-assemble/~ENABLE ;
wire \/stars/row5-counter/IC ;
wire \/stars/row5-counter/INC ;
wire \/stars/row5-counter/~DEBUG ;
wire \/stars/row6-assemble/CNT0-Q0 ;
wire \/stars/row6-assemble/CNT0-Q1 ;
wire \/stars/row6-assemble/CNT0-Q2 ;
wire \/stars/row6-assemble/CNT0-Q3 ;
wire \/stars/row6-assemble/CNT1-Q0 ;
wire \/stars/row6-assemble/CNT1-Q1 ;
wire \/stars/row6-assemble/CNT1-Q2 ;
wire \/stars/row6-assemble/CNT1-Q3 ;
wire \/stars/row6-assemble/PD5 ;
wire \/stars/row6-assemble/PD6 ;
wire \/stars/row6-assemble/PD7 ;
wire \/stars/row6-assemble/PD8 ;
wire \/stars/row6-assemble/~DEBUG ;
wire \/stars/row6-assemble/~ENABLE ;
wire \/stars/row6-counter/IC ;
wire \/stars/row6-counter/~DEBUG ;
wire \/stars/xpd-bus5/LOAD ;
wire \/stars/xpd-bus5/PD0 ;
wire \/stars/xpd-bus5/PD1 ;
wire \/stars/xpd-bus5/PD2 ;
wire \/stars/xpd-bus5/PD3 ;
wire \/stars/xpd-bus5/PD4 ;
wire \/stars/xpd-bus5/PD5 ;
wire \/stars/xpd-bus5/PD6 ;
wire \/stars/xpd-bus5/PD7 ;
wire \/stars/xpd-bus5/PD8 ;
wire \/stars/xpd-bus6/LOAD ;
wire \/stars/xpd-bus6/PD0 ;
wire \/stars/xpd-bus6/PD1 ;
wire \/stars/xpd-bus6/PD2 ;
wire \/stars/xpd-bus6/PD3 ;
wire \/stars/xpd-bus6/PD4 ;
wire \/stars/xpd-bus6/PD5 ;
wire \/stars/xpd-bus6/PD6 ;
wire \/stars/xpd-bus6/PD7 ;
wire \/stars/xpd-bus6/PD8 ;
wire \/stars/xpd5-sync/LOAD ;
wire \/stars/xpd5-sync/ZERO ;
wire \/stars/xpd5-sync/~PD0 ;
wire \/stars/xpd5-sync/~PD1 ;
wire \/stars/xpd5-sync/~PD2 ;
wire \/stars/xpd5-sync/~PD3 ;
wire \/stars/xpd5-sync/~PD4 ;
wire \/stars/xpd6-sync/LOAD ;
wire \/stars/xpd6-sync/ZERO ;
wire \/stars/xpd6-sync/~PD0 ;
wire \/stars/xpd6-sync/~PD1 ;
wire \/stars/xpd6-sync/~PD2 ;
wire \/stars/xpd6-sync/~PD3 ;
wire \/stars/xpd6-sync/~PD4 ;
wire \/tilemaps/CDEN ;
wire \/tilemaps/cb-bus1/LOAD-CHNLA ;
wire \/tilemaps/cb-bus1/LOAD-CHNLB ;
wire \/tilemaps/cb-bus2/LOAD-CHNLB ;
wire \/tilemaps/cb-bus3/LOAD-CHNLA ;
wire \/tilemaps/cb-bus3/LOAD-CHNLB ;
wire \/tilemaps/col2-assemble/CB0 ;
wire \/tilemaps/col2-assemble/CB1 ;
wire \/tilemaps/col2-assemble/CB2 ;
wire \/tilemaps/col2-assemble/CB3 ;
wire \/tilemaps/col2-assemble/CB4 ;
wire \/tilemaps/col2-assemble/CDEN ;
wire \/tilemaps/col2-assemble/CPC0 ;
wire \/tilemaps/col2-assemble/CPC1 ;
wire \/tilemaps/col2-assemble/SERIAL-END ;
wire \/tilemaps/col2-assemble/~COL2-E ;
wire \/tilemaps/col2-assemble/~DEBUG ;
wire \/tilemaps/col3-assemble/CB0 ;
wire \/tilemaps/col3-assemble/CB1 ;
wire \/tilemaps/col3-assemble/CB2 ;
wire \/tilemaps/col3-assemble/CB3 ;
wire \/tilemaps/col3-assemble/CB4 ;
wire \/tilemaps/col3-assemble/CDEN ;
wire \/tilemaps/col3-assemble/CPC0 ;
wire \/tilemaps/col3-assemble/CPC1 ;
wire \/tilemaps/col3-assemble/SERIAL-END ;
wire \/tilemaps/col3-assemble/~COL3-E ;
wire \/tilemaps/col3-assemble/~DEBUG ;
wire \/tilemaps/col4-assemble/CB0 ;
wire \/tilemaps/col4-assemble/CB1 ;
wire \/tilemaps/col4-assemble/CB2 ;
wire \/tilemaps/col4-assemble/CB3 ;
wire \/tilemaps/col4-assemble/CB4 ;
wire \/tilemaps/col4-assemble/CDEN ;
wire \/tilemaps/col4-assemble/CPC0 ;
wire \/tilemaps/col4-assemble/CPC1 ;
wire \/tilemaps/col4-assemble/SERIAL-END ;
wire \/tilemaps/col4-assemble/~COL4-E ;
wire \/tilemaps/col4-assemble/~DEBUG ;
wire \/tilemaps/sr1-sync/LOAD ;
wire \/tilemaps/sr1-sync/XS0 ;
wire \/tilemaps/sr1-sync/XS1 ;
wire \/tilemaps/sr1-sync/XS2 ;
wire \/tilemaps/sr1/A ;
wire \/tilemaps/sr1/B ;
wire \/tilemaps/sr1/C ;
wire \/tilemaps/sr1/D ;
wire \/tilemaps/sr1/XS0 ;
wire \/tilemaps/sr1/XS1 ;
wire \/tilemaps/sr1/XS2 ;
wire \/tilemaps/sr1/~RESET ;
wire \/tilemaps/sr2-sync/XS0 ;
wire \/tilemaps/sr2-sync/XS1 ;
wire \/tilemaps/sr2-sync/XS2 ;
wire \/tilemaps/sr2-sync/XS3 ;
wire \/tilemaps/sr2/A ;
wire \/tilemaps/sr2/B ;
wire \/tilemaps/sr2/C ;
wire \/tilemaps/sr2/D ;
wire \/tilemaps/sr2/XS0 ;
wire \/tilemaps/sr2/XS1 ;
wire \/tilemaps/sr2/XS2 ;
wire \/tilemaps/sr2/XS3 ;
wire \/tilemaps/sr2/~RESET ;
wire \/tilemaps/sr3-sync/~LOAD ;
wire \/tilemaps/sr3/A ;
wire \/tilemaps/sr3/B ;
wire \/tilemaps/sr3/C ;
wire \/tilemaps/sr3/D ;
wire \/tilemaps/sr3/XS0 ;
wire \/tilemaps/sr3/XS1 ;
wire \/tilemaps/sr3/XS2 ;
wire \/tilemaps/sr3/XS3 ;
wire \/tilemaps/sr3/~RESET ;
wire \/tilemaps/xpd-bus1/GFX-LOAD ;
wire \/tilemaps/xpd-bus1/XSEL ;
wire \/tilemaps/xpd-bus2/GFX-LOAD ;
wire \/tilemaps/xpd-bus2/SERIAL-CHNL ;
wire \/tilemaps/xpd-bus2/XSEL ;
wire \/tilemaps/xpd-bus3/GFX-LOAD ;
wire \/tilemaps/xpd-bus3/SERIAL-CHNL ;
wire \/tilemaps/xpd-bus3/XSEL ;
wire \/video-signals/HSYNC ;
wire \/video-signals/VSYNC ;
wire \/video-signals/video-counter/COL1 ;
wire \/video-signals/video-counter/COL2 ;
wire \/video-signals/video-counter/COL3 ;
wire \/video-signals/video-counter/COL4 ;
wire \/video-signals/video-counter/COL5 ;
wire \/video-signals/video-counter/COL6 ;
wire \/video-signals/video-counter/COL7 ;
wire \/video-signals/video-counter/COL8 ;
wire \/video-signals/video-counter/COUNTER-INC ;
wire \/video-signals/video-counter/DATA0 ;
wire \/video-signals/video-counter/DATA1 ;
wire \/video-signals/video-counter/DATA10 ;
wire \/video-signals/video-counter/DATA11 ;
wire \/video-signals/video-counter/DATA12 ;
wire \/video-signals/video-counter/DATA13 ;
wire \/video-signals/video-counter/DATA14 ;
wire \/video-signals/video-counter/DATA15 ;
wire \/video-signals/video-counter/DATA2 ;
wire \/video-signals/video-counter/DATA3 ;
wire \/video-signals/video-counter/DATA4 ;
wire \/video-signals/video-counter/DATA5 ;
wire \/video-signals/video-counter/DATA6 ;
wire \/video-signals/video-counter/DATA7 ;
wire \/video-signals/video-counter/DATA8 ;
wire \/video-signals/video-counter/DATA9 ;
wire \/video-signals/video-counter/LINE0 ;
wire \/video-signals/video-counter/LINE1 ;
wire \/video-signals/video-counter/LINE2 ;
wire \/video-signals/video-counter/LINE3 ;
wire \/video-signals/video-counter/LINE4 ;
wire \/video-signals/video-counter/LINE5 ;
wire \/video-signals/video-counter/LINE6 ;
wire \/video-signals/video-counter/LINE7 ;
wire \/video-signals/video-counter/LINE8 ;
wire \/video-signals/video-counter/~COUNTER-SET ;
wire \/video-signals/video-counter/~E ;
wire \/video-signals/video-signal-generator/BLANK ;
wire \/video-signals/video-signal-generator/HSYNC ;
wire \/video-signals/video-signal-generator/UCJ328-Q ;
wire \/video-signals/video-signal-generator/UCJ337-Q ;
wire \/video-signals/video-signal-generator/UCL375-Q ;
wire \/video-signals/video-signal-generator/UCO328-Q ;
wire \/video-signals/video-signal-generator/UCR332-Q ;
wire \/video-signals/video-signal-generator/UCR388-Q ;
wire \/video-signals/video-signal-generator/VSYNC ;
wire \/video-signals/video-signal-generator/~DEBUG-HI ;
wire \/video-signals/video-signal-generator/~DEBUG-LO ;
wire \/video-signals/video-signal-generator/~HBLANK ;
wire \/video-signals/video-signal-generator/~VBLANK ;
wire \/video-signals/~HBLANK ;
wire \/video-signals/~RESET ;
wire \/video-signals/~VBLANK ;
wire \/xpd-out/OUT0 ;
wire \/xpd-out/OUT1 ;
wire \/xpd-out/OUT2 ;
wire \/xpd-out/OUT3 ;
wire \/xpd-out/OUT4 ;
wire \/xpd-out/OUT5 ;
wire \/xpd-out/OUT6 ;
wire \/xpd-out/OUT7 ;
wire \/xpd-out/~OE ;
wire \/xpd-out/~ROMOE ;
wire \/~DEBUG1 ;
wire \/~DEBUG10 ;
wire \/~DEBUG15 ;
wire \/~DEBUG6 ;
wire \/~DEBUG7 ;
wire \/~DEBUG8 ;
wire \/~DEBUG9 ;
wire \N$/bus-io|w131 ;
wire \N$/bus-io|w132 ;
wire \N$/bus-io|w133 ;
wire \N$/bus-io|w134 ;
wire \N$/bus-io|w137 ;
wire \N$/bus-io|w138 ;
wire \N$/bus-io|w139 ;
wire \N$/bus-io|w140 ;
wire \N$/bus-io|w148 ;
wire \N$/bus-io|w151 ;
wire \N$/bus-io|w153 ;
wire \N$/bus-io|w155 ;
wire \N$/bus-io|w158 ;
wire \N$/bus-io|w161 ;
wire \N$/bus-io|w163 ;
wire \N$/bus-io|w165 ;
wire \N$/bus-io|w172 ;
wire \N$/bus-io|w64 ;
wire \N$/bus-signal-control|UBD415.17 ;
wire \N$/bus-signal-control|UBD415.18 ;
wire \N$/bus-signal-control|UBD415.19 ;
wire \N$/bus-signal-control|UBD415.20 ;
wire \N$/bus-signal-control|UBD415.21 ;
wire \N$/bus-signal-control|UBD415.22 ;
wire \N$/bus-signal-control|UBD415.23 ;
wire \N$/bus-signal-control|UBD415.24 ;
wire \N$/bus-signal-control|UBD456.5 ;
wire \N$/bus-signal-control|UBD460.5 ;
wire \N$/bus-signal-control|UBD464.5 ;
wire \N$/bus-signal-control|UBD521.1 ;
wire \N$/bus-signal-control|UBK439.3 ;
wire \N$/bus-signal-control|UBN418.1 ;
wire \N$/bus-signal-control|w13 ;
wire \N$/bus-signal-control|w16 ;
wire \N$/bus-signal-control|w23 ;
wire \N$/bus-signal-control|w25 ;
wire \N$/bus-signal-control|w29 ;
wire \N$/bus-signal-control|w36 ;
wire \N$/bus-signal-control|w46 ;
wire \N$/bus-signal-control|w63 ;
wire \N$/bus-signal-control|w80 ;
wire \N$/bus-signal-control|w83 ;
wire \N$/bus-signal-control|w93 ;
wire \N$/bus-signal-control|w95 ;
wire \N$/counter-fi|UBN281.2 ;
wire \N$/counter-fi|UBR151.9 ;
wire \N$/counter-fi|UBR161.5 ;
wire \N$/counter-fi|UBR166.5 ;
wire \N$/counter-fi|UBR170.5 ;
wire \N$/counter-fi|UBR175.5 ;
wire \N$/counter-fi|UBR179.5 ;
wire \N$/counter-fi|UBR184.5 ;
wire \N$/counter-fi|UBR274.2 ;
wire \N$/counter-fi|w103 ;
wire \N$/counter-fi|w104 ;
wire \N$/counter-fi|w105 ;
wire \N$/counter-fi|w106 ;
wire \N$/counter-fi|w107 ;
wire \N$/counter-fi|w108 ;
wire \N$/counter-fi|w121 ;
wire \N$/counter-fi|w124 ;
wire \N$/counter-fi|w126 ;
wire \N$/counter-fi|w129 ;
wire \N$/counter-fi|w131 ;
wire \N$/counter-fi|w141 ;
wire \N$/counter-fi|w144 ;
wire \N$/counter-fi|w146 ;
wire \N$/counter-fi|w149 ;
wire \N$/counter-fi|w151 ;
wire \N$/counter-fi|w155 ;
wire \N$/counter-fi|w157 ;
wire \N$/counter-fi|w161 ;
wire \N$/counter-fi|w31 ;
wire \N$/cps-id|UCL463.6 ;
wire \N$/cps-id|UCL468.5 ;
wire \N$/cps-id|UCL472.5 ;
wire \N$/cps-id|UCL477.5 ;
wire \N$/cps-id|UCL481.5 ;
wire \N$/cps-id|w19 ;
wire \N$/cps-id|w35 ;
wire \N$/cps-id|w43 ;
wire \N$/cps-id|w48 ;
wire \N$/cps-id|w57 ;
wire \N$/cps-id|w63 ;
wire \N$/debug|w3 ;
wire \N$/die/UBN264.c1 ;
wire \N$/die/UBN264.c2 ;
wire \N$/die/UBN264.c3 ;
wire \N$/die/UBN264.c4 ;
wire \N$/die/UBN264.c5 ;
wire \N$/die/UBN264.c6 ;
wire \N$/die/UBN264.c7 ;
wire \N$/die/UBN362.c1 ;
wire \N$/die/UBN362.c2 ;
wire \N$/die/UBN362.c3 ;
wire \N$/die/UBN362.c4 ;
wire \N$/die/UBN362.c5 ;
wire \N$/die/UBN362.c6 ;
wire \N$/die/UBN362.c7 ;
wire \N$/die/UBN391.c1 ;
wire \N$/die/UBN391.c2 ;
wire \N$/die/UBN391.c3 ;
wire \N$/die/UBN391.c4 ;
wire \N$/die/UBN391.c5 ;
wire \N$/die/UBN391.c6 ;
wire \N$/die/UBN391.c7 ;
wire \N$/die/UBN418.c1 ;
wire \N$/die/UBN418.c2 ;
wire \N$/die/UBN418.c3 ;
wire \N$/die/UBN418.c4 ;
wire \N$/die/UBN418.c5 ;
wire \N$/die/UBN418.c6 ;
wire \N$/die/UBN418.c7 ;
wire \N$/die/UBU414.c1 ;
wire \N$/die/UBU414.c2 ;
wire \N$/die/UBU414.c3 ;
wire \N$/die/UBU420.c1 ;
wire \N$/die/UBU420.c2 ;
wire \N$/die/UBU420.c3 ;
wire \N$/lut-assembly/layer-control|UBE104.5 ;
wire \N$/lut-assembly/layer-control|UBE108.5 ;
wire \N$/lut-assembly/layer-control|UBE48.2 ;
wire \N$/lut-assembly/layer-control|UBE50.3 ;
wire \N$/lut-assembly/layer-control|UBE50.5 ;
wire \N$/lut-assembly/layer-control|UBE55.3 ;
wire \N$/lut-assembly/layer-control|UBE55.5 ;
wire \N$/lut-assembly/layer-control|UBE59.3 ;
wire \N$/lut-assembly/layer-control|UBE59.5 ;
wire \N$/lut-assembly/layer-control|UBE64.3 ;
wire \N$/lut-assembly/layer-control|UBE64.5 ;
wire \N$/lut-assembly/layer-control|UBE68.3 ;
wire \N$/lut-assembly/layer-control|UBE68.5 ;
wire \N$/lut-assembly/layer-control|UBE72.5 ;
wire \N$/lut-assembly/layer-control|UBE77.5 ;
wire \N$/lut-assembly/layer-control|UBE86.5 ;
wire \N$/lut-assembly/layer-control|UBE90.5 ;
wire \N$/lut-assembly/layer-control|UBE95.5 ;
wire \N$/lut-assembly/layer-control|UBE99.5 ;
wire \N$/lut-assembly/layer-control|w67 ;
wire \N$/lut-assembly/lut-storage|UBF101.11 ;
wire \N$/lut-assembly/lut-storage|UBH101.11 ;
wire \N$/lut-assembly/lut-storage|w144 ;
wire \N$/lut-assembly/lut-storage|w145 ;
wire \N$/lut-assembly/lut-storage|w146 ;
wire \N$/lut-assembly/lut-storage|w147 ;
wire \N$/lut-assembly/lut-storage|w148 ;
wire \N$/lut-assembly/lut-storage|w149 ;
wire \N$/lut-assembly/lut-storage|w152 ;
wire \N$/lut-assembly/lut-storage|w37 ;
wire \N$/lut-assembly/lut-storage|w38 ;
wire \N$/lut-assembly/lut-storage|w39 ;
wire \N$/lut-assembly/lut-storage|w40 ;
wire \N$/lut-assembly/lut-storage|w41 ;
wire \N$/lut-assembly/lut-storage|w42 ;
wire \N$/lut-assembly/lut-storage|w45 ;
wire \N$/lut-assembly/priority-masks|UBK499.5 ;
wire \N$/lut-assembly/priority-masks|UBU498.5 ;
wire \N$/lut-assembly/priority-masks|UCC461.5 ;
wire \N$/lut-assembly/priority-masks|UCG383.5 ;
wire \N$/lut-assembly/priority-masks|UCJ383.5 ;
wire \N$/lut-assembly/priority-masks|UCL498.5 ;
wire \N$/lut-assembly/priority-masks|UCR496.5 ;
wire \N$/lut-assembly/priority-masks|UCT497.5 ;
wire \N$/lut-assembly/priority-masks|w123 ;
wire \N$/lut-assembly/priority-masks|w124 ;
wire \N$/lut-assembly/priority-masks|w125 ;
wire \N$/lut-assembly/priority-masks|w126 ;
wire \N$/lut-assembly/priority-masks|w127 ;
wire \N$/lut-assembly/priority-masks|w128 ;
wire \N$/lut-assembly/priority-masks|w129 ;
wire \N$/lut-assembly/priority-masks|w13 ;
wire \N$/lut-assembly/priority-masks|w130 ;
wire \N$/lut-assembly/priority-masks|w131 ;
wire \N$/lut-assembly/priority-masks|w132 ;
wire \N$/lut-assembly/priority-masks|w133 ;
wire \N$/lut-assembly/priority-masks|w134 ;
wire \N$/lut-assembly/priority-masks|w135 ;
wire \N$/lut-assembly/priority-masks|w136 ;
wire \N$/lut-assembly/priority-masks|w137 ;
wire \N$/lut-assembly/priority-masks|w138 ;
wire \N$/lut-assembly/priority-masks|w139 ;
wire \N$/lut-assembly/priority-masks|w14 ;
wire \N$/lut-assembly/priority-masks|w140 ;
wire \N$/lut-assembly/priority-masks|w141 ;
wire \N$/lut-assembly/priority-masks|w142 ;
wire \N$/lut-assembly/priority-masks|w143 ;
wire \N$/lut-assembly/priority-masks|w144 ;
wire \N$/lut-assembly/priority-masks|w145 ;
wire \N$/lut-assembly/priority-masks|w146 ;
wire \N$/lut-assembly/priority-masks|w147 ;
wire \N$/lut-assembly/priority-masks|w148 ;
wire \N$/lut-assembly/priority-masks|w149 ;
wire \N$/lut-assembly/priority-masks|w15 ;
wire \N$/lut-assembly/priority-masks|w150 ;
wire \N$/lut-assembly/priority-masks|w151 ;
wire \N$/lut-assembly/priority-masks|w152 ;
wire \N$/lut-assembly/priority-masks|w153 ;
wire \N$/lut-assembly/priority-masks|w154 ;
wire \N$/lut-assembly/priority-masks|w16 ;
wire \N$/lut-assembly/priority-masks|w215 ;
wire \N$/lut-assembly/priority-masks|w217 ;
wire \N$/lut-assembly/priority-masks|w291 ;
wire \N$/lut-assembly/priority-masks|w293 ;
wire \N$/lut-assembly/priority-masks|w294 ;
wire \N$/lut-assembly/priority-masks|w295 ;
wire \N$/lut-assembly/priority-masks|w296 ;
wire \N$/lut-assembly/priority-masks|w297 ;
wire \N$/lut-assembly/priority-masks|w298 ;
wire \N$/lut-assembly/priority-masks|w299 ;
wire \N$/lut-assembly/priority-masks|w300 ;
wire \N$/lut-assembly/priority-masks|w301 ;
wire \N$/lut-assembly/priority-masks|w302 ;
wire \N$/lut-assembly/priority-masks|w303 ;
wire \N$/lut-assembly/priority-masks|w304 ;
wire \N$/lut-assembly/priority-masks|w305 ;
wire \N$/lut-assembly/priority-masks|w306 ;
wire \N$/lut-assembly/priority-masks|w307 ;
wire \N$/lut-assembly/priority-masks|w308 ;
wire \N$/lut-assembly/priority-masks|w309 ;
wire \N$/lut-assembly/priority-masks|w310 ;
wire \N$/lut-assembly/priority-masks|w311 ;
wire \N$/lut-assembly/priority-masks|w312 ;
wire \N$/lut-assembly/priority-masks|w313 ;
wire \N$/lut-assembly/priority-masks|w314 ;
wire \N$/lut-assembly/priority-masks|w315 ;
wire \N$/lut-assembly/priority-masks|w316 ;
wire \N$/lut-assembly/priority-masks|w317 ;
wire \N$/lut-assembly/priority-masks|w318 ;
wire \N$/lut-assembly/priority-masks|w319 ;
wire \N$/lut-assembly/priority-masks|w320 ;
wire \N$/lut-assembly/priority-masks|w321 ;
wire \N$/lut-assembly/priority-masks|w322 ;
wire \N$/lut-assembly/priority-masks|w323 ;
wire \N$/lut-assembly/priority-masks|w324 ;
wire \N$/lut-assembly/priority-masks|w325 ;
wire \N$/lut-assembly/priority-masks|w363 ;
wire \N$/lut-assembly/priority-transparency|UBF48.2 ;
wire \N$/lut-assembly/priority-transparency|UBI99.7 ;
wire \N$/lut-assembly/priority-transparency|UBIX158.5 ;
wire \N$/lut-assembly/priority-transparency|UBK99.7 ;
wire \N$/lut-assembly/priority-transparency|UBM99.7 ;
wire \N$/lut-assembly/priority-transparency|UBN99.7 ;
wire \N$/lut-assembly/priority-transparency|UBNX164.2 ;
wire \N$/lut-assembly/priority-transparency|UBNX164.3 ;
wire \N$/lut-assembly/priority-transparency|w101 ;
wire \N$/lut-assembly/priority-transparency|w105 ;
wire \N$/lut-assembly/priority-transparency|w108 ;
wire \N$/lut-assembly/priority-transparency|w135 ;
wire \N$/lut-assembly/priority-transparency|w139 ;
wire \N$/lut-assembly/priority-transparency|w140 ;
wire \N$/lut-assembly/priority-transparency|w141 ;
wire \N$/lut-assembly/priority-transparency|w142 ;
wire \N$/lut-assembly/priority-transparency|w143 ;
wire \N$/lut-assembly/priority-transparency|w144 ;
wire \N$/lut-assembly/priority-transparency|w170 ;
wire \N$/lut-assembly/priority-transparency|w217 ;
wire \N$/lut-assembly/priority-transparency|w224 ;
wire \N$/lut-assembly/priority-transparency|w225 ;
wire \N$/lut-assembly/priority-transparency|w24 ;
wire \N$/lut-assembly/priority-transparency|w26 ;
wire \N$/lut-assembly/priority-transparency|w30 ;
wire \N$/lut-assembly/priority-transparency|w34 ;
wire \N$/lut-assembly/priority-transparency|w83 ;
wire \N$/lut-assembly/priority-transparency|w85 ;
wire \N$/lut-assembly/priority-transparency|w87 ;
wire \N$/lut-assembly/priority-transparency|w88 ;
wire \N$/lut-assembly/priority-transparency|w89 ;
wire \N$/lut-counter|UBW293.3 ;
wire \N$/lut-counter|UBW296.3 ;
wire \N$/lut-counter|UBW300.3 ;
wire \N$/lut-counter|UBW304.3 ;
wire \N$/lut-counter|UBZ329.6 ;
wire \N$/lut-counter|UCC293.3 ;
wire \N$/lut-counter|UCC296.3 ;
wire \N$/lut-counter|UCC300.3 ;
wire \N$/lut-counter|UCC304.3 ;
wire \N$/lut-counter|UCG328.1 ;
wire \N$/lut-counter|UCG330.6 ;
wire \N$/lut-counter|UCO335.3 ;
wire \N$/lut-counter|UCO339.3 ;
wire \N$/lut-counter|UCO343.3 ;
wire \N$/lut-counter|UCO347.3 ;
wire \N$/lut-counter|w1 ;
wire \N$/lut-counter|w113 ;
wire \N$/lut-counter|w114 ;
wire \N$/lut-counter|w116 ;
wire \N$/lut-counter|w117 ;
wire \N$/lut-counter|w211 ;
wire \N$/lut-counter|w226 ;
wire \N$/lut-counter|w237 ;
wire \N$/lut-counter|w243 ;
wire \N$/lut-counter|w245 ;
wire \N$/lut-counter|w248 ;
wire \N$/lut-counter|w25 ;
wire \N$/lut-counter|w250 ;
wire \N$/lut-counter|w253 ;
wire \N$/lut-counter|w255 ;
wire \N$/lut-counter|w257 ;
wire \N$/lut-counter|w258 ;
wire \N$/lut-counter|w259 ;
wire \N$/lut-counter|w271 ;
wire \N$/lut-counter|w273 ;
wire \N$/lut-counter|w275 ;
wire \N$/lut-counter|w277 ;
wire \N$/lut-counter|w279 ;
wire \N$/lut-counter|w280 ;
wire \N$/lut-counter|w282 ;
wire \N$/lut-counter|w284 ;
wire \N$/lut-counter|w285 ;
wire \N$/lut-counter|w288 ;
wire \N$/lut-counter|w291 ;
wire \N$/lut-counter|w38 ;
wire \N$/lut-counter|w69 ;
wire \N$/lut-counter|w70 ;
wire \N$/lut-counter|w73 ;
wire \N$/lut-counter|w74 ;
wire \N$/lut-counter|w87 ;
wire \N$/lut-counter|w88 ;
wire \N$/lut-counter|w89 ;
wire \N$/lut-counter|w90 ;
wire \N$/lut-io|UBH428.1 ;
wire \N$/lut-io|UBH500.1 ;
wire \N$/lut-io|UBH503.1 ;
wire \N$/lut-io|UBH512.1 ;
wire \N$/lut-io|UBH519.1 ;
wire \N$/lut-io|UBK498.1 ;
wire \N$/lut-io|UBK521.1 ;
wire \N$/lut-io|UBN441.1 ;
wire \N$/lut-io|UBN477.1 ;
wire \N$/lut-io|UBR487.1 ;
wire \N$/lut-io|UBR509.1 ;
wire \N$/lut-io|UBR512.1 ;
wire \N$/lut-io|UBR515.1 ;
wire \N$/lut-io|UBR518.1 ;
wire \N$/lut-io|UBR520.1 ;
wire \N$/lut-io|UBU519.1 ;
wire \N$/lut-io|UBU521.1 ;
wire \N$/lut-io|UBW502.1 ;
wire \N$/lut-io|UBW504.1 ;
wire \N$/lut-io|UBW515.1 ;
wire \N$/lut-io|UBW517.1 ;
wire \N$/lut-io|UCG460.1 ;
wire \N$/lut-io|UCG487.1 ;
wire \N$/lut-io|UCG502.1 ;
wire \N$/lut-io|w46 ;
wire \N$/lut-io|w48 ;
wire \N$/lut-io|w50 ;
wire \N$/lut-io|w52 ;
wire \N$/lut-io|w54 ;
wire \N$/lut-io|w56 ;
wire \N$/lut-io|w58 ;
wire \N$/lut-io|w62 ;
wire \N$/lut-io|w66 ;
wire \N$/lut-io|w69 ;
wire \N$/lut-io|w70 ;
wire \N$/lut-io|w71 ;
wire \N$/main-signals|UBN362.1 ;
wire \N$/main-signals|UBR501.5 ;
wire \N$/main-signals|UCG493.1 ;
wire \N$/main-signals|UCG511.5 ;
wire \N$/main-signals|UCG516.3 ;
wire \N$/main-signals|UCR296.2 ;
wire \N$/main-signals|UCT518.1 ;
wire \N$/main-signals|w42 ;
wire \N$/main-signals|w44 ;
wire \N$/main-signals|w52 ;
wire \N$/main-signals|w53 ;
wire \N$/main-signals|w54 ;
wire \N$/main-signals|w57 ;
wire \N$/main-signals|w58 ;
wire \N$/main-signals|w59 ;
wire \N$/main-signals|w65 ;
wire \N$/main-signals|w66 ;
wire \N$/main-signals|w69 ;
wire \N$/main-signals|w73 ;
wire \N$/main-signals|w74 ;
wire \N$/main-signals|w78 ;
wire \N$/main-signals|w80 ;
wire \N$/multiplier|UBH371.5 ;
wire \N$/multiplier|UBH388.5 ;
wire \N$/multiplier|UBN445.2 ;
wire \N$/multiplier|UBN455.5 ;
wire \N$/multiplier|UBN461.2 ;
wire \N$/multiplier|UBN462.3 ;
wire \N$/multiplier|UBN467.4 ;
wire \N$/multiplier|w100 ;
wire \N$/multiplier|w121 ;
wire \N$/multiplier|w17 ;
wire \N$/multiplier|w38 ;
wire \N$/multiplier|w39 ;
wire \N$/multiplier|w42 ;
wire \N$/multiplier|w45 ;
wire \N$/multiplier|w50 ;
wire \N$/multiplier|w67 ;
wire \N$/obj-manager/sd-bus|UCO435.5 ;
wire \N$/obj-manager/sd-bus|UCO439.5 ;
wire \N$/obj-manager/sd-bus|UCO444.5 ;
wire \N$/obj-manager/sd-bus|UCO448.5 ;
wire \N$/obj-manager/sd-bus|UCT409.5 ;
wire \N$/obj-manager/sd-bus|UCT413.5 ;
wire \N$/obj-manager/sd-bus|UCT418.5 ;
wire \N$/obj-manager/sd-bus|w121 ;
wire \N$/obj-manager/sd-bus|w124 ;
wire \N$/obj-manager/sd-bus|w126 ;
wire \N$/obj-manager/sd-bus|w134 ;
wire \N$/obj-manager/sd-bus|w135 ;
wire \N$/obj-manager/sd-bus|w137 ;
wire \N$/obj-manager/sd-bus|w138 ;
wire \N$/obj-manager/sd-bus|w139 ;
wire \N$/obj-manager/sd-bus|w140 ;
wire \N$/obj-manager/sd-bus|w157 ;
wire \N$/obj-manager/sd-bus|w172 ;
wire \N$/obj-manager/sd-bus|w176 ;
wire \N$/obj-manager/sd-bus|w178 ;
wire \N$/obj-manager/sd-bus|w179 ;
wire \N$/obj-manager/sd-bus|w180 ;
wire \N$/obj-manager/sd-bus|w38 ;
wire \N$/obj-manager/sd-bus|w44 ;
wire \N$/obj-manager/sd-bus|w45 ;
wire \N$/obj-manager/sd-bus|w46 ;
wire \N$/obj-manager/sd-bus|w47 ;
wire \N$/obj-manager/sd-bus|w53 ;
wire \N$/obj-manager/sd-bus|w58 ;
wire \N$/obj-manager/sd-bus|w60 ;
wire \N$/obj-manager/sd-bus|w65 ;
wire \N$/obj-manager/sd-bus|w67 ;
wire \N$/obj-manager/sd-bus|w69 ;
wire \N$/obj-manager/sd-bus|w71 ;
wire \N$/obj-manager/sd-bus|w73 ;
wire \N$/obj-manager/sd-bus|w75 ;
wire \N$/obj-manager/sd-bus|w92 ;
wire \N$/obj-manager/sd-bus|w93 ;
wire \N$/obj-manager/sd-bus|w94 ;
wire \N$/obj-manager/sd-bus|w95 ;
wire \N$/obj-manager/xpd-bus4|UAG324.2 ;
wire \N$/obj-manager/xpd-bus4|UAI287.11 ;
wire \N$/obj-manager/xpd-bus4|UAI287.12 ;
wire \N$/obj-manager/xpd-bus4|UAI287.13 ;
wire \N$/obj-manager/xpd-bus4|UAI287.14 ;
wire \N$/obj-manager/xpd-bus4|UAI287.15 ;
wire \N$/obj-manager/xpd-bus4|UAI287.16 ;
wire \N$/obj-manager/xpd-bus4|UAI325.11 ;
wire \N$/obj-manager/xpd-bus4|UAI325.12 ;
wire \N$/obj-manager/xpd-bus4|UAI325.13 ;
wire \N$/obj-manager/xpd-bus4|UAI325.14 ;
wire \N$/obj-manager/xpd-bus4|UAI325.15 ;
wire \N$/obj-manager/xpd-bus4|UAI325.16 ;
wire \N$/obj-manager/xpd-bus4|UAI326.2 ;
wire \N$/obj-manager/xpd-bus4|UAP287.11 ;
wire \N$/obj-manager/xpd-bus4|UAP287.12 ;
wire \N$/obj-manager/xpd-bus4|UAP287.13 ;
wire \N$/obj-manager/xpd-bus4|UAP287.14 ;
wire \N$/obj-manager/xpd-bus4|UAP287.15 ;
wire \N$/obj-manager/xpd-bus4|UAP287.16 ;
wire \N$/obj-manager/xpd-bus4|UAP325.11 ;
wire \N$/obj-manager/xpd-bus4|UAP325.12 ;
wire \N$/obj-manager/xpd-bus4|UAP325.13 ;
wire \N$/obj-manager/xpd-bus4|UAP325.14 ;
wire \N$/obj-manager/xpd-bus4|UAP325.15 ;
wire \N$/obj-manager/xpd-bus4|UAP325.16 ;
wire \N$/obj-manager/xpd-bus4|UAR352.5 ;
wire \N$/obj-manager/xpd-bus4|UAR357.5 ;
wire \N$/obj-manager/xpd-bus4|w185 ;
wire \N$/obj-manager/xpd-bus4|w199 ;
wire \N$/obj-manager/xpd-bus4|w216 ;
wire \N$/obj-manager/xpd-bus4|w217 ;
wire \N$/obj-manager/xpd-bus4|w269 ;
wire \N$/obj-manager/xpd-bus4|w271 ;
wire \N$/obj-manager/xpd-bus4|w273 ;
wire \N$/obj-manager/xpd-bus4|w275 ;
wire \N$/obj-manager/xpd-bus4|w278 ;
wire \N$/obj-manager/xpd-bus4|w281 ;
wire \N$/obj-manager/xpd-bus4|w284 ;
wire \N$/obj-manager/xpd-bus4|w287 ;
wire \N$/obj-manager/xpd-bus4|w289 ;
wire \N$/obj-manager/xpd-bus4|w291 ;
wire \N$/obj-manager/xpd-bus4|w293 ;
wire \N$/obj-manager/xpd-bus4|w295 ;
wire \N$/obj-manager/xpd-bus4|w300 ;
wire \N$/obj-manager/xpd-bus4|w303 ;
wire \N$/obj-manager/xpd-bus4|w306 ;
wire \N$/obj-manager/xpd-bus4|w309 ;
wire \N$/obj-manager/xpd-bus4|w313 ;
wire \N$/obj-manager/xpd-bus4|w315 ;
wire \N$/obj-manager/xpd-bus4|w317 ;
wire \N$/obj-manager/xpd-bus4|w319 ;
wire \N$/obj-manager/xpd-bus4|w322 ;
wire \N$/obj-manager/xpd-bus4|w325 ;
wire \N$/obj-manager/xpd-bus4|w328 ;
wire \N$/obj-manager/xpd-bus4|w331 ;
wire \N$/obj-manager/xpd-bus4|w333 ;
wire \N$/obj-manager/xpd-bus4|w335 ;
wire \N$/obj-manager/xpd-bus4|w337 ;
wire \N$/obj-manager/xpd-bus4|w339 ;
wire \N$/obj-manager/xpd-bus4|w342 ;
wire \N$/obj-manager/xpd-bus4|w345 ;
wire \N$/obj-manager/xpd-bus4|w348 ;
wire \N$/obj-manager/xpd-bus4|w351 ;
wire \N$/obj-manager/xpd-bus4|w360 ;
wire \N$/obj-manager/xpd-bus4|w384 ;
wire \N$/obj-manager/xpd-bus4|w385 ;
wire \N$/obj-manager/xpd-bus4|w386 ;
wire \N$/obj-manager/xpd-bus4|w393 ;
wire \N$/obj-manager/xpd-bus4|w395 ;
wire \N$/obj-manager/xpd-bus4|w397 ;
wire \N$/obj-manager/xpd-bus4|w399 ;
wire \N$/obj-manager/xpd-bus4|w412 ;
wire \N$/obj-manager/xpd-bus4|w414 ;
wire \N$/obj-manager/xpd-bus4|w418 ;
wire \N$/obj-manager/xpd-bus4|w422 ;
wire \N$/obj-manager/xpd-bus4|w424 ;
wire \N$/obj-manager/xpd-bus4|w428 ;
wire \N$/obj-manager/xpd-bus4|w6 ;
wire \N$/obj-manager/xpd-bus4|w7 ;
wire \N$/obj-manager|w27 ;
wire \N$/palette-control|UBZ473.5 ;
wire \N$/palette-control|UCC434.7 ;
wire \N$/palette-control|UCC434.9 ;
wire \N$/palette-control|UCG471.5 ;
wire \N$/palette-control|UCG475.3 ;
wire \N$/palette-control|UCG475.5 ;
wire \N$/palette-control|UCG480.5 ;
wire \N$/palette-control|UCJ446.3 ;
wire \N$/palette-control|UCJ450.3 ;
wire \N$/palette-control|UCJ455.3 ;
wire \N$/palette-control|UCJ459.3 ;
wire \N$/palette-control|UCJ463.3 ;
wire \N$/palette-control|UCJ468.3 ;
wire \N$/palette-control|w103 ;
wire \N$/palette-control|w108 ;
wire \N$/palette-control|w116 ;
wire \N$/palette-control|w120 ;
wire \N$/palette-control|w141 ;
wire \N$/palette-control|w143 ;
wire \N$/palette-control|w146 ;
wire \N$/palette-control|w147 ;
wire \N$/palette-control|w159 ;
wire \N$/palette-control|w162 ;
wire \N$/palette-control|w163 ;
wire \N$/palette-control|w165 ;
wire \N$/palette-control|w168 ;
wire \N$/palette-control|w170 ;
wire \N$/palette-control|w172 ;
wire \N$/palette-control|w178 ;
wire \N$/palette-control|w185 ;
wire \N$/palette-control|w189 ;
wire \N$/palette-control|w190 ;
wire \N$/palette-control|w191 ;
wire \N$/palette-control|w195 ;
wire \N$/palette-control|w3 ;
wire \N$/palette-control|w44 ;
wire \N$/palette-control|w96 ;
wire \N$/raster-interrupts/counter1|UBK304.1 ;
wire \N$/raster-interrupts/counter1|UBU271.5 ;
wire \N$/raster-interrupts/counter1|UBW314.5 ;
wire \N$/raster-interrupts/counter1|UBW318.5 ;
wire \N$/raster-interrupts/counter1|UBZ193.1 ;
wire \N$/raster-interrupts/counter1|w101 ;
wire \N$/raster-interrupts/counter1|w104 ;
wire \N$/raster-interrupts/counter1|w106 ;
wire \N$/raster-interrupts/counter1|w108 ;
wire \N$/raster-interrupts/counter1|w110 ;
wire \N$/raster-interrupts/counter1|w125 ;
wire \N$/raster-interrupts/counter1|w129 ;
wire \N$/raster-interrupts/counter1|w194 ;
wire \N$/raster-interrupts/counter1|w208 ;
wire \N$/raster-interrupts/counter1|w23 ;
wire \N$/raster-interrupts/counter1|w254 ;
wire \N$/raster-interrupts/counter1|w256 ;
wire \N$/raster-interrupts/counter1|w258 ;
wire \N$/raster-interrupts/counter1|w260 ;
wire \N$/raster-interrupts/counter1|w261 ;
wire \N$/raster-interrupts/counter1|w262 ;
wire \N$/raster-interrupts/counter1|w271 ;
wire \N$/raster-interrupts/counter1|w276 ;
wire \N$/raster-interrupts/counter1|w277 ;
wire \N$/raster-interrupts/counter1|w278 ;
wire \N$/raster-interrupts/counter1|w279 ;
wire \N$/raster-interrupts/counter1|w280 ;
wire \N$/raster-interrupts/counter1|w282 ;
wire \N$/raster-interrupts/counter1|w284 ;
wire \N$/raster-interrupts/counter1|w288 ;
wire \N$/raster-interrupts/counter1|w291 ;
wire \N$/raster-interrupts/counter1|w294 ;
wire \N$/raster-interrupts/counter1|w306 ;
wire \N$/raster-interrupts/counter1|w308 ;
wire \N$/raster-interrupts/counter1|w310 ;
wire \N$/raster-interrupts/counter1|w312 ;
wire \N$/raster-interrupts/counter1|w314 ;
wire \N$/raster-interrupts/counter1|w33 ;
wire \N$/raster-interrupts/counter1|w34 ;
wire \N$/raster-interrupts/counter1|w35 ;
wire \N$/raster-interrupts/counter1|w36 ;
wire \N$/raster-interrupts/counter1|w37 ;
wire \N$/raster-interrupts/counter1|w38 ;
wire \N$/raster-interrupts/counter1|w39 ;
wire \N$/raster-interrupts/counter1|w40 ;
wire \N$/raster-interrupts/counter1|w41 ;
wire \N$/raster-interrupts/counter1|w42 ;
wire \N$/raster-interrupts/counter1|w49 ;
wire \N$/raster-interrupts/counter1|w55 ;
wire \N$/raster-interrupts/counter1|w56 ;
wire \N$/raster-interrupts/counter1|w84 ;
wire \N$/raster-interrupts/counter1|w85 ;
wire \N$/raster-interrupts/counter1|w86 ;
wire \N$/raster-interrupts/counter1|w94 ;
wire \N$/raster-interrupts/counter1|w97 ;
wire \N$/raster-interrupts/counter1|w99 ;
wire \N$/raster-interrupts/counter2|UBH481.1 ;
wire \N$/raster-interrupts/counter2|UBU279.5 ;
wire \N$/raster-interrupts/counter2|UBZ277.5 ;
wire \N$/raster-interrupts/counter2|UBZ281.5 ;
wire \N$/raster-interrupts/counter2|UCL516.1 ;
wire \N$/raster-interrupts/counter2|w100 ;
wire \N$/raster-interrupts/counter2|w103 ;
wire \N$/raster-interrupts/counter2|w105 ;
wire \N$/raster-interrupts/counter2|w107 ;
wire \N$/raster-interrupts/counter2|w109 ;
wire \N$/raster-interrupts/counter2|w124 ;
wire \N$/raster-interrupts/counter2|w128 ;
wire \N$/raster-interrupts/counter2|w194 ;
wire \N$/raster-interrupts/counter2|w208 ;
wire \N$/raster-interrupts/counter2|w23 ;
wire \N$/raster-interrupts/counter2|w254 ;
wire \N$/raster-interrupts/counter2|w256 ;
wire \N$/raster-interrupts/counter2|w258 ;
wire \N$/raster-interrupts/counter2|w260 ;
wire \N$/raster-interrupts/counter2|w261 ;
wire \N$/raster-interrupts/counter2|w262 ;
wire \N$/raster-interrupts/counter2|w271 ;
wire \N$/raster-interrupts/counter2|w276 ;
wire \N$/raster-interrupts/counter2|w277 ;
wire \N$/raster-interrupts/counter2|w278 ;
wire \N$/raster-interrupts/counter2|w279 ;
wire \N$/raster-interrupts/counter2|w280 ;
wire \N$/raster-interrupts/counter2|w282 ;
wire \N$/raster-interrupts/counter2|w284 ;
wire \N$/raster-interrupts/counter2|w288 ;
wire \N$/raster-interrupts/counter2|w291 ;
wire \N$/raster-interrupts/counter2|w294 ;
wire \N$/raster-interrupts/counter2|w306 ;
wire \N$/raster-interrupts/counter2|w308 ;
wire \N$/raster-interrupts/counter2|w310 ;
wire \N$/raster-interrupts/counter2|w312 ;
wire \N$/raster-interrupts/counter2|w314 ;
wire \N$/raster-interrupts/counter2|w32 ;
wire \N$/raster-interrupts/counter2|w33 ;
wire \N$/raster-interrupts/counter2|w34 ;
wire \N$/raster-interrupts/counter2|w35 ;
wire \N$/raster-interrupts/counter2|w36 ;
wire \N$/raster-interrupts/counter2|w37 ;
wire \N$/raster-interrupts/counter2|w38 ;
wire \N$/raster-interrupts/counter2|w39 ;
wire \N$/raster-interrupts/counter2|w40 ;
wire \N$/raster-interrupts/counter2|w41 ;
wire \N$/raster-interrupts/counter2|w49 ;
wire \N$/raster-interrupts/counter2|w54 ;
wire \N$/raster-interrupts/counter2|w55 ;
wire \N$/raster-interrupts/counter2|w83 ;
wire \N$/raster-interrupts/counter2|w84 ;
wire \N$/raster-interrupts/counter2|w85 ;
wire \N$/raster-interrupts/counter2|w93 ;
wire \N$/raster-interrupts/counter2|w96 ;
wire \N$/raster-interrupts/counter2|w98 ;
wire \N$/raster-interrupts/counter3|UBU439.5 ;
wire \N$/raster-interrupts/counter3|UBZ346.1 ;
wire \N$/raster-interrupts/counter3|w101 ;
wire \N$/raster-interrupts/counter3|w162 ;
wire \N$/raster-interrupts/counter3|w18 ;
wire \N$/raster-interrupts/counter3|w209 ;
wire \N$/raster-interrupts/counter3|w211 ;
wire \N$/raster-interrupts/counter3|w215 ;
wire \N$/raster-interrupts/counter3|w217 ;
wire \N$/raster-interrupts/counter3|w218 ;
wire \N$/raster-interrupts/counter3|w219 ;
wire \N$/raster-interrupts/counter3|w223 ;
wire \N$/raster-interrupts/counter3|w228 ;
wire \N$/raster-interrupts/counter3|w230 ;
wire \N$/raster-interrupts/counter3|w231 ;
wire \N$/raster-interrupts/counter3|w232 ;
wire \N$/raster-interrupts/counter3|w233 ;
wire \N$/raster-interrupts/counter3|w236 ;
wire \N$/raster-interrupts/counter3|w237 ;
wire \N$/raster-interrupts/counter3|w238 ;
wire \N$/raster-interrupts/counter3|w243 ;
wire \N$/raster-interrupts/counter3|w246 ;
wire \N$/raster-interrupts/counter3|w249 ;
wire \N$/raster-interrupts/counter3|w261 ;
wire \N$/raster-interrupts/counter3|w265 ;
wire \N$/raster-interrupts/counter3|w267 ;
wire \N$/raster-interrupts/counter3|w269 ;
wire \N$/raster-interrupts/counter3|w271 ;
wire \N$/raster-interrupts/counter3|w28 ;
wire \N$/raster-interrupts/counter3|w29 ;
wire \N$/raster-interrupts/counter3|w30 ;
wire \N$/raster-interrupts/counter3|w31 ;
wire \N$/raster-interrupts/counter3|w32 ;
wire \N$/raster-interrupts/counter3|w33 ;
wire \N$/raster-interrupts/counter3|w34 ;
wire \N$/raster-interrupts/counter3|w35 ;
wire \N$/raster-interrupts/counter3|w36 ;
wire \N$/raster-interrupts/counter3|w63 ;
wire \N$/raster-interrupts/counter3|w67 ;
wire \N$/raster-interrupts/counter3|w71 ;
wire \N$/raster-interrupts/counter3|w74 ;
wire \N$/raster-interrupts/counter3|w76 ;
wire \N$/raster-interrupts/counter3|w78 ;
wire \N$/raster-interrupts/counter3|w81 ;
wire \N$/raster-interrupts/counter3|w83 ;
wire \N$/raster-interrupts/counter3|w85 ;
wire \N$/raster-interrupts|UBK317.3 ;
wire \N$/raster-interrupts|UBK317.5 ;
wire \N$/raster-interrupts|UBR325.1 ;
wire \N$/raster-interrupts|UBW371.2 ;
wire \N$/raster-interrupts|UBW371.3 ;
wire \N$/raster-interrupts|UBW371.5 ;
wire \N$/security-check|UBZ94.5 ;
wire \N$/security-check|w101 ;
wire \N$/security-check|w104 ;
wire \N$/security-check|w108 ;
wire \N$/security-check|w112 ;
wire \N$/security-check|w114 ;
wire \N$/security-check|w116 ;
wire \N$/security-check|w118 ;
wire \N$/security-check|w120 ;
wire \N$/security-check|w122 ;
wire \N$/security-check|w123 ;
wire \N$/security-check|w125 ;
wire \N$/security-check|w127 ;
wire \N$/security-check|w128 ;
wire \N$/security-check|w130 ;
wire \N$/security-check|w133 ;
wire \N$/security-check|w136 ;
wire \N$/security-check|w141 ;
wire \N$/security-check|w142 ;
wire \N$/security-check|w144 ;
wire \N$/security-check|w146 ;
wire \N$/security-check|w151 ;
wire \N$/security-check|w156 ;
wire \N$/security-check|w158 ;
wire \N$/security-check|w160 ;
wire \N$/security-check|w162 ;
wire \N$/security-check|w164 ;
wire \N$/security-check|w167 ;
wire \N$/security-check|w169 ;
wire \N$/security-check|w173 ;
wire \N$/security-check|w176 ;
wire \N$/security-check|w178 ;
wire \N$/security-check|w181 ;
wire \N$/security-check|w184 ;
wire \N$/security-check|w185 ;
wire \N$/security-check|w188 ;
wire \N$/security-check|w189 ;
wire \N$/security-check|w200 ;
wire \N$/security-check|w202 ;
wire \N$/security-check|w206 ;
wire \N$/security-check|w208 ;
wire \N$/security-check|w210 ;
wire \N$/security-check|w214 ;
wire \N$/security-check|w216 ;
wire \N$/security-check|w218 ;
wire \N$/security-check|w222 ;
wire \N$/security-check|w224 ;
wire \N$/security-check|w226 ;
wire \N$/security-check|w228 ;
wire \N$/security-check|w229 ;
wire \N$/security-check|w230 ;
wire \N$/security-check|w231 ;
wire \N$/security-check|w236 ;
wire \N$/security-check|w272 ;
wire \N$/security-check|w273 ;
wire \N$/security-check|w42 ;
wire \N$/security-check|w50 ;
wire \N$/security-check|w52 ;
wire \N$/security-check|w56 ;
wire \N$/security-check|w58 ;
wire \N$/security-check|w60 ;
wire \N$/security-check|w64 ;
wire \N$/security-check|w66 ;
wire \N$/security-check|w68 ;
wire \N$/security-check|w72 ;
wire \N$/security-check|w74 ;
wire \N$/security-check|w76 ;
wire \N$/security-check|w8 ;
wire \N$/security-check|w83 ;
wire \N$/security-check|w84 ;
wire \N$/security-check|w85 ;
wire \N$/security-check|w86 ;
wire \N$/security-check|w96 ;
wire \N$/security-check|w99 ;
wire \N$/security-management/addr-decoder-registry|w102 ;
wire \N$/security-management/addr-decoder-registry|w106 ;
wire \N$/security-management/addr-decoder-registry|w108 ;
wire \N$/security-management/addr-decoder-registry|w109 ;
wire \N$/security-management/addr-decoder-registry|w110 ;
wire \N$/security-management/addr-decoder-registry|w113 ;
wire \N$/security-management/addr-decoder-registry|w115 ;
wire \N$/security-management/addr-decoder-registry|w116 ;
wire \N$/security-management/addr-decoder-registry|w117 ;
wire \N$/security-management/addr-decoder-registry|w120 ;
wire \N$/security-management/addr-decoder-registry|w122 ;
wire \N$/security-management/addr-decoder-registry|w124 ;
wire \N$/security-management/addr-decoder-registry|w126 ;
wire \N$/security-management/addr-decoder-registry|w127 ;
wire \N$/security-management/addr-decoder-registry|w128 ;
wire \N$/security-management/addr-decoder-registry|w131 ;
wire \N$/security-management/addr-decoder-registry|w133 ;
wire \N$/security-management/addr-decoder-registry|w134 ;
wire \N$/security-management/addr-decoder-registry|w135 ;
wire \N$/security-management/addr-decoder-registry|w138 ;
wire \N$/security-management/addr-decoder-registry|w208 ;
wire \N$/security-management/addr-decoder-registry|w212 ;
wire \N$/security-management/addr-decoder-registry|w216 ;
wire \N$/security-management/addr-decoder-registry|w220 ;
wire \N$/security-management/addr-decoder-registry|w222 ;
wire \N$/security-management/addr-decoder-registry|w223 ;
wire \N$/security-management/addr-decoder-registry|w224 ;
wire \N$/security-management/addr-decoder-registry|w227 ;
wire \N$/security-management/addr-decoder-registry|w229 ;
wire \N$/security-management/addr-decoder-registry|w230 ;
wire \N$/security-management/addr-decoder-registry|w231 ;
wire \N$/security-management/addr-decoder-registry|w234 ;
wire \N$/security-management/addr-decoder-registry|w236 ;
wire \N$/security-management/addr-decoder-registry|w237 ;
wire \N$/security-management/addr-decoder-registry|w238 ;
wire \N$/security-management/addr-decoder-registry|w241 ;
wire \N$/security-management/addr-decoder-registry|w243 ;
wire \N$/security-management/addr-decoder-registry|w244 ;
wire \N$/security-management/addr-decoder-registry|w245 ;
wire \N$/security-management/addr-decoder-registry|w248 ;
wire \N$/security-management/addr-decoder-registry|w317 ;
wire \N$/security-management/addr-decoder-registry|w321 ;
wire \N$/security-management/addr-decoder-registry|w325 ;
wire \N$/security-management/addr-decoder-registry|w329 ;
wire \N$/security-management/addr-decoder-registry|w331 ;
wire \N$/security-management/addr-decoder-registry|w332 ;
wire \N$/security-management/addr-decoder-registry|w333 ;
wire \N$/security-management/addr-decoder-registry|w336 ;
wire \N$/security-management/addr-decoder-registry|w338 ;
wire \N$/security-management/addr-decoder-registry|w339 ;
wire \N$/security-management/addr-decoder-registry|w340 ;
wire \N$/security-management/addr-decoder-registry|w343 ;
wire \N$/security-management/addr-decoder-registry|w345 ;
wire \N$/security-management/addr-decoder-registry|w346 ;
wire \N$/security-management/addr-decoder-registry|w347 ;
wire \N$/security-management/addr-decoder-registry|w350 ;
wire \N$/security-management/addr-decoder-registry|w352 ;
wire \N$/security-management/addr-decoder-registry|w353 ;
wire \N$/security-management/addr-decoder-registry|w354 ;
wire \N$/security-management/addr-decoder-registry|w357 ;
wire \N$/security-management/addr-decoder-registry|w421 ;
wire \N$/security-management/addr-decoder-registry|w425 ;
wire \N$/security-management/addr-decoder-registry|w429 ;
wire \N$/security-management/addr-decoder-registry|w433 ;
wire \N$/security-management/addr-decoder-registry|w435 ;
wire \N$/security-management/addr-decoder-registry|w436 ;
wire \N$/security-management/addr-decoder-registry|w437 ;
wire \N$/security-management/addr-decoder-registry|w440 ;
wire \N$/security-management/addr-decoder-registry|w442 ;
wire \N$/security-management/addr-decoder-registry|w443 ;
wire \N$/security-management/addr-decoder-registry|w444 ;
wire \N$/security-management/addr-decoder-registry|w447 ;
wire \N$/security-management/addr-decoder-registry|w449 ;
wire \N$/security-management/addr-decoder-registry|w450 ;
wire \N$/security-management/addr-decoder-registry|w451 ;
wire \N$/security-management/addr-decoder-registry|w454 ;
wire \N$/security-management/addr-decoder-registry|w456 ;
wire \N$/security-management/addr-decoder-registry|w457 ;
wire \N$/security-management/addr-decoder-registry|w458 ;
wire \N$/security-management/addr-decoder-registry|w461 ;
wire \N$/security-management/addr-decoder-registry|w84 ;
wire \N$/security-management/addr-decoder-registry|w88 ;
wire \N$/security-management/addr-decoder-registry|w92 ;
wire \N$/security-management/addr-decoder-registry|w95 ;
wire \N$/security-management/addr-decoder-registry|w98 ;
wire \N$/security-management/addr-decoder|UBZ482.3 ;
wire \N$/security-management/addr-decoder|UBZ485.3 ;
wire \N$/security-management/addr-decoder|UBZ488.3 ;
wire \N$/security-management/addr-decoder|UBZ493.3 ;
wire \N$/security-management/addr-decoder|UCR348.13 ;
wire \N$/security-management/addr-decoder|UCR348.14 ;
wire \N$/security-management/addr-decoder|UCR348.15 ;
wire \N$/security-management/addr-decoder|w21 ;
wire \N$/security-management/addr-decoder|w22 ;
wire \N$/security-management/addr-decoder|w71 ;
wire \N$/security-management/keyinject|UCQ10.5 ;
wire \N$/security-management/keyinject|UCQ15.5 ;
wire \N$/security-management/keyinject|UCQ19.5 ;
wire \N$/security-management/keyinject|UCQ40.5 ;
wire \N$/security-management/keyinject|UCQ44.5 ;
wire \N$/security-management/keyinject|UCQ48.5 ;
wire \N$/security-management/keyinject|UCQ6.5 ;
wire \N$/security-management/keyinject|UCS12.6 ;
wire \N$/security-management/keyinject|UCS32.5 ;
wire \N$/security-management/keyinject|UCT12.5 ;
wire \N$/security-management/keyinject|UCT16.5 ;
wire \N$/security-management/keyinject|UCT21.5 ;
wire \N$/security-management/keyinject|UCT32.5 ;
wire \N$/security-management/keyinject|UCT48.2 ;
wire \N$/security-management/keyinject|UCT48.5 ;
wire \N$/security-management/keyinject|UCT7.5 ;
wire \N$/security-management/keyinject|w105 ;
wire \N$/security-management/keyinject|w114 ;
wire \N$/security-management/keyinject|w124 ;
wire \N$/security-management/keyinject|w126 ;
wire \N$/security-management/keyinject|w132 ;
wire \N$/security-management/keyinject|w141 ;
wire \N$/security-management/keyinject|w147 ;
wire \N$/security-management/keyinject|w149 ;
wire \N$/security-management/keyinject|w151 ;
wire \N$/security-management/keyinject|w154 ;
wire \N$/security-management/keyinject|w168 ;
wire \N$/security-management/keyinject|w180 ;
wire \N$/security-management/keyinject|w189 ;
wire \N$/security-management/keyinject|w199 ;
wire \N$/security-management/keyinject|w212 ;
wire \N$/security-management/keyinject|w215 ;
wire \N$/security-management/keyinject|w216 ;
wire \N$/security-management/keyinject|w219 ;
wire \N$/security-management/keyinject|w220 ;
wire \N$/security-management/keyinject|w40 ;
wire \N$/security-management/keyinject|w41 ;
wire \N$/security-management/keyinject|w42 ;
wire \N$/security-management/keyinject|w43 ;
wire \N$/security-management/keyinject|w57 ;
wire \N$/security-management/keyinject|w58 ;
wire \N$/security-management/keyinject|w66 ;
wire \N$/security-management/keyinject|w78 ;
wire \N$/security-management/keyinject|w85 ;
wire \N$/security-management/keyinject|w86 ;
wire \N$/security-management/keyinject|w92 ;
wire \N$/security-management/keyinject|w98 ;
wire \N$/security-management/security-decoder|w285 ;
wire \N$/security-management/security-decoder|w384 ;
wire \N$/security-management/security-key|w202 ;
wire \N$/security-management/security-key|w88 ;
wire \N$/stars/counter-xs-1|UCC12.5 ;
wire \N$/stars/counter-xs-1|UCC16.5 ;
wire \N$/stars/counter-xs-1|UCC19.5 ;
wire \N$/stars/counter-xs-1|UCC23.5 ;
wire \N$/stars/counter-xs-1|UCC243.5 ;
wire \N$/stars/counter-xs-1|UCC247.5 ;
wire \N$/stars/counter-xs-1|UCC251.5 ;
wire \N$/stars/counter-xs-1|UCC255.5 ;
wire \N$/stars/counter-xs-1|UCG259.1 ;
wire \N$/stars/counter-xs-1|w126 ;
wire \N$/stars/counter-xs-1|w140 ;
wire \N$/stars/counter-xs-1|w141 ;
wire \N$/stars/counter-xs-1|w142 ;
wire \N$/stars/counter-xs-1|w143 ;
wire \N$/stars/counter-xs-1|w144 ;
wire \N$/stars/counter-xs-1|w145 ;
wire \N$/stars/counter-xs-1|w146 ;
wire \N$/stars/counter-xs-1|w147 ;
wire \N$/stars/counter-xs-1|w158 ;
wire \N$/stars/counter-xs-1|w160 ;
wire \N$/stars/counter-xs-1|w164 ;
wire \N$/stars/counter-xs-1|w166 ;
wire \N$/stars/counter-xs-1|w168 ;
wire \N$/stars/counter-xs-1|w178 ;
wire \N$/stars/counter-xs-1|w184 ;
wire \N$/stars/counter-xs-1|w185 ;
wire \N$/stars/counter-xs-1|w34 ;
wire \N$/stars/counter-xs-1|w4 ;
wire \N$/stars/counter-xs-1|w42 ;
wire \N$/stars/counter-xs-1|w43 ;
wire \N$/stars/counter-xs-1|w46 ;
wire \N$/stars/counter-xs-1|w48 ;
wire \N$/stars/counter-xs-1|w8 ;
wire \N$/stars/counter-xs-2|UBR18.5 ;
wire \N$/stars/counter-xs-2|UBR22.5 ;
wire \N$/stars/counter-xs-2|UBR25.5 ;
wire \N$/stars/counter-xs-2|UBR29.5 ;
wire \N$/stars/counter-xs-2|UCC53.5 ;
wire \N$/stars/counter-xs-2|UCC57.5 ;
wire \N$/stars/counter-xs-2|UCC61.5 ;
wire \N$/stars/counter-xs-2|UCC65.5 ;
wire \N$/stars/counter-xs-2|UCC69.1 ;
wire \N$/stars/counter-xs-2|w127 ;
wire \N$/stars/counter-xs-2|w141 ;
wire \N$/stars/counter-xs-2|w142 ;
wire \N$/stars/counter-xs-2|w143 ;
wire \N$/stars/counter-xs-2|w144 ;
wire \N$/stars/counter-xs-2|w145 ;
wire \N$/stars/counter-xs-2|w146 ;
wire \N$/stars/counter-xs-2|w147 ;
wire \N$/stars/counter-xs-2|w148 ;
wire \N$/stars/counter-xs-2|w159 ;
wire \N$/stars/counter-xs-2|w161 ;
wire \N$/stars/counter-xs-2|w165 ;
wire \N$/stars/counter-xs-2|w167 ;
wire \N$/stars/counter-xs-2|w169 ;
wire \N$/stars/counter-xs-2|w179 ;
wire \N$/stars/counter-xs-2|w185 ;
wire \N$/stars/counter-xs-2|w186 ;
wire \N$/stars/counter-xs-2|w36 ;
wire \N$/stars/counter-xs-2|w44 ;
wire \N$/stars/counter-xs-2|w45 ;
wire \N$/stars/counter-xs-2|w47 ;
wire \N$/stars/counter-xs-2|w49 ;
wire \N$/stars/counter-xs-2|w7 ;
wire \N$/stars/counter-xs-2|w9 ;
wire \N$/stars/counter4|UCG69.5 ;
wire \N$/stars/counter4|UCG73.5 ;
wire \N$/stars/counter4|UCG76.5 ;
wire \N$/stars/counter4|UCG80.5 ;
wire \N$/stars/counter4|UCJ44.1 ;
wire \N$/stars/counter4|w19 ;
wire \N$/stars/counter4|w20 ;
wire \N$/stars/counter4|w21 ;
wire \N$/stars/counter4|w22 ;
wire \N$/stars/counter4|w30 ;
wire \N$/stars/counter4|w57 ;
wire \N$/stars/counter4|w58 ;
wire \N$/stars/counter4|w59 ;
wire \N$/stars/counter4|w60 ;
wire \N$/stars/counter4|w61 ;
wire \N$/stars/counter4|w72 ;
wire \N$/stars/counter4|w74 ;
wire \N$/stars/counter4|w76 ;
wire \N$/stars/counter4|w82 ;
wire \N$/stars/counter4|w85 ;
wire \N$/stars/counter4|w87 ;
wire \N$/stars/counter4|w89 ;
wire \N$/stars/row5-assemble|UBR118.5 ;
wire \N$/stars/row5-assemble|UBR122.5 ;
wire \N$/stars/row5-assemble|UBR126.5 ;
wire \N$/stars/row5-assemble|UBR130.5 ;
wire \N$/stars/row5-assemble|w15 ;
wire \N$/stars/row5-assemble|w31 ;
wire \N$/stars/row5-assemble|w6 ;
wire \N$/stars/row5-counter|UBD255.3 ;
wire \N$/stars/row5-counter|UBD259.3 ;
wire \N$/stars/row5-counter|UBD263.3 ;
wire \N$/stars/row5-counter|UBD267.3 ;
wire \N$/stars/row5-counter|UBH259.3 ;
wire \N$/stars/row5-counter|UBH263.3 ;
wire \N$/stars/row5-counter|UBH267.3 ;
wire \N$/stars/row5-counter|UBH271.3 ;
wire \N$/stars/row5-counter|UBK311.2 ;
wire \N$/stars/row5-counter|w11 ;
wire \N$/stars/row5-counter|w138 ;
wire \N$/stars/row5-counter|w142 ;
wire \N$/stars/row5-counter|w152 ;
wire \N$/stars/row5-counter|w154 ;
wire \N$/stars/row5-counter|w156 ;
wire \N$/stars/row5-counter|w160 ;
wire \N$/stars/row5-counter|w162 ;
wire \N$/stars/row5-counter|w164 ;
wire \N$/stars/row5-counter|w175 ;
wire \N$/stars/row5-counter|w177 ;
wire \N$/stars/row5-counter|w180 ;
wire \N$/stars/row5-counter|w181 ;
wire \N$/stars/row5-counter|w33 ;
wire \N$/stars/row5-counter|w34 ;
wire \N$/stars/row5-counter|w38 ;
wire \N$/stars/row5-counter|w42 ;
wire \N$/stars/row5-counter|w43 ;
wire \N$/stars/row5-counter|w44 ;
wire \N$/stars/row5-counter|w45 ;
wire \N$/stars/row5-counter|w46 ;
wire \N$/stars/row5-counter|w47 ;
wire \N$/stars/row5-counter|w48 ;
wire \N$/stars/row5-counter|w49 ;
wire \N$/stars/row5-counter|w69 ;
wire \N$/stars/row5-counter|w8 ;
wire \N$/stars/row6-assemble|UBH196.5 ;
wire \N$/stars/row6-assemble|UBH200.5 ;
wire \N$/stars/row6-assemble|UBH204.5 ;
wire \N$/stars/row6-assemble|UBH208.5 ;
wire \N$/stars/row6-assemble|w15 ;
wire \N$/stars/row6-assemble|w30 ;
wire \N$/stars/row6-assemble|w6 ;
wire \N$/stars/row6-counter|UBK242.3 ;
wire \N$/stars/row6-counter|UBK245.3 ;
wire \N$/stars/row6-counter|UBK249.3 ;
wire \N$/stars/row6-counter|UBK253.3 ;
wire \N$/stars/row6-counter|UBN196.3 ;
wire \N$/stars/row6-counter|UBN200.3 ;
wire \N$/stars/row6-counter|UBN204.3 ;
wire \N$/stars/row6-counter|UBN208.3 ;
wire \N$/stars/row6-counter|UBN405.2 ;
wire \N$/stars/row6-counter|w11 ;
wire \N$/stars/row6-counter|w138 ;
wire \N$/stars/row6-counter|w142 ;
wire \N$/stars/row6-counter|w152 ;
wire \N$/stars/row6-counter|w154 ;
wire \N$/stars/row6-counter|w156 ;
wire \N$/stars/row6-counter|w160 ;
wire \N$/stars/row6-counter|w162 ;
wire \N$/stars/row6-counter|w164 ;
wire \N$/stars/row6-counter|w175 ;
wire \N$/stars/row6-counter|w177 ;
wire \N$/stars/row6-counter|w180 ;
wire \N$/stars/row6-counter|w181 ;
wire \N$/stars/row6-counter|w33 ;
wire \N$/stars/row6-counter|w34 ;
wire \N$/stars/row6-counter|w38 ;
wire \N$/stars/row6-counter|w42 ;
wire \N$/stars/row6-counter|w43 ;
wire \N$/stars/row6-counter|w44 ;
wire \N$/stars/row6-counter|w45 ;
wire \N$/stars/row6-counter|w46 ;
wire \N$/stars/row6-counter|w47 ;
wire \N$/stars/row6-counter|w48 ;
wire \N$/stars/row6-counter|w49 ;
wire \N$/stars/row6-counter|w69 ;
wire \N$/stars/row6-counter|w8 ;
wire \N$/stars/xpd-bus5-sync|UBU141.5 ;
wire \N$/stars/xpd-bus5-sync|UBU145.5 ;
wire \N$/stars/xpd-bus5-sync|UBU148.5 ;
wire \N$/stars/xpd-bus5-sync|UBU152.5 ;
wire \N$/stars/xpd-bus5-sync|UBW69.3 ;
wire \N$/stars/xpd-bus5-sync|UBW73.3 ;
wire \N$/stars/xpd-bus5-sync|UBW76.3 ;
wire \N$/stars/xpd-bus5-sync|UBW80.3 ;
wire \N$/stars/xpd-bus5-sync|UBW84.3 ;
wire \N$/stars/xpd-bus5-sync|w12 ;
wire \N$/stars/xpd-bus5|UBR233.3 ;
wire \N$/stars/xpd-bus5|UBZ26.5 ;
wire \N$/stars/xpd-bus5|UBZ30.5 ;
wire \N$/stars/xpd-bus5|UBZ34.5 ;
wire \N$/stars/xpd-bus5|UBZ38.5 ;
wire \N$/stars/xpd-bus5|UBZ42.5 ;
wire \N$/stars/xpd-bus5|w37 ;
wire \N$/stars/xpd-bus5|w48 ;
wire \N$/stars/xpd-bus5|w54 ;
wire \N$/stars/xpd-bus5|w55 ;
wire \N$/stars/xpd-bus5|w61 ;
wire \N$/stars/xpd-bus5|w75 ;
wire \N$/stars/xpd-bus5|w77 ;
wire \N$/stars/xpd-bus5|w78 ;
wire \N$/stars/xpd-bus6-sync|UBH227.5 ;
wire \N$/stars/xpd-bus6-sync|UBH231.5 ;
wire \N$/stars/xpd-bus6-sync|UBH235.5 ;
wire \N$/stars/xpd-bus6-sync|UBH239.5 ;
wire \N$/stars/xpd-bus6-sync|UBR240.3 ;
wire \N$/stars/xpd-bus6-sync|UBR244.3 ;
wire \N$/stars/xpd-bus6-sync|UBR248.3 ;
wire \N$/stars/xpd-bus6-sync|UBR252.3 ;
wire \N$/stars/xpd-bus6-sync|UBR255.3 ;
wire \N$/stars/xpd-bus6-sync|w12 ;
wire \N$/stars/xpd-bus6|UBU258.3 ;
wire \N$/stars/xpd-bus6|UBZ10.5 ;
wire \N$/stars/xpd-bus6|UBZ14.5 ;
wire \N$/stars/xpd-bus6|UBZ18.5 ;
wire \N$/stars/xpd-bus6|UBZ3.5 ;
wire \N$/stars/xpd-bus6|UBZ7.5 ;
wire \N$/stars/xpd-bus6|w37 ;
wire \N$/stars/xpd-bus6|w48 ;
wire \N$/stars/xpd-bus6|w54 ;
wire \N$/stars/xpd-bus6|w55 ;
wire \N$/stars/xpd-bus6|w61 ;
wire \N$/stars/xpd-bus6|w75 ;
wire \N$/stars/xpd-bus6|w77 ;
wire \N$/stars/xpd-bus6|w78 ;
wire \N$/stars/xpd5-sync|UBU109.5 ;
wire \N$/stars/xpd5-sync|UBU113.5 ;
wire \N$/stars/xpd5-sync|UBU117.5 ;
wire \N$/stars/xpd5-sync|UBU121.5 ;
wire \N$/stars/xpd5-sync|UBU24.1 ;
wire \N$/stars/xpd5-sync|UBU52.5 ;
wire \N$/stars/xpd5-sync|UBU56.5 ;
wire \N$/stars/xpd5-sync|UBU60.5 ;
wire \N$/stars/xpd5-sync|UBU64.5 ;
wire \N$/stars/xpd5-sync|w121 ;
wire \N$/stars/xpd5-sync|w135 ;
wire \N$/stars/xpd5-sync|w136 ;
wire \N$/stars/xpd5-sync|w137 ;
wire \N$/stars/xpd5-sync|w138 ;
wire \N$/stars/xpd5-sync|w139 ;
wire \N$/stars/xpd5-sync|w140 ;
wire \N$/stars/xpd5-sync|w141 ;
wire \N$/stars/xpd5-sync|w142 ;
wire \N$/stars/xpd5-sync|w153 ;
wire \N$/stars/xpd5-sync|w155 ;
wire \N$/stars/xpd5-sync|w159 ;
wire \N$/stars/xpd5-sync|w161 ;
wire \N$/stars/xpd5-sync|w163 ;
wire \N$/stars/xpd5-sync|w173 ;
wire \N$/stars/xpd5-sync|w179 ;
wire \N$/stars/xpd5-sync|w180 ;
wire \N$/stars/xpd5-sync|w2 ;
wire \N$/stars/xpd5-sync|w38 ;
wire \N$/stars/xpd5-sync|w39 ;
wire \N$/stars/xpd5-sync|w40 ;
wire \N$/stars/xpd5-sync|w42 ;
wire \N$/stars/xpd5-sync|w44 ;
wire \N$/stars/xpd5-sync|w5 ;
wire \N$/stars/xpd6-sync|UBR56.5 ;
wire \N$/stars/xpd6-sync|UBR60.5 ;
wire \N$/stars/xpd6-sync|UBR64.5 ;
wire \N$/stars/xpd6-sync|UBR68.5 ;
wire \N$/stars/xpd6-sync|UBU218.5 ;
wire \N$/stars/xpd6-sync|UBU222.5 ;
wire \N$/stars/xpd6-sync|UBU226.5 ;
wire \N$/stars/xpd6-sync|UBU230.5 ;
wire \N$/stars/xpd6-sync|UCG203.1 ;
wire \N$/stars/xpd6-sync|w121 ;
wire \N$/stars/xpd6-sync|w135 ;
wire \N$/stars/xpd6-sync|w136 ;
wire \N$/stars/xpd6-sync|w137 ;
wire \N$/stars/xpd6-sync|w138 ;
wire \N$/stars/xpd6-sync|w139 ;
wire \N$/stars/xpd6-sync|w140 ;
wire \N$/stars/xpd6-sync|w141 ;
wire \N$/stars/xpd6-sync|w142 ;
wire \N$/stars/xpd6-sync|w153 ;
wire \N$/stars/xpd6-sync|w155 ;
wire \N$/stars/xpd6-sync|w159 ;
wire \N$/stars/xpd6-sync|w161 ;
wire \N$/stars/xpd6-sync|w163 ;
wire \N$/stars/xpd6-sync|w173 ;
wire \N$/stars/xpd6-sync|w179 ;
wire \N$/stars/xpd6-sync|w180 ;
wire \N$/stars/xpd6-sync|w2 ;
wire \N$/stars/xpd6-sync|w38 ;
wire \N$/stars/xpd6-sync|w39 ;
wire \N$/stars/xpd6-sync|w40 ;
wire \N$/stars/xpd6-sync|w42 ;
wire \N$/stars/xpd6-sync|w44 ;
wire \N$/stars/xpd6-sync|w5 ;
wire \N$/tilemaps/cb-bus1|UAX81.5 ;
wire \N$/tilemaps/cb-bus1|UAX85.5 ;
wire \N$/tilemaps/cb-bus1|UAX90.5 ;
wire \N$/tilemaps/cb-bus1|UAX94.5 ;
wire \N$/tilemaps/cb-bus1|w17 ;
wire \N$/tilemaps/cb-bus1|w177 ;
wire \N$/tilemaps/cb-bus1|w178 ;
wire \N$/tilemaps/cb-bus1|w179 ;
wire \N$/tilemaps/cb-bus1|w180 ;
wire \N$/tilemaps/cb-bus1|w181 ;
wire \N$/tilemaps/cb-bus1|w182 ;
wire \N$/tilemaps/cb-bus1|w183 ;
wire \N$/tilemaps/cb-bus1|w184 ;
wire \N$/tilemaps/cb-bus1|w188 ;
wire \N$/tilemaps/cb-bus2|UAJ81.15 ;
wire \N$/tilemaps/cb-bus2|UAJ81.16 ;
wire \N$/tilemaps/cb-bus2|UAJ81.19 ;
wire \N$/tilemaps/cb-bus2|w24 ;
wire \N$/tilemaps/cb-bus2|w25 ;
wire \N$/tilemaps/cb-bus2|w26 ;
wire \N$/tilemaps/cb-bus2|w27 ;
wire \N$/tilemaps/cb-bus2|w28 ;
wire \N$/tilemaps/cb-bus2|w29 ;
wire \N$/tilemaps/cb-bus2|w30 ;
wire \N$/tilemaps/cb-bus2|w31 ;
wire \N$/tilemaps/cb-bus2|w32 ;
wire \N$/tilemaps/cb-bus2|w33 ;
wire \N$/tilemaps/cb-bus2|w34 ;
wire \N$/tilemaps/cb-bus2|w50 ;
wire \N$/tilemaps/cb-bus2|w59 ;
wire \N$/tilemaps/cb-bus3|UAR341.5 ;
wire \N$/tilemaps/cb-bus3|UAU289.16 ;
wire \N$/tilemaps/cb-bus3|UAU289.19 ;
wire \N$/tilemaps/cb-bus3|UAU289.2 ;
wire \N$/tilemaps/cb-bus3|w31 ;
wire \N$/tilemaps/col2-assemble|w13 ;
wire \N$/tilemaps/col3-assemble|w13 ;
wire \N$/tilemaps/col4-assemble|w13 ;
wire \N$/tilemaps/sr1-sync|UAY102.5 ;
wire \N$/tilemaps/sr1-sync|UAY114.5 ;
wire \N$/tilemaps/sr1-sync|UAY121.2 ;
wire \N$/tilemaps/sr1-sync|UAZ111.5 ;
wire \N$/tilemaps/sr1-sync|UAZ98.5 ;
wire \N$/tilemaps/sr1-sync|w100 ;
wire \N$/tilemaps/sr1-sync|w102 ;
wire \N$/tilemaps/sr1-sync|w103 ;
wire \N$/tilemaps/sr1-sync|w107 ;
wire \N$/tilemaps/sr1-sync|w108 ;
wire \N$/tilemaps/sr1-sync|w110 ;
wire \N$/tilemaps/sr1-sync|w111 ;
wire \N$/tilemaps/sr1-sync|w112 ;
wire \N$/tilemaps/sr1-sync|w16 ;
wire \N$/tilemaps/sr1-sync|w2 ;
wire \N$/tilemaps/sr1-sync|w22 ;
wire \N$/tilemaps/sr1-sync|w38 ;
wire \N$/tilemaps/sr1-sync|w39 ;
wire \N$/tilemaps/sr1-sync|w40 ;
wire \N$/tilemaps/sr1-sync|w50 ;
wire \N$/tilemaps/sr1-sync|w89 ;
wire \N$/tilemaps/sr1-sync|w93 ;
wire \N$/tilemaps/sr1-sync|w94 ;
wire \N$/tilemaps/sr1-sync|w95 ;
wire \N$/tilemaps/sr1-sync|w96 ;
wire \N$/tilemaps/sr1-sync|w98 ;
wire \N$/tilemaps/sr1|w117 ;
wire \N$/tilemaps/sr1|w119 ;
wire \N$/tilemaps/sr1|w121 ;
wire \N$/tilemaps/sr1|w123 ;
wire \N$/tilemaps/sr1|w125 ;
wire \N$/tilemaps/sr1|w127 ;
wire \N$/tilemaps/sr1|w129 ;
wire \N$/tilemaps/sr1|w131 ;
wire \N$/tilemaps/sr1|w133 ;
wire \N$/tilemaps/sr1|w135 ;
wire \N$/tilemaps/sr1|w137 ;
wire \N$/tilemaps/sr1|w139 ;
wire \N$/tilemaps/sr1|w141 ;
wire \N$/tilemaps/sr1|w143 ;
wire \N$/tilemaps/sr1|w145 ;
wire \N$/tilemaps/sr1|w147 ;
wire \N$/tilemaps/sr1|w149 ;
wire \N$/tilemaps/sr1|w151 ;
wire \N$/tilemaps/sr1|w153 ;
wire \N$/tilemaps/sr1|w155 ;
wire \N$/tilemaps/sr1|w157 ;
wire \N$/tilemaps/sr1|w159 ;
wire \N$/tilemaps/sr1|w161 ;
wire \N$/tilemaps/sr1|w163 ;
wire \N$/tilemaps/sr1|w165 ;
wire \N$/tilemaps/sr1|w170 ;
wire \N$/tilemaps/sr1|w175 ;
wire \N$/tilemaps/sr1|w180 ;
wire \N$/tilemaps/sr1|w248 ;
wire \N$/tilemaps/sr1|w250 ;
wire \N$/tilemaps/sr1|w252 ;
wire \N$/tilemaps/sr1|w254 ;
wire \N$/tilemaps/sr1|w341 ;
wire \N$/tilemaps/sr1|w349 ;
wire \N$/tilemaps/sr1|w357 ;
wire \N$/tilemaps/sr1|w365 ;
wire \N$/tilemaps/sr1|w368 ;
wire \N$/tilemaps/sr1|w371 ;
wire \N$/tilemaps/sr1|w374 ;
wire \N$/tilemaps/sr1|w377 ;
wire \N$/tilemaps/sr1|w380 ;
wire \N$/tilemaps/sr1|w383 ;
wire \N$/tilemaps/sr1|w386 ;
wire \N$/tilemaps/sr1|w389 ;
wire \N$/tilemaps/sr1|w392 ;
wire \N$/tilemaps/sr1|w395 ;
wire \N$/tilemaps/sr1|w398 ;
wire \N$/tilemaps/sr1|w401 ;
wire \N$/tilemaps/sr1|w404 ;
wire \N$/tilemaps/sr1|w407 ;
wire \N$/tilemaps/sr1|w410 ;
wire \N$/tilemaps/sr1|w413 ;
wire \N$/tilemaps/sr1|w416 ;
wire \N$/tilemaps/sr1|w419 ;
wire \N$/tilemaps/sr1|w422 ;
wire \N$/tilemaps/sr1|w425 ;
wire \N$/tilemaps/sr1|w428 ;
wire \N$/tilemaps/sr1|w431 ;
wire \N$/tilemaps/sr1|w434 ;
wire \N$/tilemaps/sr1|w437 ;
wire \N$/tilemaps/sr1|w440 ;
wire \N$/tilemaps/sr1|w443 ;
wire \N$/tilemaps/sr1|w446 ;
wire \N$/tilemaps/sr1|w449 ;
wire \N$/tilemaps/sr2-sync|UAL102.5 ;
wire \N$/tilemaps/sr2-sync|UAL114.5 ;
wire \N$/tilemaps/sr2-sync|UAL121.2 ;
wire \N$/tilemaps/sr2-sync|UAN111.5 ;
wire \N$/tilemaps/sr2-sync|UAN98.5 ;
wire \N$/tilemaps/sr2-sync|w101 ;
wire \N$/tilemaps/sr2-sync|w103 ;
wire \N$/tilemaps/sr2-sync|w104 ;
wire \N$/tilemaps/sr2-sync|w108 ;
wire \N$/tilemaps/sr2-sync|w109 ;
wire \N$/tilemaps/sr2-sync|w111 ;
wire \N$/tilemaps/sr2-sync|w112 ;
wire \N$/tilemaps/sr2-sync|w113 ;
wire \N$/tilemaps/sr2-sync|w17 ;
wire \N$/tilemaps/sr2-sync|w23 ;
wire \N$/tilemaps/sr2-sync|w39 ;
wire \N$/tilemaps/sr2-sync|w40 ;
wire \N$/tilemaps/sr2-sync|w41 ;
wire \N$/tilemaps/sr2-sync|w51 ;
wire \N$/tilemaps/sr2-sync|w90 ;
wire \N$/tilemaps/sr2-sync|w94 ;
wire \N$/tilemaps/sr2-sync|w95 ;
wire \N$/tilemaps/sr2-sync|w96 ;
wire \N$/tilemaps/sr2-sync|w97 ;
wire \N$/tilemaps/sr2-sync|w99 ;
wire \N$/tilemaps/sr2|w129 ;
wire \N$/tilemaps/sr2|w132 ;
wire \N$/tilemaps/sr2|w135 ;
wire \N$/tilemaps/sr2|w138 ;
wire \N$/tilemaps/sr2|w141 ;
wire \N$/tilemaps/sr2|w144 ;
wire \N$/tilemaps/sr2|w147 ;
wire \N$/tilemaps/sr2|w150 ;
wire \N$/tilemaps/sr2|w153 ;
wire \N$/tilemaps/sr2|w156 ;
wire \N$/tilemaps/sr2|w159 ;
wire \N$/tilemaps/sr2|w162 ;
wire \N$/tilemaps/sr2|w165 ;
wire \N$/tilemaps/sr2|w168 ;
wire \N$/tilemaps/sr2|w171 ;
wire \N$/tilemaps/sr2|w174 ;
wire \N$/tilemaps/sr2|w177 ;
wire \N$/tilemaps/sr2|w179 ;
wire \N$/tilemaps/sr2|w182 ;
wire \N$/tilemaps/sr2|w185 ;
wire \N$/tilemaps/sr2|w188 ;
wire \N$/tilemaps/sr2|w191 ;
wire \N$/tilemaps/sr2|w194 ;
wire \N$/tilemaps/sr2|w197 ;
wire \N$/tilemaps/sr2|w200 ;
wire \N$/tilemaps/sr2|w203 ;
wire \N$/tilemaps/sr2|w206 ;
wire \N$/tilemaps/sr2|w209 ;
wire \N$/tilemaps/sr2|w261 ;
wire \N$/tilemaps/sr2|w275 ;
wire \N$/tilemaps/sr2|w277 ;
wire \N$/tilemaps/sr2|w279 ;
wire \N$/tilemaps/sr2|w281 ;
wire \N$/tilemaps/sr2|w365 ;
wire \N$/tilemaps/sr2|w373 ;
wire \N$/tilemaps/sr2|w381 ;
wire \N$/tilemaps/sr2|w389 ;
wire \N$/tilemaps/sr2|w392 ;
wire \N$/tilemaps/sr2|w395 ;
wire \N$/tilemaps/sr2|w398 ;
wire \N$/tilemaps/sr2|w401 ;
wire \N$/tilemaps/sr2|w404 ;
wire \N$/tilemaps/sr2|w407 ;
wire \N$/tilemaps/sr2|w410 ;
wire \N$/tilemaps/sr2|w413 ;
wire \N$/tilemaps/sr2|w416 ;
wire \N$/tilemaps/sr2|w419 ;
wire \N$/tilemaps/sr2|w422 ;
wire \N$/tilemaps/sr2|w425 ;
wire \N$/tilemaps/sr2|w428 ;
wire \N$/tilemaps/sr2|w431 ;
wire \N$/tilemaps/sr2|w434 ;
wire \N$/tilemaps/sr2|w437 ;
wire \N$/tilemaps/sr2|w440 ;
wire \N$/tilemaps/sr2|w443 ;
wire \N$/tilemaps/sr2|w446 ;
wire \N$/tilemaps/sr2|w449 ;
wire \N$/tilemaps/sr2|w452 ;
wire \N$/tilemaps/sr2|w455 ;
wire \N$/tilemaps/sr2|w458 ;
wire \N$/tilemaps/sr2|w461 ;
wire \N$/tilemaps/sr2|w464 ;
wire \N$/tilemaps/sr2|w467 ;
wire \N$/tilemaps/sr2|w470 ;
wire \N$/tilemaps/sr2|w473 ;
wire \N$/tilemaps/sr2|w493 ;
wire \N$/tilemaps/sr2|w503 ;
wire \N$/tilemaps/sr2|w504 ;
wire \N$/tilemaps/sr2|w505 ;
wire \N$/tilemaps/sr3-sync|UAT338.5 ;
wire \N$/tilemaps/sr3-sync|UAT350.5 ;
wire \N$/tilemaps/sr3-sync|UAT357.2 ;
wire \N$/tilemaps/sr3-sync|UAU334.5 ;
wire \N$/tilemaps/sr3-sync|UAU347.5 ;
wire \N$/tilemaps/sr3-sync|w101 ;
wire \N$/tilemaps/sr3-sync|w103 ;
wire \N$/tilemaps/sr3-sync|w104 ;
wire \N$/tilemaps/sr3-sync|w108 ;
wire \N$/tilemaps/sr3-sync|w109 ;
wire \N$/tilemaps/sr3-sync|w111 ;
wire \N$/tilemaps/sr3-sync|w112 ;
wire \N$/tilemaps/sr3-sync|w113 ;
wire \N$/tilemaps/sr3-sync|w17 ;
wire \N$/tilemaps/sr3-sync|w23 ;
wire \N$/tilemaps/sr3-sync|w39 ;
wire \N$/tilemaps/sr3-sync|w40 ;
wire \N$/tilemaps/sr3-sync|w41 ;
wire \N$/tilemaps/sr3-sync|w51 ;
wire \N$/tilemaps/sr3-sync|w90 ;
wire \N$/tilemaps/sr3-sync|w94 ;
wire \N$/tilemaps/sr3-sync|w95 ;
wire \N$/tilemaps/sr3-sync|w96 ;
wire \N$/tilemaps/sr3-sync|w97 ;
wire \N$/tilemaps/sr3-sync|w99 ;
wire \N$/tilemaps/sr3|w129 ;
wire \N$/tilemaps/sr3|w132 ;
wire \N$/tilemaps/sr3|w135 ;
wire \N$/tilemaps/sr3|w138 ;
wire \N$/tilemaps/sr3|w141 ;
wire \N$/tilemaps/sr3|w144 ;
wire \N$/tilemaps/sr3|w147 ;
wire \N$/tilemaps/sr3|w150 ;
wire \N$/tilemaps/sr3|w153 ;
wire \N$/tilemaps/sr3|w156 ;
wire \N$/tilemaps/sr3|w159 ;
wire \N$/tilemaps/sr3|w162 ;
wire \N$/tilemaps/sr3|w165 ;
wire \N$/tilemaps/sr3|w168 ;
wire \N$/tilemaps/sr3|w171 ;
wire \N$/tilemaps/sr3|w174 ;
wire \N$/tilemaps/sr3|w177 ;
wire \N$/tilemaps/sr3|w179 ;
wire \N$/tilemaps/sr3|w182 ;
wire \N$/tilemaps/sr3|w185 ;
wire \N$/tilemaps/sr3|w188 ;
wire \N$/tilemaps/sr3|w191 ;
wire \N$/tilemaps/sr3|w194 ;
wire \N$/tilemaps/sr3|w197 ;
wire \N$/tilemaps/sr3|w200 ;
wire \N$/tilemaps/sr3|w203 ;
wire \N$/tilemaps/sr3|w206 ;
wire \N$/tilemaps/sr3|w209 ;
wire \N$/tilemaps/sr3|w261 ;
wire \N$/tilemaps/sr3|w275 ;
wire \N$/tilemaps/sr3|w277 ;
wire \N$/tilemaps/sr3|w279 ;
wire \N$/tilemaps/sr3|w281 ;
wire \N$/tilemaps/sr3|w364 ;
wire \N$/tilemaps/sr3|w372 ;
wire \N$/tilemaps/sr3|w380 ;
wire \N$/tilemaps/sr3|w388 ;
wire \N$/tilemaps/sr3|w391 ;
wire \N$/tilemaps/sr3|w394 ;
wire \N$/tilemaps/sr3|w397 ;
wire \N$/tilemaps/sr3|w400 ;
wire \N$/tilemaps/sr3|w403 ;
wire \N$/tilemaps/sr3|w406 ;
wire \N$/tilemaps/sr3|w409 ;
wire \N$/tilemaps/sr3|w412 ;
wire \N$/tilemaps/sr3|w415 ;
wire \N$/tilemaps/sr3|w418 ;
wire \N$/tilemaps/sr3|w421 ;
wire \N$/tilemaps/sr3|w424 ;
wire \N$/tilemaps/sr3|w427 ;
wire \N$/tilemaps/sr3|w430 ;
wire \N$/tilemaps/sr3|w433 ;
wire \N$/tilemaps/sr3|w436 ;
wire \N$/tilemaps/sr3|w439 ;
wire \N$/tilemaps/sr3|w442 ;
wire \N$/tilemaps/sr3|w445 ;
wire \N$/tilemaps/sr3|w448 ;
wire \N$/tilemaps/sr3|w451 ;
wire \N$/tilemaps/sr3|w454 ;
wire \N$/tilemaps/sr3|w457 ;
wire \N$/tilemaps/sr3|w460 ;
wire \N$/tilemaps/sr3|w463 ;
wire \N$/tilemaps/sr3|w466 ;
wire \N$/tilemaps/sr3|w469 ;
wire \N$/tilemaps/sr3|w472 ;
wire \N$/tilemaps/sr3|w492 ;
wire \N$/tilemaps/sr3|w502 ;
wire \N$/tilemaps/sr3|w503 ;
wire \N$/tilemaps/sr3|w504 ;
wire \N$/tilemaps/xpd-bus1|UAG40.2 ;
wire \N$/tilemaps/xpd-bus1|UAI37.2 ;
wire \N$/tilemaps/xpd-bus1|UAJ1.11 ;
wire \N$/tilemaps/xpd-bus1|UAJ1.12 ;
wire \N$/tilemaps/xpd-bus1|UAJ1.13 ;
wire \N$/tilemaps/xpd-bus1|UAJ1.14 ;
wire \N$/tilemaps/xpd-bus1|UAJ1.15 ;
wire \N$/tilemaps/xpd-bus1|UAJ1.16 ;
wire \N$/tilemaps/xpd-bus1|UAJ39.11 ;
wire \N$/tilemaps/xpd-bus1|UAJ39.12 ;
wire \N$/tilemaps/xpd-bus1|UAJ39.13 ;
wire \N$/tilemaps/xpd-bus1|UAJ39.14 ;
wire \N$/tilemaps/xpd-bus1|UAJ39.15 ;
wire \N$/tilemaps/xpd-bus1|UAJ39.16 ;
wire \N$/tilemaps/xpd-bus1|UAP1.11 ;
wire \N$/tilemaps/xpd-bus1|UAP1.12 ;
wire \N$/tilemaps/xpd-bus1|UAP1.13 ;
wire \N$/tilemaps/xpd-bus1|UAP1.14 ;
wire \N$/tilemaps/xpd-bus1|UAP1.15 ;
wire \N$/tilemaps/xpd-bus1|UAP1.16 ;
wire \N$/tilemaps/xpd-bus1|UAP39.11 ;
wire \N$/tilemaps/xpd-bus1|UAP39.12 ;
wire \N$/tilemaps/xpd-bus1|UAP39.13 ;
wire \N$/tilemaps/xpd-bus1|UAP39.14 ;
wire \N$/tilemaps/xpd-bus1|UAP39.15 ;
wire \N$/tilemaps/xpd-bus1|UAP39.16 ;
wire \N$/tilemaps/xpd-bus1|w208 ;
wire \N$/tilemaps/xpd-bus1|w262 ;
wire \N$/tilemaps/xpd-bus1|w264 ;
wire \N$/tilemaps/xpd-bus1|w266 ;
wire \N$/tilemaps/xpd-bus1|w268 ;
wire \N$/tilemaps/xpd-bus1|w271 ;
wire \N$/tilemaps/xpd-bus1|w274 ;
wire \N$/tilemaps/xpd-bus1|w277 ;
wire \N$/tilemaps/xpd-bus1|w280 ;
wire \N$/tilemaps/xpd-bus1|w282 ;
wire \N$/tilemaps/xpd-bus1|w284 ;
wire \N$/tilemaps/xpd-bus1|w286 ;
wire \N$/tilemaps/xpd-bus1|w288 ;
wire \N$/tilemaps/xpd-bus1|w293 ;
wire \N$/tilemaps/xpd-bus1|w296 ;
wire \N$/tilemaps/xpd-bus1|w299 ;
wire \N$/tilemaps/xpd-bus1|w302 ;
wire \N$/tilemaps/xpd-bus1|w306 ;
wire \N$/tilemaps/xpd-bus1|w308 ;
wire \N$/tilemaps/xpd-bus1|w310 ;
wire \N$/tilemaps/xpd-bus1|w312 ;
wire \N$/tilemaps/xpd-bus1|w315 ;
wire \N$/tilemaps/xpd-bus1|w318 ;
wire \N$/tilemaps/xpd-bus1|w321 ;
wire \N$/tilemaps/xpd-bus1|w324 ;
wire \N$/tilemaps/xpd-bus1|w326 ;
wire \N$/tilemaps/xpd-bus1|w328 ;
wire \N$/tilemaps/xpd-bus1|w330 ;
wire \N$/tilemaps/xpd-bus1|w332 ;
wire \N$/tilemaps/xpd-bus1|w335 ;
wire \N$/tilemaps/xpd-bus1|w338 ;
wire \N$/tilemaps/xpd-bus1|w341 ;
wire \N$/tilemaps/xpd-bus1|w344 ;
wire \N$/tilemaps/xpd-bus1|w353 ;
wire \N$/tilemaps/xpd-bus1|w379 ;
wire \N$/tilemaps/xpd-bus1|w390 ;
wire \N$/tilemaps/xpd-bus1|w392 ;
wire \N$/tilemaps/xpd-bus1|w394 ;
wire \N$/tilemaps/xpd-bus1|w396 ;
wire \N$/tilemaps/xpd-bus1|w409 ;
wire \N$/tilemaps/xpd-bus1|w411 ;
wire \N$/tilemaps/xpd-bus1|w415 ;
wire \N$/tilemaps/xpd-bus1|w419 ;
wire \N$/tilemaps/xpd-bus1|w421 ;
wire \N$/tilemaps/xpd-bus1|w425 ;
wire \N$/tilemaps/xpd-bus2|UAG165.2 ;
wire \N$/tilemaps/xpd-bus2|UAI167.2 ;
wire \N$/tilemaps/xpd-bus2|UAJ128.11 ;
wire \N$/tilemaps/xpd-bus2|UAJ128.12 ;
wire \N$/tilemaps/xpd-bus2|UAJ128.13 ;
wire \N$/tilemaps/xpd-bus2|UAJ128.14 ;
wire \N$/tilemaps/xpd-bus2|UAJ128.15 ;
wire \N$/tilemaps/xpd-bus2|UAJ128.16 ;
wire \N$/tilemaps/xpd-bus2|UAJ167.11 ;
wire \N$/tilemaps/xpd-bus2|UAJ167.12 ;
wire \N$/tilemaps/xpd-bus2|UAJ167.13 ;
wire \N$/tilemaps/xpd-bus2|UAJ167.14 ;
wire \N$/tilemaps/xpd-bus2|UAJ167.15 ;
wire \N$/tilemaps/xpd-bus2|UAJ167.16 ;
wire \N$/tilemaps/xpd-bus2|UAP128.11 ;
wire \N$/tilemaps/xpd-bus2|UAP128.12 ;
wire \N$/tilemaps/xpd-bus2|UAP128.13 ;
wire \N$/tilemaps/xpd-bus2|UAP128.14 ;
wire \N$/tilemaps/xpd-bus2|UAP128.15 ;
wire \N$/tilemaps/xpd-bus2|UAP128.16 ;
wire \N$/tilemaps/xpd-bus2|UAP167.11 ;
wire \N$/tilemaps/xpd-bus2|UAP167.12 ;
wire \N$/tilemaps/xpd-bus2|UAP167.13 ;
wire \N$/tilemaps/xpd-bus2|UAP167.14 ;
wire \N$/tilemaps/xpd-bus2|UAP167.15 ;
wire \N$/tilemaps/xpd-bus2|UAP167.16 ;
wire \N$/tilemaps/xpd-bus2|w177 ;
wire \N$/tilemaps/xpd-bus2|w207 ;
wire \N$/tilemaps/xpd-bus2|w261 ;
wire \N$/tilemaps/xpd-bus2|w263 ;
wire \N$/tilemaps/xpd-bus2|w265 ;
wire \N$/tilemaps/xpd-bus2|w267 ;
wire \N$/tilemaps/xpd-bus2|w270 ;
wire \N$/tilemaps/xpd-bus2|w273 ;
wire \N$/tilemaps/xpd-bus2|w276 ;
wire \N$/tilemaps/xpd-bus2|w279 ;
wire \N$/tilemaps/xpd-bus2|w281 ;
wire \N$/tilemaps/xpd-bus2|w283 ;
wire \N$/tilemaps/xpd-bus2|w285 ;
wire \N$/tilemaps/xpd-bus2|w287 ;
wire \N$/tilemaps/xpd-bus2|w292 ;
wire \N$/tilemaps/xpd-bus2|w295 ;
wire \N$/tilemaps/xpd-bus2|w298 ;
wire \N$/tilemaps/xpd-bus2|w301 ;
wire \N$/tilemaps/xpd-bus2|w305 ;
wire \N$/tilemaps/xpd-bus2|w307 ;
wire \N$/tilemaps/xpd-bus2|w309 ;
wire \N$/tilemaps/xpd-bus2|w311 ;
wire \N$/tilemaps/xpd-bus2|w314 ;
wire \N$/tilemaps/xpd-bus2|w317 ;
wire \N$/tilemaps/xpd-bus2|w320 ;
wire \N$/tilemaps/xpd-bus2|w323 ;
wire \N$/tilemaps/xpd-bus2|w325 ;
wire \N$/tilemaps/xpd-bus2|w327 ;
wire \N$/tilemaps/xpd-bus2|w329 ;
wire \N$/tilemaps/xpd-bus2|w331 ;
wire \N$/tilemaps/xpd-bus2|w334 ;
wire \N$/tilemaps/xpd-bus2|w337 ;
wire \N$/tilemaps/xpd-bus2|w340 ;
wire \N$/tilemaps/xpd-bus2|w343 ;
wire \N$/tilemaps/xpd-bus2|w352 ;
wire \N$/tilemaps/xpd-bus2|w378 ;
wire \N$/tilemaps/xpd-bus2|w389 ;
wire \N$/tilemaps/xpd-bus2|w391 ;
wire \N$/tilemaps/xpd-bus2|w393 ;
wire \N$/tilemaps/xpd-bus2|w395 ;
wire \N$/tilemaps/xpd-bus2|w408 ;
wire \N$/tilemaps/xpd-bus2|w410 ;
wire \N$/tilemaps/xpd-bus2|w414 ;
wire \N$/tilemaps/xpd-bus2|w418 ;
wire \N$/tilemaps/xpd-bus2|w420 ;
wire \N$/tilemaps/xpd-bus2|w424 ;
wire \N$/tilemaps/xpd-bus3|UAI245.2 ;
wire \N$/tilemaps/xpd-bus3|UAJ208.11 ;
wire \N$/tilemaps/xpd-bus3|UAJ208.12 ;
wire \N$/tilemaps/xpd-bus3|UAJ208.13 ;
wire \N$/tilemaps/xpd-bus3|UAJ208.14 ;
wire \N$/tilemaps/xpd-bus3|UAJ208.15 ;
wire \N$/tilemaps/xpd-bus3|UAJ208.16 ;
wire \N$/tilemaps/xpd-bus3|UAJ247.11 ;
wire \N$/tilemaps/xpd-bus3|UAJ247.12 ;
wire \N$/tilemaps/xpd-bus3|UAJ247.13 ;
wire \N$/tilemaps/xpd-bus3|UAJ247.14 ;
wire \N$/tilemaps/xpd-bus3|UAJ247.15 ;
wire \N$/tilemaps/xpd-bus3|UAJ247.16 ;
wire \N$/tilemaps/xpd-bus3|UAP208.11 ;
wire \N$/tilemaps/xpd-bus3|UAP208.12 ;
wire \N$/tilemaps/xpd-bus3|UAP208.13 ;
wire \N$/tilemaps/xpd-bus3|UAP208.14 ;
wire \N$/tilemaps/xpd-bus3|UAP208.15 ;
wire \N$/tilemaps/xpd-bus3|UAP208.16 ;
wire \N$/tilemaps/xpd-bus3|UAP247.11 ;
wire \N$/tilemaps/xpd-bus3|UAP247.12 ;
wire \N$/tilemaps/xpd-bus3|UAP247.13 ;
wire \N$/tilemaps/xpd-bus3|UAP247.14 ;
wire \N$/tilemaps/xpd-bus3|UAP247.15 ;
wire \N$/tilemaps/xpd-bus3|UAP247.16 ;
wire \N$/tilemaps/xpd-bus3|w161 ;
wire \N$/tilemaps/xpd-bus3|w162 ;
wire \N$/tilemaps/xpd-bus3|w197 ;
wire \N$/tilemaps/xpd-bus3|w200 ;
wire \N$/tilemaps/xpd-bus3|w203 ;
wire \N$/tilemaps/xpd-bus3|w206 ;
wire \N$/tilemaps/xpd-bus3|w210 ;
wire \N$/tilemaps/xpd-bus3|w214 ;
wire \N$/tilemaps/xpd-bus3|w218 ;
wire \N$/tilemaps/xpd-bus3|w222 ;
wire \N$/tilemaps/xpd-bus3|w224 ;
wire \N$/tilemaps/xpd-bus3|w226 ;
wire \N$/tilemaps/xpd-bus3|w228 ;
wire \N$/tilemaps/xpd-bus3|w230 ;
wire \N$/tilemaps/xpd-bus3|w238 ;
wire \N$/tilemaps/xpd-bus3|w242 ;
wire \N$/tilemaps/xpd-bus3|w246 ;
wire \N$/tilemaps/xpd-bus3|w250 ;
wire \N$/tilemaps/xpd-bus3|w254 ;
wire \N$/tilemaps/xpd-bus3|w256 ;
wire \N$/tilemaps/xpd-bus3|w258 ;
wire \N$/tilemaps/xpd-bus3|w260 ;
wire \N$/tilemaps/xpd-bus3|w261 ;
wire \N$/tilemaps/xpd-bus3|w265 ;
wire \N$/tilemaps/xpd-bus3|w269 ;
wire \N$/tilemaps/xpd-bus3|w273 ;
wire \N$/tilemaps/xpd-bus3|w277 ;
wire \N$/tilemaps/xpd-bus3|w280 ;
wire \N$/tilemaps/xpd-bus3|w282 ;
wire \N$/tilemaps/xpd-bus3|w284 ;
wire \N$/tilemaps/xpd-bus3|w286 ;
wire \N$/tilemaps/xpd-bus3|w290 ;
wire \N$/tilemaps/xpd-bus3|w294 ;
wire \N$/tilemaps/xpd-bus3|w298 ;
wire \N$/tilemaps/xpd-bus3|w302 ;
wire \N$/tilemaps/xpd-bus3|w311 ;
wire \N$/tilemaps/xpd-bus3|w337 ;
wire \N$/tilemaps/xpd-bus3|w348 ;
wire \N$/tilemaps/xpd-bus3|w350 ;
wire \N$/tilemaps/xpd-bus3|w352 ;
wire \N$/tilemaps/xpd-bus3|w354 ;
wire \N$/tilemaps/xpd-bus3|w367 ;
wire \N$/tilemaps/xpd-bus3|w369 ;
wire \N$/tilemaps/xpd-bus3|w373 ;
wire \N$/tilemaps/xpd-bus3|w377 ;
wire \N$/tilemaps/xpd-bus3|w379 ;
wire \N$/tilemaps/xpd-bus3|w383 ;
wire \N$/video-signals/video-counter|UBU370.3 ;
wire \N$/video-signals/video-counter|UBU370.5 ;
wire \N$/video-signals/video-counter|UBU446.3 ;
wire \N$/video-signals/video-counter|UBU446.5 ;
wire \N$/video-signals/video-counter|UBW150.5 ;
wire \N$/video-signals/video-counter|UBZ126.5 ;
wire \N$/video-signals/video-counter|UBZ150.5 ;
wire \N$/video-signals/video-counter|UBZ187.5 ;
wire \N$/video-signals/video-counter|UBZ234.5 ;
wire \N$/video-signals/video-counter|UBZ243.5 ;
wire \N$/video-signals/video-counter|UCC161.5 ;
wire \N$/video-signals/video-counter|UCC176.5 ;
wire \N$/video-signals/video-counter|UCC181.5 ;
wire \N$/video-signals/video-counter|UCC269.5 ;
wire \N$/video-signals/video-counter|UCG161.5 ;
wire \N$/video-signals/video-counter|UCG275.5 ;
wire \N$/video-signals/video-counter|UCJ162.5 ;
wire \N$/video-signals/video-counter|UCJ222.5 ;
wire \N$/video-signals/video-counter|UCJ280.5 ;
wire \N$/video-signals/video-counter|UCL186.5 ;
wire \N$/video-signals/video-counter|UCL207.5 ;
wire \N$/video-signals/video-counter|w114 ;
wire \N$/video-signals/video-counter|w115 ;
wire \N$/video-signals/video-counter|w116 ;
wire \N$/video-signals/video-counter|w117 ;
wire \N$/video-signals/video-counter|w146 ;
wire \N$/video-signals/video-counter|w152 ;
wire \N$/video-signals/video-counter|w157 ;
wire \N$/video-signals/video-counter|w168 ;
wire \N$/video-signals/video-counter|w171 ;
wire \N$/video-signals/video-counter|w174 ;
wire \N$/video-signals/video-counter|w178 ;
wire \N$/video-signals/video-counter|w181 ;
wire \N$/video-signals/video-counter|w183 ;
wire \N$/video-signals/video-counter|w186 ;
wire \N$/video-signals/video-counter|w197 ;
wire \N$/video-signals/video-counter|w198 ;
wire \N$/video-signals/video-counter|w2 ;
wire \N$/video-signals/video-counter|w200 ;
wire \N$/video-signals/video-counter|w202 ;
wire \N$/video-signals/video-counter|w204 ;
wire \N$/video-signals/video-counter|w206 ;
wire \N$/video-signals/video-counter|w208 ;
wire \N$/video-signals/video-counter|w210 ;
wire \N$/video-signals/video-counter|w230 ;
wire \N$/video-signals/video-counter|w247 ;
wire \N$/video-signals/video-counter|w251 ;
wire \N$/video-signals/video-counter|w266 ;
wire \N$/video-signals/video-counter|w27 ;
wire \N$/video-signals/video-counter|w273 ;
wire \N$/video-signals/video-counter|w276 ;
wire \N$/video-signals/video-counter|w278 ;
wire \N$/video-signals/video-counter|w298 ;
wire \N$/video-signals/video-counter|w299 ;
wire \N$/video-signals/video-counter|w3 ;
wire \N$/video-signals/video-counter|w307 ;
wire \N$/video-signals/video-counter|w308 ;
wire \N$/video-signals/video-counter|w309 ;
wire \N$/video-signals/video-counter|w313 ;
wire \N$/video-signals/video-counter|w316 ;
wire \N$/video-signals/video-counter|w318 ;
wire \N$/video-signals/video-counter|w32 ;
wire \N$/video-signals/video-counter|w320 ;
wire \N$/video-signals/video-counter|w321 ;
wire \N$/video-signals/video-counter|w323 ;
wire \N$/video-signals/video-counter|w327 ;
wire \N$/video-signals/video-counter|w329 ;
wire \N$/video-signals/video-counter|w33 ;
wire \N$/video-signals/video-counter|w330 ;
wire \N$/video-signals/video-counter|w333 ;
wire \N$/video-signals/video-counter|w336 ;
wire \N$/video-signals/video-counter|w337 ;
wire \N$/video-signals/video-counter|w34 ;
wire \N$/video-signals/video-counter|w340 ;
wire \N$/video-signals/video-counter|w341 ;
wire \N$/video-signals/video-counter|w342 ;
wire \N$/video-signals/video-counter|w343 ;
wire \N$/video-signals/video-counter|w346 ;
wire \N$/video-signals/video-counter|w351 ;
wire \N$/video-signals/video-counter|w355 ;
wire \N$/video-signals/video-counter|w363 ;
wire \N$/video-signals/video-counter|w371 ;
wire \N$/video-signals/video-counter|w373 ;
wire \N$/video-signals/video-counter|w374 ;
wire \N$/video-signals/video-counter|w425 ;
wire \N$/video-signals/video-counter|w428 ;
wire \N$/video-signals/video-counter|w429 ;
wire \N$/video-signals/video-counter|w430 ;
wire \N$/video-signals/video-counter|w431 ;
wire \N$/video-signals/video-counter|w460 ;
wire \N$/video-signals/video-counter|w465 ;
wire \N$/video-signals/video-counter|w470 ;
wire \N$/video-signals/video-counter|w478 ;
wire \N$/video-signals/video-counter|w481 ;
wire \N$/video-signals/video-counter|w484 ;
wire \N$/video-signals/video-counter|w488 ;
wire \N$/video-signals/video-counter|w491 ;
wire \N$/video-signals/video-counter|w50 ;
wire \N$/video-signals/video-counter|w502 ;
wire \N$/video-signals/video-counter|w503 ;
wire \N$/video-signals/video-counter|w505 ;
wire \N$/video-signals/video-counter|w507 ;
wire \N$/video-signals/video-counter|w509 ;
wire \N$/video-signals/video-counter|w511 ;
wire \N$/video-signals/video-counter|w513 ;
wire \N$/video-signals/video-counter|w515 ;
wire \N$/video-signals/video-counter|w548 ;
wire \N$/video-signals/video-counter|w552 ;
wire \N$/video-signals/video-counter|w567 ;
wire \N$/video-signals/video-counter|w574 ;
wire \N$/video-signals/video-counter|w576 ;
wire \N$/video-signals/video-counter|w578 ;
wire \N$/video-signals/video-counter|w597 ;
wire \N$/video-signals/video-counter|w598 ;
wire \N$/video-signals/video-counter|w599 ;
wire \N$/video-signals/video-counter|w607 ;
wire \N$/video-signals/video-counter|w608 ;
wire \N$/video-signals/video-counter|w609 ;
wire \N$/video-signals/video-counter|w613 ;
wire \N$/video-signals/video-counter|w616 ;
wire \N$/video-signals/video-counter|w618 ;
wire \N$/video-signals/video-counter|w620 ;
wire \N$/video-signals/video-counter|w621 ;
wire \N$/video-signals/video-counter|w623 ;
wire \N$/video-signals/video-counter|w626 ;
wire \N$/video-signals/video-counter|w628 ;
wire \N$/video-signals/video-counter|w629 ;
wire \N$/video-signals/video-counter|w632 ;
wire \N$/video-signals/video-counter|w635 ;
wire \N$/video-signals/video-counter|w636 ;
wire \N$/video-signals/video-counter|w639 ;
wire \N$/video-signals/video-counter|w640 ;
wire \N$/video-signals/video-counter|w641 ;
wire \N$/video-signals/video-counter|w644 ;
wire \N$/video-signals/video-counter|w67 ;
wire \N$/video-signals/video-signal-generator|UAA254.1 ;
wire \N$/video-signals/video-signal-generator|UBD407.1 ;
wire \N$/video-signals/video-signal-generator|UBH366.6 ;
wire \N$/video-signals/video-signal-generator|UBH383.6 ;
wire \N$/video-signals/video-signal-generator|UBH430.6 ;
wire \N$/video-signals/video-signal-generator|UCJ303.6 ;
wire \N$/video-signals/video-signal-generator|UCJ307.14 ;
wire \N$/video-signals/video-signal-generator|UCJ315.14 ;
wire \N$/video-signals/video-signal-generator|UCL262.9 ;
wire \N$/video-signals/video-signal-generator|UCL272.14 ;
wire \N$/video-signals/video-signal-generator|UCL313.14 ;
wire \N$/video-signals/video-signal-generator|UCL328.14 ;
wire \N$/video-signals/video-signal-generator|UCL336.14 ;
wire \N$/video-signals/video-signal-generator|UCL350.1 ;
wire \N$/video-signals/video-signal-generator|UCL383.14 ;
wire \N$/video-signals/video-signal-generator|UCL391.14 ;
wire \N$/video-signals/video-signal-generator|UCR322.1 ;
wire \N$/video-signals/video-signal-generator|UCR389.14 ;
wire \N$/video-signals/video-signal-generator|UCT335.9 ;
wire \N$/video-signals/video-signal-generator|UCT365.14 ;
wire \N$/video-signals/video-signal-generator|UCT373.9 ;
wire \N$/video-signals/video-signal-generator|UCT388.2 ;
wire \N$/video-signals/video-signal-generator|UCT404.1 ;
wire \N$/video-signals/video-signal-generator|UCT404.2 ;
wire \N$/video-signals/video-signal-generator|w12 ;
wire \N$/video-signals/video-signal-generator|w129 ;
wire \N$/video-signals/video-signal-generator|w135 ;
wire \N$/video-signals/video-signal-generator|w150 ;
wire \N$/video-signals/video-signal-generator|w169 ;
wire \N$/video-signals/video-signal-generator|w17 ;
wire \N$/video-signals/video-signal-generator|w175 ;
wire \N$/video-signals/video-signal-generator|w18 ;
wire \N$/video-signals/video-signal-generator|w181 ;
wire \N$/video-signals/video-signal-generator|w196 ;
wire \N$/video-signals/video-signal-generator|w197 ;
wire \N$/video-signals/video-signal-generator|w198 ;
wire \N$/video-signals/video-signal-generator|w216 ;
wire \N$/video-signals/video-signal-generator|w424 ;
wire \N$/video-signals/video-signal-generator|w427 ;
wire \N$/video-signals/video-signal-generator|w452 ;
wire \N$/video-signals/video-signal-generator|w454 ;
wire \N$/video-signals/video-signal-generator|w459 ;
wire \N$/video-signals/video-signal-generator|w471 ;
wire \N$/video-signals/video-signal-generator|w473 ;
wire \N$/video-signals/video-signal-generator|w496 ;
wire \N$/video-signals/video-signal-generator|w501 ;
wire \N$/video-signals/video-signal-generator|w505 ;
wire \N$/video-signals/video-signal-generator|w507 ;
wire \N$/video-signals/video-signal-generator|w525 ;
wire \N$/video-signals/video-signal-generator|w541 ;
wire \N$/video-signals/video-signal-generator|w548 ;
wire \N$/video-signals/video-signal-generator|w549 ;
wire \N$/video-signals/video-signal-generator|w556 ;
wire \N$/video-signals/video-signal-generator|w562 ;
wire \N$/video-signals/video-signal-generator|w565 ;
wire \N$/video-signals/video-signal-generator|w6 ;
wire \N$/video-signals/video-signal-generator|w620 ;
wire \N$/video-signals/video-signal-generator|w621 ;
wire \N$/video-signals/video-signal-generator|w622 ;
wire \N$/video-signals/video-signal-generator|w624 ;
wire \N$/video-signals/video-signal-generator|w631 ;
wire \N$/video-signals/video-signal-generator|w632 ;
wire \N$/video-signals/video-signal-generator|w642 ;
wire \N$/video-signals/video-signal-generator|w643 ;
wire \N$/video-signals/video-signal-generator|w644 ;
wire \N$/video-signals/video-signal-generator|w645 ;
wire \N$/video-signals/video-signal-registries|UBH436.3 ;
wire \N$/video-signals/video-signal-registries|UBH436.5 ;
wire \N$/video-signals/video-signal-registries|UBH441.3 ;
wire \N$/video-signals/video-signal-registries|UBH441.5 ;
wire \N$/video-signals/video-signal-registries|UBH445.3 ;
wire \N$/video-signals/video-signal-registries|UBH445.5 ;
wire \N$/video-signals/video-signal-registries|UBH450.3 ;
wire \N$/video-signals/video-signal-registries|UBH450.5 ;
wire \N$/video-signals/video-signal-registries|UBH454.3 ;
wire \N$/video-signals/video-signal-registries|UBH454.5 ;
wire \N$/video-signals/video-signal-registries|UBR401.5 ;
wire \N$/video-signals/video-signal-registries|UBR406.5 ;
wire \N$/video-signals/video-signal-registries|UBR410.5 ;
wire \N$/video-signals/video-signal-registries|UBR415.5 ;
wire \N$/video-signals/video-signal-registries|UBR419.5 ;
wire \N$/video-signals/video-signal-registries|UBR429.5 ;
wire \N$/video-signals/video-signal-registries|UBR434.5 ;
wire \N$/video-signals/video-signal-registries|UBR438.5 ;
wire \N$/video-signals/video-signal-registries|UBR442.5 ;
wire \N$/video-signals/video-signal-registries|UBR447.5 ;
wire \N$/video-signals/video-signal-registries|UBU388.5 ;
wire \N$/video-signals/video-signal-registries|UBU392.5 ;
wire \N$/video-signals/video-signal-registries|UBU396.5 ;
wire \N$/video-signals/video-signal-registries|UBU401.5 ;
wire \N$/video-signals/video-signal-registries|UBU405.5 ;
wire \N$/video-signals/video-signal-registries|w28 ;
wire \N$/video-signals/video-signal-registries|w29 ;
wire \N$/video-signals/video-signal-registries|w30 ;
wire \N$/video-signals/video-signal-registries|w44 ;
wire \N$/video-signals/video-signal-registries|w47 ;
wire \N$/video-signals/video-signal-registries|w54 ;
wire \N$/video-signals/video-signal-registries|w55 ;
wire \N$/video-signals/video-signal-registries|w56 ;
wire \N$/video-signals/video-signal-registries|w71 ;
wire \N$/video-signals/video-signal-registries|w74 ;
wire \N$/video-signals/video-signal-registries|w80 ;
wire \N$/video-signals/video-signal-registries|w81 ;
wire \N$/video-signals/video-signal-registries|w82 ;
wire \N$/video-signals/video-signal-registries|w88 ;
wire \N$/video-signals/video-signal-registries|w96 ;
wire \N$/video-signals/video-signal-registries|w99 ;
wire \N$|UBR508.2 ;

//========================================================================
// Wired-OR Nets:
//========================================================================
wor \/counter-fi/~RESET ;
wor \/lut-assembly/lut-storage/CLK ;
wor \/raster-interrupts/counter1/RD ;
wor \/tilemaps/sr1/~CLK8M ;
wor \/tilemaps/sr2/~CLK8M ;
wor \/tilemaps/sr3/~CLK8M ;
wor \/video-signals/video-signal-registries/CLK8M ;
wor \N$/main-signals|w38 ;
wor \N$/xpd-out|w134 ;

//========================================================================
// Charge-Storage Nets:
//========================================================================
trireg \/cps-id/DATA14 ;
trireg \/debug/td-io/IN0 ;
trireg \/debug/td-io/IN1 ;
trireg \/debug/td-io/IN10 ;
trireg \/debug/td-io/IN11 ;
trireg \/debug/td-io/IN2 ;
trireg \/debug/td-io/IN3 ;
trireg \/debug/td-io/IN4 ;
trireg \/debug/td-io/IN5 ;
trireg \/debug/td-io/IN6 ;
trireg \/debug/td-io/IN7 ;
trireg \/debug/td-io/IN8 ;
trireg \/debug/td-io/IN9 ;
trireg \/lut-assembly/layer-control/BUS10 ;
trireg \/lut-assembly/layer-control/BUS11 ;
trireg \/lut-assembly/layer-control/BUS12 ;
trireg \/lut-assembly/layer-control/BUS13 ;
trireg \/lut-assembly/layer-control/BUS9 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D0 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D1 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D10 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D11 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D2 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D3 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D4 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D5 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D6 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D7 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D8 ;
trireg \/lut-assembly/layer-draw-order/ROW1-D9 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D0 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D1 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D10 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D11 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D2 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D3 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D4 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D5 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D6 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D7 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D8 ;
trireg \/lut-assembly/layer-draw-order/ROW2-D9 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D0 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D1 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D10 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D11 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D2 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D3 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D4 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D5 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D6 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D7 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D8 ;
trireg \/lut-assembly/layer-draw-order/ROW3-D9 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D0 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D1 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D10 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D11 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D2 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D3 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D4 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D5 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D6 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D7 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D8 ;
trireg \/lut-assembly/layer-draw-order/ROW4-D9 ;
trireg \/lut-assembly/priority-masks/S0 ;
trireg \/lut-assembly/priority-masks/S1 ;
trireg \/lut-assembly/priority-masks/S2 ;
trireg \/lut-assembly/priority-masks/S3 ;
trireg \/lut-assembly/priority-masks/S4 ;
trireg \/lut-assembly/priority-masks/S5 ;
trireg \/lut-assembly/priority-transparency/OUT10 ;
trireg \/lut-assembly/priority-transparency/OUT6 ;
trireg \/lut-assembly/priority-transparency/OUT7 ;
trireg \/lut-assembly/priority-transparency/OUT8 ;
trireg \/lut-assembly/priority-transparency/OUT9 ;
trireg \/lut-io/A0 ;
trireg \/lut-io/A1 ;
trireg \/lut-io/A10 ;
trireg \/lut-io/A11 ;
trireg \/lut-io/A2 ;
trireg \/lut-io/A3 ;
trireg \/lut-io/A4 ;
trireg \/lut-io/A5 ;
trireg \/lut-io/A6 ;
trireg \/lut-io/A7 ;
trireg \/lut-io/A8 ;
trireg \/lut-io/A9 ;
trireg \/raster-interrupts/counter1/UK ;
trireg \/raster-interrupts/counters-bus-buffer/IN0 ;
trireg \/raster-interrupts/counters-bus-buffer/IN1 ;
trireg \/raster-interrupts/counters-bus-buffer/IN2 ;
trireg \/raster-interrupts/counters-bus-buffer/IN3 ;
trireg \/raster-interrupts/counters-bus-buffer/IN4 ;
trireg \/raster-interrupts/counters-bus-buffer/IN5 ;
trireg \/raster-interrupts/counters-bus-buffer/IN6 ;
trireg \/raster-interrupts/counters-bus-buffer/IN7 ;
trireg \/raster-interrupts/counters-bus-buffer/IN8 ;
trireg \/tilemaps/col2-assemble/GFX-A ;
trireg \/tilemaps/col2-assemble/GFX-B ;
trireg \/tilemaps/col2-assemble/GFX-C ;
trireg \/tilemaps/col2-assemble/GFX-D ;
trireg \/tilemaps/col3-assemble/GFX-A ;
trireg \/tilemaps/col3-assemble/GFX-B ;
trireg \/tilemaps/col3-assemble/GFX-C ;
trireg \/tilemaps/col3-assemble/GFX-D ;
trireg \/tilemaps/col4-assemble/GFX-A ;
trireg \/tilemaps/col4-assemble/GFX-B ;
trireg \/tilemaps/col4-assemble/GFX-C ;
trireg \/tilemaps/col4-assemble/GFX-D ;
trireg \N$/die/UBI12.13 ;
trireg \N$/die/UBI12.14 ;
trireg \N$/die/UBI12.15 ;
trireg \N$/die/UBK12.13 ;
trireg \N$/die/UBK12.14 ;
trireg \N$/die/UBK12.15 ;
trireg \N$/die/UBM12.13 ;
trireg \N$/die/UBM12.14 ;
trireg \N$/die/UBM12.15 ;
trireg \N$/die/UBN12.13 ;
trireg \N$/die/UBN12.14 ;
trireg \N$/die/UBN12.15 ;
trireg \N$/lut-assembly/lut-storage|UBE112.16 ;
trireg \N$/lut-assembly/lut-storage|UBE112.19 ;
trireg \N$/lut-assembly/lut-storage|UBE150.16 ;
trireg \N$/lut-assembly/lut-storage|UBE150.19 ;
trireg \N$/lut-assembly/lut-storage|UBF112.16 ;
trireg \N$/lut-assembly/lut-storage|UBF112.19 ;
trireg \N$/lut-assembly/lut-storage|UBF150.16 ;
trireg \N$/lut-assembly/lut-storage|UBF150.19 ;
trireg \N$/lut-assembly/lut-storage|UBH112.16 ;
trireg \N$/lut-assembly/lut-storage|UBH112.19 ;
trireg \N$/lut-assembly/lut-storage|UBH150.16 ;
trireg \N$/lut-assembly/lut-storage|UBH150.19 ;
trireg \N$/lut-assembly/lut-storage|UBI112.16 ;
trireg \N$/lut-assembly/lut-storage|UBI112.19 ;
trireg \N$/lut-assembly/lut-storage|UBI150.16 ;
trireg \N$/lut-assembly/lut-storage|UBI150.19 ;
trireg \N$/lut-assembly/lut-storage|UBK112.16 ;
trireg \N$/lut-assembly/lut-storage|UBK112.19 ;
trireg \N$/lut-assembly/lut-storage|UBK150.16 ;
trireg \N$/lut-assembly/lut-storage|UBK150.19 ;
trireg \N$/lut-assembly/lut-storage|UBM112.16 ;
trireg \N$/lut-assembly/lut-storage|UBM112.19 ;
trireg \N$/lut-assembly/lut-storage|UBM150.16 ;
trireg \N$/lut-assembly/lut-storage|UBM150.19 ;
trireg \N$/lut-assembly/lut-storage|UBN112.16 ;
trireg \N$/lut-assembly/lut-storage|UBN112.19 ;
trireg \N$/lut-assembly/lut-storage|UBN150.16 ;
trireg \N$/lut-assembly/lut-storage|UBN150.19 ;
trireg \N$/lut-assembly/priority-masks|w366 ;
trireg \N$/lut-assembly/priority-masks|w370 ;
trireg \N$/lut-assembly/priority-masks|w374 ;
trireg \N$/lut-assembly/priority-masks|w378 ;
trireg \N$/lut-assembly/priority-transparency|UBI99.13 ;
trireg \N$/lut-assembly/priority-transparency|UBK99.13 ;
trireg \N$/lut-assembly/priority-transparency|UBM99.13 ;
trireg \N$/lut-assembly/priority-transparency|UBN99.13 ;
trireg \N$/lut-counter|w80 ;
trireg \N$/lut-counter|w82 ;
trireg \N$/lut-counter|w84 ;
trireg \N$/lut-counter|w86 ;
trireg \N$/obj-manager/xpd-bus4|w109 ;
trireg \N$/obj-manager/xpd-bus4|w110 ;
trireg \N$/obj-manager/xpd-bus4|w111 ;
trireg \N$/obj-manager/xpd-bus4|w112 ;
trireg \N$/obj-manager/xpd-bus4|w113 ;
trireg \N$/obj-manager/xpd-bus4|w114 ;
trireg \N$/obj-manager/xpd-bus4|w115 ;
trireg \N$/obj-manager/xpd-bus4|w116 ;
trireg \N$/obj-manager/xpd-bus4|w117 ;
trireg \N$/obj-manager/xpd-bus4|w118 ;
trireg \N$/obj-manager/xpd-bus4|w119 ;
trireg \N$/obj-manager/xpd-bus4|w120 ;
trireg \N$/obj-manager/xpd-bus4|w121 ;
trireg \N$/obj-manager/xpd-bus4|w122 ;
trireg \N$/obj-manager/xpd-bus4|w123 ;
trireg \N$/obj-manager/xpd-bus4|w124 ;
trireg \N$/obj-manager/xpd-bus4|w125 ;
trireg \N$/obj-manager/xpd-bus4|w126 ;
trireg \N$/obj-manager/xpd-bus4|w127 ;
trireg \N$/obj-manager/xpd-bus4|w128 ;
trireg \N$/obj-manager/xpd-bus4|w129 ;
trireg \N$/obj-manager/xpd-bus4|w130 ;
trireg \N$/obj-manager/xpd-bus4|w131 ;
trireg \N$/obj-manager/xpd-bus4|w132 ;
trireg \N$/obj-manager/xpd-bus4|w133 ;
trireg \N$/obj-manager/xpd-bus4|w134 ;
trireg \N$/obj-manager/xpd-bus4|w135 ;
trireg \N$/obj-manager/xpd-bus4|w136 ;
trireg \N$/obj-manager/xpd-bus4|w137 ;
trireg \N$/obj-manager/xpd-bus4|w138 ;
trireg \N$/obj-manager/xpd-bus4|w139 ;
trireg \N$/obj-manager/xpd-bus4|w140 ;
trireg \N$/obj-manager/xpd-bus4|w141 ;
trireg \N$/obj-manager/xpd-bus4|w142 ;
trireg \N$/obj-manager/xpd-bus4|w143 ;
trireg \N$/obj-manager/xpd-bus4|w144 ;
trireg \N$/obj-manager/xpd-bus4|w145 ;
trireg \N$/obj-manager/xpd-bus4|w146 ;
trireg \N$/obj-manager/xpd-bus4|w147 ;
trireg \N$/obj-manager/xpd-bus4|w148 ;
trireg \N$/obj-manager/xpd-bus4|w149 ;
trireg \N$/obj-manager/xpd-bus4|w150 ;
trireg \N$/obj-manager/xpd-bus4|w151 ;
trireg \N$/obj-manager/xpd-bus4|w152 ;
trireg \N$/obj-manager/xpd-bus4|w153 ;
trireg \N$/obj-manager/xpd-bus4|w154 ;
trireg \N$/obj-manager/xpd-bus4|w155 ;
trireg \N$/obj-manager/xpd-bus4|w156 ;
trireg \N$/obj-manager/xpd-bus4|w157 ;
trireg \N$/obj-manager/xpd-bus4|w158 ;
trireg \N$/obj-manager/xpd-bus4|w159 ;
trireg \N$/obj-manager/xpd-bus4|w160 ;
trireg \N$/obj-manager/xpd-bus4|w161 ;
trireg \N$/obj-manager/xpd-bus4|w162 ;
trireg \N$/obj-manager/xpd-bus4|w163 ;
trireg \N$/obj-manager/xpd-bus4|w164 ;
trireg \N$/obj-manager/xpd-bus4|w165 ;
trireg \N$/obj-manager/xpd-bus4|w166 ;
trireg \N$/obj-manager/xpd-bus4|w167 ;
trireg \N$/obj-manager/xpd-bus4|w168 ;
trireg \N$/obj-manager/xpd-bus4|w169 ;
trireg \N$/obj-manager/xpd-bus4|w170 ;
trireg \N$/obj-manager/xpd-bus4|w171 ;
trireg \N$/obj-manager/xpd-bus4|w172 ;
trireg \N$/raster-interrupts|UBR325.18 ;
trireg \N$/security-management/security-decoder|UBR194.11 ;
trireg \N$/stars/counter-xs-1|w60 ;
trireg \N$/stars/counter-xs-1|w62 ;
trireg \N$/stars/counter-xs-1|w64 ;
trireg \N$/stars/counter-xs-1|w66 ;
trireg \N$/stars/counter-xs-1|w68 ;
trireg \N$/stars/counter-xs-1|w70 ;
trireg \N$/stars/counter-xs-1|w72 ;
trireg \N$/stars/counter-xs-1|w74 ;
trireg \N$/stars/counter-xs-2|w61 ;
trireg \N$/stars/counter-xs-2|w63 ;
trireg \N$/stars/counter-xs-2|w65 ;
trireg \N$/stars/counter-xs-2|w67 ;
trireg \N$/stars/counter-xs-2|w69 ;
trireg \N$/stars/counter-xs-2|w71 ;
trireg \N$/stars/counter-xs-2|w73 ;
trireg \N$/stars/counter-xs-2|w75 ;
trireg \N$/stars/xpd5-sync|w54 ;
trireg \N$/stars/xpd5-sync|w56 ;
trireg \N$/stars/xpd5-sync|w59 ;
trireg \N$/stars/xpd5-sync|w61 ;
trireg \N$/stars/xpd5-sync|w63 ;
trireg \N$/stars/xpd5-sync|w65 ;
trireg \N$/stars/xpd5-sync|w67 ;
trireg \N$/stars/xpd5-sync|w69 ;
trireg \N$/stars/xpd6-sync|w54 ;
trireg \N$/stars/xpd6-sync|w56 ;
trireg \N$/stars/xpd6-sync|w59 ;
trireg \N$/stars/xpd6-sync|w61 ;
trireg \N$/stars/xpd6-sync|w63 ;
trireg \N$/stars/xpd6-sync|w65 ;
trireg \N$/stars/xpd6-sync|w67 ;
trireg \N$/stars/xpd6-sync|w69 ;
trireg \N$/tilemaps/cb-bus1|w103 ;
trireg \N$/tilemaps/cb-bus1|w105 ;
trireg \N$/tilemaps/cb-bus1|w108 ;
trireg \N$/tilemaps/cb-bus1|w110 ;
trireg \N$/tilemaps/cb-bus1|w113 ;
trireg \N$/tilemaps/cb-bus1|w119 ;
trireg \N$/tilemaps/cb-bus1|w124 ;
trireg \N$/tilemaps/cb-bus1|w130 ;
trireg \N$/tilemaps/cb-bus1|w133 ;
trireg \N$/tilemaps/cb-bus1|w136 ;
trireg \N$/tilemaps/cb-bus1|w138 ;
trireg \N$/tilemaps/cb-bus1|w141 ;
trireg \N$/tilemaps/cb-bus1|w143 ;
trireg \N$/tilemaps/cb-bus1|w148 ;
trireg \N$/tilemaps/cb-bus1|w160 ;
trireg \N$/tilemaps/cb-bus1|w162 ;
trireg \N$/tilemaps/sr1|UAR1.5 ;
trireg \N$/tilemaps/sr1|UAS40.5 ;
trireg \N$/tilemaps/sr1|UAT1.5 ;
trireg \N$/tilemaps/sr1|UAU40.5 ;
trireg \N$/tilemaps/sr1|UAV1.5 ;
trireg \N$/tilemaps/sr1|UAX40.5 ;
trireg \N$/tilemaps/sr1|UAY1.5 ;
trireg \N$/tilemaps/sr1|UAZ40.5 ;
trireg \N$/tilemaps/sr2|UAR167.5 ;
trireg \N$/tilemaps/sr2|UAS128.5 ;
trireg \N$/tilemaps/sr2|UAT167.5 ;
trireg \N$/tilemaps/sr2|UAU128.5 ;
trireg \N$/tilemaps/sr2|UAV167.5 ;
trireg \N$/tilemaps/sr2|UAX128.5 ;
trireg \N$/tilemaps/sr2|UAY167.5 ;
trireg \N$/tilemaps/sr2|UAZ129.5 ;
trireg \N$/tilemaps/sr3|UAR208.5 ;
trireg \N$/tilemaps/sr3|UAS247.5 ;
trireg \N$/tilemaps/sr3|UAT208.5 ;
trireg \N$/tilemaps/sr3|UAU247.5 ;
trireg \N$/tilemaps/sr3|UAV208.5 ;
trireg \N$/tilemaps/sr3|UAX247.5 ;
trireg \N$/tilemaps/sr3|UAY208.5 ;
trireg \N$/tilemaps/sr3|UAZ247.5 ;
trireg \N$/tilemaps/xpd-bus1|w101 ;
trireg \N$/tilemaps/xpd-bus1|w102 ;
trireg \N$/tilemaps/xpd-bus1|w103 ;
trireg \N$/tilemaps/xpd-bus1|w104 ;
trireg \N$/tilemaps/xpd-bus1|w105 ;
trireg \N$/tilemaps/xpd-bus1|w106 ;
trireg \N$/tilemaps/xpd-bus1|w107 ;
trireg \N$/tilemaps/xpd-bus1|w108 ;
trireg \N$/tilemaps/xpd-bus1|w109 ;
trireg \N$/tilemaps/xpd-bus1|w110 ;
trireg \N$/tilemaps/xpd-bus1|w111 ;
trireg \N$/tilemaps/xpd-bus1|w112 ;
trireg \N$/tilemaps/xpd-bus1|w113 ;
trireg \N$/tilemaps/xpd-bus1|w114 ;
trireg \N$/tilemaps/xpd-bus1|w115 ;
trireg \N$/tilemaps/xpd-bus1|w116 ;
trireg \N$/tilemaps/xpd-bus1|w117 ;
trireg \N$/tilemaps/xpd-bus1|w118 ;
trireg \N$/tilemaps/xpd-bus1|w119 ;
trireg \N$/tilemaps/xpd-bus1|w120 ;
trireg \N$/tilemaps/xpd-bus1|w121 ;
trireg \N$/tilemaps/xpd-bus1|w122 ;
trireg \N$/tilemaps/xpd-bus1|w123 ;
trireg \N$/tilemaps/xpd-bus1|w124 ;
trireg \N$/tilemaps/xpd-bus1|w125 ;
trireg \N$/tilemaps/xpd-bus1|w126 ;
trireg \N$/tilemaps/xpd-bus1|w127 ;
trireg \N$/tilemaps/xpd-bus1|w128 ;
trireg \N$/tilemaps/xpd-bus1|w129 ;
trireg \N$/tilemaps/xpd-bus1|w130 ;
trireg \N$/tilemaps/xpd-bus1|w131 ;
trireg \N$/tilemaps/xpd-bus1|w132 ;
trireg \N$/tilemaps/xpd-bus1|w133 ;
trireg \N$/tilemaps/xpd-bus1|w134 ;
trireg \N$/tilemaps/xpd-bus1|w135 ;
trireg \N$/tilemaps/xpd-bus1|w136 ;
trireg \N$/tilemaps/xpd-bus1|w137 ;
trireg \N$/tilemaps/xpd-bus1|w138 ;
trireg \N$/tilemaps/xpd-bus1|w139 ;
trireg \N$/tilemaps/xpd-bus1|w140 ;
trireg \N$/tilemaps/xpd-bus1|w141 ;
trireg \N$/tilemaps/xpd-bus1|w142 ;
trireg \N$/tilemaps/xpd-bus1|w143 ;
trireg \N$/tilemaps/xpd-bus1|w144 ;
trireg \N$/tilemaps/xpd-bus1|w145 ;
trireg \N$/tilemaps/xpd-bus1|w146 ;
trireg \N$/tilemaps/xpd-bus1|w147 ;
trireg \N$/tilemaps/xpd-bus1|w148 ;
trireg \N$/tilemaps/xpd-bus1|w149 ;
trireg \N$/tilemaps/xpd-bus1|w150 ;
trireg \N$/tilemaps/xpd-bus1|w151 ;
trireg \N$/tilemaps/xpd-bus1|w152 ;
trireg \N$/tilemaps/xpd-bus1|w153 ;
trireg \N$/tilemaps/xpd-bus1|w154 ;
trireg \N$/tilemaps/xpd-bus1|w155 ;
trireg \N$/tilemaps/xpd-bus1|w156 ;
trireg \N$/tilemaps/xpd-bus1|w157 ;
trireg \N$/tilemaps/xpd-bus1|w158 ;
trireg \N$/tilemaps/xpd-bus1|w159 ;
trireg \N$/tilemaps/xpd-bus1|w160 ;
trireg \N$/tilemaps/xpd-bus1|w161 ;
trireg \N$/tilemaps/xpd-bus1|w162 ;
trireg \N$/tilemaps/xpd-bus1|w163 ;
trireg \N$/tilemaps/xpd-bus1|w164 ;
trireg \N$/tilemaps/xpd-bus2|w101 ;
trireg \N$/tilemaps/xpd-bus2|w102 ;
trireg \N$/tilemaps/xpd-bus2|w103 ;
trireg \N$/tilemaps/xpd-bus2|w104 ;
trireg \N$/tilemaps/xpd-bus2|w105 ;
trireg \N$/tilemaps/xpd-bus2|w106 ;
trireg \N$/tilemaps/xpd-bus2|w107 ;
trireg \N$/tilemaps/xpd-bus2|w108 ;
trireg \N$/tilemaps/xpd-bus2|w109 ;
trireg \N$/tilemaps/xpd-bus2|w110 ;
trireg \N$/tilemaps/xpd-bus2|w111 ;
trireg \N$/tilemaps/xpd-bus2|w112 ;
trireg \N$/tilemaps/xpd-bus2|w113 ;
trireg \N$/tilemaps/xpd-bus2|w114 ;
trireg \N$/tilemaps/xpd-bus2|w115 ;
trireg \N$/tilemaps/xpd-bus2|w116 ;
trireg \N$/tilemaps/xpd-bus2|w117 ;
trireg \N$/tilemaps/xpd-bus2|w118 ;
trireg \N$/tilemaps/xpd-bus2|w119 ;
trireg \N$/tilemaps/xpd-bus2|w120 ;
trireg \N$/tilemaps/xpd-bus2|w121 ;
trireg \N$/tilemaps/xpd-bus2|w122 ;
trireg \N$/tilemaps/xpd-bus2|w123 ;
trireg \N$/tilemaps/xpd-bus2|w124 ;
trireg \N$/tilemaps/xpd-bus2|w125 ;
trireg \N$/tilemaps/xpd-bus2|w126 ;
trireg \N$/tilemaps/xpd-bus2|w127 ;
trireg \N$/tilemaps/xpd-bus2|w128 ;
trireg \N$/tilemaps/xpd-bus2|w129 ;
trireg \N$/tilemaps/xpd-bus2|w130 ;
trireg \N$/tilemaps/xpd-bus2|w131 ;
trireg \N$/tilemaps/xpd-bus2|w132 ;
trireg \N$/tilemaps/xpd-bus2|w133 ;
trireg \N$/tilemaps/xpd-bus2|w134 ;
trireg \N$/tilemaps/xpd-bus2|w135 ;
trireg \N$/tilemaps/xpd-bus2|w136 ;
trireg \N$/tilemaps/xpd-bus2|w137 ;
trireg \N$/tilemaps/xpd-bus2|w138 ;
trireg \N$/tilemaps/xpd-bus2|w139 ;
trireg \N$/tilemaps/xpd-bus2|w140 ;
trireg \N$/tilemaps/xpd-bus2|w141 ;
trireg \N$/tilemaps/xpd-bus2|w142 ;
trireg \N$/tilemaps/xpd-bus2|w143 ;
trireg \N$/tilemaps/xpd-bus2|w144 ;
trireg \N$/tilemaps/xpd-bus2|w145 ;
trireg \N$/tilemaps/xpd-bus2|w146 ;
trireg \N$/tilemaps/xpd-bus2|w147 ;
trireg \N$/tilemaps/xpd-bus2|w148 ;
trireg \N$/tilemaps/xpd-bus2|w149 ;
trireg \N$/tilemaps/xpd-bus2|w150 ;
trireg \N$/tilemaps/xpd-bus2|w151 ;
trireg \N$/tilemaps/xpd-bus2|w152 ;
trireg \N$/tilemaps/xpd-bus2|w153 ;
trireg \N$/tilemaps/xpd-bus2|w154 ;
trireg \N$/tilemaps/xpd-bus2|w155 ;
trireg \N$/tilemaps/xpd-bus2|w156 ;
trireg \N$/tilemaps/xpd-bus2|w157 ;
trireg \N$/tilemaps/xpd-bus2|w158 ;
trireg \N$/tilemaps/xpd-bus2|w159 ;
trireg \N$/tilemaps/xpd-bus2|w160 ;
trireg \N$/tilemaps/xpd-bus2|w161 ;
trireg \N$/tilemaps/xpd-bus2|w162 ;
trireg \N$/tilemaps/xpd-bus2|w163 ;
trireg \N$/tilemaps/xpd-bus2|w164 ;
trireg \N$/tilemaps/xpd-bus3|w100 ;
trireg \N$/tilemaps/xpd-bus3|w101 ;
trireg \N$/tilemaps/xpd-bus3|w102 ;
trireg \N$/tilemaps/xpd-bus3|w103 ;
trireg \N$/tilemaps/xpd-bus3|w104 ;
trireg \N$/tilemaps/xpd-bus3|w105 ;
trireg \N$/tilemaps/xpd-bus3|w106 ;
trireg \N$/tilemaps/xpd-bus3|w107 ;
trireg \N$/tilemaps/xpd-bus3|w108 ;
trireg \N$/tilemaps/xpd-bus3|w109 ;
trireg \N$/tilemaps/xpd-bus3|w110 ;
trireg \N$/tilemaps/xpd-bus3|w111 ;
trireg \N$/tilemaps/xpd-bus3|w112 ;
trireg \N$/tilemaps/xpd-bus3|w113 ;
trireg \N$/tilemaps/xpd-bus3|w114 ;
trireg \N$/tilemaps/xpd-bus3|w115 ;
trireg \N$/tilemaps/xpd-bus3|w116 ;
trireg \N$/tilemaps/xpd-bus3|w117 ;
trireg \N$/tilemaps/xpd-bus3|w118 ;
trireg \N$/tilemaps/xpd-bus3|w119 ;
trireg \N$/tilemaps/xpd-bus3|w120 ;
trireg \N$/tilemaps/xpd-bus3|w121 ;
trireg \N$/tilemaps/xpd-bus3|w122 ;
trireg \N$/tilemaps/xpd-bus3|w123 ;
trireg \N$/tilemaps/xpd-bus3|w124 ;
trireg \N$/tilemaps/xpd-bus3|w93 ;
trireg \N$/tilemaps/xpd-bus3|w94 ;
trireg \N$/tilemaps/xpd-bus3|w95 ;
trireg \N$/tilemaps/xpd-bus3|w96 ;
trireg \N$/tilemaps/xpd-bus3|w97 ;
trireg \N$/tilemaps/xpd-bus3|w98 ;
trireg \N$/tilemaps/xpd-bus3|w99 ;

//========================================================================
// Pads:
//========================================================================
tran (P1_XSEL, \/obj-manager/XSEL );
tran (P2_XS0, \/XS0 );
tran (P3_XS1, \/XS1 );
tran (P4_XS2, \/XS2 );
tran (P5_XS3, \/XS3 );
tran (P6_XS4, \/XS4 );
tran (P7__ROMOE, \/xpd-out/~ROMOE );
tran (P8_VCC, VCC);
tran (P9_TD0, \/debug/td-io/OUT0 );
tran (P10_TD1, \/debug/td-io/OUT1 );
tran (P11_TD2, \/debug/td-io/OUT2 );
tran (P12_TD3, \/debug/td-io/OUT3 );
tran (P13_TD4, \/debug/td-io/OUT4 );
tran (P14_TD5, \/debug/td-io/OUT5 );
tran (P15_TD6, \/debug/td-io/OUT6 );
tran (P16_TD7, \/debug/td-io/OUT7 );
tran (P17_TD8, \/debug/td-io/OUT8 );
tran (P18_TD9, \/debug/td-io/OUT9 );
tran (P19_TD10, \/debug/td-io/OUT10 );
tran (P20_TD11, \/debug/td-io/OUT11 );
tran (P21_GND, GND);
tran (P22_ASD0, \/ASD0 );
tran (P23_ASD1, \/ASD1 );
tran (P24_ASD2, \/ASD2 );
tran (P25_ASD3, \/ASD3 );
tran (P26_ASD4, \/ASD4 );
tran (P27_ASD5, \/ASD5 );
tran (P28_ASD6, \/ASD6 );
tran (P29_ASD7, \/ASD7 );
tran (P30_ASD8, \/ASD8 );
tran (P31_BSD0, \/BSD0 );
tran (P32_BSD1, \/BSD1 );
tran (P33_BSD2, \/BSD2 );
tran (P34_BSD3, \/BSD3 );
tran (P35_BSD4, \/BSD4 );
tran (P36_BSD5, \/BSD5 );
tran (P37_BSD6, \/BSD6 );
tran (P38_BSD7, \/BSD7 );
tran (P39_BSD8, \/BSD8 );
tran (P40_VBAT, \/security-management/VBAT );
tran (P41_GND, GND);
tran (P42_SEC_STROBE, \/security-management/keyinject/S1-STROBE );
tran (P43_SEC__E1, \/security-management/keyinject/~E1 );
tran (P44_SEC_E2, \/security-management/keyinject/E2 );
tran (P45_SEC_MODE0, \/main-signals/SEC-MODE0 );
tran (P46_SEC_MODE1, \/main-signals/SEC-MODE1 );
tran (P47_GND, GND);
tran (P48_FAD0, \/FAD0 );
tran (P49_FAD1, \/FAD1 );
tran (P50_FAD2, \/FAD2 );
tran (P51_FAD3, \/FAD3 );
tran (P52_FBD0, \/FBD0 );
tran (P53_FBD1, \/FBD1 );
tran (P54_FBD2, \/FBD2 );
tran (P55_FBD3, \/FBD3 );
tran (P56_OBJEO, \/obj-manager/OBJEO );
tran (P57__OBJUP, \/raster-interrupts/~OBJUP );
tran (P58_FRAME, \/obj-manager/FRAME );
tran (P59__REWEN, \/obj-manager/~REWEN );
tran (P60_VCC, VCC);
tran (P61_CD0, \/security-management/SEC-DATA );
tran (P62_CD1, \/security-management/SEC-CLK );
tran (P63_CD2, \/CD2 );
tran (P64_CD3, \/CD3 );
tran (P65_CD4, \/CD4 );
tran (P66_CD5, \/CD5 );
tran (P67_CD6, \/CD6 );
tran (P68_CD7, \/CD7 );
tran (P69_CD8, \/CD8 );
tran (P70_CD9, \/CD9 );
tran (P71_CD10, \/CD10 );
tran (P72_CD11, \/CD11 );
tran (P73_CD12, \/CD12 );
tran (P74_CD13, \/CD13 );
tran (P75_CD14, \/CD14 );
tran (P76_CD15, \/CD15 );
tran (P77_GND, GND);
tran (P78_CA1, \/CA1 );
tran (P79_CA2, \/CA2 );
tran (P80_CA3, \/CA3 );
tran (P81_CA4, \/CA4 );
tran (P82_CA5, \/CA5 );
tran (P83__CS, \/bus-signal-control/~CS );
tran (P84__RD, \/bus-signal-control/~RD );
tran (P85__WR, \/bus-signal-control/~WR );
tran (P86__WSTROM, \/bus-signal-control/~WSTROM );
tran (P87_LUTPRO, \/palette-control/LUTPRO );
tran (P88_WSTLUT, \/palette-control/WSTLUT );
tran (P89_LUTA0, \/LUT0 );
tran (P90_LUTA1, \/LUT1 );
tran (P91_LUTA2, \/LUT2 );
tran (P92_LUTA3, \/LUT3 );
tran (P93_LUTA4, \/LUT4 );
tran (P94_LUTA5, \/LUT5 );
tran (P95_LUTA6, \/LUT6 );
tran (P96_LUTA7, \/LUT7 );
tran (P97_LUTA8, \/LUT8 );
tran (P98_LUTA9, \/LUT9 );
tran (P99_LUTA10, \/LUT10 );
tran (P100_LUTA11, \/LUT11 );
tran (P101__LUTOE, \N$|UBR508.2 );
tran (P102__LUTWR, \/palette-control/~LUT-WR );
tran (P103__RESETI, \/main-signals/~RESETI );
tran (P104__CLK8M, \/main-signals/~CLK8M );
tran (P105_VCC, VCC);
tran (P106__CK10, \/bus-signal-control/~CK10 );
tran (P107_TI0, \/TI0 );
tran (P108__CK500, \/bus-signal-control/~CK500 );
tran (P109_TI1, \/TI1 );
tran (P110_CLK, \/main-signals/CLK16M );
tran (P111_TI2, \/TI2 );
tran (P112_TI3, \/TI3 );
tran (P113_FI, \/counter-fi/FI );
tran (P114_LI, \/main-signals/LI );
tran (P115_FLIP, \/stars/FLIP );
tran (P116_HSYNC, \/video-signals/HSYNC );
tran (P117__HBLANK, \/video-signals/~HBLANK );
tran (P118_VSYNC, \/video-signals/VSYNC );
tran (P119__VBLANK, \/video-signals/~VBLANK );
tran (P120_GND, GND);
tran (P121_APD0, \/APD0 );
tran (P122_APD1, \/APD1 );
tran (P123_APD2, \/APD2 );
tran (P124_APD3, \/APD3 );
tran (P125_APD4, \/APD4 );
tran (P126_APD5, \/APD5 );
tran (P127_APD6, \/APD6 );
tran (P128_APD7, \/APD7 );
tran (P129_BPD0, \/BPD0 );
tran (P130_BPD1, \/BPD1 );
tran (P131_BPD2, \/BPD2 );
tran (P132_BPD3, \/BPD3 );
tran (P133_BPD4, \/BPD4 );
tran (P134_BPD5, \/BPD5 );
tran (P135_BPD6, \/BPD6 );
tran (P136_BPD7, \/BPD7 );
tran (P137_CPD0, \/CPD0 );
tran (P138_CPD1, \/CPD1 );
tran (P139_CPD2, \/CPD2 );
tran (P140_CPD3, \/CPD3 );
tran (P141_CPD4, \/CPD4 );
tran (P142_CPD5, \/CPD5 );
tran (P143_CPD6, \/CPD6 );
tran (P144_CPD7, \/CPD7 );
tran (P145_DPD0, \/DPD0 );
tran (P146_DPD1, \/DPD1 );
tran (P147_DPD2, \/DPD2 );
tran (P148_DPD3, \/DPD3 );
tran (P149_DPD4, \/DPD4 );
tran (P150_DPD5, \/DPD5 );
tran (P151_DPD6, \/DPD6 );
tran (P152_DPD7, \/DPD7 );
tran (P153_CB0, \/CB0 );
tran (P154_CB1, \/CB1 );
tran (P155_CB2, \/CB2 );
tran (P156_CB3, \/CB3 );
tran (P157_CB4, \/CB4 );
tran (P158_CPC0, \/CPC0 );
tran (P159_CPC1, \/CPC1 );
tran (P160_CDEN, \/tilemaps/CDEN );

//========================================================================
// top:
//========================================================================
capcom_dl0921_BUF12 UBR508 (
    .p1 ( \/lut-counter/~LOAD ),
    .p2 ( \N$|UBR508.2        )
);

//========================================================================
// bus-io:
//========================================================================
capcom_dl0921_M368C bus_io_UCG174 (
    .p1  ( \N$/bus-io|w172                             ),
    .p2  ( \N$/bus-io|w131                             ),
    .p3  ( \N$/bus-io|w132                             ),
    .p4  ( \N$/bus-io|w133                             ),
    .p5  ( \N$/bus-io|w134                             ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN0 )
);

capcom_dl0921_M368C bus_io_UCG239 (
    .p1  ( \N$/bus-io|w172                             ),
    .p2  ( \N$/bus-io|w163                             ),
    .p3  ( \N$/bus-io|w158                             ),
    .p4  ( \N$/bus-io|w153                             ),
    .p5  ( \N$/bus-io|w148                             ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN4 )
);

capcom_dl0921_INV01 bus_io_UCG291 (
    .p1 ( \/raster-interrupts/counter1/RD ),
    .p2 ( \N$/bus-io|w172                 )
);

capcom_dl0921_L8L bus_io_UCJ233 (
    .p1  ( \/security-management/addr-decoder/LE ),
    .p2  ( \/CD7                                 ),
    .p3  ( \N$/bus-io|w148                       ),
    .p4  ( \/CD6                                 ),
    .p5  ( \N$/bus-io|w153                       ),
    .p6  ( \/CD5                                 ),
    .p7  ( \N$/bus-io|w158                       ),
    .p8  ( \/CD4                                 ),
    .p9  ( \N$/bus-io|w163                       ),
    .p10 ( \/CD3                                 ),
    .p11 ( \N$/bus-io|w134                       ),
    .p12 ( \/CD2                                 ),
    .p13 ( \N$/bus-io|w133                       ),
    .p14 ( \/security-management/SEC-CLK         ),
    .p15 ( \N$/bus-io|w132                       ),
    .p16 ( \/security-management/SEC-DATA        ),
    .p17 ( \N$/bus-io|w131                       )
);

capcom_dl0921_M368C bus_io_UCL235 (
    .p1  ( \N$/bus-io|w172                             ),
    .p2  ( \N$/bus-io|w137                             ),
    .p3  ( \N$/bus-io|w138                             ),
    .p4  ( \N$/bus-io|w139                             ),
    .p5  ( \N$/bus-io|w140                             ),
    .p15 ( \/lut-assembly/layer-control/BUS11          ),
    .p16 ( \/lut-assembly/layer-control/BUS10          ),
    .p17 ( \/lut-assembly/layer-control/BUS9           ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN8 )
);

capcom_dl0921_M368C bus_io_UCL292 (
    .p1  ( \N$/bus-io|w172                    ),
    .p2  ( \N$/bus-io|w165                    ),
    .p3  ( \N$/bus-io|w161                    ),
    .p4  ( \N$/bus-io|w155                    ),
    .p5  ( \N$/bus-io|w151                    ),
    .p15 ( \/raster-interrupts/counter1/UK    ),
    .p16 ( \/cps-id/DATA14                    ),
    .p17 ( \/lut-assembly/layer-control/BUS13 ),
    .p18 ( \/lut-assembly/layer-control/BUS12 )
);

capcom_dl0921_L8L bus_io_UCO293 (
    .p1  ( \/security-management/addr-decoder/LE ),
    .p2  ( \/CD15                                ),
    .p3  ( \N$/bus-io|w151                       ),
    .p4  ( \/CD14                                ),
    .p5  ( \N$/bus-io|w155                       ),
    .p6  ( \/CD13                                ),
    .p7  ( \N$/bus-io|w161                       ),
    .p8  ( \/CD12                                ),
    .p9  ( \N$/bus-io|w165                       ),
    .p10 ( \/CD11                                ),
    .p11 ( \N$/bus-io|w140                       ),
    .p12 ( \/CD10                                ),
    .p13 ( \N$/bus-io|w139                       ),
    .p14 ( \/CD9                                 ),
    .p15 ( \N$/bus-io|w138                       ),
    .p16 ( \/CD8                                 ),
    .p17 ( \N$/bus-io|w137                       )
);

capcom_dl0921_OR02 bus_io_UCR298 (
    .p1 ( \/bus-io/MUTE-OUT               ),
    .p2 ( \/raster-interrupts/counter1/RD ),
    .p3 ( \N$/bus-io|w64                  )
);

capcom_dl0921_OUTTRI bus_io_UCR427 (
    .p1 ( \N$/bus-io|w64                     ),
    .p2 ( \/lut-assembly/layer-control/BUS12 ),
    .p3 ( \/CD12                             )
);

capcom_dl0921_OUTTRI bus_io_UCR446 (
    .p1 ( \N$/bus-io|w64                     ),
    .p2 ( \/lut-assembly/layer-control/BUS13 ),
    .p3 ( \/CD13                             )
);

capcom_dl0921_OUTTRI bus_io_UCT292 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p3 ( \/security-management/SEC-DATA              )
);

capcom_dl0921_OUTTRI bus_io_UCT296 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p3 ( \/security-management/SEC-CLK               )
);

capcom_dl0921_OUTTRI bus_io_UCT301 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p3 ( \/CD2                                       )
);

capcom_dl0921_OUTTRI bus_io_UCT305 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p3 ( \/CD3                                       )
);

capcom_dl0921_OUTTRI bus_io_UCT317 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p3 ( \/CD4                                       )
);

capcom_dl0921_OUTTRI bus_io_UCT331 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p3 ( \/CD5                                       )
);

capcom_dl0921_OUTTRI bus_io_UCT346 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p3 ( \/CD6                                       )
);

capcom_dl0921_OUTTRI bus_io_UCT359 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p3 ( \/CD7                                       )
);

capcom_dl0921_OUTTRI bus_io_UCT383 (
    .p1 ( \N$/bus-io|w64                              ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p3 ( \/CD8                                       )
);

capcom_dl0921_OUTTRI bus_io_UCT389 (
    .p1 ( \N$/bus-io|w64                    ),
    .p2 ( \/lut-assembly/layer-control/BUS9 ),
    .p3 ( \/CD9                             )
);

capcom_dl0921_OUTTRI bus_io_UCT399 (
    .p1 ( \N$/bus-io|w64                     ),
    .p2 ( \/lut-assembly/layer-control/BUS10 ),
    .p3 ( \/CD10                             )
);

capcom_dl0921_OUTTRI bus_io_UCT432 (
    .p1 ( \N$/bus-io|w64                     ),
    .p2 ( \/lut-assembly/layer-control/BUS11 ),
    .p3 ( \/CD11                             )
);

capcom_dl0921_OUTTRI bus_io_UCT447 (
    .p1 ( \N$/bus-io|w64  ),
    .p2 ( \/cps-id/DATA14 ),
    .p3 ( \/CD14          )
);

capcom_dl0921_OUTTRI bus_io_UCT452 (
    .p1 ( \N$/bus-io|w64                  ),
    .p2 ( \/raster-interrupts/counter1/UK ),
    .p3 ( \/CD15                          )
);

//========================================================================
// bus-signal-control:
//========================================================================
capcom_dl0921_M273C bus_signal_control_UAA423 (
    .p1  ( \/cps-id/~RESET                  ),
    .p2  ( \/xpd-out/OUT0                   ),
    .p3  ( \N$/bus-signal-control|UBD415.17 ),
    .p4  ( \N$/bus-signal-control|UBD415.18 ),
    .p5  ( \/xpd-out/OUT1                   ),
    .p6  ( \/xpd-out/OUT2                   ),
    .p7  ( \N$/bus-signal-control|UBD415.19 ),
    .p8  ( \N$/bus-signal-control|UBD415.20 ),
    .p9  ( \/xpd-out/OUT3                   ),
    .p11 ( \N$/bus-signal-control|w83       ),
    .p12 ( \/xpd-out/OUT4                   ),
    .p13 ( \N$/bus-signal-control|UBD415.22 ),
    .p14 ( \N$/bus-signal-control|UBD415.23 ),
    .p15 ( \/xpd-out/OUT5                   ),
    .p16 ( \/xpd-out/OUT6                   ),
    .p17 ( \N$/bus-signal-control|UBD415.21 ),
    .p18 ( \N$/bus-signal-control|UBD415.24 ),
    .p19 ( \/xpd-out/OUT7                   )
);

capcom_dl0921_MUX28H bus_signal_control_UBD415 (
    .p1  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p5  ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p6  ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p7  ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p9  ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p10 ( \/lut-assembly/layer-control/BUS9           ),
    .p11 ( \/lut-assembly/layer-control/BUS10          ),
    .p12 ( \/lut-assembly/layer-control/BUS11          ),
    .p13 ( \/cps-id/DATA14                             ),
    .p14 ( \/lut-assembly/layer-control/BUS12          ),
    .p15 ( \/raster-interrupts/counter1/UK             ),
    .p16 ( \/lut-assembly/layer-control/BUS13          ),
    .p17 ( \N$/bus-signal-control|UBD415.17            ),
    .p18 ( \N$/bus-signal-control|UBD415.18            ),
    .p19 ( \N$/bus-signal-control|UBD415.19            ),
    .p20 ( \N$/bus-signal-control|UBD415.20            ),
    .p21 ( \N$/bus-signal-control|UBD415.21            ),
    .p22 ( \N$/bus-signal-control|UBD415.22            ),
    .p23 ( \N$/bus-signal-control|UBD415.23            ),
    .p24 ( \N$/bus-signal-control|UBD415.24            ),
    .p25 ( \N$/bus-signal-control|w95                  )
);

capcom_dl0921_DFFCOR bus_signal_control_UBD451 (
    .p1 ( \N$/bus-signal-control|w83   ),
    .p2 ( \/bus-signal-control/~WSTROM ),
    .p3 ( \N$/bus-signal-control|w29   ),
    .p4 ( \/cps-id/~RESET              ),
    .p5 ( \N$/bus-signal-control|w13   )
);

capcom_dl0921_DFFCOR bus_signal_control_UBD456 (
    .p1 ( \N$/bus-signal-control|w83      ),
    .p2 ( \N$/bus-signal-control|w29      ),
    .p3 ( \/xpd-out/~OE                   ),
    .p4 ( \/cps-id/~RESET                 ),
    .p5 ( \N$/bus-signal-control|UBD456.5 )
);

capcom_dl0921_DFFCOR bus_signal_control_UBD460 (
    .p1 ( \N$/bus-signal-control|w83        ),
    .p2 ( \/bus-signal-control/GFX-OUT-LMSB ),
    .p3 ( \N$/bus-signal-control|w95        ),
    .p4 ( \/cps-id/~RESET                   ),
    .p5 ( \N$/bus-signal-control|UBD460.5   )
);

capcom_dl0921_DFFCOR bus_signal_control_UBD464 (
    .p1 ( \N$/bus-signal-control|w83      ),
    .p2 ( \N$/bus-signal-control|w95      ),
    .p3 ( \N$/bus-signal-control|w93      ),
    .p4 ( \/cps-id/~RESET                 ),
    .p5 ( \N$/bus-signal-control|UBD464.5 )
);

capcom_dl0921_BUF12 bus_signal_control_UBD471 (
    .p1 ( \/bus-signal-control/GFX-CHNL ),
    .p2 ( \/bus-signal-control/~CK500   )
);

capcom_dl0921_BUF12 bus_signal_control_UBD474 (
    .p1 ( \N$/bus-signal-control|w93      ),
    .p2 ( \N$/bus-signal-control|UBD521.1 )
);

capcom_dl0921_BUF12 bus_signal_control_UBD521 (
    .p1 ( \N$/bus-signal-control|UBD521.1 ),
    .p2 ( \/bus-signal-control/~CK10      )
);

capcom_dl0921_DFFCOR bus_signal_control_UBK439 (
    .p1 ( \N$/bus-signal-control|w83      ),
    .p2 ( \N$/bus-signal-control|w46      ),
    .p3 ( \N$/bus-signal-control|UBK439.3 ),
    .p4 ( \/cps-id/~RESET                 ),
    .p5 ( \N$/bus-signal-control|w63      )
);

capcom_dl0921_NBUF03 bus_signal_control_UBN376 (
    .p1 ( \N$/bus-signal-control|w16      ),
    .p2 ( \/raster-interrupts/counter1/RD )
);

capcom_dl0921_BUF12 bus_signal_control_UBN383 (
    .p1 ( \N$/bus-signal-control|w63      ),
    .p2 ( \/lut-assembly/layer-control/WR )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391 (
    .p1 ( \N$/bus-signal-control|w63 ),
    .p2 ( \N$/die/UBN391.c1          )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391_u2 (
    .p1 ( \N$/die/UBN391.c1 ),
    .p2 ( \N$/die/UBN391.c2 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391_u3 (
    .p1 ( \N$/die/UBN391.c2 ),
    .p2 ( \N$/die/UBN391.c3 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391_u4 (
    .p1 ( \N$/die/UBN391.c3 ),
    .p2 ( \N$/die/UBN391.c4 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391_u5 (
    .p1 ( \N$/die/UBN391.c4 ),
    .p2 ( \N$/die/UBN391.c5 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391_u6 (
    .p1 ( \N$/die/UBN391.c5 ),
    .p2 ( \N$/die/UBN391.c6 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391_u7 (
    .p1 ( \N$/die/UBN391.c6 ),
    .p2 ( \N$/die/UBN391.c7 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN391_u8 (
    .p1 ( \N$/die/UBN391.c7               ),
    .p2 ( \N$/bus-signal-control|UBN418.1 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418 (
    .p1 ( \N$/bus-signal-control|UBN418.1 ),
    .p2 ( \N$/die/UBN418.c1               )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418_u2 (
    .p1 ( \N$/die/UBN418.c1 ),
    .p2 ( \N$/die/UBN418.c2 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418_u3 (
    .p1 ( \N$/die/UBN418.c2 ),
    .p2 ( \N$/die/UBN418.c3 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418_u4 (
    .p1 ( \N$/die/UBN418.c3 ),
    .p2 ( \N$/die/UBN418.c4 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418_u5 (
    .p1 ( \N$/die/UBN418.c4 ),
    .p2 ( \N$/die/UBN418.c5 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418_u6 (
    .p1 ( \N$/die/UBN418.c5 ),
    .p2 ( \N$/die/UBN418.c6 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418_u7 (
    .p1 ( \N$/die/UBN418.c6 ),
    .p2 ( \N$/die/UBN418.c7 )
);

capcom_dl0921_BUF01 bus_signal_control_UBN418_u8 (
    .p1 ( \N$/die/UBN418.c7          ),
    .p2 ( \N$/bus-signal-control|w80 )
);

capcom_dl0921_AND03 bus_signal_control_UBN431 (
    .p1 ( \N$/bus-signal-control|w36            ),
    .p2 ( \N$/bus-signal-control|w63            ),
    .p3 ( \N$/bus-signal-control|w80            ),
    .p4 ( \/security-management/addr-decoder/LE )
);

capcom_dl0921_DFFCOR bus_signal_control_UBN434 (
    .p1 ( \N$/bus-signal-control|w23 ),
    .p2 ( VCC                        ),
    .p3 ( \N$/bus-signal-control|w46 ),
    .p4 ( \N$/bus-signal-control|w25 ),
    .p5 ( \N$/bus-signal-control|w36 )
);

capcom_dl0921_AND02 bus_signal_control_UBN439 (
    .p1 ( \/cps-id/~RESET            ),
    .p2 ( \N$/bus-signal-control|w63 ),
    .p3 ( \N$/bus-signal-control|w25 )
);

capcom_dl0921_NOR04 bus_signal_control_UBN474 (
    .p1 ( \N$/bus-signal-control|w16 ),
    .p2 ( \N$/bus-signal-control|w13 ),
    .p3 ( \/lut-counter/~LOAD        ),
    .p4 ( \/bus-signal-control/~CS   ),
    .p5 ( \/bus-signal-control/~RD   )
);

capcom_dl0921_OR04 bus_signal_control_UBN479 (
    .p1 ( \N$/bus-signal-control|w23 ),
    .p2 ( \N$/bus-signal-control|w13 ),
    .p3 ( \/lut-counter/~LOAD        ),
    .p4 ( \/bus-signal-control/~CS   ),
    .p5 ( \/bus-signal-control/~WR   )
);

capcom_dl0921_NBUF03 bus_signal_control_UBR376 (
    .p1 ( \N$/bus-signal-control|w16      ),
    .p2 ( \/raster-interrupts/counter1/RD )
);

capcom_dl0921_NBUF02 bus_signal_control_UBW417 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/bus-signal-control|w83                    )
);

//========================================================================
// counter-fi:
//========================================================================
capcom_dl0921_NAND02 counter_fi_UBN277 (
    .p1 ( \N$/counter-fi|UBR274.2 ),
    .p2 ( \/counter-fi/FI         ),
    .p3 ( \N$/counter-fi|UBN281.2 )
);

capcom_dl0921_NAND02 counter_fi_UBN279 (
    .p1 ( \/lut-io/~E         ),
    .p2 ( \/counter-fi/~RESET ),
    .p3 ( \N$/counter-fi|w157 )
);

capcom_dl0921_NAND02 counter_fi_UBN281 (
    .p1 ( \N$/counter-fi|w157     ),
    .p2 ( \N$/counter-fi|UBN281.2 ),
    .p3 ( \/lut-io/~E             )
);

capcom_dl0921_XNOR02 counter_fi_UBR106 (
    .p1 ( \N$/counter-fi|w106 ),
    .p2 ( \N$/counter-fi|w126 ),
    .p3 ( \N$/counter-fi|w149 )
);

capcom_dl0921_NAND02 counter_fi_UBR109 (
    .p1 ( \N$/counter-fi|w103  ),
    .p2 ( \/security-check/OUT ),
    .p3 ( \N$/counter-fi|w121  )
);

capcom_dl0921_NAND04 counter_fi_UBR11 (
    .p1 ( \N$/counter-fi|w105  ),
    .p2 ( \N$/counter-fi|w104  ),
    .p3 ( \N$/counter-fi|w103  ),
    .p4 ( \/security-check/OUT ),
    .p5 ( \N$/counter-fi|w126  )
);

capcom_dl0921_NAND05 counter_fi_UBR111 (
    .p1 ( \N$/counter-fi|w106  ),
    .p2 ( \N$/counter-fi|w105  ),
    .p3 ( \N$/counter-fi|w104  ),
    .p4 ( \N$/counter-fi|w103  ),
    .p5 ( \/security-check/OUT ),
    .p6 ( \N$/counter-fi|w129  )
);

capcom_dl0921_XNOR02 counter_fi_UBR114 (
    .p1 ( \N$/counter-fi|w104 ),
    .p2 ( \N$/counter-fi|w121 ),
    .p3 ( \N$/counter-fi|w144 )
);

capcom_dl0921_NAND03 counter_fi_UBR13 (
    .p1 ( \N$/counter-fi|w104  ),
    .p2 ( \N$/counter-fi|w103  ),
    .p3 ( \/security-check/OUT ),
    .p4 ( \N$/counter-fi|w124  )
);

capcom_dl0921_XNOR02 counter_fi_UBR139 (
    .p1 ( \N$/counter-fi|w107 ),
    .p2 ( \N$/counter-fi|w129 ),
    .p3 ( \N$/counter-fi|w151 )
);

capcom_dl0921_NAND06 counter_fi_UBR143 (
    .p1 ( \/security-check/OUT ),
    .p2 ( \N$/counter-fi|w103  ),
    .p3 ( \N$/counter-fi|w104  ),
    .p4 ( \N$/counter-fi|w105  ),
    .p5 ( \N$/counter-fi|w106  ),
    .p6 ( \N$/counter-fi|w107  ),
    .p9 ( \N$/counter-fi|w131  )
);

capcom_dl0921_XNOR02 counter_fi_UBR148 (
    .p1 ( \N$/counter-fi|w108 ),
    .p2 ( \N$/counter-fi|w131 ),
    .p3 ( \N$/counter-fi|w155 )
);

capcom_dl0921_NAND08 counter_fi_UBR151 (
    .p1 ( \/security-check/OUT    ),
    .p2 ( \N$/counter-fi|w103     ),
    .p3 ( \N$/counter-fi|w104     ),
    .p4 ( \N$/counter-fi|w105     ),
    .p5 ( \N$/counter-fi|w106     ),
    .p6 ( \N$/counter-fi|w107     ),
    .p7 ( \N$/counter-fi|w108     ),
    .p8 ( VCC                     ),
    .p9 ( \N$/counter-fi|UBR151.9 )
);

capcom_dl0921_DFFCOR counter_fi_UBR161 (
    .p1 ( \N$/counter-fi|w31      ),
    .p2 ( \N$/counter-fi|w141     ),
    .p3 ( \N$/counter-fi|w103     ),
    .p4 ( \/counter-fi/~RESET     ),
    .p5 ( \N$/counter-fi|UBR161.5 )
);

capcom_dl0921_DFFCOR counter_fi_UBR166 (
    .p1 ( \N$/counter-fi|w31      ),
    .p2 ( \N$/counter-fi|w144     ),
    .p3 ( \N$/counter-fi|w104     ),
    .p4 ( \/counter-fi/~RESET     ),
    .p5 ( \N$/counter-fi|UBR166.5 )
);

capcom_dl0921_DFFCOR counter_fi_UBR170 (
    .p1 ( \N$/counter-fi|w31      ),
    .p2 ( \N$/counter-fi|w146     ),
    .p3 ( \N$/counter-fi|w105     ),
    .p4 ( \/counter-fi/~RESET     ),
    .p5 ( \N$/counter-fi|UBR170.5 )
);

capcom_dl0921_DFFCOR counter_fi_UBR175 (
    .p1 ( \N$/counter-fi|w31      ),
    .p2 ( \N$/counter-fi|w149     ),
    .p3 ( \N$/counter-fi|w106     ),
    .p4 ( \/counter-fi/~RESET     ),
    .p5 ( \N$/counter-fi|UBR175.5 )
);

capcom_dl0921_DFFCOR counter_fi_UBR179 (
    .p1 ( \N$/counter-fi|w31      ),
    .p2 ( \N$/counter-fi|w151     ),
    .p3 ( \N$/counter-fi|w107     ),
    .p4 ( \/counter-fi/~RESET     ),
    .p5 ( \N$/counter-fi|UBR179.5 )
);

capcom_dl0921_DFFCOR counter_fi_UBR184 (
    .p1 ( \N$/counter-fi|w31      ),
    .p2 ( \N$/counter-fi|w155     ),
    .p3 ( \N$/counter-fi|w108     ),
    .p4 ( \/counter-fi/~RESET     ),
    .p5 ( \N$/counter-fi|UBR184.5 )
);

capcom_dl0921_INV01 counter_fi_UBR274 (
    .p1 ( \N$/counter-fi|UBR151.9 ),
    .p2 ( \N$/counter-fi|UBR274.2 )
);

capcom_dl0921_XNOR02 counter_fi_UBR8 (
    .p1 ( \N$/counter-fi|w105 ),
    .p2 ( \N$/counter-fi|w124 ),
    .p3 ( \N$/counter-fi|w146 )
);

capcom_dl0921_XOR02 counter_fi_UBR98 (
    .p1 ( \N$/counter-fi|w103  ),
    .p2 ( \/security-check/OUT ),
    .p3 ( \N$/counter-fi|w141  )
);

capcom_dl0921_NOR02 counter_fi_UBW275 (
    .p1 ( \/lut-io/~E                         ),
    .p2 ( \N$/counter-fi|w161                 ),
    .p3 ( \/lut-assembly/layer-control/~RESET )
);

capcom_dl0921_INV01 counter_fi_UBZ133 (
    .p1 ( \/counter-fi/FI    ),
    .p2 ( \N$/counter-fi|w31 )
);

capcom_dl0921_INV01 counter_fi_UBZ242 (
    .p1 ( \/counter-fi/~RESET ),
    .p2 ( \N$/counter-fi|w161 )
);

//========================================================================
// cps-id:
//========================================================================
capcom_dl0921_XNOR02 cps_id_UCL460 (
    .p1 ( \N$/cps-id|w48 ),
    .p2 ( \N$/cps-id|w63 ),
    .p3 ( \N$/cps-id|w19 )
);

capcom_dl0921_OAI41 cps_id_UCL463 (
    .p1 ( \N$/cps-id|w19      ),
    .p2 ( \N$/cps-id|w63      ),
    .p3 ( \N$/cps-id|w48      ),
    .p4 ( \N$/cps-id|w43      ),
    .p5 ( \N$/cps-id|w35      ),
    .p6 ( \N$/cps-id|UCL463.6 )
);

capcom_dl0921_DFFCOR cps_id_UCL468 (
    .p1 ( \N$/cps-id|w57      ),
    .p2 ( \N$/cps-id|w48      ),
    .p3 ( \N$/cps-id|w63      ),
    .p4 ( \/cps-id/~RESET     ),
    .p5 ( \N$/cps-id|UCL468.5 )
);

capcom_dl0921_DFFCOR cps_id_UCL472 (
    .p1 ( \N$/cps-id|w57      ),
    .p2 ( \N$/cps-id|w43      ),
    .p3 ( \N$/cps-id|w48      ),
    .p4 ( \/cps-id/~RESET     ),
    .p5 ( \N$/cps-id|UCL472.5 )
);

capcom_dl0921_DFFCOR cps_id_UCL477 (
    .p1 ( \N$/cps-id|w57      ),
    .p2 ( \N$/cps-id|w35      ),
    .p3 ( \N$/cps-id|w43      ),
    .p4 ( \/cps-id/~RESET     ),
    .p5 ( \N$/cps-id|UCL477.5 )
);

capcom_dl0921_DFFCOR cps_id_UCL481 (
    .p1 ( \N$/cps-id|w57      ),
    .p2 ( \N$/cps-id|UCL463.6 ),
    .p3 ( \N$/cps-id|w35      ),
    .p4 ( \/cps-id/~RESET     ),
    .p5 ( \N$/cps-id|UCL481.5 )
);

capcom_dl0921_OR02 cps_id_UCO374 (
    .p1 ( \/raster-interrupts/counter1/RD ),
    .p2 ( \/cps-id/~E                     ),
    .p3 ( \N$/cps-id|w57                  )
);

capcom_dl0921_M541C cps_id_UCO383 (
    .p1  ( \N$/cps-id|w57                              ),
    .p2  ( \/cps-id/CPS-ID-D11                         ),
    .p3  ( \/cps-id/CPS-ID-D10                         ),
    .p4  ( \/cps-id/CPS-ID-D5                          ),
    .p5  ( \/cps-id/CPS-ID-D4                          ),
    .p6  ( \/cps-id/CPS-ID-D3                          ),
    .p7  ( \/cps-id/CPS-ID-D2                          ),
    .p8  ( \/cps-id/CPS-ID-D1                          ),
    .p9  ( \/cps-id/CPS-ID-D0                          ),
    .p11 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p17 ( \/lut-assembly/layer-control/BUS10          ),
    .p18 ( \/lut-assembly/layer-control/BUS11          )
);

capcom_dl0921_M541C cps_id_UCR405 (
    .p1  ( \N$/cps-id|w57                              ),
    .p2  ( \/cps-id/CPS-ID-D12                         ),
    .p3  ( \/cps-id/CPS-ID-D13                         ),
    .p4  ( \/cps-id/CPS-ID-D14                         ),
    .p5  ( \/cps-id/CPS-ID-D15                         ),
    .p6  ( \N$/cps-id|w35                              ),
    .p7  ( \N$/cps-id|w43                              ),
    .p8  ( \N$/cps-id|w48                              ),
    .p9  ( \N$/cps-id|w63                              ),
    .p11 ( \/lut-assembly/layer-control/BUS9           ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p15 ( \/raster-interrupts/counter1/UK             ),
    .p16 ( \/cps-id/DATA14                             ),
    .p17 ( \/lut-assembly/layer-control/BUS13          ),
    .p18 ( \/lut-assembly/layer-control/BUS12          )
);

//========================================================================
// debug:
//========================================================================
capcom_dl0921_D38GL debug_UBH396 (
    .p1  ( \/TI0                                            ),
    .p2  ( \/TI1                                            ),
    .p3  ( \/TI2                                            ),
    .p4  ( \N$/debug|w3                                     ),
    .p5  ( GND                                              ),
    .p6  ( GND                                              ),
    .p7  ( \/~DEBUG7                                        ),
    .p9  ( \/~DEBUG6                                        ),
    .p10 ( \/tilemaps/col4-assemble/~DEBUG                  ),
    .p11 ( \/tilemaps/col3-assemble/~DEBUG                  ),
    .p12 ( \/tilemaps/col2-assemble/~DEBUG                  ),
    .p13 ( \/obj-manager/sd-bus/~DEBUG                      ),
    .p14 ( \/~DEBUG1                                        ),
    .p15 ( \/video-signals/video-signal-generator/~DEBUG-LO )
);

capcom_dl0921_INV01 debug_UBH423 (
    .p1 ( \/TI3        ),
    .p2 ( \N$/debug|w3 )
);

capcom_dl0921_D38GL debug_UBK384 (
    .p1  ( \/TI0                                      ),
    .p2  ( \/TI1                                      ),
    .p3  ( \/TI2                                      ),
    .p4  ( \/TI3                                      ),
    .p5  ( GND                                        ),
    .p6  ( GND                                        ),
    .p7  ( \/~DEBUG15                                 ),
    .p9  ( \/stars/row6-counter/~DEBUG                ),
    .p10 ( \/stars/row5-counter/~DEBUG                ),
    .p11 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p12 ( \/video-signals/video-counter/COUNTER-INC  ),
    .p13 ( \/~DEBUG10                                 ),
    .p14 ( \/~DEBUG9                                  ),
    .p15 ( \/~DEBUG8                                  )
);

//========================================================================
// debug/td-io:
//========================================================================
capcom_dl0921_BUF12 debug_td_io_UBD217 (
    .p1 ( \/debug/td-io/IN4  ),
    .p2 ( \/debug/td-io/OUT4 )
);

capcom_dl0921_BUF12 debug_td_io_UBD316 (
    .p1 ( \/debug/td-io/IN6  ),
    .p2 ( \/debug/td-io/OUT6 )
);

capcom_dl0921_BUF12 debug_td_io_UBH193 (
    .p1 ( \/debug/td-io/IN2  ),
    .p2 ( \/debug/td-io/OUT2 )
);

capcom_dl0921_BUF12 debug_td_io_UBH217 (
    .p1 ( \/debug/td-io/IN9  ),
    .p2 ( \/debug/td-io/OUT9 )
);

capcom_dl0921_BUF12 debug_td_io_UBH219 (
    .p1 ( \/debug/td-io/IN3  ),
    .p2 ( \/debug/td-io/OUT3 )
);

capcom_dl0921_BUF12 debug_td_io_UBK193 (
    .p1 ( \/debug/td-io/IN7  ),
    .p2 ( \/debug/td-io/OUT7 )
);

capcom_dl0921_BUF12 debug_td_io_UBK217 (
    .p1 ( \/debug/td-io/IN10  ),
    .p2 ( \/debug/td-io/OUT10 )
);

capcom_dl0921_BUF12 debug_td_io_UBR1 (
    .p1 ( \/debug/td-io/IN1  ),
    .p2 ( \/debug/td-io/OUT1 )
);

capcom_dl0921_BUF12 debug_td_io_UBR3 (
    .p1 ( \/debug/td-io/IN5  ),
    .p2 ( \/debug/td-io/OUT5 )
);

capcom_dl0921_BUF12 debug_td_io_UBR44 (
    .p1 ( \/debug/td-io/IN8  ),
    .p2 ( \/debug/td-io/OUT8 )
);

capcom_dl0921_BUF12 debug_td_io_UBR5 (
    .p1 ( \/debug/td-io/IN11  ),
    .p2 ( \/debug/td-io/OUT11 )
);

capcom_dl0921_BUF12 debug_td_io_UBU1 (
    .p1 ( \/debug/td-io/IN0  ),
    .p2 ( \/debug/td-io/OUT0 )
);

//========================================================================
// lut-assembly/layer-control:
//========================================================================
capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE104 (
    .p1 ( \N$/lut-assembly/layer-control|w67      ),
    .p2 ( \/lut-assembly/layer-control/BUS12      ),
    .p3 ( \/lut-assembly/layer-control/ROW1-S0    ),
    .p4 ( \/lut-assembly/layer-control/~RESET     ),
    .p5 ( \N$/lut-assembly/layer-control|UBE104.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE108 (
    .p1 ( \N$/lut-assembly/layer-control|w67      ),
    .p2 ( \/lut-assembly/layer-control/BUS13      ),
    .p3 ( \/lut-assembly/layer-control/ROW1-S1    ),
    .p4 ( \/lut-assembly/layer-control/~RESET     ),
    .p5 ( \N$/lut-assembly/layer-control|UBE108.5 )
);

capcom_dl0921_NOR02 lut_assembly_layer_control_UBE46 (
    .p1 ( \/lut-assembly/layer-control/WR        ),
    .p2 ( \/lut-assembly/layer-control/~E        ),
    .p3 ( \N$/lut-assembly/layer-control|UBE48.2 )
);

capcom_dl0921_NAND02 lut_assembly_layer_control_UBE48 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/lut-assembly/layer-control|UBE48.2        ),
    .p3 ( \N$/lut-assembly/layer-control|w67            )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE50 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS1      ),
    .p3 ( \N$/lut-assembly/layer-control|UBE50.3 ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE50.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE55 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS2      ),
    .p3 ( \N$/lut-assembly/layer-control|UBE55.3 ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE55.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE59 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS3      ),
    .p3 ( \N$/lut-assembly/layer-control|UBE59.3 ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE59.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE64 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS4      ),
    .p3 ( \N$/lut-assembly/layer-control|UBE64.3 ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE64.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE68 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS5      ),
    .p3 ( \N$/lut-assembly/layer-control|UBE68.3 ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE68.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE72 (
    .p1 ( \N$/lut-assembly/layer-control|w67          ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p3 ( \/lut-assembly/layer-control/ROW4-S0        ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/lut-assembly/layer-control|UBE72.5      )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE77 (
    .p1 ( \N$/lut-assembly/layer-control|w67          ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p3 ( \/lut-assembly/layer-control/ROW4-S1        ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/lut-assembly/layer-control|UBE77.5      )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE86 (
    .p1 ( \N$/lut-assembly/layer-control|w67          ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p3 ( \/lut-assembly/layer-control/ROW3-S0        ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/lut-assembly/layer-control|UBE86.5      )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE90 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS9      ),
    .p3 ( \/lut-assembly/layer-control/ROW3-S1   ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE90.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE95 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS10     ),
    .p3 ( \/lut-assembly/layer-control/ROW2-S0   ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE95.5 )
);

capcom_dl0921_DFFCOR lut_assembly_layer_control_UBE99 (
    .p1 ( \N$/lut-assembly/layer-control|w67     ),
    .p2 ( \/lut-assembly/layer-control/BUS11     ),
    .p3 ( \/lut-assembly/layer-control/ROW2-S1   ),
    .p4 ( \/lut-assembly/layer-control/~RESET    ),
    .p5 ( \N$/lut-assembly/layer-control|UBE99.5 )
);

capcom_dl0921_INV01 lut_assembly_layer_control_UBF12 (
    .p1 ( \N$/lut-assembly/layer-control|UBE64.3 ),
    .p2 ( \/stars/row5-assemble/~ENABLE          )
);

capcom_dl0921_INV01 lut_assembly_layer_control_UBF16 (
    .p1 ( \N$/lut-assembly/layer-control|UBE68.3 ),
    .p2 ( \/stars/row6-assemble/~ENABLE          )
);

capcom_dl0921_INV01 lut_assembly_layer_control_UBH16 (
    .p1 ( \N$/lut-assembly/layer-control|UBE50.3 ),
    .p2 ( \/tilemaps/col2-assemble/~COL2-E       )
);

capcom_dl0921_INV01 lut_assembly_layer_control_UBH38 (
    .p1 ( \N$/lut-assembly/layer-control|UBE55.3 ),
    .p2 ( \/tilemaps/col3-assemble/~COL3-E       )
);

capcom_dl0921_INV01 lut_assembly_layer_control_UBH60 (
    .p1 ( \N$/lut-assembly/layer-control|UBE59.3 ),
    .p2 ( \/tilemaps/col4-assemble/~COL4-E       )
);

//========================================================================
// lut-assembly/layer-draw-order:
//========================================================================
capcom_dl0921_D24L lut_assembly_layer_draw_order_UBF19 (
    .p1 ( \/lut-assembly/layer-control/ROW4-S0  ),
    .p2 ( \/lut-assembly/layer-control/ROW4-S1  ),
    .p3 ( \/lut-assembly/layer-draw-order/~R4C4 ),
    .p4 ( \/lut-assembly/layer-draw-order/~R4C3 ),
    .p5 ( \/lut-assembly/layer-draw-order/~R4C2 ),
    .p6 ( \/lut-assembly/layer-draw-order/~R4C1 )
);

capcom_dl0921_D24L lut_assembly_layer_draw_order_UBF26 (
    .p1 ( \/lut-assembly/layer-control/ROW3-S0  ),
    .p2 ( \/lut-assembly/layer-control/ROW3-S1  ),
    .p3 ( \/lut-assembly/layer-draw-order/~R3C4 ),
    .p4 ( \/lut-assembly/layer-draw-order/~R3C3 ),
    .p5 ( \/lut-assembly/layer-draw-order/~R3C2 ),
    .p6 ( \/lut-assembly/layer-draw-order/~R3C1 )
);

capcom_dl0921_D24L lut_assembly_layer_draw_order_UBF33 (
    .p1 ( \/lut-assembly/layer-control/ROW2-S0  ),
    .p2 ( \/lut-assembly/layer-control/ROW2-S1  ),
    .p3 ( \/lut-assembly/layer-draw-order/~R2C4 ),
    .p4 ( \/lut-assembly/layer-draw-order/~R2C3 ),
    .p5 ( \/lut-assembly/layer-draw-order/~R2C2 ),
    .p6 ( \/lut-assembly/layer-draw-order/~R2C1 )
);

capcom_dl0921_D24L lut_assembly_layer_draw_order_UBF40 (
    .p1 ( \/lut-assembly/layer-control/ROW1-S0  ),
    .p2 ( \/lut-assembly/layer-control/ROW1-S1  ),
    .p3 ( \/lut-assembly/layer-draw-order/~R1C4 ),
    .p4 ( \/lut-assembly/layer-draw-order/~R1C3 ),
    .p5 ( \/lut-assembly/layer-draw-order/~R1C2 ),
    .p6 ( \/lut-assembly/layer-draw-order/~R1C1 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI0 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD0               ),
    .p3  ( \/obj-manager/sd-bus/XSD1               ),
    .p4  ( \/obj-manager/sd-bus/XSD2               ),
    .p5  ( \/obj-manager/sd-bus/XSD3               ),
    .p6  ( \/obj-manager/sd-bus/XSD4               ),
    .p7  ( \/obj-manager/sd-bus/XSD5               ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW4-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI12 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD6               ),
    .p3  ( \/obj-manager/sd-bus/XSD7               ),
    .p4  ( \/obj-manager/sd-bus/XSD8               ),
    .p5  ( GND                                     ),
    .p6  ( GND                                     ),
    .p7  ( GND                                     ),
    .p13 ( \N$/die/UBI12.13                        ),
    .p14 ( \N$/die/UBI12.14                        ),
    .p15 ( \N$/die/UBI12.15                        ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D8 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D7 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D6 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI21 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C2   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW4-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI33 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C2    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW4-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI43 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C3   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW4-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI55 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C3    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW4-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI65 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C4   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW4-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBI77 (
    .p1  ( \/lut-assembly/layer-draw-order/~R4C4    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW4-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW4-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW4-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW4-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK0 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD0               ),
    .p3  ( \/obj-manager/sd-bus/XSD1               ),
    .p4  ( \/obj-manager/sd-bus/XSD2               ),
    .p5  ( \/obj-manager/sd-bus/XSD3               ),
    .p6  ( \/obj-manager/sd-bus/XSD4               ),
    .p7  ( \/obj-manager/sd-bus/XSD5               ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW3-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK12 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD6               ),
    .p3  ( \/obj-manager/sd-bus/XSD7               ),
    .p4  ( \/obj-manager/sd-bus/XSD8               ),
    .p5  ( GND                                     ),
    .p6  ( GND                                     ),
    .p7  ( GND                                     ),
    .p13 ( \N$/die/UBK12.13                        ),
    .p14 ( \N$/die/UBK12.14                        ),
    .p15 ( \N$/die/UBK12.15                        ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D8 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D7 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D6 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK21 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C2   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW3-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK33 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C2    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW3-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK43 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C3   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW3-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK55 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C3    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW3-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK65 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C4   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW3-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBK77 (
    .p1  ( \/lut-assembly/layer-draw-order/~R3C4    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW3-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW3-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW3-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW3-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM0 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD0               ),
    .p3  ( \/obj-manager/sd-bus/XSD1               ),
    .p4  ( \/obj-manager/sd-bus/XSD2               ),
    .p5  ( \/obj-manager/sd-bus/XSD3               ),
    .p6  ( \/obj-manager/sd-bus/XSD4               ),
    .p7  ( \/obj-manager/sd-bus/XSD5               ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW2-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM12 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD6               ),
    .p3  ( \/obj-manager/sd-bus/XSD7               ),
    .p4  ( \/obj-manager/sd-bus/XSD8               ),
    .p5  ( GND                                     ),
    .p6  ( GND                                     ),
    .p7  ( GND                                     ),
    .p13 ( \N$/die/UBM12.13                        ),
    .p14 ( \N$/die/UBM12.14                        ),
    .p15 ( \N$/die/UBM12.15                        ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D8 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D7 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D6 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM21 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C2   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW2-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM33 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C2    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW2-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM43 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C3   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW2-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM55 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C3    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW2-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM65 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C4   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW2-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBM77 (
    .p1  ( \/lut-assembly/layer-draw-order/~R2C4    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW2-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW2-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW2-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW2-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN0 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD0               ),
    .p3  ( \/obj-manager/sd-bus/XSD1               ),
    .p4  ( \/obj-manager/sd-bus/XSD2               ),
    .p5  ( \/obj-manager/sd-bus/XSD3               ),
    .p6  ( \/obj-manager/sd-bus/XSD4               ),
    .p7  ( \/obj-manager/sd-bus/XSD5               ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW1-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN12 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C1   ),
    .p2  ( \/obj-manager/sd-bus/XSD6               ),
    .p3  ( \/obj-manager/sd-bus/XSD7               ),
    .p4  ( \/obj-manager/sd-bus/XSD8               ),
    .p5  ( GND                                     ),
    .p6  ( GND                                     ),
    .p7  ( GND                                     ),
    .p13 ( \N$/die/UBN12.13                        ),
    .p14 ( \N$/die/UBN12.14                        ),
    .p15 ( \N$/die/UBN12.15                        ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D8 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D7 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D6 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN21 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C2   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW1-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN33 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C2    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW1-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN43 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C3   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW1-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN55 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C3    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW1-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D6  )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN65 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C4   ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D0 ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D1 ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D2 ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D3 ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D4 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D5 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D5 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D4 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW1-D3 ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D2 ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D1 ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D0 )
);

capcom_dl0921_M125C_X6 lut_assembly_layer_draw_order_UBN77 (
    .p1  ( \/lut-assembly/layer-draw-order/~R1C4    ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D6  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D7  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D8  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D9  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D10 ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D11 ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D11 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D10 ),
    .p15 ( \/lut-assembly/layer-draw-order/ROW1-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/ROW1-D8  ),
    .p17 ( \/lut-assembly/layer-draw-order/ROW1-D7  ),
    .p18 ( \/lut-assembly/layer-draw-order/ROW1-D6  )
);

//========================================================================
// lut-assembly/lut-storage:
//========================================================================
capcom_dl0921_M273CG lut_assembly_lut_storage_UBE112 (
    .p1  ( \/lut-assembly/lut-storage/~E7         ),
    .p2  ( \/lut-io/A0                            ),
    .p3  ( VCC                                    ),
    .p4  ( VCC                                    ),
    .p5  ( \/lut-io/A1                            ),
    .p6  ( \/lut-io/A2                            ),
    .p7  ( VCC                                    ),
    .p8  ( VCC                                    ),
    .p9  ( \/lut-io/A3                            ),
    .p11 ( \/lut-assembly/lut-storage/CLK         ),
    .p12 ( \/lut-io/A4                            ),
    .p13 ( VCC                                    ),
    .p14 ( VCC                                    ),
    .p15 ( \/lut-io/A5                            ),
    .p16 ( \N$/lut-assembly/lut-storage|UBE112.16 ),
    .p17 ( GND                                    ),
    .p18 ( GND                                    ),
    .p19 ( \N$/lut-assembly/lut-storage|UBE112.19 )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBE150 (
    .p1  ( \/lut-assembly/lut-storage/~E7         ),
    .p2  ( \/lut-io/A6                            ),
    .p3  ( VCC                                    ),
    .p4  ( VCC                                    ),
    .p5  ( \/lut-io/A7                            ),
    .p6  ( \/lut-io/A8                            ),
    .p7  ( VCC                                    ),
    .p8  ( VCC                                    ),
    .p9  ( \/lut-io/A9                            ),
    .p11 ( \/lut-assembly/lut-storage/CLK         ),
    .p12 ( \/lut-io/A10                           ),
    .p13 ( GND                                    ),
    .p14 ( VCC                                    ),
    .p15 ( \/lut-io/A11                           ),
    .p16 ( \N$/lut-assembly/lut-storage|UBE150.16 ),
    .p17 ( GND                                    ),
    .p18 ( GND                                    ),
    .p19 ( \N$/lut-assembly/lut-storage|UBE150.19 )
);

capcom_dl0921_8BUF11 lut_assembly_lut_storage_UBF101 (
    .p2  ( \/lut-assembly/lut-storage/ROW6-D0     ),
    .p3  ( \/lut-assembly/lut-storage/ROW6-D1     ),
    .p4  ( \/lut-assembly/lut-storage/ROW6-D2     ),
    .p5  ( \/lut-assembly/lut-storage/ROW6-D3     ),
    .p6  ( \/lut-assembly/lut-storage/ROW6-D4     ),
    .p7  ( \/lut-assembly/lut-storage/ROW6-D5     ),
    .p8  ( \/lut-assembly/lut-storage/ROW6-D6     ),
    .p9  ( GND                                    ),
    .p11 ( \N$/lut-assembly/lut-storage|UBF101.11 ),
    .p12 ( \N$/lut-assembly/lut-storage|w152      ),
    .p13 ( \N$/lut-assembly/lut-storage|w149      ),
    .p14 ( \N$/lut-assembly/lut-storage|w148      ),
    .p15 ( \N$/lut-assembly/lut-storage|w147      ),
    .p16 ( \N$/lut-assembly/lut-storage|w146      ),
    .p17 ( \N$/lut-assembly/lut-storage|w145      ),
    .p18 ( \N$/lut-assembly/lut-storage|w144      )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBF112 (
    .p1  ( \/lut-assembly/lut-storage/~E6         ),
    .p2  ( \/lut-io/A0                            ),
    .p3  ( \N$/lut-assembly/lut-storage|w144      ),
    .p4  ( \N$/lut-assembly/lut-storage|w145      ),
    .p5  ( \/lut-io/A1                            ),
    .p6  ( \/lut-io/A2                            ),
    .p7  ( \N$/lut-assembly/lut-storage|w146      ),
    .p8  ( \N$/lut-assembly/lut-storage|w147      ),
    .p9  ( \/lut-io/A3                            ),
    .p11 ( \/lut-assembly/lut-storage/CLK         ),
    .p12 ( \/lut-io/A4                            ),
    .p13 ( \N$/lut-assembly/lut-storage|w148      ),
    .p14 ( \N$/lut-assembly/lut-storage|w149      ),
    .p15 ( \/lut-io/A5                            ),
    .p16 ( \N$/lut-assembly/lut-storage|UBF112.16 ),
    .p17 ( GND                                    ),
    .p18 ( GND                                    ),
    .p19 ( \N$/lut-assembly/lut-storage|UBF112.19 )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBF150 (
    .p1  ( \/lut-assembly/lut-storage/~E6         ),
    .p2  ( \/lut-io/A6                            ),
    .p3  ( \N$/lut-assembly/lut-storage|w152      ),
    .p4  ( GND                                    ),
    .p5  ( \/lut-io/A7                            ),
    .p6  ( \/lut-io/A8                            ),
    .p7  ( GND                                    ),
    .p8  ( VCC                                    ),
    .p9  ( \/lut-io/A9                            ),
    .p11 ( \/lut-assembly/lut-storage/CLK         ),
    .p12 ( \/lut-io/A10                           ),
    .p13 ( GND                                    ),
    .p14 ( VCC                                    ),
    .p15 ( \/lut-io/A11                           ),
    .p16 ( \N$/lut-assembly/lut-storage|UBF150.16 ),
    .p17 ( GND                                    ),
    .p18 ( GND                                    ),
    .p19 ( \N$/lut-assembly/lut-storage|UBF150.19 )
);

capcom_dl0921_8BUF11 lut_assembly_lut_storage_UBH101 (
    .p2  ( \/lut-assembly/lut-storage/ROW5-D0     ),
    .p3  ( \/lut-assembly/lut-storage/ROW5-D1     ),
    .p4  ( \/lut-assembly/lut-storage/ROW5-D2     ),
    .p5  ( \/lut-assembly/lut-storage/ROW5-D3     ),
    .p6  ( \/lut-assembly/lut-storage/ROW5-D4     ),
    .p7  ( \/lut-assembly/lut-storage/ROW5-D5     ),
    .p8  ( \/lut-assembly/lut-storage/ROW5-D6     ),
    .p9  ( GND                                    ),
    .p11 ( \N$/lut-assembly/lut-storage|UBH101.11 ),
    .p12 ( \N$/lut-assembly/lut-storage|w45       ),
    .p13 ( \N$/lut-assembly/lut-storage|w42       ),
    .p14 ( \N$/lut-assembly/lut-storage|w41       ),
    .p15 ( \N$/lut-assembly/lut-storage|w40       ),
    .p16 ( \N$/lut-assembly/lut-storage|w39       ),
    .p17 ( \N$/lut-assembly/lut-storage|w38       ),
    .p18 ( \N$/lut-assembly/lut-storage|w37       )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBH112 (
    .p1  ( \/lut-assembly/lut-storage/~E5         ),
    .p2  ( \/lut-io/A0                            ),
    .p3  ( \N$/lut-assembly/lut-storage|w37       ),
    .p4  ( \N$/lut-assembly/lut-storage|w38       ),
    .p5  ( \/lut-io/A1                            ),
    .p6  ( \/lut-io/A2                            ),
    .p7  ( \N$/lut-assembly/lut-storage|w39       ),
    .p8  ( \N$/lut-assembly/lut-storage|w40       ),
    .p9  ( \/lut-io/A3                            ),
    .p11 ( \/lut-assembly/lut-storage/CLK         ),
    .p12 ( \/lut-io/A4                            ),
    .p13 ( \N$/lut-assembly/lut-storage|w41       ),
    .p14 ( \N$/lut-assembly/lut-storage|w42       ),
    .p15 ( \/lut-io/A5                            ),
    .p16 ( \N$/lut-assembly/lut-storage|UBH112.16 ),
    .p17 ( GND                                    ),
    .p18 ( GND                                    ),
    .p19 ( \N$/lut-assembly/lut-storage|UBH112.19 )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBH150 (
    .p1  ( \/lut-assembly/lut-storage/~E5         ),
    .p2  ( \/lut-io/A6                            ),
    .p3  ( \N$/lut-assembly/lut-storage|w45       ),
    .p4  ( GND                                    ),
    .p5  ( \/lut-io/A7                            ),
    .p6  ( \/lut-io/A8                            ),
    .p7  ( GND                                    ),
    .p8  ( GND                                    ),
    .p9  ( \/lut-io/A9                            ),
    .p11 ( \/lut-assembly/lut-storage/CLK         ),
    .p12 ( \/lut-io/A10                           ),
    .p13 ( GND                                    ),
    .p14 ( VCC                                    ),
    .p15 ( \/lut-io/A11                           ),
    .p16 ( \N$/lut-assembly/lut-storage|UBH150.16 ),
    .p17 ( GND                                    ),
    .p18 ( GND                                    ),
    .p19 ( \N$/lut-assembly/lut-storage|UBH150.19 )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBI112 (
    .p1  ( \/lut-assembly/lut-storage/~E4          ),
    .p2  ( \/lut-io/A0                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW4-D0 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW4-D1 ),
    .p5  ( \/lut-io/A1                             ),
    .p6  ( \/lut-io/A2                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW4-D2 ),
    .p8  ( \/lut-assembly/layer-draw-order/ROW4-D3 ),
    .p9  ( \/lut-io/A3                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A4                             ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW4-D4 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW4-D5 ),
    .p15 ( \/lut-io/A5                             ),
    .p16 ( \N$/lut-assembly/lut-storage|UBI112.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBI112.19  )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBI150 (
    .p1  ( \/lut-assembly/lut-storage/~E4          ),
    .p2  ( \/lut-io/A6                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW4-D6 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW4-D7 ),
    .p5  ( \/lut-io/A7                             ),
    .p6  ( \/lut-io/A8                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW4-D8 ),
    .p8  ( \/lut-assembly/layer-control/ROW4-S0    ),
    .p9  ( \/lut-io/A9                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A10                            ),
    .p13 ( \/lut-assembly/layer-control/ROW4-S1    ),
    .p14 ( GND                                     ),
    .p15 ( \/lut-io/A11                            ),
    .p16 ( \N$/lut-assembly/lut-storage|UBI150.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBI150.19  )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBK112 (
    .p1  ( \/lut-assembly/lut-storage/~E3          ),
    .p2  ( \/lut-io/A0                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW3-D0 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW3-D1 ),
    .p5  ( \/lut-io/A1                             ),
    .p6  ( \/lut-io/A2                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW3-D2 ),
    .p8  ( \/lut-assembly/layer-draw-order/ROW3-D3 ),
    .p9  ( \/lut-io/A3                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A4                             ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW3-D4 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW3-D5 ),
    .p15 ( \/lut-io/A5                             ),
    .p16 ( \N$/lut-assembly/lut-storage|UBK112.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBK112.19  )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBK150 (
    .p1  ( \/lut-assembly/lut-storage/~E3          ),
    .p2  ( \/lut-io/A6                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW3-D6 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW3-D7 ),
    .p5  ( \/lut-io/A7                             ),
    .p6  ( \/lut-io/A8                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW3-D8 ),
    .p8  ( \/lut-assembly/layer-control/ROW3-S0    ),
    .p9  ( \/lut-io/A9                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A10                            ),
    .p13 ( \/lut-assembly/layer-control/ROW3-S1    ),
    .p14 ( GND                                     ),
    .p15 ( \/lut-io/A11                            ),
    .p16 ( \N$/lut-assembly/lut-storage|UBK150.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBK150.19  )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBM112 (
    .p1  ( \/lut-assembly/lut-storage/~E2          ),
    .p2  ( \/lut-io/A0                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW2-D0 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW2-D1 ),
    .p5  ( \/lut-io/A1                             ),
    .p6  ( \/lut-io/A2                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW2-D2 ),
    .p8  ( \/lut-assembly/layer-draw-order/ROW2-D3 ),
    .p9  ( \/lut-io/A3                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A4                             ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW2-D4 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW2-D5 ),
    .p15 ( \/lut-io/A5                             ),
    .p16 ( \N$/lut-assembly/lut-storage|UBM112.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBM112.19  )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBM150 (
    .p1  ( \/lut-assembly/lut-storage/~E2          ),
    .p2  ( \/lut-io/A6                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW2-D6 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW2-D7 ),
    .p5  ( \/lut-io/A7                             ),
    .p6  ( \/lut-io/A8                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW2-D8 ),
    .p8  ( \/lut-assembly/layer-control/ROW2-S0    ),
    .p9  ( \/lut-io/A9                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A10                            ),
    .p13 ( \/lut-assembly/layer-control/ROW2-S1    ),
    .p14 ( GND                                     ),
    .p15 ( \/lut-io/A11                            ),
    .p16 ( \N$/lut-assembly/lut-storage|UBM150.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBM150.19  )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBN112 (
    .p1  ( \/lut-assembly/lut-storage/~E1          ),
    .p2  ( \/lut-io/A0                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW1-D0 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW1-D1 ),
    .p5  ( \/lut-io/A1                             ),
    .p6  ( \/lut-io/A2                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW1-D2 ),
    .p8  ( \/lut-assembly/layer-draw-order/ROW1-D3 ),
    .p9  ( \/lut-io/A3                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A4                             ),
    .p13 ( \/lut-assembly/layer-draw-order/ROW1-D4 ),
    .p14 ( \/lut-assembly/layer-draw-order/ROW1-D5 ),
    .p15 ( \/lut-io/A5                             ),
    .p16 ( \N$/lut-assembly/lut-storage|UBN112.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBN112.19  )
);

capcom_dl0921_M273CG lut_assembly_lut_storage_UBN150 (
    .p1  ( \/lut-assembly/lut-storage/~E1          ),
    .p2  ( \/lut-io/A6                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW1-D6 ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW1-D7 ),
    .p5  ( \/lut-io/A7                             ),
    .p6  ( \/lut-io/A8                             ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW1-D8 ),
    .p8  ( \/lut-assembly/layer-control/ROW1-S0    ),
    .p9  ( \/lut-io/A9                             ),
    .p11 ( \/lut-assembly/lut-storage/CLK          ),
    .p12 ( \/lut-io/A10                            ),
    .p13 ( \/lut-assembly/layer-control/ROW1-S1    ),
    .p14 ( GND                                     ),
    .p15 ( \/lut-io/A11                            ),
    .p16 ( \N$/lut-assembly/lut-storage|UBN150.16  ),
    .p17 ( GND                                     ),
    .p18 ( GND                                     ),
    .p19 ( \N$/lut-assembly/lut-storage|UBN150.19  )
);

//========================================================================
// lut-assembly/priority-masks:
//========================================================================
capcom_dl0921_M273C lut_assembly_priority_masks_UBK460 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w310        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p4  ( \/lut-assembly/layer-control/BUS9           ),
    .p5  ( \N$/lut-assembly/priority-masks|w311        ),
    .p6  ( \N$/lut-assembly/priority-masks|w312        ),
    .p7  ( \/lut-assembly/layer-control/BUS10          ),
    .p8  ( \/lut-assembly/layer-control/BUS11          ),
    .p9  ( \N$/lut-assembly/priority-masks|w313        ),
    .p11 ( \N$/lut-assembly/priority-masks|w291        ),
    .p12 ( \N$/lut-assembly/priority-masks|w314        ),
    .p13 ( \/lut-assembly/layer-control/BUS12          ),
    .p14 ( \/lut-assembly/layer-control/BUS13          ),
    .p15 ( \N$/lut-assembly/priority-masks|w315        ),
    .p16 ( \N$/lut-assembly/priority-masks|w316        ),
    .p17 ( \/cps-id/DATA14                             ),
    .p18 ( \/raster-interrupts/counter1/UK             ),
    .p19 ( \N$/lut-assembly/priority-masks|w317        )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UBK499 (
    .p1  ( \N$/lut-assembly/priority-masks|w313     ),
    .p2  ( \N$/lut-assembly/priority-masks|w312     ),
    .p3  ( \N$/lut-assembly/priority-masks|w311     ),
    .p4  ( \N$/lut-assembly/priority-masks|w310     ),
    .p5  ( \N$/lut-assembly/priority-masks|UBK499.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w317     ),
    .p13 ( \N$/lut-assembly/priority-masks|w316     ),
    .p14 ( \N$/lut-assembly/priority-masks|w315     ),
    .p15 ( \N$/lut-assembly/priority-masks|w314     )
);

capcom_dl0921_NOR02 lut_assembly_priority_masks_UBR374 (
    .p1 ( \/lut-assembly/layer-control/WR     ),
    .p2 ( \/lut-assembly/priority-masks/ROW3  ),
    .p3 ( \N$/lut-assembly/priority-masks|w16 )
);

capcom_dl0921_NOR02 lut_assembly_priority_masks_UBU376 (
    .p1 ( \/lut-assembly/layer-control/WR     ),
    .p2 ( \/lut-assembly/priority-masks/ROW2  ),
    .p3 ( \N$/lut-assembly/priority-masks|w15 )
);

capcom_dl0921_M273C lut_assembly_priority_masks_UBU458 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w318        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p4  ( \/lut-assembly/layer-control/BUS9           ),
    .p5  ( \N$/lut-assembly/priority-masks|w319        ),
    .p6  ( \N$/lut-assembly/priority-masks|w320        ),
    .p7  ( \/lut-assembly/layer-control/BUS10          ),
    .p8  ( \/lut-assembly/layer-control/BUS11          ),
    .p9  ( \N$/lut-assembly/priority-masks|w321        ),
    .p11 ( \N$/lut-assembly/priority-masks|w293        ),
    .p12 ( \N$/lut-assembly/priority-masks|w322        ),
    .p13 ( \/lut-assembly/layer-control/BUS12          ),
    .p14 ( \/lut-assembly/layer-control/BUS13          ),
    .p15 ( \N$/lut-assembly/priority-masks|w323        ),
    .p16 ( \N$/lut-assembly/priority-masks|w324        ),
    .p17 ( \/cps-id/DATA14                             ),
    .p18 ( \/raster-interrupts/counter1/UK             ),
    .p19 ( \N$/lut-assembly/priority-masks|w325        )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UBU498 (
    .p1  ( \N$/lut-assembly/priority-masks|w321     ),
    .p2  ( \N$/lut-assembly/priority-masks|w320     ),
    .p3  ( \N$/lut-assembly/priority-masks|w319     ),
    .p4  ( \N$/lut-assembly/priority-masks|w318     ),
    .p5  ( \N$/lut-assembly/priority-masks|UBU498.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w325     ),
    .p13 ( \N$/lut-assembly/priority-masks|w324     ),
    .p14 ( \N$/lut-assembly/priority-masks|w323     ),
    .p15 ( \N$/lut-assembly/priority-masks|w322     )
);

capcom_dl0921_NAND02 lut_assembly_priority_masks_UBW389 (
    .p1 ( \N$/lut-assembly/priority-masks|w15           ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/lut-assembly/priority-masks|w291          )
);

capcom_dl0921_MUX4H lut_assembly_priority_masks_UBW401 (
    .p1 ( \N$/lut-assembly/priority-masks|w366 ),
    .p2 ( \N$/lut-assembly/priority-masks|w370 ),
    .p3 ( \N$/lut-assembly/priority-masks|w374 ),
    .p4 ( \N$/lut-assembly/priority-masks|w378 ),
    .p5 ( \/lut-assembly/priority-masks/S4     ),
    .p6 ( \/lut-assembly/priority-masks/S5     ),
    .p7 ( \/lut-assembly/priority-masks/OUT    )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UBW498 (
    .p1 ( \/lut-assembly/priority-masks/S3         ),
    .p2 ( \N$/lut-assembly/priority-masks|UCL498.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w374     )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UBW505 (
    .p1 ( \N$/lut-assembly/priority-masks|w363     ),
    .p2 ( \N$/lut-assembly/priority-masks|UBK499.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w374     )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UBW509 (
    .p1 ( \N$/lut-assembly/priority-masks|w363     ),
    .p2 ( \N$/lut-assembly/priority-masks|UBU498.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w378     )
);

capcom_dl0921_NAND02 lut_assembly_priority_masks_UBW522 (
    .p1 ( \N$/lut-assembly/priority-masks|w16           ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/lut-assembly/priority-masks|w293          )
);

capcom_dl0921_NOR02 lut_assembly_priority_masks_UBZ315 (
    .p1 ( \/lut-assembly/layer-control/WR     ),
    .p2 ( \/lut-assembly/priority-masks/ROW0  ),
    .p3 ( \N$/lut-assembly/priority-masks|w13 )
);

capcom_dl0921_NOR02 lut_assembly_priority_masks_UBZ333 (
    .p1 ( \/lut-assembly/layer-control/WR     ),
    .p2 ( \/lut-assembly/priority-masks/ROW1  ),
    .p3 ( \N$/lut-assembly/priority-masks|w14 )
);

capcom_dl0921_NAND02 lut_assembly_priority_masks_UBZ335 (
    .p1 ( \N$/lut-assembly/priority-masks|w14           ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/lut-assembly/priority-masks|w217          )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UBZ477 (
    .p1 ( \/lut-assembly/priority-masks/S3         ),
    .p2 ( \N$/lut-assembly/priority-masks|UCC461.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w378     )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UCC424 (
    .p1 ( \N$/lut-assembly/priority-masks|w363     ),
    .p2 ( \N$/lut-assembly/priority-masks|UCG383.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w366     )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UCC461 (
    .p1  ( \N$/lut-assembly/priority-masks|w150     ),
    .p2  ( \N$/lut-assembly/priority-masks|w149     ),
    .p3  ( \N$/lut-assembly/priority-masks|w148     ),
    .p4  ( \N$/lut-assembly/priority-masks|w147     ),
    .p5  ( \N$/lut-assembly/priority-masks|UCC461.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w154     ),
    .p13 ( \N$/lut-assembly/priority-masks|w153     ),
    .p14 ( \N$/lut-assembly/priority-masks|w152     ),
    .p15 ( \N$/lut-assembly/priority-masks|w151     )
);

capcom_dl0921_M273C lut_assembly_priority_masks_UCC486 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w147        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5  ( \N$/lut-assembly/priority-masks|w148        ),
    .p6  ( \N$/lut-assembly/priority-masks|w149        ),
    .p7  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p9  ( \N$/lut-assembly/priority-masks|w150        ),
    .p11 ( \N$/lut-assembly/priority-masks|w293        ),
    .p12 ( \N$/lut-assembly/priority-masks|w151        ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p15 ( \N$/lut-assembly/priority-masks|w152        ),
    .p16 ( \N$/lut-assembly/priority-masks|w153        ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p19 ( \N$/lut-assembly/priority-masks|w154        )
);

capcom_dl0921_NAND02 lut_assembly_priority_masks_UCG318 (
    .p1 ( \N$/lut-assembly/priority-masks|w13           ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/lut-assembly/priority-masks|w215          )
);

capcom_dl0921_M273C lut_assembly_priority_masks_UCG340 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w294        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p4  ( \/lut-assembly/layer-control/BUS9           ),
    .p5  ( \N$/lut-assembly/priority-masks|w295        ),
    .p6  ( \N$/lut-assembly/priority-masks|w296        ),
    .p7  ( \/lut-assembly/layer-control/BUS10          ),
    .p8  ( \/lut-assembly/layer-control/BUS11          ),
    .p9  ( \N$/lut-assembly/priority-masks|w297        ),
    .p11 ( \N$/lut-assembly/priority-masks|w215        ),
    .p12 ( \N$/lut-assembly/priority-masks|w298        ),
    .p13 ( \/lut-assembly/layer-control/BUS12          ),
    .p14 ( \/lut-assembly/layer-control/BUS13          ),
    .p15 ( \N$/lut-assembly/priority-masks|w299        ),
    .p16 ( \N$/lut-assembly/priority-masks|w300        ),
    .p17 ( \/cps-id/DATA14                             ),
    .p18 ( \/raster-interrupts/counter1/UK             ),
    .p19 ( \N$/lut-assembly/priority-masks|w301        )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UCG383 (
    .p1  ( \N$/lut-assembly/priority-masks|w297     ),
    .p2  ( \N$/lut-assembly/priority-masks|w296     ),
    .p3  ( \N$/lut-assembly/priority-masks|w295     ),
    .p4  ( \N$/lut-assembly/priority-masks|w294     ),
    .p5  ( \N$/lut-assembly/priority-masks|UCG383.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w301     ),
    .p13 ( \N$/lut-assembly/priority-masks|w300     ),
    .p14 ( \N$/lut-assembly/priority-masks|w299     ),
    .p15 ( \N$/lut-assembly/priority-masks|w298     )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UCG466 (
    .p1 ( \/lut-assembly/priority-masks/S3         ),
    .p2 ( \N$/lut-assembly/priority-masks|UCR496.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w366     )
);

capcom_dl0921_M273C lut_assembly_priority_masks_UCJ340 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w302        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p4  ( \/lut-assembly/layer-control/BUS9           ),
    .p5  ( \N$/lut-assembly/priority-masks|w303        ),
    .p6  ( \N$/lut-assembly/priority-masks|w304        ),
    .p7  ( \/lut-assembly/layer-control/BUS10          ),
    .p8  ( \/lut-assembly/layer-control/BUS11          ),
    .p9  ( \N$/lut-assembly/priority-masks|w305        ),
    .p11 ( \N$/lut-assembly/priority-masks|w217        ),
    .p12 ( \N$/lut-assembly/priority-masks|w306        ),
    .p13 ( \/lut-assembly/layer-control/BUS12          ),
    .p14 ( \/lut-assembly/layer-control/BUS13          ),
    .p15 ( \N$/lut-assembly/priority-masks|w307        ),
    .p16 ( \N$/lut-assembly/priority-masks|w308        ),
    .p17 ( \/cps-id/DATA14                             ),
    .p18 ( \/raster-interrupts/counter1/UK             ),
    .p19 ( \N$/lut-assembly/priority-masks|w309        )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UCJ383 (
    .p1  ( \N$/lut-assembly/priority-masks|w305     ),
    .p2  ( \N$/lut-assembly/priority-masks|w304     ),
    .p3  ( \N$/lut-assembly/priority-masks|w303     ),
    .p4  ( \N$/lut-assembly/priority-masks|w302     ),
    .p5  ( \N$/lut-assembly/priority-masks|UCJ383.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w309     ),
    .p13 ( \N$/lut-assembly/priority-masks|w308     ),
    .p14 ( \N$/lut-assembly/priority-masks|w307     ),
    .p15 ( \N$/lut-assembly/priority-masks|w306     )
);

capcom_dl0921_M273C lut_assembly_priority_masks_UCJ486 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w139        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5  ( \N$/lut-assembly/priority-masks|w140        ),
    .p6  ( \N$/lut-assembly/priority-masks|w141        ),
    .p7  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p9  ( \N$/lut-assembly/priority-masks|w142        ),
    .p11 ( \N$/lut-assembly/priority-masks|w291        ),
    .p12 ( \N$/lut-assembly/priority-masks|w143        ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p15 ( \N$/lut-assembly/priority-masks|w144        ),
    .p16 ( \N$/lut-assembly/priority-masks|w145        ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p19 ( \N$/lut-assembly/priority-masks|w146        )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UCL400 (
    .p1 ( \N$/lut-assembly/priority-masks|w363     ),
    .p2 ( \N$/lut-assembly/priority-masks|UCJ383.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w370     )
);

capcom_dl0921_INV01 lut_assembly_priority_masks_UCL446 (
    .p1 ( \/lut-assembly/priority-masks/S3     ),
    .p2 ( \N$/lut-assembly/priority-masks|w363 )
);

capcom_dl0921_TINVBF lut_assembly_priority_masks_UCL487 (
    .p1 ( \/lut-assembly/priority-masks/S3         ),
    .p2 ( \N$/lut-assembly/priority-masks|UCT497.5 ),
    .p3 ( \N$/lut-assembly/priority-masks|w370     )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UCL498 (
    .p1  ( \N$/lut-assembly/priority-masks|w142     ),
    .p2  ( \N$/lut-assembly/priority-masks|w141     ),
    .p3  ( \N$/lut-assembly/priority-masks|w140     ),
    .p4  ( \N$/lut-assembly/priority-masks|w139     ),
    .p5  ( \N$/lut-assembly/priority-masks|UCL498.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w146     ),
    .p13 ( \N$/lut-assembly/priority-masks|w145     ),
    .p14 ( \N$/lut-assembly/priority-masks|w144     ),
    .p15 ( \N$/lut-assembly/priority-masks|w143     )
);

capcom_dl0921_M273C lut_assembly_priority_masks_UCR458 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w123        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5  ( \N$/lut-assembly/priority-masks|w124        ),
    .p6  ( \N$/lut-assembly/priority-masks|w125        ),
    .p7  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p9  ( \N$/lut-assembly/priority-masks|w126        ),
    .p11 ( \N$/lut-assembly/priority-masks|w215        ),
    .p12 ( \N$/lut-assembly/priority-masks|w127        ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p15 ( \N$/lut-assembly/priority-masks|w128        ),
    .p16 ( \N$/lut-assembly/priority-masks|w129        ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p19 ( \N$/lut-assembly/priority-masks|w130        )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UCR496 (
    .p1  ( \N$/lut-assembly/priority-masks|w126     ),
    .p2  ( \N$/lut-assembly/priority-masks|w125     ),
    .p3  ( \N$/lut-assembly/priority-masks|w124     ),
    .p4  ( \N$/lut-assembly/priority-masks|w123     ),
    .p5  ( \N$/lut-assembly/priority-masks|UCR496.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w130     ),
    .p13 ( \N$/lut-assembly/priority-masks|w129     ),
    .p14 ( \N$/lut-assembly/priority-masks|w128     ),
    .p15 ( \N$/lut-assembly/priority-masks|w127     )
);

capcom_dl0921_M273C lut_assembly_priority_masks_UCT459 (
    .p1  ( \/lut-assembly/layer-control/~RESET         ),
    .p2  ( \N$/lut-assembly/priority-masks|w131        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5  ( \N$/lut-assembly/priority-masks|w132        ),
    .p6  ( \N$/lut-assembly/priority-masks|w133        ),
    .p7  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p9  ( \N$/lut-assembly/priority-masks|w134        ),
    .p11 ( \N$/lut-assembly/priority-masks|w217        ),
    .p12 ( \N$/lut-assembly/priority-masks|w135        ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p15 ( \N$/lut-assembly/priority-masks|w136        ),
    .p16 ( \N$/lut-assembly/priority-masks|w137        ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p19 ( \N$/lut-assembly/priority-masks|w138        )
);

capcom_dl0921_M152C lut_assembly_priority_masks_UCT497 (
    .p1  ( \N$/lut-assembly/priority-masks|w134     ),
    .p2  ( \N$/lut-assembly/priority-masks|w133     ),
    .p3  ( \N$/lut-assembly/priority-masks|w132     ),
    .p4  ( \N$/lut-assembly/priority-masks|w131     ),
    .p5  ( \N$/lut-assembly/priority-masks|UCT497.5 ),
    .p9  ( \/lut-assembly/priority-masks/S2         ),
    .p10 ( \/lut-assembly/priority-masks/S1         ),
    .p11 ( \/lut-assembly/priority-masks/S0         ),
    .p12 ( \N$/lut-assembly/priority-masks|w138     ),
    .p13 ( \N$/lut-assembly/priority-masks|w137     ),
    .p14 ( \N$/lut-assembly/priority-masks|w136     ),
    .p15 ( \N$/lut-assembly/priority-masks|w135     )
);

//========================================================================
// lut-assembly/priority-transparency:
//========================================================================
capcom_dl0921_M273C lut_assembly_priority_transparency_UBF48 (
    .p1  ( VCC                                            ),
    .p2  ( \N$/lut-assembly/priority-transparency|UBF48.2 ),
    .p3  ( VCC                                            ),
    .p4  ( \N$/lut-assembly/priority-transparency|w139    ),
    .p5  ( \/lut-assembly/lut-storage/~E1                 ),
    .p6  ( \/lut-assembly/lut-storage/~E2                 ),
    .p7  ( \N$/lut-assembly/priority-transparency|w140    ),
    .p8  ( \N$/lut-assembly/priority-transparency|w141    ),
    .p9  ( \/lut-assembly/lut-storage/~E3                 ),
    .p11 ( \/lut-assembly/lut-storage/CLK                 ),
    .p12 ( \/lut-assembly/lut-storage/~E4                 ),
    .p13 ( \N$/lut-assembly/priority-transparency|w142    ),
    .p14 ( \N$/lut-assembly/priority-transparency|w143    ),
    .p15 ( \/lut-assembly/lut-storage/~E5                 ),
    .p16 ( \/lut-assembly/lut-storage/~E6                 ),
    .p17 ( \N$/lut-assembly/priority-transparency|w144    ),
    .p18 ( \N$/lut-assembly/priority-transparency|w170    ),
    .p19 ( \/lut-assembly/lut-storage/~E7                 )
);

capcom_dl0921_INV01 lut_assembly_priority_transparency_UBF88 (
    .p1 ( \/lut-assembly/layer-draw-order/~R1C1      ),
    .p2 ( \N$/lut-assembly/priority-transparency|w24 )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBF89 (
    .p1 ( \/lut-assembly/layer-draw-order/~R4C1           ),
    .p2 ( \/lut-assembly/layer-draw-order/~R3C1           ),
    .p3 ( \/lut-assembly/layer-draw-order/~R2C1           ),
    .p4 ( \N$/lut-assembly/priority-transparency|w24      ),
    .p5 ( \/lut-assembly/priority-transparency/~SPRITE_R1 )
);

capcom_dl0921_INV01 lut_assembly_priority_transparency_UBF91 (
    .p1 ( \/lut-assembly/layer-draw-order/~R2C1      ),
    .p2 ( \N$/lut-assembly/priority-transparency|w26 )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBF92 (
    .p1 ( \/lut-assembly/layer-draw-order/~R4C1           ),
    .p2 ( \/lut-assembly/layer-draw-order/~R3C1           ),
    .p3 ( \/lut-assembly/layer-draw-order/~R1C1           ),
    .p4 ( \N$/lut-assembly/priority-transparency|w26      ),
    .p5 ( \/lut-assembly/priority-transparency/~SPRITE_R2 )
);

capcom_dl0921_INV01 lut_assembly_priority_transparency_UBF94 (
    .p1 ( \/lut-assembly/layer-draw-order/~R3C1      ),
    .p2 ( \N$/lut-assembly/priority-transparency|w30 )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBF95 (
    .p1 ( \/lut-assembly/layer-draw-order/~R4C1           ),
    .p2 ( \/lut-assembly/layer-draw-order/~R2C1           ),
    .p3 ( \/lut-assembly/layer-draw-order/~R1C1           ),
    .p4 ( \N$/lut-assembly/priority-transparency|w30      ),
    .p5 ( \/lut-assembly/priority-transparency/~SPRITE_R3 )
);

capcom_dl0921_INV01 lut_assembly_priority_transparency_UBF98 (
    .p1 ( \/lut-assembly/layer-draw-order/~R4C1      ),
    .p2 ( \N$/lut-assembly/priority-transparency|w34 )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBF99 (
    .p1 ( \/lut-assembly/layer-draw-order/~R3C1           ),
    .p2 ( \/lut-assembly/layer-draw-order/~R2C1           ),
    .p3 ( \/lut-assembly/layer-draw-order/~R1C1           ),
    .p4 ( \N$/lut-assembly/priority-transparency|w34      ),
    .p5 ( \/lut-assembly/priority-transparency/~SPRITE_R4 )
);

capcom_dl0921_PRIO lut_assembly_priority_transparency_UBH70 (
    .p1  ( \N$/lut-assembly/priority-transparency|w135  ),
    .p2  ( \N$/lut-assembly/priority-transparency|w101  ),
    .p3  ( \N$/lut-assembly/priority-transparency|w105  ),
    .p4  ( \N$/lut-assembly/priority-transparency|w108  ),
    .p5  ( \/lut-assembly/priority-transparency/~ROW5-E ),
    .p6  ( \/lut-assembly/priority-transparency/~ROW6-E ),
    .p7  ( \/lut-assembly/BLANK                         ),
    .p8  ( \N$/lut-assembly/priority-transparency|w139  ),
    .p9  ( \N$/lut-assembly/priority-transparency|w140  ),
    .p10 ( \N$/lut-assembly/priority-transparency|w141  ),
    .p11 ( \N$/lut-assembly/priority-transparency|w142  ),
    .p12 ( \N$/lut-assembly/priority-transparency|w143  ),
    .p13 ( \N$/lut-assembly/priority-transparency|w144  ),
    .p14 ( \N$/lut-assembly/priority-transparency|w170  )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBI108 (
    .p1 ( \/lut-assembly/layer-draw-order/ROW4-D0    ),
    .p2 ( \/lut-assembly/layer-draw-order/ROW4-D1    ),
    .p3 ( \/lut-assembly/layer-draw-order/ROW4-D2    ),
    .p4 ( \/lut-assembly/layer-draw-order/ROW4-D3    ),
    .p5 ( \N$/lut-assembly/priority-transparency|w89 )
);

capcom_dl0921_OAI21 lut_assembly_priority_transparency_UBI110 (
    .p1 ( \N$/lut-assembly/priority-transparency|w89      ),
    .p2 ( \/lut-assembly/priority-transparency/~SPRITE_R4 ),
    .p3 ( \N$/lut-assembly/priority-transparency|w88      ),
    .p4 ( \N$/lut-assembly/priority-transparency|w108     )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBI87 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R4 ),
    .p2  ( VCC                                             ),
    .p3  ( VCC                                             ),
    .p4  ( VCC                                             ),
    .p5  ( VCC                                             ),
    .p6  ( VCC                                             ),
    .p7  ( VCC                                             ),
    .p13 ( \/lut-assembly/priority-masks/S5                ),
    .p14 ( \/lut-assembly/priority-masks/S4                ),
    .p15 ( \/lut-assembly/priority-masks/S3                ),
    .p16 ( \/lut-assembly/priority-masks/S2                ),
    .p17 ( \/lut-assembly/priority-masks/S1                ),
    .p18 ( \/lut-assembly/priority-masks/S0                )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBI99 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R4 ),
    .p2  ( VCC                                             ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW4-D0         ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW4-D1         ),
    .p5  ( \/lut-assembly/layer-draw-order/ROW4-D2         ),
    .p6  ( \/lut-assembly/layer-draw-order/ROW4-D3         ),
    .p7  ( \N$/lut-assembly/priority-transparency|UBI99.7  ),
    .p13 ( \N$/lut-assembly/priority-transparency|UBI99.13 ),
    .p14 ( \/lut-assembly/priority-transparency/OUT10      ),
    .p15 ( \/lut-assembly/priority-transparency/OUT9       ),
    .p16 ( \/lut-assembly/priority-transparency/OUT8       ),
    .p17 ( \/lut-assembly/priority-transparency/OUT7       ),
    .p18 ( \/lut-assembly/priority-transparency/OUT6       )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBIX158 (
    .p1 ( \/lut-assembly/priority-transparency/OUT10       ),
    .p2 ( \/lut-assembly/priority-transparency/OUT9        ),
    .p3 ( \/lut-assembly/priority-transparency/OUT8        ),
    .p4 ( \/lut-assembly/priority-transparency/OUT7        ),
    .p5 ( \N$/lut-assembly/priority-transparency|UBIX158.5 )
);

capcom_dl0921_AND02 lut_assembly_priority_transparency_UBIX164 (
    .p1 ( \/lut-assembly/priority-transparency/OUT6   ),
    .p2 ( \N$/lut-assembly/priority-transparency|w217 ),
    .p3 ( \N$/lut-assembly/priority-transparency|w224 )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBK108 (
    .p1 ( \/lut-assembly/layer-draw-order/ROW3-D3    ),
    .p2 ( \/lut-assembly/layer-draw-order/ROW3-D2    ),
    .p3 ( \/lut-assembly/layer-draw-order/ROW3-D1    ),
    .p4 ( \/lut-assembly/layer-draw-order/ROW3-D0    ),
    .p5 ( \N$/lut-assembly/priority-transparency|w87 )
);

capcom_dl0921_OAI21 lut_assembly_priority_transparency_UBK110 (
    .p1 ( \N$/lut-assembly/priority-transparency|w87      ),
    .p2 ( \/lut-assembly/priority-transparency/~SPRITE_R3 ),
    .p3 ( \N$/lut-assembly/priority-transparency|w88      ),
    .p4 ( \N$/lut-assembly/priority-transparency|w105     )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBK87 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R3 ),
    .p2  ( \/lut-assembly/layer-draw-order/ROW4-D0         ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW4-D1         ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW4-D2         ),
    .p5  ( \/lut-assembly/layer-draw-order/ROW4-D3         ),
    .p6  ( \/lut-assembly/layer-draw-order/ROW4-D9         ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW4-D10        ),
    .p13 ( \/lut-assembly/priority-masks/S5                ),
    .p14 ( \/lut-assembly/priority-masks/S4                ),
    .p15 ( \/lut-assembly/priority-masks/S3                ),
    .p16 ( \/lut-assembly/priority-masks/S2                ),
    .p17 ( \/lut-assembly/priority-masks/S1                ),
    .p18 ( \/lut-assembly/priority-masks/S0                )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBK99 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R3 ),
    .p2  ( \/lut-assembly/layer-draw-order/ROW4-D11        ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW3-D0         ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW3-D1         ),
    .p5  ( \/lut-assembly/layer-draw-order/ROW3-D2         ),
    .p6  ( \/lut-assembly/layer-draw-order/ROW3-D3         ),
    .p7  ( \N$/lut-assembly/priority-transparency|UBK99.7  ),
    .p13 ( \N$/lut-assembly/priority-transparency|UBK99.13 ),
    .p14 ( \/lut-assembly/priority-transparency/OUT10      ),
    .p15 ( \/lut-assembly/priority-transparency/OUT9       ),
    .p16 ( \/lut-assembly/priority-transparency/OUT8       ),
    .p17 ( \/lut-assembly/priority-transparency/OUT7       ),
    .p18 ( \/lut-assembly/priority-transparency/OUT6       )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBKX158 (
    .p1 ( \/lut-assembly/priority-masks/S3            ),
    .p2 ( \/lut-assembly/priority-masks/S2            ),
    .p3 ( \/lut-assembly/priority-masks/S1            ),
    .p4 ( \/lut-assembly/priority-masks/S0            ),
    .p5 ( \N$/lut-assembly/priority-transparency|w217 )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBM108 (
    .p1 ( \/lut-assembly/layer-draw-order/ROW2-D3    ),
    .p2 ( \/lut-assembly/layer-draw-order/ROW2-D2    ),
    .p3 ( \/lut-assembly/layer-draw-order/ROW2-D1    ),
    .p4 ( \/lut-assembly/layer-draw-order/ROW2-D0    ),
    .p5 ( \N$/lut-assembly/priority-transparency|w85 )
);

capcom_dl0921_OAI21 lut_assembly_priority_transparency_UBM110 (
    .p1 ( \N$/lut-assembly/priority-transparency|w85      ),
    .p2 ( \/lut-assembly/priority-transparency/~SPRITE_R2 ),
    .p3 ( \N$/lut-assembly/priority-transparency|w88      ),
    .p4 ( \N$/lut-assembly/priority-transparency|w101     )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBM87 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R2 ),
    .p2  ( \/lut-assembly/layer-draw-order/ROW3-D0         ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW3-D1         ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW3-D2         ),
    .p5  ( \/lut-assembly/layer-draw-order/ROW3-D3         ),
    .p6  ( \/lut-assembly/layer-draw-order/ROW3-D9         ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW3-D10        ),
    .p13 ( \/lut-assembly/priority-masks/S5                ),
    .p14 ( \/lut-assembly/priority-masks/S4                ),
    .p15 ( \/lut-assembly/priority-masks/S3                ),
    .p16 ( \/lut-assembly/priority-masks/S2                ),
    .p17 ( \/lut-assembly/priority-masks/S1                ),
    .p18 ( \/lut-assembly/priority-masks/S0                )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBM99 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R2 ),
    .p2  ( \/lut-assembly/layer-draw-order/ROW3-D11        ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW2-D0         ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW2-D1         ),
    .p5  ( \/lut-assembly/layer-draw-order/ROW2-D2         ),
    .p6  ( \/lut-assembly/layer-draw-order/ROW2-D3         ),
    .p7  ( \N$/lut-assembly/priority-transparency|UBM99.7  ),
    .p13 ( \N$/lut-assembly/priority-transparency|UBM99.13 ),
    .p14 ( \/lut-assembly/priority-transparency/OUT10      ),
    .p15 ( \/lut-assembly/priority-transparency/OUT9       ),
    .p16 ( \/lut-assembly/priority-transparency/OUT8       ),
    .p17 ( \/lut-assembly/priority-transparency/OUT7       ),
    .p18 ( \/lut-assembly/priority-transparency/OUT6       )
);

capcom_dl0921_INV01 lut_assembly_priority_transparency_UBMX159 (
    .p1 ( \/lut-assembly/priority-masks/OUT          ),
    .p2 ( \N$/lut-assembly/priority-transparency|w88 )
);

capcom_dl0921_INV01 lut_assembly_priority_transparency_UBMX160 (
    .p1 ( \/lut-assembly/BLANK                        ),
    .p2 ( \N$/lut-assembly/priority-transparency|w225 )
);

capcom_dl0921_AND02 lut_assembly_priority_transparency_UBMX164 (
    .p1 ( \N$/lut-assembly/priority-transparency|UBIX158.5 ),
    .p2 ( \N$/lut-assembly/priority-transparency|w224      ),
    .p3 ( \N$/lut-assembly/priority-transparency|UBNX164.2 )
);

capcom_dl0921_NAND04 lut_assembly_priority_transparency_UBN108 (
    .p1 ( \/lut-assembly/layer-draw-order/ROW1-D3    ),
    .p2 ( \/lut-assembly/layer-draw-order/ROW1-D2    ),
    .p3 ( \/lut-assembly/layer-draw-order/ROW1-D1    ),
    .p4 ( \/lut-assembly/layer-draw-order/ROW1-D0    ),
    .p5 ( \N$/lut-assembly/priority-transparency|w83 )
);

capcom_dl0921_OAI21 lut_assembly_priority_transparency_UBN110 (
    .p1 ( \N$/lut-assembly/priority-transparency|w83      ),
    .p2 ( \/lut-assembly/priority-transparency/~SPRITE_R1 ),
    .p3 ( \N$/lut-assembly/priority-transparency|w88      ),
    .p4 ( \N$/lut-assembly/priority-transparency|w135     )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBN87 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R1 ),
    .p2  ( \/lut-assembly/layer-draw-order/ROW2-D0         ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW2-D1         ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW2-D2         ),
    .p5  ( \/lut-assembly/layer-draw-order/ROW2-D3         ),
    .p6  ( \/lut-assembly/layer-draw-order/ROW2-D9         ),
    .p7  ( \/lut-assembly/layer-draw-order/ROW2-D10        ),
    .p13 ( \/lut-assembly/priority-masks/S5                ),
    .p14 ( \/lut-assembly/priority-masks/S4                ),
    .p15 ( \/lut-assembly/priority-masks/S3                ),
    .p16 ( \/lut-assembly/priority-masks/S2                ),
    .p17 ( \/lut-assembly/priority-masks/S1                ),
    .p18 ( \/lut-assembly/priority-masks/S0                )
);

capcom_dl0921_M125C_X6 lut_assembly_priority_transparency_UBN99 (
    .p1  ( \/lut-assembly/priority-transparency/~SPRITE_R1 ),
    .p2  ( \/lut-assembly/layer-draw-order/ROW2-D11        ),
    .p3  ( \/lut-assembly/layer-draw-order/ROW1-D0         ),
    .p4  ( \/lut-assembly/layer-draw-order/ROW1-D1         ),
    .p5  ( \/lut-assembly/layer-draw-order/ROW1-D2         ),
    .p6  ( \/lut-assembly/layer-draw-order/ROW1-D3         ),
    .p7  ( \N$/lut-assembly/priority-transparency|UBN99.7  ),
    .p13 ( \N$/lut-assembly/priority-transparency|UBN99.13 ),
    .p14 ( \/lut-assembly/priority-transparency/OUT10      ),
    .p15 ( \/lut-assembly/priority-transparency/OUT9       ),
    .p16 ( \/lut-assembly/priority-transparency/OUT8       ),
    .p17 ( \/lut-assembly/priority-transparency/OUT7       ),
    .p18 ( \/lut-assembly/priority-transparency/OUT6       )
);

capcom_dl0921_AND02 lut_assembly_priority_transparency_UBNX164 (
    .p1 ( \N$/lut-assembly/priority-transparency|w225      ),
    .p2 ( \N$/lut-assembly/priority-transparency|UBNX164.2 ),
    .p3 ( \N$/lut-assembly/priority-transparency|UBNX164.3 )
);

//========================================================================
// lut-counter:
//========================================================================
capcom_dl0921_DFFCOO lut_counter_UBW293 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w80      ),
    .p3 ( \N$/lut-counter|UBW293.3 ),
    .p5 ( \/lut-io/B8              )
);

capcom_dl0921_DFFCOO lut_counter_UBW296 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w84      ),
    .p3 ( \N$/lut-counter|UBW296.3 ),
    .p5 ( \/lut-io/B9              )
);

capcom_dl0921_DFFCOO lut_counter_UBW300 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w86      ),
    .p3 ( \N$/lut-counter|UBW300.3 ),
    .p5 ( \/lut-io/B10             )
);

capcom_dl0921_DFFCOO lut_counter_UBW304 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w82      ),
    .p3 ( \N$/lut-counter|UBW304.3 ),
    .p5 ( \/lut-io/B11             )
);

capcom_dl0921_XNOR02 lut_counter_UBZ292 (
    .p1 ( \/lut-io/B10         ),
    .p2 ( \N$/lut-counter|w255 ),
    .p3 ( \N$/lut-counter|w285 )
);

capcom_dl0921_XOR02 lut_counter_UBZ294 (
    .p1 ( \N$/lut-counter|w237 ),
    .p2 ( \/lut-io/B8          ),
    .p3 ( \N$/lut-counter|w275 )
);

capcom_dl0921_INV01 lut_counter_UBZ298 (
    .p1 ( \N$/lut-counter|w25 ),
    .p2 ( \N$/lut-counter|w38 )
);

capcom_dl0921_M258C lut_counter_UBZ299 (
    .p1  ( \/lut-counter/SET11  ),
    .p2  ( \/lut-counter/SET10  ),
    .p3  ( \/lut-counter/SET9   ),
    .p4  ( GND                  ),
    .p5  ( \N$/lut-counter|w80  ),
    .p6  ( \N$/lut-counter|w84  ),
    .p7  ( \N$/lut-counter|w86  ),
    .p8  ( \N$/lut-counter|w82  ),
    .p9  ( \/lut-counter/~LOAD  ),
    .p10 ( \N$/lut-counter|w288 ),
    .p11 ( \N$/lut-counter|w285 ),
    .p12 ( \N$/lut-counter|w280 ),
    .p13 ( \N$/lut-counter|w275 ),
    .p14 ( \N$/lut-counter|w38  )
);

capcom_dl0921_NAND04 lut_counter_UBZ318 (
    .p1 ( \/lut-io/B2          ),
    .p2 ( \/lut-io/B1          ),
    .p3 ( \/lut-io/B0          ),
    .p4 ( \N$/lut-counter|w211 ),
    .p5 ( \N$/lut-counter|w257 )
);

capcom_dl0921_BUF01 lut_counter_UBZ320 (
    .p1 ( \/lut-counter/INC    ),
    .p2 ( \N$/lut-counter|w211 )
);

capcom_dl0921_INV01 lut_counter_UBZ328 (
    .p1 ( \N$/lut-counter|UBZ329.6 ),
    .p2 ( \N$/lut-counter|UCG328.1 )
);

capcom_dl0921_NAND05 lut_counter_UBZ329 (
    .p1 ( \/lut-io/B0              ),
    .p2 ( \/lut-io/B1              ),
    .p3 ( \/lut-io/B2              ),
    .p4 ( \/lut-io/B3              ),
    .p5 ( \N$/lut-counter|w211     ),
    .p6 ( \N$/lut-counter|UBZ329.6 )
);

capcom_dl0921_XNOR02 lut_counter_UCC275 (
    .p1 ( \/lut-io/B1          ),
    .p2 ( \N$/lut-counter|w243 ),
    .p3 ( \N$/lut-counter|w277 )
);

capcom_dl0921_XOR02 lut_counter_UCC277 (
    .p1 ( \N$/lut-counter|w211 ),
    .p2 ( \/lut-io/B0          ),
    .p3 ( \N$/lut-counter|w271 )
);

capcom_dl0921_NAND03 lut_counter_UCC280 (
    .p1 ( \/lut-io/B1          ),
    .p2 ( \N$/lut-counter|w211 ),
    .p3 ( \/lut-io/B0          ),
    .p4 ( \N$/lut-counter|w245 )
);

capcom_dl0921_NAND03 lut_counter_UCC283 (
    .p1 ( \/lut-io/B9          ),
    .p2 ( \N$/lut-counter|w237 ),
    .p3 ( \/lut-io/B8          ),
    .p4 ( \N$/lut-counter|w255 )
);

capcom_dl0921_DFFCOO lut_counter_UCC293 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w87      ),
    .p3 ( \N$/lut-counter|UCC293.3 ),
    .p5 ( \/lut-io/B0              )
);

capcom_dl0921_DFFCOO lut_counter_UCC296 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w113     ),
    .p3 ( \N$/lut-counter|UCC296.3 ),
    .p5 ( \/lut-io/B1              )
);

capcom_dl0921_DFFCOO lut_counter_UCC300 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w88      ),
    .p3 ( \N$/lut-counter|UCC300.3 ),
    .p5 ( \/lut-io/B2              )
);

capcom_dl0921_DFFCOO lut_counter_UCC304 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w114     ),
    .p3 ( \N$/lut-counter|UCC304.3 ),
    .p5 ( \/lut-io/B3              )
);

capcom_dl0921_NAND02 lut_counter_UCC308 (
    .p1 ( \N$/lut-counter|w70  ),
    .p2 ( \N$/lut-counter|w271 ),
    .p3 ( \N$/lut-counter|w87  )
);

capcom_dl0921_NAND02 lut_counter_UCC310 (
    .p1 ( \N$/lut-counter|w70  ),
    .p2 ( \N$/lut-counter|w277 ),
    .p3 ( \N$/lut-counter|w113 )
);

capcom_dl0921_NAND02 lut_counter_UCC312 (
    .p1 ( \N$/lut-counter|w70  ),
    .p2 ( \N$/lut-counter|w282 ),
    .p3 ( \N$/lut-counter|w88  )
);

capcom_dl0921_NAND02 lut_counter_UCC313 (
    .p1 ( \N$/lut-counter|w70  ),
    .p2 ( \N$/lut-counter|w69  ),
    .p3 ( \N$/lut-counter|w114 )
);

capcom_dl0921_INV01 lut_counter_UCC315 (
    .p1 ( \/counter-fi/~RESET ),
    .p2 ( \N$/lut-counter|w1  )
);

capcom_dl0921_XNOR02 lut_counter_UCC316 (
    .p1 ( \/lut-io/B2          ),
    .p2 ( \N$/lut-counter|w245 ),
    .p3 ( \N$/lut-counter|w282 )
);

capcom_dl0921_XNOR02 lut_counter_UCC319 (
    .p1 ( \/lut-io/B3          ),
    .p2 ( \N$/lut-counter|w257 ),
    .p3 ( \N$/lut-counter|w69  )
);

capcom_dl0921_NAND02 lut_counter_UCG281 (
    .p1 ( \N$/lut-counter|w211 ),
    .p2 ( \/lut-io/B0          ),
    .p3 ( \N$/lut-counter|w243 )
);

capcom_dl0921_BUF01 lut_counter_UCG308 (
    .p1 ( \N$/lut-counter|w291 ),
    .p2 ( \N$/lut-counter|w237 )
);

capcom_dl0921_AND02 lut_counter_UCG309 (
    .p1 ( \/lut-counter/~LOAD ),
    .p2 ( \N$/lut-counter|w25 ),
    .p3 ( \N$/lut-counter|w70 )
);

capcom_dl0921_AOI41 lut_counter_UCG312 (
    .p1 ( \/lut-io/B8          ),
    .p2 ( \N$/lut-counter|w25  ),
    .p3 ( \/lut-io/B9          ),
    .p4 ( \/lut-io/B11         ),
    .p5 ( \N$/lut-counter|w291 ),
    .p6 ( \N$/lut-counter|w1   )
);

capcom_dl0921_NAND04 lut_counter_UCG315 (
    .p1 ( \/lut-io/B10         ),
    .p2 ( \/lut-io/B9          ),
    .p3 ( \/lut-io/B8          ),
    .p4 ( \N$/lut-counter|w237 ),
    .p5 ( \N$/lut-counter|w259 )
);

capcom_dl0921_XNOR02 lut_counter_UCG320 (
    .p1 ( \/lut-io/B11         ),
    .p2 ( \N$/lut-counter|w259 ),
    .p3 ( \N$/lut-counter|w288 )
);

capcom_dl0921_BUF01 lut_counter_UCG328 (
    .p1 ( \N$/lut-counter|UCG328.1 ),
    .p2 ( \N$/lut-counter|w226     )
);

capcom_dl0921_INV01 lut_counter_UCG329 (
    .p1 ( \N$/lut-counter|UCG330.6 ),
    .p2 ( \N$/lut-counter|w291     )
);

capcom_dl0921_NAND05 lut_counter_UCG330 (
    .p1 ( \/lut-io/B4              ),
    .p2 ( \/lut-io/B5              ),
    .p3 ( \/lut-io/B6              ),
    .p4 ( \/lut-io/B7              ),
    .p5 ( \N$/lut-counter|w226     ),
    .p6 ( \N$/lut-counter|UCG330.6 )
);

capcom_dl0921_AND02 lut_counter_UCG334 (
    .p1 ( \/lut-counter/~LOAD ),
    .p2 ( \N$/lut-counter|w25 ),
    .p3 ( \N$/lut-counter|w74 )
);

capcom_dl0921_NAND02 lut_counter_UCJ297 (
    .p1 ( \N$/lut-counter|w237 ),
    .p2 ( \/lut-io/B8          ),
    .p3 ( \N$/lut-counter|w253 )
);

capcom_dl0921_XNOR02 lut_counter_UCJ299 (
    .p1 ( \/lut-io/B9          ),
    .p2 ( \N$/lut-counter|w253 ),
    .p3 ( \N$/lut-counter|w280 )
);

capcom_dl0921_XOR02 lut_counter_UCL310 (
    .p1 ( \N$/lut-counter|w226 ),
    .p2 ( \/lut-io/B4          ),
    .p3 ( \N$/lut-counter|w273 )
);

capcom_dl0921_NAND03 lut_counter_UCO269 (
    .p1 ( \/lut-io/B5          ),
    .p2 ( \N$/lut-counter|w226 ),
    .p3 ( \/lut-io/B4          ),
    .p4 ( \N$/lut-counter|w250 )
);

capcom_dl0921_XNOR02 lut_counter_UCO272 (
    .p1 ( \/lut-io/B6          ),
    .p2 ( \N$/lut-counter|w250 ),
    .p3 ( \N$/lut-counter|w284 )
);

capcom_dl0921_NAND04 lut_counter_UCO274 (
    .p1 ( \/lut-io/B6          ),
    .p2 ( \/lut-io/B5          ),
    .p3 ( \/lut-io/B4          ),
    .p4 ( \N$/lut-counter|w226 ),
    .p5 ( \N$/lut-counter|w258 )
);

capcom_dl0921_NAND02 lut_counter_UCO277 (
    .p1 ( \N$/lut-counter|w226 ),
    .p2 ( \/lut-io/B4          ),
    .p3 ( \N$/lut-counter|w248 )
);

capcom_dl0921_XNOR02 lut_counter_UCO279 (
    .p1 ( \/lut-io/B5          ),
    .p2 ( \N$/lut-counter|w248 ),
    .p3 ( \N$/lut-counter|w279 )
);

capcom_dl0921_NAND02 lut_counter_UCO315 (
    .p1 ( \N$/lut-counter|w74  ),
    .p2 ( \N$/lut-counter|w273 ),
    .p3 ( \N$/lut-counter|w89  )
);

capcom_dl0921_NAND02 lut_counter_UCO317 (
    .p1 ( \N$/lut-counter|w74  ),
    .p2 ( \N$/lut-counter|w279 ),
    .p3 ( \N$/lut-counter|w116 )
);

capcom_dl0921_NAND02 lut_counter_UCO318 (
    .p1 ( \N$/lut-counter|w74  ),
    .p2 ( \N$/lut-counter|w284 ),
    .p3 ( \N$/lut-counter|w90  )
);

capcom_dl0921_NAND02 lut_counter_UCO320 (
    .p1 ( \N$/lut-counter|w74  ),
    .p2 ( \N$/lut-counter|w73  ),
    .p3 ( \N$/lut-counter|w117 )
);

capcom_dl0921_XNOR02 lut_counter_UCO329 (
    .p1 ( \/lut-io/B7          ),
    .p2 ( \N$/lut-counter|w258 ),
    .p3 ( \N$/lut-counter|w73  )
);

capcom_dl0921_DFFCOO lut_counter_UCO335 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w89      ),
    .p3 ( \N$/lut-counter|UCO335.3 ),
    .p5 ( \/lut-io/B4              )
);

capcom_dl0921_DFFCOO lut_counter_UCO339 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w116     ),
    .p3 ( \N$/lut-counter|UCO339.3 ),
    .p5 ( \/lut-io/B5              )
);

capcom_dl0921_DFFCOO lut_counter_UCO343 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w90      ),
    .p3 ( \N$/lut-counter|UCO343.3 ),
    .p5 ( \/lut-io/B6              )
);

capcom_dl0921_DFFCOO lut_counter_UCO347 (
    .p1 ( \/lut-counter/CLK4M      ),
    .p2 ( \N$/lut-counter|w117     ),
    .p3 ( \N$/lut-counter|UCO347.3 ),
    .p5 ( \/lut-io/B7              )
);

//========================================================================
// lut-io:
//========================================================================
capcom_dl0921_BUF01 lut_io_UBH427 (
    .p1 ( \N$/lut-io|w71      ),
    .p2 ( \N$/lut-io|UBH428.1 )
);

capcom_dl0921_BUF01 lut_io_UBH428 (
    .p1 ( \N$/lut-io|UBH428.1 ),
    .p2 ( \N$/lut-io|UBH500.1 )
);

capcom_dl0921_BUF12 lut_io_UBH500 (
    .p1 ( \N$/lut-io|UBH500.1 ),
    .p2 ( \/LUT10             )
);

capcom_dl0921_BUF01 lut_io_UBH503 (
    .p1 ( \N$/lut-io|UBH503.1 ),
    .p2 ( \N$/lut-io|UBH519.1 )
);

capcom_dl0921_BUF01 lut_io_UBH505 (
    .p1 ( \N$/lut-io|w48      ),
    .p2 ( \N$/lut-io|UBH512.1 )
);

capcom_dl0921_BUF01 lut_io_UBH512 (
    .p1 ( \N$/lut-io|UBH512.1 ),
    .p2 ( \N$/lut-io|UBR515.1 )
);

capcom_dl0921_BUF12 lut_io_UBH519 (
    .p1 ( \N$/lut-io|UBH519.1 ),
    .p2 ( \/LUT0              )
);

capcom_dl0921_BUF01 lut_io_UBK454 (
    .p1 ( \N$/lut-io|w46      ),
    .p2 ( \N$/lut-io|UBH503.1 )
);

capcom_dl0921_BUF01 lut_io_UBK498 (
    .p1 ( \N$/lut-io|UBK498.1 ),
    .p2 ( \N$/lut-io|UBK521.1 )
);

capcom_dl0921_BUF12 lut_io_UBK521 (
    .p1 ( \N$/lut-io|UBK521.1 ),
    .p2 ( \/LUT11             )
);

capcom_dl0921_M157C lut_io_UBN328 (
    .p1  ( \/lut-io/A3       ),
    .p2  ( \/lut-io/A2       ),
    .p3  ( \/lut-io/A1       ),
    .p4  ( \/lut-io/A0       ),
    .p5  ( \N$/lut-io|w46    ),
    .p6  ( \N$/lut-io|w58    ),
    .p7  ( \N$/lut-io|w69    ),
    .p8  ( \N$/lut-io|w48    ),
    .p9  ( \/lut-counter/INC ),
    .p10 ( \/lut-io/B3       ),
    .p11 ( \/lut-io/B2       ),
    .p12 ( \/lut-io/B1       ),
    .p13 ( \/lut-io/B0       ),
    .p14 ( \/lut-io/~E       )
);

capcom_dl0921_BUF01 lut_io_UBN355 (
    .p1 ( \N$/lut-io|w69      ),
    .p2 ( \N$/lut-io|UBN477.1 )
);

capcom_dl0921_BUF01 lut_io_UBN416 (
    .p1 ( \N$/lut-io|w58      ),
    .p2 ( \N$/lut-io|UBN441.1 )
);

capcom_dl0921_BUF01 lut_io_UBN441 (
    .p1 ( \N$/lut-io|UBN441.1 ),
    .p2 ( \N$/lut-io|UBR512.1 )
);

capcom_dl0921_BUF01 lut_io_UBN446 (
    .p1 ( \N$/lut-io|w56      ),
    .p2 ( \N$/lut-io|UBK498.1 )
);

capcom_dl0921_BUF01 lut_io_UBN477 (
    .p1 ( \N$/lut-io|UBN477.1 ),
    .p2 ( \N$/lut-io|UBU521.1 )
);

capcom_dl0921_M157C lut_io_UBR383 (
    .p1  ( \/lut-io/A11      ),
    .p2  ( \/lut-io/A10      ),
    .p3  ( \/lut-io/A9       ),
    .p4  ( \/lut-io/A8       ),
    .p5  ( \N$/lut-io|w54    ),
    .p6  ( \N$/lut-io|w66    ),
    .p7  ( \N$/lut-io|w71    ),
    .p8  ( \N$/lut-io|w56    ),
    .p9  ( \/lut-counter/INC ),
    .p10 ( \/lut-io/B11      ),
    .p11 ( \/lut-io/B10      ),
    .p12 ( \/lut-io/B9       ),
    .p13 ( \/lut-io/B8       ),
    .p14 ( \/lut-io/~E       )
);

capcom_dl0921_BUF01 lut_io_UBR487 (
    .p1 ( \N$/lut-io|UBR487.1 ),
    .p2 ( \N$/lut-io|UBR520.1 )
);

capcom_dl0921_BUF01 lut_io_UBR494 (
    .p1 ( \N$/lut-io|w66      ),
    .p2 ( \N$/lut-io|UBR509.1 )
);

capcom_dl0921_BUF01 lut_io_UBR509 (
    .p1 ( \N$/lut-io|UBR509.1 ),
    .p2 ( \N$/lut-io|UBR518.1 )
);

capcom_dl0921_BUF12 lut_io_UBR512 (
    .p1 ( \N$/lut-io|UBR512.1 ),
    .p2 ( \/LUT1              )
);

capcom_dl0921_BUF12 lut_io_UBR515 (
    .p1 ( \N$/lut-io|UBR515.1 ),
    .p2 ( \/LUT3              )
);

capcom_dl0921_BUF12 lut_io_UBR518 (
    .p1 ( \N$/lut-io|UBR518.1 ),
    .p2 ( \/LUT9              )
);

capcom_dl0921_BUF12 lut_io_UBR520 (
    .p1 ( \N$/lut-io|UBR520.1 ),
    .p2 ( \/LUT8              )
);

capcom_dl0921_BUF01 lut_io_UBU412 (
    .p1 ( \N$/lut-io|w54      ),
    .p2 ( \N$/lut-io|UBR487.1 )
);

capcom_dl0921_BUF12 lut_io_UBU519 (
    .p1 ( \N$/lut-io|UBU519.1 ),
    .p2 ( \/LUT7              )
);

capcom_dl0921_BUF12 lut_io_UBU521 (
    .p1 ( \N$/lut-io|UBU521.1 ),
    .p2 ( \/LUT2              )
);

capcom_dl0921_BUF12 lut_io_UBW502 (
    .p1 ( \N$/lut-io|UBW502.1 ),
    .p2 ( \/LUT6              )
);

capcom_dl0921_BUF01 lut_io_UBW504 (
    .p1 ( \N$/lut-io|UBW504.1 ),
    .p2 ( \N$/lut-io|UBU519.1 )
);

capcom_dl0921_BUF12 lut_io_UBW515 (
    .p1 ( \N$/lut-io|UBW515.1 ),
    .p2 ( \/LUT5              )
);

capcom_dl0921_BUF12 lut_io_UBW517 (
    .p1 ( \N$/lut-io|UBW517.1 ),
    .p2 ( \/LUT4              )
);

capcom_dl0921_BUF01 lut_io_UCC420 (
    .p1 ( \N$/lut-io|w52      ),
    .p2 ( \N$/lut-io|UBW504.1 )
);

capcom_dl0921_M157C lut_io_UCG292 (
    .p1  ( \/lut-io/A7       ),
    .p2  ( \/lut-io/A6       ),
    .p3  ( \/lut-io/A5       ),
    .p4  ( \/lut-io/A4       ),
    .p5  ( \N$/lut-io|w50    ),
    .p6  ( \N$/lut-io|w62    ),
    .p7  ( \N$/lut-io|w70    ),
    .p8  ( \N$/lut-io|w52    ),
    .p9  ( \/lut-counter/INC ),
    .p10 ( \/lut-io/B7       ),
    .p11 ( \/lut-io/B6       ),
    .p12 ( \/lut-io/B5       ),
    .p13 ( \/lut-io/B4       ),
    .p14 ( \/lut-io/~E       )
);

capcom_dl0921_BUF01 lut_io_UCG336 (
    .p1 ( \N$/lut-io|w70      ),
    .p2 ( \N$/lut-io|UCG460.1 )
);

capcom_dl0921_BUF01 lut_io_UCG460 (
    .p1 ( \N$/lut-io|UCG460.1 ),
    .p2 ( \N$/lut-io|UBW502.1 )
);

capcom_dl0921_BUF01 lut_io_UCG486 (
    .p1 ( \N$/lut-io|w62      ),
    .p2 ( \N$/lut-io|UCG487.1 )
);

capcom_dl0921_BUF01 lut_io_UCG487 (
    .p1 ( \N$/lut-io|UCG487.1 ),
    .p2 ( \N$/lut-io|UBW515.1 )
);

capcom_dl0921_BUF01 lut_io_UCG490 (
    .p1 ( \N$/lut-io|w50      ),
    .p2 ( \N$/lut-io|UCG502.1 )
);

capcom_dl0921_BUF01 lut_io_UCG502 (
    .p1 ( \N$/lut-io|UCG502.1 ),
    .p2 ( \N$/lut-io|UBW517.1 )
);

//========================================================================
// main-signals:
//========================================================================
capcom_dl0921_NBUF03 main_signals_UBD516 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/main-signals/~CLK8M          )
);

capcom_dl0921_BUF12 main_signals_UBH490 (
    .p1 ( \/main-signals/~RESETI ),
    .p2 ( \/counter-fi/~RESET    )
);

capcom_dl0921_BUF12 main_signals_UBH492 (
    .p1 ( \/main-signals/~RESETI ),
    .p2 ( \/counter-fi/~RESET    )
);

capcom_dl0921_BUF12 main_signals_UBK328 (
    .p1 ( \/counter-fi/~RESET    ),
    .p2 ( \/video-signals/~RESET )
);

capcom_dl0921_BUF01 main_signals_UBN264 (
    .p1 ( \/video-signals/~RESET ),
    .p2 ( \N$/die/UBN264.c1      )
);

capcom_dl0921_BUF01 main_signals_UBN264_u2 (
    .p1 ( \N$/die/UBN264.c1 ),
    .p2 ( \N$/die/UBN264.c2 )
);

capcom_dl0921_BUF01 main_signals_UBN264_u3 (
    .p1 ( \N$/die/UBN264.c2 ),
    .p2 ( \N$/die/UBN264.c3 )
);

capcom_dl0921_BUF01 main_signals_UBN264_u4 (
    .p1 ( \N$/die/UBN264.c3 ),
    .p2 ( \N$/die/UBN264.c4 )
);

capcom_dl0921_BUF01 main_signals_UBN264_u5 (
    .p1 ( \N$/die/UBN264.c4 ),
    .p2 ( \N$/die/UBN264.c5 )
);

capcom_dl0921_BUF01 main_signals_UBN264_u6 (
    .p1 ( \N$/die/UBN264.c5 ),
    .p2 ( \N$/die/UBN264.c6 )
);

capcom_dl0921_BUF01 main_signals_UBN264_u7 (
    .p1 ( \N$/die/UBN264.c6 ),
    .p2 ( \N$/die/UBN264.c7 )
);

capcom_dl0921_BUF01 main_signals_UBN264_u8 (
    .p1 ( \N$/die/UBN264.c7         ),
    .p2 ( \N$/main-signals|UBN362.1 )
);

capcom_dl0921_BUF01 main_signals_UBN362 (
    .p1 ( \N$/main-signals|UBN362.1 ),
    .p2 ( \N$/die/UBN362.c1         )
);

capcom_dl0921_BUF01 main_signals_UBN362_u2 (
    .p1 ( \N$/die/UBN362.c1 ),
    .p2 ( \N$/die/UBN362.c2 )
);

capcom_dl0921_BUF01 main_signals_UBN362_u3 (
    .p1 ( \N$/die/UBN362.c2 ),
    .p2 ( \N$/die/UBN362.c3 )
);

capcom_dl0921_BUF01 main_signals_UBN362_u4 (
    .p1 ( \N$/die/UBN362.c3 ),
    .p2 ( \N$/die/UBN362.c4 )
);

capcom_dl0921_BUF01 main_signals_UBN362_u5 (
    .p1 ( \N$/die/UBN362.c4 ),
    .p2 ( \N$/die/UBN362.c5 )
);

capcom_dl0921_BUF01 main_signals_UBN362_u6 (
    .p1 ( \N$/die/UBN362.c5 ),
    .p2 ( \N$/die/UBN362.c6 )
);

capcom_dl0921_BUF01 main_signals_UBN362_u7 (
    .p1 ( \N$/die/UBN362.c6 ),
    .p2 ( \N$/die/UBN362.c7 )
);

capcom_dl0921_BUF01 main_signals_UBN362_u8 (
    .p1 ( \N$/die/UBN362.c7    ),
    .p2 ( \N$/main-signals|w38 )
);

capcom_dl0921_OR02 main_signals_UBR497 (
    .p1 ( \/lut-assembly/lut-storage/CLK                ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/main-signals|w42                          )
);

capcom_dl0921_DFFCOR main_signals_UBR501 (
    .p1 ( \/main-signals/LI         ),
    .p2 ( \N$/main-signals|w42      ),
    .p3 ( \N$/main-signals|w54      ),
    .p4 ( \/video-signals/~RESET    ),
    .p5 ( \N$/main-signals|UBR501.5 )
);

capcom_dl0921_BUF01 main_signals_UBU414 (
    .p1 ( \N$/main-signals|w38 ),
    .p2 ( \N$/die/UBU414.c1    )
);

capcom_dl0921_BUF01 main_signals_UBU414_u2 (
    .p1 ( \N$/die/UBU414.c1 ),
    .p2 ( \N$/die/UBU414.c2 )
);

capcom_dl0921_BUF01 main_signals_UBU414_u3 (
    .p1 ( \N$/die/UBU414.c2 ),
    .p2 ( \N$/die/UBU414.c3 )
);

capcom_dl0921_BUF01 main_signals_UBU414_u4 (
    .p1 ( \N$/die/UBU414.c3    ),
    .p2 ( \N$/main-signals|w38 )
);

capcom_dl0921_BUF01 main_signals_UBU420 (
    .p1 ( \N$/main-signals|w38 ),
    .p2 ( \N$/die/UBU420.c1    )
);

capcom_dl0921_BUF01 main_signals_UBU420_u2 (
    .p1 ( \N$/die/UBU420.c1 ),
    .p2 ( \N$/die/UBU420.c2 )
);

capcom_dl0921_BUF01 main_signals_UBU420_u3 (
    .p1 ( \N$/die/UBU420.c2 ),
    .p2 ( \N$/die/UBU420.c3 )
);

capcom_dl0921_BUF01 main_signals_UBU420_u4 (
    .p1 ( \N$/die/UBU420.c3    ),
    .p2 ( \N$/main-signals|w38 )
);

capcom_dl0921_BUF12 main_signals_UBW424 (
    .p1 ( \/counter-fi/~RESET ),
    .p2 ( \/cps-id/~RESET     )
);

capcom_dl0921_BUF12 main_signals_UCG457 (
    .p1 ( \N$/main-signals|w80                          ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M )
);

capcom_dl0921_INV01 main_signals_UCG492 (
    .p1 ( \N$/main-signals|w69      ),
    .p2 ( \N$/main-signals|UCG493.1 )
);

capcom_dl0921_DFFCOR main_signals_UCG493 (
    .p1 ( \N$/main-signals|UCG493.1 ),
    .p2 ( \N$/main-signals|w78      ),
    .p3 ( \N$/main-signals|w74      ),
    .p4 ( \N$/main-signals|w73      ),
    .p5 ( \N$/main-signals|w78      )
);

capcom_dl0921_BUF12 main_signals_UCG499 (
    .p1 ( \N$/main-signals|w74 ),
    .p2 ( \N$/main-signals|w80 )
);

capcom_dl0921_NAND04 main_signals_UCG504 (
    .p1 ( \N$/main-signals|w54 ),
    .p2 ( \N$/main-signals|w44 ),
    .p3 ( \N$/main-signals|w53 ),
    .p4 ( \N$/main-signals|w52 ),
    .p5 ( \N$/main-signals|w58 )
);

capcom_dl0921_INV01 main_signals_UCG507 (
    .p1 ( \/main-signals/CLK16M ),
    .p2 ( \N$/main-signals|w57  )
);

capcom_dl0921_NAND02 main_signals_UCG508 (
    .p1 ( \N$/main-signals|w58      ),
    .p2 ( \N$/main-signals|w57      ),
    .p3 ( \N$/main-signals|UCT518.1 )
);

capcom_dl0921_DFFCOR main_signals_UCG511 (
    .p1 ( \/main-signals/CLK16M     ),
    .p2 ( \/main-signals/LI         ),
    .p3 ( \N$/main-signals|w53      ),
    .p4 ( \/video-signals/~RESET    ),
    .p5 ( \N$/main-signals|UCG511.5 )
);

capcom_dl0921_DFFCOR main_signals_UCG516 (
    .p1 ( \/main-signals/CLK16M     ),
    .p2 ( \N$/main-signals|w53      ),
    .p3 ( \N$/main-signals|UCG516.3 ),
    .p4 ( \/video-signals/~RESET    ),
    .p5 ( \N$/main-signals|w44      )
);

capcom_dl0921_BUF12 main_signals_UCJ475 (
    .p1 ( \N$/main-signals|w69           ),
    .p2 ( \/lut-assembly/lut-storage/CLK )
);

capcom_dl0921_INV01 main_signals_UCL448 (
    .p1 ( \N$/main-signals|w38 ),
    .p2 ( \N$/main-signals|w59 )
);

capcom_dl0921_BUF12 main_signals_UCL456 (
    .p1 ( \N$/main-signals|w80                          ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M )
);

capcom_dl0921_BUF12 main_signals_UCL458 (
    .p1 ( \N$/main-signals|w80                          ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M )
);

capcom_dl0921_BUF12 main_signals_UCL496 (
    .p1 ( \N$/main-signals|w69           ),
    .p2 ( \/lut-assembly/lut-storage/CLK )
);

capcom_dl0921_OR02 main_signals_UCO491 (
    .p1 ( \N$/main-signals|w59   ),
    .p2 ( \/video-signals/~RESET ),
    .p3 ( \N$/main-signals|w73   )
);

capcom_dl0921_BUF12 main_signals_UCO494 (
    .p1 ( \N$/main-signals|w69           ),
    .p2 ( \/lut-assembly/lut-storage/CLK )
);

capcom_dl0921_AND02 main_signals_UCR291 (
    .p1 ( \/main-signals/SEC-MODE0 ),
    .p2 ( \/main-signals/SEC-MODE1 ),
    .p3 ( \/main-signals/DEFAULT   )
);

capcom_dl0921_NAND02 main_signals_UCR294 (
    .p1 ( \N$/main-signals|UCR296.2 ),
    .p2 ( \/main-signals/SEC-MODE1  ),
    .p3 ( \N$/main-signals|w52      )
);

capcom_dl0921_INV01 main_signals_UCR296 (
    .p1 ( \/main-signals/SEC-MODE0  ),
    .p2 ( \N$/main-signals|UCR296.2 )
);

capcom_dl0921_BUF12 main_signals_UCT516 (
    .p1 ( \N$/main-signals|w66 ),
    .p2 ( \N$/main-signals|w69 )
);

capcom_dl0921_DFFCOR main_signals_UCT518 (
    .p1 ( \N$/main-signals|UCT518.1 ),
    .p2 ( \N$/main-signals|w65      ),
    .p3 ( \N$/main-signals|w66      ),
    .p4 ( \N$/main-signals|w73      ),
    .p5 ( \N$/main-signals|w65      )
);

//========================================================================
// multiplier:
//========================================================================
capcom_dl0921_MULT multiplier_UAF386 (
    .p1  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p5  ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p6  ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p7  ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p9  ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p10 ( \/lut-assembly/layer-control/BUS9           ),
    .p11 ( \/lut-assembly/layer-control/BUS10          ),
    .p12 ( \/lut-assembly/layer-control/BUS11          ),
    .p13 ( \/lut-assembly/layer-control/BUS12          ),
    .p14 ( \/lut-assembly/layer-control/BUS13          ),
    .p15 ( \/cps-id/DATA14                             ),
    .p16 ( \/raster-interrupts/counter1/UK             ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p19 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p20 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p21 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p22 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p23 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p24 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p25 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p26 ( \/lut-assembly/layer-control/BUS9           ),
    .p27 ( \/lut-assembly/layer-control/BUS10          ),
    .p28 ( \/lut-assembly/layer-control/BUS11          ),
    .p29 ( \/lut-assembly/layer-control/BUS12          ),
    .p30 ( \/lut-assembly/layer-control/BUS13          ),
    .p31 ( \/cps-id/DATA14                             ),
    .p32 ( \/raster-interrupts/counter1/UK             ),
    .p33 ( \N$/multiplier|w50                          ),
    .p34 ( \N$/multiplier|w50                          ),
    .p35 ( \N$/multiplier|w45                          ),
    .p36 ( \N$/multiplier|w100                         ),
    .p37 ( \/lut-assembly/lut-storage/CLK              ),
    .p38 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p39 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p40 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p41 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p42 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p43 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p44 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p45 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p46 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p47 ( \/lut-assembly/layer-control/BUS9           ),
    .p48 ( \/lut-assembly/layer-control/BUS10          ),
    .p49 ( \/lut-assembly/layer-control/BUS11          ),
    .p50 ( \/lut-assembly/layer-control/BUS12          ),
    .p51 ( \/lut-assembly/layer-control/BUS13          ),
    .p52 ( \/cps-id/DATA14                             ),
    .p53 ( \/raster-interrupts/counter1/UK             ),
    .p54 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p55 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p56 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p57 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p58 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p59 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p60 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p61 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p62 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p63 ( \/lut-assembly/layer-control/BUS9           ),
    .p64 ( \/lut-assembly/layer-control/BUS10          ),
    .p65 ( \/lut-assembly/layer-control/BUS11          ),
    .p66 ( \/lut-assembly/layer-control/BUS12          ),
    .p67 ( \/lut-assembly/layer-control/BUS13          ),
    .p68 ( \/cps-id/DATA14                             ),
    .p69 ( \/raster-interrupts/counter1/UK             ),
    .p70 ( \N$/multiplier|w67                          ),
    .p71 ( \N$/multiplier|w121                         ),
    .p72 ( \/lut-assembly/lut-storage/CLK              )
);

capcom_dl0921_DFFCOO multiplier_UBH371 (
    .p1 ( \N$/multiplier|w100             ),
    .p2 ( \/raster-interrupts/counter1/UK ),
    .p3 ( \N$/multiplier|w38              ),
    .p5 ( \N$/multiplier|UBH371.5         )
);

capcom_dl0921_DFFCOO multiplier_UBH388 (
    .p1 ( \N$/multiplier|w45              ),
    .p2 ( \/raster-interrupts/counter1/UK ),
    .p3 ( \N$/multiplier|w39              ),
    .p5 ( \N$/multiplier|UBH388.5         )
);

capcom_dl0921_XOR02 multiplier_UBH463 (
    .p1 ( \N$/multiplier|w38 ),
    .p2 ( \N$/multiplier|w39 ),
    .p3 ( \N$/multiplier|w42 )
);

capcom_dl0921_OR02 multiplier_UBK376 (
    .p1 ( \/lut-assembly/layer-control/WR ),
    .p2 ( \/multiplier/~X-E               ),
    .p3 ( \N$/multiplier|w45              )
);

capcom_dl0921_OR02 multiplier_UBN357 (
    .p1 ( \/raster-interrupts/counter1/RD ),
    .p2 ( \/multiplier/~LSB-E             ),
    .p3 ( \N$/multiplier|w67              )
);

capcom_dl0921_INV01 multiplier_UBN445 (
    .p1 ( \N$/multiplier|w121     ),
    .p2 ( \N$/multiplier|UBN445.2 )
);

capcom_dl0921_DFFCOR multiplier_UBN455 (
    .p1 ( \N$/multiplier|w17                          ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p3 ( \N$/multiplier|w50                          ),
    .p4 ( \/counter-fi/~RESET                         ),
    .p5 ( \N$/multiplier|UBN455.5                     )
);

capcom_dl0921_INV01 multiplier_UBN461 (
    .p1 ( \N$/multiplier|w50      ),
    .p2 ( \N$/multiplier|UBN461.2 )
);

capcom_dl0921_AND02 multiplier_UBN462 (
    .p1 ( \/raster-interrupts/counter1/UK ),
    .p2 ( \N$/multiplier|UBN461.2         ),
    .p3 ( \N$/multiplier|UBN462.3         )
);

capcom_dl0921_MUX2H multiplier_UBN467 (
    .p1 ( \N$/multiplier|w50      ),
    .p2 ( \N$/multiplier|w42      ),
    .p3 ( \N$/multiplier|w42      ),
    .p4 ( \N$/multiplier|UBN467.4 )
);

capcom_dl0921_OR02 multiplier_UBU347 (
    .p1 ( \/lut-assembly/layer-control/WR ),
    .p2 ( \/multiplier/~Y-E               ),
    .p3 ( \N$/multiplier|w100             )
);

capcom_dl0921_OR02 multiplier_UBW387 (
    .p1 ( \/raster-interrupts/counter1/RD ),
    .p2 ( \/multiplier/~MSB-E             ),
    .p3 ( \N$/multiplier|w121             )
);

capcom_dl0921_OR02 multiplier_UBW398 (
    .p1 ( \/lut-assembly/layer-control/WR ),
    .p2 ( \/multiplier/~TC-E              ),
    .p3 ( \N$/multiplier|w17              )
);

//========================================================================
// obj-manager:
//========================================================================
capcom_dl0921_OR02 obj_manager_UCR301 (
    .p1 ( \N$/obj-manager|w27      ),
    .p2 ( \/obj-manager/xpd-bus4/A ),
    .p3 ( \/FAD0                   )
);

capcom_dl0921_OR02 obj_manager_UCR303 (
    .p1 ( \N$/obj-manager|w27      ),
    .p2 ( \/obj-manager/xpd-bus4/B ),
    .p3 ( \/FAD1                   )
);

capcom_dl0921_OR02 obj_manager_UCR305 (
    .p1 ( \N$/obj-manager|w27      ),
    .p2 ( \/obj-manager/xpd-bus4/C ),
    .p3 ( \/FAD2                   )
);

capcom_dl0921_OR02 obj_manager_UCR308 (
    .p1 ( \N$/obj-manager|w27      ),
    .p2 ( \/obj-manager/xpd-bus4/D ),
    .p3 ( \/FAD3                   )
);

capcom_dl0921_OR02 obj_manager_UCR311 (
    .p1 ( \/obj-manager/sd-bus/~A~B ),
    .p2 ( \/obj-manager/xpd-bus4/A  ),
    .p3 ( \/FBD0                    )
);

capcom_dl0921_OR02 obj_manager_UCR313 (
    .p1 ( \/obj-manager/sd-bus/~A~B ),
    .p2 ( \/obj-manager/xpd-bus4/B  ),
    .p3 ( \/FBD1                    )
);

capcom_dl0921_OR02 obj_manager_UCR315 (
    .p1 ( \/obj-manager/sd-bus/~A~B ),
    .p2 ( \/obj-manager/xpd-bus4/C  ),
    .p3 ( \/FBD2                    )
);

capcom_dl0921_OR02 obj_manager_UCR318 (
    .p1 ( \/obj-manager/sd-bus/~A~B ),
    .p2 ( \/obj-manager/xpd-bus4/D  ),
    .p3 ( \/FBD3                    )
);

capcom_dl0921_DBUF obj_manager_UCT310 (
    .p2 ( \/obj-manager/FRAME       ),
    .p3 ( \N$/obj-manager|w27       ),
    .p4 ( \/obj-manager/sd-bus/~A~B )
);

//========================================================================
// obj-manager/sd-bus:
//========================================================================
capcom_dl0921_M125C_X6 obj_manager_sd_bus_UBE0 (
    .p1  ( \/obj-manager/sd-bus/~DEBUG ),
    .p2  ( \/obj-manager/sd-bus/XSD0   ),
    .p3  ( \/obj-manager/sd-bus/XSD1   ),
    .p4  ( \/obj-manager/sd-bus/XSD2   ),
    .p5  ( \/obj-manager/sd-bus/XSD3   ),
    .p6  ( \/obj-manager/sd-bus/XSD4   ),
    .p7  ( \/obj-manager/sd-bus/XSD5   ),
    .p13 ( \/debug/td-io/IN5           ),
    .p14 ( \/debug/td-io/IN4           ),
    .p15 ( \/debug/td-io/IN3           ),
    .p16 ( \/debug/td-io/IN2           ),
    .p17 ( \/debug/td-io/IN1           ),
    .p18 ( \/debug/td-io/IN0           )
);

capcom_dl0921_M125C_X6 obj_manager_sd_bus_UBE12 (
    .p1  ( \/obj-manager/sd-bus/~DEBUG ),
    .p2  ( \/obj-manager/sd-bus/XSD6   ),
    .p3  ( \/obj-manager/sd-bus/XSD7   ),
    .p4  ( \/obj-manager/sd-bus/XSD8   ),
    .p5  ( GND                         ),
    .p6  ( GND                         ),
    .p7  ( GND                         ),
    .p13 ( \/debug/td-io/IN11          ),
    .p14 ( \/debug/td-io/IN10          ),
    .p15 ( \/debug/td-io/IN9           ),
    .p16 ( \/debug/td-io/IN8           ),
    .p17 ( \/debug/td-io/IN7           ),
    .p18 ( \/debug/td-io/IN6           )
);

capcom_dl0921_M273C obj_manager_sd_bus_UCJ404 (
    .p1  ( \N$/obj-manager/sd-bus|w172 ),
    .p2  ( \N$/obj-manager/sd-bus|w92  ),
    .p3  ( \/ASD0                      ),
    .p4  ( \/ASD1                      ),
    .p5  ( \N$/obj-manager/sd-bus|w93  ),
    .p6  ( \N$/obj-manager/sd-bus|w94  ),
    .p7  ( \/ASD2                      ),
    .p8  ( \/ASD3                      ),
    .p9  ( \N$/obj-manager/sd-bus|w95  ),
    .p11 ( \N$/obj-manager/sd-bus|w157 ),
    .p12 ( \N$/obj-manager/sd-bus|w44  ),
    .p13 ( \/ASD4                      ),
    .p14 ( \/ASD5                      ),
    .p15 ( \N$/obj-manager/sd-bus|w45  ),
    .p16 ( \N$/obj-manager/sd-bus|w46  ),
    .p17 ( \/ASD6                      ),
    .p18 ( \/ASD7                      ),
    .p19 ( \N$/obj-manager/sd-bus|w47  )
);

capcom_dl0921_BUF01 obj_manager_sd_bus_UCL404 (
    .p1 ( \/counter-fi/~RESET         ),
    .p2 ( \N$/obj-manager/sd-bus|w172 )
);

capcom_dl0921_M273C obj_manager_sd_bus_UCL408 (
    .p1  ( \N$/obj-manager/sd-bus|w172 ),
    .p2  ( \N$/obj-manager/sd-bus|w53  ),
    .p3  ( \/BSD0                      ),
    .p4  ( \/BSD1                      ),
    .p5  ( \N$/obj-manager/sd-bus|w58  ),
    .p6  ( \N$/obj-manager/sd-bus|w60  ),
    .p7  ( \/BSD2                      ),
    .p8  ( \/BSD3                      ),
    .p9  ( \N$/obj-manager/sd-bus|w65  ),
    .p11 ( \N$/obj-manager/sd-bus|w157 ),
    .p12 ( \N$/obj-manager/sd-bus|w67  ),
    .p13 ( \/BSD4                      ),
    .p14 ( \/BSD5                      ),
    .p15 ( \N$/obj-manager/sd-bus|w69  ),
    .p16 ( \N$/obj-manager/sd-bus|w71  ),
    .p17 ( \/BSD6                      ),
    .p18 ( \/BSD7                      ),
    .p19 ( \N$/obj-manager/sd-bus|w73  )
);

capcom_dl0921_OR02 obj_manager_sd_bus_UCL450 (
    .p1 ( \N$/obj-manager/sd-bus|w134 ),
    .p2 ( \N$/obj-manager/sd-bus|w124 ),
    .p3 ( \N$/obj-manager/sd-bus|w137 )
);

capcom_dl0921_MUX28H obj_manager_sd_bus_UCO404 (
    .p1  ( \N$/obj-manager/sd-bus|w92 ),
    .p2  ( \N$/obj-manager/sd-bus|w93 ),
    .p3  ( \N$/obj-manager/sd-bus|w94 ),
    .p4  ( \N$/obj-manager/sd-bus|w95 ),
    .p5  ( \N$/obj-manager/sd-bus|w44 ),
    .p6  ( \N$/obj-manager/sd-bus|w47 ),
    .p7  ( \N$/obj-manager/sd-bus|w46 ),
    .p8  ( \N$/obj-manager/sd-bus|w45 ),
    .p9  ( \N$/obj-manager/sd-bus|w53 ),
    .p10 ( \N$/obj-manager/sd-bus|w58 ),
    .p11 ( \N$/obj-manager/sd-bus|w60 ),
    .p12 ( \N$/obj-manager/sd-bus|w65 ),
    .p13 ( \N$/obj-manager/sd-bus|w71 ),
    .p14 ( \N$/obj-manager/sd-bus|w67 ),
    .p15 ( \N$/obj-manager/sd-bus|w73 ),
    .p16 ( \N$/obj-manager/sd-bus|w69 ),
    .p17 ( \/obj-manager/sd-bus/XSD0  ),
    .p18 ( \/obj-manager/sd-bus/XSD1  ),
    .p19 ( \/obj-manager/sd-bus/XSD2  ),
    .p20 ( \/obj-manager/sd-bus/XSD3  ),
    .p21 ( \/obj-manager/sd-bus/XSD6  ),
    .p22 ( \/obj-manager/sd-bus/XSD4  ),
    .p23 ( \/obj-manager/sd-bus/XSD5  ),
    .p24 ( \/obj-manager/sd-bus/XSD7  ),
    .p25 ( \/obj-manager/sd-bus/~A~B  )
);

capcom_dl0921_DFFCOR obj_manager_sd_bus_UCO435 (
    .p1 ( \N$/obj-manager/sd-bus|w157     ),
    .p2 ( \N$/obj-manager/sd-bus|w138     ),
    .p3 ( \N$/obj-manager/sd-bus|w178     ),
    .p4 ( \N$/obj-manager/sd-bus|w172     ),
    .p5 ( \N$/obj-manager/sd-bus|UCO435.5 )
);

capcom_dl0921_DFFCOR obj_manager_sd_bus_UCO439 (
    .p1 ( \N$/obj-manager/sd-bus|w157     ),
    .p2 ( \N$/obj-manager/sd-bus|w139     ),
    .p3 ( \N$/obj-manager/sd-bus|w179     ),
    .p4 ( \N$/obj-manager/sd-bus|w172     ),
    .p5 ( \N$/obj-manager/sd-bus|UCO439.5 )
);

capcom_dl0921_DFFCOR obj_manager_sd_bus_UCO444 (
    .p1 ( \N$/obj-manager/sd-bus|w157     ),
    .p2 ( \N$/obj-manager/sd-bus|w137     ),
    .p3 ( \N$/obj-manager/sd-bus|w176     ),
    .p4 ( \N$/obj-manager/sd-bus|w172     ),
    .p5 ( \N$/obj-manager/sd-bus|UCO444.5 )
);

capcom_dl0921_DFFCOR obj_manager_sd_bus_UCO448 (
    .p1 ( \N$/obj-manager/sd-bus|w157     ),
    .p2 ( \N$/obj-manager/sd-bus|w140     ),
    .p3 ( \N$/obj-manager/sd-bus|w180     ),
    .p4 ( \N$/obj-manager/sd-bus|w172     ),
    .p5 ( \N$/obj-manager/sd-bus|UCO448.5 )
);

capcom_dl0921_OR02 obj_manager_sd_bus_UCO455 (
    .p1 ( \N$/obj-manager/sd-bus|w134 ),
    .p2 ( \N$/obj-manager/sd-bus|w135 ),
    .p3 ( \N$/obj-manager/sd-bus|w139 )
);

capcom_dl0921_MUX24H obj_manager_sd_bus_UCO457 (
    .p1  ( \N$/obj-manager/sd-bus|w65  ),
    .p2  ( \N$/obj-manager/sd-bus|w60  ),
    .p3  ( \N$/obj-manager/sd-bus|w58  ),
    .p4  ( \N$/obj-manager/sd-bus|w53  ),
    .p5  ( \N$/obj-manager/sd-bus|w126 ),
    .p6  ( \N$/obj-manager/sd-bus|w135 ),
    .p7  ( \N$/obj-manager/sd-bus|w124 ),
    .p8  ( \N$/obj-manager/sd-bus|w121 ),
    .p9  ( \/obj-manager/sd-bus/~A~B   ),
    .p10 ( \N$/obj-manager/sd-bus|w95  ),
    .p11 ( \N$/obj-manager/sd-bus|w94  ),
    .p12 ( \N$/obj-manager/sd-bus|w93  ),
    .p13 ( \N$/obj-manager/sd-bus|w92  )
);

capcom_dl0921_INV01 obj_manager_sd_bus_UCR425 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \N$/obj-manager/sd-bus|w157    )
);

capcom_dl0921_NAND04 obj_manager_sd_bus_UCR443 (
    .p1 ( \N$/obj-manager/sd-bus|w180 ),
    .p2 ( \N$/obj-manager/sd-bus|w176 ),
    .p3 ( \N$/obj-manager/sd-bus|w179 ),
    .p4 ( \N$/obj-manager/sd-bus|w178 ),
    .p5 ( \/obj-manager/~REWEN        )
);

capcom_dl0921_OR02 obj_manager_sd_bus_UCR451 (
    .p1 ( \N$/obj-manager/sd-bus|w134 ),
    .p2 ( \N$/obj-manager/sd-bus|w126 ),
    .p3 ( \N$/obj-manager/sd-bus|w138 )
);

capcom_dl0921_OR02 obj_manager_sd_bus_UCR453 (
    .p1 ( \N$/obj-manager/sd-bus|w134 ),
    .p2 ( \N$/obj-manager/sd-bus|w121 ),
    .p3 ( \N$/obj-manager/sd-bus|w140 )
);

capcom_dl0921_DFFCOR obj_manager_sd_bus_UCT409 (
    .p1 ( \N$/obj-manager/sd-bus|w157     ),
    .p2 ( \/ASD8                          ),
    .p3 ( \N$/obj-manager/sd-bus|w38      ),
    .p4 ( \N$/obj-manager/sd-bus|w172     ),
    .p5 ( \N$/obj-manager/sd-bus|UCT409.5 )
);

capcom_dl0921_DFFCOR obj_manager_sd_bus_UCT413 (
    .p1 ( \N$/obj-manager/sd-bus|w157     ),
    .p2 ( \/BSD8                          ),
    .p3 ( \N$/obj-manager/sd-bus|w75      ),
    .p4 ( \N$/obj-manager/sd-bus|w172     ),
    .p5 ( \N$/obj-manager/sd-bus|UCT413.5 )
);

capcom_dl0921_DFFCOR obj_manager_sd_bus_UCT418 (
    .p1 ( \N$/obj-manager/sd-bus|w157     ),
    .p2 ( \/obj-manager/OBJEO             ),
    .p3 ( \N$/obj-manager/sd-bus|w134     ),
    .p4 ( \N$/obj-manager/sd-bus|w172     ),
    .p5 ( \N$/obj-manager/sd-bus|UCT418.5 )
);

capcom_dl0921_MUX2H obj_manager_sd_bus_UCT426 (
    .p1 ( \/obj-manager/sd-bus/~A~B  ),
    .p2 ( \N$/obj-manager/sd-bus|w75 ),
    .p3 ( \N$/obj-manager/sd-bus|w38 ),
    .p4 ( \/obj-manager/sd-bus/XSD8  )
);

//========================================================================
// obj-manager/xpd-bus4:
//========================================================================
capcom_dl0921_L8G obj_manager_xpd_bus4_UAE288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \/CPD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w164 ),
    .p4  ( \/CPD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w163 ),
    .p6  ( \/CPD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w162 ),
    .p8  ( \/CPD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w161 ),
    .p10 ( \/CPD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w160 ),
    .p12 ( \/CPD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w159 ),
    .p14 ( \/CPD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w158 ),
    .p16 ( \/CPD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w157 ),
    .p18 ( GND                           )
);

capcom_dl0921_NAND03 obj_manager_xpd_bus4_UAE325 (
    .p1 ( \/lut-assembly/lut-storage/CLK  ),
    .p2 ( \/obj-manager/xpd-bus4/GFX-LOAD ),
    .p3 ( \/bus-signal-control/GFX-CHNL   ),
    .p4 ( \N$/obj-manager/xpd-bus4|w185   )
);

capcom_dl0921_L8G obj_manager_xpd_bus4_UAE327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \/DPD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w132 ),
    .p4  ( \/DPD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w131 ),
    .p6  ( \/DPD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w130 ),
    .p8  ( \/DPD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w129 ),
    .p10 ( \/DPD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w128 ),
    .p12 ( \/DPD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w127 ),
    .p14 ( \/DPD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w126 ),
    .p16 ( \/DPD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w125 ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 obj_manager_xpd_bus4_UAE362 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \N$/obj-manager/xpd-bus4|w384  )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAF288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w164 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w351 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w163 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w339 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w162 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w331 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w161 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w319 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w160 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w309 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w159 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w295 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w158 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w287 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w157 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w275 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w216 )
);

capcom_dl0921_NAND03 obj_manager_xpd_bus4_UAF325 (
    .p1 ( \/lut-assembly/lut-storage/CLK    ),
    .p2 ( \/obj-manager/xpd-bus4/GFX-LOAD   ),
    .p3 ( \N$/obj-manager/xpd-bus4|UAG324.2 ),
    .p4 ( \N$/obj-manager/xpd-bus4|w199     )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAF327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w132 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w345 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w131 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w335 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w130 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w325 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w129 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w315 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w128 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w303 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w127 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w291 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w126 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w281 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w125 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w271 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w216 )
);

capcom_dl0921_L8G obj_manager_xpd_bus4_UAG288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \/CPD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w172 ),
    .p4  ( \/CPD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w171 ),
    .p6  ( \/CPD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w170 ),
    .p8  ( \/CPD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w169 ),
    .p10 ( \/CPD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w168 ),
    .p12 ( \/CPD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w167 ),
    .p14 ( \/CPD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w166 ),
    .p16 ( \/CPD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w165 ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 obj_manager_xpd_bus4_UAG324 (
    .p1 ( \/bus-signal-control/GFX-CHNL     ),
    .p2 ( \N$/obj-manager/xpd-bus4|UAG324.2 )
);

capcom_dl0921_OR02 obj_manager_xpd_bus4_UAG325 (
    .p1 ( \/obj-manager/SERIAL-LOAD        ),
    .p2 ( \/obj-manager/xpd-bus4/XSEL-SYNC ),
    .p3 ( \N$/obj-manager/xpd-bus4|w360    )
);

capcom_dl0921_L8G obj_manager_xpd_bus4_UAG327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \/DPD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w140 ),
    .p4  ( \/DPD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w139 ),
    .p6  ( \/DPD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w138 ),
    .p8  ( \/DPD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w137 ),
    .p10 ( \/DPD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w136 ),
    .p12 ( \/DPD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w135 ),
    .p14 ( \/DPD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w134 ),
    .p16 ( \/DPD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w133 ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 obj_manager_xpd_bus4_UAH324 (
    .p1 ( \N$/obj-manager/xpd-bus4|w217 ),
    .p2 ( \N$/obj-manager/xpd-bus4|w216 )
);

capcom_dl0921_M198C obj_manager_xpd_bus4_UAI287 (
    .p1  ( \N$/obj-manager/xpd-bus4|w275      ),
    .p2  ( \N$/obj-manager/xpd-bus4|w287      ),
    .p3  ( \N$/obj-manager/xpd-bus4|w295      ),
    .p4  ( \N$/obj-manager/xpd-bus4|w309      ),
    .p5  ( \N$/obj-manager/xpd-bus4|w319      ),
    .p6  ( \N$/obj-manager/xpd-bus4|w331      ),
    .p7  ( \N$/obj-manager/xpd-bus4|w339      ),
    .p8  ( VCC                                ),
    .p9  ( \N$/obj-manager/xpd-bus4|w351      ),
    .p10 ( \N$/obj-manager/xpd-bus4|w422      ),
    .p11 ( \N$/obj-manager/xpd-bus4|UAI287.11 ),
    .p12 ( \N$/obj-manager/xpd-bus4|UAI287.12 ),
    .p13 ( \N$/obj-manager/xpd-bus4|UAI287.13 ),
    .p14 ( \N$/obj-manager/xpd-bus4|UAI287.14 ),
    .p15 ( \N$/obj-manager/xpd-bus4|UAI287.15 ),
    .p16 ( \N$/obj-manager/xpd-bus4|UAI287.16 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w399      ),
    .p18 ( VCC                                ),
    .p19 ( \N$/obj-manager/xpd-bus4|w384      ),
    .p20 ( \N$/obj-manager/xpd-bus4|w385      ),
    .p21 ( \N$/obj-manager/xpd-bus4|w360      ),
    .p22 ( \N$/obj-manager/xpd-bus4|w386      )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAI288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w172 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w351 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w171 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w339 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w170 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w331 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w169 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w319 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w168 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w309 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w167 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w295 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w166 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w287 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w165 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w275 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w217 )
);

capcom_dl0921_OR02 obj_manager_xpd_bus4_UAI324 (
    .p1 ( \/obj-manager/SERIAL-LOAD         ),
    .p2 ( \N$/obj-manager/xpd-bus4|UAI326.2 ),
    .p3 ( \N$/obj-manager/xpd-bus4|w385     )
);

capcom_dl0921_M198C obj_manager_xpd_bus4_UAI325 (
    .p1  ( \N$/obj-manager/xpd-bus4|w271      ),
    .p2  ( \N$/obj-manager/xpd-bus4|w281      ),
    .p3  ( \N$/obj-manager/xpd-bus4|w291      ),
    .p4  ( \N$/obj-manager/xpd-bus4|w303      ),
    .p5  ( \N$/obj-manager/xpd-bus4|w315      ),
    .p6  ( \N$/obj-manager/xpd-bus4|w325      ),
    .p7  ( \N$/obj-manager/xpd-bus4|w335      ),
    .p8  ( VCC                                ),
    .p9  ( \N$/obj-manager/xpd-bus4|w345      ),
    .p10 ( \N$/obj-manager/xpd-bus4|w414      ),
    .p11 ( \N$/obj-manager/xpd-bus4|UAI325.11 ),
    .p12 ( \N$/obj-manager/xpd-bus4|UAI325.12 ),
    .p13 ( \N$/obj-manager/xpd-bus4|UAI325.13 ),
    .p14 ( \N$/obj-manager/xpd-bus4|UAI325.14 ),
    .p15 ( \N$/obj-manager/xpd-bus4|UAI325.15 ),
    .p16 ( \N$/obj-manager/xpd-bus4|UAI325.16 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w395      ),
    .p18 ( VCC                                ),
    .p19 ( \N$/obj-manager/xpd-bus4|w384      ),
    .p20 ( \N$/obj-manager/xpd-bus4|w385      ),
    .p21 ( \N$/obj-manager/xpd-bus4|w360      ),
    .p22 ( \N$/obj-manager/xpd-bus4|w386      )
);

capcom_dl0921_INV01 obj_manager_xpd_bus4_UAI326 (
    .p1 ( \/obj-manager/xpd-bus4/XSEL-SYNC  ),
    .p2 ( \N$/obj-manager/xpd-bus4|UAI326.2 )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAI327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w140 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w345 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w139 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w335 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w138 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w325 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w137 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w315 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w136 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w303 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w135 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w291 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w134 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w281 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w133 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w271 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w217 )
);

capcom_dl0921_L8G obj_manager_xpd_bus4_UAL288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \/APD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w148 ),
    .p4  ( \/APD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w147 ),
    .p6  ( \/APD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w146 ),
    .p8  ( \/APD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w145 ),
    .p10 ( \/APD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w144 ),
    .p12 ( \/APD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w143 ),
    .p14 ( \/APD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w142 ),
    .p16 ( \/APD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w141 ),
    .p18 ( GND                           )
);

capcom_dl0921_AO22 obj_manager_xpd_bus4_UAL324 (
    .p1 ( \N$/obj-manager/xpd-bus4|w424 ),
    .p2 ( \N$/obj-manager/xpd-bus4|w428 ),
    .p3 ( \N$/obj-manager/xpd-bus4|w395 ),
    .p4 ( \N$/obj-manager/xpd-bus4|w414 ),
    .p5 ( \/obj-manager/xpd-bus4/D      )
);

capcom_dl0921_L8G obj_manager_xpd_bus4_UAL327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \/BPD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w116 ),
    .p4  ( \/BPD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w115 ),
    .p6  ( \/BPD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w114 ),
    .p8  ( \/BPD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w113 ),
    .p10 ( \/BPD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w112 ),
    .p12 ( \/BPD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w111 ),
    .p14 ( \/BPD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w110 ),
    .p16 ( \/BPD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w109 ),
    .p18 ( GND                           )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAM288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w148 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w348 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w147 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w337 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w146 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w328 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w145 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w317 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w144 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w306 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w143 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w293 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w142 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w284 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w141 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w273 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w216 )
);

capcom_dl0921_AO22 obj_manager_xpd_bus4_UAM324 (
    .p1 ( \N$/obj-manager/xpd-bus4|w424 ),
    .p2 ( \N$/obj-manager/xpd-bus4|w428 ),
    .p3 ( \N$/obj-manager/xpd-bus4|w399 ),
    .p4 ( \N$/obj-manager/xpd-bus4|w422 ),
    .p5 ( \/obj-manager/xpd-bus4/C      )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAM327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w185 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w116 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w342 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w115 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w333 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w114 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w322 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w113 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w313 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w112 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w300 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w111 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w289 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w110 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w278 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w109 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w269 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w216 )
);

capcom_dl0921_INV01 obj_manager_xpd_bus4_UAN287 (
    .p1 ( \N$/obj-manager/xpd-bus4|w428 ),
    .p2 ( \N$/obj-manager/xpd-bus4|w424 )
);

capcom_dl0921_L8G obj_manager_xpd_bus4_UAN288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \/APD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w156 ),
    .p4  ( \/APD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w155 ),
    .p6  ( \/APD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w154 ),
    .p8  ( \/APD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w153 ),
    .p10 ( \/APD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w152 ),
    .p12 ( \/APD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w151 ),
    .p14 ( \/APD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w150 ),
    .p16 ( \/APD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w149 ),
    .p18 ( GND                           )
);

capcom_dl0921_AO22 obj_manager_xpd_bus4_UAN324 (
    .p1 ( \N$/obj-manager/xpd-bus4|w424 ),
    .p2 ( \N$/obj-manager/xpd-bus4|w428 ),
    .p3 ( \N$/obj-manager/xpd-bus4|w393 ),
    .p4 ( \N$/obj-manager/xpd-bus4|w412 ),
    .p5 ( \/obj-manager/xpd-bus4/B      )
);

capcom_dl0921_L8G obj_manager_xpd_bus4_UAN327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \/BPD0                        ),
    .p3  ( \N$/obj-manager/xpd-bus4|w124 ),
    .p4  ( \/BPD1                        ),
    .p5  ( \N$/obj-manager/xpd-bus4|w123 ),
    .p6  ( \/BPD2                        ),
    .p7  ( \N$/obj-manager/xpd-bus4|w122 ),
    .p8  ( \/BPD3                        ),
    .p9  ( \N$/obj-manager/xpd-bus4|w121 ),
    .p10 ( \/BPD4                        ),
    .p11 ( \N$/obj-manager/xpd-bus4|w120 ),
    .p12 ( \/BPD5                        ),
    .p13 ( \N$/obj-manager/xpd-bus4|w119 ),
    .p14 ( \/BPD6                        ),
    .p15 ( \N$/obj-manager/xpd-bus4|w118 ),
    .p16 ( \/BPD7                        ),
    .p17 ( \N$/obj-manager/xpd-bus4|w117 ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 obj_manager_xpd_bus4_UAO287 (
    .p1 ( \/obj-manager/xpd-bus4/XSEL-SYNC ),
    .p2 ( \N$/obj-manager/xpd-bus4|w428    )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAO288 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w156 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w348 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w155 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w337 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w154 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w328 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w153 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w317 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w152 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w306 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w151 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w293 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w150 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w284 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w149 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w273 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w217 )
);

capcom_dl0921_AO22 obj_manager_xpd_bus4_UAO324 (
    .p1 ( \N$/obj-manager/xpd-bus4|w424 ),
    .p2 ( \N$/obj-manager/xpd-bus4|w428 ),
    .p3 ( \N$/obj-manager/xpd-bus4|w397 ),
    .p4 ( \N$/obj-manager/xpd-bus4|w418 ),
    .p5 ( \/obj-manager/xpd-bus4/A      )
);

capcom_dl0921_L8GH obj_manager_xpd_bus4_UAO327 (
    .p1  ( \N$/obj-manager/xpd-bus4|w199 ),
    .p2  ( \N$/obj-manager/xpd-bus4|w124 ),
    .p3  ( \N$/obj-manager/xpd-bus4|w342 ),
    .p4  ( \N$/obj-manager/xpd-bus4|w123 ),
    .p5  ( \N$/obj-manager/xpd-bus4|w333 ),
    .p6  ( \N$/obj-manager/xpd-bus4|w122 ),
    .p7  ( \N$/obj-manager/xpd-bus4|w322 ),
    .p8  ( \N$/obj-manager/xpd-bus4|w121 ),
    .p9  ( \N$/obj-manager/xpd-bus4|w313 ),
    .p10 ( \N$/obj-manager/xpd-bus4|w120 ),
    .p11 ( \N$/obj-manager/xpd-bus4|w300 ),
    .p12 ( \N$/obj-manager/xpd-bus4|w119 ),
    .p13 ( \N$/obj-manager/xpd-bus4|w289 ),
    .p14 ( \N$/obj-manager/xpd-bus4|w118 ),
    .p15 ( \N$/obj-manager/xpd-bus4|w278 ),
    .p16 ( \N$/obj-manager/xpd-bus4|w117 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w269 ),
    .p18 ( \N$/obj-manager/xpd-bus4|w217 )
);

capcom_dl0921_M198C obj_manager_xpd_bus4_UAP287 (
    .p1  ( \N$/obj-manager/xpd-bus4|w273      ),
    .p2  ( \N$/obj-manager/xpd-bus4|w284      ),
    .p3  ( \N$/obj-manager/xpd-bus4|w293      ),
    .p4  ( \N$/obj-manager/xpd-bus4|w306      ),
    .p5  ( \N$/obj-manager/xpd-bus4|w317      ),
    .p6  ( \N$/obj-manager/xpd-bus4|w328      ),
    .p7  ( \N$/obj-manager/xpd-bus4|w337      ),
    .p8  ( VCC                                ),
    .p9  ( \N$/obj-manager/xpd-bus4|w348      ),
    .p10 ( \N$/obj-manager/xpd-bus4|w418      ),
    .p11 ( \N$/obj-manager/xpd-bus4|UAP287.11 ),
    .p12 ( \N$/obj-manager/xpd-bus4|UAP287.12 ),
    .p13 ( \N$/obj-manager/xpd-bus4|UAP287.13 ),
    .p14 ( \N$/obj-manager/xpd-bus4|UAP287.14 ),
    .p15 ( \N$/obj-manager/xpd-bus4|UAP287.15 ),
    .p16 ( \N$/obj-manager/xpd-bus4|UAP287.16 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w397      ),
    .p18 ( VCC                                ),
    .p19 ( \N$/obj-manager/xpd-bus4|w384      ),
    .p20 ( \N$/obj-manager/xpd-bus4|w385      ),
    .p21 ( \N$/obj-manager/xpd-bus4|w360      ),
    .p22 ( \N$/obj-manager/xpd-bus4|w386      )
);

capcom_dl0921_M198C obj_manager_xpd_bus4_UAP325 (
    .p1  ( \N$/obj-manager/xpd-bus4|w269      ),
    .p2  ( \N$/obj-manager/xpd-bus4|w278      ),
    .p3  ( \N$/obj-manager/xpd-bus4|w289      ),
    .p4  ( \N$/obj-manager/xpd-bus4|w300      ),
    .p5  ( \N$/obj-manager/xpd-bus4|w313      ),
    .p6  ( \N$/obj-manager/xpd-bus4|w322      ),
    .p7  ( \N$/obj-manager/xpd-bus4|w333      ),
    .p8  ( VCC                                ),
    .p9  ( \N$/obj-manager/xpd-bus4|w342      ),
    .p10 ( \N$/obj-manager/xpd-bus4|w412      ),
    .p11 ( \N$/obj-manager/xpd-bus4|UAP325.11 ),
    .p12 ( \N$/obj-manager/xpd-bus4|UAP325.12 ),
    .p13 ( \N$/obj-manager/xpd-bus4|UAP325.13 ),
    .p14 ( \N$/obj-manager/xpd-bus4|UAP325.14 ),
    .p15 ( \N$/obj-manager/xpd-bus4|UAP325.15 ),
    .p16 ( \N$/obj-manager/xpd-bus4|UAP325.16 ),
    .p17 ( \N$/obj-manager/xpd-bus4|w393      ),
    .p18 ( VCC                                ),
    .p19 ( \N$/obj-manager/xpd-bus4|w384      ),
    .p20 ( \N$/obj-manager/xpd-bus4|w385      ),
    .p21 ( \N$/obj-manager/xpd-bus4|w360      ),
    .p22 ( \N$/obj-manager/xpd-bus4|w386      )
);

capcom_dl0921_BUF12 obj_manager_xpd_bus4_UAR327 (
    .p1 ( \/counter-fi/~RESET           ),
    .p2 ( \N$/obj-manager/xpd-bus4|w386 )
);

capcom_dl0921_XOR02 obj_manager_xpd_bus4_UAR349 (
    .p1 ( \N$/obj-manager/xpd-bus4|w6   ),
    .p2 ( \/obj-manager/SERIAL-CHNL     ),
    .p3 ( \N$/obj-manager/xpd-bus4|w217 )
);

capcom_dl0921_DFFCOO obj_manager_xpd_bus4_UAR352 (
    .p1 ( \N$/obj-manager/xpd-bus4|w7       ),
    .p2 ( \N$/obj-manager/xpd-bus4|w6       ),
    .p3 ( \/obj-manager/xpd-bus4/XSEL-SYNC  ),
    .p5 ( \N$/obj-manager/xpd-bus4|UAR352.5 )
);

capcom_dl0921_DFFCOO obj_manager_xpd_bus4_UAR357 (
    .p1 ( \N$/obj-manager/xpd-bus4|w199     ),
    .p2 ( \/obj-manager/XSEL                ),
    .p3 ( \N$/obj-manager/xpd-bus4|w6       ),
    .p5 ( \N$/obj-manager/xpd-bus4|UAR357.5 )
);

capcom_dl0921_NAND02 obj_manager_xpd_bus4_UAR361 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/obj-manager/SERIAL-LOAD      ),
    .p3 ( \N$/obj-manager/xpd-bus4|w7    )
);

//========================================================================
// palette-control:
//========================================================================
capcom_dl0921_BUF12 palette_control_UBR491 (
    .p1 ( \N$/palette-control|UBZ473.5 ),
    .p2 ( \/palette-control/~LUT-WR    )
);

capcom_dl0921_NBUF02 palette_control_UBW436 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \/lut-counter/CLK4M                           )
);

capcom_dl0921_OR03 palette_control_UBZ465 (
    .p1 ( \/lut-assembly/layer-control/WR ),
    .p2 ( \/palette-control/~E            ),
    .p3 ( \/lut-counter/CLK4M             ),
    .p4 ( \N$/palette-control|w44         )
);

capcom_dl0921_OAI211 palette_control_UBZ473 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \/lut-counter/INC                             ),
    .p3 ( \N$/palette-control|w189                      ),
    .p4 ( \N$/palette-control|w195                      ),
    .p5 ( \N$/palette-control|UBZ473.5                  )
);

capcom_dl0921_OAI23 palette_control_UCC430 (
    .p1 ( \N$/palette-control|w141 ),
    .p2 ( \N$/palette-control|w159 ),
    .p3 ( \N$/palette-control|w163 ),
    .p4 ( \N$/palette-control|w165 ),
    .p5 ( \N$/palette-control|w116 ),
    .p6 ( \N$/palette-control|w162 ),
    .p7 ( \N$/palette-control|w195 )
);

capcom_dl0921_D38GL palette_control_UCC434 (
    .p1  ( \/lut-io/B9                  ),
    .p2  ( \/lut-io/B10                 ),
    .p3  ( \/lut-io/B11                 ),
    .p4  ( VCC                          ),
    .p5  ( GND                          ),
    .p6  ( GND                          ),
    .p7  ( \N$/palette-control|UCC434.7 ),
    .p9  ( \N$/palette-control|UCC434.9 ),
    .p10 ( \N$/palette-control|w96      ),
    .p11 ( \N$/palette-control|w103     ),
    .p12 ( \N$/palette-control|w108     ),
    .p13 ( \N$/palette-control|w165     ),
    .p14 ( \N$/palette-control|w116     ),
    .p15 ( \N$/palette-control|w162     )
);

capcom_dl0921_INV01 palette_control_UCG430 (
    .p1 ( \N$/palette-control|w147 ),
    .p2 ( \N$/palette-control|w190 )
);

capcom_dl0921_AOI33 palette_control_UCG432 (
    .p1  ( VCC                      ),
    .p2  ( VCC                      ),
    .p3  ( \N$/palette-control|w159 ),
    .p4  ( \/lut-counter/SET9       ),
    .p5  ( VCC                      ),
    .p6  ( \N$/palette-control|w159 ),
    .p7  ( \N$/palette-control|w147 ),
    .p8  ( \N$/palette-control|w185 ),
    .p9  ( \N$/palette-control|w191 ),
    .p10 ( \N$/palette-control|w146 )
);

capcom_dl0921_NOR04 palette_control_UCG437 (
    .p1 ( \/lut-counter/SET11      ),
    .p2 ( \N$/palette-control|w190 ),
    .p3 ( \N$/palette-control|w191 ),
    .p4 ( \N$/palette-control|w178 ),
    .p5 ( \N$/palette-control|w185 )
);

capcom_dl0921_INV01 palette_control_UCG441 (
    .p1 ( \N$/palette-control|w159 ),
    .p2 ( \N$/palette-control|w178 )
);

capcom_dl0921_NOR04 palette_control_UCG442 (
    .p1 ( \/lut-counter/SET10      ),
    .p2 ( \N$/palette-control|w172 ),
    .p3 ( \N$/palette-control|w170 ),
    .p4 ( \N$/palette-control|w178 ),
    .p5 ( \N$/palette-control|w185 )
);

capcom_dl0921_INV01 palette_control_UCG445 (
    .p1 ( \N$/palette-control|w163 ),
    .p2 ( \N$/palette-control|w185 )
);

capcom_dl0921_INV01 palette_control_UCG446 (
    .p1 ( \N$/palette-control|w141 ),
    .p2 ( \N$/palette-control|w191 )
);

capcom_dl0921_AND03 palette_control_UCG447 (
    .p1 ( \N$/palette-control|w141 ),
    .p2 ( \N$/palette-control|w147 ),
    .p3 ( \N$/palette-control|w146 ),
    .p4 ( \N$/palette-control|w170 )
);

capcom_dl0921_INV01 palette_control_UCG451 (
    .p1 ( \N$/palette-control|w120 ),
    .p2 ( \N$/palette-control|w143 )
);

capcom_dl0921_BUF12 palette_control_UCG452 (
    .p1 ( \N$/palette-control|UCG475.3 ),
    .p2 ( \/lut-counter/~LOAD          )
);

capcom_dl0921_AND03 palette_control_UCG454 (
    .p1 ( \N$/palette-control|w141 ),
    .p2 ( \N$/palette-control|w147 ),
    .p3 ( \N$/palette-control|w143 ),
    .p4 ( \N$/palette-control|w172 )
);

capcom_dl0921_INV01 palette_control_UCG459 (
    .p1 ( \N$/palette-control|w168 ),
    .p2 ( \N$/palette-control|w146 )
);

capcom_dl0921_OAI23 palette_control_UCG462 (
    .p1 ( \N$/palette-control|w120 ),
    .p2 ( \N$/palette-control|w168 ),
    .p3 ( \N$/palette-control|w147 ),
    .p4 ( \N$/palette-control|w96  ),
    .p5 ( \N$/palette-control|w103 ),
    .p6 ( \N$/palette-control|w108 ),
    .p7 ( \N$/palette-control|w189 )
);

capcom_dl0921_DFFCOR palette_control_UCG471 (
    .p1 ( \/lut-counter/CLK4M          ),
    .p2 ( \/palette-control/LUTPRO     ),
    .p3 ( \N$/palette-control|w3       ),
    .p4 ( \/counter-fi/~RESET          ),
    .p5 ( \N$/palette-control|UCG471.5 )
);

capcom_dl0921_DFFCOR palette_control_UCG475 (
    .p1 ( \/lut-counter/CLK4M          ),
    .p2 ( \N$/palette-control|w3       ),
    .p3 ( \N$/palette-control|UCG475.3 ),
    .p4 ( \/counter-fi/~RESET          ),
    .p5 ( \N$/palette-control|UCG475.5 )
);

capcom_dl0921_DFFCOR palette_control_UCG480 (
    .p1 ( \/lut-counter/CLK4M          ),
    .p2 ( \/palette-control/WSTLUT     ),
    .p3 ( \/lut-counter/INC            ),
    .p4 ( \/counter-fi/~RESET          ),
    .p5 ( \N$/palette-control|UCG480.5 )
);

capcom_dl0921_DFFCOR palette_control_UCJ446 (
    .p1 ( \N$/palette-control|w44                     ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p3 ( \N$/palette-control|UCJ446.3                ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/palette-control|w120                    )
);

capcom_dl0921_DFFCOR palette_control_UCJ450 (
    .p1 ( \N$/palette-control|w44                     ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p3 ( \N$/palette-control|UCJ450.3                ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/palette-control|w168                    )
);

capcom_dl0921_DFFCOR palette_control_UCJ455 (
    .p1 ( \N$/palette-control|w44                     ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p3 ( \N$/palette-control|UCJ455.3                ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/palette-control|w147                    )
);

capcom_dl0921_DFFCOR palette_control_UCJ459 (
    .p1 ( \N$/palette-control|w44                     ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p3 ( \N$/palette-control|UCJ459.3                ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/palette-control|w141                    )
);

capcom_dl0921_DFFCOR palette_control_UCJ463 (
    .p1 ( \N$/palette-control|w44                     ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p3 ( \N$/palette-control|UCJ463.3                ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/palette-control|w159                    )
);

capcom_dl0921_DFFCOR palette_control_UCJ468 (
    .p1 ( \N$/palette-control|w44                     ),
    .p2 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p3 ( \N$/palette-control|UCJ468.3                ),
    .p4 ( \/lut-assembly/layer-control/~RESET         ),
    .p5 ( \N$/palette-control|w163                    )
);

//========================================================================
// raster-interrupts:
//========================================================================
capcom_dl0921_OR02 raster_interrupts_UBK309 (
    .p1 ( \N$/raster-interrupts|UBK317.3        ),
    .p2 ( \/counter-fi/FI                       ),
    .p3 ( \/raster-interrupts/counter1/SET-~INC )
);

capcom_dl0921_DFFCOO raster_interrupts_UBK317 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \/counter-fi/FI                               ),
    .p3 ( \N$/raster-interrupts|UBK317.3                ),
    .p5 ( \N$/raster-interrupts|UBK317.5                )
);

capcom_dl0921_M541C raster_interrupts_UBR325 (
    .p1  ( \N$/raster-interrupts|UBR325.1     ),
    .p2  ( GND                                ),
    .p3  ( GND                                ),
    .p4  ( GND                                ),
    .p5  ( GND                                ),
    .p6  ( GND                                ),
    .p7  ( GND                                ),
    .p8  ( GND                                ),
    .p9  ( GND                                ),
    .p11 ( \/raster-interrupts/counter1/UK    ),
    .p12 ( \/cps-id/DATA14                    ),
    .p13 ( \/lut-assembly/layer-control/BUS13 ),
    .p14 ( \/lut-assembly/layer-control/BUS12 ),
    .p15 ( \/lut-assembly/layer-control/BUS11 ),
    .p16 ( \/lut-assembly/layer-control/BUS10 ),
    .p17 ( \/lut-assembly/layer-control/BUS9  ),
    .p18 ( \N$/raster-interrupts|UBR325.18    )
);

capcom_dl0921_AND03 raster_interrupts_UBR371 (
    .p1 ( \/raster-interrupts/counter3/~OUT-ENABLE ),
    .p2 ( \/raster-interrupts/counter2/~OUT-ENABLE ),
    .p3 ( \/raster-interrupts/counter1/~OUT-ENABLE ),
    .p4 ( \N$/raster-interrupts|UBR325.1           )
);

capcom_dl0921_BUF12 raster_interrupts_UBR489 (
    .p1 ( \/lut-assembly/layer-control/~RESET ),
    .p2 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOR raster_interrupts_UBW371 (
    .p1 ( \/raster-interrupts/counter3/_OUT0  ),
    .p2 ( \N$/raster-interrupts|UBW371.2      ),
    .p3 ( \N$/raster-interrupts|UBW371.3      ),
    .p4 ( \/raster-interrupts/counter1/~RESET ),
    .p5 ( \N$/raster-interrupts|UBW371.5      )
);

capcom_dl0921_AOI21 raster_interrupts_UBZ353 (
    .p1 ( \/raster-interrupts/counter2/~ZERO ),
    .p2 ( \/raster-interrupts/counter1/~ZERO ),
    .p3 ( \/raster-interrupts/counter3/~ZERO ),
    .p4 ( \N$/raster-interrupts|UBW371.2     )
);

capcom_dl0921_BUF12 raster_interrupts_UCO232 (
    .p1 ( \N$/raster-interrupts|UBW371.3 ),
    .p2 ( \/raster-interrupts/~OBJUP     )
);

//========================================================================
// raster-interrupts/counter1:
//========================================================================
capcom_dl0921_OR03 raster_interrupts_counter1_UBK298 (
    .p1 ( \N$/raster-interrupts/counter1|w284 ),
    .p2 ( \N$/raster-interrupts/counter1|w308 ),
    .p3 ( \N$/raster-interrupts/counter1|w310 ),
    .p4 ( \N$/raster-interrupts/counter1|w256 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBK301 (
    .p1 ( \N$/raster-interrupts/counter1|w312 ),
    .p2 ( \N$/raster-interrupts/counter1|w256 ),
    .p3 ( \N$/raster-interrupts/counter1|w279 )
);

capcom_dl0921_NOR05 raster_interrupts_counter1_UBK304 (
    .p1 ( \N$/raster-interrupts/counter1|UBK304.1 ),
    .p2 ( \N$/raster-interrupts/counter1|w284     ),
    .p3 ( \N$/raster-interrupts/counter1|w308     ),
    .p4 ( \N$/raster-interrupts/counter1|w312     ),
    .p5 ( \N$/raster-interrupts/counter1|w310     ),
    .p6 ( \N$/raster-interrupts/counter1|w314     )
);

capcom_dl0921_INV01 raster_interrupts_counter1_UBK308 (
    .p1 ( \N$/raster-interrupts/counter1|UBK304.1 ),
    .p2 ( \N$/raster-interrupts/counter1|w208     )
);

capcom_dl0921_OR04 raster_interrupts_counter1_UBK312 (
    .p1 ( \N$/raster-interrupts/counter1|w258 ),
    .p2 ( \N$/raster-interrupts/counter1|w284 ),
    .p3 ( \N$/raster-interrupts/counter1|w308 ),
    .p4 ( \N$/raster-interrupts/counter1|w310 ),
    .p5 ( \N$/raster-interrupts/counter1|w312 )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBK344 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w284         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBK349 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w308         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBK355 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w310         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBK361 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w312         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBK367 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w314         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBN295 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w97  ),
    .p3 ( \N$/raster-interrupts/counter1|w284 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBN299 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w99  ),
    .p3 ( \N$/raster-interrupts/counter1|w308 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBN304 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w104 ),
    .p3 ( \N$/raster-interrupts/counter1|w310 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBN308 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w108 ),
    .p3 ( \N$/raster-interrupts/counter1|w312 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBN313 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w125 ),
    .p3 ( \N$/raster-interrupts/counter1|w314 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBN319 (
    .p1 ( \N$/raster-interrupts/counter1|w314 ),
    .p2 ( \N$/raster-interrupts/counter1|w258 ),
    .p3 ( \N$/raster-interrupts/counter1|w86  )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBR192 (
    .p1 ( \N$/raster-interrupts/counter1|w288 ),
    .p2 ( \N$/raster-interrupts/counter1|w262 ),
    .p3 ( \N$/raster-interrupts/counter1|w276 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBR293 (
    .p1 ( \N$/raster-interrupts/counter1|w284 ),
    .p2 ( \N$/raster-interrupts/counter1|w308 ),
    .p3 ( \N$/raster-interrupts/counter1|w85  )
);

capcom_dl0921_OR02 raster_interrupts_counter1_UBR296 (
    .p1 ( \N$/raster-interrupts/counter1|w308 ),
    .p2 ( \N$/raster-interrupts/counter1|w284 ),
    .p3 ( \N$/raster-interrupts/counter1|w254 )
);

capcom_dl0921_INV01 raster_interrupts_counter1_UBR298 (
    .p1 ( \N$/raster-interrupts/counter1|w284 ),
    .p2 ( \N$/raster-interrupts/counter1|w271 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBR300 (
    .p1 ( \N$/raster-interrupts/counter1|w310 ),
    .p2 ( \N$/raster-interrupts/counter1|w254 ),
    .p3 ( \N$/raster-interrupts/counter1|w277 )
);

capcom_dl0921_MUX25H raster_interrupts_counter1_UBR302 (
    .p1  ( \N$/raster-interrupts/counter1|w36  ),
    .p2  ( \N$/raster-interrupts/counter1|w37  ),
    .p3  ( \N$/raster-interrupts/counter1|w35  ),
    .p4  ( \N$/raster-interrupts/counter1|w34  ),
    .p5  ( \N$/raster-interrupts/counter1|w33  ),
    .p6  ( \N$/raster-interrupts/counter1|w97  ),
    .p7  ( \N$/raster-interrupts/counter1|w99  ),
    .p8  ( \N$/raster-interrupts/counter1|w104 ),
    .p9  ( \N$/raster-interrupts/counter1|w108 ),
    .p10 ( \N$/raster-interrupts/counter1|w125 ),
    .p11 ( \N$/raster-interrupts/counter1|w84  ),
    .p12 ( \N$/raster-interrupts/counter1|w279 ),
    .p13 ( \N$/raster-interrupts/counter1|w86  ),
    .p14 ( \N$/raster-interrupts/counter1|w277 ),
    .p15 ( \N$/raster-interrupts/counter1|w85  ),
    .p16 ( \N$/raster-interrupts/counter1|w271 )
);

capcom_dl0921_NOR02 raster_interrupts_counter1_UBR365 (
    .p1 ( \/raster-interrupts/counter1/ENABLE ),
    .p2 ( \/lut-assembly/layer-control/WR     ),
    .p3 ( \N$/raster-interrupts/counter1|w23  )
);

capcom_dl0921_OR02 raster_interrupts_counter1_UBR367 (
    .p1 ( \/raster-interrupts/counter1/RD          ),
    .p2 ( \/raster-interrupts/counter1/ENABLE      ),
    .p3 ( \/raster-interrupts/counter1/~OUT-ENABLE )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBU161 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w101 ),
    .p3 ( \N$/raster-interrupts/counter1|w194 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBU165 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w106 ),
    .p3 ( \N$/raster-interrupts/counter1|w294 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBU170 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w110 ),
    .p3 ( \N$/raster-interrupts/counter1|w291 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter1_UBU174 (
    .p1 ( \N$/raster-interrupts/counter1|w129 ),
    .p2 ( \N$/raster-interrupts/counter1|w94  ),
    .p3 ( \N$/raster-interrupts/counter1|w288 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOR raster_interrupts_counter1_UBU271 (
    .p1 ( \N$/raster-interrupts/counter1|w42      ),
    .p2 ( \/raster-interrupts/counter1/UK         ),
    .p3 ( \N$/raster-interrupts/counter1|w55      ),
    .p4 ( \/raster-interrupts/counter1/~RESET     ),
    .p5 ( \N$/raster-interrupts/counter1|UBU271.5 )
);

capcom_dl0921_AOI21 raster_interrupts_counter1_UBU291 (
    .p1 ( \N$/raster-interrupts/counter1|w23  ),
    .p2 ( \N$/raster-interrupts/counter1|w55  ),
    .p3 ( \/main-signals/LI                   ),
    .p4 ( \N$/raster-interrupts/counter1|w129 )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBU298 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w194         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBU303 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w294         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBU309 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w291         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter1_UBU315 (
    .p1 ( \N$/raster-interrupts/counter1|w306         ),
    .p2 ( \N$/raster-interrupts/counter1|w288         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p5 ( \/raster-interrupts/counter1/~OUT-ENABLE    )
);

capcom_dl0921_R52 raster_interrupts_counter1_UBU329 (
    .p1  ( \N$/raster-interrupts/counter1|w23  ),
    .p2  ( \/raster-interrupts/counter1/~RESET ),
    .p3  ( \/raster-interrupts/counter1/~BUS0  ),
    .p4  ( \/raster-interrupts/counter1/~BUS1  ),
    .p5  ( \/raster-interrupts/counter1/~BUS2  ),
    .p6  ( \/raster-interrupts/counter1/~BUS3  ),
    .p7  ( \/raster-interrupts/counter1/~BUS4  ),
    .p8  ( \N$/raster-interrupts/counter1|w33  ),
    .p9  ( \N$/raster-interrupts/counter1|w34  ),
    .p10 ( \N$/raster-interrupts/counter1|w35  ),
    .p11 ( \N$/raster-interrupts/counter1|w36  ),
    .p12 ( \N$/raster-interrupts/counter1|w37  )
);

capcom_dl0921_R42 raster_interrupts_counter1_UBU349 (
    .p1  ( \N$/raster-interrupts/counter1|w23  ),
    .p2  ( \/raster-interrupts/counter1/~RESET ),
    .p3  ( \/raster-interrupts/counter1/~BUS5  ),
    .p4  ( \/raster-interrupts/counter1/~BUS6  ),
    .p5  ( \/raster-interrupts/counter1/~BUS7  ),
    .p6  ( \/raster-interrupts/counter1/~BUS8  ),
    .p7  ( \N$/raster-interrupts/counter1|w38  ),
    .p8  ( \N$/raster-interrupts/counter1|w39  ),
    .p9  ( \N$/raster-interrupts/counter1|w40  ),
    .p10 ( \N$/raster-interrupts/counter1|w41  )
);

capcom_dl0921_NAND02 raster_interrupts_counter1_UBU367 (
    .p1 ( \/raster-interrupts/counter1/~OUT-ENABLE      ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/raster-interrupts/counter1|w306           )
);

capcom_dl0921_OR02 raster_interrupts_counter1_UBW110 (
    .p1 ( \N$/raster-interrupts/counter1|w194 ),
    .p2 ( \N$/raster-interrupts/counter1|w208 ),
    .p3 ( \N$/raster-interrupts/counter1|w260 )
);

capcom_dl0921_OR03 raster_interrupts_counter1_UBW119 (
    .p1 ( \N$/raster-interrupts/counter1|w208 ),
    .p2 ( \N$/raster-interrupts/counter1|w194 ),
    .p3 ( \N$/raster-interrupts/counter1|w294 ),
    .p4 ( \N$/raster-interrupts/counter1|w261 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBW122 (
    .p1 ( \N$/raster-interrupts/counter1|w291 ),
    .p2 ( \N$/raster-interrupts/counter1|w261 ),
    .p3 ( \N$/raster-interrupts/counter1|w278 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBW127 (
    .p1 ( \N$/raster-interrupts/counter1|w294 ),
    .p2 ( \N$/raster-interrupts/counter1|w260 ),
    .p3 ( \N$/raster-interrupts/counter1|w280 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter1_UBW146 (
    .p1 ( \N$/raster-interrupts/counter1|w208 ),
    .p2 ( \N$/raster-interrupts/counter1|w194 ),
    .p3 ( \N$/raster-interrupts/counter1|w282 )
);

capcom_dl0921_MUX24H raster_interrupts_counter1_UBW160 (
    .p1  ( \N$/raster-interrupts/counter1|w41  ),
    .p2  ( \N$/raster-interrupts/counter1|w40  ),
    .p3  ( \N$/raster-interrupts/counter1|w39  ),
    .p4  ( \N$/raster-interrupts/counter1|w38  ),
    .p5  ( \N$/raster-interrupts/counter1|w101 ),
    .p6  ( \N$/raster-interrupts/counter1|w106 ),
    .p7  ( \N$/raster-interrupts/counter1|w110 ),
    .p8  ( \N$/raster-interrupts/counter1|w94  ),
    .p9  ( \N$/raster-interrupts/counter1|w84  ),
    .p10 ( \N$/raster-interrupts/counter1|w276 ),
    .p11 ( \N$/raster-interrupts/counter1|w278 ),
    .p12 ( \N$/raster-interrupts/counter1|w280 ),
    .p13 ( \N$/raster-interrupts/counter1|w282 )
);

capcom_dl0921_OR04 raster_interrupts_counter1_UBW217 (
    .p1 ( \N$/raster-interrupts/counter1|w262 ),
    .p2 ( \N$/raster-interrupts/counter1|w208 ),
    .p3 ( \N$/raster-interrupts/counter1|w194 ),
    .p4 ( \N$/raster-interrupts/counter1|w294 ),
    .p5 ( \N$/raster-interrupts/counter1|w291 )
);

capcom_dl0921_INV01 raster_interrupts_counter1_UBW274 (
    .p1 ( \N$/raster-interrupts/counter1|w23 ),
    .p2 ( \N$/raster-interrupts/counter1|w42 )
);

capcom_dl0921_AOI21 raster_interrupts_counter1_UBW310 (
    .p1 ( \N$/raster-interrupts/counter1|w49    ),
    .p2 ( \N$/raster-interrupts/counter1|w56    ),
    .p3 ( \/raster-interrupts/counter1/SET-~INC ),
    .p4 ( \N$/raster-interrupts/counter1|w84    )
);

capcom_dl0921_DFFCOO raster_interrupts_counter1_UBW314 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/raster-interrupts/counter1|w55            ),
    .p3 ( \N$/raster-interrupts/counter1|w56            ),
    .p5 ( \N$/raster-interrupts/counter1|UBW314.5       )
);

capcom_dl0921_DFFCOO raster_interrupts_counter1_UBW318 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/raster-interrupts/counter1|w23            ),
    .p3 ( \N$/raster-interrupts/counter1|w49            ),
    .p5 ( \N$/raster-interrupts/counter1|UBW318.5       )
);

capcom_dl0921_INV01 raster_interrupts_counter1_UBZ192 (
    .p1 ( \N$/raster-interrupts/counter1|UBZ193.1 ),
    .p2 ( \/raster-interrupts/counter1/~ZERO      )
);

capcom_dl0921_NOR05 raster_interrupts_counter1_UBZ193 (
    .p1 ( \N$/raster-interrupts/counter1|UBZ193.1 ),
    .p2 ( \N$/raster-interrupts/counter1|w208     ),
    .p3 ( \N$/raster-interrupts/counter1|w194     ),
    .p4 ( \N$/raster-interrupts/counter1|w291     ),
    .p5 ( \N$/raster-interrupts/counter1|w294     ),
    .p6 ( \N$/raster-interrupts/counter1|w288     )
);

//========================================================================
// raster-interrupts/counter2:
//========================================================================
capcom_dl0921_DFFCOS raster_interrupts_counter2_UBD342 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w96  ),
    .p3 ( \N$/raster-interrupts/counter2|w284 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UBD346 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w98  ),
    .p3 ( \N$/raster-interrupts/counter2|w308 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UBD351 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w103 ),
    .p3 ( \N$/raster-interrupts/counter2|w310 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UBD355 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w107 ),
    .p3 ( \N$/raster-interrupts/counter2|w312 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UBD360 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w124 ),
    .p3 ( \N$/raster-interrupts/counter2|w314 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_OR03 raster_interrupts_counter2_UBD372 (
    .p1 ( \N$/raster-interrupts/counter2|w284 ),
    .p2 ( \N$/raster-interrupts/counter2|w308 ),
    .p3 ( \N$/raster-interrupts/counter2|w310 ),
    .p4 ( \N$/raster-interrupts/counter2|w256 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UBD400 (
    .p1 ( \N$/raster-interrupts/counter2|w312 ),
    .p2 ( \N$/raster-interrupts/counter2|w256 ),
    .p3 ( \N$/raster-interrupts/counter2|w279 )
);

capcom_dl0921_OR04 raster_interrupts_counter2_UBD411 (
    .p1 ( \N$/raster-interrupts/counter2|w258 ),
    .p2 ( \N$/raster-interrupts/counter2|w284 ),
    .p3 ( \N$/raster-interrupts/counter2|w308 ),
    .p4 ( \N$/raster-interrupts/counter2|w310 ),
    .p5 ( \N$/raster-interrupts/counter2|w312 )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBD484 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w284         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBD490 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w308         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBD495 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w310         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBD501 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w312         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBD507 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w314         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UBH318 (
    .p1 ( \N$/raster-interrupts/counter2|w284 ),
    .p2 ( \N$/raster-interrupts/counter2|w308 ),
    .p3 ( \N$/raster-interrupts/counter2|w84  )
);

capcom_dl0921_OR02 raster_interrupts_counter2_UBH320 (
    .p1 ( \N$/raster-interrupts/counter2|w308 ),
    .p2 ( \N$/raster-interrupts/counter2|w284 ),
    .p3 ( \N$/raster-interrupts/counter2|w254 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UBH333 (
    .p1 ( \N$/raster-interrupts/counter2|w310 ),
    .p2 ( \N$/raster-interrupts/counter2|w254 ),
    .p3 ( \N$/raster-interrupts/counter2|w277 )
);

capcom_dl0921_INV01 raster_interrupts_counter2_UBH335 (
    .p1 ( \N$/raster-interrupts/counter2|w284 ),
    .p2 ( \N$/raster-interrupts/counter2|w271 )
);

capcom_dl0921_MUX25H raster_interrupts_counter2_UBH336 (
    .p1  ( \N$/raster-interrupts/counter2|w35  ),
    .p2  ( \N$/raster-interrupts/counter2|w36  ),
    .p3  ( \N$/raster-interrupts/counter2|w34  ),
    .p4  ( \N$/raster-interrupts/counter2|w33  ),
    .p5  ( \N$/raster-interrupts/counter2|w32  ),
    .p6  ( \N$/raster-interrupts/counter2|w96  ),
    .p7  ( \N$/raster-interrupts/counter2|w98  ),
    .p8  ( \N$/raster-interrupts/counter2|w103 ),
    .p9  ( \N$/raster-interrupts/counter2|w107 ),
    .p10 ( \N$/raster-interrupts/counter2|w124 ),
    .p11 ( \N$/raster-interrupts/counter2|w83  ),
    .p12 ( \N$/raster-interrupts/counter2|w279 ),
    .p13 ( \N$/raster-interrupts/counter2|w85  ),
    .p14 ( \N$/raster-interrupts/counter2|w277 ),
    .p15 ( \N$/raster-interrupts/counter2|w84  ),
    .p16 ( \N$/raster-interrupts/counter2|w271 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UBH424 (
    .p1 ( \N$/raster-interrupts/counter2|w314 ),
    .p2 ( \N$/raster-interrupts/counter2|w258 ),
    .p3 ( \N$/raster-interrupts/counter2|w85  )
);

capcom_dl0921_NOR05 raster_interrupts_counter2_UBH481 (
    .p1 ( \N$/raster-interrupts/counter2|UBH481.1 ),
    .p2 ( \N$/raster-interrupts/counter2|w284     ),
    .p3 ( \N$/raster-interrupts/counter2|w308     ),
    .p4 ( \N$/raster-interrupts/counter2|w312     ),
    .p5 ( \N$/raster-interrupts/counter2|w310     ),
    .p6 ( \N$/raster-interrupts/counter2|w314     )
);

capcom_dl0921_NAND02 raster_interrupts_counter2_UBH485 (
    .p1 ( \/raster-interrupts/counter2/~OUT-ENABLE      ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/raster-interrupts/counter2|w306           )
);

capcom_dl0921_DFFCOR raster_interrupts_counter2_UBU279 (
    .p1 ( \N$/raster-interrupts/counter2|w41      ),
    .p2 ( \/raster-interrupts/counter1/UK         ),
    .p3 ( \N$/raster-interrupts/counter2|w54      ),
    .p4 ( \/raster-interrupts/counter1/~RESET     ),
    .p5 ( \N$/raster-interrupts/counter2|UBU279.5 )
);

capcom_dl0921_AOI21 raster_interrupts_counter2_UBW272 (
    .p1 ( \N$/raster-interrupts/counter2|w23  ),
    .p2 ( \N$/raster-interrupts/counter2|w54  ),
    .p3 ( \/main-signals/LI                   ),
    .p4 ( \N$/raster-interrupts/counter2|w128 )
);

capcom_dl0921_INV01 raster_interrupts_counter2_UBW283 (
    .p1 ( \N$/raster-interrupts/counter2|w23 ),
    .p2 ( \N$/raster-interrupts/counter2|w41 )
);

capcom_dl0921_AOI21 raster_interrupts_counter2_UBW308 (
    .p1 ( \N$/raster-interrupts/counter2|w49    ),
    .p2 ( \N$/raster-interrupts/counter2|w55    ),
    .p3 ( \/raster-interrupts/counter1/SET-~INC ),
    .p4 ( \N$/raster-interrupts/counter2|w83    )
);

capcom_dl0921_R52 raster_interrupts_counter2_UBW347 (
    .p1  ( \N$/raster-interrupts/counter2|w23  ),
    .p2  ( \/raster-interrupts/counter1/~RESET ),
    .p3  ( \/raster-interrupts/counter1/~BUS0  ),
    .p4  ( \/raster-interrupts/counter1/~BUS1  ),
    .p5  ( \/raster-interrupts/counter1/~BUS2  ),
    .p6  ( \/raster-interrupts/counter1/~BUS3  ),
    .p7  ( \/raster-interrupts/counter1/~BUS4  ),
    .p8  ( \N$/raster-interrupts/counter2|w32  ),
    .p9  ( \N$/raster-interrupts/counter2|w33  ),
    .p10 ( \N$/raster-interrupts/counter2|w34  ),
    .p11 ( \N$/raster-interrupts/counter2|w35  ),
    .p12 ( \N$/raster-interrupts/counter2|w36  )
);

capcom_dl0921_OR02 raster_interrupts_counter2_UBW410 (
    .p1 ( \/raster-interrupts/counter1/RD          ),
    .p2 ( \/raster-interrupts/counter2/ENABLE      ),
    .p3 ( \/raster-interrupts/counter2/~OUT-ENABLE )
);

capcom_dl0921_DFFCOO raster_interrupts_counter2_UBZ277 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/raster-interrupts/counter2|w54            ),
    .p3 ( \N$/raster-interrupts/counter2|w55            ),
    .p5 ( \N$/raster-interrupts/counter2|UBZ277.5       )
);

capcom_dl0921_DFFCOO raster_interrupts_counter2_UBZ281 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/raster-interrupts/counter2|w23            ),
    .p3 ( \N$/raster-interrupts/counter2|w49            ),
    .p5 ( \N$/raster-interrupts/counter2|UBZ281.5       )
);

capcom_dl0921_NOR02 raster_interrupts_counter2_UBZ313 (
    .p1 ( \/raster-interrupts/counter2/ENABLE ),
    .p2 ( \/lut-assembly/layer-control/WR     ),
    .p3 ( \N$/raster-interrupts/counter2|w23  )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBZ498 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w194         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBZ504 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w294         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBZ509 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w291         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter2_UBZ515 (
    .p1 ( \N$/raster-interrupts/counter2|w306         ),
    .p2 ( \N$/raster-interrupts/counter2|w288         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p5 ( \/raster-interrupts/counter2/~OUT-ENABLE    )
);

capcom_dl0921_INV01 raster_interrupts_counter2_UCC479 (
    .p1 ( \N$/raster-interrupts/counter2|UBH481.1 ),
    .p2 ( \N$/raster-interrupts/counter2|w208     )
);

capcom_dl0921_R42 raster_interrupts_counter2_UCG415 (
    .p1  ( \N$/raster-interrupts/counter2|w23  ),
    .p2  ( \/raster-interrupts/counter1/~RESET ),
    .p3  ( \/raster-interrupts/counter1/~BUS5  ),
    .p4  ( \/raster-interrupts/counter1/~BUS6  ),
    .p5  ( \/raster-interrupts/counter1/~BUS7  ),
    .p6  ( \/raster-interrupts/counter1/~BUS8  ),
    .p7  ( \N$/raster-interrupts/counter2|w37  ),
    .p8  ( \N$/raster-interrupts/counter2|w38  ),
    .p9  ( \N$/raster-interrupts/counter2|w39  ),
    .p10 ( \N$/raster-interrupts/counter2|w40  )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UCJ478 (
    .p1 ( \N$/raster-interrupts/counter2|w294 ),
    .p2 ( \N$/raster-interrupts/counter2|w260 ),
    .p3 ( \N$/raster-interrupts/counter2|w280 )
);

capcom_dl0921_OR02 raster_interrupts_counter2_UCJ481 (
    .p1 ( \N$/raster-interrupts/counter2|w194 ),
    .p2 ( \N$/raster-interrupts/counter2|w208 ),
    .p3 ( \N$/raster-interrupts/counter2|w260 )
);

capcom_dl0921_INV01 raster_interrupts_counter2_UCL377 (
    .p1 ( \N$/raster-interrupts/counter2|UCL516.1 ),
    .p2 ( \/raster-interrupts/counter2/~ZERO      )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UCL491 (
    .p1 ( \N$/raster-interrupts/counter2|w208 ),
    .p2 ( \N$/raster-interrupts/counter2|w194 ),
    .p3 ( \N$/raster-interrupts/counter2|w282 )
);

capcom_dl0921_NOR05 raster_interrupts_counter2_UCL516 (
    .p1 ( \N$/raster-interrupts/counter2|UCL516.1 ),
    .p2 ( \N$/raster-interrupts/counter2|w208     ),
    .p3 ( \N$/raster-interrupts/counter2|w194     ),
    .p4 ( \N$/raster-interrupts/counter2|w291     ),
    .p5 ( \N$/raster-interrupts/counter2|w294     ),
    .p6 ( \N$/raster-interrupts/counter2|w288     )
);

capcom_dl0921_OR04 raster_interrupts_counter2_UCL519 (
    .p1 ( \N$/raster-interrupts/counter2|w262 ),
    .p2 ( \N$/raster-interrupts/counter2|w208 ),
    .p3 ( \N$/raster-interrupts/counter2|w194 ),
    .p4 ( \N$/raster-interrupts/counter2|w294 ),
    .p5 ( \N$/raster-interrupts/counter2|w291 )
);

capcom_dl0921_MUX24H raster_interrupts_counter2_UCO474 (
    .p1  ( \N$/raster-interrupts/counter2|w40  ),
    .p2  ( \N$/raster-interrupts/counter2|w39  ),
    .p3  ( \N$/raster-interrupts/counter2|w38  ),
    .p4  ( \N$/raster-interrupts/counter2|w37  ),
    .p5  ( \N$/raster-interrupts/counter2|w100 ),
    .p6  ( \N$/raster-interrupts/counter2|w105 ),
    .p7  ( \N$/raster-interrupts/counter2|w109 ),
    .p8  ( \N$/raster-interrupts/counter2|w93  ),
    .p9  ( \N$/raster-interrupts/counter2|w83  ),
    .p10 ( \N$/raster-interrupts/counter2|w276 ),
    .p11 ( \N$/raster-interrupts/counter2|w278 ),
    .p12 ( \N$/raster-interrupts/counter2|w280 ),
    .p13 ( \N$/raster-interrupts/counter2|w282 )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UCO497 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w100 ),
    .p3 ( \N$/raster-interrupts/counter2|w194 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UCO502 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w105 ),
    .p3 ( \N$/raster-interrupts/counter2|w294 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UCO506 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w109 ),
    .p3 ( \N$/raster-interrupts/counter2|w291 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter2_UCO511 (
    .p1 ( \N$/raster-interrupts/counter2|w128 ),
    .p2 ( \N$/raster-interrupts/counter2|w93  ),
    .p3 ( \N$/raster-interrupts/counter2|w288 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UCO519 (
    .p1 ( \N$/raster-interrupts/counter2|w288 ),
    .p2 ( \N$/raster-interrupts/counter2|w262 ),
    .p3 ( \N$/raster-interrupts/counter2|w276 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter2_UCR515 (
    .p1 ( \N$/raster-interrupts/counter2|w291 ),
    .p2 ( \N$/raster-interrupts/counter2|w261 ),
    .p3 ( \N$/raster-interrupts/counter2|w278 )
);

capcom_dl0921_OR03 raster_interrupts_counter2_UCR519 (
    .p1 ( \N$/raster-interrupts/counter2|w208 ),
    .p2 ( \N$/raster-interrupts/counter2|w194 ),
    .p3 ( \N$/raster-interrupts/counter2|w294 ),
    .p4 ( \N$/raster-interrupts/counter2|w261 )
);

//========================================================================
// raster-interrupts/counter3:
//========================================================================
capcom_dl0921_DFGOO raster_interrupts_counter3_UBR456 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \/raster-interrupts/counter3/_OUT0          ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBR462 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w265         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBR468 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w267         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBR474 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w269         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBR479 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w271         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFFCOO raster_interrupts_counter3_UBU439 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \/main-signals/LI                             ),
    .p3 ( \N$/raster-interrupts/counter3|w36            ),
    .p5 ( \N$/raster-interrupts/counter3|UBU439.5       )
);

capcom_dl0921_OR02 raster_interrupts_counter3_UBW366 (
    .p1 ( \/raster-interrupts/counter1/RD          ),
    .p2 ( \/raster-interrupts/counter3/ENABLE      ),
    .p3 ( \/raster-interrupts/counter3/~OUT-ENABLE )
);

capcom_dl0921_XOR02 raster_interrupts_counter3_UBW384 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/raster-interrupts/counter3|w236           ),
    .p3 ( \/raster-interrupts/counter3/_OUT0            )
);

capcom_dl0921_XNOR02 raster_interrupts_counter3_UBW414 (
    .p1 ( \N$/raster-interrupts/counter3|w271 ),
    .p2 ( \N$/raster-interrupts/counter3|w211 ),
    .p3 ( \N$/raster-interrupts/counter3|w232 )
);

capcom_dl0921_OR03 raster_interrupts_counter3_UBW419 (
    .p1 ( \N$/raster-interrupts/counter3|w265 ),
    .p2 ( \N$/raster-interrupts/counter3|w267 ),
    .p3 ( \N$/raster-interrupts/counter3|w269 ),
    .p4 ( \N$/raster-interrupts/counter3|w211 )
);

capcom_dl0921_NAND02 raster_interrupts_counter3_UBW440 (
    .p1 ( \/raster-interrupts/counter3/~OUT-ENABLE      ),
    .p2 ( \/video-signals/video-signal-registries/CLK8M ),
    .p3 ( \N$/raster-interrupts/counter3|w261           )
);

capcom_dl0921_INV01 raster_interrupts_counter3_UBZ337 (
    .p1 ( \N$/raster-interrupts/counter3|UBZ346.1 ),
    .p2 ( \/raster-interrupts/counter3/~ZERO      )
);

capcom_dl0921_XNOR02 raster_interrupts_counter3_UBZ338 (
    .p1 ( \N$/raster-interrupts/counter3|w243 ),
    .p2 ( \N$/raster-interrupts/counter3|w219 ),
    .p3 ( \N$/raster-interrupts/counter3|w231 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter3_UBZ341 (
    .p1 ( \N$/raster-interrupts/counter3|w249 ),
    .p2 ( \N$/raster-interrupts/counter3|w217 ),
    .p3 ( \N$/raster-interrupts/counter3|w237 )
);

capcom_dl0921_NOR02 raster_interrupts_counter3_UBZ344 (
    .p1 ( \/raster-interrupts/counter3/ENABLE ),
    .p2 ( \/lut-assembly/layer-control/WR     ),
    .p3 ( \N$/raster-interrupts/counter3|w18  )
);

capcom_dl0921_NOR05 raster_interrupts_counter3_UBZ346 (
    .p1 ( \N$/raster-interrupts/counter3|UBZ346.1 ),
    .p2 ( \N$/raster-interrupts/counter3|w215     ),
    .p3 ( \N$/raster-interrupts/counter3|w162     ),
    .p4 ( \N$/raster-interrupts/counter3|w246     ),
    .p5 ( \N$/raster-interrupts/counter3|w249     ),
    .p6 ( \N$/raster-interrupts/counter3|w243     )
);

capcom_dl0921_OR04 raster_interrupts_counter3_UBZ349 (
    .p1 ( \N$/raster-interrupts/counter3|w219 ),
    .p2 ( \N$/raster-interrupts/counter3|w215 ),
    .p3 ( \N$/raster-interrupts/counter3|w162 ),
    .p4 ( \N$/raster-interrupts/counter3|w249 ),
    .p5 ( \N$/raster-interrupts/counter3|w246 )
);

capcom_dl0921_OR02 raster_interrupts_counter3_UBZ355 (
    .p1 ( \N$/raster-interrupts/counter3|w267 ),
    .p2 ( \N$/raster-interrupts/counter3|w265 ),
    .p3 ( \N$/raster-interrupts/counter3|w209 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter3_UBZ357 (
    .p1 ( \N$/raster-interrupts/counter3|w269 ),
    .p2 ( \N$/raster-interrupts/counter3|w209 ),
    .p3 ( \N$/raster-interrupts/counter3|w230 )
);

capcom_dl0921_R52 raster_interrupts_counter3_UBZ360 (
    .p1  ( \N$/raster-interrupts/counter3|w18  ),
    .p2  ( \/raster-interrupts/counter1/~RESET ),
    .p3  ( \/raster-interrupts/counter1/~BUS0  ),
    .p4  ( \/raster-interrupts/counter1/~BUS1  ),
    .p5  ( \/raster-interrupts/counter1/~BUS2  ),
    .p6  ( \/raster-interrupts/counter1/~BUS3  ),
    .p7  ( \/raster-interrupts/counter1/~BUS4  ),
    .p8  ( \N$/raster-interrupts/counter3|w236 ),
    .p9  ( \N$/raster-interrupts/counter3|w28  ),
    .p10 ( \N$/raster-interrupts/counter3|w29  ),
    .p11 ( \N$/raster-interrupts/counter3|w30  ),
    .p12 ( \N$/raster-interrupts/counter3|w31  )
);

capcom_dl0921_INV01 raster_interrupts_counter3_UBZ377 (
    .p1 ( \N$/raster-interrupts/counter3|w265 ),
    .p2 ( \N$/raster-interrupts/counter3|w223 )
);

capcom_dl0921_MUX24H raster_interrupts_counter3_UBZ383 (
    .p1  ( \N$/raster-interrupts/counter3|w31  ),
    .p2  ( \N$/raster-interrupts/counter3|w30  ),
    .p3  ( \N$/raster-interrupts/counter3|w29  ),
    .p4  ( \N$/raster-interrupts/counter3|w28  ),
    .p5  ( \N$/raster-interrupts/counter3|w74  ),
    .p6  ( \N$/raster-interrupts/counter3|w76  ),
    .p7  ( \N$/raster-interrupts/counter3|w81  ),
    .p8  ( \N$/raster-interrupts/counter3|w67  ),
    .p9  ( \N$/raster-interrupts/counter3|w63  ),
    .p10 ( \N$/raster-interrupts/counter3|w232 ),
    .p11 ( \N$/raster-interrupts/counter3|w230 ),
    .p12 ( \N$/raster-interrupts/counter3|w228 ),
    .p13 ( \N$/raster-interrupts/counter3|w223 )
);

capcom_dl0921_MUX24H raster_interrupts_counter3_UBZ398 (
    .p1  ( \N$/raster-interrupts/counter3|w35  ),
    .p2  ( \N$/raster-interrupts/counter3|w34  ),
    .p3  ( \N$/raster-interrupts/counter3|w33  ),
    .p4  ( \N$/raster-interrupts/counter3|w32  ),
    .p5  ( \N$/raster-interrupts/counter3|w78  ),
    .p6  ( \N$/raster-interrupts/counter3|w83  ),
    .p7  ( \N$/raster-interrupts/counter3|w85  ),
    .p8  ( \N$/raster-interrupts/counter3|w71  ),
    .p9  ( \N$/raster-interrupts/counter3|w63  ),
    .p10 ( \N$/raster-interrupts/counter3|w231 ),
    .p11 ( \N$/raster-interrupts/counter3|w233 ),
    .p12 ( \N$/raster-interrupts/counter3|w237 ),
    .p13 ( \N$/raster-interrupts/counter3|w238 )
);

capcom_dl0921_R42 raster_interrupts_counter3_UBZ413 (
    .p1  ( \N$/raster-interrupts/counter3|w18  ),
    .p2  ( \/raster-interrupts/counter1/~RESET ),
    .p3  ( \/raster-interrupts/counter1/~BUS5  ),
    .p4  ( \/raster-interrupts/counter1/~BUS6  ),
    .p5  ( \/raster-interrupts/counter1/~BUS7  ),
    .p6  ( \/raster-interrupts/counter1/~BUS8  ),
    .p7  ( \N$/raster-interrupts/counter3|w32  ),
    .p8  ( \N$/raster-interrupts/counter3|w33  ),
    .p9  ( \N$/raster-interrupts/counter3|w34  ),
    .p10 ( \N$/raster-interrupts/counter3|w35  )
);

capcom_dl0921_NOR02 raster_interrupts_counter3_UBZ428 (
    .p1 ( \/main-signals/LI                  ),
    .p2 ( \N$/raster-interrupts/counter3|w36 ),
    .p3 ( \N$/raster-interrupts/counter3|w63 )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBZ440 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w162         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBZ446 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w249         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBZ452 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w246         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_DFGOO raster_interrupts_counter3_UBZ458 (
    .p1 ( \N$/raster-interrupts/counter3|w261         ),
    .p2 ( \N$/raster-interrupts/counter3|w243         ),
    .p3 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p5 ( \/raster-interrupts/counter3/~OUT-ENABLE    )
);

capcom_dl0921_OR02 raster_interrupts_counter3_UCC354 (
    .p1 ( \N$/raster-interrupts/counter3|w162 ),
    .p2 ( \N$/raster-interrupts/counter3|w215 ),
    .p3 ( \N$/raster-interrupts/counter3|w217 )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC359 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w74  ),
    .p3 ( \N$/raster-interrupts/counter3|w265 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC363 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w76  ),
    .p3 ( \N$/raster-interrupts/counter3|w267 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC368 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w81  ),
    .p3 ( \N$/raster-interrupts/counter3|w269 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC372 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w67  ),
    .p3 ( \N$/raster-interrupts/counter3|w271 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_INV01 raster_interrupts_counter3_UCC383 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/raster-interrupts/counter3|w101           )
);

capcom_dl0921_OR04 raster_interrupts_counter3_UCC385 (
    .p1 ( \N$/raster-interrupts/counter3|w215 ),
    .p2 ( \N$/raster-interrupts/counter3|w265 ),
    .p3 ( \N$/raster-interrupts/counter3|w267 ),
    .p4 ( \N$/raster-interrupts/counter3|w269 ),
    .p5 ( \N$/raster-interrupts/counter3|w271 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter3_UCC388 (
    .p1 ( \N$/raster-interrupts/counter3|w265 ),
    .p2 ( \N$/raster-interrupts/counter3|w267 ),
    .p3 ( \N$/raster-interrupts/counter3|w228 )
);

capcom_dl0921_OR03 raster_interrupts_counter3_UCC393 (
    .p1 ( \N$/raster-interrupts/counter3|w215 ),
    .p2 ( \N$/raster-interrupts/counter3|w162 ),
    .p3 ( \N$/raster-interrupts/counter3|w249 ),
    .p4 ( \N$/raster-interrupts/counter3|w218 )
);

capcom_dl0921_XNOR02 raster_interrupts_counter3_UCC396 (
    .p1 ( \N$/raster-interrupts/counter3|w162 ),
    .p2 ( \N$/raster-interrupts/counter3|w215 ),
    .p3 ( \N$/raster-interrupts/counter3|w238 )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC400 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w78  ),
    .p3 ( \N$/raster-interrupts/counter3|w162 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC405 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w83  ),
    .p3 ( \N$/raster-interrupts/counter3|w249 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC409 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w85  ),
    .p3 ( \N$/raster-interrupts/counter3|w246 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_DFFCOS raster_interrupts_counter3_UCC414 (
    .p1 ( \N$/raster-interrupts/counter3|w101 ),
    .p2 ( \N$/raster-interrupts/counter3|w71  ),
    .p3 ( \N$/raster-interrupts/counter3|w243 ),
    .p4 ( \/raster-interrupts/counter1/~RESET )
);

capcom_dl0921_XNOR02 raster_interrupts_counter3_UCC422 (
    .p1 ( \N$/raster-interrupts/counter3|w246 ),
    .p2 ( \N$/raster-interrupts/counter3|w218 ),
    .p3 ( \N$/raster-interrupts/counter3|w233 )
);

//========================================================================
// raster-interrupts/counters-bus-buffer:
//========================================================================
capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UBU364 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p2 ( \/raster-interrupts/counter1/~BUS0          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UBU365 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p2 ( \/raster-interrupts/counter1/~BUS3          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UBU366 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p2 ( \/raster-interrupts/counter1/~BUS4          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UBW364 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p2 ( \/raster-interrupts/counter1/~BUS1          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UBW365 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p2 ( \/raster-interrupts/counter1/~BUS2          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UCC391 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p2 ( \/raster-interrupts/counter1/~BUS5          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UCG401 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p2 ( \/raster-interrupts/counter1/~BUS7          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UCG408 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p2 ( \/raster-interrupts/counter1/~BUS6          )
);

capcom_dl0921_INV01 raster_interrupts_counters_bus_buffer_UCG414 (
    .p1 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p2 ( \/raster-interrupts/counter1/~BUS8          )
);

//========================================================================
// security-check:
//========================================================================
capcom_dl0921_L8 security_check_UBW8 (
    .p1  ( \N$/security-check|w8                       ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p3  ( \N$/security-check|w76                      ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p5  ( \N$/security-check|w72                      ),
    .p6  ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p7  ( \N$/security-check|w68                      ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p9  ( \N$/security-check|w64                      ),
    .p10 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p11 ( \N$/security-check|w60                      ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p13 ( \N$/security-check|w56                      ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p15 ( \N$/security-check|w52                      ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p17 ( \N$/security-check|w42                      )
);

capcom_dl0921_OR02 security_check_UBZ203 (
    .p1 ( \/security-check/~E1            ),
    .p2 ( \/lut-assembly/layer-control/WR ),
    .p3 ( \N$/security-check|w273         )
);

capcom_dl0921_INV01 security_check_UBZ51 (
    .p1 ( \N$/security-check|w144 ),
    .p2 ( \N$/security-check|w8   )
);

capcom_dl0921_OR02 security_check_UBZ90 (
    .p1 ( \/security-check/~E2            ),
    .p2 ( \/lut-assembly/layer-control/WR ),
    .p3 ( \N$/security-check|w144         )
);

capcom_dl0921_DFFCOR security_check_UBZ94 (
    .p1 ( \N$/security-check|w144    ),
    .p2 ( \N$/security-check|w167    ),
    .p3 ( \/security-check/OUT       ),
    .p4 ( \/counter-fi/~RESET        ),
    .p5 ( \N$/security-check|UBZ94.5 )
);

capcom_dl0921_INV01 security_check_UCC202 (
    .p1 ( \N$/security-check|w273 ),
    .p2 ( \N$/security-check|w272 )
);

capcom_dl0921_XNOR02 security_check_UCG137 (
    .p1 ( \/CHECK1-D5             ),
    .p2 ( \N$/security-check|w208 ),
    .p3 ( \N$/security-check|w184 )
);

capcom_dl0921_XNOR02 security_check_UCG25 (
    .p1 ( \/CHECK2-D5             ),
    .p2 ( \N$/security-check|w68  ),
    .p3 ( \N$/security-check|w108 )
);

capcom_dl0921_XNOR02 security_check_UCJ10 (
    .p1 ( \/CHECK2-D1             ),
    .p2 ( \N$/security-check|w52  ),
    .p3 ( \N$/security-check|w114 )
);

capcom_dl0921_L8 security_check_UCJ120 (
    .p1  ( \N$/security-check|w272                     ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p3  ( \N$/security-check|w200                     ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p5  ( \N$/security-check|w231                     ),
    .p6  ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p7  ( \N$/security-check|w208                     ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p9  ( \N$/security-check|w230                     ),
    .p10 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p11 ( \N$/security-check|w216                     ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p13 ( \N$/security-check|w229                     ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p15 ( \N$/security-check|w224                     ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p17 ( \N$/security-check|w228                     )
);

capcom_dl0921_XNOR02 security_check_UCJ13 (
    .p1 ( \/CHECK2-D2             ),
    .p2 ( \N$/security-check|w56  ),
    .p3 ( \N$/security-check|w123 )
);

capcom_dl0921_XNOR02 security_check_UCJ16 (
    .p1 ( \/CHECK2-D0             ),
    .p2 ( \N$/security-check|w42  ),
    .p3 ( \N$/security-check|w122 )
);

capcom_dl0921_XNOR02 security_check_UCJ19 (
    .p1 ( \/CHECK2-D3            ),
    .p2 ( \N$/security-check|w60 ),
    .p3 ( \N$/security-check|w96 )
);

capcom_dl0921_NAND08 security_check_UCJ21 (
    .p1 ( \N$/security-check|w122 ),
    .p2 ( \N$/security-check|w114 ),
    .p3 ( \N$/security-check|w123 ),
    .p4 ( \N$/security-check|w96  ),
    .p5 ( \N$/security-check|w99  ),
    .p6 ( \N$/security-check|w108 ),
    .p7 ( \N$/security-check|w116 ),
    .p8 ( \N$/security-check|w125 ),
    .p9 ( \N$/security-check|w133 )
);

capcom_dl0921_XNOR02 security_check_UCJ27 (
    .p1 ( \/CHECK2-D7             ),
    .p2 ( \N$/security-check|w76  ),
    .p3 ( \N$/security-check|w125 )
);

capcom_dl0921_XNOR02 security_check_UCJ32 (
    .p1 ( \/CHECK2-D4            ),
    .p2 ( \N$/security-check|w64 ),
    .p3 ( \N$/security-check|w99 )
);

capcom_dl0921_XNOR02 security_check_UCJ35 (
    .p1 ( \/CHECK2-D6             ),
    .p2 ( \N$/security-check|w72  ),
    .p3 ( \N$/security-check|w116 )
);

capcom_dl0921_XNOR02 security_check_UCJ65 (
    .p1 ( \/CHECK2-D10            ),
    .p2 ( \N$/security-check|w84  ),
    .p3 ( \N$/security-check|w128 )
);

capcom_dl0921_XNOR02 security_check_UCJ68 (
    .p1 ( \/CHECK2-D13            ),
    .p2 ( \N$/security-check|w58  ),
    .p3 ( \N$/security-check|w112 )
);

capcom_dl0921_XNOR02 security_check_UCJ71 (
    .p1 ( \/CHECK2-D11            ),
    .p2 ( \N$/security-check|w66  ),
    .p3 ( \N$/security-check|w101 )
);

capcom_dl0921_L8 security_check_UCJ79 (
    .p1  ( \N$/security-check|w8                       ),
    .p2  ( \/raster-interrupts/counter1/UK             ),
    .p3  ( \N$/security-check|w50                      ),
    .p4  ( \/cps-id/DATA14                             ),
    .p5  ( \N$/security-check|w86                      ),
    .p6  ( \/lut-assembly/layer-control/BUS13          ),
    .p7  ( \N$/security-check|w58                      ),
    .p8  ( \/lut-assembly/layer-control/BUS12          ),
    .p9  ( \N$/security-check|w85                      ),
    .p10 ( \/lut-assembly/layer-control/BUS11          ),
    .p11 ( \N$/security-check|w66                      ),
    .p12 ( \/lut-assembly/layer-control/BUS10          ),
    .p13 ( \N$/security-check|w84                      ),
    .p14 ( \/lut-assembly/layer-control/BUS9           ),
    .p15 ( \N$/security-check|w74                      ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p17 ( \N$/security-check|w83                      )
);

capcom_dl0921_L8 security_check_UCL108 (
    .p1  ( \N$/security-check|w272                     ),
    .p2  ( \/raster-interrupts/counter1/UK             ),
    .p3  ( \N$/security-check|w236                     ),
    .p4  ( \/cps-id/DATA14                             ),
    .p5  ( \N$/security-check|w226                     ),
    .p6  ( \/lut-assembly/layer-control/BUS13          ),
    .p7  ( \N$/security-check|w222                     ),
    .p8  ( \/lut-assembly/layer-control/BUS12          ),
    .p9  ( \N$/security-check|w218                     ),
    .p10 ( \/lut-assembly/layer-control/BUS11          ),
    .p11 ( \N$/security-check|w214                     ),
    .p12 ( \/lut-assembly/layer-control/BUS10          ),
    .p13 ( \N$/security-check|w210                     ),
    .p14 ( \/lut-assembly/layer-control/BUS9           ),
    .p15 ( \N$/security-check|w206                     ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p17 ( \N$/security-check|w202                     )
);

capcom_dl0921_XNOR02 security_check_UCL131 (
    .p1 ( \/CHECK1-D13            ),
    .p2 ( \N$/security-check|w222 ),
    .p3 ( \N$/security-check|w188 )
);

capcom_dl0921_XNOR02 security_check_UCL134 (
    .p1 ( \/CHECK1-D1             ),
    .p2 ( \N$/security-check|w224 ),
    .p3 ( \N$/security-check|w156 )
);

capcom_dl0921_NAND08 security_check_UCL137 (
    .p1 ( \N$/security-check|w146 ),
    .p2 ( \N$/security-check|w156 ),
    .p3 ( \N$/security-check|w164 ),
    .p4 ( \N$/security-check|w173 ),
    .p5 ( \N$/security-check|w176 ),
    .p6 ( \N$/security-check|w184 ),
    .p7 ( \N$/security-check|w158 ),
    .p8 ( \N$/security-check|w185 ),
    .p9 ( \N$/security-check|w142 )
);

capcom_dl0921_XNOR02 security_check_UCL143 (
    .p1 ( \/CHECK1-D3             ),
    .p2 ( \N$/security-check|w216 ),
    .p3 ( \N$/security-check|w173 )
);

capcom_dl0921_XNOR02 security_check_UCL146 (
    .p1 ( \/CHECK1-D4             ),
    .p2 ( \N$/security-check|w230 ),
    .p3 ( \N$/security-check|w176 )
);

capcom_dl0921_XNOR02 security_check_UCL149 (
    .p1 ( \/CHECK1-D6             ),
    .p2 ( \N$/security-check|w231 ),
    .p3 ( \N$/security-check|w158 )
);

capcom_dl0921_XNOR02 security_check_UCL152 (
    .p1 ( \/CHECK1-D7             ),
    .p2 ( \N$/security-check|w200 ),
    .p3 ( \N$/security-check|w185 )
);

capcom_dl0921_OR04 security_check_UCL53 (
    .p1 ( \N$/security-check|w167 ),
    .p2 ( \N$/security-check|w142 ),
    .p3 ( \N$/security-check|w133 ),
    .p4 ( \N$/security-check|w136 ),
    .p5 ( \N$/security-check|w141 )
);

capcom_dl0921_XNOR02 security_check_UCL56 (
    .p1 ( \/CHECK2-D14            ),
    .p2 ( \N$/security-check|w86  ),
    .p3 ( \N$/security-check|w120 )
);

capcom_dl0921_XNOR02 security_check_UCL59 (
    .p1 ( \/CHECK2-D8             ),
    .p2 ( \N$/security-check|w83  ),
    .p3 ( \N$/security-check|w127 )
);

capcom_dl0921_XNOR02 security_check_UCL62 (
    .p1 ( \/CHECK2-D9             ),
    .p2 ( \N$/security-check|w74  ),
    .p3 ( \N$/security-check|w118 )
);

capcom_dl0921_XNOR02 security_check_UCL65 (
    .p1 ( \/CHECK2-D15            ),
    .p2 ( \N$/security-check|w50  ),
    .p3 ( \N$/security-check|w130 )
);

capcom_dl0921_NAND08 security_check_UCL67 (
    .p1 ( \N$/security-check|w127 ),
    .p2 ( \N$/security-check|w118 ),
    .p3 ( \N$/security-check|w128 ),
    .p4 ( \N$/security-check|w101 ),
    .p5 ( \N$/security-check|w104 ),
    .p6 ( \N$/security-check|w112 ),
    .p7 ( \N$/security-check|w120 ),
    .p8 ( \N$/security-check|w130 ),
    .p9 ( \N$/security-check|w136 )
);

capcom_dl0921_XNOR02 security_check_UCL73 (
    .p1 ( \/CHECK2-D12            ),
    .p2 ( \N$/security-check|w85  ),
    .p3 ( \N$/security-check|w104 )
);

capcom_dl0921_NAND08 security_check_UCL76 (
    .p1 ( \N$/security-check|w151 ),
    .p2 ( \N$/security-check|w160 ),
    .p3 ( \N$/security-check|w169 ),
    .p4 ( \N$/security-check|w178 ),
    .p5 ( \N$/security-check|w181 ),
    .p6 ( \N$/security-check|w188 ),
    .p7 ( \N$/security-check|w162 ),
    .p8 ( \N$/security-check|w189 ),
    .p9 ( \N$/security-check|w141 )
);

capcom_dl0921_XNOR02 security_check_UCL82 (
    .p1 ( \/CHECK1-D9             ),
    .p2 ( \N$/security-check|w206 ),
    .p3 ( \N$/security-check|w160 )
);

capcom_dl0921_XNOR02 security_check_UCL85 (
    .p1 ( \/CHECK1-D12            ),
    .p2 ( \N$/security-check|w218 ),
    .p3 ( \N$/security-check|w181 )
);

capcom_dl0921_XNOR02 security_check_UCL87 (
    .p1 ( \/CHECK1-D8             ),
    .p2 ( \N$/security-check|w202 ),
    .p3 ( \N$/security-check|w151 )
);

capcom_dl0921_XNOR02 security_check_UCL90 (
    .p1 ( \/CHECK1-D14            ),
    .p2 ( \N$/security-check|w226 ),
    .p3 ( \N$/security-check|w162 )
);

capcom_dl0921_XNOR02 security_check_UCL93 (
    .p1 ( \/CHECK1-D11            ),
    .p2 ( \N$/security-check|w214 ),
    .p3 ( \N$/security-check|w178 )
);

capcom_dl0921_XNOR02 security_check_UCO128 (
    .p1 ( \/CHECK1-D0             ),
    .p2 ( \N$/security-check|w228 ),
    .p3 ( \N$/security-check|w146 )
);

capcom_dl0921_XNOR02 security_check_UCO131 (
    .p1 ( \/CHECK1-D15            ),
    .p2 ( \N$/security-check|w236 ),
    .p3 ( \N$/security-check|w189 )
);

capcom_dl0921_XNOR02 security_check_UCO134 (
    .p1 ( \/CHECK1-D2             ),
    .p2 ( \N$/security-check|w229 ),
    .p3 ( \N$/security-check|w164 )
);

capcom_dl0921_XNOR02 security_check_UCO59 (
    .p1 ( \/CHECK1-D10            ),
    .p2 ( \N$/security-check|w210 ),
    .p3 ( \N$/security-check|w169 )
);

//========================================================================
// security-management/addr-decoder-registry:
//========================================================================
capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UBW244 (
    .p1 ( \/security-management/addr-decoder-registry/KEY27  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w436 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UBW262 (
    .p1 ( \/security-management/addr-decoder-registry/KEY26  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w437 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UBW265 (
    .p1 ( \/security-management/addr-decoder-registry/KEY25  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w421 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UBZ144 (
    .p1 ( \/security-management/addr-decoder-registry/KEY123 ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w95  )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UBZ147 (
    .p1 ( \N$/security-management/addr-decoder-registry|w124      ),
    .p2 ( \N$/security-management/addr-decoder-registry|w98       ),
    .p3 ( \N$/security-management/addr-decoder-registry|w84       ),
    .p4 ( \N$/security-management/addr-decoder-registry|w95       ),
    .p5 ( \N$/security-management/addr-decoder-registry|w122      ),
    .p6 ( \/security-management/addr-decoder-registry/~LAYER-CTRL )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UBZ272 (
    .p1 ( \N$/security-management/addr-decoder-registry|w440    ),
    .p2 ( \N$/security-management/addr-decoder-registry|w421    ),
    .p3 ( \N$/security-management/addr-decoder-registry|w437    ),
    .p4 ( \N$/security-management/addr-decoder-registry|w436    ),
    .p5 ( \N$/security-management/addr-decoder-registry|w435    ),
    .p6 ( \/security-management/addr-decoder-registry/~PAL-CTRL )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC107 (
    .p1 ( \/security-management/addr-decoder-registry/KEY116 ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w102 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC112 (
    .p1 ( \/security-management/addr-decoder-registry/KEY118 ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w127 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCC115 (
    .p1 ( \N$/security-management/addr-decoder-registry|w131   ),
    .p2 ( \N$/security-management/addr-decoder-registry|w102   ),
    .p3 ( \N$/security-management/addr-decoder-registry|w128   ),
    .p4 ( \N$/security-management/addr-decoder-registry|w127   ),
    .p5 ( \N$/security-management/addr-decoder-registry|w126   ),
    .p6 ( \/security-management/addr-decoder-registry/~RASTER1 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC124 (
    .p1 ( \/security-management/addr-decoder-registry/KEY119 ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w126 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC136 (
    .p1 ( \/security-management/addr-decoder-registry/KEY124 ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w122 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC159 (
    .p1 ( \/security-management/addr-decoder-registry/KEY38  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w345 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC188 (
    .p1 ( \/security-management/addr-decoder-registry/KEY35  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w325 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCC194 (
    .p1 ( \N$/security-management/addr-decoder-registry|w350     ),
    .p2 ( \N$/security-management/addr-decoder-registry|w325     ),
    .p3 ( \N$/security-management/addr-decoder-registry|w347     ),
    .p4 ( \N$/security-management/addr-decoder-registry|w346     ),
    .p5 ( \N$/security-management/addr-decoder-registry|w345     ),
    .p6 ( \/security-management/addr-decoder-registry/~PRIORITY3 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC200 (
    .p1 ( \/security-management/addr-decoder-registry/KEY34  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w350 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC209 (
    .p1 ( \/security-management/addr-decoder-registry/KEY56  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w243 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCC218 (
    .p1 ( \N$/security-management/addr-decoder-registry|w248   ),
    .p2 ( \N$/security-management/addr-decoder-registry|w220   ),
    .p3 ( \N$/security-management/addr-decoder-registry|w245   ),
    .p4 ( \N$/security-management/addr-decoder-registry|w244   ),
    .p5 ( \N$/security-management/addr-decoder-registry|w243   ),
    .p6 ( \/security-management/addr-decoder-registry/~MULT-TC )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC260 (
    .p1 ( \/security-management/addr-decoder-registry/KEY28  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w435 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC82 (
    .p1 ( \/security-management/addr-decoder-registry/KEY115 ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w131 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC85 (
    .p1 ( \/security-management/addr-decoder-registry/KEY89  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w223 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCC93 (
    .p1 ( \N$/security-management/addr-decoder-registry|w227     ),
    .p2 ( \N$/security-management/addr-decoder-registry|w208     ),
    .p3 ( \N$/security-management/addr-decoder-registry|w224     ),
    .p4 ( \N$/security-management/addr-decoder-registry|w223     ),
    .p5 ( \N$/security-management/addr-decoder-registry|w222     ),
    .p6 ( \/security-management/addr-decoder-registry/~PRIORITY0 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCC98 (
    .p1 ( \/security-management/addr-decoder-registry/KEY86  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w227 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG106 (
    .p1 ( \/security-management/addr-decoder-registry/KEY109 ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w135 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG109 (
    .p1 ( \/security-management/addr-decoder-registry/KEY82  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w212 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG112 (
    .p1 ( \/security-management/addr-decoder-registry/KEY85  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w229 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCG114 (
    .p1 ( \N$/security-management/addr-decoder-registry|w234  ),
    .p2 ( \N$/security-management/addr-decoder-registry|w212  ),
    .p3 ( \N$/security-management/addr-decoder-registry|w231  ),
    .p4 ( \N$/security-management/addr-decoder-registry|w230  ),
    .p5 ( \N$/security-management/addr-decoder-registry|w229  ),
    .p6 ( \/security-management/addr-decoder-registry/~CHECK1 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG118 (
    .p1 ( \/security-management/addr-decoder-registry/KEY107 ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w138 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG121 (
    .p1 ( \/security-management/addr-decoder-registry/KEY108 ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w106 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG124 (
    .p1 ( \/security-management/addr-decoder-registry/KEY129 ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w115 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCG127 (
    .p1 ( \N$/security-management/addr-decoder-registry|w138  ),
    .p2 ( \N$/security-management/addr-decoder-registry|w106  ),
    .p3 ( \N$/security-management/addr-decoder-registry|w135  ),
    .p4 ( \N$/security-management/addr-decoder-registry|w134  ),
    .p5 ( \N$/security-management/addr-decoder-registry|w133  ),
    .p6 ( \/security-management/addr-decoder-registry/~CHECK2 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG131 (
    .p1 ( \/security-management/addr-decoder-registry/KEY128 ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w116 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG134 (
    .p1 ( \/security-management/addr-decoder-registry/KEY127 ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w117 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG140 (
    .p1 ( \/security-management/addr-decoder-registry/KEY111 ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w133 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCG143 (
    .p1 ( \N$/security-management/addr-decoder-registry|w120   ),
    .p2 ( \N$/security-management/addr-decoder-registry|w92    ),
    .p3 ( \N$/security-management/addr-decoder-registry|w117   ),
    .p4 ( \N$/security-management/addr-decoder-registry|w116   ),
    .p5 ( \N$/security-management/addr-decoder-registry|w115   ),
    .p6 ( \/security-management/addr-decoder-registry/~RASTER2 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG148 (
    .p1 ( \/security-management/addr-decoder-registry/KEY125 ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w120 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG150 (
    .p1 ( \/security-management/addr-decoder-registry/KEY121 ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w98  )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG153 (
    .p1 ( \/security-management/addr-decoder-registry/KEY120 ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w124 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG159 (
    .p1 ( \/security-management/addr-decoder-registry/KEY37  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w346 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG171 (
    .p1 ( \/security-management/addr-decoder-registry/KEY22  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w443 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCG191 (
    .p1 ( \N$/security-management/addr-decoder-registry|w447  ),
    .p2 ( \N$/security-management/addr-decoder-registry|w425  ),
    .p3 ( \N$/security-management/addr-decoder-registry|w444  ),
    .p4 ( \N$/security-management/addr-decoder-registry|w443  ),
    .p5 ( \N$/security-management/addr-decoder-registry|w442  ),
    .p6 ( \/security-management/addr-decoder-registry/~MULT-Y )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG194 (
    .p1 ( \/security-management/addr-decoder-registry/KEY19  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w447 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG197 (
    .p1 ( \/security-management/addr-decoder-registry/KEY20  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w425 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG217 (
    .p1 ( \/security-management/addr-decoder-registry/KEY55  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w244 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG235 (
    .p1 ( \/security-management/addr-decoder-registry/KEY53  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w220 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG273 (
    .p1 ( \/security-management/addr-decoder-registry/KEY24  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w440 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG86 (
    .p1 ( \/security-management/addr-decoder-registry/KEY90  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w222 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG90 (
    .p1 ( \/security-management/addr-decoder-registry/KEY88  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w224 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG92 (
    .p1 ( \/security-management/addr-decoder-registry/KEY130 ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w113 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG95 (
    .p1 ( \/security-management/addr-decoder-registry/KEY87  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w208 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCG98 (
    .p1 ( \/security-management/addr-decoder-registry/KEY81  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w234 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCJ107 (
    .p1 ( \N$/security-management/addr-decoder-registry|w113   ),
    .p2 ( \N$/security-management/addr-decoder-registry|w88    ),
    .p3 ( \N$/security-management/addr-decoder-registry|w110   ),
    .p4 ( \N$/security-management/addr-decoder-registry|w109   ),
    .p5 ( \N$/security-management/addr-decoder-registry|w108   ),
    .p6 ( \/security-management/addr-decoder-registry/~RASTER3 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ110 (
    .p1 ( \/security-management/addr-decoder-registry/KEY84  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w230 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ113 (
    .p1 ( \/security-management/addr-decoder-registry/KEY83  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w231 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ116 (
    .p1 ( \/security-management/addr-decoder-registry/KEY110 ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w134 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ142 (
    .p1 ( \/security-management/addr-decoder-registry/KEY126 ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w92  )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ145 (
    .p1 ( \/security-management/addr-decoder-registry/KEY122 ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w84  )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ170 (
    .p1 ( \/security-management/addr-decoder-registry/KEY23  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w442 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ177 (
    .p1 ( \/security-management/addr-decoder-registry/KEY21  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w444 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ190 (
    .p1 ( \/security-management/addr-decoder-registry/KEY36  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w347 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ219 (
    .p1 ( \/security-management/addr-decoder-registry/KEY33  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w352 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ226 (
    .p1 ( \/security-management/addr-decoder-registry/KEY54  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w245 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ229 (
    .p1 ( \/security-management/addr-decoder-registry/KEY52  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w248 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCJ75 (
    .p1 ( \/security-management/addr-decoder-registry/KEY117 ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w128 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL192 (
    .p1 ( \/security-management/addr-decoder-registry/KEY43  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w321 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL195 (
    .p1 ( \/security-management/addr-decoder-registry/KEY44  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w340 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCL197 (
    .p1 ( \N$/security-management/addr-decoder-registry|w343    ),
    .p2 ( \N$/security-management/addr-decoder-registry|w321    ),
    .p3 ( \N$/security-management/addr-decoder-registry|w340    ),
    .p4 ( \N$/security-management/addr-decoder-registry|w339    ),
    .p5 ( \N$/security-management/addr-decoder-registry|w338    ),
    .p6 ( \/security-management/addr-decoder-registry/~MULT-MSB )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL219 (
    .p1 ( \/security-management/addr-decoder-registry/KEY31  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w354 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL221 (
    .p1 ( \/security-management/addr-decoder-registry/KEY32  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w353 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCL224 (
    .p1 ( \N$/security-management/addr-decoder-registry|w357    ),
    .p2 ( \N$/security-management/addr-decoder-registry|w329    ),
    .p3 ( \N$/security-management/addr-decoder-registry|w354    ),
    .p4 ( \N$/security-management/addr-decoder-registry|w353    ),
    .p5 ( \N$/security-management/addr-decoder-registry|w352    ),
    .p6 ( \/security-management/addr-decoder-registry/~MULT-LSB )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL228 (
    .p1 ( \/security-management/addr-decoder-registry/KEY29  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w357 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL231 (
    .p1 ( \/security-management/addr-decoder-registry/KEY8   ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w458 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL96 (
    .p1 ( \/security-management/addr-decoder-registry/KEY134 ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w108 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCL98 (
    .p1 ( \/security-management/addr-decoder-registry/KEY132 ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w110 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO106 (
    .p1 ( \/security-management/addr-decoder-registry/KEY131 ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w88  )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO179 (
    .p1 ( \/security-management/addr-decoder-registry/KEY46  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w338 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO182 (
    .p1 ( \/security-management/addr-decoder-registry/KEY45  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w339 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO204 (
    .p1 ( \/security-management/addr-decoder-registry/KEY42  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w343 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO206 (
    .p1 ( \/security-management/addr-decoder-registry/KEY18  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w449 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO209 (
    .p1 ( \/security-management/addr-decoder-registry/KEY47  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w336 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO217 (
    .p1 ( \/security-management/addr-decoder-registry/KEY15  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w429 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO220 (
    .p1 ( \/security-management/addr-decoder-registry/KEY17  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w450 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO223 (
    .p1 ( \/security-management/addr-decoder-registry/KEY16  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w451 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCO225 (
    .p1 ( \N$/security-management/addr-decoder-registry|w454  ),
    .p2 ( \N$/security-management/addr-decoder-registry|w429  ),
    .p3 ( \N$/security-management/addr-decoder-registry|w451  ),
    .p4 ( \N$/security-management/addr-decoder-registry|w450  ),
    .p5 ( \N$/security-management/addr-decoder-registry|w449  ),
    .p6 ( \/security-management/addr-decoder-registry/~CPS-ID )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO229 (
    .p1 ( \/security-management/addr-decoder-registry/KEY14  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w454 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO234 (
    .p1 ( \/security-management/addr-decoder-registry/KEY10  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w456 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO237 (
    .p1 ( \/security-management/addr-decoder-registry/KEY9   ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w457 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCO240 (
    .p1 ( \N$/security-management/addr-decoder-registry|w461  ),
    .p2 ( \N$/security-management/addr-decoder-registry|w433  ),
    .p3 ( \N$/security-management/addr-decoder-registry|w458  ),
    .p4 ( \N$/security-management/addr-decoder-registry|w457  ),
    .p5 ( \N$/security-management/addr-decoder-registry|w456  ),
    .p6 ( \/security-management/addr-decoder-registry/~MULT-X )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO243 (
    .p1 ( \/security-management/addr-decoder-registry/KEY51  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w331 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO246 (
    .p1 ( \/security-management/addr-decoder-registry/KEY6   ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w461 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO250 (
    .p1 ( \/security-management/addr-decoder-registry/KEY7   ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w433 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCO252 (
    .p1 ( \N$/security-management/addr-decoder-registry|w336     ),
    .p2 ( \N$/security-management/addr-decoder-registry|w317     ),
    .p3 ( \N$/security-management/addr-decoder-registry|w333     ),
    .p4 ( \N$/security-management/addr-decoder-registry|w332     ),
    .p5 ( \N$/security-management/addr-decoder-registry|w331     ),
    .p6 ( \/security-management/addr-decoder-registry/~PRIORITY2 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO256 (
    .p1 ( \/security-management/addr-decoder-registry/KEY50  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w332 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO259 (
    .p1 ( \/security-management/addr-decoder-registry/KEY49  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w333 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO262 (
    .p1 ( \/security-management/addr-decoder-registry/KEY48  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w317 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO282 (
    .p1 ( \/security-management/addr-decoder-registry/KEY30  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w329 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO79 (
    .p1 ( \/security-management/addr-decoder-registry/KEY59  ),
    .p2 ( \/security-management/addr-decoder/CA3             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w238 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO82 (
    .p1 ( \/security-management/addr-decoder-registry/KEY57  ),
    .p2 ( \/security-management/addr-decoder/CA1             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w241 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO85 (
    .p1 ( \/security-management/addr-decoder-registry/KEY60  ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w237 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO90 (
    .p1 ( \/security-management/addr-decoder-registry/KEY61  ),
    .p2 ( \/security-management/addr-decoder/CA5             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w236 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_registry_UCO92 (
    .p1 ( \N$/security-management/addr-decoder-registry|w241     ),
    .p2 ( \N$/security-management/addr-decoder-registry|w216     ),
    .p3 ( \N$/security-management/addr-decoder-registry|w238     ),
    .p4 ( \N$/security-management/addr-decoder-registry|w237     ),
    .p5 ( \N$/security-management/addr-decoder-registry|w236     ),
    .p6 ( \/security-management/addr-decoder-registry/~PRIORITY1 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO96 (
    .p1 ( \/security-management/addr-decoder-registry/KEY58  ),
    .p2 ( \/security-management/addr-decoder/CA2             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w216 )
);

capcom_dl0921_XNOR02 security_management_addr_decoder_registry_UCO98 (
    .p1 ( \/security-management/addr-decoder-registry/KEY133 ),
    .p2 ( \/security-management/addr-decoder/CA4             ),
    .p3 ( \N$/security-management/addr-decoder-registry|w109 )
);

//========================================================================
// security-management/addr-decoder:
//========================================================================
capcom_dl0921_D38GL security_management_addr_decoder_UBW185 (
    .p1  ( \/security-management/addr-decoder/CA5  ),
    .p2  ( \/security-management/addr-decoder/CA4  ),
    .p3  ( \/security-management/addr-decoder/CA3  ),
    .p4  ( VCC                                     ),
    .p5  ( \/security-management/addr-decoder/CA2  ),
    .p6  ( \/security-management/addr-decoder/CA1  ),
    .p7  ( \/security-management/addr-decoder/0x0E ),
    .p9  ( \/security-management/addr-decoder/0x0C ),
    .p10 ( \/security-management/addr-decoder/0x0A ),
    .p11 ( \/security-management/addr-decoder/0x08 ),
    .p12 ( \/security-management/addr-decoder/0x06 ),
    .p13 ( \/security-management/addr-decoder/0x04 ),
    .p14 ( \/security-management/addr-decoder/0x02 ),
    .p15 ( \/security-management/addr-decoder/0x00 )
);

capcom_dl0921_D24GL security_management_addr_decoder_UBW247 (
    .p1 ( \/security-management/addr-decoder/CA5   ),
    .p2 ( \/security-management/addr-decoder/CA1   ),
    .p3 ( \N$/security-management/addr-decoder|w71 ),
    .p4 ( \/security-management/addr-decoder/0x32  ),
    .p5 ( \/security-management/addr-decoder/0x30  ),
    .p6 ( \/security-management/addr-decoder/0x12  ),
    .p7 ( \/security-management/addr-decoder/0x10  )
);

capcom_dl0921_OR03 security_management_addr_decoder_UBW280 (
    .p1 ( \/security-management/addr-decoder/CA4   ),
    .p2 ( \/security-management/addr-decoder/CA3   ),
    .p3 ( \N$/security-management/addr-decoder|w22 ),
    .p4 ( \N$/security-management/addr-decoder|w71 )
);

capcom_dl0921_NAND05 security_management_addr_decoder_UBW391 (
    .p1 ( \/security-management/addr-decoder/CA1 ),
    .p2 ( \/security-management/addr-decoder/CA2 ),
    .p3 ( \/security-management/addr-decoder/CA3 ),
    .p4 ( \/security-management/addr-decoder/CA4 ),
    .p5 ( \/security-management/addr-decoder/CA5 ),
    .p6 ( \/video-signals/video-counter/~E       )
);

capcom_dl0921_INV01 security_management_addr_decoder_UBW395 (
    .p1 ( \N$/security-management/addr-decoder|w21 ),
    .p2 ( \N$/security-management/addr-decoder|w22 )
);

capcom_dl0921_BUF12 security_management_addr_decoder_UBW396 (
    .p1 ( \N$/security-management/addr-decoder|w21 ),
    .p2 ( \/security-management/addr-decoder/CA2   )
);

capcom_dl0921_BUF12 security_management_addr_decoder_UBW453 (
    .p1 ( \N$/security-management/addr-decoder|UBZ493.3 ),
    .p2 ( \/security-management/addr-decoder/CA1        )
);

capcom_dl0921_BUF12 security_management_addr_decoder_UBZ434 (
    .p1 ( \N$/security-management/addr-decoder|UBZ485.3 ),
    .p2 ( \/security-management/addr-decoder/CA4        )
);

capcom_dl0921_BUF12 security_management_addr_decoder_UBZ437 (
    .p1 ( \N$/security-management/addr-decoder|UBZ488.3 ),
    .p2 ( \/security-management/addr-decoder/CA3        )
);

capcom_dl0921_L security_management_addr_decoder_UBZ482 (
    .p1 ( \/security-management/addr-decoder/LE         ),
    .p2 ( \/CA1                                         ),
    .p3 ( \N$/security-management/addr-decoder|UBZ482.3 )
);

capcom_dl0921_L security_management_addr_decoder_UBZ485 (
    .p1 ( \/security-management/addr-decoder/LE         ),
    .p2 ( \/CA2                                         ),
    .p3 ( \N$/security-management/addr-decoder|UBZ485.3 )
);

capcom_dl0921_L security_management_addr_decoder_UBZ488 (
    .p1 ( \/security-management/addr-decoder/LE         ),
    .p2 ( \/CA3                                         ),
    .p3 ( \N$/security-management/addr-decoder|UBZ488.3 )
);

capcom_dl0921_L security_management_addr_decoder_UBZ491 (
    .p1 ( \/security-management/addr-decoder/LE    ),
    .p2 ( \/CA4                                    ),
    .p3 ( \N$/security-management/addr-decoder|w21 )
);

capcom_dl0921_L security_management_addr_decoder_UBZ493 (
    .p1 ( \/security-management/addr-decoder/LE         ),
    .p2 ( \/CA5                                         ),
    .p3 ( \N$/security-management/addr-decoder|UBZ493.3 )
);

capcom_dl0921_BUF12 security_management_addr_decoder_UCC481 (
    .p1 ( \N$/security-management/addr-decoder|UBZ482.3 ),
    .p2 ( \/security-management/addr-decoder/CA5        )
);

capcom_dl0921_D38GL security_management_addr_decoder_UCR348 (
    .p1  ( \/security-management/addr-decoder/CA5         ),
    .p2  ( \/security-management/addr-decoder/CA4         ),
    .p3  ( \/security-management/addr-decoder/CA3         ),
    .p4  ( \/security-management/addr-decoder/CA1         ),
    .p5  ( GND                                            ),
    .p6  ( \/security-management/addr-decoder/CA2         ),
    .p7  ( \/security-management/addr-decoder/0x2E        ),
    .p9  ( \/security-management/addr-decoder/0x2C        ),
    .p10 ( \/security-management/addr-decoder/0x2A        ),
    .p11 ( \/security-management/addr-decoder/0x28        ),
    .p12 ( \/security-management/addr-decoder/0x26        ),
    .p13 ( \N$/security-management/addr-decoder|UCR348.13 ),
    .p14 ( \N$/security-management/addr-decoder|UCR348.14 ),
    .p15 ( \N$/security-management/addr-decoder|UCR348.15 )
);

//========================================================================
// security-management/bus-mux-key:
//========================================================================
capcom_dl0921_M151C security_management_bus_mux_key_UCJ192 (
    .p1  ( \/raster-interrupts/counters-bus-buffer/IN3       ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN2       ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN1       ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN0       ),
    .p5  ( \/security-management/bus-mux-key/LAYER-D2        ),
    .p7  ( GND                                               ),
    .p9  ( \/security-management/addr-decoder-registry/KEY11 ),
    .p10 ( \/security-management/addr-decoder-registry/KEY12 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY13 ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN7       ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN6       ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5       ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN4       )
);

capcom_dl0921_M151C security_management_bus_mux_key_UCL166 (
    .p1  ( \/raster-interrupts/counters-bus-buffer/IN3       ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN2       ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN1       ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN0       ),
    .p5  ( \/security-management/bus-mux-key/LAYER-D5        ),
    .p7  ( GND                                               ),
    .p9  ( \/security-management/addr-decoder-registry/KEY78 ),
    .p10 ( \/security-management/addr-decoder-registry/KEY79 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY80 ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN7       ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN6       ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5       ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN4       )
);

capcom_dl0921_M151C security_management_bus_mux_key_UCO109 (
    .p1  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p5  ( \/security-management/bus-mux-key/LAYER-D1  ),
    .p7  ( GND                                         ),
    .p9  ( \/security-management/bus-mux-key/KEY135    ),
    .p10 ( \/security-management/bus-mux-key/KEY136    ),
    .p11 ( \/security-management/bus-mux-key/KEY137    ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN4 )
);

capcom_dl0921_M151C security_management_bus_mux_key_UCO184 (
    .p1  ( \/raster-interrupts/counters-bus-buffer/IN3       ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN2       ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN1       ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN0       ),
    .p5  ( \/security-management/bus-mux-key/LAYER-D3        ),
    .p7  ( GND                                               ),
    .p9  ( \/security-management/addr-decoder-registry/KEY39 ),
    .p10 ( \/security-management/addr-decoder-registry/KEY40 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY41 ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN7       ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN6       ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5       ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN4       )
);

capcom_dl0921_M151C security_management_bus_mux_key_UCO26 (
    .p1  ( \/raster-interrupts/counters-bus-buffer/IN3        ),
    .p2  ( \/raster-interrupts/counters-bus-buffer/IN2        ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN1        ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN0        ),
    .p5  ( \/security-management/bus-mux-key/LAYER-D4         ),
    .p7  ( GND                                                ),
    .p9  ( \/security-management/addr-decoder-registry/KEY112 ),
    .p10 ( \/security-management/addr-decoder-registry/KEY113 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY114 ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN7        ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN6        ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5        ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN4        )
);

//========================================================================
// security-management/keyinject:
//========================================================================
capcom_dl0921_XNOR02 security_management_keyinject_UCQ1 (
    .p1 ( \N$/security-management/keyinject|w40  ),
    .p2 ( \N$/security-management/keyinject|w114 ),
    .p3 ( \N$/security-management/keyinject|w57  )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCQ10 (
    .p1 ( \/security-management/keyinject/~CLK      ),
    .p2 ( \N$/security-management/keyinject|w57     ),
    .p3 ( \N$/security-management/keyinject|w114    ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCQ10.5 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCQ15 (
    .p1 ( \/security-management/keyinject/~CLK      ),
    .p2 ( \N$/security-management/keyinject|w86     ),
    .p3 ( \N$/security-management/keyinject|w105    ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCQ15.5 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCQ19 (
    .p1 ( \/security-management/keyinject/~CLK      ),
    .p2 ( \N$/security-management/keyinject|w58     ),
    .p3 ( \N$/security-management/keyinject|w98     ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCQ19.5 )
);

capcom_dl0921_AND02 security_management_keyinject_UCQ25 (
    .p1 ( \/security-management/keyinject/~RESET ),
    .p2 ( \/security-management/SEC-DATA         ),
    .p3 ( \/security-management/keyinject/DATA   )
);

capcom_dl0921_AND02 security_management_keyinject_UCQ28 (
    .p1 ( \/security-management/keyinject/DATA     ),
    .p2 ( \/security-management/keyinject/STAGE3-Q ),
    .p3 ( \/security-management/security-key/DATA  )
);

capcom_dl0921_INV01 security_management_keyinject_UCQ31 (
    .p1 ( \/security-management/keyinject/~E1   ),
    .p2 ( \N$/security-management/keyinject|w43 )
);

capcom_dl0921_AND02 security_management_keyinject_UCQ32 (
    .p1 ( \/security-management/keyinject/E2     ),
    .p2 ( \N$/security-management/keyinject|w43  ),
    .p3 ( \/security-management/keyinject/~RESET )
);

capcom_dl0921_INV01 security_management_keyinject_UCQ36 (
    .p1 ( \/security-management/keyinject/S1-STROBE ),
    .p2 ( \N$/security-management/keyinject|w151    )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCQ40 (
    .p1 ( \/security-management/keyinject/S1-STROBE ),
    .p2 ( \N$/security-management/keyinject|w147    ),
    .p3 ( \N$/security-management/keyinject|w78     ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCQ40.5 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCQ44 (
    .p1 ( \/security-management/keyinject/S1-STROBE ),
    .p2 ( \N$/security-management/keyinject|w126    ),
    .p3 ( \N$/security-management/keyinject|w66     ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCQ44.5 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCQ48 (
    .p1 ( \/security-management/keyinject/S1-STROBE ),
    .p2 ( \N$/security-management/keyinject|w132    ),
    .p3 ( \N$/security-management/keyinject|w149    ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCQ48.5 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCQ6 (
    .p1 ( \/security-management/keyinject/~CLK     ),
    .p2 ( \N$/security-management/keyinject|w85    ),
    .p3 ( \N$/security-management/keyinject|w124   ),
    .p4 ( \/security-management/keyinject/~RESET   ),
    .p5 ( \N$/security-management/keyinject|UCQ6.5 )
);

capcom_dl0921_NAND03 security_management_keyinject_UCS1 (
    .p1 ( \N$/security-management/keyinject|w114   ),
    .p2 ( \N$/security-management/keyinject|w124   ),
    .p3 ( \/security-management/keyinject/STAGE2-Q ),
    .p4 ( \N$/security-management/keyinject|w41    )
);

capcom_dl0921_NAND05 security_management_keyinject_UCS12 (
    .p1 ( \N$/security-management/keyinject|w98     ),
    .p2 ( \N$/security-management/keyinject|w105    ),
    .p3 ( \N$/security-management/keyinject|w114    ),
    .p4 ( \N$/security-management/keyinject|w124    ),
    .p5 ( \/security-management/keyinject/STAGE2-Q  ),
    .p6 ( \N$/security-management/keyinject|UCS12.6 )
);

capcom_dl0921_INV01 security_management_keyinject_UCS16 (
    .p1 ( \/security-management/keyinject/CLK  ),
    .p2 ( \/security-management/keyinject/~CLK )
);

capcom_dl0921_XNOR02 security_management_keyinject_UCS18 (
    .p1 ( \N$/security-management/keyinject|w42 ),
    .p2 ( \N$/security-management/keyinject|w98 ),
    .p3 ( \N$/security-management/keyinject|w58 )
);

capcom_dl0921_AND02 security_management_keyinject_UCS21 (
    .p1 ( \/security-management/keyinject/~RESET ),
    .p2 ( \/security-management/SEC-CLK          ),
    .p3 ( \/security-management/keyinject/CLK    )
);

capcom_dl0921_INV01 security_management_keyinject_UCS24 (
    .p1 ( \N$/security-management/keyinject|w199 ),
    .p2 ( \N$/security-management/keyinject|w212 )
);

capcom_dl0921_AND02 security_management_keyinject_UCS26 (
    .p1 ( \/security-management/keyinject/CLK      ),
    .p2 ( \/security-management/keyinject/STAGE3-Q ),
    .p3 ( \/security-management/security-key/CLK   )
);

capcom_dl0921_INV01 security_management_keyinject_UCS29 (
    .p1 ( \N$/security-management/keyinject|UCS12.6 ),
    .p2 ( \N$/security-management/keyinject|w154    )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCS32 (
    .p1 ( \/security-management/keyinject/CLK       ),
    .p2 ( \N$/security-management/keyinject|w154    ),
    .p3 ( \N$/security-management/keyinject|w168    ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCS32.5 )
);

capcom_dl0921_INV01 security_management_keyinject_UCS39 (
    .p1 ( \N$/security-management/keyinject|w78  ),
    .p2 ( \N$/security-management/keyinject|w147 )
);

capcom_dl0921_NAND02 security_management_keyinject_UCS4 (
    .p1 ( \N$/security-management/keyinject|w124   ),
    .p2 ( \/security-management/keyinject/STAGE2-Q ),
    .p3 ( \N$/security-management/keyinject|w40    )
);

capcom_dl0921_XOR02 security_management_keyinject_UCS41 (
    .p1 ( \N$/security-management/keyinject|w66  ),
    .p2 ( \N$/security-management/keyinject|w78  ),
    .p3 ( \N$/security-management/keyinject|w126 )
);

capcom_dl0921_AND03 security_management_keyinject_UCS44 (
    .p1 ( \N$/security-management/keyinject|w149    ),
    .p2 ( \N$/security-management/keyinject|w141    ),
    .p3 ( \N$/security-management/keyinject|w147    ),
    .p4 ( \N$/security-management/keyinject|UCT48.2 )
);

capcom_dl0921_INV01 security_management_keyinject_UCS48 (
    .p1 ( \N$/security-management/keyinject|w66  ),
    .p2 ( \N$/security-management/keyinject|w141 )
);

capcom_dl0921_NAND02 security_management_keyinject_UCS50 (
    .p1 ( \N$/security-management/keyinject|w66 ),
    .p2 ( \N$/security-management/keyinject|w78 ),
    .p3 ( \N$/security-management/keyinject|w92 )
);

capcom_dl0921_XNOR02 security_management_keyinject_UCS52 (
    .p1 ( \N$/security-management/keyinject|w149 ),
    .p2 ( \N$/security-management/keyinject|w92  ),
    .p3 ( \N$/security-management/keyinject|w132 )
);

capcom_dl0921_XNOR02 security_management_keyinject_UCS6 (
    .p1 ( \N$/security-management/keyinject|w41  ),
    .p2 ( \N$/security-management/keyinject|w105 ),
    .p3 ( \N$/security-management/keyinject|w86  )
);

capcom_dl0921_NAND04 security_management_keyinject_UCS9 (
    .p1 ( \N$/security-management/keyinject|w105   ),
    .p2 ( \N$/security-management/keyinject|w114   ),
    .p3 ( \N$/security-management/keyinject|w124   ),
    .p4 ( \/security-management/keyinject/STAGE2-Q ),
    .p5 ( \N$/security-management/keyinject|w42    )
);

capcom_dl0921_INV01 security_management_keyinject_UCT0 (
    .p1 ( \N$/security-management/keyinject|w180 ),
    .p2 ( \N$/security-management/keyinject|w216 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCT12 (
    .p1 ( \/security-management/keyinject/~CLK      ),
    .p2 ( \N$/security-management/keyinject|w180    ),
    .p3 ( \N$/security-management/keyinject|w189    ),
    .p4 ( \/bus-io/MUTE-OUT                         ),
    .p5 ( \N$/security-management/keyinject|UCT12.5 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCT16 (
    .p1 ( \/security-management/keyinject/~CLK      ),
    .p2 ( \N$/security-management/keyinject|w189    ),
    .p3 ( \N$/security-management/keyinject|w199    ),
    .p4 ( \/bus-io/MUTE-OUT                         ),
    .p5 ( \N$/security-management/keyinject|UCT16.5 )
);

capcom_dl0921_XOR02 security_management_keyinject_UCT2 (
    .p1 ( \/security-management/keyinject/STAGE2-Q ),
    .p2 ( \N$/security-management/keyinject|w124   ),
    .p3 ( \N$/security-management/keyinject|w85    )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCT21 (
    .p1 ( \/security-management/keyinject/~CLK      ),
    .p2 ( \N$/security-management/keyinject|w199    ),
    .p3 ( \N$/security-management/keyinject|w215    ),
    .p4 ( \/bus-io/MUTE-OUT                         ),
    .p5 ( \N$/security-management/keyinject|UCT21.5 )
);

capcom_dl0921_NOR05 security_management_keyinject_UCT27 (
    .p1 ( \N$/security-management/keyinject|w219      ),
    .p2 ( \/security-management/keyinject/STAGE-RESET ),
    .p3 ( \N$/security-management/keyinject|w216      ),
    .p4 ( \N$/security-management/keyinject|w212      ),
    .p5 ( \N$/security-management/keyinject|w189      ),
    .p6 ( \N$/security-management/keyinject|w215      )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCT32 (
    .p1 ( \/security-management/keyinject/CLK       ),
    .p2 ( \N$/security-management/keyinject|w219    ),
    .p3 ( \N$/security-management/keyinject|w220    ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCT32.5 )
);

capcom_dl0921_RSLT security_management_keyinject_UCT38 (
    .p1 ( \N$/security-management/keyinject|w220      ),
    .p2 ( \/security-management/keyinject/STAGE-RESET ),
    .p3 ( \/security-management/keyinject/STAGE2-Q    )
);

capcom_dl0921_RSLT security_management_keyinject_UCT42 (
    .p1 ( \N$/security-management/keyinject|w168      ),
    .p2 ( \/security-management/keyinject/STAGE-RESET ),
    .p3 ( \/security-management/keyinject/STAGE3-Q    )
);

capcom_dl0921_INV01 security_management_keyinject_UCT45 (
    .p1 ( \/bus-io/MUTE-OUT                           ),
    .p2 ( \/security-management/keyinject/STAGE-RESET )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCT48 (
    .p1 ( \N$/security-management/keyinject|w151    ),
    .p2 ( \N$/security-management/keyinject|UCT48.2 ),
    .p3 ( \/bus-io/MUTE-OUT                         ),
    .p4 ( \/security-management/keyinject/~RESET    ),
    .p5 ( \N$/security-management/keyinject|UCT48.5 )
);

capcom_dl0921_DFFCOR security_management_keyinject_UCT7 (
    .p1 ( \/security-management/keyinject/~CLK     ),
    .p2 ( \/security-management/keyinject/DATA     ),
    .p3 ( \N$/security-management/keyinject|w180   ),
    .p4 ( \/bus-io/MUTE-OUT                        ),
    .p5 ( \N$/security-management/keyinject|UCT7.5 )
);

//========================================================================
// security-management/security-decoder:
//========================================================================
capcom_dl0921_M367C security_management_security_decoder_UBN406 (
    .p1  ( \/~DEBUG9          ),
    .p2  ( GND                ),
    .p3  ( GND                ),
    .p4  ( GND                ),
    .p5  ( GND                ),
    .p15 ( \/debug/td-io/IN11 ),
    .p16 ( \/debug/td-io/IN10 ),
    .p17 ( \/debug/td-io/IN9  ),
    .p18 ( \/debug/td-io/IN8  )
);

capcom_dl0921_M541C security_management_security_decoder_UBR194 (
    .p1  ( \/~DEBUG15                                         ),
    .p2  ( GND                                                ),
    .p3  ( GND                                                ),
    .p4  ( GND                                                ),
    .p5  ( GND                                                ),
    .p6  ( GND                                                ),
    .p7  ( GND                                                ),
    .p8  ( GND                                                ),
    .p9  ( GND                                                ),
    .p11 ( \N$/security-management/security-decoder|UBR194.11 ),
    .p12 ( \/debug/td-io/IN11                                 ),
    .p13 ( \/debug/td-io/IN10                                 ),
    .p14 ( \/debug/td-io/IN9                                  ),
    .p15 ( \/debug/td-io/IN8                                  ),
    .p16 ( \/debug/td-io/IN7                                  ),
    .p17 ( \/debug/td-io/IN6                                  ),
    .p18 ( \/debug/td-io/IN5                                  )
);

capcom_dl0921_M541C security_management_security_decoder_UBR345 (
    .p1  ( \/~DEBUG9                           ),
    .p2  ( \/raster-interrupts/counter1/ENABLE ),
    .p3  ( GND                                 ),
    .p4  ( GND                                 ),
    .p5  ( GND                                 ),
    .p6  ( GND                                 ),
    .p7  ( GND                                 ),
    .p8  ( GND                                 ),
    .p9  ( GND                                 ),
    .p11 ( \/debug/td-io/IN7                   ),
    .p12 ( \/debug/td-io/IN6                   ),
    .p13 ( \/debug/td-io/IN5                   ),
    .p14 ( \/debug/td-io/IN4                   ),
    .p15 ( \/debug/td-io/IN3                   ),
    .p16 ( \/debug/td-io/IN2                   ),
    .p17 ( \/debug/td-io/IN1                   ),
    .p18 ( \/debug/td-io/IN0                   )
);

capcom_dl0921_MUX26H security_management_security_decoder_UBU187 (
    .p1  ( \/security-management/addr-decoder-registry/~MULT-X   ),
    .p2  ( \/security-management/addr-decoder-registry/~MULT-Y   ),
    .p3  ( \/security-management/addr-decoder-registry/~MULT-LSB ),
    .p4  ( \/security-management/addr-decoder-registry/~MULT-MSB ),
    .p5  ( \/security-management/addr-decoder-registry/~MULT-TC  ),
    .p6  ( \/security-management/addr-decoder-registry/~CHECK1   ),
    .p7  ( \/security-management/addr-decoder/0x00               ),
    .p8  ( \/security-management/addr-decoder/0x02               ),
    .p9  ( \/security-management/addr-decoder/0x04               ),
    .p10 ( \/security-management/addr-decoder/0x06               ),
    .p11 ( \/security-management/addr-decoder/0x08               ),
    .p12 ( \/security-management/addr-decoder/0x0A               ),
    .p13 ( \/multiplier/~X-E                                     ),
    .p14 ( \/multiplier/~Y-E                                     ),
    .p15 ( \/multiplier/~LSB-E                                   ),
    .p16 ( \/multiplier/~MSB-E                                   ),
    .p17 ( \/multiplier/~TC-E                                    ),
    .p18 ( \/security-check/~E1                                  ),
    .p19 ( \/main-signals/DEFAULT                                )
);

capcom_dl0921_M541C security_management_security_decoder_UBU234 (
    .p1  ( \/~DEBUG8                           ),
    .p2  ( \/multiplier/~X-E                   ),
    .p3  ( \/multiplier/~Y-E                   ),
    .p4  ( \/multiplier/~LSB-E                 ),
    .p5  ( \/multiplier/~MSB-E                 ),
    .p6  ( \/multiplier/~TC-E                  ),
    .p7  ( \/security-check/~E1                ),
    .p8  ( \/security-check/~E2                ),
    .p9  ( \/raster-interrupts/counter3/ENABLE ),
    .p11 ( \/debug/td-io/IN7                   ),
    .p12 ( \/debug/td-io/IN6                   ),
    .p13 ( \/debug/td-io/IN5                   ),
    .p14 ( \/debug/td-io/IN4                   ),
    .p15 ( \/debug/td-io/IN3                   ),
    .p16 ( \/debug/td-io/IN2                   ),
    .p17 ( \/debug/td-io/IN1                   ),
    .p18 ( \/debug/td-io/IN0                   )
);

capcom_dl0921_M367C security_management_security_decoder_UBU427 (
    .p1  ( \/~DEBUG8                           ),
    .p2  ( \/raster-interrupts/counter2/ENABLE ),
    .p3  ( \/raster-interrupts/counter1/RD     ),
    .p4  ( GND                                 ),
    .p5  ( GND                                 ),
    .p15 ( \/debug/td-io/IN11                  ),
    .p16 ( \/debug/td-io/IN10                  ),
    .p17 ( \/debug/td-io/IN9                   ),
    .p18 ( \/debug/td-io/IN8                   )
);

capcom_dl0921_M125C security_management_security_decoder_UBU80 (
    .p1 ( \/~DEBUG15                        ),
    .p2 ( \/lut-assembly/layer-control/BUS1 ),
    .p3 ( \/debug/td-io/IN0                 )
);

capcom_dl0921_M367C security_management_security_decoder_UBU83 (
    .p1  ( \/~DEBUG15                        ),
    .p2  ( \/lut-assembly/layer-control/BUS2 ),
    .p3  ( \/lut-assembly/layer-control/BUS3 ),
    .p4  ( \/lut-assembly/layer-control/BUS4 ),
    .p5  ( \/lut-assembly/layer-control/BUS5 ),
    .p15 ( \/debug/td-io/IN4                 ),
    .p16 ( \/debug/td-io/IN3                 ),
    .p17 ( \/debug/td-io/IN2                 ),
    .p18 ( \/debug/td-io/IN1                 )
);

capcom_dl0921_MUX26H security_management_security_decoder_UBW221 (
    .p1  ( \/security-management/addr-decoder-registry/~CHECK2     ),
    .p2  ( \/security-management/addr-decoder-registry/~RASTER1    ),
    .p3  ( \/security-management/addr-decoder-registry/~RASTER2    ),
    .p4  ( \/security-management/addr-decoder-registry/~RASTER3    ),
    .p5  ( \/security-management/addr-decoder-registry/~LAYER-CTRL ),
    .p6  ( \/security-management/addr-decoder-registry/~PRIORITY0  ),
    .p7  ( \/security-management/addr-decoder/0x0C                 ),
    .p8  ( \/security-management/addr-decoder/0x0E                 ),
    .p9  ( \/security-management/addr-decoder/0x10                 ),
    .p10 ( \/security-management/addr-decoder/0x12                 ),
    .p11 ( \/security-management/addr-decoder/0x26                 ),
    .p12 ( \/security-management/addr-decoder/0x28                 ),
    .p13 ( \/security-check/~E2                                    ),
    .p14 ( \/raster-interrupts/counter3/ENABLE                     ),
    .p15 ( \/raster-interrupts/counter2/ENABLE                     ),
    .p16 ( \/raster-interrupts/counter1/ENABLE                     ),
    .p17 ( \/lut-assembly/layer-control/~E                         ),
    .p18 ( \/lut-assembly/priority-masks/ROW0                      ),
    .p19 ( \/main-signals/DEFAULT                                  )
);

capcom_dl0921_M541C security_management_security_decoder_UBW328 (
    .p1  ( \/~DEBUG10                         ),
    .p2  ( \/lut-assembly/layer-control/~E    ),
    .p3  ( \/lut-assembly/priority-masks/ROW0 ),
    .p4  ( \/lut-assembly/priority-masks/ROW1 ),
    .p5  ( \/lut-assembly/priority-masks/ROW2 ),
    .p6  ( \/lut-assembly/priority-masks/ROW3 ),
    .p7  ( \/palette-control/~E               ),
    .p8  ( \/cps-id/~E                        ),
    .p9  ( \/video-signals/video-counter/~E   ),
    .p11 ( \/debug/td-io/IN7                  ),
    .p12 ( \/debug/td-io/IN6                  ),
    .p13 ( \/debug/td-io/IN5                  ),
    .p14 ( \/debug/td-io/IN4                  ),
    .p15 ( \/debug/td-io/IN3                  ),
    .p16 ( \/debug/td-io/IN2                  ),
    .p17 ( \/debug/td-io/IN1                  ),
    .p18 ( \/debug/td-io/IN0                  )
);

capcom_dl0921_M367C security_management_security_decoder_UBW426 (
    .p1  ( \/~DEBUG10                      ),
    .p2  ( \/raster-interrupts/counter1/RD ),
    .p3  ( \/lut-assembly/layer-control/WR ),
    .p4  ( GND                             ),
    .p5  ( GND                             ),
    .p15 ( \/debug/td-io/IN11              ),
    .p16 ( \/debug/td-io/IN10              ),
    .p17 ( \/debug/td-io/IN9               ),
    .p18 ( \/debug/td-io/IN8               )
);

capcom_dl0921_MUX25H security_management_security_decoder_UBZ106 (
    .p1  ( \/security-management/bus-mux-key/LAYER-D4  ),
    .p2  ( \/security-management/bus-mux-key/LAYER-D5  ),
    .p3  ( \/security-management/bus-mux-key/LAYER-D3  ),
    .p4  ( \/security-management/bus-mux-key/LAYER-D2  ),
    .p5  ( \/security-management/bus-mux-key/LAYER-D1  ),
    .p6  ( \/lut-assembly/layer-control/BUS1           ),
    .p7  ( \/lut-assembly/layer-control/BUS2           ),
    .p8  ( \/lut-assembly/layer-control/BUS3           ),
    .p9  ( \/lut-assembly/layer-control/BUS4           ),
    .p10 ( \/lut-assembly/layer-control/BUS5           ),
    .p11 ( \/main-signals/DEFAULT                      ),
    .p12 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p15 ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p16 ( \/raster-interrupts/counters-bus-buffer/IN1 )
);

capcom_dl0921_MUX25H security_management_security_decoder_UBZ248 (
    .p1  ( \/security-management/addr-decoder-registry/~PAL-CTRL  ),
    .p2  ( \/security-management/addr-decoder-registry/~CPS-ID    ),
    .p3  ( \/security-management/addr-decoder-registry/~PRIORITY3 ),
    .p4  ( \/security-management/addr-decoder-registry/~PRIORITY2 ),
    .p5  ( \/security-management/addr-decoder-registry/~PRIORITY1 ),
    .p6  ( \/lut-assembly/priority-masks/ROW1                     ),
    .p7  ( \/lut-assembly/priority-masks/ROW2                     ),
    .p8  ( \/lut-assembly/priority-masks/ROW3                     ),
    .p9  ( \/palette-control/~E                                   ),
    .p10 ( \/cps-id/~E                                            ),
    .p11 ( \/main-signals/DEFAULT                                 ),
    .p12 ( \/security-management/addr-decoder/0x30                ),
    .p13 ( \/security-management/addr-decoder/0x32                ),
    .p14 ( \/security-management/addr-decoder/0x2E                ),
    .p15 ( \/security-management/addr-decoder/0x2C                ),
    .p16 ( \/security-management/addr-decoder/0x2A                )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL28 (
    .p1 ( \N$/security-management/security-decoder|w384      ),
    .p2 ( \/security-management/addr-decoder-registry/KEY106 ),
    .p3 ( \/CHECK2-D0                                        )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL30 (
    .p1 ( \N$/security-management/security-decoder|w384      ),
    .p2 ( \/security-management/addr-decoder-registry/KEY105 ),
    .p3 ( \/CHECK2-D1                                        )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL32 (
    .p1 ( \N$/security-management/security-decoder|w384      ),
    .p2 ( \/security-management/addr-decoder-registry/KEY104 ),
    .p3 ( \/CHECK2-D2                                        )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL34 (
    .p1 ( \N$/security-management/security-decoder|w384      ),
    .p2 ( \/security-management/addr-decoder-registry/KEY103 ),
    .p3 ( \/CHECK2-D3                                        )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL37 (
    .p1 ( \N$/security-management/security-decoder|w384      ),
    .p2 ( \/security-management/addr-decoder-registry/KEY102 ),
    .p3 ( \/CHECK2-D4                                        )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL39 (
    .p1 ( \N$/security-management/security-decoder|w384      ),
    .p2 ( \/security-management/addr-decoder-registry/KEY101 ),
    .p3 ( \/CHECK2-D5                                        )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL41 (
    .p1 ( \N$/security-management/security-decoder|w384      ),
    .p2 ( \/security-management/addr-decoder-registry/KEY100 ),
    .p3 ( \/CHECK2-D6                                        )
);

capcom_dl0921_AND02 security_management_security_decoder_UCL43 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY99 ),
    .p3 ( \/CHECK2-D7                                       )
);

capcom_dl0921_NBUF03 security_management_security_decoder_UCO137 (
    .p1 ( \/main-signals/DEFAULT                        ),
    .p2 ( \N$/security-management/security-decoder|w384 )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO139 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY77 ),
    .p3 ( \/CHECK1-D0                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO141 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY76 ),
    .p3 ( \/CHECK1-D1                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO143 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY75 ),
    .p3 ( \/CHECK1-D2                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO145 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY74 ),
    .p3 ( \/CHECK1-D3                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO148 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY73 ),
    .p3 ( \/CHECK1-D4                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO150 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY72 ),
    .p3 ( \/CHECK1-D5                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO152 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY71 ),
    .p3 ( \/CHECK1-D6                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO154 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY70 ),
    .p3 ( \/CHECK1-D7                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO160 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY69 ),
    .p3 ( \/CHECK1-D8                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO162 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY68 ),
    .p3 ( \/CHECK1-D9                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO165 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY67 ),
    .p3 ( \/CHECK1-D10                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO167 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY66 ),
    .p3 ( \/CHECK1-D11                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO169 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY65 ),
    .p3 ( \/CHECK1-D12                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO171 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY64 ),
    .p3 ( \/CHECK1-D13                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO174 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY63 ),
    .p3 ( \/CHECK1-D14                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO176 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY62 ),
    .p3 ( \/CHECK1-D15                                      )
);

capcom_dl0921_NBUF03 security_management_security_decoder_UCO332 (
    .p1 ( \/main-signals/DEFAULT                        ),
    .p2 ( \N$/security-management/security-decoder|w285 )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO354 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY142 ),
    .p3 ( \/cps-id/CPS-ID-D11                           )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO356 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY143 ),
    .p3 ( \/cps-id/CPS-ID-D10                           )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO358 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY5   ),
    .p3 ( \/cps-id/CPS-ID-D0                            )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO360 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY4   ),
    .p3 ( \/cps-id/CPS-ID-D1                            )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO363 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY3   ),
    .p3 ( \/cps-id/CPS-ID-D2                            )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO365 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY2   ),
    .p3 ( \/cps-id/CPS-ID-D3                            )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO367 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY1   ),
    .p3 ( \/cps-id/CPS-ID-D4                            )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO369 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY0   ),
    .p3 ( \/cps-id/CPS-ID-D5                            )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO61 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY98 ),
    .p3 ( \/CHECK2-D8                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO63 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY97 ),
    .p3 ( \/CHECK2-D9                                       )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO66 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY96 ),
    .p3 ( \/CHECK2-D10                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO68 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY95 ),
    .p3 ( \/CHECK2-D11                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO70 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY94 ),
    .p3 ( \/CHECK2-D12                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO72 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY93 ),
    .p3 ( \/CHECK2-D13                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO74 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY92 ),
    .p3 ( \/CHECK2-D14                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCO77 (
    .p1 ( \N$/security-management/security-decoder|w384     ),
    .p2 ( \/security-management/addr-decoder-registry/KEY91 ),
    .p3 ( \/CHECK2-D15                                      )
);

capcom_dl0921_AND02 security_management_security_decoder_UCR339 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY141 ),
    .p3 ( \/cps-id/CPS-ID-D12                           )
);

capcom_dl0921_AND02 security_management_security_decoder_UCR342 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY140 ),
    .p3 ( \/cps-id/CPS-ID-D13                           )
);

capcom_dl0921_AND02 security_management_security_decoder_UCR344 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY139 ),
    .p3 ( \/cps-id/CPS-ID-D14                           )
);

capcom_dl0921_AND02 security_management_security_decoder_UCR346 (
    .p1 ( \N$/security-management/security-decoder|w285 ),
    .p2 ( \/security-management/security-decoder/KEY138 ),
    .p3 ( \/cps-id/CPS-ID-D15                           )
);

//========================================================================
// security-management/security-key:
//========================================================================
capcom_dl0921_M164C security_management_security_key_UCR130 (
    .p1  ( \/security-management/addr-decoder-registry/KEY80 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY79 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY78 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY77 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY76 ),
    .p8  ( \N$/security-management/security-key|w88          ),
    .p10 ( \/security-management/addr-decoder-registry/KEY75 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY74 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY73 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY72 )
);

capcom_dl0921_M164C security_management_security_key_UCR166 (
    .p1  ( \/security-management/addr-decoder-registry/KEY24 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY23 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY22 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY21 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY20 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY19 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY18 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY17 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY16 )
);

capcom_dl0921_M164C security_management_security_key_UCR200 (
    .p1  ( \/security-management/addr-decoder-registry/KEY16 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY15 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY14 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY13 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY12 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY11 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY10 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY9  ),
    .p13 ( \/security-management/addr-decoder-registry/KEY8  )
);

capcom_dl0921_M164C security_management_security_key_UCR233 (
    .p1  ( \/security-management/addr-decoder-registry/KEY8 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY7 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY6 ),
    .p5  ( \/security-management/security-decoder/KEY5      ),
    .p6  ( \/security-management/security-decoder/KEY4      ),
    .p8  ( \N$/security-management/security-key|w202        ),
    .p10 ( \/security-management/security-decoder/KEY3      ),
    .p11 ( \/security-management/security-decoder/KEY2      ),
    .p12 ( \/security-management/security-decoder/KEY1      ),
    .p13 ( \/security-management/security-decoder/KEY0      )
);

capcom_dl0921_M164C security_management_security_key_UCR62 (
    .p1  ( \/security-management/addr-decoder-registry/KEY96 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY95 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY94 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY93 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY92 ),
    .p8  ( \N$/security-management/security-key|w88          ),
    .p10 ( \/security-management/addr-decoder-registry/KEY91 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY90 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY89 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY88 )
);

capcom_dl0921_M164C security_management_security_key_UCR96 (
    .p1  ( \/security-management/addr-decoder-registry/KEY88 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY87 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY86 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY85 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY84 ),
    .p8  ( \N$/security-management/security-key|w88          ),
    .p10 ( \/security-management/addr-decoder-registry/KEY83 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY82 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY81 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY80 )
);

capcom_dl0921_M164C security_management_security_key_UCS130 (
    .p1  ( \/security-management/addr-decoder-registry/KEY104 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY103 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY102 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY101 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY100 ),
    .p8  ( \N$/security-management/security-key|w88           ),
    .p10 ( \/security-management/addr-decoder-registry/KEY99  ),
    .p11 ( \/security-management/addr-decoder-registry/KEY98  ),
    .p12 ( \/security-management/addr-decoder-registry/KEY97  ),
    .p13 ( \/security-management/addr-decoder-registry/KEY96  )
);

capcom_dl0921_M164C security_management_security_key_UCS166 (
    .p1  ( \/security-management/addr-decoder-registry/KEY48 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY47 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY46 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY45 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY44 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY43 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY42 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY41 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY40 )
);

capcom_dl0921_M164C security_management_security_key_UCS200 (
    .p1  ( \/security-management/addr-decoder-registry/KEY40 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY39 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY38 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY37 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY36 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY35 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY34 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY33 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY32 )
);

capcom_dl0921_M164C security_management_security_key_UCS234 (
    .p1  ( \/security-management/addr-decoder-registry/KEY32 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY31 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY30 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY29 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY28 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY27 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY26 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY25 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY24 )
);

capcom_dl0921_M164C security_management_security_key_UCS62 (
    .p1  ( \/security-management/addr-decoder-registry/KEY120 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY119 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY118 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY117 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY116 ),
    .p8  ( \N$/security-management/security-key|w88           ),
    .p10 ( \/security-management/addr-decoder-registry/KEY115 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY114 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY113 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY112 )
);

capcom_dl0921_M164C security_management_security_key_UCS96 (
    .p1  ( \/security-management/addr-decoder-registry/KEY112 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY111 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY110 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY109 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY108 ),
    .p8  ( \N$/security-management/security-key|w88           ),
    .p10 ( \/security-management/addr-decoder-registry/KEY107 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY106 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY105 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY104 )
);

capcom_dl0921_M164C security_management_security_key_UCT130 (
    .p1  ( \/security-management/addr-decoder-registry/KEY128 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY127 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY126 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY125 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY124 ),
    .p8  ( \N$/security-management/security-key|w88           ),
    .p10 ( \/security-management/addr-decoder-registry/KEY123 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY122 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY121 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY120 )
);

capcom_dl0921_BUF12 security_management_security_key_UCT164 (
    .p1 ( \/security-management/security-key/CLK    ),
    .p2 ( \N$/security-management/security-key|w202 )
);

capcom_dl0921_M164C security_management_security_key_UCT166 (
    .p1  ( \/security-management/addr-decoder-registry/KEY72 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY71 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY70 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY69 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY68 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY67 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY66 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY65 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY64 )
);

capcom_dl0921_M164C security_management_security_key_UCT200 (
    .p1  ( \/security-management/addr-decoder-registry/KEY64 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY63 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY62 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY61 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY60 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY59 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY58 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY57 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY56 )
);

capcom_dl0921_M164C security_management_security_key_UCT234 (
    .p1  ( \/security-management/addr-decoder-registry/KEY56 ),
    .p3  ( \/security-management/addr-decoder-registry/KEY55 ),
    .p4  ( \/security-management/addr-decoder-registry/KEY54 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY53 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY52 ),
    .p8  ( \N$/security-management/security-key|w202         ),
    .p10 ( \/security-management/addr-decoder-registry/KEY51 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY50 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY49 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY48 )
);

capcom_dl0921_BUF12 security_management_security_key_UCT60 (
    .p1 ( \/security-management/security-key/CLK   ),
    .p2 ( \N$/security-management/security-key|w88 )
);

capcom_dl0921_M164C security_management_security_key_UCT62 (
    .p1  ( \/security-management/security-key/DATA       ),
    .p3  ( \/security-management/security-decoder/KEY143 ),
    .p4  ( \/security-management/security-decoder/KEY142 ),
    .p5  ( \/security-management/security-decoder/KEY141 ),
    .p6  ( \/security-management/security-decoder/KEY140 ),
    .p8  ( \N$/security-management/security-key|w88      ),
    .p10 ( \/security-management/security-decoder/KEY139 ),
    .p11 ( \/security-management/security-decoder/KEY138 ),
    .p12 ( \/security-management/bus-mux-key/KEY137      ),
    .p13 ( \/security-management/bus-mux-key/KEY136      )
);

capcom_dl0921_M164C security_management_security_key_UCT96 (
    .p1  ( \/security-management/bus-mux-key/KEY136           ),
    .p3  ( \/security-management/bus-mux-key/KEY135           ),
    .p4  ( \/security-management/addr-decoder-registry/KEY134 ),
    .p5  ( \/security-management/addr-decoder-registry/KEY133 ),
    .p6  ( \/security-management/addr-decoder-registry/KEY132 ),
    .p8  ( \N$/security-management/security-key|w88           ),
    .p10 ( \/security-management/addr-decoder-registry/KEY131 ),
    .p11 ( \/security-management/addr-decoder-registry/KEY130 ),
    .p12 ( \/security-management/addr-decoder-registry/KEY129 ),
    .p13 ( \/security-management/addr-decoder-registry/KEY128 )
);

//========================================================================
// stars:
//========================================================================
capcom_dl0921_AND02 stars_UBK411 (
    .p1 ( \/~DEBUG7                    ),
    .p2 ( \/stars/row6-counter/~DEBUG  ),
    .p3 ( \/stars/row6-assemble/~DEBUG )
);

capcom_dl0921_AND02 stars_UBK428 (
    .p1 ( \/~DEBUG6                    ),
    .p2 ( \/stars/row5-counter/~DEBUG  ),
    .p3 ( \/stars/row5-assemble/~DEBUG )
);

capcom_dl0921_NBUF03 stars_UBU210 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/stars/counter-xs-1/~CLK8M    )
);

//========================================================================
// stars/counter-xs-1:
//========================================================================
capcom_dl0921_INV01 stars_counter_xs_1_UBZ48 (
    .p1 ( \/counter-fi/~RESET       ),
    .p2 ( \N$/stars/counter-xs-1|w8 )
);

capcom_dl0921_INV01 stars_counter_xs_1_UCC119 (
    .p1 ( \/stars/counter-xs-1/LOAD  ),
    .p2 ( \N$/stars/counter-xs-1|w34 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC12 (
    .p1 ( \/stars/counter-xs-1/~CLK8M    ),
    .p2 ( \N$/stars/counter-xs-1|w64     ),
    .p3 ( \N$/stars/counter-xs-1|w144    ),
    .p5 ( \N$/stars/counter-xs-1|UCC12.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC16 (
    .p1 ( \/stars/counter-xs-1/~CLK8M    ),
    .p2 ( \N$/stars/counter-xs-1|w72     ),
    .p3 ( \N$/stars/counter-xs-1|w145    ),
    .p5 ( \N$/stars/counter-xs-1|UCC16.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC19 (
    .p1 ( \/stars/counter-xs-1/~CLK8M    ),
    .p2 ( \N$/stars/counter-xs-1|w74     ),
    .p3 ( \N$/stars/counter-xs-1|w146    ),
    .p5 ( \N$/stars/counter-xs-1|UCC19.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC23 (
    .p1 ( \/stars/counter-xs-1/~CLK8M    ),
    .p2 ( \N$/stars/counter-xs-1|w66     ),
    .p3 ( \N$/stars/counter-xs-1|w147    ),
    .p5 ( \N$/stars/counter-xs-1|UCC23.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC243 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/counter-xs-1|w60      ),
    .p3 ( \N$/stars/counter-xs-1|w126     ),
    .p5 ( \N$/stars/counter-xs-1|UCC243.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC247 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/counter-xs-1|w68      ),
    .p3 ( \N$/stars/counter-xs-1|w140     ),
    .p5 ( \N$/stars/counter-xs-1|UCC247.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC251 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/counter-xs-1|w70      ),
    .p3 ( \N$/stars/counter-xs-1|w141     ),
    .p5 ( \N$/stars/counter-xs-1|UCC251.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_1_UCC255 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/counter-xs-1|w62      ),
    .p3 ( \N$/stars/counter-xs-1|w142     ),
    .p5 ( \N$/stars/counter-xs-1|UCC255.5 )
);

capcom_dl0921_XNOR02 stars_counter_xs_1_UCC27 (
    .p1 ( \N$/stars/counter-xs-1|w147 ),
    .p2 ( \N$/stars/counter-xs-1|w168 ),
    .p3 ( \N$/stars/counter-xs-1|w48  )
);

capcom_dl0921_M258C stars_counter_xs_1_UCC31 (
    .p1  ( VCC                         ),
    .p2  ( VCC                         ),
    .p3  ( VCC                         ),
    .p4  ( \/stars/counter-xs-1/XS4    ),
    .p5  ( \N$/stars/counter-xs-1|w64  ),
    .p6  ( \N$/stars/counter-xs-1|w72  ),
    .p7  ( \N$/stars/counter-xs-1|w74  ),
    .p8  ( \N$/stars/counter-xs-1|w66  ),
    .p9  ( \N$/stars/counter-xs-1|w34  ),
    .p10 ( \N$/stars/counter-xs-1|w48  ),
    .p11 ( \N$/stars/counter-xs-1|w185 ),
    .p12 ( \N$/stars/counter-xs-1|w184 ),
    .p13 ( \N$/stars/counter-xs-1|w46  ),
    .p14 ( \N$/stars/counter-xs-1|w8   )
);

capcom_dl0921_NOR03 stars_counter_xs_1_UCG11 (
    .p1 ( \N$/stars/counter-xs-1|w143 ),
    .p2 ( \N$/stars/counter-xs-1|w144 ),
    .p3 ( \N$/stars/counter-xs-1|w145 ),
    .p4 ( \N$/stars/counter-xs-1|w166 )
);

capcom_dl0921_NOR04 stars_counter_xs_1_UCG14 (
    .p1 ( \N$/stars/counter-xs-1|w168 ),
    .p2 ( \N$/stars/counter-xs-1|w143 ),
    .p3 ( \N$/stars/counter-xs-1|w144 ),
    .p4 ( \N$/stars/counter-xs-1|w145 ),
    .p5 ( \N$/stars/counter-xs-1|w146 )
);

capcom_dl0921_NOR05 stars_counter_xs_1_UCG17 (
    .p1 ( \/stars/xpd6-sync/LOAD      ),
    .p2 ( \N$/stars/counter-xs-1|w143 ),
    .p3 ( \N$/stars/counter-xs-1|w144 ),
    .p4 ( \N$/stars/counter-xs-1|w146 ),
    .p5 ( \N$/stars/counter-xs-1|w145 ),
    .p6 ( \N$/stars/counter-xs-1|w147 )
);

capcom_dl0921_XNOR02 stars_counter_xs_1_UCG21 (
    .p1 ( \N$/stars/counter-xs-1|w146 ),
    .p2 ( \N$/stars/counter-xs-1|w166 ),
    .p3 ( \N$/stars/counter-xs-1|w185 )
);

capcom_dl0921_INV01 stars_counter_xs_1_UCG220 (
    .p1 ( \/counter-fi/~RESET       ),
    .p2 ( \N$/stars/counter-xs-1|w4 )
);

capcom_dl0921_M258C stars_counter_xs_1_UCG221 (
    .p1  ( \/stars/counter-xs-1/XS3    ),
    .p2  ( \/stars/counter-xs-1/XS2    ),
    .p3  ( \/stars/counter-xs-1/XS1    ),
    .p4  ( \/stars/counter-xs-1/XS0    ),
    .p5  ( \N$/stars/counter-xs-1|w60  ),
    .p6  ( \N$/stars/counter-xs-1|w68  ),
    .p7  ( \N$/stars/counter-xs-1|w70  ),
    .p8  ( \N$/stars/counter-xs-1|w62  ),
    .p9  ( \N$/stars/counter-xs-1|w34  ),
    .p10 ( \N$/stars/counter-xs-1|w43  ),
    .p11 ( \N$/stars/counter-xs-1|w178 ),
    .p12 ( \N$/stars/counter-xs-1|w42  ),
    .p13 ( \N$/stars/counter-xs-1|w126 ),
    .p14 ( \N$/stars/counter-xs-1|w4   )
);

capcom_dl0921_XNOR02 stars_counter_xs_1_UCG256 (
    .p1 ( \N$/stars/counter-xs-1|w142 ),
    .p2 ( \N$/stars/counter-xs-1|w160 ),
    .p3 ( \N$/stars/counter-xs-1|w43  )
);

capcom_dl0921_NOR04 stars_counter_xs_1_UCG259 (
    .p1 ( \N$/stars/counter-xs-1|UCG259.1 ),
    .p2 ( \N$/stars/counter-xs-1|w126     ),
    .p3 ( \N$/stars/counter-xs-1|w140     ),
    .p4 ( \N$/stars/counter-xs-1|w141     ),
    .p5 ( \N$/stars/counter-xs-1|w142     )
);

capcom_dl0921_XOR02 stars_counter_xs_1_UCG264 (
    .p1 ( \N$/stars/counter-xs-1|w140 ),
    .p2 ( \N$/stars/counter-xs-1|w126 ),
    .p3 ( \N$/stars/counter-xs-1|w42  )
);

capcom_dl0921_NOR03 stars_counter_xs_1_UCG270 (
    .p1 ( \N$/stars/counter-xs-1|w126 ),
    .p2 ( \N$/stars/counter-xs-1|w140 ),
    .p3 ( \N$/stars/counter-xs-1|w141 ),
    .p4 ( \N$/stars/counter-xs-1|w160 )
);

capcom_dl0921_NOR02 stars_counter_xs_1_UCG6 (
    .p1 ( \N$/stars/counter-xs-1|w144 ),
    .p2 ( \N$/stars/counter-xs-1|w143 ),
    .p3 ( \N$/stars/counter-xs-1|w164 )
);

capcom_dl0921_XNOR02 stars_counter_xs_1_UCG9 (
    .p1 ( \N$/stars/counter-xs-1|w145 ),
    .p2 ( \N$/stars/counter-xs-1|w164 ),
    .p3 ( \N$/stars/counter-xs-1|w184 )
);

capcom_dl0921_XNOR02 stars_counter_xs_1_UCJ270 (
    .p1 ( \N$/stars/counter-xs-1|w141 ),
    .p2 ( \N$/stars/counter-xs-1|w158 ),
    .p3 ( \N$/stars/counter-xs-1|w178 )
);

capcom_dl0921_XOR02 stars_counter_xs_1_UCJ6 (
    .p1 ( \N$/stars/counter-xs-1|w144 ),
    .p2 ( \N$/stars/counter-xs-1|w143 ),
    .p3 ( \N$/stars/counter-xs-1|w46  )
);

capcom_dl0921_NOR02 stars_counter_xs_1_UCL269 (
    .p1 ( \N$/stars/counter-xs-1|w140 ),
    .p2 ( \N$/stars/counter-xs-1|w126 ),
    .p3 ( \N$/stars/counter-xs-1|w158 )
);

capcom_dl0921_INV01 stars_counter_xs_1_UCO17 (
    .p1 ( \N$/stars/counter-xs-1|UCG259.1 ),
    .p2 ( \N$/stars/counter-xs-1|w143     )
);

//========================================================================
// stars/counter-xs-2:
//========================================================================
capcom_dl0921_DFFCOO stars_counter_xs_2_UBR18 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w65     ),
    .p3 ( \N$/stars/counter-xs-2|w145    ),
    .p5 ( \N$/stars/counter-xs-2|UBR18.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_2_UBR22 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w73     ),
    .p3 ( \N$/stars/counter-xs-2|w146    ),
    .p5 ( \N$/stars/counter-xs-2|UBR22.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_2_UBR25 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w75     ),
    .p3 ( \N$/stars/counter-xs-2|w147    ),
    .p5 ( \N$/stars/counter-xs-2|UBR25.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_2_UBR29 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w67     ),
    .p3 ( \N$/stars/counter-xs-2|w148    ),
    .p5 ( \N$/stars/counter-xs-2|UBR29.5 )
);

capcom_dl0921_NOR05 stars_counter_xs_2_UBR33 (
    .p1 ( \/stars/xpd5-sync/LOAD      ),
    .p2 ( \N$/stars/counter-xs-2|w144 ),
    .p3 ( \N$/stars/counter-xs-2|w145 ),
    .p4 ( \N$/stars/counter-xs-2|w147 ),
    .p5 ( \N$/stars/counter-xs-2|w146 ),
    .p6 ( \N$/stars/counter-xs-2|w148 )
);

capcom_dl0921_NOR02 stars_counter_xs_2_UBR37 (
    .p1 ( \N$/stars/counter-xs-2|w145 ),
    .p2 ( \N$/stars/counter-xs-2|w144 ),
    .p3 ( \N$/stars/counter-xs-2|w165 )
);

capcom_dl0921_XNOR02 stars_counter_xs_2_UBR39 (
    .p1 ( \N$/stars/counter-xs-2|w146 ),
    .p2 ( \N$/stars/counter-xs-2|w165 ),
    .p3 ( \N$/stars/counter-xs-2|w185 )
);

capcom_dl0921_INV01 stars_counter_xs_2_UBR42 (
    .p1 ( \/counter-fi/~RESET       ),
    .p2 ( \N$/stars/counter-xs-2|w9 )
);

capcom_dl0921_XOR02 stars_counter_xs_2_UBU10 (
    .p1 ( \N$/stars/counter-xs-2|w145 ),
    .p2 ( \N$/stars/counter-xs-2|w144 ),
    .p3 ( \N$/stars/counter-xs-2|w47  )
);

capcom_dl0921_XNOR02 stars_counter_xs_2_UBU14 (
    .p1 ( \N$/stars/counter-xs-2|w148 ),
    .p2 ( \N$/stars/counter-xs-2|w169 ),
    .p3 ( \N$/stars/counter-xs-2|w49  )
);

capcom_dl0921_NOR04 stars_counter_xs_2_UBU17 (
    .p1 ( \N$/stars/counter-xs-2|w169 ),
    .p2 ( \N$/stars/counter-xs-2|w144 ),
    .p3 ( \N$/stars/counter-xs-2|w145 ),
    .p4 ( \N$/stars/counter-xs-2|w146 ),
    .p5 ( \N$/stars/counter-xs-2|w147 )
);

capcom_dl0921_INV01 stars_counter_xs_2_UBU23 (
    .p1 ( \N$/stars/counter-xs-2|UCC69.1 ),
    .p2 ( \N$/stars/counter-xs-2|w144    )
);

capcom_dl0921_NOR03 stars_counter_xs_2_UBU27 (
    .p1 ( \N$/stars/counter-xs-2|w144 ),
    .p2 ( \N$/stars/counter-xs-2|w145 ),
    .p3 ( \N$/stars/counter-xs-2|w146 ),
    .p4 ( \N$/stars/counter-xs-2|w167 )
);

capcom_dl0921_M258C stars_counter_xs_2_UBU31 (
    .p1  ( VCC                         ),
    .p2  ( VCC                         ),
    .p3  ( VCC                         ),
    .p4  ( \/stars/counter-xs-2/XS4    ),
    .p5  ( \N$/stars/counter-xs-2|w65  ),
    .p6  ( \N$/stars/counter-xs-2|w73  ),
    .p7  ( \N$/stars/counter-xs-2|w75  ),
    .p8  ( \N$/stars/counter-xs-2|w67  ),
    .p9  ( \N$/stars/counter-xs-2|w36  ),
    .p10 ( \N$/stars/counter-xs-2|w49  ),
    .p11 ( \N$/stars/counter-xs-2|w186 ),
    .p12 ( \N$/stars/counter-xs-2|w185 ),
    .p13 ( \N$/stars/counter-xs-2|w47  ),
    .p14 ( \N$/stars/counter-xs-2|w9   )
);

capcom_dl0921_XNOR02 stars_counter_xs_2_UBU48 (
    .p1 ( \N$/stars/counter-xs-2|w147 ),
    .p2 ( \N$/stars/counter-xs-2|w167 ),
    .p3 ( \N$/stars/counter-xs-2|w186 )
);

capcom_dl0921_INV01 stars_counter_xs_2_UBZ62 (
    .p1 ( \/counter-fi/~RESET       ),
    .p2 ( \N$/stars/counter-xs-2|w7 )
);

capcom_dl0921_M258C stars_counter_xs_2_UBZ66 (
    .p1  ( \/stars/counter-xs-2/XS3    ),
    .p2  ( \/stars/counter-xs-2/XS2    ),
    .p3  ( \/stars/counter-xs-2/XS1    ),
    .p4  ( \/stars/counter-xs-2/XS0    ),
    .p5  ( \N$/stars/counter-xs-2|w61  ),
    .p6  ( \N$/stars/counter-xs-2|w69  ),
    .p7  ( \N$/stars/counter-xs-2|w71  ),
    .p8  ( \N$/stars/counter-xs-2|w63  ),
    .p9  ( \N$/stars/counter-xs-2|w36  ),
    .p10 ( \N$/stars/counter-xs-2|w45  ),
    .p11 ( \N$/stars/counter-xs-2|w179 ),
    .p12 ( \N$/stars/counter-xs-2|w44  ),
    .p13 ( \N$/stars/counter-xs-2|w127 ),
    .p14 ( \N$/stars/counter-xs-2|w7   )
);

capcom_dl0921_INV01 stars_counter_xs_2_UBZ86 (
    .p1 ( \/stars/counter-xs-1/LOAD  ),
    .p2 ( \N$/stars/counter-xs-2|w36 )
);

capcom_dl0921_DFFCOO stars_counter_xs_2_UCC53 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w61     ),
    .p3 ( \N$/stars/counter-xs-2|w127    ),
    .p5 ( \N$/stars/counter-xs-2|UCC53.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_2_UCC57 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w69     ),
    .p3 ( \N$/stars/counter-xs-2|w141    ),
    .p5 ( \N$/stars/counter-xs-2|UCC57.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_2_UCC61 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w71     ),
    .p3 ( \N$/stars/counter-xs-2|w142    ),
    .p5 ( \N$/stars/counter-xs-2|UCC61.5 )
);

capcom_dl0921_DFFCOO stars_counter_xs_2_UCC65 (
    .p1 ( \N$/stars/counter4|w30         ),
    .p2 ( \N$/stars/counter-xs-2|w63     ),
    .p3 ( \N$/stars/counter-xs-2|w143    ),
    .p5 ( \N$/stars/counter-xs-2|UCC65.5 )
);

capcom_dl0921_NOR04 stars_counter_xs_2_UCC69 (
    .p1 ( \N$/stars/counter-xs-2|UCC69.1 ),
    .p2 ( \N$/stars/counter-xs-2|w127    ),
    .p3 ( \N$/stars/counter-xs-2|w141    ),
    .p4 ( \N$/stars/counter-xs-2|w142    ),
    .p5 ( \N$/stars/counter-xs-2|w143    )
);

capcom_dl0921_XNOR02 stars_counter_xs_2_UCC73 (
    .p1 ( \N$/stars/counter-xs-2|w143 ),
    .p2 ( \N$/stars/counter-xs-2|w161 ),
    .p3 ( \N$/stars/counter-xs-2|w45  )
);

capcom_dl0921_XNOR02 stars_counter_xs_2_UCC76 (
    .p1 ( \N$/stars/counter-xs-2|w142 ),
    .p2 ( \N$/stars/counter-xs-2|w159 ),
    .p3 ( \N$/stars/counter-xs-2|w179 )
);

capcom_dl0921_NOR03 stars_counter_xs_2_UCC79 (
    .p1 ( \N$/stars/counter-xs-2|w127 ),
    .p2 ( \N$/stars/counter-xs-2|w141 ),
    .p3 ( \N$/stars/counter-xs-2|w142 ),
    .p4 ( \N$/stars/counter-xs-2|w161 )
);

capcom_dl0921_NOR02 stars_counter_xs_2_UCC87 (
    .p1 ( \N$/stars/counter-xs-2|w141 ),
    .p2 ( \N$/stars/counter-xs-2|w127 ),
    .p3 ( \N$/stars/counter-xs-2|w159 )
);

capcom_dl0921_XOR02 stars_counter_xs_2_UCC89 (
    .p1 ( \N$/stars/counter-xs-2|w141 ),
    .p2 ( \N$/stars/counter-xs-2|w127 ),
    .p3 ( \N$/stars/counter-xs-2|w44  )
);

//========================================================================
// stars/counter4:
//========================================================================
capcom_dl0921_NBUF03 stars_counter4_UBR271 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \N$/stars/counter4|w30         )
);

capcom_dl0921_AND02 stars_counter4_UCC121 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \/counter-fi/FI                               ),
    .p3 ( \N$/stars/counter4|UCJ44.1                    )
);

capcom_dl0921_XNOR02 stars_counter4_UCG27 (
    .p1 ( \N$/stars/counter4|w60 ),
    .p2 ( \N$/stars/counter4|w74 ),
    .p3 ( \N$/stars/counter4|w87 )
);

capcom_dl0921_NOR02 stars_counter4_UCG31 (
    .p1 ( \N$/stars/counter4|w58 ),
    .p2 ( \N$/stars/counter4|w57 ),
    .p3 ( \N$/stars/counter4|w72 )
);

capcom_dl0921_NOR03 stars_counter4_UCG34 (
    .p1 ( \N$/stars/counter4|w57 ),
    .p2 ( \N$/stars/counter4|w58 ),
    .p3 ( \N$/stars/counter4|w59 ),
    .p4 ( \N$/stars/counter4|w74 )
);

capcom_dl0921_XNOR02 stars_counter4_UCG39 (
    .p1 ( \N$/stars/counter4|w59 ),
    .p2 ( \N$/stars/counter4|w72 ),
    .p3 ( \N$/stars/counter4|w85 )
);

capcom_dl0921_NOR04 stars_counter4_UCG42 (
    .p1 ( \N$/stars/counter4|w76 ),
    .p2 ( \N$/stars/counter4|w57 ),
    .p3 ( \N$/stars/counter4|w58 ),
    .p4 ( \N$/stars/counter4|w59 ),
    .p5 ( \N$/stars/counter4|w60 )
);

capcom_dl0921_XNOR02 stars_counter4_UCG51 (
    .p1 ( \N$/stars/counter4|w61 ),
    .p2 ( \N$/stars/counter4|w76 ),
    .p3 ( \N$/stars/counter4|w89 )
);

capcom_dl0921_NAND02 stars_counter4_UCG54 (
    .p1 ( \/counter-fi/~RESET    ),
    .p2 ( \N$/stars/counter4|w89 ),
    .p3 ( \N$/stars/counter4|w22 )
);

capcom_dl0921_NAND02 stars_counter4_UCG56 (
    .p1 ( \/counter-fi/~RESET    ),
    .p2 ( \N$/stars/counter4|w87 ),
    .p3 ( \N$/stars/counter4|w21 )
);

capcom_dl0921_NAND02 stars_counter4_UCG57 (
    .p1 ( \/counter-fi/~RESET    ),
    .p2 ( \N$/stars/counter4|w85 ),
    .p3 ( \N$/stars/counter4|w20 )
);

capcom_dl0921_NAND02 stars_counter4_UCG59 (
    .p1 ( \/counter-fi/~RESET    ),
    .p2 ( \N$/stars/counter4|w82 ),
    .p3 ( \N$/stars/counter4|w19 )
);

capcom_dl0921_NOR05 stars_counter4_UCG60 (
    .p1 ( \/stars/row5-counter/INC ),
    .p2 ( \N$/stars/counter4|w57   ),
    .p3 ( \N$/stars/counter4|w58   ),
    .p4 ( \N$/stars/counter4|w60   ),
    .p5 ( \N$/stars/counter4|w59   ),
    .p6 ( \N$/stars/counter4|w61   )
);

capcom_dl0921_XOR02 stars_counter4_UCG64 (
    .p1 ( \N$/stars/counter4|w58 ),
    .p2 ( \N$/stars/counter4|w57 ),
    .p3 ( \N$/stars/counter4|w82 )
);

capcom_dl0921_DFFCOO stars_counter4_UCG69 (
    .p1 ( \N$/stars/counter4|w30     ),
    .p2 ( \N$/stars/counter4|w19     ),
    .p3 ( \N$/stars/counter4|w58     ),
    .p5 ( \N$/stars/counter4|UCG69.5 )
);

capcom_dl0921_DFFCOO stars_counter4_UCG73 (
    .p1 ( \N$/stars/counter4|w30     ),
    .p2 ( \N$/stars/counter4|w20     ),
    .p3 ( \N$/stars/counter4|w59     ),
    .p5 ( \N$/stars/counter4|UCG73.5 )
);

capcom_dl0921_DFFCOO stars_counter4_UCG76 (
    .p1 ( \N$/stars/counter4|w30     ),
    .p2 ( \N$/stars/counter4|w21     ),
    .p3 ( \N$/stars/counter4|w60     ),
    .p5 ( \N$/stars/counter4|UCG76.5 )
);

capcom_dl0921_DFFCOO stars_counter4_UCG80 (
    .p1 ( \N$/stars/counter4|w30     ),
    .p2 ( \N$/stars/counter4|w22     ),
    .p3 ( \N$/stars/counter4|w61     ),
    .p5 ( \N$/stars/counter4|UCG80.5 )
);

capcom_dl0921_INV01 stars_counter4_UCJ44 (
    .p1 ( \N$/stars/counter4|UCJ44.1 ),
    .p2 ( \N$/stars/counter4|w57     )
);

//========================================================================
// stars/row5-assemble:
//========================================================================
capcom_dl0921_OR02 stars_row5_assemble_UBF13 (
    .p1 ( \/stars/row5-assemble/~ENABLE                ),
    .p2 ( \N$/stars/row5-assemble|w31                  ),
    .p3 ( \/lut-assembly/priority-transparency/~ROW5-E )
);

capcom_dl0921_MUX24H stars_row5_assemble_UBH243 (
    .p1  ( \/stars/row5-assemble/CNT0-Q3      ),
    .p2  ( \/stars/row5-assemble/CNT0-Q2      ),
    .p3  ( \/stars/row5-assemble/CNT0-Q1      ),
    .p4  ( \/stars/row5-assemble/CNT0-Q0      ),
    .p5  ( \/lut-assembly/lut-storage/ROW5-D0 ),
    .p6  ( \/lut-assembly/lut-storage/ROW5-D1 ),
    .p7  ( \/lut-assembly/lut-storage/ROW5-D2 ),
    .p8  ( \/lut-assembly/lut-storage/ROW5-D3 ),
    .p9  ( \/lut-assembly/lut-storage/ROW5-D6 ),
    .p10 ( \/stars/row5-assemble/CNT1-Q3      ),
    .p11 ( \/stars/row5-assemble/CNT1-Q2      ),
    .p12 ( \/stars/row5-assemble/CNT1-Q1      ),
    .p13 ( \/stars/row5-assemble/CNT1-Q0      )
);

capcom_dl0921_M541C stars_row5_assemble_UBK219 (
    .p1  ( \/stars/row5-assemble/~DEBUG       ),
    .p2  ( \/lut-assembly/lut-storage/ROW5-D0 ),
    .p3  ( \/lut-assembly/lut-storage/ROW5-D1 ),
    .p4  ( \/lut-assembly/lut-storage/ROW5-D2 ),
    .p5  ( \/lut-assembly/lut-storage/ROW5-D3 ),
    .p6  ( \/lut-assembly/lut-storage/ROW5-D4 ),
    .p7  ( \/lut-assembly/lut-storage/ROW5-D5 ),
    .p8  ( \/lut-assembly/lut-storage/ROW5-D6 ),
    .p9  ( \N$/stars/row5-assemble|w31        ),
    .p11 ( \/debug/td-io/IN7                  ),
    .p12 ( \/debug/td-io/IN6                  ),
    .p13 ( \/debug/td-io/IN5                  ),
    .p14 ( \/debug/td-io/IN4                  ),
    .p15 ( \/debug/td-io/IN3                  ),
    .p16 ( \/debug/td-io/IN2                  ),
    .p17 ( \/debug/td-io/IN1                  ),
    .p18 ( \/debug/td-io/IN0                  )
);

capcom_dl0921_M367C stars_row5_assemble_UBK331 (
    .p1  ( \/stars/row5-assemble/~DEBUG ),
    .p2  ( GND                          ),
    .p3  ( GND                          ),
    .p4  ( GND                          ),
    .p5  ( GND                          ),
    .p15 ( \/debug/td-io/IN11           ),
    .p16 ( \/debug/td-io/IN10           ),
    .p17 ( \/debug/td-io/IN9            ),
    .p18 ( \/debug/td-io/IN8            )
);

capcom_dl0921_NAND02 stars_row5_assemble_UBN193 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/stars/xpd5-sync/LOAD         ),
    .p3 ( \N$/stars/row5-assemble|w6     )
);

capcom_dl0921_DFFCOO stars_row5_assemble_UBR118 (
    .p1 ( \N$/stars/row5-assemble|w6         ),
    .p2 ( \/stars/row5-assemble/PD5          ),
    .p3 ( \/lut-assembly/lut-storage/ROW5-D4 ),
    .p5 ( \N$/stars/row5-assemble|UBR118.5   )
);

capcom_dl0921_DFFCOO stars_row5_assemble_UBR122 (
    .p1 ( \N$/stars/row5-assemble|w6         ),
    .p2 ( \/stars/row5-assemble/PD6          ),
    .p3 ( \/lut-assembly/lut-storage/ROW5-D5 ),
    .p5 ( \N$/stars/row5-assemble|UBR122.5   )
);

capcom_dl0921_DFFCOO stars_row5_assemble_UBR126 (
    .p1 ( \N$/stars/row5-assemble|w6         ),
    .p2 ( \/stars/row5-assemble/PD7          ),
    .p3 ( \/lut-assembly/lut-storage/ROW5-D6 ),
    .p5 ( \N$/stars/row5-assemble|UBR126.5   )
);

capcom_dl0921_DFFCOO stars_row5_assemble_UBR130 (
    .p1 ( \N$/stars/row5-assemble|w6       ),
    .p2 ( \/stars/row5-assemble/PD8        ),
    .p3 ( \N$/stars/row5-assemble|w15      ),
    .p5 ( \N$/stars/row5-assemble|UBR130.5 )
);

capcom_dl0921_NAND02 stars_row5_assemble_UBR141 (
    .p1 ( \/stars/xpd5-sync/ZERO      ),
    .p2 ( \N$/stars/row5-assemble|w15 ),
    .p3 ( \N$/stars/row5-assemble|w31 )
);

//========================================================================
// stars/row5-counter:
//========================================================================
capcom_dl0921_DFFCOO stars_row5_counter_UBD255 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w46      ),
    .p3 ( \N$/stars/row5-counter|UBD255.3 ),
    .p5 ( \/stars/row5-assemble/CNT1-Q0   )
);

capcom_dl0921_DFFCOO stars_row5_counter_UBD259 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w47      ),
    .p3 ( \N$/stars/row5-counter|UBD259.3 ),
    .p5 ( \/stars/row5-assemble/CNT1-Q1   )
);

capcom_dl0921_DFFCOO stars_row5_counter_UBD263 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w48      ),
    .p3 ( \N$/stars/row5-counter|UBD263.3 ),
    .p5 ( \/stars/row5-assemble/CNT1-Q2   )
);

capcom_dl0921_DFFCOO stars_row5_counter_UBD267 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w49      ),
    .p3 ( \N$/stars/row5-counter|UBD267.3 ),
    .p5 ( \/stars/row5-assemble/CNT1-Q3   )
);

capcom_dl0921_XNOR02 stars_row5_counter_UBD274 (
    .p1 ( \/stars/row5-assemble/CNT1-Q3 ),
    .p2 ( \N$/stars/row5-counter|w164   ),
    .p3 ( \N$/stars/row5-counter|w181   )
);

capcom_dl0921_NAND02 stars_row5_counter_UBD277 (
    .p1 ( \N$/stars/row5-counter|w33 ),
    .p2 ( \N$/stars/row5-counter|w38 ),
    .p3 ( \N$/stars/row5-counter|w46 )
);

capcom_dl0921_NAND02 stars_row5_counter_UBD279 (
    .p1 ( \N$/stars/row5-counter|w33  ),
    .p2 ( \N$/stars/row5-counter|w177 ),
    .p3 ( \N$/stars/row5-counter|w47  )
);

capcom_dl0921_NAND02 stars_row5_counter_UBD280 (
    .p1 ( \N$/stars/row5-counter|w33 ),
    .p2 ( \N$/stars/row5-counter|w11 ),
    .p3 ( \N$/stars/row5-counter|w48 )
);

capcom_dl0921_NAND02 stars_row5_counter_UBD282 (
    .p1 ( \N$/stars/row5-counter|w33  ),
    .p2 ( \N$/stars/row5-counter|w181 ),
    .p3 ( \N$/stars/row5-counter|w49  )
);

capcom_dl0921_NAND04 stars_row5_counter_UBD291 (
    .p1 ( \/stars/row5-assemble/CNT1-Q2 ),
    .p2 ( \/stars/row5-assemble/CNT1-Q1 ),
    .p3 ( \/stars/row5-assemble/CNT1-Q0 ),
    .p4 ( \N$/stars/row5-counter|w142   ),
    .p5 ( \N$/stars/row5-counter|w164   )
);

capcom_dl0921_XNOR02 stars_row5_counter_UBD294 (
    .p1 ( \/stars/row5-assemble/CNT1-Q2 ),
    .p2 ( \N$/stars/row5-counter|w162   ),
    .p3 ( \N$/stars/row5-counter|w11    )
);

capcom_dl0921_NAND04 stars_row5_counter_UBD296 (
    .p1 ( \/stars/row5-counter/IC       ),
    .p2 ( \/stars/row5-assemble/CNT1-Q1 ),
    .p3 ( \/stars/row5-assemble/CNT1-Q2 ),
    .p4 ( \/stars/row5-assemble/CNT1-Q3 ),
    .p5 ( \N$/stars/row5-counter|w69    )
);

capcom_dl0921_XNOR02 stars_row5_counter_UBD299 (
    .p1 ( \/stars/row5-assemble/CNT1-Q1 ),
    .p2 ( \N$/stars/row5-counter|w160   ),
    .p3 ( \N$/stars/row5-counter|w177   )
);

capcom_dl0921_AND02 stars_row5_counter_UBD302 (
    .p1 ( \N$/stars/row5-counter|w69 ),
    .p2 ( \/counter-fi/~RESET        ),
    .p3 ( \N$/stars/row5-counter|w33 )
);

capcom_dl0921_NAND03 stars_row5_counter_UBD304 (
    .p1 ( \/stars/row5-assemble/CNT1-Q1 ),
    .p2 ( \/stars/row5-assemble/CNT1-Q0 ),
    .p3 ( \N$/stars/row5-counter|w142   ),
    .p4 ( \N$/stars/row5-counter|w162   )
);

capcom_dl0921_NAND02 stars_row5_counter_UBD306 (
    .p1 ( \/stars/row5-assemble/CNT1-Q0 ),
    .p2 ( \N$/stars/row5-counter|w142   ),
    .p3 ( \N$/stars/row5-counter|w160   )
);

capcom_dl0921_BUF01 stars_row5_counter_UBD308 (
    .p1 ( \/stars/row5-counter/IC     ),
    .p2 ( \N$/stars/row5-counter|w142 )
);

capcom_dl0921_XOR02 stars_row5_counter_UBD310 (
    .p1 ( \/stars/row5-assemble/CNT1-Q0 ),
    .p2 ( \N$/stars/row5-counter|w142   ),
    .p3 ( \N$/stars/row5-counter|w38    )
);

capcom_dl0921_DFFCOO stars_row5_counter_UBH259 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w42      ),
    .p3 ( \N$/stars/row5-counter|UBH259.3 ),
    .p5 ( \/stars/row5-assemble/CNT0-Q0   )
);

capcom_dl0921_DFFCOO stars_row5_counter_UBH263 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w43      ),
    .p3 ( \N$/stars/row5-counter|UBH263.3 ),
    .p5 ( \/stars/row5-assemble/CNT0-Q1   )
);

capcom_dl0921_DFFCOO stars_row5_counter_UBH267 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w44      ),
    .p3 ( \N$/stars/row5-counter|UBH267.3 ),
    .p5 ( \/stars/row5-assemble/CNT0-Q2   )
);

capcom_dl0921_DFFCOO stars_row5_counter_UBH271 (
    .p1 ( \N$/stars/counter4|w30          ),
    .p2 ( \N$/stars/row5-counter|w45      ),
    .p3 ( \N$/stars/row5-counter|UBH271.3 ),
    .p5 ( \/stars/row5-assemble/CNT0-Q3   )
);

capcom_dl0921_NAND02 stars_row5_counter_UBH275 (
    .p1 ( \/counter-fi/~RESET        ),
    .p2 ( \N$/stars/row5-counter|w34 ),
    .p3 ( \N$/stars/row5-counter|w42 )
);

capcom_dl0921_NAND02 stars_row5_counter_UBH277 (
    .p1 ( \/counter-fi/~RESET         ),
    .p2 ( \N$/stars/row5-counter|w175 ),
    .p3 ( \N$/stars/row5-counter|w43  )
);

capcom_dl0921_NAND02 stars_row5_counter_UBH278 (
    .p1 ( \/counter-fi/~RESET        ),
    .p2 ( \N$/stars/row5-counter|w8  ),
    .p3 ( \N$/stars/row5-counter|w44 )
);

capcom_dl0921_NAND02 stars_row5_counter_UBH280 (
    .p1 ( \/counter-fi/~RESET         ),
    .p2 ( \N$/stars/row5-counter|w180 ),
    .p3 ( \N$/stars/row5-counter|w45  )
);

capcom_dl0921_XOR02 stars_row5_counter_UBH282 (
    .p1 ( \/stars/row5-assemble/CNT0-Q0 ),
    .p2 ( \N$/stars/row5-counter|w138   ),
    .p3 ( \N$/stars/row5-counter|w34    )
);

capcom_dl0921_XNOR02 stars_row5_counter_UBH291 (
    .p1 ( \/stars/row5-assemble/CNT0-Q3 ),
    .p2 ( \N$/stars/row5-counter|w156   ),
    .p3 ( \N$/stars/row5-counter|w180   )
);

capcom_dl0921_NAND04 stars_row5_counter_UBH294 (
    .p1 ( \/stars/row5-assemble/CNT0-Q2 ),
    .p2 ( \/stars/row5-assemble/CNT0-Q1 ),
    .p3 ( \/stars/row5-assemble/CNT0-Q0 ),
    .p4 ( \N$/stars/row5-counter|w138   ),
    .p5 ( \N$/stars/row5-counter|w156   )
);

capcom_dl0921_XNOR02 stars_row5_counter_UBH297 (
    .p1 ( \/stars/row5-assemble/CNT0-Q2 ),
    .p2 ( \N$/stars/row5-counter|w154   ),
    .p3 ( \N$/stars/row5-counter|w8     )
);

capcom_dl0921_XNOR02 stars_row5_counter_UBH299 (
    .p1 ( \/stars/row5-assemble/CNT0-Q1 ),
    .p2 ( \N$/stars/row5-counter|w152   ),
    .p3 ( \N$/stars/row5-counter|w175   )
);

capcom_dl0921_NAND03 stars_row5_counter_UBH302 (
    .p1 ( \/stars/row5-assemble/CNT0-Q1 ),
    .p2 ( \/stars/row5-assemble/CNT0-Q0 ),
    .p3 ( \N$/stars/row5-counter|w138   ),
    .p4 ( \N$/stars/row5-counter|w154   )
);

capcom_dl0921_NAND02 stars_row5_counter_UBH304 (
    .p1 ( \/stars/row5-assemble/CNT0-Q0 ),
    .p2 ( \N$/stars/row5-counter|w138   ),
    .p3 ( \N$/stars/row5-counter|w152   )
);

capcom_dl0921_BUF01 stars_row5_counter_UBH306 (
    .p1 ( \/stars/row5-counter/IC     ),
    .p2 ( \N$/stars/row5-counter|w138 )
);

capcom_dl0921_OR02 stars_row5_counter_UBK295 (
    .p1 ( \/stars/row5-counter/INC        ),
    .p2 ( \N$/stars/row5-counter|UBK311.2 ),
    .p3 ( \/stars/row5-counter/IC         )
);

capcom_dl0921_INV01 stars_row5_counter_UBK311 (
    .p1 ( \/stars/row5-counter/~DEBUG     ),
    .p2 ( \N$/stars/row5-counter|UBK311.2 )
);

//========================================================================
// stars/row6-assemble:
//========================================================================
capcom_dl0921_M541C stars_row6_assemble_UBD192 (
    .p1  ( \/stars/row6-assemble/~DEBUG       ),
    .p2  ( \/lut-assembly/lut-storage/ROW6-D0 ),
    .p3  ( \/lut-assembly/lut-storage/ROW6-D1 ),
    .p4  ( \/lut-assembly/lut-storage/ROW6-D2 ),
    .p5  ( \/lut-assembly/lut-storage/ROW6-D3 ),
    .p6  ( \/lut-assembly/lut-storage/ROW6-D4 ),
    .p7  ( \/lut-assembly/lut-storage/ROW6-D5 ),
    .p8  ( \/lut-assembly/lut-storage/ROW6-D6 ),
    .p9  ( \N$/stars/row6-assemble|w30        ),
    .p11 ( \/debug/td-io/IN7                  ),
    .p12 ( \/debug/td-io/IN6                  ),
    .p13 ( \/debug/td-io/IN5                  ),
    .p14 ( \/debug/td-io/IN4                  ),
    .p15 ( \/debug/td-io/IN3                  ),
    .p16 ( \/debug/td-io/IN2                  ),
    .p17 ( \/debug/td-io/IN1                  ),
    .p18 ( \/debug/td-io/IN0                  )
);

capcom_dl0921_OR02 stars_row6_assemble_UBF17 (
    .p1 ( \/stars/row6-assemble/~ENABLE                ),
    .p2 ( \N$/stars/row6-assemble|w30                  ),
    .p3 ( \/lut-assembly/priority-transparency/~ROW6-E )
);

capcom_dl0921_DFFCOO stars_row6_assemble_UBH196 (
    .p1 ( \N$/stars/row6-assemble|w6         ),
    .p2 ( \/stars/row6-assemble/PD5          ),
    .p3 ( \/lut-assembly/lut-storage/ROW6-D4 ),
    .p5 ( \N$/stars/row6-assemble|UBH196.5   )
);

capcom_dl0921_DFFCOO stars_row6_assemble_UBH200 (
    .p1 ( \N$/stars/row6-assemble|w6         ),
    .p2 ( \/stars/row6-assemble/PD6          ),
    .p3 ( \/lut-assembly/lut-storage/ROW6-D5 ),
    .p5 ( \N$/stars/row6-assemble|UBH200.5   )
);

capcom_dl0921_DFFCOO stars_row6_assemble_UBH204 (
    .p1 ( \N$/stars/row6-assemble|w6         ),
    .p2 ( \/stars/row6-assemble/PD7          ),
    .p3 ( \/lut-assembly/lut-storage/ROW6-D6 ),
    .p5 ( \N$/stars/row6-assemble|UBH204.5   )
);

capcom_dl0921_DFFCOO stars_row6_assemble_UBH208 (
    .p1 ( \N$/stars/row6-assemble|w6       ),
    .p2 ( \/stars/row6-assemble/PD8        ),
    .p3 ( \N$/stars/row6-assemble|w15      ),
    .p5 ( \N$/stars/row6-assemble|UBH208.5 )
);

capcom_dl0921_M367C stars_row6_assemble_UBH308 (
    .p1  ( \/stars/row6-assemble/~DEBUG ),
    .p2  ( GND                          ),
    .p3  ( GND                          ),
    .p4  ( GND                          ),
    .p5  ( GND                          ),
    .p15 ( \/debug/td-io/IN11           ),
    .p16 ( \/debug/td-io/IN10           ),
    .p17 ( \/debug/td-io/IN9            ),
    .p18 ( \/debug/td-io/IN8            )
);

capcom_dl0921_MUX24H stars_row6_assemble_UBK195 (
    .p1  ( \/stars/row6-assemble/CNT0-Q3      ),
    .p2  ( \/stars/row6-assemble/CNT0-Q2      ),
    .p3  ( \/stars/row6-assemble/CNT0-Q1      ),
    .p4  ( \/stars/row6-assemble/CNT0-Q0      ),
    .p5  ( \/lut-assembly/lut-storage/ROW6-D0 ),
    .p6  ( \/lut-assembly/lut-storage/ROW6-D1 ),
    .p7  ( \/lut-assembly/lut-storage/ROW6-D2 ),
    .p8  ( \/lut-assembly/lut-storage/ROW6-D3 ),
    .p9  ( \/lut-assembly/lut-storage/ROW6-D6 ),
    .p10 ( \/stars/row6-assemble/CNT1-Q3      ),
    .p11 ( \/stars/row6-assemble/CNT1-Q2      ),
    .p12 ( \/stars/row6-assemble/CNT1-Q1      ),
    .p13 ( \/stars/row6-assemble/CNT1-Q0      )
);

capcom_dl0921_NAND02 stars_row6_assemble_UBK210 (
    .p1 ( \/stars/xpd6-sync/ZERO      ),
    .p2 ( \N$/stars/row6-assemble|w15 ),
    .p3 ( \N$/stars/row6-assemble|w30 )
);

capcom_dl0921_NAND02 stars_row6_assemble_UBU185 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/stars/xpd6-sync/LOAD         ),
    .p3 ( \N$/stars/row6-assemble|w6     )
);

//========================================================================
// stars/row6-counter:
//========================================================================
capcom_dl0921_NAND02 stars_row6_counter_UBD272 (
    .p1 ( \/stars/row6-assemble/CNT0-Q0 ),
    .p2 ( \N$/stars/row6-counter|w138   ),
    .p3 ( \N$/stars/row6-counter|w152   )
);

capcom_dl0921_BUF01 stars_row6_counter_UBK238 (
    .p1 ( \/stars/row6-counter/IC     ),
    .p2 ( \N$/stars/row6-counter|w138 )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBK242 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w42      ),
    .p3 ( \N$/stars/row6-counter|UBK242.3 ),
    .p5 ( \/stars/row6-assemble/CNT0-Q0   )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBK245 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w43      ),
    .p3 ( \N$/stars/row6-counter|UBK245.3 ),
    .p5 ( \/stars/row6-assemble/CNT0-Q1   )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBK249 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w44      ),
    .p3 ( \N$/stars/row6-counter|UBK249.3 ),
    .p5 ( \/stars/row6-assemble/CNT0-Q2   )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBK253 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w45      ),
    .p3 ( \N$/stars/row6-counter|UBK253.3 ),
    .p5 ( \/stars/row6-assemble/CNT0-Q3   )
);

capcom_dl0921_XNOR02 stars_row6_counter_UBK257 (
    .p1 ( \/stars/row6-assemble/CNT0-Q3 ),
    .p2 ( \N$/stars/row6-counter|w156   ),
    .p3 ( \N$/stars/row6-counter|w180   )
);

capcom_dl0921_NAND04 stars_row6_counter_UBK260 (
    .p1 ( \/stars/row6-assemble/CNT0-Q2 ),
    .p2 ( \/stars/row6-assemble/CNT0-Q1 ),
    .p3 ( \/stars/row6-assemble/CNT0-Q0 ),
    .p4 ( \N$/stars/row6-counter|w138   ),
    .p5 ( \N$/stars/row6-counter|w156   )
);

capcom_dl0921_NAND03 stars_row6_counter_UBK263 (
    .p1 ( \/stars/row6-assemble/CNT0-Q1 ),
    .p2 ( \/stars/row6-assemble/CNT0-Q0 ),
    .p3 ( \N$/stars/row6-counter|w138   ),
    .p4 ( \N$/stars/row6-counter|w154   )
);

capcom_dl0921_XNOR02 stars_row6_counter_UBK265 (
    .p1 ( \/stars/row6-assemble/CNT0-Q2 ),
    .p2 ( \N$/stars/row6-counter|w154   ),
    .p3 ( \N$/stars/row6-counter|w8     )
);

capcom_dl0921_XNOR02 stars_row6_counter_UBK268 (
    .p1 ( \/stars/row6-assemble/CNT0-Q1 ),
    .p2 ( \N$/stars/row6-counter|w152   ),
    .p3 ( \N$/stars/row6-counter|w175   )
);

capcom_dl0921_NAND02 stars_row6_counter_UBK270 (
    .p1 ( \/counter-fi/~RESET        ),
    .p2 ( \N$/stars/row6-counter|w34 ),
    .p3 ( \N$/stars/row6-counter|w42 )
);

capcom_dl0921_NAND02 stars_row6_counter_UBK272 (
    .p1 ( \/counter-fi/~RESET         ),
    .p2 ( \N$/stars/row6-counter|w175 ),
    .p3 ( \N$/stars/row6-counter|w43  )
);

capcom_dl0921_NAND02 stars_row6_counter_UBK274 (
    .p1 ( \/counter-fi/~RESET        ),
    .p2 ( \N$/stars/row6-counter|w8  ),
    .p3 ( \N$/stars/row6-counter|w44 )
);

capcom_dl0921_NAND02 stars_row6_counter_UBK275 (
    .p1 ( \/counter-fi/~RESET         ),
    .p2 ( \N$/stars/row6-counter|w180 ),
    .p3 ( \N$/stars/row6-counter|w45  )
);

capcom_dl0921_XOR02 stars_row6_counter_UBK277 (
    .p1 ( \/stars/row6-assemble/CNT0-Q0 ),
    .p2 ( \N$/stars/row6-counter|w138   ),
    .p3 ( \N$/stars/row6-counter|w34    )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBN196 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w46      ),
    .p3 ( \N$/stars/row6-counter|UBN196.3 ),
    .p5 ( \/stars/row6-assemble/CNT1-Q0   )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBN200 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w47      ),
    .p3 ( \N$/stars/row6-counter|UBN200.3 ),
    .p5 ( \/stars/row6-assemble/CNT1-Q1   )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBN204 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w48      ),
    .p3 ( \N$/stars/row6-counter|UBN204.3 ),
    .p5 ( \/stars/row6-assemble/CNT1-Q2   )
);

capcom_dl0921_DFFCOO stars_row6_counter_UBN208 (
    .p1 ( \/stars/counter-xs-1/~CLK8M     ),
    .p2 ( \N$/stars/row6-counter|w49      ),
    .p3 ( \N$/stars/row6-counter|UBN208.3 ),
    .p5 ( \/stars/row6-assemble/CNT1-Q3   )
);

capcom_dl0921_AND02 stars_row6_counter_UBN217 (
    .p1 ( \N$/stars/row6-counter|w69 ),
    .p2 ( \/counter-fi/~RESET        ),
    .p3 ( \N$/stars/row6-counter|w33 )
);

capcom_dl0921_BUF01 stars_row6_counter_UBN219 (
    .p1 ( \/stars/row6-counter/IC     ),
    .p2 ( \N$/stars/row6-counter|w142 )
);

capcom_dl0921_NAND04 stars_row6_counter_UBN221 (
    .p1 ( \/stars/row6-counter/IC       ),
    .p2 ( \/stars/row6-assemble/CNT1-Q1 ),
    .p3 ( \/stars/row6-assemble/CNT1-Q2 ),
    .p4 ( \/stars/row6-assemble/CNT1-Q3 ),
    .p5 ( \N$/stars/row6-counter|w69    )
);

capcom_dl0921_OR02 stars_row6_counter_UBN261 (
    .p1 ( \/stars/row5-counter/INC        ),
    .p2 ( \N$/stars/row6-counter|UBN405.2 ),
    .p3 ( \/stars/row6-counter/IC         )
);

capcom_dl0921_INV01 stars_row6_counter_UBN405 (
    .p1 ( \/stars/row6-counter/~DEBUG     ),
    .p2 ( \N$/stars/row6-counter|UBN405.2 )
);

capcom_dl0921_NAND04 stars_row6_counter_UBU20 (
    .p1 ( \/stars/row6-assemble/CNT1-Q2 ),
    .p2 ( \/stars/row6-assemble/CNT1-Q1 ),
    .p3 ( \/stars/row6-assemble/CNT1-Q0 ),
    .p4 ( \N$/stars/row6-counter|w142   ),
    .p5 ( \N$/stars/row6-counter|w164   )
);

capcom_dl0921_NAND02 stars_row6_counter_UBW31 (
    .p1 ( \/stars/row6-assemble/CNT1-Q0 ),
    .p2 ( \N$/stars/row6-counter|w142   ),
    .p3 ( \N$/stars/row6-counter|w160   )
);

capcom_dl0921_XNOR02 stars_row6_counter_UBW32 (
    .p1 ( \/stars/row6-assemble/CNT1-Q1 ),
    .p2 ( \N$/stars/row6-counter|w160   ),
    .p3 ( \N$/stars/row6-counter|w177   )
);

capcom_dl0921_XNOR02 stars_row6_counter_UBW41 (
    .p1 ( \/stars/row6-assemble/CNT1-Q2 ),
    .p2 ( \N$/stars/row6-counter|w162   ),
    .p3 ( \N$/stars/row6-counter|w11    )
);

capcom_dl0921_NAND03 stars_row6_counter_UBW43 (
    .p1 ( \/stars/row6-assemble/CNT1-Q1 ),
    .p2 ( \/stars/row6-assemble/CNT1-Q0 ),
    .p3 ( \N$/stars/row6-counter|w142   ),
    .p4 ( \N$/stars/row6-counter|w162   )
);

capcom_dl0921_XOR02 stars_row6_counter_UBW63 (
    .p1 ( \/stars/row6-assemble/CNT1-Q0 ),
    .p2 ( \N$/stars/row6-counter|w142   ),
    .p3 ( \N$/stars/row6-counter|w38    )
);

capcom_dl0921_XNOR02 stars_row6_counter_UBW88 (
    .p1 ( \/stars/row6-assemble/CNT1-Q3 ),
    .p2 ( \N$/stars/row6-counter|w164   ),
    .p3 ( \N$/stars/row6-counter|w181   )
);

capcom_dl0921_NAND02 stars_row6_counter_UBW94 (
    .p1 ( \N$/stars/row6-counter|w33 ),
    .p2 ( \N$/stars/row6-counter|w38 ),
    .p3 ( \N$/stars/row6-counter|w46 )
);

capcom_dl0921_NAND02 stars_row6_counter_UBW96 (
    .p1 ( \N$/stars/row6-counter|w33  ),
    .p2 ( \N$/stars/row6-counter|w177 ),
    .p3 ( \N$/stars/row6-counter|w47  )
);

capcom_dl0921_NAND02 stars_row6_counter_UBW98 (
    .p1 ( \N$/stars/row6-counter|w33 ),
    .p2 ( \N$/stars/row6-counter|w11 ),
    .p3 ( \N$/stars/row6-counter|w48 )
);

capcom_dl0921_NAND02 stars_row6_counter_UBW99 (
    .p1 ( \N$/stars/row6-counter|w33  ),
    .p2 ( \N$/stars/row6-counter|w181 ),
    .p3 ( \N$/stars/row6-counter|w49  )
);

//========================================================================
// stars/xpd-bus5-sync:
//========================================================================
capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBU141 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12      ),
    .p2 ( \/stars/xpd-bus5/PD5             ),
    .p3 ( \/stars/row5-assemble/PD5        ),
    .p5 ( \N$/stars/xpd-bus5-sync|UBU141.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBU145 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12      ),
    .p2 ( \/stars/xpd-bus5/PD6             ),
    .p3 ( \/stars/row5-assemble/PD6        ),
    .p5 ( \N$/stars/xpd-bus5-sync|UBU145.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBU148 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12      ),
    .p2 ( \/stars/xpd-bus5/PD7             ),
    .p3 ( \/stars/row5-assemble/PD7        ),
    .p5 ( \N$/stars/xpd-bus5-sync|UBU148.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBU152 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12      ),
    .p2 ( \/stars/xpd-bus5/PD8             ),
    .p3 ( \/stars/row5-assemble/PD8        ),
    .p5 ( \N$/stars/xpd-bus5-sync|UBU152.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBW69 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12     ),
    .p2 ( \/stars/xpd-bus5/PD0            ),
    .p3 ( \N$/stars/xpd-bus5-sync|UBW69.3 ),
    .p5 ( \/stars/xpd5-sync/~PD0          )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBW73 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12     ),
    .p2 ( \/stars/xpd-bus5/PD1            ),
    .p3 ( \N$/stars/xpd-bus5-sync|UBW73.3 ),
    .p5 ( \/stars/xpd5-sync/~PD1          )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBW76 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12     ),
    .p2 ( \/stars/xpd-bus5/PD2            ),
    .p3 ( \N$/stars/xpd-bus5-sync|UBW76.3 ),
    .p5 ( \/stars/xpd5-sync/~PD2          )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBW80 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12     ),
    .p2 ( \/stars/xpd-bus5/PD3            ),
    .p3 ( \N$/stars/xpd-bus5-sync|UBW80.3 ),
    .p5 ( \/stars/xpd5-sync/~PD3          )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_sync_UBW84 (
    .p1 ( \N$/stars/xpd-bus5-sync|w12     ),
    .p2 ( \/stars/xpd-bus5/PD4            ),
    .p3 ( \N$/stars/xpd-bus5-sync|UBW84.3 ),
    .p5 ( \/stars/xpd5-sync/~PD4          )
);

capcom_dl0921_NAND02 stars_xpd_bus5_sync_UBW93 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/stars/counter-xs-1/LOAD      ),
    .p3 ( \N$/stars/xpd-bus5-sync|w12    )
);

//========================================================================
// stars/xpd-bus5:
//========================================================================
capcom_dl0921_M273C stars_xpd_bus5_UBN226 (
    .p1  ( VCC                    ),
    .p2  ( \N$/stars/xpd-bus5|w78 ),
    .p3  ( \/APD0                 ),
    .p4  ( \/APD1                 ),
    .p5  ( \N$/stars/xpd-bus5|w54 ),
    .p6  ( \N$/stars/xpd-bus5|w77 ),
    .p7  ( \/APD2                 ),
    .p8  ( \/APD3                 ),
    .p9  ( \N$/stars/xpd-bus5|w61 ),
    .p11 ( \N$/stars/xpd-bus5|w37 ),
    .p12 ( \N$/stars/xpd-bus5|w48 ),
    .p13 ( \/APD4                 ),
    .p14 ( \/APD5                 ),
    .p15 ( \/stars/xpd-bus5/PD5   ),
    .p16 ( \/stars/xpd-bus5/PD6   ),
    .p17 ( \/APD6                 ),
    .p18 ( \/APD7                 ),
    .p19 ( \/stars/xpd-bus5/PD7   )
);

capcom_dl0921_NAND02 stars_xpd_bus5_UBN282 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/stars/xpd-bus5/LOAD          ),
    .p3 ( \N$/stars/xpd-bus5|w37         )
);

capcom_dl0921_NAND05 stars_xpd_bus5_UBR134 (
    .p1 ( \N$/stars/xpd-bus5|w61 ),
    .p2 ( \N$/stars/xpd-bus5|w77 ),
    .p3 ( \N$/stars/xpd-bus5|w54 ),
    .p4 ( \N$/stars/xpd-bus5|w78 ),
    .p5 ( \N$/stars/xpd-bus5|w55 ),
    .p6 ( \/stars/xpd-bus5/PD8   )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_UBR233 (
    .p1 ( \N$/stars/xpd-bus5|w37      ),
    .p2 ( \/stars/FLIP                ),
    .p3 ( \N$/stars/xpd-bus5|UBR233.3 ),
    .p5 ( \N$/stars/xpd-bus5|w75      )
);

capcom_dl0921_INV01 stars_xpd_bus5_UBW125 (
    .p1 ( \N$/stars/xpd-bus5|w48 ),
    .p2 ( \N$/stars/xpd-bus5|w55 )
);

capcom_dl0921_XNOR02 stars_xpd_bus5_UBW131 (
    .p1 ( \N$/stars/xpd-bus5|w78 ),
    .p2 ( \N$/stars/xpd-bus5|w75 ),
    .p3 ( \/stars/xpd-bus5/PD0   )
);

capcom_dl0921_XNOR02 stars_xpd_bus5_UBW134 (
    .p1 ( \N$/stars/xpd-bus5|w54 ),
    .p2 ( \N$/stars/xpd-bus5|w75 ),
    .p3 ( \/stars/xpd-bus5/PD1   )
);

capcom_dl0921_XNOR02 stars_xpd_bus5_UBW137 (
    .p1 ( \N$/stars/xpd-bus5|w77 ),
    .p2 ( \N$/stars/xpd-bus5|w75 ),
    .p3 ( \/stars/xpd-bus5/PD2   )
);

capcom_dl0921_XNOR02 stars_xpd_bus5_UBW139 (
    .p1 ( \N$/stars/xpd-bus5|w61 ),
    .p2 ( \N$/stars/xpd-bus5|w75 ),
    .p3 ( \/stars/xpd-bus5/PD3   )
);

capcom_dl0921_XNOR02 stars_xpd_bus5_UBW142 (
    .p1 ( \N$/stars/xpd-bus5|w48 ),
    .p2 ( \N$/stars/xpd-bus5|w75 ),
    .p3 ( \/stars/xpd-bus5/PD4   )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_UBZ26 (
    .p1 ( \N$/stars/xpd-bus5|w37     ),
    .p2 ( \/XS0                      ),
    .p3 ( \/stars/counter-xs-2/XS0   ),
    .p5 ( \N$/stars/xpd-bus5|UBZ26.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_UBZ30 (
    .p1 ( \N$/stars/xpd-bus5|w37     ),
    .p2 ( \/XS1                      ),
    .p3 ( \/stars/counter-xs-2/XS1   ),
    .p5 ( \N$/stars/xpd-bus5|UBZ30.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_UBZ34 (
    .p1 ( \N$/stars/xpd-bus5|w37     ),
    .p2 ( \/XS2                      ),
    .p3 ( \/stars/counter-xs-2/XS2   ),
    .p5 ( \N$/stars/xpd-bus5|UBZ34.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_UBZ38 (
    .p1 ( \N$/stars/xpd-bus5|w37     ),
    .p2 ( \/XS3                      ),
    .p3 ( \/stars/counter-xs-2/XS3   ),
    .p5 ( \N$/stars/xpd-bus5|UBZ38.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus5_UBZ42 (
    .p1 ( \N$/stars/xpd-bus5|w37     ),
    .p2 ( \/XS4                      ),
    .p3 ( \/stars/counter-xs-2/XS4   ),
    .p5 ( \N$/stars/xpd-bus5|UBZ42.5 )
);

//========================================================================
// stars/xpd-bus6-sync:
//========================================================================
capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBH227 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD5             ),
    .p3 ( \/stars/row6-assemble/PD5        ),
    .p5 ( \N$/stars/xpd-bus6-sync|UBH227.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBH231 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD6             ),
    .p3 ( \/stars/row6-assemble/PD6        ),
    .p5 ( \N$/stars/xpd-bus6-sync|UBH231.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBH235 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD7             ),
    .p3 ( \/stars/row6-assemble/PD7        ),
    .p5 ( \N$/stars/xpd-bus6-sync|UBH235.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBH239 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD8             ),
    .p3 ( \/stars/row6-assemble/PD8        ),
    .p5 ( \N$/stars/xpd-bus6-sync|UBH239.5 )
);

capcom_dl0921_NAND02 stars_xpd_bus6_sync_UBN258 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/stars/counter-xs-1/LOAD      ),
    .p3 ( \N$/stars/xpd-bus6-sync|w12    )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBR240 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD0             ),
    .p3 ( \N$/stars/xpd-bus6-sync|UBR240.3 ),
    .p5 ( \/stars/xpd6-sync/~PD0           )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBR244 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD1             ),
    .p3 ( \N$/stars/xpd-bus6-sync|UBR244.3 ),
    .p5 ( \/stars/xpd6-sync/~PD1           )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBR248 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD2             ),
    .p3 ( \N$/stars/xpd-bus6-sync|UBR248.3 ),
    .p5 ( \/stars/xpd6-sync/~PD2           )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBR252 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD3             ),
    .p3 ( \N$/stars/xpd-bus6-sync|UBR252.3 ),
    .p5 ( \/stars/xpd6-sync/~PD3           )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_sync_UBR255 (
    .p1 ( \N$/stars/xpd-bus6-sync|w12      ),
    .p2 ( \/stars/xpd-bus6/PD4             ),
    .p3 ( \N$/stars/xpd-bus6-sync|UBR255.3 ),
    .p5 ( \/stars/xpd6-sync/~PD4           )
);

//========================================================================
// stars/xpd-bus6:
//========================================================================
capcom_dl0921_M273C stars_xpd_bus6_UBD222 (
    .p1  ( VCC                    ),
    .p2  ( \N$/stars/xpd-bus6|w78 ),
    .p3  ( \/APD0                 ),
    .p4  ( \/APD1                 ),
    .p5  ( \N$/stars/xpd-bus6|w54 ),
    .p6  ( \N$/stars/xpd-bus6|w77 ),
    .p7  ( \/APD2                 ),
    .p8  ( \/APD3                 ),
    .p9  ( \N$/stars/xpd-bus6|w61 ),
    .p11 ( \N$/stars/xpd-bus6|w37 ),
    .p12 ( \N$/stars/xpd-bus6|w48 ),
    .p13 ( \/APD4                 ),
    .p14 ( \/APD5                 ),
    .p15 ( \/stars/xpd-bus6/PD5   ),
    .p16 ( \/stars/xpd-bus6/PD6   ),
    .p17 ( \/APD6                 ),
    .p18 ( \/APD7                 ),
    .p19 ( \/stars/xpd-bus6/PD7   )
);

capcom_dl0921_INV01 stars_xpd_bus6_UBH221 (
    .p1 ( \N$/stars/xpd-bus6|w48 ),
    .p2 ( \N$/stars/xpd-bus6|w55 )
);

capcom_dl0921_NAND05 stars_xpd_bus6_UBH222 (
    .p1 ( \N$/stars/xpd-bus6|w61 ),
    .p2 ( \N$/stars/xpd-bus6|w77 ),
    .p3 ( \N$/stars/xpd-bus6|w54 ),
    .p4 ( \N$/stars/xpd-bus6|w78 ),
    .p5 ( \N$/stars/xpd-bus6|w55 ),
    .p6 ( \/stars/xpd-bus6/PD8   )
);

capcom_dl0921_NAND02 stars_xpd_bus6_UBH474 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/stars/xpd-bus6/LOAD          ),
    .p3 ( \N$/stars/xpd-bus6|w37         )
);

capcom_dl0921_XNOR02 stars_xpd_bus6_UBR218 (
    .p1 ( \N$/stars/xpd-bus6|w78 ),
    .p2 ( \N$/stars/xpd-bus6|w75 ),
    .p3 ( \/stars/xpd-bus6/PD0   )
);

capcom_dl0921_XNOR02 stars_xpd_bus6_UBR221 (
    .p1 ( \N$/stars/xpd-bus6|w54 ),
    .p2 ( \N$/stars/xpd-bus6|w75 ),
    .p3 ( \/stars/xpd-bus6/PD1   )
);

capcom_dl0921_XNOR02 stars_xpd_bus6_UBR224 (
    .p1 ( \N$/stars/xpd-bus6|w77 ),
    .p2 ( \N$/stars/xpd-bus6|w75 ),
    .p3 ( \/stars/xpd-bus6/PD2   )
);

capcom_dl0921_XNOR02 stars_xpd_bus6_UBR226 (
    .p1 ( \N$/stars/xpd-bus6|w61 ),
    .p2 ( \N$/stars/xpd-bus6|w75 ),
    .p3 ( \/stars/xpd-bus6/PD3   )
);

capcom_dl0921_XNOR02 stars_xpd_bus6_UBR229 (
    .p1 ( \N$/stars/xpd-bus6|w48 ),
    .p2 ( \N$/stars/xpd-bus6|w75 ),
    .p3 ( \/stars/xpd-bus6/PD4   )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_UBU258 (
    .p1 ( \N$/stars/xpd-bus6|w37      ),
    .p2 ( \/stars/FLIP                ),
    .p3 ( \N$/stars/xpd-bus6|UBU258.3 ),
    .p5 ( \N$/stars/xpd-bus6|w75      )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_UBZ10 (
    .p1 ( \N$/stars/xpd-bus6|w37     ),
    .p2 ( \/XS2                      ),
    .p3 ( \/stars/counter-xs-1/XS2   ),
    .p5 ( \N$/stars/xpd-bus6|UBZ10.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_UBZ14 (
    .p1 ( \N$/stars/xpd-bus6|w37     ),
    .p2 ( \/XS3                      ),
    .p3 ( \/stars/counter-xs-1/XS3   ),
    .p5 ( \N$/stars/xpd-bus6|UBZ14.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_UBZ18 (
    .p1 ( \N$/stars/xpd-bus6|w37     ),
    .p2 ( \/XS4                      ),
    .p3 ( \/stars/counter-xs-1/XS4   ),
    .p5 ( \N$/stars/xpd-bus6|UBZ18.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_UBZ3 (
    .p1 ( \N$/stars/xpd-bus6|w37    ),
    .p2 ( \/XS0                     ),
    .p3 ( \/stars/counter-xs-1/XS0  ),
    .p5 ( \N$/stars/xpd-bus6|UBZ3.5 )
);

capcom_dl0921_DFFCOO stars_xpd_bus6_UBZ7 (
    .p1 ( \N$/stars/xpd-bus6|w37    ),
    .p2 ( \/XS1                     ),
    .p3 ( \/stars/counter-xs-1/XS1  ),
    .p5 ( \N$/stars/xpd-bus6|UBZ7.5 )
);

//========================================================================
// stars/xpd5-sync:
//========================================================================
capcom_dl0921_INV01 stars_xpd5_sync_UAA484 (
    .p1 ( \/counter-fi/~RESET    ),
    .p2 ( \N$/stars/xpd5-sync|w2 )
);

capcom_dl0921_INV01 stars_xpd5_sync_UBR50 (
    .p1 ( \/stars/xpd5-sync/LOAD ),
    .p2 ( \N$/stars/xpd5-sync|w5 )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU109 (
    .p1 ( \N$/stars/counter4|w30       ),
    .p2 ( \N$/stars/xpd5-sync|w59      ),
    .p3 ( \N$/stars/xpd5-sync|w139     ),
    .p5 ( \N$/stars/xpd5-sync|UBU109.5 )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU113 (
    .p1 ( \N$/stars/counter4|w30       ),
    .p2 ( \N$/stars/xpd5-sync|w67      ),
    .p3 ( \N$/stars/xpd5-sync|w140     ),
    .p5 ( \N$/stars/xpd5-sync|UBU113.5 )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU117 (
    .p1 ( \N$/stars/counter4|w30       ),
    .p2 ( \N$/stars/xpd5-sync|w69      ),
    .p3 ( \N$/stars/xpd5-sync|w141     ),
    .p5 ( \N$/stars/xpd5-sync|UBU117.5 )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU121 (
    .p1 ( \N$/stars/counter4|w30       ),
    .p2 ( \N$/stars/xpd5-sync|w61      ),
    .p3 ( \N$/stars/xpd5-sync|w142     ),
    .p5 ( \N$/stars/xpd5-sync|UBU121.5 )
);

capcom_dl0921_M258C stars_xpd5_sync_UBU125 (
    .p1  ( VCC                      ),
    .p2  ( VCC                      ),
    .p3  ( VCC                      ),
    .p4  ( \/stars/xpd5-sync/~PD4   ),
    .p5  ( \N$/stars/xpd5-sync|w59  ),
    .p6  ( \N$/stars/xpd5-sync|w67  ),
    .p7  ( \N$/stars/xpd5-sync|w69  ),
    .p8  ( \N$/stars/xpd5-sync|w61  ),
    .p9  ( \N$/stars/xpd5-sync|w5   ),
    .p10 ( \N$/stars/xpd5-sync|w44  ),
    .p11 ( \N$/stars/xpd5-sync|w180 ),
    .p12 ( \N$/stars/xpd5-sync|w179 ),
    .p13 ( \N$/stars/xpd5-sync|w42  ),
    .p14 ( \N$/stars/xpd5-sync|w2   )
);

capcom_dl0921_NOR04 stars_xpd5_sync_UBU24 (
    .p1 ( \N$/stars/xpd5-sync|UBU24.1 ),
    .p2 ( \N$/stars/xpd5-sync|w121    ),
    .p3 ( \N$/stars/xpd5-sync|w135    ),
    .p4 ( \N$/stars/xpd5-sync|w136    ),
    .p5 ( \N$/stars/xpd5-sync|w137    )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU52 (
    .p1 ( \N$/stars/counter4|w30      ),
    .p2 ( \N$/stars/xpd5-sync|w54     ),
    .p3 ( \N$/stars/xpd5-sync|w121    ),
    .p5 ( \N$/stars/xpd5-sync|UBU52.5 )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU56 (
    .p1 ( \N$/stars/counter4|w30      ),
    .p2 ( \N$/stars/xpd5-sync|w63     ),
    .p3 ( \N$/stars/xpd5-sync|w135    ),
    .p5 ( \N$/stars/xpd5-sync|UBU56.5 )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU60 (
    .p1 ( \N$/stars/counter4|w30      ),
    .p2 ( \N$/stars/xpd5-sync|w65     ),
    .p3 ( \N$/stars/xpd5-sync|w136    ),
    .p5 ( \N$/stars/xpd5-sync|UBU60.5 )
);

capcom_dl0921_DFFCOO stars_xpd5_sync_UBU64 (
    .p1 ( \N$/stars/counter4|w30      ),
    .p2 ( \N$/stars/xpd5-sync|w56     ),
    .p3 ( \N$/stars/xpd5-sync|w137    ),
    .p5 ( \N$/stars/xpd5-sync|UBU64.5 )
);

capcom_dl0921_INV01 stars_xpd5_sync_UBU68 (
    .p1 ( \N$/stars/xpd5-sync|UBU24.1 ),
    .p2 ( \N$/stars/xpd5-sync|w138    )
);

capcom_dl0921_NOR02 stars_xpd5_sync_UBU70 (
    .p1 ( \N$/stars/xpd5-sync|w139 ),
    .p2 ( \N$/stars/xpd5-sync|w138 ),
    .p3 ( \N$/stars/xpd5-sync|w159 )
);

capcom_dl0921_XOR02 stars_xpd5_sync_UBU73 (
    .p1 ( \N$/stars/xpd5-sync|w139 ),
    .p2 ( \N$/stars/xpd5-sync|w138 ),
    .p3 ( \N$/stars/xpd5-sync|w42  )
);

capcom_dl0921_NOR03 stars_xpd5_sync_UBU92 (
    .p1 ( \N$/stars/xpd5-sync|w138 ),
    .p2 ( \N$/stars/xpd5-sync|w139 ),
    .p3 ( \N$/stars/xpd5-sync|w140 ),
    .p4 ( \N$/stars/xpd5-sync|w161 )
);

capcom_dl0921_XNOR02 stars_xpd5_sync_UBU96 (
    .p1 ( \N$/stars/xpd5-sync|w140 ),
    .p2 ( \N$/stars/xpd5-sync|w159 ),
    .p3 ( \N$/stars/xpd5-sync|w179 )
);

capcom_dl0921_XNOR02 stars_xpd5_sync_UBU98 (
    .p1 ( \N$/stars/xpd5-sync|w141 ),
    .p2 ( \N$/stars/xpd5-sync|w161 ),
    .p3 ( \N$/stars/xpd5-sync|w180 )
);

capcom_dl0921_NOR04 stars_xpd5_sync_UBW107 (
    .p1 ( \N$/stars/xpd5-sync|w163 ),
    .p2 ( \N$/stars/xpd5-sync|w138 ),
    .p3 ( \N$/stars/xpd5-sync|w139 ),
    .p4 ( \N$/stars/xpd5-sync|w140 ),
    .p5 ( \N$/stars/xpd5-sync|w141 )
);

capcom_dl0921_NOR05 stars_xpd5_sync_UBW113 (
    .p1 ( \/stars/xpd5-sync/ZERO   ),
    .p2 ( \N$/stars/xpd5-sync|w138 ),
    .p3 ( \N$/stars/xpd5-sync|w139 ),
    .p4 ( \N$/stars/xpd5-sync|w141 ),
    .p5 ( \N$/stars/xpd5-sync|w140 ),
    .p6 ( \N$/stars/xpd5-sync|w142 )
);

capcom_dl0921_XNOR02 stars_xpd5_sync_UBW117 (
    .p1 ( \N$/stars/xpd5-sync|w142 ),
    .p2 ( \N$/stars/xpd5-sync|w163 ),
    .p3 ( \N$/stars/xpd5-sync|w44  )
);

capcom_dl0921_NOR03 stars_xpd5_sync_UBW35 (
    .p1 ( \N$/stars/xpd5-sync|w121 ),
    .p2 ( \N$/stars/xpd5-sync|w135 ),
    .p3 ( \N$/stars/xpd5-sync|w136 ),
    .p4 ( \N$/stars/xpd5-sync|w155 )
);

capcom_dl0921_XNOR02 stars_xpd5_sync_UBW38 (
    .p1 ( \N$/stars/xpd5-sync|w137 ),
    .p2 ( \N$/stars/xpd5-sync|w155 ),
    .p3 ( \N$/stars/xpd5-sync|w39  )
);

capcom_dl0921_M258C stars_xpd5_sync_UBW48 (
    .p1  ( \/stars/xpd5-sync/~PD3   ),
    .p2  ( \/stars/xpd5-sync/~PD2   ),
    .p3  ( \/stars/xpd5-sync/~PD1   ),
    .p4  ( \/stars/xpd5-sync/~PD0   ),
    .p5  ( \N$/stars/xpd5-sync|w54  ),
    .p6  ( \N$/stars/xpd5-sync|w63  ),
    .p7  ( \N$/stars/xpd5-sync|w65  ),
    .p8  ( \N$/stars/xpd5-sync|w56  ),
    .p9  ( \N$/stars/xpd5-sync|w5   ),
    .p10 ( \N$/stars/xpd5-sync|w39  ),
    .p11 ( \N$/stars/xpd5-sync|w173 ),
    .p12 ( \N$/stars/xpd5-sync|w38  ),
    .p13 ( \N$/stars/xpd5-sync|w121 ),
    .p14 ( \N$/stars/xpd5-sync|w40  )
);

capcom_dl0921_INV01 stars_xpd5_sync_UBZ49 (
    .p1 ( \/counter-fi/~RESET     ),
    .p2 ( \N$/stars/xpd5-sync|w40 )
);

capcom_dl0921_XOR02 stars_xpd5_sync_UBZ52 (
    .p1 ( \N$/stars/xpd5-sync|w135 ),
    .p2 ( \N$/stars/xpd5-sync|w121 ),
    .p3 ( \N$/stars/xpd5-sync|w38  )
);

capcom_dl0921_NOR02 stars_xpd5_sync_UBZ55 (
    .p1 ( \N$/stars/xpd5-sync|w135 ),
    .p2 ( \N$/stars/xpd5-sync|w121 ),
    .p3 ( \N$/stars/xpd5-sync|w153 )
);

capcom_dl0921_XNOR02 stars_xpd5_sync_UBZ58 (
    .p1 ( \N$/stars/xpd5-sync|w136 ),
    .p2 ( \N$/stars/xpd5-sync|w153 ),
    .p3 ( \N$/stars/xpd5-sync|w173 )
);

//========================================================================
// stars/xpd6-sync:
//========================================================================
capcom_dl0921_XOR02 stars_xpd6_sync_UBR52 (
    .p1 ( \N$/stars/xpd6-sync|w139 ),
    .p2 ( \N$/stars/xpd6-sync|w138 ),
    .p3 ( \N$/stars/xpd6-sync|w42  )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBR56 (
    .p1 ( \/stars/counter-xs-1/~CLK8M ),
    .p2 ( \N$/stars/xpd6-sync|w59     ),
    .p3 ( \N$/stars/xpd6-sync|w139    ),
    .p5 ( \N$/stars/xpd6-sync|UBR56.5 )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBR60 (
    .p1 ( \/stars/counter-xs-1/~CLK8M ),
    .p2 ( \N$/stars/xpd6-sync|w67     ),
    .p3 ( \N$/stars/xpd6-sync|w140    ),
    .p5 ( \N$/stars/xpd6-sync|UBR60.5 )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBR64 (
    .p1 ( \/stars/counter-xs-1/~CLK8M ),
    .p2 ( \N$/stars/xpd6-sync|w69     ),
    .p3 ( \N$/stars/xpd6-sync|w141    ),
    .p5 ( \N$/stars/xpd6-sync|UBR64.5 )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBR68 (
    .p1 ( \/stars/counter-xs-1/~CLK8M ),
    .p2 ( \N$/stars/xpd6-sync|w61     ),
    .p3 ( \N$/stars/xpd6-sync|w142    ),
    .p5 ( \N$/stars/xpd6-sync|UBR68.5 )
);

capcom_dl0921_INV01 stars_xpd6_sync_UBR72 (
    .p1 ( \/counter-fi/~RESET    ),
    .p2 ( \N$/stars/xpd6-sync|w2 )
);

capcom_dl0921_NOR04 stars_xpd6_sync_UBR73 (
    .p1 ( \N$/stars/xpd6-sync|w163 ),
    .p2 ( \N$/stars/xpd6-sync|w138 ),
    .p3 ( \N$/stars/xpd6-sync|w139 ),
    .p4 ( \N$/stars/xpd6-sync|w140 ),
    .p5 ( \N$/stars/xpd6-sync|w141 )
);

capcom_dl0921_NOR05 stars_xpd6_sync_UBR76 (
    .p1 ( \/stars/xpd6-sync/ZERO   ),
    .p2 ( \N$/stars/xpd6-sync|w138 ),
    .p3 ( \N$/stars/xpd6-sync|w139 ),
    .p4 ( \N$/stars/xpd6-sync|w141 ),
    .p5 ( \N$/stars/xpd6-sync|w140 ),
    .p6 ( \N$/stars/xpd6-sync|w142 )
);

capcom_dl0921_XNOR02 stars_xpd6_sync_UBR81 (
    .p1 ( \N$/stars/xpd6-sync|w142 ),
    .p2 ( \N$/stars/xpd6-sync|w163 ),
    .p3 ( \N$/stars/xpd6-sync|w44  )
);

capcom_dl0921_M258C stars_xpd6_sync_UBR83 (
    .p1  ( VCC                      ),
    .p2  ( VCC                      ),
    .p3  ( VCC                      ),
    .p4  ( \/stars/xpd6-sync/~PD4   ),
    .p5  ( \N$/stars/xpd6-sync|w59  ),
    .p6  ( \N$/stars/xpd6-sync|w67  ),
    .p7  ( \N$/stars/xpd6-sync|w69  ),
    .p8  ( \N$/stars/xpd6-sync|w61  ),
    .p9  ( \N$/stars/xpd6-sync|w5   ),
    .p10 ( \N$/stars/xpd6-sync|w44  ),
    .p11 ( \N$/stars/xpd6-sync|w180 ),
    .p12 ( \N$/stars/xpd6-sync|w179 ),
    .p13 ( \N$/stars/xpd6-sync|w42  ),
    .p14 ( \N$/stars/xpd6-sync|w2   )
);

capcom_dl0921_INV01 stars_xpd6_sync_UBU181 (
    .p1 ( \/stars/xpd6-sync/LOAD ),
    .p2 ( \N$/stars/xpd6-sync|w5 )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBU218 (
    .p1 ( \/stars/counter-xs-1/~CLK8M  ),
    .p2 ( \N$/stars/xpd6-sync|w54      ),
    .p3 ( \N$/stars/xpd6-sync|w121     ),
    .p5 ( \N$/stars/xpd6-sync|UBU218.5 )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBU222 (
    .p1 ( \/stars/counter-xs-1/~CLK8M  ),
    .p2 ( \N$/stars/xpd6-sync|w63      ),
    .p3 ( \N$/stars/xpd6-sync|w135     ),
    .p5 ( \N$/stars/xpd6-sync|UBU222.5 )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBU226 (
    .p1 ( \/stars/counter-xs-1/~CLK8M  ),
    .p2 ( \N$/stars/xpd6-sync|w65      ),
    .p3 ( \N$/stars/xpd6-sync|w136     ),
    .p5 ( \N$/stars/xpd6-sync|UBU226.5 )
);

capcom_dl0921_DFFCOO stars_xpd6_sync_UBU230 (
    .p1 ( \/stars/counter-xs-1/~CLK8M  ),
    .p2 ( \N$/stars/xpd6-sync|w56      ),
    .p3 ( \N$/stars/xpd6-sync|w137     ),
    .p5 ( \N$/stars/xpd6-sync|UBU230.5 )
);

capcom_dl0921_XNOR02 stars_xpd6_sync_UBU77 (
    .p1 ( \N$/stars/xpd6-sync|w141 ),
    .p2 ( \N$/stars/xpd6-sync|w161 ),
    .p3 ( \N$/stars/xpd6-sync|w180 )
);

capcom_dl0921_NOR03 stars_xpd6_sync_UBZ80 (
    .p1 ( \N$/stars/xpd6-sync|w138 ),
    .p2 ( \N$/stars/xpd6-sync|w139 ),
    .p3 ( \N$/stars/xpd6-sync|w140 ),
    .p4 ( \N$/stars/xpd6-sync|w161 )
);

capcom_dl0921_NOR02 stars_xpd6_sync_UBZ83 (
    .p1 ( \N$/stars/xpd6-sync|w139 ),
    .p2 ( \N$/stars/xpd6-sync|w138 ),
    .p3 ( \N$/stars/xpd6-sync|w159 )
);

capcom_dl0921_XNOR02 stars_xpd6_sync_UBZ87 (
    .p1 ( \N$/stars/xpd6-sync|w140 ),
    .p2 ( \N$/stars/xpd6-sync|w159 ),
    .p3 ( \N$/stars/xpd6-sync|w179 )
);

capcom_dl0921_XOR02 stars_xpd6_sync_UCC204 (
    .p1 ( \N$/stars/xpd6-sync|w135 ),
    .p2 ( \N$/stars/xpd6-sync|w121 ),
    .p3 ( \N$/stars/xpd6-sync|w38  )
);

capcom_dl0921_XNOR02 stars_xpd6_sync_UCC221 (
    .p1 ( \N$/stars/xpd6-sync|w136 ),
    .p2 ( \N$/stars/xpd6-sync|w153 ),
    .p3 ( \N$/stars/xpd6-sync|w173 )
);

capcom_dl0921_M258C stars_xpd6_sync_UCC224 (
    .p1  ( \/stars/xpd6-sync/~PD3   ),
    .p2  ( \/stars/xpd6-sync/~PD2   ),
    .p3  ( \/stars/xpd6-sync/~PD1   ),
    .p4  ( \/stars/xpd6-sync/~PD0   ),
    .p5  ( \N$/stars/xpd6-sync|w54  ),
    .p6  ( \N$/stars/xpd6-sync|w63  ),
    .p7  ( \N$/stars/xpd6-sync|w65  ),
    .p8  ( \N$/stars/xpd6-sync|w56  ),
    .p9  ( \N$/stars/xpd6-sync|w5   ),
    .p10 ( \N$/stars/xpd6-sync|w39  ),
    .p11 ( \N$/stars/xpd6-sync|w173 ),
    .p12 ( \N$/stars/xpd6-sync|w38  ),
    .p13 ( \N$/stars/xpd6-sync|w121 ),
    .p14 ( \N$/stars/xpd6-sync|w40  )
);

capcom_dl0921_NOR02 stars_xpd6_sync_UCC239 (
    .p1 ( \N$/stars/xpd6-sync|w135 ),
    .p2 ( \N$/stars/xpd6-sync|w121 ),
    .p3 ( \N$/stars/xpd6-sync|w153 )
);

capcom_dl0921_INV01 stars_xpd6_sync_UCC263 (
    .p1 ( \/counter-fi/~RESET     ),
    .p2 ( \N$/stars/xpd6-sync|w40 )
);

capcom_dl0921_INV01 stars_xpd6_sync_UCC96 (
    .p1 ( \N$/stars/xpd6-sync|UCG203.1 ),
    .p2 ( \N$/stars/xpd6-sync|w138     )
);

capcom_dl0921_NOR04 stars_xpd6_sync_UCG203 (
    .p1 ( \N$/stars/xpd6-sync|UCG203.1 ),
    .p2 ( \N$/stars/xpd6-sync|w121     ),
    .p3 ( \N$/stars/xpd6-sync|w135     ),
    .p4 ( \N$/stars/xpd6-sync|w136     ),
    .p5 ( \N$/stars/xpd6-sync|w137     )
);

capcom_dl0921_NOR03 stars_xpd6_sync_UCG206 (
    .p1 ( \N$/stars/xpd6-sync|w121 ),
    .p2 ( \N$/stars/xpd6-sync|w135 ),
    .p3 ( \N$/stars/xpd6-sync|w136 ),
    .p4 ( \N$/stars/xpd6-sync|w155 )
);

capcom_dl0921_XNOR02 stars_xpd6_sync_UCG209 (
    .p1 ( \N$/stars/xpd6-sync|w137 ),
    .p2 ( \N$/stars/xpd6-sync|w155 ),
    .p3 ( \N$/stars/xpd6-sync|w39  )
);

//========================================================================
// tilemaps/cb-bus1:
//========================================================================
capcom_dl0921_NAND02 tilemaps_cb_bus1_UAN81 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr1-sync/LOAD       ),
    .p3 ( \N$/tilemaps/cb-bus1|w188      )
);

capcom_dl0921_M273CG tilemaps_cb_bus1_UAO79 (
    .p1  ( \/obj-manager/SERIAL-CHNL     ),
    .p2  ( \N$/tilemaps/cb-bus1|w141     ),
    .p3  ( \/CB0                         ),
    .p4  ( \/CB1                         ),
    .p5  ( \N$/tilemaps/cb-bus1|w136     ),
    .p6  ( \N$/tilemaps/cb-bus1|w130     ),
    .p7  ( \/CB2                         ),
    .p8  ( \/CB3                         ),
    .p9  ( \N$/tilemaps/cb-bus1|w124     ),
    .p11 ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p12 ( \N$/tilemaps/cb-bus1|w119     ),
    .p13 ( \/CB4                         ),
    .p14 ( \/CPC0                        ),
    .p15 ( \N$/tilemaps/cb-bus1|w113     ),
    .p16 ( \N$/tilemaps/cb-bus1|w108     ),
    .p17 ( \/CPC1                        ),
    .p18 ( \/tilemaps/CDEN               ),
    .p19 ( \N$/tilemaps/cb-bus1|w103     )
);

capcom_dl0921_M273CG tilemaps_cb_bus1_UAP79 (
    .p1  ( \N$/tilemaps/cb-bus1|w17      ),
    .p2  ( \N$/tilemaps/cb-bus1|w141     ),
    .p3  ( \/CB0                         ),
    .p4  ( \/CB1                         ),
    .p5  ( \N$/tilemaps/cb-bus1|w136     ),
    .p6  ( \N$/tilemaps/cb-bus1|w130     ),
    .p7  ( \/CB2                         ),
    .p8  ( \/CB3                         ),
    .p9  ( \N$/tilemaps/cb-bus1|w124     ),
    .p11 ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p12 ( \N$/tilemaps/cb-bus1|w119     ),
    .p13 ( \/CB4                         ),
    .p14 ( \/CPC0                        ),
    .p15 ( \N$/tilemaps/cb-bus1|w113     ),
    .p16 ( \N$/tilemaps/cb-bus1|w108     ),
    .p17 ( \/CPC1                        ),
    .p18 ( \/tilemaps/CDEN               ),
    .p19 ( \N$/tilemaps/cb-bus1|w103     )
);

capcom_dl0921_M273CG tilemaps_cb_bus1_UAQ79 (
    .p1  ( \/obj-manager/SERIAL-CHNL     ),
    .p2  ( \N$/tilemaps/cb-bus1|w143     ),
    .p3  ( VCC                           ),
    .p4  ( VCC                           ),
    .p5  ( \N$/tilemaps/cb-bus1|w138     ),
    .p6  ( \N$/tilemaps/cb-bus1|w133     ),
    .p7  ( \/obj-manager/XSEL            ),
    .p8  ( \/XS0                         ),
    .p9  ( \N$/tilemaps/cb-bus1|w148     ),
    .p11 ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p12 ( \N$/tilemaps/cb-bus1|w160     ),
    .p13 ( \/XS1                         ),
    .p14 ( \/XS2                         ),
    .p15 ( \N$/tilemaps/cb-bus1|w162     ),
    .p16 ( \N$/tilemaps/cb-bus1|w110     ),
    .p17 ( VCC                           ),
    .p18 ( VCC                           ),
    .p19 ( \N$/tilemaps/cb-bus1|w105     )
);

capcom_dl0921_M273CG tilemaps_cb_bus1_UAR79 (
    .p1  ( \N$/tilemaps/cb-bus1|w17      ),
    .p2  ( \N$/tilemaps/cb-bus1|w143     ),
    .p3  ( VCC                           ),
    .p4  ( VCC                           ),
    .p5  ( \N$/tilemaps/cb-bus1|w138     ),
    .p6  ( \N$/tilemaps/cb-bus1|w133     ),
    .p7  ( \/obj-manager/XSEL            ),
    .p8  ( \/XS0                         ),
    .p9  ( \N$/tilemaps/cb-bus1|w148     ),
    .p11 ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p12 ( \N$/tilemaps/cb-bus1|w160     ),
    .p13 ( \/XS1                         ),
    .p14 ( \/XS2                         ),
    .p15 ( \N$/tilemaps/cb-bus1|w162     ),
    .p16 ( \N$/tilemaps/cb-bus1|w110     ),
    .p17 ( VCC                           ),
    .p18 ( VCC                           ),
    .p19 ( \N$/tilemaps/cb-bus1|w105     )
);

capcom_dl0921_INV01 tilemaps_cb_bus1_UAS126 (
    .p1 ( \/obj-manager/SERIAL-CHNL ),
    .p2 ( \N$/tilemaps/cb-bus1|w17  )
);

capcom_dl0921_M273C tilemaps_cb_bus1_UAS79 (
    .p1  ( VCC                       ),
    .p2  ( \N$/tilemaps/cb-bus1|w177 ),
    .p3  ( \N$/tilemaps/cb-bus1|w141 ),
    .p4  ( \N$/tilemaps/cb-bus1|w136 ),
    .p5  ( \N$/tilemaps/cb-bus1|w178 ),
    .p6  ( \N$/tilemaps/cb-bus1|w179 ),
    .p7  ( \N$/tilemaps/cb-bus1|w130 ),
    .p8  ( \N$/tilemaps/cb-bus1|w124 ),
    .p9  ( \N$/tilemaps/cb-bus1|w180 ),
    .p11 ( \N$/tilemaps/cb-bus1|w188 ),
    .p12 ( \N$/tilemaps/cb-bus1|w181 ),
    .p13 ( \N$/tilemaps/cb-bus1|w119 ),
    .p14 ( \N$/tilemaps/cb-bus1|w113 ),
    .p15 ( \N$/tilemaps/cb-bus1|w182 ),
    .p16 ( \N$/tilemaps/cb-bus1|w183 ),
    .p17 ( \N$/tilemaps/cb-bus1|w108 ),
    .p18 ( \N$/tilemaps/cb-bus1|w103 ),
    .p19 ( \N$/tilemaps/cb-bus1|w184 )
);

capcom_dl0921_M273C tilemaps_cb_bus1_UAT79 (
    .p1  ( VCC                           ),
    .p2  ( \/tilemaps/col2-assemble/CDEN ),
    .p3  ( \N$/tilemaps/cb-bus1|w184     ),
    .p4  ( \N$/tilemaps/cb-bus1|w183     ),
    .p5  ( \/tilemaps/col2-assemble/CPC1 ),
    .p6  ( \/tilemaps/col2-assemble/CPC0 ),
    .p7  ( \N$/tilemaps/cb-bus1|w182     ),
    .p8  ( \N$/tilemaps/cb-bus1|w181     ),
    .p9  ( \/tilemaps/col2-assemble/CB4  ),
    .p11 ( \N$/tilemaps/cb-bus1|w188     ),
    .p12 ( \/tilemaps/col2-assemble/CB3  ),
    .p13 ( \N$/tilemaps/cb-bus1|w180     ),
    .p14 ( \N$/tilemaps/cb-bus1|w179     ),
    .p15 ( \/tilemaps/col2-assemble/CB2  ),
    .p16 ( \/tilemaps/col2-assemble/CB1  ),
    .p17 ( \N$/tilemaps/cb-bus1|w178     ),
    .p18 ( \N$/tilemaps/cb-bus1|w177     ),
    .p19 ( \/tilemaps/col2-assemble/CB0  )
);

capcom_dl0921_DFFCOR tilemaps_cb_bus1_UAX81 (
    .p1 ( \N$/tilemaps/cb-bus1|w188    ),
    .p2 ( \N$/tilemaps/cb-bus1|w133    ),
    .p3 ( \/tilemaps/xpd-bus1/XSEL     ),
    .p4 ( VCC                          ),
    .p5 ( \N$/tilemaps/cb-bus1|UAX81.5 )
);

capcom_dl0921_DFFCOR tilemaps_cb_bus1_UAX85 (
    .p1 ( \N$/tilemaps/cb-bus1|w188    ),
    .p2 ( \N$/tilemaps/cb-bus1|w148    ),
    .p3 ( \/tilemaps/sr1/XS0           ),
    .p4 ( VCC                          ),
    .p5 ( \N$/tilemaps/cb-bus1|UAX85.5 )
);

capcom_dl0921_DFFCOR tilemaps_cb_bus1_UAX90 (
    .p1 ( \N$/tilemaps/cb-bus1|w188    ),
    .p2 ( \N$/tilemaps/cb-bus1|w160    ),
    .p3 ( \/tilemaps/sr1/XS1           ),
    .p4 ( VCC                          ),
    .p5 ( \N$/tilemaps/cb-bus1|UAX90.5 )
);

capcom_dl0921_DFFCOR tilemaps_cb_bus1_UAX94 (
    .p1 ( \N$/tilemaps/cb-bus1|w188    ),
    .p2 ( \N$/tilemaps/cb-bus1|w162    ),
    .p3 ( \/tilemaps/sr1/XS2           ),
    .p4 ( VCC                          ),
    .p5 ( \N$/tilemaps/cb-bus1|UAX94.5 )
);

//========================================================================
// tilemaps/cb-bus2:
//========================================================================
capcom_dl0921_M273C tilemaps_cb_bus2_UAE79 (
    .p1  ( VCC                           ),
    .p2  ( \N$/tilemaps/cb-bus2|w24      ),
    .p3  ( \/CB0                         ),
    .p4  ( \/CB1                         ),
    .p5  ( \N$/tilemaps/cb-bus2|w25      ),
    .p6  ( \N$/tilemaps/cb-bus2|w26      ),
    .p7  ( \/CB2                         ),
    .p8  ( \/CB3                         ),
    .p9  ( \N$/tilemaps/cb-bus2|w27      ),
    .p11 ( \/tilemaps/cb-bus2/LOAD-CHNLB ),
    .p12 ( \N$/tilemaps/cb-bus2|w28      ),
    .p13 ( \/CB4                         ),
    .p14 ( \/CPC0                        ),
    .p15 ( \N$/tilemaps/cb-bus2|w29      ),
    .p16 ( \N$/tilemaps/cb-bus2|w30      ),
    .p17 ( \/CPC1                        ),
    .p18 ( \/tilemaps/CDEN               ),
    .p19 ( \N$/tilemaps/cb-bus2|w31      )
);

capcom_dl0921_M273C tilemaps_cb_bus2_UAF79 (
    .p1  ( VCC                           ),
    .p2  ( \/tilemaps/col3-assemble/CDEN ),
    .p3  ( \N$/tilemaps/cb-bus2|w31      ),
    .p4  ( \N$/tilemaps/cb-bus2|w30      ),
    .p5  ( \/tilemaps/col3-assemble/CPC1 ),
    .p6  ( \/tilemaps/col3-assemble/CPC0 ),
    .p7  ( \N$/tilemaps/cb-bus2|w29      ),
    .p8  ( \N$/tilemaps/cb-bus2|w28      ),
    .p9  ( \/tilemaps/col3-assemble/CB4  ),
    .p11 ( \N$/tilemaps/cb-bus2|w50      ),
    .p12 ( \/tilemaps/col3-assemble/CB3  ),
    .p13 ( \N$/tilemaps/cb-bus2|w27      ),
    .p14 ( \N$/tilemaps/cb-bus2|w26      ),
    .p15 ( \/tilemaps/col3-assemble/CB2  ),
    .p16 ( \/tilemaps/col3-assemble/CB1  ),
    .p17 ( \N$/tilemaps/cb-bus2|w25      ),
    .p18 ( \N$/tilemaps/cb-bus2|w24      ),
    .p19 ( \/tilemaps/col3-assemble/CB0  )
);

capcom_dl0921_XOR02 tilemaps_cb_bus2_UAG124 (
    .p1 ( \/obj-manager/SERIAL-CHNL       ),
    .p2 ( \N$/tilemaps/cb-bus2|w59        ),
    .p3 ( \/tilemaps/xpd-bus2/SERIAL-CHNL )
);

capcom_dl0921_M273C tilemaps_cb_bus2_UAI81 (
    .p1  ( VCC                           ),
    .p2  ( \N$/tilemaps/cb-bus2|w32      ),
    .p3  ( VCC                           ),
    .p4  ( VCC                           ),
    .p5  ( \N$/tilemaps/cb-bus2|w33      ),
    .p6  ( \N$/tilemaps/cb-bus2|w34      ),
    .p7  ( VCC                           ),
    .p8  ( \/obj-manager/XSEL            ),
    .p9  ( \N$/tilemaps/cb-bus2|w59      ),
    .p11 ( \/tilemaps/cb-bus2/LOAD-CHNLB ),
    .p12 ( \/tilemaps/sr2-sync/XS0       ),
    .p13 ( \/XS0                         ),
    .p14 ( \/XS1                         ),
    .p15 ( \/tilemaps/sr2-sync/XS1       ),
    .p16 ( \/tilemaps/sr2-sync/XS2       ),
    .p17 ( \/XS2                         ),
    .p18 ( \/XS3                         ),
    .p19 ( \/tilemaps/sr2-sync/XS3       )
);

capcom_dl0921_M273C tilemaps_cb_bus2_UAJ81 (
    .p1  ( VCC                           ),
    .p2  ( \/tilemaps/sr2/XS3            ),
    .p3  ( \/tilemaps/sr2-sync/XS3       ),
    .p4  ( \/tilemaps/sr2-sync/XS2       ),
    .p5  ( \/tilemaps/sr2/XS2            ),
    .p6  ( \/tilemaps/sr2/XS1            ),
    .p7  ( \/tilemaps/sr2-sync/XS1       ),
    .p8  ( \/tilemaps/sr2-sync/XS0       ),
    .p9  ( \/tilemaps/sr2/XS0            ),
    .p11 ( \N$/tilemaps/cb-bus2|w50      ),
    .p12 ( \/tilemaps/xpd-bus2/XSEL      ),
    .p13 ( \N$/tilemaps/cb-bus2|w59      ),
    .p14 ( \N$/tilemaps/cb-bus2|w34      ),
    .p15 ( \N$/tilemaps/cb-bus2|UAJ81.15 ),
    .p16 ( \N$/tilemaps/cb-bus2|UAJ81.16 ),
    .p17 ( \N$/tilemaps/cb-bus2|w33      ),
    .p18 ( \N$/tilemaps/cb-bus2|w32      ),
    .p19 ( \N$/tilemaps/cb-bus2|UAJ81.19 )
);

capcom_dl0921_NAND02 tilemaps_cb_bus2_UAN124 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr1-sync/LOAD       ),
    .p3 ( \N$/tilemaps/cb-bus2|w50       )
);

//========================================================================
// tilemaps/cb-bus3:
//========================================================================
capcom_dl0921_M273C tilemaps_cb_bus3_UAR287 (
    .p1  ( VCC                           ),
    .p2  ( \/tilemaps/col4-assemble/CB0  ),
    .p3  ( \/CB0                         ),
    .p4  ( \/CB1                         ),
    .p5  ( \/tilemaps/col4-assemble/CB1  ),
    .p6  ( \/tilemaps/col4-assemble/CB2  ),
    .p7  ( \/CB2                         ),
    .p8  ( \/CB3                         ),
    .p9  ( \/tilemaps/col4-assemble/CB3  ),
    .p11 ( \/tilemaps/cb-bus3/LOAD-CHNLA ),
    .p12 ( \/tilemaps/col4-assemble/CB4  ),
    .p13 ( \/CB4                         ),
    .p14 ( \/CPC0                        ),
    .p15 ( \/tilemaps/col4-assemble/CPC0 ),
    .p16 ( \/tilemaps/col4-assemble/CPC1 ),
    .p17 ( \/CPC1                        ),
    .p18 ( \/tilemaps/CDEN               ),
    .p19 ( \/tilemaps/col4-assemble/CDEN )
);

capcom_dl0921_DFFCOO tilemaps_cb_bus3_UAR341 (
    .p1 ( \/tilemaps/cb-bus3/LOAD-CHNLB ),
    .p2 ( \/obj-manager/XSEL            ),
    .p3 ( \N$/tilemaps/cb-bus3|w31      ),
    .p5 ( \N$/tilemaps/cb-bus3|UAR341.5 )
);

capcom_dl0921_XOR02 tilemaps_cb_bus3_UAR346 (
    .p1 ( \/obj-manager/SERIAL-CHNL       ),
    .p2 ( \N$/tilemaps/cb-bus3|w31        ),
    .p3 ( \/tilemaps/xpd-bus3/SERIAL-CHNL )
);

capcom_dl0921_M273C tilemaps_cb_bus3_UAU289 (
    .p1  ( VCC                            ),
    .p2  ( \N$/tilemaps/cb-bus3|UAU289.2  ),
    .p3  ( VCC                            ),
    .p4  ( \/XS3                          ),
    .p5  ( \/tilemaps/sr3/XS3             ),
    .p6  ( \/tilemaps/sr3/XS2             ),
    .p7  ( \/XS2                          ),
    .p8  ( \/XS1                          ),
    .p9  ( \/tilemaps/sr3/XS1             ),
    .p11 ( \/tilemaps/cb-bus3/LOAD-CHNLA  ),
    .p12 ( \/tilemaps/sr3/XS0             ),
    .p13 ( \/XS0                          ),
    .p14 ( \N$/tilemaps/cb-bus3|w31       ),
    .p15 ( \/tilemaps/xpd-bus3/XSEL       ),
    .p16 ( \N$/tilemaps/cb-bus3|UAU289.16 ),
    .p17 ( VCC                            ),
    .p18 ( VCC                            ),
    .p19 ( \N$/tilemaps/cb-bus3|UAU289.19 )
);

//========================================================================
// tilemaps/col2-assemble:
//========================================================================
capcom_dl0921_M273C tilemaps_col2_assemble_UAU79 (
    .p1  ( VCC                                      ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D4  ),
    .p3  ( \/tilemaps/col2-assemble/CB0             ),
    .p4  ( \/tilemaps/col2-assemble/CB1             ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D5  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D6  ),
    .p7  ( \/tilemaps/col2-assemble/CB2             ),
    .p8  ( \/tilemaps/col2-assemble/CB3             ),
    .p9  ( \/lut-assembly/layer-draw-order/COL2-D7  ),
    .p11 ( \N$/tilemaps/col2-assemble|w13           ),
    .p12 ( \/lut-assembly/layer-draw-order/COL2-D8  ),
    .p13 ( \/tilemaps/col2-assemble/CB4             ),
    .p14 ( \/tilemaps/col2-assemble/CPC0            ),
    .p15 ( \/lut-assembly/layer-draw-order/COL2-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/COL2-D10 ),
    .p17 ( \/tilemaps/col2-assemble/CPC1            ),
    .p18 ( \/tilemaps/col2-assemble/CDEN            ),
    .p19 ( \/lut-assembly/layer-draw-order/COL2-D11 )
);

capcom_dl0921_M367C tilemaps_col2_assemble_UAV116 (
    .p1  ( \/tilemaps/col2-assemble/~DEBUG ),
    .p2  ( \/tilemaps/col2-assemble/GFX-A  ),
    .p3  ( \/tilemaps/col2-assemble/GFX-B  ),
    .p4  ( \/tilemaps/col2-assemble/GFX-C  ),
    .p5  ( \/tilemaps/col2-assemble/GFX-D  ),
    .p15 ( \/debug/td-io/IN11              ),
    .p16 ( \/debug/td-io/IN10              ),
    .p17 ( \/debug/td-io/IN9               ),
    .p18 ( \/debug/td-io/IN8               )
);

capcom_dl0921_M541C tilemaps_col2_assemble_UAV79 (
    .p1  ( \/tilemaps/col2-assemble/~DEBUG          ),
    .p2  ( \/lut-assembly/layer-draw-order/COL2-D4  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL2-D5  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL2-D6  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL2-D7  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL2-D8  ),
    .p7  ( \/lut-assembly/layer-draw-order/COL2-D9  ),
    .p8  ( \/lut-assembly/layer-draw-order/COL2-D10 ),
    .p9  ( \/lut-assembly/layer-draw-order/COL2-D11 ),
    .p11 ( \/debug/td-io/IN7                        ),
    .p12 ( \/debug/td-io/IN6                        ),
    .p13 ( \/debug/td-io/IN5                        ),
    .p14 ( \/debug/td-io/IN4                        ),
    .p15 ( \/debug/td-io/IN3                        ),
    .p16 ( \/debug/td-io/IN2                        ),
    .p17 ( \/debug/td-io/IN1                        ),
    .p18 ( \/debug/td-io/IN0                        )
);

capcom_dl0921_NAND02 tilemaps_col2_assemble_UAZ91 (
    .p1 ( \/lut-assembly/lut-storage/CLK      ),
    .p2 ( \/tilemaps/col2-assemble/SERIAL-END ),
    .p3 ( \N$/tilemaps/col2-assemble|w13      )
);

capcom_dl0921_OR02 tilemaps_col2_assemble_UBH17 (
    .p1 ( \/tilemaps/col2-assemble/~COL2-E        ),
    .p2 ( \/tilemaps/col2-assemble/GFX-A          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL2-D0 )
);

capcom_dl0921_OR02 tilemaps_col2_assemble_UBH19 (
    .p1 ( \/tilemaps/col2-assemble/~COL2-E        ),
    .p2 ( \/tilemaps/col2-assemble/GFX-B          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL2-D1 )
);

capcom_dl0921_OR02 tilemaps_col2_assemble_UBH22 (
    .p1 ( \/tilemaps/col2-assemble/~COL2-E        ),
    .p2 ( \/tilemaps/col2-assemble/GFX-C          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL2-D2 )
);

capcom_dl0921_OR02 tilemaps_col2_assemble_UBH24 (
    .p1 ( \/tilemaps/col2-assemble/~COL2-E        ),
    .p2 ( \/tilemaps/col2-assemble/GFX-D          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL2-D3 )
);

//========================================================================
// tilemaps/col3-assemble:
//========================================================================
capcom_dl0921_M273C tilemaps_col3_assemble_UAG79 (
    .p1  ( VCC                                      ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D4  ),
    .p3  ( \/tilemaps/col3-assemble/CB0             ),
    .p4  ( \/tilemaps/col3-assemble/CB1             ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D5  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D6  ),
    .p7  ( \/tilemaps/col3-assemble/CB2             ),
    .p8  ( \/tilemaps/col3-assemble/CB3             ),
    .p9  ( \/lut-assembly/layer-draw-order/COL3-D7  ),
    .p11 ( \N$/tilemaps/col3-assemble|w13           ),
    .p12 ( \/lut-assembly/layer-draw-order/COL3-D8  ),
    .p13 ( \/tilemaps/col3-assemble/CB4             ),
    .p14 ( \/tilemaps/col3-assemble/CPC0            ),
    .p15 ( \/lut-assembly/layer-draw-order/COL3-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/COL3-D10 ),
    .p17 ( \/tilemaps/col3-assemble/CPC1            ),
    .p18 ( \/tilemaps/col3-assemble/CDEN            ),
    .p19 ( \/lut-assembly/layer-draw-order/COL3-D11 )
);

capcom_dl0921_M367C tilemaps_col3_assemble_UAK116 (
    .p1  ( \/tilemaps/col3-assemble/~DEBUG ),
    .p2  ( \/tilemaps/col3-assemble/GFX-A  ),
    .p3  ( \/tilemaps/col3-assemble/GFX-B  ),
    .p4  ( \/tilemaps/col3-assemble/GFX-C  ),
    .p5  ( \/tilemaps/col3-assemble/GFX-D  ),
    .p15 ( \/debug/td-io/IN11              ),
    .p16 ( \/debug/td-io/IN10              ),
    .p17 ( \/debug/td-io/IN9               ),
    .p18 ( \/debug/td-io/IN8               )
);

capcom_dl0921_M541C tilemaps_col3_assemble_UAK81 (
    .p1  ( \/tilemaps/col3-assemble/~DEBUG          ),
    .p2  ( \/lut-assembly/layer-draw-order/COL3-D4  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL3-D5  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL3-D6  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL3-D7  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL3-D8  ),
    .p7  ( \/lut-assembly/layer-draw-order/COL3-D9  ),
    .p8  ( \/lut-assembly/layer-draw-order/COL3-D10 ),
    .p9  ( \/lut-assembly/layer-draw-order/COL3-D11 ),
    .p11 ( \/debug/td-io/IN7                        ),
    .p12 ( \/debug/td-io/IN6                        ),
    .p13 ( \/debug/td-io/IN5                        ),
    .p14 ( \/debug/td-io/IN4                        ),
    .p15 ( \/debug/td-io/IN3                        ),
    .p16 ( \/debug/td-io/IN2                        ),
    .p17 ( \/debug/td-io/IN1                        ),
    .p18 ( \/debug/td-io/IN0                        )
);

capcom_dl0921_NAND02 tilemaps_col3_assemble_UAN91 (
    .p1 ( \/lut-assembly/lut-storage/CLK      ),
    .p2 ( \/tilemaps/col3-assemble/SERIAL-END ),
    .p3 ( \N$/tilemaps/col3-assemble|w13      )
);

capcom_dl0921_OR02 tilemaps_col3_assemble_UBH39 (
    .p1 ( \/tilemaps/col3-assemble/~COL3-E        ),
    .p2 ( \/tilemaps/col3-assemble/GFX-A          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL3-D0 )
);

capcom_dl0921_OR02 tilemaps_col3_assemble_UBH42 (
    .p1 ( \/tilemaps/col3-assemble/~COL3-E        ),
    .p2 ( \/tilemaps/col3-assemble/GFX-B          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL3-D1 )
);

capcom_dl0921_OR02 tilemaps_col3_assemble_UBH44 (
    .p1 ( \/tilemaps/col3-assemble/~COL3-E        ),
    .p2 ( \/tilemaps/col3-assemble/GFX-C          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL3-D2 )
);

capcom_dl0921_OR02 tilemaps_col3_assemble_UBH46 (
    .p1 ( \/tilemaps/col3-assemble/~COL3-E        ),
    .p2 ( \/tilemaps/col3-assemble/GFX-D          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL3-D3 )
);

//========================================================================
// tilemaps/col4-assemble:
//========================================================================
capcom_dl0921_M273C tilemaps_col4_assemble_UAS287 (
    .p1  ( VCC                                      ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D4  ),
    .p3  ( \/tilemaps/col4-assemble/CB0             ),
    .p4  ( \/tilemaps/col4-assemble/CB1             ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D5  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D6  ),
    .p7  ( \/tilemaps/col4-assemble/CB2             ),
    .p8  ( \/tilemaps/col4-assemble/CB3             ),
    .p9  ( \/lut-assembly/layer-draw-order/COL4-D7  ),
    .p11 ( \N$/tilemaps/col4-assemble|w13           ),
    .p12 ( \/lut-assembly/layer-draw-order/COL4-D8  ),
    .p13 ( \/tilemaps/col4-assemble/CB4             ),
    .p14 ( \/tilemaps/col4-assemble/CPC0            ),
    .p15 ( \/lut-assembly/layer-draw-order/COL4-D9  ),
    .p16 ( \/lut-assembly/layer-draw-order/COL4-D10 ),
    .p17 ( \/tilemaps/col4-assemble/CPC1            ),
    .p18 ( \/tilemaps/col4-assemble/CDEN            ),
    .p19 ( \/lut-assembly/layer-draw-order/COL4-D11 )
);

capcom_dl0921_M367C tilemaps_col4_assemble_UAT290 (
    .p1  ( \/tilemaps/col4-assemble/~DEBUG ),
    .p2  ( \/tilemaps/col4-assemble/GFX-A  ),
    .p3  ( \/tilemaps/col4-assemble/GFX-B  ),
    .p4  ( \/tilemaps/col4-assemble/GFX-C  ),
    .p5  ( \/tilemaps/col4-assemble/GFX-D  ),
    .p15 ( \/debug/td-io/IN11              ),
    .p16 ( \/debug/td-io/IN10              ),
    .p17 ( \/debug/td-io/IN9               ),
    .p18 ( \/debug/td-io/IN8               )
);

capcom_dl0921_M541C tilemaps_col4_assemble_UAT299 (
    .p1  ( \/tilemaps/col4-assemble/~DEBUG          ),
    .p2  ( \/lut-assembly/layer-draw-order/COL4-D4  ),
    .p3  ( \/lut-assembly/layer-draw-order/COL4-D5  ),
    .p4  ( \/lut-assembly/layer-draw-order/COL4-D6  ),
    .p5  ( \/lut-assembly/layer-draw-order/COL4-D7  ),
    .p6  ( \/lut-assembly/layer-draw-order/COL4-D8  ),
    .p7  ( \/lut-assembly/layer-draw-order/COL4-D9  ),
    .p8  ( \/lut-assembly/layer-draw-order/COL4-D10 ),
    .p9  ( \/lut-assembly/layer-draw-order/COL4-D11 ),
    .p11 ( \/debug/td-io/IN7                        ),
    .p12 ( \/debug/td-io/IN6                        ),
    .p13 ( \/debug/td-io/IN5                        ),
    .p14 ( \/debug/td-io/IN4                        ),
    .p15 ( \/debug/td-io/IN3                        ),
    .p16 ( \/debug/td-io/IN2                        ),
    .p17 ( \/debug/td-io/IN1                        ),
    .p18 ( \/debug/td-io/IN0                        )
);

capcom_dl0921_NAND02 tilemaps_col4_assemble_UAU327 (
    .p1 ( \/lut-assembly/lut-storage/CLK      ),
    .p2 ( \/tilemaps/col4-assemble/SERIAL-END ),
    .p3 ( \N$/tilemaps/col4-assemble|w13      )
);

capcom_dl0921_OR02 tilemaps_col4_assemble_UBH62 (
    .p1 ( \/tilemaps/col4-assemble/~COL4-E        ),
    .p2 ( \/tilemaps/col4-assemble/GFX-A          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL4-D0 )
);

capcom_dl0921_OR02 tilemaps_col4_assemble_UBH64 (
    .p1 ( \/tilemaps/col4-assemble/~COL4-E        ),
    .p2 ( \/tilemaps/col4-assemble/GFX-B          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL4-D1 )
);

capcom_dl0921_OR02 tilemaps_col4_assemble_UBH66 (
    .p1 ( \/tilemaps/col4-assemble/~COL4-E        ),
    .p2 ( \/tilemaps/col4-assemble/GFX-C          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL4-D2 )
);

capcom_dl0921_OR02 tilemaps_col4_assemble_UBH68 (
    .p1 ( \/tilemaps/col4-assemble/~COL4-E        ),
    .p2 ( \/tilemaps/col4-assemble/GFX-D          ),
    .p3 ( \/lut-assembly/layer-draw-order/COL4-D3 )
);

//========================================================================
// tilemaps/sr1-sync:
//========================================================================
capcom_dl0921_INV01 tilemaps_sr1_sync_UAX120 (
    .p1 ( \/tilemaps/sr1-sync/LOAD ),
    .p2 ( \N$/tilemaps/sr1-sync|w2 )
);

capcom_dl0921_DFFCOO tilemaps_sr1_sync_UAY102 (
    .p1 ( \/tilemaps/sr1/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr1-sync|w50      ),
    .p3 ( \N$/tilemaps/sr1-sync|w96      ),
    .p5 ( \N$/tilemaps/sr1-sync|UAY102.5 )
);

capcom_dl0921_NOR02 tilemaps_sr1_sync_UAY106 (
    .p1 ( \N$/tilemaps/sr1-sync|w96 ),
    .p2 ( \N$/tilemaps/sr1-sync|w89 ),
    .p3 ( \N$/tilemaps/sr1-sync|w98 )
);

capcom_dl0921_XNOR02 tilemaps_sr1_sync_UAY109 (
    .p1 ( \N$/tilemaps/sr1-sync|w95  ),
    .p2 ( \N$/tilemaps/sr1-sync|w98  ),
    .p3 ( \N$/tilemaps/sr1-sync|w110 )
);

capcom_dl0921_AOI22 tilemaps_sr1_sync_UAY111 (
    .p1 ( \N$/tilemaps/sr1-sync|w16  ),
    .p2 ( \N$/tilemaps/sr1-sync|w22  ),
    .p3 ( \N$/tilemaps/sr1-sync|w110 ),
    .p4 ( \/tilemaps/sr1-sync/XS1    ),
    .p5 ( \N$/tilemaps/sr1-sync|w38  )
);

capcom_dl0921_DFFCOO tilemaps_sr1_sync_UAY114 (
    .p1 ( \/tilemaps/sr1/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr1-sync|w38      ),
    .p3 ( \N$/tilemaps/sr1-sync|w95      ),
    .p5 ( \N$/tilemaps/sr1-sync|UAY114.5 )
);

capcom_dl0921_AND02 tilemaps_sr1_sync_UAY119 (
    .p1 ( \/tilemaps/sr1/~RESET     ),
    .p2 ( \N$/tilemaps/sr1-sync|w2  ),
    .p3 ( \N$/tilemaps/sr1-sync|w16 )
);

capcom_dl0921_INV01 tilemaps_sr1_sync_UAY121 (
    .p1 ( \N$/tilemaps/sr1-sync|w2       ),
    .p2 ( \N$/tilemaps/sr1-sync|UAY121.2 )
);

capcom_dl0921_AND02 tilemaps_sr1_sync_UAY122 (
    .p1 ( \/tilemaps/sr1/~RESET          ),
    .p2 ( \N$/tilemaps/sr1-sync|UAY121.2 ),
    .p3 ( \N$/tilemaps/sr1-sync|w22      )
);

capcom_dl0921_INV01 tilemaps_sr1_sync_UAY93 (
    .p1 ( VCC                        ),
    .p2 ( \N$/tilemaps/sr1-sync|w112 )
);

capcom_dl0921_NAND02 tilemaps_sr1_sync_UAY94 (
    .p1 ( VCC                       ),
    .p2 ( VCC                       ),
    .p3 ( \N$/tilemaps/sr1-sync|w89 )
);

capcom_dl0921_XOR02 tilemaps_sr1_sync_UAY96 (
    .p1 ( \N$/tilemaps/sr1-sync|w96  ),
    .p2 ( \N$/tilemaps/sr1-sync|w89  ),
    .p3 ( \N$/tilemaps/sr1-sync|w111 )
);

capcom_dl0921_AOI22 tilemaps_sr1_sync_UAY99 (
    .p1 ( \N$/tilemaps/sr1-sync|w16  ),
    .p2 ( \N$/tilemaps/sr1-sync|w22  ),
    .p3 ( \N$/tilemaps/sr1-sync|w111 ),
    .p4 ( \/tilemaps/sr1-sync/XS0    ),
    .p5 ( \N$/tilemaps/sr1-sync|w50  )
);

capcom_dl0921_AOI22 tilemaps_sr1_sync_UAZ103 (
    .p1 ( \N$/tilemaps/sr1-sync|w16  ),
    .p2 ( \N$/tilemaps/sr1-sync|w22  ),
    .p3 ( \N$/tilemaps/sr1-sync|w107 ),
    .p4 ( VCC                        ),
    .p5 ( \N$/tilemaps/sr1-sync|w40  )
);

capcom_dl0921_XNOR02 tilemaps_sr1_sync_UAZ105 (
    .p1 ( \N$/tilemaps/sr1-sync|w93  ),
    .p2 ( \N$/tilemaps/sr1-sync|w102 ),
    .p3 ( \N$/tilemaps/sr1-sync|w107 )
);

capcom_dl0921_NOR04 tilemaps_sr1_sync_UAZ108 (
    .p1 ( \N$/tilemaps/sr1-sync|w102 ),
    .p2 ( \N$/tilemaps/sr1-sync|w89  ),
    .p3 ( \N$/tilemaps/sr1-sync|w96  ),
    .p4 ( \N$/tilemaps/sr1-sync|w95  ),
    .p5 ( \N$/tilemaps/sr1-sync|w94  )
);

capcom_dl0921_DFFCOO tilemaps_sr1_sync_UAZ111 (
    .p1 ( \/tilemaps/sr1/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr1-sync|w39      ),
    .p3 ( \N$/tilemaps/sr1-sync|w94      ),
    .p5 ( \N$/tilemaps/sr1-sync|UAZ111.5 )
);

capcom_dl0921_AOI22 tilemaps_sr1_sync_UAZ116 (
    .p1 ( \N$/tilemaps/sr1-sync|w16  ),
    .p2 ( \N$/tilemaps/sr1-sync|w22  ),
    .p3 ( \N$/tilemaps/sr1-sync|w108 ),
    .p4 ( \/tilemaps/sr1-sync/XS2    ),
    .p5 ( \N$/tilemaps/sr1-sync|w39  )
);

capcom_dl0921_XNOR02 tilemaps_sr1_sync_UAZ118 (
    .p1 ( \N$/tilemaps/sr1-sync|w94  ),
    .p2 ( \N$/tilemaps/sr1-sync|w100 ),
    .p3 ( \N$/tilemaps/sr1-sync|w108 )
);

capcom_dl0921_NOR03 tilemaps_sr1_sync_UAZ122 (
    .p1 ( \N$/tilemaps/sr1-sync|w89  ),
    .p2 ( \N$/tilemaps/sr1-sync|w96  ),
    .p3 ( \N$/tilemaps/sr1-sync|w95  ),
    .p4 ( \N$/tilemaps/sr1-sync|w100 )
);

capcom_dl0921_NOR02 tilemaps_sr1_sync_UAZ93 (
    .p1 ( \N$/tilemaps/sr1-sync|w112          ),
    .p2 ( \N$/tilemaps/sr1-sync|w103          ),
    .p3 ( \/tilemaps/col2-assemble/SERIAL-END )
);

capcom_dl0921_OR04 tilemaps_sr1_sync_UAZ95 (
    .p1 ( \N$/tilemaps/sr1-sync|w103 ),
    .p2 ( \N$/tilemaps/sr1-sync|w93  ),
    .p3 ( \N$/tilemaps/sr1-sync|w94  ),
    .p4 ( \N$/tilemaps/sr1-sync|w95  ),
    .p5 ( \N$/tilemaps/sr1-sync|w96  )
);

capcom_dl0921_DFFCOO tilemaps_sr1_sync_UAZ98 (
    .p1 ( \/tilemaps/sr1/~CLK8M         ),
    .p2 ( \N$/tilemaps/sr1-sync|w40     ),
    .p3 ( \N$/tilemaps/sr1-sync|w93     ),
    .p5 ( \N$/tilemaps/sr1-sync|UAZ98.5 )
);

//========================================================================
// tilemaps/sr1:
//========================================================================
capcom_dl0921_MUX8GLH tilemaps_sr1_UAR1 (
    .p1  ( VCC                            ),
    .p2  ( VCC                            ),
    .p3  ( VCC                            ),
    .p4  ( VCC                            ),
    .p5  ( \N$/tilemaps/sr1|UAR1.5        ),
    .p6  ( \/tilemaps/col2-assemble/GFX-B ),
    .p7  ( VCC                            ),
    .p9  ( VCC                            ),
    .p10 ( VCC                            ),
    .p11 ( VCC                            ),
    .p12 ( VCC                            ),
    .p13 ( VCC                            ),
    .p14 ( VCC                            ),
    .p15 ( VCC                            )
);

capcom_dl0921_M273C tilemaps_sr1_UAR39 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w117 ),
    .p3  ( \/tilemaps/sr1/A      ),
    .p4  ( \N$/tilemaps/sr1|w117 ),
    .p5  ( \N$/tilemaps/sr1|w125 ),
    .p6  ( \N$/tilemaps/sr1|w133 ),
    .p7  ( \N$/tilemaps/sr1|w125 ),
    .p8  ( \N$/tilemaps/sr1|w133 ),
    .p9  ( \N$/tilemaps/sr1|w141 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w149 ),
    .p13 ( \N$/tilemaps/sr1|w141 ),
    .p14 ( \N$/tilemaps/sr1|w149 ),
    .p15 ( \N$/tilemaps/sr1|w157 ),
    .p16 ( \N$/tilemaps/sr1|w165 ),
    .p17 ( \N$/tilemaps/sr1|w157 ),
    .p18 ( \N$/tilemaps/sr1|w165 ),
    .p19 ( \N$/tilemaps/sr1|w248 )
);

capcom_dl0921_M273C tilemaps_sr1_UAS0 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w119 ),
    .p3  ( \/tilemaps/sr1/B      ),
    .p4  ( \N$/tilemaps/sr1|w119 ),
    .p5  ( \N$/tilemaps/sr1|w127 ),
    .p6  ( \N$/tilemaps/sr1|w135 ),
    .p7  ( \N$/tilemaps/sr1|w127 ),
    .p8  ( \N$/tilemaps/sr1|w135 ),
    .p9  ( \N$/tilemaps/sr1|w143 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w151 ),
    .p13 ( \N$/tilemaps/sr1|w143 ),
    .p14 ( \N$/tilemaps/sr1|w151 ),
    .p15 ( \N$/tilemaps/sr1|w159 ),
    .p16 ( \N$/tilemaps/sr1|w170 ),
    .p17 ( \N$/tilemaps/sr1|w159 ),
    .p18 ( \N$/tilemaps/sr1|w170 ),
    .p19 ( \N$/tilemaps/sr1|w250 )
);

capcom_dl0921_MUX8GLH tilemaps_sr1_UAS40 (
    .p1  ( VCC                            ),
    .p2  ( VCC                            ),
    .p3  ( VCC                            ),
    .p4  ( VCC                            ),
    .p5  ( \N$/tilemaps/sr1|UAS40.5       ),
    .p6  ( \/tilemaps/col2-assemble/GFX-A ),
    .p7  ( VCC                            ),
    .p9  ( VCC                            ),
    .p10 ( VCC                            ),
    .p11 ( VCC                            ),
    .p12 ( VCC                            ),
    .p13 ( VCC                            ),
    .p14 ( VCC                            ),
    .p15 ( VCC                            )
);

capcom_dl0921_MUX8GLH tilemaps_sr1_UAT1 (
    .p1  ( \N$/tilemaps/sr1|w407          ),
    .p2  ( \N$/tilemaps/sr1|w395          ),
    .p3  ( \N$/tilemaps/sr1|w383          ),
    .p4  ( \N$/tilemaps/sr1|w371          ),
    .p5  ( \N$/tilemaps/sr1|UAT1.5        ),
    .p6  ( \/tilemaps/col2-assemble/GFX-B ),
    .p7  ( GND                            ),
    .p9  ( \/tilemaps/sr1-sync/XS2        ),
    .p10 ( \/tilemaps/sr1-sync/XS1        ),
    .p11 ( \/tilemaps/sr1-sync/XS0        ),
    .p12 ( \N$/tilemaps/sr1|w349          ),
    .p13 ( \N$/tilemaps/sr1|w443          ),
    .p14 ( \N$/tilemaps/sr1|w431          ),
    .p15 ( \N$/tilemaps/sr1|w419          )
);

capcom_dl0921_M273C tilemaps_sr1_UAT39 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w368 ),
    .p3  ( \N$/tilemaps/sr1|w248 ),
    .p4  ( \N$/tilemaps/sr1|w368 ),
    .p5  ( \N$/tilemaps/sr1|w380 ),
    .p6  ( \N$/tilemaps/sr1|w392 ),
    .p7  ( \N$/tilemaps/sr1|w380 ),
    .p8  ( \N$/tilemaps/sr1|w392 ),
    .p9  ( \N$/tilemaps/sr1|w404 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w416 ),
    .p13 ( \N$/tilemaps/sr1|w404 ),
    .p14 ( \N$/tilemaps/sr1|w416 ),
    .p15 ( \N$/tilemaps/sr1|w428 ),
    .p16 ( \N$/tilemaps/sr1|w440 ),
    .p17 ( \N$/tilemaps/sr1|w428 ),
    .p18 ( \N$/tilemaps/sr1|w440 ),
    .p19 ( \N$/tilemaps/sr1|w341 )
);

capcom_dl0921_M273C tilemaps_sr1_UAU0 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w371 ),
    .p3  ( \N$/tilemaps/sr1|w250 ),
    .p4  ( \N$/tilemaps/sr1|w371 ),
    .p5  ( \N$/tilemaps/sr1|w383 ),
    .p6  ( \N$/tilemaps/sr1|w395 ),
    .p7  ( \N$/tilemaps/sr1|w383 ),
    .p8  ( \N$/tilemaps/sr1|w395 ),
    .p9  ( \N$/tilemaps/sr1|w407 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w419 ),
    .p13 ( \N$/tilemaps/sr1|w407 ),
    .p14 ( \N$/tilemaps/sr1|w419 ),
    .p15 ( \N$/tilemaps/sr1|w431 ),
    .p16 ( \N$/tilemaps/sr1|w443 ),
    .p17 ( \N$/tilemaps/sr1|w431 ),
    .p18 ( \N$/tilemaps/sr1|w443 ),
    .p19 ( \N$/tilemaps/sr1|w349 )
);

capcom_dl0921_MUX8GLH tilemaps_sr1_UAU40 (
    .p1  ( \N$/tilemaps/sr1|w404          ),
    .p2  ( \N$/tilemaps/sr1|w392          ),
    .p3  ( \N$/tilemaps/sr1|w380          ),
    .p4  ( \N$/tilemaps/sr1|w368          ),
    .p5  ( \N$/tilemaps/sr1|UAU40.5       ),
    .p6  ( \/tilemaps/col2-assemble/GFX-A ),
    .p7  ( GND                            ),
    .p9  ( \/tilemaps/sr1-sync/XS2        ),
    .p10 ( \/tilemaps/sr1-sync/XS1        ),
    .p11 ( \/tilemaps/sr1-sync/XS0        ),
    .p12 ( \N$/tilemaps/sr1|w341          ),
    .p13 ( \N$/tilemaps/sr1|w440          ),
    .p14 ( \N$/tilemaps/sr1|w428          ),
    .p15 ( \N$/tilemaps/sr1|w416          )
);

capcom_dl0921_MUX8GLH tilemaps_sr1_UAV1 (
    .p1  ( VCC                            ),
    .p2  ( VCC                            ),
    .p3  ( VCC                            ),
    .p4  ( VCC                            ),
    .p5  ( \N$/tilemaps/sr1|UAV1.5        ),
    .p6  ( \/tilemaps/col2-assemble/GFX-D ),
    .p7  ( VCC                            ),
    .p9  ( VCC                            ),
    .p10 ( VCC                            ),
    .p11 ( VCC                            ),
    .p12 ( VCC                            ),
    .p13 ( VCC                            ),
    .p14 ( VCC                            ),
    .p15 ( VCC                            )
);

capcom_dl0921_M273C tilemaps_sr1_UAV39 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w121 ),
    .p3  ( \/tilemaps/sr1/C      ),
    .p4  ( \N$/tilemaps/sr1|w121 ),
    .p5  ( \N$/tilemaps/sr1|w129 ),
    .p6  ( \N$/tilemaps/sr1|w137 ),
    .p7  ( \N$/tilemaps/sr1|w129 ),
    .p8  ( \N$/tilemaps/sr1|w137 ),
    .p9  ( \N$/tilemaps/sr1|w145 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w153 ),
    .p13 ( \N$/tilemaps/sr1|w145 ),
    .p14 ( \N$/tilemaps/sr1|w153 ),
    .p15 ( \N$/tilemaps/sr1|w161 ),
    .p16 ( \N$/tilemaps/sr1|w175 ),
    .p17 ( \N$/tilemaps/sr1|w161 ),
    .p18 ( \N$/tilemaps/sr1|w175 ),
    .p19 ( \N$/tilemaps/sr1|w252 )
);

capcom_dl0921_BUF12 tilemaps_sr1_UAV87 (
    .p1 ( \/tilemaps/sr1/XS0      ),
    .p2 ( \/tilemaps/sr1-sync/XS0 )
);

capcom_dl0921_BUF12 tilemaps_sr1_UAV92 (
    .p1 ( \/tilemaps/sr1/XS1      ),
    .p2 ( \/tilemaps/sr1-sync/XS1 )
);

capcom_dl0921_BUF12 tilemaps_sr1_UAV96 (
    .p1 ( \/tilemaps/sr1/XS2      ),
    .p2 ( \/tilemaps/sr1-sync/XS2 )
);

capcom_dl0921_M273C tilemaps_sr1_UAX0 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w123 ),
    .p3  ( \/tilemaps/sr1/D      ),
    .p4  ( \N$/tilemaps/sr1|w123 ),
    .p5  ( \N$/tilemaps/sr1|w131 ),
    .p6  ( \N$/tilemaps/sr1|w139 ),
    .p7  ( \N$/tilemaps/sr1|w131 ),
    .p8  ( \N$/tilemaps/sr1|w139 ),
    .p9  ( \N$/tilemaps/sr1|w147 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w155 ),
    .p13 ( \N$/tilemaps/sr1|w147 ),
    .p14 ( \N$/tilemaps/sr1|w155 ),
    .p15 ( \N$/tilemaps/sr1|w163 ),
    .p16 ( \N$/tilemaps/sr1|w180 ),
    .p17 ( \N$/tilemaps/sr1|w163 ),
    .p18 ( \N$/tilemaps/sr1|w180 ),
    .p19 ( \N$/tilemaps/sr1|w254 )
);

capcom_dl0921_MUX8GLH tilemaps_sr1_UAX40 (
    .p1  ( VCC                            ),
    .p2  ( VCC                            ),
    .p3  ( VCC                            ),
    .p4  ( VCC                            ),
    .p5  ( \N$/tilemaps/sr1|UAX40.5       ),
    .p6  ( \/tilemaps/col2-assemble/GFX-C ),
    .p7  ( VCC                            ),
    .p9  ( VCC                            ),
    .p10 ( VCC                            ),
    .p11 ( VCC                            ),
    .p12 ( VCC                            ),
    .p13 ( VCC                            ),
    .p14 ( VCC                            ),
    .p15 ( VCC                            )
);

capcom_dl0921_MUX8GLH tilemaps_sr1_UAY1 (
    .p1  ( \N$/tilemaps/sr1|w413          ),
    .p2  ( \N$/tilemaps/sr1|w401          ),
    .p3  ( \N$/tilemaps/sr1|w389          ),
    .p4  ( \N$/tilemaps/sr1|w377          ),
    .p5  ( \N$/tilemaps/sr1|UAY1.5        ),
    .p6  ( \/tilemaps/col2-assemble/GFX-D ),
    .p7  ( GND                            ),
    .p9  ( \/tilemaps/sr1-sync/XS2        ),
    .p10 ( \/tilemaps/sr1-sync/XS1        ),
    .p11 ( \/tilemaps/sr1-sync/XS0        ),
    .p12 ( \N$/tilemaps/sr1|w365          ),
    .p13 ( \N$/tilemaps/sr1|w449          ),
    .p14 ( \N$/tilemaps/sr1|w437          ),
    .p15 ( \N$/tilemaps/sr1|w425          )
);

capcom_dl0921_M273C tilemaps_sr1_UAY39 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w374 ),
    .p3  ( \N$/tilemaps/sr1|w252 ),
    .p4  ( \N$/tilemaps/sr1|w374 ),
    .p5  ( \N$/tilemaps/sr1|w386 ),
    .p6  ( \N$/tilemaps/sr1|w398 ),
    .p7  ( \N$/tilemaps/sr1|w386 ),
    .p8  ( \N$/tilemaps/sr1|w398 ),
    .p9  ( \N$/tilemaps/sr1|w410 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w422 ),
    .p13 ( \N$/tilemaps/sr1|w410 ),
    .p14 ( \N$/tilemaps/sr1|w422 ),
    .p15 ( \N$/tilemaps/sr1|w434 ),
    .p16 ( \N$/tilemaps/sr1|w446 ),
    .p17 ( \N$/tilemaps/sr1|w434 ),
    .p18 ( \N$/tilemaps/sr1|w446 ),
    .p19 ( \N$/tilemaps/sr1|w357 )
);

capcom_dl0921_M273C tilemaps_sr1_UAZ0 (
    .p1  ( \/tilemaps/sr1/~RESET ),
    .p2  ( \N$/tilemaps/sr1|w377 ),
    .p3  ( \N$/tilemaps/sr1|w254 ),
    .p4  ( \N$/tilemaps/sr1|w377 ),
    .p5  ( \N$/tilemaps/sr1|w389 ),
    .p6  ( \N$/tilemaps/sr1|w401 ),
    .p7  ( \N$/tilemaps/sr1|w389 ),
    .p8  ( \N$/tilemaps/sr1|w401 ),
    .p9  ( \N$/tilemaps/sr1|w413 ),
    .p11 ( \/tilemaps/sr1/~CLK8M ),
    .p12 ( \N$/tilemaps/sr1|w425 ),
    .p13 ( \N$/tilemaps/sr1|w413 ),
    .p14 ( \N$/tilemaps/sr1|w425 ),
    .p15 ( \N$/tilemaps/sr1|w437 ),
    .p16 ( \N$/tilemaps/sr1|w449 ),
    .p17 ( \N$/tilemaps/sr1|w437 ),
    .p18 ( \N$/tilemaps/sr1|w449 ),
    .p19 ( \N$/tilemaps/sr1|w365 )
);

capcom_dl0921_MUX8GLH tilemaps_sr1_UAZ40 (
    .p1  ( \N$/tilemaps/sr1|w410          ),
    .p2  ( \N$/tilemaps/sr1|w398          ),
    .p3  ( \N$/tilemaps/sr1|w386          ),
    .p4  ( \N$/tilemaps/sr1|w374          ),
    .p5  ( \N$/tilemaps/sr1|UAZ40.5       ),
    .p6  ( \/tilemaps/col2-assemble/GFX-C ),
    .p7  ( GND                            ),
    .p9  ( \/tilemaps/sr1-sync/XS2        ),
    .p10 ( \/tilemaps/sr1-sync/XS1        ),
    .p11 ( \/tilemaps/sr1-sync/XS0        ),
    .p12 ( \N$/tilemaps/sr1|w357          ),
    .p13 ( \N$/tilemaps/sr1|w446          ),
    .p14 ( \N$/tilemaps/sr1|w434          ),
    .p15 ( \N$/tilemaps/sr1|w422          )
);

//========================================================================
// tilemaps/sr2-sync:
//========================================================================
capcom_dl0921_DFFCOO tilemaps_sr2_sync_UAL102 (
    .p1 ( \/tilemaps/sr2/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr2-sync|w51      ),
    .p3 ( \N$/tilemaps/sr2-sync|w97      ),
    .p5 ( \N$/tilemaps/sr2-sync|UAL102.5 )
);

capcom_dl0921_NOR02 tilemaps_sr2_sync_UAL106 (
    .p1 ( \N$/tilemaps/sr2-sync|w97 ),
    .p2 ( \N$/tilemaps/sr2-sync|w90 ),
    .p3 ( \N$/tilemaps/sr2-sync|w99 )
);

capcom_dl0921_XNOR02 tilemaps_sr2_sync_UAL109 (
    .p1 ( \N$/tilemaps/sr2-sync|w96  ),
    .p2 ( \N$/tilemaps/sr2-sync|w99  ),
    .p3 ( \N$/tilemaps/sr2-sync|w111 )
);

capcom_dl0921_AOI22 tilemaps_sr2_sync_UAL111 (
    .p1 ( \N$/tilemaps/sr2-sync|w17  ),
    .p2 ( \N$/tilemaps/sr2-sync|w23  ),
    .p3 ( \N$/tilemaps/sr2-sync|w111 ),
    .p4 ( \/tilemaps/sr2-sync/XS1    ),
    .p5 ( \N$/tilemaps/sr2-sync|w39  )
);

capcom_dl0921_DFFCOO tilemaps_sr2_sync_UAL114 (
    .p1 ( \/tilemaps/sr2/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr2-sync|w39      ),
    .p3 ( \N$/tilemaps/sr2-sync|w96      ),
    .p5 ( \N$/tilemaps/sr2-sync|UAL114.5 )
);

capcom_dl0921_AND02 tilemaps_sr2_sync_UAL119 (
    .p1 ( \/tilemaps/sr2/~RESET     ),
    .p2 ( \/tilemaps/sr3-sync/~LOAD ),
    .p3 ( \N$/tilemaps/sr2-sync|w17 )
);

capcom_dl0921_INV01 tilemaps_sr2_sync_UAL121 (
    .p1 ( \/tilemaps/sr3-sync/~LOAD      ),
    .p2 ( \N$/tilemaps/sr2-sync|UAL121.2 )
);

capcom_dl0921_AND02 tilemaps_sr2_sync_UAL122 (
    .p1 ( \/tilemaps/sr2/~RESET          ),
    .p2 ( \N$/tilemaps/sr2-sync|UAL121.2 ),
    .p3 ( \N$/tilemaps/sr2-sync|w23      )
);

capcom_dl0921_INV01 tilemaps_sr2_sync_UAL93 (
    .p1 ( VCC                        ),
    .p2 ( \N$/tilemaps/sr2-sync|w113 )
);

capcom_dl0921_NAND02 tilemaps_sr2_sync_UAL94 (
    .p1 ( VCC                       ),
    .p2 ( VCC                       ),
    .p3 ( \N$/tilemaps/sr2-sync|w90 )
);

capcom_dl0921_XOR02 tilemaps_sr2_sync_UAL96 (
    .p1 ( \N$/tilemaps/sr2-sync|w97  ),
    .p2 ( \N$/tilemaps/sr2-sync|w90  ),
    .p3 ( \N$/tilemaps/sr2-sync|w112 )
);

capcom_dl0921_AOI22 tilemaps_sr2_sync_UAL99 (
    .p1 ( \N$/tilemaps/sr2-sync|w17  ),
    .p2 ( \N$/tilemaps/sr2-sync|w23  ),
    .p3 ( \N$/tilemaps/sr2-sync|w112 ),
    .p4 ( \/tilemaps/sr2-sync/XS0    ),
    .p5 ( \N$/tilemaps/sr2-sync|w51  )
);

capcom_dl0921_AOI22 tilemaps_sr2_sync_UAN103 (
    .p1 ( \N$/tilemaps/sr2-sync|w17  ),
    .p2 ( \N$/tilemaps/sr2-sync|w23  ),
    .p3 ( \N$/tilemaps/sr2-sync|w108 ),
    .p4 ( \/tilemaps/sr2-sync/XS3    ),
    .p5 ( \N$/tilemaps/sr2-sync|w41  )
);

capcom_dl0921_XNOR02 tilemaps_sr2_sync_UAN105 (
    .p1 ( \N$/tilemaps/sr2-sync|w94  ),
    .p2 ( \N$/tilemaps/sr2-sync|w103 ),
    .p3 ( \N$/tilemaps/sr2-sync|w108 )
);

capcom_dl0921_NOR04 tilemaps_sr2_sync_UAN108 (
    .p1 ( \N$/tilemaps/sr2-sync|w103 ),
    .p2 ( \N$/tilemaps/sr2-sync|w90  ),
    .p3 ( \N$/tilemaps/sr2-sync|w97  ),
    .p4 ( \N$/tilemaps/sr2-sync|w96  ),
    .p5 ( \N$/tilemaps/sr2-sync|w95  )
);

capcom_dl0921_DFFCOO tilemaps_sr2_sync_UAN111 (
    .p1 ( \/tilemaps/sr2/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr2-sync|w40      ),
    .p3 ( \N$/tilemaps/sr2-sync|w95      ),
    .p5 ( \N$/tilemaps/sr2-sync|UAN111.5 )
);

capcom_dl0921_AOI22 tilemaps_sr2_sync_UAN116 (
    .p1 ( \N$/tilemaps/sr2-sync|w17  ),
    .p2 ( \N$/tilemaps/sr2-sync|w23  ),
    .p3 ( \N$/tilemaps/sr2-sync|w109 ),
    .p4 ( \/tilemaps/sr2-sync/XS2    ),
    .p5 ( \N$/tilemaps/sr2-sync|w40  )
);

capcom_dl0921_XNOR02 tilemaps_sr2_sync_UAN118 (
    .p1 ( \N$/tilemaps/sr2-sync|w95  ),
    .p2 ( \N$/tilemaps/sr2-sync|w101 ),
    .p3 ( \N$/tilemaps/sr2-sync|w109 )
);

capcom_dl0921_NOR03 tilemaps_sr2_sync_UAN122 (
    .p1 ( \N$/tilemaps/sr2-sync|w90  ),
    .p2 ( \N$/tilemaps/sr2-sync|w97  ),
    .p3 ( \N$/tilemaps/sr2-sync|w96  ),
    .p4 ( \N$/tilemaps/sr2-sync|w101 )
);

capcom_dl0921_NOR02 tilemaps_sr2_sync_UAN93 (
    .p1 ( \N$/tilemaps/sr2-sync|w113          ),
    .p2 ( \N$/tilemaps/sr2-sync|w104          ),
    .p3 ( \/tilemaps/col3-assemble/SERIAL-END )
);

capcom_dl0921_OR04 tilemaps_sr2_sync_UAN95 (
    .p1 ( \N$/tilemaps/sr2-sync|w104 ),
    .p2 ( \N$/tilemaps/sr2-sync|w94  ),
    .p3 ( \N$/tilemaps/sr2-sync|w95  ),
    .p4 ( \N$/tilemaps/sr2-sync|w96  ),
    .p5 ( \N$/tilemaps/sr2-sync|w97  )
);

capcom_dl0921_DFFCOO tilemaps_sr2_sync_UAN98 (
    .p1 ( \/tilemaps/sr2/~CLK8M         ),
    .p2 ( \N$/tilemaps/sr2-sync|w41     ),
    .p3 ( \N$/tilemaps/sr2-sync|w94     ),
    .p5 ( \N$/tilemaps/sr2-sync|UAN98.5 )
);

//========================================================================
// tilemaps/sr2:
//========================================================================
capcom_dl0921_BUF12 tilemaps_sr2_UAK103 (
    .p1 ( \/tilemaps/sr2/XS3    ),
    .p2 ( \N$/tilemaps/sr2|w493 )
);

capcom_dl0921_NBUF02 tilemaps_sr2_UAK107 (
    .p1 ( \/tilemaps/sr2/XS3    ),
    .p2 ( \N$/tilemaps/sr2|w261 )
);

capcom_dl0921_BUF12 tilemaps_sr2_UAK90 (
    .p1 ( \/tilemaps/sr2/XS0    ),
    .p2 ( \N$/tilemaps/sr2|w503 )
);

capcom_dl0921_BUF12 tilemaps_sr2_UAK94 (
    .p1 ( \/tilemaps/sr2/XS1    ),
    .p2 ( \N$/tilemaps/sr2|w504 )
);

capcom_dl0921_BUF12 tilemaps_sr2_UAK99 (
    .p1 ( \/tilemaps/sr2/XS2    ),
    .p2 ( \N$/tilemaps/sr2|w505 )
);

capcom_dl0921_M273C tilemaps_sr2_UAR127 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w129 ),
    .p3  ( \/tilemaps/sr2/A      ),
    .p4  ( \N$/tilemaps/sr2|w129 ),
    .p5  ( \N$/tilemaps/sr2|w141 ),
    .p6  ( \N$/tilemaps/sr2|w153 ),
    .p7  ( \N$/tilemaps/sr2|w141 ),
    .p8  ( \N$/tilemaps/sr2|w153 ),
    .p9  ( \N$/tilemaps/sr2|w165 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w177 ),
    .p13 ( \N$/tilemaps/sr2|w165 ),
    .p14 ( \N$/tilemaps/sr2|w177 ),
    .p15 ( \N$/tilemaps/sr2|w188 ),
    .p16 ( \N$/tilemaps/sr2|w200 ),
    .p17 ( \N$/tilemaps/sr2|w188 ),
    .p18 ( \N$/tilemaps/sr2|w200 ),
    .p19 ( \N$/tilemaps/sr2|w275 )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAR167 (
    .p1  ( \N$/tilemaps/sr2|w168          ),
    .p2  ( \N$/tilemaps/sr2|w156          ),
    .p3  ( \N$/tilemaps/sr2|w144          ),
    .p4  ( \N$/tilemaps/sr2|w132          ),
    .p5  ( \N$/tilemaps/sr2|UAR167.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-B ),
    .p7  ( \N$/tilemaps/sr2|w261          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w277          ),
    .p13 ( \N$/tilemaps/sr2|w203          ),
    .p14 ( \N$/tilemaps/sr2|w191          ),
    .p15 ( \N$/tilemaps/sr2|w179          )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAS128 (
    .p1  ( \N$/tilemaps/sr2|w165          ),
    .p2  ( \N$/tilemaps/sr2|w153          ),
    .p3  ( \N$/tilemaps/sr2|w141          ),
    .p4  ( \N$/tilemaps/sr2|w129          ),
    .p5  ( \N$/tilemaps/sr2|UAS128.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-A ),
    .p7  ( \N$/tilemaps/sr2|w261          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w275          ),
    .p13 ( \N$/tilemaps/sr2|w200          ),
    .p14 ( \N$/tilemaps/sr2|w188          ),
    .p15 ( \N$/tilemaps/sr2|w177          )
);

capcom_dl0921_M273C tilemaps_sr2_UAS166 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w132 ),
    .p3  ( \/tilemaps/sr2/B      ),
    .p4  ( \N$/tilemaps/sr2|w132 ),
    .p5  ( \N$/tilemaps/sr2|w144 ),
    .p6  ( \N$/tilemaps/sr2|w156 ),
    .p7  ( \N$/tilemaps/sr2|w144 ),
    .p8  ( \N$/tilemaps/sr2|w156 ),
    .p9  ( \N$/tilemaps/sr2|w168 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w179 ),
    .p13 ( \N$/tilemaps/sr2|w168 ),
    .p14 ( \N$/tilemaps/sr2|w179 ),
    .p15 ( \N$/tilemaps/sr2|w191 ),
    .p16 ( \N$/tilemaps/sr2|w203 ),
    .p17 ( \N$/tilemaps/sr2|w191 ),
    .p18 ( \N$/tilemaps/sr2|w203 ),
    .p19 ( \N$/tilemaps/sr2|w277 )
);

capcom_dl0921_M273C tilemaps_sr2_UAT127 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w392 ),
    .p3  ( \N$/tilemaps/sr2|w275 ),
    .p4  ( \N$/tilemaps/sr2|w392 ),
    .p5  ( \N$/tilemaps/sr2|w404 ),
    .p6  ( \N$/tilemaps/sr2|w416 ),
    .p7  ( \N$/tilemaps/sr2|w404 ),
    .p8  ( \N$/tilemaps/sr2|w416 ),
    .p9  ( \N$/tilemaps/sr2|w428 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w440 ),
    .p13 ( \N$/tilemaps/sr2|w428 ),
    .p14 ( \N$/tilemaps/sr2|w440 ),
    .p15 ( \N$/tilemaps/sr2|w452 ),
    .p16 ( \N$/tilemaps/sr2|w464 ),
    .p17 ( \N$/tilemaps/sr2|w452 ),
    .p18 ( \N$/tilemaps/sr2|w464 ),
    .p19 ( \N$/tilemaps/sr2|w365 )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAT167 (
    .p1  ( \N$/tilemaps/sr2|w431          ),
    .p2  ( \N$/tilemaps/sr2|w419          ),
    .p3  ( \N$/tilemaps/sr2|w407          ),
    .p4  ( \N$/tilemaps/sr2|w395          ),
    .p5  ( \N$/tilemaps/sr2|UAT167.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-B ),
    .p7  ( \N$/tilemaps/sr2|w493          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w373          ),
    .p13 ( \N$/tilemaps/sr2|w467          ),
    .p14 ( \N$/tilemaps/sr2|w455          ),
    .p15 ( \N$/tilemaps/sr2|w443          )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAU128 (
    .p1  ( \N$/tilemaps/sr2|w428          ),
    .p2  ( \N$/tilemaps/sr2|w416          ),
    .p3  ( \N$/tilemaps/sr2|w404          ),
    .p4  ( \N$/tilemaps/sr2|w392          ),
    .p5  ( \N$/tilemaps/sr2|UAU128.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-A ),
    .p7  ( \N$/tilemaps/sr2|w493          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w365          ),
    .p13 ( \N$/tilemaps/sr2|w464          ),
    .p14 ( \N$/tilemaps/sr2|w452          ),
    .p15 ( \N$/tilemaps/sr2|w440          )
);

capcom_dl0921_M273C tilemaps_sr2_UAU166 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w395 ),
    .p3  ( \N$/tilemaps/sr2|w277 ),
    .p4  ( \N$/tilemaps/sr2|w395 ),
    .p5  ( \N$/tilemaps/sr2|w407 ),
    .p6  ( \N$/tilemaps/sr2|w419 ),
    .p7  ( \N$/tilemaps/sr2|w407 ),
    .p8  ( \N$/tilemaps/sr2|w419 ),
    .p9  ( \N$/tilemaps/sr2|w431 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w443 ),
    .p13 ( \N$/tilemaps/sr2|w431 ),
    .p14 ( \N$/tilemaps/sr2|w443 ),
    .p15 ( \N$/tilemaps/sr2|w455 ),
    .p16 ( \N$/tilemaps/sr2|w467 ),
    .p17 ( \N$/tilemaps/sr2|w455 ),
    .p18 ( \N$/tilemaps/sr2|w467 ),
    .p19 ( \N$/tilemaps/sr2|w373 )
);

capcom_dl0921_M273C tilemaps_sr2_UAV127 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w135 ),
    .p3  ( \/tilemaps/sr2/C      ),
    .p4  ( \N$/tilemaps/sr2|w135 ),
    .p5  ( \N$/tilemaps/sr2|w147 ),
    .p6  ( \N$/tilemaps/sr2|w159 ),
    .p7  ( \N$/tilemaps/sr2|w147 ),
    .p8  ( \N$/tilemaps/sr2|w159 ),
    .p9  ( \N$/tilemaps/sr2|w171 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w182 ),
    .p13 ( \N$/tilemaps/sr2|w171 ),
    .p14 ( \N$/tilemaps/sr2|w182 ),
    .p15 ( \N$/tilemaps/sr2|w194 ),
    .p16 ( \N$/tilemaps/sr2|w206 ),
    .p17 ( \N$/tilemaps/sr2|w194 ),
    .p18 ( \N$/tilemaps/sr2|w206 ),
    .p19 ( \N$/tilemaps/sr2|w279 )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAV167 (
    .p1  ( \N$/tilemaps/sr2|w174          ),
    .p2  ( \N$/tilemaps/sr2|w162          ),
    .p3  ( \N$/tilemaps/sr2|w150          ),
    .p4  ( \N$/tilemaps/sr2|w138          ),
    .p5  ( \N$/tilemaps/sr2|UAV167.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-D ),
    .p7  ( \N$/tilemaps/sr2|w261          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w281          ),
    .p13 ( \N$/tilemaps/sr2|w209          ),
    .p14 ( \N$/tilemaps/sr2|w197          ),
    .p15 ( \N$/tilemaps/sr2|w185          )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAX128 (
    .p1  ( \N$/tilemaps/sr2|w171          ),
    .p2  ( \N$/tilemaps/sr2|w159          ),
    .p3  ( \N$/tilemaps/sr2|w147          ),
    .p4  ( \N$/tilemaps/sr2|w135          ),
    .p5  ( \N$/tilemaps/sr2|UAX128.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-C ),
    .p7  ( \N$/tilemaps/sr2|w261          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w279          ),
    .p13 ( \N$/tilemaps/sr2|w206          ),
    .p14 ( \N$/tilemaps/sr2|w194          ),
    .p15 ( \N$/tilemaps/sr2|w182          )
);

capcom_dl0921_M273C tilemaps_sr2_UAX166 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w138 ),
    .p3  ( \/tilemaps/sr2/D      ),
    .p4  ( \N$/tilemaps/sr2|w138 ),
    .p5  ( \N$/tilemaps/sr2|w150 ),
    .p6  ( \N$/tilemaps/sr2|w162 ),
    .p7  ( \N$/tilemaps/sr2|w150 ),
    .p8  ( \N$/tilemaps/sr2|w162 ),
    .p9  ( \N$/tilemaps/sr2|w174 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w185 ),
    .p13 ( \N$/tilemaps/sr2|w174 ),
    .p14 ( \N$/tilemaps/sr2|w185 ),
    .p15 ( \N$/tilemaps/sr2|w197 ),
    .p16 ( \N$/tilemaps/sr2|w209 ),
    .p17 ( \N$/tilemaps/sr2|w197 ),
    .p18 ( \N$/tilemaps/sr2|w209 ),
    .p19 ( \N$/tilemaps/sr2|w281 )
);

capcom_dl0921_M273C tilemaps_sr2_UAY127 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w398 ),
    .p3  ( \N$/tilemaps/sr2|w279 ),
    .p4  ( \N$/tilemaps/sr2|w398 ),
    .p5  ( \N$/tilemaps/sr2|w410 ),
    .p6  ( \N$/tilemaps/sr2|w422 ),
    .p7  ( \N$/tilemaps/sr2|w410 ),
    .p8  ( \N$/tilemaps/sr2|w422 ),
    .p9  ( \N$/tilemaps/sr2|w434 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w446 ),
    .p13 ( \N$/tilemaps/sr2|w434 ),
    .p14 ( \N$/tilemaps/sr2|w446 ),
    .p15 ( \N$/tilemaps/sr2|w458 ),
    .p16 ( \N$/tilemaps/sr2|w470 ),
    .p17 ( \N$/tilemaps/sr2|w458 ),
    .p18 ( \N$/tilemaps/sr2|w470 ),
    .p19 ( \N$/tilemaps/sr2|w381 )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAY167 (
    .p1  ( \N$/tilemaps/sr2|w437          ),
    .p2  ( \N$/tilemaps/sr2|w425          ),
    .p3  ( \N$/tilemaps/sr2|w413          ),
    .p4  ( \N$/tilemaps/sr2|w401          ),
    .p5  ( \N$/tilemaps/sr2|UAY167.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-D ),
    .p7  ( \N$/tilemaps/sr2|w493          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w389          ),
    .p13 ( \N$/tilemaps/sr2|w473          ),
    .p14 ( \N$/tilemaps/sr2|w461          ),
    .p15 ( \N$/tilemaps/sr2|w449          )
);

capcom_dl0921_MUX8GLH tilemaps_sr2_UAZ129 (
    .p1  ( \N$/tilemaps/sr2|w434          ),
    .p2  ( \N$/tilemaps/sr2|w422          ),
    .p3  ( \N$/tilemaps/sr2|w410          ),
    .p4  ( \N$/tilemaps/sr2|w398          ),
    .p5  ( \N$/tilemaps/sr2|UAZ129.5      ),
    .p6  ( \/tilemaps/col3-assemble/GFX-C ),
    .p7  ( \N$/tilemaps/sr2|w493          ),
    .p9  ( \N$/tilemaps/sr2|w505          ),
    .p10 ( \N$/tilemaps/sr2|w504          ),
    .p11 ( \N$/tilemaps/sr2|w503          ),
    .p12 ( \N$/tilemaps/sr2|w381          ),
    .p13 ( \N$/tilemaps/sr2|w470          ),
    .p14 ( \N$/tilemaps/sr2|w458          ),
    .p15 ( \N$/tilemaps/sr2|w446          )
);

capcom_dl0921_M273C tilemaps_sr2_UAZ166 (
    .p1  ( \/tilemaps/sr2/~RESET ),
    .p2  ( \N$/tilemaps/sr2|w401 ),
    .p3  ( \N$/tilemaps/sr2|w281 ),
    .p4  ( \N$/tilemaps/sr2|w401 ),
    .p5  ( \N$/tilemaps/sr2|w413 ),
    .p6  ( \N$/tilemaps/sr2|w425 ),
    .p7  ( \N$/tilemaps/sr2|w413 ),
    .p8  ( \N$/tilemaps/sr2|w425 ),
    .p9  ( \N$/tilemaps/sr2|w437 ),
    .p11 ( \/tilemaps/sr2/~CLK8M ),
    .p12 ( \N$/tilemaps/sr2|w449 ),
    .p13 ( \N$/tilemaps/sr2|w437 ),
    .p14 ( \N$/tilemaps/sr2|w449 ),
    .p15 ( \N$/tilemaps/sr2|w461 ),
    .p16 ( \N$/tilemaps/sr2|w473 ),
    .p17 ( \N$/tilemaps/sr2|w461 ),
    .p18 ( \N$/tilemaps/sr2|w473 ),
    .p19 ( \N$/tilemaps/sr2|w389 )
);

//========================================================================
// tilemaps/sr3-sync:
//========================================================================
capcom_dl0921_INV01 tilemaps_sr3_sync_UAT329 (
    .p1 ( VCC                        ),
    .p2 ( \N$/tilemaps/sr3-sync|w113 )
);

capcom_dl0921_NAND02 tilemaps_sr3_sync_UAT330 (
    .p1 ( VCC                       ),
    .p2 ( VCC                       ),
    .p3 ( \N$/tilemaps/sr3-sync|w90 )
);

capcom_dl0921_XOR02 tilemaps_sr3_sync_UAT332 (
    .p1 ( \N$/tilemaps/sr3-sync|w97  ),
    .p2 ( \N$/tilemaps/sr3-sync|w90  ),
    .p3 ( \N$/tilemaps/sr3-sync|w112 )
);

capcom_dl0921_AOI22 tilemaps_sr3_sync_UAT335 (
    .p1 ( \N$/tilemaps/sr3-sync|w17  ),
    .p2 ( \N$/tilemaps/sr3-sync|w23  ),
    .p3 ( \N$/tilemaps/sr3-sync|w112 ),
    .p4 ( \/XS0                      ),
    .p5 ( \N$/tilemaps/sr3-sync|w51  )
);

capcom_dl0921_DFFCOO tilemaps_sr3_sync_UAT338 (
    .p1 ( \/tilemaps/sr3/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr3-sync|w51      ),
    .p3 ( \N$/tilemaps/sr3-sync|w97      ),
    .p5 ( \N$/tilemaps/sr3-sync|UAT338.5 )
);

capcom_dl0921_NOR02 tilemaps_sr3_sync_UAT342 (
    .p1 ( \N$/tilemaps/sr3-sync|w97 ),
    .p2 ( \N$/tilemaps/sr3-sync|w90 ),
    .p3 ( \N$/tilemaps/sr3-sync|w99 )
);

capcom_dl0921_XNOR02 tilemaps_sr3_sync_UAT345 (
    .p1 ( \N$/tilemaps/sr3-sync|w96  ),
    .p2 ( \N$/tilemaps/sr3-sync|w99  ),
    .p3 ( \N$/tilemaps/sr3-sync|w111 )
);

capcom_dl0921_AOI22 tilemaps_sr3_sync_UAT347 (
    .p1 ( \N$/tilemaps/sr3-sync|w17  ),
    .p2 ( \N$/tilemaps/sr3-sync|w23  ),
    .p3 ( \N$/tilemaps/sr3-sync|w111 ),
    .p4 ( \/XS1                      ),
    .p5 ( \N$/tilemaps/sr3-sync|w39  )
);

capcom_dl0921_DFFCOO tilemaps_sr3_sync_UAT350 (
    .p1 ( \/tilemaps/sr3/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr3-sync|w39      ),
    .p3 ( \N$/tilemaps/sr3-sync|w96      ),
    .p5 ( \N$/tilemaps/sr3-sync|UAT350.5 )
);

capcom_dl0921_AND02 tilemaps_sr3_sync_UAT355 (
    .p1 ( \/tilemaps/sr3/~RESET     ),
    .p2 ( \/tilemaps/sr3-sync/~LOAD ),
    .p3 ( \N$/tilemaps/sr3-sync|w17 )
);

capcom_dl0921_INV01 tilemaps_sr3_sync_UAT357 (
    .p1 ( \/tilemaps/sr3-sync/~LOAD      ),
    .p2 ( \N$/tilemaps/sr3-sync|UAT357.2 )
);

capcom_dl0921_AND02 tilemaps_sr3_sync_UAT358 (
    .p1 ( \/tilemaps/sr3/~RESET          ),
    .p2 ( \N$/tilemaps/sr3-sync|UAT357.2 ),
    .p3 ( \N$/tilemaps/sr3-sync|w23      )
);

capcom_dl0921_NOR02 tilemaps_sr3_sync_UAU329 (
    .p1 ( \N$/tilemaps/sr3-sync|w113          ),
    .p2 ( \N$/tilemaps/sr3-sync|w104          ),
    .p3 ( \/tilemaps/col4-assemble/SERIAL-END )
);

capcom_dl0921_OR04 tilemaps_sr3_sync_UAU331 (
    .p1 ( \N$/tilemaps/sr3-sync|w104 ),
    .p2 ( \N$/tilemaps/sr3-sync|w94  ),
    .p3 ( \N$/tilemaps/sr3-sync|w95  ),
    .p4 ( \N$/tilemaps/sr3-sync|w96  ),
    .p5 ( \N$/tilemaps/sr3-sync|w97  )
);

capcom_dl0921_DFFCOO tilemaps_sr3_sync_UAU334 (
    .p1 ( \/tilemaps/sr3/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr3-sync|w41      ),
    .p3 ( \N$/tilemaps/sr3-sync|w94      ),
    .p5 ( \N$/tilemaps/sr3-sync|UAU334.5 )
);

capcom_dl0921_AOI22 tilemaps_sr3_sync_UAU339 (
    .p1 ( \N$/tilemaps/sr3-sync|w17  ),
    .p2 ( \N$/tilemaps/sr3-sync|w23  ),
    .p3 ( \N$/tilemaps/sr3-sync|w108 ),
    .p4 ( \/XS3                      ),
    .p5 ( \N$/tilemaps/sr3-sync|w41  )
);

capcom_dl0921_XNOR02 tilemaps_sr3_sync_UAU341 (
    .p1 ( \N$/tilemaps/sr3-sync|w94  ),
    .p2 ( \N$/tilemaps/sr3-sync|w103 ),
    .p3 ( \N$/tilemaps/sr3-sync|w108 )
);

capcom_dl0921_NOR04 tilemaps_sr3_sync_UAU344 (
    .p1 ( \N$/tilemaps/sr3-sync|w103 ),
    .p2 ( \N$/tilemaps/sr3-sync|w90  ),
    .p3 ( \N$/tilemaps/sr3-sync|w97  ),
    .p4 ( \N$/tilemaps/sr3-sync|w96  ),
    .p5 ( \N$/tilemaps/sr3-sync|w95  )
);

capcom_dl0921_DFFCOO tilemaps_sr3_sync_UAU347 (
    .p1 ( \/tilemaps/sr3/~CLK8M          ),
    .p2 ( \N$/tilemaps/sr3-sync|w40      ),
    .p3 ( \N$/tilemaps/sr3-sync|w95      ),
    .p5 ( \N$/tilemaps/sr3-sync|UAU347.5 )
);

capcom_dl0921_AOI22 tilemaps_sr3_sync_UAU352 (
    .p1 ( \N$/tilemaps/sr3-sync|w17  ),
    .p2 ( \N$/tilemaps/sr3-sync|w23  ),
    .p3 ( \N$/tilemaps/sr3-sync|w109 ),
    .p4 ( \/XS2                      ),
    .p5 ( \N$/tilemaps/sr3-sync|w40  )
);

capcom_dl0921_XNOR02 tilemaps_sr3_sync_UAU355 (
    .p1 ( \N$/tilemaps/sr3-sync|w95  ),
    .p2 ( \N$/tilemaps/sr3-sync|w101 ),
    .p3 ( \N$/tilemaps/sr3-sync|w109 )
);

capcom_dl0921_NOR03 tilemaps_sr3_sync_UAU358 (
    .p1 ( \N$/tilemaps/sr3-sync|w90  ),
    .p2 ( \N$/tilemaps/sr3-sync|w97  ),
    .p3 ( \N$/tilemaps/sr3-sync|w96  ),
    .p4 ( \N$/tilemaps/sr3-sync|w101 )
);

//========================================================================
// tilemaps/sr3:
//========================================================================
capcom_dl0921_MUX8GLH tilemaps_sr3_UAR208 (
    .p1  ( \N$/tilemaps/sr3|w168          ),
    .p2  ( \N$/tilemaps/sr3|w156          ),
    .p3  ( \N$/tilemaps/sr3|w144          ),
    .p4  ( \N$/tilemaps/sr3|w132          ),
    .p5  ( \N$/tilemaps/sr3|UAR208.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-B ),
    .p7  ( \N$/tilemaps/sr3|w261          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w277          ),
    .p13 ( \N$/tilemaps/sr3|w203          ),
    .p14 ( \N$/tilemaps/sr3|w191          ),
    .p15 ( \N$/tilemaps/sr3|w179          )
);

capcom_dl0921_M273C tilemaps_sr3_UAR246 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w129 ),
    .p3  ( \/tilemaps/sr3/A      ),
    .p4  ( \N$/tilemaps/sr3|w129 ),
    .p5  ( \N$/tilemaps/sr3|w141 ),
    .p6  ( \N$/tilemaps/sr3|w153 ),
    .p7  ( \N$/tilemaps/sr3|w141 ),
    .p8  ( \N$/tilemaps/sr3|w153 ),
    .p9  ( \N$/tilemaps/sr3|w165 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w177 ),
    .p13 ( \N$/tilemaps/sr3|w165 ),
    .p14 ( \N$/tilemaps/sr3|w177 ),
    .p15 ( \N$/tilemaps/sr3|w188 ),
    .p16 ( \N$/tilemaps/sr3|w200 ),
    .p17 ( \N$/tilemaps/sr3|w188 ),
    .p18 ( \N$/tilemaps/sr3|w200 ),
    .p19 ( \N$/tilemaps/sr3|w275 )
);

capcom_dl0921_M273C tilemaps_sr3_UAS207 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w132 ),
    .p3  ( \/tilemaps/sr3/B      ),
    .p4  ( \N$/tilemaps/sr3|w132 ),
    .p5  ( \N$/tilemaps/sr3|w144 ),
    .p6  ( \N$/tilemaps/sr3|w156 ),
    .p7  ( \N$/tilemaps/sr3|w144 ),
    .p8  ( \N$/tilemaps/sr3|w156 ),
    .p9  ( \N$/tilemaps/sr3|w168 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w179 ),
    .p13 ( \N$/tilemaps/sr3|w168 ),
    .p14 ( \N$/tilemaps/sr3|w179 ),
    .p15 ( \N$/tilemaps/sr3|w191 ),
    .p16 ( \N$/tilemaps/sr3|w203 ),
    .p17 ( \N$/tilemaps/sr3|w191 ),
    .p18 ( \N$/tilemaps/sr3|w203 ),
    .p19 ( \N$/tilemaps/sr3|w277 )
);

capcom_dl0921_MUX8GLH tilemaps_sr3_UAS247 (
    .p1  ( \N$/tilemaps/sr3|w165          ),
    .p2  ( \N$/tilemaps/sr3|w153          ),
    .p3  ( \N$/tilemaps/sr3|w141          ),
    .p4  ( \N$/tilemaps/sr3|w129          ),
    .p5  ( \N$/tilemaps/sr3|UAS247.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-A ),
    .p7  ( \N$/tilemaps/sr3|w261          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w275          ),
    .p13 ( \N$/tilemaps/sr3|w200          ),
    .p14 ( \N$/tilemaps/sr3|w188          ),
    .p15 ( \N$/tilemaps/sr3|w177          )
);

capcom_dl0921_MUX8GLH tilemaps_sr3_UAT208 (
    .p1  ( \N$/tilemaps/sr3|w430          ),
    .p2  ( \N$/tilemaps/sr3|w418          ),
    .p3  ( \N$/tilemaps/sr3|w406          ),
    .p4  ( \N$/tilemaps/sr3|w394          ),
    .p5  ( \N$/tilemaps/sr3|UAT208.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-B ),
    .p7  ( \N$/tilemaps/sr3|w492          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w372          ),
    .p13 ( \N$/tilemaps/sr3|w466          ),
    .p14 ( \N$/tilemaps/sr3|w454          ),
    .p15 ( \N$/tilemaps/sr3|w442          )
);

capcom_dl0921_M273C tilemaps_sr3_UAT246 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w391 ),
    .p3  ( \N$/tilemaps/sr3|w275 ),
    .p4  ( \N$/tilemaps/sr3|w391 ),
    .p5  ( \N$/tilemaps/sr3|w403 ),
    .p6  ( \N$/tilemaps/sr3|w415 ),
    .p7  ( \N$/tilemaps/sr3|w403 ),
    .p8  ( \N$/tilemaps/sr3|w415 ),
    .p9  ( \N$/tilemaps/sr3|w427 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w439 ),
    .p13 ( \N$/tilemaps/sr3|w427 ),
    .p14 ( \N$/tilemaps/sr3|w439 ),
    .p15 ( \N$/tilemaps/sr3|w451 ),
    .p16 ( \N$/tilemaps/sr3|w463 ),
    .p17 ( \N$/tilemaps/sr3|w451 ),
    .p18 ( \N$/tilemaps/sr3|w463 ),
    .p19 ( \N$/tilemaps/sr3|w364 )
);

capcom_dl0921_M273C tilemaps_sr3_UAU207 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w394 ),
    .p3  ( \N$/tilemaps/sr3|w277 ),
    .p4  ( \N$/tilemaps/sr3|w394 ),
    .p5  ( \N$/tilemaps/sr3|w406 ),
    .p6  ( \N$/tilemaps/sr3|w418 ),
    .p7  ( \N$/tilemaps/sr3|w406 ),
    .p8  ( \N$/tilemaps/sr3|w418 ),
    .p9  ( \N$/tilemaps/sr3|w430 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w442 ),
    .p13 ( \N$/tilemaps/sr3|w430 ),
    .p14 ( \N$/tilemaps/sr3|w442 ),
    .p15 ( \N$/tilemaps/sr3|w454 ),
    .p16 ( \N$/tilemaps/sr3|w466 ),
    .p17 ( \N$/tilemaps/sr3|w454 ),
    .p18 ( \N$/tilemaps/sr3|w466 ),
    .p19 ( \N$/tilemaps/sr3|w372 )
);

capcom_dl0921_MUX8GLH tilemaps_sr3_UAU247 (
    .p1  ( \N$/tilemaps/sr3|w427          ),
    .p2  ( \N$/tilemaps/sr3|w415          ),
    .p3  ( \N$/tilemaps/sr3|w403          ),
    .p4  ( \N$/tilemaps/sr3|w391          ),
    .p5  ( \N$/tilemaps/sr3|UAU247.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-A ),
    .p7  ( \N$/tilemaps/sr3|w492          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w364          ),
    .p13 ( \N$/tilemaps/sr3|w463          ),
    .p14 ( \N$/tilemaps/sr3|w451          ),
    .p15 ( \N$/tilemaps/sr3|w439          )
);

capcom_dl0921_MUX8GLH tilemaps_sr3_UAV208 (
    .p1  ( \N$/tilemaps/sr3|w174          ),
    .p2  ( \N$/tilemaps/sr3|w162          ),
    .p3  ( \N$/tilemaps/sr3|w150          ),
    .p4  ( \N$/tilemaps/sr3|w138          ),
    .p5  ( \N$/tilemaps/sr3|UAV208.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-D ),
    .p7  ( \N$/tilemaps/sr3|w261          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w281          ),
    .p13 ( \N$/tilemaps/sr3|w209          ),
    .p14 ( \N$/tilemaps/sr3|w197          ),
    .p15 ( \N$/tilemaps/sr3|w185          )
);

capcom_dl0921_M273C tilemaps_sr3_UAV246 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w135 ),
    .p3  ( \/tilemaps/sr3/C      ),
    .p4  ( \N$/tilemaps/sr3|w135 ),
    .p5  ( \N$/tilemaps/sr3|w147 ),
    .p6  ( \N$/tilemaps/sr3|w159 ),
    .p7  ( \N$/tilemaps/sr3|w147 ),
    .p8  ( \N$/tilemaps/sr3|w159 ),
    .p9  ( \N$/tilemaps/sr3|w171 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w182 ),
    .p13 ( \N$/tilemaps/sr3|w171 ),
    .p14 ( \N$/tilemaps/sr3|w182 ),
    .p15 ( \N$/tilemaps/sr3|w194 ),
    .p16 ( \N$/tilemaps/sr3|w206 ),
    .p17 ( \N$/tilemaps/sr3|w194 ),
    .p18 ( \N$/tilemaps/sr3|w206 ),
    .p19 ( \N$/tilemaps/sr3|w279 )
);

capcom_dl0921_BUF12 tilemaps_sr3_UAV294 (
    .p1 ( \/tilemaps/sr3/XS0    ),
    .p2 ( \N$/tilemaps/sr3|w502 )
);

capcom_dl0921_BUF12 tilemaps_sr3_UAV298 (
    .p1 ( \/tilemaps/sr3/XS1    ),
    .p2 ( \N$/tilemaps/sr3|w503 )
);

capcom_dl0921_BUF12 tilemaps_sr3_UAV303 (
    .p1 ( \/tilemaps/sr3/XS2    ),
    .p2 ( \N$/tilemaps/sr3|w504 )
);

capcom_dl0921_BUF12 tilemaps_sr3_UAV306 (
    .p1 ( \/tilemaps/sr3/XS3    ),
    .p2 ( \N$/tilemaps/sr3|w492 )
);

capcom_dl0921_NBUF02 tilemaps_sr3_UAV308 (
    .p1 ( \/tilemaps/sr3/XS3    ),
    .p2 ( \N$/tilemaps/sr3|w261 )
);

capcom_dl0921_M273C tilemaps_sr3_UAX207 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w138 ),
    .p3  ( \/tilemaps/sr3/D      ),
    .p4  ( \N$/tilemaps/sr3|w138 ),
    .p5  ( \N$/tilemaps/sr3|w150 ),
    .p6  ( \N$/tilemaps/sr3|w162 ),
    .p7  ( \N$/tilemaps/sr3|w150 ),
    .p8  ( \N$/tilemaps/sr3|w162 ),
    .p9  ( \N$/tilemaps/sr3|w174 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w185 ),
    .p13 ( \N$/tilemaps/sr3|w174 ),
    .p14 ( \N$/tilemaps/sr3|w185 ),
    .p15 ( \N$/tilemaps/sr3|w197 ),
    .p16 ( \N$/tilemaps/sr3|w209 ),
    .p17 ( \N$/tilemaps/sr3|w197 ),
    .p18 ( \N$/tilemaps/sr3|w209 ),
    .p19 ( \N$/tilemaps/sr3|w281 )
);

capcom_dl0921_MUX8GLH tilemaps_sr3_UAX247 (
    .p1  ( \N$/tilemaps/sr3|w171          ),
    .p2  ( \N$/tilemaps/sr3|w159          ),
    .p3  ( \N$/tilemaps/sr3|w147          ),
    .p4  ( \N$/tilemaps/sr3|w135          ),
    .p5  ( \N$/tilemaps/sr3|UAX247.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-C ),
    .p7  ( \N$/tilemaps/sr3|w261          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w279          ),
    .p13 ( \N$/tilemaps/sr3|w206          ),
    .p14 ( \N$/tilemaps/sr3|w194          ),
    .p15 ( \N$/tilemaps/sr3|w182          )
);

capcom_dl0921_MUX8GLH tilemaps_sr3_UAY208 (
    .p1  ( \N$/tilemaps/sr3|w436          ),
    .p2  ( \N$/tilemaps/sr3|w424          ),
    .p3  ( \N$/tilemaps/sr3|w412          ),
    .p4  ( \N$/tilemaps/sr3|w400          ),
    .p5  ( \N$/tilemaps/sr3|UAY208.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-D ),
    .p7  ( \N$/tilemaps/sr3|w492          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w388          ),
    .p13 ( \N$/tilemaps/sr3|w472          ),
    .p14 ( \N$/tilemaps/sr3|w460          ),
    .p15 ( \N$/tilemaps/sr3|w448          )
);

capcom_dl0921_M273C tilemaps_sr3_UAY246 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w397 ),
    .p3  ( \N$/tilemaps/sr3|w279 ),
    .p4  ( \N$/tilemaps/sr3|w397 ),
    .p5  ( \N$/tilemaps/sr3|w409 ),
    .p6  ( \N$/tilemaps/sr3|w421 ),
    .p7  ( \N$/tilemaps/sr3|w409 ),
    .p8  ( \N$/tilemaps/sr3|w421 ),
    .p9  ( \N$/tilemaps/sr3|w433 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w445 ),
    .p13 ( \N$/tilemaps/sr3|w433 ),
    .p14 ( \N$/tilemaps/sr3|w445 ),
    .p15 ( \N$/tilemaps/sr3|w457 ),
    .p16 ( \N$/tilemaps/sr3|w469 ),
    .p17 ( \N$/tilemaps/sr3|w457 ),
    .p18 ( \N$/tilemaps/sr3|w469 ),
    .p19 ( \N$/tilemaps/sr3|w380 )
);

capcom_dl0921_M273C tilemaps_sr3_UAZ207 (
    .p1  ( \/tilemaps/sr3/~RESET ),
    .p2  ( \N$/tilemaps/sr3|w400 ),
    .p3  ( \N$/tilemaps/sr3|w281 ),
    .p4  ( \N$/tilemaps/sr3|w400 ),
    .p5  ( \N$/tilemaps/sr3|w412 ),
    .p6  ( \N$/tilemaps/sr3|w424 ),
    .p7  ( \N$/tilemaps/sr3|w412 ),
    .p8  ( \N$/tilemaps/sr3|w424 ),
    .p9  ( \N$/tilemaps/sr3|w436 ),
    .p11 ( \/tilemaps/sr3/~CLK8M ),
    .p12 ( \N$/tilemaps/sr3|w448 ),
    .p13 ( \N$/tilemaps/sr3|w436 ),
    .p14 ( \N$/tilemaps/sr3|w448 ),
    .p15 ( \N$/tilemaps/sr3|w460 ),
    .p16 ( \N$/tilemaps/sr3|w472 ),
    .p17 ( \N$/tilemaps/sr3|w460 ),
    .p18 ( \N$/tilemaps/sr3|w472 ),
    .p19 ( \N$/tilemaps/sr3|w388 )
);

capcom_dl0921_MUX8GLH tilemaps_sr3_UAZ247 (
    .p1  ( \N$/tilemaps/sr3|w433          ),
    .p2  ( \N$/tilemaps/sr3|w421          ),
    .p3  ( \N$/tilemaps/sr3|w409          ),
    .p4  ( \N$/tilemaps/sr3|w397          ),
    .p5  ( \N$/tilemaps/sr3|UAZ247.5      ),
    .p6  ( \/tilemaps/col4-assemble/GFX-C ),
    .p7  ( \N$/tilemaps/sr3|w492          ),
    .p9  ( \N$/tilemaps/sr3|w504          ),
    .p10 ( \N$/tilemaps/sr3|w503          ),
    .p11 ( \N$/tilemaps/sr3|w502          ),
    .p12 ( \N$/tilemaps/sr3|w380          ),
    .p13 ( \N$/tilemaps/sr3|w469          ),
    .p14 ( \N$/tilemaps/sr3|w457          ),
    .p15 ( \N$/tilemaps/sr3|w445          )
);

//========================================================================
// tilemaps/xpd-bus1:
//========================================================================
capcom_dl0921_L8G tilemaps_xpd_bus1_UAE2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \/DPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w124    ),
    .p4  ( \/DPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w123    ),
    .p6  ( \/DPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w122    ),
    .p8  ( \/DPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w121    ),
    .p10 ( \/DPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w120    ),
    .p12 ( \/DPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w119    ),
    .p14 ( \/DPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w118    ),
    .p16 ( \/DPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w117    ),
    .p18 ( GND                           )
);

capcom_dl0921_NAND03 tilemaps_xpd_bus1_UAE38 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/xpd-bus1/GFX-LOAD   ),
    .p3 ( \/bus-signal-control/GFX-CHNL  ),
    .p4 ( \/tilemaps/cb-bus1/LOAD-CHNLA  )
);

capcom_dl0921_L8G tilemaps_xpd_bus1_UAE41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \/CPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w156    ),
    .p4  ( \/CPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w155    ),
    .p6  ( \/CPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w154    ),
    .p8  ( \/CPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w153    ),
    .p10 ( \/CPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w152    ),
    .p12 ( \/CPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w151    ),
    .p14 ( \/CPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w150    ),
    .p16 ( \/CPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w149    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAF1 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr1/~CLK8M          )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAF2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \N$/tilemaps/xpd-bus1|w124    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w338    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w123    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w328    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w122    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w318    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w121    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w308    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w120    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w296    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w119    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w284    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w118    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w274    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w117    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w264    ),
    .p18 ( \N$/tilemaps/xpd-bus1|w208    )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAF41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \N$/tilemaps/xpd-bus1|w156    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w344    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w155    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w332    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w154    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w324    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w153    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w312    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w152    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w302    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w151    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w288    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w150    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w280    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w149    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w268    ),
    .p18 ( \N$/tilemaps/xpd-bus1|w208    )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAG1 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr1/~CLK8M          )
);

capcom_dl0921_NAND03 tilemaps_xpd_bus1_UAG38 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/xpd-bus1/GFX-LOAD   ),
    .p3 ( \N$/tilemaps/xpd-bus1|UAG40.2  ),
    .p4 ( \/tilemaps/cb-bus1/LOAD-CHNLB  )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAG40 (
    .p1 ( \/bus-signal-control/GFX-CHNL ),
    .p2 ( \N$/tilemaps/xpd-bus1|UAG40.2 )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAH1 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr1/~CLK8M          )
);

capcom_dl0921_L8G tilemaps_xpd_bus1_UAH2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \/DPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w132    ),
    .p4  ( \/DPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w131    ),
    .p6  ( \/DPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w130    ),
    .p8  ( \/DPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w129    ),
    .p10 ( \/DPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w128    ),
    .p12 ( \/DPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w127    ),
    .p14 ( \/DPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w126    ),
    .p16 ( \/DPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w125    ),
    .p18 ( GND                           )
);

capcom_dl0921_OR02 tilemaps_xpd_bus1_UAH38 (
    .p1 ( \/tilemaps/sr1-sync/LOAD   ),
    .p2 ( \/tilemaps/xpd-bus1/XSEL   ),
    .p3 ( \N$/tilemaps/xpd-bus1|w353 )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAH40 (
    .p1 ( \/obj-manager/SERIAL-CHNL  ),
    .p2 ( \N$/tilemaps/xpd-bus1|w208 )
);

capcom_dl0921_L8G tilemaps_xpd_bus1_UAH41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \/CPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w164    ),
    .p4  ( \/CPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w163    ),
    .p6  ( \/CPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w162    ),
    .p8  ( \/CPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w161    ),
    .p10 ( \/CPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w160    ),
    .p12 ( \/CPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w159    ),
    .p14 ( \/CPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w158    ),
    .p16 ( \/CPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w157    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAI1 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr1/~CLK8M          )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAI2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \N$/tilemaps/xpd-bus1|w132    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w338    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w131    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w328    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w130    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w318    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w129    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w308    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w128    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w296    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w127    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w284    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w126    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w274    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w125    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w264    ),
    .p18 ( \/obj-manager/SERIAL-CHNL     )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAI37 (
    .p1 ( \/tilemaps/xpd-bus1/XSEL      ),
    .p2 ( \N$/tilemaps/xpd-bus1|UAI37.2 )
);

capcom_dl0921_OR02 tilemaps_xpd_bus1_UAI39 (
    .p1 ( \/tilemaps/sr1-sync/LOAD      ),
    .p2 ( \N$/tilemaps/xpd-bus1|UAI37.2 ),
    .p3 ( \N$/tilemaps/xpd-bus1|w379    )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAI41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \N$/tilemaps/xpd-bus1|w164    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w344    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w163    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w332    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w162    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w324    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w161    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w312    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w160    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w302    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w159    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w288    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w158    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w280    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w157    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w268    ),
    .p18 ( \/obj-manager/SERIAL-CHNL     )
);

capcom_dl0921_M198C tilemaps_xpd_bus1_UAJ1 (
    .p1  ( \N$/tilemaps/xpd-bus1|w264    ),
    .p2  ( \N$/tilemaps/xpd-bus1|w274    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w284    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w296    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w308    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w318    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w328    ),
    .p8  ( VCC                           ),
    .p9  ( \N$/tilemaps/xpd-bus1|w338    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w411    ),
    .p11 ( \N$/tilemaps/xpd-bus1|UAJ1.11 ),
    .p12 ( \N$/tilemaps/xpd-bus1|UAJ1.12 ),
    .p13 ( \N$/tilemaps/xpd-bus1|UAJ1.13 ),
    .p14 ( \N$/tilemaps/xpd-bus1|UAJ1.14 ),
    .p15 ( \N$/tilemaps/xpd-bus1|UAJ1.15 ),
    .p16 ( \N$/tilemaps/xpd-bus1|UAJ1.16 ),
    .p17 ( \N$/tilemaps/xpd-bus1|w392    ),
    .p18 ( VCC                           ),
    .p19 ( \/tilemaps/sr1/~CLK8M         ),
    .p20 ( \N$/tilemaps/xpd-bus1|w379    ),
    .p21 ( \N$/tilemaps/xpd-bus1|w353    ),
    .p22 ( \/counter-fi/~RESET           )
);

capcom_dl0921_M198C tilemaps_xpd_bus1_UAJ39 (
    .p1  ( \N$/tilemaps/xpd-bus1|w268     ),
    .p2  ( \N$/tilemaps/xpd-bus1|w280     ),
    .p3  ( \N$/tilemaps/xpd-bus1|w288     ),
    .p4  ( \N$/tilemaps/xpd-bus1|w302     ),
    .p5  ( \N$/tilemaps/xpd-bus1|w312     ),
    .p6  ( \N$/tilemaps/xpd-bus1|w324     ),
    .p7  ( \N$/tilemaps/xpd-bus1|w332     ),
    .p8  ( VCC                            ),
    .p9  ( \N$/tilemaps/xpd-bus1|w344     ),
    .p10 ( \N$/tilemaps/xpd-bus1|w419     ),
    .p11 ( \N$/tilemaps/xpd-bus1|UAJ39.11 ),
    .p12 ( \N$/tilemaps/xpd-bus1|UAJ39.12 ),
    .p13 ( \N$/tilemaps/xpd-bus1|UAJ39.13 ),
    .p14 ( \N$/tilemaps/xpd-bus1|UAJ39.14 ),
    .p15 ( \N$/tilemaps/xpd-bus1|UAJ39.15 ),
    .p16 ( \N$/tilemaps/xpd-bus1|UAJ39.16 ),
    .p17 ( \N$/tilemaps/xpd-bus1|w396     ),
    .p18 ( VCC                            ),
    .p19 ( \/tilemaps/sr1/~CLK8M          ),
    .p20 ( \N$/tilemaps/xpd-bus1|w379     ),
    .p21 ( \N$/tilemaps/xpd-bus1|w353     ),
    .p22 ( \/counter-fi/~RESET            )
);

capcom_dl0921_L8G tilemaps_xpd_bus1_UAL2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \/BPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w108    ),
    .p4  ( \/BPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w107    ),
    .p6  ( \/BPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w106    ),
    .p8  ( \/BPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w105    ),
    .p10 ( \/BPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w104    ),
    .p12 ( \/BPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w103    ),
    .p14 ( \/BPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w102    ),
    .p16 ( \/BPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w101    ),
    .p18 ( GND                           )
);

capcom_dl0921_AO22 tilemaps_xpd_bus1_UAL38 (
    .p1 ( \N$/tilemaps/xpd-bus1|w421 ),
    .p2 ( \N$/tilemaps/xpd-bus1|w425 ),
    .p3 ( \N$/tilemaps/xpd-bus1|w392 ),
    .p4 ( \N$/tilemaps/xpd-bus1|w411 ),
    .p5 ( \/tilemaps/sr1/D           )
);

capcom_dl0921_L8G tilemaps_xpd_bus1_UAL41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \/APD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w140    ),
    .p4  ( \/APD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w139    ),
    .p6  ( \/APD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w138    ),
    .p8  ( \/APD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w137    ),
    .p10 ( \/APD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w136    ),
    .p12 ( \/APD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w135    ),
    .p14 ( \/APD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w134    ),
    .p16 ( \/APD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w133    ),
    .p18 ( GND                           )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAM2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \N$/tilemaps/xpd-bus1|w108    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w335    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w107    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w326    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w106    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w315    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w105    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w306    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w104    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w293    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w103    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w282    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w102    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w271    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w101    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w262    ),
    .p18 ( \N$/tilemaps/xpd-bus1|w208    )
);

capcom_dl0921_AO22 tilemaps_xpd_bus1_UAM38 (
    .p1 ( \N$/tilemaps/xpd-bus1|w421 ),
    .p2 ( \N$/tilemaps/xpd-bus1|w425 ),
    .p3 ( \N$/tilemaps/xpd-bus1|w396 ),
    .p4 ( \N$/tilemaps/xpd-bus1|w419 ),
    .p5 ( \/tilemaps/sr1/C           )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAM41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLA ),
    .p2  ( \N$/tilemaps/xpd-bus1|w140    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w341    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w139    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w330    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w138    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w321    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w137    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w310    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w136    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w299    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w135    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w286    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w134    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w277    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w133    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w266    ),
    .p18 ( \N$/tilemaps/xpd-bus1|w208    )
);

capcom_dl0921_L8G tilemaps_xpd_bus1_UAN2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \/BPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w116    ),
    .p4  ( \/BPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w115    ),
    .p6  ( \/BPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w114    ),
    .p8  ( \/BPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w113    ),
    .p10 ( \/BPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w112    ),
    .p12 ( \/BPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w111    ),
    .p14 ( \/BPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w110    ),
    .p16 ( \/BPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w109    ),
    .p18 ( GND                           )
);

capcom_dl0921_AO22 tilemaps_xpd_bus1_UAN38 (
    .p1 ( \N$/tilemaps/xpd-bus1|w421 ),
    .p2 ( \N$/tilemaps/xpd-bus1|w425 ),
    .p3 ( \N$/tilemaps/xpd-bus1|w390 ),
    .p4 ( \N$/tilemaps/xpd-bus1|w409 ),
    .p5 ( \/tilemaps/sr1/B           )
);

capcom_dl0921_L8G tilemaps_xpd_bus1_UAN41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \/APD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus1|w148    ),
    .p4  ( \/APD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus1|w147    ),
    .p6  ( \/APD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus1|w146    ),
    .p8  ( \/APD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus1|w145    ),
    .p10 ( \/APD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus1|w144    ),
    .p12 ( \/APD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus1|w143    ),
    .p14 ( \/APD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus1|w142    ),
    .p16 ( \/APD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus1|w141    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAN76 (
    .p1 ( \N$/tilemaps/xpd-bus1|w425 ),
    .p2 ( \N$/tilemaps/xpd-bus1|w421 )
);

capcom_dl0921_BUF12 tilemaps_xpd_bus1_UAO0 (
    .p1 ( \/counter-fi/~RESET   ),
    .p2 ( \/tilemaps/sr1/~RESET )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAO2 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \N$/tilemaps/xpd-bus1|w116    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w335    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w115    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w326    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w114    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w315    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w113    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w306    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w112    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w293    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w111    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w282    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w110    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w271    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w109    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w262    ),
    .p18 ( \/obj-manager/SERIAL-CHNL     )
);

capcom_dl0921_AO22 tilemaps_xpd_bus1_UAO38 (
    .p1 ( \N$/tilemaps/xpd-bus1|w421 ),
    .p2 ( \N$/tilemaps/xpd-bus1|w425 ),
    .p3 ( \N$/tilemaps/xpd-bus1|w394 ),
    .p4 ( \N$/tilemaps/xpd-bus1|w415 ),
    .p5 ( \/tilemaps/sr1/A           )
);

capcom_dl0921_L8GH tilemaps_xpd_bus1_UAO41 (
    .p1  ( \/tilemaps/cb-bus1/LOAD-CHNLB ),
    .p2  ( \N$/tilemaps/xpd-bus1|w148    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w341    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w147    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w330    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w146    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w321    ),
    .p8  ( \N$/tilemaps/xpd-bus1|w145    ),
    .p9  ( \N$/tilemaps/xpd-bus1|w310    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w144    ),
    .p11 ( \N$/tilemaps/xpd-bus1|w299    ),
    .p12 ( \N$/tilemaps/xpd-bus1|w143    ),
    .p13 ( \N$/tilemaps/xpd-bus1|w286    ),
    .p14 ( \N$/tilemaps/xpd-bus1|w142    ),
    .p15 ( \N$/tilemaps/xpd-bus1|w277    ),
    .p16 ( \N$/tilemaps/xpd-bus1|w141    ),
    .p17 ( \N$/tilemaps/xpd-bus1|w266    ),
    .p18 ( \/obj-manager/SERIAL-CHNL     )
);

capcom_dl0921_INV01 tilemaps_xpd_bus1_UAO76 (
    .p1 ( \/tilemaps/xpd-bus1/XSEL   ),
    .p2 ( \N$/tilemaps/xpd-bus1|w425 )
);

capcom_dl0921_M198C tilemaps_xpd_bus1_UAP1 (
    .p1  ( \N$/tilemaps/xpd-bus1|w262    ),
    .p2  ( \N$/tilemaps/xpd-bus1|w271    ),
    .p3  ( \N$/tilemaps/xpd-bus1|w282    ),
    .p4  ( \N$/tilemaps/xpd-bus1|w293    ),
    .p5  ( \N$/tilemaps/xpd-bus1|w306    ),
    .p6  ( \N$/tilemaps/xpd-bus1|w315    ),
    .p7  ( \N$/tilemaps/xpd-bus1|w326    ),
    .p8  ( VCC                           ),
    .p9  ( \N$/tilemaps/xpd-bus1|w335    ),
    .p10 ( \N$/tilemaps/xpd-bus1|w409    ),
    .p11 ( \N$/tilemaps/xpd-bus1|UAP1.11 ),
    .p12 ( \N$/tilemaps/xpd-bus1|UAP1.12 ),
    .p13 ( \N$/tilemaps/xpd-bus1|UAP1.13 ),
    .p14 ( \N$/tilemaps/xpd-bus1|UAP1.14 ),
    .p15 ( \N$/tilemaps/xpd-bus1|UAP1.15 ),
    .p16 ( \N$/tilemaps/xpd-bus1|UAP1.16 ),
    .p17 ( \N$/tilemaps/xpd-bus1|w390    ),
    .p18 ( VCC                           ),
    .p19 ( \/tilemaps/sr1/~CLK8M         ),
    .p20 ( \N$/tilemaps/xpd-bus1|w379    ),
    .p21 ( \N$/tilemaps/xpd-bus1|w353    ),
    .p22 ( \/counter-fi/~RESET           )
);

capcom_dl0921_M198C tilemaps_xpd_bus1_UAP39 (
    .p1  ( \N$/tilemaps/xpd-bus1|w266     ),
    .p2  ( \N$/tilemaps/xpd-bus1|w277     ),
    .p3  ( \N$/tilemaps/xpd-bus1|w286     ),
    .p4  ( \N$/tilemaps/xpd-bus1|w299     ),
    .p5  ( \N$/tilemaps/xpd-bus1|w310     ),
    .p6  ( \N$/tilemaps/xpd-bus1|w321     ),
    .p7  ( \N$/tilemaps/xpd-bus1|w330     ),
    .p8  ( VCC                            ),
    .p9  ( \N$/tilemaps/xpd-bus1|w341     ),
    .p10 ( \N$/tilemaps/xpd-bus1|w415     ),
    .p11 ( \N$/tilemaps/xpd-bus1|UAP39.11 ),
    .p12 ( \N$/tilemaps/xpd-bus1|UAP39.12 ),
    .p13 ( \N$/tilemaps/xpd-bus1|UAP39.13 ),
    .p14 ( \N$/tilemaps/xpd-bus1|UAP39.14 ),
    .p15 ( \N$/tilemaps/xpd-bus1|UAP39.15 ),
    .p16 ( \N$/tilemaps/xpd-bus1|UAP39.16 ),
    .p17 ( \N$/tilemaps/xpd-bus1|w394     ),
    .p18 ( VCC                            ),
    .p19 ( \/tilemaps/sr1/~CLK8M          ),
    .p20 ( \N$/tilemaps/xpd-bus1|w379     ),
    .p21 ( \N$/tilemaps/xpd-bus1|w353     ),
    .p22 ( \/counter-fi/~RESET            )
);

//========================================================================
// tilemaps/xpd-bus2:
//========================================================================
capcom_dl0921_L8G tilemaps_xpd_bus2_UAE130 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \/CPD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus2|w156 ),
    .p4  ( \/CPD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus2|w155 ),
    .p6  ( \/CPD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus2|w154 ),
    .p8  ( \/CPD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus2|w153 ),
    .p10 ( \/CPD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus2|w152 ),
    .p12 ( \/CPD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus2|w151 ),
    .p14 ( \/CPD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus2|w150 ),
    .p16 ( \/CPD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus2|w149 ),
    .p18 ( GND                        )
);

capcom_dl0921_NAND03 tilemaps_xpd_bus2_UAE166 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/xpd-bus2/GFX-LOAD   ),
    .p3 ( \/bus-signal-control/GFX-CHNL  ),
    .p4 ( \N$/tilemaps/xpd-bus2|w177     )
);

capcom_dl0921_L8G tilemaps_xpd_bus2_UAE168 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \/DPD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus2|w124 ),
    .p4  ( \/DPD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus2|w123 ),
    .p6  ( \/DPD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus2|w122 ),
    .p8  ( \/DPD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus2|w121 ),
    .p10 ( \/DPD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus2|w120 ),
    .p12 ( \/DPD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus2|w119 ),
    .p14 ( \/DPD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus2|w118 ),
    .p16 ( \/DPD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus2|w117 ),
    .p18 ( GND                        )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAE204 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr2/~CLK8M          )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAF130 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \N$/tilemaps/xpd-bus2|w156 ),
    .p3  ( \N$/tilemaps/xpd-bus2|w343 ),
    .p4  ( \N$/tilemaps/xpd-bus2|w155 ),
    .p5  ( \N$/tilemaps/xpd-bus2|w331 ),
    .p6  ( \N$/tilemaps/xpd-bus2|w154 ),
    .p7  ( \N$/tilemaps/xpd-bus2|w323 ),
    .p8  ( \N$/tilemaps/xpd-bus2|w153 ),
    .p9  ( \N$/tilemaps/xpd-bus2|w311 ),
    .p10 ( \N$/tilemaps/xpd-bus2|w152 ),
    .p11 ( \N$/tilemaps/xpd-bus2|w301 ),
    .p12 ( \N$/tilemaps/xpd-bus2|w151 ),
    .p13 ( \N$/tilemaps/xpd-bus2|w287 ),
    .p14 ( \N$/tilemaps/xpd-bus2|w150 ),
    .p15 ( \N$/tilemaps/xpd-bus2|w279 ),
    .p16 ( \N$/tilemaps/xpd-bus2|w149 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w267 ),
    .p18 ( \N$/tilemaps/xpd-bus2|w207 )
);

capcom_dl0921_NAND03 tilemaps_xpd_bus2_UAF166 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/xpd-bus2/GFX-LOAD   ),
    .p3 ( \N$/tilemaps/xpd-bus2|UAG165.2 ),
    .p4 ( \/tilemaps/cb-bus2/LOAD-CHNLB  )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAF168 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \N$/tilemaps/xpd-bus2|w124 ),
    .p3  ( \N$/tilemaps/xpd-bus2|w337 ),
    .p4  ( \N$/tilemaps/xpd-bus2|w123 ),
    .p5  ( \N$/tilemaps/xpd-bus2|w327 ),
    .p6  ( \N$/tilemaps/xpd-bus2|w122 ),
    .p7  ( \N$/tilemaps/xpd-bus2|w317 ),
    .p8  ( \N$/tilemaps/xpd-bus2|w121 ),
    .p9  ( \N$/tilemaps/xpd-bus2|w307 ),
    .p10 ( \N$/tilemaps/xpd-bus2|w120 ),
    .p11 ( \N$/tilemaps/xpd-bus2|w295 ),
    .p12 ( \N$/tilemaps/xpd-bus2|w119 ),
    .p13 ( \N$/tilemaps/xpd-bus2|w283 ),
    .p14 ( \N$/tilemaps/xpd-bus2|w118 ),
    .p15 ( \N$/tilemaps/xpd-bus2|w273 ),
    .p16 ( \N$/tilemaps/xpd-bus2|w117 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w263 ),
    .p18 ( \N$/tilemaps/xpd-bus2|w207 )
);

capcom_dl0921_L8G tilemaps_xpd_bus2_UAG130 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB ),
    .p2  ( \/CPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus2|w164    ),
    .p4  ( \/CPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus2|w163    ),
    .p6  ( \/CPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus2|w162    ),
    .p8  ( \/CPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus2|w161    ),
    .p10 ( \/CPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus2|w160    ),
    .p12 ( \/CPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus2|w159    ),
    .p14 ( \/CPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus2|w158    ),
    .p16 ( \/CPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus2|w157    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAG165 (
    .p1 ( \/bus-signal-control/GFX-CHNL  ),
    .p2 ( \N$/tilemaps/xpd-bus2|UAG165.2 )
);

capcom_dl0921_OR02 tilemaps_xpd_bus2_UAG166 (
    .p1 ( \/tilemaps/sr1-sync/LOAD   ),
    .p2 ( \/tilemaps/xpd-bus2/XSEL   ),
    .p3 ( \N$/tilemaps/xpd-bus2|w352 )
);

capcom_dl0921_L8G tilemaps_xpd_bus2_UAG168 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB ),
    .p2  ( \/DPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus2|w132    ),
    .p4  ( \/DPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus2|w131    ),
    .p6  ( \/DPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus2|w130    ),
    .p8  ( \/DPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus2|w129    ),
    .p10 ( \/DPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus2|w128    ),
    .p12 ( \/DPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus2|w127    ),
    .p14 ( \/DPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus2|w126    ),
    .p16 ( \/DPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus2|w125    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAG204 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr2/~CLK8M          )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAH165 (
    .p1 ( \/tilemaps/xpd-bus2/SERIAL-CHNL ),
    .p2 ( \N$/tilemaps/xpd-bus2|w207      )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAH204 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr2/~CLK8M          )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAI130 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus2|w164      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w343      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w163      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w331      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w162      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w323      ),
    .p8  ( \N$/tilemaps/xpd-bus2|w161      ),
    .p9  ( \N$/tilemaps/xpd-bus2|w311      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w160      ),
    .p11 ( \N$/tilemaps/xpd-bus2|w301      ),
    .p12 ( \N$/tilemaps/xpd-bus2|w159      ),
    .p13 ( \N$/tilemaps/xpd-bus2|w287      ),
    .p14 ( \N$/tilemaps/xpd-bus2|w158      ),
    .p15 ( \N$/tilemaps/xpd-bus2|w279      ),
    .p16 ( \N$/tilemaps/xpd-bus2|w157      ),
    .p17 ( \N$/tilemaps/xpd-bus2|w267      ),
    .p18 ( \/tilemaps/xpd-bus2/SERIAL-CHNL )
);

capcom_dl0921_OR02 tilemaps_xpd_bus2_UAI165 (
    .p1 ( \/tilemaps/sr1-sync/LOAD       ),
    .p2 ( \N$/tilemaps/xpd-bus2|UAI167.2 ),
    .p3 ( \N$/tilemaps/xpd-bus2|w378     )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAI167 (
    .p1 ( \/tilemaps/xpd-bus2/XSEL       ),
    .p2 ( \N$/tilemaps/xpd-bus2|UAI167.2 )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAI168 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus2|w132      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w337      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w131      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w327      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w130      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w317      ),
    .p8  ( \N$/tilemaps/xpd-bus2|w129      ),
    .p9  ( \N$/tilemaps/xpd-bus2|w307      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w128      ),
    .p11 ( \N$/tilemaps/xpd-bus2|w295      ),
    .p12 ( \N$/tilemaps/xpd-bus2|w127      ),
    .p13 ( \N$/tilemaps/xpd-bus2|w283      ),
    .p14 ( \N$/tilemaps/xpd-bus2|w126      ),
    .p15 ( \N$/tilemaps/xpd-bus2|w273      ),
    .p16 ( \N$/tilemaps/xpd-bus2|w125      ),
    .p17 ( \N$/tilemaps/xpd-bus2|w263      ),
    .p18 ( \/tilemaps/xpd-bus2/SERIAL-CHNL )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAI204 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr2/~CLK8M          )
);

capcom_dl0921_M198C tilemaps_xpd_bus2_UAJ128 (
    .p1  ( \N$/tilemaps/xpd-bus2|w267      ),
    .p2  ( \N$/tilemaps/xpd-bus2|w279      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w287      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w301      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w311      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w323      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w331      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus2|w343      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w418      ),
    .p11 ( \N$/tilemaps/xpd-bus2|UAJ128.11 ),
    .p12 ( \N$/tilemaps/xpd-bus2|UAJ128.12 ),
    .p13 ( \N$/tilemaps/xpd-bus2|UAJ128.13 ),
    .p14 ( \N$/tilemaps/xpd-bus2|UAJ128.14 ),
    .p15 ( \N$/tilemaps/xpd-bus2|UAJ128.15 ),
    .p16 ( \N$/tilemaps/xpd-bus2|UAJ128.16 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w395      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr2/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus2|w378      ),
    .p21 ( \N$/tilemaps/xpd-bus2|w352      ),
    .p22 ( \/counter-fi/~RESET             )
);

capcom_dl0921_M198C tilemaps_xpd_bus2_UAJ167 (
    .p1  ( \N$/tilemaps/xpd-bus2|w263      ),
    .p2  ( \N$/tilemaps/xpd-bus2|w273      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w283      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w295      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w307      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w317      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w327      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus2|w337      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w410      ),
    .p11 ( \N$/tilemaps/xpd-bus2|UAJ167.11 ),
    .p12 ( \N$/tilemaps/xpd-bus2|UAJ167.12 ),
    .p13 ( \N$/tilemaps/xpd-bus2|UAJ167.13 ),
    .p14 ( \N$/tilemaps/xpd-bus2|UAJ167.14 ),
    .p15 ( \N$/tilemaps/xpd-bus2|UAJ167.15 ),
    .p16 ( \N$/tilemaps/xpd-bus2|UAJ167.16 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w391      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr2/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus2|w378      ),
    .p21 ( \N$/tilemaps/xpd-bus2|w352      ),
    .p22 ( \/counter-fi/~RESET             )
);

capcom_dl0921_L8G tilemaps_xpd_bus2_UAL130 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \/APD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus2|w140 ),
    .p4  ( \/APD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus2|w139 ),
    .p6  ( \/APD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus2|w138 ),
    .p8  ( \/APD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus2|w137 ),
    .p10 ( \/APD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus2|w136 ),
    .p12 ( \/APD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus2|w135 ),
    .p14 ( \/APD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus2|w134 ),
    .p16 ( \/APD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus2|w133 ),
    .p18 ( GND                        )
);

capcom_dl0921_AO22 tilemaps_xpd_bus2_UAL165 (
    .p1 ( \N$/tilemaps/xpd-bus2|w420 ),
    .p2 ( \N$/tilemaps/xpd-bus2|w424 ),
    .p3 ( \N$/tilemaps/xpd-bus2|w391 ),
    .p4 ( \N$/tilemaps/xpd-bus2|w410 ),
    .p5 ( \/tilemaps/sr2/D           )
);

capcom_dl0921_L8G tilemaps_xpd_bus2_UAL168 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \/BPD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus2|w108 ),
    .p4  ( \/BPD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus2|w107 ),
    .p6  ( \/BPD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus2|w106 ),
    .p8  ( \/BPD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus2|w105 ),
    .p10 ( \/BPD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus2|w104 ),
    .p12 ( \/BPD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus2|w103 ),
    .p14 ( \/BPD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus2|w102 ),
    .p16 ( \/BPD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus2|w101 ),
    .p18 ( GND                        )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAM130 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \N$/tilemaps/xpd-bus2|w140 ),
    .p3  ( \N$/tilemaps/xpd-bus2|w340 ),
    .p4  ( \N$/tilemaps/xpd-bus2|w139 ),
    .p5  ( \N$/tilemaps/xpd-bus2|w329 ),
    .p6  ( \N$/tilemaps/xpd-bus2|w138 ),
    .p7  ( \N$/tilemaps/xpd-bus2|w320 ),
    .p8  ( \N$/tilemaps/xpd-bus2|w137 ),
    .p9  ( \N$/tilemaps/xpd-bus2|w309 ),
    .p10 ( \N$/tilemaps/xpd-bus2|w136 ),
    .p11 ( \N$/tilemaps/xpd-bus2|w298 ),
    .p12 ( \N$/tilemaps/xpd-bus2|w135 ),
    .p13 ( \N$/tilemaps/xpd-bus2|w285 ),
    .p14 ( \N$/tilemaps/xpd-bus2|w134 ),
    .p15 ( \N$/tilemaps/xpd-bus2|w276 ),
    .p16 ( \N$/tilemaps/xpd-bus2|w133 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w265 ),
    .p18 ( \N$/tilemaps/xpd-bus2|w207 )
);

capcom_dl0921_AO22 tilemaps_xpd_bus2_UAM165 (
    .p1 ( \N$/tilemaps/xpd-bus2|w420 ),
    .p2 ( \N$/tilemaps/xpd-bus2|w424 ),
    .p3 ( \N$/tilemaps/xpd-bus2|w395 ),
    .p4 ( \N$/tilemaps/xpd-bus2|w418 ),
    .p5 ( \/tilemaps/sr2/C           )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAM168 (
    .p1  ( \N$/tilemaps/xpd-bus2|w177 ),
    .p2  ( \N$/tilemaps/xpd-bus2|w108 ),
    .p3  ( \N$/tilemaps/xpd-bus2|w334 ),
    .p4  ( \N$/tilemaps/xpd-bus2|w107 ),
    .p5  ( \N$/tilemaps/xpd-bus2|w325 ),
    .p6  ( \N$/tilemaps/xpd-bus2|w106 ),
    .p7  ( \N$/tilemaps/xpd-bus2|w314 ),
    .p8  ( \N$/tilemaps/xpd-bus2|w105 ),
    .p9  ( \N$/tilemaps/xpd-bus2|w305 ),
    .p10 ( \N$/tilemaps/xpd-bus2|w104 ),
    .p11 ( \N$/tilemaps/xpd-bus2|w292 ),
    .p12 ( \N$/tilemaps/xpd-bus2|w103 ),
    .p13 ( \N$/tilemaps/xpd-bus2|w281 ),
    .p14 ( \N$/tilemaps/xpd-bus2|w102 ),
    .p15 ( \N$/tilemaps/xpd-bus2|w270 ),
    .p16 ( \N$/tilemaps/xpd-bus2|w101 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w261 ),
    .p18 ( \N$/tilemaps/xpd-bus2|w207 )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAN129 (
    .p1 ( \N$/tilemaps/xpd-bus2|w424 ),
    .p2 ( \N$/tilemaps/xpd-bus2|w420 )
);

capcom_dl0921_L8G tilemaps_xpd_bus2_UAN130 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB ),
    .p2  ( \/APD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus2|w148    ),
    .p4  ( \/APD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus2|w147    ),
    .p6  ( \/APD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus2|w146    ),
    .p8  ( \/APD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus2|w145    ),
    .p10 ( \/APD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus2|w144    ),
    .p12 ( \/APD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus2|w143    ),
    .p14 ( \/APD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus2|w142    ),
    .p16 ( \/APD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus2|w141    ),
    .p18 ( GND                           )
);

capcom_dl0921_AO22 tilemaps_xpd_bus2_UAN165 (
    .p1 ( \N$/tilemaps/xpd-bus2|w420 ),
    .p2 ( \N$/tilemaps/xpd-bus2|w424 ),
    .p3 ( \N$/tilemaps/xpd-bus2|w389 ),
    .p4 ( \N$/tilemaps/xpd-bus2|w408 ),
    .p5 ( \/tilemaps/sr2/B           )
);

capcom_dl0921_L8G tilemaps_xpd_bus2_UAN168 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB ),
    .p2  ( \/BPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus2|w116    ),
    .p4  ( \/BPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus2|w115    ),
    .p6  ( \/BPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus2|w114    ),
    .p8  ( \/BPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus2|w113    ),
    .p10 ( \/BPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus2|w112    ),
    .p12 ( \/BPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus2|w111    ),
    .p14 ( \/BPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus2|w110    ),
    .p16 ( \/BPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus2|w109    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus2_UAO129 (
    .p1 ( \/tilemaps/xpd-bus2/XSEL   ),
    .p2 ( \N$/tilemaps/xpd-bus2|w424 )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAO130 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus2|w148      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w340      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w147      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w329      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w146      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w320      ),
    .p8  ( \N$/tilemaps/xpd-bus2|w145      ),
    .p9  ( \N$/tilemaps/xpd-bus2|w309      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w144      ),
    .p11 ( \N$/tilemaps/xpd-bus2|w298      ),
    .p12 ( \N$/tilemaps/xpd-bus2|w143      ),
    .p13 ( \N$/tilemaps/xpd-bus2|w285      ),
    .p14 ( \N$/tilemaps/xpd-bus2|w142      ),
    .p15 ( \N$/tilemaps/xpd-bus2|w276      ),
    .p16 ( \N$/tilemaps/xpd-bus2|w141      ),
    .p17 ( \N$/tilemaps/xpd-bus2|w265      ),
    .p18 ( \/tilemaps/xpd-bus2/SERIAL-CHNL )
);

capcom_dl0921_AO22 tilemaps_xpd_bus2_UAO165 (
    .p1 ( \N$/tilemaps/xpd-bus2|w420 ),
    .p2 ( \N$/tilemaps/xpd-bus2|w424 ),
    .p3 ( \N$/tilemaps/xpd-bus2|w393 ),
    .p4 ( \N$/tilemaps/xpd-bus2|w414 ),
    .p5 ( \/tilemaps/sr2/A           )
);

capcom_dl0921_L8GH tilemaps_xpd_bus2_UAO168 (
    .p1  ( \/tilemaps/cb-bus2/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus2|w116      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w334      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w115      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w325      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w114      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w314      ),
    .p8  ( \N$/tilemaps/xpd-bus2|w113      ),
    .p9  ( \N$/tilemaps/xpd-bus2|w305      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w112      ),
    .p11 ( \N$/tilemaps/xpd-bus2|w292      ),
    .p12 ( \N$/tilemaps/xpd-bus2|w111      ),
    .p13 ( \N$/tilemaps/xpd-bus2|w281      ),
    .p14 ( \N$/tilemaps/xpd-bus2|w110      ),
    .p15 ( \N$/tilemaps/xpd-bus2|w270      ),
    .p16 ( \N$/tilemaps/xpd-bus2|w109      ),
    .p17 ( \N$/tilemaps/xpd-bus2|w261      ),
    .p18 ( \/tilemaps/xpd-bus2/SERIAL-CHNL )
);

capcom_dl0921_BUF12 tilemaps_xpd_bus2_UAO204 (
    .p1 ( \/counter-fi/~RESET   ),
    .p2 ( \/tilemaps/sr2/~RESET )
);

capcom_dl0921_M198C tilemaps_xpd_bus2_UAP128 (
    .p1  ( \N$/tilemaps/xpd-bus2|w265      ),
    .p2  ( \N$/tilemaps/xpd-bus2|w276      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w285      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w298      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w309      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w320      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w329      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus2|w340      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w414      ),
    .p11 ( \N$/tilemaps/xpd-bus2|UAP128.11 ),
    .p12 ( \N$/tilemaps/xpd-bus2|UAP128.12 ),
    .p13 ( \N$/tilemaps/xpd-bus2|UAP128.13 ),
    .p14 ( \N$/tilemaps/xpd-bus2|UAP128.14 ),
    .p15 ( \N$/tilemaps/xpd-bus2|UAP128.15 ),
    .p16 ( \N$/tilemaps/xpd-bus2|UAP128.16 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w393      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr2/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus2|w378      ),
    .p21 ( \N$/tilemaps/xpd-bus2|w352      ),
    .p22 ( \/counter-fi/~RESET             )
);

capcom_dl0921_M198C tilemaps_xpd_bus2_UAP167 (
    .p1  ( \N$/tilemaps/xpd-bus2|w261      ),
    .p2  ( \N$/tilemaps/xpd-bus2|w270      ),
    .p3  ( \N$/tilemaps/xpd-bus2|w281      ),
    .p4  ( \N$/tilemaps/xpd-bus2|w292      ),
    .p5  ( \N$/tilemaps/xpd-bus2|w305      ),
    .p6  ( \N$/tilemaps/xpd-bus2|w314      ),
    .p7  ( \N$/tilemaps/xpd-bus2|w325      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus2|w334      ),
    .p10 ( \N$/tilemaps/xpd-bus2|w408      ),
    .p11 ( \N$/tilemaps/xpd-bus2|UAP167.11 ),
    .p12 ( \N$/tilemaps/xpd-bus2|UAP167.12 ),
    .p13 ( \N$/tilemaps/xpd-bus2|UAP167.13 ),
    .p14 ( \N$/tilemaps/xpd-bus2|UAP167.14 ),
    .p15 ( \N$/tilemaps/xpd-bus2|UAP167.15 ),
    .p16 ( \N$/tilemaps/xpd-bus2|UAP167.16 ),
    .p17 ( \N$/tilemaps/xpd-bus2|w389      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr2/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus2|w378      ),
    .p21 ( \N$/tilemaps/xpd-bus2|w352      ),
    .p22 ( \/counter-fi/~RESET             )
);

//========================================================================
// tilemaps/xpd-bus3:
//========================================================================
capcom_dl0921_INV01 tilemaps_xpd_bus3_UAE208 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr3/~CLK8M          )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAE209 (
    .p1  ( \N$/tilemaps/xpd-bus3|w161 ),
    .p2  ( \/DPD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus3|w294 ),
    .p4  ( \/DPD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus3|w282 ),
    .p6  ( \/DPD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus3|w269 ),
    .p8  ( \/DPD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus3|w256 ),
    .p10 ( \/DPD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus3|w242 ),
    .p12 ( \/DPD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus3|w226 ),
    .p14 ( \/DPD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus3|w214 ),
    .p16 ( \/DPD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus3|w200 ),
    .p18 ( \N$/tilemaps/xpd-bus3|w162 )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAE245 (
    .p1 ( \/tilemaps/cb-bus3/LOAD-CHNLA ),
    .p2 ( \N$/tilemaps/xpd-bus3|w161    )
);

capcom_dl0921_NAND03 tilemaps_xpd_bus3_UAE246 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/xpd-bus3/GFX-LOAD   ),
    .p3 ( \/bus-signal-control/GFX-CHNL  ),
    .p4 ( \/tilemaps/cb-bus3/LOAD-CHNLA  )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAE248 (
    .p1  ( \N$/tilemaps/xpd-bus3|w161 ),
    .p2  ( \/CPD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus3|w302 ),
    .p4  ( \/CPD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus3|w286 ),
    .p6  ( \/CPD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus3|w277 ),
    .p8  ( \/CPD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus3|w260 ),
    .p10 ( \/CPD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus3|w250 ),
    .p12 ( \/CPD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus3|w230 ),
    .p14 ( \/CPD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus3|w222 ),
    .p16 ( \/CPD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus3|w206 ),
    .p18 ( \N$/tilemaps/xpd-bus3|w162 )
);

capcom_dl0921_NAND03 tilemaps_xpd_bus3_UAF245 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/xpd-bus3/GFX-LOAD   ),
    .p3 ( \N$/tilemaps/xpd-bus3|w261     ),
    .p4 ( \/tilemaps/cb-bus3/LOAD-CHNLB  )
);

capcom_dl0921_NAND02 tilemaps_xpd_bus3_UAF249 (
    .p1 ( \/tilemaps/xpd-bus3/GFX-LOAD  ),
    .p2 ( \/bus-signal-control/GFX-CHNL ),
    .p3 ( \/tilemaps/sr3-sync/~LOAD     )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAG208 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr3/~CLK8M          )
);

capcom_dl0921_L8G tilemaps_xpd_bus3_UAG209 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB ),
    .p2  ( \/DPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus3|w108    ),
    .p4  ( \/DPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus3|w107    ),
    .p6  ( \/DPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus3|w106    ),
    .p8  ( \/DPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus3|w105    ),
    .p10 ( \/DPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus3|w104    ),
    .p12 ( \/DPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus3|w103    ),
    .p14 ( \/DPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus3|w102    ),
    .p16 ( \/DPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus3|w101    ),
    .p18 ( GND                           )
);

capcom_dl0921_OR02 tilemaps_xpd_bus3_UAG245 (
    .p1 ( \/tilemaps/sr1-sync/LOAD   ),
    .p2 ( \/tilemaps/xpd-bus3/XSEL   ),
    .p3 ( \N$/tilemaps/xpd-bus3|w311 )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAG247 (
    .p1 ( \/bus-signal-control/GFX-CHNL ),
    .p2 ( \N$/tilemaps/xpd-bus3|w261    )
);

capcom_dl0921_L8G tilemaps_xpd_bus3_UAG248 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB ),
    .p2  ( \/CPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus3|w124    ),
    .p4  ( \/CPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus3|w123    ),
    .p6  ( \/CPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus3|w122    ),
    .p8  ( \/CPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus3|w121    ),
    .p10 ( \/CPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus3|w120    ),
    .p12 ( \/CPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus3|w119    ),
    .p14 ( \/CPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus3|w118    ),
    .p16 ( \/CPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus3|w117    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAH208 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr3/~CLK8M          )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAH247 (
    .p1 ( \/tilemaps/xpd-bus3/SERIAL-CHNL ),
    .p2 ( \N$/tilemaps/xpd-bus3|w162      )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAI208 (
    .p1 ( \/lut-assembly/lut-storage/CLK ),
    .p2 ( \/tilemaps/sr3/~CLK8M          )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAI209 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus3|w108      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w294      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w107      ),
    .p5  ( \N$/tilemaps/xpd-bus3|w282      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w106      ),
    .p7  ( \N$/tilemaps/xpd-bus3|w269      ),
    .p8  ( \N$/tilemaps/xpd-bus3|w105      ),
    .p9  ( \N$/tilemaps/xpd-bus3|w256      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w104      ),
    .p11 ( \N$/tilemaps/xpd-bus3|w242      ),
    .p12 ( \N$/tilemaps/xpd-bus3|w103      ),
    .p13 ( \N$/tilemaps/xpd-bus3|w226      ),
    .p14 ( \N$/tilemaps/xpd-bus3|w102      ),
    .p15 ( \N$/tilemaps/xpd-bus3|w214      ),
    .p16 ( \N$/tilemaps/xpd-bus3|w101      ),
    .p17 ( \N$/tilemaps/xpd-bus3|w200      ),
    .p18 ( \/tilemaps/xpd-bus3/SERIAL-CHNL )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAI245 (
    .p1 ( \/tilemaps/xpd-bus3/XSEL       ),
    .p2 ( \N$/tilemaps/xpd-bus3|UAI245.2 )
);

capcom_dl0921_OR02 tilemaps_xpd_bus3_UAI246 (
    .p1 ( \/tilemaps/sr1-sync/LOAD       ),
    .p2 ( \N$/tilemaps/xpd-bus3|UAI245.2 ),
    .p3 ( \N$/tilemaps/xpd-bus3|w337     )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAI248 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus3|w124      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w302      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w123      ),
    .p5  ( \N$/tilemaps/xpd-bus3|w286      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w122      ),
    .p7  ( \N$/tilemaps/xpd-bus3|w277      ),
    .p8  ( \N$/tilemaps/xpd-bus3|w121      ),
    .p9  ( \N$/tilemaps/xpd-bus3|w260      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w120      ),
    .p11 ( \N$/tilemaps/xpd-bus3|w250      ),
    .p12 ( \N$/tilemaps/xpd-bus3|w119      ),
    .p13 ( \N$/tilemaps/xpd-bus3|w230      ),
    .p14 ( \N$/tilemaps/xpd-bus3|w118      ),
    .p15 ( \N$/tilemaps/xpd-bus3|w222      ),
    .p16 ( \N$/tilemaps/xpd-bus3|w117      ),
    .p17 ( \N$/tilemaps/xpd-bus3|w206      ),
    .p18 ( \/tilemaps/xpd-bus3/SERIAL-CHNL )
);

capcom_dl0921_M198C tilemaps_xpd_bus3_UAJ208 (
    .p1  ( \N$/tilemaps/xpd-bus3|w200      ),
    .p2  ( \N$/tilemaps/xpd-bus3|w214      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w226      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w242      ),
    .p5  ( \N$/tilemaps/xpd-bus3|w256      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w269      ),
    .p7  ( \N$/tilemaps/xpd-bus3|w282      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus3|w294      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w369      ),
    .p11 ( \N$/tilemaps/xpd-bus3|UAJ208.11 ),
    .p12 ( \N$/tilemaps/xpd-bus3|UAJ208.12 ),
    .p13 ( \N$/tilemaps/xpd-bus3|UAJ208.13 ),
    .p14 ( \N$/tilemaps/xpd-bus3|UAJ208.14 ),
    .p15 ( \N$/tilemaps/xpd-bus3|UAJ208.15 ),
    .p16 ( \N$/tilemaps/xpd-bus3|UAJ208.16 ),
    .p17 ( \N$/tilemaps/xpd-bus3|w350      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr3/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus3|w337      ),
    .p21 ( \N$/tilemaps/xpd-bus3|w311      ),
    .p22 ( \/counter-fi/~RESET             )
);

capcom_dl0921_M198C tilemaps_xpd_bus3_UAJ247 (
    .p1  ( \N$/tilemaps/xpd-bus3|w206      ),
    .p2  ( \N$/tilemaps/xpd-bus3|w222      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w230      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w250      ),
    .p5  ( \N$/tilemaps/xpd-bus3|w260      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w277      ),
    .p7  ( \N$/tilemaps/xpd-bus3|w286      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus3|w302      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w377      ),
    .p11 ( \N$/tilemaps/xpd-bus3|UAJ247.11 ),
    .p12 ( \N$/tilemaps/xpd-bus3|UAJ247.12 ),
    .p13 ( \N$/tilemaps/xpd-bus3|UAJ247.13 ),
    .p14 ( \N$/tilemaps/xpd-bus3|UAJ247.14 ),
    .p15 ( \N$/tilemaps/xpd-bus3|UAJ247.15 ),
    .p16 ( \N$/tilemaps/xpd-bus3|UAJ247.16 ),
    .p17 ( \N$/tilemaps/xpd-bus3|w354      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr3/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus3|w337      ),
    .p21 ( \N$/tilemaps/xpd-bus3|w311      ),
    .p22 ( \/counter-fi/~RESET             )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAL209 (
    .p1  ( \N$/tilemaps/xpd-bus3|w161 ),
    .p2  ( \/BPD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus3|w290 ),
    .p4  ( \/BPD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus3|w280 ),
    .p6  ( \/BPD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus3|w265 ),
    .p8  ( \/BPD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus3|w254 ),
    .p10 ( \/BPD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus3|w238 ),
    .p12 ( \/BPD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus3|w224 ),
    .p14 ( \/BPD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus3|w210 ),
    .p16 ( \/BPD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus3|w197 ),
    .p18 ( \N$/tilemaps/xpd-bus3|w162 )
);

capcom_dl0921_AO22 tilemaps_xpd_bus3_UAL245 (
    .p1 ( \N$/tilemaps/xpd-bus3|w379 ),
    .p2 ( \N$/tilemaps/xpd-bus3|w383 ),
    .p3 ( \N$/tilemaps/xpd-bus3|w350 ),
    .p4 ( \N$/tilemaps/xpd-bus3|w369 ),
    .p5 ( \/tilemaps/sr3/D           )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAL248 (
    .p1  ( \N$/tilemaps/xpd-bus3|w161 ),
    .p2  ( \/APD0                     ),
    .p3  ( \N$/tilemaps/xpd-bus3|w298 ),
    .p4  ( \/APD1                     ),
    .p5  ( \N$/tilemaps/xpd-bus3|w284 ),
    .p6  ( \/APD2                     ),
    .p7  ( \N$/tilemaps/xpd-bus3|w273 ),
    .p8  ( \/APD3                     ),
    .p9  ( \N$/tilemaps/xpd-bus3|w258 ),
    .p10 ( \/APD4                     ),
    .p11 ( \N$/tilemaps/xpd-bus3|w246 ),
    .p12 ( \/APD5                     ),
    .p13 ( \N$/tilemaps/xpd-bus3|w228 ),
    .p14 ( \/APD6                     ),
    .p15 ( \N$/tilemaps/xpd-bus3|w218 ),
    .p16 ( \/APD7                     ),
    .p17 ( \N$/tilemaps/xpd-bus3|w203 ),
    .p18 ( \N$/tilemaps/xpd-bus3|w162 )
);

capcom_dl0921_AO22 tilemaps_xpd_bus3_UAM245 (
    .p1 ( \N$/tilemaps/xpd-bus3|w379 ),
    .p2 ( \N$/tilemaps/xpd-bus3|w383 ),
    .p3 ( \N$/tilemaps/xpd-bus3|w354 ),
    .p4 ( \N$/tilemaps/xpd-bus3|w377 ),
    .p5 ( \/tilemaps/sr3/C           )
);

capcom_dl0921_L8G tilemaps_xpd_bus3_UAN209 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB ),
    .p2  ( \/BPD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus3|w100    ),
    .p4  ( \/BPD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus3|w99     ),
    .p6  ( \/BPD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus3|w98     ),
    .p8  ( \/BPD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus3|w97     ),
    .p10 ( \/BPD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus3|w96     ),
    .p12 ( \/BPD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus3|w95     ),
    .p14 ( \/BPD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus3|w94     ),
    .p16 ( \/BPD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus3|w93     ),
    .p18 ( GND                           )
);

capcom_dl0921_AO22 tilemaps_xpd_bus3_UAN245 (
    .p1 ( \N$/tilemaps/xpd-bus3|w379 ),
    .p2 ( \N$/tilemaps/xpd-bus3|w383 ),
    .p3 ( \N$/tilemaps/xpd-bus3|w348 ),
    .p4 ( \N$/tilemaps/xpd-bus3|w367 ),
    .p5 ( \/tilemaps/sr3/B           )
);

capcom_dl0921_L8G tilemaps_xpd_bus3_UAN248 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB ),
    .p2  ( \/APD0                        ),
    .p3  ( \N$/tilemaps/xpd-bus3|w116    ),
    .p4  ( \/APD1                        ),
    .p5  ( \N$/tilemaps/xpd-bus3|w115    ),
    .p6  ( \/APD2                        ),
    .p7  ( \N$/tilemaps/xpd-bus3|w114    ),
    .p8  ( \/APD3                        ),
    .p9  ( \N$/tilemaps/xpd-bus3|w113    ),
    .p10 ( \/APD4                        ),
    .p11 ( \N$/tilemaps/xpd-bus3|w112    ),
    .p12 ( \/APD5                        ),
    .p13 ( \N$/tilemaps/xpd-bus3|w111    ),
    .p14 ( \/APD6                        ),
    .p15 ( \N$/tilemaps/xpd-bus3|w110    ),
    .p16 ( \/APD7                        ),
    .p17 ( \N$/tilemaps/xpd-bus3|w109    ),
    .p18 ( GND                           )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAN284 (
    .p1 ( \N$/tilemaps/xpd-bus3|w383 ),
    .p2 ( \N$/tilemaps/xpd-bus3|w379 )
);

capcom_dl0921_BUF12 tilemaps_xpd_bus3_UAO208 (
    .p1 ( \/counter-fi/~RESET   ),
    .p2 ( \/tilemaps/sr3/~RESET )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAO209 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus3|w100      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w290      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w99       ),
    .p5  ( \N$/tilemaps/xpd-bus3|w280      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w98       ),
    .p7  ( \N$/tilemaps/xpd-bus3|w265      ),
    .p8  ( \N$/tilemaps/xpd-bus3|w97       ),
    .p9  ( \N$/tilemaps/xpd-bus3|w254      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w96       ),
    .p11 ( \N$/tilemaps/xpd-bus3|w238      ),
    .p12 ( \N$/tilemaps/xpd-bus3|w95       ),
    .p13 ( \N$/tilemaps/xpd-bus3|w224      ),
    .p14 ( \N$/tilemaps/xpd-bus3|w94       ),
    .p15 ( \N$/tilemaps/xpd-bus3|w210      ),
    .p16 ( \N$/tilemaps/xpd-bus3|w93       ),
    .p17 ( \N$/tilemaps/xpd-bus3|w197      ),
    .p18 ( \/tilemaps/xpd-bus3/SERIAL-CHNL )
);

capcom_dl0921_AO22 tilemaps_xpd_bus3_UAO245 (
    .p1 ( \N$/tilemaps/xpd-bus3|w379 ),
    .p2 ( \N$/tilemaps/xpd-bus3|w383 ),
    .p3 ( \N$/tilemaps/xpd-bus3|w352 ),
    .p4 ( \N$/tilemaps/xpd-bus3|w373 ),
    .p5 ( \/tilemaps/sr3/A           )
);

capcom_dl0921_L8GH tilemaps_xpd_bus3_UAO248 (
    .p1  ( \/tilemaps/cb-bus3/LOAD-CHNLB   ),
    .p2  ( \N$/tilemaps/xpd-bus3|w116      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w298      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w115      ),
    .p5  ( \N$/tilemaps/xpd-bus3|w284      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w114      ),
    .p7  ( \N$/tilemaps/xpd-bus3|w273      ),
    .p8  ( \N$/tilemaps/xpd-bus3|w113      ),
    .p9  ( \N$/tilemaps/xpd-bus3|w258      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w112      ),
    .p11 ( \N$/tilemaps/xpd-bus3|w246      ),
    .p12 ( \N$/tilemaps/xpd-bus3|w111      ),
    .p13 ( \N$/tilemaps/xpd-bus3|w228      ),
    .p14 ( \N$/tilemaps/xpd-bus3|w110      ),
    .p15 ( \N$/tilemaps/xpd-bus3|w218      ),
    .p16 ( \N$/tilemaps/xpd-bus3|w109      ),
    .p17 ( \N$/tilemaps/xpd-bus3|w203      ),
    .p18 ( \/tilemaps/xpd-bus3/SERIAL-CHNL )
);

capcom_dl0921_INV01 tilemaps_xpd_bus3_UAO284 (
    .p1 ( \/tilemaps/xpd-bus3/XSEL   ),
    .p2 ( \N$/tilemaps/xpd-bus3|w383 )
);

capcom_dl0921_M198C tilemaps_xpd_bus3_UAP208 (
    .p1  ( \N$/tilemaps/xpd-bus3|w197      ),
    .p2  ( \N$/tilemaps/xpd-bus3|w210      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w224      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w238      ),
    .p5  ( \N$/tilemaps/xpd-bus3|w254      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w265      ),
    .p7  ( \N$/tilemaps/xpd-bus3|w280      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus3|w290      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w367      ),
    .p11 ( \N$/tilemaps/xpd-bus3|UAP208.11 ),
    .p12 ( \N$/tilemaps/xpd-bus3|UAP208.12 ),
    .p13 ( \N$/tilemaps/xpd-bus3|UAP208.13 ),
    .p14 ( \N$/tilemaps/xpd-bus3|UAP208.14 ),
    .p15 ( \N$/tilemaps/xpd-bus3|UAP208.15 ),
    .p16 ( \N$/tilemaps/xpd-bus3|UAP208.16 ),
    .p17 ( \N$/tilemaps/xpd-bus3|w348      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr3/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus3|w337      ),
    .p21 ( \N$/tilemaps/xpd-bus3|w311      ),
    .p22 ( \/counter-fi/~RESET             )
);

capcom_dl0921_M198C tilemaps_xpd_bus3_UAP247 (
    .p1  ( \N$/tilemaps/xpd-bus3|w203      ),
    .p2  ( \N$/tilemaps/xpd-bus3|w218      ),
    .p3  ( \N$/tilemaps/xpd-bus3|w228      ),
    .p4  ( \N$/tilemaps/xpd-bus3|w246      ),
    .p5  ( \N$/tilemaps/xpd-bus3|w258      ),
    .p6  ( \N$/tilemaps/xpd-bus3|w273      ),
    .p7  ( \N$/tilemaps/xpd-bus3|w284      ),
    .p8  ( VCC                             ),
    .p9  ( \N$/tilemaps/xpd-bus3|w298      ),
    .p10 ( \N$/tilemaps/xpd-bus3|w373      ),
    .p11 ( \N$/tilemaps/xpd-bus3|UAP247.11 ),
    .p12 ( \N$/tilemaps/xpd-bus3|UAP247.12 ),
    .p13 ( \N$/tilemaps/xpd-bus3|UAP247.13 ),
    .p14 ( \N$/tilemaps/xpd-bus3|UAP247.14 ),
    .p15 ( \N$/tilemaps/xpd-bus3|UAP247.15 ),
    .p16 ( \N$/tilemaps/xpd-bus3|UAP247.16 ),
    .p17 ( \N$/tilemaps/xpd-bus3|w352      ),
    .p18 ( VCC                             ),
    .p19 ( \/tilemaps/sr3/~CLK8M           ),
    .p20 ( \N$/tilemaps/xpd-bus3|w337      ),
    .p21 ( \N$/tilemaps/xpd-bus3|w311      ),
    .p22 ( \/counter-fi/~RESET             )
);

//========================================================================
// video-signals:
//========================================================================
capcom_dl0921_AND03 video_signals_UBN385 (
    .p1 ( \/~DEBUG1                                        ),
    .p2 ( \/video-signals/video-counter/~COUNTER-SET       ),
    .p3 ( \/video-signals/video-counter/COUNTER-INC        ),
    .p4 ( \/video-signals/video-signal-generator/~DEBUG-HI )
);

//========================================================================
// video-signals/video-counter:
//========================================================================
capcom_dl0921_OR03 video_signals_video_counter_UBN388 (
    .p1 ( \/video-signals/video-counter/~E    ),
    .p2 ( \/lut-assembly/layer-control/WR     ),
    .p3 ( \N$/video-signals/video-counter|w2  ),
    .p4 ( \N$/video-signals/video-counter|w50 )
);

capcom_dl0921_OR02 video_signals_video_counter_UBN451 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \/video-signals/video-counter/DATA14       ),
    .p3 ( \N$/video-signals/video-counter|w178       )
);

capcom_dl0921_M273C video_signals_video_counter_UBN485 (
    .p1  ( \/video-signals/~RESET                      ),
    .p2  ( \/video-signals/video-counter/DATA8         ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN8 ),
    .p4  ( \/lut-assembly/layer-control/BUS9           ),
    .p5  ( \/video-signals/video-counter/DATA9         ),
    .p6  ( \/video-signals/video-counter/DATA10        ),
    .p7  ( \/lut-assembly/layer-control/BUS10          ),
    .p8  ( \/lut-assembly/layer-control/BUS11          ),
    .p9  ( \/video-signals/video-counter/DATA11        ),
    .p11 ( \N$/video-signals/video-counter|w50         ),
    .p12 ( \/video-signals/video-counter/DATA12        ),
    .p13 ( \/lut-assembly/layer-control/BUS12          ),
    .p14 ( \/lut-assembly/layer-control/BUS13          ),
    .p15 ( \/video-signals/video-counter/DATA13        ),
    .p16 ( \/video-signals/video-counter/DATA14        ),
    .p17 ( \/cps-id/DATA14                             ),
    .p18 ( \/raster-interrupts/counter1/UK             ),
    .p19 ( \/video-signals/video-counter/DATA15        )
);

capcom_dl0921_INV01 video_signals_video_counter_UBU180 (
    .p1 ( \N$/video-signals/video-counter|w363 ),
    .p2 ( \N$/video-signals/video-counter|w373 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBU182 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w373 ),
    .p3 ( \N$/video-signals/video-counter|w470 )
);

capcom_dl0921_NAND02 video_signals_video_counter_UBU265 (
    .p1 ( \N$/video-signals/video-counter|w371      ),
    .p2 ( \/video-signals/video-counter/COUNTER-INC ),
    .p3 ( \N$/video-signals/video-counter|w355      )
);

capcom_dl0921_AND02 video_signals_video_counter_UBU293 (
    .p1 ( \N$/video-signals/video-counter|UBU370.3 ),
    .p2 ( \N$/video-signals/video-counter|w371     ),
    .p3 ( \N$/video-signals/video-counter|w363     )
);

capcom_dl0921_INV01 video_signals_video_counter_UBU328 (
    .p1 ( \/main-signals/LI                    ),
    .p2 ( \N$/video-signals/video-counter|w371 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBU370 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/video-signals/video-counter|w371          ),
    .p3 ( \N$/video-signals/video-counter|UBU370.3      ),
    .p5 ( \N$/video-signals/video-counter|UBU370.5      )
);

capcom_dl0921_INV01 video_signals_video_counter_UBU443 (
    .p1 ( \/counter-fi/FI                    ),
    .p2 ( \N$/video-signals/video-counter|w3 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBU446 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/video-signals/video-counter|w3            ),
    .p3 ( \N$/video-signals/video-counter|UBU446.3      ),
    .p5 ( \N$/video-signals/video-counter|UBU446.5      )
);

capcom_dl0921_AND02 video_signals_video_counter_UBU451 (
    .p1 ( \N$/video-signals/video-counter|UBU446.3 ),
    .p2 ( \N$/video-signals/video-counter|w3       ),
    .p3 ( \N$/video-signals/video-counter|w27      )
);

capcom_dl0921_OR02 video_signals_video_counter_UBU453 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \/video-signals/video-counter/DATA15       ),
    .p3 ( \N$/video-signals/video-counter|w117       )
);

capcom_dl0921_OR02 video_signals_video_counter_UBU496 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \/video-signals/video-counter/DATA13       ),
    .p3 ( \N$/video-signals/video-counter|w116       )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBW150 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w502     ),
    .p3 ( \N$/video-signals/video-counter|w567     ),
    .p5 ( \N$/video-signals/video-counter|UBW150.5 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UBW154 (
    .p1 ( \N$/video-signals/video-counter|UBW150.5 ),
    .p2 ( \/video-signals/video-counter/COL1       )
);

capcom_dl0921_AND02 video_signals_video_counter_UBW175 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w363 ),
    .p3 ( \N$/video-signals/video-counter|w460 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBW177 (
    .p1 ( \N$/video-signals/video-counter|w460 ),
    .p2 ( \N$/video-signals/video-counter|w470 ),
    .p3 ( \N$/video-signals/video-counter|w629 ),
    .p4 ( \N$/video-signals/video-counter|w428 ),
    .p5 ( \N$/video-signals/video-counter|w502 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBW180 (
    .p1 ( \N$/video-signals/video-counter|w460 ),
    .p2 ( \N$/video-signals/video-counter|w470 ),
    .p3 ( \N$/video-signals/video-counter|w639 ),
    .p4 ( \N$/video-signals/video-counter|w481 ),
    .p5 ( \N$/video-signals/video-counter|w505 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBW183 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w27  ),
    .p3 ( \N$/video-signals/video-counter|w146 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UBW278 (
    .p1 ( \N$/video-signals/video-counter|UBZ187.5 ),
    .p2 ( \/video-signals/video-counter/COL4       )
);

capcom_dl0921_OR02 video_signals_video_counter_UBW412 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \/video-signals/video-counter/DATA11       ),
    .p3 ( \N$/video-signals/video-counter|w115       )
);

capcom_dl0921_AND02 video_signals_video_counter_UBW421 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA2  ),
    .p3 ( \N$/video-signals/video-counter|w481 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBW438 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA7  ),
    .p3 ( \N$/video-signals/video-counter|w431 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBW442 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA1  ),
    .p3 ( \N$/video-signals/video-counter|w478 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBW445 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA0  ),
    .p3 ( \N$/video-signals/video-counter|w428 )
);

capcom_dl0921_OR02 video_signals_video_counter_UBW447 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \/video-signals/video-counter/DATA10       ),
    .p3 ( \N$/video-signals/video-counter|w171       )
);

capcom_dl0921_AND02 video_signals_video_counter_UBW450 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA6  ),
    .p3 ( \N$/video-signals/video-counter|w488 )
);

capcom_dl0921_M273C video_signals_video_counter_UBW457 (
    .p1  ( \/video-signals/~RESET                      ),
    .p2  ( \/video-signals/video-counter/DATA0         ),
    .p3  ( \/raster-interrupts/counters-bus-buffer/IN0 ),
    .p4  ( \/raster-interrupts/counters-bus-buffer/IN1 ),
    .p5  ( \/video-signals/video-counter/DATA1         ),
    .p6  ( \/video-signals/video-counter/DATA2         ),
    .p7  ( \/raster-interrupts/counters-bus-buffer/IN2 ),
    .p8  ( \/raster-interrupts/counters-bus-buffer/IN3 ),
    .p9  ( \/video-signals/video-counter/DATA3         ),
    .p11 ( \N$/video-signals/video-counter|w50         ),
    .p12 ( \/video-signals/video-counter/DATA4         ),
    .p13 ( \/raster-interrupts/counters-bus-buffer/IN4 ),
    .p14 ( \/raster-interrupts/counters-bus-buffer/IN5 ),
    .p15 ( \/video-signals/video-counter/DATA5         ),
    .p16 ( \/video-signals/video-counter/DATA6         ),
    .p17 ( \/raster-interrupts/counters-bus-buffer/IN6 ),
    .p18 ( \/raster-interrupts/counters-bus-buffer/IN7 ),
    .p19 ( \/video-signals/video-counter/DATA7         )
);

capcom_dl0921_OR02 video_signals_video_counter_UBW496 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \/video-signals/video-counter/DATA12       ),
    .p3 ( \N$/video-signals/video-counter|w174       )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBZ126 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w505     ),
    .p3 ( \N$/video-signals/video-counter|w548     ),
    .p5 ( \N$/video-signals/video-counter|UBZ126.5 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UBZ131 (
    .p1 ( \N$/video-signals/video-counter|UBZ126.5 ),
    .p2 ( \/video-signals/video-counter/COL3       )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UBZ135 (
    .p1 ( \N$/video-signals/video-counter|w548 ),
    .p2 ( \N$/video-signals/video-counter|w618 ),
    .p3 ( \N$/video-signals/video-counter|w639 )
);

capcom_dl0921_NOR03 video_signals_video_counter_UBZ138 (
    .p1 ( \N$/video-signals/video-counter|w599 ),
    .p2 ( \N$/video-signals/video-counter|w567 ),
    .p3 ( \N$/video-signals/video-counter|w597 ),
    .p4 ( \N$/video-signals/video-counter|w618 )
);

capcom_dl0921_NOR04 video_signals_video_counter_UBZ141 (
    .p1 ( \N$/video-signals/video-counter|w620 ),
    .p2 ( \N$/video-signals/video-counter|w548 ),
    .p3 ( \N$/video-signals/video-counter|w599 ),
    .p4 ( \N$/video-signals/video-counter|w567 ),
    .p5 ( \N$/video-signals/video-counter|w597 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBZ150 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w511     ),
    .p3 ( \N$/video-signals/video-counter|w609     ),
    .p5 ( \N$/video-signals/video-counter|UBZ150.5 )
);

capcom_dl0921_NAND02 video_signals_video_counter_UBZ155 (
    .p1 ( \/video-signals/video-counter/COUNTER-INC ),
    .p2 ( \/video-signals/video-counter/COUNTER-INC ),
    .p3 ( \N$/video-signals/video-counter|w597      )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ159 (
    .p1 ( \N$/video-signals/video-counter|w465 ),
    .p2 ( \N$/video-signals/video-counter|w491 ),
    .p3 ( \N$/video-signals/video-counter|w640 ),
    .p4 ( \N$/video-signals/video-counter|w488 ),
    .p5 ( \N$/video-signals/video-counter|w513 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ162 (
    .p1 ( \N$/video-signals/video-counter|w465 ),
    .p2 ( \N$/video-signals/video-counter|w491 ),
    .p3 ( \N$/video-signals/video-counter|w644 ),
    .p4 ( \N$/video-signals/video-counter|w431 ),
    .p5 ( \N$/video-signals/video-counter|w515 )
);

capcom_dl0921_XOR02 video_signals_video_counter_UBZ165 (
    .p1 ( \N$/video-signals/video-counter|w597 ),
    .p2 ( \N$/video-signals/video-counter|w567 ),
    .p3 ( \N$/video-signals/video-counter|w629 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UBZ168 (
    .p1 ( \N$/video-signals/video-counter|w609 ),
    .p2 ( \N$/video-signals/video-counter|w616 ),
    .p3 ( \N$/video-signals/video-counter|w636 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ171 (
    .p1 ( \N$/video-signals/video-counter|w465 ),
    .p2 ( \N$/video-signals/video-counter|w491 ),
    .p3 ( \N$/video-signals/video-counter|w636 ),
    .p4 ( \N$/video-signals/video-counter|w430 ),
    .p5 ( \N$/video-signals/video-counter|w511 )
);

capcom_dl0921_NOR02 video_signals_video_counter_UBZ173 (
    .p1 ( \N$/video-signals/video-counter|w597 ),
    .p2 ( \N$/video-signals/video-counter|w567 ),
    .p3 ( \N$/video-signals/video-counter|w613 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UBZ176 (
    .p1 ( \N$/video-signals/video-counter|w599 ),
    .p2 ( \N$/video-signals/video-counter|w613 ),
    .p3 ( \N$/video-signals/video-counter|w635 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ179 (
    .p1 ( \N$/video-signals/video-counter|w460 ),
    .p2 ( \N$/video-signals/video-counter|w470 ),
    .p3 ( \N$/video-signals/video-counter|w635 ),
    .p4 ( \N$/video-signals/video-counter|w478 ),
    .p5 ( \N$/video-signals/video-counter|w503 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UBZ182 (
    .p1 ( \N$/video-signals/video-counter|w598 ),
    .p2 ( \N$/video-signals/video-counter|w620 ),
    .p3 ( \N$/video-signals/video-counter|w641 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ185 (
    .p1 ( \N$/video-signals/video-counter|w460 ),
    .p2 ( \N$/video-signals/video-counter|w470 ),
    .p3 ( \N$/video-signals/video-counter|w641 ),
    .p4 ( \N$/video-signals/video-counter|w429 ),
    .p5 ( \N$/video-signals/video-counter|w507 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBZ187 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w507     ),
    .p3 ( \N$/video-signals/video-counter|w598     ),
    .p5 ( \N$/video-signals/video-counter|UBZ187.5 )
);

capcom_dl0921_NAND02 video_signals_video_counter_UBZ197 (
    .p1 ( \N$/video-signals/video-counter|w355 ),
    .p2 ( \N$/video-signals/video-counter|w355 ),
    .p3 ( \N$/video-signals/video-counter|w351 )
);

capcom_dl0921_INV01 video_signals_video_counter_UBZ199 (
    .p1 ( \N$/video-signals/video-counter|w355 ),
    .p2 ( \N$/video-signals/video-counter|w276 )
);

capcom_dl0921_NOR05 video_signals_video_counter_UBZ200 (
    .p1 ( \N$/video-signals/video-counter|w329 ),
    .p2 ( \N$/video-signals/video-counter|w298 ),
    .p3 ( \N$/video-signals/video-counter|w247 ),
    .p4 ( \N$/video-signals/video-counter|w266 ),
    .p5 ( \N$/video-signals/video-counter|w299 ),
    .p6 ( \N$/video-signals/video-counter|w276 )
);

capcom_dl0921_NOR04 video_signals_video_counter_UBZ205 (
    .p1 ( \N$/video-signals/video-counter|w320 ),
    .p2 ( \N$/video-signals/video-counter|w247 ),
    .p3 ( \N$/video-signals/video-counter|w299 ),
    .p4 ( \N$/video-signals/video-counter|w266 ),
    .p5 ( \N$/video-signals/video-counter|w351 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UBZ209 (
    .p1 ( \N$/video-signals/video-counter|w298 ),
    .p2 ( \N$/video-signals/video-counter|w320 ),
    .p3 ( \N$/video-signals/video-counter|w343 )
);

capcom_dl0921_XOR02 video_signals_video_counter_UBZ217 (
    .p1 ( \N$/video-signals/video-counter|w351 ),
    .p2 ( \N$/video-signals/video-counter|w266 ),
    .p3 ( \N$/video-signals/video-counter|w330 )
);

capcom_dl0921_NOR03 video_signals_video_counter_UBZ220 (
    .p1 ( \N$/video-signals/video-counter|w299 ),
    .p2 ( \N$/video-signals/video-counter|w266 ),
    .p3 ( \N$/video-signals/video-counter|w351 ),
    .p4 ( \N$/video-signals/video-counter|w318 )
);

capcom_dl0921_NOR02 video_signals_video_counter_UBZ223 (
    .p1 ( \N$/video-signals/video-counter|w351 ),
    .p2 ( \N$/video-signals/video-counter|w266 ),
    .p3 ( \N$/video-signals/video-counter|w313 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UBZ225 (
    .p1 ( \N$/video-signals/video-counter|w299 ),
    .p2 ( \N$/video-signals/video-counter|w313 ),
    .p3 ( \N$/video-signals/video-counter|w336 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UBZ229 (
    .p1 ( \N$/video-signals/video-counter|w247 ),
    .p2 ( \N$/video-signals/video-counter|w318 ),
    .p3 ( \N$/video-signals/video-counter|w340 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ232 (
    .p1 ( \N$/video-signals/video-counter|w146 ),
    .p2 ( \N$/video-signals/video-counter|w157 ),
    .p3 ( \N$/video-signals/video-counter|w336 ),
    .p4 ( \N$/video-signals/video-counter|w168 ),
    .p5 ( \N$/video-signals/video-counter|w198 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBZ234 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w198     ),
    .p3 ( \N$/video-signals/video-counter|w299     ),
    .p5 ( \N$/video-signals/video-counter|UBZ234.5 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ240 (
    .p1 ( \N$/video-signals/video-counter|w146 ),
    .p2 ( \N$/video-signals/video-counter|w157 ),
    .p3 ( \N$/video-signals/video-counter|w343 ),
    .p4 ( \N$/video-signals/video-counter|w115 ),
    .p5 ( \N$/video-signals/video-counter|w202 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UBZ243 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w202     ),
    .p3 ( \N$/video-signals/video-counter|w298     ),
    .p5 ( \N$/video-signals/video-counter|UBZ243.5 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UBZ269 (
    .p1 ( \N$/video-signals/video-counter|w146 ),
    .p2 ( \N$/video-signals/video-counter|w157 ),
    .p3 ( \N$/video-signals/video-counter|w340 ),
    .p4 ( \N$/video-signals/video-counter|w171 ),
    .p5 ( \N$/video-signals/video-counter|w200 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBZ430 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA5  ),
    .p3 ( \N$/video-signals/video-counter|w430 )
);

capcom_dl0921_NBUF02 video_signals_video_counter_UBZ432 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \N$/video-signals/video-counter|w425       )
);

capcom_dl0921_AND02 video_signals_video_counter_UBZ467 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA4  ),
    .p3 ( \N$/video-signals/video-counter|w484 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBZ470 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA3  ),
    .p3 ( \N$/video-signals/video-counter|w429 )
);

capcom_dl0921_AND02 video_signals_video_counter_UBZ475 (
    .p1 ( \N$/video-signals/video-counter|w425 ),
    .p2 ( \/video-signals/video-counter/DATA9  ),
    .p3 ( \N$/video-signals/video-counter|w168 )
);

capcom_dl0921_INV01 video_signals_video_counter_UCC130 (
    .p1 ( \/video-signals/video-counter/COUNTER-INC ),
    .p2 ( \N$/video-signals/video-counter|w576      )
);

capcom_dl0921_NOR05 video_signals_video_counter_UCC131 (
    .p1 ( \N$/video-signals/video-counter|w628 ),
    .p2 ( \N$/video-signals/video-counter|w598 ),
    .p3 ( \N$/video-signals/video-counter|w548 ),
    .p4 ( \N$/video-signals/video-counter|w567 ),
    .p5 ( \N$/video-signals/video-counter|w599 ),
    .p6 ( \N$/video-signals/video-counter|w576 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UCC139 (
    .p1 ( \N$/video-signals/video-counter|w552 ),
    .p2 ( \N$/video-signals/video-counter|w621 ),
    .p3 ( \N$/video-signals/video-counter|w640 )
);

capcom_dl0921_INV01 video_signals_video_counter_UCC141 (
    .p1 ( \N$/video-signals/video-counter|w628 ),
    .p2 ( \N$/video-signals/video-counter|w578 )
);

capcom_dl0921_NAND02 video_signals_video_counter_UCC143 (
    .p1 ( \N$/video-signals/video-counter|w628 ),
    .p2 ( \N$/video-signals/video-counter|w628 ),
    .p3 ( \N$/video-signals/video-counter|w607 )
);

capcom_dl0921_NOR05 video_signals_video_counter_UCC144 (
    .p1 ( \N$/video-signals/video-counter|w626 ),
    .p2 ( \N$/video-signals/video-counter|w608 ),
    .p3 ( \N$/video-signals/video-counter|w552 ),
    .p4 ( \N$/video-signals/video-counter|w574 ),
    .p5 ( \N$/video-signals/video-counter|w609 ),
    .p6 ( \N$/video-signals/video-counter|w578 )
);

capcom_dl0921_NOR03 video_signals_video_counter_UCC147 (
    .p1 ( \N$/video-signals/video-counter|w609 ),
    .p2 ( \N$/video-signals/video-counter|w574 ),
    .p3 ( \N$/video-signals/video-counter|w607 ),
    .p4 ( \N$/video-signals/video-counter|w621 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UCC150 (
    .p1 ( \N$/video-signals/video-counter|w608 ),
    .p2 ( \N$/video-signals/video-counter|w623 ),
    .p3 ( \N$/video-signals/video-counter|w644 )
);

capcom_dl0921_NOR04 video_signals_video_counter_UCC153 (
    .p1 ( \N$/video-signals/video-counter|w623 ),
    .p2 ( \N$/video-signals/video-counter|w552 ),
    .p3 ( \N$/video-signals/video-counter|w609 ),
    .p4 ( \N$/video-signals/video-counter|w574 ),
    .p5 ( \N$/video-signals/video-counter|w607 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCC161 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w513     ),
    .p3 ( \N$/video-signals/video-counter|w552     ),
    .p5 ( \N$/video-signals/video-counter|UCC161.5 )
);

capcom_dl0921_XOR02 video_signals_video_counter_UCC166 (
    .p1 ( \N$/video-signals/video-counter|w607 ),
    .p2 ( \N$/video-signals/video-counter|w574 ),
    .p3 ( \N$/video-signals/video-counter|w632 )
);

capcom_dl0921_NOR02 video_signals_video_counter_UCC169 (
    .p1 ( \N$/video-signals/video-counter|w607 ),
    .p2 ( \N$/video-signals/video-counter|w574 ),
    .p3 ( \N$/video-signals/video-counter|w616 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCC172 (
    .p1 ( \N$/video-signals/video-counter|UBZ150.5 ),
    .p2 ( \/video-signals/video-counter/COL6       )
);

capcom_dl0921_AOI22 video_signals_video_counter_UCC174 (
    .p1 ( \N$/video-signals/video-counter|w465 ),
    .p2 ( \N$/video-signals/video-counter|w491 ),
    .p3 ( \N$/video-signals/video-counter|w632 ),
    .p4 ( \N$/video-signals/video-counter|w484 ),
    .p5 ( \N$/video-signals/video-counter|w509 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCC176 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w509     ),
    .p3 ( \N$/video-signals/video-counter|w574     ),
    .p5 ( \N$/video-signals/video-counter|UCC176.5 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCC181 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w503     ),
    .p3 ( \N$/video-signals/video-counter|w599     ),
    .p5 ( \N$/video-signals/video-counter|UCC181.5 )
);

capcom_dl0921_AND02 video_signals_video_counter_UCC185 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w363 ),
    .p3 ( \N$/video-signals/video-counter|w465 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCC192 (
    .p1 ( \N$/video-signals/video-counter|UCC176.5 ),
    .p2 ( \/video-signals/video-counter/COL5       )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCC198 (
    .p1 ( \N$/video-signals/video-counter|UCC161.5 ),
    .p2 ( \/video-signals/video-counter/COL7       )
);

capcom_dl0921_AND02 video_signals_video_counter_UCC207 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w32  ),
    .p3 ( \N$/video-signals/video-counter|w157 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UCC264 (
    .p1 ( \N$/video-signals/video-counter|w146 ),
    .p2 ( \N$/video-signals/video-counter|w157 ),
    .p3 ( \N$/video-signals/video-counter|w330 ),
    .p4 ( \N$/video-signals/video-counter|w114 ),
    .p5 ( \N$/video-signals/video-counter|w197 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCC269 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w200     ),
    .p3 ( \N$/video-signals/video-counter|w247     ),
    .p5 ( \N$/video-signals/video-counter|UCC269.5 )
);

capcom_dl0921_OR02 video_signals_video_counter_UCC428 (
    .p1 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p2 ( \/video-signals/video-counter/DATA8        ),
    .p3 ( \N$/video-signals/video-counter|w114       )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCG161 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w515     ),
    .p3 ( \N$/video-signals/video-counter|w608     ),
    .p5 ( \N$/video-signals/video-counter|UCG161.5 )
);

capcom_dl0921_INV01 video_signals_video_counter_UCG166 (
    .p1 ( \N$/video-signals/video-counter|w363 ),
    .p2 ( \N$/video-signals/video-counter|w374 )
);

capcom_dl0921_AND02 video_signals_video_counter_UCG167 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w374 ),
    .p3 ( \N$/video-signals/video-counter|w491 )
);

capcom_dl0921_NAND02 video_signals_video_counter_UCG169 (
    .p1 ( \N$/video-signals/video-counter|w329 ),
    .p2 ( \N$/video-signals/video-counter|w329 ),
    .p3 ( \N$/video-signals/video-counter|w307 )
);

capcom_dl0921_AND02 video_signals_video_counter_UCG200 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w27  ),
    .p3 ( \N$/video-signals/video-counter|w152 )
);

capcom_dl0921_INV01 video_signals_video_counter_UCG202 (
    .p1 ( \N$/video-signals/video-counter|w27 ),
    .p2 ( \N$/video-signals/video-counter|w32 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCG275 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w197     ),
    .p3 ( \N$/video-signals/video-counter|w266     ),
    .p5 ( \N$/video-signals/video-counter|UCG275.5 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCG283 (
    .p1 ( \N$/video-signals/video-counter|UCC181.5 ),
    .p2 ( \/video-signals/video-counter/COL2       )
);

capcom_dl0921_AND02 video_signals_video_counter_UCG403 (
    .p1 ( \/video-signals/~RESET              ),
    .p2 ( \N$/video-signals/video-counter|w27 ),
    .p3 ( \N$/video-signals/video-counter|w67 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UCG405 (
    .p1 ( \N$/video-signals/video-counter|w67        ),
    .p2 ( \N$/video-signals/video-counter|w183       ),
    .p3 ( \N$/video-signals/video-counter|w342       ),
    .p4 ( \/video-signals/video-counter/~COUNTER-SET ),
    .p5 ( \N$/video-signals/video-counter|w186       )
);

capcom_dl0921_AND02 video_signals_video_counter_UCG409 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w34  ),
    .p3 ( \N$/video-signals/video-counter|w183 )
);

capcom_dl0921_INV01 video_signals_video_counter_UCG412 (
    .p1 ( \N$/video-signals/video-counter|w27 ),
    .p2 ( \N$/video-signals/video-counter|w34 )
);

capcom_dl0921_NOR04 video_signals_video_counter_UCJ147 (
    .p1 ( \N$/video-signals/video-counter|w323 ),
    .p2 ( \N$/video-signals/video-counter|w251 ),
    .p3 ( \N$/video-signals/video-counter|w309 ),
    .p4 ( \N$/video-signals/video-counter|w273 ),
    .p5 ( \N$/video-signals/video-counter|w307 )
);

capcom_dl0921_NOR03 video_signals_video_counter_UCJ151 (
    .p1 ( \N$/video-signals/video-counter|w309 ),
    .p2 ( \N$/video-signals/video-counter|w273 ),
    .p3 ( \N$/video-signals/video-counter|w307 ),
    .p4 ( \N$/video-signals/video-counter|w321 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UCJ154 (
    .p1 ( \N$/video-signals/video-counter|w251 ),
    .p2 ( \N$/video-signals/video-counter|w321 ),
    .p3 ( \N$/video-signals/video-counter|w341 )
);

capcom_dl0921_XOR02 video_signals_video_counter_UCJ159 (
    .p1 ( \N$/video-signals/video-counter|w307 ),
    .p2 ( \N$/video-signals/video-counter|w273 ),
    .p3 ( \N$/video-signals/video-counter|w333 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCJ162 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w208     ),
    .p3 ( \N$/video-signals/video-counter|w251     ),
    .p5 ( \N$/video-signals/video-counter|UCJ162.5 )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UCJ167 (
    .p1 ( \N$/video-signals/video-counter|w308 ),
    .p2 ( \N$/video-signals/video-counter|w323 ),
    .p3 ( \N$/video-signals/video-counter|w346 )
);

capcom_dl0921_NOR05 video_signals_video_counter_UCJ172 (
    .p1 ( \N$/video-signals/video-counter|w327 ),
    .p2 ( \N$/video-signals/video-counter|w308 ),
    .p3 ( \N$/video-signals/video-counter|w251 ),
    .p4 ( \N$/video-signals/video-counter|w273 ),
    .p5 ( \N$/video-signals/video-counter|w309 ),
    .p6 ( \N$/video-signals/video-counter|w278 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UCJ180 (
    .p1 ( \N$/video-signals/video-counter|w152 ),
    .p2 ( \N$/video-signals/video-counter|w181 ),
    .p3 ( \N$/video-signals/video-counter|w341 ),
    .p4 ( \N$/video-signals/video-counter|w178 ),
    .p5 ( \N$/video-signals/video-counter|w208 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UCJ182 (
    .p1 ( \N$/video-signals/video-counter|w152 ),
    .p2 ( \N$/video-signals/video-counter|w181 ),
    .p3 ( \N$/video-signals/video-counter|w346 ),
    .p4 ( \N$/video-signals/video-counter|w117 ),
    .p5 ( \N$/video-signals/video-counter|w210 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UCJ185 (
    .p1 ( \N$/video-signals/video-counter|w152 ),
    .p2 ( \N$/video-signals/video-counter|w181 ),
    .p3 ( \N$/video-signals/video-counter|w333 ),
    .p4 ( \N$/video-signals/video-counter|w174 ),
    .p5 ( \N$/video-signals/video-counter|w204 )
);

capcom_dl0921_INV01 video_signals_video_counter_UCJ188 (
    .p1 ( \N$/video-signals/video-counter|w329 ),
    .p2 ( \N$/video-signals/video-counter|w278 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCJ217 (
    .p1 ( \N$/video-signals/video-counter|UCG161.5 ),
    .p2 ( \/video-signals/video-counter/COL8       )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCJ222 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w210     ),
    .p3 ( \N$/video-signals/video-counter|w308     ),
    .p5 ( \N$/video-signals/video-counter|UCJ222.5 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCJ273 (
    .p1 ( \N$/video-signals/video-counter|UCC269.5 ),
    .p2 ( \/video-signals/video-counter/LINE2      )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCJ275 (
    .p1 ( \N$/video-signals/video-counter|UBZ234.5 ),
    .p2 ( \/video-signals/video-counter/LINE1      )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UCJ278 (
    .p1 ( \N$/video-signals/video-counter|w230 ),
    .p2 ( \N$/video-signals/video-counter|w327 ),
    .p3 ( \N$/video-signals/video-counter|w342 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCJ280 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w186     ),
    .p3 ( \N$/video-signals/video-counter|w230     ),
    .p5 ( \N$/video-signals/video-counter|UCJ280.5 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCJ293 (
    .p1 ( \N$/video-signals/video-counter|UCG275.5 ),
    .p2 ( \/video-signals/video-counter/LINE0      )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCJ295 (
    .p1 ( \N$/video-signals/video-counter|UBZ243.5 ),
    .p2 ( \/video-signals/video-counter/LINE3      )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCJ330 (
    .p1 ( \N$/video-signals/video-counter|UCJ280.5 ),
    .p2 ( \/video-signals/video-counter/LINE8      )
);

capcom_dl0921_XNOR02 video_signals_video_counter_UCL160 (
    .p1 ( \N$/video-signals/video-counter|w309 ),
    .p2 ( \N$/video-signals/video-counter|w316 ),
    .p3 ( \N$/video-signals/video-counter|w337 )
);

capcom_dl0921_NOR02 video_signals_video_counter_UCL164 (
    .p1 ( \N$/video-signals/video-counter|w307 ),
    .p2 ( \N$/video-signals/video-counter|w273 ),
    .p3 ( \N$/video-signals/video-counter|w316 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCL186 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w204     ),
    .p3 ( \N$/video-signals/video-counter|w273     ),
    .p5 ( \N$/video-signals/video-counter|UCL186.5 )
);

capcom_dl0921_INV01 video_signals_video_counter_UCL201 (
    .p1 ( \N$/video-signals/video-counter|w27 ),
    .p2 ( \N$/video-signals/video-counter|w33 )
);

capcom_dl0921_AOI22 video_signals_video_counter_UCL202 (
    .p1 ( \N$/video-signals/video-counter|w152 ),
    .p2 ( \N$/video-signals/video-counter|w181 ),
    .p3 ( \N$/video-signals/video-counter|w337 ),
    .p4 ( \N$/video-signals/video-counter|w116 ),
    .p5 ( \N$/video-signals/video-counter|w206 )
);

capcom_dl0921_AND02 video_signals_video_counter_UCL205 (
    .p1 ( \/video-signals/~RESET               ),
    .p2 ( \N$/video-signals/video-counter|w33  ),
    .p3 ( \N$/video-signals/video-counter|w181 )
);

capcom_dl0921_DFFCOO video_signals_video_counter_UCL207 (
    .p1 ( \N$/video-signals/video-counter|w2       ),
    .p2 ( \N$/video-signals/video-counter|w206     ),
    .p3 ( \N$/video-signals/video-counter|w309     ),
    .p5 ( \N$/video-signals/video-counter|UCL207.5 )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCL259 (
    .p1 ( \N$/video-signals/video-counter|UCJ222.5 ),
    .p2 ( \/video-signals/video-counter/LINE7      )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCL283 (
    .p1 ( \N$/video-signals/video-counter|UCL186.5 ),
    .p2 ( \/video-signals/video-counter/LINE4      )
);

capcom_dl0921_NBUF03 video_signals_video_counter_UCL373 (
    .p1 ( \/video-signals/video-signal-registries/CLK8M ),
    .p2 ( \N$/video-signals/video-counter|w2            )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCO265 (
    .p1 ( \N$/video-signals/video-counter|UCL207.5 ),
    .p2 ( \/video-signals/video-counter/LINE5      )
);

capcom_dl0921_BUF12 video_signals_video_counter_UCT312 (
    .p1 ( \N$/video-signals/video-counter|UCJ162.5 ),
    .p2 ( \/video-signals/video-counter/LINE6      )
);

//========================================================================
// video-signals/video-signal-generator:
//========================================================================
capcom_dl0921_BUF12 video_signals_video_signal_generator_UAA254 (
    .p1 ( \N$/video-signals/video-signal-generator|UAA254.1 ),
    .p2 ( \/tilemaps/sr1-sync/LOAD                          )
);

capcom_dl0921_AND03 video_signals_video_signal_generator_UBD328 (
    .p1 ( \N$/video-signals/video-signal-generator|w496     ),
    .p2 ( \/video-signals/video-counter/COL1                ),
    .p3 ( \N$/video-signals/video-signal-generator|w501     ),
    .p4 ( \N$/video-signals/video-signal-generator|UAA254.1 )
);

capcom_dl0921_AND03 video_signals_video_signal_generator_UBD330 (
    .p1 ( \/video-signals/video-counter/COL3            ),
    .p2 ( \N$/video-signals/video-signal-generator|w496 ),
    .p3 ( \N$/video-signals/video-signal-generator|w501 ),
    .p4 ( \/tilemaps/xpd-bus1/GFX-LOAD                  )
);

capcom_dl0921_AND03 video_signals_video_signal_generator_UBD333 (
    .p1 ( \/video-signals/video-counter/COL3            ),
    .p2 ( \/video-signals/video-counter/COL2            ),
    .p3 ( \N$/video-signals/video-signal-generator|w501 ),
    .p4 ( \/tilemaps/xpd-bus2/GFX-LOAD                  )
);

capcom_dl0921_BUF12 video_signals_video_signal_generator_UBD337 (
    .p1 ( \/video-signals/video-counter/COL3 ),
    .p2 ( \/obj-manager/SERIAL-CHNL          )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBD370 (
    .p1 ( \/video-signals/video-counter/COL2            ),
    .p2 ( \N$/video-signals/video-signal-generator|w496 )
);

capcom_dl0921_BUF12 video_signals_video_signal_generator_UBD383 (
    .p1 ( \/video-signals/video-counter/COL1 ),
    .p2 ( \/bus-signal-control/GFX-CHNL      )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBD407 (
    .p1 ( \N$/video-signals/video-signal-generator|UBD407.1 ),
    .p2 ( \/tilemaps/xpd-bus3/GFX-LOAD                      )
);

capcom_dl0921_AND04 video_signals_video_signal_generator_UBH328 (
    .p1 ( \/video-signals/video-counter/COL4            ),
    .p2 ( \N$/video-signals/video-signal-generator|w496 ),
    .p3 ( \/video-signals/video-counter/COL1            ),
    .p4 ( \N$/video-signals/video-signal-generator|w501 ),
    .p5 ( \/obj-manager/SERIAL-LOAD                     )
);

capcom_dl0921_M367C video_signals_video_signal_generator_UBH356 (
    .p1  ( \/video-signals/video-signal-generator/~DEBUG-LO ),
    .p2  ( \/video-signals/video-counter/COL2               ),
    .p3  ( \/video-signals/video-counter/COL1               ),
    .p4  ( \/video-signals/video-signal-registries/CLK8M    ),
    .p5  ( GND                                              ),
    .p15 ( \/debug/td-io/IN11                               ),
    .p16 ( \/debug/td-io/IN10                               ),
    .p17 ( \/debug/td-io/IN9                                ),
    .p18 ( \/debug/td-io/IN8                                )
);

capcom_dl0921_NAND05 video_signals_video_signal_generator_UBH366 (
    .p1 ( \/video-signals/video-counter/COL4                ),
    .p2 ( \N$/video-signals/video-signal-generator|w459     ),
    .p3 ( \/video-signals/video-counter/COL2                ),
    .p4 ( \N$/video-signals/video-signal-generator|w454     ),
    .p5 ( \N$/video-signals/video-signal-generator|w501     ),
    .p6 ( \N$/video-signals/video-signal-generator|UBH366.6 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBH375 (
    .p1 ( \/video-signals/video-counter/COL1            ),
    .p2 ( \N$/video-signals/video-signal-generator|w454 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBH377 (
    .p1 ( \/video-signals/video-counter/COL3            ),
    .p2 ( \N$/video-signals/video-signal-generator|w459 )
);

capcom_dl0921_NAND05 video_signals_video_signal_generator_UBH383 (
    .p1 ( \N$/video-signals/video-signal-generator|w452     ),
    .p2 ( \N$/video-signals/video-signal-generator|w459     ),
    .p3 ( \N$/video-signals/video-signal-generator|w496     ),
    .p4 ( \/video-signals/video-counter/COL1                ),
    .p5 ( \N$/video-signals/video-signal-generator|w501     ),
    .p6 ( \N$/video-signals/video-signal-generator|UBH383.6 )
);

capcom_dl0921_AND04 video_signals_video_signal_generator_UBH393 (
    .p1 ( \N$/video-signals/video-signal-generator|w452 ),
    .p2 ( \N$/video-signals/video-signal-generator|w459 ),
    .p3 ( \/video-signals/video-counter/COL2            ),
    .p4 ( \N$/video-signals/video-signal-generator|w501 ),
    .p5 ( \/obj-manager/xpd-bus4/GFX-LOAD               )
);

capcom_dl0921_NAND05 video_signals_video_signal_generator_UBH430 (
    .p1 ( \/video-signals/video-counter/COL4                ),
    .p2 ( \N$/video-signals/video-signal-generator|w459     ),
    .p3 ( \/video-signals/video-counter/COL2                ),
    .p4 ( \/video-signals/video-counter/COL1                ),
    .p5 ( \N$/video-signals/video-signal-generator|w501     ),
    .p6 ( \N$/video-signals/video-signal-generator|UBH430.6 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBH476 (
    .p1 ( \N$/video-signals/video-signal-generator|UBH430.6 ),
    .p2 ( \/stars/xpd-bus6/LOAD                             )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBK322 (
    .p1 ( \N$/video-signals/video-signal-generator|UBH366.6 ),
    .p2 ( \/stars/xpd-bus5/LOAD                             )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBK330 (
    .p1 ( \N$/video-signals/video-counter|w2            ),
    .p2 ( \N$/video-signals/video-signal-generator|w501 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBK383 (
    .p1 ( \/video-signals/video-counter/COL4            ),
    .p2 ( \N$/video-signals/video-signal-generator|w452 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBK414 (
    .p1 ( \N$/video-signals/video-counter|w2            ),
    .p2 ( \N$/video-signals/video-signal-generator|w471 )
);

capcom_dl0921_NAND03 video_signals_video_signal_generator_UBK416 (
    .p1 ( \N$/video-signals/video-signal-generator|w473     ),
    .p2 ( \N$/video-signals/video-signal-generator|w505     ),
    .p3 ( \N$/video-signals/video-signal-generator|w471     ),
    .p4 ( \N$/video-signals/video-signal-generator|UBD407.1 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBK419 (
    .p1 ( \/video-signals/video-counter/COL3            ),
    .p2 ( \N$/video-signals/video-signal-generator|w473 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBK420 (
    .p1 ( \/video-signals/video-counter/COL2            ),
    .p2 ( \N$/video-signals/video-signal-generator|w505 )
);

capcom_dl0921_BUF12 video_signals_video_signal_generator_UBK433 (
    .p1 ( \/video-signals/video-counter/COL2 ),
    .p2 ( \/bus-signal-control/GFX-OUT-LMSB  )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UBN260 (
    .p1 ( \N$/video-signals/video-signal-generator|UBH383.6 ),
    .p2 ( \/stars/counter-xs-1/LOAD                         )
);

capcom_dl0921_M367C video_signals_video_signal_generator_UBN344 (
    .p1  ( \/video-signals/video-signal-generator/~DEBUG-HI ),
    .p2  ( \/video-signals/video-counter/LINE0              ),
    .p3  ( \/counter-fi/FI                                  ),
    .p4  ( GND                                              ),
    .p5  ( GND                                              ),
    .p15 ( \/debug/td-io/IN11                               ),
    .p16 ( \/debug/td-io/IN10                               ),
    .p17 ( \/debug/td-io/IN9                                ),
    .p18 ( \/debug/td-io/IN8                                )
);

capcom_dl0921_AND04 video_signals_video_signal_generator_UCC329 (
    .p1 ( \/video-signals/video-counter/COL8            ),
    .p2 ( \/video-signals/video-counter/COL7            ),
    .p3 ( \/video-signals/video-counter/COL6            ),
    .p4 ( \/video-signals/video-counter/COL5            ),
    .p5 ( \N$/video-signals/video-signal-generator|w624 )
);

capcom_dl0921_NOR02 video_signals_video_signal_generator_UCC332 (
    .p1 ( \N$/video-signals/video-signal-generator|w624 ),
    .p2 ( \N$/video-signals/video-signal-generator|w632 ),
    .p3 ( \/video-signals/video-signal-generator/HSYNC  )
);

capcom_dl0921_M541C video_signals_video_signal_generator_UCC334 (
    .p1  ( \/video-signals/video-signal-generator/~DEBUG-LO ),
    .p2  ( \/main-signals/LI                                ),
    .p3  ( \/counter-fi/FI                                  ),
    .p4  ( \/video-signals/video-counter/COL8               ),
    .p5  ( \/video-signals/video-counter/COL7               ),
    .p6  ( \/video-signals/video-counter/COL6               ),
    .p7  ( \/video-signals/video-counter/COL5               ),
    .p8  ( \/video-signals/video-counter/COL4               ),
    .p9  ( \/video-signals/video-counter/COL3               ),
    .p11 ( \/debug/td-io/IN7                                ),
    .p12 ( \/debug/td-io/IN6                                ),
    .p13 ( \/debug/td-io/IN5                                ),
    .p14 ( \/debug/td-io/IN4                                ),
    .p15 ( \/debug/td-io/IN3                                ),
    .p16 ( \/debug/td-io/IN2                                ),
    .p17 ( \/debug/td-io/IN1                                ),
    .p18 ( \/debug/td-io/IN0                                )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCG262 (
    .p1 ( \/video-signals/video-counter/COL7            ),
    .p2 ( \N$/video-signals/video-signal-generator|w621 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCG402 (
    .p1 ( \N$/video-signals/video-signal-generator|UCL350.1 ),
    .p2 ( \/video-signals/video-signal-generator/BLANK      )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCJ257 (
    .p1  ( \N$/video-signals/video-counter|w2            ),
    .p2  ( \N$/video-signals/video-signal-generator|w562 ),
    .p3  ( \/stars/FLIP                                  ),
    .p4  ( \N$/video-signals/video-signal-generator|w556 ),
    .p5  ( \N$/video-signals/video-signal-generator|w622 ),
    .p6  ( \/video-signals/video-counter/COL7            ),
    .p7  ( \N$/video-signals/video-signal-generator|w548 ),
    .p8  ( \/video-signals/video-counter/COL8            ),
    .p9  ( \N$/video-signals/video-signal-generator|w541 ),
    .p10 ( VCC                                           ),
    .p11 ( \/video-signals/video-counter/COL6            ),
    .p12 ( VCC                                           ),
    .p13 ( VCC                                           ),
    .p14 ( \N$/video-signals/video-signal-generator|w631 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ266 (
    .p1 ( \/video-signals/video-counter/COL2            ),
    .p2 ( \N$/video-signals/video-signal-generator|w556 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ277 (
    .p1 ( \/video-signals/video-counter/COL1            ),
    .p2 ( \N$/video-signals/video-signal-generator|w562 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ291 (
    .p1 ( \N$/video-signals/video-signal-generator|UCL262.9 ),
    .p2 ( \N$/video-signals/video-signal-generator|w632     )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ302 (
    .p1 ( \/video-signals/video-counter/LINE4           ),
    .p2 ( \N$/video-signals/video-signal-generator|w198 )
);

capcom_dl0921_NAND05 video_signals_video_signal_generator_UCJ303 (
    .p1 ( \N$/video-signals/video-signal-generator|w196     ),
    .p2 ( \N$/video-signals/video-signal-generator|w181     ),
    .p3 ( \N$/video-signals/video-signal-generator|w175     ),
    .p4 ( \N$/video-signals/video-signal-generator|w169     ),
    .p5 ( \N$/video-signals/video-signal-generator|w198     ),
    .p6 ( \N$/video-signals/video-signal-generator|UCJ303.6 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ306 (
    .p1 ( \/video-signals/video-counter/LINE0           ),
    .p2 ( \N$/video-signals/video-signal-generator|w129 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCJ307 (
    .p1  ( \N$/video-signals/video-signal-generator|w196      ),
    .p2  ( \N$/video-signals/video-signal-generator|w181      ),
    .p3  ( \N$/video-signals/video-signal-generator|w175      ),
    .p4  ( \N$/video-signals/video-signal-generator|w169      ),
    .p5  ( \/video-signals/video-counter/LINE4                ),
    .p6  ( \N$/video-signals/video-signal-generator|w129      ),
    .p7  ( \N$/video-signals/video-signal-generator|w150      ),
    .p8  ( \/stars/FLIP                                       ),
    .p9  ( \N$/video-signals/video-signal-generator|w216      ),
    .p10 ( VCC                                                ),
    .p11 ( \N$/video-signals/video-signal-generator|w135      ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCJ307.14 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCJ315 (
    .p1  ( \N$/video-signals/video-signal-generator|w196      ),
    .p2  ( \N$/video-signals/video-signal-generator|w181      ),
    .p3  ( \N$/video-signals/video-signal-generator|w175      ),
    .p4  ( \N$/video-signals/video-signal-generator|w169      ),
    .p5  ( \/video-signals/video-counter/LINE4                ),
    .p6  ( \/video-signals/video-counter/LINE0                ),
    .p7  ( \N$/video-signals/video-signal-generator|w150      ),
    .p8  ( \/stars/FLIP                                       ),
    .p9  ( \N$/video-signals/video-signal-generator|w216      ),
    .p10 ( VCC                                                ),
    .p11 ( \N$/video-signals/video-signal-generator|w135      ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCJ315.14 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ328 (
    .p1 ( \N$/video-signals/video-signal-generator|UCJ315.14 ),
    .p2 ( \/video-signals/video-signal-generator/UCJ328-Q    )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ329 (
    .p1 ( \/video-signals/video-counter/COL8            ),
    .p2 ( \N$/video-signals/video-signal-generator|w549 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ332 (
    .p1 ( \/video-signals/video-counter/COL7            ),
    .p2 ( \N$/video-signals/video-signal-generator|w507 )
);

capcom_dl0921_AND04 video_signals_video_signal_generator_UCJ333 (
    .p1 ( \N$/video-signals/video-signal-generator|w631 ),
    .p2 ( \/video-signals/video-counter/COL6            ),
    .p3 ( \/video-signals/video-counter/COL7            ),
    .p4 ( \/video-signals/video-counter/COL8            ),
    .p5 ( \N$/video-signals/video-signal-generator|w642 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCJ337 (
    .p1 ( \N$/video-signals/video-signal-generator|UCJ307.14 ),
    .p2 ( \/video-signals/video-signal-generator/UCJ337-Q    )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL252 (
    .p1 ( \/video-signals/video-counter/COL6            ),
    .p2 ( \N$/video-signals/video-signal-generator|w525 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL253 (
    .p1 ( \/video-signals/video-counter/COL8            ),
    .p2 ( \N$/video-signals/video-signal-generator|w620 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL255 (
    .p1 ( \/video-signals/video-counter/COL5            ),
    .p2 ( \N$/video-signals/video-signal-generator|w622 )
);

capcom_dl0921_AND03 video_signals_video_signal_generator_UCL256 (
    .p1 ( \N$/video-signals/video-signal-generator|w620 ),
    .p2 ( \N$/video-signals/video-signal-generator|w621 ),
    .p3 ( \N$/video-signals/video-signal-generator|w525 ),
    .p4 ( \N$/video-signals/video-signal-generator|w644 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL261 (
    .p1 ( \/video-signals/video-counter/COL3            ),
    .p2 ( \N$/video-signals/video-signal-generator|w548 )
);

capcom_dl0921_NAND08 video_signals_video_signal_generator_UCL262 (
    .p1 ( \N$/video-signals/video-signal-generator|w620     ),
    .p2 ( \N$/video-signals/video-signal-generator|w621     ),
    .p3 ( \N$/video-signals/video-signal-generator|w525     ),
    .p4 ( \N$/video-signals/video-signal-generator|w622     ),
    .p5 ( \N$/video-signals/video-signal-generator|w541     ),
    .p6 ( \N$/video-signals/video-signal-generator|w548     ),
    .p7 ( \N$/video-signals/video-signal-generator|w556     ),
    .p8 ( VCC                                               ),
    .p9 ( \N$/video-signals/video-signal-generator|UCL262.9 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCL272 (
    .p1  ( \/stars/FLIP                                       ),
    .p2  ( \N$/video-signals/video-signal-generator|w562      ),
    .p3  ( \N$/video-signals/video-counter|w2                 ),
    .p4  ( VCC                                                ),
    .p5  ( VCC                                                ),
    .p6  ( \N$/video-signals/video-signal-generator|w548      ),
    .p7  ( VCC                                                ),
    .p8  ( \N$/video-signals/video-signal-generator|w541      ),
    .p9  ( \N$/video-signals/video-signal-generator|w620      ),
    .p10 ( \N$/video-signals/video-signal-generator|w622      ),
    .p11 ( \N$/video-signals/video-signal-generator|w556      ),
    .p12 ( \/video-signals/video-counter/COL6                 ),
    .p13 ( \N$/video-signals/video-signal-generator|w621      ),
    .p14 ( \N$/video-signals/video-signal-generator|UCL272.14 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL280 (
    .p1 ( \/video-signals/video-counter/COL4            ),
    .p2 ( \N$/video-signals/video-signal-generator|w541 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL291 (
    .p1 ( \/video-signals/video-counter/LINE5           ),
    .p2 ( \N$/video-signals/video-signal-generator|w169 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCL313 (
    .p1  ( \N$/video-signals/video-signal-generator|w196      ),
    .p2  ( \N$/video-signals/video-signal-generator|w181      ),
    .p3  ( \N$/video-signals/video-signal-generator|w175      ),
    .p4  ( \N$/video-signals/video-signal-generator|w169      ),
    .p5  ( \/video-signals/video-counter/LINE4                ),
    .p6  ( \N$/video-signals/video-signal-generator|w129      ),
    .p7  ( \N$/video-signals/video-signal-generator|w150      ),
    .p8  ( \N$/video-signals/video-signal-generator|w197      ),
    .p9  ( \N$/video-signals/video-signal-generator|w216      ),
    .p10 ( VCC                                                ),
    .p11 ( \N$/video-signals/video-signal-generator|w135      ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCL313.14 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL321 (
    .p1 ( \/stars/FLIP                                  ),
    .p2 ( \N$/video-signals/video-signal-generator|w197 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL322 (
    .p1 ( \/video-signals/video-counter/COL6            ),
    .p2 ( \N$/video-signals/video-signal-generator|w427 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCL328 (
    .p1  ( \N$/video-signals/video-signal-generator|w565      ),
    .p2  ( \N$/video-signals/video-signal-generator|w549      ),
    .p3  ( \N$/video-signals/video-signal-generator|w507      ),
    .p4  ( \N$/video-signals/video-signal-generator|w427      ),
    .p5  ( \/video-signals/video-counter/COL5                 ),
    .p6  ( \/video-signals/video-counter/COL1                 ),
    .p7  ( \/video-signals/video-counter/COL4                 ),
    .p8  ( VCC                                                ),
    .p9  ( \/video-signals/video-counter/COL3                 ),
    .p10 ( VCC                                                ),
    .p11 ( \/video-signals/video-counter/COL2                 ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCL328.14 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCL336 (
    .p1  ( \/video-signals/video-signal-generator/UCL375-Q    ),
    .p2  ( \/video-signals/video-counter/COL8                 ),
    .p3  ( \/video-signals/video-counter/COL7                 ),
    .p4  ( \/video-signals/video-counter/COL6                 ),
    .p5  ( \N$/video-signals/video-signal-generator|w424      ),
    .p6  ( \/video-signals/video-counter/COL1                 ),
    .p7  ( \/video-signals/video-counter/COL4                 ),
    .p8  ( VCC                                                ),
    .p9  ( \/video-signals/video-counter/COL3                 ),
    .p10 ( VCC                                                ),
    .p11 ( \/video-signals/video-counter/COL2                 ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCL336.14 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL344 (
    .p1 ( \/video-signals/video-counter/COL5            ),
    .p2 ( \N$/video-signals/video-signal-generator|w424 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL345 (
    .p1 ( \N$/video-signals/video-signal-generator|UCL272.14 ),
    .p2 ( \N$/video-signals/video-signal-generator|w643      )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL347 (
    .p1 ( \/video-signals/video-signal-generator/~VBLANK ),
    .p2 ( \N$/video-signals/video-signal-generator|w645  )
);

capcom_dl0921_NOR03 video_signals_video_signal_generator_UCL348 (
    .p1 ( \N$/video-signals/video-signal-generator|w643  ),
    .p2 ( \N$/video-signals/video-signal-generator|w644  ),
    .p3 ( \N$/video-signals/video-signal-generator|w642  ),
    .p4 ( \/video-signals/video-signal-generator/~HBLANK )
);

capcom_dl0921_NOR04 video_signals_video_signal_generator_UCL350 (
    .p1 ( \N$/video-signals/video-signal-generator|UCL350.1 ),
    .p2 ( \N$/video-signals/video-signal-generator|w642     ),
    .p3 ( \N$/video-signals/video-signal-generator|w643     ),
    .p4 ( \N$/video-signals/video-signal-generator|w644     ),
    .p5 ( \N$/video-signals/video-signal-generator|w645     )
);

capcom_dl0921_M541C video_signals_video_signal_generator_UCL354 (
    .p1  ( \/video-signals/video-signal-generator/~DEBUG-HI ),
    .p2  ( \/video-signals/video-counter/LINE8              ),
    .p3  ( \/video-signals/video-counter/LINE7              ),
    .p4  ( \/video-signals/video-counter/LINE6              ),
    .p5  ( \/video-signals/video-counter/LINE5              ),
    .p6  ( \/video-signals/video-counter/LINE4              ),
    .p7  ( \/video-signals/video-counter/LINE3              ),
    .p8  ( \/video-signals/video-counter/LINE2              ),
    .p9  ( \/video-signals/video-counter/LINE1              ),
    .p11 ( \/debug/td-io/IN7                                ),
    .p12 ( \/debug/td-io/IN6                                ),
    .p13 ( \/debug/td-io/IN5                                ),
    .p14 ( \/debug/td-io/IN4                                ),
    .p15 ( \/debug/td-io/IN3                                ),
    .p16 ( \/debug/td-io/IN2                                ),
    .p17 ( \/debug/td-io/IN1                                ),
    .p18 ( \/debug/td-io/IN0                                )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCL375 (
    .p1 ( \N$/video-signals/video-signal-generator|UCL391.14 ),
    .p2 ( \/video-signals/video-signal-generator/UCL375-Q    )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCL383 (
    .p1  ( \N$/video-signals/video-signal-generator|w196      ),
    .p2  ( \/video-signals/video-counter/LINE7                ),
    .p3  ( \/video-signals/video-counter/LINE6                ),
    .p4  ( \/video-signals/video-counter/LINE5                ),
    .p5  ( \/video-signals/video-counter/LINE4                ),
    .p6  ( \N$/video-signals/video-signal-generator|w129      ),
    .p7  ( \/video-signals/video-counter/LINE3                ),
    .p8  ( VCC                                                ),
    .p9  ( \/video-signals/video-counter/LINE2                ),
    .p10 ( VCC                                                ),
    .p11 ( \/video-signals/video-counter/LINE1                ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCL383.14 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCL391 (
    .p1  ( \N$/video-signals/video-signal-generator|w196      ),
    .p2  ( \/video-signals/video-counter/LINE7                ),
    .p3  ( \/video-signals/video-counter/LINE6                ),
    .p4  ( \/video-signals/video-counter/LINE5                ),
    .p5  ( \/video-signals/video-counter/LINE4                ),
    .p6  ( \N$/video-signals/video-signal-generator|w129      ),
    .p7  ( \N$/video-signals/video-signal-generator|w150      ),
    .p8  ( VCC                                                ),
    .p9  ( \/video-signals/video-counter/LINE2                ),
    .p10 ( VCC                                                ),
    .p11 ( \/video-signals/video-counter/LINE1                ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCL391.14 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCO322 (
    .p1 ( \/video-signals/video-counter/LINE6           ),
    .p2 ( \N$/video-signals/video-signal-generator|w175 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCO328 (
    .p1 ( \N$/video-signals/video-signal-generator|UCL313.14 ),
    .p2 ( \/video-signals/video-signal-generator/UCO328-Q    )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCO372 (
    .p1 ( \/video-signals/video-counter/LINE3           ),
    .p2 ( \N$/video-signals/video-signal-generator|w150 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCR297 (
    .p1 ( \/video-signals/video-counter/LINE7           ),
    .p2 ( \N$/video-signals/video-signal-generator|w181 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCR322 (
    .p1 ( \N$/video-signals/video-signal-generator|UCR322.1 ),
    .p2 ( \N$/video-signals/video-signal-generator|w565     )
);

capcom_dl0921_NOR02 video_signals_video_signal_generator_UCR329 (
    .p1 ( \/video-signals/video-signal-generator/UCO328-Q   ),
    .p2 ( \/video-signals/video-signal-generator/UCJ328-Q   ),
    .p3 ( \N$/video-signals/video-signal-generator|UCR322.1 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCR332 (
    .p1  ( \N$/video-signals/video-signal-generator|w196   ),
    .p2  ( \/video-signals/video-counter/LINE7             ),
    .p3  ( \/video-signals/video-counter/LINE6             ),
    .p4  ( \/video-signals/video-counter/LINE5             ),
    .p5  ( \/video-signals/video-counter/LINE4             ),
    .p6  ( \N$/video-signals/video-signal-generator|w129   ),
    .p7  ( \N$/video-signals/video-signal-generator|w150   ),
    .p8  ( \/stars/FLIP                                    ),
    .p9  ( \N$/video-signals/video-signal-generator|w216   ),
    .p10 ( VCC                                             ),
    .p11 ( \N$/video-signals/video-signal-generator|w135   ),
    .p12 ( VCC                                             ),
    .p13 ( VCC                                             ),
    .p14 ( \/video-signals/video-signal-generator/UCR332-Q )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCR375 (
    .p1 ( \/video-signals/video-counter/LINE1           ),
    .p2 ( \N$/video-signals/video-signal-generator|w135 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCR384 (
    .p1 ( \/video-signals/video-counter/LINE2           ),
    .p2 ( \N$/video-signals/video-signal-generator|w216 )
);

capcom_dl0921_NOR02 video_signals_video_signal_generator_UCR385 (
    .p1 ( \/video-signals/video-signal-generator/UCR388-Q   ),
    .p2 ( \N$/video-signals/video-signal-generator|UCT388.2 ),
    .p3 ( \/video-signals/video-signal-generator/VSYNC      )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCR388 (
    .p1 ( \N$/video-signals/video-signal-generator|UCL383.14 ),
    .p2 ( \/video-signals/video-signal-generator/UCR388-Q    )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCR389 (
    .p1  ( \N$/video-signals/video-signal-generator|w196      ),
    .p2  ( \/video-signals/video-counter/LINE7                ),
    .p3  ( \/video-signals/video-counter/LINE6                ),
    .p4  ( \/video-signals/video-counter/LINE5                ),
    .p5  ( \/video-signals/video-counter/LINE4                ),
    .p6  ( VCC                                                ),
    .p7  ( \N$/video-signals/video-signal-generator|w150      ),
    .p8  ( VCC                                                ),
    .p9  ( \N$/video-signals/video-signal-generator|w216      ),
    .p10 ( VCC                                                ),
    .p11 ( VCC                                                ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCR389.14 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCR404 (
    .p1 ( \N$/video-signals/video-signal-generator|UCR389.14 ),
    .p2 ( \N$/video-signals/video-signal-generator|w17       )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCT330 (
    .p1 ( \N$/video-signals/video-signal-generator|UCJ303.6 ),
    .p2 ( \N$/video-signals/video-signal-generator|w6       )
);

capcom_dl0921_NAND06 video_signals_video_signal_generator_UCT335 (
    .p1 ( \/video-signals/video-counter/LINE4               ),
    .p2 ( \/video-signals/video-counter/LINE5               ),
    .p3 ( \/video-signals/video-counter/LINE6               ),
    .p4 ( \/video-signals/video-counter/LINE7               ),
    .p5 ( \N$/video-signals/video-signal-generator|w196     ),
    .p6 ( \/video-signals/video-signal-generator/UCR332-Q   ),
    .p9 ( \N$/video-signals/video-signal-generator|UCT335.9 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCT340 (
    .p1 ( \N$/video-signals/video-signal-generator|UCT335.9 ),
    .p2 ( \N$/video-signals/video-signal-generator|w12      )
);

capcom_dl0921_NOR04 video_signals_video_signal_generator_UCT341 (
    .p1 ( \/video-signals/video-signal-generator/~VBLANK  ),
    .p2 ( \N$/video-signals/video-signal-generator|w6     ),
    .p3 ( \/video-signals/video-counter/LINE8             ),
    .p4 ( \N$/video-signals/video-signal-generator|w12    ),
    .p5 ( \/video-signals/video-signal-generator/UCJ337-Q )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCT345 (
    .p1 ( \/video-signals/video-counter/LINE8           ),
    .p2 ( \N$/video-signals/video-signal-generator|w196 )
);

capcom_dl0921_NAND13 video_signals_video_signal_generator_UCT365 (
    .p1  ( \N$/video-signals/video-signal-generator|w196      ),
    .p2  ( \/video-signals/video-counter/LINE7                ),
    .p3  ( \/video-signals/video-counter/LINE6                ),
    .p4  ( \/video-signals/video-counter/LINE5                ),
    .p5  ( \/video-signals/video-counter/LINE4                ),
    .p6  ( VCC                                                ),
    .p7  ( \N$/video-signals/video-signal-generator|w150      ),
    .p8  ( VCC                                                ),
    .p9  ( \/video-signals/video-counter/LINE2                ),
    .p10 ( VCC                                                ),
    .p11 ( \N$/video-signals/video-signal-generator|w135      ),
    .p12 ( VCC                                                ),
    .p13 ( VCC                                                ),
    .p14 ( \N$/video-signals/video-signal-generator|UCT365.14 )
);

capcom_dl0921_NAND08 video_signals_video_signal_generator_UCT373 (
    .p1 ( \N$/video-signals/video-signal-generator|w196     ),
    .p2 ( \/video-signals/video-counter/LINE7               ),
    .p3 ( \/video-signals/video-counter/LINE6               ),
    .p4 ( \/video-signals/video-counter/LINE5               ),
    .p5 ( \/video-signals/video-counter/LINE4               ),
    .p6 ( \/video-signals/video-counter/LINE3               ),
    .p7 ( \/video-signals/video-counter/LINE2               ),
    .p8 ( \N$/video-signals/video-signal-generator|w135     ),
    .p9 ( \N$/video-signals/video-signal-generator|UCT373.9 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCT388 (
    .p1 ( \N$/video-signals/video-signal-generator|UCT373.9 ),
    .p2 ( \N$/video-signals/video-signal-generator|UCT388.2 )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCT393 (
    .p1 ( \N$/video-signals/video-signal-generator|UCT365.14 ),
    .p2 ( \N$/video-signals/video-signal-generator|w18       )
);

capcom_dl0921_INV01 video_signals_video_signal_generator_UCT404 (
    .p1 ( \N$/video-signals/video-signal-generator|UCT404.1 ),
    .p2 ( \N$/video-signals/video-signal-generator|UCT404.2 )
);

capcom_dl0921_NOR02 video_signals_video_signal_generator_UCT405 (
    .p1 ( \N$/video-signals/video-signal-generator|w18      ),
    .p2 ( \N$/video-signals/video-signal-generator|w17      ),
    .p3 ( \N$/video-signals/video-signal-generator|UCT404.1 )
);

//========================================================================
// video-signals/video-signal-registries:
//========================================================================
capcom_dl0921_BUF12 video_signals_video_signal_registries_UAA482 (
    .p1 ( \N$/video-signals/video-signal-registries|UBH436.3 ),
    .p2 ( \/video-signals/VSYNC                              )
);

capcom_dl0921_BUF12 video_signals_video_signal_registries_UAA485 (
    .p1 ( \N$/video-signals/video-signal-registries|UBH445.3 ),
    .p2 ( \/video-signals/HSYNC                              )
);

capcom_dl0921_BUF12 video_signals_video_signal_registries_UAA506 (
    .p1 ( \N$/video-signals/video-signal-registries|UBH441.3 ),
    .p2 ( \/video-signals/~VBLANK                            )
);

capcom_dl0921_BUF12 video_signals_video_signal_registries_UAA511 (
    .p1 ( \N$/video-signals/video-signal-registries|UBH450.3 ),
    .p2 ( \/video-signals/~HBLANK                            )
);

capcom_dl0921_NBUF02 video_signals_video_signal_registries_UBH331 (
    .p1 ( \/lut-assembly/lut-storage/CLK                ),
    .p2 ( \N$/video-signals/video-signal-registries|w88 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBH436 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w80      ),
    .p3 ( \N$/video-signals/video-signal-registries|UBH436.3 ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBH436.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBH441 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w96      ),
    .p3 ( \N$/video-signals/video-signal-registries|UBH441.3 ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBH441.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBH445 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w81      ),
    .p3 ( \N$/video-signals/video-signal-registries|UBH445.3 ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBH445.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBH450 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w99      ),
    .p3 ( \N$/video-signals/video-signal-registries|UBH450.3 ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBH450.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBH454 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w82      ),
    .p3 ( \N$/video-signals/video-signal-registries|UBH454.3 ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBH454.5 )
);

capcom_dl0921_BUF12 video_signals_video_signal_registries_UBK435 (
    .p1 ( \N$/video-signals/video-signal-registries|UBH454.3 ),
    .p2 ( \/lut-assembly/BLANK                               )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR401 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w28      ),
    .p3 ( \N$/video-signals/video-signal-registries|w54      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR401.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR406 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w44      ),
    .p3 ( \N$/video-signals/video-signal-registries|w71      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR406.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR410 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w29      ),
    .p3 ( \N$/video-signals/video-signal-registries|w55      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR410.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR415 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w47      ),
    .p3 ( \N$/video-signals/video-signal-registries|w74      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR415.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR419 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w30      ),
    .p3 ( \N$/video-signals/video-signal-registries|w56      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR419.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR429 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w54      ),
    .p3 ( \N$/video-signals/video-signal-registries|w80      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR429.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR434 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w71      ),
    .p3 ( \N$/video-signals/video-signal-registries|w96      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR434.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR438 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w55      ),
    .p3 ( \N$/video-signals/video-signal-registries|w81      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR438.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR442 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w74      ),
    .p3 ( \N$/video-signals/video-signal-registries|w99      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR442.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBR447 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \N$/video-signals/video-signal-registries|w56      ),
    .p3 ( \N$/video-signals/video-signal-registries|w82      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBR447.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBU388 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \/video-signals/video-signal-generator/VSYNC       ),
    .p3 ( \N$/video-signals/video-signal-registries|w28      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBU388.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBU392 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \/video-signals/video-signal-generator/~VBLANK     ),
    .p3 ( \N$/video-signals/video-signal-registries|w44      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBU392.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBU396 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \/video-signals/video-signal-generator/HSYNC       ),
    .p3 ( \N$/video-signals/video-signal-registries|w29      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBU396.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBU401 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \/video-signals/video-signal-generator/~HBLANK     ),
    .p3 ( \N$/video-signals/video-signal-registries|w47      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBU401.5 )
);

capcom_dl0921_DFFCOR video_signals_video_signal_registries_UBU405 (
    .p1 ( \N$/video-signals/video-signal-registries|w88      ),
    .p2 ( \/video-signals/video-signal-generator/BLANK       ),
    .p3 ( \N$/video-signals/video-signal-registries|w30      ),
    .p4 ( \/video-signals/~RESET                             ),
    .p5 ( \N$/video-signals/video-signal-registries|UBU405.5 )
);

//========================================================================
// xpd-out:
//========================================================================
capcom_dl0921_NBUF03 xpd_out_UAA162 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/~ROMOE )
);

capcom_dl0921_OUTTRI xpd_out_UAA164 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT6   ),
    .p3 ( \/DPD6           )
);

capcom_dl0921_OUTTRI xpd_out_UAA168 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT4   ),
    .p3 ( \/DPD4           )
);

capcom_dl0921_OUTTRI xpd_out_UAA182 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT3   ),
    .p3 ( \/DPD3           )
);

capcom_dl0921_OUTTRI xpd_out_UAA186 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT5   ),
    .p3 ( \/DPD5           )
);

capcom_dl0921_OUTTRI xpd_out_UAA191 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT7   ),
    .p3 ( \/DPD7           )
);

capcom_dl0921_OUTTRI xpd_out_UAA201 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT1   ),
    .p3 ( \/DPD1           )
);

capcom_dl0921_OUTTRI xpd_out_UAA216 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT7   ),
    .p3 ( \/CPD7           )
);

capcom_dl0921_OUTTRI xpd_out_UAA227 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT6   ),
    .p3 ( \/CPD6           )
);

capcom_dl0921_OUTTRI xpd_out_UAA231 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT2   ),
    .p3 ( \/DPD2           )
);

capcom_dl0921_OUTTRI xpd_out_UAA241 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT5   ),
    .p3 ( \/CPD5           )
);

capcom_dl0921_OUTTRI xpd_out_UAA245 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT0   ),
    .p3 ( \/DPD0           )
);

capcom_dl0921_OUTTRI xpd_out_UAA256 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT4   ),
    .p3 ( \/CPD4           )
);

capcom_dl0921_OUTTRI xpd_out_UAA269 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT3   ),
    .p3 ( \/CPD3           )
);

capcom_dl0921_OUTTRI xpd_out_UAA291 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT2   ),
    .p3 ( \/CPD2           )
);

capcom_dl0921_OUTTRI xpd_out_UAA295 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT1   ),
    .p3 ( \/CPD1           )
);

capcom_dl0921_OUTTRI xpd_out_UAA300 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT0   ),
    .p3 ( \/CPD0           )
);

capcom_dl0921_OUTTRI xpd_out_UAA328 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT6   ),
    .p3 ( \/BPD6           )
);

capcom_dl0921_OUTTRI xpd_out_UAA337 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT4   ),
    .p3 ( \/BPD4           )
);

capcom_dl0921_OUTTRI xpd_out_UAA346 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT7   ),
    .p3 ( \/BPD7           )
);

capcom_dl0921_OUTTRI xpd_out_UAA351 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT3   ),
    .p3 ( \/BPD3           )
);

capcom_dl0921_OUTTRI xpd_out_UAA356 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT5   ),
    .p3 ( \/BPD5           )
);

capcom_dl0921_OUTTRI xpd_out_UAA383 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT7   ),
    .p3 ( \/APD7           )
);

capcom_dl0921_OUTTRI xpd_out_UAA387 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT2   ),
    .p3 ( \/BPD2           )
);

capcom_dl0921_BUF12 xpd_out_UAA392 (
    .p1 ( \/xpd-out/~OE    ),
    .p2 ( \N$/xpd-out|w134 )
);

capcom_dl0921_BUF12 xpd_out_UAA394 (
    .p1 ( \/xpd-out/~OE    ),
    .p2 ( \N$/xpd-out|w134 )
);

capcom_dl0921_OUTTRI xpd_out_UAA396 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT5   ),
    .p3 ( \/APD5           )
);

capcom_dl0921_OUTTRI xpd_out_UAA401 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT1   ),
    .p3 ( \/BPD1           )
);

capcom_dl0921_OUTTRI xpd_out_UAA407 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT0   ),
    .p3 ( \/BPD0           )
);

capcom_dl0921_OUTTRI xpd_out_UAA412 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT2   ),
    .p3 ( \/APD2           )
);

capcom_dl0921_OUTTRI xpd_out_UAA416 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT4   ),
    .p3 ( \/APD4           )
);

capcom_dl0921_OUTTRI xpd_out_UAA463 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT1   ),
    .p3 ( \/APD1           )
);

capcom_dl0921_BUF12 xpd_out_UAA467 (
    .p1 ( \/xpd-out/~OE    ),
    .p2 ( \N$/xpd-out|w134 )
);

capcom_dl0921_OUTTRI xpd_out_UAA488 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT3   ),
    .p3 ( \/APD3           )
);

capcom_dl0921_OUTTRI xpd_out_UAA494 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT0   ),
    .p3 ( \/APD0           )
);

capcom_dl0921_OUTTRI xpd_out_UBD444 (
    .p1 ( \N$/xpd-out|w134 ),
    .p2 ( \/xpd-out/OUT6   ),
    .p3 ( \/APD6           )
);

endmodule
