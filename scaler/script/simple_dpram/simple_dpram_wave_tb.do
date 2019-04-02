onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global} -radix hexadecimal /tb_simple_dpram/clk_i

# Simple dual-port RAM
add wave -noupdate -expand -group {RAM} -radix hexadecimal /tb_simple_dpram/data_i
add wave -noupdate -expand -group {RAM} -radix hexadecimal /tb_simple_dpram/wr_en_i
add wave -noupdate -expand -group {RAM} -radix hexadecimal /tb_simple_dpram/wr_addr_i
add wave -noupdate -expand -group {RAM} -radix hexadecimal /tb_simple_dpram/rd_addr_i
add wave -noupdate -expand -group {RAM} -radix hexadecimal /tb_simple_dpram/data_o

# RAM internal
add wave -noupdate -expand -group {RAM internal} -radix hexadecimal /tb_simple_dpram/i_simple_dpram/ram_data

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