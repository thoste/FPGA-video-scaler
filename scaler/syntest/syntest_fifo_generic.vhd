------------------------------------------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-04-03
-- Version: 0.1
------------------------------------------------------------------------------------------
-- Description:
------------------------------------------------------------------------------------------
-- v0.1:
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity syntest_fifo_generic is
   port(
      clk_i         : in  std_logic;
      sink_o        : out std_logic
   );
end entity syntest_fifo_generic;

architecture rtl of syntest_fifo_generic is
   signal source : std_logic_vector(88 downto 0) := (others => '0');
   signal sink   : std_logic_vector(87 downto 0) := (others => '0');

begin

   i_mut : entity work.fifo_generic
   generic map(
      g_width        => 86,
      g_depth        => 512,
      g_ramstyle     => "M20K",
      g_output_reg   => true
   )
   port map(
      clk_i       => clk_i,
      sreset_i    => source(0),
      wr_en_i     => source(1),
      rd_en_i     => source(2),
		data_i      => source(88 downto 3),
      full_o      => sink(0),
      empty_o     => sink(1),
		data_o      => sink(87 downto 2)
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
