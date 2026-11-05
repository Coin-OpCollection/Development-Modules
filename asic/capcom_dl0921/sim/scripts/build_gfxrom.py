"""
Build a game's CPS1 graphics ROM image in MAME's "gfx" region layout (ROM_LOAD64_WORD / ROM_LOAD64_BYTE):

    python build_gfxrom.py <game> <romset.zip> <out.bin>

The load lists are copied from MAME src/mame/capcom/cps1.cpp (ROM_START blocks). Byte k of each 8-byte unit is
pixel plane (k % 4) of pixels 0-7 (k < 4) or 8-15 (k >= 4).
"""
import sys
import zipfile

# (file, region offset, kind[, CRC32]) ; kind "w" = ROM_LOAD64_WORD (2 bytes per 8-byte unit), "b" = ROM_LOAD64_BYTE,
# "wc" = ROM_LOAD64_WORD of the first half and ROM_CONTINUE of the second half 4 bytes on.
# With a CRC the file is picked by CRC (a merged romset can hold clone files of the same name), otherwise by name,
# preferring the zip's top level.
LOADS = {
    "pang3": (0x400000, [
        ("pa3-01m.2c", 0x000000, "wc", 0x068a152c), ("pa3-07m.2f", 0x000002, "wc", 0x3a4a619d),
    ]),
    "megaman": (0x800000, [
        ("rcm_01.3a", 0x000000, "w", 0x6ecdf13f), ("rcm_02.4a", 0x000002, "w", 0x944d4f0f),
        ("rcm_03.5a", 0x000004, "w", 0x36f3073c), ("rcm_04.6a", 0x000006, "w", 0x54e622ff),
        ("rcm_05.7a", 0x200000, "w", 0x5dd131fd), ("rcm_06.8a", 0x200002, "w", 0xf0faf813),
        ("rcm_07.9a", 0x200004, "w", 0x826de013), ("rcm_08.10a", 0x200006, "w", 0xfbff64cf),
        ("rcm_10.3c", 0x400000, "w", 0x4dc8ada9), ("rcm_11.4c", 0x400002, "w", 0xf2b9ee06),
        ("rcm_12.5c", 0x400004, "w", 0xfed5f203), ("rcm_13.6c", 0x400006, "w", 0x5069d4a9),
        ("rcm_14.7c", 0x600000, "w", 0x303be3bd), ("rcm_15.8c", 0x600002, "w", 0x4f2d372f),
        ("rcm_16.9c", 0x600004, "w", 0x93d97fde), ("rcm_17.10c", 0x600006, "w", 0x92371042),
    ]),
    "qtono2j": (0x400000, [
        ("tn2-02m.4a", 0x000000, "w", 0xf2016a34), ("tn2-04m.6a", 0x000002, "w", 0x094e0fb1),
        ("tn2-01m.3a", 0x000004, "w", 0xcb950cf9), ("tn2-03m.5a", 0x000006, "w", 0x18a5bf59),
        ("tn2-11m.4c", 0x200000, "w", 0xd0edd30b), ("tn2-13m.6c", 0x200002, "w", 0x426621c3),
        ("tn2-10m.3c", 0x200004, "w", 0xa34ece70), ("tn2-12m.5c", 0x200006, "w", 0xe04ff2f4),
    ]),
    "pnickj": (0x200000, [
        ("pnij_09.4b", 0x000000, "b", 0x48177b0a), ("pnij_01.4a", 0x000001, "b", 0x01a0f311),
        ("pnij_13.9b", 0x000002, "b", 0x406451b0), ("pnij_05.9a", 0x000003, "b", 0x8c515dc0),
        ("pnij_26.5e", 0x000004, "b", 0xe2af981e), ("pnij_18.5c", 0x000005, "b", 0xf17a0e56),
        ("pnij_38.8h", 0x000006, "b", 0xeb75bd8c), ("pnij_32.8f", 0x000007, "b", 0x84560bef),
        ("pnij_10.5b", 0x100000, "b", 0xc2acc171), ("pnij_02.5a", 0x100001, "b", 0x0e21fc33),
        ("pnij_14.10b", 0x100002, "b", 0x7fe59b19), ("pnij_06.10a", 0x100003, "b", 0x79f4bfe3),
        ("pnij_27.7e", 0x100004, "b", 0x83d5cb0e), ("pnij_19.7c", 0x100005, "b", 0xaf08b230),
        ("pnij_39.9h", 0x100006, "b", 0x70fbe579), ("pnij_33.9f", 0x100007, "b", 0x3ed2c680),
    ]),
    "striderjr": (0x400000, [
        ("sth_01.3a", 0x000000, "w", 0x4eee9aea), ("sth_02.4a", 0x000002, "w", 0x2d7f21e4),
        ("sth_03.5a", 0x000004, "w", 0x7705aa46), ("sth_04.6a", 0x000006, "w", 0x5b18b722),
        ("sth_05.7a", 0x200000, "w", 0x005f000b), ("sth_06.8a", 0x200002, "w", 0xb9441519),
        ("sth_07.9a", 0x200004, "w", 0xb7d04e8b), ("sth_08.10a", 0x200006, "w", 0x6b4713b4),
    ]),
    "dynwarjr": (0x400000, [
        ("tk1_01.3a", 0x000000, "w", 0xf64bb6a0), ("tk1_02.4a", 0x000002, "w", 0x21fe6274),
        ("tk1_03.5a", 0x000004, "w", 0x0bf228cb), ("tk1_04.6a", 0x000006, "w", 0x1255dfb1),
        ("tk1_05.7a", 0x200000, "w", 0x44f7661e), ("tk1_06.8a", 0x200002, "w", 0xa54c515d),
        ("tk1_07.9a", 0x200004, "w", 0xca5c687c), ("tk1_08.10a", 0x200006, "w", 0xf9fe6591),
    ]),
    "sf2hf": (0x600000, [
        ("s92-1m.3a", 0x000000, "w"), ("s92-3m.5a", 0x000002, "w"), ("s92-2m.4a", 0x000004, "w"),
        ("s92-4m.6a", 0x000006, "w"), ("s92-5m.7a", 0x200000, "w"), ("s92-7m.9a", 0x200002, "w"),
        ("s92-6m.8a", 0x200004, "w"), ("s92-8m.10a", 0x200006, "w"), ("s92-10m.3c", 0x400000, "w"),
        ("s92-12m.5c", 0x400002, "w"), ("s92-11m.4c", 0x400004, "w"), ("s92-13m.6c", 0x400006, "w"),
    ]),
    "ghouls": (0x300000, [
        ("dm-05.3a", 0x000000, "w"), ("dm-07.3f", 0x000002, "w"), ("dm-06.3c", 0x000004, "w"),
        ("dm-08.3g", 0x000006, "w"),
        ("09.4a", 0x200000, "b"), ("18.7a", 0x200001, "b"), ("13.4e", 0x200002, "b"), ("22.7e", 0x200003, "b"),
        ("11.4c", 0x200004, "b"), ("20.7c", 0x200005, "b"), ("15.4g", 0x200006, "b"), ("24.7g", 0x200007, "b"),
        ("10.4b", 0x280000, "b"), ("19.7b", 0x280001, "b"), ("14.4f", 0x280002, "b"), ("23.7f", 0x280003, "b"),
        ("12.4d", 0x280004, "b"), ("21.7d", 0x280005, "b"), ("16.4h", 0x280006, "b"), ("25.7h", 0x280007, "b"),
    ]),
    "forgottn": (0x400000, [
        ("lw_2.2b", 0x000000, "b", 0x4bd75fee),
        ("lw_1.2a", 0x000001, "b", 0x65f41485),
        ("lw-08.9b", 0x000002, "w", 0x25a8e43c),
        ("lw_18.5e", 0x000004, "b", 0xb4b6241b),
        ("lw_17.5c", 0x000005, "b", 0xc5eea115),
        ("lw_30.8h", 0x000006, "b", 0xb385954e),
        ("lw_29.8f", 0x000007, "b", 0x7bda1ac6),
        ("lw_4.3b", 0x100000, "b", 0x50cf757f),
        ("lw_3.3a", 0x100001, "b", 0xc03ef278),
        ("lw_20.7e", 0x100004, "b", 0xdf1a3665),
        ("lw_19.7c", 0x100005, "b", 0x15af8440),
        ("lw_32.9h", 0x100006, "b", 0x30967a15),
        ("lw_31.9f", 0x100007, "b", 0xc49d37fb),
        ("lw-02.6b", 0x200000, "w", 0x43e6c5c8),
        ("lw_14.10b", 0x200002, "b", 0x82862cce),
        ("lw_13.10a", 0x200003, "b", 0xb81c0e96),
        ("lw-06.9d", 0x200004, "w", 0x5b9edffc),
        ("lw_26.10e", 0x200006, "b", 0x57bcd032),
        ("lw_25.10c", 0x200007, "b", 0xbac91554),
        ("lw_16.11b", 0x300002, "b", 0x40b26554),
        ("lw_15.11a", 0x300003, "b", 0x1b7d2e07),
        ("lw_28.11e", 0x300006, "b", 0xa805ad30),
        ("lw_27.11c", 0x300007, "b", 0x103c1bd2),
    ]),
    "strider": (0x400000, [
        ("st-2.8a", 0x000000, "w", 0x4eee9aea),
        ("st-11.10a", 0x000002, "w", 0x2d7f21e4),
        ("st-5.4a", 0x000004, "w", 0x7705aa46),
        ("st-9.6a", 0x000006, "w", 0x5b18b722),
        ("st-1.7a", 0x200000, "w", 0x005f000b),
        ("st-10.9a", 0x200002, "w", 0xb9441519),
        ("st-4.3a", 0x200004, "w", 0xb7d04e8b),
        ("st-8.5a", 0x200006, "w", 0x6b4713b4),
    ]),
    "willow": (0x400000, [
        ("wlm-7.7a", 0x000000, "w", 0xafa74b73),
        ("wlm-5.9a", 0x000002, "w", 0x12a0dc0b),
        ("wlm-3.3a", 0x000004, "w", 0xc6f2abce),
        ("wlm-1.5a", 0x000006, "w", 0x4aa4c6d3),
        ("wl_24.7d", 0x200000, "b", 0x6f0adee5),
        ("wl_14.7c", 0x200001, "b", 0x9cf3027d),
        ("wl_26.9d", 0x200002, "b", 0xf09c8ecf),
        ("wl_16.9c", 0x200003, "b", 0xe35407aa),
        ("wl_20.3d", 0x200004, "b", 0x84992350),
        ("wl_10.3c", 0x200005, "b", 0xb87b5a36),
        ("wl_22.5d", 0x200006, "b", 0xfd3f89f0),
        ("wl_12.5c", 0x200007, "b", 0x7da49d69),
    ]),
    "nemo": (0x200000, [
        ("nm-5m.7a", 0x000000, "w", 0x487b8747),
        ("nm-7m.9a", 0x000002, "w", 0x203dc8c6),
        ("nm-1m.3a", 0x000004, "w", 0x9e878024),
        ("nm-3m.5a", 0x000006, "w", 0xbb01e6b6),
    ]),
    "dynwar": (0x400000, [
        ("tkm-5.7a", 0x000000, "w", 0xf64bb6a0),
        ("tkm-8.9a", 0x000002, "w", 0x21fe6274),
        ("tkm-6.3a", 0x000004, "w", 0x0bf228cb),
        ("tkm-7.5a", 0x000006, "w", 0x1255dfb1),
        ("tkm-1.8a", 0x200000, "w", 0x44f7661e),
        ("tkm-4.10a", 0x200002, "w", 0xa54c515d),
        ("tkm-2.4a", 0x200004, "w", 0xca5c687c),
        ("tkm-3.6a", 0x200006, "w", 0xf9fe6591),
    ]),
    "sf2ee": (0x600000, [
        ("sf2-5m.4a", 0x000000, "w", 0x22c9cc8e),
        ("sf2-7m.6a", 0x000002, "w", 0x57213be8),
        ("sf2-1m.3a", 0x000004, "w", 0xba529b4f),
        ("sf2-3m.5a", 0x000006, "w", 0x4b1b33a8),
        ("sf2-6m.4c", 0x200000, "w", 0x2c7e2229),
        ("sf2-8m.6c", 0x200002, "w", 0xb5548f17),
        ("sf2-2m.3c", 0x200004, "w", 0x14b84312),
        ("sf2-4m.5c", 0x200006, "w", 0x5e9cd89a),
        ("sf2-13m.4d", 0x400000, "w", 0x994bfa58),
        ("sf2-15m.6d", 0x400002, "w", 0x3e66ad9d),
        ("sf2-9m.3d", 0x400004, "w", 0xc1befaa8),
        ("sf2-11m.5d", 0x400006, "w", 0x0627c831),
    ]),
    "captcomm": (0x400000, [
        ("cc-5m.3a", 0x000000, "w", 0x7261d8ba),
        ("cc-7m.5a", 0x000002, "w", 0x6a60f949),
        ("cc-1m.4a", 0x000004, "w", 0x00637302),
        ("cc-3m.6a", 0x000006, "w", 0xcc87cf61),
        ("cc-6m.7a", 0x200000, "w", 0x28718bed),
        ("cc-8m.9a", 0x200002, "w", 0xd4acc53a),
        ("cc-2m.8a", 0x200004, "w", 0x0c69f151),
        ("cc-4m.10a", 0x200006, "w", 0x1f9ebb97),
    ]),
    "knights": (0x400000, [
        ("kr-5m.3a", 0x000000, "w", 0x9e36c1a4),
        ("kr-7m.5a", 0x000002, "w", 0xc5832cae),
        ("kr-1m.4a", 0x000004, "w", 0xf095be2d),
        ("kr-3m.6a", 0x000006, "w", 0x179dfd96),
        ("kr-6m.7a", 0x200000, "w", 0x1f4298d2),
        ("kr-8m.9a", 0x200002, "w", 0x37fa8751),
        ("kr-2m.8a", 0x200004, "w", 0x0200bc3d),
        ("kr-4m.10a", 0x200006, "w", 0x0bb2b4e7),
    ]),
    "dino": (0x400000, [
        ("cd-1m.3a", 0x000000, "w", 0x8da4f917),
        ("cd-3m.5a", 0x000002, "w", 0x6c40f603),
        ("cd-2m.4a", 0x000004, "w", 0x09c8fc2d),
        ("cd-4m.6a", 0x000006, "w", 0x637ff38f),
        ("cd-5m.7a", 0x200000, "w", 0x470befee),
        ("cd-7m.9a", 0x200002, "w", 0x22bfb7a3),
        ("cd-6m.8a", 0x200004, "w", 0xe7599ac4),
        ("cd-8m.10a", 0x200006, "w", 0x211b4b15),
    ]),
    "punisher": (0x400000, [
        ("ps-1m.3a", 0x000000, "w", 0x77b7ccab),
        ("ps-3m.5a", 0x000002, "w", 0x0122720b),
        ("ps-2m.4a", 0x000004, "w", 0x64fa58d4),
        ("ps-4m.6a", 0x000006, "w", 0x60da42c8),
        ("ps-5m.7a", 0x200000, "w", 0xc54ea839),
        ("ps-7m.9a", 0x200002, "w", 0x04c5acbd),
        ("ps-6m.8a", 0x200004, "w", 0xa544f4cc),
        ("ps-8m.10a", 0x200006, "w", 0x8f02f436),
    ]),
    "3wonders": (0x400000, [
        ("rt-5m.7a", 0x000000, "w", 0x86aef804),
        ("rt-7m.9a", 0x000002, "w", 0x4f057110),
        ("rt-1m.3a", 0x000004, "w", 0x902489d0),
        ("rt-3m.5a", 0x000006, "w", 0xe35ce720),
        ("rt-6m.8a", 0x200000, "w", 0x13cb0e7c),
        ("rt-8m.10a", 0x200002, "w", 0x1f055014),
        ("rt-2m.4a", 0x200004, "w", 0xe9a034f4),
        ("rt-4m.6a", 0x200006, "w", 0xdf0eea8b),
    ]),
    "kod": (0x400000, [
        ("kd-5m.4a", 0x000000, "w", 0xe45b8701),
        ("kd-7m.6a", 0x000002, "w", 0xa7750322),
        ("kd-1m.3a", 0x000004, "w", 0x5f74bf78),
        ("kd-3m.5a", 0x000006, "w", 0x5e5303bf),
        ("kd-6m.4c", 0x200000, "w", 0x113358f3),
        ("kd-8m.6c", 0x200002, "w", 0x38853c44),
        ("kd-2m.3c", 0x200004, "w", 0x9ef36604),
        ("kd-4m.5c", 0x200006, "w", 0x402b9b4f),
    ]),
    "varthj": (0x200000, [
        ("va_09.4b", 0x000000, "b", 0x183dfaa8),
        ("va_01.4a", 0x000001, "b", 0xc41312b5),
        ("va_13.9b", 0x000002, "b", 0x45537e69),
        ("va_05.9a", 0x000003, "b", 0x7065d4e9),
        ("va_24.5e", 0x000004, "b", 0x57191ccf),
        ("va_17.5c", 0x000005, "b", 0x054f5a5b),
        ("va_38.8h", 0x000006, "b", 0xe117a17e),
        ("va_32.8f", 0x000007, "b", 0x3b4f40b2),
        ("va_10.5b", 0x100000, "b", 0xd62750cd),
        ("va_02.5a", 0x100001, "b", 0x11590325),
        ("va_14.10b", 0x100002, "b", 0xdc2f4783),
        ("va_06.10a", 0x100003, "b", 0x06e833ac),
        ("va_25.7e", 0x100004, "b", 0x51d90690),
        ("va_18.7c", 0x100005, "b", 0xa17817c0),
        ("va_39.9h", 0x100006, "b", 0xb0b12f51),
        ("va_33.9f", 0x100007, "b", 0x4b003af7),
    ]),
    "cworld2j": (0x200000, [
        ("q5_09.4b", 0x000000, "b", 0x48496d80),
        ("q5_01.4a", 0x000001, "b", 0xc5453f56),
        ("q5_13.9b", 0x000002, "b", 0xc741ac52),
        ("q5_05.9a", 0x000003, "b", 0x143e068f),
        ("q5_24.5e", 0x000004, "b", 0xb419d139),
        ("q5_17.5c", 0x000005, "b", 0xbd3b4d11),
        ("q5_38.8h", 0x000006, "b", 0x9c24670c),
        ("q5_32.8f", 0x000007, "b", 0x3ef9c7c2),
        ("q5_10.5b", 0x100000, "b", 0x119e5e93),
        ("q5_02.5a", 0x100001, "b", 0xa2cadcbe),
        ("q5_14.10b", 0x100002, "b", 0xa8755f82),
        ("q5_06.10a", 0x100003, "b", 0xc92a91fc),
        ("q5_25.7e", 0x100004, "b", 0x979237cb),
        ("q5_18.7c", 0x100005, "b", 0xc57da03c),
        ("q5_39.9h", 0x100006, "b", 0xa5839b25),
        ("q5_33.9f", 0x100007, "b", 0x04d03930),
    ]),
    "qad": (0x200000, [
        ("qd_09.4b", 0x000000, "b", 0x8c3f9f44),
        ("qd_01.4a", 0x000001, "b", 0xf688cf8f),
        ("qd_13.9b", 0x000002, "b", 0xafbd551b),
        ("qd_05.9a", 0x000003, "b", 0xc3db0910),
        ("qd_24.5e", 0x000004, "b", 0x2f1bd0ec),
        ("qd_17.5c", 0x000005, "b", 0xa812f9e2),
        ("qd_38.8h", 0x000006, "b", 0xccdddd1f),
        ("qd_32.8f", 0x000007, "b", 0xa8d295d3),
    ]),
    "wof": (0x400000, [
        ("tk2-1m.3a", 0x000000, "w", 0x0d9cb9bf),
        ("tk2-3m.5a", 0x000002, "w", 0x45227027),
        ("tk2-2m.4a", 0x000004, "w", 0xc5ca2460),
        ("tk2-4m.6a", 0x000006, "w", 0xe349551c),
        ("tk2-5m.7a", 0x200000, "w", 0x291f0f0b),
        ("tk2-7m.9a", 0x200002, "w", 0x3edeb949),
        ("tk2-6m.8a", 0x200004, "w", 0x1abd14d6),
        ("tk2-8m.10a", 0x200006, "w", 0xb27948e3),
    ]),
    "slammast": (0x600000, [
        ("mb-1m.3a", 0x000000, "w", 0x41468e06),
        ("mb-3m.5a", 0x000002, "w", 0xf453aa9e),
        ("mb-2m.4a", 0x000004, "w", 0x2ffbfea8),
        ("mb-4m.6a", 0x000006, "w", 0x1eb9841d),
        ("mb-5m.7a", 0x200000, "w", 0x506b9dc9),
        ("mb-7m.9a", 0x200002, "w", 0xaff8c2fb),
        ("mb-6m.8a", 0x200004, "w", 0xb76c70e9),
        ("mb-8m.10a", 0x200006, "w", 0xe60c9556),
        ("mb-10m.3c", 0x400000, "w", 0x97976ff5),
        ("mb-12m.5c", 0x400002, "w", 0xb350a840),
        ("mb-11m.4c", 0x400004, "w", 0x8fb94743),
        ("mb-13m.6c", 0x400006, "w", 0xda810d5f),
    ]),
    "mbombrd": (0x600000, [
        ("mb-1m.3a", 0x000000, "w", 0x41468e06),
        ("mb-3m.5a", 0x000002, "w", 0xf453aa9e),
        ("mb-2m.4a", 0x000004, "w", 0x2ffbfea8),
        ("mb-4m.6a", 0x000006, "w", 0x1eb9841d),
        ("mb-5m.7a", 0x200000, "w", 0x506b9dc9),
        ("mb-7m.9a", 0x200002, "w", 0xaff8c2fb),
        ("mb-6m.8a", 0x200004, "w", 0xb76c70e9),
        ("mb-8m.10a", 0x200006, "w", 0xe60c9556),
        ("mb-10m.3c", 0x400000, "w", 0x97976ff5),
        ("mb-12m.5c", 0x400002, "w", 0xb350a840),
        ("mb-11m.4c", 0x400004, "w", 0x8fb94743),
        ("mb-13m.6c", 0x400006, "w", 0xda810d5f),
    ]),
    "ffight": (0x200000, [
        ("ff-5m.7a", 0x000000, "w", 0x9c284108),
        ("ff-7m.9a", 0x000002, "w", 0xa7584dfb),
        ("ff-1m.3a", 0x000004, "w", 0x0b605e44),
        ("ff-3m.5a", 0x000006, "w", 0x52291cd2),
    ]),
    "1941": (0x200000, [
        ("41-5m.7a", 0x000000, "w", 0x01d1cb11),
        ("41-7m.9a", 0x000002, "w", 0xaeaa3509),
        ("41-1m.3a", 0x000004, "w", 0xff77985a),
        ("41-3m.5a", 0x000006, "w", 0x983be58f),
    ]),
    "unsquad": (0x200000, [
        ("ar-5m.7a", 0x000000, "w", 0xbf4575d8),
        ("ar-7m.9a", 0x000002, "w", 0xa02945f4),
        ("ar-1m.3a", 0x000004, "w", 0x5965ca8d),
        ("ar-3m.5a", 0x000006, "w", 0xac6db17d),
    ]),
    "mercs": (0x300000, [
        ("so2-6m.8a", 0x000000, "w", 0xaa6102af),
        ("so2-8m.10a", 0x000002, "w", 0x839e6869),
        ("so2-2m.4a", 0x000004, "w", 0x597c2875),
        ("so2-4m.6a", 0x000006, "w", 0x912a9ca0),
        ("so2_24.7d", 0x200000, "b", 0x3f254efe),
        ("so2_14.7c", 0x200001, "b", 0xf5a8905e),
        ("so2_26.9d", 0x200002, "b", 0xf3aa5a4a),
        ("so2_16.9c", 0x200003, "b", 0xb43cd1a8),
        ("so2_20.3d", 0x200004, "b", 0x8ca751a3),
        ("so2_10.3c", 0x200005, "b", 0xe9f569fd),
        ("so2_22.5d", 0x200006, "b", 0xfce9a377),
        ("so2_12.5c", 0x200007, "b", 0xb7df8a06),
    ]),
    "msword": (0x200000, [
        ("ms-5m.7a", 0x000000, "w", 0xc00fe7e2),
        ("ms-7m.9a", 0x000002, "w", 0x4ccacac5),
        ("ms-1m.3a", 0x000004, "w", 0x0d2bbe00),
        ("ms-3m.5a", 0x000006, "w", 0x3a1a5bf4),
    ]),
    "mtwins": (0x200000, [
        ("ck-5m.7a", 0x000000, "w", 0x4ec75f15),
        ("ck-7m.9a", 0x000002, "w", 0xd85d00d6),
        ("ck-1m.3a", 0x000004, "w", 0xf33ca9d4),
        ("ck-3m.5a", 0x000006, "w", 0x0ba2047f),
    ]),
    "cawing": (0x200000, [
        ("ca-5m.7a", 0x000000, "w", 0x66d4cc37),
        ("ca-7m.9a", 0x000002, "w", 0xb6f896f2),
        ("ca-1m.3a", 0x000004, "w", 0x4d0620fd),
        ("ca-3m.5a", 0x000006, "w", 0x0b0341c3),
    ]),
    "sf2eb": (0x600000, [
        ("sf2-5m.4a", 0x000000, "w", 0x22c9cc8e),
        ("sf2-7m.6a", 0x000002, "w", 0x57213be8),
        ("sf2-1m.3a", 0x000004, "w", 0xba529b4f),
        ("sf2-3m.5a", 0x000006, "w", 0x4b1b33a8),
        ("sf2-6m.4c", 0x200000, "w", 0x2c7e2229),
        ("sf2-8m.6c", 0x200002, "w", 0xb5548f17),
        ("sf2-2m.3c", 0x200004, "w", 0x14b84312),
        ("sf2-4m.5c", 0x200006, "w", 0x5e9cd89a),
        ("sf2-13m.4d", 0x400000, "w", 0x994bfa58),
        ("sf2-15m.6d", 0x400002, "w", 0x3e66ad9d),
        ("sf2-9m.3d", 0x400004, "w", 0xc1befaa8),
        ("sf2-11m.5d", 0x400006, "w", 0x0627c831),
    ]),
    # B3 item 39: the sets with no gate-level frame (load lists from MAME cps1.cpp)
    "daimakair": (0x400000, [
        ("dam_01.3a", 0x000000, "w", 0x0ba9c0b0), ("dam_02.4a", 0x000002, "w", 0x5d760ab9),
        ("dam_03.5a", 0x000004, "w", 0x4ba90b59), ("dam_04.6a", 0x000006, "w", 0x4bdee9de),
        ("dam_05.7a", 0x200000, "w", 0x7dc61b94), ("dam_06.8a", 0x200002, "w", 0xfde89758),
        ("dam_07.9a", 0x200004, "w", 0xec351d78), ("dam_08.10a", 0x200006, "w", 0xee2acc1e),
    ]),
    "area88r": (0x200000, [
        ("ara_01.3a", 0x000000, "w", 0xbf4575d8), ("ara_02.4a", 0x000002, "w", 0xa02945f4),
        ("ara_03.5a", 0x000004, "w", 0x5965ca8d), ("ara_04.6a", 0x000006, "w", 0xac6db17d),
    ]),
    "qadjr": (0x200000, [
        ("qad_01.3a", 0x000000, "w", 0x9d853b57), ("qad_02.4a", 0x000002, "w", 0xb35976c4),
        ("qad_03.5a", 0x000004, "w", 0xcea4ca8c), ("qad_04.6a", 0x000006, "w", 0x41b74d1b),
    ]),
    "sf2ce": (0x600000, [
        ("s92-1m.3a", 0x000000, "w", 0x03b0d852), ("s92-3m.5a", 0x000002, "w", 0x840289ec),
        ("s92-2m.4a", 0x000004, "w", 0xcdb5f027), ("s92-4m.6a", 0x000006, "w", 0xe2799472),
        ("s92-5m.7a", 0x200000, "w", 0xba8a2761), ("s92-7m.9a", 0x200002, "w", 0xe584bfb5),
        ("s92-6m.8a", 0x200004, "w", 0x21e3f87d), ("s92-8m.10a", 0x200006, "w", 0xbefc47df),
        ("s92-10m.3c", 0x400000, "w", 0x960687d5), ("s92-12m.5c", 0x400002, "w", 0x978ecd18),
        ("s92-11m.4c", 0x400004, "w", 0xd6ec9a0a), ("s92-13m.6c", 0x400006, "w", 0xed2c67f6),
    ]),
    "varth": (0x200000, [
        ("va-5m.7a", 0x000000, "w", 0xb1fb726e), ("va-7m.9a", 0x000002, "w", 0x4c6588cd),
        ("va-1m.3a", 0x000004, "w", 0x0b1ace37), ("va-3m.5a", 0x000006, "w", 0x44dfe706),
    ]),
    "cawingjr": (0x200000, [
        ("usn_01.3a", 0x000000, "w", 0xc08ffb8b), ("usn_02.4a", 0x000002, "w", 0x37b1b27a),
        ("usn_03.5a", 0x000004, "w", 0x9f89a540), ("usn_04.6a", 0x000006, "w", 0x1f31f1d0),
    ]),
    "cworld2jb": (0x200000, [
        ("q5 - 01_91634b.3a", 0x000000, "w", 0x09d0e7ce), ("q5 - 02_91634b.4a", 0x000002, "w", 0x22e4ce9a),
        ("q5 - 03_91634b.5a", 0x000004, "w", 0xf7b3aed6), ("q5 - 04_91634b.6a", 0x000006, "w", 0x520c6c88),
    ]),
}


