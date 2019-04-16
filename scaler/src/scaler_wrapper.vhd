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


entity scaler_wrapper is
   generic (
      g_data_width               : natural;
      g_empty_width              : natural;
      g_fifo_data_width          : natural;
      g_fifo_data_depth          : natural;
      g_tx_video_width           : natural;
      g_tx_video_height          : natural;
      g_tx_video_scaling_method  : natural
   );
   port (
      clk_i       : in  std_logic;
      sreset_i    : in  std_logic;
      -- To scaler
      startofpacket_i   : in  std_logic;
      endofpacket_i     : in  std_logic;
      data_i            : in  std_logic_vector(g_data_width-1 downto 0);
      empty_i           : in  std_logic_vector(g_empty_width-1 downto 0);
      valid_i           : in  std_logic;
      ready_o           : out std_logic := '0';

      -- From scaler
      startofpacket_o   : out std_logic := '0';
      endofpacket_o     : out std_logic := '0';
      data_o            : out std_logic_vector(g_data_width-1 downto 0) := (others => '0');
      empty_o           : out std_logic_vector(g_empty_width-1 downto 0) := (others => '0');
      valid_o           : out std_logic := '0';
      ready_i           : in  std_logic
   );
end entity scaler_wrapper;

architecture scaler_wrapper_arc of scaler_wrapper is
   --constant c_data_range_fifo    : natural := g_data_width;
   --constant c_empty_range_fifo   : natural := g_data_width + g_empty_width;
   --constant c_sop_range_fifo     : natural := g_data_width + g_empty_width + 1;
   --constant c_eop_range_fifo     : natural := g_data_width + g_empty_width + 2;

   -- Controller
   signal ctrl_ready_i  : std_logic;
   signal ctrl_ready_o  : std_logic;
   signal ctrl_valid_i  : std_logic;
   signal ctrl_valid_o  : std_logic;

   signal rx_video_width_o          : std_logic_vector(15 downto 0);
   signal rx_video_height_o         : std_logic_vector(15 downto 0);

   -- Framebuffer
   signal fb_data_i     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_wr_addr_i  : integer := 0;
   signal fb_wr_en_i    : std_logic := '0';
   signal fb_data_o     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_rd_addr_i  : integer := 0;

   ---- Input FIFO
   --signal fifo_in_wr_en_i        : std_logic;
   --signal fifo_in_rd_en_i        : std_logic;
   --signal fifo_in_data_i         : std_logic_vector(g_fifo_data_width-1 downto 0);
   --signal fifo_in_full_o         : std_logic;
   --signal fifo_in_almostfull_o   : std_logic;
   --signal fifo_in_empty_o        : std_logic;
   --signal fifo_in_data_o         : std_logic_vector(g_fifo_data_width-1 downto 0);
   --signal fifo_in_data_reg       : std_logic_vector(g_fifo_data_width-1 downto 0);

