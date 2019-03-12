onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /tb_scaler_vvc/i_test_harness/i_scaler/clk_i
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /tb_scaler_vvc/i_test_harness/i_scaler/sreset_i

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