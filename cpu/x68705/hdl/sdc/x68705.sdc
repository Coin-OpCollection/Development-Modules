# Timing constraints for the x68705 MC68705P3/P5 microcomputer.
# Read from x68705.qip. The core SDC sets x68705_cen_div and is read before this file.

# ===================================================================================================
# Clock enable ratio
# ===================================================================================================
# x68705_cen_div is the fewest system clocks between two cen pulses, one machine cycle. The CPU, the
# port latches and the RAM relax to that window. Without it no path is relaxed and a critical warning
# is posted. At 1 (cen on every clock) every window stays single cycle.
# ===================================================================================================
if {![info exists x68705_cen_div]} {
    post_message -type critical_warning "x68705_cen_div is not set, x68705 paths are not relaxed"
    set x68705_cen_div 1
}

set x68705_cen_su [expr {max(1, $x68705_cen_div)}]
set x68705_cen_ho [expr {$x68705_cen_su - 1}]

# ===================================================================================================
# Machine-cycle multicycle (cen-paced)
# ===================================================================================================
# The CPU registers and state machine, the port data latches and data direction registers and the RAM
# load only on a cen pulse; the RAM read register follows the CPU address, which changes only on cen.
# The external interrupt latch, the timer (its prescaler, counter and TIMER edge detector), the port
# pin registers and the MOR latch load on any system clock and keep their single-cycle check.
#
# Relax to an x68705_cen_div-cycle window.
# ===================================================================================================
set x68705_cen_regs [get_keepers -nowarn {*x68705:*|x6805:u_cpu|* \
                                          *x68705:*|x68705_io:u_io|*_latch* \
                                          *x68705:*|x68705_io:u_io|*_ddr* \
                                          *x68705:*|x68705_mem:u_mem|*}]
set x68705_clk_regs [get_keepers -nowarn {*x68705:*|x6805:u_cpu|irq_prev* \
                                          *x68705:*|x6805:u_cpu|irq_latch*}]
set x68705_cen_regs [remove_from_collection $x68705_cen_regs $x68705_clk_regs]

set_multicycle_path -setup -end $x68705_cen_su -from $x68705_cen_regs -to $x68705_cen_regs
set_multicycle_path -hold  -end $x68705_cen_ho -from $x68705_cen_regs -to $x68705_cen_regs
