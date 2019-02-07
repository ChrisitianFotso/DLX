library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX2X1_4 is
	port(
		a : in std_logic_vector(4 downto 0);--select rt as source register
		b : in std_logic_vector(4 downto 0);--select rd as source register
		sel : in std_logic;
		o : out std_logic_vector(4 downto 0)
		);
end MUX2X1_4;

architecture Behavioral of MUX2X1_4 is

begin
	process(a,b,sel)
	begin
		if(sel = '1')then
			o <= a;
		else o <= b;
		end if;
	end process;
end Behavioral;
