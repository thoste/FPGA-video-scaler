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

architecture scaler_tb_arch of scaler_tb is
	signal clk	 				: std_logic := '0';
	signal rst 					: std_logic := '1';
	
	signal startofpacket_in		: std_logic := '0';
	signal endofpacket_in		: std_logic := '0';
	signal data_in 				: bit_vector (19 downto 0);
	signal empty_in				: std_logic := '0';
	signal valid_in				: std_logic := '0';
	signal ready_sent			: std_logic;

	signal startofpacket_out	: std_logic;
	signal endofpacket_out		: std_logic;
	signal data_out				: bit_vector (19 downto 0);
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
			rst <= '0';
			clk <= '1';
			wait for 10ns;

			clk <= '0';
			data_in <= X"00005";
			wait for 10ns;

			clk <= '1';
			wait for 10ns;

			clk <= '0';
			wait for 10ns;

			clk <= '1';
			data_in <= X"00300";
			wait for 10ns;

			clk <= '0';
			wait for 10ns;

			clk <= '1';
			wait for 10ns;
			wait;
		end process;
			
end scaler_tb_arch;

