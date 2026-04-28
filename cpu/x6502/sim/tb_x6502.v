/*
* <-- Coin-Op Collection -->
* https://coinopcollection.org
* https://github.com/Coin-OpCollection/
*
* Author: atrac17 (https://twitter.com/_atrac17)
* Copyright © 2026 Coin-Op Collection
*
* This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/.
*
* You may use, share, and modify this code for non-commercial purposes, provided that proper credit is given.
*/

//============================================================================
//  Comprehensive testbench for the NMOS 6502 CPU implementation.
//
//  Verifies functional correctness and cycle-accurate timing per the MOS
//  Technology MCS6500 Hardware Manual. Tests are organised by addressing
//  mode following the same pattern as the x68705 testbench: each test
//  forces the CPU into a known state, places opcode and operands into
//  ROM or RAM, executes the instruction, and checks register state,
//  flags, memory side-effects, and cycle count.
//
//  ALU-direct verification (Sections 25 - 34) drives a second
//  x6502_alu instance from the testbench so corner cases that are not
//  cleanly observable through the CPU instruction stream - for example
//  the EQ1 / EQ2 pass-through ops and specific BCD nibble adjustments -
//  can be exercised with deterministic stimulus.
//
//  Test Organization:
//    Section 1:  Reset sequence (vector fetch from $FFFC/$FFFD)
//    Section 2:  Implied/inherent (NOP, flag set/clear, INX/INY/DEX/DEY, TAX/TAY/TXA/TYA/TSX/TXS)
//    Section 3:  Immediate (LDA #, LDX #, LDY #, ADC #, SBC #, AND #, ORA #, EOR #, CMP #, CPX #, CPY #)
//    Section 4:  Zero page reads (LDA, LDX, LDY, ADC, SBC, AND, ORA, EOR, CMP, CPX, CPY, BIT)
//    Section 5:  Zero page writes (STA, STX, STY)
//    Section 6:  Conditional branches (BPL, BMI, BVC, BVS, BCC, BCS, BNE, BEQ; taken, not taken, page cross)
//    Section 7:  JMP absolute
//    Section 8:  Absolute reads (LDA, LDX, LDY, ADC, SBC, AND, ORA, EOR, CMP, CPX, CPY, BIT)
//    Section 9:  Absolute writes (STA, STX, STY)
//    Section 10: Accumulator shifts (ASL A, LSR A, ROL A, ROR A)
//    Section 11: Stack push / pull (PHA, PHP, PLA, PLP)
//    Section 12: JMP indirect (normal + NMOS page-wrap bug)
//    Section 13: Zero page indexed reads (LDA/LDY zp,X; LDX zp,Y; ADC/SBC/AND/ORA/EOR/CMP zp,X)
//    Section 14: Zero page indexed writes (STA/STY zp,X; STX zp,Y)
//    Section 15: Absolute indexed reads (LDA/LDY abs,X; LDX/LDA abs,Y; ADC/SBC/AND/ORA/EOR/CMP abs,X/Y; no-cross and page-cross paths)
//    Section 16: Absolute indexed writes (STA abs,X / abs,Y; fixed 5)
//    Section 17: Indexed indirect (ZP,X) reads / write (LDA/ADC/SBC/AND/ORA/EOR/CMP; STA)
//    Section 18: Indirect indexed (ZP),Y reads / write (LDA/ADC/SBC/AND/ORA/EOR/CMP; STA)
//    Section 19: JSR / RTS round trip
//    Section 20: RMW zero page (ASL, LSR, ROL, ROR, INC, DEC)
//    Section 21: RMW zero page,X / absolute / absolute,X
//    Section 22: BRK + RTI round trip (B flag pushed, vector $FFFE/F)
//    Section 23: IRQ injection (B flag clear, gated by I flag, RTI)
//    Section 24: NMI injection (falling edge, vector $FFFA/B)
//    Section 25: ALU logical operations (ORA, AND, EOR, flag preservation)
//    Section 26: ALU pass-through (EQ1 no flags, EQ2 N/Z update)
//    Section 27: ALU increment / decrement (INC, DEC)
//    Section 28: ALU shift / rotate (ASL, LSR, ROL, ROR)
//    Section 29: ALU ADC binary mode (carry, overflow scenarios)
//    Section 30: ALU ADC decimal mode (BCD half-carry, high-carry adjust)
//    Section 31: ALU SBC binary mode (carry, overflow scenarios)
//    Section 32: ALU SBC decimal mode (BCD borrow adjust)
//    Section 33: ALU CMP (carry-in forced, flag-only update)
//    Section 34: ALU BIT (V from b[6], N from b[7], Z from a & b)
//    Section 35: VP_n Vector Pull (BRK, IRQ, NMI vector-fetch cycles)
//    Section 36: RDY Read-Cycle Stall (read halt, write bypass, resume)
//
//  Cycle Timing Reference (NMOS 6502, MCS6500 Hardware Manual):
//    Implied / accumulator : 2 cycles
//    Immediate             : 2 cycles
//    Zero page read        : 3 cycles
//    Zero page write       : 3 cycles
//    Zero page,X/Y read    : 4 cycles
//    Zero page,X/Y write   : 4 cycles
//    Absolute read         : 4 cycles
//    Absolute write        : 4 cycles
//    Absolute,X/Y read     : 4 cycles (+1 page cross)
//    Absolute,X/Y write    : 5 cycles
//    (ZP,X) read / write   : 6 cycles
//    (ZP),Y read           : 5 cycles (+1 page cross)
//    (ZP),Y write          : 6 cycles
//    Stack push (PHA/PHP)  : 3 cycles
//    Stack pull (PLA/PLP)  : 4 cycles
//    JSR / RTS             : 6 cycles
//    RMW zp                : 5 cycles
//    RMW zp,X              : 6 cycles
//    RMW abs               : 6 cycles
//    RMW abs,X             : 7 cycles (fixed)
//    BRK / IRQ / NMI       : 7 cycles
//    RTI                   : 6 cycles
//    Branch not taken      : 2 cycles
//    Branch taken          : 3 cycles
//    Branch taken + cross  : 4 cycles
//    JMP absolute          : 3 cycles
//    JMP indirect          : 5 cycles
//
//  Memory Map for Tests:
//    $0000 - $01FF : RAM (zero page + stack page)
//    $1000 - $1FFF : ROM (test programs)
//    $FFFC - $FFFD : Reset vector (returns $1000)
//
//  Reference: MOS Technology MCS6500 Microcomputer Family Hardware Manual,
//             January 1976
//============================================================================

