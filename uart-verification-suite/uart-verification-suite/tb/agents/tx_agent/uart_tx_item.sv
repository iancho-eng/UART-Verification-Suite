//-----------------------------------------------------------------------------
// uart_tx_item.sv
// Transaction: a register-level write requesting the DUT transmit one byte.
//-----------------------------------------------------------------------------
class uart_tx_item extends uvm_sequence_item;

  rand bit [7:0] data;
  rand bit       inject_fifo_pressure;  // back-to-back stress mode

  `uvm_object_utils_begin(uart_tx_item)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(inject_fifo_pressure, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "uart_tx_item");
    super.new(name);
  endfunction

endclass : uart_tx_item
