# OUTTRI

Tri-state driver with an active-low enable.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="OUTTRI_die.jpg"><img src="OUTTRI_die.jpg" height="240"></a><br>
  <small>UCT292 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 48 in the netlist
- Pin 1 is the active-low output enable.

## Model

```verilog
module capcom_dl0921_OUTTRI (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 ? 1'bz : p2;

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="OUTTRI_drawing.png"><img src="OUTTRI_drawing.png" height="240"></a></td><td align="center"><a href="OUTTRI_drawing_pins.png"><img src="OUTTRI_drawing_pins.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td><td align="center"><b>Drawing With Pin Numbers</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), OUTTRI.
