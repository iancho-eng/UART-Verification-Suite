# UART Verification Suite

A register-mapped UART transceiver designed in **VHDL** and verified with a **UVM** testbench, built as a mixed-language digital verification (DV) flow. The full simulate → regress → report loop is automated with **Tcl** and **Perl**, running on **Linux**, and closed out with **FPGA synthesis and hardware bring-up in Vivado**.

This project mirrors a standard ASIC/FPGA design-and-verification workflow: a DUT, a class-based UVM environment, scripted regression automation, and a real hardware bring-up step at the end.

![Status](https://img.shields.io/badge/status-in--progress-yellow)
![VHDL](https://img.shields.io/badge/RTL-VHDL-blue)
![UVM](https://img.shields.io/badge/Verification-UVM%2FSystemVerilog-purple)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## Overview

The DUT is a UART transceiver with configurable baud rate, parity, and word length, backed by synchronous TX/RX FIFOs and a memory-mapped register interface. The UVM environment drives register writes and serial-line stimulus, checks TX/RX data integrity with a scoreboard, and collects functional coverage across word length, parity mode, baud rate, and FIFO fill level.

Because UVM is SystemVerilog-native and the DUT is VHDL, the testbench runs as a **mixed-language simulation**.

```
 ┌─────────────┐        ┌────────────────────┐
 │  UVM Env    │◄──────►│   UART DUT (VHDL)   │
 │ (SystemVerilog)      │  baud_gen / tx / rx │
 │  driver/monitor/     │  fifo_sync / reg_if │
 │  scoreboard/coverage │                     │
 └─────────────┘        └────────────────────┘
        │ logs
        ▼
 ┌─────────────┐   parses   ┌──────────────────┐
 │ Tcl scripts │──────────► │ Perl log parsers  │
 │ build/sim/  │            │ → CSV/HTML report │
 │ regress     │            └──────────────────┘
        │
        ▼
 ┌─────────────┐
 │   Vivado    │  synth → bitstream → FPGA board
 └─────────────┘
```

## Features Under Verification

- Reset behavior and register default states
- Basic loopback at matched baud rate
- Baud rate mismatch tolerance
- Parity error injection and detection
- Frame error injection and detection
- FIFO full / empty / overrun conditions
- Back-to-back byte streaming
- Register read/write correctness (`CTRL`, `STATUS`, `TX_DATA`, `RX_DATA`)

See [`docs/verification_plan.md`](docs/verification_plan.md) for the full plan and coverage model.

## Repository Structure

```
uart-verification-suite/
├── rtl/                  # VHDL DUT
│   ├── baud_gen.vhd
│   ├── uart_tx.vhd
│   ├── uart_rx.vhd
│   ├── fifo_sync.vhd
│   ├── reg_if.vhd
│   └── uart_top.vhd
├── tb/                   # UVM testbench (SystemVerilog)
│   ├── agents/
│   │   ├── tx_agent/
│   │   └── rx_agent/
│   ├── env/
│   ├── seq/
│   └── tests/
├── scripts/              # Tcl build/sim/regression automation
│   ├── create_project.tcl
│   ├── compile.tcl
│   ├── sim.tcl
│   ├── synth.tcl
│   └── regress.tcl
├── perl/                 # Regression log parsing & reporting
│   ├── parse_log.pl
│   └── gen_report.pl
├── docs/
│   └── verification_plan.md
├── results/              # Regression logs & reports (gitignored)
├── Makefile
└── README.md
```

## Getting Started

### Prerequisites

- [Vivado](https://www.xilinx.com/support/download.html) (Design Edition or WebPACK) — synthesis, XSIM
- A UVM-capable simulator — Vivado XSIM (basic UVM support) or Questa/ModelSim Intel FPGA Edition (recommended for full UVM factory/macro support)
- Perl 5 (ships with most Linux distros)
- An FPGA dev board for hardware bring-up (Basys3, Arty A7, or similar) — optional, for the final step

### Build & Run

```bash
# Build the Vivado project from the RTL/TB filelists
make build

# Run a single UVM test
make sim TEST=basic_loopback_seq

# Run the full regression across the test list and seeds
make regress

# Generate the pass/fail HTML report from regression logs
make report

# Synthesize and generate a bitstream (once verified)
make synth
```

## Regression Reporting

`regress.tcl` sweeps the test list and seed list, dumping one structured log per run to `results/`. `perl/gen_report.pl` aggregates those logs into a single CSV and an HTML summary table showing pass/fail status and per-test coverage.

## Hardware Bring-Up

Once the UVM regression passes clean, the design is synthesized in Vivado and programmed onto an FPGA board for a real UART loopback test (TX jumpered to RX, or validated over a USB-UART bridge from Linux) — closing the loop from RTL design to working hardware.

## Roadmap

- [x] Define verification plan and coverage model
- [ ] VHDL DUT: baud generator, TX/RX datapath, sync FIFO, register interface
- [ ] UVM environment: agents, scoreboard, coverage model
- [ ] Sequence library (loopback, random word, parity/frame error, FIFO overrun, back-to-back)
- [ ] Tcl build/sim/regression automation
- [ ] Perl log parsing and HTML reporting
- [ ] FPGA synthesis and hardware bring-up
- [ ] Stretch: SPI mode on the same IP, SVA protocol assertions, CI-driven regression

## License

MIT — see [LICENSE](LICENSE).
