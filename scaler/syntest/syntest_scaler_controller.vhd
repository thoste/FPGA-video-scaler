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


entity syntest_scaler_controller is
   port(
      clk_i         : in  std_logic;
      sink_o        : out std_logic
   );
end entity syntest_scaler_controller;

architecture rtl of syntest_scaler_controller is
   constant C_DATA_WIDTH   : natural := 80;
   constant C_EMPTY_WIDTH  : natural := 3;

   signal source : std_logic_vector((C_DATA_WIDTH + C_EMPTY_WIDTH + 6)-1 downto 0) := (others => '0');
   signal sink   : std_logic_vector((C_DATA_WIDTH + C_EMPTY_WIDTH + 36)-1 downto 0) := (others => '0');

begin

   i_mut : entity work.scaler_controller
   generic map(
      g_data_width               => C_DATA_WIDTH,
      g_empty_width              => C_EMPTY_WIDTH,
      g_tx_video_width           => 1920,
      g_tx_video_height          => 1080,
      g_tx_video_scaling_method  => 0
   )
   port map(
      clk_i       => source(0),
      sreset_i    => source(1),
      
      -- Source
      startofpacket_i   => source(2),
      endofpacket_i     => source(3),
      valid_i           => source(4),
      ready_i           => source(5),
      data_i            => source(C_DATA_WIDTH+5 downto 6),
      empty_i           => source(C_EMPTY_WIDTH+C_DATA_WIDTH+5 downto C_DATA_WIDTH+6),

      -- Sink
      startofpacket_o   => sink(0),
      endofpacket_o     => sink(1),
      valid_o           => sink(2),
      ready_o           => sink(3),

      rx_video_width_o  => sink(19 downto 4),
      rx_video_height_o => sink(35 downto 20),

      data_o            => sink(C_DATA_WIDTH+35 downto 36), 
      empty_o           => sink(C_EMPTY_WIDTH+C_DATA_WIDTH+35 downto C_DATA_WIDTH+36)
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
