# OAI21

OR-AND-invert, a two-input OR and one input into a NAND.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="OAI21_die.jpg"><img src="OAI21_die.jpg" height="240"></a><br>
  <small>UBN110 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 4 in the netlist
- The input groups follow the symbol geometry.

## Model

```verilog
module capcom_dl0921_OAI21 (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    output wire p4
);

assign `D p4 = ~(p1 & (p2 | p3));

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="OAI21_drawing.png"><img src="OAI21_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), OAI21.
