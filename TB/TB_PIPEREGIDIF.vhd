library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_PIPEREGIDIF is 
end entity;

architecture TEST_TB_PIPEREGIDIF of TB_PIPEREGIDIF is 

component pc_id_if_reg  is
	port(
		clock,reset,enable,flush : in std_logic;
		data_in  : in std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end component;

SIGNAL CLK : std_logic := '0';
SIGNAL RST,EN,FSH : STD_LOGIC;
SIGNAL DATAIN,DATAOUT : STD_LOGIC_VECTOR (31 DOWNTO 0);

begin 

RG:pc_id_if_reg
port map (CLK,RST,EN,FSH,DATAIN,DATAOUT );

RST <= '1','0' after 5 ns;
EN  <= '0','1' after 3 ns, '0' after 10 ns, '1' after 15 ns;
FSH <= '0','1' after 6 ns, '0' after 7 ns, '1' after 10 ns, '0' after 20 ns;
DATAIN<=x"FFA003EF", x"FFC003FF" after 8 ns ,(others => '1') after 12 ns;
	
PCLOCK : process(CLK)
begin
	CLK <= not(CLK) after 0.5 ns;	
end process;

end TEST_TB_PIPEREGIDIF;