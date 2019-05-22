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

   -- Scaling ratio
   -- Using (others => '1') or else division by 0 error 
   signal scaling_ratio       : ufixed(3 downto -12) := (others => '0');
   signal scaling_ratio_reg   : ufixed(3 downto -12) := (others => '0');

   signal tx_height           : ufixed(11 downto 0) := (others => '1');
   signal rx_height           : ufixed(11 downto 0) := (others => '1');
   signal tx_height_reg       : ufixed(11 downto 0) := (others => '1');
   signal rx_height_reg       : ufixed(11 downto 0) := (others => '1');

   -- Framebuffer
   signal fb_wr_en_i       : std_logic := '0';
   signal fb_wr_en_reg     : std_logic := '0';
   signal fb_data_i        : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_data_reg      : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_wr_addr_i     : integer := 0;
   signal fb_wr_addr_reg   : integer := 0;
   signal fb_valid_reg     : std_logic := '0';
   signal fb_data_a_o      : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_data_b_o      : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_data_c_o      : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_data_d_o      : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_rd_addr_a_i   : integer := 0;
   signal fb_rd_addr_b_i   : integer := 0;
   signal fb_rd_addr_c_i   : integer := 0;
   signal fb_rd_addr_d_i   : integer := 0;

   -- Scaler
   signal interpolate      : boolean := false;

   -- Mapping function
   signal dx            : ufixed(16 downto -16) := (others => '0');
   signal dy            : ufixed(16 downto -16) := (others => '0');
   signal dy_fb         : ufixed(16 downto -16) := (others => '0');
   signal dx_reg        : ufixed(16 downto -16) := (others => '0');
   signal dy_reg        : ufixed(16 downto -16) := (others => '0');
   signal dy_fb_reg     : ufixed(16 downto -16) := (others => '0');

   signal dx_reg_1      : ufixed(16 downto -16) := (others => '0');
   signal dy_reg_1      : ufixed(16 downto -16) := (others => '0');

   signal dx_1          : ufixed(15 downto -12) := (others => '0');
   signal dy_1          : ufixed(15 downto -12) := (others => '0');
   signal dy_fb_1       : ufixed(15 downto -12) := (others => '0');
   signal dx_1_reg      : ufixed(15 downto -12) := (others => '0');
   signal dy_1_reg      : ufixed(15 downto -12) := (others => '0');
   signal dy_fb_1_reg   : ufixed(15 downto -12) := (others => '0');

   signal dxy_2         : ufixed(15 downto -16) := (others => '0');
   signal dxy_2_reg     : ufixed(15 downto -16) := (others => '0');

   -- Needs to be 1 because of dx/dy algorithm
   signal x_count          : integer := 1; 
   signal y_count          : integer := 1;
   signal y_count_fb       : integer := 1;
   signal x_count_ufx      : ufixed(11 downto 0) := 12x"1";
   signal y_count_ufx      : ufixed(11 downto 0) := 12x"1";
   signal y_count_fb_ufx   : ufixed(11 downto 0) := 12x"1";
   signal x_count_ufx_reg  : ufixed(11 downto 0) := 12x"1";
   signal y_count_ufx_reg  : ufixed(11 downto 0) := 12x"1";
   signal y_count_fb_ufx_reg  : ufixed(11 downto 0) := 12x"1";
   

   signal x1_int        : integer := 1;
   signal x2_int        : integer := 2;
   signal y1_int        : integer := 1;
   signal y2_int        : integer := 2;
   signal y1_fb_int     : integer := 1;
   signal y2_fb_int     : integer := 2;
   
   signal pix1_int      : integer := 0;
   signal pix2_int      : integer := 0;
   signal pix3_int      : integer := 0;
   signal pix4_int      : integer := 0;
   signal pix1_data     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal pix2_data     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal pix3_data     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal pix4_data     : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   
   signal dy_fb_int        : integer := 1;
   signal dy_fb_int_last   : integer := 1;
   signal dy_change        : boolean := false;

   signal x1_int_reg_1  : integer := 0;
   signal x2_int_reg_1  : integer := 0;
   signal y1_int_reg_1  : integer := 0;
   signal y2_int_reg_1  : integer := 0;

   signal x1_int_reg_2  : integer := 0;
   signal x2_int_reg_2  : integer := 0;
   signal y1_int_reg_2  : integer := 0;
   signal y2_int_reg_2  : integer := 0;

   -- Coefficients
   signal delta1      : ufixed(1 downto -16) := (others => '0');
   signal delta2      : ufixed(1 downto -16) := (others => '0');
   signal delta3      : ufixed(1 downto -16) := (others => '0');
   signal delta4      : ufixed(1 downto -16) := (others => '0');

   signal delta1_reg_1  : ufixed(1 downto -16) := (others => '0');
   signal delta2_reg_1  : ufixed(1 downto -16) := (others => '0');
   signal delta3_reg_1  : ufixed(1 downto -16) := (others => '0');
   signal delta4_reg_1  : ufixed(1 downto -16) := (others => '0');

   signal delta1_reg_2  : ufixed(1 downto -16) := (others => '0');
   signal delta2_reg_2  : ufixed(1 downto -16) := (others => '0');
   signal delta3_reg_2  : ufixed(1 downto -16) := (others => '0');
   signal delta4_reg_2  : ufixed(1 downto -16) := (others => '0');

   signal delta1_reg_3  : ufixed(1 downto -16) := (others => '0');
   signal delta2_reg_3  : ufixed(1 downto -16) := (others => '0');
   signal delta3_reg_3  : ufixed(1 downto -16) := (others => '0');
   signal delta4_reg_3  : ufixed(1 downto -16) := (others => '0');

   signal delta1_reg_4  : ufixed(1 downto -16) := (others => '0');
   signal delta2_reg_4  : ufixed(1 downto -16) := (others => '0');
   signal delta3_reg_4  : ufixed(1 downto -16) := (others => '0');
   signal delta4_reg_4  : ufixed(1 downto -16) := (others => '0');

   signal delta1_reg_5  : ufixed(1 downto -16) := (others => '0');
   signal delta2_reg_5  : ufixed(1 downto -16) := (others => '0');
   signal delta3_reg_5  : ufixed(1 downto -16) := (others => '0');
   signal delta4_reg_5  : ufixed(1 downto -16) := (others => '0');

   signal pix1_data_A : ufixed(7 downto 0)   := (others => '0');
   signal pix2_data_A : ufixed(7 downto 0)   := (others => '0');
   signal pix3_data_A : ufixed(7 downto 0)   := (others => '0');
   signal pix4_data_A : ufixed(7 downto 0)   := (others => '0');
   signal pix1_data_B : ufixed(7 downto 0)   := (others => '0');
   signal pix2_data_B : ufixed(7 downto 0)   := (others => '0');
   signal pix3_data_B : ufixed(7 downto 0)   := (others => '0');
   signal pix4_data_B : ufixed(7 downto 0)   := (others => '0');
   signal pix1_data_C : ufixed(7 downto 0)   := (others => '0');
   signal pix2_data_C : ufixed(7 downto 0)   := (others => '0');
   signal pix3_data_C : ufixed(7 downto 0)   := (others => '0');
   signal pix4_data_C : ufixed(7 downto 0)   := (others => '0');

   signal A_y1_a        : ufixed(9 downto -16) := (others => '0');
   signal A_y1_b        : ufixed(9 downto -16) := (others => '0');
   signal A_y2_a        : ufixed(9 downto -16) := (others => '0');
   signal A_y2_b        : ufixed(9 downto -16) := (others => '0');
   signal A_y1          : ufixed(7 downto -8) := (others => '0');
   signal A_y2          : ufixed(7 downto -8) := (others => '0');
   signal A_1           : ufixed(7 downto -8) := (others => '0');
   signal A_2           : ufixed(7 downto -8) := (others => '0');
   signal A             : ufixed(7 downto 0) := (others => '0');

   signal B_y1_a        : ufixed(9 downto -16) := (others => '0');
   signal B_y1_b        : ufixed(9 downto -16) := (others => '0');
   signal B_y2_a        : ufixed(9 downto -16) := (others => '0');
   signal B_y2_b        : ufixed(9 downto -16) := (others => '0');
   signal B_y1          : ufixed(7 downto -8) := (others => '0');
   signal B_y2          : ufixed(7 downto -8) := (others => '0');
   signal B_1           : ufixed(7 downto -8) := (others => '0');
   signal B_2           : ufixed(7 downto -8) := (others => '0');
   signal B             : ufixed(7 downto 0) := (others => '0');

   signal C_y1_a        : ufixed(9 downto -16) := (others => '0');
   signal C_y1_b        : ufixed(9 downto -16) := (others => '0');
   signal C_y2_a        : ufixed(9 downto -16) := (others => '0');
   signal C_y2_b        : ufixed(9 downto -16) := (others => '0');
   signal C_y1          : ufixed(7 downto -8) := (others => '0');
   signal C_y2          : ufixed(7 downto -8) := (others => '0');
   signal C_1           : ufixed(7 downto -8) := (others => '0');
   signal C_2           : ufixed(7 downto -8) := (others => '0');
   signal C             : ufixed(7 downto 0) := (others => '0');

   -- Counters
   signal cur_input     : integer := 0;
   signal cur_output    : integer := 0;
  

