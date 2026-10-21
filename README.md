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

| Module | Device | Description | Die | Trace | Netlist |
|--------|--------|-------------|-----|-------|---------|
| [x6502](cpu/x6502/) | MOS&nbsp;Technology&nbsp;MCS6502 | NMOS&nbsp;8&#8209;bit&nbsp;Microprocessor | Yes | Complete | Complete |
| [x65c02](cpu/x65c02/) | Rockwell&nbsp;R65C02 | CMOS&nbsp;8&#8209;bit&nbsp;Microprocessor | Yes | In&#8209;Progress | x6502¹ |
| [x6280](cpu/x6280/) | Hudson&nbsp;Soft&nbsp;HuC6280 | CMOS&nbsp;8&#8209;bit&nbsp;Microprocessor&nbsp;with&nbsp;Timer,&nbsp;I/O&nbsp;Port&nbsp;and&nbsp;PSG | Yes | In&#8209;Progress | x6502¹ |
| [x68705](cpu/x68705/) | Motorola&nbsp;MC68705P3&nbsp;/&nbsp;MC68705P5 | M6805&nbsp;based&nbsp;8&#8209;bit&nbsp;EPROM&nbsp;MCU | No | - | - |

### Sound

| Module | Device | Description | Die | Trace | Netlist |
|--------|--------|-------------|-----|-------|---------|
| [x8910](sound/x8910/) | General&nbsp;Instrument&nbsp;AY&#8209;3&#8209;8910 | Programmable&nbsp;Sound&nbsp;Generator | Yes | In&#8209;Progress² | Complete² |
| [x76489](sound/x76489/) | Texas&nbsp;Instruments&nbsp;SN76489AN | Digital&nbsp;Complex&nbsp;Sound&nbsp;Generator | Yes | In&#8209;Progress² | Complete² |

<small>

¹ Built on the x6502 core.<br>
² Checked against a third-party netlist; our own trace of the die is in progress.

</small>

## Pending Modules

These modules are in development or final verification, and several already run in Coin-Op Collection cores. A module moves to Available Modules once its testbench, timing constraints, device usage and documentation are complete and it has held up through a period of public testing in released cores. The tables below are not a complete list; further modules are underway and will be added as they mature.

### CPU

