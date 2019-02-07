library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity G_BLOCK is
	generic(
		row_0: boolean :=false );
	port(
		G_C,P_C,G_P: in std_logic;  ----- E.G :P_C MEANS CURRENT PROPAGATE ,P_P --> PREVIOUS PROPAGATE;G_C--->CURRENT GENERATE ;G_P -->PREVIOUS GENERATE
		G: out std_logic 
		);
end G_BLOCK;

architecture BEHAVIORAL of G_BLOCK is
begin
	
	GEN0: if row_0=true generate		
	
			G <= (P_C AND G_C) OR ((P_C xor G_C) and G_P)  ;
		end generate;
	
	
	GEN1: if row_0=false generate
		    G <= G_C or (P_C and G_P);
	end generate;
end BEHAVIORAL;


configuration CFG_G_BLOCK_BEHAVIORAL of G_BLOCK is
	for BEHAVIORAL
	end for;
end CFG_G_BLOCK_BEHAVIORAL ;