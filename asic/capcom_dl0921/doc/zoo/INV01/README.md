# INV01

Inverter.

**Confirmed, With Fixes.** Twelve cells traced as NBUF02 are INV01 on the die.

<p align="center">
  <a href="INV01_die.jpg"><img src="INV01_die.jpg" height="240"></a><br>
  <small>UCQ31 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 190 in the netlist

## Model

```verilog
module capcom_dl0921_INV01 (
    input  wire p1,
    output wire p2
);

assign `D p2 = ~p1;

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="INV01_drawing.png"><img src="INV01_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), INV01.
