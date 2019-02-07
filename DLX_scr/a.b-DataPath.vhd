library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity datapath is 
port (
		clock : in std_logic;
		reset : in std_logic;
		-------inputs decode unit---------
		read_port1			: in std_logic;
		read_port2      	: in std_logic;
		enable_reg_file 	: in std_logic;
		jump				: in std_logic;
		ext_mux_sel			: in std_logic;
		ext_uimm_o_imm		: in std_logic;   ---signal from cu.use to select between imm16 and uimm16
		BRANCH_OP				: IN STD_LOGIC;
		--BEQZ_OP				: IN STD_LOGIC;
		JAL_OP				: IN STD_LOGIC;  --from control------------------------
		-------inputs execute unit---------
		reg_dst_sel			: in std_logic;
		ALU_SRC_SEL     	: in std_logic;
		ALU_SRC_SEL_UP		: in std_logic;
		memread_id_ex   	: in std_logic;
		alu_op				: in std_logic_vector(ALU_OP_SIZE-1 downto 0);
		-------inputs memory_unit----------
		--memread_ex_mem		: in std_logic;
		--mem_write       	: in std_logic;
		ex_mem_reg_write	: in std_logic;
		-------inputs write back unit---------
		mem_wb_reg_write	: in std_logic;
		mux_wb_sel  		: in std_logic;
		-----------------------------------------
		from_data_memory			 	: in std_logic_vector(31 downto 0);
		from_instruction_memory 	 	: in std_logic_vector(31 downto 0);
		--------------------output---------------
		OPCODE 							: out   std_logic_vector(OPCODE_SIZE - 1 downto 0);
		FUNC				   			: out   std_logic_vector(FUNC_SIZE   - 1 downto 0);		
		data_ram_in						: out std_logic_vector(31 downto 0);
		data_ram_address				: out std_logic_vector(31 downto 0);
		from_fetchAdder_To_IFID_Pipe	: out std_logic_vector(31 downto 0);
		from_pc_To_instruction_memory	: out std_logic_vector(31 downto 0);
		stall							: out std_logic	);
end datapath;

architecture arch_datapath of datapath is 

component fetch_unit is
  port (
		clk              		: in std_logic;
		reset              		: in std_logic;
		from_branch_comparator  : in std_logic;
		jump_signal         	: in std_logic;
		enable_pc          		: in std_logic;
		from_ID_adder          	: in std_logic_vector(31 downto 0); 
		to_iram          		: out std_logic_vector(31 downto 0);        
		to_pc_id_if_reg         : out std_logic_vector(31 downto 0);         
		flush_signal     		: out std_logic    
	);
end component;


component decode_unit is
port( 	CLK				: 	IN std_logic;  
		RESET			: 	IN std_logic;  
		ENABLE			: 	IN std_logic;  -----------------------------------------
		RD1_CU			: 	IN std_logic;  --from control unit
		RD2_CU			:	IN std_logic;  --from control unit
		WR_CU			: 	IN std_logic;  --from control unit
		MEM_READ		:	IN std_logic;  --from control unit
		EXT_MUX_SEL		:	IN std_logic;  --from control unit / signal from CU.use to select between imm16 and imm26 
		EXT_UIMM_O_IMM	:   IN STD_LOGIC;  --from control unit / signal from CU.use to select between imm16 and uimm16
		BRANCH_OP		:	IN STD_LOGIC;  --from control
		--BEQZ_OP			:   IN STD_LOGIC;  --from control----------------------------
		JAL_OP			:   IN STD_LOGIC;  --from control------------------------
		RT_ADDRESS_IDEX	:	IN std_logic_vector(4 downto 0); -- RT_ADDRESS feeddback from id stage to decode stage
		WR_ADDRESS		: 	IN std_logic_vector(4 downto 0); -- WRITE ADDRESS OF THE REGISTER FILE --(FROM THE WRITE BACK STAGE)
		PC_FROM_IFID_PIPE:	IN std_logic_vector(31 downto 0);
		INSTRUC_DECODE 	:	IN std_logic_vector(31 downto 0);
		DATAIN			: 	IN std_logic_vector(31 downto 0); --data to be stored in the register file
		BRANCH_TAKEN	:	OUT STD_LOGIC;
		ENABLE_IF_ID_REG:	OUT STD_LOGIC;
		PC_JUMP			:   OUT std_logic_vector(31 downto 0); --new value of the pc in case the branch has been taken
		DATA_EXT		: 	OUT std_logic_vector(31 downto 0);
		REG_OUT1		: 	OUT std_logic_vector(31 downto 0);
		REG_OUT2		: 	OUT std_logic_vector(31 downto 0);
		--PC_OUT			:	OUT std_logic_vector(31 downto 0);		
		OPCODE 			:   OUT   std_logic_vector(OPCODE_SIZE - 1 downto 0);
		FUNC   			:   OUT   std_logic_vector(FUNC_SIZE   - 1 downto 0);
		ID_RS_REG		: 	OUT std_logic_vector(4 downto 0);--------
		ID_RT_REG		:	OUT std_logic_vector(4 downto 0);----ADRESSES
		ID_DESTREG_RT	:	OUT std_logic_vector(4 downto 0);----
		ID_DESTREG_RD	:	OUT std_logic_vector(4 downto 0);--------
		STALL			:	OUT std_logic); --signal generated in case of stall and will be an input of the control unit
