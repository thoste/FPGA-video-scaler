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
--use ieee.fixed_pkg.all;
--use ieee.math_real.all;

use work.my_fixed_pkg.all;

entity scaler is
   generic (
      g_data_width         : natural;
      g_rx_video_width     : natural;
      g_rx_video_height    : natural;
      g_tx_video_width     : natural;
      g_tx_video_height    : natural
   );
   port (
      clk_i             : in  std_logic;
      sreset_i          : in  std_logic;

      scaler_data_i     : in  std_logic_vector(g_data_width-1 downto 0);
      scaler_valid_i    : in  std_logic;
      scaler_ready_o    : out std_logic := '0';

      scaler_data_o     : out std_logic_vector(g_data_width-1 downto 0) := (others => '0');
      scaler_valid_o    : out std_logic := '0';
      scaler_ready_i    : in  std_logic
   );
end scaler;

architecture scaler_arc of scaler is
   signal vid_width_ufixed    : ufixed(12 downto -6) := (others => '0');
   signal vid_height_ufixed   : ufixed(12 downto -6) := (others => '0');

   signal tx_width_ufixed    : ufixed(12 downto -6) := (others => '0');
   signal tx_height_ufixed    : ufixed(12 downto -6) := (others => '0');
   signal rx_width_ufixed    : ufixed(12 downto -6) := (others => '0');
   signal rx_height_ufixed    : ufixed(12 downto -6) := (others => '0');

   -- Framebuffer
   signal fb_data_i     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_wr_addr_i  : integer := 0;
   signal fb_wr_en_i    : std_logic := '0';
   signal fb_data_o     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_rd_addr_i  : integer := 0;


   signal fb_count : integer := 0;
   signal fb_full : boolean := false;

   signal dx : ufixed(18 downto -13) := (others => '0');
   signal dy : ufixed(18 downto -13) := (others => '0');
   signal x_count : integer := 0;
   signal y_count : integer := 0;

   signal out_count : integer := 0;
   signal frame_done : boolean := false;

begin
   framebuffer : entity work.simple_dpram
   generic map (
      g_ram_width    => g_data_width,
      g_ram_depth    => g_rx_video_width*g_rx_video_height,
      g_ramstyle     => "M20K",
      g_output_reg   => false
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

   -- Calc scaling ratio
   rx_width_ufixed <= to_ufixed(g_rx_video_width, rx_width_ufixed);
   rx_height_ufixed <= to_ufixed(g_rx_video_height, rx_width_ufixed);
   tx_width_ufixed <= to_ufixed(g_tx_video_width, tx_width_ufixed);
   tx_height_ufixed <= to_ufixed(g_tx_video_height, tx_width_ufixed);
   vid_width_ufixed <= resize(tx_width_ufixed/rx_width_ufixed, vid_width_ufixed'high, vid_width_ufixed'low);  
   vid_height_ufixed <= resize(tx_height_ufixed/rx_height_ufixed, vid_height_ufixed'high, vid_height_ufixed'low);  
   
   -- Asseart ready out
   scaler_ready_o <= scaler_ready_i or not scaler_valid_o;

   p_fill_fb : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if scaler_ready_o = '1' and scaler_valid_i = '1' then
            if fb_count <  g_rx_video_width*g_rx_video_height then
               fb_wr_en_i <= '1';
               fb_wr_addr_i <= fb_count;
               fb_data_i <= scaler_data_i;
               fb_count <= fb_count + 1;
            end if;
         end if;
      end if;
   end process p_fill_fb;


   p_fb_full : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if fb_count = g_rx_video_width*g_rx_video_height then 
            fb_full <= true;
         end if;
         if frame_done then
            fb_full <= false;
         end if;
      end if;
   end process p_fb_full;


   p_reverse_mapping : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if fb_full then
               --dx <= x_count/vid_width_ufixed;
               --dy <= y_count/vid_width_ufixed;
               dx <= resize(x_count/vid_width_ufixed, dx'high, dx'low);
               dy <= resize(y_count/vid_height_ufixed, dy'high, dy'low);

               --dx <= (x_count/vid_width_ufixed) + (0.5 * (1 - 1/vid_width_ufixed));
               --dy <= (y_count/vid_height_ufixed) + (0.5 * (1 - 1/vid_height_ufixed));
               --dx <= resize((x_count/vid_width_ufixed) + (0.5 * (1 - 1/vid_width_ufixed)), dx'high, dx'low);
               --dy <= resize((y_count/vid_height_ufixed) + (0.5 * (1 - 1/vid_height_ufixed)), dy'high, dy'low);
               
               x_count <= x_count + 1;

               if x_count = g_tx_video_width-1 then
                  x_count <= 0;
                  y_count <= y_count + 1;
               end if;

               if y_count = g_tx_video_height-1 and x_count = g_tx_video_width-2 then
                  frame_done <= true;
               end if;

               out_count <= out_count + 1;
            end if;
         end if;
   end process p_reverse_mapping;


   p_interpolation : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if fb_full then
            fb_rd_addr_i <= g_rx_video_width*to_integer(dy) + to_integer(dx);    
            scaler_valid_o <= '1'; 
         end if;
         scaler_data_o <= fb_data_o;
      end if;
   end process p_interpolation;

end scaler_arc;