# NAND05

Five-input NAND.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="NAND05_die.jpg"><img src="NAND05_die.jpg" height="240"></a><br>
  <small>UCS12 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 28 in the netlist

## Model

```verilog
module capcom_dl0921_NAND05 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p6
);

assign `D p6 = ~(p1 & p2 & p3 & p4 & p5);

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="NAND05_drawing.png"><img src="NAND05_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), NAND05.
