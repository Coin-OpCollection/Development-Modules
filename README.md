# Development-Modules

<table align="center">
  <tr>
    <td align="center" style="padding: 10px;">
      <img align="center" src="cpu/x68705/img/coc_banner.png">
    </td>
  </tr>
</table>

## Overview

Verified Verilog IP modules for FPGA-based applications. Each module targets cycle-accurate, fully synchronous behavior verified against available documentation such as manufacturer datasheets, user and data manuals, and gate-level schematics traced from silicon.

## Available Modules

### CPU

| Module | Device | Description |
|--------|--------|-------------|
| [x6502](cpu/x6502/) | MOS Technology 6502 | NMOS 8-bit Microprocessor |
| [x65c02](cpu/x65c02/) | Rockwell R65C02 | CMOS 8-bit Microprocessor |
| [x68705](cpu/x68705/) | Motorola MC68705P3 | M6805 based 8-bit EPROM MCU |

### Sound

| Module | Device | Description |
|--------|--------|-------------|
| [x76489](sound/x76489/) | Texas Instruments SN76489AN | Digital Complex Sound Generator |
| [x8910](sound/x8910/) | General Instrument AY-3-8910 | Programmable Sound Generator |

## Design Principles

<small>

- **Fully Synchronous**: All state changes on `posedge clk` with clock enable. No latches or asynchronous logic.
- **Register Compatible**: Internal register maps match original device specifications.
- **Datasheet Verified**: All behavior cross-referenced against original manufacturer documentation.
- **Simulation Proven**: Each module includes a comprehensive ModelSim testbench with documented results.

</small>

## License

This work is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License](LICENSE) (CC BY-NC 4.0). You may use, share, and modify this code for non-commercial purposes, provided that proper credit is given.

## Support

Please consider supporting this and future projects by joining the [**Coin-Op Collection Patreon**](https://www.patreon.com/atrac17).

---
