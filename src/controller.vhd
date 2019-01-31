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

entity controller is
   port (
      -- To scaler
      clk_i             : in std_logic;
      sreset_i          : in std_logic;
      startofpacket_i   : in std_logic;
      endofpacket_i     : in std_logic;
      data_i            : in std_logic_vector (19 downto 0) := (others => '0');
      empty_i           : in std_logic;
      valid_i           : in std_logic;
      ready_i           : in std_logic;
      -- From scaler
      startofpacket_o   : out std_logic;
      endofpacket_o     : out std_logic;
      data_o            : out std_logic_vector (19 downto 0);
      empty_o           : out std_logic;
      valid_o           : out std_logic;
      ready_o           : out std_logic;

      -- Internal
      rx_video_width    : out unsigned(15 downto 0);
      rx_video_height   : out unsigned(15 downto 0);
      rx_interlacing    : out unsigned(3 downto 0));
   end entity controller;

architecture controller_arc of controller is
   type t_controller_state is (s_idle, s_video_data, s_control_packet, s_others);
   signal state                : t_controller_state;
   signal clear_eop_o        : boolean;
begin
   p_main_state_macine : process(clk_i)
      variable v_packet_type_id: unsigned(3 downto 0);
   begin
      if rising_edge(clk_i) then
         -- FSM
         v_packet_type_id := unsigned(data_i(3 downto 0));
         case state is
            when s_idle =>

            -- Clear endofpacket after return
            if clear_eop_o then
               endofpacket_o <= '0';
               clear_eop_o <= false;
            end if;

            -- Check packet type identifier when startofpacket is recieved and next module is ready
            if (ready_i = '1' and startofpacket_i = '1') then
               -- Video data packet
               if(v_packet_type_id = 0) then
                  state <= s_video_data;
               -- Control packet
               elsif(v_packet_type_id = 15) then
                  state <= s_control_packet;
               -- Other packets
               else
                  state <= s_others;
               end if;
            -- Keep s_idle state when there is no incomming packets
            else
               state <= s_idle;
            end if;

            when s_video_data =>
               if (endofpacket_i = '1') then
                  -- Last input packet, set endofpacket_o this cycle and clear on next cycle
                  endofpacket_o <= '1';
                  clear_eop_o <= true;
                  -- TODO:
                  -- Tell scaler to finish 
                  data_o <= data_i;
                  state <= s_idle;
               elsif (ready_i = '1') then
                  -- TODO:
                  -- Enable scaler
                  valid_o <= '1';
                  data_o <= data_i;
                  state <= s_video_data;
               end if;

            when s_control_packet =>
               -- Decode control packet, 5 clock cycles
               state <= s_idle;

            when s_others =>
               -- Passthrough signal with delay
               data_o <= data_i;
               state <= s_idle;

         end case;

         -- Check for reset signal
         if sreset_i = '1' then
            state <= s_idle;
            ready_o <= '0';
            startofpacket_o <= '0';
            endofpacket_o <= '0';
            data_o <= 20x"0";
            empty_o <= '0';
            valid_o <= '0';
         end if;
      end if;
   end process;
end controller_arc;
