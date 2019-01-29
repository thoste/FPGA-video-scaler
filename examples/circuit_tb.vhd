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


entity circuit_tb is
end circuit_tb;

architecture tb_behaviour of circuit_tb is
	component circuit
		port(
			a, b : in std_ulogic;
			q : out std_ulogic
		);
	end component;
	
	signal a : std_ulogic;
	signal b : std_ulogic;
	signal q : std_ulogic;
	
	begin
	UUT : circuit
		port map(
			a => a,
			b => b,
			q => q
		);
		
	process
	begin
		a <= '0';
		b <= '1';
		wait for 10ns;
		a <= '1';
		wait for 10ns;
		b <= '0';
		wait for 10ns;
		a <= '0';
		wait for 10ns;
		wait;
	end process;
end tb_behaviour;

configuration tb_for_circuit of circuit_tb is
	for tb_behaviour
		for UUT : circuit
			use entity work.circuit(structural);
		end for;
	end for;
end tb_for_circuit;
