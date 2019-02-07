library ieee;
use ieee.std_logic_1164.all;

package FUNC is
function CEIL_LOG2 (N:integer) return integer;
end FUNC;

package body FUNC is
  
  
  function CEIL_LOG2 (n:integer) return integer is
	begin
		if N < 2 or N=2 then
			return 1;
		else
			return 1 + CEIL_LOG2(N/2);
		end if;
	end CEIL_LOG2;
end FUNC;