library ieee;
use ieee.std_logic_1164.all;
--use work.myTypes.all;
use ieee.numeric_std.all;

ENTITY DECODE_ADDER is
	port(PC_PIPE  			: in STD_LOGIC_VECTOR (31 downto 0);
		 DATA_SHT 			: in STD_LOGIC_VECTOR (31 downto 0);
		 DECODE_ADDER_OUT  	: out STD_LOGIC_VECTOR(31 downto 0)
		 );
END DECODE_ADDER;


ARCHITECTURE STRUCTURAL OF DECODE_ADDER IS 

signal temp_output : std_logic_vector(32 downto 0);

begin

temp_output <= std_logic_vector(signed(( '0' & PC_PIPE)) + signed(DATA_SHT));  
DECODE_ADDER_OUT <=temp_output(31 downto 0); 

END STRUCTURAL;
