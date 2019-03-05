library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity syntest_simple_dpram is
   generic(
      g_num_inputs : natural := 1;
      g_data_width : integer := 8
   );
   port(
      clk_i         : in  std_logic;
      sink_o        : out std_logic
   );
end entity syntest_simple_dpram;

architecture rtl of syntest_simple_dpram is
   signal source : std_logic_vector(40 downto 0) := (others => '0');
   signal sink   : std_logic_vector(9  downto 0) := (others => '0');

begin

   i_mut : entity work.simple_dpram
   generic map(
      g_word_size => 10,
      g_word_count => 23040
   )
   port map(
      clk_i       => clk_i,
      sreset_i    => source(0),
      wr_en_i     => source(1),
      data_i      => source(10 downto 1),
      wr_addr_i   => source(25 downto 11),
      rd_addr_i   => source(40 downto 26),
      q_o   => sink(9 downto 0)
   );

   i_source : entity work.atv_dummy_source
   generic map (
      g_ports   => source'length
   )
   port map (
      clk_i     => clk_i,
      outputs_o => source
   );

   i_sink : entity work.atv_dummy_sink
   generic map (
      g_ports  => sink'length
   )
   port map (
      clk_i    => clk_i,
      inputs_i => sink,
      output_o => sink_o
   );

end architecture;
