//-----------------------------------------------------------------------------
// uart_rx_monitor.sv
// Watches register reads (RX_DATA, STATUS) and publishes captured bytes
// plus error flags to the scoreboard via an analysis port.
//-----------------------------------------------------------------------------
class uart_rx_monitor extends uvm_monitor;

  `uvm_component_utils(uart_rx_monitor)

  virtual uart_reg_if vif;
  uvm_analysis_port #(uart_rx_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_reg_if)::get(this, "", "reg_vif", vif))
      `uvm_fatal("NOVIF", "reg_vif not set for uart_rx_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      uart_rx_item item = uart_rx_item::type_id::create("item");
      // TODO: poll STATUS.rx_empty, read RX_DATA when data available,
      // capture STATUS.frame_err/parity_err/overrun alongside the byte,
      // and broadcast via ap.write(item).
      @(posedge vif.clk);  // placeholder
      ap.write(item);
    end
  endtask

endclass : uart_rx_monitor
