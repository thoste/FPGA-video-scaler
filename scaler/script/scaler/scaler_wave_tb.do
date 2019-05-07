onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global} -radix hexadecimal     -label clk_i         /tb_scaler/clk_i

# Scaler in
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal  -label ready_o       /tb_scaler/ready_o
add wave -noupdate -expand -group {Scaler in} -radix unsigned     -label data_i        /tb_scaler/data_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal  -label valid_i       /tb_scaler/valid_i

# Scaler out
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal    -label ready_i    /tb_scaler/ready_i
add wave -noupdate -expand -group {Scaler out} -radix unsigned       -label data_o     /tb_scaler/data_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal    -label valid_o    /tb_scaler/valid_o

# State
add wave -noupdate -expand -group {State} -radix unsigned   -label state   /tb_scaler/i_scaler/state

# Framebuffer write
add wave -noupdate -expand -group {Framebuffer write}       -radix unsigned   -label fb_wr_addr_i  /tb_scaler/i_scaler/fb_wr_addr_i
add wave -noupdate -expand -group {Framebuffer write}       -radix unsigned   -label fb_wr_en_i     /tb_scaler/i_scaler/fb_wr_en_i
add wave -noupdate -expand -group {Framebuffer write}       -radix unsigned   -label fb_data_i     /tb_scaler/i_scaler/fb_data_i
add wave -noupdate -expand -group {Framebuffer write}       -radix unsigned   -label ram_data      /tb_scaler/i_scaler/framebuffer/ram_data

# Framebuffer read
add wave -noupdate -expand -group {Framebuffer read}        -radix unsigned   -label fb_rd_addr_i   /tb_scaler/i_scaler/fb_rd_addr_i
add wave -noupdate -expand -group {Framebuffer read}        -radix unsigned   -label fb_data_o      /tb_scaler/i_scaler/fb_data_o

# X
#add wave -noupdate -expand -group {X} -radix unsigned    -label x_count             /tb_scaler/i_scaler/x_count
#add wave -noupdate -expand -group {X} -radix ufixed      -label dx                  /tb_scaler/i_scaler/dx

# Y
#add wave -noupdate -expand -group {Y} -radix unsigned    -label y_count 	         /tb_scaler/i_scaler/y_count
#add wave -noupdate -expand -group {Y} -radix ufixed      -label dy 		            /tb_scaler/i_scaler/dy

# SR
#add wave -noupdate -expand -group {SR} -radix ufixed     -label vid_width_ufixed 	/tb_scaler/i_scaler/sr_width_reg
#add wave -noupdate -expand -group {SR} -radix ufixed     -label vid_width_ufixed    /tb_scaler/i_scaler/sr_height_reg

# debug
add wave -noupdate -expand -group {debug} -radix unsigned     -label up_input    /tb_scaler/i_scaler/up_input
add wave -noupdate -expand -group {debug} -radix unsigned     -label up_output   /tb_scaler/i_scaler/up_output
add wave -noupdate -expand -group {debug} -radix unsigned     -label tot_count   /tb_scaler/i_scaler/tot_count

TreeUpdate [SetDefaultTree]
