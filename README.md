# DLX
DLX implementation in VHDL
click [instruction.pdf](https://github.com/ChrisitianFotso/DLX/blob/master/instruction_set.pdf) to see the instruction set list.
# HOW TO 
The whole design has been simulated with modelsim.
Before the simulation we have to load the program instuction's in the instruction memory.Some programs are available in the asm_example folder.You can write you own program and load it in the instruction memory.To do it :
	-go the in asm_folder
	-sh assembler.sh [path_to_your_asm_file]
In order to compile the design, the go in the folder sim_dlx, launch modelsim and run the the script [script_sim.tlc] (https://github.com/ChrisitianFotso/DLX/blob/master/DLX_sim/script_sim.tcl)  