begin
   framebuffer : entity work.multiport_ram
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
      data_a_o       => fb_data_a_o,
      data_b_o       => fb_data_b_o,
      data_c_o       => fb_data_c_o,
      data_d_o       => fb_data_d_o,
      rd_addr_a_i    => fb_rd_addr_a_i,
      rd_addr_b_i    => fb_rd_addr_b_i,
      rd_addr_c_i    => fb_rd_addr_c_i,
      rd_addr_d_i    => fb_rd_addr_d_i
   );



   p_fsm : process(clk_i) is
      variable v_count : integer := 0;
   begin
      if rising_edge(clk_i) then
         case(state) is

            when s_idle => 
               scaler_ready_o       <= '1';
               cur_input            <= 0;
               cur_output           <= 0;
               scaler_endofpacket_o <= '0';
               fb_valid_reg         <= '0';
               
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

                  if cur_output >= 13 then
                     -- First data on output
                     -- Need +17 because delay through scaler is 17 clock cycles
                     fb_valid_reg <= '1';
                     scaler_startofpacket_o <= '1' when cur_output = 14 else '0';
                  end if;


                  if dy_change and (cur_input < (g_rx_video_width*g_rx_video_height)) then
                     -- One line in framebuffer has been processed, ready to be refilled
                     scaler_ready_o <= '1';
                     fb_wr_en_reg   <= '1';
                     interpolate    <= false;
                     state          <= s_upscale_and_fill;
                  end if;

                  if cur_output >= (g_tx_video_width*g_tx_video_height)+22 then
                     -- Done processing
                     interpolate <= false;
                  end if;

                  if cur_output >= (g_tx_video_width*g_tx_video_height)+23 then
                     -- Last data on output
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
                     fb_valid_reg <= '0';

                     v_count := v_count + 1;
                     if v_count >= 3 then
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
            --dx <= resize((x_count*sr_width) + (0.5 * (1 - 1*sr_width)), dx'high, dx'low);
            --dy <= resize((y_count*sr_height) + (0.5 * (1 - 1*sr_height)), dy'high, dy'low);

            -- Make x/y_count ufixed
            x_count_ufx          <= to_ufixed(x_count, x_count_ufx);
            y_count_ufx          <= to_ufixed(y_count, x_count_ufx);
            y_count_fb_ufx       <= to_ufixed(y_count, x_count_ufx);
            x_count_ufx_reg      <= x_count_ufx;
            y_count_ufx_reg      <= y_count_ufx;
            y_count_fb_ufx_reg   <= y_count_fb_ufx;

            -- Fixed point DSP multiplication of variable part of dx/dy calculation
            dx_1        <= x_count_ufx_reg * scaling_ratio_reg;
            dy_1        <= y_count_ufx_reg * scaling_ratio_reg;
            dy_fb_1     <= y_count_fb_ufx_reg * scaling_ratio_reg;
            dx_1_reg    <= dx_1;
            dy_1_reg    <= dy_1;
            dy_fb_1_reg <= dy_fb_1;

            -- Constant part of dx/dy calculation
            dxy_2       <= to_ufixed(0.5, 1, -2) * (1 - resize(scaling_ratio_reg, 12, -14));
            dxy_2_reg   <= dxy_2;

            -- Final dx/dy calculation
            dx          <= dx_1_reg + dxy_2_reg;
            dy          <= dy_1_reg + dxy_2_reg;
            dy_fb       <= dy_fb_1_reg + dxy_2_reg;
            dx_reg      <= dx;
            dy_reg      <= dy;
            dy_fb_reg   <= dy_fb;

            -- Next pixel in target frame
            x_count <= x_count + 1;
            
            -- Check if a row in target frame is completed
            if x_count = g_tx_video_width then
               x_count <= 1;
               y_count <= y_count + 1;
               y_count_fb <= y_count_fb + 1;
            end if;

            -- Keep kernel within boundaries
            if dx_reg < 1 then
               dx_reg_1 <= to_ufixed(1, dx_reg_1);
               x1_int   <= 1;
               x2_int   <= 2;
            elsif dx_reg > g_rx_video_width then
               dx_reg_1 <= to_ufixed(g_rx_video_width, dx_reg_1);
               x1_int <= g_rx_video_width - 1;
               x2_int <= g_rx_video_width;
            else
               dx_reg_1 <= dx_reg;
               x1_int <= to_integer(dx_reg);
               x2_int <= to_integer(dx_reg) + 1;
            end if;

            -- Keep kernel within boundaries
            if dy_reg < 1 then
               dy_reg_1 <= to_ufixed(1, dy_reg_1);
               y1_int <= 1;
               y2_int <= 2;
            elsif dy_reg > g_rx_video_height then
               dy_reg_1 <= to_ufixed(g_rx_video_height, dy_reg_1);
               y1_int <= g_rx_video_height - 1;
               y2_int <= g_rx_video_height;
            else
               dy_reg_1 <= dy_reg;
               y1_int <= to_integer(dy_reg);
               y2_int <= to_integer(dy_reg) + 1;
            end if;

            -- Keep kernel within boundaries
            -- Special case for y_count for framebuffer
            if dy_fb_reg < 1 then
               dy_fb_int   <= 1;
               y1_fb_int   <= 1;
               y2_fb_int   <= 2;
            elsif dy_fb_reg >= C_LINE_BUFFERS+1 then 
               -- Start from beginning of framebuffer when both lines have been completed
               y_count_fb           <= 1;
               y_count_fb_ufx       <= to_ufixed(1, y_count_fb_ufx);
               y_count_fb_ufx_reg   <= to_ufixed(1, y_count_fb_ufx_reg);
               dy_fb                <= resize(scaling_ratio_reg + dxy_2_reg, dy_fb);
               dy_fb_reg            <= resize(scaling_ratio_reg + dxy_2_reg, dy_fb);
               dy_fb_1              <= resize(scaling_ratio_reg, dy_fb_1);
               dy_fb_int            <= 1;
               y1_fb_int            <= 1;
               y2_fb_int            <= 2;
            elsif dy_reg >= C_LINE_BUFFERS then
               -- Special case when one line has completed but not the other one
               dy_fb_int   <= C_LINE_BUFFERS;
               y1_fb_int   <= C_LINE_BUFFERS;
               y2_fb_int   <= 1;
            else
               dy_fb_int   <= to_integer(dy_fb_reg);
               y1_fb_int   <= to_integer(dy_fb_reg);
               y2_fb_int   <= to_integer(dy_fb_reg) + 1;
            end if;


            -- Read data from framebuffer
            pix1_int <= ((y1_fb_int-1)*g_rx_video_width) + (x1_int - 1);
            pix2_int <= ((y1_fb_int-1)*g_rx_video_width) + (x2_int - 1);
            pix3_int <= ((y2_fb_int-1)*g_rx_video_width) + (x1_int - 1);
            pix4_int <= ((y2_fb_int-1)*g_rx_video_width) + (x2_int - 1);

            fb_rd_addr_a_i <= ((y1_fb_int-1)*g_rx_video_width) + (x1_int - 1);
            fb_rd_addr_b_i <= ((y1_fb_int-1)*g_rx_video_width) + (x2_int - 1);
            fb_rd_addr_c_i <= ((y2_fb_int-1)*g_rx_video_width) + (x1_int - 1);
            fb_rd_addr_d_i <= ((y2_fb_int-1)*g_rx_video_width) + (x2_int - 1);

            pix1_data <= fb_data_a_o;
            pix2_data <= fb_data_b_o;
            pix3_data <= fb_data_c_o;
            pix4_data <= fb_data_d_o;

            pix1_data_A <= to_ufixed(fb_data_a_o(7 downto 0), pix1_data_A);
            pix2_data_A <= to_ufixed(fb_data_b_o(7 downto 0), pix2_data_A);
            pix3_data_A <= to_ufixed(fb_data_c_o(7 downto 0), pix3_data_A);
            pix4_data_A <= to_ufixed(fb_data_d_o(7 downto 0), pix4_data_A);

            pix1_data_B <= to_ufixed(fb_data_a_o(15 downto 8), pix1_data_B);
            pix2_data_B <= to_ufixed(fb_data_b_o(15 downto 8), pix2_data_B);
            pix3_data_B <= to_ufixed(fb_data_c_o(15 downto 8), pix3_data_B);
            pix4_data_B <= to_ufixed(fb_data_d_o(15 downto 8), pix4_data_B);

            pix1_data_C <= to_ufixed(fb_data_a_o(23 downto 16), pix1_data_C);
            pix2_data_C <= to_ufixed(fb_data_b_o(23 downto 16), pix2_data_C);
            pix3_data_C <= to_ufixed(fb_data_c_o(23 downto 16), pix3_data_C);
            pix4_data_C <= to_ufixed(fb_data_d_o(23 downto 16), pix4_data_C);


            ---------------------------------------------------
            -- MATLAB algorithm:
            -- A_y1 = (x2 - dx)*A(y1,x1) + (dx - x1)*A(y1,x2);
            -- A_y2 = (x2 - dx)*A(y2,x1) + (dx - x1)*A(y2,x2);
            -- A = (y2 - dy)*A_y1 + (dy - y1)*A_y2;
            ---------------------------------------------------

            delta1 <= resize(x2_int - dx_reg_1, delta1);
            delta2 <= resize(dx_reg_1 - x1_int, delta2);
            delta3 <= resize(y2_int - dy_reg_1, delta3);
            delta4 <= resize(dy_reg_1 - y1_int, delta4);

            delta1_reg_1 <= delta1;
            delta2_reg_1 <= delta2;
            delta3_reg_1 <= delta3;
            delta4_reg_1 <= delta4;
            delta1_reg_2 <= delta1_reg_1;
            delta2_reg_2 <= delta2_reg_1;
            delta3_reg_2 <= delta3_reg_1;
            delta4_reg_2 <= delta4_reg_1;
            delta1_reg_3 <= delta1_reg_2;
            delta2_reg_3 <= delta2_reg_2;
            delta3_reg_3 <= delta3_reg_2;
            delta4_reg_3 <= delta4_reg_2;
            delta1_reg_4 <= delta1_reg_3;
            delta2_reg_4 <= delta2_reg_3;
            delta3_reg_4 <= delta3_reg_3;
            delta4_reg_4 <= delta4_reg_3;


            
            A_y1 <= resize(delta1_reg_3*pix1_data_A + delta2_reg_3*pix2_data_A, A_y1);
            A_y2 <= resize(delta1_reg_3*pix3_data_A + delta2_reg_3*pix4_data_A, A_y2);
            A  <= resize(delta3_reg_4*A_y1 + delta4_reg_4*A_y2, A);
            
            B_y1 <= resize(delta1_reg_3*pix1_data_B + delta2_reg_3*pix2_data_B, B_y1);
            B_y2 <= resize(delta1_reg_3*pix3_data_B + delta2_reg_3*pix4_data_B, B_y2);
            B  <= resize(delta3_reg_4*B_y1 + delta4_reg_4*B_y2, B);

            C_y1 <= resize(delta1_reg_3*pix1_data_C + delta2_reg_3*pix2_data_C, C_y1);
            C_y2 <= resize(delta1_reg_3*pix3_data_C + delta2_reg_3*pix4_data_C, C_y2);
            C  <= resize(delta3_reg_4*C_y1 + delta4_reg_4*C_y2, C);

            -- Check if scaler is done with a framebuffer line
            dy_fb_int_last <= dy_fb_int;
            dy_change   <= true when dy_fb_int_last /= dy_fb_int else false; 
         end if;

         scaler_data_o(7 downto 0)     <= std_logic_vector(unsigned(A));
         scaler_data_o(15 downto 8)    <= std_logic_vector(unsigned(B));
         scaler_data_o(23 downto 16)   <= std_logic_vector(unsigned(C));

         -- Handle reset
         if sreset_i = '1' then
            x_count <= 1; -- Needs to be 1 because of dx/dy algorithm
            y_count <= 1; -- Needs to be 1 because of dx/dy algorithm
         end if;
      end if;
   end process p_reverse_mapping;

   p_scaling_ratio : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         -- Calc scaling ratio
         -- Needs to be inside clocked process to become registers for fixed point DSP implementation
         rx_height         <= to_ufixed(g_rx_video_height, rx_height);
         tx_height         <= to_ufixed(g_tx_video_height, tx_height);
         rx_height_reg     <= rx_height;
         tx_height_reg     <= tx_height;
         scaling_ratio     <= resize(rx_height_reg/tx_height_reg, scaling_ratio'high, scaling_ratio'low);
         scaling_ratio_reg <= scaling_ratio;
      end if;
   end process p_scaling_ratio;

end scaler_arc;