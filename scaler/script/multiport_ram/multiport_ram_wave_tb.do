onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global}      -radix hexadecimal   -label clk_i         /tb_multiport_ram/clk_i

# Write RAM
add wave -noupdate -expand -group {Write RAM}   -radix hexadecimal   -label wr_en_i       /tb_multiport_ram/wr_en_i
add wave -noupdate -expand -group {Write RAM}   -radix unsigned      -label wr_addr_i     /tb_multiport_ram/wr_addr_i
add wave -noupdate -expand -group {Write RAM}   -radix hexadecimal   -label data_i        /tb_multiport_ram/data_i

# Read RAM
add wave -noupdate -expand -group {Read RAM}    -radix unsigned      -label rd_addr_a_i   /tb_multiport_ram/rd_addr_a_i
add wave -noupdate -expand -group {Read RAM}    -radix unsigned      -label rd_addr_b_i   /tb_multiport_ram/rd_addr_b_i
add wave -noupdate -expand -group {Read RAM}    -radix unsigned      -label rd_addr_c_i   /tb_multiport_ram/rd_addr_c_i
add wave -noupdate -expand -group {Read RAM}    -radix unsigned      -label rd_addr_d_i   /tb_multiport_ram/rd_addr_d_i
add wave -noupdate -expand -group {Read RAM}    -radix hexadecimal   -label data_a_o      /tb_multiport_ram/data_a_o
add wave -noupdate -expand -group {Read RAM}    -radix hexadecimal   -label data_b_o      /tb_multiport_ram/data_b_o
add wave -noupdate -expand -group {Read RAM}    -radix hexadecimal   -label data_c_o      /tb_multiport_ram/data_c_o
add wave -noupdate -expand -group {Read RAM}    -radix hexadecimal   -label data_d_o      /tb_multiport_ram/data_d_o

# RAM internal
add wave -noupdate -expand -group {RAM data}    -radix hexadecimal   -label ram_data_a    /tb_multiport_ram/i_multiport_ram/g_multiport_ram(0)/u_simple_dpram/ram_data
add wave -noupdate -expand -group {RAM data}    -radix hexadecimal   -label ram_data_b    /tb_multiport_ram/i_multiport_ram/g_multiport_ram(1)/u_simple_dpram/ram_data
add wave -noupdate -expand -group {RAM data}    -radix hexadecimal   -label ram_data_c    /tb_multiport_ram/i_multiport_ram/g_multiport_ram(2)/u_simple_dpram/ram_data
add wave -noupdate -expand -group {RAM data}    -radix hexadecimal   -label ram_data_d    /tb_multiport_ram/i_multiport_ram/g_multiport_ram(3)/u_simple_dpram/ram_data

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