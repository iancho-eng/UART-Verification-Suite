//-----------------------------------------------------------------------------
// uart_coverage.sv
// Functional coverage: word length x parity mode x baud rate x FIFO fill
// level, plus cross-coverage on (error type x FIFO state).
//-----------------------------------------------------------------------------
class uart_coverage extends uvm_subscriber #(uart_rx_item);

  `uvm_component_utils(uart_coverage)

  uart_rx_item item;

  covergroup cg_uart;
    option.per_instance = 1;

    cp_word_len : coverpoint item.data[2:0] {  // placeholder field mapping
      bins len_5 = {5};
      bins len_6 = {6};
      bins len_7 = {7};
      bins len_8 = {8};
    }

    cp_error : coverpoint {item.inject_parity_error, item.inject_frame_error} {
      bins no_error     = {2'b00};
      bins parity_error = {2'b10};
      bins frame_error  = {2'b01};
    }

    // TODO: add cp_parity_mode, cp_baud_rate, cp_fifo_level coverpoints,
    // plus cross-coverage: cross cp_error, cp_fifo_level;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_uart = new();
  endfunction

  function void write(uart_rx_item t);
    item = t;
    cg_uart.sample();
  endfunction

endclass : uart_coverage
