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

      scaler_startofpacket_o  : out std_logic := '0';
      scaler_endofpacket_o    : out std_logic := '0';
      scaler_data_o           : out std_logic_vector(g_data_width-1 downto 0) := (others => '0');
      scaler_valid_o          : out std_logic := '0';
      scaler_ready_i          : in  std_logic
   );
end scaler;

architecture scaler_arc of scaler is
   type t_state is (s_idle, s_pre_fill_fb, s_finish_fill_fb, s_upscale, s_upscale_and_fill);
   signal state : t_state := s_idle;

   constant C_LINE_BUFFERS : integer := 4;

    --Scaling ratio
   signal sr_width         : ufixed(5 downto -12) := (others => '0');
   signal sr_height        : ufixed(5 downto -12) := (others => '0');
   signal sr_width_reg     : ufixed(5 downto -12) := (others => '0');
   signal sr_height_reg    : ufixed(5 downto -12) := (others => '0');

   signal tx_width         : ufixed(11 downto 0) := (others => '0');
   signal tx_height        : ufixed(11 downto 0) := (others => '0');
   signal rx_width         : ufixed(11 downto 0) := (others => '0');
   signal rx_height        : ufixed(11 downto 0) := (others => '0');

   -- Framebuffer
   signal fb_wr_en_i       : std_logic := '0';
   signal fb_wr_en_reg     : std_logic := '0';
   signal fb_data_i        : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_data_reg      : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_wr_addr_i     : integer := 0;
   signal fb_wr_addr_reg   : integer := 0;
   signal fb_valid_reg     : std_logic := '0';
   signal fb_data_o        : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_rd_addr_i     : integer := 0;

   -- Scaler
   signal interpolate      : boolean := false;

   -- Mapping function
   signal dx            : ufixed(11 downto -6) := (others => '0');
   signal dy            : ufixed(11 downto -6) := (others => '0');
   signal dx_reg        : ufixed(11 downto -6) := (others => '0');
   signal dy_reg        : ufixed(11 downto -6) := (others => '0');
   signal dx_1          : ufixed(11 downto -6) := (others => '0');
   signal dy_1          : ufixed(11 downto -6) := (others => '0');
   signal dx_2          : ufixed(11 downto -6) := (others => '0');
   signal dy_2          : ufixed(11 downto -6) := (others => '0');
   signal dx_3          : ufixed(11 downto -6) := (others => '0');
   signal dy_3          : ufixed(11 downto -6) := (others => '0');
   signal dx_1_reg_a    : ufixed(11 downto -6) := (others => '0');
   signal dy_1_reg_a    : ufixed(11 downto -6) := (others => '0');
   signal dx_1_reg_b    : ufixed(11 downto -6) := (others => '0');
   signal dy_1_reg_b    : ufixed(11 downto -6) := (others => '0');
   signal dx_1_reg_c    : ufixed(11 downto -6) := (others => '0');
   signal dy_1_reg_c    : ufixed(11 downto -6) := (others => '0');
   signal dx_2_reg      : ufixed(11 downto -6) := (others => '0');
   signal dy_2_reg      : ufixed(11 downto -6) := (others => '0');
   signal dx_3_reg      : ufixed(11 downto -6) := (others => '0');
   signal dy_3_reg      : ufixed(11 downto -6) := (others => '0');
   

   signal dx_int        : integer := 0;
   signal dy_int        : integer := 0;
   signal dx_int_reg    : integer := 0;
   signal dy_int_reg    : integer := 0;
   signal x_count       : integer := 0;
   signal y_count       : integer := 0;
   signal x_count_reg   : integer := 0;
   signal y_count_reg   : integer := 0;

   signal dy_int_last   : integer := 0;
   signal dy_change     : boolean := false;

   -- Counters
   signal exp_input     : integer := 0;
   signal cur_input     : integer := 0;
   signal exp_output    : integer := 0;
   signal cur_output    : integer := 0;
  

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
   rx_width       <= to_ufixed(g_rx_video_width, rx_width);
   rx_height      <= to_ufixed(g_rx_video_height, rx_height);
   tx_width       <= to_ufixed(g_tx_video_width, tx_width);
   tx_height      <= to_ufixed(g_tx_video_height, tx_height);
   
   sr_width       <= resize(1/(tx_width/rx_width), sr_width'high, sr_width'low);  
   sr_height      <= resize(1/(tx_height/rx_height), sr_height'high, sr_height'low);

   sr_width_reg  <= sr_width; 
   sr_height_reg <= sr_height;

   exp_input      <= g_rx_video_width*g_rx_video_height;
   exp_output     <= g_tx_video_width*g_tx_video_height;
   

   p_fsm : process(clk_i) is
      variable v_count : integer := 0;
   begin
      if rising_edge(clk_i) then
         -- Reset valid_o
         fb_valid_reg <= '0';

         case(state) is

            when s_idle => 
               scaler_ready_o       <= '1';
               cur_input            <= 0;
               cur_output           <= 0;
               scaler_endofpacket_o <= '0';
               
               if scaler_ready_o = '1' and scaler_valid_i = '1' then
                  if scaler_startofpacket_i = '1' then
                     fb_wr_en_reg   <= '1';
                     state          <= s_pre_fill_fb;
                  end if;
               end if;


            when s_pre_fill_fb =>
               -- Pre-fill framebuffer before starting the scaler
               if scaler_ready_o = '1' and scaler_valid_i = '1' then
                  if fb_wr_addr_reg = (g_rx_video_width*C_LINE_BUFFERS)-2 then
                     -- Ready latency of 1 on Avalon ST-video
                     scaler_ready_o <= '0';
                     fb_wr_en_reg   <= '1';
                     fb_wr_addr_reg <= fb_wr_addr_reg + 1;
                     cur_input      <= cur_input + 1;
                     state          <= s_finish_fill_fb;
                  else
                     -- Fill framebuffer
                     scaler_ready_o <= '1';
                     fb_wr_en_reg   <= '1';
                     fb_wr_addr_reg <= fb_wr_addr_reg + 1;
                     cur_input      <= cur_input + 1;
                  end if;
               end if;


            when s_finish_fill_fb =>
               -- Fill the last data recieved after ready latency of 1
               if scaler_valid_i = '1' then
                  fb_wr_en_reg   <= '0';
                  fb_wr_addr_reg <= 0 when (fb_wr_addr_reg = (g_rx_video_width*C_LINE_BUFFERS)-1) else fb_wr_addr_reg + 1;
                  cur_input      <= cur_input + 1;

                  -- Upscaling
                  state <= s_upscale;
                  if interpolate = true then
                     cur_output     <= cur_output + 1;
                     fb_valid_reg   <= '1';
                  end if;
               end if;


            when s_upscale =>
               -- Upscaling process
               if scaler_ready_i = '1' then
                  interpolate    <= true;
                  cur_output     <= cur_output + 1;
                  scaler_ready_o <= '0';
                  fb_wr_en_reg   <= '0';

                  if cur_output >= 6 then
                     -- First data on output
                     -- Need +6 because delay through scaler is 6 clock cycles
                     fb_valid_reg <= '1';
                     scaler_startofpacket_o <= '1' when cur_output = 7 else '0';
                  end if;


                  if dy_change and (cur_input < exp_input) then
                     -- One line in framebuffer has been processed, ready to be refilled
                     scaler_ready_o <= '1';
                     fb_wr_en_reg   <= '1';
                     interpolate    <= false;
                     state          <= s_upscale_and_fill;
                  end if;

                  if cur_output >= exp_output+3 then
                     -- Done processing
                     interpolate <= false;
                  end if;

                  if cur_output >= exp_output+6 then
                     -- Last data on output
                     -- Need +6 because delay through scaler is 6 clock cycles
                     fb_valid_reg   <= '0';
                     scaler_endofpacket_o <= '1';
                     state          <= s_idle;
                  end if;
               else
                  interpolate <= false;
               end if;


            when s_upscale_and_fill =>
               -- Fill one line in framebuffer while upscaling
               if scaler_ready_o = '1' and scaler_valid_i = '1' then
                  if scaler_ready_i = '1' then
                     interpolate    <= true;
                     scaler_ready_o <= '1';
                     fb_wr_en_reg   <= '1';
                     fb_wr_addr_reg <= 0 when (fb_wr_addr_reg = (g_rx_video_width*C_LINE_BUFFERS)-1) else fb_wr_addr_reg + 1;
                     cur_input      <= cur_input + 1;

                     v_count := v_count + 1;
                     if v_count >= 2 then
                        -- 2 clock cycles delay from fb_rd_addr is set to data is on output
                        fb_valid_reg   <= '1';
                        cur_output     <= cur_output + 1;
                     end if;

                     if v_count = g_rx_video_width-1 then
                        -- One line has been filled.
                        -- Ready latency of 1 on Avalon ST-video
                        scaler_ready_o <= '0';
                        v_count        := 0;
                        state          <= s_finish_fill_fb;
                     end if;
                  else
                     interpolate <= false;
                  end if;
               end if;


         end case;

         -- Connect registers
         fb_wr_en_i     <= fb_wr_en_reg;
         fb_wr_addr_i   <= fb_wr_addr_reg;
         fb_data_i      <= scaler_data_i;
         scaler_valid_o <= fb_valid_reg;

         -- Handle reset
         if sreset_i = '1' then
            state <= s_idle;
         end if;
      end if;
   end process p_fsm;



   p_reverse_mapping : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if interpolate then
            --dx <= resize(x_count*sr_width, dx'high, dx'low);
            --dy <= resize(y_count*sr_height, dy'high, dy'low);
            --dx <= resize((x_count*sr_width) + (0.5 * (1 - 1*sr_width)), dx'high, dx'low);
            --dy <= resize((y_count*sr_height) + (0.5 * (1 - 1*sr_height)), dy'high, dy'low);

            dx_1 <= resize(x_count_reg*sr_width_reg, dx_1'high, dx_1'low);
            dy_1 <= resize(y_count_reg*sr_height_reg, dy_1'high, dy_1'low);         

            dx_2 <= resize(1 - sr_width_reg, dx_2'high, dx_2'low);
            dy_2 <= resize(1 - sr_height_reg, dy_2'high, dy_2'low);       

            dx_3 <= resize(0.5*dx_2_reg, dx_2'high, dx_2'low);
            dy_3 <= resize(0.5*dy_2_reg, dy_2'high, dy_2'low);

            dx <= resize(dx_1_reg_c + dx_3_reg, dx'high, dx'low);
            dy <= resize(dy_1_reg_c + dy_3_reg, dy'high, dy'low);

            -- Next pixel in target frame
            x_count <= x_count + 1;
            
            -- Check if a row in target frame is completed
            if x_count = g_tx_video_width-1 then
               x_count <= 0;
               y_count <= y_count + 1;
            end if;

            -- Check if all rowns in line buffer is completed
            if dy_reg >= C_LINE_BUFFERS then
               y_count  <= 0;
               dy_int   <= 0;
            else
               dy_int <= to_integer(dy_reg);
            end if;

            dx_int         <= to_integer(dx_reg);
            fb_rd_addr_i   <= g_rx_video_width*dy_int_reg + dx_int_reg;

            -- Check if scaler is done with a framebuffer line 
            dy_change   <= true when dy_int_last /= dy_int else false; 
         end if;

         x_count_reg <= x_count;
         y_count_reg <= y_count;

         dx_1_reg_a <= dx_1;
         dy_1_reg_a <= dy_1;
         dx_1_reg_b <= dx_1_reg_a;
         dy_1_reg_b <= dy_1_reg_a;
         dx_1_reg_c <= dx_1_reg_b;
         dy_1_reg_c <= dy_1_reg_b;

         dx_2_reg <= dx_2;
         dy_2_reg <= dy_2;

         dx_3_reg <= dx_3;
         dy_3_reg <= dy_3;

         dx_reg <= dx;
         dy_reg <= dy;

         dx_int_reg <= dx_int;
         dy_int_reg <= dy_int;

         dy_int_last <= dy_int;

         scaler_data_o <= fb_data_o;
      end if;
   end process p_reverse_mapping;


end scaler_arc;