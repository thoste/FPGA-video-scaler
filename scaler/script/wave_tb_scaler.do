onerror {resume}
quietly WaveActivateNextPane {} 0

# GLOBAL
add wave -noupdate -expand -group {Global} -radix hexadecimal /tb_scaler/i_test_harness/clk_i
add wave -noupdate -expand -group {Global} -radix hexadecimal /tb_scaler/i_test_harness/sreset_i
add wave -noupdate -expand -group {Global} -radix hexadecimal /tb_scaler/i_test_harness/i_scaler/scaler_controller/state

# AVALON_ST SOURCE
add wave -noupdate -expand -group {Avalon-ST Source} -radix hexadecimal /tb_scaler/i_test_harness/source_data_o
add wave -noupdate -expand -group {Avalon-ST Source} -radix hexadecimal /tb_scaler/i_test_harness/source_ready_i
add wave -noupdate -expand -group {Avalon-ST Source} -radix hexadecimal /tb_scaler/i_test_harness/source_valid_o
add wave -noupdate -expand -group {Avalon-ST Source} -radix hexadecimal /tb_scaler/i_test_harness/source_empty_o
add wave -noupdate -expand -group {Avalon-ST Source} -radix hexadecimal /tb_scaler/i_test_harness/source_endofpacket_o
add wave -noupdate -expand -group {Avalon-ST Source} -radix hexadecimal /tb_scaler/i_test_harness/source_startofpacket_o

# SCALER
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/i_test_harness/scaler_data_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/i_test_harness/scaler_ready_o
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/i_test_harness/scaler_valid_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/i_test_harness/scaler_empty_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/i_test_harness/scaler_endofpacket_i
add wave -noupdate -expand -group {Scaler in} -radix hexadecimal /tb_scaler/i_test_harness/scaler_startofpacket_i

add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/i_test_harness/scaler_data_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/i_test_harness/scaler_ready_i
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/i_test_harness/scaler_valid_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/i_test_harness/scaler_empty_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/i_test_harness/scaler_endofpacket_o
add wave -noupdate -expand -group {Scaler out} -radix hexadecimal /tb_scaler/i_test_harness/scaler_startofpacket_o


# AVALON_ST SINK
add wave -noupdate -expand -group {Avalon-ST Sink} -radix hexadecimal /tb_scaler/i_test_harness/sink_data_i
add wave -noupdate -expand -group {Avalon-ST Sink} -radix hexadecimal /tb_scaler/i_test_harness/sink_ready_o
add wave -noupdate -expand -group {Avalon-ST Sink} -radix hexadecimal /tb_scaler/i_test_harness/sink_valid_i
add wave -noupdate -expand -group {Avalon-ST Sink} -radix hexadecimal /tb_scaler/i_test_harness/sink_empty_i
add wave -noupdate -expand -group {Avalon-ST Sink} -radix hexadecimal /tb_scaler/i_test_harness/sink_endofpacket_i
add wave -noupdate -expand -group {Avalon-ST Sink} -radix hexadecimal /tb_scaler/i_test_harness/sink_startofpacket_i

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