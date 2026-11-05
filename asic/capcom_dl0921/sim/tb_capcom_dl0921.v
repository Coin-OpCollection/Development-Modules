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
//  System testbench for the CAPCOM DL-0921 (CPS-B-21) netlist.
//
//  The CPS1 video system at gate level on a model of the A-, B- and
//  C-boards, loaded with one frame of game state.
//
//  DUTs:
//    a - capcom_dl0311, the CPS-A-01 (DL-0311) netlist
//    b - capcom_dl0921
//
//  Board Model:
//    - CLK 16 MHz to both chips; the CPS-A-01's ~RESETI resets the CPS-B-21
//    - CPU bus: CA pulled up; CD holds its last value when undriven
//    - GFX RAM 0x900000-0x92FFFF drives CD while the CPS-A-01 owns the bus,
//      granted two CLK after its ~BR: the data follows the address after
//      +ramacc, or with +asxwin only while the select window ASX =
//      NOR(CK250, CKDLY) is low, from 73 ns after a CK250 fall, valid from
//      178 ns
//    - graphics ROM: the game PAL from +mapper, one range per line
//      ("type-mask start end base mask", hex, the first hit wins; ROMA22-20
//      the layer, ROMA19-3 the 64-byte unit; no hit reads 0xff); the data
//      +romacc after ROMA and +romoe after CK500, which selects bank 2
//      while high
//    - palette RAM 4K x 16, written from CD on the /LUTWR rising edge
//    - sprite frame buffer: four hitachi_hm53461 rows, two per bank
//    - the CPS-B-21 sees two-state copies of the CPS-A-01 outputs and of the
//      frame buffer's serial data (x and z read as 0)
//    - CPS-B-21 key: default mode, or +key shifted in through the security
//      pins before the reset: SEC-E2 high and SEC-/E1 low, four SEC-STROBE
//      pulses, then DATA on CD0 clocked by CD1: 1 0 1 0 1 1, twelve 1s and
//      the 144 key bits, byte 0 first, MSB first
//    - the frame state's registers are written through the bus after the
//      reset, the palette base last
//
//  Plusargs:
//    +dump=<prefix>    frame state (<prefix>_gfxram.bin, _cpsa.bin,
//                      _cpsb.bin)
//    +gfx=<file>       the graphics ROM in gfx-region layout
//    +game=<name> +frames=<n> +out=<prefix for the output files>
//    +mapper=<file> +rlayer=<hex> +rprio=<hex> +rpal=<hex> [+key=<hex>]
//                      the game's PAL ranges, CPS-B-21 register offsets and
//                      key
//    +romacc=<ns>      ROM access from ROMA (default 180)
//    +romoe=<ns>       ROM access from CK500 (default 60)
//    +ramacc=<ns>      GFX RAM access (default 100)
//    +asxwin=<0|1>     the GFX RAM select window (default 1)
//    +bshift=<CLK>     LI and FI reach the CPS-B-21 that many CLK late
//    +liclean          LI to the CPS-B-21 without the CPS-A-01's hazard
//                      pulse: an LI rise passes 62 us after the last, a
//                      passed pulse under 50 ns does not count
//    +rewendly=<CLK>   ~REWEN reaches the CPS-A-01 that many CLK late
//    +xsrev            XS4-0 on the CPS-B-21's XS0-4
//    +xs3inv           XS3 inverted to the CPS-B-21
//    +bitrev           ROM data bit n on xPD 7-n
//    +rw<n>t=<ns> +rw<n>a=<hex> +rw<n>v=<hex>, +rr<n>t=<ns> +rr<n>a=<hex>
//                      timed CPS-B-21 writes and reads, n = 1-8, earliest
//                      first
//    +lutlog           every palette write in lutlog.txt
//    +rastlog          every CPS-B-21 ~OBJUP edge with the line and pixel
//                      counters in <out>_raster.txt; +rastlines adds
//                      every LI / FI edge with counters 1 and 2
//    +fbdump           both frame-buffer banks at each FI
//
//  Outputs:
//    <out>_f<n>.txt      one line per LI: per CLK, LUTA (3 hex) and
//                        {~HBLANK, ~VBLANK, HSYNC, VSYNC} (1 hex)
//    <out>_pal_f<n>.txt  the palette RAM at each FI
//    <out>_fb_f<n>.txt   the frame buffer at each FI (+fbdump)
//  An FI counts 1 ms after the last; the run ends after +frames frames, or
//  at 120 ms.
//============================================================================

