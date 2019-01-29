------------------------------------------------------------------------------------------
-- Project: FPGA video VIDEO_DATAr
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
            clk, rst            : in std_logic;
            startofpacket_in    : in std_logic;
            endofpacket_in      : in std_logic;
            data_in             : in std_logic_vector (19 downto 0) := (others => '0');
            empty_in            : in std_logic;
            valid_in            : in std_logic;
            ready_sent          : out std_logic;
            -- From scaler
            startofpacket_out   : out std_logic;
            endofpacket_out     : out std_logic;
            data_out            : out std_logic_vector (19 downto 0);
            empty_out           : out std_logic;
            valid_out           : out std_logic;
            ready_recieved      : in std_logic;

            -- Internal
            ctrl_pkt_dec_en     : out std_logic
        );
end entity controller;

architecture controller_arc of controller is
    type state_name is (IDLE, VIDEO_DATA, USER_DATA, CLOCKED_VIDEO_DATA, CONTROL_PACKET);
    signal state                : state_name;
    signal clear_eop            : boolean;

begin
    process(clk)
        variable v_data_in: unsigned(data_in'range);
    begin
        if rising_edge(clk) then

            -- Check for reset signal
            if rst = '1' then
                state <= IDLE;
                ready_sent <= '0';
                startofpacket_out <= '0';
                endofpacket_out <= '0';
                data_out <= 20x"0";
                empty_out <= '0';
                valid_out <= '0';
            end if;

            -- FSM
            v_data_in := unsigned(data_in);
            case state is
                when IDLE =>

                    -- Clear endofpacket after return
                    if clear_eop then
                        endofpacket_out <= '0';
                        clear_eop <= false;
                    end if;

                    -- Check packet type identifier when startofpacket is recieved and next module is ready
                    if (ready_recieved = '1' and startofpacket_in = '1') then
                        -- Video data packet
                        if(v_data_in = 0) then
                            state <= VIDEO_DATA;

                        -- User data packet
                        elsif (v_data_in >= 1 and v_data_in <= 8) then
                            state <= USER_DATA;

                        -- Clocked video data ancillary user packet
                        elsif (v_data_in = 13) then
                            state <= CLOCKED_VIDEO_DATA;

                        -- Control packet
                        elsif(v_data_in = 15) then
                            ctrl_pkt_dec_en <= '1';
                            state <= CONTROL_PACKET;

                        -- Default to IDLE when not recognized
                        else
                            state <= IDLE;
                        end if;

                    -- Keep IDLE state when there is no incomming packets
                    else
                        state <= IDLE;
                    end if;

                when VIDEO_DATA =>
                    if (endofpacket_in = '1') then
                        endofpacket_out <= '1';
                        data_out <= data_in;
                        clear_eop <= true;
                        state <= IDLE;
                    elsif (ready_recieved = '1') then
                        valid_out <= '1';
                        data_out <= data_in;
                        state <= VIDEO_DATA;
                    end if;

                when USER_DATA =>
                    state <= IDLE;

                when CLOCKED_VIDEO_DATA =>
                    state <= IDLE;

                when CONTROL_PACKET =>
                    state <= IDLE;

            end case;
        end if;
    end process;

end controller_arc;