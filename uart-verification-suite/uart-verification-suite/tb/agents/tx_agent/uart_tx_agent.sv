//-----------------------------------------------------------------------------
// uart_tx_agent.sv
// Standard UVM agent: sequencer + driver + monitor for the TX side.
//-----------------------------------------------------------------------------
class uart_tx_agent extends uvm_agent;

  `uvm_component_utils(uart_tx_agent)

  uvm_sequencer #(uart_tx_item) sequencer;
  uart_tx_driver                driver;
  uart_tx_monitor               monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = uart_tx_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sequencer = uvm_sequencer#(uart_tx_item)::type_id::create("sequencer", this);
      driver    = uart_tx_driver::type_id::create("driver", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : uart_tx_agent
