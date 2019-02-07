library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_EXTENDER16_TO_32 is 
end entity;

architecture TEST_EXTENDER16_TO_32 of TB_EXTENDER16_TO_32 is 

COMPONENT EXTENDER16_TO_32 is
	port(
		data_in  : in  std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end COMPONENT;


SIGNAL DATAIN  : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL DATAOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN 

EXT:EXTENDER16_TO_32
port map (DATAIN,DATAOUT );

-- RST <= '1','0' after 5 ns;
-- EN  <= '0','1' after 3 ns, '0' after 10 ns, '1' after 15 ns;
-- FSH <= '0','1' after 6 ns, '0' after 7 ns, '1' after 10 ns, '0' after 20 ns;
DATAIN<=x"83EF", x"F3FF" after 8 ns ,(others => '1') after 12 ns;
	

END TEST_EXTENDER16_TO_32;