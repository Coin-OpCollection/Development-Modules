# Timing constraints for the x6280 Hudson HuC6280 CPU.
# Read from x6280.qip. The core SDC sets x6280_cen_div and is read before this file.

# ===================================================================================================
# Clock enable ratio
# ===================================================================================================
# x6280_cen_div is the fewest system clocks between two cen pulses of the x6280 (the OSC1 / 3 enable,
# one CPU cycle at high speed). A core with several HuC6280s gives the fastest. Without it no path is
# relaxed and a critical warning is posted. At 1 every window stays single cycle.
# ===================================================================================================
if {![info exists x6280_cen_div]} {
    post_message -type critical_warning "x6280_cen_div is not set, x6280 paths are not relaxed"
    set x6280_cen_div 1
}

set x6280_cen_su [expr {max(1, $x6280_cen_div)}]
set x6280_cen_ho [expr {$x6280_cen_su - 1}]
set x6280_per_su [expr {max(1, $x6280_cen_div - 1)}]
set x6280_per_ho [expr {$x6280_per_su - 1}]

set x6280_cpu_regs [get_keepers -nowarn {*x6280_cpu:*|*}]
set x6280_csl_cnt  [get_keepers -nowarn {*x6280:*|csl_cnt[*]}]
set x6280_per_regs [get_keepers -nowarn {*x6280_int:*|* *x6280_timer:*|* *x6280_mem:*|*}]
set x6280_bus_dst  [get_keepers -nowarn {*x6280_int:*|* *x6280_timer:*|* *x6280_mem:*|* *x6280_io:*|* \
                                         *x6280_psg:*|*}]

# ===================================================================================================
# CPU multicycle (enable-paced)
# ===================================================================================================
# Every x6280_cpu register loads only on the CPU enable, which passes at most one cen in each window
# (CSH every cen, CSL one in four). The low-speed counter loads on cen and only gates that enable.
#
# Relax to an x6280_cen_div-cycle window.
# ===================================================================================================
set_multicycle_path -setup -end $x6280_cen_su -from $x6280_cpu_regs -to $x6280_cpu_regs
set_multicycle_path -hold  -end $x6280_cen_ho -from $x6280_cpu_regs -to $x6280_cpu_regs
set_multicycle_path -setup -end $x6280_cen_su -from $x6280_csl_cnt  -to $x6280_cpu_regs
set_multicycle_path -hold  -end $x6280_cen_ho -from $x6280_csl_cnt  -to $x6280_cpu_regs

# ===================================================================================================
# CPU bus writes to the on-chip blocks (enable-paced)
# ===================================================================================================
# The interrupt, timer, I/O, IO_BUF and PSG registers take CPU data only at the enable that ends a
# CPU bus cycle (cer / we from bus_ce); the CPU registers they read change only on the CPU enable.
#
# Relax to an x6280_cen_div-cycle window.
# ===================================================================================================
set_multicycle_path -setup -end $x6280_cen_su -from $x6280_cpu_regs -to $x6280_bus_dst
set_multicycle_path -hold  -end $x6280_cen_ho -from $x6280_cpu_regs -to $x6280_bus_dst

# ===================================================================================================
# On-chip read data and interrupt requests into the CPU (enable-paced)
# ===================================================================================================
# IO_BUF, the interrupt mask and the timer counter change only on an enable; the timer request also
# clears one clock after a write to the request register. The CPU takes them through its read data
# and its interrupt poll only on the CPU enable.
#
# Relax to an (x6280_cen_div - 1)-cycle window.
# ===================================================================================================
set_multicycle_path -setup -end $x6280_per_su -from $x6280_per_regs -to $x6280_cpu_regs
set_multicycle_path -hold  -end $x6280_per_ho -from $x6280_per_regs -to $x6280_cpu_regs
