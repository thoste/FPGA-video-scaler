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


entity syntest_scaler_bilinear is
   port(
      clk_i         : in  std_logic;
      sink_o        : out std_logic
   );
end entity syntest_scaler_bilinear;

architecture rtl of syntest_scaler_bilinear is
   signal source : std_logic_vector(28 downto 0) := (others => '0');
   signal sink   : std_logic_vector(27 downto 0) := (others => '0');

begin

   i_mut : entity work.scaler
   generic map(
      g_data_width         => 24, 
      g_rx_video_width     => 1920,
      g_rx_video_height    => 1080,
      g_tx_video_width     => 3840,
      g_tx_video_height    => 2160
   )
   port map(
      clk_i             => clk_i,
      sreset_i          => source(0),

      scaler_valid_i          => source(1),
      scaler_ready_i          => source(2),
      scaler_startofpacket_i  => source(3),
      scaler_endofpacket_i    => source(4),
      scaler_data_i           => source(28 downto 5),

      scaler_valid_o          => sink(0),
      scaler_ready_o          => sink(1),
      scaler_startofpacket_o  => sink(2),
      scaler_endofpacket_o    => sink(3),
      scaler_data_o           => sink(27 downto 4)
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
