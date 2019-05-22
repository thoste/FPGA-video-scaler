onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global} -radix hexadecimal  -label clk_i   /tb_scaler/clk_i
add wave -noupdate -expand -group {Global} -radix unsigned     -label state   /tb_scaler/i_scaler/state

# Scaler in
add wave -noupdate -group {Scaler in} -radix hexadecimal  	-label ready_o            /tb_scaler/ready_o
add wave -noupdate -group {Scaler in} -radix unsigned     	-label data_i             /tb_scaler/data_i
add wave -noupdate -group {Scaler in} -radix hexadecimal  	-label valid_i            /tb_scaler/valid_i
add wave -noupdate -group {Scaler in} -radix hexadecimal 	   -label startofpacket_i 	  /tb_scaler/startofpacket_i
add wave -noupdate -group {Scaler in} -radix hexadecimal     -label endofpacket_i 	  /tb_scaler/endofpacket_i

# Scaler out
add wave -noupdate -group {Scaler out} -radix hexadecimal    -label ready_i             /tb_scaler/ready_i
add wave -noupdate -group {Scaler out} -radix unsigned       -label data_o              /tb_scaler/data_o
add wave -noupdate -group {Scaler out} -radix hexadecimal    -label valid_o             /tb_scaler/valid_o
add wave -noupdate -group {Scaler out} -radix hexadecimal    -label startofpacket_o     /tb_scaler/startofpacket_o
add wave -noupdate -group {Scaler out} -radix hexadecimal    -label endofpacket_o       /tb_scaler/endofpacket_o



# Framebuffer write
add wave -noupdate -group {Framebuffer write}       -radix unsigned   -label fb_wr_addr_i     /tb_scaler/i_scaler/fb_wr_addr_i
add wave -noupdate -group {Framebuffer write}       -radix unsigned   -label fb_wr_en_i       /tb_scaler/i_scaler/fb_wr_en_i
add wave -noupdate -group {Framebuffer write}       -radix unsigned   -label fb_data_i        /tb_scaler/i_scaler/fb_data_i
add wave -noupdate -group {Framebuffer write}       -radix unsigned   -label ram_data        /tb_scaler/i_scaler/framebuffer/g_multiport_ram(0)/u_simple_dpram/ram_data

# Framebuffer read
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_rd_addr_a_i   /tb_scaler/i_scaler/fb_rd_addr_a_i
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_rd_addr_b_i   /tb_scaler/i_scaler/fb_rd_addr_b_i
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_rd_addr_c_i   /tb_scaler/i_scaler/fb_rd_addr_c_i
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_rd_addr_d_i   /tb_scaler/i_scaler/fb_rd_addr_d_i
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_data_a_o      /tb_scaler/i_scaler/fb_data_a_o
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_data_b_o      /tb_scaler/i_scaler/fb_data_b_o
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_data_c_o      /tb_scaler/i_scaler/fb_data_c_o
add wave -noupdate -group {Framebuffer read}        -radix unsigned   -label fb_data_d_o      /tb_scaler/i_scaler/fb_data_d_o

# X
add wave -noupdate -group {X} -radix unsigned    -label x_count             /tb_scaler/i_scaler/x_count
add wave -noupdate -group {X} -radix ufixed      -label dx                  /tb_scaler/i_scaler/dx
add wave -noupdate -group {X} -radix ufixed      -label dx_reg              /tb_scaler/i_scaler/dx_reg
add wave -noupdate -group {X} -radix ufixed      -label dx_reg_1              /tb_scaler/i_scaler/dx_reg_1

# Y
add wave -noupdate -group {Y} -radix unsigned    -label y_count 	         /tb_scaler/i_scaler/y_count
add wave -noupdate -group {Y} -radix ufixed      -label dy 		            /tb_scaler/i_scaler/dy
add wave -noupdate -group {Y} -radix ufixed      -label dy_reg              /tb_scaler/i_scaler/dy_reg
add wave -noupdate -group {Y} -radix ufixed      -label dy_fb_reg              /tb_scaler/i_scaler/dy_fb_reg
add wave -noupdate -group {Y} -radix ufixed      -label dy_reg_1              /tb_scaler/i_scaler/dy_reg_1


# Kernel window
add wave -noupdate -group {Kernel window} -radix unsigned    -label x1_int      /tb_scaler/i_scaler/x1_int
add wave -noupdate -group {Kernel window} -radix unsigned    -label x2_int      /tb_scaler/i_scaler/x2_int
add wave -noupdate -group {Kernel window} -radix unsigned    -label y1_int      /tb_scaler/i_scaler/y1_int
add wave -noupdate -group {Kernel window} -radix unsigned    -label y2_int      /tb_scaler/i_scaler/y2_int


# Pixel data
#add wave -noupdate -group {Pixel data} -radix unsigned    -label pix1_data    /tb_scaler/i_scaler/pix1_data
#add wave -noupdate -group {Pixel data} -radix unsigned    -label pix2_data    /tb_scaler/i_scaler/pix2_data
#add wave -noupdate -group {Pixel data} -radix unsigned    -label pix3_data    /tb_scaler/i_scaler/pix3_data
#add wave -noupdate -group {Pixel data} -radix unsigned    -label pix4_data    /tb_scaler/i_scaler/pix4_data

# Pixel calc
#add wave -noupdate -group {Pixel calc} -radix ufixed    -label delta1       /tb_scaler/i_scaler/delta1
#add wave -noupdate -group {Pixel calc} -radix ufixed    -label delta2       /tb_scaler/i_scaler/delta2
#add wave -noupdate -group {Pixel calc} -radix ufixed    -label delta3       /tb_scaler/i_scaler/delta3
#add wave -noupdate -group {Pixel calc} -radix ufixed    -label delta4       /tb_scaler/i_scaler/delta4
add wave -noupdate -group {Pixel calc} -radix ufixed    -label A_y1           /tb_scaler/i_scaler/A_y1
add wave -noupdate -group {Pixel calc} -radix ufixed    -label A_y2           /tb_scaler/i_scaler/A_y2
add wave -noupdate -group {Pixel calc} -radix ufixed    -label A              /tb_scaler/i_scaler/A

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
