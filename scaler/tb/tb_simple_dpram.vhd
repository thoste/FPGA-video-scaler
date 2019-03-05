library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_simple_dpram is
end tb_simple_dpram;

architecture tb_simple_dpram_arc of tb_simple_dpram is
   -- Component declaration
   component simple_dpram
      port (
      clk_i       : in std_logic;
      sreset_i    : in std_logic;
      -- To RAM
      data_i      : in std_logic_vector(7 downto 0);
      wr_addr_i   : in std_logic_vector(5 downto 0);
      wr_en_i     : in std_logic;
      -- From RAM
      q_o         : out std_logic_vector(7 downto 0);
      rd_addr_i   : in std_logic_vector(5 downto 0)
      );
   end component;

   signal clk_i      : std_logic := '0';
   signal sreset_i   : std_logic := '0';
   signal data_i     : std_logic_vector(7 downto 0);
   signal wr_addr_i  : std_logic_vector(5 downto 0);
   signal wr_en_i    : std_logic := '0';
   signal rd_addr_i  : std_logic_vector(5 downto 0);
   signal q_o        : std_logic_vector(7 downto 0);

   constant clk_period : time := 10 ns;

begin
   DUT: simple_dpram_sclk
      port map(
         clk_i => clk_i,
         sreset_i => sreset_i,
         data_i => data_i,
         wr_addr_i => wr_addr_i,
         wr_en_i => wr_en_i,
         rd_addr_i => rd_addr_i,
         q_o => q_o
      );
      
   clk_i <= not clk_i after clk_period/2;
   wr_en_i <= '1' after 100 ns;


   process(clk_i)
      variable counter_v : integer := 0;
      variable writeaddr : natural := 0;
      variable readaddr  : natural := 20;
   begin
      if rising_edge(clk_i) then
         data_i <= std_logic_vector(to_unsigned(counter_v, data_i'length));
         wr_addr_i <= std_logic_vector(to_unsigned(writeaddr, wr_addr_i'length));
         rd_addr_i <= std_logic_vector(to_unsigned(readaddr, rd_addr_i'length));

         counter_v := counter_v + 1;
         if (writeaddr < 62) then
            writeaddr := writeaddr + 1;
         else
            writeaddr := 0;
         end if;

         if (readaddr < 62) then
            readaddr := readaddr + 1;
         else
            readaddr := 0;
         end if;
      end if;
   end process;


   process
   begin
      wait for 5000 ns;
      stop;
   end process;


end tb_simple_dpram_arc;