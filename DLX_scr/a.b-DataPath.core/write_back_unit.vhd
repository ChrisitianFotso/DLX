library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity write_back_unit is
	port(
		MUX_WB_SEL : in std_logic; --from control unit
		data_from_memory : in std_logic_vector(31 downto 0);
		data_from_alu : in std_logic_vector(31 downto 0);
		write_back_value : out std_logic_vector(31 downto 0)); -- to be forwarded to the decode_unit and the execute_unit
end write_back_unit;

ARCHITECTURE BEHAVIOUR OF write_back_unit IS 

begin
	process(data_from_memory,data_from_alu,MUX_WB_SEL)
	begin
		if(MUX_WB_SEL = '1')then
			write_back_value <= data_from_memory;
		else write_back_value <= data_from_alu;
		end if;
	end process;
end BEHAVIOUR;