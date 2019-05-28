--------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-01-21
-- Version: 0.1
--------------------------------------------------------
-- Description: Testbench for scaler full design
--------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_data_fifo_pkg.all;

library vip_avalon_st;
use vip_avalon_st.vvc_methods_pkg.all;
use vip_avalon_st.td_vvc_framework_common_methods_pkg.all;


-- Test bench entity
entity tb_scaler_complete is
end entity;

-- Test bench architecture
architecture func of tb_scaler_complete is
   constant C_SCOPE              : string  := C_TB_SCOPE_DEFAULT;

   -- Clock and bit period settings
   constant C_CLK_PERIOD         : time := 10 ns;
   constant C_BIT_PERIOD         : time := 16 * C_CLK_PERIOD;

   -- Avalon-ST bus widths
   constant C_DATA_WIDTH      : natural := 80;
   constant C_EMPTY_WIDTH     : natural := 1;

   -- FIFOs
   constant C_FIFO_DATA_WIDTH : natural := C_DATA_WIDTH + C_EMPTY_WIDTH + 2;
   constant C_FIFO_DATA_DEPTH : natural := 6;

   -- File I/O
   constant c_INPUT_FILE   : string := "../../data/orig/lionking/lionking_ycbcr444_8bit_360.bin";
   constant c_EXPECT_FILE  : string := "../../data/orig/lionking/lionking_ycbcr444_8bit_360.bin";
   file     file_input     : text;
   file     file_expect    : text;

   -- Test data
   constant C_RX_VIDEO_WIDTH  : natural := 640;
   constant C_RX_VIDEO_HEIGHT : natural := 360;
   constant C_TX_VIDEO_WIDTH  : natural := 640;
   constant C_TX_VIDEO_HEIGHT : natural := 360;
   constant C_DATA_LENGTH     : natural := C_RX_VIDEO_WIDTH*C_RX_VIDEO_HEIGHT;
   constant C_EXPECT_LENGTH   : natural := C_TX_VIDEO_WIDTH*C_TX_VIDEO_HEIGHT;


   procedure wait_for_time_wrap(   -- Wait for next round time number - e.g. if now=2100ns, and round_time=1000ns, then next round time is 3000ns
      round_time   : time) is
      variable v_overshoot   : time    := now rem round_time;
   begin
      wait for (round_time - v_overshoot);
   end;

