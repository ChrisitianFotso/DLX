library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use ieee.numeric_std.all;
use work.FUNC.all;

entity CARRY_GENERATOR is 
    generic(	delta:integer:=delta_Co;
			N:integer:=P4_bit_num);
	port (	A,B:in std_logic_vector(N-1 downto 0);
			Cin:in std_logic;	      
			COUT:out std_logic_vector(N/delta -1 downto 0)
		 );
end CARRY_GENERATOR;


architecture STRUCTURAL of CARRY_GENERATOR is 

COMPONENT PG_BLOCK is
	generic(row_0: boolean :=false );
	port(
		P_C,P_P,G_C,G_P: in std_logic;  ----- E.G :P_C MEANS CURRENT PROPAGATE ,P_P --> PREVIOUS PROPAGATE;G_C--->CURRENT GENERATE ;G_P -->PREVIOUS GENERATE
		P, G: out std_logic 
		);
end COMPONENT;

COMPONENT G_BLOCK is
	generic(row_0: boolean :=false );
	port(
		G_C,P_C,G_P: in std_logic;  ----- E.G :P_C MEANS CURRENT PROPAGATE ,P_P --> PREVIOUS PROPAGATE;G_C--->CURRENT GENERATE ;G_P -->PREVIOUS GENERATE
		G: out std_logic 
		);
end COMPONENT;


constant depth : integer := CEIL_LOG2(N);
type pg_array is array (depth downto 0) of std_logic_vector(N-1 downto 1); 
signal SIGNAL_P_PG,SIGNAL_G_PG :pg_array; 
signal SIGNALG :std_logic_vector(5 downto 0);


begin 
GEN_CO :for row in 0 to depth generate 
----------------------------------------------------------------------------------------------------------------------- row 0		
		GEN0: 	if row=0 generate
				    GEN01 : for colum in 1 to N-1 generate 
							line_PG:PG_BLOCK
							generic map(true)
							port map(A(colum),B(colum),'0','0',SIGNAL_P_PG(row)(colum),SIGNAL_G_PG(row)(colum));
					end generate ;
		            PG_BLOCK_0:G_BLOCK
							generic map(true)
							port map(A(0),B(0),Cin,SIGNALG(row));
		
		end generate GEN0;
----------------------------------------------------------------------------------------------------------------------- row	1 to 2
		GEN1:	if row>0 and row<3 generate
					GEN10 : for colum in 1 to N/(2**row)-1  generate
							line_PG:PG_BLOCK
							generic map(false)
							port map(SIGNAL_P_PG(row-1)(colum*2+1),SIGNAL_P_PG(row-1)(colum*2),SIGNAL_G_PG(row-1)(colum*2+1),SIGNAL_G_PG(row-1)(colum*2),SIGNAL_P_PG(row)(colum),SIGNAL_G_PG(row)(colum));	
                            end generate;
					line_G:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-1)(1),SIGNAL_P_PG(row-1)(1),SIGNALG(row-1),SIGNALG(row));
		end generate GEN1; 

-----------------------------------------------------------------------------------------------------------------------------row3	
		GEN2:	if row=3 generate
					
							line_PG_3_1:PG_BLOCK
							generic map(false)
							port map(SIGNAL_P_PG(row-1)(3),SIGNAL_P_PG(row-1)(2),SIGNAL_G_PG(row-1)(3),SIGNAL_G_PG(row-1)(2),SIGNAL_P_PG(row)(1),SIGNAL_G_PG(row)(1));	
							
							line_PG_3_2:PG_BLOCK
							generic map(false)
							port map(SIGNAL_P_PG(row-1)(5),SIGNAL_P_PG(row-1)(4),SIGNAL_G_PG(row-1)(5),SIGNAL_G_PG(row-1)(4),SIGNAL_P_PG(row)(2),SIGNAL_G_PG(row)(2));
					        
							line_PG_3_3:PG_BLOCK
							generic map(false)
							port map(SIGNAL_P_PG(row-1)(7),SIGNAL_P_PG(row-1)(6),SIGNAL_G_PG(row-1)(7),SIGNAL_G_PG(row-1)(6),SIGNAL_P_PG(row)(3),SIGNAL_G_PG(row)(3));
							
							line_G:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-1)(1),SIGNAL_P_PG(row-1)(1),SIGNALG(row-1),SIGNALG(row));
		
							COUT(1)<=SIGNALG(3);
							COUT(0)<=SIGNALG(2);
		
		end generate GEN2; 		
		
		
--------------------------------------------------------------------------------------------------------------------------row 4 
		GEN3:	if  row =4  generate
	 
							line_PG_4_1:PG_BLOCK
							generic map(false)
							port map(SIGNAL_P_PG(row-2)(6),SIGNAL_P_PG(row-1)(2),SIGNAL_G_PG(row-2)(6),SIGNAL_G_PG(row-1)(2),SIGNAL_P_PG(row)(1),SIGNAL_G_PG(row)(1));

							line_PG_4_2:PG_BLOCK
							generic map(false)
							port map(SIGNAL_P_PG(row-1)(3),SIGNAL_P_PG(row-1)(2),SIGNAL_G_PG(row-2)(3),SIGNAL_G_PG(row-1)(2),SIGNAL_P_PG(row)(2),SIGNAL_G_PG(row)(2));							
                            
							line_G_4_1:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-2)(2),SIGNAL_P_PG(row-2)(2),SIGNALG(row-1),SIGNALG(row));----cout(2)
							
							line_G_4_2:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-1)(1),SIGNAL_P_PG(row-1)(1),SIGNALG(row-1),SIGNALG(row+1)); ---cout(3);row+1=5
							
							COUT(2)<=SIGNALG(4);
								
								GEN30:IF N>12 GENERATE 
										COUT(3)<=SIGNALG(5);
								END GENERATE GEN30;
		end generate GEN3;
---------------------------------------------------------------------------------------------------------------------------row 5
        GEN4:	if  row =5 generate
	 
														
                            
							line_G_5_1:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-1)(2),SIGNAL_P_PG(row-1)(2),SIGNALG(row),COUT(7));
							
							line_G_5_2:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-1)(1),SIGNAL_P_PG(row-1)(1),SIGNALG(row),COUT(6));
							
							line_G_5_3:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-2)(3),SIGNAL_P_PG(row-1)(1),SIGNALG(row),COUT(5));
							 
							line_G_5_4:G_BLOCK 
							generic map(false)
							port map(SIGNAL_G_PG(row-3)(5),SIGNAL_P_PG(row-3)(5),SIGNALG(row),COUT(4));
							
		end generate GEN4;
 END GENERATE;
 
 


 
 end STRUCTURAL;


configuration CFG_CARRY_GENERATOR_STRUCTURAL of CARRY_GENERATOR is
	for STRUCTURAL
		for all : PG_BLOCK
				use configuration WORK.CFG_PG_BLOCK_BEHAVIORAL;
		end for;
		
		for all : G_BLOCK
				use configuration  WORK.CFG_G_BLOCK_BEHAVIORAL;
		end for;
	end for;
end CFG_CARRY_GENERATOR_STRUCTURAL;
	 
		
