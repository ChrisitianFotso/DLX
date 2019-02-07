-------------------------------------------------------
--Since the ram is byte addressable and an instruction is on 32 byte,
--at each reading operation of the IRAM we should read the content of contiguous byte 
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.myTypes.all;


-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity IRAM is
  generic (
    IRAM_DEPTH : integer := IRAM_SIZE;
    I_SIZE 	   : integer := ISTR_SIZE);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(ADDR_SIZE - 1 downto 0):=(others=>'0');
    Dout : out std_logic_vector(ISTR_SIZE - 1 downto 0):=(others=>'0')
    );

end IRAM;

architecture IRam_Bhe of IRAM is

  type IRAMtype is array (0 to IRAM_DEPTH - 1) of std_logic_vector(MEM_WORD-1 downto 0);
  signal IRAM_mem : IRAMtype:=(others=>"00000000");

begin  -- IRam_Bhe

	Rd_Mem_Process:process(rst,addr) 
	--Purpose:process aiming to access the Instruction memory after the reset
		variable index : integer := 0;
	begin
		if rst = '1' then
			Dout <= (others=>'0');
		else
			index := to_integer(unsigned(addr));
			Dout <= IRAM_mem(index)&IRAM_mem(index+1)&IRAM_mem(index+2)&IRAM_mem(index+3);
    	end if;
	end process Rd_Mem_Process;
  
  --Dout <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr))),I_SIZE);
  
  


  FILL_MEM_P: process (Rst)
  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable var_scan : integer:=4;
	variable tmp_data_u : std_logic_vector(ISTR_SIZE-1 downto 0);
	--variable istr: std_logic_vector(ISTR_SIZE-1 downto 0);
begin  -- process FILL_MEM_P
    if (Rst = '1') then
		file_open(mem_fp,"JumpAndLink.asm.mem",READ_MODE);
		while (not endfile(mem_fp)) loop
			readline(mem_fp,file_line);
			hread(file_line,tmp_data_u);
			--var_scan:=4;
			-- for i in 0 to 3 loop
		
				-- IRAM_mem(4*index + i) <= tmp_data_u(8*var_scan-1 downto 8*(var_scan-1));
				-- var_scan:=var_scan-1;

			-- end loop;
			-- index := index + 1;
			IRAM_mem(index) <= tmp_data_u(31 downto 24);
			index := index + 1;
			IRAM_mem(index) <= tmp_data_u(23 downto 16);
			index := index + 1;
			IRAM_mem(index) <= tmp_data_u(15 downto 8);
			index := index + 1;
			IRAM_mem(index) <= tmp_data_u(7 downto 0);
			index := index + 1;
		
		
		end loop;
    end if;
end process FILL_MEM_P;

end IRam_Bhe;
