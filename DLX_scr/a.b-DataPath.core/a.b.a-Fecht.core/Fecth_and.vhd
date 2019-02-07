library ieee;
use ieee.std_logic_1164.all;
--use work.globals.all;

entity FETCH_AND is 
	port(
		jump: in std_logic;
		from_decode_comparator: in std_logic;
		Fetch_mux_sel: out std_logic
	);
end FETCH_AND;

architecture behaviour of FETCH_AND is 

begin 
Fetch_mux_sel <= (jump and from_decode_comparator);
end behaviour;