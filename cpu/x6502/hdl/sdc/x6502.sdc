# Timing constraints for the x6502 MOS Technology 6502 CPU.
# Read from x6502.qip. The core SDC sets x6502_cen_div and is read before this file.

# ===================================================================================================
# Clock enable ratio
# ===================================================================================================
# x6502_cen_div is the fewest system clocks between two enables. With HALF_CYCLE = 0 that is the gap
# between two cen pulses, one bus cycle; with HALF_CYCLE = 1 registers also load on cen_p2, so it is
# the gap between a cen and the next cen_p2. A core with several 6502s gives the fastest. Without it
# no path is relaxed and a critical warning is posted. At 1 every window stays single cycle.
# ===================================================================================================
if {![info exists x6502_cen_div]} {
    post_message -type critical_warning "x6502_cen_div is not set, x6502 paths are not relaxed"
    set x6502_cen_div 1
}

set x6502_cen_su [expr {max(1, $x6502_cen_div)}]
set x6502_cen_ho [expr {$x6502_cen_su - 1}]

# ===================================================================================================
# Bus cycle multicycle (enable-paced)
# ===================================================================================================
# Every x6502 register loads only on cen, or on cen_p2 with HALF_CYCLE = 1. RES, RDY, IRQ and NMI are
# sampled at cen, and SO at cen or cen_p2, so no register loads on every system clock.
#
# Relax to an x6502_cen_div-cycle window.
# ===================================================================================================
set x6502_cen_regs [get_keepers -nowarn {*x6502:*|*}]

set_multicycle_path -setup -end $x6502_cen_su -from $x6502_cen_regs -to $x6502_cen_regs
set_multicycle_path -hold  -end $x6502_cen_ho -from $x6502_cen_regs -to $x6502_cen_regs
