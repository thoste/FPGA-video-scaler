--------------------------------------------------------
-- Project: FPGA video scaler
-- Author: Thomas Stenseth
-- Date: 2019-04-24
-- Version: 0.1
--------------------------------------------------------
-- Description: Custom version of fixed point package
--              using fixed_truncate round style
--              instead of the default fixed_round
--------------------------------------------------------


library ieee;
use ieee.fixed_float_types.all;


package my_fixed_pkg is new ieee.fixed_generic_pkg
   generic map (
      fixed_round_style    => fixed_truncate,
      fixed_overflow_style => ieee.fixed_float_types.fixed_saturate,
      fixed_guard_bits     => 3,
      no_warning           => false
   );
end package my_fixed_pkg;
