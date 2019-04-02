library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity syntest_fifo_generic is
   --generic(
   --   g_num_inputs : natural := 1;
   --   g_data_width : integer := 8
   --);
   port(
      clk_i         : in  std_logic;
      sink_o        : out std_logic
   );
end entity syntest_fifo_generic;

architecture rtl of syntest_fifo_generic is
   signal source : std_logic_vector(22 downto 0) := (others => '0');
   signal sink   : std_logic_vector(21  downto 0) := (others => '0');

begin

   i_mut : entity work.fifo_generic
   generic map(
      g_width => 20,
      g_depth => 64
   )
   port map(
      clk_i       => clk_i,
      sreset_i    => source(0),
      data_i      => source(20 downto 1),
      wr_en_i     => source(21),
      rd_en_i     => source(22),
      full_o      => sink(0),
      data_o      => sink(20 downto 1),
      empty_o     => sink(21)
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
