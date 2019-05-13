#------------------------------------------------------
quit -sim

quietly set tb_part_path ../../scaler
do $tb_part_path/script/multiport_ram/multiport_ram_1_compile_src.do $tb_part_path
do $tb_part_path/script/multiport_ram/multiport_ram_2_compile_util.do $tb_part_path
do $tb_part_path/script/multiport_ram/multiport_ram_3_compile_tb.do  $tb_part_path
do $tb_part_path/script/multiport_ram/multiport_ram_4_simulate_tb.do $tb_part_path
