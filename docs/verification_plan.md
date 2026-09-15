# UART Verification Plan

## 1. DUT Summary

A register-mapped UART transceiver with configurable baud rate, word length, and parity, backed by synchronous TX/RX FIFOs.

**Registers**

| Register  | Access | Description                                              |
|-----------|--------|------------------------------------------------------------|
| `CTRL`    | R/W    | Enable, parity mode, word length, baud divisor              |
| `STATUS`  | R      | `tx_full`, `rx_empty`, `frame_err`, `parity_err`, `overrun` |
| `TX_DATA` | W      | Byte to transmit (pushes into TX FIFO)                      |
| `RX_DATA` | R      | Received byte (pops from RX FIFO)                            |

## 2. Features to Verify

- Reset behavior and register default values
- Basic loopback at matched baud rate
- Baud rate mismatch tolerance (within spec)
- Parity error injection and detection
- Frame error injection and detection
- FIFO full / empty / overrun conditions
- Back-to-back byte streaming (no gaps between frames)
- Register read/write correctness and side effects (e.g., `TX_DATA` write when FIFO full)

## 3. Coverage Model

**Primary coverpoints**

- Word length: 5, 6, 7, 8 bits
- Parity mode: none, even, odd
- Baud rate: slow / nominal / fast (relative to reference clock)
- FIFO fill level: empty, partial, full

**Cross-coverage**

- Error type (parity / frame / overrun) × FIFO state
- Word length × parity mode

## 4. Checking Strategy

- **Scoreboard**: compares the TX-side reference model output against RX-side captured data, bit-for-bit at the serial level and byte-for-byte at the register level.
- **Reference model**: a simple behavioral model (SystemVerilog class) that mirrors expected TX framing (start bit, data bits, parity bit, stop bit) given the current `CTRL` configuration.
- **Error injection**: the RX driver can flip parity bits, drop/insert stop bits, or delay bytes past FIFO depth to intentionally trigger `parity_err`, `frame_err`, and `overrun`.

## 5. Sequence Library

| Sequence               | Purpose                                             |
|-------------------------|------------------------------------------------------|
| `basic_loopback_seq`    | Sanity: single byte, matched baud, no errors         |
| `random_word_seq`       | Randomized word length/parity/baud, many bytes       |
| `parity_error_seq`      | Injects parity errors, checks `STATUS.parity_err`    |
| `frame_error_seq`       | Injects framing errors, checks `STATUS.frame_err`    |
| `fifo_overrun_seq`      | Fills FIFO past capacity, checks `STATUS.overrun`    |
| `back_to_back_seq`      | Streams bytes with no idle gaps between frames       |

## 6. Simulator Notes

UVM is SystemVerilog-native; the DUT is VHDL, so the environment runs as a mixed-language simulation.

- **Vivado XSIM**: supports VHDL + SystemVerilog/UVM mixed simulation, but has known limitations with some UVM factory/macro features depending on version.
- **Questa / ModelSim Intel FPGA Edition** (free with Quartus Prime): more complete UVM support; fallback if XSIM hits limitations.

Recommendation: compile a trivial DUT + empty UVM test in both before committing to one.

## 7. Exit Criteria

- All sequences in the sequence library pass with zero `UVM_ERROR`/`UVM_FATAL` across at least 10 random seeds each.
- Coverage model closes at ≥ 95% (primary coverpoints and cross-coverage).
- Design synthesizes cleanly in Vivado and passes a real hardware loopback test.
