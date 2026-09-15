-------------------------------------------------------------------------------
-- reg_if.vhd
-- Simple memory-mapped register interface: CTRL, STATUS, TX_DATA, RX_DATA.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_if is
    port (
        clk       : in  std_logic;
        rst_n     : in  std_logic;

        -- simple bus interface
        addr      : in  std_logic_vector(3 downto 0);
        wr_en     : in  std_logic;
        rd_en     : in  std_logic;
        wdata     : in  std_logic_vector(31 downto 0);
        rdata     : out std_logic_vector(31 downto 0);

        -- CTRL fields out to datapath
        uart_en    : out std_logic;
        word_len   : out unsigned(2 downto 0);
        parity_en  : out std_logic;
        parity_odd : out std_logic;
        baud_div   : out unsigned(15 downto 0);

        -- STATUS fields in from datapath
        tx_full    : in  std_logic;
        rx_empty   : in  std_logic;
        frame_err  : in  std_logic;
        parity_err : in  std_logic;
        overrun    : in  std_logic;

        -- TX/RX data ports
        tx_data_wr : out std_logic_vector(7 downto 0);
        tx_wr_en   : out std_logic;
        rx_data_rd : in  std_logic_vector(7 downto 0);
        rx_rd_en   : out std_logic
    );
end entity reg_if;

architecture rtl of reg_if is
    constant ADDR_CTRL    : std_logic_vector(3 downto 0) := x"0";
    constant ADDR_STATUS  : std_logic_vector(3 downto 0) := x"4";
    constant ADDR_TX_DATA : std_logic_vector(3 downto 0) := x"8";
    constant ADDR_RX_DATA : std_logic_vector(3 downto 0) := x"C";

    signal ctrl_reg : std_logic_vector(31 downto 0) := (others => '0');
begin

    -- TODO: decode addr on wr_en/rd_en, drive tx_wr_en/rx_rd_en pulses,
    -- mux rdata from ctrl_reg / status bits / rx_data_rd based on addr.

    uart_en    <= ctrl_reg(0);
    parity_en  <= ctrl_reg(1);
    parity_odd <= ctrl_reg(2);
    word_len   <= unsigned(ctrl_reg(5 downto 3));
    baud_div   <= unsigned(ctrl_reg(31 downto 16));

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            ctrl_reg <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' and addr = ADDR_CTRL then
                ctrl_reg <= wdata;
            end if;
        end if;
    end process;

end architecture rtl;
