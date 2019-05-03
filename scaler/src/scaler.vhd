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

      scaler_startofpacket_i  : in  std_logic;
      scaler_endofpacket_i    : in  std_logic;
      scaler_data_i           : in  std_logic_vector(g_data_width-1 downto 0);
      scaler_valid_i          : in  std_logic;
      scaler_ready_o          : out std_logic := '0';

      scaler_startofpacket_o  : in  std_logic := '0';
      scaler_endofpacket_o    : in  std_logic := '0';
      scaler_data_o           : out std_logic_vector(g_data_width-1 downto 0) := (others => '0');
      scaler_valid_o          : out std_logic := '0';
      scaler_ready_i          : in  std_logic
   );
end scaler;

architecture scaler_arc of scaler is
   type t_state is (s_idle, s_pre_fill_fb, s_process, s_empty_fb);
   signal state : t_state := s_idle;

    --Scaling ratio
   signal sr_width         : ufixed(7 downto -10) := (others => '0');
   signal sr_height        : ufixed(7 downto -10) := (others => '0');
   signal sr_width_reg     : ufixed(7 downto -10) := (others => '0');
   signal sr_height_reg    : ufixed(7 downto -10) := (others => '0');

   signal sf : integer := 0;

   signal tx_width         : ufixed(11 downto -6) := (others => '0');
   signal tx_height        : ufixed(11 downto -6) := (others => '0');
   signal rx_width         : ufixed(11 downto -6) := (others => '0');
   signal rx_height        : ufixed(11 downto -6) := (others => '0');

   signal tx_width_reg     : ufixed(11 downto -6) := (others => '0');
   signal tx_height_reg    : ufixed(11 downto -6) := (others => '0');
   signal rx_width_reg     : ufixed(11 downto -6) := (others => '0');
   signal rx_height_reg    : ufixed(11 downto -6) := (others => '0');

   -- Framebuffer
   signal fb_wr_en_i       : std_logic := '0';
   signal fb_data_i        : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_wr_addr_i     : integer := 0;
   signal fb_wr_addr       : integer := 0;

   signal fb_data_o        : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_rd_addr_i     : integer := 0;
   signal fb_rd_addr       : integer := 0;

   signal fb_last_addr     : integer := 0;
   signal interpolate      : boolean := false;

   -- Mapping function
   signal dx            : ufixed(15 downto -2) := (others => '0');
   signal dy            : ufixed(15 downto -2) := (others => '0');
   signal dx_reg        : ufixed(15 downto -2) := (others => '0');
   signal dy_reg        : ufixed(15 downto -2) := (others => '0');
   signal dx_int        : integer := 0;
   signal dy_int        : integer := 0;
   signal x_count       : integer := 0;
   signal y_count       : integer := 0;
   signal x_count_reg   : integer := 0;
   signal y_count_reg   : integer := 0;

   signal fsm_ready     : std_logic := '0';

   constant C_LINE_BUFFERS : integer := 4;

begin
   framebuffer : entity work.simple_dpram
   generic map (
      g_ram_width    => g_data_width,
      g_ram_depth    => g_rx_video_width*C_LINE_BUFFERS,
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

   -- Calc scaling ratio
   rx_width       <= to_ufixed(g_rx_video_width, rx_width_reg);
   rx_height      <= to_ufixed(g_rx_video_height, rx_width_reg);
   tx_width       <= to_ufixed(g_tx_video_width, tx_width_reg);
   tx_height      <= to_ufixed(g_tx_video_height, tx_width_reg);
   rx_width_reg   <= rx_width;
   rx_height_reg  <= rx_height;
   tx_width_reg   <= tx_width;
   tx_height_reg  <= tx_height;
   
   sr_width       <= resize(1/(tx_width_reg/rx_width_reg), sr_width'high, sr_width'low);  
   sr_height      <= resize(1/(tx_height_reg/rx_height_reg), sr_height'high, sr_height'low);
   sr_width_reg   <= sr_width;
   sr_height_reg  <= sr_height;

   sf <= to_integer(tx_width_reg/rx_width_reg);
   --sr_width_reg   <= to_ufixed(0.4, sr_width_reg);
   --sr_height_reg  <= to_ufixed(0.4, sr_height_reg); 
   
   -- Asseart ready out
   --scaler_ready_o <= (scaler_ready_i or not scaler_valid_o) and fsm_ready;

   p_fsm : process(clk_i) is
      variable v_count : integer := 0;
   begin
      if rising_edge(clk_i) then
         case(state) is
            when s_idle => 
               scaler_ready_o <= '1';
               if scaler_startofpacket_i = '1' then
                  state <= s_pre_fill_fb;
               end if;

            when s_pre_fill_fb =>
               -- Pre-fill 2 lines of pixels before starting the scaler
               scaler_ready_o <= '1';
               fb_wr_en_i <= '1';
               fb_wr_addr <= fb_wr_addr + 1;
               if fb_wr_addr = (g_rx_video_width*2)-1 then
                  scaler_ready_o <= '0';
                  interpolate <= true;
                  state <= s_process;
               end if;

            when s_process =>
               if v_count = (sf*sf) then
                  fb_wr_addr <= 0 when (fb_wr_addr = (g_rx_video_width*C_LINE_BUFFERS)-1) else fb_wr_addr + 1;
                  scaler_ready_o <= '1';
                  fb_wr_en_i <= '1';
                  v_count := 0;
               else
                  scaler_ready_o <= '0';
                  fb_wr_en_i <= '0';
                  v_count := v_count + 1;
               end if;
               if scaler_endofpacket_i = '1' then
                  fb_last_addr <= fb_wr_addr;
                  state <= s_empty_fb;
               end if;

            when s_empty_fb =>
               if fb_rd_addr_i = fb_last_addr then
                  interpolate <= false;
                  state <= s_idle;
               end if;
               

         end case;

         fb_wr_addr_i <= fb_wr_addr;
         fb_data_i <= scaler_data_i;

         if sreset_i = '1' then
            state <= s_idle;
         end if;
      end if;
   end process p_fsm;



   p_reverse_mapping : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if interpolate then
            --dx <= resize(x_count*sr_width_reg, dx'high, dx'low);
            --dy <= resize(y_count*sr_height_reg, dy'high, dy'low);
            dx <= resize((x_count*sr_width_reg) + (0.5 * (1 - 1*sr_width_reg)), dx'high, dx'low);
            dy <= resize((y_count*sr_height_reg) + (0.5 * (1 - 1*sr_height_reg)), dy'high, dy'low);

            dx_int <= to_integer(dx);
            dy_int <= to_integer(dy);

            fb_rd_addr_i <= g_rx_video_width*to_integer(dy) + to_integer(dx);

            -- Next pixel in target frame
            x_count <= x_count + 1;
            
            -- Check if a row in target frame is completed
            if x_count = g_tx_video_width-1 then
               x_count <= 0;
               y_count <= y_count + 1;
            end if;

            -- Check if all rows are completed
            if y_count = C_LINE_BUFFERS and x_count = g_tx_video_width-2 then
               y_count <= 0;
            end if;
         end if;

         scaler_data_o <= fb_data_o;
      end if;
   end process p_reverse_mapping;


end scaler_arc;