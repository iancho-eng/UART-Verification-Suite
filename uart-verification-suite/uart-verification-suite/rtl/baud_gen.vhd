-------------------------------------------------------------------------------
-- baud_gen.vhd
-- Programmable baud rate generator. Divides the system clock down to a
-- configurable tick rate (typically 16x oversampled) used by uart_tx/uart_rx.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is
    generic (
        DIVISOR_WIDTH : integer := 16
    );
    port (
        clk       : in  std_logic;
        rst_n     : in  std_logic;
        divisor   : in  unsigned(DIVISOR_WIDTH-1 downto 0);  -- from CTRL register
        baud_tick : out std_logic                            -- 1-cycle pulse at 16x baud rate
    );
end entity baud_gen;

architecture rtl of baud_gen is
    signal counter : unsigned(DIVISOR_WIDTH-1 downto 0) := (others => '0');
begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            counter   <= (others => '0');
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if counter = divisor then
                counter   <= (others => '0');
                baud_tick <= '1';
            else
                counter   <= counter + 1;
                baud_tick <= '0';
            end if;
        end if;
    end process;

end architecture rtl;
