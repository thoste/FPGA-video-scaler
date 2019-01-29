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


entity scaler_tb is
end scaler_tb;

architecture scaler_tb_arc of scaler_tb is
	signal clk	 				: std_logic := '0';
	signal rst 					: std_logic := '1';
	
	signal startofpacket_in		: std_logic := '0';
	signal endofpacket_in		: std_logic := '0';
	signal data_in 				: std_logic_vector (19 downto 0);
	signal empty_in				: std_logic := '0';
	signal valid_in				: std_logic := '0';
	signal ready_sent			: std_logic;

	signal startofpacket_out	: std_logic;
	signal endofpacket_out		: std_logic;
	signal data_out				: std_logic_vector (19 downto 0);
	signal empty_out			: std_logic;
	signal valid_out			: std_logic;
	signal ready_recieved		: std_logic := '0';
	
	begin
		UUT : entity work.scaler
			port map(
				clk => clk,
				rst => rst,
				startofpacket_in => startofpacket_in,
				endofpacket_in => endofpacket_in,
				data_in => data_in,
				empty_in => empty_in,
				valid_in => valid_in,
				ready_sent => ready_sent,
				startofpacket_out => startofpacket_out,
				endofpacket_out => endofpacket_out,
				data_out => data_out,
				empty_out => empty_out,
				valid_out => valid_out,
				ready_recieved => ready_recieved
			);

		process
		begin
			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			rst <= '0';

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			ready_recieved <= '1';

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			startofpacket_in <= '1';
			data_in <= 20x"F";

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			startofpacket_in <= '0';
			data_in <= 20x"FF";

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;


			endofpacket_in <= '1';

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			endofpacket_in <= '0';

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			startofpacket_in <= '1';
			data_in <= 20x"0";

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			startofpacket_in <= '0';
			data_in <= 20x"2";

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			data_in <= 20x"3";

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			data_in <= 20x"4";

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			data_in <= 20x"5";
			endofpacket_in <= '1';

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			endofpacket_in <= '0';

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			clk <= not clk;
			wait for 10ns;
			clk <= not clk;
			wait for 10ns;

			wait;
		end process;
			
end scaler_tb_arc;

