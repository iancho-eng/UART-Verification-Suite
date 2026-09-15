-------------------------------------------------------------------------------
-- uart_tx.vhd
-- Parallel-to-serial UART transmitter. Pulls bytes from the TX FIFO and
-- shifts out start/data/parity/stop framing at the configured baud rate.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        baud_tick   : in  std_logic;                      -- 16x oversampled tick
        word_len    : in  unsigned(2 downto 0);            -- 5..8 bits
        parity_en   : in  std_logic;
        parity_odd  : in  std_logic;

        -- FIFO interface
        fifo_data   : in  std_logic_vector(7 downto 0);
        fifo_empty  : in  std_logic;
        fifo_rd_en  : out std_logic;

        -- serial line
        tx_out      : out std_logic;
        tx_busy     : out std_logic
    );
end entity uart_tx;

architecture rtl of uart_tx is
    type state_t is (IDLE, START, DATA, PARITY, STOP);
    signal state      : state_t := IDLE;
    signal bit_index  : unsigned(2 downto 0) := (others => '0');
    signal shift_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal tick_count : unsigned(3 downto 0) := (others => '0');
    signal parity_bit : std_logic := '0';
begin

    tx_busy <= '0' when state = IDLE else '1';

    -- TODO: implement 16x-oversampled state machine:
    --   IDLE   -> drive tx_out high, wait for !fifo_empty, pop byte, load shift_reg
    --   START  -> drive tx_out low for one bit period
    --   DATA   -> shift out word_len bits LSB-first
    --   PARITY -> drive computed parity bit if parity_en
    --   STOP   -> drive tx_out high for stop bit(s), return to IDLE
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state     <= IDLE;
            tx_out    <= '1';
            fifo_rd_en <= '0';
        elsif rising_edge(clk) then
            -- state machine body TBD
            null;
        end if;
    end process;

end architecture rtl;
