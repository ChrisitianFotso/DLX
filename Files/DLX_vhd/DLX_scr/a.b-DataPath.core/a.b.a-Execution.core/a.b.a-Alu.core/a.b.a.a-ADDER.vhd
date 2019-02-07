library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use ieee.numeric_std.all;


ENTITY P4ADDER is
		GENERIC(N: INTEGER := P4_BIT_NUM;
			    DELTA :INTEGER:=delta_Co);
		port	(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
				CIN: in STD_LOGIC;
				S : out STD_LOGIC_VECTOR(N-1 downto 0);
				COUT: out STD_LOGIC);
END P4ADDER;


ARCHITECTURE STRUCTURAL OF P4ADDER IS 

COMPONENT CARRY_GENERATOR is 
    generic(	delta:integer:=delta_Co;
			N:integer:=P4_bit_num);
	port 	(	A,B:in std_logic_vector(N-1 downto 0);
			Cin:in std_logic;	      
			COUT:out std_logic_vector(N/delta -1 downto 0));
end COMPONENT;

COMPONENT Carry_Select_Sum_Gen is --carry select sum generator
	generic(N:integer:=P4_bit_num;
			delta:integer:=delta_Co
			);
	port	(A,B: std_logic_vector(N-1 downto 0);
			Cin: in std_logic_vector(N/delta -1 downto 0);
			SUM: out std_logic_vector(N-1 downto 0));
end COMPONENT;

SIGNAL  CARRY_SIGNAL: std_logic_vector(N/delta downto 0);

BEGIN 
CARRY_SIGNAL(0) <= cin;
	COMP1: CARRY_GENERATOR
	    generic map (DELTA, N)
		port map	(A, B, CIN, CARRY_SIGNAL(N/delta downto 1));
	
	COMP2: Carry_Select_Sum_Gen
		generic map (N, DELTA)
		port map	(A, B, CARRY_SIGNAL(N/delta-1 downto 0), s);
	
	COUT <= CARRY_SIGNAL(N/delta-1 );

END STRUCTURAL;

configuration CFG_P4ADDER_STRUCTURAL of P4ADDER is
	for STRUCTURAL
		for all : CARRY_GENERATOR
				use configuration WORK.CFG_CARRY_GENERATOR_STRUCTURAL;
		end for;
		
		for all : Carry_Select_Sum_Gen
				use configuration  WORK.CFG_Carry_Select_Sum_Gen_STRUCTURAL;
		end for;
	END for;
END CFG_P4ADDER_STRUCTURAL;