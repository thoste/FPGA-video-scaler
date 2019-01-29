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


entity circuit is 
	port(
		a, b	: in std_ulogic;
		q		: out std_ulogic
	);
end entity circuit;

architecture behaviour of circuit is
	--signal q_internal : std_ulogic;
	
	begin
		q <= a and b;
		--q <= q_internal;
		
		--process(a,b,q_internal)
		--begin
		--	q_internal <= a and b;
		--end process;
	
end architecture behaviour;

