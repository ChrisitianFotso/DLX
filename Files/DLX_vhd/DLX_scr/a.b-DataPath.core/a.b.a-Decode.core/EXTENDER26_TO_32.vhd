library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EXTENDER26_TO_32 is
	port(
		data_in  : in  std_logic_vector(25 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end EXTENDER26_TO_32;

architecture Behaviour of EXTENDER26_TO_32 is

begin
	
	data_out(31 downto 26) <= (others => data_in(25));
	data_out(25 downto 0)  <= data_in;

end Behaviour;