end component;

component execute_unit is
	port(
		IMM_DATA_EX					: 	IN std_logic_vector(31 downto 0);--IMMEDIATE DATA 
		ALU_OP 						: 	IN STD_LOGIC_VECTOR(ALU_OP_SIZE-1 downto 0);
		REG_OUT1_EX					: 	IN std_logic_vector(31 downto 0);--DATA COMING FROM REGISTER FILE
		REG_OUT2_EX					: 	IN std_logic_vector(31 downto 0);--DATA COMING FROM REGISTER FILE
		PC_IN						:	IN std_logic_vector(31 downto 0);		
		ID_RS_REG_EX				: 	IN std_logic_vector(4 downto 0); -----------
		ID_RT_REG_EX				:	IN std_logic_vector(4 downto 0); --ADRESSES 
		ID_DESTREG_RT_EX			:	IN std_logic_vector(4 downto 0); --
		ID_DESTREG_RD_EX			:	IN std_logic_vector(4 downto 0); --
		DESTREG_ADDRESS_EX_MEM		:   IN std_logic_vector(4 downto 0); --
		DESTREG_ADDRESS_MEM_WR		:	IN std_logic_vector(4 downto 0); --
		WR_CU_MEM					: 	IN std_logic; --SIGNAL TO SET WHEN A WRITE TO A REGISTER IS DETECTED (IN THE EX/MEN STAGE) --  FROM THE CONTROL UNIT
		WR_CU_WB					: 	IN std_logic; --SIGNAL TO SET WHEN A WRITE TO A REGISTER IS DETECTED (IN THE MEM/WRITEBACK STAGE)--  FROM THE CONTROL UNIT	
		REG_DST_SEL					:	IN std_logic; --SIGNAL that SELECT THE DESTINATION REGISTER (RT FOR I-TYPE, RD FOR R-TYPE)
		ALU_SRC_SEL					:	IN std_logic;--SIGANAL that SELECT THE THE SECOND INPUT OF THE ALU ( FROM THE IMMEDIATE VALUE OR FROM THE LOWER MUX MANAGING THE FORWARDING )
		ALU_SRC_SEL_UP				:	IN std_logic;
		ALU_FEEDBACK_EXMEM			: 	IN STD_LOGIC_VECTOR(31 DOWNTO 0);--
		ALU_FEEDBACK_MEMWR			: 	IN STD_LOGIC_VECTOR(31 DOWNTO 0);--
		ALU_OUT						: 	OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		MEM_DATA_WR					: 	OUT STD_LOGIC_VECTOR(31 DOWNTO 0);-- DATA TO STORE IN THE DATA MEMORY
		DESTREG_ADDRESS				:   OUT std_logic_vector(4 downto 0));--ADDRESS OF THE FINAL DESTINATION REGISTER
end component;

-- component memory_unit is 
	-- port (
	-- DESTREG_ADDRESS_EX_MEM			: INOUT std_logic_vector(4 downto 0); --TO BE FORWARDED IN THE MEM_WB PIPE REGISTERS
	-- FROM_ALU						: INOUT std_logic_vector(31 downto 0);--TO BE FORWARDED IN THE DATA MEMORY
	-- ALU_FEEDBACK			        : OUT std_logic_vector(31 downto 0);
	-- DESTREG_ADDRESS_EX_MEM_TOFWUNIT : OUT std_logic_vector(4 downto 0); 
	-- ALU_EX_MEM_OUT					: OUT std_logic_vector(31 downto 0)); --ALU DATA THAT ARE NOT THE RESULT OF AN OPERATION WITH ACCESS TO MEMORY
