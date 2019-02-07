library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC is
	port(
		clock,reset,enable : in std_logic;
		data_in : in std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end PC;

architecture Behavioral of PC is
	--signal  : std_logic_vector(31 downto 0);

begin
	process (clock)
	begin
		if(clock = '1' and clock'event)then
			if(reset = '1')then
				data_out <= (others => '0');
			elsif(enable = '1')then
				data_out <= data_in;
			end if;
		end if;
	end process;

	-- data_out <= R;
	
end Behavioral;

