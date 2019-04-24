#------------------------------------------------------
quit -sim

quietly set tb_part_path ../../scaler
do $tb_part_path/script/scaler/scaler_1_compile_src.do $tb_part_path
do $tb_part_path/script/scaler/scaler_2_compile_util.do $tb_part_path
do $tb_part_path/script/scaler/scaler_3_compile_tb.do  $tb_part_path
do $tb_part_path/script/scaler/scaler_4_simulate_tb.do $tb_part_path