-- END component memory_unit;

component write_back_unit is
	port(
		MUX_WB_SEL : in std_logic; --from control unit
		data_from_memory : in std_logic_vector(31 downto 0);
		data_from_alu : in std_logic_vector(31 downto 0);
		write_back_value : out std_logic_vector(31 downto 0)); -- to be forwarded to the decode_unit and the execute_unit
end component;

component InstructionRegister is
	port(
		clock,reset,enable,flush : in std_logic;
		data_in  : in std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end component;

component pc_id_if_reg  is
	port(
		clock,reset,enable,flush : in std_logic;
		data_in  : in std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end component;

component ID_EX_PIPE_REG is
  port (
		CLK				        : 	IN std_logic;
		RESET			        : 	IN std_logic;
		ENABLE					:	IN std_logic;
		DATA_EXT_PIPE_IN		: 	IN std_logic_vector(31 downto 0);    
		--REG_OUT1_PIPE_IN		: 	IN std_logic_vector(31 downto 0);	
		--REG_OUT2_PIPE_IN		: 	IN std_logic_vector(31 downto 0);	
		ID_RS_REG_PIPE_IN		: 	IN std_logic_vector(4 downto 0);    
		ID_RT_REG_PIPE_IN		:	IN std_logic_vector(4 downto 0);    
		ID_DESTREG_RT_PIPE_IN	:	IN std_logic_vector(4 downto 0);    
		ID_DESTREG_RD_PIPE_IN	:	IN std_logic_vector(4 downto 0);    
		PC						:	IN std_logic_vector(31 downto 0);
		DATA_EXT_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);                    
		--REG_OUT1_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);    
		--REG_OUT2_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);
		ID_RS_REG_PIPE_OUT		: 	OUT std_logic_vector(4 downto 0); 
		ID_RT_REG_PIPE_OUT		:	OUT std_logic_vector(4 downto 0); 
		ID_DESTREG_RT_PIPE_OUT	:	OUT std_logic_vector(4 downto 0); 
		ID_DESTREG_RD_PIPE_OUT	:	OUT std_logic_vector(4 downto 0);
		PC_OUT					:	OUT std_logic_vector(31 downto 0)); 
end component;

component EX_MEM_PIPE_REG is
  port (
		CLK				        	: 	IN std_logic;
		RESET			        	: 	IN std_logic;
		ENABLE						:	IN std_logic;
		ALU_OUT_PIPE_IN				: 	IN std_logic_vector(31 downto 0);    
		DATA_MEM_PIPE_IN			: 	IN std_logic_vector(31 downto 0);	
		DESTREG_ADDRESS_PIPE_IN		: 	IN std_logic_vector(4 downto 0);	
		ALU_OUT_PIPE_OUT			: 	OUT std_logic_vector(31 downto 0);                    
		DATA_MEM_PIPE_OUT			: 	OUT std_logic_vector(31 downto 0);
		DESTREG_ADDRESS_PIPE_OUT	: 	OUT std_logic_vector(4 downto 0)); 
end component;


component MEM_WB_PIPE_REG is
  port (
		CLK				        	: 	IN std_logic;
		RESET			        	: 	IN std_logic;
		ENABLE						:	IN std_logic;
		ALU_OUT_PIPE_IN				: 	IN std_logic_vector(31 downto 0);     
                --DATA_MEMOUT_PIPE_IN			: 	IN std_logic_vector(31 downto 0);	
		DESTREG_ADDRESS_PIPE_IN		: 	IN std_logic_vector(4 downto 0);	
		ALU_OUT_PIPE_OUT			: 	OUT std_logic_vector(31 downto 0);                    
		--DATA_MEMOUT_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);
		DESTREG_ADDRESS_PIPE_OUT	: 	OUT std_logic_vector(4 downto 0)); 
end component;

