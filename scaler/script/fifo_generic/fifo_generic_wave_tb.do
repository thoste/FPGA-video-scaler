onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global} -radix hexadecimal /tb_fifo_generic/clk_i
add wave -noupdate -expand -group {Global} -radix hexadecimal /tb_fifo_generic/sreset_i

# FIFO
add wave -noupdate -expand -group {FIFO} -radix hexadecimal /tb_fifo_generic/data_i
add wave -noupdate -expand -group {FIFO} -radix hexadecimal /tb_fifo_generic/wr_en_i
add wave -noupdate -expand -group {FIFO} -radix hexadecimal /tb_fifo_generic/full_o
add wave -noupdate -expand -group {FIFO} -radix hexadecimal /tb_fifo_generic/almostfull_o
add wave -noupdate -expand -group {FIFO} -radix hexadecimal /tb_fifo_generic/data_o
add wave -noupdate -expand -group {FIFO} -radix hexadecimal /tb_fifo_generic/rd_en_i
add wave -noupdate -expand -group {FIFO} -radix hexadecimal /tb_fifo_generic/empty_o

# FIFO internal
add wave -noupdate -expand -group {FIFO internal} -radix hexadecimal /tb_fifo_generic/i_fifo/ram_wr_ptr
add wave -noupdate -expand -group {FIFO internal} -radix hexadecimal /tb_fifo_generic/i_fifo/ram_rd_ptr
add wave -noupdate -expand -group {FIFO internal} -radix hexadecimal /tb_fifo_generic/i_fifo/words_in_ram
add wave -noupdate -expand -group {FIFO internal} -radix hexadecimal /tb_fifo_generic/i_fifo/ram_data

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