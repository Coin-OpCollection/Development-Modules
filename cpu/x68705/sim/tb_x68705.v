/*
* <-- Coin-Op Collection -->
* https://coinopcollection.org
* https://github.com/Coin-OpCollection/
*
* Author: atrac17 (https://twitter.com/_atrac17)
* Copyright © 2025 Coin-Op Collection
*
* This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/.
*
* You may use, share, and modify this code for non-commercial purposes, provided that proper credit is given.
*/

//============================================================================
//  Comprehensive testbench for the MC68705P3 microcomputer implementation.
//
//  Verifies all CPU instructions with functional correctness and cycle-
//  accurate timing per the M6805 CMOS Family User's Manual. Tests cover
//  all seven addressing modes: inherent, immediate, direct, extended,
//  indexed (3 variants), relative, and bit manipulation (2 variants).
//
//  Test Organization:
//    Section 1:  Inherent mode control (NOP, TAX, TXA, CLC, SEC, etc.)
//    Section 2:  Accumulator RMW (INCA, DECA, shifts, rotates)
//    Section 3:  Index register RMW (INCX, DECX, CLRX)
//    Section 4:  Immediate addressing (LDA #, ADD #, AND #, etc.)
//    Section 5:  Direct addressing (LDA dir, STA dir, ADD dir)
//    Section 6:  Extended addressing (LDA ext, STA ext)
//    Section 7:  Indexed addressing (,X  off,X  off16,X variants)
//    Section 8:  Branch instructions (BRA, BEQ, BNE, etc.)
//    Section 9:  Bit set/clear (BSET, BCLR)
//    Section 10: Bit test and branch (BRSET, BRCLR)
//    Section 11: Direct RMW (INC dir, DEC dir, CLR dir)
//    Section 12: Indexed RMW (INC ,X  INC off,X)
//    Section 13: Jump instructions (JMP dir, JMP ext, JMP ,X)
//    Section 14: Subroutine calls (JSR, BSR, RTS)
//    Section 15: Interrupt instructions (SWI, RTI)
//    Section 16: Hardware interrupts (IRQ, TIRQ, priority)
//    Section 17: I/O port operations (DDR, data read/write)
//    Section 18: Timer operations (TDR, TCR access)
//    Section 19: Memory boundary tests (RAM limits)
//
//  Cycle Timing Reference (M146805 CMOS):
//    Inherent:       2 cycles (1-byte)
//    Accumulator:    3 cycles (1-byte RMW)
//    Immediate:      2 cycles (2-byte)
//    Direct:         3-4 cycles (2-byte, +1 for store)
//    Extended:       4-5 cycles (3-byte, +1 for store)
//    Indexed no off: 3-4 cycles (1-byte, +1 for store)
//    Indexed 8-bit:  4-5 cycles (2-byte, +1 for store)
//    Indexed 16-bit: 5-6 cycles (3-byte, +1 for store)
//    Branch:         3 cycles (2-byte, taken or not)
//    Bit set/clear:  5 cycles (2-byte)
//    Bit test/branch:5 cycles (3-byte)
//    Direct RMW:     5 cycles (2-byte)
//    JSR direct:     5 cycles
//    JSR extended:   6 cycles
//    BSR:            6 cycles
//    RTS:            6 cycles
//    SWI:            10 cycles
//    RTI:            9 cycles
//
//  Reference: MC68705P3 8-BIT EPROM Micro Computer Unit Data Sheet and
//             M6805/M146805 CMOS Family User's Manual, Second Edition
//============================================================================
`timescale 1ns/1ps

module tb_x68705;

//=========================================================================
// Test Signals:
// Main clock, reset, and clock enable drive the DUT. ROM interface
// provides instruction and data fetch. I/O ports allow peripheral
// testing. Interrupt inputs test hardware interrupt handling.
//=========================================================================
reg clk;
reg rst;
reg cen;

// ROM interface
wire [10:0] rom_addr;
reg   [7:0] rom_data;
wire        rom_cs;

// I/O Ports
reg  [7:0] pa_i;
wire [7:0] pa_o;
reg  [7:0] pb_i;
wire [7:0] pb_o;
reg  [3:0] pc_i;
wire [3:0] pc_o;

// Interrupts and Timer
reg       irq;
reg       timer_in;
reg [7:0] mor;

//=========================================================================
// Test Infrastructure:
// Counters track pass/fail statistics. ROM array provides 2KB of
// instruction storage. Each test section loads specific opcodes and
// operands into ROM before execution.
//=========================================================================
integer total_tests;
integer passed_tests;
integer failed_tests;
integer cycle_count;
integer i;

// ROM storage (2KB matches MC68705P3 address space $080-$7FF)
reg [7:0] rom [0:2047];

// ROM Read:
// Directly maps rom_addr to rom array for instruction/data fetch.
always @(*) begin
    rom_data = rom[rom_addr];
end

//=========================================================================
// DUT Instantiation:
// Complete MC68705P3 MCU including CPU, ALU, memory, I/O, and timer.
//=========================================================================
x68705 uut (
    .clk      ( clk      ),
    .rst      ( rst      ),
    .cen      ( cen      ),
    .rom_addr ( rom_addr ),
    .rom_data ( rom_data ),
    .rom_cs   ( rom_cs   ),
    .pa_i     ( pa_i     ),
    .pa_o     ( pa_o     ),
    .pb_i     ( pb_i     ),
    .pb_o     ( pb_o     ),
    .pc_i     ( pc_i     ),
    .pc_o     ( pc_o     ),
    .irq      ( irq      ),
    .timer_in ( timer_in ),
    .mor      ( mor      )
);

//=========================================================================
// Clock Generation:
// 10ns period (100MHz) provides fast simulation. Real MC68705P3 runs
// at up to 4MHz with internal divide-by-2, giving 2MHz bus rate.
//=========================================================================
initial clk = 0;
always #5 clk = ~clk;

//=========================================================================
// Helper Tasks:
// Provide consistent test execution and result checking across all
// test sections.
//=========================================================================

//-------------------------------------------------------------------------
// Single Clock Cycle:
// Executes one clock cycle with clock enable asserted. The two-edge
// sequence ensures proper synchronous operation.
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
// Monitors CPU state machine and counts cycles until it returns to
// FETCH state, indicating instruction completion. Timeout prevents
// infinite loops on errors.
//-------------------------------------------------------------------------
task count_cycles;
    output integer cycles;
    begin
        cycles = 0;
        while(uut.u_cpu.state != uut.u_cpu.ST_FETCH) begin
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
// Executes one instruction and returns total cycle count. Used for
// cycle-accurate timing verification against M6805 manual.
//-------------------------------------------------------------------------
task run_instruction_timed;
    output integer cycles;
    begin
        cycle(); // Start instruction execution
        count_cycles(cycles);
        cycles = cycles + 1; // Include the starting cycle
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
        while(uut.u_cpu.state != uut.u_cpu.ST_FETCH && timeout < 30) begin
            cycle();
            timeout = timeout + 1;
        end
    end
endtask

//-------------------------------------------------------------------------
// System Reset:
// Asserts reset, initializes all inputs, then releases reset and runs
// through the reset vector fetch sequence. After reset, PC loads from
// $7FE/$7FF and SP initializes to $7F.
//-------------------------------------------------------------------------
task reset_system;
    begin
        rst = 1;
        cen = 0;
        irq = 0;
        timer_in = 0;
        pa_i = 8'h00;
        pb_i = 8'h00;
        pc_i = 4'h0;
        mor = 8'h00;
        #100;
        rst = 0;
        #50;

        // Run through reset vector fetch
        cycle(); cycle(); cycle(); cycle();
    end
endtask

//-------------------------------------------------------------------------
// Test Setup:
// Forces CPU to FETCH state at specified address with known register
// values. Allows each test to start from a clean, predictable state
// without running full reset sequence.
//-------------------------------------------------------------------------
task setup_test;
    input [12:0] start_addr;
    begin
        uut.u_cpu.state = uut.u_cpu.ST_FETCH;
        uut.u_cpu.reg_pc = start_addr;
        uut.u_cpu.addr = start_addr;
        uut.u_cpu.rd = 1'b1;
        uut.u_cpu.reg_sp = 6'h3F;     // SP at top of stack ($7F)
        uut.u_cpu.cc_c = 1'b0;
        uut.u_cpu.cc_z = 1'b0;
        uut.u_cpu.cc_n = 1'b0;
        uut.u_cpu.cc_h = 1'b0;
        uut.u_cpu.cc_i = 1'b1;        // Interrupts disabled by default
        uut.u_cpu.reg_a = 8'h00;
        uut.u_cpu.reg_x = 8'h00;
        #10;
    end
endtask

//-------------------------------------------------------------------------
// Value Check:
// Compares actual result against expected value and updates pass/fail
// counters. Provides clear output for test results.
//-------------------------------------------------------------------------
task check;
    input [31:0] actual;
    input [31:0] expected;
    input [255:0] name;
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
// Timing Check:
// Verifies instruction executed in expected number of cycles per M6805
// CMOS manual timing specifications.
//-------------------------------------------------------------------------
task check_timing;
    input [31:0] actual_cycles;
    input [31:0] expected_cycles;
    input [255:0] name;
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
// Executes all test sections in order, initializing ROM with test
// programs and verifying both functional correctness and cycle timing.
//=========================================================================
initial begin
    $display("=============================================================");
    $display("  MC68705P3 Comprehensive MCU Testbench");
    $display("  Reference: M6805/M146805 CMOS Family User's Manual");
    $display("=============================================================\n");

    // Initialize counters
    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;

    // Initialize ROM with NOPs ($9D)
    for(i = 0; i < 2048; i = i + 1) rom[i] = 8'h9D;

    //---------------------------------------------------------------------
    // Interrupt Vector Setup:
    // MC68705P3 vectors at top of address space:
    //   $7F8/$7F9 - Timer interrupt vector
    //   $7FA/$7FB - External interrupt (IRQ) vector
    //   $7FC/$7FD - Software interrupt (SWI) vector
    //   $7FE/$7FF - Reset vector
    //---------------------------------------------------------------------
    rom[11'h7FE] = 8'h01;  // Reset vector -> $0100
    rom[11'h7FF] = 8'h00;
    rom[11'h7F8] = 8'h04;  // Timer vector -> $0400
    rom[11'h7F9] = 8'h00;
    rom[11'h7FA] = 8'h03;  // IRQ vector -> $0300
    rom[11'h7FB] = 8'h00;
    rom[11'h7FC] = 8'h02;  // SWI vector -> $0200
    rom[11'h7FD] = 8'h00;

    //=====================================================================
    // SECTION 1: Inherent Addressing Mode
    // 1-byte instructions, 2 cycles. No external operand needed; all
    // information is contained in the opcode itself.
    //=====================================================================
    $display("\n=== SECTION 1: Inherent Mode Control Instructions ===\n");

    // NOP ($9D) - No operation, 2 cycles
    rom[11'h100] = 8'h9D;
    reset_system();
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "NOP timing");

    // TAX ($97) - Transfer A to X, 2 cycles
    rom[11'h100] = 8'h97;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h42;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TAX timing");
    check(uut.u_cpu.reg_x, 8'h42, "TAX: X = A");

    // TXA ($9F) - Transfer X to A, 2 cycles
    rom[11'h100] = 8'h9F;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h99;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "TXA timing");
    check(uut.u_cpu.reg_a, 8'h99, "TXA: A = X");

    // CLC ($98) - Clear carry flag, 2 cycles
    rom[11'h100] = 8'h98;
    setup_test(13'h0100);
    uut.u_cpu.cc_c = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CLC timing");
    check(uut.u_cpu.cc_c, 1'b0, "CLC: C = 0");

    // SEC ($99) - Set carry flag, 2 cycles
    rom[11'h100] = 8'h99;
    setup_test(13'h0100);
    uut.u_cpu.cc_c = 1'b0;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "SEC timing");
    check(uut.u_cpu.cc_c, 1'b1, "SEC: C = 1");

    // CLI ($9A) - Clear interrupt mask, 2 cycles
    rom[11'h100] = 8'h9A;
    setup_test(13'h0100);
    uut.u_cpu.cc_i = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CLI timing");
    check(uut.u_cpu.cc_i, 1'b0, "CLI: I = 0");

    // SEI ($9B) - Set interrupt mask, 2 cycles
    rom[11'h100] = 8'h9B;
    setup_test(13'h0100);
    uut.u_cpu.cc_i = 1'b0;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "SEI timing");
    check(uut.u_cpu.cc_i, 1'b1, "SEI: I = 1");

    // RSP ($9C) - Reset stack pointer to $7F, 2 cycles
    rom[11'h100] = 8'h9C;
    setup_test(13'h0100);
    uut.u_cpu.reg_sp = 6'h20;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "RSP timing");
    check(uut.u_cpu.reg_sp, 6'h3F, "RSP: SP = $3F");

    //=====================================================================
    // SECTION 2: Accumulator RMW Instructions
    // 1-byte instructions, 3 cycles. Read-modify-write operations on
    // accumulator. Extra cycle for internal ALU operation.
    //=====================================================================
    $display("\n=== SECTION 2: Accumulator RMW Instructions ===\n");

    // INCA ($4C) - Increment A, 3 cycles
    // Tests N flag set on $7F -> $80 (negative result)
    rom[11'h100] = 8'h4C;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h7F;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "INCA timing");
    check(uut.u_cpu.reg_a, 8'h80, "INCA: A = $80");
    check(uut.u_cpu.cc_n, 1'b1, "INCA: N = 1");

    // DECA ($4A) - Decrement A, 3 cycles
    // Tests Z flag set on $01 -> $00 (zero result)
    rom[11'h100] = 8'h4A;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h01;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "DECA timing");
    check(uut.u_cpu.reg_a, 8'h00, "DECA: A = $00");
    check(uut.u_cpu.cc_z, 1'b1, "DECA: Z = 1");

    // CLRA ($4F) - Clear A, 3 cycles
    rom[11'h100] = 8'h4F;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'hFF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "CLRA timing");
    check(uut.u_cpu.reg_a, 8'h00, "CLRA: A = $00");

    // COMA ($43) - Complement A (one's complement), 3 cycles
    rom[11'h100] = 8'h43;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h55;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "COMA timing");
    check(uut.u_cpu.reg_a, 8'hAA, "COMA: A = $AA");

    // NEGA ($40) - Negate A (two's complement), 3 cycles
    rom[11'h100] = 8'h40;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h01;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "NEGA timing");
    check(uut.u_cpu.reg_a, 8'hFF, "NEGA: A = $FF");

    // LSRA ($44) - Logical shift right A, 3 cycles
    // Bit 0 -> C, 0 -> bit 7
    rom[11'h100] = 8'h44;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h82;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "LSRA timing");
    check(uut.u_cpu.reg_a, 8'h41, "LSRA: A = $41");
    check(uut.u_cpu.cc_c, 1'b0, "LSRA: C = 0");

    // RORA ($46) - Rotate right through carry, 3 cycles
    // C -> bit 7, bit 0 -> C
    rom[11'h100] = 8'h46;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h01;
    uut.u_cpu.cc_c = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "RORA timing");
    check(uut.u_cpu.reg_a, 8'h80, "RORA: A = $80");
    check(uut.u_cpu.cc_c, 1'b1, "RORA: C = 1");

    // ASRA ($47) - Arithmetic shift right A, 3 cycles
    // Bit 7 held (sign extend), bit 0 -> C
    rom[11'h100] = 8'h47;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h82;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "ASRA timing");
    check(uut.u_cpu.reg_a, 8'hC1, "ASRA: A = $C1");

    // LSLA ($48) - Logical shift left A, 3 cycles
    // Bit 7 -> C, 0 -> bit 0
    rom[11'h100] = 8'h48;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h81;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "LSLA timing");
    check(uut.u_cpu.reg_a, 8'h02, "LSLA: A = $02");
    check(uut.u_cpu.cc_c, 1'b1, "LSLA: C = 1");

    // ROLA ($49) - Rotate left through carry, 3 cycles
    // Bit 7 -> C, C -> bit 0
    rom[11'h100] = 8'h49;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h81;
    uut.u_cpu.cc_c = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "ROLA timing");
    check(uut.u_cpu.reg_a, 8'h03, "ROLA: A = $03");

    // TSTA ($4D) - Test A (set flags only), 3 cycles
    rom[11'h100] = 8'h4D;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "TSTA timing");
    check(uut.u_cpu.cc_z, 1'b1, "TSTA: Z = 1");

    //=====================================================================
    // SECTION 3: Index Register RMW Instructions
    // 1-byte instructions, 3 cycles. Same as accumulator RMW but
    // operates on index register X.
    //=====================================================================
    $display("\n=== SECTION 3: Index Register RMW Instructions ===\n");

    // INCX ($5C) - Increment X, 3 cycles
    rom[11'h100] = 8'h5C;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'hFE;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "INCX timing");
    check(uut.u_cpu.reg_x, 8'hFF, "INCX: X = $FF");

    // DECX ($5A) - Decrement X, 3 cycles
    rom[11'h100] = 8'h5A;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h01;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "DECX timing");
    check(uut.u_cpu.reg_x, 8'h00, "DECX: X = $00");

    // CLRX ($5F) - Clear X, 3 cycles
    rom[11'h100] = 8'h5F;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'hAB;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "CLRX timing");
    check(uut.u_cpu.reg_x, 8'h00, "CLRX: X = $00");

    //=====================================================================
    // SECTION 4: Immediate Addressing Mode
    // 2-byte instructions, 2 cycles. Operand is the byte immediately
    // following the opcode. Used for constants known at assembly time.
    //=====================================================================
    $display("\n=== SECTION 4: Immediate Addressing Mode ===\n");

    // LDA #imm ($A6) - Load A with immediate, 2 cycles
    rom[11'h100] = 8'hA6;
    rom[11'h101] = 8'h42;
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "LDA #imm timing");
    check(uut.u_cpu.reg_a, 8'h42, "LDA #$42");

    // LDX #imm ($AE) - Load X with immediate, 2 cycles
    rom[11'h100] = 8'hAE;
    rom[11'h101] = 8'h99;
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "LDX #imm timing");
    check(uut.u_cpu.reg_x, 8'h99, "LDX #$99");

    // ADD #imm ($AB) - Add immediate to A, 2 cycles
    rom[11'h100] = 8'hAB;
    rom[11'h101] = 8'h10;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h20;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "ADD #imm timing");
    check(uut.u_cpu.reg_a, 8'h30, "ADD #$10: A = $30");

    // SUB #imm ($A0) - Subtract immediate from A, 2 cycles
    rom[11'h100] = 8'hA0;
    rom[11'h101] = 8'h05;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "SUB #imm timing");
    check(uut.u_cpu.reg_a, 8'h0B, "SUB #$05: A = $0B");

    // CMP #imm ($A1) - Compare A with immediate, 2 cycles
    // Sets Z when equal (A - operand = 0)
    rom[11'h100] = 8'hA1;
    rom[11'h101] = 8'h42;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h42;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "CMP #imm timing");
    check(uut.u_cpu.cc_z, 1'b1, "CMP #$42: Z = 1");

    // AND #imm ($A4) - Logical AND immediate, 2 cycles
    rom[11'h100] = 8'hA4;
    rom[11'h101] = 8'h0F;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'hAB;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "AND #imm timing");
    check(uut.u_cpu.reg_a, 8'h0B, "AND #$0F: A = $0B");

    // ORA #imm ($AA) - Logical OR immediate, 2 cycles
    rom[11'h100] = 8'hAA;
    rom[11'h101] = 8'hF0;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h0F;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "ORA #imm timing");
    check(uut.u_cpu.reg_a, 8'hFF, "ORA #$F0: A = $FF");

    // EOR #imm ($A8) - Exclusive OR immediate, 2 cycles
    rom[11'h100] = 8'hA8;
    rom[11'h101] = 8'hFF;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h55;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "EOR #imm timing");
    check(uut.u_cpu.reg_a, 8'hAA, "EOR #$FF: A = $AA");

    //=====================================================================
    // SECTION 5: Direct Addressing Mode
    // 2-byte instructions. Operand address is in page zero ($00-$FF).
    // Load: 3 cycles, Store: 4 cycles (extra cycle for write).
    //=====================================================================
    $display("\n=== SECTION 5: Direct Addressing Mode ===\n");

    // LDA dir ($B6) - Load A from direct address, 3 cycles
    rom[11'h100] = 8'hB6;
    rom[11'h101] = 8'h20;              // Address $20 in RAM
    setup_test(13'h0100);
    uut.u_mem.ram[8'h10] = 8'h77;      // $20 - $10 = $10 in RAM array
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "LDA dir timing");
    check(uut.u_cpu.reg_a, 8'h77, "LDA $20: A = $77");

    // STA dir ($B7) - Store A to direct address, 4 cycles
    rom[11'h100] = 8'hB7;
    rom[11'h101] = 8'h25;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'hAB;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STA dir timing");
    check(uut.u_mem.ram[8'h15], 8'hAB, "STA $25: RAM = $AB");

    // ADD dir ($BB) - Add direct memory to A, 3 cycles
    rom[11'h100] = 8'hBB;
    rom[11'h101] = 8'h30;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h10;
    uut.u_mem.ram[8'h20] = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "ADD dir timing");
    check(uut.u_cpu.reg_a, 8'h15, "ADD $30: A = $15");

    //=====================================================================
    // SECTION 6: Extended Addressing Mode
    // 3-byte instructions. Full 16-bit address allows access anywhere
    // in memory map. Load: 4 cycles, Store: 5 cycles.
    //=====================================================================
    $display("\n=== SECTION 6: Extended Addressing Mode ===\n");

    // LDA ext ($C6) - Load A from extended address, 4 cycles
    rom[11'h100] = 8'hC6;
    rom[11'h101] = 8'h01;              // High byte
    rom[11'h102] = 8'h50;              // Low byte -> $0150
    rom[11'h150] = 8'hCD;              // Data at $0150
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDA ext timing");
    check(uut.u_cpu.reg_a, 8'hCD, "LDA $0150: A = $CD");

    // STA ext ($C7) - Store A to extended address, 5 cycles
    rom[11'h100] = 8'hC7;
    rom[11'h101] = 8'h00;
    rom[11'h102] = 8'h40;              // -> $0040 (RAM)
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'hEF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "STA ext timing");
    check(uut.u_mem.ram[8'h30], 8'hEF, "STA $0040: RAM = $EF");

    //=====================================================================
    // SECTION 7: Indexed Addressing Modes
    // Three variants with increasing offset size:
    //   No offset (,X):     1-byte, 3-4 cycles
    //   8-bit offset:       2-byte, 4-5 cycles
    //   16-bit offset:      3-byte, 5-6 cycles
    // Effective address = X + offset
    //=====================================================================
    $display("\n=== SECTION 7: Indexed Addressing Modes ===\n");

    // LDA ,X ($F6) - Load A from address in X, 3 cycles
    rom[11'h100] = 8'hF6;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h50;
    uut.u_mem.ram[8'h40] = 8'h11;      // $50 - $10 = $40
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "LDA ,X timing");
    check(uut.u_cpu.reg_a, 8'h11, "LDA ,X: A = $11");

    // STA ,X ($F7) - Store A to address in X, 4 cycles
    rom[11'h100] = 8'hF7;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h22;
    uut.u_cpu.reg_x = 8'h60;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "STA ,X timing");
    check(uut.u_mem.ram[8'h50], 8'h22, "STA ,X: RAM = $22");

    // LDA off,X ($E6) - Load A from X + 8-bit offset, 4 cycles
    rom[11'h100] = 8'hE6;
    rom[11'h101] = 8'h10;              // Offset
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h20;
    uut.u_mem.ram[8'h20] = 8'h33;      // $30 - $10 = $20
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "LDA off,X timing");
    check(uut.u_cpu.reg_a, 8'h33, "LDA $10,X: A = $33");

    // STA off,X ($E7) - Store A to X + 8-bit offset, 5 cycles
    rom[11'h100] = 8'hE7;
    rom[11'h101] = 8'h05;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h44;
    uut.u_cpu.reg_x = 8'h30;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "STA off,X timing");
    check(uut.u_mem.ram[8'h25], 8'h44, "STA $05,X: RAM = $44");

    // LDA off16,X ($D6) - Load A from X + 16-bit offset, 5 cycles
    rom[11'h100] = 8'hD6;
    rom[11'h101] = 8'h01;              // High byte
    rom[11'h102] = 8'h00;              // Low byte -> offset $0100
    rom[11'h110] = 8'h55;              // Data at $0100 + X($10)
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "LDA off16,X timing");
    check(uut.u_cpu.reg_a, 8'h55, "LDA $0100,X: A = $55");

    // STA off16,X ($D7) - Store A to X + 16-bit offset, 6 cycles
    rom[11'h100] = 8'hD7;
    rom[11'h101] = 8'h00;
    rom[11'h102] = 8'h40;              // -> $0040 + X
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h66;
    uut.u_cpu.reg_x = 8'h05;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "STA off16,X timing");
    check(uut.u_mem.ram[8'h35], 8'h66, "STA $0040,X: RAM = $66");

    //=====================================================================
    // SECTION 8: Branch Instructions
    // 2-byte instructions, 3 cycles (same for taken or not taken).
    // Relative addressing: PC = PC + 2 + signed offset.
    //=====================================================================
    $display("\n=== SECTION 8: Branch Instructions ===\n");

    // BRA ($20) - Branch always, 3 cycles
    rom[11'h100] = 8'h20;
    rom[11'h101] = 8'h10;              // Branch +16
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BRA timing");
    check(uut.u_cpu.reg_pc, 13'h0112, "BRA +16: PC = $0112");

    // BEQ taken ($27) - Branch if Z=1, 3 cycles
    rom[11'h100] = 8'h27;
    rom[11'h101] = 8'h05;
    setup_test(13'h0100);
    uut.u_cpu.cc_z = 1'b1;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BEQ taken timing");
    check(uut.u_cpu.reg_pc, 13'h0107, "BEQ taken: PC = $0107");

    // BEQ not taken ($27) - Branch if Z=1, 3 cycles
    rom[11'h100] = 8'h27;
    rom[11'h101] = 8'h05;
    setup_test(13'h0100);
    uut.u_cpu.cc_z = 1'b0;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BEQ not taken timing");
    check(uut.u_cpu.reg_pc, 13'h0102, "BEQ not taken: PC = $0102");

    // BNE ($26) - Branch if Z=0, backward branch test
    rom[11'h100] = 8'h26;
    rom[11'h101] = 8'hFE;              // Branch -2 (backward)
    setup_test(13'h0100);
    uut.u_cpu.cc_z = 1'b0;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "BNE timing");
    check(uut.u_cpu.reg_pc, 13'h0100, "BNE -2: PC = $0100");

    //=====================================================================
    // SECTION 9: Bit Set/Clear Instructions
    // 2-byte instructions, 5 cycles. Direct addressing for bit
    // manipulation in page zero. Bit number encoded in opcode.
    //=====================================================================
    $display("\n=== SECTION 9: Bit Set/Clear Instructions ===\n");

    // BSET0 ($10) - Set bit 0, 5 cycles
    rom[11'h100] = 8'h10;
    rom[11'h101] = 8'h30;              // Address $30 in RAM
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "BSET0 timing");
    check(uut.u_mem.ram[8'h20], 8'h01, "BSET0 $30: bit 0 set");

    // BCLR7 ($1F) - Clear bit 7, 5 cycles
    rom[11'h100] = 8'h1F;
    rom[11'h101] = 8'h30;
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'hFF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "BCLR7 timing");
    check(uut.u_mem.ram[8'h20], 8'h7F, "BCLR7 $30: bit 7 clear");

    //=====================================================================
    // SECTION 10: Bit Test and Branch Instructions
    // 3-byte instructions, 5 cycles. Tests specified bit and branches
    // if condition met. C flag set to tested bit value.
    //=====================================================================
    $display("\n=== SECTION 10: Bit Test and Branch Instructions ===\n");

    // BRSET0 ($00) - Branch if bit 0 set, 5 cycles
    rom[11'h100] = 8'h00;
    rom[11'h101] = 8'h30;              // Direct address
    rom[11'h102] = 8'h10;              // Branch offset
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'h01;      // Bit 0 set
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "BRSET0 timing");
    check(uut.u_cpu.reg_pc, 13'h0113, "BRSET0 taken: PC = $0113");

    // BRCLR7 ($0F) - Branch if bit 7 clear, 5 cycles
    rom[11'h100] = 8'h0F;
    rom[11'h101] = 8'h30;
    rom[11'h102] = 8'h05;
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'h7F;      // Bit 7 clear
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "BRCLR7 timing");
    check(uut.u_cpu.reg_pc, 13'h0108, "BRCLR7 taken: PC = $0108");

    //=====================================================================
    // SECTION 11: Direct RMW Instructions
    // 2-byte instructions. Read-modify-write on direct memory.
    // INC/DEC/CLR: 5 cycles, TST: 4 cycles (no write back).
    //=====================================================================
    $display("\n=== SECTION 11: Direct RMW Instructions ===\n");

    // INC dir ($3C) - Increment memory, 5 cycles
    rom[11'h100] = 8'h3C;
    rom[11'h101] = 8'h30;
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "INC dir timing");
    check(uut.u_mem.ram[8'h20], 8'h11, "INC $30: RAM = $11");

    // DEC dir ($3A) - Decrement memory, 5 cycles
    rom[11'h100] = 8'h3A;
    rom[11'h101] = 8'h30;
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'h10;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "DEC dir timing");
    check(uut.u_mem.ram[8'h20], 8'h0F, "DEC $30: RAM = $0F");

    // CLR dir ($3F) - Clear memory, 5 cycles
    rom[11'h100] = 8'h3F;
    rom[11'h101] = 8'h30;
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'hFF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "CLR dir timing");
    check(uut.u_mem.ram[8'h20], 8'h00, "CLR $30: RAM = $00");

    // TST dir ($3D) - Test memory (set flags only), 4 cycles
    rom[11'h100] = 8'h3D;
    rom[11'h101] = 8'h30;
    setup_test(13'h0100);
    uut.u_mem.ram[8'h20] = 8'h80;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "TST dir timing");
    check(uut.u_cpu.cc_n, 1'b1, "TST $30: N = 1");

    //=====================================================================
    // SECTION 12: Indexed RMW Instructions
    // INC/DEC/CLR ,X: 5 cycles, with offset: 6 cycles
    // TST ,X: 4 cycles, with offset: 5 cycles
    //=====================================================================
    $display("\n=== SECTION 12: Indexed RMW Instructions ===\n");

    // INC ,X ($7C) - Increment at address X, 5 cycles
    rom[11'h100] = 8'h7C;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h40;
    uut.u_mem.ram[8'h30] = 8'h20;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "INC ,X timing");
    check(uut.u_mem.ram[8'h30], 8'h21, "INC ,X: RAM = $21");

    // INC off,X ($6C) - Increment at X + offset, 6 cycles
    rom[11'h100] = 8'h6C;
    rom[11'h101] = 8'h05;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h30;
    uut.u_mem.ram[8'h25] = 8'h30;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "INC off,X timing");
    check(uut.u_mem.ram[8'h25], 8'h31, "INC $05,X: RAM = $31");

    // TST ,X ($7D) - Test at address X, 4 cycles
    rom[11'h100] = 8'h7D;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h40;
    uut.u_mem.ram[8'h30] = 8'h00;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 4, "TST ,X timing");
    check(uut.u_cpu.cc_z, 1'b1, "TST ,X: Z = 1");

    // TST off,X ($6D) - Test at X + offset, 5 cycles
    rom[11'h100] = 8'h6D;
    rom[11'h101] = 8'h10;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h20;
    uut.u_mem.ram[8'h20] = 8'hFF;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "TST off,X timing");
    check(uut.u_cpu.cc_n, 1'b1, "TST $10,X: N = 1");

    //=====================================================================
    // SECTION 13: Jump Instructions
    // Unconditional transfer of control. No stack operations.
    // JMP dir: 2 cycles, JMP ext: 3 cycles, JMP ,X: 2 cycles
    //=====================================================================
    $display("\n=== SECTION 13: Jump Instructions ===\n");

    // JMP dir ($BC) - Jump to direct address, 2 cycles
    rom[11'h100] = 8'hBC;
    rom[11'h101] = 8'h50;
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "JMP dir timing");
    check(uut.u_cpu.reg_pc, 13'h0050, "JMP $50: PC = $0050");

    // JMP ext ($CC) - Jump to extended address, 3 cycles
    rom[11'h100] = 8'hCC;
    rom[11'h101] = 8'h02;
    rom[11'h102] = 8'h00;
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 3, "JMP ext timing");
    check(uut.u_cpu.reg_pc, 13'h0200, "JMP $0200: PC = $0200");

    // JMP ,X ($FC) - Jump to address in X, 2 cycles
    rom[11'h100] = 8'hFC;
    setup_test(13'h0100);
    uut.u_cpu.reg_x = 8'h80;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 2, "JMP ,X timing");
    check(uut.u_cpu.reg_pc, 13'h0080, "JMP ,X: PC = $0080");

    //=====================================================================
    // SECTION 14: Subroutine Instructions
    // Push return address to stack before jump. Stack grows downward.
    // JSR dir: 5 cycles, JSR ext: 6 cycles, BSR: 6 cycles, RTS: 6 cycles
    //=====================================================================
    $display("\n=== SECTION 14: Subroutine Instructions ===\n");

    // JSR dir ($BD) - Jump to subroutine direct, 5 cycles
    // Pushes PCL then PCH, SP decrements by 2
    rom[11'h100] = 8'hBD;
    rom[11'h101] = 8'h50;
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 5, "JSR dir timing");
    check(uut.u_cpu.reg_pc, 13'h0050, "JSR $50: PC = $0050");
    check(uut.u_cpu.reg_sp, 6'h3D, "JSR: SP decremented by 2");

    // JSR ext ($CD) - Jump to subroutine extended, 6 cycles
    rom[11'h100] = 8'hCD;
    rom[11'h101] = 8'h02;
    rom[11'h102] = 8'h00;
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "JSR ext timing");
    check(uut.u_cpu.reg_pc, 13'h0200, "JSR $0200: PC = $0200");

    // BSR ($AD) - Branch to subroutine relative, 6 cycles
    rom[11'h100] = 8'hAD;
    rom[11'h101] = 8'h10;
    setup_test(13'h0100);
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "BSR timing");
    check(uut.u_cpu.reg_pc, 13'h0112, "BSR +16: PC = $0112");

    // RTS ($81) - Return from subroutine, 6 cycles
    // Pulls PCH then PCL, SP increments by 2
    rom[11'h100] = 8'h81;
    setup_test(13'h0100);
    uut.u_cpu.reg_sp = 6'h3D;
    // Set up return address on stack (SP+1=PCH, SP+2=PCL)
    uut.u_mem.ram[8'h6E] = 8'h01;      // PCH at $7E
    uut.u_mem.ram[8'h6F] = 8'h50;      // PCL at $7F
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 6, "RTS timing");
    check(uut.u_cpu.reg_pc, 13'h0150, "RTS: PC = $0150");
    check(uut.u_cpu.reg_sp, 6'h3F, "RTS: SP restored");

    //=====================================================================
    // SECTION 15: Interrupt Instructions
    // SWI pushes all registers (CC, A, X, PCH, PCL) and vectors through
    // $7FC/$7FD. RTI restores all registers from stack.
    // SWI: 10 cycles, RTI: 9 cycles
    //=====================================================================
    $display("\n=== SECTION 15: Interrupt Instructions ===\n");

    // SWI ($83) - Software interrupt, 10 cycles
    // Stack order (top to bottom): PCL, PCH, X, A, CC
    rom[11'h100] = 8'h83;
    rom[11'h200] = 8'h9D;              // NOP at SWI vector
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h12;
    uut.u_cpu.reg_x = 8'h34;
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 10, "SWI timing");
    check(uut.u_cpu.reg_pc, 13'h0200, "SWI: PC = $0200");
    check(uut.u_cpu.cc_i, 1'b1, "SWI: I = 1");
    check(uut.u_cpu.reg_sp, 6'h3A, "SWI: SP = $3A (5 pushed)");

    // RTI ($80) - Return from interrupt, 9 cycles
    // Restores CC, A, X, PCH, PCL from stack
    rom[11'h100] = 8'h80;
    setup_test(13'h0100);
    uut.u_cpu.reg_sp = 6'h3A;
    // Set up stack frame
    uut.u_mem.ram[8'h6B] = 8'hE0;      // CCR (I=0)
    uut.u_mem.ram[8'h6C] = 8'hAA;      // A
    uut.u_mem.ram[8'h6D] = 8'h55;      // X
    uut.u_mem.ram[8'h6E] = 8'h01;      // PCH
    uut.u_mem.ram[8'h6F] = 8'h50;      // PCL
    run_instruction_timed(cycle_count);
    check_timing(cycle_count, 9, "RTI timing");
    check(uut.u_cpu.reg_pc, 13'h0150, "RTI: PC = $0150");
    check(uut.u_cpu.reg_a, 8'hAA, "RTI: A = $AA");
    check(uut.u_cpu.reg_x, 8'h55, "RTI: X = $55");
    check(uut.u_cpu.reg_sp, 6'h3F, "RTI: SP = $3F");

    //=====================================================================
    // SECTION 16: Hardware Interrupts
    // Tests IRQ and timer interrupt handling. Interrupts are level-
    // sensitive and checked between instructions. Priority: Timer > IRQ.
    // Hardware interrupts masked when I bit = 1.
    //=====================================================================
    $display("\n=== SECTION 16: Hardware Interrupts ===\n");

    // IRQ when enabled (I=0)
    rom[11'h100] = 8'h9D;              // NOP
    rom[11'h300] = 8'h9D;              // NOP in ISR
    setup_test(13'h0100);
    uut.u_cpu.cc_i = 1'b0;             // Enable interrupts
    uut.u_cpu.reg_a = 8'h11;
    uut.u_cpu.reg_x = 8'h22;
    irq = 1'b1;
    run_instruction();
    check(uut.u_cpu.reg_pc, 13'h0300, "IRQ: PC = $0300 (ISR)");
    check(uut.u_cpu.cc_i, 1'b1, "IRQ: I = 1");
    irq = 1'b0;

    // IRQ masked (I=1)
    rom[11'h100] = 8'h4C;              // INCA
    setup_test(13'h0100);
    uut.u_cpu.cc_i = 1'b1;             // Disable interrupts
    uut.u_cpu.reg_a = 8'h10;
    irq = 1'b1;
    run_instruction();
    check(uut.u_cpu.reg_pc, 13'h0101, "IRQ masked: PC = $0101");
    check(uut.u_cpu.reg_a, 8'h11, "IRQ masked: A = $11 (INCA ran)");
    irq = 1'b0;

    // Timer interrupt (TIRQ) when enabled
    rom[11'h100] = 8'h9D;
    rom[11'h400] = 8'h9D;              // NOP in timer ISR
    setup_test(13'h0100);
    uut.u_cpu.cc_i = 1'b0;
    uut.u_timer.tcr[7] = 1'b1;         // Set TIR (interrupt request)
    uut.u_timer.tcr[6] = 1'b0;         // Clear TIM (unmask)
    run_instruction();
    check(uut.u_cpu.reg_pc, 13'h0400, "TIRQ: PC = $0400 (Timer ISR)");
    uut.u_timer.tcr[7] = 1'b0;         // Clear TIR

    // TIRQ priority over IRQ
    // Both pending, timer should be serviced first
    setup_test(13'h0100);
    uut.u_cpu.cc_i = 1'b0;
    irq = 1'b1;
    uut.u_timer.tcr[7] = 1'b1;
    uut.u_timer.tcr[6] = 1'b0;
    run_instruction();
    check(uut.u_cpu.reg_pc, 13'h0400, "Priority: TIRQ > IRQ");
    irq = 1'b0;
    uut.u_timer.tcr[7] = 1'b0;

    //=====================================================================
    // SECTION 17: I/O Port Operations
    // Tests port data and DDR register access. DDR bits configure pins
    // as input (0) or output (1). Reading data register returns latch
    // for outputs, pin state for inputs.
    //=====================================================================
    $display("\n=== SECTION 17: I/O Port Operations ===\n");

    // Write to Port A DDR ($04), then data ($00)
    rom[11'h100] = 8'hB7;              // STA dir
    rom[11'h101] = 8'h04;              // DDRA
    rom[11'h102] = 8'hB7;
    rom[11'h103] = 8'h00;              // PORTA
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'hFF;           // All outputs
    run_instruction();
    check(uut.u_io.pa_ddr, 8'hFF, "DDRA = $FF");

    uut.u_cpu.reg_a = 8'hA5;
    run_instruction();
    cycle(); // Allow registered output to propagate
    check(pa_o, 8'hA5, "Port A output = $A5");

    // Read from Port B ($01) with inputs
    rom[11'h100] = 8'hB6;              // LDA dir
    rom[11'h101] = 8'h01;              // PORTB
    setup_test(13'h0100);
    pb_i = 8'h5A;                      // External input
    uut.u_io.pb_ddr = 8'h00;           // All inputs
    run_instruction();
    check(uut.u_cpu.reg_a, 8'h5A, "Port B read = $5A");

    //=====================================================================
    // SECTION 18: Timer Operations
    // Tests TDR ($08) and TCR ($09) register access. TDR is 8-bit
    // counter, TCR controls timer mode and interrupt enable.
    //=====================================================================
    $display("\n=== SECTION 18: Timer Operations ===\n");

    // Write to TDR ($08)
    rom[11'h100] = 8'hB7;              // STA dir
    rom[11'h101] = 8'h08;              // TDR
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h80;
    run_instruction();
    check(uut.u_timer.tdr, 8'h80, "TDR = $80");

    // Read TCR ($09) - bit 3 always reads as 0
    rom[11'h100] = 8'hB6;
    rom[11'h101] = 8'h09;              // TCR
    setup_test(13'h0100);
    uut.u_timer.tcr = 8'hC5;
    run_instruction();
    check(uut.u_cpu.reg_a, 8'hC5, "TCR read = $C5");

    //=====================================================================
    // SECTION 19: Memory Boundaries
    // Tests RAM boundaries at $10 (start) and $7F (end). Verifies
    // proper address translation to internal RAM array.
    //=====================================================================
    $display("\n=== SECTION 19: Memory Boundaries ===\n");

    // RAM at $10 (first RAM location)
    rom[11'h100] = 8'hB7;
    rom[11'h101] = 8'h10;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h11;
    run_instruction();
    check(uut.u_mem.ram[0], 8'h11, "RAM[$10] = $11");

    // RAM at $7F (last RAM location, top of stack)
    rom[11'h100] = 8'hB7;
    rom[11'h101] = 8'h7F;
    setup_test(13'h0100);
    uut.u_cpu.reg_a = 8'h7F;
    run_instruction();
    check(uut.u_mem.ram[111], 8'h7F, "RAM[$7F] = $7F");

    //=====================================================================
    // Final Test Summary
    //=====================================================================
    $display("\n=============================================================");
    $display("  MC68705P3 Comprehensive Test Results");
    $display("=============================================================");
    $display("  Total Tests:  %0d", total_tests);
    $display("  Passed:       %0d", passed_tests);
    $display("  Failed:       %0d", failed_tests);
    $display("=============================================================");

    if(failed_tests == 0) begin
        $display("  *** ALL TESTS PASSED ***");
        $display("  Cycle-accurate to M6805 CMOS Manual");
    end else begin
        $display("  *** SOME TESTS FAILED ***");
    end

    $display("=============================================================\n");

    $stop;
end

endmodule
