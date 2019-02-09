# DLX
DLX implementation in VHDL
click [instruction.pdf](https://github.com/ChrisitianFotso/DLX/blob/master/instruction_set.pdf) to see the instruction set list.
# HOW TO 
The whole design has been simulated with modelsim se 6.2g. 
Before the simulation we have to load the program instruction's in the instruction memory. Some programs are available in the asm_example folder. You can write you own program and load it in the instruction memory. To do it:  
- move to asm_example folder 
- sh assembler.sh [path_to_your_asm_file] 
In order to compile the design :  
	- move to sim_dlx folder 
	- launch modelsim  
	- run the the script [script_sim.tlc](https://github.com/ChrisitianFotso/DLX/blob/master/DLX_sim/script_sim.tcl)  
