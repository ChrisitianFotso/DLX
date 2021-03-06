library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity hazardUnit is
	port(
		RS_address : in std_logic_vector(4 downto 0);
		RT_address : in std_logic_vector(4 downto 0);
		RT_address_ID_EX : in std_logic_vector(4 downto 0);
		MemRead_ID_EX : in std_logic;	
		enable_signal : out std_logic;
		stall		  : out std_logic
	);
		
end hazardUnit;

architecture Behavioral of hazardUnit is
	
begin
	process(RS_address,RT_address,RT_address_ID_EX,MemRead_ID_EX)
	begin
		--HAZARD
		if((MemRead_ID_EX = '1' and ((RT_address_ID_EX = RS_address)or (RT_address_ID_EX = RT_address))))then	
			enable_signal <= '0';
			stall <='1';
		else
			enable_signal <= '1';
			stall <='0';
		end if;
	end process;

end Behavioral;
