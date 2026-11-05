# Timing constraints for the CAPCOM DL-0921 (CPS-B-21) netlist.
# Read from capcom_dl0921.qip. The core SDC sets capcom_dl0921_cen_div and is read before this file.

# ===================================================================================================
# Clock enable ratio
# ===================================================================================================
# capcom_dl0921_cen_div is the fewest system clocks between two enables. The registers load on CEN,
# the chip's 16 MHz clock rising, and on CEN_F, the same clock falling, so it is the gap between a CEN
# and the next CEN_F (3 at 96 MHz). Without it no path is relaxed and a critical warning is posted. At 1
# every window stays single cycle.
# ===================================================================================================
if {![info exists capcom_dl0921_cen_div]} {
    post_message -type critical_warning "capcom_dl0921_cen_div is not set, capcom_dl0921 paths are not relaxed"
    set capcom_dl0921_cen_div 1
}

set capcom_dl0921_cen_su [expr {max(1, $capcom_dl0921_cen_div)}]
set capcom_dl0921_cen_ho [expr {$capcom_dl0921_cen_su - 1}]

# ===================================================================================================
# Chip clock multicycle (enable-paced)
# ===================================================================================================
# Every capcom_dl0921 register loads only on CEN or CEN_F.
#
# Relax to a capcom_dl0921_cen_div-cycle window.
# ===================================================================================================
set capcom_dl0921_cen_regs [get_keepers -nowarn {*capcom_dl0921:*|*}]

set_multicycle_path -setup -end $capcom_dl0921_cen_su \
                    -from $capcom_dl0921_cen_regs -to $capcom_dl0921_cen_regs
set_multicycle_path -hold  -end $capcom_dl0921_cen_ho \
                    -from $capcom_dl0921_cen_regs -to $capcom_dl0921_cen_regs
