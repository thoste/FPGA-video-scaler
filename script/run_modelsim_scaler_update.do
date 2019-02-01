transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -2008 -work work {C:/Users/stens/Documents/NTNU/FPGA-video-scaler/src/controller.vhd}
vcom -2008 -work work {C:/Users/stens/Documents/NTNU/FPGA-video-scaler/src/scaler.vhd}

vcom -2008 -work work {C:/Users/stens/Documents/NTNU/FPGA-video-scaler/project/../tb/tb_scaler.vhd}

restart -f
run -all