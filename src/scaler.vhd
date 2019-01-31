------------------------------------------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-01-21
-- Version: 0.1
------------------------------------------------------------------------------------------
-- Description:
------------------------------------------------------------------------------------------
-- v0.1:
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity scaler is
   port (
      -- To scaler
      clk_i : in std_logic;
      sreset_i : in std_logic;
      startofpacket_i : in std_logic;
      endofpacket_i : in std_logic;
      data_i : in std_logic_vector (19 downto 0);
      empty_i : in std_logic;
      valid_i : in std_logic;
      ready_i : in std_logic;

      -- From scaler
      startofpacket_o : out std_logic;
      endofpacket_o : out std_logic;
      data_o : out std_logic_vector (19 downto 0);
      empty_o : out std_logic;
      valid_o : out std_logic;
      ready_o : out std_logic);
end entity scaler;

architecture scaler_arc of scaler is
   signal rx_video_width    : unsigned(15 downto 0);
   signal rx_video_height   : unsigned(15 downto 0);
   signal rx_interlacing    : unsigned(3 downto 0);
begin
   controller : entity work.controller
   port map(
      clk_i => clk_i,
      sreset_i => sreset_i,
      startofpacket_i => startofpacket_i,
      endofpacket_i => endofpacket_i,
      data_i => data_i,
      empty_i => empty_i,
      valid_i => valid_i,
      ready_i => ready_i,
      startofpacket_o => startofpacket_o,
      endofpacket_o => endofpacket_o,
      data_o => data_o,
      empty_o => empty_o,
      valid_o => valid_o,
      ready_o => ready_o,
      rx_video_width  => rx_video_width,
      rx_video_height => rx_video_height,
      rx_interlacing => rx_interlacing);

end scaler_arc;
