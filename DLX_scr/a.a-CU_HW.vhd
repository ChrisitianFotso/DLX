library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
--use ieee.numeric_std.all;
--use work.all;

entity dlx_cu is
port (
		-- inputs decode unit
		read_port1			: OUT std_logic:='0';
		read_port2      	: OUT std_logic:='0';				
		enable_reg_file 	: OUT std_logic:='0';				
		jump				: OUT std_logic:='0';				
		EXT_MUX_SEL			: OUT std_logic:='0';
		EXT_UIMM_O_IMM		: OUT std_logic:='0';
		BRANCH_OP           : OUT std_logic:='0';
		--BEQZ_OP             : OUT std_logic:='0';
		JAL_OP				: OUT STD_LOGIC;  --from control------------------------		
		-------inputs execute unit---------
		reg_dst_sel			: OUT std_logic:='0';               
		ALU_SRC_SEL     	: OUT std_logic:='0';               
		ALU_SRC_SEL_UP		: OUT std_logic:='0';
		memread_id_ex   	: OUT std_logic:='0';               
		alu_op				: OUT std_logic_vector(ALU_OP_SIZE-1 downto 0):=(others=>'0');               
		-------inputs memory_unit----------
		memread_ex_mem		: OUT std_logic:='0';
		mem_write       	: OUT std_logic:='0';
		ex_mem_reg_write	: OUT std_logic:='0';-- TELL US IF IS IS A WRITE BACK OPERATION
		-------inputs write back unit---------
		mem_wb_reg_write	: OUT std_logic:='0';
		mux_wb_sel  		: OUT std_logic:='0';
		-------input control_unit-----------------
		--IR_IN : in  std_logic_vector(31 downto 0):=(others=>'0');              
		OPCODE : in  std_logic_vector(OPCODE_SIZE - 1 downto 0);
		FUNC : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
		Clk : in std_logic:='0';
		Rst : in std_logic:='0';
		stall_flag: in std_logic:='0');         

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is
  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw_mem : mem_array := ("11100100011000110", -- R 
                                "00000000011000000", -- NOP
                                "00011110011000000", -- J 
                                "00011111010000010", -- JAL 
                                "11110110011000000", -- BEQZ 
                                "11110100011000000", -- BNEZ
                                "10100100101000110", -- ADDI/... signed immediate operation
                                "10100000101000110", -- ADDUI/...unsigned immediate operation
                                "10100100101110111", -- LW
                                "11100100001001000"); -- SW
								
                                                          
  signal IR_opcode : std_logic_vector(OPCODE_SIZE -1 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(FUNC_SIZE-1 downto 0);   -- Func part of IR when Rtype
 -- signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem
  signal opcode_address : std_logic_vector(OPCODE_SIZE-1 downto 0);

  -- control word is shifted to the correct stage
  --signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- first stage
  signal cw2 : std_logic_vector(CW_SIZE - 1 downto 0); -- second stage
  signal cw3 : std_logic_vector(CW_SIZE - 1 - 8 downto 0); -- third stage
  signal cw4 : std_logic_vector(CW_SIZE - 1 - 12 downto 0); -- fourth stage
  signal cw5 : std_logic_vector(CW_SIZE -1 - 15  downto 0); -- fifth stage
	
  signal aluOpcode_i: std_logic_vector(ALU_OP_SIZE -1 downto 0); -- ALUOP defined in package
  --signal aluOpcode1:  std_logic_vector(ALU_OP_SIZE -1 downto 0);
  signal aluOpcode2:  std_logic_vector(ALU_OP_SIZE -1 downto 0);
  signal aluOpcode3:  std_logic_vector(ALU_OP_SIZE -1 downto 0);

begin  -- dlx_cu_rtl

  IR_opcode(5 downto 0) <= opcode;
  IR_func(10 downto 0)  <= func;

  cw2 <= "00000000011000000" WHEN (Rst='1' or stall_flag='1')  else  cw_mem(conv_integer(opcode_address));

---------inputs decode unit---------------------------------- 

read_port1		 <= cw2(CW_SIZE-1);
read_port2       <= cw2(CW_SIZE-2);
enable_reg_file  <= cw2(CW_SIZE-3);
jump			 <= cw2(CW_SIZE-4);
EXT_MUX_SEL		 <= cw2(CW_SIZE-5);
EXT_UIMM_O_IMM	 <= cw2(CW_SIZE-6);
BRANCH_OP        <= cw2(CW_SIZE-7);     
JAL_OP			 <= cw2(CW_SIZE-8);
-------inputs execute unit
reg_dst_sel		 <= cw3(CW_SIZE-9);
ALU_SRC_SEL      <= cw3(CW_SIZE-10);
ALU_SRC_SEL_UP	 <= cw3(CW_SIZE-11);
memread_id_ex    <= cw3(CW_SIZE-12);
--alu_op			 <= cw3(CW_SIZE-13);
-------inputs memory unit
memread_ex_mem	 <= cw4(CW_SIZE-13);
mem_write        <= cw4(CW_SIZE-14);
ex_mem_reg_write <= cw4(CW_SIZE-15);
-------inputs write back unit
mem_wb_reg_write <= cw5(CW_SIZE-16);
mux_wb_sel  	 <= cw5(CW_SIZE-17);

  --process opcode assignment 
op_proc : process (IR_opcode)
	begin 
  
		case IR_opcode is 
		 		
			when	OPCD_SUBI	=> opcode_address <=  "000110"  ;
			when	OPCD_SUBUI	=> opcode_address <=  "000111"  ;
			when	OPCD_ANDI	=> opcode_address <=  "000110"  ;
			when	OPCD_ORI	=> opcode_address <=  "000110"  ;
			when	OPCD_XORI	=> opcode_address <=  "000110"  ;
			when	OPCD_SLLI	=> opcode_address <=  "000110"  ;
			when	OPCD_NOP	=> opcode_address <=  "000001"  ;
			when	OPCD_SRLI	=> opcode_address <=  "000110"  ;
			--when	--OPCD_SRAI	                                ;
			when	OPCD_SEQI	=> opcode_address <=  "000110"  ;
			when	OPCD_SNEI	=> opcode_address <=  "000110"  ;
			when	OPCD_SLTI	=> opcode_address <=  "000110"  ;
			when	OPCD_SGTI	=> opcode_address <=  "000110"  ;
			when	OPCD_SLEI	=> opcode_address <=  "000110"  ;
			when	OPCD_SGEI	=> opcode_address <=  "000110"  ;
			when	OPCD_SLTUI	=> opcode_address <=  "000111"  ; 
			when	OPCD_SGTUI	=> opcode_address <=  "000111"  ; 
			when	OPCD_SLEUI	=> opcode_address <=  "000111"  ; 
			when	OPCD_SGEUI	=> opcode_address <=  "000111"  ; 
			when    OPCD_LW 	=> opcode_address <=  "001000"  ;
			when    OPCD_SW		=> opcode_address <=  "001001"  ;
			when    OPCD_ADDI	=> opcode_address <=  "000110"  ;
			when    OPCD_ADDUI	=> opcode_address <=  "000111"  ;
			when    others 		=> opcode_address <= IR_opcode  ;
		end case ;
end process op_proc;	
  -- process to pipeline control words
  CW_PIPE: process (Clk,rst)
  begin  -- process Clk
		if Clk'event and Clk = '1' then  -- rising clock edge
      --cw1 <= cw;
		--cw2 <= cw;--(CW_SIZE - 1 - 8 downto 0);
		cw3 <= cw2(CW_SIZE - 1 - 8 downto  0);
		cw4 <= cw3(CW_SIZE - 1 - 12 downto 0);
		cw5 <= cw4(CW_SIZE - 1 - 15 downto 0);

      --aluOpcode1 <= ;
      aluOpcode2 <= aluOpcode_i;
      aluOpcode3 <= aluOpcode2;
    end if;
  end process CW_PIPE;

  alu_op <= aluOpcode2;

   ALU_OP_CODE_P : process (IR_opcode, IR_func)
   begin  -- process ALU_OP_CODE_P
	case IR_opcode is
	        -- case of R type requires analysis of FUNC
		when OPCD_R =>
			case IR_func is
				when FUNC_sll   => aluOpcode_i <= OP_SLL; 
				when FUNC_srl   => aluOpcode_i <= OP_SRL; 
				--when FUNC_sra   => aluOpcode_i <= OP_SRA,
				when FUNC_add 	=> aluOpcode_i <= OP_ADD;
				when FUNC_addu  => aluOpcode_i <= OP_ADD;
				when FUNC_sub   => aluOpcode_i <= OP_SUB;
				when FUNC_subu  => aluOpcode_i <= OP_SUB;
				when FUNC_and   => aluOpcode_i <= OP_AND;
				when FUNC_or    => aluOpcode_i <= OP_OR;
				when FUNC_xor   => aluOpcode_i <= OP_XOR;
				when FUNC_seq   => aluOpcode_i <= OP_SEQ;
				when FUNC_sne   => aluOpcode_i <= OP_SNE;
				when FUNC_slt   => aluOpcode_i <= OP_SLT;
				when FUNC_sgt   => aluOpcode_i <= OP_SGT;
				when FUNC_sle   => aluOpcode_i <= OP_SLE;
				when FUNC_sge   => aluOpcode_i <= OP_SGE;
				when FUNC_sltu  => aluOpcode_i <= op_SLTU;
				when FUNC_sgtu  => aluOpcode_i <= OP_SGTU;
				when FUNC_sleu  => aluOpcode_i <= OP_SLEU;
				when FUNC_sgeu  => aluOpcode_i <= OP_SGEU;
				when others 	=> aluOpcode_i <= OP_ADD;
			end case;	
		
		when OPCD_J		=> aluOpcode_i <= OP_ADD;
		when OPCD_JAL	=> aluOpcode_i <= OP_ADD;
        when OPCD_BEQZ	=> aluOpcode_i <= OP_ADD;
        when OPCD_BNEZ	=> aluOpcode_i <= OP_ADD;
        when OPCD_ADDI	=> aluOpcode_i <= OP_ADD;
        when OPCD_ADDUI	=> aluOpcode_i <= OP_ADD;
        when OPCD_SUBI	=> aluOpcode_i <= OP_SUB;
        when OPCD_SUBUI	=> aluOpcode_i <= OP_SUB;
        when OPCD_ANDI	=> aluOpcode_i <= OP_AND;
        when OPCD_ORI	=> aluOpcode_i <= OP_OR;
        when OPCD_XORI	=> aluOpcode_i <= OP_XOR;
        when OPCD_SLLI	=> aluOpcode_i <= OP_SLL;
        when OPCD_NOP	=> aluOpcode_i <= OP_ADD;
        when OPCD_SRLI	=> aluOpcode_i <= OP_SRL;
        when OPCD_SEQI	=> aluOpcode_i <= OP_SEQ;
        when OPCD_SNEI	=> aluOpcode_i <= OP_SNE;
        when OPCD_SLTI	=> aluOpcode_i <= OP_SLT;
        when OPCD_SGTI	=> aluOpcode_i <= OP_SGT;
        when OPCD_SLEI	=> aluOpcode_i <= OP_SLE;
        when OPCD_SGEI	=> aluOpcode_i <= OP_SGE;
        when OPCD_LW	=> aluOpcode_i <= OP_ADD;
        when OPCD_SW	=> aluOpcode_i <= OP_ADD;
        when OPCD_SLTUI	=> aluOpcode_i <= OP_SLTU;
        when OPCD_SGTUI	=> aluOpcode_i <= OP_SGTU;
        when OPCD_SLEUI	=> aluOpcode_i <= OP_SLEU;
        when OPCD_SGEUI	=> aluOpcode_i <= OP_SGEU;
		WHEN OTHERS 	=> aluOpcode_i <= OP_ADD;	
	END CASE ;  
END PROCESS ALU_OP_CODE_P;


end dlx_cu_hw;
