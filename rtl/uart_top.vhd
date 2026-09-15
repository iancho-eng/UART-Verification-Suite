-------------------------------------------------------------------------------
-- uart_top.vhd
-- Top-level UART transceiver: wires baud_gen, uart_tx, uart_rx, fifo_sync
-- (x2), and reg_if together behind a simple memory-mapped bus.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;

        -- register bus
        addr    : in  std_logic_vector(3 downto 0);
        wr_en   : in  std_logic;
        rd_en   : in  std_logic;
        wdata   : in  std_logic_vector(31 downto 0);
        rdata   : out std_logic_vector(31 downto 0);

        -- serial pins
        tx      : out std_logic;
        rx      : in  std_logic
    );
end entity uart_top;

architecture structural of uart_top is

    component baud_gen is
        generic (DIVISOR_WIDTH : integer := 16);
        port (
            clk       : in  std_logic;
            rst_n     : in  std_logic;
            divisor   : in  unsigned(DIVISOR_WIDTH-1 downto 0);
            baud_tick : out std_logic
        );
    end component;

    component fifo_sync is
        generic (DATA_WIDTH : integer := 8; DEPTH : integer := 16);
        port (
            clk     : in  std_logic;
            rst_n   : in  std_logic;
            wr_en   : in  std_logic;
            wr_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            full    : out std_logic;
            rd_en   : in  std_logic;
            rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
            empty   : out std_logic;
            overrun : out std_logic
        );
    end component;

    -- uart_tx / uart_rx / reg_if component declarations omitted for brevity —
    -- see rtl/uart_tx.vhd, rtl/uart_rx.vhd, rtl/reg_if.vhd for their ports.

    signal baud_tick_i               : std_logic;
    signal baud_div_i                : unsigned(15 downto 0);
    signal word_len_i                : unsigned(2 downto 0);
    signal parity_en_i, parity_odd_i : std_logic;

    signal tx_fifo_wr, tx_fifo_rd    : std_logic;
    signal tx_fifo_full, tx_fifo_empty : std_logic;
    signal tx_fifo_din, tx_fifo_dout : std_logic_vector(7 downto 0);
    signal tx_fifo_overrun           : std_logic;

    signal rx_fifo_wr, rx_fifo_rd    : std_logic;
    signal rx_fifo_full, rx_fifo_empty : std_logic;
    signal rx_fifo_din, rx_fifo_dout : std_logic_vector(7 downto 0);
    signal rx_fifo_overrun           : std_logic;

    signal frame_err_i, parity_err_i : std_logic;

begin

    u_baud_gen : baud_gen
        port map (
            clk       => clk,
            rst_n     => rst_n,
            divisor   => baud_div_i,
            baud_tick => baud_tick_i
        );

    u_tx_fifo : fifo_sync
        generic map (DATA_WIDTH => 8, DEPTH => 16)
        port map (
            clk => clk, rst_n => rst_n,
            wr_en => tx_fifo_wr, wr_data => tx_fifo_din, full => tx_fifo_full,
            rd_en => tx_fifo_rd, rd_data => tx_fifo_dout, empty => tx_fifo_empty,
            overrun => tx_fifo_overrun
        );

    u_rx_fifo : fifo_sync
        generic map (DATA_WIDTH => 8, DEPTH => 16)
        port map (
            clk => clk, rst_n => rst_n,
            wr_en => rx_fifo_wr, wr_data => rx_fifo_din, full => rx_fifo_full,
            rd_en => rx_fifo_rd, rd_data => rx_fifo_dout, empty => rx_fifo_empty,
            overrun => rx_fifo_overrun
        );

    -- TODO: instantiate uart_tx, uart_rx, and reg_if, and wire them to the
    -- FIFOs above and to the tx/rx serial pins and register bus ports.

end architecture structural;
