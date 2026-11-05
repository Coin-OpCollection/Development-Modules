# NBUF02

Inverting buffer.

**Confirmed, With Fixes.** Fourteen cells traced as NBUF02 are other cells on the die, twelve INV01 and two NBUF03.

<p align="center">
  <a href="NBUF02_die.jpg"><img src="NBUF02_die.jpg" height="240"></a><br>
  <small>UBW436 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 6 in the netlist

## Model

```verilog
module capcom_dl0921_NBUF02 (
    input  wire p1,
    output wire p2
);

assign `D p2 = ~p1;

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="NBUF02_drawing.png"><img src="NBUF02_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), NBUF02.
