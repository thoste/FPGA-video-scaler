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


entity fifo_generic is
   generic (
      g_width 	      : natural   := 8;
      g_depth 	      : natural   := 32;
      g_ramstyle     : string    := "MLAB";
      g_output_reg   : boolean   := false
   );
   port (
      clk_i       : in  std_logic;
      sreset_i    : in  std_logic;
      -- Write
      data_i      : in  std_logic_vector(g_width-1 downto 0);
      wr_en_i     : in  std_logic;
      full_o      : out std_logic := '0';
      -- Read
      data_o      : out std_logic_vector(g_width-1 downto 0) := (others => '0');
      rd_en_i     : in  std_logic;
      empty_o     : out std_logic := '1'
   );
end fifo_generic;

architecture fifo_generic_arc of fifo_generic is
   -- RAM
   type t_ram is array (natural range <>) of std_logic_vector(g_width-1 downto 0);
   signal ram_data      : t_ram(g_depth-1 downto 0)               := (others => (others => '0'));
   signal ram_out       : std_logic_vector(g_width-1 downto 0)    := (others => '0');
   signal ram_out_reg   : std_logic_vector(g_width-1 downto 0)    := (others => '0');

   -- RAM style
   attribute ramstyle : string;
   attribute ramstyle of ram_data : signal is g_ramstyle;

   -- Signals
   signal ram_wr_ptr    : integer range 0 to g_depth-1;  -- RAM write pointer
   signal ram_rd_ptr    : integer range 0 to g_depth-1;  -- RAM read pointer 
   signal words_in_ram  : integer range 0 to g_depth;

   signal wr_ok         : std_logic := '0';
   signal rd_ok         : std_logic := '0';
   signal is_full       : std_logic := '0';
   signal is_empty      : std_logic := '1';
begin
   -- Validate write and read
   wr_ok <= '1' when wr_en_i = '1' and is_full = '0' else '0';
   rd_ok <= '1' when rd_en_i = '1' and is_empty = '0' else '0';

   -- Update number of words in ram
   p_words : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         if sreset_i = '1' then
            words_in_ram   <= 0;
         else
            -- FIFO write
            if (wr_ok = '1' and rd_ok = '0') then
               words_in_ram <= words_in_ram + 1;
            -- FIFO read
            elsif (wr_ok = '0' and rd_ok = '1') then
               words_in_ram <= words_in_ram - 1;
            -- FIFO both read and write, or no action
            else
               words_in_ram <= words_in_ram;
            end if;
         end if;
      end if;
   end process p_words;

   -- Update empty and full signals
   p_flags : process(clk_i) is 
   begin
      if rising_edge(clk_i) then
         if sreset_i = '1' then
            is_empty <= '1';
            is_full <= '0';
         else
            -- Assert empty signal
            if (words_in_ram = 0) or (words_in_ram = 1 and wr_ok = '0' and rd_ok = '1') then
               is_empty <= '1';
            else
               is_empty <= '0';
            end if;
            -- Assert full signal
            if(words_in_ram = g_depth) or (words_in_ram = g_depth-1 and wr_ok = '1' and rd_ok = '0') then
               is_full <= '1';
            else
               is_full <= '0';
            end if;
         end if;
      end if;
   end process p_flags;

   -- Update write pointer
   p_ram_wr_ptr : process(clk_i) is 
   begin
      if rising_edge(clk_i) then
         if sreset_i = '1' then
            ram_wr_ptr <= 0;
         elsif wr_ok = '1' then
            ram_wr_ptr <= (ram_wr_ptr + 1) mod g_depth;
         end if;
      end if;
   end process p_ram_wr_ptr;

   -- Update read pointer
   p_ram_rd_ptr : process(clk_i) is 
   begin
      if rising_edge(clk_i) then
         if sreset_i = '1' then
            ram_rd_ptr <= 0;
         elsif rd_ok = '1' then
            ram_rd_ptr <= (ram_rd_ptr + 1) mod g_depth;
         end if;
      end if;
   end process p_ram_rd_ptr;

   -- Write to FIFO
   p_write : process(clk_i) is 
   begin
      if rising_edge(clk_i) then
         if wr_ok = '1' then
            ram_data(ram_wr_ptr) <= data_i;
         end if;
      end if;
   end process p_write;

   -- Read from FIFO
   p_read : process(clk_i) is 
   begin
      if rising_edge(clk_i) then
         if rd_ok = '1' then
            ram_out <= ram_data(ram_rd_ptr);
            ram_out_reg <= ram_out;
         end if;
      end if;
   end process p_read;

   -- Outputs
   full_o   <= is_full;
   empty_o  <= is_empty;
   data_o   <= ram_out_reg when g_output_reg else ram_out;
   
end fifo_generic_arc;