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


library std
use std.textio.all;

entity write_to_file is
end entity;

architecture write_to_file of write_to_file is
	constant period: time := 100ns;
	signal clk: bit := '0';
	file f: text open write_mode is "../data/test_file.txt";
begin
	process
		constant str1: string(1 to 2) := "t=";
		constant str2: string(1 to 3) := " i=";
		variable l: line;
		variable t: time range 0ns to 800ns;
		variable i: natural range 0 to 7 := 0;
	begin
		wait for period/2;
		clk <= '1';
		t := period/2 + i*period;
		write(1, str1);
		write(1, t);
		write(1, str2);
		write(1, i);
		writeline(f, 1);
		i := i + 1;
		wait for period/2;
		clk <= '0';
	end process;
end architecture;