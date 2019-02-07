library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- Encode of FUNCTION (f) signal:
--00000 -- [ADD] Addition, or NOP
--00001 -- [SUB]
--00010 -- [AND]
--00011 -- [OR]
--00100 -- [XOR] 
--00101 -- [SLL] SHIFT LEFT LOGICAL
--00110 -- [SRL] SHIFT RIGHT LOGICAL
--00111 -- [SLE] SET If LESS AND EQUAL, For SIGNED
--01000 -- NOT USED
--01001 -- [SLT] SET If LESS, For SIGNED
--01010 -- NOT USED
--01011 -- [SGT] SET If GREAT, For SIGNED 
--01100 -- NOT USED
--01101 -- [SGE] SET If GREAT AND EQUAL, For SIGNED
--01110 -- NOT USED
--01111 -- [SEQ] SET If EQUAL
--10000 -- NOT USED
--10001 -- [SNE] SET If NOT EQUAL
--10010 -- NOT USED
--10011	-- [SGEU]
--10100 -- NOT USED
--10101 -- [SGTU]
--10110 -- NOT USED
--10111 -- [SLEU]
--11000 -- NOT USED
--11001 -- [SLTU]
--11010 -- NOT USED
--------------------------------------------------------------------------------

ENTITY ALU is
		GENERIC(DATA_SIZE: INTEGER :=DATA_SIZE);
		port(ALU_OP: STD_LOGIC_VECTOR(ALU_OP_SIZE-1 downto 0):=(others=>'0');
		    A, B: in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
			--ALU_OP: (ALU_OP_SIZE-1 downto 0):=(others=>'0');
			OUTALU: OUT std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0')
			);
END ALU;

ARCHITECTURE ARCH_ALU OF ALU IS 

COMPONENT P4ADDER is
		GENERIC(N: INTEGER := P4_BIT_NUM;
			    DELTA :INTEGER:=delta_Co);
		port	(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
				CIN: in STD_LOGIC;
				S : out STD_LOGIC_VECTOR(N-1 downto 0);
				COUT: out STD_LOGIC);
END COMPONENT;

SIGNAL CIN_EXT : std_logic_vector(DATA_SIZE-1 downto 0);
signal ZERO_ARR : std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
SIGNAL B_NEW : std_logic_vector(DATA_SIZE-1 downto 0);-- the one-s complement of B
SIGNAL CIN_ARR : std_logic_vector(DATA_SIZE-1 downto 0);
SIGNAL C_F,Z_F,S_F,O_F: std_logic := '0';
SIGNAL ADD_OUT : std_logic_vector(DATA_SIZE-1 downto 0);

BEGIN 

CIN_ARR <= (others=>ALU_OP(0));
B_NEW <= B xor CIN_ARR; -- the last bit of the ALU_OP is used as carry in. In case of addiction the carry is set to zero
						--in case of subtraction the carry is set to one.This is done in order to obtain the two's complement of B.
ADD_UNIT: P4ADDER
generic map (DATA_SIZE)
port map (A,B_NEW,ALU_OP(0),ADD_OUT, C_F);

S_F <= ADD_OUT(DATA_SIZE-1);
O_F <= (NOT (A(DATA_SIZE-1) XOR B_NEW(DATA_SIZE-1))) AND (A(DATA_SIZE-1) XOR S_F);

Zero_proc: process(ADD_OUT)
	begin
		if ADD_OUT = ZERO_ARR then
			Z_F <= '1';
		else
			Z_F <= '0';
		end if;
	end process Zero_proc;

ALU_OP_PROC:process(ALU_OP,A,B,ADD_OUT,O_F, S_F,Z_F)
	begin
	
		case ALU_OP is 
			when OP_ADD => OUTALU <= ADD_OUT;
			when OP_SUB => OUTALU <= ADD_OUT;
			when OP_AND => OUTALU <= A AND B;
			when OP_OR	=> OUTALU <= A  OR B;
			when OP_XOR => OUTALU <= A XOR B;
			when OP_SLL => OUTALU <= (std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(NUM_BIT2SHIFT-1 DOWNTO 0))))));
			when OP_SRL => OUTALU <= (std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(NUM_BIT2SHIFT-1 DOWNTO 0)))))) ;
			when OP_SLT => OUTALU <= (0 => (O_F XOR S_F),OTHERS => '0');
			when OP_SLE => OUTALU <= (0 => ((O_F XOR S_F) OR Z_F),OTHERS => '0');
			when OP_SGT => OUTALU <= (0 => (NOT Z_F) AND (NOT (S_F XOR O_F)),OTHERS => '0');
			when OP_SGE => OUTALU <= (0 =>  NOT (S_F XOR O_F),OTHERS => '0');
			when OP_SEQ => OUTALU <= (0 =>  Z_F, OTHERS => '0');
			when OP_SNE => OUTALU <= (0 => (NOT Z_F), OTHERS => '0');	
			when OP_SGEU => OUTALU <= (0 => C_F,OTHERS => '0');
			WHEN OP_SGTU => OUTALU <= (0 => (C_F AND NOT(Z_F)),OTHERS => '0');
			WHEN OP_SLEU => OUTALU <= (0 => (NOT (C_F) OR Z_F),OTHERS => '0');
			WHEN OTHERS  => OUTALU <= (0 => NOT(C_F),OTHERS => '0');
		end case;
	END process ALU_OP_PROC;	
END ARCH_ALU;