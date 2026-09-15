//-----------------------------------------------------------------------------
// uart_tx_monitor.sv
// Watches the serial TX line, decodes start/data/parity/stop framing, and
// publishes decoded bytes to the scoreboard via an analysis port.
//-----------------------------------------------------------------------------
class uart_tx_monitor extends uvm_monitor;

  `uvm_component_utils(uart_tx_monitor)

  virtual uart_serial_if vif;
  uvm_analysis_port #(uart_tx_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_serial_if)::get(this, "", "serial_vif", vif))
      `uvm_fatal("NOVIF", "serial_vif not set for uart_tx_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      uart_tx_item item = uart_tx_item::type_id::create("item");
      // TODO: sample vif.tx at 16x oversampling, decode start/data/parity/stop,
      // populate item.data, and broadcast via ap.write(item).
      @(negedge vif.tx);  // placeholder: wait for start bit
      ap.write(item);
    end
  endtask

endclass : uart_tx_monitor
