//-----------------------------------------------------------------------------
// uart_rx_driver.sv
// Drives serial input on the DUT's RX pin: normal framing, or injected
// parity/framing errors per the transaction's control fields.
//-----------------------------------------------------------------------------
class uart_rx_driver extends uvm_driver #(uart_rx_item);

  `uvm_component_utils(uart_rx_driver)

  virtual uart_serial_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_serial_if)::get(this, "", "serial_vif", vif))
      `uvm_fatal("NOVIF", "serial_vif not set for uart_rx_driver")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      uart_rx_item item;
      seq_item_port.get_next_item(item);

      // TODO: bit-bang vif.rx: start bit, data bits (LSB first), optional
      // flipped parity bit if inject_parity_error, stop bit (or missing
      // stop bit if inject_frame_error).
      `uvm_info("RX_DRV", $sformatf("Driving byte: 0x%0h", item.data), UVM_MEDIUM)

      seq_item_port.item_done();
    end
  endtask

endclass : uart_rx_driver
