library ieee;
use ieee.std_logic_1164.all;

entity mux4X1 is
	Port (
		a:	in	std_logic_vector(31 downto 0);
		b:	in	std_logic_vector(31 downto 0);
		c:  in	std_logic_vector(31 downto 0);
		s:	in	std_logic_vector(1 downto 0);
		y:	out	std_logic_vector(31 downto 0)
		);
end mux4X1;


architecture behaviour of mux4X1 is
begin
	process (a, b, c, s)
	begin
		case s is
		 when "00" =>
			y <= a;
		 when "01" =>
			y <= b;
		 when "10" =>
			y <= c;
		 when others =>  
			y <= (others => '0');
	  end case;
	 end process;
end behaviour;
