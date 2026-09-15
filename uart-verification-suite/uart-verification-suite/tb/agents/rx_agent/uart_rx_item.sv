//-----------------------------------------------------------------------------
// uart_rx_item.sv
// Transaction: serial-line stimulus driven into the DUT's RX pin, with
// optional error injection.
//-----------------------------------------------------------------------------
class uart_rx_item extends uvm_sequence_item;

  rand bit [7:0] data;
  rand bit       inject_parity_error;
  rand bit       inject_frame_error;

  `uvm_object_utils_begin(uart_rx_item)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(inject_parity_error, UVM_ALL_ON)
    `uvm_field_int(inject_frame_error, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "uart_rx_item");
    super.new(name);
  endfunction

endclass : uart_rx_item
