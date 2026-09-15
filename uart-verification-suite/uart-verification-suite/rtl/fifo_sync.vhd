-------------------------------------------------------------------------------
-- fifo_sync.vhd
-- Generic synchronous FIFO, reused for both the TX and RX paths.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_sync is
    generic (
        DATA_WIDTH : integer := 8;
        DEPTH      : integer := 16  -- must be a power of 2
    );
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;

        wr_en   : in  std_logic;
        wr_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        full    : out std_logic;

        rd_en   : in  std_logic;
        rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        empty   : out std_logic;

        overrun : out std_logic  -- pulses if wr_en asserted while full
    );
end entity fifo_sync;

architecture rtl of fifo_sync is
    constant ADDR_WIDTH : integer := integer(ceil(log2(real(DEPTH))));

    type mem_t is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : mem_t := (others => (others => '0'));

    signal wr_ptr, rd_ptr : unsigned(ADDR_WIDTH downto 0) := (others => '0');
begin

    full  <= '1' when (wr_ptr(ADDR_WIDTH) /= rd_ptr(ADDR_WIDTH)) and
                       (wr_ptr(ADDR_WIDTH-1 downto 0) = rd_ptr(ADDR_WIDTH-1 downto 0)) else '0';
    empty <= '1' when wr_ptr = rd_ptr else '0';

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            wr_ptr  <= (others => '0');
            rd_ptr  <= (others => '0');
            overrun <= '0';
        elsif rising_edge(clk) then
            overrun <= '0';

            if wr_en = '1' then
                if full = '1' then
                    overrun <= '1';  -- drop write, flag overrun
                else
                    mem(to_integer(wr_ptr(ADDR_WIDTH-1 downto 0))) <= wr_data;
                    wr_ptr <= wr_ptr + 1;
                end if;
            end if;

            if rd_en = '1' and empty = '0' then
                rd_ptr <= rd_ptr + 1;
            end if;
        end if;
    end process;

    rd_data <= mem(to_integer(rd_ptr(ADDR_WIDTH-1 downto 0)));

end architecture rtl;
