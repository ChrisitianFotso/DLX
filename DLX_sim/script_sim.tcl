

vlib work
vcom -93 -work ./work ..//a.c-IRAM.vhd
vcom -93 -work ./work ..//test_bench/TB-a.c-IRAM.vhd
vsim work.TB_IRAM
#vcom -93 -work ./work ../tb/data_maker_new.vhd
#vcom -93 -work ./work ../tb/data_sink.vhd
#vcom -93 -work ./work ../src_ad/iir_ad.vhd
#vlog -work ./work ../netlist/iir_ad.v
#vlog -work ./work ../tb/tb_fir.v
#vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_fir/UUT=../netlist/iir_ad.sdf -pli /software/synopsys/syn_current/auxx/syn/power/vpower/lib-linux/libvpower.so work.tb_fir

add wave sim:TB_IRAM/*
run 30 ns
