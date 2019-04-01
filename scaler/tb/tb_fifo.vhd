-------------------------------------------------------------------------------
-- (C) 2009 Appear TV AS. All Rights Reserved.
-------------------------------------------------------------------------------
-- File Name      : tb_atv_fifo_generic.vhd
-- Library Name   : atv_lib
-- Author         : A.Knowles
-- Date Created   : 19/08/2009
-- Description    : 
-- Change Log     : 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library atv_lib;
use atv_lib.atv_lib_pkg.all;
use atv_lib.atv_types_pkg.all;

entity tb_fifo is

end entity tb_fifo;

architecture rtl of tb_fifo is

   signal clk_i        : std_logic;
   signal sreset_i     : std_logic;

   signal data_i    : std_logic_vector(31 downto 0) := x"ABCD1234";
   signal wr_en_i   : std_logic;
   signal full_o    : std_logic;
   
   signal data_o     : std_logic_vector(31 downto 0);
   signal rd_en_i    : std_logic;
   signal empty_o    : std_logic;
      
begin

   i_fifo_generic : fifo_generic
      generic map
      (
         g_width         => 32,
         g_depth         => 16
         
      )
      port map
      (
         clk_i          => clk,
         sreset_i       => sreset,
         data_i       => data_in,
         wr_en_i      => wr_en,
         full_o       => full,
         data_o       => data_out,
         rd_en_i      => rd_en,
         empty_o      => empty
      );
      
   process
   begin
      clk <= '0';
      wait for 2.0 ns;
      clk <= '1';
      wait for 2.0 ns;
   end process;
   
   process
   begin
      sreset <= '1';
      wait for 50 ns;
      wait until rising_edge(clk);
      sreset <= '0';
      wait;
   end process;
   
   process(clk)
   begin
      if rising_edge(clk) then
         data_in <= data_in(30 downto 0) & data_in(31);
      end if;
   end process;
   
   process
   begin
      wr_en <= '0';
      rd_en <= '0';
      wait until falling_edge(sreset);
      wait until rising_edge(clk);
      -- Stream through empty FIFO
      wr_en <= '1';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Empty FIFO
      wr_en <= '0';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Idle
      wr_en <= '0';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Fill FIFO
      wr_en <= '1';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Idle
      wr_en <= '0';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Stream through full FIFO
      wr_en <= '1';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Idle
      wr_en <= '0';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Empty FIFO
      wr_en <= '0';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Half fill FIFO
      wr_en <= '1';
      rd_en <= '0';
      for i in 0 to 7 loop
         wait until rising_edge(clk);
      end loop;
      -- Stream through half full FIFO
      wr_en <= '1';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Half speed stream through half full FIFO
      wr_en <= '1';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
         wr_en <= not wr_en;
         rd_en <= not rd_en;
      end loop;
      -- Empty FIFO
      wr_en <= '0';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Idle
      wr_en <= '0';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Half speed stream through empty FIFO
      wr_en <= '1';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
         wr_en <= not wr_en;
         rd_en <= not rd_en;
      end loop;
      -- Empty FIFO
      wr_en <= '0';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Idle
      wr_en <= '0';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Half speed fill FIFO
      wr_en <= '1';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
         wr_en <= not wr_en;
      end loop;
      -- Idle
      wr_en <= '0';
      rd_en <= '0';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
      end loop;
      -- Half speed empty FIFO
      wr_en <= '0';
      rd_en <= '1';
      for i in 0 to 50 loop
         wait until rising_edge(clk);
         rd_en <= not rd_en;
      end loop;
      -- Idle
      wr_en <= '0';
      rd_en <= '0';
      wait;
   end process;

end architecture rtl;