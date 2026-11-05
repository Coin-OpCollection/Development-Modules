# NAND08

Eight-input NAND.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="NAND08_die.jpg"><img src="NAND08_die.jpg" width="760"></a><br>
  <small>UCT373 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 7 in the netlist

## Model

```verilog
module capcom_dl0921_NAND08 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    output wire p9
);

assign `D p9 = ~(p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8);

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="NAND08_drawing.png"><img src="NAND08_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), NAND08.
