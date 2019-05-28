--------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-04-14
-- Version: 0.1
--------------------------------------------------------
-- Description: Nearest-neighbor interpolation
--              using 4-line framebuffer
--------------------------------------------------------


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
      clk_i                   : in  std_logic;
      sreset_i                : in  std_logic;

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
   signal fb_data_o        : std_logic_vector(g_data_width-1 downto 0) := (others => '0');
   signal fb_rd_addr_i     : integer := 0;

   -- Scaler
   signal interpolate      : boolean := false;

   -- Mapping function
   signal dx            : ufixed(16 downto -16) := (others => '0');
   signal dy            : ufixed(16 downto -16) := (others => '0');
   signal dx_reg        : ufixed(16 downto -16) := (others => '0');
   signal dy_reg        : ufixed(16 downto -16) := (others => '0');

   signal dx_1          : ufixed(15 downto -12) := (others => '0');
   signal dy_1          : ufixed(15 downto -12) := (others => '0');
   signal dx_1_reg      : ufixed(15 downto -12) := (others => '0');
   signal dy_1_reg      : ufixed(15 downto -12) := (others => '0');

   signal dxy_2           : ufixed(15 downto -16) := (others => '0');
   signal dxy_2_reg       : ufixed(15 downto -16) := (others => '0');

   signal dx_int        : integer := 0;
   signal dy_int        : integer := 0;
   signal dx_int_reg    : integer := 0;
   signal dy_int_reg    : integer := 0;

   signal x_count          : integer := 0;
   signal y_count          : integer := 0;
   signal x_count_ufx      : ufixed(11 downto 0) := (others => '0');
   signal y_count_ufx      : ufixed(11 downto 0) := (others => '0');
   signal x_count_ufx_reg  : ufixed(11 downto 0) := (others => '0');
   signal y_count_ufx_reg  : ufixed(11 downto 0) := (others => '0');

   signal dy_int_last   : integer := 0;
   signal dy_change     : boolean := false;

   -- Counters
   signal cur_input     : integer := 0;
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

                  if cur_output >= 11 then
                     -- First data on output
                     -- Need +11 because delay through scaler is 11 clock cycles
                     fb_valid_reg <= '1';
                     scaler_startofpacket_o <= '1' when cur_output = 12 else '0';
                  end if;


                  if dy_change and (cur_input < (g_rx_video_width*g_rx_video_height)) then
                     -- One line in framebuffer has been processed, ready to be refilled
                     scaler_ready_o <= '1';
                     fb_wr_en_reg   <= '1';
                     interpolate    <= false;
                     state          <= s_upscale_and_fill;
                  end if;

                  if cur_output >= (g_tx_video_width*g_tx_video_height)+6 then
                     -- Done processing
                     interpolate <= false;
                  end if;

                  if cur_output >= (g_tx_video_width*g_tx_video_height)+9 then
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



   p_nearest : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if interpolate then
            -- Make x/y_count ufixed
            x_count_ufx       <= to_ufixed(x_count, x_count_ufx);
            y_count_ufx       <= to_ufixed(y_count, y_count_ufx);
            x_count_ufx_reg   <= x_count_ufx;
            y_count_ufx_reg   <= y_count_ufx;

            -- Fixed point DSP multiplication of variable part of dx/dy calculation
            dx_1     <= x_count_ufx_reg * scaling_ratio_reg;
            dy_1     <= y_count_ufx_reg * scaling_ratio_reg;
            dx_1_reg <= dx_1;
            dy_1_reg <= dy_1;

            -- Constant part of dx/dy calculation
            dxy_2       <= to_ufixed(0.5, 1, -2) * (1 - resize(scaling_ratio_reg, 12, -14));
            dxy_2_reg   <= dxy_2;

            -- Final dx/dy calculation
            dx       <= dx_1_reg + dxy_2_reg;
            dy       <= dy_1_reg + dxy_2_reg;
            dx_reg   <= dx;
            dy_reg   <= dy;              

            -- Next pixel in target frame
            x_count <= x_count + 1;
            
            -- Check if a row in target frame is completed
            if x_count = g_tx_video_width-1 then
               x_count <= 0;
               y_count <= y_count + 1;
            end if;

            -- Check if all rowns in line buffer is completed
            if dy_reg >= C_LINE_BUFFERS then
               -- Reset y_count for frambuffer addresses
               y_count           <= 0;
               y_count_ufx       <= to_ufixed(0, y_count_ufx);
               y_count_ufx_reg   <= to_ufixed(0, y_count_ufx_reg);
               -- Variable part of dx/dy is zero, use only constant part
               dy                <= resize(dxy_2_reg, dy'high, dy'low);
               dy_reg            <= resize(dxy_2_reg, dy'high, dy'low);
               dy_int            <= 0;
               -- Unable to set dx_1/dy_1 to zero, as this ruins fixed point DSP implementation
               -- This is instead handled by setting y_count_ufx/y_count_ufx_reg to zero. 
               -- This will give wrong dx_1/dy_1 calculation on current clock cycle, 
               -- but this is fixed by forcing dy_int <= 0 and having y_count set to zero.
            else
               dy_int <= to_integer(dy_reg);
            end if;

            -- Use floor from my_fixed_pkg to get dx/dy to integer for fb_rd_addr
            dx_int      <= to_integer(dx_reg);
            dx_int_reg  <= dx_int;
            dy_int_reg  <= dy_int;

            -- Find nearest neighbor address for framebuffer
            fb_rd_addr_i <= g_rx_video_width*dy_int_reg + dx_int_reg;

            -- Check if scaler is done with a framebuffer line
            dy_int_last <= dy_int; 
            dy_change   <= true when dy_int_last /= dy_int else false; 
         end if; 

         scaler_data_o <= fb_data_o;
      end if;
   end process p_nearest;



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