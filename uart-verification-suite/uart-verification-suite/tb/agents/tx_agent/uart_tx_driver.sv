//-----------------------------------------------------------------------------
// uart_tx_driver.sv
// Drives register writes (TX_DATA) via reg_if to request byte transmission.
//-----------------------------------------------------------------------------
class uart_tx_driver extends uvm_driver #(uart_tx_item);

  `uvm_component_utils(uart_tx_driver)

  virtual uart_reg_if vif;  // register bus interface

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_reg_if)::get(this, "", "reg_vif", vif))
      `uvm_fatal("NOVIF", "reg_vif not set for uart_tx_driver")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      uart_tx_item item;
      seq_item_port.get_next_item(item);

      // TODO: drive reg bus: write item.data to TX_DATA register,
      // poll STATUS.tx_full if inject_fifo_pressure, etc.
      `uvm_info("TX_DRV", $sformatf("Driving byte: 0x%0h", item.data), UVM_MEDIUM)

      seq_item_port.item_done();
    end
  endtask

endclass : uart_tx_driver
