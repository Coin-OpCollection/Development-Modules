# OAI41

OR-AND-invert, a four-input OR and one input into a NAND.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="OAI41_die.jpg"><img src="OAI41_die.jpg" height="240"></a><br>
  <small>UCL463 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 1 in the netlist
- The input groups follow the symbol geometry.

## Model

```verilog
module capcom_dl0921_OAI41 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    output wire p6
);

assign `D p6 = ~(p1 & (p2 | p3 | p4 | p5));

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="OAI41_drawing.png"><img src="OAI41_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), OAI41.
