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
      clk_i             : in  std_logic;
      sreset_i          : in  std_logic
   );
end scaler;

architecture scaler_arc of scaler is
begin

end scaler_arc;