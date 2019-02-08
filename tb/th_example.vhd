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
entity th_example is
   generic (
      g_sim_mode : boolean;
      g_clk_period : time
      );
end entity;

architecture sim of th_example is

   signal clk_i : std_logic := '0';

begin

   -----------------------------------------------------------------------------
   -- Instantiate the concurrent procedure that initializes UVVM
   -----------------------------------------------------------------------------
   i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

   ------------------------------------------------
   -- generating clock
   ------------------------------------------------
   clock_generator(clk_i, g_clk_period);

   -----------------------------------------------------------------------------
   -- INSTANTIATE MUT HERE
   -----------------------------------------------------------------------------
-- i_mut : entity mut_lib.mut
--    generic map (
--       g_sim_mode            => g_sim_mode)
--    port map (
--       clk_i                    => clk_i);

end architecture;

