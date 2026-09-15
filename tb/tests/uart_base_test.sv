//-----------------------------------------------------------------------------
// uart_base_test.sv
// Base test: builds the environment. Concrete tests extend this and start
// a specific sequence in run_phase, selected via +UVM_TESTNAME on the
// command line (see scripts/sim.tcl).
//-----------------------------------------------------------------------------
class uart_base_test extends uvm_test;

  `uvm_component_utils(uart_base_test)

  uart_env env;

  function new(string name = "uart_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = uart_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

endclass : uart_base_test


class basic_loopback_test extends uart_base_test;
  `uvm_component_utils(basic_loopback_test)
  function new(string name = "basic_loopback_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    basic_loopback_seq seq = basic_loopback_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.tx_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass : basic_loopback_test


class random_word_test extends uart_base_test;
  `uvm_component_utils(random_word_test)
  function new(string name = "random_word_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    random_word_seq seq = random_word_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.tx_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass : random_word_test

// Additional tests (parity_error_test, frame_error_test, fifo_overrun_test,
// back_to_back_test) follow the same pattern — instantiate the matching
// sequence from tb/seq/uart_sequences.sv and start it on the right agent.
