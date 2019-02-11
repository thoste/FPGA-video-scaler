transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -2008 -work work {C:/Users/stens/Documents/NTNU/FPGA-video-scaler/src/scaler_controller.vhd}
vcom -2008 -work work {C:/Users/stens/Documents/NTNU/FPGA-video-scaler/src/scaler.vhd}

vcom -2008 -work work {C:/Users/stens/Documents/NTNU/FPGA-video-scaler/project/../tb/tb_scaler.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L twentynm -L twentynm_hssi -L twentynm_hip -L rtl_work -L work -voptargs="+acc"  tb_scaler

view structure
view signals

add wave *
add wave /tb_scaler/UUT/scaler_controller/state

run -all

wave zoom full