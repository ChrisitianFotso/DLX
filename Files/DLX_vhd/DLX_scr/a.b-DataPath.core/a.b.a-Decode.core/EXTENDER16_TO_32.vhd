library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EXTENDER16_TO_32 is
	port(
		ext_uimm_o_imm: in std_logic:='0'; --signal from CU.use to select between imm16 and uimm16 
		data_in  : in  std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end EXTENDER16_TO_32;

architecture Behaviour of EXTENDER16_TO_32 is

begin
	
	data_out(31 downto 16) <= (others => (ext_uimm_o_imm and data_in(15)));
	data_out(15 downto 0)  <= data_in;

end Behaviour;