# The frame standard's other sets, from MAME's ROM_START blocks (gfxloads.json)
_AUTO = __import__("os").path.join(__import__("os").path.dirname(__import__("os").path.abspath(__file__)), "gfxloads.json")
if __import__("os").path.exists(_AUTO):
    for _n, (_size, _rows) in __import__("json").load(open(_AUTO)).items():
        LOADS.setdefault(_n, (_size, [tuple(r) for r in _rows]))


def build(game, zpath, out):
    size, loads = LOADS[game]
    region = bytearray(size)
    z = zipfile.ZipFile(zpath)
    names = {}
    for n in sorted(z.namelist(), key=lambda n: -n.count("/")):      # top-level entries last, so they win
        names[n.split("/")[-1]] = n
    by_crc = {i.CRC: i.filename for i in z.infolist()}
    for entry in loads:
        fname, off, kind = entry[:3]
        data = z.read(by_crc[entry[3]] if len(entry) > 3 else names[fname])
        if kind == "wc":                                            # ROM_LOAD64_WORD + ROM_CONTINUE at +4
            half = len(data) // 2
            for i in range(0, half, 2):
                region[off + 4 * i] = data[i]
                region[off + 4 * i + 1] = data[i + 1]
                region[off + 4 + 4 * i] = data[half + i]
                region[off + 4 + 4 * i + 1] = data[half + i + 1]
        elif kind == "w":
            for i in range(0, len(data), 2):
                region[off + 4 * i] = data[i]
                region[off + 4 * i + 1] = data[i + 1]
        else:
            for i in range(len(data)):
                region[off + 8 * i] = data[i]
    open(out, "wb").write(region)
    print(game, hex(size), "bytes ->", out)


if __name__ == "__main__":
    build(*sys.argv[1:4])
