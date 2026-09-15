#-------------------------------------------------------------------------------
# synth.tcl
# Synthesis + implementation + bitstream generation. Run once the UVM
# regression is clean.
# Usage: vivado -mode batch -source scripts/synth.tcl
#-------------------------------------------------------------------------------

open_project "./build/uart_verification_suite/uart_verification_suite.xpr"

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

set bitstream "./build/uart_verification_suite/uart_verification_suite.runs/impl_1/uart_top.bit"
puts "INFO: Bitstream generated at ${bitstream}"
puts "INFO: Program the board with: program_hw_devices [current_hw_device] -file ${bitstream}"
