library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;


entity simple_dpram is
	generic (
			g_word_size 	: natural;
			g_word_count 	: natural
		);
	port (	
		clk_i			: in std_logic;
		sreset_i		: in std_logic;
		-- To RAM
		data_i		: in std_logic_vector(g_word_size-1 downto 0);
		wr_addr_i	: in std_logic_vector(integer(ceil(log2(real(g_word_count))))-1 downto 0);
		wr_en_i		: in std_logic;
		-- From RAM
		q_o			: out std_logic_vector(g_word_size-1 downto 0);
		rd_addr_i	: in std_logic_vector(integer(ceil(log2(real(g_word_count))))-1 downto 0)
	);
	
end simple_dpram;

architecture rtl of simple_dpram is
	
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(g_word_size-1 downto 0);
	type memory_t is array(g_word_count-1 downto 0) of word_t;
	
	-- Declare the RAM
	shared variable ram : memory_t;

begin

	process(clk_i)
	begin
		if(rising_edge(clk_i)) then 
			if(wr_en_i = '1') then
				ram(to_integer(unsigned(wr_addr_i))) := data_i;
			end if;
			q_o <= ram(to_integer(unsigned(rd_addr_i)));
		
			if (sreset_i = '1') then
            -- reset ram
         end if;
		end if;
	end process;
	
end rtl;
