//-----------------------------------------------------------------------------
// uart_env.sv
// Top-level UVM environment: TX agent, RX agent, scoreboard, coverage.
//-----------------------------------------------------------------------------
class uart_env extends uvm_env;

  `uvm_component_utils(uart_env)

  uart_tx_agent   tx_agent;
  uart_rx_agent   rx_agent;
  uart_scoreboard scoreboard;
  uart_coverage   coverage;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tx_agent   = uart_tx_agent::type_id::create("tx_agent", this);
    rx_agent   = uart_rx_agent::type_id::create("rx_agent", this);
    scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
    coverage   = uart_coverage::type_id::create("coverage", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    tx_agent.monitor.ap.connect(scoreboard.tx_fifo.analysis_export);
    rx_agent.monitor.ap.connect(scoreboard.rx_fifo.analysis_export);
    rx_agent.monitor.ap.connect(coverage.analysis_export);
  endfunction

endclass : uart_env
