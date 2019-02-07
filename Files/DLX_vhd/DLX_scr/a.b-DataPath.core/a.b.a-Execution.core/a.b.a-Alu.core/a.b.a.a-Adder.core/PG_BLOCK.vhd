library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity PG_BLOCK is
	generic(
		row_0: boolean :=false );
	port(
		P_C,P_P,G_C,G_P: in std_logic;  ----- E.G :P_C MEANS CURRENT PROPAGATE ,P_P --> PREVIOUS PROPAGATE;G_C--->CURRENT GENERATE ;G_P -->PREVIOUS GENERATE
		P, G: out std_logic 
		);
end PG_BLOCK;

architecture BEHAVIORAL of PG_BLOCK is
begin
	
	GEN0: if row_0=true generate
		
			P <= P_C xor P_P;
			G <= P_C and P_P;
		end generate;
	
	
	GEN1: if row_0=false generate
			P <= P_C and P_P;
		    G <= G_C or (P_C and G_P);
	end generate;
end BEHAVIORAL;


configuration CFG_PG_BLOCK_BEHAVIORAL of PG_BLOCK is
	for BEHAVIORAL
	end for;
end CFG_PG_BLOCK_BEHAVIORAL ;