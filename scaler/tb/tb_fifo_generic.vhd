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


-- Test bench entity
entity tb_fifo_generic is
end tb_fifo_generic;

-- Test bench architecture
architecture tb_fifo_generic_arc of tb_fifo_generic is
   constant C_SCOPE              : string  := C_TB_SCOPE_DEFAULT;
   constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

   -- Width and depth of FIFO
   constant C_WIDTH     : natural   := 20;
   constant C_DEPTH     : natural   := 10; 

   -- Clk, sreset
   signal clk_i         : std_logic;
   signal sreset_i      : std_logic;
   -- Write to fifo
   signal data_i        : std_logic_vector(C_WIDTH-1 downto 0) := (others => '0');
   signal wr_en_i       : std_logic;
   signal full_o        : std_logic;
   signal almostfull_o  : std_logic;
   -- Read from fifo
   signal data_o        : std_logic_vector(C_WIDTH-1 downto 0);
   signal rd_en_i       : std_logic;
   signal empty_o       : std_logic;

begin
   -----------------------------------------------------------------------------
   -- Instantiate the concurrent procedure that initializes UVVM
   -----------------------------------------------------------------------------
   i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;


   -----------------------------------------------------------------------------
   -- Instantiate DUT
   -----------------------------------------------------------------------------
   i_fifo: entity work.fifo_generic
   generic map(
      g_width     => C_WIDTH, 
      g_depth     => C_DEPTH
   )
   port map(
      clk_i          => clk_i,
      sreset_i       => sreset_i,
      data_i         => data_i,
      wr_en_i        => wr_en_i,
      full_o         => full_o,
      almostfull_o   => almostfull_o,
      data_o         => data_o,
      rd_en_i        => rd_en_i,
      empty_o        => empty_o
   );


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

   -----------------------------------------------------------------------------
   -- Data_i generate random data process
   ----------------------------------------------------------------------------- 
   p_data_i : process(clk_i)
   begin
      if rising_edge(clk_i) then
         data_i <= random(C_WIDTH);
      end if;
   end process;

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
      -- Test FIFO
      -----------------------------------------------------------------------------
      wr_en_i <= '0';
      rd_en_i <= '0';
      wait until rising_edge(clk_i);

      -- Fill FIFO
      for i in 1 to C_DEPTH*2 loop
         wr_en_i <= '1';
         rd_en_i <= '0';
         wait until rising_edge(clk_i);
      end loop;

      -- Empty FIFO
      for i in 1 to C_DEPTH*2 loop
         wr_en_i <= '0';
         rd_en_i <= '1';
         wait until rising_edge(clk_i);
      end loop;

      -- Idle
      for i in 1 to C_DEPTH*2 loop
         wr_en_i <= '0';
         rd_en_i <= '0';
         wait until rising_edge(clk_i);
      end loop;

      -- Stream through empty FIFO
      for i in 1 to C_DEPTH*2 loop
         wr_en_i <= '1';
         rd_en_i <= '1';
         wait until rising_edge(clk_i);
      end loop;

      -- Empty FIFO
      for i in 1 to C_DEPTH*2 loop
         wr_en_i <= '0';
         rd_en_i <= '1';
         wait until rising_edge(clk_i);
      end loop;

      -- Idle
      for i in 1 to C_DEPTH*2 loop
         wr_en_i <= '0';
         rd_en_i <= '0';
         wait until rising_edge(clk_i);
      end loop;


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