| Module | Device | Description | Die | Trace | Netlist |
|--------|--------|-------------|-----|-------|---------|
| xZ80 | Zilog&nbsp;Z80&nbsp;(Z8400&nbsp;/&nbsp;Z84C00) | 8&#8209;bit&nbsp;Microprocessor | Yes | Complete | Complete |
| x5182 | Toshiba&nbsp;T5182 | Z80&nbsp;Sound&nbsp;CPU&nbsp;Package | Yes | xZ80³ | xZ80³ |
| x90840 | Toshiba&nbsp;TMP90C840&nbsp;(NMK&#8209;004) | TLCS&#8209;90&nbsp;8&#8209;bit&nbsp;MCU | No | - | - |
| x6801u4 | Motorola&nbsp;MC6801U4&nbsp;/&nbsp;MC6803U4 | 6801&nbsp;Family&nbsp;8&#8209;bit&nbsp;MCU | No | - | - |
| x63701 | Hitachi&nbsp;HD63701V0&nbsp;/&nbsp;HD63701Y0 | HD6301&nbsp;Family&nbsp;8&#8209;bit&nbsp;EPROM&nbsp;MCU | No | - | - |
| x6809 | Motorola&nbsp;MC6809E&nbsp;/&nbsp;MC6809,&nbsp;Hitachi&nbsp;HD6309E | 8&#8209;bit&nbsp;Microprocessor | Yes | In&#8209;Progress | No |
| xM68K | Motorola&nbsp;MC68000&nbsp;/&nbsp;MC68HC000&#8209;1&nbsp;/&nbsp;MC68EC000&nbsp;/&nbsp;MC68008 | 16/32&#8209;bit&nbsp;Microprocessor | Yes | Complete | Complete |
| x8751 | Intel&nbsp;8751H | MCS&#8209;51&nbsp;8&#8209;bit&nbsp;EPROM&nbsp;MCU | Yes | In&#8209;Progress | No |

### Sound

| Module | Device | Description | Die | Trace | Netlist |
|--------|--------|-------------|-----|-------|---------|
| x5205 | OKI&nbsp;MSM5205 | ADPCM&nbsp;Speech&nbsp;Synthesizer | No | - | - |
| x6295 | OKI&nbsp;MSM6295 | 4&#8209;Channel&nbsp;ADPCM&nbsp;Speech&nbsp;Synthesizer | No | - | - |
| x2203 | Yamaha&nbsp;YM2203&nbsp;(OPN) | FM&nbsp;Sound&nbsp;Generator&nbsp;with&nbsp;SSG | Yes | In&#8209;Progress | No |
| x2610 | Yamaha&nbsp;YM2610&nbsp;(OPNB) | FM&nbsp;Sound&nbsp;Generator&nbsp;with&nbsp;SSG&nbsp;and&nbsp;ADPCM | Yes | In&#8209;Progress | No |
| x8950 | Yamaha&nbsp;Y8950&nbsp;(MSX&#8209;AUDIO) | FM&nbsp;Sound&nbsp;Generator&nbsp;with&nbsp;ADPCM | Yes | In&#8209;Progress | No |
| x3812 | Yamaha&nbsp;YM3812&nbsp;(OPL2) | FM&nbsp;Sound&nbsp;Generator | Yes | In&#8209;Progress | No |
| xF262 | Yamaha&nbsp;YMF262&nbsp;(OPL3) | FM&nbsp;Sound&nbsp;Generator | Yes | In&#8209;Progress | No |
| xF271 | Yamaha&nbsp;YMF271&nbsp;(OPX) | FM&nbsp;and&nbsp;PCM&nbsp;Sound&nbsp;Generator | Yes | In&#8209;Progress | No |
| x7759 | NEC&nbsp;uPD7759 | ADPCM&nbsp;Speech&nbsp;Synthesizer | Yes | In&#8209;Progress | No |
| x1425 | AT&T&nbsp;WE&nbsp;DSP16A | QSound&nbsp;DSP&nbsp;(CAPCOM&nbsp;DL&#8209;1425) | Yes | In&#8209;Progress | No |
| xCUS30 | Namco&nbsp;CUS30 | Wave&nbsp;Sound&nbsp;Generator | Yes | In&#8209;Progress | No |

### Graphics

| Module | Device | Description | Die | Trace | Netlist |
|--------|--------|-------------|-----|-------|---------|
| x6270 | Hudson&nbsp;Soft&nbsp;HuC6270 | Video&nbsp;Display&nbsp;Controller:&nbsp;Tile&nbsp;Background&nbsp;and&nbsp;Sprites | Yes | In&#8209;Progress | No |
| capcom_dl0311 | CAPCOM&nbsp;DL&#8209;0311&nbsp;(CPS&#8209;A&#8209;01) | CPS1&nbsp;Video&nbsp;Controller:&nbsp;Scroll&nbsp;Layers,&nbsp;Sprites&nbsp;and&nbsp;Palette | Yes | Complete | Complete |
| capcom_dl0921 | CAPCOM&nbsp;DL&#8209;0921&nbsp;(CPS&#8209;B&#8209;21) | CPS1&nbsp;Video&nbsp;Mixer:&nbsp;Layer&nbsp;Priority,&nbsp;Palette,&nbsp;Raster&nbsp;Interrupt,&nbsp;Multiplier&nbsp;and&nbsp;Configuration&nbsp;Key | Yes | In&#8209;Progress | No |
| TBD | Data&nbsp;East&nbsp;DECO&nbsp;52 | Sprite&nbsp;Generator | Yes | In&#8209;Progress | No |
| TBD | Data&nbsp;East&nbsp;DECO&nbsp;55 | Tile&nbsp;Generator&nbsp;with&nbsp;Row&nbsp;and&nbsp;Column&nbsp;Scroll | Yes | In&#8209;Progress | No |
| TBD | Data&nbsp;East&nbsp;DECO&nbsp;56 | Tile&nbsp;Generator&nbsp;with&nbsp;Row&nbsp;and&nbsp;Column&nbsp;Scroll&nbsp;and&nbsp;On&#8209;Chip&nbsp;Decryption | Yes | In&#8209;Progress | No |

<small>

³ Built on the xZ80 core; the rest of the package was identified.<br><br>
Die: Yes, die photographs of the chip are available; No, none are available.<br>
Trace: the chip's layers traced from the die photographs: Complete, In-Progress, No when not traced, or - when there is no die.<br>
Netlist: the transistor- or gate-level netlist extracted from the trace, which the module is checked against: Complete, In-Progress, No when there is none, or - when there is no die.

</small>

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
