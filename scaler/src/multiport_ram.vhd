--------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-03-11
-- Version: 0.1
--------------------------------------------------------
-- Description: Multiport RAM consisting of
--              4 simple dual-port RAMs
--------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiport_ram is
   generic (
      g_ram_width    : natural   := 8;
      g_ram_depth    : natural   := 32;
      g_ramstyle     : string    := "M20K";
      g_output_reg   : boolean   := false
   );
   port (   
      clk_i          : in std_logic;
      -- Write
      data_i         : in std_logic_vector(g_ram_width-1 downto 0);
      wr_addr_i      : in integer range 0 to g_ram_depth-1;
      wr_en_i        : in std_logic;
      -- Read
      data_a_o       : out std_logic_vector(g_ram_width-1 downto 0) := (others => '0');
      data_b_o       : out std_logic_vector(g_ram_width-1 downto 0) := (others => '0');
      data_c_o       : out std_logic_vector(g_ram_width-1 downto 0) := (others => '0');
      data_d_o       : out std_logic_vector(g_ram_width-1 downto 0) := (others => '0');
      rd_addr_a_i    : in integer range 0 to g_ram_depth-1;
      rd_addr_b_i    : in integer range 0 to g_ram_depth-1;
      rd_addr_c_i    : in integer range 0 to g_ram_depth-1;
      rd_addr_d_i    : in integer range 0 to g_ram_depth-1
   );
end multiport_ram;

architecture rtl of multiport_ram is
   constant C_NUM_PORTS    : integer := 4;

   type t_read_addr is array(0 to C_NUM_PORTS-1) of integer range 0 to g_ram_depth-1;
   type t_read_data is array(0 to C_NUM_PORTS-1) of std_logic_vector(g_ram_width-1 downto 0);

   signal read_addr : t_read_addr;
   signal read_data : t_read_data;

   component simple_dpram
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
   end component;

begin

   g_multiport_ram : for i in 0 to C_NUM_PORTS-1 generate
      u_simple_dpram : simple_dpram
      generic map (
         g_ram_width    => g_ram_width,
         g_ram_depth    => g_ram_depth,
         g_ramstyle     => "M20K",
         g_output_reg   => true
      )
      port map(
         clk_i          => clk_i,
         -- Write
         data_i         => data_i,
         wr_addr_i      => wr_addr_i,
         wr_en_i        => wr_en_i,
         -- Read
         data_o         => read_data(i),
         rd_addr_i      => read_addr(i)
      );
   end generate g_multiport_ram;

   data_a_o <= read_data(0);
   data_b_o <= read_data(1);
   data_c_o <= read_data(2);
   data_d_o <= read_data(3);

   read_addr(0) <= rd_addr_a_i;
   read_addr(1) <= rd_addr_b_i;
   read_addr(2) <= rd_addr_c_i;
   read_addr(3) <= rd_addr_d_i;   

end rtl;