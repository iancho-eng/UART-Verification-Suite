-------------------------------------------------------------------------------
-- uart_rx.vhd
-- Serial-to-parallel UART receiver. Oversamples the incoming line at 16x
-- baud, reconstructs bytes, checks parity/framing, and pushes into RX FIFO.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        baud_tick   : in  std_logic;
        word_len    : in  unsigned(2 downto 0);
        parity_en   : in  std_logic;
        parity_odd  : in  std_logic;

        rx_in       : in  std_logic;

        -- FIFO interface
        fifo_data   : out std_logic_vector(7 downto 0);
        fifo_wr_en  : out std_logic;
        fifo_full   : in  std_logic;

        -- status flags
        frame_err   : out std_logic;
        parity_err  : out std_logic;
        overrun     : out std_logic
    );
end entity uart_rx;

architecture rtl of uart_rx is
    type state_t is (IDLE, START, DATA, PARITY, STOP);
    signal state     : state_t := IDLE;
    signal bit_index : unsigned(2 downto 0) := (others => '0');
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
begin

    -- TODO: implement mid-bit sampling state machine:
    --   IDLE   -> detect falling edge on rx_in (start bit)
    --   START  -> confirm start bit at mid-bit sample point
    --   DATA   -> sample word_len bits at mid-bit points, shift into shift_reg
    --   PARITY -> sample and compare against computed parity -> parity_err
    --   STOP   -> check stop bit(s) -> frame_err; push to FIFO or set overrun
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state      <= IDLE;
            fifo_wr_en <= '0';
            frame_err  <= '0';
            parity_err <= '0';
            overrun    <= '0';
        elsif rising_edge(clk) then
            -- state machine body TBD
            null;
        end if;
    end process;

end architecture rtl;
