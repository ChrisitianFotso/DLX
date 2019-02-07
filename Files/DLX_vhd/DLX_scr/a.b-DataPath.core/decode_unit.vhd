library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity decode_unit is
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
		--BEQZ_OP			:   IN STD_LOGIC;  --from control---------------------------
		JAL_OP			:   IN STD_LOGIC;  --from control---------------------------
		RT_ADDRESS_IDEX	:	IN std_logic_vector(4 downto 0); -- ADDRESS
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
		OPCODE 			: out   std_logic_vector(OPCODE_SIZE - 1 downto 0);
		FUNC   			: out   std_logic_vector(FUNC_SIZE   - 1 downto 0);
		ID_RS_REG		: 	OUT std_logic_vector(4 downto 0);--------
		ID_RT_REG		:	OUT std_logic_vector(4 downto 0);----ADRESSES
		ID_DESTREG_RT	:	OUT std_logic_vector(4 downto 0);----
		ID_DESTREG_RD	:	OUT std_logic_vector(4 downto 0);--------
		STALL			:	OUT std_logic); --signal generated in case of a "true" data hazard (load followed by a the used the register loaded on the next instruction)
end decode_unit;

architecture ARCH_DECODE_UNIT of decode_unit is 

--------------COMPONENT DECLARATION -----------------------------
COMPONENT EXTENDER16_TO_32 is
port(
	ext_uimm_o_imm: in std_logic:='0'; --signal from CU.use to select between imm16 and uimm16
	data_in  : in  std_logic_vector(15 downto 0);
	data_out : out std_logic_vector(31 downto 0));
end COMPONENT;

