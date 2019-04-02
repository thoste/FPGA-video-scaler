#------------------------------------------------------
quit -sim

quietly set tb_part_path ../../scaler
do $tb_part_path/script/simple_dpram/simple_dpram_1_compile_src.do $tb_part_path
do $tb_part_path/script/simple_dpram/simple_dpram_2_compile_util.do $tb_part_path
do $tb_part_path/script/simple_dpram/simple_dpram_3_compile_tb.do  $tb_part_path
do $tb_part_path/script/simple_dpram/simple_dpram_4_simulate_tb.do $tb_part_path
