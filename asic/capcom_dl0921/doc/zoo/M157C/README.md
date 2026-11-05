# M157C

Four two-to-one multiplexers whose outputs are held low while the enable is high, as the 74157.

**Confirmed.** Matches its drawing in the trace, checked on the die.

<p align="center">
  <a href="M157C_die.jpg"><img src="M157C_die.jpg" height="240"></a><br>
  <small>UBN328 at top metal, delayering step 3 and delayering step 5 (top to bottom)</small>
</p>

- **Instances**: 3 in the netlist

## Model

```verilog
module capcom_dl0921_M157C (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p13,
    input  wire p14,
    output wire p5,
    output wire p6,
    output wire p7,
    output wire p8
);

wire [3:0] a = {p1, p2, p3, p4};
wire [3:0] b = {p10, p11, p12, p13};

assign `D {p8, p7, p6, p5} = p14 ? 4'b0 : (p9 ? b : a);

endmodule
```

## Drawing

<table align="center">
  <tr><td align="center"><a href="M157C_drawing.png"><img src="M157C_drawing.png" height="240"></a></td><td align="center"><a href="M157C_drawing_pins.png"><img src="M157C_drawing_pins.png" height="240"></a></td></tr>
  <tr><td align="center"><b>Drawing</b></td><td align="center"><b>Drawing With Pin Numbers</b></td></tr>
</table>

Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY), M157C.
