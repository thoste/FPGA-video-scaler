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
use ieee.numeric_std.all;


entity scaler is
   generic (
      g_data_width         : natural;
      g_empty_width        : natural;
      g_fifo_data_width    : natural;
      g_fifo_data_depth    : natural
   );
   port (
      clk_i             : in  std_logic;
      sreset_i          : in  std_logic;
      -- To scaler
      scaler_sop_i      : in  std_logic;
      scaler_eop_i      : in  std_logic;
      scaler_data_i     : in  std_logic_vector(g_data_width-1 downto 0);
      scaler_empty_i    : in  std_logic_vector(g_empty_width-1 downto 0);
      scaler_valid_i    : in  std_logic;
      scaler_ready_o    : out std_logic := '0';

      -- From scaler
      scaler_sop_o      : out std_logic := '0';
      scaler_eop_o      : out std_logic := '0';
      scaler_data_o     : out std_logic_vector(g_data_width-1 downto 0) := (others => '0');
      scaler_empty_o    : out std_logic_vector(g_empty_width-1 downto 0) := (others => '0');
      scaler_valid_o    : out std_logic := '0';
      scaler_ready_i    : in  std_logic
      
      );
end entity scaler;

architecture scaler_arc of scaler is
   constant c_data_range_fifo    : natural := g_data_width;
   constant c_empty_range_fifo   : natural := g_data_width + g_empty_width;
   constant c_sop_range_fifo     : natural := g_data_width + g_empty_width + 1;
   constant c_eop_range_fifo     : natural := g_data_width + g_empty_width + 2;

   -- Map different data signals to their respective range in FIFO data bus
   --type t_data_range_fifo     is range g_data_width - 1                 downto 0;
   --type t_empty_range_fifo    is range g_data_width + g_empty_width - 1 downto g_data_width;
   --type t_sop_range_fifo      is range g_data_width + g_empty_width     downto g_data_width + g_empty_width;
   --type t_eop_range_fifo      is range g_data_width + g_empty_width + 1 downto g_data_width + g_empty_width + 1;

   -- Controller
   signal ctrl_ready_i  : std_logic;
   signal ctrl_ready_o  : std_logic;
   signal ctrl_valid_i  : std_logic;

   --signal rx_video_width_o          : unsigned(15 downto 0);
   --signal rx_video_height_o         : unsigned(15 downto 0);
   --signal rx_video_interlacing_o    : unsigned(3 downto 0);
   --signal tx_video_width_o          : unsigned(15 downto 0);
   --signal tx_video_height_o         : unsigned(15 downto 0);
   --signal tx_video_scaling_method_o : unsigned(3 downto 0);

   -- Input FIFO
   signal fifo_in_wr_en_i        : std_logic;
   signal fifo_in_rd_en_i        : std_logic;
   signal fifo_in_data_i         : std_logic_vector(g_fifo_data_width-1 downto 0);
   signal fifo_in_full_o         : std_logic;
   signal fifo_in_almostfull_o   : std_logic;
   signal fifo_in_empty_o        : std_logic;
   signal fifo_in_data_o         : std_logic_vector(g_fifo_data_width-1 downto 0);
   --signal fifo_in_valid_o        : std_logic;
   signal fifo_in_data_reg       : std_logic_vector(g_fifo_data_width-1 downto 0);

   ---- Output FIFO
   --signal fifo_out_wr_en_i  : std_logic;
   --signal fifo_out_rd_en_i  : std_logic;
   --signal fifo_out_data_i   : std_logic_vector(g_fifo_data_width-1 downto 0);
   --signal fifo_out_full_o   : std_logic;
   --signal fifo_out_empty_o  : std_logic;
   --signal fifo_out_data_o   : std_logic_vector(g_fifo_data_width-1 downto 0);
