library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.myTypes.all;

entity CARRY_SELECT is 
	generic (N: integer:= CS_numbit);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(N-1 downto 0));
end CARRY_SELECT; 

architecture STRUCTURAL of CARRY_SELECT is

  signal SUM_A : std_logic_vector(N-1 downto 0);
  signal SUM_B : std_logic_vector(N-1 downto 0);
 

  component RCA 
	generic (	
				N: integer:= rca_bit		         
               );
	Port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(N-1 downto 0);
			Co:	Out	std_logic);
  end component; 

  component  MUX21_GENERIC is
	Generic (	N: integer:= numBit);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			SEL:	In	std_logic;
			Y:	Out	std_logic_vector(N-1 downto 0));
  end component;
  
begin

  
  RCAone : RCA 
      generic map(N)
	  Port Map (A, B,'0',SUM_B,open);
  RCAtwo : RCA 
	  generic map(N)
	  Port Map (A, B,'1',SUM_A,open);
	MUX : MUX21_GENERIC
	  generic map(N)
	  Port Map (SUM_A, SUM_B, Ci, S);
 


end STRUCTURAL;



configuration CFG_CARRY_SELECT_STRUCTURAL of CARRY_SELECT is
  for STRUCTURAL 
         for all : RCA
        use configuration WORK.CFG_RCA_STRUCTURAL;
      end for;
	  for all : MUX21_GENERIC
		use configuration WORK.CFG_MUX21_GENERIC_STRUCTURAL;
	  end for;
  end for;
end CFG_CARRY_SELECT_STRUCTURAL;
