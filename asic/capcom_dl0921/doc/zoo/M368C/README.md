# M368C

Four tri-state inverters on one active-low enable, as the 74368.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="M368C_die.jpg"><img src="M368C_die.jpg" height="240"></a><br>
  <small>UCG174 at top metal, delayering step 3 and delayering step 5 (top to bottom)</small>
</p>

- **Instances**: 4 in the netlist
- Pin 1 is the active-low output enable.

## Model

```verilog
module capcom_dl0921_M368C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p18,
    output wire p17,
    output wire p16,
    output wire p15
);

assign `D {p15, p16, p17, p18} = p1 ? 4'bz : ~{p5, p4, p3, p2};

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="M368C_drawing.png"><img src="M368C_drawing.png" height="240"></a></td><td align="center"><a href="M368C_drawing_pins.png"><img src="M368C_drawing_pins.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td><td align="center"><b>Drawing With Pin Numbers</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), M368C.
