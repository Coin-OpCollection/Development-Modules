# DFFCOS

D flip-flop with an active-low asynchronous set.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="DFFCOS_die.jpg"><img src="DFFCOS_die.jpg" height="240"></a><br>
  <small>UBU165 at top metal, delayering step 3 and delayering step 5 (left to right)</small>
</p>

- **Instances**: 26 in the netlist

## Model

```verilog
module capcom_dl0921_DFFCOS (
    input  wire p1,
    input  wire p2,
    input  wire p4,
    output reg  p3
);

wire c;

initial p3 = 1'b0;

assign `MPW c = p4;

always @(posedge p1 or negedge c) begin
    if(!c) p3 <= `Q 1'b1;
    else p3 <= `Q p2;
end

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="DFFCOS_drawing.png"><img src="DFFCOS_drawing.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), DFF-3.
