library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.myTypes.all;
entity InstructionRegister is
	port(
		clock,reset,enable,flush : in std_logic;
		data_in  : in std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end InstructionRegister;

architecture Behavioral of InstructionRegister is

begin
	process (clock)
	
	begin
	
		if(clock = '1' and clock'event)then
				if (reset = '1' or flush = '1') then
					data_out <= OPCD_NOP & "00000000000000000000000000";
				elsif (enable='1') then 
					data_out <= data_in;
				end if;
		end if;
		
	end process;
	
end Behavioral;

