--------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-03-11
-- Version: 0.1
--------------------------------------------------------
-- Description: Testbench for multiport RAM
--------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_data_fifo_pkg.all;


-- Test bench entity
entity tb_multiport_ram is
end tb_multiport_ram;

-- Test bench architecture
architecture tb_multiport_ram_arc of tb_multiport_ram is
   constant C_SCOPE        : string  := C_TB_SCOPE_DEFAULT;
   constant C_CLK_PERIOD   : time := 10 ns; -- 100 MHz

   -- RAM width and depth
   constant C_RAM_WIDTH    : natural := 30;
   constant C_RAM_DEPTH    : natural := 10;

   signal clk_i         : std_logic;
   signal data_i        : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others =>'0');
   signal wr_addr_i     : integer := 0;
   signal wr_en_i       : std_logic := '0';
   signal rd_addr_a_i   : integer := 0;
   signal rd_addr_b_i   : integer := 0;
   signal rd_addr_c_i   : integer := 0;
   signal rd_addr_d_i   : integer := 0;
   signal data_a_o      : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others =>'0');
   signal data_b_o      : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others =>'0');
   signal data_c_o      : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others =>'0');
   signal data_d_o      : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others =>'0');

begin
   -----------------------------------------------------------------------------
   -- Instantiate the concurrent procedure that initializes UVVM
   -----------------------------------------------------------------------------
   i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;


   -----------------------------------------------------------------------------
   -- Instantiate DUT
   -----------------------------------------------------------------------------
   i_multiport_ram: entity work.multiport_ram
   generic map(
      g_ram_width    => C_RAM_WIDTH, 
      g_ram_depth    => C_RAM_DEPTH
   )
   port map(
      clk_i       => clk_i,
      data_i      => data_i,
      wr_addr_i   => wr_addr_i,
      wr_en_i     => wr_en_i,
      data_a_o    => data_a_o,   
      data_b_o    => data_b_o,   
      data_c_o    => data_c_o,   
      data_d_o    => data_d_o,   
      rd_addr_a_i => rd_addr_a_i,
      rd_addr_b_i => rd_addr_b_i,
      rd_addr_c_i => rd_addr_c_i,
      rd_addr_d_i => rd_addr_d_i
   );


   ------------------------------------------------
   -- PROCESS: p_main
   ------------------------------------------------
   p_main: process 
      variable v_writeaddr    : natural := 0;
      variable v_readaddr_a   : natural := 0;
      variable v_readaddr_b   : natural := 0;
      variable v_readaddr_c   : natural := 0;
      variable v_readaddr_d   : natural := 0;
   begin
      -- Wait for UVVM to finish initialization
      await_uvvm_initialization(VOID);

      -- Print the configuration to the log
      report_global_ctrl(VOID);
      report_msg_id_panel(VOID);

      -----------------------------------------------------------------------------
      -- Enable log message
      -----------------------------------------------------------------------------
      enable_log_msg(ALL_MESSAGES);

      log(ID_LOG_HDR, "Starting simulation of FIFO", C_SCOPE);
      log("Wait 10 clock period for reset to be turned off");
      wait for (10 * C_CLK_PERIOD); 

      -----------------------------------------------------------------------------
      -- Test simple dual-port RAM
      -----------------------------------------------------------------------------
      wait until rising_edge(clk_i);
      
      -- Write random data to RAM
      wr_en_i <= '1';
      for i in 1 to C_RAM_DEPTH loop
         data_i      <= random(C_RAM_WIDTH);
         wr_addr_i   <= v_writeaddr;
         v_writeaddr := v_writeaddr + 1 when (v_writeaddr < C_RAM_DEPTH-1) else 0;
         wait until rising_edge(clk_i);
      end loop;
      wr_en_i <= '0';

      -- Read from RAM
      for i in 1 to C_RAM_DEPTH loop  
         rd_addr_a_i    <= v_readaddr_a;
         rd_addr_b_i    <= v_readaddr_b;
         rd_addr_c_i    <= v_readaddr_c;
         rd_addr_d_i    <= v_readaddr_d;
         v_readaddr_a   := v_readaddr_a + 1 when (v_readaddr_a < C_RAM_DEPTH-1) else 0;
         v_readaddr_b   := v_readaddr_b + 1 when (v_readaddr_b < C_RAM_DEPTH-1) else 0;
         v_readaddr_c   := v_readaddr_c + 1 when (v_readaddr_c < C_RAM_DEPTH-1) else 0;
         v_readaddr_d   := v_readaddr_d + 1 when (v_readaddr_d < C_RAM_DEPTH-1) else 0;
         wait until rising_edge(clk_i);
      end loop;

      -- Random fill up RAM
      wr_en_i <= '1';
      for i in 1 to C_RAM_DEPTH loop
         data_i      <= random(C_RAM_WIDTH);
         wr_addr_i   <= random(0,C_RAM_DEPTH-1);
         wait until rising_edge(clk_i);
      end loop;
      wr_en_i <= '0';

      -- Random read RAM
      for i in 1 to C_RAM_DEPTH loop  
         rd_addr_a_i <= random(0,C_RAM_DEPTH-1);
         rd_addr_b_i <= random(0,C_RAM_DEPTH-1);
         rd_addr_c_i <= random(0,C_RAM_DEPTH-1);
         rd_addr_d_i <= random(0,C_RAM_DEPTH-1);
         wait until rising_edge(clk_i);
      end loop;

      -- Concurrent read and write form random addresses
      wr_en_i <= '1';
      for i in 1 to 5*C_RAM_DEPTH loop
         data_i      <= random(C_RAM_WIDTH);
         wr_addr_i   <= random(0,C_RAM_DEPTH-1);
         rd_addr_a_i <= random(0,C_RAM_DEPTH-1);
         rd_addr_b_i <= random(0,C_RAM_DEPTH-1);
         rd_addr_c_i <= random(0,C_RAM_DEPTH-1);
         rd_addr_d_i <= random(0,C_RAM_DEPTH-1);
         wait until rising_edge(clk_i);
      end loop;
      wr_en_i <= '0';


      -----------------------------------------------------------------------------
      -- Ending the simulation
      -----------------------------------------------------------------------------
      wait for 1000 ns;             -- to allow some time for completion
      report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
      log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

      -- Finish the simulation
      std.env.stop;
      wait;  -- to stop completely
   end process p_main;


   -----------------------------------------------------------------------------
   -- Clock process
   -----------------------------------------------------------------------------  
   p_clk: process
   begin
      clk_i <= '0', '1' after C_CLK_PERIOD / 2;
      wait for C_CLK_PERIOD;
   end process;

end tb_multiport_ram_arc;