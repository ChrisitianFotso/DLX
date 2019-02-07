library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.myTypes.all;

entity DLX is

  port (
    Clk : in std_logic;
    Rst : in std_logic);                
end DLX;


architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------
  
--Instruction Ram

  component IRAM is
  generic (
    IRAM_DEPTH : integer := IRAM_SIZE;
    I_SIZE 	   : integer := ISTR_SIZE);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(ADDR_SIZE - 1 downto 0):=(others=>'0');
    Dout : out std_logic_vector(ISTR_SIZE - 1 downto 0):=(others=>'0')
    );
  end component;

  -- Data Ram 
 component DRAM is
	generic (
		ADDR_SIZE : integer := ADDR_SIZE;
		DATA_SIZE : integer := DATA_SIZE
	);
	port (
		RST		: in std_logic;
		CLK		: in std_logic;
		ADDR	: in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
		DIN		: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		DOUT	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		RD_EN	: in std_logic;
		WR_EN   : in std_logic 
);
end component;
  
-- Datapath

component datapath is 
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
end component;
  
  -- Control Unit
component dlx_cu is
port (
		-- inputs decode unit
		read_port1			: OUT std_logic:='0';
		read_port2      	: OUT std_logic:='0';				
		enable_reg_file 	: OUT std_logic:='0';				
		jump				: OUT std_logic:='0';				
		EXT_MUX_SEL			: OUT std_logic:='0';
		EXT_UIMM_O_IMM		: OUT std_logic:='0';
		BRANCH_OP           : OUT std_logic:='0';
		--BEQZ_OP             : OUT std_logic:='0';
		JAL_OP				: OUT STD_LOGIC;  --from control------------------------		
		-------inputs execute unit---------
		reg_dst_sel			: OUT std_logic:='0';               
		ALU_SRC_SEL     	: OUT std_logic:='0';               
		ALU_SRC_SEL_UP		: OUT std_logic:='0';
		memread_id_ex   	: OUT std_logic:='0';               
		alu_op				: OUT std_logic_vector(ALU_OP_SIZE-1 downto 0):=(others=>'0');               
		-------inputs memory_unit----------
		memread_ex_mem		: OUT std_logic:='0';
		mem_write       	: OUT std_logic:='0';
		ex_mem_reg_write	: OUT std_logic:='0';-- TELL US IF IS IS A WRITE BACK OPERATION
		-------inputs write back unit---------
		mem_wb_reg_write	: OUT std_logic:='0';
		mux_wb_sel  		: OUT std_logic:='0';
		-------input control_unit-----------------
		--IR_IN : in  std_logic_vector(31 downto 0):=(others=>'0');              
		OPCODE : in  std_logic_vector(OPCODE_SIZE - 1 downto 0);
		FUNC : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
		Clk : in std_logic:='0';
		Rst : in std_logic:='0';
		stall_flag: in std_logic:='0');         

end component;


  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------
  
  -- Instruction Register (IR) and Program Counter (PC) declaration
 -- signal IR : std_logic_vector(IR_SIZE - 1 downto 0);
 -- signal PC : std_logic_vector(PC_SIZE - 1 downto 0);

  -- Instruction Ram Bus signals
 -- signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);

  -- Datapath Bus signals
  --signal PC_BUS : std_logic_vector(PC_SIZE -1 downto 0);

	signal read_port1_i : std_logic;		
	signal read_port2_i : std_logic; 
	signal enable_reg_file_i : std_logic; 
	signal jump_i : std_logic;			
	signal EXT_MUX_SEL_i : std_logic;		
	signal EXT_UIMM_O_IMM_i : std_logic;	
	signal BRANCH_OP_i : std_logic;              
	signal JAL_OP_i : std_logic;			
	signal reg_dst_sel_i : std_logic;		
	signal ALU_SRC_SEL_i : std_logic;     
	signal ALU_SRC_SEL_UP_i : std_logic;	
	signal memread_id_ex_i : std_logic;   
	signal alu_op_i : std_logic_vector(ALU_OP_SIZE-1 downto 0);			
	signal memread_ex_mem_i : std_logic;	
	signal mem_write_i : std_logic;       
	signal ex_mem_reg_write_i : std_logic;
	signal mem_wb_reg_write_i : std_logic;
	signal mux_wb_sel_i : std_logic;  	
	signal from_data_memory_i :  std_logic_vector(31 downto 0);		
	signal from_instruction_memory_i : std_logic_vector(31 downto 0);
	signal OPCODE_i : std_logic_vector(OPCODE_SIZE - 1 downto 0);
	signal FUNC_i : std_logic_vector(FUNC_SIZE - 1 downto 0);
	signal data_ram_in_i					: std_logic_vector(31 downto 0);
	signal data_ram_address_i			    : std_logic_vector(31 downto 0);
    signal from_fetchAdder_To_IFID_Pipe_i   : std_logic_vector(31 downto 0);
    signal from_pc_To_instruction_memory_i  : std_logic_vector(31 downto 0);
	signal stall_i : std_logic;
  
  
begin  

comp1: datapath
		port map (
clk,
rst,
read_port1_i 		,
read_port2_i        ,
enable_reg_file_i   ,
jump_i 			    ,
EXT_MUX_SEL_i 		,
EXT_UIMM_O_IMM_i 	,
BRANCH_OP_i         ,
JAL_OP_i 			,
reg_dst_sel_i 	    ,
ALU_SRC_SEL_i       ,
ALU_SRC_SEL_UP_i    ,
memread_id_ex_i     ,
alu_op_i 			,
--memread_ex_mem_i 	,
--mem_write_i         ,
ex_mem_reg_write_i  ,
mem_wb_reg_write_i  ,
mux_wb_sel_i  	    ,
from_data_memory_i,		
from_instruction_memory_i, 
OPCODE_i            ,
FUNC_i              ,
data_ram_in_i		,			
data_ram_address_i	,		    
from_fetchAdder_To_IFID_Pipe_i ,  
from_pc_To_instruction_memory_i , 
stall_i		
);

comp2 : dlx_cu
       port map(
read_port1_i 		,
read_port2_i        ,
enable_reg_file_i   ,
jump_i 			    ,
EXT_MUX_SEL_i 		,
EXT_UIMM_O_IMM_i 	,
BRANCH_OP_i         ,
JAL_OP_i 			,
reg_dst_sel_i 	    ,
ALU_SRC_SEL_i       ,
ALU_SRC_SEL_UP_i    ,
memread_id_ex_i     ,
alu_op_i 			,
memread_ex_mem_i 	,
mem_write_i         ,
ex_mem_reg_write_i  ,
mem_wb_reg_write_i  ,
mux_wb_sel_i  	    ,
OPCODE_i            ,
FUNC_i              ,
clk,
rst,
stall_i
);

comp3 : iram 
		port map (
		rst,
		from_pc_To_instruction_memory_i, 
		from_instruction_memory_i
		);

comp4 : dram 
		port map (
		rst,
		clk,
		data_ram_address_i,
		data_ram_in_i,
		from_data_memory_i,
		memread_ex_mem_i,
		mem_write_i
		);

    
    
end dlx_rtl;
