# Development-Modules

<table align="center">
  <tr>
    <td align="center" style="padding: 10px;">
      <img align="center" src="cpu/x68705/img/coc_banner.png">
    </td>
  </tr>
</table>

## Overview

Verified Verilog IP modules for FPGA-based applications. Each module reproduces an original device, the CPUs to the cycle and the sound generators as functional equivalents of the silicon. Every module is checked against the manufacturer's documentation and, where available, against published test suites, transistor-level netlists, die schematics, circuits the author has traced from die photographs, and bus captures and measurements of the original parts. Each module documents its sources, behavior and verification.

## Available Modules

### CPU

| Module | Device | Description | Netlist / Die |
|--------|--------|-------------|---------------|
| [x6502](cpu/x6502/) | MOS Technology MCS6502 | NMOS 8-bit Microprocessor | Available |
| [x65c02](cpu/x65c02/) | Rockwell R65C02 | CMOS 8-bit Microprocessor | Available |
| [x6280](cpu/x6280/) | Hudson Soft HuC6280 | CMOS 8-bit Microprocessor with Timer, I/O Port and PSG | Available |
| [x68705](cpu/x68705/) | Motorola MC68705P3 / MC68705P5 | M6805 based 8-bit EPROM MCU | N/A |

### Sound

| Module | Device | Description | Netlist / Die |
|--------|--------|-------------|---------------|
| [x8910](sound/x8910/) | General Instrument AY-3-8910 | Programmable Sound Generator | Available |
| [x76489](sound/x76489/) | Texas Instruments SN76489AN | Digital Complex Sound Generator | Available |

## Pending Modules

These modules are in development or final verification, and several already run in Coin-Op Collection cores. A module moves to Available Modules once its testbench, timing constraints, device usage and documentation are complete and it has held up through a period of public testing in released cores. The tables below are not a complete list; further modules are underway and will be added as they mature.

Netlist / Die marks a module checked against a transistor-level netlist or a die-traced model of the chip or its family.

### CPU

| Module | Device | Description | Netlist / Die |
|--------|--------|-------------|---------------|
| xZ80 | Zilog Z80 (Z8400 / Z84C00) | 8-bit Microprocessor | Available |
| x5182 | Toshiba T5182 | Z80 Sound CPU Package | Available |
| x90840 | Toshiba TMP90C840 (NMK-004) | TLCS-90 8-bit MCU | In-Progress |
| x6801u4 | Motorola MC6801U4 / MC6803U4 | 6801 Family 8-bit MCU | N/A |
| x63701 | Hitachi HD63701V0 / HD63701Y0 | HD6301 Family 8-bit EPROM MCU | N/A |
| x6809 | Motorola MC6809E / MC6809, Hitachi HD6309E | 8-bit Microprocessor | N/A |
| xM68K | Motorola MC68000 / MC68HC000-1 / MC68EC000 / MC68008 | 16/32-bit Microprocessor | Available |
| x8751 | Intel 8751H | MCS-51 8-bit EPROM MCU | N/A |

### Sound

| Module | Device | Description | Netlist / Die |
|--------|--------|-------------|---------------|
| x5205 | OKI MSM5205 | ADPCM Speech Synthesizer | N/A |
| x6295 | OKI MSM6295 | 4-Channel ADPCM Speech Synthesizer | N/A |
| x2203 | Yamaha YM2203 (OPN) | FM Sound Generator with SSG | Available |
| x2610 | Yamaha YM2610 (OPNB) | FM Sound Generator with SSG and ADPCM | Available |
| x8950 | Yamaha Y8950 (MSX-AUDIO) | FM Sound Generator with ADPCM | Available |
| x3812 | Yamaha YM3812 (OPL2) | FM Sound Generator | Available |
| xF262 | Yamaha YMF262 (OPL3) | FM Sound Generator | Available |
| xF271 | Yamaha YMF271 (OPX) | FM and PCM Sound Generator | Available |
| x7759 | NEC uPD7759 | ADPCM Speech Synthesizer | N/A |
| x1425 | AT&T WE DSP16A | QSound DSP (CAPCOM DL-1425) | In-Progress |

### Graphics

| Module | Device | Description | Netlist / Die |
|--------|--------|-------------|---------------|
| x6270 | Hudson Soft HuC6270 | Video Display Controller: Tile Background and Sprites | In-Progress |
| x0311 | CAPCOM DL-0311 | CPS1 Video Controller: Scroll Layers, Sprites and Palette | Available |
| TBD | Data East DECO 52 | Sprite Generator | In-Progress |
| TBD | Data East DECO 55 | Tile Generator with Row and Column Scroll | In-Progress |
| TBD | Data East DECO 56 | Tile Generator with Row and Column Scroll and On-Chip Decryption | In-Progress |

## Design Principles

<small>

- **Fully Synchronous**: All state changes on the rising edge of a single system clock, with device timing advanced by a clock enable. No latches or asynchronous logic.
- **Register Compatible**: Internal register maps match original device specifications.
- **Datasheet Verified**: Behavior is cross-referenced against original manufacturer documentation; where it is silent or sources disagree, each module's readme states the source followed.
- **Silicon Behavior Preserved**: Device quirks are kept rather than cleaned up; any idealization is documented in the module's readme.
- **No Microcode**: CPU modules are explicit per-cycle state machines.
- **Simulation Proven**: Each module includes a comprehensive ModelSim testbench with documented results.
- **Externally Validated**: Where available, CPUs run against published test suites, netlists and bus recordings; sound generators render WAV files from VGM register logs for comparison with the original hardware.
- **Timing Closure**: Each module meets timing at 96 MHz on both Cyclone V parts; where needed, its own SDC relaxes the enable-paced paths from one setting in the core SDC.
- **Self-Contained Package**: Each module ships its Verilog sources, a Quartus include file, an SDC where needed, a self-checking testbench with logs, reference documents and a readme.

</small>

## License

This work is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License](LICENSE) (CC BY-NC 4.0). You may use, share, and modify this code for non-commercial purposes, provided that proper credit is given.

## Support

Please consider supporting this and future projects by joining the [**Coin-Op Collection Patreon**](https://www.patreon.com/atrac17).

---
