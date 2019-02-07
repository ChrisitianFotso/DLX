library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_PIPE_REG is
  port (
		CLK				        : 	IN std_logic;
		RESET			        : 	IN std_logic;
		ENABLE					:	IN std_logic;
		DATA_EXT_PIPE_IN		: 	IN std_logic_vector(31 downto 0);    
		--REG_OUT1_PIPE_IN		: 	IN std_logic_vector(31 downto 0);	
		--REG_OUT2_PIPE_IN		: 	IN std_logic_vector(31 downto 0);	
		ID_RS_REG_PIPE_IN		: 	IN std_logic_vector(4 downto 0);    
		ID_RT_REG_PIPE_IN		:	IN std_logic_vector(4 downto 0);    
		ID_DESTREG_RT_PIPE_IN	:	IN std_logic_vector(4 downto 0);    
		ID_DESTREG_RD_PIPE_IN	:	IN std_logic_vector(4 downto 0);    
		PC						:	IN std_logic_vector(31 downto 0);
		DATA_EXT_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);                    
		--REG_OUT1_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);    
		--REG_OUT2_PIPE_OUT		: 	OUT std_logic_vector(31 downto 0);
		ID_RS_REG_PIPE_OUT		: 	OUT std_logic_vector(4 downto 0); 
		ID_RT_REG_PIPE_OUT		:	OUT std_logic_vector(4 downto 0); 
		ID_DESTREG_RT_PIPE_OUT	:	OUT std_logic_vector(4 downto 0); 
		ID_DESTREG_RD_PIPE_OUT	:	OUT std_logic_vector(4 downto 0);
		PC_OUT					:	OUT std_logic_vector(31 downto 0)); 
end ID_EX_PIPE_REG;
architecture behavioral of ID_EX_PIPE_REG is

begin
	process(clk)
		begin
			if (clk = '1' and clk'event) then
				if (RESET = '1') then
					DATA_EXT_PIPE_OUT		<= (others => '0');
					--REG_OUT1_PIPE_OUT		<= (others => '0');
					--REG_OUT2_PIPE_OUT		<= (others => '0');
					ID_RS_REG_PIPE_OUT		<= (others => '0');
					ID_RT_REG_PIPE_OUT		<= (others => '0');
					ID_DESTREG_RT_PIPE_OUT	<= (others => '0');
					ID_DESTREG_RD_PIPE_OUT	<= (others => '0');
					PC_OUT					<= (others => '0');
				elsif(ENABLE = '1') then
					DATA_EXT_PIPE_OUT		<= 	DATA_EXT_PIPE_IN;		
					--REG_OUT1_PIPE_OUT		<=	REG_OUT1_PIPE_IN;			
					--REG_OUT2_PIPE_OUT		<=	REG_OUT2_PIPE_IN;			
					ID_RS_REG_PIPE_OUT		<=	ID_RS_REG_PIPE_IN;			
					ID_RT_REG_PIPE_OUT		<=	ID_RT_REG_PIPE_IN;			
					ID_DESTREG_RT_PIPE_OUT	<=	ID_DESTREG_RT_PIPE_IN;		
					ID_DESTREG_RD_PIPE_OUT	<=	ID_DESTREG_RD_PIPE_IN;		
					PC_OUT					<=  PC;
				end if;
			end if;
	end process;
end behavioral;
