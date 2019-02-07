library ieee;
use ieee.std_logic_1164.all;
--use work.Consts.all;
--use ieee.math_real.all;
use ieee.numeric_std.all;
use work.myTypes.all;



ENTITY TBALU IS
END TBALU;

architecture TB_ALU_ARCH of TBALU is
	--constant N: integer:=32;
	signal A_TEST, B_TEST: std_logic_vector(DATA_SIZE-1 downto 0):=x"00000000";
	signal O_ADD, O_AND, O_OR, O_XOR, O_SLL, O_SRL, O_SUB, O_SGT, O_SGE, O_SLT, O_SLE, O_SEQ, O_SNE: std_logic_vector(DATA_SIZE-1 downto 0):=x"00000000";
	
	COMPONENT ALU is
		GENERIC(DATA_SIZE: INTEGER :=DATA_SIZE);
		port(A, B: in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
			ALU_OP: (ALU_OP_SIZE-1 downto 0):=(others=>'0');
			OUTALU: OUT std_logic_vector(DATA_SIZE-1 downto 0)
			);
	END COMPONENT;
begin
	ALU0 : ALU
	generic map(N)
	port map(OP_ADD, A_TEST, B_TEST, OP_ADD);
	ALU1 : ALU
	generic map(N)
	port map(OP_AND, A_TEST, B_TEST, O_AND);
	ALU2 : ALU
	generic map(N)
	port map(OP_OR, A_TEST, B_TEST, O_OR);
	ALU3 : ALU
	generic map(N)
	port map(OP_XOR, A_TEST, B_TEST, O_XOR);
	ALU4 : ALU
	generic map(N)
	port map(OP_SLL, A_TEST, B_TEST, O_SLL);
	ALU5 : ALU
	generic map(N)
	port map(OP_SRL, A_TEST, B_TEST, O_SRL);
	ALU6 : ALU
	generic map(N)
	port map(OP_SUB, A_TEST, B_TEST, O_SUB);
	ALU7 : ALU
	generic map(N)
	port map(OP_SGT, A_TEST, B_TEST, O_SGT);
	ALU8 : ALU
	generic map(N)
	port map(OP_SGE, A_TEST, B_TEST, O_SGE);
	ALU9 : ALU
	generic map(N)
	port map(OP_SLT, A_TEST, B_TEST, O_SLT);
	ALU10 : ALU
	generic map(N)
	port map(OP_SLE, A_TEST, B_TEST, O_SLE);
	ALU11 : ALU
	generic map(N)
	port map(OP_SEQ, A_TEST, B_TEST, O_SEQ);
	ALU12 : ALU
	generic map(N)
	port map(OP_SNE, A_TEST, B_TEST, O_SNE);
	
	
	A_TEST <= x"ffffffff", x"04532434" after 1 ns, x"2234e826" after 2 ns, x"a323f443" after 3 ns, x"8b651a8b" after 4 ns, x"ffffffff" after 5 ns;
	B_TEST <= x"00000001", x"05335f28" after 1.5 ns, x"2234e826" after 2.5 ns, x"11645030" after 3.5 ns, x"030035a6" after 4.5 ns, x"00000001" after 5.5 ns, x"12334224" after 7 ns;
end TB_ALU_ARCH;

-- configuration tb_alu_cfg of tbAlu is
	-- for tb_alu_arch
	-- end for;
-- end tb_alu_cfg;