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
use ieee.fixed_pkg.all;
--use ieee.math_real.all;

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
   signal vid_width_ufixed    : ufixed(15 downto -8) := (others => '0');
   signal vid_height_ufixed   : ufixed(15 downto -8) := (others => '0');

   -- Framebuffer
   signal fb_data_i     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_wr_addr_i  : integer := 0;
   signal fb_wr_en_i    : std_logic := '0';
   signal fb_data_o     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_rd_addr_i  : integer := 0;


   signal fb_count : integer := 0;
   signal fb_full : boolean := false;

   signal dx : integer := 0;
   signal dy : integer := 0;
   signal x_count : integer := 0;
   signal y_count : integer := 0;

   signal out_count : integer := 0;
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
   vid_width_ufixed <= to_ufixed(6.30, vid_width_ufixed);   

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
         if out_count >= (g_tx_video_width*g_tx_video_height) then
            fb_full <= false;
         end if;
      end if;
   end process p_fb_full;

   p_nearest : process(clk_i) is
   begin
      if rising_edge(clk_i) then

         --if fb_full then
         --   dx := 3/2;
         --   dy := 3/2;

         --   fb_rd_addr_i <= g_rx_video_width*dy + dx;
         --end if;
         --scaler_data_o <= fb_data_o;

         if fb_full then
            dx <= x_count/(g_tx_video_width/g_rx_video_width);
            dy <= y_count/(g_tx_video_height/g_rx_video_height);

            fb_rd_addr_i <= g_rx_video_width*dy + dx;
            scaler_valid_o <= '0' when out_count < 3 else '1';

            out_count <= out_count + 1;

            x_count <= x_count + 1;

            if x_count = g_tx_video_width-1 then
               x_count <= 0;
               y_count <= 0 when y_count = g_tx_video_height-1 else y_count + 1 ;
            end if;

            --if y_count < g_tx_video_height and x_count = g_tx_video_width-1 then
               
            --   y_count <= y_count + 1;
            --   x_count <= 0;
            --end if;
            
            
            --if v_count = 2 then
            --   scaler_valid_o <= '1';
            --else
            --   v_count := v_count + 1;
            --end if;
            

            --if x_count = g_tx_video_width then
            --   x_count := 0;
            --end if;
            --if y_count = g_tx_video_height then
            --   y_count := 0;
            --end if;
            
            
         end if;
         scaler_data_o <= fb_data_o;
      end if;
   end process p_nearest;

end scaler_arc;