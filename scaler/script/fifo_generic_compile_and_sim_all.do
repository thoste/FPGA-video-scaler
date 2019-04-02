#------------------------------------------------------
quit -sim

quietly set tb_part_path ../../scaler
do $tb_part_path/script/fifo_generic_1_compile_src.do $tb_part_path
do $tb_part_path/script/fifo_generic_2_compile_util.do $tb_part_path
do $tb_part_path/script/fifo_generic_3_compile_tb.do  $tb_part_path
do $tb_part_path/script/fifo_generic_4_simulate_tb.do $tb_part_path