begin
   scaler_controller : entity work.scaler_controller
   generic map(
      g_data_width     => g_data_width,
      g_empty_width    => g_empty_width
   )

   port map(
      clk_i             => clk_i,
      sreset_i          => sreset_i,
      -- To scaler_controller
      startofpacket_i   => fifo_in_data_o(c_sop_range_fifo-1),
      endofpacket_i     => fifo_in_data_o(c_eop_range_fifo-1),
      data_i            => fifo_in_data_o(c_data_range_fifo-1 downto 0),
      empty_i           => fifo_in_data_o(c_empty_range_fifo-1 downto c_data_range_fifo),
      valid_i           => ctrl_valid_i,
      ready_o           => ctrl_ready_o,

      -- From scaler_controller
      startofpacket_o   => scaler_sop_o,
      endofpacket_o     => scaler_eop_o,
      data_o            => scaler_data_o,
      empty_o           => scaler_empty_o,
      valid_o           => scaler_valid_o,
      ready_i           => ctrl_ready_i


      ---- Internal
      --rx_video_width_o           => rx_video_width_o,
      --rx_video_height_o          => rx_video_height_o,
      --rx_video_interlacing_o     => rx_video_interlacing_o,
      --tx_video_width_o           => tx_video_width_o,
      --tx_video_height_o          => tx_video_height_o,
      --tx_video_scaling_method_o  => tx_video_scaling_method_o,

      ---- Input FIFO
      --fifo_in_wr_en_i         => fifo_in_wr_en_i,
      --fifo_in_rd_en_i         => fifo_in_rd_en_i,
      --fifo_in_full_o          => fifo_in_full_o,
      --fifo_in_almostfull_o    => fifo_in_almostfull_o,
      --fifo_in_empty_o         => fifo_in_empty_o

      ---- Output FIFO
      --fifo_out_wr_en_i   => fifo_out_wr_en_i,
      --fifo_out_rd_en_i   => fifo_out_rd_en_i,
      --fifo_out_full_o    => fifo_out_full_o,
      --fifo_out_empty_o   => fifo_out_empty_o
   );

   fifo_in : entity work.fifo_generic
   generic map (
      g_width        => g_fifo_data_width,
      g_depth        => g_fifo_data_depth,
      g_ramstyle     => "M20K",
      g_output_reg   => true
   )
   port map(
      clk_i          => clk_i,
      sreset_i       => sreset_i,
      wr_en_i        => fifo_in_wr_en_i,
      rd_en_i        => fifo_in_rd_en_i,
      data_i         => fifo_in_data_i,
      full_o         => fifo_in_full_o,
      almostfull_o   => fifo_in_almostfull_o,
      empty_o        => fifo_in_empty_o,
      data_o         => fifo_in_data_o
   );

   --fifo_out : entity work.fifo_generic
   --generic map (
   --   g_width        => g_fifo_data_width,
   --   g_depth        => g_fifo_data_depth,
   --   g_ramstyle     => "M20K",
   --   g_output_reg   => true
   --)
   --port map(
   --   clk_i       => clk_i,
   --   sreset_i    => sreset_i,
   --   wr_en_i     => fifo_out_wr_en_i,
   --   rd_en_i     => fifo_out_rd_en_i,
   --   data_i      => fifo_out_data_i,
   --   full_o      => fifo_out_full_o,
   --   empty_o     => fifo_out_empty_o,
   --   data_o      => fifo_out_data_o
   --);


   ---- Map outputs signals to output FIFO
   --scaler_data_o     <= fifo_out_data_o(t_data_range_fifo);
   --scaler_empty_o    <= fifo_out_data_o(t_empty_range_fifo);
   --scaler_sop_o      <= fifo_out_data_o(t_sop_range_fifo);
   --scaler_eop_o      <= fifo_out_data_o(t_eop_range_fifo);

   --p_fill_fifo_in : process(clk_i) is
   --begin
   --   if rising_edge(clk_i) then
   --      -- Assert ready out as long as there is room in FIFO
   --      if fifo_in_almostfull_o = '1' or fifo_in_full_o = '1' then
   --         scaler_ready_o <= '0';
   --      else 
   --         scaler_ready_o <= '1';
   --      end if;

   --      -- Write to FIFO on valid_i if FIFO is not full
   --      if scaler_valid_i = '1' and fifo_in_full_o = '0' then
   --         fifo_in_wr_en_i <= '1';
   --      else
   --         fifo_in_wr_en_i <= '0';
   --      end if;

   --      -- Empty FIFO when controller is ready and FIFO is not empty
   --      if ctrl_ready_o = '1' and fifo_in_empty_o = '0' then
   --         fifo_in_rd_en_i   <= '1';
   --         ctrl_valid_i      <= '1';
   --      else
   --         fifo_in_rd_en_i   <= '0';
   --         ctrl_valid_i      <= '0';
   --      end if;
   --   end if; -- rising_edge(clk_i)
   --end process p_fill_fifo_in;

   -- NOT CORRECT!!!!!
   p_fifo_in : process(clk_i) is
   begin
      if rising_edge(clk_i) then  
         if fifo_in_rd_en_i = '1' then
            ctrl_valid_i <= '1';
         end if;
      end if;
   end process p_fifo_in;

   -- Read/write to fifo
   scaler_ready_o <= not(fifo_in_almostfull_o);
   fifo_in_wr_en_i <= '1' when scaler_valid_i = '1' and fifo_in_full_o = '0' else '0';
   fifo_in_rd_en_i <= '1' when (ctrl_ready_o = '1' and fifo_in_empty_o = '0') else '0';


   -- Map input data signals to input FIFO
   fifo_in_data_i(c_data_range_fifo-1 downto 0)                   <= scaler_data_i;
   fifo_in_data_i(c_empty_range_fifo-1 downto c_data_range_fifo)  <= scaler_empty_i;
   fifo_in_data_i(c_sop_range_fifo-1)                             <= scaler_sop_i;
   fifo_in_data_i(c_eop_range_fifo-1)                             <= scaler_eop_i;

   -- FIFO output
   ctrl_ready_i <= '1';

end scaler_arc;
