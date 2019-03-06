#------------------------------------------------------
quit -sim

quietly set tb_part_path ../../scaler
do $tb_part_path/script/compile_src.do $tb_part_path
do $tb_part_path/script/compile_util.do $tb_part_path
do $tb_part_path/script/compile_tb.do  $tb_part_path
do $tb_part_path/script/simulate_tb.do $tb_part_path
