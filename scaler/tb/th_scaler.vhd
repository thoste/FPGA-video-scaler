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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_data_fifo_pkg.all;

library vip_avalon_st;


-- Test harness entity
entity th_scaler is
   generic (
         g_data_width               : natural;
         g_empty_width              : natural;
         g_fifo_data_width          : natural;
         g_fifo_data_depth          : natural;
         g_tx_video_width           : natural;
         g_tx_video_height          : natural;
         g_tx_video_scaling_method  : natural
      );
end entity;

-- Test harness architecture
architecture struct of th_scaler is
   -- DSP interface and general control signals
   signal clk_i               : std_logic  := '0';
   signal sreset_i            : std_logic := '0';

   -- DUT scaler inputs
   signal scaler_startofpacket_i     : std_logic;
   signal scaler_endofpacket_i       : std_logic;
   signal scaler_data_i              : std_logic_vector(g_data_width-1 downto 0);
   signal scaler_empty_i             : std_logic_vector(g_empty_width-1 downto 0);
   signal scaler_valid_i             : std_logic;
   signal scaler_ready_i             : std_logic;
   -- DUT scaler outputs
   signal scaler_startofpacket_o     : std_logic := '0';
   signal scaler_endofpacket_o       : std_logic := '0';
   signal scaler_data_o              : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal scaler_empty_o             : std_logic_vector(g_empty_width-1 downto 0) := (others => '0');
   signal scaler_valid_o             : std_logic := '0';
   signal scaler_ready_o             : std_logic := '0';

   -- Sink
   signal sink_startofpacket_i     : std_logic;
   signal sink_endofpacket_i       : std_logic;
   signal sink_data_i              : std_logic_vector(g_data_width-1 downto 0);
   signal sink_empty_i             : std_logic_vector(g_empty_width-1 downto 0);
   signal sink_valid_i             : std_logic;
   signal sink_ready_o             : std_logic := '0';

   -- Source
   signal source_startofpacket_o     : std_logic := '0';
   signal source_endofpacket_o       : std_logic := '0';
   signal source_data_o              : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal source_empty_o             : std_logic_vector(g_empty_width-1 downto 0) := (others => '0');
   signal source_valid_o             : std_logic := '0';
   signal source_ready_i             : std_logic;


   constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz
begin
   -----------------------------------------------------------------------------
   -- Instantiate the concurrent procedure that initializes UVVM
   -----------------------------------------------------------------------------
   i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

   -----------------------------------------------------------------------------
   -- Instantiate DUT
   -----------------------------------------------------------------------------
   i_scaler: entity work.scaler_wrapper
   generic map (
      g_data_width      => g_data_width,
      g_empty_width     => g_empty_width,
      g_fifo_data_width => g_fifo_data_width,
      g_fifo_data_depth => g_fifo_data_depth,
      g_tx_video_width  => g_tx_video_width,
      g_tx_video_height => g_tx_video_height,
      g_tx_video_scaling_method => g_tx_video_scaling_method
   )
   port map (
      clk_i             => clk_i,
      sreset_i          => sreset_i,

      -- x -> scaler
      scaler_data_i            => scaler_data_i,
      scaler_ready_o           => scaler_ready_o,
      scaler_valid_i           => scaler_valid_i,
      scaler_empty_i           => scaler_empty_i,
      scaler_eop_i             => scaler_endofpacket_i,
      scaler_sop_i             => scaler_startofpacket_i,
      
      -- scaler -> x
      scaler_data_o            => scaler_data_o,
      scaler_ready_i           => scaler_ready_i,
      scaler_valid_o           => scaler_valid_o,
      scaler_empty_o           => scaler_empty_o,
      scaler_eop_o             => scaler_endofpacket_o,
      scaler_sop_o             => scaler_startofpacket_o
   );


   -----------------------------------------------------------------------------
   -- AVALON ST VVC
   -----------------------------------------------------------------------------
   i1_avalon_st_vvc: entity vip_avalon_st.avalon_st_vvc
   generic map(
      GC_DATA_WIDTH     => g_data_width,
      GC_EMPTY_WIDTH    => g_empty_width,
      GC_INSTANCE_IDX   => 1
   )
   port map(
      clk   => clk_i,

      -- Sink
      avalon_st_sink_if.data_i               => sink_data_i,
      avalon_st_sink_if.ready_o              => sink_ready_o,
      avalon_st_sink_if.valid_i              => sink_valid_i,
      avalon_st_sink_if.empty_i              => sink_empty_i,
      avalon_st_sink_if.endofpacket_i        => sink_endofpacket_i,
      avalon_st_sink_if.startofpacket_i      => sink_startofpacket_i,

      -- Source
      avalon_st_source_if.data_o             => source_data_o,
      avalon_st_source_if.ready_i            => source_ready_i,
      avalon_st_source_if.valid_o            => source_valid_o,
      avalon_st_source_if.empty_o            => source_empty_o,
      avalon_st_source_if.endofpacket_o      => source_endofpacket_o,
      avalon_st_source_if.startofpacket_o    => source_startofpacket_o
   );


   -----------------------------------------------------------------------------
   -- Connect: source -> scaler -> sink
   -----------------------------------------------------------------------------
   scaler_data_i           <= source_data_o;
   source_ready_i          <= scaler_ready_o;
   scaler_valid_i          <= source_valid_o;
   scaler_empty_i          <= source_empty_o;
   scaler_endofpacket_i    <= source_endofpacket_o;
   scaler_startofpacket_i  <= source_startofpacket_o;

   sink_data_i             <= scaler_data_o;
   scaler_ready_i          <= sink_ready_o;
   sink_valid_i            <= scaler_valid_o;
   sink_empty_i            <= scaler_empty_o;
   sink_endofpacket_i      <= scaler_endofpacket_o;
   sink_startofpacket_i    <= scaler_startofpacket_o;



   -----------------------------------------------------------------------------
   -- Reset process
   -----------------------------------------------------------------------------  
   -- Toggle the reset after 5 clock periods
   p_sreset: sreset_i <= '1', '0' after 5 *C_CLK_PERIOD;

   -----------------------------------------------------------------------------
   -- Clock process
   -----------------------------------------------------------------------------  
   p_clk: process
   begin
      clk_i <= '0', '1' after C_CLK_PERIOD / 2;
      wait for C_CLK_PERIOD;
   end process;

end struct;