`timescale 1ns/1ps

module tb_capcom_dl0921;

//========================================================================
// Clock:
//========================================================================
reg clk = 0;

always #31.25 clk = ~clk;

//========================================================================
// CPU Bus:
//========================================================================
reg        n_reset = 0;
reg        n_csa = 1;
reg        n_csb = 1;
reg        n_wr = 1;
reg        n_rd = 1;
reg [23:1] host_a = 0;
reg [15:0] host_d = 0;
reg        host_drive = 0;
reg        host_adrive = 0;
reg        n_bgack = 1;
reg        sec_strobe = 0;
reg        sec_ne1 = 1;
reg        sec_e2 = 0;
reg        sec_mode = 1;
wire       sec_strobe_w = sec_strobe;
wire       sec_ne1_w = sec_ne1;
wire       sec_e2_w = sec_e2;
wire       sec_mode_w = sec_mode;

tri1   [23:1] ca;
trireg [15:0] cd;

wire n_br;

//========================================================================
// GFX RAM:
//========================================================================
reg  [15:0] ram [0:24'h17fff];
wire        in_ram = ca[23:16] >= 8'h90 && ca[23:16] <= 8'h92;
wire [16:0] ram_a = {ca[23:16] - 8'h90, ca[15:1]};
wire        master = !n_bgack;

assign ca = (host_drive || host_adrive) ? host_a : 23'bz;

integer ramacc = 100;

reg [16:0] ram_a_d = 0;
reg        in_ram_d = 0;

always @(ram_a) begin
    ram_a_d <= #(ramacc) ram_a;
end

always @(in_ram) begin
    in_ram_d <= #(ramacc) in_ram;
end

integer asxwin = 1;

reg        asx_on = 0;
reg        asx_ok = 0;
reg [15:0] asx_d = 0;

assign cd = host_drive ? host_d : master ? (asxwin ? (asx_on ? (asx_ok ? asx_d : 16'bx) : 16'bz) :
                                           (in_ram_d ? ram[ram_a_d] : 16'h0000)) : 16'bz;

//========================================================================
// Bus Arbitration:
//========================================================================
reg setup_done = 0;
reg host_busy = 0;

always @(posedge clk) begin
    if(!n_br && n_bgack && setup_done && !host_busy) begin
        repeat(2) @(posedge clk);
        n_bgack <= 0;
    end
    else if(n_br && !n_bgack) n_bgack <= 1;
end

tri1 w_rd;

assign w_rd = n_bgack ? n_rd : 1'bz;

wire n_csa_w = n_csa;
wire n_csb_w = n_csb;
wire w_clk = clk;
wire w_reset = n_reset;
wire w_bgack = n_bgack;
wire w_wr = n_wr;
wire w1 = 1'b1;
wire w0 = 1'b0;

//========================================================================
// Chip-to-Chip Nets:
//========================================================================
wire [22:0] roma;
wire  [4:0] cb;
wire  [4:0] xs;
wire  [1:0] cpc;
wire  [3:0] plwed;
wire        cden;
wire        xsel;
wire        flip;
wire        n_reseti;
wire        ck250;
wire        ck125;
wire        fi;
wire        li;
wire        n_wstrom;
wire        wstlut;
wire        n_wstobj;
wire        lutpro;

always @(negedge ck250) begin
    if(asxwin) begin
        asx_on <= 0;
        asx_ok <= 0;
        #73 asx_on <= 1;
        #105 begin
            asx_d <= in_ram ? ram[ram_a] : 16'h0000;
            asx_ok <= 1;
        end
    end
end

wire        objeo;
wire        n_objup_a;
wire        n_objup_b;
wire        frame;
wire        n_rewen;
wire [11:0] luta;
wire [11:0] td;
wire        n_romoe;
wire        n_lutoe;
wire        n_lutwr;
wire        n_clk8m_b;
wire        n_ck10;
wire        ck500;
wire        hsync;
wire        n_hblank;
wire        vsync;
wire        n_vblank;

//========================================================================
// Sprite Frame Buffer:
//========================================================================
wire  [7:0] aa;
wire  [7:0] ba;
wire [12:4] ad;
wire [12:4] bd;
wire        n_acas0;
wire        n_acas1;
wire        n_asoe0;
wire        n_asoe1;
wire        n_asck;
wire        n_adtoe;
wire        n_fwe;
wire        n_fras;
wire        n_bcas0;
wire        n_bcas1;
wire        n_bsoe0;
wire        n_bsoe1;
wire        n_bsck;
wire        n_bdtoe;
wire  [3:0] fad;
wire  [3:0] fbd;
wire [12:0] asd;
wire [12:0] bsd;

hitachi_hm53461 #(
    .NAME ( "A0" )
) va0 (
    .RASn  ( n_fras    ),
    .CASn  ( n_acas0   ),
    .WEn   ( n_fwe     ),
    .DTOEn ( n_adtoe   ),
    .SC    ( n_asck    ),
    .SOEn  ( n_asoe0   ),
    .A     ( aa        ),
    .D     ( {ad, fad} ),
    .SD    ( asd       )
);

hitachi_hm53461 #(
    .NAME ( "A1" )
) va1 (
    .RASn  ( n_fras    ),
    .CASn  ( n_acas1   ),
    .WEn   ( n_fwe     ),
    .DTOEn ( n_adtoe   ),
    .SC    ( n_asck    ),
    .SOEn  ( n_asoe1   ),
    .A     ( aa        ),
    .D     ( {ad, fad} ),
    .SD    ( asd       )
);

hitachi_hm53461 #(
    .NAME ( "B0" )
) vb0 (
    .RASn  ( n_fras    ),
    .CASn  ( n_bcas0   ),
    .WEn   ( n_fwe     ),
    .DTOEn ( n_bdtoe   ),
    .SC    ( n_bsck    ),
    .SOEn  ( n_bsoe0   ),
    .A     ( ba        ),
    .D     ( {bd, fbd} ),
    .SD    ( bsd       )
);

hitachi_hm53461 #(
    .NAME ( "B1" )
) vb1 (
    .RASn  ( n_fras    ),
    .CASn  ( n_bcas1   ),
    .WEn   ( n_fwe     ),
    .DTOEn ( n_bdtoe   ),
    .SC    ( n_bsck    ),
    .SOEn  ( n_bsoe1   ),
    .A     ( ba        ),
    .D     ( {bd, fbd} ),
    .SD    ( bsd       )
);

//========================================================================
// Graphics ROM:
//========================================================================
reg [7:0] gfx [0:24'h7fffff];

reg [8*16-1:0] game;

reg  [7:0] m_t [0:15];
reg [16:0] m_s [0:15];
reg [16:0] m_e [0:15];
reg [16:0] m_k [0:15];
reg [23:0] m_b [0:15];

integer m_n = 0;

function [24:0] gmap(input [22:0] a);
    integer    k;
    reg        hit;
    reg [16:0] v;
    begin
        v = a[19:3];
        hit = 0;
        gmap = 25'd0;
        for(k = 0; k < m_n; k = k + 1) begin
            if(!hit && m_t[k][a[22:20]] && v >= m_s[k] && v <= m_e[k]) begin
                hit = 1;
                gmap = {1'b1, m_b[k] + {v & m_k[k], a[2:0], 3'b000}};
            end
        end
    end
endfunction

integer tacc = 180;
integer toe = 60;

reg [22:0] roma_d = 0;
reg        ck500_d = 0;

always @(roma) begin
    roma_d <= #(tacc) roma;
end

always @(ck500) begin
    ck500_d <= #(toe) ck500;
end

wire [24:0] gm = gmap(roma_d);
wire        bank2 = ck500_d;
wire [23:0] gofs = gm[23:0] + {bank2, 2'b00};

reg bitrev = 0;

function [7:0] rev8(input [7:0] v);
    integer k;
    begin
        for(k = 0; k < 8; k = k + 1) rev8[k] = v[7 - k];
    end
endfunction

function [7:0] rom(input [23:0] o);
    rom = !gm[24] ? 8'hff : bitrev ? rev8(gfx[o]) : gfx[o];
endfunction

wire [7:0] apd = rom(gofs + 0);
wire [7:0] bpd = rom(gofs + 1);
wire [7:0] cpd = rom(gofs + 2);
wire [7:0] dpd = rom(gofs + 3);

//========================================================================
// Palette RAM:
//========================================================================
reg [15:0] pal [0:4095];

always @(posedge n_lutwr) begin
    pal[luta] <= cd;
end

integer lutfd = 0;

initial begin
    if($test$plusargs("lutlog")) lutfd = $fopen("lutlog.txt", "w");
end

always @(posedge n_lutwr) begin
    if(lutfd) $fdisplay(lutfd, "%0t %03x %04x %06x %b", $time, luta, cd, {ca, 1'b0}, n_bgack);
end

//========================================================================
// CPS-B-21 Inputs:
//========================================================================
function [22:0] two(input [22:0] v);
    integer k;
    begin
        for(k = 0; k < 23; k = k + 1) two[k] = (v[k] === 1'b1);
    end
endfunction

reg        xsrev = 0;
wire [4:0] xs_t = two(xs);
reg        xs3inv = 0;
wire [4:0] xs_r = xsrev ? {xs_t[0], xs_t[1], xs_t[2], xs_t[3], xs_t[4]} : xs_t;
wire [4:0] xs_b = xs_r ^ {1'b0, xs3inv, 3'b000};
wire [4:0] cb_b = two(cb);
wire [1:0] cpc_b = two(cpc);
wire [8:0] asd_b = two(asd[8:0]);
wire [8:0] bsd_b = two(bsd[8:0]);
wire       xsel_b = two(xsel);
wire       objeo_b = two(objeo);
wire       frame_b = two(frame);
wire       lutpro_b = two(lutpro);

integer bshift = 0;

reg li_d = 0;
reg fi_d = 0;

always @(li) begin
    li_d <= #(bshift * 62.5) li;
end

always @(fi) begin
    fi_d <= #(bshift * 62.5) fi;
end

reg li_c = 0;
reg liclean = 0;

realtime li_last = -1.0e9;
realtime li_prev = -1.0e9;

initial begin
    liclean = $test$plusargs("liclean");
end

always @(li) begin
    if(li) begin
        if($realtime - li_last > 62000.0) begin
            li_c = 1;
            li_prev = li_last;
            li_last = $realtime;
        end
    end
    else begin
        if(li_c && $realtime - li_last < 50.0) li_last = li_prev;
        li_c = 0;
    end
end

wire li_s = bshift ? li_d : (liclean ? li_c : li);
wire fi_s = bshift ? fi_d : fi;

integer rewendly = 0;

reg n_rewen_d = 0;

always @(n_rewen) begin
    n_rewen_d <= #(rewendly * 62.5) n_rewen;
end

wire n_rewen_a = rewendly ? n_rewen_d : n_rewen;
wire n_wstrom_b = two(n_wstrom);
wire wstlut_b = two(wstlut);
wire n_reseti_b = two(n_reseti);
wire fi_b = two(fi_s);
wire li_b = two(li_s);
wire flip_b = two(flip);
wire cden_b = two(cden);

//========================================================================
// DL-0311:
//========================================================================
capcom_dl0311 a (
    .P1_n_RD       ( w_rd      ),
    .P2_n_CS       ( n_csa_w   ),
    .P3_n_TEST3    ( w1        ),
    .P4_CLK        ( w_clk     ),
    .P5_n_TEST2    ( w1        ),
    .P6_n_TEST1    ( w1        ),
    .P7_AA0        ( aa[0]     ),
    .P8_AA1        ( aa[1]     ),
    .P9_AA2        ( aa[2]     ),
    .P10_AA3       ( aa[3]     ),
    .P11_AA4       ( aa[4]     ),
    .P12_AA5       ( aa[5]     ),
    .P13_AA6       ( aa[6]     ),
    .P14_AA7       ( aa[7]     ),
    .P15_n_ACAS0   ( n_acas0   ),
    .P16_n_ACAS1   ( n_acas1   ),
    .P17_n_ASOE0   ( n_asoe0   ),
    .P18_n_ASOE1   ( n_asoe1   ),
    .P19_GND       ( w0        ),
    .P20_n_ASCK    ( n_asck    ),
    .P21_n_ADTOE   ( n_adtoe   ),
    .P22_AD4       ( ad[4]     ),
    .P23_AD5       ( ad[5]     ),
    .P24_AD6       ( ad[6]     ),
    .P25_AD7       ( ad[7]     ),
    .P26_AD8       ( ad[8]     ),
    .P27_AD9       ( ad[9]     ),
    .P28_AD10      ( ad[10]    ),
    .P29_AD11      ( ad[11]    ),
    .P30_AD12      ( ad[12]    ),
    .P31_n_FWE     ( n_fwe     ),
    .P32_n_FRAS    ( n_fras    ),
    .P33_BA0       ( ba[0]     ),
    .P34_BA1       ( ba[1]     ),
    .P35_BA2       ( ba[2]     ),
    .P36_BA3       ( ba[3]     ),
    .P37_BA4       ( ba[4]     ),
    .P38_BA5       ( ba[5]     ),
    .P39_BA6       ( ba[6]     ),
    .P40_BA7       ( ba[7]     ),
    .P41_n_BCAS0   ( n_bcas0   ),
    .P42_n_BCAS1   ( n_bcas1   ),
    .P43_n_BSOE0   ( n_bsoe0   ),
    .P44_n_BSOE1   ( n_bsoe1   ),
    .P45_VCC       ( w1        ),
    .P46_n_BSCK    ( n_bsck    ),
    .P47_n_BDTOE   ( n_bdtoe   ),
    .P48_BD4       ( bd[4]     ),
    .P49_BD5       ( bd[5]     ),
    .P50_BD6       ( bd[6]     ),
    .P51_BD7       ( bd[7]     ),
    .P52_BD8       ( bd[8]     ),
    .P53_BD9       ( bd[9]     ),
    .P54_BD10      ( bd[10]    ),
    .P55_BD11      ( bd[11]    ),
    .P56_BD12      ( bd[12]    ),
    .P57_n_REWEN   ( n_rewen_a ),
    .P58_OBJEO     ( objeo     ),
    .P59_n_OBJUP   ( n_objup_a ),
    .P60_FRAME     ( frame     ),
    .P61_XS0       ( xs[0]     ),
    .P62_XS1       ( xs[1]     ),
    .P63_XS2       ( xs[2]     ),
    .P64_XS3       ( xs[3]     ),
    .P65_XS4       ( xs[4]     ),
    .P66_CPC0      ( cpc[0]    ),
    .P67_CPC1      ( cpc[1]    ),
    .P68_CDEN      ( cden      ),
    .P69_XSEL      ( xsel      ),
    .P70_GND       ( w0        ),
    .P71_PL0WED    ( plwed[0]  ),
    .P72_PL1WED    ( plwed[1]  ),
    .P73_PL2WED    ( plwed[2]  ),
    .P74_PL3WED    ( plwed[3]  ),
    .P75_ROMA0     ( roma[0]   ),
    .P76_ROMA1     ( roma[1]   ),
    .P77_ROMA2     ( roma[2]   ),
    .P78_ROMA3     ( roma[3]   ),
    .P79_ROMA4     ( roma[4]   ),
    .P80_ROMA5     ( roma[5]   ),
    .P81_VCC       ( w1        ),
    .P82_ROMA6     ( roma[6]   ),
    .P83_ROMA7     ( roma[7]   ),
    .P84_ROMA8     ( roma[8]   ),
    .P85_ROMA9     ( roma[9]   ),
    .P86_ROMA10    ( roma[10]  ),
    .P87_ROMA11    ( roma[11]  ),
    .P88_ROMA12    ( roma[12]  ),
    .P89_ROMA13    ( roma[13]  ),
    .P90_ROMA14    ( roma[14]  ),
    .P91_ROMA15    ( roma[15]  ),
    .P92_ROMA16    ( roma[16]  ),
    .P93_ROMA17    ( roma[17]  ),
    .P94_ROMA18    ( roma[18]  ),
    .P95_ROMA19    ( roma[19]  ),
    .P96_ROMA20    ( roma[20]  ),
    .P97_ROMA21    ( roma[21]  ),
    .P98_ROMA22    ( roma[22]  ),
    .P99_CB0       ( cb[0]     ),
    .P100_CB1      ( cb[1]     ),
    .P101_CB2      ( cb[2]     ),
    .P102_CB3      ( cb[3]     ),
    .P103_CB4      ( cb[4]     ),
    .P104_FLIP     ( flip      ),
    .P105_n_RESETI ( n_reseti  ),
    .P106_n_RESET  ( w_reset   ),
    .P107_CK250    ( ck250     ),
    .P108_HSYNC    ( w1        ),
    .P109_CK125    ( ck125     ),
    .P110_VSYNC    ( w1        ),
    .P111_FI       ( fi        ),
    .P112_LI       ( li        ),
    .P113_n_WSTROM ( n_wstrom  ),
    .P114_WSTLUT   ( wstlut    ),
    .P115_n_WSTOBJ ( n_wstobj  ),
    .P116_LUTPRO   ( lutpro    ),
    .P117_n_BR     ( n_br      ),
    .P118_n_BGACK  ( w_bgack   ),
    .P119_GND      ( w0        ),
    .P120_CD0      ( cd[0]     ),
    .P121_CD1      ( cd[1]     ),
    .P122_CD2      ( cd[2]     ),
    .P123_CD3      ( cd[3]     ),
    .P124_CD4      ( cd[4]     ),
    .P125_CD5      ( cd[5]     ),
    .P126_CD6      ( cd[6]     ),
    .P127_CD7      ( cd[7]     ),
    .P128_CD8      ( cd[8]     ),
    .P129_CD9      ( cd[9]     ),
    .P130_CD10     ( cd[10]    ),
    .P131_CD11     ( cd[11]    ),
    .P132_CD12     ( cd[12]    ),
    .P133_CD13     ( cd[13]    ),
    .P134_CD14     ( cd[14]    ),
    .P135_CD15     ( cd[15]    ),
    .P136_VCC      ( w1        ),
    .P137_CA1      ( ca[1]     ),
    .P138_CA2      ( ca[2]     ),
    .P139_CA3      ( ca[3]     ),
    .P140_CA4      ( ca[4]     ),
    .P141_CA5      ( ca[5]     ),
    .P142_CA6      ( ca[6]     ),
    .P143_CA7      ( ca[7]     ),
    .P144_CA8      ( ca[8]     ),
    .P145_CA9      ( ca[9]     ),
    .P146_CA10     ( ca[10]    ),
    .P147_CA11     ( ca[11]    ),
    .P148_CA12     ( ca[12]    ),
    .P149_CA13     ( ca[13]    ),
    .P150_CA14     ( ca[14]    ),
    .P151_CA15     ( ca[15]    ),
    .P152_CA16     ( ca[16]    ),
    .P153_CA17     ( ca[17]    ),
    .P154_CA18     ( ca[18]    ),
    .P155_CA19     ( ca[19]    ),
    .P156_CA20     ( ca[20]    ),
    .P157_CA21     ( ca[21]    ),
    .P158_CA22     ( ca[22]    ),
    .P159_CA23     ( ca[23]    ),
    .P160_n_WR     ( w_wr      )
);

//========================================================================
// DL-0921:
//========================================================================
capcom_dl0921 b (
    .P1_XSEL        ( xsel_b       ),
    .P2_XS0         ( xs_b[0]      ),
    .P3_XS1         ( xs_b[1]      ),
    .P4_XS2         ( xs_b[2]      ),
    .P5_XS3         ( xs_b[3]      ),
    .P6_XS4         ( xs_b[4]      ),
    .P7__ROMOE      ( n_romoe      ),
    .P8_VCC         ( w1           ),
    .P9_TD0         ( td[0]        ),
    .P10_TD1        ( td[1]        ),
    .P11_TD2        ( td[2]        ),
    .P12_TD3        ( td[3]        ),
    .P13_TD4        ( td[4]        ),
    .P14_TD5        ( td[5]        ),
    .P15_TD6        ( td[6]        ),
    .P16_TD7        ( td[7]        ),
    .P17_TD8        ( td[8]        ),
    .P18_TD9        ( td[9]        ),
    .P19_TD10       ( td[10]       ),
    .P20_TD11       ( td[11]       ),
    .P21_GND        ( w0           ),
    .P22_ASD0       ( asd_b[0]     ),
    .P23_ASD1       ( asd_b[1]     ),
    .P24_ASD2       ( asd_b[2]     ),
    .P25_ASD3       ( asd_b[3]     ),
    .P26_ASD4       ( asd_b[4]     ),
    .P27_ASD5       ( asd_b[5]     ),
    .P28_ASD6       ( asd_b[6]     ),
    .P29_ASD7       ( asd_b[7]     ),
    .P30_ASD8       ( asd_b[8]     ),
    .P31_BSD0       ( bsd_b[0]     ),
    .P32_BSD1       ( bsd_b[1]     ),
    .P33_BSD2       ( bsd_b[2]     ),
    .P34_BSD3       ( bsd_b[3]     ),
    .P35_BSD4       ( bsd_b[4]     ),
    .P36_BSD5       ( bsd_b[5]     ),
    .P37_BSD6       ( bsd_b[6]     ),
    .P38_BSD7       ( bsd_b[7]     ),
    .P39_BSD8       ( bsd_b[8]     ),
    .P40_VBAT       ( w1           ),
    .P41_GND        ( w0           ),
    .P42_SEC_STROBE ( sec_strobe_w ),
    .P43_SEC__E1    ( sec_ne1_w    ),
    .P44_SEC_E2     ( sec_e2_w     ),
    .P45_SEC_MODE0  ( sec_mode_w   ),
    .P46_SEC_MODE1  ( sec_mode_w   ),
    .P47_GND        ( w0           ),
    .P48_FAD0       ( fad[0]       ),
    .P49_FAD1       ( fad[1]       ),
    .P50_FAD2       ( fad[2]       ),
    .P51_FAD3       ( fad[3]       ),
    .P52_FBD0       ( fbd[0]       ),
    .P53_FBD1       ( fbd[1]       ),
    .P54_FBD2       ( fbd[2]       ),
    .P55_FBD3       ( fbd[3]       ),
    .P56_OBJEO      ( objeo_b      ),
    .P57__OBJUP     ( n_objup_b    ),
    .P58_FRAME      ( frame_b      ),
    .P59__REWEN     ( n_rewen      ),
    .P60_VCC        ( w1           ),
    .P61_CD0        ( cd[0]        ),
    .P62_CD1        ( cd[1]        ),
    .P63_CD2        ( cd[2]        ),
    .P64_CD3        ( cd[3]        ),
    .P65_CD4        ( cd[4]        ),
    .P66_CD5        ( cd[5]        ),
    .P67_CD6        ( cd[6]        ),
    .P68_CD7        ( cd[7]        ),
    .P69_CD8        ( cd[8]        ),
    .P70_CD9        ( cd[9]        ),
    .P71_CD10       ( cd[10]       ),
    .P72_CD11       ( cd[11]       ),
    .P73_CD12       ( cd[12]       ),
    .P74_CD13       ( cd[13]       ),
    .P75_CD14       ( cd[14]       ),
    .P76_CD15       ( cd[15]       ),
    .P77_GND        ( w0           ),
    .P78_CA1        ( ca[1]        ),
    .P79_CA2        ( ca[2]        ),
    .P80_CA3        ( ca[3]        ),
    .P81_CA4        ( ca[4]        ),
    .P82_CA5        ( ca[5]        ),
    .P83__CS        ( n_csb_w      ),
    .P84__RD        ( w_rd         ),
    .P85__WR        ( w_wr         ),
    .P86__WSTROM    ( n_wstrom_b   ),
    .P87_LUTPRO     ( lutpro_b     ),
    .P88_WSTLUT     ( wstlut_b     ),
    .P89_LUTA0      ( luta[0]      ),
    .P90_LUTA1      ( luta[1]      ),
    .P91_LUTA2      ( luta[2]      ),
    .P92_LUTA3      ( luta[3]      ),
    .P93_LUTA4      ( luta[4]      ),
    .P94_LUTA5      ( luta[5]      ),
    .P95_LUTA6      ( luta[6]      ),
    .P96_LUTA7      ( luta[7]      ),
    .P97_LUTA8      ( luta[8]      ),
    .P98_LUTA9      ( luta[9]      ),
    .P99_LUTA10     ( luta[10]     ),
    .P100_LUTA11    ( luta[11]     ),
    .P101__LUTOE    ( n_lutoe      ),
    .P102__LUTWR    ( n_lutwr      ),
    .P103__RESETI   ( n_reseti_b   ),
    .P104__CLK8M    ( n_clk8m_b    ),
    .P105_VCC       ( w1           ),
    .P106__CK10     ( n_ck10       ),
    .P107_TI0       ( w0           ),
    .P108__CK500    ( ck500        ),
    .P109_TI1       ( w0           ),
    .P110_CLK       ( w_clk        ),
    .P111_TI2       ( w0           ),
    .P112_TI3       ( w0           ),
    .P113_FI        ( fi_b         ),
    .P114_LI        ( li_b         ),
    .P115_FLIP      ( flip_b       ),
    .P116_HSYNC     ( hsync        ),
    .P117__HBLANK   ( n_hblank     ),
    .P118_VSYNC     ( vsync        ),
    .P119__VBLANK   ( n_vblank     ),
    .P120_GND       ( w0           ),
    .P121_APD0      ( apd[0]       ),
    .P122_APD1      ( apd[1]       ),
    .P123_APD2      ( apd[2]       ),
    .P124_APD3      ( apd[3]       ),
    .P125_APD4      ( apd[4]       ),
    .P126_APD5      ( apd[5]       ),
    .P127_APD6      ( apd[6]       ),
    .P128_APD7      ( apd[7]       ),
    .P129_BPD0      ( bpd[0]       ),
    .P130_BPD1      ( bpd[1]       ),
    .P131_BPD2      ( bpd[2]       ),
    .P132_BPD3      ( bpd[3]       ),
    .P133_BPD4      ( bpd[4]       ),
    .P134_BPD5      ( bpd[5]       ),
    .P135_BPD6      ( bpd[6]       ),
    .P136_BPD7      ( bpd[7]       ),
    .P137_CPD0      ( cpd[0]       ),
    .P138_CPD1      ( cpd[1]       ),
    .P139_CPD2      ( cpd[2]       ),
    .P140_CPD3      ( cpd[3]       ),
    .P141_CPD4      ( cpd[4]       ),
    .P142_CPD5      ( cpd[5]       ),
    .P143_CPD6      ( cpd[6]       ),
    .P144_CPD7      ( cpd[7]       ),
    .P145_DPD0      ( dpd[0]       ),
    .P146_DPD1      ( dpd[1]       ),
    .P147_DPD2      ( dpd[2]       ),
    .P148_DPD3      ( dpd[3]       ),
    .P149_DPD4      ( dpd[4]       ),
    .P150_DPD5      ( dpd[5]       ),
    .P151_DPD6      ( dpd[6]       ),
    .P152_DPD7      ( dpd[7]       ),
    .P153_CB0       ( cb_b[0]      ),
    .P154_CB1       ( cb_b[1]      ),
    .P155_CB2       ( cb_b[2]      ),
    .P156_CB3       ( cb_b[3]      ),
    .P157_CB4       ( cb_b[4]      ),
    .P158_CPC0      ( cpc_b[0]     ),
    .P159_CPC1      ( cpc_b[1]     ),
    .P160_CDEN      ( cden_b       )
);

//========================================================================
// Register Load:
//========================================================================
reg [15:0] cpsa [0:31];
reg [15:0] cpsb [0:31];

task wreg(input b, input [5:0] off, input [15:0] val);
    begin
        @(posedge clk);
        host_a = (b ? 23'h4000a0 : 23'h400080) | (off >> 1);
        host_d = val;
        host_drive = 1;
        repeat(2) @(posedge clk);
        if(b) n_csb = 0;
        else n_csa = 0;
        n_wr = 0;
        repeat(4) @(posedge clk);
        n_wr = 1;
        n_csa = 1;
        n_csb = 1;
        @(posedge clk);
        host_drive = 0;
    end
endtask

//========================================================================
// Security Key:
//========================================================================
reg [143:0] key;

task sec_bit(input d);
    begin
        host_d[0] = d;
        #500 host_d[1] = 1'b1;
        #500 host_d[1] = 1'b0;
    end
endtask

task inject_key;
    integer k;
    begin
        sec_mode = 0;
        host_a = 0;
        host_d = 0;
        host_drive = 1;
        #1000 sec_ne1 = 0;
        sec_e2 = 1;
        #1000 repeat(4) begin
            #500 sec_strobe = 1;
            #500 sec_strobe = 0;
        end
        sec_bit(1);
        sec_bit(0);
        sec_bit(1);
        sec_bit(0);
        sec_bit(1);
        sec_bit(1);
        repeat(12) sec_bit(1);
        for(k = 0; k < 144; k = k + 1) sec_bit(key[143 - k]);
        #1000 sec_e2 = 0;
        #500 sec_ne1 = 1;
        host_drive = 0;
    end
endtask

reg  [7:0] r_layer = 8'h26;
reg  [7:0] r_pal = 8'h30;
reg [31:0] r_prio = 32'h282a2c2e;

//========================================================================
// Setup:
//========================================================================
integer i;
integer fd;
integer r;
integer frames;

reg [8*256-1:0] dump;
reg [8*256-1:0] gfxfile;
reg [8*256-1:0] outp;
reg [8*256-1:0] mapfile;

initial begin
    if(!$value$plusargs("frames=%d", frames)) frames = 4;
    if(!$value$plusargs("game=%s", game)) game = "sf2hf";
    if(!$value$plusargs("dump=%s", dump)) dump = "dump";
    if(!$value$plusargs("gfx=%s", gfxfile)) gfxfile = "gfx.bin";
    if(!$value$plusargs("out=%s", outp)) outp = "cap";
    if($value$plusargs("romacc=%d", tacc)) ;
    if($value$plusargs("romoe=%d", toe)) ;
    bitrev = $test$plusargs("bitrev");
    if($value$plusargs("bshift=%d", bshift)) ;
    if($value$plusargs("rewendly=%d", rewendly)) ;
    if($value$plusargs("ramacc=%d", ramacc)) ;
    if($value$plusargs("asxwin=%d", asxwin)) ;
    xsrev = $test$plusargs("xsrev");
    xs3inv = $test$plusargs("xs3inv");
    if($value$plusargs("rlayer=%h", r_layer)) ;
    if($value$plusargs("rprio=%h", r_prio)) ;
    if($value$plusargs("rpal=%h", r_pal)) ;
    if($value$plusargs("mapper=%s", mapfile)) begin
        fd = $fopen(mapfile, "r");
        while(!$feof(fd)) begin
            r = $fscanf(fd, "%h %h %h %h %h\n", m_t[m_n], m_s[m_n], m_e[m_n], m_b[m_n], m_k[m_n]);
            if(r == 5) m_n = m_n + 1;
        end
        $fclose(fd);
    end
    else $display("no +mapper: graphics ROM reads 0xff");
    for(i = 0; i < 4096; i = i + 1) pal[i] = 16'h0000;
    fd = $fopen({dump, "_gfxram.bin"}, "rb");
    r = $fread(ram, fd);
    $fclose(fd);
    fd = $fopen({dump, "_cpsa.bin"}, "rb");
    r = $fread(cpsa, fd);
    $fclose(fd);
    fd = $fopen({dump, "_cpsb.bin"}, "rb");
    r = $fread(cpsb, fd);
    $fclose(fd);
    fd = $fopen(gfxfile, "rb");
    r = $fread(gfx, fd, 0, 24'h800000);
    $fclose(fd);
    $display("loaded: gfx %0d bytes, %0d mapper ranges; CPS-A-01 video control %h, OBJ base %h, palette base %h; CPS-B-21 layer %h prio %h %h %h %h pal %h",
             r, m_n, cpsa[17], cpsa[0], cpsa[5], cpsb[r_layer[5:1]], cpsb[r_prio[29:25]], cpsb[r_prio[21:17]],
             cpsb[r_prio[13:9]], cpsb[r_prio[5:1]], cpsb[r_pal[5:1]]);
    if($value$plusargs("key=%h", key)) begin
        inject_key;
        $display("[%0t] CPS-B-21 key injected: %h", $time, key);
    end
    #2000 n_reset = 1;
    #1000;
    for(i = 0; i < 18; i = i + 1) if(i != 5) wreg(0, 2 * i, cpsa[i]);
    wreg(1, r_layer[5:0], cpsb[r_layer[5:1]]);
    for(i = 3; i >= 0; i = i - 1) wreg(1, r_prio[8 * i +: 6], cpsb[r_prio[8 * i + 1 +: 5]]);
    wreg(1, r_pal[5:0], cpsb[r_pal[5:1]]);
    wreg(0, 6'h0a, cpsa[5]);
    setup_done = 1;
    $display("[%0t] registers written", $time);
end

//========================================================================
// Timed Register Accesses:
//========================================================================
integer rfd = 0;
integer lines_fi = 0;

realtime t_li = 0;

task rreg(input [5:0] off);
    reg [15:0] v;
    begin
        @(posedge clk);
        host_a = 23'h4000a0 | (off >> 1);
        host_drive = 0;
        host_adrive = 1;
        repeat(2) @(posedge clk);
        n_csb = 0;
        n_rd = 0;
        repeat(4) @(posedge clk);
        v = cd;
        n_rd = 1;
        n_csb = 1;
        @(posedge clk);
        host_adrive = 0;
        $display("[%0t] CPS-B-21 read %02x = %04x (line %0d since FI, CLK %0d since LI)", $time, off, v, lines_fi,
                 $rtoi(($realtime - t_li) / 62.5));
    end
endtask

real       acc_t [0:15];
reg [15:0] acc_a [0:15];
reg [15:0] acc_v [0:15];
reg        acc_w [0:15];
reg        acc_on [0:15];

integer ai;
integer an;
integer best;

real tnow;

reg [8*16-1:0] nm;

initial begin
    an = 0;
    for(ai = 1; ai <= 8; ai = ai + 1) begin
        acc_on[an] = 0;
        if($value$plusargs($sformatf("rw%0dt=%%f", ai), acc_t[an]) && $value$plusargs($sformatf("rw%0da=%%h", ai), acc_a[an])
           && $value$plusargs($sformatf("rw%0dv=%%h", ai), acc_v[an])) begin
            acc_w[an] = 1;
            acc_on[an] = 1;
            an = an + 1;
        end
        acc_on[an] = 0;
        if($value$plusargs($sformatf("rr%0dt=%%f", ai), acc_t[an]) && $value$plusargs($sformatf("rr%0da=%%h", ai), acc_a[an])) begin
            acc_w[an] = 0;
            acc_on[an] = 1;
            an = an + 1;
        end
    end
    tnow = 0;
    repeat(an) begin
        best = -1;
        for(ai = 0; ai < an; ai = ai + 1) begin
            if(acc_on[ai] && (best < 0 || acc_t[ai] < acc_t[best])) best = ai;
        end
        acc_on[best] = 0;
        if(acc_t[best] > $realtime) #(acc_t[best] - $realtime);
        wait(setup_done && !host_drive && n_csa && n_csb);
        host_busy = 1;
        repeat(4) @(posedge clk);
        wait(n_bgack);
        if(acc_w[best]) begin
            wreg(1, acc_a[best][5:0], acc_v[best]);
            $display("[%0t] CPS-B-21 write %02x = %04x (line %0d since FI)", $time, acc_a[best][5:0], acc_v[best], lines_fi);
        end
        else rreg(acc_a[best][5:0]);
        host_busy = 0;
    end
end

//========================================================================
// Raster Log:
//========================================================================
always @(posedge li_s) begin
    lines_fi = lines_fi + 1;
    t_li = $realtime;
end

always @(posedge fi) begin
    lines_fi = 0;
end

initial begin
    if($test$plusargs("rastlog")) begin
        #1 rfd = $fopen($sformatf("%0s_raster.txt", outp), "w");
    end
end

wire [8:0] b_line = {b.\/video-signals/video-counter/LINE8 , b.\/video-signals/video-counter/LINE7 ,
                     b.\/video-signals/video-counter/LINE6 , b.\/video-signals/video-counter/LINE5 ,
                     b.\/video-signals/video-counter/LINE4 , b.\/video-signals/video-counter/LINE3 ,
                     b.\/video-signals/video-counter/LINE2 , b.\/video-signals/video-counter/LINE1 ,
                     b.\/video-signals/video-counter/LINE0 };

wire [8:0] b_p = {b.\/video-signals/video-counter/COL8 , b.\/video-signals/video-counter/COL7 ,
                  b.\/video-signals/video-counter/COL6 , b.\/video-signals/video-counter/COL5 ,
                  b.\/video-signals/video-counter/COL4 , b.\/video-signals/video-counter/COL3 ,
                  b.\/video-signals/video-counter/COL2 , b.\/video-signals/video-counter/COL1 ,
                  ~b.video_signals_video_counter_UBW150.p1 };

always @(b.\/raster-interrupts/~OBJUP ) begin
    if(rfd) $fdisplay(rfd, "%0t frame %0d lines_since_FI %0d clk_since_LI %0d LINE %0d P %0d ~OBJUP %b zero123 %b%b%b",
                      $time, nframes, lines_fi, $rtoi(($realtime - t_li) / 62.5), b_line, b_p,
                      b.\/raster-interrupts/~OBJUP , !b.\/raster-interrupts/counter1/~ZERO ,
                      !b.\/raster-interrupts/counter2/~ZERO , !b.\/raster-interrupts/counter3/~ZERO );
end

wire [8:0] c1raw = {b.\N$/raster-interrupts/counter1|w284 , b.\N$/raster-interrupts/counter1|w308 ,
                    b.\N$/raster-interrupts/counter1|w310 , b.\N$/raster-interrupts/counter1|w312 ,
                    b.\N$/raster-interrupts/counter1|w314 , b.\N$/raster-interrupts/counter1|w194 ,
                    b.\N$/raster-interrupts/counter1|w294 , b.\N$/raster-interrupts/counter1|w291 ,
                    b.\N$/raster-interrupts/counter1|w288 };

wire [8:0] c2raw = {b.\N$/raster-interrupts/counter2|w284 , b.\N$/raster-interrupts/counter2|w308 ,
                    b.\N$/raster-interrupts/counter2|w310 , b.\N$/raster-interrupts/counter2|w312 ,
                    b.\N$/raster-interrupts/counter2|w314 , b.\N$/raster-interrupts/counter2|w194 ,
                    b.\N$/raster-interrupts/counter2|w294 , b.\N$/raster-interrupts/counter2|w291 ,
                    b.\N$/raster-interrupts/counter2|w288 };

always @(li_s or fi_s) begin
    if(rfd && $test$plusargs("rastlines"))
        $fdisplay(rfd, "%0t edge li %b fi %b frame %0d lines_since_FI %0d LINE %0d P %0d c1raw %b c2raw %b", $time, li_s,
                  fi_s, nframes, lines_fi, b_line, b_p, c1raw, c2raw);
end

//========================================================================
// Capture:
//========================================================================
integer cfd = 0;
integer nframes = 0;
integer fy;
integer fx;

task fbdump(input integer n);
    begin
        fd = $fopen($sformatf("%0s_fb_f%0d.txt", outp, n), "w");
        $fdisplay(fd, "# frame %0d FRAME=%b", n, frame);
        for(fy = 0; fy < 256; fy = fy + 1) begin
            for(fx = 0; fx < 512; fx = fx + 1)
                $fwrite(fd, "%04x", (fx & 1) ? va1.mem[{fy[7:0], fx[8:1]}] : va0.mem[{fy[7:0], fx[8:1]}]);
            $fwrite(fd, " ");
            for(fx = 0; fx < 512; fx = fx + 1)
                $fwrite(fd, "%04x", (fx & 1) ? vb1.mem[{fy[7:0], fx[8:1]}] : vb0.mem[{fy[7:0], fx[8:1]}]);
            $fwrite(fd, "\n");
        end
        $fclose(fd);
    end
endtask

realtime last_fi = -1e9;

always @(posedge fi) begin
    if($realtime - last_fi > 1000000.0) begin
        last_fi = $realtime;
        nframes = nframes + 1;
        if($test$plusargs("fbdump")) fbdump(nframes);
        if(cfd) $fclose(cfd);
        cfd = $fopen($sformatf("%0s_f%0d.txt", outp, nframes), "w");
        fd = $fopen($sformatf("%0s_pal_f%0d.txt", outp, nframes), "w");
        for(i = 0; i < 4096; i = i + 1) $fdisplay(fd, "%04x", pal[i]);
        $fclose(fd);
        $display("[%0t] FI #%0d", $time, nframes);
        if(nframes > frames) $finish;
    end
end

always @(posedge li) begin
    if(cfd) $fwrite(cfd, "\n%0t ", $time);
end

always @(posedge clk) begin
    if(cfd) $fwrite(cfd, "%03x%1x", (^luta === 1'bx) ? 12'hfff : luta, {n_hblank, n_vblank, hsync, vsync});
end

//========================================================================
// Timeout:
//========================================================================
initial #120000000 begin
    $display("timeout");
    $finish;
end

endmodule
