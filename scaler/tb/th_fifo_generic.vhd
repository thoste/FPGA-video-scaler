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


-- Test harness entity
entity th_fifo_generic is
   generic (
      g_width : natural;
      g_depth : natural
   );
end entity;


-- Test harness architecture
architecture struct of th_fifo_generic is
   constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

   -- Clk, sreset
   signal clk_i      : std_logic := '0';
   signal sreset_i   : std_logic := '0';
   -- Write to fifo
   signal data_i     : std_logic_vector(g_width-1 downto 0) := (others => '0');
   signal wr_en_i    : std_logic := '0';
   signal full_o     : std_logic;
   -- Read from fifo
   signal data_o     : std_logic_vector(g_width-1 downto 0);
   signal rd_en_i    : std_logic := '0';
   signal empty_o    : std_logic;

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
      g_width     => g_width, 
      g_depth     => g_depth
   )
   port map(
      clk_i       => clk_i,
      sreset_i    => sreset_i,
      data_i      => data_i,
      wr_en_i     => wr_en_i,
      full_o      => full_o,
      data_o      => data_o,
      rd_en_i     => rd_en_i,
      empty_o     => empty_o
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