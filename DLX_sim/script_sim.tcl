set path_to_adderCore  "../DLX_scr/a.b-DataPath.core/a.b.a-Execution.core/a.b.a-Alu.core/a.b.a.a-Adder.core"
set path_to_DatapathCore "../DLX_scr/a.b-DataPath.core"
set path_to_TB "../TB"
file delete -force -- ./work

vlib work
vcom -93 -work ./work ../DLX_scr/000-globals.vhd
vcom -93 -work ./work ../DLX_scr/a.c-IRAM.vhd
vcom -93 -work ./work ../DLX_scr/a.d-DRAM.vhd
vcom -93 -work ./work  $path_to_adderCore/FUNC.vhd
vcom -93 -work  ./work $path_to_adderCore/nd2.vhd
vcom -93 -work  ./work $path_to_adderCore/iv.vhd
vcom -93 -work  ./work $path_to_adderCore/G_BLOCK.vhd
vcom -93 -work  ./work $path_to_adderCore/PG_BLOCK.vhd
vcom -93 -work  ./work $path_to_adderCore/fa.vhd
vcom -93 -work  ./work $path_to_adderCore/mux21.vhd
vcom -93 -work  ./work $path_to_adderCore/MUX_GENERIC.vhd
vcom -93 -work  ./work $path_to_adderCore/rca.vhd
vcom -93 -work  ./work $path_to_adderCore/carry_select.vhd
vcom -93 -work  ./work $path_to_adderCore/Carry_Select_Sum_Gen.vhd
vcom -93 -work  ./work $path_to_adderCore/CARRY_GENERATOR.vhd
vcom -93 -work  ./work $path_to_adderCore/../*.vhd
#vcom -93 -work  ./work $path_to_adderCore/../../mux4X1.vhd
#vcom -93 -work  ./work $path_to_adderCore/../../MUX2X1_4.vhd
#vcom -93 -work  ./work $path_to_adderCore/../../ALU_MUX2X1.vhd
#vcom -93 -work  ./work $path_to_adderCore/../../*.vhd #execution core folder.vhd
vcom -93 -work  ./work $path_to_DatapathCore/a.b.a-Decode.core/*.vhd
vcom -93 -work  ./work $path_to_DatapathCore/a.b.a-Fecht.core/*.vhd
vcom -93 -work  ./work $path_to_DatapathCore/a.b.a-Execution.core/*.vhd
vcom -93 -work  ./work $path_to_DatapathCore/a-b-a-WriteBack.core/*.vhd
vcom -93 -work  ./work $path_to_DatapathCore/*.vhd
vcom -93 -work  ./work $path_to_DatapathCore/../*.vhd
vcom -93 -work  ./work $path_to_TB/TB_DLX.vhd
vsim -t ns -novopt work.tb_dlx(test_dlx)
#add wave sim:/tb_dlx/u1/comp1/comp_dec_u/rf/*
#run 50 ns 
