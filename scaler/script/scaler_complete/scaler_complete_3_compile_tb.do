# Set up scaler_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "scaler"
quietly set part_name "scaler"
# path from mpf-file in sim
quietly set scaler_part_path "../../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set scaler_part_path "$1/..//$part_name"
  unset 1
}


# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------
set compdirectives "-2008 -work $lib_name"


# UVVM TBs
#------------------------------------------------------------------------
eval vcom  $compdirectives  $scaler_part_path/tb/th_scaler_complete.vhd
eval vcom  $compdirectives  $scaler_part_path/tb/tb_scaler_complete.vhd
