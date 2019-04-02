# Set up fifo_generic_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "scaler"
quietly set part_name "scaler"
# path from mpf-file in sim
quietly set fifo_generic_part_path "../../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set fifo_generic_part_path "$1/..//$part_name"
  unset 1
}


# (Re-)Generate library and Compile source files
#------------------------------------------------------
echo "\n\nRe-gen lib and compile $lib_name source\n"
if {[file exists $fifo_generic_part_path/sim/$lib_name]} {
  file delete -force $fifo_generic_part_path/sim/$lib_name
}
if {![file exists $fifo_generic_part_path/sim]} {
  file mkdir $fifo_generic_part_path/sim
}


#------------------------------------------------------
vlib $fifo_generic_part_path/sim/$lib_name
vmap $lib_name $fifo_generic_part_path/sim/$lib_name

set compdirectives "-2008 -work $lib_name"

eval vcom  $compdirectives  $fifo_generic_part_path/src/fifo_generic.vhd