begin
   -----------------------------------------------------------------------------
   -- Instantiate test harness, containing DUT and Executors
   -----------------------------------------------------------------------------
   i_test_harness : entity work.th_scaler_complete
   generic map (
      g_data_width      => C_DATA_WIDTH,
      g_empty_width     => C_EMPTY_WIDTH,
      g_fifo_data_width => C_FIFO_DATA_WIDTH,
      g_fifo_data_depth => C_FIFO_DATA_DEPTH,
      --g_rx_video_width  => C_RX_VIDEO_WIDTH,
      --g_rx_video_height => C_RX_VIDEO_HEIGHT,
      g_tx_video_width  => C_TX_VIDEO_WIDTH,
      g_tx_video_height => C_TX_VIDEO_HEIGHT
   );


   ------------------------------------------------
   -- PROCESS: p_main
   ------------------------------------------------
   p_main: process
      variable v_ctrl_pkt_array  : t_slv_array(0 to 1)(C_DATA_WIDTH-1 downto 0)                 := (others => (others => '0'));
      variable v_data_array      : t_slv_array(0 to C_DATA_LENGTH)(C_DATA_WIDTH-1 downto 0)   := (others => (others => '0'));
      variable v_exp_data_array  : t_slv_array(0 to C_EXPECT_LENGTH-1)(C_DATA_WIDTH-1 downto 0) := (others => (others => '0'));
      variable v_empty           : std_logic_vector(C_EMPTY_WIDTH-1 downto 0) := (others => '0');

      variable v_num_test_loops  : natural := 0;

      variable v_rx_video_width   : std_logic_vector(15 downto 0) := (others => '0');
      variable v_rx_video_height  : std_logic_vector(15 downto 0) := (others => '0');

      variable v_file_input_line    : line;
      variable v_file_expect_line   : line;
      variable v_file_data_input    : std_logic_vector(C_DATA_WIDTH-1 downto 0);
      variable v_file_data_expect   : std_logic_vector(C_DATA_WIDTH-1 downto 0);

      variable v_counter : integer := 0;
   begin

   -- Wait for UVVM to finish initialization
   await_uvvm_initialization(VOID);

   -- Print the configuration to the log
   report_global_ctrl(VOID);
   report_msg_id_panel(VOID);

   -----------------------------------------------------------------------------
   -- Enable log message
   -----------------------------------------------------------------------------
   enable_log_msg(ALL_MESSAGES);
   enable_log_msg(ID_LOG_HDR);
   enable_log_msg(ID_UVVM_SEND_CMD);

   disable_log_msg(AVALON_ST_VVCT, 1, TX, ALL_MESSAGES);
   disable_log_msg(AVALON_ST_VVCT, 1, RX, ALL_MESSAGES);

   enable_log_msg(AVALON_ST_VVCT, 1, TX, ID_BFM);
   enable_log_msg(AVALON_ST_VVCT, 1, TX, ID_PACKET_INITIATE);
   enable_log_msg(AVALON_ST_VVCT, 1, TX, ID_PACKET_COMPLETE);

   enable_log_msg(AVALON_ST_VVCT, 1, RX, ID_BFM);
   enable_log_msg(AVALON_ST_VVCT, 1, RX, ID_PACKET_INITIATE);
   enable_log_msg(AVALON_ST_VVCT, 1, RX, ID_PACKET_COMPLETE);

   -----------------------------------------------------------------------------
   -- Enable/disable Avalon-ST signals 
   -----------------------------------------------------------------------------
   shared_avalon_st_vvc_config(TX, 1).bfm_config.use_channel   := false;
   shared_avalon_st_vvc_config(TX, 1).bfm_config.use_error     := false;
   shared_avalon_st_vvc_config(TX, 1).bfm_config.use_empty     := true;

   -- Percent of cycles the receive module should assert ready_o signal
   shared_avalon_st_vvc_config(RX, 1).bfm_config.ready_percentage := 100;

   -- Set empty signal if some symbols are empty at the last transmission
   v_empty := std_logic_vector(to_unsigned(0, v_empty'length));


   log(ID_LOG_HDR, "Starting simulation of TB scaler", C_SCOPE);
   log("Wait 10 clock period for reset to be turned off");
   wait for (10 * C_CLK_PERIOD); 


   -----------------------------------------------------------------------------
   -- Control packet
   -----------------------------------------------------------------------------
   log(ID_LOG_HDR, "Sending control packet", C_SCOPE);
   -- Send control packet
   v_ctrl_pkt_array(0) := std_logic_vector(to_unsigned(15, C_DATA_WIDTH));
   -- Set rx resolution
   v_rx_video_width  := std_logic_vector(to_unsigned(C_RX_VIDEO_WIDTH, v_rx_video_width'length));
   v_rx_video_height := std_logic_vector(to_unsigned(C_RX_VIDEO_HEIGHT, v_rx_video_height'length));
   v_ctrl_pkt_array(1)(3 downto 0)   := v_rx_video_width(15 downto 12);
   v_ctrl_pkt_array(1)(13 downto 10) := v_rx_video_width(11 downto 8);
   v_ctrl_pkt_array(1)(23 downto 20) := v_rx_video_width(7 downto 4);
   v_ctrl_pkt_array(1)(33 downto 30) := v_rx_video_width(3 downto 0);
   v_ctrl_pkt_array(1)(43 downto 40) := v_rx_video_height(15 downto 12);
   v_ctrl_pkt_array(1)(53 downto 50) := v_rx_video_height(11 downto 8);
   v_ctrl_pkt_array(1)(63 downto 60) := v_rx_video_height(7 downto 4);
   v_ctrl_pkt_array(1)(73 downto 70) := v_rx_video_height(3 downto 0);

   -- Start send and receive VVC
   avalon_st_send(AVALON_ST_VVCT, 1, v_ctrl_pkt_array, v_empty, "Sending v_data_array");
   avalon_st_expect(AVALON_ST_VVCT, 1, v_ctrl_pkt_array, v_empty, "Checking data", ERROR);
   --avalon_st_receive(AVALON_ST_VVCT, 1, "Receiving");

   -- Wait for completion
   await_completion(AVALON_ST_VVCT, 1, RX, 10*C_DATA_LENGTH*C_CLK_PERIOD);
   wait for (10 * C_CLK_PERIOD); 
   
   -------------------------------------------------------------------------------
   ---- Video data packet
   -------------------------------------------------------------------------------
   --log(ID_LOG_HDR, "Sending video data packet", C_SCOPE);
   ---- Number of times to run the test loop
   --v_num_test_loops := 1;

   ----wait_for_time_wrap(10000 ns);

   --for i in 1 to v_num_test_loops loop
   --   -- Create a random ready percentage for the recieve module
   --   shared_avalon_st_vvc_config(RX, 1).bfm_config.ready_percentage := random(1,100);
   --   --shared_avalon_st_vvc_config(RX, 1).bfm_config.ready_percentage := 50;

   --   -- Write packet info, Data[3:0] = 0 for video_packet
   --   --v_data_array(0)      := std_logic_vector(to_unsigned(0, C_DATA_WIDTH));
   --   --v_exp_data_array(0)  := std_logic_vector(to_unsigned(0, C_DATA_WIDTH));
   --   v_data_array(0)      := (3 downto 0 => '0', others => '1');
   --   --v_exp_data_array(0)  := (3 downto 0 => '0', others => '1');


   --   --------------------------------------------------
   --   -- Read input file and fill data array
   --   --------------------------------------------------
   --   file_open(file_input, c_INPUT_FILE, read_mode);

   --   while not endfile(file_input) loop
   --      v_counter := v_counter + 1;

   --      -- Read input data and store to data array
   --      readline(file_input, v_file_input_line);
   --      read(v_file_input_line, v_file_data_input);
   --      v_data_array(v_counter) := v_file_data_input;
   --   end loop;

   --   file_close(file_input);

   --   -- Reset v_counter
   --   v_counter := 0;


   --   --------------------------------------------------
   --   -- Read expect file and fill expect data array
   --   --------------------------------------------------
   --   file_open(file_expect, c_EXPECT_FILE, read_mode);

   --   while not endfile(file_expect) loop
   --      -- Read expected output data and store to expect array
   --      readline(file_expect, v_file_expect_line);
   --      read(v_file_expect_line, v_file_data_expect);
   --      v_exp_data_array(v_counter) := v_file_data_expect;
   --      v_counter := v_counter + 1;
   --   end loop;
      
   --   file_close(file_expect);

   --   -- Reset v_counter
   --   v_counter := 0;

   --   -- Margin
   --   wait for 10*C_CLK_PERIOD; 


   --   --------------------------------------------------
   --   -- Send/recieve using avalon st vvc
   --   --------------------------------------------------

   --   log(ID_LOG_HDR, "Test loop " & to_string(i) & " of " & to_string(v_num_test_loops) & " tests. Sending " & to_string(C_DATA_LENGTH) & " pixels. Using ready percentage: " & to_string(shared_avalon_st_vvc_config(RX, 1).bfm_config.ready_percentage), C_SCOPE);

   --   -- Start send and receive VVC
   --   avalon_st_send(AVALON_ST_VVCT, 1, v_data_array, v_empty, "Sending v_data_array");
   --   --avalon_st_expect(AVALON_ST_VVCT, 1, v_exp_data_array, v_empty, "Checking data", ERROR);
   --   avalon_st_receive(AVALON_ST_VVCT, 1, "Receiving");
      

   --   -- Wait for completion
   --   await_completion(AVALON_ST_VVCT, 1, RX, 100*C_DATA_LENGTH*C_CLK_PERIOD);
   --end loop;
   

   -----------------------------------------------------------------------------
   -- Ending the simulation
   -----------------------------------------------------------------------------
   wait for 1000 ns;             -- to allow some time for completion
   report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
   log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

   -- Finish the simulation
   std.env.stop;
   wait;  -- to stop completely

   end process p_main;
end func;
