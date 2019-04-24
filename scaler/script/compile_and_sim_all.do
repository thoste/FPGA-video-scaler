#------------------------------------------------------
quit -sim

quietly set tb_part_path ../../scaler
do $tb_part_path/script/scaler_complete/scaler_complete_1_compile_src.do $tb_part_path
do $tb_part_path/script/scaler_complete/scaler_complete_2_compile_util.do $tb_part_path
do $tb_part_path/script/scaler_complete/scaler_complete_3_compile_tb.do  $tb_part_path
do $tb_part_path/script/scaler_complete/scaler_complete_4_simulate_tb.do $tb_part_path
