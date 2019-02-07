library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.myTypes.all;

entity TB_DRAM is
end TB_DRAM;

architecture TB_DRAM_ARCH of TB_DRAM is
	--constant DRCW_SIZE : integer := C_CTR_DRCW_SIZE;
	--constant ADDR_SIZE : integer := C_SYS_ADDR_SIZE;
	--constant DATA_SIZE : integer := C_SYS_DATA_SIZE;
	
	component DRAM is
	generic (
		ADDR_SIZE : integer := ADDR_SIZE;
		DATA_SIZE : integer := DATA_SIZE
	);
	port(
		RST		: in std_logic;
		CLK		: in std_logic;
		ADDR	: in std_logic_vector(ADDR_SIZE-1 downto 0):=(others=>'0');
		DIN		: in std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		DOUT	: out std_logic_vector(DATA_SIZE-1 downto 0):=(others=>'0');
		RD_EN	: in std_logic;
		WR_EN   : in std_logic 
		);
	end component;
	
	signal rst			: std_logic;
	signal addr			: std_logic_vector(ADDR_SIZE-1 downto 0):=x"00000000";
	signal din			: std_logic_vector(DATA_SIZE-1 downto 0);
	signal dout	    	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal clk: std_logic := '0';
	signal rd_en		: std_logic;
	signal wr_en		: std_logic;
	
begin
	PCLOCK : process(CLK)
	begin
		CLK <= not(CLK) after 0.5 ns;	
	end process;
	
	
	DRAM_UUT: DRAM
	port map(rst, clk, addr, din, dout,rd_en,wr_en);
	
	rst 	 <= '0', '1' after 1 ns;
	rd_en 	 <= '0', '1' after 10 ns;
	wr_en    <= '1', '0' after 10 ns;
	
	addr <= x"00000000", x"00000004" after 2 ns, x"00000008" after 3 ns, x"0000000C" after 4 ns, x"00000010" after 5 ns, x"00000014" after 7 ns, x"00000018" after 8 ns, x"0000001C" after 9 ns, x"00000020" after 10 ns,
	x"00000000" after 11 ns, x"00000004" after 12 ns, x"00000008" after 13 ns, x"0000000C" after 14 ns, x"00000010" after 15 ns, x"00000014" after 17 ns, x"00000018" after 18 ns, x"0000001C" after 19 ns, x"00000020" after 20 ns;
	din <=  x"00805060", x"08010001" after 2 ns, x"12f67002" after 3 ns, x"02028003" after 4 ns, x"08900204" after 5 ns, x"34502005" after 7 ns, x"030b2003" after 8 ns, x"01034602" after 9 ns, x"0f0a4601" after 10 ns;
	
end TB_DRAM_ARCH;


