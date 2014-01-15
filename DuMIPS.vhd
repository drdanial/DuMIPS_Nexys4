--
--
-- TOP_SPIM module
--
-- VHDL synthesis and simulation model of MIPS machine
-- as described in chapter 5 of Patterson and Hennessey
-- NOTE: Data paths limited to 8 bits to speed synthesis and
-- simulation.  Registers limited to 8 bits and $R0..$R7
-- Program and Data memory limited to locations 0..7

-- Recent changes from DuMIPS
--implemented BNE instruction.
-- Need to add 
--     Shift and Rotate
--		 serial communication with devices
--		 VGA drivers
--		 operating system support

library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;
--library SYNTH;
--use SYNTH.VHDLSYNTH.ALL;

entity DuMIPS is
generic (
			datapath_size : integer := 16;
			word_size : integer := 32;
			imem_size : integer := 6;		-- address width of instruction memory
			dmem_size : integer := 3 		-- address width of data memory
			);
port(    reset_in,sys_clk: in std_logic; 
			switchin  : in std_logic_vector(10 downto 0); -- btn2, btn1, btn0, sw7 downto sw0.  
			leds      : out std_logic_vector(7 downto 0);
			anodes    : out std_logic_vector(3 downto 0);
			segments  : out std_logic_vector(0 to 7));  -- 8th bit is decimal point

end DuMIPS;



architecture structure of DuMIPS is
	
   component Ifetch 
	generic (
			datapath_size : integer;
			word_size : integer;
			imem_size : integer
	);
	port(
		  Instruction: out std_logic_vector(word_size - 1 downto 0);
        PCadd : out  std_logic_vector(datapath_size - 1 downto 0);
        Addresult : in std_logic_vector(datapath_size - 1 downto 0);
        Branch : in std_logic;
		  BranchNotEqual: in std_logic;
		  Jump: in std_logic;
		  JR: in std_logic;
        phi2,reset : in std_logic;
        Zero : in std_logic);
--        PCout : out std_logic_vector(7 downto 0));

   end component;

   component Idecode 
	generic (
			datapath_size : integer;
			word_size : integer
	);
	port(
		  rr1d_bus : out std_logic_vector(datapath_size - 1 downto 0);
        rr2d_bus : out std_logic_vector(datapath_size - 1 downto 0);
        Instruction : in std_logic_vector(31 downto 0);
        wrd_bus : in std_logic_vector(datapath_size - 1 downto 0);
        RegWrite : in std_logic;
        RegDst : in std_logic;
        Extend : out std_logic_vector(datapath_size - 1 downto 0);
        phi2: in std_logic);

	end component;



   component control 
		port( 
				Op : in std_logic_vector(5 downto 0);
				 RegDst : out std_logic;
				 ALUSrc : out std_logic;
				 MemtoReg : out std_logic;
				 RegWrite : out std_logic;
				 MemRead : out std_logic;
				 MemWrite : out std_logic;
				 Branch : out std_logic;
				 BranchNotEqual : out std_logic;
				 Jump		: out std_logic;
				 JR		: out std_logic;
				 ALUctl : out std_logic_vector(4 downto 0);
				 Funct : in std_logic_vector(5 downto 0));
				 --phi2: in std_logic);
	
	 end component;

   component  Execute  
		generic (
				datapath_size : integer;
				word_size : integer
			);
		port(
				Readdata1 : in std_logic_vector(datapath_size - 1 downto 0);
				 Readdata2 : in std_logic_vector(datapath_size - 1 downto 0);
				 Extend : in std_logic_vector(datapath_size - 1 downto 0);
				 ALUctl : in std_logic_vector(4 downto 0);
				 ALUSrc : in std_logic;
				 shamt  : in std_logic_vector(4 downto 0);
				 Zero : out std_logic;
				 ALUResult : out std_logic_vector(datapath_size - 1 downto 0);
				 ADDResult : out std_logic_vector(datapath_size - 1 downto 0);
				 PCadd : in std_logic_vector(datapath_size - 1 downto 0));
				 --phi2: in std_logic);

	end component;


   component dmemory 
		generic (
			datapath_size : integer;
			word_size : integer;
			dmem_size : integer  -- size of data memory address in bits. 
		);
		port(
		  rd_bus : out std_logic_vector(datapath_size - 1 downto 0);
        ra_bus : in std_logic_vector(datapath_size - 1 downto 0);
        wd_bus : in std_logic_vector(datapath_size - 1 downto 0);
        wadd_bus : in std_logic_vector(datapath_size - 1 downto 0);
        MemRead, Memwrite, MemtoReg : in std_logic;
		  -- seven segment LED display outputs
		  segments : out std_logic_vector(0 to 7);  -- 8th bit is decimal point
		  anodes   : out std_logic_vector(3 downto 0);

		  -- I/O ports to the processor follow here
		  port0 : out std_logic_vector(7 downto 0);

		-- digin(10 downto 8) go to push buttons
		-- digin(7 downto 0) go to slide switches
		  digin : in std_logic_vector(10 downto 0);  
		  phi2,reset: in std_logic);

   end component;

	signal phi2 : std_logic;
	signal reset : std_logic;
	
   signal PCadd :  std_logic_vector(datapath_size - 1 downto 0) := conv_std_logic_vector(0,datapath_size);
   signal rr1d_bus : std_logic_vector(datapath_size - 1 downto 0);
   signal rr2d_bus : std_logic_vector(datapath_size - 1 downto 0);
   signal Extend : std_logic_vector(datapath_size - 1 downto 0);
   signal Addresult : std_logic_vector(datapath_size - 1 downto 0);
   signal ALUresult : std_logic_vector(datapath_size - 1 downto 0);
   signal shamt : std_logic_vector(5 downto 0);
   signal Branch : std_logic := '0';
   signal BranchNotEqual : std_logic := '0';
	signal Jump : std_logic := '0';
	signal JR   : std_logic := '0';
   signal Zero : std_logic := '0';
   signal wrd_bus : std_logic_vector(datapath_size - 1 downto 0);
   signal RegWrite : std_logic := '0';
   signal RegDst :  std_logic := '0';
   signal ALUSrc :  std_logic := '0';
   signal MemtoReg :  std_logic := '0';
   signal MemRead :  std_logic := '0';
   signal MemWrite :  std_logic := '0';
   signal ALUctl :  std_logic_vector(4 downto 0) := "00000";
   signal MIPS_Inst: std_logic_vector(word_size - 1 downto 0) := conv_std_logic_vector(0,word_size);
	signal disp0: std_logic_vector(7 downto 0);



