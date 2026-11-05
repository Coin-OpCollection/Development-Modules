# MUX26H

Two-to-one multiplexer of two 6-bit words.

**Original.** The trace has no drawing of this cell; it was read from the die.

<p align="center">
  <a href="MUX26H_die.jpg"><img src="MUX26H_die.jpg" height="240"></a><br>
  <small>UBU187 at top metal, delayering step 3 and delayering step 5 (top to bottom)</small>
</p>

- **Instances**: 2 in the netlist

## Model

```verilog
module capcom_dl0921_MUX26H (
    input  wire p1,
    input  wire p2,
    input  wire p3,
    input  wire p4,
    input  wire p5,
    input  wire p6,
    input  wire p7,
    input  wire p8,
    input  wire p9,
    input  wire p10,
    input  wire p11,
    input  wire p12,
    input  wire p19,
    output wire p13,
    output wire p14,
    output wire p15,
    output wire p16,
    output wire p17,
    output wire p18
);

wire [5:0] a = {p6, p5, p4, p3, p2, p1};
wire [5:0] b = {p12, p11, p10, p9, p8, p7};

assign `D {p18, p17, p16, p15, p14, p13} = p19 ? b : a;

endmodule
```
