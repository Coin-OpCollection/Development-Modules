# BUF12

Buffer.

**Confirmed, With Fixes.** Twenty-seven cells traced as BUF12 are BUF01 on the die.

<p align="center">
  <a href="BUF12_die.jpg"><img src="BUF12_die.jpg" height="240"></a><br>
  <small>UAK90 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 96 in the netlist

## Model

```verilog
module capcom_dl0921_BUF12 (
    input  wire p1,
    output wire p2
);

assign `D p2 = p1;

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="BUF12_drawing.png"><img src="BUF12_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), BUF12B.
