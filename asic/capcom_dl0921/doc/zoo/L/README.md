# L

Latch, transparent while its enable is high.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="L_die.jpg"><img src="L_die.jpg" height="240"></a><br>
  <small>UBZ493 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 5 in the netlist

## Model

```verilog
module capcom_dl0921_L (
    input  wire p1,
    input  wire p2,
    output reg  p3
);

initial p3 = 1'b0;

always @* begin
    if(p1) p3 = p2;
end

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="L_drawing.png"><img src="L_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), L.
