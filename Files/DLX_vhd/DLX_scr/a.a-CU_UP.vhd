--  stages pipelined versions
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

-----------------------------------ENTITY-----------------------
entity 	DLX_CU_PU is
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
				memread_ex_mem		: in std_logic:='0';
				mem_write       	: in std_logic:='0';
				ex_mem_reg_write	: in std_logic:='0';-- TELL US IF IS IS A WRITE BACK OPERATION
				-------inputs write back unit---------
				mem_wb_reg_write	: in std_logic:='0';
				mux_wb_sel  		: in std_logic:='0';
				-------input control_unit-----------------
				OPCODE : in  std_logic_vector(OPCODE_SIZE - 1 downto 0):=(others=>'0');
				FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0):=(others=>'0');              
				Clk : in std_logic:='0';
				Rst : in std_logic:='0';
				stall_flag: in std_logic):='0';                  
end DLX_CU_PU;

--------------------------------------------ARCHITECTURE-----------------------------------------------------------
architecture MICRO_CU_BEHAVIORAL of DLX_CU_PU is
  
	type MEM_ARRAY is array (integer range 0 to MICROCODE_MEM_SIZE_P - 1) of std_logic_vector(CWRD_SIZE - 1 downto 0);
	type OFFSET_MICROCODE_ARRAY is array (integer range 0 to OFFSET_MEM_SIZE ) of std_logic_vector(OPCODE_SIZE + 1 downto 0);-- a memory word is one byte
	signal OFFSET_MICROCODE : OFFSET_MICROCODE_ARRAY := (	--X"00",--0x00 reset   
															X"01",--0x00 R 
															X"05",--0x02 J
															X"09",--0x03 JAL
															X"0d",--0x04 BEQZ
															X"25",--0x05 BNEZ
															X"00",--0x06 UNUSED
															X"00",--0x07 UNUSED
															X"11",--0x08 ADDI
															X"19",--0x09 ADDUI
															X"11",--0x0A SUBI
															X"19",--0x0B SUBUI
															X"19",--0x0C ANDI
															X"19",--0x0D ORI
															X"19",--0x0E XORI
															X"00",--0x0F UNUSED
															X"00",--0x10 UNUSED
															X"00",--0x11 UNUSED	
															X"00",--0x12 UNUSED
															X"00",--0x13 UNUSED
															X"19",--0x14 SLLI
															X"15",--0x15 NOP
															X"19",--0x16 SRLI
															X"00",--0x17 UNUSED
															x"11",--0x18 SEQI
															x"11",--0x19 SNEI
															x"11",--0x1a SLTI
															x"11",--0x1b SGTI
															x"11",--0x1c SLEI
															x"11",--0x1d SGEI
															X"00",--0x1e UNUSED
															X"00",--0x1f UNUSED
															X"00",--0x20 UNUSED
															X"00",--0x21 UNUSED
															X"00",--0x22 UNUSED
															x"1d",--0x23 LW
															X"00",--0x24 UNUSED
															X"00",--0x25 UNUSED
															X"00",--0x26 UNUSED
															X"00",--0x27 UNUSED
															X"00",--0x28 UNUSED
															X"00",--0x29 UNUSED
															X"00",--0x2a UNUSED
															x"21",--0x2b sw
															X"00",--0x2c UNUSED
															X"00",--0x2d UNUSED
															X"00",--0x2e UNUSED
															X"00",--0x2f UNUSED
															X"00",--0x30 UNUSED
															X"00",--0x31 UNUSED
															X"00",--0x32 UNUSED
															X"00",--0x33 UNUSED
															X"00",--0x34 UNUSED
															X"00",--0x35 UNUSED
															X"00",--0x36 UNUSED
															X"00",--0x37 UNUSED
															X"00",--0x38 UNUSED
															X"00",--0x39 UNUSED
															X"19",--0x3a SLTUI
															X"19",--0x3b SGTUI
															X"19",--0x3c SLEUI
															X"19",--0x3d SGEUI
															X"00",--0x3e UNUSED
															X"00",--0x3f UNUSED
														);
signal 	MICROCODE : MEM_ARRAY := (                     
                                    "00000100011000000", -- reset
									"11100100000000000", -- 0x01 R
									"00000000011000000",
									"00000000000000100",
                                    "00000000000000010",
									"00011110000000000", -- 0x05	J
									"00000000011000000",
									"00000000000000000",
									"00000000000000000",
									"00011111000000000", -- 0x09	JAL
									"00000000010000000",
									"00000000000000000",
									"00000000000000010",
									"11110110000000000", -- 0x0d	BEQZ
									"00000000011000000",
									"00000000000000000",
									"00000000000000000",
									"10100100000000000", -- 0x11	ADDI/... signed immediate operation
									"00000000101000000",
									"00000000000000100",
									"00000000000000010",
									"00000000000000000", --0x15     NOP
									"00000000011000000",
									"00000000000000000",
									"00000000000000000",
									"10100000000000000", -- 0x19	ADDUI/...unsigned immediate operation
									"00000000101000000",
									"00000000000000100",
									"00000000000000010",
									"10100100000000000", -- 0x1d	LW
									"00000000101100000",
									"00000000000010100",
									"00000000000000011",
									"11100100000000000", -- 0x21	SW
									"00000000001000000",
									"00000000000001000",
									"00000000000000000",
									"11110100000000000", -- 0x25	BNEZ
									"00000000011000000",
									"00000000000000000",
								    "00000000000000000",
									);
											
signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
signal OpCode_Offset : std_logic_vector(OP_CODE_SIZE +1 downto 0);
signal IR_func : std_logic_vector(FUNC_SIZE - 1 downto 0);   -- Func part of IR when Rtype
signal cw   : std_logic_vector(CW_SIZE_P - 1 downto 0); -- full control word read from cw_mem
signal cw1  : std_logic_vector(CW_SIZE_P - 1 downto 0);	
signal cw2  : std_logic_vector(CW_SIZE_P - 1 downto 0); 
signal cw3  : std_logic_vector(CW_SIZE_P - 1 downto 0);
signal cw4  : std_logic_vector(CW_SIZE_P - 1 downto 0);
signal ALU_OPCODE_SIG  : std_logic_vector(1 downto 0);
signal uPC1 : integer range 0 to 63 := 0;
signal uPC2 : integer range 0 to 63 := 0;
signal uPC3 : integer range 0 to 63 := 0;
signal uPC4 : integer range 0 to 63 := 0;
signal CNT  : integer range 0 to  4 := 0;

begin
  
  cw1 <= microcode(uPC1);
  cw2 <= microcode(uPC2);
  cw3 <= microcode(uPC3);
  cw4 <= microcode(uPC4);
  cw  <= cw1 or cw2 or cw3 ot cw4;
  
  -- FIRST PIPE STAGE OUTPUTS
  EN1 <= cw(CW_SIZE_P - 1);               -- enables the register file and the pipeline registers
  RF1 <= cw(CW_SIZE_P - 2);               -- enables the read port 1 of the register file
  RF2 <= cw(CW_SIZE_P - 3);               -- enables the read port 2 of the register file
  WF1 <= cw(CW_SIZE_P - 11);              -- enables the write port of the register file
  -- SECOND PIPE STAGE OUTPUTS
  EN2 <= cw(CW_SIZE_P - 4);               -- enables the pipe registers
  S1  <= cw(CW_SIZE_P - 5);               -- input selection of the first multiplexer--MUX A SELECT
  S2  <= cw(CW_SIZE_P - 6);               -- input selection of the second multiplexer--MUX B SELECT
  -- THIRD PIPE STAGE OUTPUTS
  EN3 <= cw(CW_SIZE_P - 7);               -- enables the memory and the pipeline registers
  RM  <= cw(CW_SIZE_P - 8);               -- enables the read-out of the memory
  WM  <= cw(CW_SIZE_P - 9);               -- enables the write-in of the memory
  S3  <= cw(CW_SIZE_P - 10);              -- input selection of the multiplexer--MEMORY SELECT
  
  IR_opcode (5 downto 0)<= OPCODE;
  OpCode_Offset <= OFFSET_MICROCODE(conv_integer(IR_opcode));
  IR_func<= FUNC;

-------------------------------------process ALU_OPCODE-------------------------------------------------------------
  ALU_OP_CODE_P : process (IR_opcode,IR_func)
   begin  -- process ALU_OP_CODE_P
   ALU_OPCODE_SIG <= (others => '0');

   case conv_integer(unsigned(IR_opcode)) is 
        
		when 0 => ALU_OPCODE_SIG <= "00";
		when 1 =>
            case (conv_integer(IR_func)) is
                when 0 => ALU_OPCODE_SIG <= "00"; --add
                when 1 => ALU_OPCODE_SIG <= "01"; -- sub
                when 2 => ALU_OPCODE_SIG <= "10"; -- and  
                when 3 => ALU_OPCODE_SIG <= "11"; -- or                               
                when others =>ALU_OPCODE_SIG <= "00"; --set default control value of alu into "00"
            end case;
		when conv_integer(unsigned(ITYPE_ADDI1)) => ALU_OPCODE_SIG <= "00"; -- add
		when conv_integer(unsigned(ITYPE_ADDI2)) => ALU_OPCODE_SIG <= "00"; -- add
		when conv_integer(unsigned(ITYPE_SUBI1)) => ALU_OPCODE_SIG <= "01"; -- sub
        when conv_integer(unsigned(ITYPE_SUBI2)) => ALU_OPCODE_SIG <= "01"; -- sub
		when conv_integer(unsigned(ITYPE_ANDI2)) => ALU_OPCODE_SIG <= "10"; -- and
        when conv_integer(unsigned(ITYPE_ANDI1)) => ALU_OPCODE_SIG <= "10"; -- and
        when conv_integer(unsigned(ITYPE_ORI2 )) => ALU_OPCODE_SIG <= "11"; -- or
        when conv_integer(unsigned(ITYPE_ORI1 )) => ALU_OPCODE_SIG <= "11"; -- or
        when others => ALU_OPCODE_SIG <= "00"; --in those cases alucode doesn't influence the behavior
    end case;
end process ALU_OP_CODE_P;

uPC1 <= 0 when rst = '0' else conv_integer(OpCode_Offset); 
-----------------------------------------------uPC_Proc-----------------------------------------------------

uPC_Proc: process (Clk, Rst)

begin  
    if Rst = '0' then                   -- asynchronous reset (active low)
		uPC1 <= 0;
		uPC2 <= 0;
		uPC3 <= 0;
		uPC4 <= 0;
		--CNT <= 0;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
		if(uPC1/=0) then
		upc2 <= upc1+1;
		ALU_OPCODE <= ALU_OPCODE_SIG;
		end if;
	    if (uPC2 /=0) then
		upc3 <= uPC2 +1;
		end if;
			--uPC <= uPC + 1;                                   
			--CNT <= CNT + 1;
			--end if;
			
			--if CNT=2 then
			   --CNT<=0;
			--end if;
	end if;
  end process uPC_Proc;
  
end DLX_CU_PU;
