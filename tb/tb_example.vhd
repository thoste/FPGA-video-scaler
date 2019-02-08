library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library modelsim_lib;
use modelsim_lib.util;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_data_fifo_pkg.all;

--! @brief Testbench for example
entity tb_example is
   generic (
      g_verbose    : boolean := false;
      g_test_cases : integer := 10;
      g_sim_mode   : boolean := true;
      g_clk_period : time    := 5 ns
      );
end entity;

architecture sim of tb_example is

begin

   -----------------------------------------------------------------------------
   -- Instantiate test harness, containing DUT and Executors
   -----------------------------------------------------------------------------
   i_th_example : entity work.th_example
      generic map (
         g_sim_mode   => g_sim_mode,
         g_clk_period => g_clk_period
         );

   -----------------------------------------------------------------------------
   -- Aliases declared in block to make sure test harness is elaborated
   -----------------------------------------------------------------------------
   b_main : block
      alias clk_i is << signal .tb_example.i_th_example.clk_i : std_logic >>;
   begin

      -----------------------------------------------------------------
      -- Main process
      -----------------------------------------------------------------
      p_main : process
         variable success   : boolean := true;
         variable rand_int  : integer;
         variable rand_byte : std_logic_vector(7 downto 0);
      begin

         -- Wait for UVVM to finish initialization
         await_uvvm_initialization(VOID);

         if not g_verbose then
            -- Disable uninteresting logs.
            disable_log_msg(ALL_MESSAGES);
            enable_log_msg(ID_LOG_HDR);
            enable_log_msg(ID_LOG_HDR_LARGE);
            enable_log_msg(ID_LOG_HDR_XL);
            enable_log_msg(ID_SEQUENCER);
            enable_log_msg(ID_SEQUENCER_SUB);
         end if;

         log(ID_LOG_HDR_XL, "Starting simulation of TB for example", C_SCOPE);

         wait for 10 * g_clk_period;

         -----------------------------------------------------------------------------------------------------               
         log(ID_LOG_HDR, "Test initialized", C_SCOPE);
         -----------------------------------------------------------------------------------------------------

         for test in 1 to g_test_cases loop
            wait until rising_edge(clk_i);
            log(ID_SEQUENCER, "Test " & to_string(test), C_SCOPE);
            check_value(clk_i = '1', warning, "Verifying checks are performed when clk_i = '1'", C_SCOPE);
            rand_int  := random(1, 10);
            check_value(rand_int /= 10, warning, "Verifying rand_int is not 10", C_SCOPE);
            rand_byte := random(8);
            check_value(unsigned(rand_byte) < 192, warning, "Verifying rand_byte is less than 192", C_SCOPE);
            wait until falling_edge(clk_i);
         end loop;

         if success then
            log(ID_SEQUENCER, "All tests passed", C_SCOPE);
         end if;

         -----------------------------------------------------------------------------
         -- Ending the simulation
         -----------------------------------------------------------------------------
         report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
         log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

         -- Finish the simulation
         std.env.stop;
         wait;                          -- to stop completely

      end process p_main;
   end block;

end architecture;

