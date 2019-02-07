library ieee;
use ieee.std_logic_1164.all;
--use work.myTypes.all;
use ieee.numeric_std.all;

ENTITY FETCH_ADDER is
	port(from_pc_to_adder : in STD_LOGIC_VECTOR(31 downto 0);
		 fetch_adder_out  : out STD_LOGIC_VECTOR(31 downto 0)
		 );
END FETCH_ADDER;


ARCHITECTURE STRUCTURAL OF FETCH_ADDER IS 

signal temp_output : std_logic_vector(32 downto 0);

begin

temp_output <= std_logic_vector(unsigned(('0' & from_pc_to_adder)) + X"00000004");
fetch_adder_out <= temp_output (31 downto 0); 
 
END STRUCTURAL;