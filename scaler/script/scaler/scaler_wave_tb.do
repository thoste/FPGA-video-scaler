onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global} -radix hexadecimal /tb_scaler/clk_i

# Scaler in
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/ready_o
add wave -noupdate -expand -group {Scaler in} -radix unsigned /tb_scaler/data_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/valid_i

# Scaler out
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/ready_i
add wave -noupdate -expand -group {Scaler out} -radix unsigned /tb_scaler/data_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/valid_o


# Framebuffer
add wave -noupdate -expand -group {Framebuffer} -radix hexadecimal /tb_scaler/i_scaler/fb_rd_addr_i

TreeUpdate [SetDefaultTree]
