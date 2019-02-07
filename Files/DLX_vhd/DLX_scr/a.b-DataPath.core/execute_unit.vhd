library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use ieee.numeric_std.all;

entity execute_unit is
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
end execute_unit;

architecture arch_execute_unit of execute_unit is 

component FORWARD_UNIT is
	port(
		EX_MEM_Write : in std_logic;
		EX_MEM_Rd : in std_logic_vector(4 downto 0);
		ID_EX_Rs : in std_logic_vector(4 downto 0);
		ID_EX_Rt : in std_logic_vector(4 downto 0);
		MEM_WB_write : in std_logic;
		MEM_WB_Rd : in std_logic_vector(4 downto 0);
		
		sel_lower_mux : out std_logic_vector(1 downto 0);--multiplexer select signal
		sel_upper_mux : out std_logic_vector(1 downto 0)-- //--
	);
end component;


COMPONENT MUX2X1_4 is
	port(
		a : in std_logic_vector(4 downto 0);
		b : in std_logic_vector(4 downto 0);
		sel : in std_logic;
		o : out std_logic_vector(4 downto 0)
		);
end COMPONENT;


COMPONENT ALU_MUX2X1 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		sel : in std_logic;
		o : out std_logic_vector(31 downto 0)
		);
end COMPONENT;


component mux4X1 is
	Port (
		a:	in	std_logic_vector(31 downto 0);
		b:	in	std_logic_vector(31 downto 0);
		c:  in	std_logic_vector(31 downto 0);
		s:	in	std_logic_vector(1 downto 0);
		y:	out	std_logic_vector(31 downto 0)
		);
end component;

component ALU is
		GENERIC(DATA_SIZE: INTEGER :=DATA_SIZE);
		port(ALU_OP: STD_LOGIC_VECTOR(ALU_OP_SIZE-1 downto 0):=(others=>'0');
		    A, B: in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
			OUTALU: OUT std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0')
			);
END component;


SIGNAL MUX_UP_OUT  	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MUX_DOWN_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MUX_ALU_OUT 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MUX_ALU_OUT_UP 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SEL_LOWER_MUX : STD_LOGIC_VECTOR(1 downto 0);
SIGNAL SEL_UPPER_MUX : STD_LOGIC_VECTOR(1 downto 0);

begin 

FU:FORWARD_UNIT
	PORT MAP(WR_CU_MEM,DESTREG_ADDRESS_EX_MEM,ID_RS_REG_EX,ID_RT_REG_EX,WR_CU_WB,DESTREG_ADDRESS_MEM_WR,SEL_LOWER_MUX,SEL_UPPER_MUX);

COMP_ALU: ALU 
	PORT MAP(ALU_OP,MUX_ALU_OUT_UP,MUX_ALU_OUT,ALU_OUT);

EXEC_MUX4X1_UP:mux4X1
	PORT MAP(REG_OUT1_EX,ALU_FEEDBACK_MEMWR,ALU_FEEDBACK_EXMEM,SEL_UPPER_MUX,MUX_UP_OUT );

EXEC_MUX4X1_DOWN:mux4X1
	port map(REG_OUT2_EX,ALU_FEEDBACK_MEMWR,ALU_FEEDBACK_EXMEM,SEL_LOWER_MUX,MUX_DOWN_OUT );

EXEC_MUX2X1_DESTREG:mux2X1_4
	port map(ID_DESTREG_RT_EX,ID_DESTREG_RD_EX,REG_DST_SEL,DESTREG_ADDRESS);

EXEC_ALU_MUX:ALU_MUX2X1
	port map(MUX_DOWN_OUT,IMM_DATA_EX,ALU_SRC_SEL,MUX_ALU_OUT);

EXEC_ALU_MUX1:ALU_MUX2X1
	port map(MUX_UP_OUT,PC_IN,ALU_SRC_SEL_UP,MUX_ALU_OUT_UP);

MEM_DATA_WR<=MUX_DOWN_OUT;
end arch_execute_unit;
