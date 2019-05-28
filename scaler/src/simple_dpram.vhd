--------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-03-11
-- Version: 0.1
--------------------------------------------------------
-- Description: Simple dual-port RAM
--------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity simple_dpram is
   generic (
      g_ram_width    : natural   := 8;
      g_ram_depth    : natural   := 32;
      g_ramstyle     : string    := "M20K";
      g_output_reg   : boolean   := false
   );
   port (   
      clk_i       : in std_logic;
      -- Write
      data_i      : in std_logic_vector(g_ram_width-1 downto 0);
      wr_addr_i   : in integer range 0 to g_ram_depth-1;
      wr_en_i     : in std_logic;
      -- Read
      data_o      : out std_logic_vector(g_ram_width-1 downto 0) := (others => '0');
      rd_addr_i   : in integer range 0 to g_ram_depth-1
   );
   
end simple_dpram;

architecture rtl of simple_dpram is
   -- RAM
   type t_ram is array (natural range <>) of std_logic_vector(g_ram_width-1 downto 0);
   signal ram_data      : t_ram(g_ram_depth-1 downto 0)              := (others => (others => '0'));
   signal ram_out       : std_logic_vector(g_ram_width-1 downto 0)   := (others => '0');
   signal ram_out_reg   : std_logic_vector(g_ram_width-1 downto 0)   := (others => '0');

   -- RAM style
   attribute ramstyle : string;
   attribute ramstyle of ram_data : signal is g_ramstyle;
begin

   p_ram : process(clk_i)
   begin
      if(rising_edge(clk_i)) then 
         -- Write to RAM
         if(wr_en_i = '1') then
            ram_data(wr_addr_i) <= data_i;
         end if;

         -- Read from RAM
         ram_out     <= ram_data(rd_addr_i);
         ram_out_reg <= ram_out;
      end if;
   end process p_ram;
   
   -- Outputs
   data_o <= ram_out_reg when g_output_reg else ram_out;

end rtl;
