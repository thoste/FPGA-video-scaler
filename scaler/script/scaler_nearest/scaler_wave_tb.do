onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global} -radix hexadecimal     -label clk_i         /tb_scaler/clk_i

# Scaler in
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal  	-label ready_o             /tb_scaler/ready_o
add wave -noupdate -expand -group {Scaler in} -radix unsigned     	-label data_i              /tb_scaler/data_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal  	-label valid_i             /tb_scaler/valid_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal 	   -label startofpacket_i     /tb_scaler/startofpacket_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal     -label endofpacket_i 	   /tb_scaler/endofpacket_i

# Scaler out
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal    -label ready_i             /tb_scaler/ready_i
add wave -noupdate -expand -group {Scaler out} -radix unsigned       -label data_o              /tb_scaler/data_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal    -label valid_o             /tb_scaler/valid_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal    -label startofpacket_o     /tb_scaler/startofpacket_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal    -label endofpacket_o       /tb_scaler/endofpacket_o

# State
add wave -noupdate -expand -group {State} -radix unsigned   -label state   /tb_scaler/i_scaler/state

# Framebuffer write
#add wave -noupdate -expand -group {Framebuffer write}       -radix unsigned   -label fb_wr_addr_i     /tb_scaler/i_scaler/fb_wr_addr_i
#add wave -noupdate -expand -group {Framebuffer write}       -radix unsigned   -label fb_wr_en_i       /tb_scaler/i_scaler/fb_wr_en_i
#add wave -noupdate -expand -group {Framebuffer write}       -radix unsigned   -label fb_data_i        /tb_scaler/i_scaler/fb_data_i

# Framebuffer read
add wave -noupdate -expand -group {Framebuffer read}        -radix unsigned   -label fb_rd_addr_a_i   /tb_scaler/i_scaler/fb_rd_addr_i
add wave -noupdate -expand -group {Framebuffer read}        -radix unsigned   -label fb_data_a_o      /tb_scaler/i_scaler/fb_data_o


# X
add wave -noupdate -expand -group {X} -radix unsigned    -label x_count             /tb_scaler/i_scaler/x_count
add wave -noupdate -expand -group {X} -radix ufixed      -label dx                  /tb_scaler/i_scaler/dx
add wave -noupdate -expand -group {X} -radix ufixed      -label dx_reg              /tb_scaler/i_scaler/dx_reg

# Y
add wave -noupdate -expand -group {Y} -radix unsigned    -label y_count 	         /tb_scaler/i_scaler/y_count
add wave -noupdate -expand -group {Y} -radix ufixed      -label dy 		            /tb_scaler/i_scaler/dy
add wave -noupdate -expand -group {Y} -radix ufixed      -label dy_reg              /tb_scaler/i_scaler/dy_reg
add wave -noupdate -expand -group {Y} -radix unsigned    -label dy_int              /tb_scaler/i_scaler/dy_int
add wave -noupdate -expand -group {Y} -radix unsigned    -label dy_change           /tb_scaler/i_scaler/dy_change


# debug
#add wave -position end  sim:/tb_scaler/i_scaler/exp_input
#add wave -position end  sim:/tb_scaler/i_scaler/cur_input
#add wave -position end  sim:/tb_scaler/i_scaler/exp_output
#add wave -position end  sim:/tb_scaler/i_scaler/cur_output


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1411622 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {27512625 ps}
