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
use std.textio.all;
use ieee.std_logic_textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_data_fifo_pkg.all;


-- Test bench entity
entity tb_scaler is
end tb_scaler;

-- Test bench architecture
architecture tb_scaler_arc of tb_scaler is
   constant C_SCOPE        : string := C_TB_SCOPE_DEFAULT;
   constant C_CLK_PERIOD   : time   := 10 ns; -- 100 MHz

   -- Avalon-ST bus widths
   constant C_DATA_WIDTH      : natural := 24; 
   constant C_BITS_PIXEL      : natural := 8; 

   --constant C_RX_VIDEO_WIDTH  : natural := 6;
   --constant C_RX_VIDEO_HEIGHT : natural := 6;
   --constant C_TX_VIDEO_WIDTH  : natural := 12;
   --constant C_TX_VIDEO_HEIGHT : natural := 12;

   constant C_RX_VIDEO_WIDTH  : natural := 1280;
   constant C_RX_VIDEO_HEIGHT : natural := 720;
   constant C_TX_VIDEO_WIDTH  : natural := 1920;
   constant C_TX_VIDEO_HEIGHT : natural := 1080;

   -- File I/O
   constant C_IMAGE        : string := "planetearth2c";
   constant C_SCALING      : string := "bilinear";
   constant C_INPUT_FILE   : string := "../../data/orig/" & C_IMAGE & "/" & C_IMAGE & "_ycbcr444_" & to_string(C_BITS_PIXEL) & "bit_" & to_string(C_RX_VIDEO_HEIGHT) & ".bin";
   constant C_OUTPUT_FILE  : string := "../../data/vhdl_out/" & C_IMAGE & "/" & C_IMAGE & "_" & C_SCALING & "_" & to_string(C_RX_VIDEO_HEIGHT) & "_to_" & to_string(C_TX_VIDEO_HEIGHT) & ".bin";
   file     file_input     : text;
   file     file_output    : text;

   -- DSP interface and general control signals
   signal clk_i               : std_logic := '0';
   signal sreset_i            : std_logic := '0';

  -- DUT scaler inputs
   signal startofpacket_i     : std_logic := '0';
   signal endofpacket_i       : std_logic := '0';
   signal data_i              : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
   signal valid_i             : std_logic := '0';
   signal ready_i             : std_logic := '0';

   -- DUT scaler outputs
   signal startofpacket_o     : std_logic := '0';
   signal endofpacket_o       : std_logic := '0';
   signal data_o              : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
   signal valid_o             : std_logic := '0';
   signal ready_o             : std_logic := '0';

