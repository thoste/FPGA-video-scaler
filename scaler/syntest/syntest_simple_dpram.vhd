------------------------------------------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-03-11
-- Version: 0.1
------------------------------------------------------------------------------------------
-- Description:
------------------------------------------------------------------------------------------
-- v0.1:
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity syntest_simple_dpram is
   port(
      clk_i         : in  std_logic;
      sink_o        : out std_logic
   );
end entity syntest_simple_dpram;

architecture rtl of syntest_simple_dpram is
   signal source : std_logic_vector(52 downto 0) := (others => '0');
   signal sink   : std_logic_vector(19  downto 0) := (others => '0');

begin

   i_mut : entity work.simple_dpram
   generic map(
      g_ram_width => 20,
      g_ram_depth => 200
   )
   port map(
      clk_i       => clk_i,
      wr_en_i     => source(0),
      data_i      => source(20 downto 1),
      wr_addr_i   => to_integer(unsigned(source(36 downto 21))),
      rd_addr_i   => to_integer(unsigned(source(52 downto 37))),
      data_o      => sink(19 downto 0)
   );

   i_source : entity work.atv_dummy_source
   generic map (
      g_ports   => source'length
   )
   port map (
      clk_i     => clk_i,
      outputs_o => source
   );

   i_sink : entity work.atv_dummy_sink
   generic map (
      g_ports  => sink'length
   )
   port map (
      clk_i    => clk_i,
      inputs_i => sink,
      output_o => sink_o
   );

end architecture;
