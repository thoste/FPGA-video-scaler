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

entity scaler_controller is
   generic (
      g_data_width               : natural;
      g_empty_width              : natural;
      g_tx_video_width           : natural;
      g_tx_video_height          : natural;
      g_tx_video_scaling_method  : natural
   );
   port (
      clk_i             : in  std_logic;
      sreset_i          : in  std_logic;
      -- scaler -> scaler_controller
      startofpacket_i   : in  std_logic;
      endofpacket_i     : in  std_logic;
      data_i            : in  std_logic_vector(g_data_width-1 downto 0);
      empty_i           : in  std_logic_vector(g_empty_width-1 downto 0);
      valid_i           : in  std_logic;
      ready_o           : out std_logic := '0';
      
      -- scaler_controller -> scaler
      startofpacket_o   : out std_logic := '0';
      endofpacket_o     : out std_logic := '0';
      data_o            : out std_logic_vector(g_data_width-1 downto 0) := (others => '0');
      empty_o           : out std_logic_vector(g_empty_width-1 downto 0) := (others => '0');
      valid_o           : out std_logic := '0';
      ready_i           : in  std_logic;

      -- Config
      rx_video_width_o           : out std_logic_vector(15 downto 0);
      rx_video_height_o          : out std_logic_vector(15 downto 0)

      ---- Input FIFO
      --fifo_in_wr_en_i   : in  std_logic;
      --fifo_in_rd_en_i   : in  std_logic;
      --fifo_in_full_o    : out std_logic;
      --fifo_in_empty_o   : out std_logic

      ---- Output FIFO
      --fifo_out_wr_en_i  : in  std_logic;
      --fifo_out_rd_en_i  : in  std_logic;
      --fifo_out_full_o   : out std_logic;
      --fifo_out_empty_o  : out std_logic
      );
   end entity scaler_controller;

architecture scaler_controller_arc of scaler_controller is
   type t_packet_type is (s_idle, s_video_data, s_control_packet);
   signal state   : t_packet_type := s_idle;
   signal fsm_ready     : std_logic := '0';

begin
   -- Asseart ready out
   ready_o <= (ready_i or not valid_o) and fsm_ready;

   p_fsm : process(clk_i) is
      variable v_tx_video_width : std_logic_vector(15 downto 0);
      variable v_tx_video_height : std_logic_vector(15 downto 0);
   begin
      if rising_edge(clk_i) then
         if ready_i = '1' then
            valid_o <= '0';
         end if;

         fsm_ready <= '1';

         case state is
            when s_idle =>
               if ready_o = '1' and valid_i = '1' then
                  if startofpacket_i = '1' and data_i(3 downto 0) = "0000" then
                     -- Send startofpacket and video packet identifier to output
                     data_o  <= (3 downto 0 => '0', others => '1'); -- Using others => 1 for easy identification in modelsim
                     valid_o   <= '1';
                     startofpacket_o <= '1';

                     -- Next state
                     fsm_ready <= '0';
                     state <= s_video_data;
                  elsif startofpacket_i = '1' and data_i(3 downto 0) = "1111" then
                     -- Send startofpacket and ctrl pkg identifier to output
                     data_o  <= (3 downto 0 => '1', others => '0');
                     valid_o   <= '1';
                     startofpacket_o <= '1';

                     -- Next state
                     fsm_ready <= '0';
                     state <= s_control_packet;
                  end if;

                  -- Reset endofpacket
                  endofpacket_o <= '0';
               end if;


            when s_video_data =>
               if ready_o = '1' and valid_i = '1' then
                  if endofpacket_i = '1' then
                     endofpacket_o <= '1';

                     -- Next state
                     fsm_ready <= '1';
                     state <= s_idle;
                  else
                     -- Next state
                     fsm_ready <= '0';
                     state <= s_video_data;
                  end if;
                  data_o  <= data_i;
                  valid_o   <= '1';
                  startofpacket_o <= '0';
               end if;


            when s_control_packet =>
               if ready_o = '1' and valid_i = '1' then
                  -- Decode input video resolution
                  rx_video_width_o(3 downto 0)     <= data_i(33 downto 30);
                  rx_video_width_o(7 downto 4)     <= data_i(23 downto 20);
                  rx_video_width_o(11 downto 8)    <= data_i(13 downto 10);
                  rx_video_width_o(15 downto 12)   <= data_i(3 downto 0);
                  rx_video_height_o(3 downto 0)    <= data_i(73 downto 70);
                  rx_video_height_o(7 downto 4)    <= data_i(63 downto 60);
                  rx_video_height_o(11 downto 8)   <= data_i(53 downto 50);
                  rx_video_height_o(15 downto 12)  <= data_i(43 downto 40);

                  -- Set output to slv format
                  v_tx_video_width  := std_logic_vector(to_unsigned(g_tx_video_width, v_tx_video_width'length));
                  v_tx_video_height := std_logic_vector(to_unsigned(g_tx_video_height, v_tx_video_height'length));

                  -- Send output resolution and endofpacket
                  data_o(3 downto 0)   <= v_tx_video_width(15 downto 12);
                  data_o(13 downto 10) <= v_tx_video_width(11 downto 8);
                  data_o(23 downto 20) <= v_tx_video_width(7 downto 4);
                  data_o(33 downto 30) <= v_tx_video_width(3 downto 0);
                  data_o(43 downto 40) <= v_tx_video_height(15 downto 12);
                  data_o(53 downto 50) <= v_tx_video_height(11 downto 8);
                  data_o(63 downto 60) <= v_tx_video_height(7 downto 4);
                  data_o(73 downto 70) <= v_tx_video_height(3 downto 0);

                  valid_o   <= '1';
                  startofpacket_o <= '0';
                  endofpacket_o <= '1';

                  -- Next state
                  fsm_ready <= '1';
                  state <= s_idle;
               end if;

         end case;

         if sreset_i = '1' then
            valid_o <= '0';
         end if;
      end if;
   end process p_fsm;
end scaler_controller_arc;