signal from_branch_comparator_sig : std_logic ;
signal hazard_unit_out : std_logic; -- hazard unit output ---> enable pc and if/id register pipe
signal from_ID_adder_sig   : std_logic_vector(31 downto 0);
signal to_pc_id_if_reg_sig : std_logic_vector(31 downto 0);
signal flush_signal_sig : std_logic;
signal instruction_sig :std_logic_vector(31 downto 0);
signal PC_id_sig : std_logic_vector(31 downto 0);
--signal memread_id_ex_sig : std_logic;
--signal RT_ADDRESS_IDEX_sig : std_logic_vector(4 downto 0);
--signal WR_ADDRESS_sig :	std_logic_vector(4 downto 0);-- from wb to decode
--signal data_in_sig : std_logic_vector(4 downto 0);-- from wb to decode
signal imm_32 : std_logic_vector(31 downto 0);
signal port_a_out  : std_logic_vector(31 downto 0);
signal port_b_out  : std_logic_vector(31 downto 0);
signal ID_RS_REG_SIG	 :  std_logic_vector(4 downto 0);
signal ID_RT_REG_SIG	 : std_logic_vector(4 downto 0);
signal ID_DESTREG_RT_SIG : std_logic_vector(4 downto 0);
signal ID_DESTREG_RD_SIG : std_logic_vector(4 downto 0);
signal imm_32_ex : std_logic_vector(31 downto 0);
signal port_a_out_ex  : std_logic_vector(31 downto 0);
signal port_b_out_ex  : std_logic_vector(31 downto 0);
signal RS_REG_EX_SIG	 : 	 std_logic_vector(4 downto 0);
signal RT_REG_EX_SIG	 :	 std_logic_vector(4 downto 0);
signal DESTREG_RT_EX_SIG :	 std_logic_vector(4 downto 0);
signal DESTREG_RD_EX_SIG :	 std_logic_vector(4 downto 0);
signal DESTREG_ADDRESS_EX_MEM_SIG : std_logic_vector(4 downto 0);
--signal DESTREG_ADDRESS_MEM_WR_SIG : std_logic_vector(4 downto 0);
signal ALU_FEEDBACK_EXMEM_SIG :STD_LOGIC_VECTOR(31 downto 0);
--signal ALU_FEEDBACK_MEMWR_SIG :STD_LOGIC_VECTOR(31 downto 0);
signal ALU_OUT_SIG			:	STD_LOGIC_VECTOR(31 downto 0);	
SIGNAL PC_SIG_EX : STD_LOGIC_VECTOR(31 downto 0);	
signal MEM_DATA_WR_SIG 		:STD_LOGIC_VECTOR(31 downto 0);		
signal DESTREG_ADDRESS_SIG 	: STD_LOGIC_VECTOR(4 downto 0);
signal ALU_OUT_MEM_SIG		:	STD_LOGIC_VECTOR(31 downto 0);	
signal ALU_EX_MEM_OUT_SIG	:STD_LOGIC_VECTOR(31 downto 0);		
signal DESTREG_ADDRESS_MEM_PIPE_SIG 	  	: STD_LOGIC_VECTOR(4 downto 0);
--signal ALU_FEEDBACK_SIG : std_logic_vector(31 downto 0);
--signal DESTREG_ADDRESS_EX_MEM_TOFWT_SIG : std_logic_vector(4 downto 0);
signal ALU_WB_OUT_PIPE_OUT			:  std_logic_vector(31 downto 0);
signal DATA_MEM_WB_PIPE_OUT				:  std_logic_vector(31 downto 0);
signal DESTREG_ADD_WB_PIPE_OUT		:  std_logic_vector(4 downto 0);
signal WRITE_BACK_WB_OUT :  std_logic_vector(31 downto 0);

begin 

--memread_id_ex_sig <= memread_id_ex;
data_ram_address<=ALU_OUT_MEM_SIG;

comp_FU : fetch_unit
		 port map(
		 clock,
		 reset,
		 from_branch_comparator_sig,
		 jump,
		 hazard_unit_out,
		 from_ID_adder_sig,
		 from_pc_To_instruction_memory,
		 to_pc_id_if_reg_sig,
		 flush_signal_sig);

comp_IR : InstructionRegister
			port map (
			clock,
			reset,
			hazard_unit_out,
			flush_signal_sig,
			from_instruction_memory,
			instruction_sig
			);
			
comp_id_if_reg : pc_id_if_reg
			port map (
			clock,
			reset,
			hazard_unit_out,
			flush_signal_sig,
			to_pc_id_if_reg_sig,
			PC_id_sig
			);
			
