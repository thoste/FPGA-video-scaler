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


entity scaler is
	port (
			-- To scaler
			clk, rst 			: in std_logic;
			startofpacket_in	: in std_logic;
			endofpacket_in		: in std_logic;
			data_in				: in std_logic_vector (19 downto 0);
			empty_in			: in std_logic;
			valid_in			: in std_logic;
			ready_sent			: out std_logic;
			-- From scaler
			startofpacket_out	: out std_logic;
			endofpacket_out		: out std_logic;
			data_out			: out std_logic_vector (19 downto 0);
			empty_out			: out std_logic;
			valid_out			: out std_logic;
			ready_recieved		: in std_logic
		);
end entity scaler;

architecture scaler_arc of scaler is
		signal ctrl_pkt_dec_en 	: std_logic;
		signal in_video_width 	: unsigned(15 downto 0);
		signal in_video_height 	: unsigned(15 downto 0);
begin
	controller : entity work.controller
		port map(
			clk => clk,
			rst => rst,
			startofpacket_in => startofpacket_in,
			endofpacket_in => endofpacket_in,
			data_in => data_in,
			empty_in => empty_in,
			valid_in => valid_in,
			ready_sent => ready_sent,
			startofpacket_out => startofpacket_out,
			endofpacket_out => endofpacket_out,
			data_out => data_out,
			empty_out => empty_out,
			valid_out => valid_out,
			ready_recieved => ready_recieved,
			ctrl_pkt_dec_en => ctrl_pkt_dec_en
		); 

	control_packet_decoder : entity work.control_packet_decoder
		port map(
			clk => clk,
			rst => rst,
			data_in => data_in,
			ctrl_pkt_dec_en => ctrl_pkt_dec_en, 
			in_video_width	=> in_video_width,
			in_video_height	=> in_video_height
		);
end scaler_arc;
		