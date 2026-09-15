#-------------------------------------------------------------------------------
# sim.tcl
# Elaborates and runs a single UVM test.
# Usage: vivado -mode batch -source scripts/sim.tcl -tclargs <test_name> [seed]
#-------------------------------------------------------------------------------

set test_name [lindex $argv 0]
set seed      [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

if {$test_name eq ""} {
    puts "ERROR: no test name given. Usage: sim.tcl <test_name> [seed]"
    exit 1
}

open_project "./build/uart_verification_suite/uart_verification_suite.xpr"

set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.uvm_version} -value {2.0} -objects [get_filesets sim_1]

launch_simulation

# Pass +UVM_TESTNAME and seed into the simulation
run -all
puts "INFO: Ran test '${test_name}' with seed ${seed}"

close_sim