comp_dec_U: decode_unit
			port map (
			clock,
			reset,
			enable_reg_file,
			read_port1,
			read_port2,
			mem_wb_reg_write,
			memread_id_ex,
			ext_mux_sel,
			ext_uimm_o_imm, --ICI
			BRANCH_OP,
			--BEQZ_OP,
			JAL_OP,
			DESTREG_RT_EX_SIG,
			--RT_ADDRESS_IDEX_sig,
			--WR_ADDRESS_sig,
			DESTREG_ADD_WB_PIPE_OUT,
			PC_id_sig,
			instruction_sig,
			WRITE_BACK_WB_OUT,
			from_branch_comparator_sig,
			hazard_unit_out,
			from_ID_adder_sig,
			imm_32,
			port_a_out,
			port_b_out,
			--PC_id_sig,
			OPCODE,
			FUNC ,
			ID_RS_REG_SIG,	
			ID_RT_REG_SIG,	
			ID_DESTREG_RT_SIG,
			ID_DESTREG_RD_SIG,
			stall
			);
			
COMP_ID_EX_PIPE_REG : ID_EX_PIPE_REG
		PORT MAP (
		clock,
		reset,
		'1',
		imm_32,
		--port_a_out,
		--port_b_out,
		ID_RS_REG_SIG,	
		ID_RT_REG_SIG,	
		ID_DESTREG_RT_SIG,
		ID_DESTREG_RD_SIG,
		PC_id_sig,
		imm_32_ex,
		--port_a_out_ex,
		--port_b_out_ex,
		RS_REG_EX_SIG,	
		RT_REG_EX_SIG,	
		DESTREG_RT_EX_SIG,
		DESTREG_RD_EX_SIG,
		PC_SIG_EX
		);
COMP_EXEC_U : execute_unit
		port map(
		imm_32_ex,
		alu_op,
		port_a_out,
		port_b_out,
		PC_SIG_EX,
		RS_REG_EX_SIG,
		RT_REG_EX_SIG,
		DESTREG_RT_EX_SIG,
		DESTREG_RD_EX_SIG,
		DESTREG_ADDRESS_MEM_PIPE_SIG,
		DESTREG_ADD_WB_PIPE_OUT,
		--DESTREG_ADDRESS_MEM_WR_SIG,
		--memread_id_ex_sig,
		--memread_id_ex,
		ex_mem_reg_write,	
		mem_wb_reg_write,
		reg_dst_sel,
        ALU_SRC_SEL,
		ALU_SRC_SEL_UP,
		ALU_OUT_MEM_SIG,
		WRITE_BACK_WB_OUT,
		ALU_OUT_SIG,			
		MEM_DATA_WR_SIG, 		
		DESTREG_ADDRESS_SIG 	
		);

COMP_EX_MEM_PIPE : EX_MEM_PIPE_REG
		PORT MAP(
		clock,
		reset,
		'1',
		ALU_OUT_SIG,
		MEM_DATA_WR_SIG,
		DESTREG_ADDRESS_SIG, 
		ALU_OUT_MEM_SIG,				
		data_ram_in, 		
		DESTREG_ADDRESS_MEM_PIPE_SIG 
		);

-- COMP_MEMORY : memory_unit
		-- port map(
		-- DESTREG_ADDRESS_MEM_PIPE_SIG,
		-- ALU_OUT_MEM_SIG,
		-- ALU_FEEDBACK_EXMEM_SIG,
		-- DESTREG_ADDRESS_EX_MEM_SIG,
		-- ALU_EX_MEM_OUT_SIG
		-- );
	
	
COMP_MEM_WB : MEM_WB_PIPE_REG
		PORT MAP (
		clock,
		reset,
		'1',
		ALU_OUT_MEM_SIG,
		--from_data_memory,
		DESTREG_ADDRESS_MEM_PIPE_SIG,
		ALU_WB_OUT_PIPE_OUT,	
		--DATA_MEM_WB_PIPE_OUT,			
		DESTREG_ADD_WB_PIPE_OUT	);
		
COMP_WB: write_back_unit
	port map(
	mux_wb_sel,
	from_data_memory,
	ALU_WB_OUT_PIPE_OUT,
	WRITE_BACK_WB_OUT
	);
	

end architecture; 
