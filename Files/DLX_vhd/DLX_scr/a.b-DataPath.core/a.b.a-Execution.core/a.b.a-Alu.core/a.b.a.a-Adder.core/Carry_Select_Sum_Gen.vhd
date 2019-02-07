library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;



entity Carry_Select_Sum_Gen is --carry select sum generator
	generic(N:integer:=P4_bit_num;
			delta:integer:=delta_Co
			);
	port(A,B: std_logic_vector(N-1 downto 0);
     	 Cin: in std_logic_vector(N/delta -1 downto 0);
		   SUM: out std_logic_vector(N-1 downto 0)
	);
end Carry_Select_Sum_Gen;

architecture STRUCTURAL of Carry_Select_Sum_Gen is 

component CARRY_SELECT is 
	generic (N: integer:= CS_numbit);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(N-1 downto 0));
end component;

begin 
gen: for i in 0 to N/delta -1 generate
	 CSSG:CARRY_SELECT 
	 generic map(delta)
     port map(A((i+1)*delta-1 downto i*delta),B((i+1)*delta-1 downto i*delta),Cin(i),SUM((i+1)*delta-1 downto i*delta));	 
     end generate;
end STRUCTURAL;

configuration CFG_Carry_Select_Sum_Gen_STRUCTURAL of Carry_Select_Sum_Gen is
  for STRUCTURAL 
    for ALL :CARRY_SELECT
      use configuration WORK.CFG_CARRY_SELECT_STRUCTURAL;
    end for;
  end for;
end CFG_Carry_Select_Sum_Gen_STRUCTURAL;

