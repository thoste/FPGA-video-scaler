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
   type t_state is (s_idle, s_pre_fill_fb, s_process);
   signal state : t_state := s_idle;

   constant C_LINE_BUFFERS : integer := 4;

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

   signal fb_last_addr     : integer := 0;
   signal interpolate      : boolean := false;

   -- Mapping function
   signal dx            : ufixed(15 downto -10) := (others => '0');
   signal dy            : ufixed(15 downto -10) := (others => '0');
   signal dx_reg        : ufixed(15 downto -10) := (others => '0');
   signal dy_reg        : ufixed(15 downto -10) := (others => '0');
   signal dx_int        : integer := 0;
   signal dy_int        : integer := 0;
   signal x_count       : integer := 0;
   signal y_count       : integer := 0;


   signal tot_count : integer := 0;

   signal exp_input : integer := 0;
   signal cur_input : integer := 0;
   signal exp_output : integer := 0;
   signal cur_output : integer := 0;
   
   signal up_input : integer := 0;
   signal down_input : integer := 0;
   signal up_output : integer := 0;
   signal down_output : integer := 0;

   signal fsm_ready     : std_logic := '0';

   signal avalon_ready : boolean := true;
   signal avalon_ready_2 : boolean := true;

   

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
   exp_input <= g_rx_video_width*g_rx_video_height;
   exp_output <= g_tx_video_width*g_tx_video_height;
   
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
               -- Pre-fill framebuffer before starting the scaler
               if scaler_valid_i = '1' then
                  scaler_ready_o <= '1';
                  fb_wr_en_i <= '1';
                  fb_wr_addr <= 0 when (fb_wr_addr = (g_rx_video_width*C_LINE_BUFFERS)-1) else fb_wr_addr + 1;
                  cur_input <= cur_input + 1;
                  down_input <= down_input + 1;
                  if fb_wr_addr = (g_rx_video_width*C_LINE_BUFFERS)-2 then
                     --up_input <= up_input + C_LINE_BUFFERS;
                     scaler_ready_o <= '0';
                     interpolate <= true;
                     state <= s_process;
                  end if;
               end if;

            when s_process =>
               if g_rx_video_width < g_tx_video_width then
                  -- Upscaling
                  -- Cannot write before the fb_addr has been read
                  -- It is faster to fill the fb than to empty it
                  tot_count <= up_output/sf;
                  if up_output/sf > up_input then
                     scaler_ready_o <= '1';
                     if scaler_valid_i = '1' then
                        fb_wr_addr <= 0 when (fb_wr_addr = (g_rx_video_width*C_LINE_BUFFERS)-1) else fb_wr_addr + 1;
                        fb_wr_en_i <= '1';
                        cur_input <= cur_input + 1;
                     end if;                  
                  else
                     scaler_ready_o <= '0';
                     fb_wr_en_i <= '0';
                  end if;
                  up_input <= fb_wr_addr/(g_rx_video_width-1);

                  interpolate <= true;
               else
                  -- Downscaling
                  -- Cannot read before the fb_addr has been written
                  -- It is faster to empty the fb than to fill it
               end if;

               ---- Old code
               --if v_count = exp_output/exp_input and cur_input < exp_input then
               --   fb_wr_addr <= 0 when (fb_wr_addr = (g_rx_video_width*C_LINE_BUFFERS)-1) else fb_wr_addr + 1;
               --   scaler_ready_o <= '1';
               --   fb_wr_en_i <= '1';
               --   v_count := 0;
               --   cur_input <= cur_input + 1;   
               --   --up_input <= up_input + 1 when (fb_wr_addr mod (g_rx_video_width-1) = 0) else up_input;         
               --   up_input <= fb_wr_addr/(g_rx_video_width-1); 
               --else
               --   scaler_ready_o <= '0';
               --   fb_wr_en_i <= '0';
               --   v_count := v_count + 1;
               --end if;

               if cur_input >= exp_input-1 then
                  -- Done filling fb
                  scaler_ready_o <= '0';            
               end if; 

               if cur_output >= exp_output+2 then
                  interpolate <= false;
               end if;
               if cur_output >= exp_output+6 then
                  scaler_ready_o <= '1';
                  state <= s_idle;
               end if;
               cur_output <= cur_output + 1;

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
            dx <= resize(x_count*sr_width_reg, dx'high, dx'low);
            dy <= resize(y_count*sr_height_reg, dy'high, dy'low);

            dx_reg <= dx;
            dy_reg <= dy;

            -- Next pixel in target frame
            x_count <= x_count + 1;
            
            -- Check if a row in target frame is completed
            if x_count = g_tx_video_width-1 then
               x_count <= 0;
               y_count <= y_count + 1;
               up_output <= up_output + 1 when ((dy_int mod 1 = 0) or (dy_int mod 2 = 0)) else up_output;
            end if;

            -- Check if all rowns in line buffer is completed
            if dy_reg >= C_LINE_BUFFERS then
               y_count <= 0;
               dy_int <= 0;
            else
               dy_int <= to_integer(dy_reg);
            end if;

            dx_int <= to_integer(dx_reg);
            fb_rd_addr_i <= g_rx_video_width*dy_int + dx_int;
         end if;

         scaler_data_o <= fb_data_o;
      end if;
   end process p_reverse_mapping;


end scaler_arc;