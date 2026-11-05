# NOR03

Three-input NOR.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="NOR03_die.jpg"><img src="NOR03_die.jpg" height="240"></a><br>
  <small>UCJ151 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 17 in the netlist

## Model

```verilog
module capcom_dl0921_NOR03 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = ~(p1 | p2 | p3);

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="NOR03_drawing.png"><img src="NOR03_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), NOR03.
