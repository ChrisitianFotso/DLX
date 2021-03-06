library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;
--use WORK.all;

entity register_file is
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
end register_file;

architecture BEHAVIORAL of register_file is

        -- suggested structures
    subtype REG_ADDR is natural range 0 to 2**N-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(M-1 downto 0); 
	signal REGISTERS : REG_ARRAY; 

	
begin 

	REG_FILE:PROCESS(CLK)
		begin
			IF CLK'EVENT AND CLK='1' THEN
				IF RESET ='1' THEN 
					LO0: FOR I IN 0 TO 2**N-1 LOOP
					REGISTERS(I) <= (OTHERS=>'0');
				    OUT2<=(others=>'0');
					OUT1<=(others=>'0');
				END LOOP;
				ELSE
					IF WR='1' THEN
						REGISTERS(TO_INTEGER(UNSIGNED(ADD_WR)))<=DATAIN;
					END IF;

					IF ENABLE ='1' THEN 
						
						
						IF RD2 ='1' THEN 
							IF WR='1' AND ADD_WR=ADD_RD2 THEN
								OUT2 <= DATAIN;
							ELSE 
								OUT2 <= REGISTERS(TO_INTEGER(UNSIGNED(ADD_RD2)));
							END IF;
						END IF;	
						
						IF RD1 ='1' THEN 
							IF WR='1' AND ADD_WR=ADD_RD1 THEN
								OUT1 <= DATAIN;
							ELSE
								OUT1<=REGISTERS(TO_INTEGER(UNSIGNED(ADD_RD1)));
							END IF;
						END IF;					
						ELSE
						OUT2<=(others=>'0');
						OUT1<=(others=>'0');
					END IF;
				END IF;
			END IF;
	END PROCESS REG_FILE ;
end BEHAVIORAL;

----


configuration CFG_RF_BEH of register_file is
  for BEHAVIORAL
  end for;
end configuration;
