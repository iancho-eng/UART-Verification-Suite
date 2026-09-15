//-----------------------------------------------------------------------------
// uart_scoreboard.sv
// Compares TX-side reference model output against RX-side captured data.
// Receives transactions from both monitors via TLM analysis exports.
//-----------------------------------------------------------------------------
class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard)

  uvm_tlm_analysis_fifo #(uart_tx_item) tx_fifo;
  uvm_tlm_analysis_fifo #(uart_rx_item) rx_fifo;

  int unsigned match_count = 0;
  int unsigned mismatch_count = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    tx_fifo = new("tx_fifo", this);
    rx_fifo = new("rx_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    uart_tx_item tx_item;
    uart_rx_item rx_item;
    forever begin
      tx_fifo.get(tx_item);
      rx_fifo.get(rx_item);

      if (tx_item.data === rx_item.data) begin
        match_count++;
        `uvm_info("SB", $sformatf("MATCH: 0x%0h", tx_item.data), UVM_HIGH)
      end else begin
        mismatch_count++;
        `uvm_error("SB", $sformatf("MISMATCH: expected 0x%0h, got 0x%0h",
                                    tx_item.data, rx_item.data))
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info("SB", $sformatf("Scoreboard summary: %0d match, %0d mismatch",
                               match_count, mismatch_count), UVM_LOW)
  endfunction

endclass : uart_scoreboard
