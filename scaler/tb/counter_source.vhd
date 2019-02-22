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

entity counter_source is
   port(
      clk_i          : in std_logic;
      sreset_i       : in std_logic;
      count_o        : out std_logic_vector (19 downto 0));
end counter_source;

architecture counter_source_arc of counter_source is
   signal s_count : unsigned(19 downto 0);
begin
   process(clk_i, sreset_i)
   begin
      if sreset_i = '1' then
         s_count <= (others => '0');
      elsif rising_edge(clk_i) then
         s_count <= s_count + 1;
      end if;
   end process;
count_o <= std_logic_vector(s_count);
end counter_source_arc;