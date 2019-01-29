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

entity control_packet_decoder is
    port (
            clk, rst            : in std_logic;
            data_in             : in std_logic_vector (19 downto 0) := (others => '0');

            -- Internal
            ctrl_pkt_dec_en 	: in std_logic;
            in_video_width		: out unsigned(15 downto 0);
            in_video_height		: out unsigned(15 downto 0)

        );
end entity control_packet_decoder;

architecture control_packet_decoder_arc of control_packet_decoder is

begin
	process(clk, ctrl_pkt_dec_en)
	begin
		if rising_edge(clk) then
			-- Default values on reset
			if (rst = '1') then
				null;

			elsif ctrl_pkt_dec_en then 
				-- Decode info from control packet in data_in
				in_video_width <= 16x"FF00";
				in_video_height <= 16x"00FF";
			end if;
		end if;
	end process;

end control_packet_decoder_arc;