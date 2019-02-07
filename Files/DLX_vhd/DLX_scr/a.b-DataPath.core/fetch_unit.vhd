library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use ieee.numeric_std.all;

entity fetch_unit is
  port (
		clk              		: in std_logic;
		reset              		: in std_logic;
		from_branch_comparator  : in std_logic;
		jump_signal         	: in std_logic;
		enable_pc          		: in std_logic;
		from_ID_adder          	: in std_logic_vector(31 downto 0); 
		to_iram          		: out std_logic_vector(31 downto 0);        
		to_pc_id_if_reg         : out std_logic_vector(31 downto 0);         
		flush_signal     		: out std_logic    
	);
end fetch_unit;


architecture structural of fetch_unit is


component FETCH_ADDER is
	port(from_pc_to_adder : in STD_LOGIC_VECTOR(31 downto 0);
		 fetch_adder_out  : out STD_LOGIC_VECTOR(31 downto 0));
END component;


component PC is
	port(
		clock,reset,enable : in std_logic;
		data_in : in std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end component;


component Mux2X1 is
	port(
		a 	: in std_logic_vector(31 downto 0);
		b 	: in std_logic_vector(31 downto 0);
		sel : in std_logic;
		o 	: out std_logic_vector(31 downto 0)
		);
end component;


component FETCH_AND is 
	port(
		jump: in std_logic;
		from_decode_comparator: in std_logic;
		Fetch_mux_sel: out std_logic
	);
end component;


signal FETCH_AND_OUT   	: std_logic;  
signal FETCH_PC_OUT     : std_logic_vector(31 downto 0);  
signal FETCH_MUX_OUT    : std_logic_vector(31 downto 0);  
signal FETCH_ADDER_OUT  : std_logic_vector(31 downto 0);  

begin

COMP1 : FETCH_AND
		PORT MAP(
		jump => jump_signal,
		from_decode_comparator => from_branch_comparator,
		Fetch_mux_sel => FETCH_AND_OUT
		);

COMP2 : Mux2X1
		port map(
		a	=> from_ID_adder, 	
		b	=> FETCH_ADDER_OUT,	
		sel => FETCH_AND_OUT,
		o	=> FETCH_MUX_OUT	
		);

COMP3 : PC
		port map(
		clock => clk,reset => reset,enable => enable_pc,data_in => FETCH_MUX_OUT,data_out => FETCH_PC_OUT
		);
		
COMP4 : FETCH_ADDER
		port map(
		from_pc_to_adder => FETCH_PC_OUT,fetch_adder_out => FETCH_ADDER_OUT);

to_iram <= FETCH_PC_OUT;       
to_pc_id_if_reg	<= FETCH_ADDER_OUT;	
flush_signal <= FETCH_AND_OUT;  

end structural;