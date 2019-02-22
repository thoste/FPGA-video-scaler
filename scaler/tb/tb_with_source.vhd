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
use std.env.stop;

entity tb_with_source is
end tb_with_source;

architecture tb_with_source_arc of tb_with_source is
   component scaler
      port (
          -- To scaler
         clk_i          : in std_logic;
         sreset_i       : in std_logic;
         sop_i          : in std_logic;
         eop_i          : in std_logic;
         data_i         : in std_logic_vector (19 downto 0);
         empty_i        : in std_logic;
         valid_i        : in std_logic;
         ready_i        : in std_logic;

         -- From scaler
         sop_o          : out std_logic;
         eop_o          : out std_logic;
         data_o         : out std_logic_vector (19 downto 0);
         empty_o        : out std_logic;
         valid_o        : out std_logic;
         ready_o        : out std_logic);
   end component;
   component counter_source
      port (
         clk_i          : in std_logic;
         sreset_i       : in std_logic;
         count_o        : out std_logic_vector (19 downto 0));
   end component;

   constant period : time := 50 ns;

   signal clk_i               : std_logic := '0';
   signal sreset_i            : std_logic := '1';

   signal sop_i               : std_logic := '0';
   signal eop_i               : std_logic := '0';
   signal data_i              : std_logic_vector (19 downto 0);
   signal empty_i             : std_logic := '0';
   signal valid_i             : std_logic := '0';
   signal ready_i             : std_logic := '0';

   signal sop_o               : std_logic;
   signal eop_o               : std_logic;
   signal data_o              : std_logic_vector (19 downto 0);
   signal empty_o             : std_logic;
   signal valid_o             : std_logic;
   signal ready_o             : std_logic;

   signal response_dut, data_counter_dut : std_logic_vector(19 downto 0);
begin
   DUT: scaler
      port map(
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

   i_source : counter_source
      port map(
         clk_i       => clk_i,
         sreset_i       => sreset_i,
         count_o     => data_counter_dut
      );

   clk_i <= not clk_i after period/2;
   sreset_i <= '0' after 10 ns;
   ready_i <= '1' after 50 ns;
   sop_i <= '1' after 50 ns;

   -- Send video packet identifier at certain intervals 
   process(clk_i)
      variable counter_v : integer := 0; 
   begin
      if rising_edge(clk_i) then
         if counter_v = 10 then
            data_i <= 20x"0";
            counter_v := 0;
         else
            data_i <= data_counter_dut; 
            counter_v := counter_v + 1;
         end if;
      end if;
   end process;

   -- How long to run the simulation
   process
   begin
      wait for 1000 ns;
      stop;
   end process;

end tb_with_source_arc;