begin
--   Out_Inst <= MIPS_Inst;
   IFE : Ifetch 
	generic map (
			datapath_size => datapath_size,
			word_size => word_size,
			imem_size => imem_size
			)
	port map (
			Instruction => MIPS_Inst,
			PCadd => PCadd,
			Addresult => Addresult,
			Branch => Branch,
			BranchNotEqual => BranchNotEqual,
			Jump => Jump,
			JR   => JR,
			phi2 => phi2, reset => reset,
			Zero => Zero);
--			PCout => PC);

	ID : Idecode    
	generic map (
			datapath_size => datapath_size,
			word_size => word_size
			)
	port map (
			rr1d_bus => rr1d_bus,
			rr2d_bus => rr2d_bus,
			Instruction => MIPS_Inst,
			wrd_bus => wrd_bus,
			RegWrite => RegWrite,
			RegDst => RegDst,
			Extend => Extend,
         phi2 => phi2); --, reset => reset);

   CTL:   control    
	port map ( Op => MIPS_Inst(31 downto 26),
			RegDst => RegDst,
			ALUSrc => ALUSrc,
			MemtoReg => MemtoReg,
			RegWrite => RegWrite,
			MemRead => MemRead,
			MemWrite => MemWrite,
			Branch => Branch,
			BranchNotEqual => BranchNotEqual,
			Jump => Jump,
			JR   => JR,
			ALUctl => ALUctl,
         Funct => MIPS_Inst(5 downto 0));
		--	phi2 => phi2);

   EXE:  Execute   
	generic map (
			datapath_size => datapath_size,
			word_size => word_size
			)
	port map (
			Readdata1 => rr1d_bus,
			Readdata2 => rr2d_bus,
			Extend => Extend,
			ALUctl => ALUctl,
			ALUSrc => ALUSrc,
			shamt => MIPS_Inst(10 downto 6),
			Zero => Zero,
			ALUResult => ALUResult,
			ADDResult => ADDResult,
			PCadd => PCadd);
			--phi2 => phi2);

   MEM:  dmemory 
	generic map (
			datapath_size => datapath_size,
			word_size => word_size,
			dmem_size => dmem_size
			)
	port map ( 
			rd_bus => wrd_bus,
			ra_bus => ALUResult,
			wd_bus => rr2d_bus,
			wadd_bus => ALUResult,
			MemRead => MemRead, 
			Memwrite => MemWrite, 
			MemtoReg => MemtoReg,
			segments => segments,
			anodes => anodes,
			port0 => leds,
			digin => switchin,
			phi2 => phi2, reset => reset);

--	phi2 <= sys_clk;  If we can get the delay small enough, we won't have to divide the clock.  
	reset <= not reset_in;
	
process(sys_clk,phi2) 
	begin
	if (sys_clk'event and sys_clk = '1') then
		phi2 <= not phi2;
	end if;
	end process;
	
	
end structure;

