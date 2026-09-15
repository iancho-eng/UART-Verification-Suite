//-----------------------------------------------------------------------------
// uart_sequences.sv
// Sequence library driving the TX agent (register-side stimulus).
// See docs/verification_plan.md section 5 for the full intent of each.
//-----------------------------------------------------------------------------

class basic_loopback_seq extends uvm_sequence #(uart_tx_item);
  `uvm_object_utils(basic_loopback_seq)
  function new(string name = "basic_loopback_seq"); super.new(name); endfunction

  task body();
    uart_tx_item item = uart_tx_item::type_id::create("item");
    start_item(item);
    assert(item.randomize() with { inject_fifo_pressure == 0; });
    finish_item(item);
  endtask
endclass : basic_loopback_seq


class random_word_seq extends uvm_sequence #(uart_tx_item);
  `uvm_object_utils(random_word_seq)
  rand int unsigned num_bytes = 50;
  function new(string name = "random_word_seq"); super.new(name); endfunction

  task body();
    repeat (num_bytes) begin
      uart_tx_item item = uart_tx_item::type_id::create("item");
      start_item(item);
      assert(item.randomize());
      finish_item(item);
    end
  endtask
endclass : random_word_seq


class parity_error_seq extends uvm_sequence #(uart_rx_item);
  `uvm_object_utils(parity_error_seq)
  function new(string name = "parity_error_seq"); super.new(name); endfunction

  task body();
    uart_rx_item item = uart_rx_item::type_id::create("item");
    start_item(item);
    assert(item.randomize() with {
      inject_parity_error == 1;
      inject_frame_error  == 0;
    });
    finish_item(item);
  endtask
endclass : parity_error_seq


class frame_error_seq extends uvm_sequence #(uart_rx_item);
  `uvm_object_utils(frame_error_seq)
  function new(string name = "frame_error_seq"); super.new(name); endfunction

  task body();
    uart_rx_item item = uart_rx_item::type_id::create("item");
    start_item(item);
    assert(item.randomize() with {
      inject_frame_error  == 1;
      inject_parity_error == 0;
    });
    finish_item(item);
  endtask
endclass : frame_error_seq


class fifo_overrun_seq extends uvm_sequence #(uart_tx_item);
  `uvm_object_utils(fifo_overrun_seq)
  function new(string name = "fifo_overrun_seq"); super.new(name); endfunction

  task body();
    // Push bytes faster than the DUT can drain the TX FIFO to force overrun.
    repeat (32) begin
      uart_tx_item item = uart_tx_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with { inject_fifo_pressure == 1; });
      finish_item(item);
    end
  endtask
endclass : fifo_overrun_seq


class back_to_back_seq extends uvm_sequence #(uart_tx_item);
  `uvm_object_utils(back_to_back_seq)
  rand int unsigned num_bytes = 20;
  function new(string name = "back_to_back_seq"); super.new(name); endfunction

  task body();
    // TODO: drive bytes with zero idle gap between stop bit and next start bit.
    repeat (num_bytes) begin
      uart_tx_item item = uart_tx_item::type_id::create("item");
      start_item(item);
      assert(item.randomize());
      finish_item(item);
    end
  endtask
endclass : back_to_back_seq