begin
   -----------------------------------------------------------------------------
   -- Instantiate the concurrent procedure that initializes UVVM
   -----------------------------------------------------------------------------
   i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;


   -----------------------------------------------------------------------------
   -- Instantiate DUT
   -----------------------------------------------------------------------------
   i_scaler: entity work.scaler
   generic map(
      g_data_width         => C_DATA_WIDTH, 
      g_rx_video_width     => C_RX_VIDEO_WIDTH,
      g_rx_video_height    => C_RX_VIDEO_HEIGHT,
      g_tx_video_width     => C_TX_VIDEO_WIDTH,
      g_tx_video_height    => C_TX_VIDEO_HEIGHT
   )
   port map(
      clk_i             => clk_i,
      sreset_i          => sreset_i,

      scaler_startofpacket_i  => startofpacket_i,
      scaler_endofpacket_i    => endofpacket_i,
      scaler_data_i           => data_i,
      scaler_valid_i          => valid_i,
      scaler_ready_o          => ready_o,

      scaler_startofpacket_o  => startofpacket_o,
      scaler_endofpacket_o    => endofpacket_o,
      scaler_data_o           => data_o,
      scaler_valid_o          => valid_o,
      scaler_ready_i          => ready_i
   );


   ------------------------------------------------
   -- PROCESS: p_main
   ------------------------------------------------
   p_main: process 
      variable v_input_line      : line;
      variable v_data_slv        : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
      variable v_data            : integer := 0;
      variable v_num_test_loops  : integer := 0;
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

      log(ID_LOG_HDR, "Starting simulation of bilinear", C_SCOPE);
      log("Wait 10 clock period for reset to be turned off");
      wait for (10 * C_CLK_PERIOD); 
      wait until rising_edge(clk_i);
      
      -----------------------------------------------------------------------------
      -- Test scaler
      -----------------------------------------------------------------------------
      v_num_test_loops := 1;

      -----------------------------------------------------------------------------
      -- Send video data control packet
      -----------------------------------------------------------------------------
      ready_i <= '1';
      data_i <= (others => '0');
      valid_i <= '1';
      startofpacket_i <= '1';
      wait until rising_edge(clk_i);
      startofpacket_i <= '0';

      -------------------------------------------------------------------------------
      ---- Send known video data
      -------------------------------------------------------------------------------
      --for n in 1 to v_num_test_loops loop
      --   for i in 1 to C_RX_VIDEO_WIDTH loop
      --      v_data := (10 * i) + 1;
      --      for j in 1 to C_RX_VIDEO_HEIGHT loop
      --         while ready_o = '0' loop
      --            valid_i  <= '0';
      --            wait until rising_edge(clk_i);
      --         end loop;
      --         endofpacket_i  <= '1' when (i = C_RX_VIDEO_WIDTH and j = C_RX_VIDEO_HEIGHT) else '0';
      --         data_i   <= std_logic_vector(to_unsigned(v_data, data_i'length));
      --         valid_i  <= '1';
      --         v_data := v_data + 1;
      --         wait until rising_edge(clk_i);
      --         --valid_i  <= '0';
      --         --wait until rising_edge(clk_i);
      --      end loop;
      --   end loop;
      --end loop;
      --valid_i <= '0';
      --endofpacket_i <= '0';

      --------------------------------------------------
      -- Read input file and send video data
      --------------------------------------------------
      file_open(file_input, C_INPUT_FILE, read_mode);

      while not endfile(file_input) loop
         while ready_o = '0' loop
            valid_i  <= '0';
            wait until rising_edge(clk_i);
         end loop;

         -- Read input data and send
         readline(file_input, v_input_line);
         read(v_input_line, v_data_slv);
         data_i <= v_data_slv;
         valid_i <= '1';
         wait until rising_edge(clk_i);
      end loop;
      file_close(file_input);
      valid_i <= '0';


      -----------------------------------------------------------------------------
      -- Ending the simulation
      -----------------------------------------------------------------------------
      wait for 10*C_CLK_PERIOD;
      wait for 2*C_TX_VIDEO_WIDTH*C_TX_VIDEO_HEIGHT*C_CLK_PERIOD;

      report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
      log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

      -- Finish the simulation
      std.env.stop;
      wait;  -- to stop completely
   end process p_main;


   -----------------------------------------------------------------------------
   -- Write data to binary file
   -----------------------------------------------------------------------------  
   p_write_data: process 
      variable v_out_line  : line;
      variable v_data_slv  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
      variable v_sop       : boolean := false;
   begin
      file_open(file_output, C_OUTPUT_FILE, write_mode);
      wait until rising_edge(clk_i);
      
      -- Wait for startofpacket_o
      while not v_sop loop
         wait until rising_edge(clk_i);
         if startofpacket_o = '1' then
            v_sop := true;
         end if;
      end loop;

      -- Write data on eack clock as long as valid_o = '1'
      while v_sop loop
         if valid_o = '1' then
            v_data_slv := data_o;
            write(v_out_line, v_data_slv);
            writeline(file_output, v_out_line);
         end if;
         wait until rising_edge(clk_i);
      end loop;
      file_close(file_output);
   end process;


   -----------------------------------------------------------------------------
   -- Clock process
   -----------------------------------------------------------------------------  
   p_clk: process
   begin
      clk_i <= '0', '1' after C_CLK_PERIOD / 2;
      wait for C_CLK_PERIOD;
   end process;

end tb_scaler_arc;