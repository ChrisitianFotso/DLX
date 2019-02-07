library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity cu_dlx_test is
end cu_dlx_test;

architecture TEST_DLX_CU of cu_dlx_test is

    component dlx_cu
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
    end component;

    signal Clock: std_logic := '0';
    signal Reset: std_logic := '1';

    --signal cu_opcode_i: std_logic_vector(OPCODE_SIZE - 1 downto 0) ;
    --signal cu_func_i: std_logic_vector(FUNC_SIZE - 1 downto 0);
    
	signal read_port1_i : std_logic;		
	signal read_port2_i : std_logic; 
	signal enable_reg_file_i : std_logic; 
	signal jump_i : std_logic;			
	signal EXT_MUX_SEL_i : std_logic;		
	signal EXT_UIMM_O_IMM_i : std_logic;	
	signal BRANCH_OP_i : std_logic;       
	       
	signal JAL_OP_i : std_logic;			
	
	signal reg_dst_sel_i : std_logic;		
	signal ALU_SRC_SEL_i : std_logic;     
	signal ALU_SRC_SEL_UP_i : std_logic;	
	signal memread_id_ex_i : std_logic;   
	signal alu_op_i : std_logic_vector(ALU_OP_SIZE-1 downto 0);			
	
	signal memread_ex_mem_i : std_logic;	
	signal mem_write_i : std_logic;       
	signal ex_mem_reg_write_i : std_logic;
	
	signal mem_wb_reg_write_i : std_logic;
	signal mux_wb_sel_i : std_logic;  	
	signal OPCODE_i : std_logic_vector(OPCODE_SIZE - 1 downto 0);
	signal FUNC_i : std_logic_vector(FUNC_SIZE - 1 downto 0);
--	signal Clk_i : std_logic;
	--signal Rst_i : std_logic;
	signal stall_flag_i : std_logic;
	
begin

        -- instance of DLX
       dut: dlx_cu
       port map (
                 -- OUTPUTS
                read_port1		=> read_port1_i,		
				read_port2      => read_port2_i ,     
				enable_reg_file => enable_reg_file_i, 
				jump			=> jump_i		     	,
				EXT_MUX_SEL		=> EXT_MUX_SEL_i		,
				EXT_UIMM_O_IMM	=> EXT_UIMM_O_IMM_i	    ,
				BRANCH_OP       => BRANCH_OP_i          ,  
				JAL_OP			=> JAL_OP_i			    ,
				reg_dst_sel		=> reg_dst_sel_i		,
				ALU_SRC_SEL     => ALU_SRC_SEL_i        ,
				ALU_SRC_SEL_UP	=> ALU_SRC_SEL_UP_i	    ,
				memread_id_ex   => memread_id_ex_i      ,
				alu_op			=> alu_op_i			    ,
				memread_ex_mem	=> memread_ex_mem_i	    ,
				mem_write       => mem_write_i          ,
				ex_mem_reg_write=> ex_mem_reg_write_i   ,
				mem_wb_reg_write=> mem_wb_reg_write_i   ,
				mux_wb_sel  	=> mux_wb_sel_i  	    ,
				
                 -- INPUTS
                 OPCODE => OPCODE_i,
                 FUNC   => FUNC_i,            
                 Clk    => Clock,
                 Rst    => Reset
               );

    Clock <= not Clock after 1 ns;
	Reset <= '0', '1' after 7 ns;


        CONTROL: process
        begin

        wait for 7 ns;  
        OPCODE_i <= OPCD_J;
        
        wait for 2 ns;
        OPCODE_i  <= OPCD_R;
        func_i <= FUNC_add;
        
		wait for 2 ns;
		
   
        OPCODE_i  <= OPCD_ANDI;
        func_i <= FUNC_add;
         
		wait for 2 ns;
        wait;
		end process;

end TEST_DLX_CU;
