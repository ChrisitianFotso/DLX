library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc_id_if_reg  is
	port(
		clock,reset,enable,flush : in std_logic;
		data_in  : in std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end pc_id_if_reg;

architecture Behavioral of pc_id_if_reg is
	--signal R : std_logic_vector(31 downto 0);

begin
	process (clock)
	
	begin
	--if (flush = '1') then
		--data_out <= (others => '0');		
		if(clock = '1' and clock'event)then
				if (reset = '1' or flush = '1') then
					data_out <= (others => '0');
				elsif (enable = '1') then
				data_out <= data_in;
				end if;
		end if;
	--end if;	
	end process;
	
end Behavioral;