# OR03

Three-input OR.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="OR03_die.jpg"><img src="OR03_die.jpg" height="240"></a><br>
  <small>UCR519 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 9 in the netlist

## Model

```verilog
module capcom_dl0921_OR03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = p1 | p2 | p3;

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="OR03_drawing.png"><img src="OR03_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), OR03.
