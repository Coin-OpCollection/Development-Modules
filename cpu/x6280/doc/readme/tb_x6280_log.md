# x6280 Chip Regression Log

Full output of the `tb_x6280` testbench (64 tests). See [README.md](../../README.md#design-verification) for the section-by-section description.

```
=============================================================
  x6280 Chip-Level Testbench
=============================================================

=============================================================
 Section 1: External Strobes and Chip Enables
=============================================================
PASS: program runs to the end
PASS: read 1FE000: rd_n low, ce7_n low, cek_n high, 2 enables (CE wait)
PASS: write 1FE002: wr_n low, ce7_n low, data in the external memory
PASS: read 1FE404: rd_n low, cek_n low, ce7_n high
PASS: write 1FE402: wr_n low, cek_n low
PASS: write 1FE800 (PSG): no external strobe
PASS: read 1FEC00 (timer): no external strobe
PASS: read 1FF000 (port K): no external strobe
PASS: read 1FF402 (interrupt registers): no external strobe
PASS: read 1F0000: rd_n low, cer_n low
PASS: write 1F0001: wr_n low, cer_n low
PASS: read 002000: rd_n low, no chip enable
PASS: internal cycles (12): rd_n and wr_n high (INT_RD = 0)
PASS: internal cycles with rd_n high in uutr (INT_RD = 1) = 00000000

=============================================================
 Section 2: Interrupt Controller
=============================================================
PASS: program runs to the end
PASS: interrupt disable register read back (low 3 bits) = 00000005
PASS: request register: IRQ1 pin low -> bit 1 = 00000002
PASS: IRQ1 disabled by IDR bit 1: no entry = 00000000
PASS: IRQ1 enabled: entry through FFF8 = 00000011
PASS: IRQ1 and IRQ2 low: IRQ1 first, then IRQ2 = 00001111

=============================================================
 Section 3: Timer
=============================================================
PASS: timer stopped and TIQ clear after reset = 00000000
PASS: first borrow (TIQ) after start: (reload + 1) x 1024 enables = 00000c00
PASS: next borrow after the reload = 00000c00
PASS: timer interrupt entries through FFFA, acknowledged by an IRR write = 00000002
PASS: low speed: borrow after (1 + 1) x 1024 enables = 00000800

=============================================================
 Section 4: I/O Ports
=============================================================
PASS: port O after reset = 000000ff
PASS: port K read at 1FF000 = 0000005a
PASS: port O written at 1FF000 = 0000003c

=============================================================
 Section 5: PSG
=============================================================
PASS: DDA 1F at full level: output above zero
PASS: PSG = 0 instance: output = 00000000
PASS: attenuation index 29 (AL = 02, LMAL = LAL = F): output above zero
PASS: attenuation index 30 (45 dB): silent = 00000000
PASS: PSG read returns the I/O buffer (5A) = 0000005a
PASS: reset: every waveform address 0
PASS: volume curve entries 5, 6, 9, 12, 14, 15 = round(2048 x 10^(-1.5 i / 20))
PASS: LFO off: channel 2 steps every 2 x F = 34 enables
PASS: LFO on: channel 1 steps every 2 x F x FLF = 30 enables
PASS: LFO on: channel 2 still steps every 34 enables
PASS: LFO frequency 0 counts 256: channel 1 steps every 1536 enables
PASS: LF CTL 1, channel 1 data 00: channel 0 steps every 992 enables
PASS: LF CTL 2, channel 1 data 00: channel 0 steps every 896 enables
PASS: LF CTL 3, channel 1 data 00: channel 0 steps every 512 enables
PASS: LF CTL 3, channel 1 data 1f: channel 0 steps every 1504 enables
PASS: LF CTL 3, channel 1 data 10: channel 0 steps every 1024 enables
PASS: channel 0 follows channel 1's waveform: periods 528 and 496 only, both seen
PASS: LF TRG: channel 1 returns to address 0 and holds there
PASS: LF TRG: channel 0 modulated by channel 1 word 0 (-16): 480 enables
PASS: LF TRG cleared: channel 1 steps every 12 enables again
PASS: channel 1 off: channel 0 unmodulated, 2 x F = 512 enables
PASS: channel 1 off: its waveform address does not run
PASS: DDA set: waveform address 0 and held
PASS: channel 4 with NE and DDA set: noise output, not the DDA latch
PASS: channel 1 audible while it runs the LFO: data 1F at full scale = 00007800
PASS: LFO off: channel 1 steps every 2 x F = 8 enables
PASS: R0 = 6 or 7: R4 writes reach no channel

=============================================================
 Section 6: CSL / CSH Enable
=============================================================
PASS: after reset: 4 enables per cycle, hsm low
PASS: after CSH: 1 enable per cycle, hsm high
PASS: after CSL: 4 enables per cycle, hsm low
PASS: CSL after 0 NOPs: cycles 1-2 one enable, cycle 3 and the NOP after it 4 enables each
PASS: CSL after 1 NOPs: cycles 1-2 one enable, cycle 3 and the NOP after it 4 enables each
PASS: CSL after 2 NOPs: cycles 1-2 one enable, cycle 3 and the NOP after it 4 enables each
PASS: CSL after 3 NOPs: cycles 1-2 one enable, cycle 3 and the NOP after it 4 enables each

=============================================================
 Section 7: RDY and the CE7 / CEK Wait
=============================================================
PASS: write held by RDY: one cycle of several enables, one external write
PASS: read of 1FE000 at high speed: enables = 00000002

=============================================================
  x6280 Chip Test Results
=============================================================
  Total Tests:  64
  Passed:       64
  Failed:       0
=============================================================
  *** ALL TESTS PASSED ***
=============================================================
```
