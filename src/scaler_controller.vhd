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
   port (
      -- Signals to scaler
      clk_i             : in std_logic;
      sreset_i          : in std_logic;
      sop_i             : in std_logic;
      eop_i             : in std_logic;
      data_i            : in std_logic_vector (19 downto 0);
      empty_i           : in std_logic;
      valid_i           : in std_logic;
      ready_i           : in std_logic;
      -- Signals from scaler
      sop_o             : out std_logic;
      eop_o             : out std_logic;
      data_o            : out std_logic_vector (19 downto 0);
      empty_o           : out std_logic;
      valid_o           : out std_logic;
      ready_o           : out std_logic;

      -- Internal signals
      -- Recieved from control packet, passed to scaler
      rx_video_width_o           : out unsigned(15 downto 0);
      rx_video_height_o          : out unsigned(15 downto 0);
      rx_video_interlacing_o     : out unsigned(3 downto 0);

      -- Read from config file, passed to scaler
      tx_video_width_o           : out unsigned(15 downto 0);
      tx_video_height_o          : out unsigned(15 downto 0);
      tx_video_scaling_method_o  : out unsigned(3 downto 0));
   end entity scaler_controller;

architecture scaler_controller_arc of scaler_controller is
   type t_controller_state is (s_idle, s_video_data, s_control_packet, s_others);
   signal state         : t_controller_state;
   signal clear_eop_o   : boolean;
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
               eop_o <= '0';
               clear_eop_o <= false;
            end if;

            -- Check packet type identifier when startofpacket is recieved and next module is ready
            if (ready_i = '1' and sop_i = '1') then
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
               if (eop_i = '1') then
                  -- Last input packet, set eop_o this cycle and clear on next cycle
                  eop_o <= '1';
                  clear_eop_o <= true;
                  -- TODO:
                  -- Tell scaler to finish and empty line buffer
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
               -- TODO:
               -- Decode control packet, takes 5 clock cycles
               state <= s_idle;

            when s_others =>
               -- TODO:
               -- Passthrough signal with delay
               data_o <= data_i;
               state <= s_idle;

         end case;

         -- Check for reset signal
         if (sreset_i = '1') then
            state <= s_idle;
            ready_o <= '0';
            sop_o <= '0';
            eop_o <= '0';
            data_o <= 20x"0";
            empty_o <= '0';
            valid_o <= '0';
         end if;
      end if;
   end process;
end scaler_controller_arc;
