library ieee;
use ieee.std_logic_1164.all;
--use work.myTypes.all;
use ieee.numeric_std.all;

entity  TB_FETCH_ADDER is 
end TB_FETCH_ADDER; 

architecture TEST_FETCH_ADDER of TB_FETCH_ADDER is

component FETCH_ADDER is
	port(from_pc_to_adder : in STD_LOGIC_VECTOR(31 downto 0);
		 fetch_adder_out  : out STD_LOGIC_VECTOR(31 downto 0)
		);
END component;

signal A   : STD_LOGIC_VECTOR(31 downto 0);
signal SUM : STD_LOGIC_VECTOR(31 downto 0);


begin

ADD_FETCH : FETCH_ADDER  
port map (A,SUM);
	   
A <= x"55555555", x"FFFFFFFF" after 10 ns ,x"FFC003FF" after 20 ns ,x"2234e826" after 30 ns ,x"8b651a8b" after 40 ns, x"2234e826" after 50 ns ;	   
 
 
END TEST_FETCH_ADDER;