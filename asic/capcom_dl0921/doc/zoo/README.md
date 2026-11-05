# CAPCOM DL-0921 (CPS-B-21) Cell Zoo

A folder for each of the 74 Ricoh A5C cell types the netlist uses, with one instance of the cell on the die at top metal and after two delayering steps, what it does, how it was read and its model in the cell library.

Confirmed means the cell matches its drawing in the trace and was checked on the die. Confirmed, With Fixes means the same, with cells the trace had as another type fixed to this one. Corrected means the die showed the cell differently, and its page says how. Original means the trace has no drawing of the cell and it was read from the die. 52 are confirmed, 7 confirmed with fixes, 3 corrected and 12 original.

\* Drawing by Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY).

| Cell | Function | Reading | Instances |
|------|----------|---------|-----------|
| [INV01](INV01/README.md) \* | Inverter | Confirmed, With Fixes | 190 |
| [BUF01](BUF01/README.md) \* | Buffer | Confirmed, With Fixes | 72 |
| [BUF12](BUF12/README.md) \* | Buffer | Confirmed, With Fixes | 96 |
| [NBUF02](NBUF02/README.md) \* | Inverting buffer | Confirmed, With Fixes | 6 |
| [NBUF03](NBUF03/README.md) \* | Inverting buffer | Confirmed, With Fixes | 9 |
| [DBUF](DBUF/README.md) \* | Two inverters in series, with the inverted output after the first and the true output after the second | Confirmed | 1 |
| [8BUF11](8BUF11/README.md) | Eight buffers, the inputs to the outputs in reverse pin order | Original | 2 |
| [AND02](AND02/README.md) \* | Two-input AND | Confirmed | 89 |
| [AND03](AND03/README.md) \* | Three-input AND | Confirmed | 10 |
| [AND04](AND04/README.md) \* | Four-input AND | Confirmed | 4 |
| [OR02](OR02/README.md) \* | Two-input OR | Confirmed | 64 |
| [OR03](OR03/README.md) \* | Three-input OR | Confirmed | 9 |
| [OR04](OR04/README.md) \* | Four-input OR | Confirmed | 11 |
| [NAND02](NAND02/README.md) \* | Two-input NAND | Confirmed | 74 |
| [NAND03](NAND03/README.md) \* | Three-input NAND | Confirmed | 18 |
| [NAND04](NAND04/README.md) \* | Four-input NAND | Confirmed | 23 |
| [NAND05](NAND05/README.md) \* | Five-input NAND | Confirmed | 28 |
| [NAND06](NAND06/README.md) \* | Six-input NAND | Confirmed | 2 |
| [NAND08](NAND08/README.md) \* | Eight-input NAND | Confirmed | 7 |
| [NAND13](NAND13/README.md) \* | Thirteen-input NAND | Confirmed | 12 |
| [NOR02](NOR02/README.md) \* | Two-input NOR | Confirmed | 33 |
| [NOR03](NOR03/README.md) \* | Three-input NOR | Confirmed | 17 |
| [NOR04](NOR04/README.md) \* | Four-input NOR | Confirmed | 21 |
| [NOR05](NOR05/README.md) \* | Five-input NOR | Confirmed | 15 |
| [XOR02](XOR02/README.md) \* | Two-input exclusive OR | Confirmed, With Fixes | 31 |
| [XNOR02](XNOR02/README.md) \* | Two-input exclusive NOR | Confirmed, With Fixes | 226 |
| [AO22](AO22/README.md) \* | AND-OR, two two-input ANDs into an OR | Confirmed | 16 |
| [AOI21](AOI21/README.md) \* | AND-OR-invert, a two-input AND and one input into a NOR | Confirmed | 5 |
| [AOI22](AOI22/README.md) \* | AND-OR-invert, two two-input ANDs into a NOR | Confirmed | 29 |
| [AOI33](AOI33/README.md) \* | AND-OR-invert, three three-input ANDs into a NOR | Confirmed | 1 |
| [AOI41](AOI41/README.md) | AND-OR-invert, a four-input AND and one input into a NOR | Original | 1 |
| [OAI21](OAI21/README.md) \* | OR-AND-invert, a two-input OR and one input into a NAND | Confirmed | 4 |
| [OAI211](OAI211/README.md) | OR-AND-invert, a two-input OR and two inputs into a NAND | Original | 1 |
| [OAI23](OAI23/README.md) \* | OR-AND-invert, three two-input ORs into a NAND | Confirmed | 2 |
| [OAI41](OAI41/README.md) \* | OR-AND-invert, a four-input OR and one input into a NAND | Confirmed | 1 |
| [M125C](M125C/README.md) | Tri-state buffer with an active-low enable, as the 74125 | Original | 1 |
| [M125C_X6](M125C_X6/README.md) | Six tri-state buffers on one active-low enable | Corrected | 42 |
| [OUTTRI](OUTTRI/README.md) \* | Tri-state driver with an active-low enable | Confirmed | 48 |
| [TINVBF](TINVBF/README.md) \* | Tri-state inverter with an active-low enable | Confirmed | 8 |
| [M367C](M367C/README.md) \* | Four tri-state buffers on one active-low enable, as the 74367 | Confirmed | 11 |
| [M368C](M368C/README.md) \* | Four tri-state inverters on one active-low enable, as the 74368 | Confirmed | 4 |
| [M541C](M541C/README.md) \* | Eight tri-state buffers on one active-low enable, as the 74541 | Confirmed | 14 |
| [MUX2H](MUX2H/README.md) \* | Two-to-one multiplexer | Confirmed | 2 |
| [MUX4H](MUX4H/README.md) \* | Four-to-one multiplexer | Confirmed | 1 |
| [MUX24H](MUX24H/README.md) | Two-to-one multiplexer of two 4-bit words | Original | 7 |
| [MUX25H](MUX25H/README.md) | Two-to-one multiplexer of two 5-bit words | Original | 4 |
| [MUX26H](MUX26H/README.md) | Two-to-one multiplexer of two 6-bit words | Original | 2 |
| [MUX28H](MUX28H/README.md) | Two-to-one multiplexer of two 8-bit words | Original | 2 |
| [MUX8GLH](MUX8GLH/README.md) \* | Eight-to-one multiplexer with true and inverted tri-state outputs | Confirmed | 24 |
| [M151C](M151C/README.md) \* | Eight-to-one multiplexer whose output is held low while the strobe is high, as the 74151 | Confirmed | 5 |
| [M152C](M152C/README.md) \* | Eight-to-one multiplexer with an inverted output, as the 74152 | Confirmed | 8 |
| [M157C](M157C/README.md) \* | Four two-to-one multiplexers whose outputs are held low while the enable is high, as the 74157 | Confirmed | 3 |
| [M258C](M258C/README.md) \* | Four two-to-one multiplexers with inverted tri-state outputs, as the 74258 | Confirmed | 9 |
| [D24GL](D24GL/README.md) \* | Two-to-four decoder with an enable | Confirmed | 1 |
| [D24L](D24L/README.md) \* | Two-to-four decoder with active-low outputs | Confirmed | 4 |
| [D38GL](D38GL/README.md) \* | Three-to-eight decoder with enables | Confirmed | 5 |
| [PRIO](PRIO/README.md) \* | Priority encoder of six inputs with an enable, active-low outputs | Confirmed | 1 |
| [DFFCOO](DFFCOO/README.md) \* | D flip-flop with an inverted output | Confirmed | 144 |
| [DFFCOR](DFFCOR/README.md) \* | D flip-flop with an active-low asynchronous clear and an inverted output | Confirmed | 93 |
| [DFFCOS](DFFCOS/README.md) \* | D flip-flop with an active-low asynchronous set | Confirmed | 26 |
| [DFGOO](DFGOO/README.md) \* | D flip-flop with a tri-state output on an active-low enable | Confirmed | 27 |
| [M164C](M164C/README.md) | Eight-bit serial-in, parallel-out shift register without a clear, as the 74164 | Original | 18 |
| [M198C](M198C/README.md) \* | Eight-bit shift register that holds, shifts either way or loads, as the 74198 | Confirmed | 16 |
| [M273C](M273C/README.md) \* | Eight-bit register with an active-low asynchronous clear, as the 74273 | Confirmed | 51 |
| [M273CG](M273CG/README.md) \* | Eight-bit register with tri-state outputs on an active-low enable | Confirmed | 18 |
| [L](L/README.md) \* | Latch, transparent while its enable is high | Confirmed | 5 |
| [L8](L8/README.md) | Eight-bit latch, transparent while pin 1 is high | Corrected | 4 |
| [L8G](L8G/README.md) \* | Eight-bit latch with tri-state outputs, transparent while pin 1 is low | Confirmed | 28 |
| [L8GH](L8GH/README.md) \* | Eight-bit latch with tri-state outputs, transparent while pin 1 is high | Corrected | 32 |
| [L8L](L8L/README.md) | Eight-bit latch with inverted outputs, transparent while pin 1 is high | Original | 2 |
| [R42](R42/README.md) \* | Four-bit latch of the inverted inputs with an active-low set | Confirmed | 3 |
| [R52](R52/README.md) | Five-bit latch of the inverted inputs with an active-low set | Original | 3 |
| [RSLT](RSLT/README.md) \* | Set / reset latch | Confirmed | 2 |
| [MULT](MULT/README.md) | Sixteen by sixteen multiplier with input registers, a product register and tri-state output halves | Original | 1 |

\* Drawing by Loïc "WydD" Petit, [cps2-reverse](https://gitlab.com/loic.petit/cps2-reverse) (CC BY).
