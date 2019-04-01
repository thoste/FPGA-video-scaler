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
   generic (
      DATA_WIDTH        : natural;
      EMPTY_WIDTH       : natural
   );
   port (
      -- To scaler
      clk_i          : in std_logic;
      sreset_i       : in std_logic;
      sop_i          : in std_logic;
      eop_i          : in std_logic;
      data_i         : in std_logic_vector(DATA_WIDTH-1 downto 0);
      empty_i        : in std_logic_vector(EMPTY_WIDTH-1 downto 0);
      valid_i        : in std_logic;
      ready_i        : in std_logic;

      -- From scaler
      sop_o          : out std_logic := '0';
      eop_o          : out std_logic := '0';
      data_o         : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      empty_o        : out std_logic_vector(EMPTY_WIDTH-1 downto 0) := (others => '0');
      valid_o        : out std_logic := '0';
      ready_o        : out std_logic := '0'
      );
end entity scaler;

architecture scaler_arc of scaler is
   signal rx_video_width_o          : unsigned(15 downto 0);
   signal rx_video_height_o         : unsigned(15 downto 0);
   signal rx_video_interlacing_o    : unsigned(3 downto 0);
   signal tx_video_width_o          : unsigned(15 downto 0);
   signal tx_video_height_o         : unsigned(15 downto 0);
   signal tx_video_scaling_method_o : unsigned(3 downto 0);
begin
   scaler_controller : entity work.scaler_controller
   generic map(
      DATA_WIDTH     => DATA_WIDTH,
      EMPTY_WIDTH    => EMPTY_WIDTH
   )

   port map(
      clk_i          => clk_i,
      sreset_i       => sreset_i,
      -- To scaler
      sop_i          => sop_i,
      eop_i          => eop_i,
      data_i         => data_i,
      empty_i        => empty_i,
      valid_i        => valid_i,
      ready_i        => ready_i,
      -- From scaler
      sop_o          => sop_o,
      eop_o          => eop_o,
      data_o         => data_o,
      empty_o        => empty_o,
      valid_o        => valid_o,
      ready_o        => ready_o,
      -- Internal
      rx_video_width_o           => rx_video_width_o,
      rx_video_height_o          => rx_video_height_o,
      rx_video_interlacing_o     => rx_video_interlacing_o,
      tx_video_width_o           => tx_video_width_o,
      tx_video_height_o          => tx_video_height_o,
      tx_video_scaling_method_o  => tx_video_scaling_method_o);

end scaler_arc;