`timescale 1ns/1ps

module tb_x6502;

//=========================================================================
// Test Signals:
// Drive the DUT clock and reset; bus signals come from the CPU and the
// testbench memory model.
//=========================================================================
reg clk;
reg rst_n;
reg cen;

reg irq_n;
reg nmi_n;
reg so_n;
reg rdy;

wire [15:0] addr;
reg   [7:0] din;
wire  [7:0] dout;
wire        rw_n;
wire        sync;
wire        vp_n;

//=========================================================================
// Test Statistics:
// Track pass/fail counts across all sections for the final summary.
//=========================================================================
integer total_tests;
integer passed_tests;
integer failed_tests;
integer cycle_count;
integer i;

//=========================================================================
// Memory Model:
// 4 KB of ROM mapped at $1000-$1FFF holds test programs. 512 B of RAM
// at $0000-$01FF covers the zero page and the stack page. Reset vector
// fetches return $1000 so a clean reset lands in the test ROM.
//=========================================================================
reg [7:0] rom [0:4095];
reg [7:0] ram [0:511];

wire        rom_select = (addr[15:12] == 4'h1);
wire        ram_select = (addr[15:9]  == 7'h00);
wire [11:0] rom_offset = addr[11:0];

always @(*) begin
    if(rom_select)
        din = rom[rom_offset];
    else if(ram_select)
        din = ram[addr[8:0]];
    else if(addr == 16'hFFFA)
        din = 8'h00;             // NMI vector low   (PC = $1400)
    else if(addr == 16'hFFFB)
        din = 8'h14;             // NMI vector high
    else if(addr == 16'hFFFC)
        din = 8'h00;             // Reset vector low (PC = $1000)
    else if(addr == 16'hFFFD)
        din = 8'h10;             // Reset vector high
    else if(addr == 16'hFFFE)
        din = 8'h00;             // IRQ/BRK vector low (PC = $1300)
    else if(addr == 16'hFFFF)
        din = 8'h13;             // IRQ/BRK vector high
    else
        din = 8'h00;
end

always @(posedge clk) begin
    if(cen && ram_select && (rw_n == 1'b0))
        ram[addr[8:0]] <= dout;
end

//=========================================================================
// DUT Instantiation:
// Complete x6502 CPU under test. ALU is instantiated inside x6502.
//=========================================================================
x6502 uut (
    .clk   ( clk   ),
    .cen   ( cen   ),
    .rst_n ( rst_n ),
    .rdy   ( rdy   ),
    .irq_n ( irq_n ),
    .nmi_n ( nmi_n ),
    .so_n  ( so_n  ),
    .addr  ( addr  ),
    .din   ( din   ),
    .dout  ( dout  ),
    .rw_n  ( rw_n  ),
    .sync  ( sync  ),
    .vp_n  ( vp_n  )
);

//=========================================================================
// Standalone ALU Instance:
// Independent x6502_alu used by Sections 25 - 34 to drive the ALU
// directly with pre-defined operands. Combinational - no clock.
//=========================================================================
reg  [7:0] alu_chk_a;
reg  [7:0] alu_chk_b;
reg  [3:0] alu_chk_op;
reg  [7:0] alu_chk_pin;
wire [7:0] alu_chk_q;
wire [7:0] alu_chk_pout;

x6502_alu u_alu_chk (
    .a     ( alu_chk_a    ),
    .b     ( alu_chk_b    ),
    .op    ( alu_chk_op   ),
    .p_in  ( alu_chk_pin  ),
    .q     ( alu_chk_q    ),
    .p_out ( alu_chk_pout )
);

//=========================================================================
// ALU Operation Codes (mirror x6502_alu.v):
// Local copies so Sections 25 - 34 can refer to operations symbolically
// without depending on the CPU's internal state.
//=========================================================================
localparam [3:0]
    ALU_OR  = 4'h0,
    ALU_AND = 4'h1,
    ALU_EOR = 4'h2,
    ALU_ADC = 4'h3,
    ALU_EQ1 = 4'h4,
    ALU_EQ2 = 4'h5,
    ALU_CMP = 4'h6,
    ALU_SBC = 4'h7,
    ALU_ASL = 4'h8,
    ALU_ROL = 4'h9,
    ALU_LSR = 4'hA,
    ALU_ROR = 4'hB,
    ALU_BIT = 4'hC,
    ALU_DEC = 4'hD,
    ALU_INC = 4'hE;

//=========================================================================
// Clock Generation:
// 10 ns period (100 MHz). cen gating inside the test tasks makes each
// cen pulse correspond to one bus cycle.
//=========================================================================
initial clk = 0;
always #5 clk = ~clk;

//=========================================================================
// Helper Tasks:
//=========================================================================

//-------------------------------------------------------------------------
// Single Cycle:
// Pulses cen across one rising clock edge so the CPU advances exactly
// one bus cycle.
//-------------------------------------------------------------------------
task cycle;
    begin
        @(posedge clk);
        #1 cen = 1;
        @(posedge clk);
        #1 cen = 0;
    end
endtask

//-------------------------------------------------------------------------
// Count Cycles Until Fetch:
// Pulses cen until the CPU returns to ST_FETCH, indicating instruction
// completion. Times out at 30 cycles to prevent infinite loops on bugs.
//-------------------------------------------------------------------------
task count_cycles;
    output integer cycles;
    begin
        cycles = 0;
        while(uut.state != uut.ST_FETCH) begin
            cycle();
            cycles = cycles + 1;
            if(cycles > 30) begin
                $display("ERROR: Timeout waiting for FETCH state");
                cycles = -1;
                disable count_cycles;
            end
        end
    end
endtask

//-------------------------------------------------------------------------
// Run Instruction with Timing:
// Executes one instruction starting from the current ST_FETCH state and
// returns the total cycle count. The starting cycle is included.
//-------------------------------------------------------------------------
task run_instruction_timed;
    output integer cycles;
    begin
        cycle();
        count_cycles(cycles);
        cycles = cycles + 1;
    end
endtask

//-------------------------------------------------------------------------
// Run Instruction (No Timing):
// Executes one instruction without timing measurement. Used when only
// functional correctness is being verified.
//-------------------------------------------------------------------------
task run_instruction;
    integer timeout;
    begin
        timeout = 0;
        cycle();
        while(uut.state != uut.ST_FETCH && timeout < 30) begin
            cycle();
            timeout = timeout + 1;
        end
    end
endtask

//-------------------------------------------------------------------------
// System Reset:
// Asserts rst_n low, runs through reset sequence, and lets the CPU
// land in ST_FETCH after vector fetch. After reset the CPU is at PC
// = $1000 (per the testbench reset vector).
//-------------------------------------------------------------------------
task reset_system;
    begin
        rst_n = 0;
        cen = 0;
        irq_n = 1;
        nmi_n = 1;
        so_n = 1;
        rdy = 1;
        #100;
        rst_n = 1;
        #50;

        // Run through 7 reset cycles + opcode fetch
        cycle(); cycle(); cycle(); cycle();
        cycle(); cycle(); cycle();
    end
endtask

//-------------------------------------------------------------------------
// Test Setup:
// Forces CPU to ST_FETCH at the specified address with known register
// values. Allows each test to start from a clean state.
//-------------------------------------------------------------------------
task setup_test;
    input [15:0] start_addr;
    begin
        uut.state = uut.ST_FETCH;
        uut.reg_pc = start_addr;
        uut.addr = start_addr;
        uut.rw_n = 1'b1;
        uut.sync = 1'b1;
        uut.reg_a = 8'h00;
        uut.reg_x = 8'h00;
        uut.reg_y = 8'h00;
        uut.reg_s = 8'hFD;
        uut.reg_p = 8'h24;        // I=1, bit 5 always 1
        // Deassert interrupt lines and clear NMI latch so each test
        // starts from a clean interrupt-free state unless a section
        // explicitly drives the lines.
        irq_n = 1'b1;
        nmi_n = 1'b1;
        so_n = 1'b1;
        uut.nmi_n_sync = 1'b1;
        uut.irq_n_sync = 1'b1;
        uut.so_n_sync = 1'b1;
        uut.nmi_latch = 1'b0;
        #10;
    end
endtask

//-------------------------------------------------------------------------
// Value Check:
// Compares actual against expected and updates pass/fail counters.
//-------------------------------------------------------------------------
task check;
    input [31:0] actual;
    input [31:0] expected;
    input [511:0] name;
    begin
        total_tests = total_tests + 1;
        if(actual === expected) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s = %h", name, actual);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s - Expected: %h, Got: %h", name, expected, actual);
        end
    end
endtask

//-------------------------------------------------------------------------
// Apply ALU:
// Drives the standalone ALU (u_alu_chk) inputs and waits one settle
// delay. Used by Sections 25 - 34 to exercise the ALU directly.
//-------------------------------------------------------------------------
task apply_alu;
    input [7:0] a_in;
    input [7:0] b_in;
    input [3:0] op_in;
    input [7:0] p_in_in;
    begin
        alu_chk_a = a_in;
        alu_chk_b = b_in;
        alu_chk_op = op_in;
        alu_chk_pin = p_in_in;
        #1;
    end
endtask

//-------------------------------------------------------------------------
// Check ALU Result:
// Compares alu_chk_q against expected and updates pass/fail counters.
//-------------------------------------------------------------------------
task check_alu_q;
    input [7:0] expected;
    input [511:0] name;
    begin
        total_tests = total_tests + 1;
        if(alu_chk_q === expected) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s q = %h", name, alu_chk_q);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s q - Expected: %h, Got: %h", name, expected, alu_chk_q);
        end
    end
endtask

//-------------------------------------------------------------------------
// Check ALU Flag:
// Compares one bit of alu_chk_pout against expected.
//-------------------------------------------------------------------------
task check_alu_flag;
    input integer bit_pos;
    input expected;
    input [511:0] name;
    begin
        total_tests = total_tests + 1;
        if(alu_chk_pout[bit_pos] === expected) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s = %b", name, alu_chk_pout[bit_pos]);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s - Expected: %b, Got: %b", name, expected, alu_chk_pout[bit_pos]);
        end
    end
endtask

//-------------------------------------------------------------------------
// Check ALU Flag Unchanged:
// Verifies a flag bit on alu_chk_pout was not modified relative to the
// alu_chk_pin input.
//-------------------------------------------------------------------------
task check_alu_flag_unchanged;
    input integer bit_pos;
    input [511:0] name;
    begin
        total_tests = total_tests + 1;
        if(alu_chk_pout[bit_pos] === alu_chk_pin[bit_pos]) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s preserved (%b)", name, alu_chk_pout[bit_pos]);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s changed - in: %b, out: %b", name, alu_chk_pin[bit_pos], alu_chk_pout[bit_pos]);
        end
    end
endtask

//-------------------------------------------------------------------------
// Timing Check:
// Verifies instruction executed in expected number of cycles per the
// MCS6500 Hardware Manual.
//-------------------------------------------------------------------------
task check_timing;
    input [31:0] actual_cycles;
    input [31:0] expected_cycles;
    input [511:0] name;
    begin
        total_tests = total_tests + 1;
        if(actual_cycles === expected_cycles) begin
            passed_tests = passed_tests + 1;
            $display("PASS: %0s = %0d cycles", name, actual_cycles);
        end else begin
            failed_tests = failed_tests + 1;
            $display("FAIL: %0s - Expected: %0d cycles, Got: %0d cycles", name, expected_cycles, actual_cycles);
        end
    end
endtask

//=========================================================================
// Main Test Sequence:
//=========================================================================
initial begin
    $display("=============================================================");
    $display("  x6502 Comprehensive Testbench");
    $display("  Reference: MOS Technology MCS6500 Hardware Manual");
    $display("=============================================================\n");

    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;

    // Initialize ROM with NOPs
    for(i = 0; i < 4096; i = i + 1) rom[i] = 8'hEA;
    // Initialize RAM
    for(i = 0; i < 512;  i = i + 1) ram[i] = 8'h00;

    //=====================================================================
    // SECTION 1: Reset Sequence
    // 7 internal cycles followed by vector fetch from $FFFC/$FFFD. After
    // reset, PC should equal the reset vector and I=1, D=0.
    //=====================================================================
    $display("\n=== SECTION 1: Reset Sequence ===\n");

    reset_system();
    check(uut.reg_pc, 16'h1000, "Reset PC = $1000");
    check(uut.reg_p[uut.FLAG_I], 1'b1, "Reset I = 1");
    check(uut.reg_p[uut.FLAG_D], 1'b0, "Reset D = 0");
    check(uut.reg_s, 8'hFD, "Reset S = $FD");

    //=====================================================================
    // SECTION 2: Implied / Inherent Mode
    // 1-byte instructions, 2 cycles. NOP, flag set/clear, INX/DEX/INY/
    // DEY, register transfers.
    //=====================================================================
    $display("\n=== SECTION 2: Implied Mode ===\n");

    // NOP ($EA) - 2 cycles, no register changes
    rom[12'h100] = 8'hEA;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "NOP timing");
    check(uut.reg_pc, 16'h1101, "NOP: PC advanced");

    // CLC ($18) - clear carry
    rom[12'h100] = 8'h18;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CLC timing");
    check(uut.reg_p[uut.FLAG_C], 1'b0, "CLC: C = 0");

    // SEC ($38) - set carry
    rom[12'h100] = 8'h38;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "SEC timing");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "SEC: C = 1");

    // CLI ($58) - clear interrupt mask
    rom[12'h100] = 8'h58;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_I] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CLI timing");
    check(uut.reg_p[uut.FLAG_I], 1'b0, "CLI: I = 0");

    // SEI ($78) - set interrupt mask
    rom[12'h100] = 8'h78;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "SEI timing");
    check(uut.reg_p[uut.FLAG_I], 1'b1, "SEI: I = 1");

    // CLV ($B8) - clear overflow
    rom[12'h100] = 8'hB8;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_V] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CLV timing");
    check(uut.reg_p[uut.FLAG_V], 1'b0, "CLV: V = 0");

    // CLD ($D8) - clear decimal
    rom[12'h100] = 8'hD8;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_D] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CLD timing");
    check(uut.reg_p[uut.FLAG_D], 1'b0, "CLD: D = 0");

    // SED ($F8) - set decimal
    rom[12'h100] = 8'hF8;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "SED timing");
    check(uut.reg_p[uut.FLAG_D], 1'b1, "SED: D = 1");

    // INX ($E8) - X = X + 1, set N/Z
    rom[12'h100] = 8'hE8;
    setup_test(16'h1100);
    uut.reg_x = 8'h7F;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "INX timing");
    check(uut.reg_x, 8'h80, "INX: X = $80");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "INX: N = 1");

    // INX wrap to zero
    rom[12'h100] = 8'hE8;
    setup_test(16'h1100);
    uut.reg_x = 8'hFF;
    run_instruction_timed(cycle_count);
    check(uut.reg_x, 8'h00, "INX: $FF -> $00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "INX: Z = 1");

    // INY ($C8)
    rom[12'h100] = 8'hC8;
    setup_test(16'h1100);
    uut.reg_y = 8'h41;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "INY timing");
    check(uut.reg_y, 8'h42, "INY: Y = $42");

    // DEX ($CA)
    rom[12'h100] = 8'hCA;
    setup_test(16'h1100);
    uut.reg_x = 8'h01;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "DEX timing");
    check(uut.reg_x, 8'h00, "DEX: X = $00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "DEX: Z = 1");

    // DEY ($88) wraps below zero
    rom[12'h100] = 8'h88;
    setup_test(16'h1100);
    uut.reg_y = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "DEY timing");
    check(uut.reg_y, 8'hFF, "DEY: $00 -> $FF");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "DEY: N = 1");

    // TAX ($AA)
    rom[12'h100] = 8'hAA;
    setup_test(16'h1100);
    uut.reg_a = 8'h55;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TAX timing");
    check(uut.reg_x, 8'h55, "TAX: X = A");

    // TAY ($A8)
    rom[12'h100] = 8'hA8;
    setup_test(16'h1100);
    uut.reg_a = 8'hAA;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TAY timing");
    check(uut.reg_y, 8'hAA, "TAY: Y = A");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "TAY: N = 1");

    // TXA ($8A)
    rom[12'h100] = 8'h8A;
    setup_test(16'h1100);
    uut.reg_x = 8'h33;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TXA timing");
    check(uut.reg_a, 8'h33, "TXA: A = X");

    // TYA ($98)
    rom[12'h100] = 8'h98;
    setup_test(16'h1100);
    uut.reg_y = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TYA timing");
    check(uut.reg_a, 8'h00, "TYA: A = Y");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "TYA: Z = 1");

    // TSX ($BA)
    rom[12'h100] = 8'hBA;
    setup_test(16'h1100);
    uut.reg_s = 8'hC0;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TSX timing");
    check(uut.reg_x, 8'hC0, "TSX: X = S");

    // TXS ($9A) - no flag update
    rom[12'h100] = 8'h9A;
    setup_test(16'h1100);
    uut.reg_x = 8'h00;
    uut.reg_p[uut.FLAG_Z] = 1'b0;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TXS timing");
    check(uut.reg_s, 8'h00, "TXS: S = X");
    check(uut.reg_p[uut.FLAG_Z], 1'b0, "TXS: Z unchanged");

    //=====================================================================
    // SECTION 3: Immediate Mode
    // 2-byte instructions, 2 cycles. Operand is the byte after opcode.
    //=====================================================================
    $display("\n=== SECTION 3: Immediate Mode ===\n");

    // LDA #imm ($A9)
    rom[12'h100] = 8'hA9;
    rom[12'h101] = 8'h42;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "LDA # timing");
    check(uut.reg_a, 8'h42, "LDA #$42");

    // LDX #imm ($A2)
    rom[12'h100] = 8'hA2;
    rom[12'h101] = 8'h99;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "LDX # timing");
    check(uut.reg_x, 8'h99, "LDX #$99");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "LDX #$99: N = 1");

    // LDY #imm ($A0)
    rom[12'h100] = 8'hA0;
    rom[12'h101] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "LDY # timing");
    check(uut.reg_y, 8'h00, "LDY #$00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "LDY #$00: Z = 1");

    // ADC # ($69) with C=0, no overflow
    rom[12'h100] = 8'h69;
    rom[12'h101] = 8'h10;
    setup_test(16'h1100);
    uut.reg_a = 8'h20;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "ADC # timing");
    check(uut.reg_a, 8'h30, "ADC #$10: A = $30");
    check(uut.reg_p[uut.FLAG_C], 1'b0, "ADC: C = 0");
    check(uut.reg_p[uut.FLAG_V], 1'b0, "ADC: V = 0");

    // ADC # with overflow
    rom[12'h100] = 8'h69;
    rom[12'h101] = 8'h01;
    setup_test(16'h1100);
    uut.reg_a = 8'h7F;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'h80, "ADC #$01: $7F+$01");
    check(uut.reg_p[uut.FLAG_V], 1'b1, "ADC overflow: V = 1");

    // SBC # ($E9) with C=1 (no borrow)
    rom[12'h100] = 8'hE9;
    rom[12'h101] = 8'h05;
    setup_test(16'h1100);
    uut.reg_a = 8'h10;
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "SBC # timing");
    check(uut.reg_a, 8'h0B, "SBC #$05: A = $0B");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "SBC: C = 1");

    // CMP # equal
    rom[12'h100] = 8'hC9;
    rom[12'h101] = 8'h42;
    setup_test(16'h1100);
    uut.reg_a = 8'h42;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CMP # timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CMP equal: Z = 1");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "CMP equal: C = 1");

    // AND # ($29)
    rom[12'h100] = 8'h29;
    rom[12'h101] = 8'h0F;
    setup_test(16'h1100);
    uut.reg_a = 8'hAB;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'h0B, "AND #$0F: A = $0B");

    // ORA # ($09)
    rom[12'h100] = 8'h09;
    rom[12'h101] = 8'hF0;
    setup_test(16'h1100);
    uut.reg_a = 8'h0F;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'hFF, "ORA #$F0: A = $FF");

    // EOR # ($49)
    rom[12'h100] = 8'h49;
    rom[12'h101] = 8'hFF;
    setup_test(16'h1100);
    uut.reg_a = 8'h55;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'hAA, "EOR #$FF: A = $AA");

    // CPX # ($E0)
    rom[12'h100] = 8'hE0;
    rom[12'h101] = 8'h10;
    setup_test(16'h1100);
    uut.reg_x = 8'h20;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CPX # timing");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "CPX: X >= operand, C = 1");

    // CPY # ($C0)
    rom[12'h100] = 8'hC0;
    rom[12'h101] = 8'h30;
    setup_test(16'h1100);
    uut.reg_y = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CPY # timing");
    check(uut.reg_p[uut.FLAG_C], 1'b0, "CPY: Y < operand, C = 0");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "CPY: N = 1");

    //=====================================================================
    // SECTION 4: Zero Page Reads
    // 2-byte instructions, 3 cycles. Operand is ZP address.
    //=====================================================================
    $display("\n=== SECTION 4: Zero Page Reads ===\n");

    // LDA zp ($A5)
    rom[12'h100] = 8'hA5;
    rom[12'h101] = 8'h20;
    ram[8'h20]   = 8'h77;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "LDA zp timing");
    check(uut.reg_a, 8'h77, "LDA $20: A = $77");

    // LDX zp ($A6)
    rom[12'h100] = 8'hA6;
    rom[12'h101] = 8'h21;
    ram[8'h21]   = 8'h88;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "LDX zp timing");
    check(uut.reg_x, 8'h88, "LDX $21: X = $88");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "LDX $21: N = 1");

    // LDY zp ($A4)
    rom[12'h100] = 8'hA4;
    rom[12'h101] = 8'h22;
    ram[8'h22]   = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "LDY zp timing");
    check(uut.reg_y, 8'h00, "LDY $22: Y = $00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "LDY $22: Z = 1");

    // ADC zp ($65)
    rom[12'h100] = 8'h65;
    rom[12'h101] = 8'h30;
    ram[8'h30]   = 8'h05;
    setup_test(16'h1100);
    uut.reg_a = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "ADC zp timing");
    check(uut.reg_a, 8'h15, "ADC $30: A = $15");

    // SBC zp ($E5)
    rom[12'h100] = 8'hE5;
    rom[12'h101] = 8'h31;
    ram[8'h31]   = 8'h05;
    setup_test(16'h1100);
    uut.reg_a = 8'h20;
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "SBC zp timing");
    check(uut.reg_a, 8'h1B, "SBC $31: A = $1B");

    // AND zp ($25)
    rom[12'h100] = 8'h25;
    rom[12'h101] = 8'h32;
    ram[8'h32]   = 8'hF0;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'hF0, "AND $32: A = $F0");

    // ORA zp ($05)
    rom[12'h100] = 8'h05;
    rom[12'h101] = 8'h33;
    ram[8'h33]   = 8'h0F;
    setup_test(16'h1100);
    uut.reg_a = 8'hF0;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'hFF, "ORA $33: A = $FF");

    // EOR zp ($45)
    rom[12'h100] = 8'h45;
    rom[12'h101] = 8'h34;
    ram[8'h34]   = 8'hAA;
    setup_test(16'h1100);
    uut.reg_a = 8'h55;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'hFF, "EOR $34: A = $FF");

    // CMP zp ($C5)
    rom[12'h100] = 8'hC5;
    rom[12'h101] = 8'h35;
    ram[8'h35]   = 8'h42;
    setup_test(16'h1100);
    uut.reg_a = 8'h42;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "CMP zp timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CMP zp equal: Z = 1");

    // CPX zp ($E4)
    rom[12'h100] = 8'hE4;
    rom[12'h101] = 8'h36;
    ram[8'h36]   = 8'h10;
    setup_test(16'h1100);
    uut.reg_x = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "CPX zp timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CPX zp equal: Z = 1");

    // CPY zp ($C4)
    rom[12'h100] = 8'hC4;
    rom[12'h101] = 8'h37;
    ram[8'h37]   = 8'h05;
    setup_test(16'h1100);
    uut.reg_y = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "CPY zp timing");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "CPY zp: Y > op, C = 1");

    // BIT zp ($24)
    rom[12'h100] = 8'h24;
    rom[12'h101] = 8'h38;
    ram[8'h38]   = 8'hC0;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BIT zp timing");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "BIT $38: N from b[7]");
    check(uut.reg_p[uut.FLAG_V], 1'b1, "BIT $38: V from b[6]");
    check(uut.reg_p[uut.FLAG_Z], 1'b0, "BIT $38: Z = 0");

    //=====================================================================
    // SECTION 5: Zero Page Writes
    // 2-byte instructions, 3 cycles. Stores A, X, or Y to ZP address.
    //=====================================================================
    $display("\n=== SECTION 5: Zero Page Writes ===\n");

    // STA zp ($85)
    rom[12'h100] = 8'h85;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'hAB;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "STA zp timing");
    check(ram[8'h40], 8'hAB, "STA $40: RAM = $AB");

    // STX zp ($86)
    rom[12'h100] = 8'h86;
    rom[12'h101] = 8'h41;
    setup_test(16'h1100);
    uut.reg_x = 8'hCD;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "STX zp timing");
    check(ram[8'h41], 8'hCD, "STX $41: RAM = $CD");

    // STY zp ($84)
    rom[12'h100] = 8'h84;
    rom[12'h101] = 8'h42;
    setup_test(16'h1100);
    uut.reg_y = 8'hEF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "STY zp timing");
    check(ram[8'h42], 8'hEF, "STY $42: RAM = $EF");

    //=====================================================================
    // SECTION 6: Conditional Branches
    // 2-byte instructions. 2 cycles not taken, 3 taken, 4 with page
    // cross. Offset is signed 8-bit relative to instruction-after byte.
    //=====================================================================
    $display("\n=== SECTION 6: Conditional Branches ===\n");

    // BPL not taken (N=1)
    rom[12'h100] = 8'h10;
    rom[12'h101] = 8'h10;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_N] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "BPL not taken timing");
    check(uut.reg_pc, 16'h1102, "BPL not taken: PC advances 2");

    // BPL taken (N=0), no page cross
    rom[12'h100] = 8'h10;
    rom[12'h101] = 8'h10;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BPL taken timing");
    check(uut.reg_pc, 16'h1112, "BPL taken: PC = $1112");

    // BMI taken (N=1)
    rom[12'h100] = 8'h30;
    rom[12'h101] = 8'h05;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_N] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BMI taken timing");
    check(uut.reg_pc, 16'h1107, "BMI taken: PC = $1107");

    // BVC taken (V=0)
    rom[12'h100] = 8'h50;
    rom[12'h101] = 8'h08;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BVC taken timing");
    check(uut.reg_pc, 16'h110A, "BVC taken: PC = $110A");

    // BVS taken (V=1)
    rom[12'h100] = 8'h70;
    rom[12'h101] = 8'h04;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_V] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BVS taken timing");
    check(uut.reg_pc, 16'h1106, "BVS taken: PC = $1106");

    // BCC taken (C=0)
    rom[12'h100] = 8'h90;
    rom[12'h101] = 8'h0A;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BCC taken timing");
    check(uut.reg_pc, 16'h110C, "BCC taken: PC = $110C");

    // BCS taken (C=1)
    rom[12'h100] = 8'hB0;
    rom[12'h101] = 8'h02;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BCS taken timing");
    check(uut.reg_pc, 16'h1104, "BCS taken: PC = $1104");

    // BNE taken (Z=0)
    rom[12'h100] = 8'hD0;
    rom[12'h101] = 8'hFE;        // -2 (backward)
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BNE backward timing");
    check(uut.reg_pc, 16'h1100, "BNE -2: PC = $1100");

    // BEQ taken (Z=1)
    rom[12'h100] = 8'hF0;
    rom[12'h101] = 8'h05;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_Z] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BEQ taken timing");
    check(uut.reg_pc, 16'h1107, "BEQ taken: PC = $1107");

    // Branch with forward page cross
    // PC=$10F0, offset=$20 -> PC after = $10F2 + $20 = $1112 (no cross since
    // $10F2[15:8] = $11... wait $10F2 high = $10, $1112 high = $11). Cross.
    rom[12'h0F0] = 8'hF0;        // BEQ
    rom[12'h0F1] = 8'h20;        // +32
    setup_test(16'h10F0);
    uut.reg_p[uut.FLAG_Z] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "BEQ page cross timing");
    check(uut.reg_pc, 16'h1112, "BEQ +32: PC = $1112");

    // Branch with backward page cross
    // PC=$1110, offset=$E0 (-32) -> PC after = $1112 + (-32) = $10F2. Cross.
    rom[12'h110] = 8'hF0;
    rom[12'h111] = 8'hE0;
    setup_test(16'h1110);
    uut.reg_p[uut.FLAG_Z] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "BEQ neg cross timing");
    check(uut.reg_pc, 16'h10F2, "BEQ -32: PC = $10F2");

    //=====================================================================
    // SECTION 7: JMP Absolute
    // 3-byte instruction, 3 cycles. PC = {hi, lo}.
    //=====================================================================
    $display("\n=== SECTION 7: JMP Absolute ===\n");

    // JMP $1234
    rom[12'h100] = 8'h4C;
    rom[12'h101] = 8'h34;
    rom[12'h102] = 8'h12;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "JMP abs timing");
    check(uut.reg_pc, 16'h1234, "JMP $1234: PC = $1234");

    // JMP $1500 (back to ROM range)
    rom[12'h200] = 8'h4C;
    rom[12'h201] = 8'h00;
    rom[12'h202] = 8'h15;
    setup_test(16'h1200);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "JMP abs timing 2");
    check(uut.reg_pc, 16'h1500, "JMP $1500: PC = $1500");

    //=====================================================================
    // SECTION 8: Absolute Reads
    // 3-byte instruction, 4 cycles. Effective address = {hi, lo}.
    // Tested against RAM in zero page so writes from earlier sections
    // are predictable, plus ROM-resident constants.
    //=====================================================================
    $display("\n=== SECTION 8: Absolute Reads ===\n");

    // Pre-populate RAM with known data for absolute reads
    ram[8'h50] = 8'h44;   // for LDA abs
    ram[8'h51] = 8'h99;   // for LDX abs (negative)
    ram[8'h52] = 8'h00;   // for LDY abs (zero)
    ram[8'h53] = 8'h05;   // for ADC abs
    ram[8'h54] = 8'h05;   // for SBC abs
    ram[8'h55] = 8'h0F;   // for AND abs
    ram[8'h56] = 8'hF0;   // for ORA abs
    ram[8'h57] = 8'hAA;   // for EOR abs
    ram[8'h58] = 8'h33;   // for CMP abs (equal to A)
    ram[8'h59] = 8'h33;   // for CPX abs
    ram[8'h5A] = 8'h33;   // for CPY abs
    ram[8'h5B] = 8'hC0;   // for BIT abs (N=1, V=1)

    // LDA abs ($AD) - load A from RAM[$0050]
    rom[12'h100] = 8'hAD;
    rom[12'h101] = 8'h50;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDA abs timing");
    check(uut.reg_a, 8'h44, "LDA $0050: A = $44");

    // LDX abs ($AE) - load X with negative value
    rom[12'h100] = 8'hAE;
    rom[12'h101] = 8'h51;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDX abs timing");
    check(uut.reg_x, 8'h99, "LDX $0051: X = $99");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "LDX abs: N = 1");

    // LDY abs ($AC) - load Y with zero
    rom[12'h100] = 8'hAC;
    rom[12'h101] = 8'h52;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDY abs timing");
    check(uut.reg_y, 8'h00, "LDY $0052: Y = $00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "LDY abs: Z = 1");

    // ADC abs ($6D) - add memory to A
    rom[12'h100] = 8'h6D;
    rom[12'h101] = 8'h53;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "ADC abs timing");
    check(uut.reg_a, 8'h15, "ADC $0053: A = $15");

    // SBC abs ($ED) - subtract memory from A
    rom[12'h100] = 8'hED;
    rom[12'h101] = 8'h54;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'h20;
    uut.reg_p[uut.FLAG_C] = 1'b1;        // no borrow
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "SBC abs timing");
    check(uut.reg_a, 8'h1B, "SBC $0054: A = $1B");

    // AND abs ($2D)
    rom[12'h100] = 8'h2D;
    rom[12'h101] = 8'h55;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "AND abs timing");
    check(uut.reg_a, 8'h0F, "AND $0055: A = $0F");

    // ORA abs ($0D)
    rom[12'h100] = 8'h0D;
    rom[12'h101] = 8'h56;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'h0F;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "ORA abs timing");
    check(uut.reg_a, 8'hFF, "ORA $0056: A = $FF");

    // EOR abs ($4D)
    rom[12'h100] = 8'h4D;
    rom[12'h101] = 8'h57;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'h55;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "EOR abs timing");
    check(uut.reg_a, 8'hFF, "EOR $0057: A = $FF");

    // CMP abs ($CD) - equal
    rom[12'h100] = 8'hCD;
    rom[12'h101] = 8'h58;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'h33;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "CMP abs timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CMP abs equal: Z = 1");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "CMP abs equal: C = 1");

    // CPX abs ($EC) - X greater than mem
    rom[12'h100] = 8'hEC;
    rom[12'h101] = 8'h59;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_x = 8'h44;                    // X > mem ($33)
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "CPX abs timing");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "CPX abs: X >= mem, C = 1");

    // CPY abs ($CC) - Y less than mem
    rom[12'h100] = 8'hCC;
    rom[12'h101] = 8'h5A;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_y = 8'h22;                    // Y < mem ($33)
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "CPY abs timing");
    check(uut.reg_p[uut.FLAG_C], 1'b0, "CPY abs: Y < mem, C = 0");

    // BIT abs ($2C) - N from b[7], V from b[6], Z from (A & b)
    rom[12'h100] = 8'h2C;
    rom[12'h101] = 8'h5B;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;                    // A & b = $C0 != 0
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "BIT abs timing");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "BIT abs: N from b[7]");
    check(uut.reg_p[uut.FLAG_V], 1'b1, "BIT abs: V from b[6]");
    check(uut.reg_p[uut.FLAG_Z], 1'b0, "BIT abs: Z = 0");

    //=====================================================================
    // SECTION 9: Absolute Writes
    // 3-byte instruction, 4 cycles. Memory at {hi, lo} <- A/X/Y.
    //=====================================================================
    $display("\n=== SECTION 9: Absolute Writes ===\n");

    // STA abs ($8D)
    rom[12'h100] = 8'h8D;
    rom[12'h101] = 8'h60;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'hAB;
    ram[8'h60] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STA abs timing");
    check({24'h0, ram[8'h60]}, 8'hAB, "STA $0060: RAM = $AB");

    // STX abs ($8E)
    rom[12'h100] = 8'h8E;
    rom[12'h101] = 8'h61;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_x = 8'hCD;
    ram[8'h61] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STX abs timing");
    check({24'h0, ram[8'h61]}, 8'hCD, "STX $0061: RAM = $CD");

    // STY abs ($8C)
    rom[12'h100] = 8'h8C;
    rom[12'h101] = 8'h62;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_y = 8'hEF;
    ram[8'h62] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STY abs timing");
    check({24'h0, ram[8'h62]}, 8'hEF, "STY $0062: RAM = $EF");

    //=====================================================================
    // SECTION 10: Accumulator Shifts
    // 1-byte instruction, 2 cycles. Operates on A and updates C, N, Z.
    //=====================================================================
    $display("\n=== SECTION 10: Accumulator Shifts ===\n");

    // ASL A ($0A) - shift left, bit 7 -> C
    rom[12'h100] = 8'h0A;
    setup_test(16'h1100);
    uut.reg_a = 8'h81;                    // 1000_0001 -> 0000_0010, C=1
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "ASL A timing");
    check(uut.reg_a, 8'h02, "ASL A: $81 -> $02");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "ASL A: C from bit 7");
    check(uut.reg_p[uut.FLAG_N], 1'b0, "ASL A: N = 0");

    // LSR A ($4A) - shift right, bit 0 -> C
    rom[12'h100] = 8'h4A;
    setup_test(16'h1100);
    uut.reg_a = 8'h81;                    // 1000_0001 -> 0100_0000, C=1
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "LSR A timing");
    check(uut.reg_a, 8'h40, "LSR A: $81 -> $40");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "LSR A: C from bit 0");
    check(uut.reg_p[uut.FLAG_N], 1'b0, "LSR A: N always 0");

    // ROL A ($2A) - rotate left through carry
    rom[12'h100] = 8'h2A;
    setup_test(16'h1100);
    uut.reg_a = 8'h81;                    // 1000_0001 with C=1 -> 0000_0011, C=1
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "ROL A timing");
    check(uut.reg_a, 8'h03, "ROL A: $81 + C=1 -> $03");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "ROL A: old bit 7 -> C");

    // ROR A ($6A) - rotate right through carry
    rom[12'h100] = 8'h6A;
    setup_test(16'h1100);
    uut.reg_a = 8'h01;                    // 0000_0001 with C=1 -> 1000_0000, C=1
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "ROR A timing");
    check(uut.reg_a, 8'h80, "ROR A: $01 + C=1 -> $80");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "ROR A: old bit 0 -> C");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "ROR A: N from new bit 7");

    //=====================================================================
    // SECTION 11: Stack Push / Pull
    // PHA / PHP : 3 cycles, S decrements after write
    // PLA / PLP : 4 cycles, S increments before read
    // PHP pushes P with bit 4 (B) and bit 5 forced to 1.
    // PLP loads P, forcing bit 5 = 1 and bit 4 (B) = 0.
    //=====================================================================
    $display("\n=== SECTION 11: Stack Push / Pull ===\n");

    // PHA ($48)
    rom[12'h100] = 8'h48;
    setup_test(16'h1100);
    uut.reg_a = 8'h7E;
    uut.reg_s = 8'hFD;
    ram[9'h1FD] = 8'h00;                  // clear stack target
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "PHA timing");
    check({24'h0, ram[9'h1FD]}, 8'h7E, "PHA: stack[$01FD] = $7E");
    check(uut.reg_s, 8'hFC, "PHA: S decremented to $FC");

    // PHP ($08) - bit 4 (B) and bit 5 set in pushed byte
    rom[12'h100] = 8'h08;
    setup_test(16'h1100);
    uut.reg_p = 8'hC3;                   // N=1,V=1,...,Z=1,C=1
    uut.reg_s = 8'hFC;
    ram[9'h1FC] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "PHP timing");
    check({24'h0, ram[9'h1FC]}, 8'hF3, "PHP: stack[$01FC] = P|$30");
    check(uut.reg_s, 8'hFB, "PHP: S decremented to $FB");

    // PLA ($68) - pull from stack into A, update N/Z
    rom[12'h100] = 8'h68;
    setup_test(16'h1100);
    uut.reg_s = 8'hFB;
    ram[9'h1FC] = 8'h82;                  // negative value
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "PLA timing");
    check(uut.reg_a, 8'h82, "PLA: A = $82");
    check(uut.reg_s, 8'hFC, "PLA: S incremented to $FC");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "PLA: N = 1");
    check(uut.reg_p[uut.FLAG_Z], 1'b0, "PLA: Z = 0");

    // PLA pulling zero -> Z flag
    rom[12'h100] = 8'h68;
    setup_test(16'h1100);
    uut.reg_s = 8'hFB;
    ram[9'h1FC] = 8'h00;
    run_instruction_timed(cycle_count);
    check(uut.reg_a, 8'h00, "PLA zero: A = $00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "PLA zero: Z = 1");

    // PLP ($28) - pull P, forcing bit5=1 and bit4=0
    rom[12'h100] = 8'h28;
    setup_test(16'h1100);
    uut.reg_s = 8'hFB;
    uut.reg_p = 8'h24;                   // existing P
    ram[9'h1FC] = 8'hFF;                  // pushed byte = $FF
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "PLP timing");
    check(uut.reg_p, 8'hEF, "PLP: P = $EF (bit4 cleared, bit5 set)");
    check(uut.reg_s, 8'hFC, "PLP: S incremented to $FC");

    // PLP with all flags clear except bit 5
    rom[12'h100] = 8'h28;
    setup_test(16'h1100);
    uut.reg_s = 8'hFB;
    ram[9'h1FC] = 8'h00;
    run_instruction_timed(cycle_count);
    check(uut.reg_p, 8'h20, "PLP zero pull: P = $20 (bit5 forced)");

    //=====================================================================
    // SECTION 12: JMP Indirect
    // 5 cycles. PC <- mem[{hi,lo}], mem[{hi,lo}+1] with NMOS page-wrap
    // bug: high byte fetch does not propagate carry into the high half
    // of the indirect pointer. JMP ($12FF) reads PCL from $12FF and
    // PCH from $1200 (NOT $1300).
    //=====================================================================
    $display("\n=== SECTION 12: JMP Indirect ===\n");

    // JMP ($0030) - normal case via zero page
    ram[8'h30] = 8'h22;                  // target low
    ram[8'h31] = 8'h15;                  // target high
    rom[12'h100] = 8'h6C;
    rom[12'h101] = 8'h30;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "JMP ind timing");
    check(uut.reg_pc, 16'h1522, "JMP ($0030): PC = $1522");

    // JMP indirect via $0100 - normal
    ram[9'h100] = 8'h44;
    ram[9'h101] = 8'h17;
    rom[12'h100] = 8'h6C;
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h01;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "JMP ind timing 2");
    check(uut.reg_pc, 16'h1744, "JMP ($0100): PC = $1744");

    // JMP ($00FF) - NMOS page-wrap bug demonstration
    // Without bug: PC = {ram[$0100], ram[$00FF]} = {$44, $77} = $1744
    // With bug:    PC = {ram[$0000], ram[$00FF]}
    // Set ram[$0000]=$13, ram[$00FF]=$77, ram[$0100]=$44
    ram[8'h00]  = 8'h13;                  // wrap-to byte (bug uses this)
    ram[8'hFF]  = 8'h77;                  // low byte of target
    ram[9'h100] = 8'h44;                  // would-be high byte (bug ignores)
    rom[12'h100] = 8'h6C;
    rom[12'h101] = 8'hFF;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "JMP ind page-wrap timing");
    check(uut.reg_pc, 16'h1377, "JMP ($00FF): NMOS bug -> $1377");

    //=====================================================================
    // SECTION 13: Zero Page Indexed Reads
    // 4 cycles. Effective addr = (base + index) wrapped within zero page.
    //=====================================================================
    $display("\n=== SECTION 13: Zero Page Indexed Reads ===\n");

    // Pre-populate RAM with known values for ZP indexed
    ram[8'h70] = 8'h22;   // base+0 (LDA zp,X with X=0)
    ram[8'h75] = 8'h33;   // base+5 (LDA zp,X with X=5)
    ram[8'h7A] = 8'hF0;   // for AND/EOR
    ram[8'h82] = 8'h11;   // for LDX zp,Y test
    ram[8'h08] = 8'h99;   // for ZP wrap test ($FF + $09 = $08)

    // LDA zp,X ($B5) with X=$05 -> reads ram[$75]
    rom[12'h100] = 8'hB5;
    rom[12'h101] = 8'h70;
    setup_test(16'h1100);
    uut.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDA zp,X timing");
    check(uut.reg_a, 8'h33, "LDA $70,X (X=5): A = $33");

    // LDA zp,X with ZP wrap: base $FF + X $09 = $08 (wraps in ZP)
    rom[12'h100] = 8'hB5;
    rom[12'h101] = 8'hFF;
    setup_test(16'h1100);
    uut.reg_x = 8'h09;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDA zp,X wrap timing");
    check(uut.reg_a, 8'h99, "LDA $FF,X (X=9): wrap to $08");

    // LDY zp,X ($B4)
    rom[12'h100] = 8'hB4;
    rom[12'h101] = 8'h70;
    setup_test(16'h1100);
    uut.reg_x = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDY zp,X timing");
    check(uut.reg_y, 8'h22, "LDY $70,X (X=0): Y = $22");

    // LDX zp,Y ($B6) - the only Y-indexed ZP read
    rom[12'h100] = 8'hB6;
    rom[12'h101] = 8'h80;
    setup_test(16'h1100);
    uut.reg_y = 8'h02;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDX zp,Y timing");
    check(uut.reg_x, 8'h11, "LDX $80,Y (Y=2): X = $11");

    // ADC zp,X ($75)
    rom[12'h100] = 8'h75;
    rom[12'h101] = 8'h70;
    setup_test(16'h1100);
    uut.reg_a = 8'h10;
    uut.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "ADC zp,X timing");
    check(uut.reg_a, 8'h43, "ADC $70,X (X=5): A = $43");

    // SBC zp,X ($F5)
    rom[12'h100] = 8'hF5;
    rom[12'h101] = 8'h70;
    setup_test(16'h1100);
    uut.reg_a = 8'h50;
    uut.reg_x = 8'h05;
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "SBC zp,X timing");
    check(uut.reg_a, 8'h1D, "SBC $70,X (X=5): A = $1D");

    // AND zp,X ($35)
    rom[12'h100] = 8'h35;
    rom[12'h101] = 8'h75;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;
    uut.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "AND zp,X timing");
    check(uut.reg_a, 8'hF0, "AND $75,X (X=5): A = $F0");

    // ORA zp,X ($15)
    rom[12'h100] = 8'h15;
    rom[12'h101] = 8'h70;
    setup_test(16'h1100);
    uut.reg_a = 8'h0F;
    uut.reg_x = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "ORA zp,X timing");
    check(uut.reg_a, 8'h2F, "ORA $70,X (X=0): A = $2F");

    // EOR zp,X ($55)
    rom[12'h100] = 8'h55;
    rom[12'h101] = 8'h75;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;
    uut.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "EOR zp,X timing");
    check(uut.reg_a, 8'h0F, "EOR $75,X (X=5): A = $0F");

    // CMP zp,X ($D5)
    rom[12'h100] = 8'hD5;
    rom[12'h101] = 8'h70;
    setup_test(16'h1100);
    uut.reg_a = 8'h33;
    uut.reg_x = 8'h05;                    // ram[$75] = $33
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "CMP zp,X timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CMP zp,X equal: Z = 1");

    //=====================================================================
    // SECTION 14: Zero Page Indexed Writes
    // 4 cycles. Memory at (base + index) wrapped to zero page <- src.
    //=====================================================================
    $display("\n=== SECTION 14: Zero Page Indexed Writes ===\n");

    // STA zp,X ($95)
    rom[12'h100] = 8'h95;
    rom[12'h101] = 8'h90;
    setup_test(16'h1100);
    uut.reg_a = 8'h12;
    uut.reg_x = 8'h05;                    // target = $95
    ram[8'h95] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STA zp,X timing");
    check({24'h0, ram[8'h95]}, 8'h12, "STA $90,X (X=5): RAM[$95] = $12");

    // STY zp,X ($94)
    rom[12'h100] = 8'h94;
    rom[12'h101] = 8'h90;
    setup_test(16'h1100);
    uut.reg_y = 8'h34;
    uut.reg_x = 8'h06;                    // target = $96
    ram[8'h96] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STY zp,X timing");
    check({24'h0, ram[8'h96]}, 8'h34, "STY $90,X (X=6): RAM[$96] = $34");

    // STX zp,Y ($96)
    rom[12'h100] = 8'h96;
    rom[12'h101] = 8'h90;
    setup_test(16'h1100);
    uut.reg_x = 8'h56;
    uut.reg_y = 8'h07;                    // target = $97
    ram[8'h97] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STX zp,Y timing");
    check({24'h0, ram[8'h97]}, 8'h56, "STX $90,Y (Y=7): RAM[$97] = $56");

    // ZP write wrap: base $FE + X $05 = $03
    rom[12'h100] = 8'h95;
    rom[12'h101] = 8'hFE;
    setup_test(16'h1100);
    uut.reg_a = 8'h78;
    uut.reg_x = 8'h05;
    ram[8'h03] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STA zp,X wrap timing");
    check({24'h0, ram[8'h03]}, 8'h78, "STA $FE,X (X=5): wrap to RAM[$03]");

    //=====================================================================
    // SECTION 15: Absolute Indexed Reads
    // 4 cycles, +1 if page cross. Effective addr = base + index.
    //=====================================================================
    $display("\n=== SECTION 15: Absolute Indexed Reads ===\n");

    // Use ROM data for these reads ($1Ennn region)
    rom[12'hE00] = 8'hAA;   // for LDA abs,X X=0 -> $1E00
    rom[12'hE05] = 8'hBB;   // for LDA abs,X X=5 -> $1E05
    rom[12'hE10] = 8'h33;   // for LDX abs,Y
    rom[12'hE20] = 8'h44;   // for LDY abs,X
    rom[12'hF03] = 8'h77;   // for page-cross test (base $1EFF + X $04 = $1F03)

    // LDA abs,X no cross ($BD)
    rom[12'h100] = 8'hBD;
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDA abs,X no cross timing");
    check(uut.reg_a, 8'hBB, "LDA $1E00,X (X=5): A = $BB");

    // LDA abs,X with page cross
    rom[12'h100] = 8'hBD;
    rom[12'h101] = 8'hFF;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_x = 8'h04;                    // $1EFF + 4 = $1F03 (cross)
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "LDA abs,X cross timing");
    check(uut.reg_a, 8'h77, "LDA $1EFF,X (X=4): A = $77");

    // LDA abs,Y no cross ($B9)
    rom[12'h100] = 8'hB9;
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_y = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDA abs,Y no cross timing");
    check(uut.reg_a, 8'hBB, "LDA $1E00,Y (Y=5): A = $BB");

    // LDA abs,Y with page cross
    rom[12'h100] = 8'hB9;
    rom[12'h101] = 8'hFF;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_y = 8'h04;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "LDA abs,Y cross timing");
    check(uut.reg_a, 8'h77, "LDA $1EFF,Y (Y=4): A = $77");

    // LDX abs,Y ($BE)
    rom[12'h100] = 8'hBE;
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_y = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDX abs,Y timing");
    check(uut.reg_x, 8'h33, "LDX $1E00,Y (Y=$10): X = $33");

    // LDY abs,X ($BC)
    rom[12'h100] = 8'hBC;
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_x = 8'h20;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDY abs,X timing");
    check(uut.reg_y, 8'h44, "LDY $1E00,X (X=$20): Y = $44");

    // ADC abs,X ($7D) no cross
    rom[12'h100] = 8'h7D;
    rom[12'h101] = 8'h05;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_a = 8'h10;
    uut.reg_x = 8'h00;                    // $1E05 = $BB
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "ADC abs,X timing");
    check(uut.reg_a, 8'hCB, "ADC $1E05,X: A = $CB");

    // CMP abs,Y ($D9) with cross
    rom[12'h100] = 8'hD9;
    rom[12'h101] = 8'hFF;
    rom[12'h102] = 8'h1E;
    setup_test(16'h1100);
    uut.reg_a = 8'h77;                    // ram[$1F03] = $77
    uut.reg_y = 8'h04;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "CMP abs,Y cross timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CMP abs,Y cross: Z = 1");

    //=====================================================================
    // SECTION 16: Absolute Indexed Writes
    // 5 cycles fixed. Memory at (base + index) <- A.
    //=====================================================================
    $display("\n=== SECTION 16: Absolute Indexed Writes ===\n");

    // STA abs,X ($9D) no cross
    rom[12'h100] = 8'h9D;
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h00;                 // base $0000, X=$30 -> $0030
    setup_test(16'h1100);
    uut.reg_a = 8'h9C;
    uut.reg_x = 8'h30;
    ram[8'h30] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "STA abs,X no cross timing");
    check({24'h0, ram[8'h30]}, 8'h9C, "STA $0000,X (X=$30): RAM = $9C");

    // STA abs,X with cross  ($00FF + $05 = $0104)
    rom[12'h100] = 8'h9D;
    rom[12'h101] = 8'hFF;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'h7E;
    uut.reg_x = 8'h05;
    ram[9'h104] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "STA abs,X cross timing");
    check({24'h0, ram[9'h104]}, 8'h7E, "STA $00FF,X (X=5): RAM[$0104] = $7E");

    // STA abs,Y ($99)
    rom[12'h100] = 8'h99;
    rom[12'h101] = 8'h40;
    rom[12'h102] = 8'h00;                 // base $0040, Y=$10 -> $0050
    setup_test(16'h1100);
    uut.reg_a = 8'h21;
    uut.reg_y = 8'h10;
    ram[8'h50] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "STA abs,Y no cross timing");
    check({24'h0, ram[8'h50]}, 8'h21, "STA $0040,Y (Y=$10): RAM = $21");

    // STA abs,Y with cross ($00C0 + $50 = $0110)
    rom[12'h100] = 8'h99;
    rom[12'h101] = 8'hC0;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'h43;
    uut.reg_y = 8'h50;
    ram[9'h110] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "STA abs,Y cross timing");
    check({24'h0, ram[9'h110]}, 8'h43, "STA $00C0,Y (Y=$50): RAM[$0110] = $43");

    //=====================================================================
    // SECTION 17: Indexed Indirect (ZP,X)
    // 6 cycles for read and write. The (base + X) wraps within zero
    // page. The high byte of the pointer is read at (base+X+1) & $FF.
    //=====================================================================
    $display("\n=== SECTION 17: Indexed Indirect (ZP,X) ===\n");

    // Set up ZP pointer table at $40-$4F:
    //   ZP[$40] = $00, ZP[$41] = $1E   -> $1E00 (rom[$E00] = $AA)
    //   ZP[$42] = $05, ZP[$43] = $1E   -> $1E05 (rom[$E05] = $BB)
    ram[8'h40] = 8'h00;
    ram[8'h41] = 8'h1E;
    ram[8'h42] = 8'h05;
    ram[8'h43] = 8'h1E;

    // LDA (ZP,X) ($A1) with X=0 -> ptr at $40 = $1E00 -> rom = $AA
    rom[12'h100] = 8'hA1;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_x = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "LDA (ZP,X) timing");
    check(uut.reg_a, 8'hAA, "LDA ($40,X=0): A = $AA");

    // LDA (ZP,X) with X=2 -> ptr at $42 = $1E05 -> rom = $BB
    rom[12'h100] = 8'hA1;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_x = 8'h02;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "LDA (ZP,X) X=2 timing");
    check(uut.reg_a, 8'hBB, "LDA ($40,X=2): A = $BB");

    // ADC (ZP,X)
    rom[12'h100] = 8'h61;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'h11;
    uut.reg_x = 8'h00;                    // ptr -> $1E00 -> $AA
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "ADC (ZP,X) timing");
    check(uut.reg_a, 8'hBB, "ADC ($40,X=0): A = $BB");

    // SBC (ZP,X)
    rom[12'h100] = 8'hE1;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'hC0;
    uut.reg_x = 8'h02;                    // ptr -> $1E05 -> $BB
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "SBC (ZP,X) timing");
    check(uut.reg_a, 8'h05, "SBC ($40,X=2): A = $05");

    // AND (ZP,X)
    rom[12'h100] = 8'h21;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'hF0;
    uut.reg_x = 8'h00;                    // ptr -> $1E00 -> $AA
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "AND (ZP,X) timing");
    check(uut.reg_a, 8'hA0, "AND ($40,X=0): A = $A0");

    // ORA (ZP,X)
    rom[12'h100] = 8'h01;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'h05;
    uut.reg_x = 8'h00;                    // ptr -> $AA
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "ORA (ZP,X) timing");
    check(uut.reg_a, 8'hAF, "ORA ($40,X=0): A = $AF");

    // EOR (ZP,X)
    rom[12'h100] = 8'h41;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;
    uut.reg_x = 8'h00;                    // ptr -> $AA
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "EOR (ZP,X) timing");
    check(uut.reg_a, 8'h55, "EOR ($40,X=0): A = $55");

    // CMP (ZP,X) equal
    rom[12'h100] = 8'hC1;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'hAA;
    uut.reg_x = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "CMP (ZP,X) timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CMP ($40,X=0) equal: Z = 1");

    // ZP wrap: base $FE + X $03 = $01 -> ptr at $01/$02
    ram[8'h01] = 8'h00;
    ram[8'h02] = 8'h00;                   // ptr -> $0000
    ram[8'h00] = 8'h5A;                   // target byte
    rom[12'h100] = 8'hA1;
    rom[12'h101] = 8'hFE;
    setup_test(16'h1100);
    uut.reg_x = 8'h03;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "LDA (ZP,X) wrap timing");
    check(uut.reg_a, 8'h5A, "LDA ($FE,X=3): wrap to $01 -> $5A");

    // STA (ZP,X)
    ram[8'h44] = 8'h80;                   // ptr low
    ram[8'h45] = 8'h00;                   // ptr high  -> writes RAM[$0080]
    rom[12'h100] = 8'h81;
    rom[12'h101] = 8'h40;
    setup_test(16'h1100);
    uut.reg_a = 8'h7E;
    uut.reg_x = 8'h04;                    // ptr at $44 -> $0080
    ram[8'h80] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "STA (ZP,X) timing");
    check({24'h0, ram[8'h80]}, 8'h7E, "STA ($40,X=4): RAM[$0080] = $7E");

    //=====================================================================
    // SECTION 18: Indirect Indexed (ZP),Y
    // 5 cycles for read (+1 page cross). 6 cycles fixed for write.
    // Pointer at ZP[base], ZP[base+1] (with ZP wrap on +1).
    //=====================================================================
    $display("\n=== SECTION 18: Indirect Indexed (ZP),Y ===\n");

    // Pointer table:
    //   ZP[$60]=$00 ZP[$61]=$1E -> base $1E00 -> rom[$E00..]
    //   ZP[$62]=$F0 ZP[$63]=$1E -> base $1EF0 -> page-cross with Y>=$10
    ram[8'h60] = 8'h00;
    ram[8'h61] = 8'h1E;
    ram[8'h62] = 8'hF0;
    ram[8'h63] = 8'h1E;

    // LDA (ZP),Y no cross -> base $1E00 + Y=5 -> $1E05 -> $BB
    rom[12'h100] = 8'hB1;
    rom[12'h101] = 8'h60;
    setup_test(16'h1100);
    uut.reg_y = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "LDA (ZP),Y no cross timing");
    check(uut.reg_a, 8'hBB, "LDA ($60),Y=5: A = $BB");

    // LDA (ZP),Y with page cross -> base $1EF0 + Y=$13 -> $1F03 -> $77
    rom[12'h100] = 8'hB1;
    rom[12'h101] = 8'h62;
    setup_test(16'h1100);
    uut.reg_y = 8'h13;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "LDA (ZP),Y cross timing");
    check(uut.reg_a, 8'h77, "LDA ($62),Y=$13: A = $77");

    // ADC (ZP),Y
    rom[12'h100] = 8'h71;
    rom[12'h101] = 8'h60;
    setup_test(16'h1100);
    uut.reg_a = 8'h11;
    uut.reg_y = 8'h05;                    // -> $BB
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "ADC (ZP),Y timing");
    check(uut.reg_a, 8'hCC, "ADC ($60),Y=5: A = $CC");

    // SBC (ZP),Y
    rom[12'h100] = 8'hF1;
    rom[12'h101] = 8'h60;
    setup_test(16'h1100);
    uut.reg_a = 8'hC0;
    uut.reg_y = 8'h05;                    // -> $BB
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "SBC (ZP),Y timing");
    check(uut.reg_a, 8'h05, "SBC ($60),Y=5: A = $05");

    // AND (ZP),Y
    rom[12'h100] = 8'h31;
    rom[12'h101] = 8'h60;
    setup_test(16'h1100);
    uut.reg_a = 8'hF0;
    uut.reg_y = 8'h00;                    // -> $AA
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "AND (ZP),Y timing");
    check(uut.reg_a, 8'hA0, "AND ($60),Y=0: A = $A0");

    // ORA (ZP),Y
    rom[12'h100] = 8'h11;
    rom[12'h101] = 8'h60;
    setup_test(16'h1100);
    uut.reg_a = 8'h05;
    uut.reg_y = 8'h00;                    // -> $AA
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "ORA (ZP),Y timing");
    check(uut.reg_a, 8'hAF, "ORA ($60),Y=0: A = $AF");

    // EOR (ZP),Y
    rom[12'h100] = 8'h51;
    rom[12'h101] = 8'h60;
    setup_test(16'h1100);
    uut.reg_a = 8'hFF;
    uut.reg_y = 8'h00;                    // -> $AA
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "EOR (ZP),Y timing");
    check(uut.reg_a, 8'h55, "EOR ($60),Y=0: A = $55");

    // CMP (ZP),Y equal
    rom[12'h100] = 8'hD1;
    rom[12'h101] = 8'h60;
    setup_test(16'h1100);
    uut.reg_a = 8'hAA;
    uut.reg_y = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "CMP (ZP),Y timing");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "CMP ($60),Y=0 equal: Z = 1");

    // ZP wrap on pointer high: base $FF -> low at $FF, high at $00
    ram[8'hFF] = 8'h20;                   // ptr low
    ram[8'h00] = 8'h00;                   // ptr high (wrap) -> $0020
    ram[8'h20] = 8'h7B;
    rom[12'h100] = 8'hB1;
    rom[12'h101] = 8'hFF;
    setup_test(16'h1100);
    uut.reg_y = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "LDA (ZP),Y ZP wrap timing");
    check(uut.reg_a, 8'h7B, "LDA ($FF),Y=0: ZP-wrap ptr -> $7B");

    // STA (ZP),Y no cross (always 6 cycles)
    ram[8'h64] = 8'h00;                   // ptr low
    ram[8'h65] = 8'h00;                   // ptr high -> base $0000
    rom[12'h100] = 8'h91;
    rom[12'h101] = 8'h64;
    setup_test(16'h1100);
    uut.reg_a = 8'h99;
    uut.reg_y = 8'h70;                    // -> $0070
    ram[8'h70] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "STA (ZP),Y no cross timing");
    check({24'h0, ram[8'h70]}, 8'h99, "STA ($64),Y=$70: RAM[$0070] = $99");

    // STA (ZP),Y with cross (still 6 cycles)
    ram[8'h66] = 8'hC0;                   // ptr low
    ram[8'h67] = 8'h00;                   // ptr high -> base $00C0
    rom[12'h100] = 8'h91;
    rom[12'h101] = 8'h66;
    setup_test(16'h1100);
    uut.reg_a = 8'hAB;
    uut.reg_y = 8'h60;                    // $00C0 + $60 = $0120 (cross)
    ram[9'h120] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "STA (ZP),Y cross timing");
    check({24'h0, ram[9'h120]}, 8'hAB, "STA ($66),Y=$60 cross: RAM[$0120] = $AB");

    //=====================================================================
    // SECTION 19: JSR / RTS
    // JSR pushes the address of the JSR last byte (JSR_addr+2) high
    // then low. RTS pops PCL then PCH and adds 1.
    //=====================================================================
    $display("\n=== SECTION 19: JSR / RTS ===\n");

    // JSR $1500 from $1100. Pushes $1102. PC <- $1500.
    rom[12'h100] = 8'h20;
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h15;
    setup_test(16'h1100);
    uut.reg_s = 8'hFD;
    ram[9'h1FD] = 8'h00;
    ram[9'h1FC] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "JSR timing");
    check(uut.reg_pc, 16'h1500, "JSR $1500: PC = $1500");
    check(uut.reg_s, 8'hFB, "JSR: S decremented by 2 to $FB");
    check({24'h0, ram[9'h1FD]}, 8'h11, "JSR: stack[$01FD] = PCH = $11");
    check({24'h0, ram[9'h1FC]}, 8'h02, "JSR: stack[$01FC] = PCL = $02");

    // RTS from above stack state. Should restore PC = $1102 + 1 = $1103, S = $FD.
    rom[12'h500] = 8'h60;
    setup_test(16'h1500);
    uut.reg_s = 8'hFB;
    ram[9'h1FC] = 8'h02;                  // PCL pushed by JSR
    ram[9'h1FD] = 8'h11;                  // PCH pushed by JSR
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "RTS timing");
    check(uut.reg_pc, 16'h1103, "RTS: PC = $1103 (popped + 1)");
    check(uut.reg_s, 8'hFD, "RTS: S restored to $FD");

    // JSR/RTS round trip: JSR at $1100 -> subroutine at $1200 -> RTS -> back at $1103.
    rom[12'h100] = 8'h20;                 // JSR
    rom[12'h101] = 8'h00;
    rom[12'h102] = 8'h12;
    rom[12'h200] = 8'h60;                 // RTS at $1200
    setup_test(16'h1100);
    uut.reg_s = 8'hFD;
    run_instruction(); // JSR
    check(uut.reg_pc, 16'h1200, "Round trip: JSR landed at $1200");
    run_instruction(); // RTS
    check(uut.reg_pc, 16'h1103, "Round trip: RTS returned to $1103");
    check(uut.reg_s, 8'hFD, "Round trip: S restored");

    //=====================================================================
    // SECTION 20: RMW Zero Page
    // 5 cycles. Memory is read, modified, dummy-written back, then the
    // modified value is written.
    //=====================================================================
    $display("\n=== SECTION 20: RMW Zero Page ===\n");

    // ASL $50 - shift mem left
    ram[8'h50] = 8'h41;                   // 0100_0001 -> 1000_0010, C = 0
    rom[12'h100] = 8'h06;
    rom[12'h101] = 8'h50;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "ASL zp timing");
    check({24'h0, ram[8'h50]}, 8'h82, "ASL $50: $41 -> $82");
    check(uut.reg_p[uut.FLAG_C], 1'b0, "ASL zp: C from old bit 7 = 0");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "ASL zp: N from new bit 7 = 1");

    // LSR $51
    ram[8'h51] = 8'h81;                   // 1000_0001 -> 0100_0000, C = 1
    rom[12'h100] = 8'h46;
    rom[12'h101] = 8'h51;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "LSR zp timing");
    check({24'h0, ram[8'h51]}, 8'h40, "LSR $51: $81 -> $40");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "LSR zp: C from old bit 0 = 1");

    // ROL $52
    ram[8'h52] = 8'h81;                   // C=1 in -> 0000_0011, C=1 out
    rom[12'h100] = 8'h26;
    rom[12'h101] = 8'h52;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "ROL zp timing");
    check({24'h0, ram[8'h52]}, 8'h03, "ROL $52: $81 + C -> $03");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "ROL zp: old bit 7 -> C");

    // ROR $53
    ram[8'h53] = 8'h01;                   // C=1 in -> 1000_0000, C=1 out
    rom[12'h100] = 8'h66;
    rom[12'h101] = 8'h53;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "ROR zp timing");
    check({24'h0, ram[8'h53]}, 8'h80, "ROR $53: $01 + C -> $80");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "ROR zp: N = 1");

    // INC $54
    ram[8'h54] = 8'hFF;                   // wrap to 0
    rom[12'h100] = 8'hE6;
    rom[12'h101] = 8'h54;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "INC zp timing");
    check({24'h0, ram[8'h54]}, 8'h00, "INC $54: $FF -> $00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "INC zp: Z = 1");

    // DEC $55
    ram[8'h55] = 8'h01;                   // -> 0
    rom[12'h100] = 8'hC6;
    rom[12'h101] = 8'h55;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "DEC zp timing");
    check({24'h0, ram[8'h55]}, 8'h00, "DEC $55: $01 -> $00");
    check(uut.reg_p[uut.FLAG_Z], 1'b1, "DEC zp: Z = 1");

    //=====================================================================
    // SECTION 21: RMW Zero Page,X / Absolute / Absolute,X
    // 6 / 6 / 7 cycles respectively. RMW abs,X is fixed 7 cycles
    // regardless of page cross.
    //=====================================================================
    $display("\n=== SECTION 21: RMW zp,X / abs / abs,X ===\n");

    // ASL $50,X  X=$04 -> ram[$54]
    ram[8'h54] = 8'h22;                   // -> $44
    rom[12'h100] = 8'h16;
    rom[12'h101] = 8'h50;
    setup_test(16'h1100);
    uut.reg_x = 8'h04;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "ASL zp,X timing");
    check({24'h0, ram[8'h54]}, 8'h44, "ASL $50,X (X=4): $22 -> $44");

    // INC $50,X  X=$05 -> ram[$55]
    ram[8'h55] = 8'h0F;                   // -> $10
    rom[12'h100] = 8'hF6;
    rom[12'h101] = 8'h50;
    setup_test(16'h1100);
    uut.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "INC zp,X timing");
    check({24'h0, ram[8'h55]}, 8'h10, "INC $50,X (X=5): $0F -> $10");

    // LSR abs ($0040)
    ram[8'h40] = 8'h81;                   // -> $40, C=1
    rom[12'h100] = 8'h4E;
    rom[12'h101] = 8'h40;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "LSR abs timing");
    check({24'h0, ram[8'h40]}, 8'h40, "LSR $0040: $81 -> $40");
    check(uut.reg_p[uut.FLAG_C], 1'b1, "LSR abs: C = old bit 0");

    // INC abs ($0041)
    ram[8'h41] = 8'h7F;                   // -> $80, N flips to 1
    rom[12'h100] = 8'hEE;
    rom[12'h101] = 8'h41;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "INC abs timing");
    check({24'h0, ram[8'h41]}, 8'h80, "INC $0041: $7F -> $80");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "INC abs: N = 1");

    // DEC abs ($0042)
    ram[8'h42] = 8'h00;                   // -> $FF
    rom[12'h100] = 8'hCE;
    rom[12'h101] = 8'h42;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "DEC abs timing");
    check({24'h0, ram[8'h42]}, 8'hFF, "DEC $0042: $00 -> $FF");
    check(uut.reg_p[uut.FLAG_N], 1'b1, "DEC abs: N = 1");

    // ASL abs,X no cross  $0040 + X=$05 -> $0045
    ram[8'h45] = 8'h11;                   // -> $22
    rom[12'h100] = 8'h1E;
    rom[12'h101] = 8'h40;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 7, "ASL abs,X no cross timing");
    check({24'h0, ram[8'h45]}, 8'h22, "ASL $0040,X (X=5): $11 -> $22");

    // INC abs,X with cross  $00C0 + X=$50 -> $0110
    ram[9'h110] = 8'h05;                  // -> $06
    rom[12'h100] = 8'hFE;
    rom[12'h101] = 8'hC0;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_x = 8'h50;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 7, "INC abs,X cross timing");
    check({24'h0, ram[9'h110]}, 8'h06, "INC $00C0,X (X=$50): $05 -> $06");

    // ROL abs,X  $0040 + X=$06 -> $0046, C=1 in -> $XX|1
    ram[8'h46] = 8'h7F;                   // 0111_1111 + C=1 -> 1111_1111, C=0
    rom[12'h100] = 8'h3E;
    rom[12'h101] = 8'h40;
    rom[12'h102] = 8'h00;
    setup_test(16'h1100);
    uut.reg_x = 8'h06;
    uut.reg_p[uut.FLAG_C] = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 7, "ROL abs,X timing");
    check({24'h0, ram[8'h46]}, 8'hFF, "ROL $0040,X (X=6): $7F + C -> $FF");
    check(uut.reg_p[uut.FLAG_C], 1'b0, "ROL abs,X: old bit 7 = 0 -> C = 0");

    //=====================================================================
    // SECTION 22: BRK + RTI Round Trip
    // BRK pushes PC+2 then P with B = 1, sets I, fetches IRQ vector.
    // RTI pops P (B forced 0, bit 5 forced 1) then PCL, PCH (no +1).
    //=====================================================================
    $display("\n=== SECTION 22: BRK + RTI ===\n");

    // BRK at $1100. PC pushed = $1102, P pushed = current P with B=1.
    rom[12'h100] = 8'h00;                 // BRK opcode
    rom[12'h101] = 8'h00;                 // BRK signature byte (skipped)
    setup_test(16'h1100);
    uut.reg_s = 8'hFD;
    uut.reg_p = 8'h24;                    // I=1, bit5=1
    ram[9'h1FB] = 8'h00;
    ram[9'h1FC] = 8'h00;
    ram[9'h1FD] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 7, "BRK timing");
    check(uut.reg_pc, 16'h1300, "BRK: PC = IRQ vector $1300");
    check({24'h0, ram[9'h1FD]}, 8'h11, "BRK: stack[$01FD] = PCH = $11");
    check({24'h0, ram[9'h1FC]}, 8'h02, "BRK: stack[$01FC] = PCL = $02");
    check({24'h0, ram[9'h1FB]}, 8'h34, "BRK: stack[$01FB] = P with B=1 = $34");
    check(uut.reg_p[uut.FLAG_I], 1'b1, "BRK: I forced 1");
    check(uut.reg_s, 8'hFA, "BRK: S decremented by 3");

    // RTI from same stack state (PCL=$02 PCH=$11 P=$34 -> P loads as
    // $24 because bit 4 (B) is cleared and bit 5 forced 1).
    rom[12'h300] = 8'h40;                 // RTI at $1300
    setup_test(16'h1300);
    uut.reg_s = 8'hFA;
    ram[9'h1FB] = 8'h34;                  // pushed P with B=1
    ram[9'h1FC] = 8'h02;                  // pushed PCL
    ram[9'h1FD] = 8'h11;                  // pushed PCH
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "RTI timing");
    check(uut.reg_pc, 16'h1102, "RTI: PC = popped (no +1) = $1102");
    check(uut.reg_p, 8'h24, "RTI: P with bit 4 cleared = $24");
    check(uut.reg_s, 8'hFD, "RTI: S restored to $FD");

    // BRK -> RTI round trip: BRK at $1100, RTI at $1300, end at $1102.
    rom[12'h100] = 8'h00;                 // BRK
    rom[12'h101] = 8'h00;
    rom[12'h300] = 8'h40;                 // RTI
    setup_test(16'h1100);
    uut.reg_s = 8'hFD;
    uut.reg_p = 8'h24;
    run_instruction(); // BRK
    check(uut.reg_pc, 16'h1300, "BRK round trip: at IRQ vector");
    run_instruction(); // RTI
    check(uut.reg_pc, 16'h1102, "BRK round trip: RTI back to $1102");
    check(uut.reg_s, 8'hFD, "BRK round trip: S restored");

    //=====================================================================
    // SECTION 23: IRQ Injection
    // IRQ asserts irq_n low while I = 0. The CPU should inject a
    // BRK-like sequence at fetch time, push the next-instruction PC,
    // push P with B = 0, set I, and fetch the IRQ vector.
    //=====================================================================
    $display("\n=== SECTION 23: IRQ Injection ===\n");

    // Set up IRQ scenario: NOP at $1100, IRQ asserted with I = 0.
    rom[12'h100] = 8'hEA;                 // NOP that gets preempted
    setup_test(16'h1100);
    uut.reg_s = 8'hFD;
    uut.reg_p = 8'h20;                    // bit5=1, I=0 (IRQ enabled)
    ram[9'h1FB] = 8'h00;
    ram[9'h1FC] = 8'h00;
    ram[9'h1FD] = 8'h00;
    irq_n = 1'b0;                         // assert IRQ
    uut.irq_n_sync = 1'b0;                // and sync
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 7, "IRQ injection timing");
    check(uut.reg_pc, 16'h1300, "IRQ: PC = vector $1300");
    check({24'h0, ram[9'h1FD]}, 8'h11, "IRQ: stack[$01FD] = PCH = $11");
    check({24'h0, ram[9'h1FC]}, 8'h00, "IRQ: stack[$01FC] = PCL = $00 (next instr)");
    check({24'h0, ram[9'h1FB]}, 8'h20, "IRQ: stack[$01FB] = P with B=0 = $20");
    check(uut.reg_p[uut.FLAG_I], 1'b1, "IRQ: I forced 1");

    // IRQ masked by I = 1 should not fire. Run a NOP and confirm
    // execution continues normally.
    rom[12'h100] = 8'hEA;
    rom[12'h101] = 8'hEA;
    setup_test(16'h1100);
    uut.reg_p = 8'h24;                    // I=1
    irq_n = 1'b0;
    uut.irq_n_sync = 1'b0;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "IRQ masked: NOP runs normally");
    check(uut.reg_pc, 16'h1101, "IRQ masked: PC = $1101 (NOP advanced)");

    //=====================================================================
    // SECTION 24: NMI Injection
    // NMI is edge-triggered. A falling edge on nmi_n latches an NMI
    // request that the CPU services at the next fetch regardless of
    // the I flag. NMI uses vector $FFFA / $FFFB.
    //=====================================================================
    $display("\n=== SECTION 24: NMI Injection ===\n");

    rom[12'h100] = 8'hEA;                 // preempted NOP
    setup_test(16'h1100);
    uut.reg_s = 8'hFD;
    uut.reg_p = 8'h24;                    // I=1 - NMI ignores it
    ram[9'h1FB] = 8'h00;
    ram[9'h1FC] = 8'h00;
    ram[9'h1FD] = 8'h00;
    // Manually latch NMI as if a falling edge had been observed.
    uut.nmi_latch = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 7, "NMI injection timing");
    check(uut.reg_pc, 16'h1400, "NMI: PC = vector $1400");
    check({24'h0, ram[9'h1FD]}, 8'h11, "NMI: stack[$01FD] = PCH = $11");
    check({24'h0, ram[9'h1FC]}, 8'h00, "NMI: stack[$01FC] = PCL = $00");
    check({24'h0, ram[9'h1FB]}, 8'h24, "NMI: stack[$01FB] = P with B=0 = $24");
    check(uut.reg_p[uut.FLAG_I], 1'b1, "NMI: I forced 1");
    check({24'h0, uut.nmi_latch}, 1'b0, "NMI: latch cleared after ack");

    //=====================================================================
    // SECTION 25: ALU Logical Operations (direct)
    // ORA, AND, EOR. N from result[7], Z from result == 0. C and V
    // unchanged. Driven directly through u_alu_chk so flag-preservation
    // edge cases are verifiable without the CPU drive overriding the
    // ALU inputs.
    //=====================================================================
    $display("\n=== SECTION 25: ALU Logical Operations ===\n");

    apply_alu(8'h0F, 8'hF0, ALU_OR, 8'h00);
    check_alu_q  (8'hFF, "ORA $0F | $F0");
    check_alu_flag(uut.FLAG_N, 1'b1, "ORA N=1");
    check_alu_flag(uut.FLAG_Z, 1'b0, "ORA Z=0");

    apply_alu(8'h00, 8'h00, ALU_OR, 8'h00);
    check_alu_q  (8'h00, "ORA $00 | $00");
    check_alu_flag(uut.FLAG_N, 1'b0, "ORA N=0");
    check_alu_flag(uut.FLAG_Z, 1'b1, "ORA Z=1");

    apply_alu(8'hFF, 8'h0F, ALU_AND, 8'h00);
    check_alu_q  (8'h0F, "AND $FF & $0F");
    check_alu_flag(uut.FLAG_N, 1'b0, "AND N=0");
    check_alu_flag(uut.FLAG_Z, 1'b0, "AND Z=0");

    apply_alu(8'h80, 8'h80, ALU_AND, 8'h00);
    check_alu_q  (8'h80, "AND $80 & $80");
    check_alu_flag(uut.FLAG_N, 1'b1, "AND N=1");

    apply_alu(8'h55, 8'hAA, ALU_AND, 8'h00);
    check_alu_q  (8'h00, "AND $55 & $AA");
    check_alu_flag(uut.FLAG_Z, 1'b1, "AND Z=1");

    apply_alu(8'hFF, 8'h0F, ALU_EOR, 8'h00);
    check_alu_q  (8'hF0, "EOR $FF ^ $0F");
    check_alu_flag(uut.FLAG_N, 1'b1, "EOR N=1");

    apply_alu(8'h55, 8'h55, ALU_EOR, 8'h00);
    check_alu_q  (8'h00, "EOR $55 ^ $55");
    check_alu_flag(uut.FLAG_Z, 1'b1, "EOR Z=1");

    apply_alu(8'h0F, 8'hF0, ALU_OR, 8'h01);
    check_alu_flag_unchanged(uut.FLAG_C, "ORA preserves C=1");
    apply_alu(8'h0F, 8'hF0, ALU_OR, 8'h00);
    check_alu_flag_unchanged(uut.FLAG_C, "ORA preserves C=0");

    //=====================================================================
    // SECTION 26: ALU Pass-through (direct)
    // EQ1 leaves all flags unchanged (used internally for STA, branches).
    // EQ2 updates N and Z, leaves others alone (used for LDA, transfers).
    //=====================================================================
    $display("\n=== SECTION 26: ALU Pass-through ===\n");

    apply_alu(8'h42, 8'h00, ALU_EQ1, 8'h00);
    check_alu_q  (8'h42, "EQ1 pass $42");
    apply_alu(8'h00, 8'h00, ALU_EQ1, 8'hFF);
    check_alu_flag_unchanged(uut.FLAG_N, "EQ1 N preserved");
    check_alu_flag_unchanged(uut.FLAG_Z, "EQ1 Z preserved");
    check_alu_flag_unchanged(uut.FLAG_C, "EQ1 C preserved");
    check_alu_flag_unchanged(uut.FLAG_V, "EQ1 V preserved");

    apply_alu(8'h80, 8'h00, ALU_EQ2, 8'h00);
    check_alu_q  (8'h80, "EQ2 pass $80");
    check_alu_flag(uut.FLAG_N, 1'b1, "EQ2 N=1 (from $80)");
    check_alu_flag(uut.FLAG_Z, 1'b0, "EQ2 Z=0");

    apply_alu(8'h00, 8'h00, ALU_EQ2, 8'h00);
    check_alu_q  (8'h00, "EQ2 pass $00");
    check_alu_flag(uut.FLAG_N, 1'b0, "EQ2 N=0");
    check_alu_flag(uut.FLAG_Z, 1'b1, "EQ2 Z=1 (from $00)");

    apply_alu(8'h7F, 8'h00, ALU_EQ2, 8'h41);
    check_alu_flag_unchanged(uut.FLAG_C, "EQ2 C preserved");
    check_alu_flag_unchanged(uut.FLAG_V, "EQ2 V preserved");

    //=====================================================================
    // SECTION 27: ALU Increment / Decrement (direct)
    // INC: a + 1. DEC: a - 1. N from result[7], Z from result == 0.
    // C and V unchanged.
    //=====================================================================
    $display("\n=== SECTION 27: ALU Increment / Decrement ===\n");

    apply_alu(8'h7F, 8'h00, ALU_INC, 8'h00);
    check_alu_q  (8'h80, "INC $7F");
    check_alu_flag(uut.FLAG_N, 1'b1, "INC N=1 ($7F->$80)");
    check_alu_flag(uut.FLAG_Z, 1'b0, "INC Z=0");

    apply_alu(8'hFF, 8'h00, ALU_INC, 8'h00);
    check_alu_q  (8'h00, "INC $FF");
    check_alu_flag(uut.FLAG_Z, 1'b1, "INC Z=1 ($FF->$00)");

    apply_alu(8'h00, 8'h00, ALU_INC, 8'h00);
    check_alu_q  (8'h01, "INC $00");

    apply_alu(8'h01, 8'h00, ALU_DEC, 8'h00);
    check_alu_q  (8'h00, "DEC $01");
    check_alu_flag(uut.FLAG_Z, 1'b1, "DEC Z=1 ($01->$00)");

    apply_alu(8'h00, 8'h00, ALU_DEC, 8'h00);
    check_alu_q  (8'hFF, "DEC $00");
    check_alu_flag(uut.FLAG_N, 1'b1, "DEC N=1 ($00->$FF)");

    apply_alu(8'h7F, 8'h00, ALU_INC, 8'h01);
    check_alu_flag_unchanged(uut.FLAG_C, "INC preserves C");

    //=====================================================================
    // SECTION 28: ALU Shift / Rotate (direct)
    // ASL: bit 7 -> C, 0 -> bit 0
    // LSR: bit 0 -> C, 0 -> bit 7
    // ROL: bit 7 -> C, C -> bit 0
    // ROR: bit 0 -> C, C -> bit 7
    // All update N from result[7], Z from result == 0.
    //=====================================================================
    $display("\n=== SECTION 28: ALU Shift / Rotate ===\n");

    apply_alu(8'h80, 8'h00, ALU_ASL, 8'h00);
    check_alu_q  (8'h00, "ASL $80");
    check_alu_flag(uut.FLAG_C, 1'b1, "ASL C=1 (bit 7 set)");
    check_alu_flag(uut.FLAG_Z, 1'b1, "ASL Z=1");
    check_alu_flag(uut.FLAG_N, 1'b0, "ASL N=0");

    apply_alu(8'h40, 8'h00, ALU_ASL, 8'h00);
    check_alu_q  (8'h80, "ASL $40");
    check_alu_flag(uut.FLAG_C, 1'b0, "ASL C=0 (bit 7 clear)");
    check_alu_flag(uut.FLAG_N, 1'b1, "ASL N=1");

    apply_alu(8'h01, 8'h00, ALU_LSR, 8'h00);
    check_alu_q  (8'h00, "LSR $01");
    check_alu_flag(uut.FLAG_C, 1'b1, "LSR C=1");
    check_alu_flag(uut.FLAG_Z, 1'b1, "LSR Z=1");
    check_alu_flag(uut.FLAG_N, 1'b0, "LSR N=0 (always after LSR)");

    apply_alu(8'h80, 8'h00, ALU_LSR, 8'h00);
    check_alu_q  (8'h40, "LSR $80");
    check_alu_flag(uut.FLAG_C, 1'b0, "LSR C=0");
    check_alu_flag(uut.FLAG_N, 1'b0, "LSR N=0");

    apply_alu(8'h80, 8'h00, ALU_ROL, 8'h00);
    check_alu_q  (8'h00, "ROL $80, C in=0");
    check_alu_flag(uut.FLAG_C, 1'b1, "ROL C out=1");
    check_alu_flag(uut.FLAG_Z, 1'b1, "ROL Z=1");

    apply_alu(8'h40, 8'h00, ALU_ROL, 8'h01);
    check_alu_q  (8'h81, "ROL $40, C in=1");
    check_alu_flag(uut.FLAG_C, 1'b0, "ROL C out=0");
    check_alu_flag(uut.FLAG_N, 1'b1, "ROL N=1");

    apply_alu(8'h01, 8'h00, ALU_ROR, 8'h00);
    check_alu_q  (8'h00, "ROR $01, C in=0");
    check_alu_flag(uut.FLAG_C, 1'b1, "ROR C out=1");
    check_alu_flag(uut.FLAG_Z, 1'b1, "ROR Z=1");

    apply_alu(8'h02, 8'h00, ALU_ROR, 8'h01);
    check_alu_q  (8'h81, "ROR $02, C in=1");
    check_alu_flag(uut.FLAG_C, 1'b0, "ROR C out=0");
    check_alu_flag(uut.FLAG_N, 1'b1, "ROR N=1");

    //=====================================================================
    // SECTION 29: ALU ADC Binary Mode (direct)
    // a + b + C, with C from p_in. D flag clear (binary mode).
    // Update C, N, V, Z.
    //=====================================================================
    $display("\n=== SECTION 29: ALU ADC Binary Mode ===\n");

    apply_alu(8'h00, 8'h00, ALU_ADC, 8'h00);
    check_alu_q  (8'h00, "ADC $00 + $00 + 0");
    check_alu_flag(uut.FLAG_C, 1'b0, "ADC C=0");
    check_alu_flag(uut.FLAG_Z, 1'b1, "ADC Z=1");
    check_alu_flag(uut.FLAG_V, 1'b0, "ADC V=0");
    check_alu_flag(uut.FLAG_N, 1'b0, "ADC N=0");

    apply_alu(8'h7F, 8'h01, ALU_ADC, 8'h00);
    check_alu_q  (8'h80, "ADC $7F + $01 + 0");
    check_alu_flag(uut.FLAG_V, 1'b1, "ADC V=1 (signed overflow)");
    check_alu_flag(uut.FLAG_N, 1'b1, "ADC N=1");
    check_alu_flag(uut.FLAG_C, 1'b0, "ADC C=0");

    apply_alu(8'hFF, 8'h01, ALU_ADC, 8'h00);
    check_alu_q  (8'h00, "ADC $FF + $01 + 0");
    check_alu_flag(uut.FLAG_C, 1'b1, "ADC C=1 (carry out)");
    check_alu_flag(uut.FLAG_Z, 1'b1, "ADC Z=1");
    check_alu_flag(uut.FLAG_V, 1'b0, "ADC V=0");

    apply_alu(8'h7F, 8'h00, ALU_ADC, 8'h01);
    check_alu_q  (8'h80, "ADC $7F + $00 + 1");
    check_alu_flag(uut.FLAG_V, 1'b1, "ADC V=1");

    apply_alu(8'h80, 8'h80, ALU_ADC, 8'h00);
    check_alu_q  (8'h00, "ADC $80 + $80 + 0");
    check_alu_flag(uut.FLAG_C, 1'b1, "ADC C=1");
    check_alu_flag(uut.FLAG_V, 1'b1, "ADC V=1 (neg overflow)");

    apply_alu(8'h40, 8'h40, ALU_ADC, 8'h00);
    check_alu_q  (8'h80, "ADC $40 + $40 + 0");
    check_alu_flag(uut.FLAG_V, 1'b1, "ADC V=1 (pos overflow)");

    apply_alu(8'h50, 8'h30, ALU_ADC, 8'h00);
    check_alu_q  (8'h80, "ADC $50 + $30 + 0");
    check_alu_flag(uut.FLAG_V, 1'b1, "ADC V=1 (pos+pos=neg)");

    apply_alu(8'h50, 8'h10, ALU_ADC, 8'h00);
    check_alu_q  (8'h60, "ADC $50 + $10 + 0");
    check_alu_flag(uut.FLAG_V, 1'b0, "ADC V=0 (no overflow)");

    //=====================================================================
    // SECTION 30: ALU ADC Decimal Mode (direct)
    // D flag set in p_in. C reflects post-BCD-adjust carry.
    // N, V, Z come from binary intermediate (NMOS behaviour).
    //=====================================================================
    $display("\n=== SECTION 30: ALU ADC Decimal Mode ===\n");

    apply_alu(8'h09, 8'h01, ALU_ADC, 8'h08);
    check_alu_q  (8'h10, "ADC BCD $09 + $01");
    check_alu_flag(uut.FLAG_C, 1'b0, "ADC BCD C=0");

    apply_alu(8'h49, 8'h49, ALU_ADC, 8'h08);
    check_alu_q  (8'h98, "ADC BCD $49 + $49");
    check_alu_flag(uut.FLAG_C, 1'b0, "ADC BCD C=0");

    apply_alu(8'h50, 8'h50, ALU_ADC, 8'h08);
    check_alu_q  (8'h00, "ADC BCD $50 + $50");
    check_alu_flag(uut.FLAG_C, 1'b1, "ADC BCD C=1 (high carry)");

    apply_alu(8'h99, 8'h01, ALU_ADC, 8'h08);
    check_alu_q  (8'h00, "ADC BCD $99 + $01");
    check_alu_flag(uut.FLAG_C, 1'b1, "ADC BCD C=1 (rollover)");

    apply_alu(8'h99, 8'h99, ALU_ADC, 8'h08);
    check_alu_q  (8'h98, "ADC BCD $99 + $99");
    check_alu_flag(uut.FLAG_C, 1'b1, "ADC BCD C=1");

    apply_alu(8'h25, 8'h25, ALU_ADC, 8'h09);
    check_alu_q  (8'h51, "ADC BCD $25 + $25 + 1");
    check_alu_flag(uut.FLAG_C, 1'b0, "ADC BCD C=0");

    //=====================================================================
    // SECTION 31: ALU SBC Binary Mode (direct)
    // a - b - !C. C=1 means no borrow; C=0 means borrow in.
    // Update C, N, V, Z. C=1 in result means no borrow occurred.
    //=====================================================================
    $display("\n=== SECTION 31: ALU SBC Binary Mode ===\n");

    apply_alu(8'h50, 8'h30, ALU_SBC, 8'h01);
    check_alu_q  (8'h20, "SBC $50 - $30 (C=1)");
    check_alu_flag(uut.FLAG_C, 1'b1, "SBC C=1 (no borrow)");
    check_alu_flag(uut.FLAG_V, 1'b0, "SBC V=0");
    check_alu_flag(uut.FLAG_N, 1'b0, "SBC N=0");

    apply_alu(8'h50, 8'h30, ALU_SBC, 8'h00);
    check_alu_q  (8'h1F, "SBC $50 - $30 - 1 (C=0)");
    check_alu_flag(uut.FLAG_C, 1'b1, "SBC C=1");

    apply_alu(8'h00, 8'h01, ALU_SBC, 8'h01);
    check_alu_q  (8'hFF, "SBC $00 - $01 (C=1)");
    check_alu_flag(uut.FLAG_C, 1'b0, "SBC C=0 (borrow)");
    check_alu_flag(uut.FLAG_N, 1'b1, "SBC N=1");

    apply_alu(8'h80, 8'h01, ALU_SBC, 8'h01);
    check_alu_q  (8'h7F, "SBC $80 - $01");
    check_alu_flag(uut.FLAG_V, 1'b1, "SBC V=1 (neg-pos=pos)");

    apply_alu(8'h7F, 8'hFF, ALU_SBC, 8'h01);
    check_alu_q  (8'h80, "SBC $7F - $FF");
    check_alu_flag(uut.FLAG_V, 1'b1, "SBC V=1 (pos-neg=neg)");

    apply_alu(8'h42, 8'h42, ALU_SBC, 8'h01);
    check_alu_q  (8'h00, "SBC $42 - $42");
    check_alu_flag(uut.FLAG_Z, 1'b1, "SBC Z=1");
    check_alu_flag(uut.FLAG_C, 1'b1, "SBC C=1");

    //=====================================================================
    // SECTION 32: ALU SBC Decimal Mode (direct)
    // D flag set. BCD adjust subtracts 6 from any nibble that borrowed.
    // C reflects post-adjust borrow. N, V, Z from binary intermediate.
    //=====================================================================
    $display("\n=== SECTION 32: ALU SBC Decimal Mode ===\n");

    apply_alu(8'h50, 8'h25, ALU_SBC, 8'h09);
    check_alu_q  (8'h25, "SBC BCD $50 - $25");
    check_alu_flag(uut.FLAG_C, 1'b1, "SBC BCD C=1");

    apply_alu(8'h00, 8'h01, ALU_SBC, 8'h09);
    check_alu_q  (8'h99, "SBC BCD $00 - $01");
    check_alu_flag(uut.FLAG_C, 1'b0, "SBC BCD C=0 (borrow)");

    apply_alu(8'h99, 8'h01, ALU_SBC, 8'h09);
    check_alu_q  (8'h98, "SBC BCD $99 - $01");
    check_alu_flag(uut.FLAG_C, 1'b1, "SBC BCD C=1");

    apply_alu(8'h10, 8'h05, ALU_SBC, 8'h09);
    check_alu_q  (8'h05, "SBC BCD $10 - $05");
    check_alu_flag(uut.FLAG_C, 1'b1, "SBC BCD C=1");

    //=====================================================================
    // SECTION 33: ALU CMP (direct)
    // Subtraction with carry-in forced to 1 (no borrow). Result NOT
    // written back; only C, N, Z update. V unchanged.
    //=====================================================================
    $display("\n=== SECTION 33: ALU CMP ===\n");

    apply_alu(8'h42, 8'h42, ALU_CMP, 8'h00);
    check_alu_flag(uut.FLAG_Z, 1'b1, "CMP $42 == $42, Z=1");
    check_alu_flag(uut.FLAG_C, 1'b1, "CMP C=1 (a >= b)");
    check_alu_flag(uut.FLAG_N, 1'b0, "CMP N=0");

    apply_alu(8'h50, 8'h30, ALU_CMP, 8'h00);
    check_alu_flag(uut.FLAG_Z, 1'b0, "CMP $50 > $30, Z=0");
    check_alu_flag(uut.FLAG_C, 1'b1, "CMP C=1 (a >= b)");
    check_alu_flag(uut.FLAG_N, 1'b0, "CMP N=0");

    apply_alu(8'h30, 8'h50, ALU_CMP, 8'h00);
    check_alu_flag(uut.FLAG_Z, 1'b0, "CMP $30 < $50, Z=0");
    check_alu_flag(uut.FLAG_C, 1'b0, "CMP C=0 (a < b)");
    check_alu_flag(uut.FLAG_N, 1'b1, "CMP N=1");

    apply_alu(8'h42, 8'h42, ALU_CMP, 8'h00);
    check_alu_flag(uut.FLAG_Z, 1'b1, "CMP $42==$42 with p_in C=0");
    check_alu_flag(uut.FLAG_C, 1'b1, "CMP C=1 regardless");

    apply_alu(8'h00, 8'h00, ALU_CMP, 8'h40);
    check_alu_flag_unchanged(uut.FLAG_V, "CMP preserves V");

    //=====================================================================
    // SECTION 34: ALU BIT (direct)
    // V from b[6], N from b[7], Z from (a & b). C unchanged.
    //=====================================================================
    $display("\n=== SECTION 34: ALU BIT ===\n");

    apply_alu(8'hFF, 8'h80, ALU_BIT, 8'h00);
    check_alu_flag(uut.FLAG_N, 1'b1, "BIT N=1 (b[7]=1)");
    check_alu_flag(uut.FLAG_V, 1'b0, "BIT V=0 (b[6]=0)");
    check_alu_flag(uut.FLAG_Z, 1'b0, "BIT Z=0 (a & b != 0)");

    apply_alu(8'h00, 8'h80, ALU_BIT, 8'h00);
    check_alu_flag(uut.FLAG_N, 1'b1, "BIT N=1");
    check_alu_flag(uut.FLAG_V, 1'b0, "BIT V=0");
    check_alu_flag(uut.FLAG_Z, 1'b1, "BIT Z=1 ($00 & $80 = 0)");

    apply_alu(8'hFF, 8'h40, ALU_BIT, 8'h00);
    check_alu_flag(uut.FLAG_N, 1'b0, "BIT N=0 (b[7]=0)");
    check_alu_flag(uut.FLAG_V, 1'b1, "BIT V=1 (b[6]=1)");

    apply_alu(8'hFF, 8'hC0, ALU_BIT, 8'h00);
    check_alu_flag(uut.FLAG_N, 1'b1, "BIT N=1 (b[7]=1)");
    check_alu_flag(uut.FLAG_V, 1'b1, "BIT V=1 (b[6]=1)");

    apply_alu(8'hFF, 8'h00, ALU_BIT, 8'h00);
    check_alu_flag(uut.FLAG_N, 1'b0, "BIT N=0");
    check_alu_flag(uut.FLAG_V, 1'b0, "BIT V=0");
    check_alu_flag(uut.FLAG_Z, 1'b1, "BIT Z=1 ($FF & $00 = 0)");

    apply_alu(8'hFF, 8'h00, ALU_BIT, 8'h01);
    check_alu_flag_unchanged(uut.FLAG_C, "BIT preserves C");

    //=====================================================================
    // SECTION 35: VP_n Vector Pull
    // VP_n is asserted (low) only during the two vector-fetch cycles of
    // an IRQ / NMI / BRK sequence. It is high during the push cycles, the
    // dummy reads, the opcode fetch, and any normal read or write. After
    // each cycle() call the registered outputs reflect what the bus will
    // present during the NEXT cycle, so checks after cycle N read the
    // bus values for cycle N+1.
    //=====================================================================
    $display("\n=== SECTION 35: VP_n Vector Pull ===\n");

    // Idle - vp_n stays high through normal operation
    rom[12'h100] = 8'hEA; // NOP
    rom[12'h101] = 8'hEA;
    setup_test(16'h1100);
    cycle();
    check(vp_n, 1'b1, "VP_n high during NOP");

    // BRK - 7-cycle sequence. Cycles 1..4 push and dummies (vp_n high).
    // After cycle 5: bus latched for cycle 6 -> addr $FFFE, vp_n low.
    // After cycle 6: bus latched for cycle 7 -> addr $FFFF, vp_n low.
    // After cycle 7: bus latched for cycle 8 -> addr vector target, vp_n high.
    rom[12'h100] = 8'h00; // BRK
    rom[12'h101] = 8'h00;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_I] = 1'b0;
    cycle();                                     // 1: FETCH dispatch
    check(vp_n, 1'b1, "BRK after cycle 1 VP_n=1");
    cycle();                                     // 2: T1
    check(vp_n, 1'b1, "BRK after cycle 2 VP_n=1");
    cycle();                                     // 3: T2 push PCH
    check(vp_n, 1'b1, "BRK after cycle 3 VP_n=1");
    cycle();                                     // 4: T3 push PCL
    check(vp_n, 1'b1, "BRK after cycle 4 VP_n=1");
    cycle();                                     // 5: T4 push P, latch vp_n low for T5
    check(vp_n, 1'b0, "BRK after cycle 5 VP_n=0 (vector lo coming)");
    check(addr, 16'hFFFE, "BRK after cycle 5 addr = $FFFE");
    cycle();                                     // 6: T5 read vector lo, latch for T6
    check(vp_n, 1'b0, "BRK after cycle 6 VP_n=0 (vector hi coming)");
    check(addr, 16'hFFFF, "BRK after cycle 6 addr = $FFFF");
    cycle();                                     // 7: T6 read vector hi, latch for FETCH
    check(vp_n, 1'b1, "BRK after cycle 7 VP_n=1 (vector done)");
    check(addr, 16'h1300, "BRK after cycle 7 addr = vector target");

    // IRQ injection - same 7-cycle vector-fetch pattern
    rom[12'h100] = 8'hEA;
    rom[12'h101] = 8'hEA;
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_I] = 1'b0;
    irq_n = 1'b0;
    uut.irq_n_sync = 1'b0;
    cycle();                                     // 1: FETCH detects IRQ
    cycle();                                     // 2: T1
    cycle();                                     // 3: T2
    cycle();                                     // 4: T3
    cycle();                                     // 5: T4 latches vector lo
    check(vp_n, 1'b0, "IRQ after cycle 5 VP_n=0");
    check(addr, 16'hFFFE, "IRQ after cycle 5 addr = $FFFE");
    cycle();                                     // 6: T5 latches vector hi
    check(vp_n, 1'b0, "IRQ after cycle 6 VP_n=0");
    check(addr, 16'hFFFF, "IRQ after cycle 6 addr = $FFFF");
    cycle();                                     // 7: T6 latches FETCH at $1300
    check(vp_n, 1'b1, "IRQ after cycle 7 VP_n=1");
    irq_n = 1'b1;

    // NMI injection - vector at $FFFA / $FFFB
    setup_test(16'h1100);
    uut.reg_p[uut.FLAG_I] = 1'b0;
    nmi_n = 1'b0;
    uut.nmi_latch = 1'b1;
    cycle(); cycle(); cycle(); cycle();          // 1..4
    cycle();                                     // 5: T4 latches NMI vector lo
    check(vp_n, 1'b0, "NMI after cycle 5 VP_n=0");
    check(addr, 16'hFFFA, "NMI after cycle 5 addr = $FFFA");
    cycle();                                     // 6: T5 latches NMI vector hi
    check(vp_n, 1'b0, "NMI after cycle 6 VP_n=0");
    check(addr, 16'hFFFB, "NMI after cycle 6 addr = $FFFB");
    cycle();                                     // 7: T6 latches FETCH
    check(vp_n, 1'b1, "NMI after cycle 7 VP_n=1");
    nmi_n = 1'b1;

    // Reset vector fetch must NOT assert VP_n (NMOS / 65C02 convention)
    rst_n = 1'b0;
    cen = 1'b0;
    #20;
    rst_n = 1'b1;
    #10;
    cycle(); cycle(); cycle(); cycle(); cycle(); cycle(); cycle();
    check(vp_n, 1'b1, "Reset vector fetch leaves VP_n high");

    //=====================================================================
    // SECTION 36: RDY Read-Cycle Stall
    // RDY low halts the CPU on read cycles per MCS6500 manual. Write
    // cycles (rw_n = 0) complete regardless so external logic cannot
    // lose a pending write.
    //=====================================================================
    $display("\n=== SECTION 36: RDY Stall ===\n");

    // Read-cycle stall: pull rdy low mid-instruction, confirm state holds
    rom[12'h100] = 8'hA9; // LDA #$42
    rom[12'h101] = 8'h42;
    setup_test(16'h1100);
    cycle();                                     // FETCH -> ST_IMM_T1
    rdy = 1'b0;
    cycle();                                     // would normally complete LDA
    check({16'h0, uut.state}, 24'h0 + uut.ST_IMM_T1, "RDY=0 holds state at ST_IMM_T1");
    check(uut.reg_a, 8'h00, "RDY=0 holds A unchanged");
    cycle();
    check({16'h0, uut.state}, 24'h0 + uut.ST_IMM_T1, "RDY=0 second tick still holds");
    cycle();
    check({16'h0, uut.state}, 24'h0 + uut.ST_IMM_T1, "RDY=0 third tick still holds");
    rdy = 1'b1;
    cycle();                                     // resumes; LDA completes
    check(uut.reg_a, 8'h42, "RDY=1 resume completes LDA");

    // Write cycle bypasses stall - STA $0040 must complete with rdy low
    rom[12'h100] = 8'h8D; // STA abs
    rom[12'h101] = 8'h40;
    rom[12'h102] = 8'h00;
    ram[9'h040] = 8'h00;
    setup_test(16'h1100);
    uut.reg_a = 8'hAB;
    cycle();                                     // FETCH -> ST_ABS_W_T1
    cycle();                                     // T1 read operand low
    cycle();                                     // T2 read operand high; sets rw_n=0 for next
    // At this point rw_n is 0 (write cycle on bus). Pull rdy low: T3 should still complete.
    rdy = 1'b0;
    cycle();                                     // T3 write to RAM
    rdy = 1'b1;
    cycle();                                     // FETCH at next opcode
    check({24'h0, ram[9'h040]}, 8'hAB, "RDY=0 does not block write (RAM[$40] = $AB)");

    // Read-cycle stall during operand fetch (LDA abs T1)
    rom[12'h100] = 8'hAD; // LDA abs
    rom[12'h101] = 8'h41;
    rom[12'h102] = 8'h00;
    ram[9'h041] = 8'h77;
    setup_test(16'h1100);
    uut.reg_a = 8'h00;
    cycle();                                     // FETCH -> ST_ABS_R_T1
    rdy = 1'b0;
    cycle();
    check({16'h0, uut.state}, 24'h0 + uut.ST_ABS_R_T1, "RDY=0 stalls operand-fetch read");
    rdy = 1'b1;
    cycle(); cycle(); cycle();                   // T1, T2, T3 complete
    check(uut.reg_a, 8'h77, "RDY released, LDA abs completes (A = $77)");

    //=====================================================================
    // Final Test Summary
    //=====================================================================
    $display("\n=============================================================");
    $display("  x6502 Test Results");
    $display("=============================================================");
    $display("  Total Tests:  %0d", total_tests);
    $display("  Passed:       %0d", passed_tests);
    $display("  Failed:       %0d", failed_tests);
    $display("=============================================================");

    if(failed_tests == 0) begin
        $display("  *** ALL TESTS PASSED ***");
        $display("  Cycle-accurate to MCS6500 Hardware Manual");
    end else begin
        $display("  *** SOME TESTS FAILED ***");
    end

    $display("=============================================================\n");

    $stop;
end

endmodule
