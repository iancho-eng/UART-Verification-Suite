#-------------------------------------------------------------------------------
# compile.tcl
# Compiles RTL (VHDL) and testbench (SystemVerilog/UVM) sources using
# xvhdl/xvlog ahead of simulation. Assumes create_project.tcl has been run.
#-------------------------------------------------------------------------------

open_project "./build/uart_verification_suite/uart_verification_suite.xpr"

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "INFO: Compiling RTL (xvhdl) and testbench (xvlog) sources..."
launch_simulation -scripts_only
puts "INFO: Compile scripts generated under build/uart_verification_suite/uart_verification_suite.sim/"
