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


entity tb_scaler is
end tb_scaler;

architecture tb_scaler_arc of tb_scaler is
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

begin
   UUT : entity work.scaler
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
      ready_o        => ready_o);

   process
   begin
      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      sreset_i <= '0';

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      ready_i <= '1';

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      sop_i <= '1';
      data_i <= 20x"F";

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      sop_i <= '0';
      data_i <= 20x"FF";

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;


      eop_i <= '1';

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      eop_i <= '0';

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      sop_i <= '1';
      data_i <= 20x"0";

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      sop_i <= '0';
      data_i <= 20x"2";

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      data_i <= 20x"3";

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      data_i <= 20x"4";

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      data_i <= 20x"5";
      eop_i <= '1';

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      eop_i <= '0';

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      clk_i <= not clk_i;
      wait for 10ns;
      clk_i <= not clk_i;
      wait for 10ns;

      wait;
   end process;

end tb_scaler_arc;
