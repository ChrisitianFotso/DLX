
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.myTypes.all;

entity FORWARD_UNIT is
	port(
		EX_MEM_Write : in std_logic;
		EX_MEM_Rd : in std_logic_vector(4 downto 0);
		ID_EX_Rs : in std_logic_vector(4 downto 0);
		ID_EX_Rt : in std_logic_vector(4 downto 0);
		MEM_WB_write : in std_logic;
		MEM_WB_Rd : in std_logic_vector(4 downto 0);
		
		sel_lower_mux : out std_logic_vector(1 downto 0);--multiplexer select signal
		sel_upper_mux : out std_logic_vector(1 downto 0)-- //--
	);
								
end FORWARD_UNIT;

architecture Structural of FORWARD_UNIT is

begin

mux_dow:process(EX_MEM_write,EX_MEM_Rd,ID_EX_Rt,MEM_WB_write,MEM_WB_Rd)
	begin
		if((EX_MEM_write = '1') and (EX_MEM_Rd/="00000") and (EX_MEM_Rd = ID_EX_Rt))then
			sel_lower_mux <= "10";
		elsif ((MEM_WB_write = '1') and (MEM_WB_Rd/="00000") and (MEM_WB_Rd = ID_EX_Rt) and (EX_MEM_Rd /= ID_EX_Rt) ) then
			sel_lower_mux <= "01";
		else 
			sel_lower_mux <= "00";
		end if;
	end process;

mux_up:process(EX_MEM_write,EX_MEM_Rd,ID_EX_Rs,MEM_WB_write,MEM_WB_Rd)
	begin
		if((EX_MEM_write = '1') and (EX_MEM_Rd/="00000") and (EX_MEM_Rd = ID_EX_Rs))then
			sel_upper_mux <= "10";
		elsif ((MEM_WB_write = '1') and (MEM_WB_Rd/="00000") and (MEM_WB_Rd = ID_EX_Rs) and (EX_MEM_Rd /= ID_EX_Rs) ) then
			sel_upper_mux <= "01";
		else
			sel_upper_mux <= "00";
		end if;
	end process;

end Structural;