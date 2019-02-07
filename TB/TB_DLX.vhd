library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.myTypes.all;

entity tb_dlx is
end tb_dlx;

architecture TEST_DLX of tb_dlx is

    signal Clock: std_logic := '0';
    signal Reset: std_logic := '0';

    component DLX
       port (
       Clk : in std_logic;
       Rst : in std_logic);   
    end component;
begin


  -- instance of DLX
	U1: DLX Port Map (Clock, Reset);


  PCLOCK : process(Clock)
	begin
		Clock <= not(Clock) after 0.5 ns;
	end process;

	Reset <= '1', '0' after 6 ns;


end TEST_DLX;