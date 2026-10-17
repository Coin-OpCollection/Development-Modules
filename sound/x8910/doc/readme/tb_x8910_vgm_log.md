# x8910 VGM Playback Log

Output of the `tb_x8910_vgm` testbench for one AY-3-8910 VGM, Mat Mania BGM command $01 on the first AY (1,500,000 Hz, 3,504 commands). See [README.md](../../README.md#vgm-playback) for the pipeline.

```
=============================================================
  x8910 (AY-3-8910) VGM Playlist Testbench
=============================================================

  [Track 1] clock=1500000 Hz
    -> 248364 samples (5.6 sec)

=============================================================
  Playlist complete: 1 track(s)
  Run: python sim/scripts/wav_batch.py
=============================================================
```

`wav_batch.py`: `cmd0x01_ay1.wav`, 5.63 s, 248,364 samples at 44,100 Hz.
