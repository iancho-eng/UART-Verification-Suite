//-----------------------------------------------------------------------------
// uart_rx_agent.sv
// Standard UVM agent: sequencer + driver + monitor for the RX side.
//-----------------------------------------------------------------------------
class uart_rx_agent extends uvm_agent;

  `uvm_component_utils(uart_rx_agent)

  uvm_sequencer #(uart_rx_item) sequencer;
  uart_rx_driver                driver;
  uart_rx_monitor               monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = uart_rx_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sequencer = uvm_sequencer#(uart_rx_item)::type_id::create("sequencer", this);
      driver    = uart_rx_driver::type_id::create("driver", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : uart_rx_agent
