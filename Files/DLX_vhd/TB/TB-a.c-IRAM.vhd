library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity TB_IRAM is
end TB_IRAM;

architecture TB_IRAM_BEH of TB_IRAM is
	--constant ADDR_SIZE : integer := ADDR_SIZE;
	--constant ISTR_SIZE : integer := ISTR_SIZE;
	
	component IRAM
		generic (
			IRAM_DEPTH : integer := IRAM_SIZE;
			I_SIZE 	   : integer := ISTR_SIZE
		);
		port (
			Rst  : in std_logic;
			Addr : in std_logic_vector(ADDR_SIZE-1 downto 0);
			Dout : out std_logic_vector(ISTR_SIZE-1 downto 0)
		);
	end component;
	
	signal rst			: std_logic;
	signal addr			: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal dout			: std_logic_vector(ISTR_SIZE-1 downto 0);
	
begin
	IRAM_COMP: IRAM
	--generic map(ADDR_SIZE,ISTR_SIZE)
	port map(rst, addr, dout);

	rst <= '0', '1' after 1 ns;
	addr <= x"00000000", x"00000004" after 2 ns, x"00000008" after 3 ns, x"0000000C" after 4 ns, x"00000010" after 5 ns; -- the numbers in the quotes are in hexadecimal
end TB_IRAM_BEH ;

--configuration tb_instruction_ram_cfg of tbInstructionRam is
	-- for tb_instruction_ram_arch
	-- end for;
-- end tb_instruction_ram_cfg;
