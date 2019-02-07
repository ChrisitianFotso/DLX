library ieee;
use ieee.std_logic_1164.all;

entity MEM_WB_PIPE_REG is
  port (
		CLK				        	: 	IN std_logic;
		RESET			        	: 	IN std_logic;
		ENABLE						:	IN std_logic;
		ALU_OUT_PIPE_IN				: 	IN std_logic_vector(31 downto 0);     
		--DATA_MEMOUT_PIPE_IN			: 	IN std_logic_vector(31 downto 0);	
		DESTREG_ADDRESS_PIPE_IN		: 	IN std_logic_vector(4 downto 0);	
		ALU_OUT_PIPE_OUT			: 	OUT std_logic_vector(31 downto 0);                    
		--DATA_MEMOUT_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);
		DESTREG_ADDRESS_PIPE_OUT	: 	OUT std_logic_vector(4 downto 0)); 
end MEM_WB_PIPE_REG;

architecture behavioral of MEM_WB_PIPE_REG is

begin
	process(clk)
		begin
			if (clk = '1' and clk'event) then
				if (RESET = '1') then
					ALU_OUT_PIPE_OUT				<= (others => '0');
					--DATA_MEMOUT_PIPE_OUT				<= (others => '0');
					DESTREG_ADDRESS_PIPE_OUT		<= (others => '0');

				elsif(ENABLE = '1') then
					ALU_OUT_PIPE_OUT				<= 	ALU_OUT_PIPE_IN			;		
					--DATA_MEMOUT_PIPE_OUT			<=	DATA_MEMOUT_PIPE_IN		;			
					DESTREG_ADDRESS_PIPE_OUT		<=	DESTREG_ADDRESS_PIPE_IN	;			
		
				end if;
			end if;
	end process;
end behavioral;
