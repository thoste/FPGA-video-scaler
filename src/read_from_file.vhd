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

entity read_from_file is
end entity;

architecture read_from_file of read_from_file is
	file f: text open read_mode is "../data/test_file.txt";
	signal clk: bit := '0';
	signal t_out: time range 0ns to 800ns;
	signal i_out: natural range 0 to 7;
begin
	process
		variable l: line;
		variable str1: string(1 to 2);
		variable str2: string(1 to 3);
		variable t: time range 0ns to 800ns;
		variable i: natural range 0 to 7;
	begin
		wait for 50ns;
		clk <= '1';
		if not endfile(f) then	readline(f, 1);
			read(1, str1);
			read(1, t);
			read(1, str2);
			read(1, i);
			t_out <= t;
			i_out <= i;
		end if;
		wait for 50 ns;
		clk <= '0';
	end process;
end architecture;
		
