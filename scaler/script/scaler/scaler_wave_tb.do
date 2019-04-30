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


# Framebuffer
add wave -noupdate -expand -group {Framebuffer} -radix hexadecimal   -label fb_full       /tb_scaler/i_scaler/fb_full
add wave -noupdate -expand -group {Framebuffer} -radix hexadecimal   -label fb_rd_addr_i  /tb_scaler/i_scaler/fb_rd_addr_i

# X
add wave -noupdate -expand -group {X} -radix unsigned    -label x_count             /tb_scaler/i_scaler/x_count
add wave -noupdate -expand -group {X} -radix ufixed      -label dx                  /tb_scaler/i_scaler/dx

# Y
add wave -noupdate -expand -group {Y} -radix unsigned    -label y_count 	         /tb_scaler/i_scaler/y_count
add wave -noupdate -expand -group {Y} -radix ufixed      -label dy 		            /tb_scaler/i_scaler/dy

# SR
add wave -noupdate -expand -group {SR} -radix ufixed     -label vid_width_ufixed 	/tb_scaler/i_scaler/sr_width_reg
add wave -noupdate -expand -group {SR} -radix ufixed     -label vid_width_ufixed    /tb_scaler/i_scaler/sr_height_reg

TreeUpdate [SetDefaultTree]
