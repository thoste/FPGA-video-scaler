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


entity syntest_multiport_ram is
   port(
      clk_i         : in  std_logic;
      sink_o        : out std_logic
   );
end entity syntest_multiport_ram;

architecture rtl of syntest_multiport_ram is
   signal source : std_logic_vector(104 downto 0) := (others => '0');
   signal sink   : std_logic_vector(95 downto 0) := (others => '0');

begin

   i_mut : entity work.multiport_ram
   generic map(
      g_ram_width    => 24,
      g_ram_depth    => 15360,
      g_ramstyle     => "M20K",
      g_output_reg   => true
   )
   port map(
      clk_i          => clk_i,
      wr_en_i        => source(0),
      data_i         => source(24 downto 1),
      wr_addr_i      => to_integer(unsigned(source(40 downto 25))),
      rd_addr_a_i    => to_integer(unsigned(source(56 downto 41))),
      rd_addr_b_i    => to_integer(unsigned(source(72 downto 57))),
      rd_addr_c_i    => to_integer(unsigned(source(88 downto 73))),
      rd_addr_d_i    => to_integer(unsigned(source(104 downto 89))),
      data_a_o       => sink(23 downto 0),
      data_b_o       => sink(47 downto 24),
      data_c_o       => sink(71 downto 48),
      data_d_o       => sink(95 downto 72)
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