begin
   scaler_controller : entity work.scaler_controller
   generic map(
      g_data_width      => g_data_width,
      g_empty_width     => g_empty_width,
      g_tx_video_width  => g_tx_video_width,
      g_tx_video_height => g_tx_video_height,
      g_tx_video_scaling_method => g_tx_video_scaling_method
   )

   port map(
      clk_i             => clk_i,
      sreset_i          => sreset_i,
      -- To scaler_controller
      --startofpacket_i   => fifo_in_data_o(c_sop_range_fifo-1),
      --endofpacket_i     => fifo_in_data_o(c_eop_range_fifo-1),
      --data_i            => fifo_in_data_o(c_data_range_fifo-1 downto 0),
      --empty_i           => fifo_in_data_o(c_empty_range_fifo-1 downto c_data_range_fifo),
      ctrl_startofpacket_i   => startofpacket_i,
      ctrl_endofpacket_i     => endofpacket_i,
      ctrl_data_i            => data_i,
      ctrl_empty_i           => empty_i,
      ctrl_valid_i           => ctrl_valid_i,
      ctrl_ready_o           => ctrl_ready_o,

      -- From scaler_controller
      ctrl_startofpacket_o   => startofpacket_o,
      ctrl_endofpacket_o     => endofpacket_o,
      ctrl_data_o            => fb_data_i,
      ctrl_empty_o           => empty_o,
      ctrl_valid_o           => ctrl_valid_o,
      ctrl_ready_i           => ctrl_ready_i,

      -- Config
      rx_video_width_o           => rx_video_width_o,
      rx_video_height_o          => rx_video_height_o,

      -- Framebuffer
      fb_wr_addr        => fb_wr_addr_i,
      fb_wr_en          => fb_wr_en_i

      ---- Input FIFO
      --fifo_in_wr_en_i         => fifo_in_wr_en_i,
      --fifo_in_rd_en_i         => fifo_in_rd_en_i,
      --fifo_in_full_o          => fifo_in_full_o,
      --fifo_in_almostfull_o    => fifo_in_almostfull_o,
      --fifo_in_empty_o         => fifo_in_empty_o
   );

   ctrl_ready_i   <= ready_i;
   ctrl_valid_i   <= valid_i;
   ready_o        <= ctrl_ready_o;
   valid_o        <= ctrl_valid_o;

   framebuffer : entity work.simple_dpram
   generic map (
      g_ram_width    => g_data_width,
      g_ram_depth    => 20,
      g_ramstyle     => "M20K",
      g_output_reg   => true
   )
   port map(
      clk_i          => clk_i,
      -- Write
      data_i         => fb_data_i,
      wr_addr_i      => fb_wr_addr_i,
      wr_en_i        => fb_wr_en_i,
      -- Read
      data_o         => fb_data_o,
      rd_addr_i      => fb_rd_addr_i
   );

   p_empty_framebuffer : process(clk_i) is
      variable v_index : integer := 0;
   begin
      if rising_edge(clk_i) then
         fb_rd_addr_i <= v_index;
         data_o <= fb_data_o;
         v_index := v_index + 1;
         if v_index = 19 then
            v_index := 0;
         end if;
      end if;
   end process p_empty_framebuffer;


   --fifo_in : entity work.fifo_generic
   --generic map (
   --   g_width        => g_fifo_data_width,
   --   g_depth        => g_fifo_data_depth,
   --   g_ramstyle     => "M20K",
   --   g_output_reg   => true
   --)
   --port map(
   --   clk_i          => clk_i,
   --   sreset_i       => sreset_i,
   --   wr_en_i        => fifo_in_wr_en_i,
   --   rd_en_i        => fifo_in_rd_en_i,
   --   data_i         => fifo_in_data_i,
   --   full_o         => fifo_in_full_o,
   --   almostfull_o   => fifo_in_almostfull_o,
   --   empty_o        => fifo_in_empty_o,
   --   data_o         => fifo_in_data_o
   --);

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

   ---- NOT CORRECT!!!!!
   --p_fifo_in : process(clk_i) is
   --begin
   --   if rising_edge(clk_i) then  
   --      if fifo_in_rd_en_i = '1' then
   --         ctrl_valid_i <= '1';
   --      end if;
   --   end if;
   --end process p_fifo_in;

   ---- Read/write to fifo
   --scaler_ready_o <= not(fifo_in_almostfull_o);
   --fifo_in_wr_en_i <= '1' when scaler_valid_i = '1' and fifo_in_full_o = '0' else '0';
   --fifo_in_rd_en_i <= '1' when (ctrl_ready_o = '1' and fifo_in_empty_o = '0') else '0';


   ---- Map input data signals to input FIFO
   --fifo_in_data_i(c_data_range_fifo-1 downto 0)                   <= scaler_data_i;
   --fifo_in_data_i(c_empty_range_fifo-1 downto c_data_range_fifo)  <= scaler_empty_i;
   --fifo_in_data_i(c_sop_range_fifo-1)                             <= scaler_sop_i;
   --fifo_in_data_i(c_eop_range_fifo-1)                             <= scaler_eop_i;

   ---- FIFO output
   --ctrl_ready_i <= '1';

end scaler_wrapper_arc;
