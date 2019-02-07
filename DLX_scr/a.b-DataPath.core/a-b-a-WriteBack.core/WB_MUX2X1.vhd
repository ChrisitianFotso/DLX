library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WB_MUX2X1 is
	port(
		a : in std_logic_vector(31 downto 0);---SELECT DATA FROM LOWER FORWARD MUX
		b : in std_logic_vector(31 downto 0); --SELECT IMMEDIATE VALUE
		sel : in std_logic;
		o : out std_logic_vector(31 downto 0)
		);
end WB_MUX2X1;

architecture Behavioral of WB_MUX2X1 is

begin
	process(a,b,sel)
	begin
		if(sel = '1')then
			o <= a;
		else o <= b;
		end if;
	end process;
end Behavioral;