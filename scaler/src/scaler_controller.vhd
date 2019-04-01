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
      DATA_WIDTH        : natural;
      EMPTY_WIDTH       : natural
   );
   port (
      -- Signals to scaler
      clk_i             : in std_logic;
      sreset_i          : in std_logic;
      sop_i             : in std_logic;
      eop_i             : in std_logic;
      data_i            : in std_logic_vector(DATA_WIDTH-1 downto 0);
      empty_i           : in std_logic_vector(EMPTY_WIDTH-1 downto 0);
      valid_i           : in std_logic;
      ready_i           : in std_logic;
      -- Signals from scaler
      sop_o             : out std_logic := '0';
      eop_o             : out std_logic := '0';
      data_o            : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      empty_o           : out std_logic_vector(EMPTY_WIDTH-1 downto 0) := (others => '0');
      valid_o           : out std_logic := '0';
      ready_o           : out std_logic := '0';

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
   type t_controller_state is (s_idle, s_video_data, s_user_data, s_reserved_data, s_clocked_video_data, s_control_packet);
   signal state         : t_controller_state := s_idle;
   signal fsm_ready     : std_logic := '0';
begin

   -- Asseart ready out
   ready_o <= (ready_i or not valid_o) and fsm_ready;

   ------------------------------------------------
   -- PROCESS: p_decode_packet_type
   ------------------------------------------------
   p_decode_packet_type : process(clk_i) is
      variable v_packet_type_id  : natural range 0 to 15;
   begin
      if rising_edge(clk_i) then
         -- Decode packet
         if sop_i = '1' and valid_i = '1' then
            v_packet_type_id := to_integer(unsigned(data_i(3 downto 0)));
            case(v_packet_type_id) is
               when 0 => 
                  state <= s_video_data;
               when 1 to 8 =>
                  state <= s_user_data;
               when 9 to 12 =>
                  state <= s_reserved_data;
               when 13 =>
                  state <= s_clocked_video_data;
               when 14 =>
                  state <= s_reserved_data;
               when 15 =>
                  state <= s_control_packet;
            end case;
         end if;

         -- Go back to idle after endofpacket
         if eop_i = '1' then
            state <= s_idle;
         end if;
         
         -- Handle reset
         if sreset_i = '1' then
            state <= s_idle;
         end if;
      end if;
   end process p_decode_packet_type;


   ------------------------------------------------
   -- PROCESS: p_main_state_macine
   ------------------------------------------------
   p_main_state_macine : process(clk_i) is
      variable v_sent_sop : boolean := false;
      variable v_sent_eop : boolean := false;
   begin
      if rising_edge(clk_i) then
         -- Reset valid_o signal
         if ready_i = '1' then
            valid_o <= '0';
         end if;

         if v_sent_sop then
            sop_o <= '0';
         end if;

         if v_sent_eop then
            eop_o <= '0';
            -- Clear flags after transmission
            v_sent_sop := false;
            v_sent_eop := false;
         end if;
         
         fsm_ready <= '1';

         -- FSM
         case state is
            when s_idle =>
               -- Nothing

            when s_video_data =>
               fsm_ready <= '1';
               if not v_sent_sop then
                  sop_o <= '1';
                  v_sent_sop := true;
               end if;

               if eop_i = '1' then
                  eop_o <= '1';
                  v_sent_eop := true;
               end if;

               -- Passthrough signal
               data_o   <= data_i;
               valid_o  <= valid_i;
               empty_o  <= empty_i;
               

            when s_user_data =>
               -- Nothing

            when s_reserved_data =>
               -- Nothing

            when s_clocked_video_data =>
               -- Nothing

            when s_control_packet =>
               -- Nothing
         end case;

         -- Check for reset signal
         if (sreset_i = '1') then
            fsm_ready <= '0';
            sop_o <= '0';
            eop_o <= '0';
            data_o <= (others => '0');
            empty_o <= (others =>'0');
            valid_o <= '0';
         end if;
      end if;
   end process p_main_state_macine;
end scaler_controller_arc;
