library ieee;
use ieee.std_logic_1164.all;

package myTypes is
	constant DATA_SIZE 		: integer	:= 32;			-- Data size
	constant ISTR_SIZE		: integer	:= 32;			-- Instruction size
	constant RF_WORD    	: integer   := 32;
	constant RF_ADDRESS 	: integer   := 5;
	constant ADDR_SIZE		: integer	:= 32;			-- Address size
	constant ALU_OP_SIZE	: integer	:= 5;		-- ALU Operation Code Size
	constant CW_SIZE		: integer	:= 17;		-- Control Word size
	constant OPCODE_SIZE	: integer	:= 6;			-- Operation code size
	constant FUNC_SIZE		: integer	:= 11;			-- Function code size
	constant IMME_SIZE		: integer	:= 16;			-- Immediate value size
	--constant OFFSET_MEM_SIZE 	 : integer	:= 64;
	constant MICROCODE_MEM_SIZE  : INTEGER  := 10;
	--constant C_CTR_CALU_SIZE	: integer	:= 5;			-- ALU Operation Code size
	--constant C_CTR_DRCW_SIZE	: integer	:= 4;			-- Data Memory Control word size
	constant REG_NUM	: integer	:= 32;			-- Number of Register in Register File
	--constant C_REG_GLOBAL_NUM	: integer	:= 8;			-- Number of Global register in register file
	--constant C_REG_GENERAL_NUM	: integer	:= 8;			-- Number of General registers (I/L/O) in register file
	
	constant IRAM_SIZE	: integer	:= 4096;		-- IRAM size
	constant DRAM_SIZE	: integer	:= 1024;		-- DRAM size
	constant MEM_WORD	: integer 	:= 8;  			-- MEMORY WORD SIZE
	
	
	------------------------OPCODE FIELD-----------------------------------
	
	-- R-Type instruction -> FUNC field
	constant FUNC_sll  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";   
	constant FUNC_srl  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";   
	constant FUNC_sra  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";
	constant FUNC_add  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100000";
	constant FUNC_addu : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100001";
	constant FUNC_sub  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100010";
	constant FUNC_subu : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100011";
	constant FUNC_and  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100100";
	constant FUNC_or   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100101";
	constant FUNC_xor  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100110";
	constant FUNC_seq  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101000";
	constant FUNC_sne  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101001";
	constant FUNC_slt  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101010";
	constant FUNC_sgt  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101011";
	constant FUNC_sle  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101100";
	constant FUNC_sge  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101101";
    constant FUNC_sltu : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111010";	
	constant FUNC_sgtu : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111011";
	constant FUNC_sleu : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111100";
	constant FUNC_sgeu : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111101";
	
	-- to be completed with the others 2 alu operation
	
	constant NOP : std_logic_vector(FUNC_SIZE  - 1 downto 0) :=  "00000000000";
	--constant NOP1 : std_logic_vector(CW_SIZE  - 1 downto 0) :=  "0000000000000";
	-- R-Type instruction -> OPCODE field
	constant OPCD_R		: std_logic_vector(OPCODE_SIZE-1 downto 0) := "000000";	--0x00
	constant OPCD_J		: std_logic_vector(OPCODE_SIZE-1 downto 0) := "000010";	--0x02
	constant OPCD_JAL	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "000011";	--0x03
	constant OPCD_BEQZ	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "000100";	--0x04
	constant OPCD_BNEZ	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "000101";	--0x05
	constant OPCD_ADDI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "001000";	--0x08
	constant OPCD_ADDUI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "001001";	--0x09
	constant OPCD_SUBI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "001010";	--0x0a
	constant OPCD_SUBUI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "001011";	--0x0b
	constant OPCD_ANDI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "001100";	--0x0c
	constant OPCD_ORI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "001101";	--0x0d
	constant OPCD_XORI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "001110";	--0x0e
	constant OPCD_SLLI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "010100";	--0x14
	constant OPCD_NOP	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "010101";	--0x15
	constant OPCD_SRLI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "010110";	--0x16
	--constant OPCD_SRAI	: std_logic_vecOPCODE_SIZESIZE-1 downto 0) := "010111";	--0x17
	constant OPCD_SEQI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "011000";	--0x18
	constant OPCD_SNEI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "011001";	--0x19
	constant OPCD_SLTI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "011010";	--0x1a
	constant OPCD_SGTI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "011011";	--0x1b
	constant OPCD_SLEI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "011100";	--0x1c
	constant OPCD_SGEI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "011101";	--0x1d
	constant OPCD_LW	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "100011"; --0x23
	constant OPCD_SW	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "101011"; --0x2b
	constant OPCD_SLTUI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "111010";	--0x3a
	constant OPCD_SGTUI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "111011";	--0x3b
	constant OPCD_SLEUI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "111100";	--0x3c
	constant OPCD_SGEUI	: std_logic_vector(OPCODE_SIZE-1 downto 0) := "111101";	--0x3d
	
	--constant OPCD_TYPE_NOP   : std_logic_vector (OPCD_SIZE-1 downto 0) := "010101";
	
	-- ALU OPERATION
	constant OP_ADD		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00000";
	constant OP_SUB		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00001";
	constant OP_AND		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00010";
	constant OP_OR		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00011";
	constant OP_XOR		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00100";
	constant OP_SLL		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00101";
	constant OP_SRL		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00110";
	constant OP_SLE 	: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "00111";
	constant OP_SLT	  	: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "01001";
	constant OP_SGT		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "01011";
	constant OP_SGE		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "01101";
	constant OP_SEQ		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "01111";
	constant OP_SNE		: std_logic_vector(ALU_OP_SIZE-1 downto 0) := "10001";
	CONSTANT OP_SGEU    : std_logic_vector(ALU_OP_SIZE-1 downto 0) := "10011";
	CONSTANT OP_SGTU    : std_logic_vector(ALU_OP_SIZE-1 downto 0) := "10101";
    CONSTANT OP_SLEU    : std_logic_vector(ALU_OP_SIZE-1 downto 0) := "10111";
	CONSTANT OP_SLTU    : std_logic_vector(ALU_OP_SIZE-1 downto 0) := "11001";
	
	constant NUM_BIT2SHIFT : INTEGER := 5;
	
	-- type aluOp is (
		-- NOP, ADDS, LLS, LRS --- to be completed
			-- );
			
	-------------------------------------------------------------------------------------------------------
	--									DAPAPATH
	-------------------------------------------------------------------------------------------------------
   constant NumBit : integer := 16;	--default data size of the inputs of the generic multiplexer  	
   constant rca_bit:integer:=16; 	--default number of bit of the RCAs used to build the carry select adder 
   constant RegBit:integer:=16;	 	--this used by the multiplier
   constant ACC_NUM_BIT:integer:=16;---this is used  or the multiplier
   constant delta_Co :integer:=4; 	----interval of generation of carries performed by the carry generator
   constant P4_BIT_NUM:integer:=32; ---number of bit of the p4 adder
   constant CS_numbit:integer:=4;	---number of bit of the carry select adder used in the adder structure
	
	
end myTypes;

