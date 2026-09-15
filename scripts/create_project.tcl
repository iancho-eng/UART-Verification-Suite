#-------------------------------------------------------------------------------
# create_project.tcl
# Builds the Vivado project from the RTL and testbench filelists.
# Usage: vivado -mode batch -source scripts/create_project.tcl
#-------------------------------------------------------------------------------

set proj_name   "uart_verification_suite"
set proj_dir    "./build/${proj_name}"
set part        "xc7a35tcpg236-1"   ;# Basys3 by default; override for other boards

file mkdir $proj_dir
create_project $proj_name $proj_dir -part $part -force

# RTL sources (VHDL)
set rtl_files [list \
    "./rtl/baud_gen.vhd" \
    "./rtl/uart_tx.vhd" \
    "./rtl/uart_rx.vhd" \
    "./rtl/fifo_sync.vhd" \
    "./rtl/reg_if.vhd" \
    "./rtl/uart_top.vhd" \
]
add_files -norecurse $rtl_files
set_property file_type {VHDL 2008} [get_files *.vhd]

# Testbench sources (SystemVerilog / UVM)
set tb_files [list \
    "./tb/agents/tx_agent/uart_tx_item.sv" \
    "./tb/agents/tx_agent/uart_tx_driver.sv" \
    "./tb/agents/tx_agent/uart_tx_monitor.sv" \
    "./tb/agents/tx_agent/uart_tx_agent.sv" \
    "./tb/agents/rx_agent/uart_rx_item.sv" \
    "./tb/agents/rx_agent/uart_rx_driver.sv" \
    "./tb/agents/rx_agent/uart_rx_monitor.sv" \
    "./tb/agents/rx_agent/uart_rx_agent.sv" \
    "./tb/env/uart_scoreboard.sv" \
    "./tb/env/uart_coverage.sv" \
    "./tb/env/uart_env.sv" \
    "./tb/seq/uart_sequences.sv" \
    "./tb/tests/uart_base_test.sv" \
]
add_files -fileset sim_1 -norecurse $tb_files
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sim_1] *.sv]

puts "INFO: Project '${proj_name}' created at ${proj_dir} (part: ${part})"
