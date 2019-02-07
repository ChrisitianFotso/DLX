library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- we need a conversion to unsigned 
use work.myTypes.all;


entity  TB_P4ADDER is 
end TB_P4ADDER; 

architecture TEST of TB_P4ADDER is

COMPONENT P4ADDER is
		GENERIC(N: INTEGER := P4_BIT_NUM;
			    DELTA :INTEGER:=delta_Co);
		port	(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
				CIN: in STD_LOGIC;
				S : out STD_LOGIC_VECTOR(N-1 downto 0);
				COUT: out STD_LOGIC);
END COMPONENT;
  
  signal A, B : std_logic_vector(31 downto 0);
  signal Ci: std_logic;
  signal C0: std_logic;
  signal SUM :STD_LOGIC_VECTOR(31 downto 0);
Begin

-- Instanciate the ADDER without delay in the carry generation
	ADD: P4ADDER  
       GENERIC MAP (32,4)
	   port map (A, B, Ci,SUM, C0);


  Ci <= '1','0' after 30 ns;
  A <= x"55555555", x"FFFFFFFF" after 10 ns ,x"FFC003FF" after 20 ns ,x"2234e826" after 30 ns ,x"8b651a8b" after 40 ns, x"2234e826" after 50 ns;--input pattern express in exact decimal
  B <= x"46894689", x"00000001" after 10 ns ,x"01F81F01" after 20 ns ,x"23323424" after 30 ns ,x"030035a6" after 40 ns, x"23323424" after 50 ns; 
  

end TEST;

configuration TB_P4ADDER_TEST of TB_P4ADDER is
  for TEST
    for ADD: P4ADDER
      use configuration WORK.CFG_P4ADDER_STRUCTURAL;
    end for; 
  end for;
end TB_P4ADDER_TEST;
