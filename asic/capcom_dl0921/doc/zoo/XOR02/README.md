# XOR02

Two-input exclusive OR.

**Confirmed, With Fixes.** UBW384, traced as XNOR02, is an XOR02 on the die.

<p align="center">
  <a href="XOR02_die.jpg"><img src="XOR02_die.jpg" height="240"></a><br>
  <small>UCS41 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 31 in the netlist

## Model

```verilog
module capcom_dl0921_XOR02 (
    input  wire p1,
    input  wire p2,
    output wire p3
);

assign `D p3 = p1 ^ p2;

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="XOR02_drawing.png"><img src="XOR02_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), XOR02.
