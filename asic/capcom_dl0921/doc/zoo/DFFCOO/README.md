# DFFCOO

D flip-flop with an inverted output.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="DFFCOO_die.jpg"><img src="DFFCOO_die.jpg" height="240"></a><br>
  <small>UCJ162 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 144 in the netlist

## Model

```verilog
module capcom_dl0921_DFFCOO (
    input  wire p1,
    input  wire p2,
    output reg  p3,
    output wire p5
);

initial p3 = 1'b0;

always @(posedge p1) begin
    p3 <= `Q p2;
end

assign p5 = ~p3;

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="DFFCOO_drawing.png"><img src="DFFCOO_drawing.png" height="240"></a></td><td align="center"><a href="DFFCOO_drawing_pins.png"><img src="DFFCOO_drawing_pins.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td><td align="center"><b>Drawing With Pin Numbers</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), DFFCOO.
