library IEEE;
use ieee.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.Constants.all;

entity TB_DECODE_COMPARATOR is
end TB_DECODE_COMPARATOR;

architecture TEST_TB_DECODE_COMPARATOR of TB_DECODE_COMPARATOR is 


COMPONENT DECODE_COMPARATOR IS 
	PORT(
		DATA1  : in STD_LOGIC_VECTOR(31 downto 0);
		DATA2  : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		DATAOUT: OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL D1 : STD_LOGIC_VECTOR(31 downto 0) ;
SIGNAL D2 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL DOUT : STD_LOGIC;

begin 

COMP:DECODE_COMPARATOR
port map (D1,D2,DOUT );


D2<=x"FFA003EF", x"FFC003FE" after 8 ns ,(others => '1') after 12 ns;
D1<=x"FFA003EF", x"FFC003FF" after 8 ns ,(others => '1') after 12 ns;
	


end TEST_TB_DECODE_COMPARATOR ;