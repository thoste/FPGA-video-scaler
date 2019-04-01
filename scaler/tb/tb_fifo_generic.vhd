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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_data_fifo_pkg.all;


-- Test bench entity
entity tb_fifo_generic is
end tb_fifo_generic;

-- Test bench architecture
architecture tb_fifo_generic_arc of tb_fifo_generic is
   constant C_SCOPE              : string  := C_TB_SCOPE_DEFAULT;

   constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

   constant C_WIDTH     : natural   := 20;
   constant C_DEPTH     : natural   := 128; 

begin
   -----------------------------------------------------------------------------
   -- Instantiate test harness, containing DUT and Executors
   -----------------------------------------------------------------------------
   i_test_harness : entity work.th_fifo_generic
   generic map (
      g_width     => C_WIDTH,
      g_depth     => C_DEPTH
   );

   ------------------------------------------------
   -- PROCESS: p_main
   ------------------------------------------------
   p_main: process
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

      log(ID_LOG_HDR, "Starting simulation of FIFO", C_SCOPE);
      log("Wait 10 clock period for reset to be turned off");
      wait for (10 * C_CLK_PERIOD); 


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


end tb_fifo_generic_arc;