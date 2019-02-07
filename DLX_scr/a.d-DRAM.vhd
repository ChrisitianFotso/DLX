--------------------------------------------------------------------------------
--note: synchronous ram memory.
--positive clock edge triggered
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.myTypes.all;


entity DRAM is
	generic (
		ADDR_SIZE : integer := ADDR_SIZE;
		DATA_SIZE : integer := DATA_SIZE
	);
	port (
		RST		: in std_logic;
		CLK		: in std_logic;
		ADDR	: in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
		DIN		: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		DOUT	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		RD_EN	: in std_logic;
		WR_EN   : in std_logic 
);
end DRAM;


architecture DRAM_BHV of  DRAM is 

	type Dram_type is array (0 to DRAM_SIZE-1) of std_logic_vector (MEM_WORD-1 downto 0);
	signal ram_mem : Dram_type:=(others=>"00000000");
begin
	
	ram_process:process(CLK)
		begin	
			IF CLK'EVENT AND CLK='1' THEN
				IF RST ='1' THEN 
					LO0:FOR I IN 0 TO DRAM_SIZE-1 LOOP
							ram_mem(I) <= (others=>'0');
						END LOOP;
				ELSE
					IF WR_EN='1' THEN
						ram_mem(to_integer(unsigned(ADDR))) <= DIN(31 downto 24);
						ram_mem(to_integer(unsigned(ADDR))+1) <= DIN(23 downto 16);
						ram_mem(to_integer(unsigned(ADDR))+2) <= DIN(15 downto 8);
						ram_mem(to_integer(unsigned(ADDR))+3)   <= DIN(7 downto 0);
					END IF;                                       
					                                              
					IF RD_EN ='1' THEN                            
						DOUT(31 downto 24) <= ram_mem(to_integer(unsigned(ADDR)));
						DOUT(23 downto 16) <= ram_mem(to_integer(unsigned(ADDR))+1);
						DOUT(15 downto  8) <= ram_mem(to_integer(unsigned(ADDR))+2);
						DOUT(7  downto  0) <= ram_mem(to_integer(unsigned(ADDR))+3);
					
					END IF;	
				END IF;
			END IF;
	end process;
end DRAM_BHV;
