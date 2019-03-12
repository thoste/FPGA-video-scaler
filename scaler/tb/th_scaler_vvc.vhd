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

library vip_avalon_st;


-- Test harness entity
entity th_scaler_vvc is
end entity;

-- Test harness architecture
architecture struct of th_scaler_vvc is
   -- DSP interface and general control signals
   signal clk_i               : std_logic  := '0';
   signal sreset_i            : std_logic := '0';

   -- DUT scaler inputs
   signal sop_i               : std_logic := '0';
   signal eop_i               : std_logic := '0';
   signal data_i              : std_logic_vector (19 downto 0);
   signal empty_i             : std_logic := '0';
   signal valid_i             : std_logic := '0';
   signal ready_i             : std_logic := '0';
   -- DUT scaler outputs
   signal sop_o               : std_logic;
   signal eop_o               : std_logic;
   signal data_o              : std_logic_vector (19 downto 0);
   signal empty_o             : std_logic;
   signal valid_o             : std_logic;
   signal ready_o             : std_logic;

   constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz
begin
   -----------------------------------------------------------------------------
   -- Instantiate the concurrent procedure that initializes UVVM
   -----------------------------------------------------------------------------
   i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

   -----------------------------------------------------------------------------
   -- Instantiate DUT
   -----------------------------------------------------------------------------
   i_scaler: entity work.scaler
   port map (
      -- To scaler
      clk_i          => clk_i,
      sreset_i       => sreset_i,
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
      ready_o        => ready_o
   );


   -----------------------------------------------------------------------------
   -- AVALON ST VVC
   -----------------------------------------------------------------------------
   i1_avalon_st_vvc: entity vip_avalon_st.avalon_st_vvc
   generic map(
      GC_INSTANCE_IDX   => 1
   )
   port map(
      clk   => clk_i
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

end struct;