COMPONENT EXTENDER26_TO_32 is
	port(
		data_in  : in  std_logic_vector(25 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end COMPONENT;

COMPONENT Mux2X1 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		sel : in std_logic;
		o : out std_logic_vector(31 downto 0)
		);
end COMPONENT;

COMPONENT DECODE_COMPARATOR IS 
PORT(
	DATA1  : in STD_LOGIC_VECTOR(31 downto 0);
	DATA2  : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	DATAOUT: OUT STD_LOGIC);
END COMPONENT;

COMPONENT hazardUnit is
port(
	RS_address : in std_logic_vector(4 downto 0);
	RT_address : in std_logic_vector(4 downto 0);
	RT_address_ID_EX : in std_logic_vector(4 downto 0);
	MemRead_ID_EX : in std_logic;
	enable_signal : out std_logic;
	stall		  : out std_logic);				
end COMPONENT;

COMPONENT register_file is
generic	(M:integer:=RF_WORD;
		N:INTEGER:=RF_ADDRESS);
port ( CLK: 		IN std_logic;
        RESET: 	    IN std_logic;
		ENABLE: 	IN std_logic;
		RD1: 		IN std_logic;
		RD2: 		IN std_logic;
		WR: 		IN std_logic;
		ADD_WR: 	IN std_logic_vector(N-1 downto 0);
		ADD_RD1: 	IN std_logic_vector(N-1 downto 0);
		ADD_RD2: 	IN std_logic_vector(N-1 downto 0);
		DATAIN: 	IN std_logic_vector(M-1 downto 0);
		OUT1: 		OUT std_logic_vector(M-1 downto 0);
		OUT2: 		OUT std_logic_vector(M-1 downto 0));
end COMPONENT;

COMPONENT DECODE_ADDER is
	port(PC_PIPE  			: in STD_LOGIC_VECTOR (31 downto 0);
		 DATA_SHT 			: in STD_LOGIC_VECTOR (31 downto 0);
		 DECODE_ADDER_OUT  	: out STD_LOGIC_VECTOR(31 downto 0)
		 );
END COMPONENT;

---------------------END COMPONENT DECLARATION----------------------------

------------------------SIGNAL DECLARATION----------------------------------

SIGNAL REG_OUT1_SIG   : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL REG_OUT2_SIG   : STD_LOGIC_VECTOR(31 downto 0);
--SIGNAL DATA_EXT_SHT   : STD_LOGIC_VECTOR(31 downto 0);
--SIGNAL DATA_EXT_SHT_1 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL DATA_EXT_SIG   : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DATA_EXT_SIG_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MUX_OUT 		  : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL COMP_OUT		  : STD_LOGIC;
--------------------------------------------------------------------------


begin 

RF:REGISTER_FILE
		-- generic	(M:integer:=RF_WORD;
			-- N:INTEGER:=RF_ADDRESS);
		port map (
			CLK => CLK,
			RESET => RESET,
			ENABLE => ENABLE,
			RD1 => RD1_CU,
			RD2 => RD2_CU,
			WR  => WR_CU,
			ADD_WR => WR_ADDRESS,
			ADD_RD1	=> INSTRUC_DECODE(25 downto 21),
			ADD_RD2 => INSTRUC_DECODE(20 downto 16),		
			DATAIN	=> DATAIN,
			OUT1	=> REG_OUT1_SIG,
			OUT2	=> REG_OUT2_SIG
		);

EXT:EXTENDER16_TO_32
		port map (
			ext_uimm_o_imm, --signal from CU.use to select between imm16 and uimm16
			data_in => INSTRUC_DECODE(15 downto 0),
			data_out => DATA_EXT_SIG );
	
EXT1:EXTENDER26_TO_32
		port map(
		INSTRUC_DECODE(25 downto 0),DATA_EXT_SIG_1);

COMP_HAR_UNIT : hazardUnit 
		PORT MAP(
			RS_address => INSTRUC_DECODE(25 downto 21) ,
			RT_address => INSTRUC_DECODE(20 downto 16) ,
			RT_address_ID_EX => RT_ADDRESS_IDEX,
			MemRead_ID_EX 	 => MEM_READ, 
			enable_signal	 => ENABLE_IF_ID_REG,
			stall => STALL);


COMP_DEC_COM : DECODE_COMPARATOR 
		PORT MAP(
			DATA1   =>  REG_OUT1_SIG,
			DATA2   =>  REG_OUT2_SIG,
			DATAOUT => 	COMP_OUT );
	

COMP_ADD : DECODE_ADDER
		PORT MAP(
			PC_PIPE  			=>  PC_FROM_IFID_PIPE,		
			DATA_SHT 			=>  MUX_OUT,	
			DECODE_ADDER_OUT	=>  PC_JUMP
			);

MUX: Mux2X1 
	port map(
		DATA_EXT_SIG_1, --FROM EXT 26 TO 31
		DATA_EXT_SIG,   --FROM EXT 16 TO 31
		EXT_MUX_SEL ,
		MUX_OUT 
		);

BRANCH_TAKEN	<= COMP_OUT XNOR BRANCH_OP;			
DATA_EXT        <= DATA_EXT_SIG;	
REG_OUT1 		<= REG_OUT1_SIG;
REG_OUT2 		<= REG_OUT2_SIG;
--DATA_EXT_SHT 	<= (MUX_OUT(29 DOWNTO 0) & "00"); 
ID_RS_REG	 	<= INSTRUC_DECODE(25 DOWNTO 21) ;
ID_RT_REG		<= INSTRUC_DECODE(20 DOWNTO 16);
ID_DESTREG_RT	<= INSTRUC_DECODE(20 DOWNTO 16);
ID_DESTREG_RD	<= INSTRUC_DECODE(15 DOWNTO 11) WHEN JAL_OP = '0' ELSE "11111";
OPCODE 			<= INSTRUC_DECODE(31 DOWNTO 26);
FUNC            <= INSTRUC_DECODE(10 DOWNTO 0 );
--PC_OUT			<= PC_FROM_IFID_PIPE;

end ARCH_DECODE_UNIT;
