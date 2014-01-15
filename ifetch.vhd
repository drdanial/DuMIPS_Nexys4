--
--
-- Ifetch module (provides the PC and instruction memory for the SPIM computer)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

--library SYNTH;
--use SYNTH.VHDLSYNTH.ALL;
--use SYNTH.VIEWARCHITECT.ALL;
--use SYNTH.VL_COMPS.ALL;

entity Ifetch is
generic (
			datapath_size : integer;
			word_size : integer;
			imem_size : integer
			);
port( 
			Instruction : out std_logic_vector(word_size - 1 downto 0);
         PCadd : out  std_logic_vector(datapath_size - 1 downto 0);
         Addresult : in std_logic_vector(datapath_size - 1 downto 0);
         Branch : in std_logic;
			BranchNotEqual: in std_logic;
			Jump: in std_logic;
			JR:   in std_logic;
         phi2, reset : in std_logic;
         Zero : in std_logic);

end Ifetch;

--
-- Ifetch architecture
--

architecture behavior of Ifetch is

	signal PC : std_logic_vector(datapath_size - 1 downto 0) := conv_std_logic_vector(0,datapath_size);
	signal PCtemp : std_logic_vector(datapath_size - 1 downto 0) := conv_std_logic_vector(0,datapath_size);
	signal PCaddtemp : std_logic_vector(datapath_size - 1 downto 0) := conv_std_logic_vector(0,datapath_size);
	signal imemContent: std_logic_vector(word_size - 1 downto 0);
	
	-- Insert SPIM Machine Language Test Program Here

	type memory_array is array (0 to 2**imem_size - 1) of std_logic_vector(word_size - 1 downto 0);
	constant imem : memory_array := (
-- place your machine code here:
-- include assembly code as comments

  X"3410c000", --  ori $16, $0, -16384      ; 12: ori $s0, $zero, 0xC000 # point a register at 0xC000 
  X"00008825", --  or $17, $0, $0           ; 14: or $s1, $zero, $zero # $s1 points to memory 
  X"8e080004", --  lw $8, 4($16)            ; 17: lw $t0, 4($s0) # get counter 
  X"8e090000", --  lw $9, 0($16)            ; 18: lw $t1, 0($s0) # get switches and pushbuttons 

  X"ae08000c", --  sw $8, 12($16)           ; 20: sw $t0, 12($s0) # display count on 7-segment display 
  X"ae090008", --  sw $9, 8($16)            ; 21: sw $t1, 8($s0) # display switches 8 leds 
  X"1000fffb", --  beq $0, $0, -20 [loop-0x00400018]
	
		(x"00000000"),	
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),

		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),

		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),

		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000")

	);
	


	begin
-- Increment PC by 4        
--		PCout <= PC;
      PCaddtemp(datapath_size - 1 downto 2) <= PC(datapath_size - 1 downto 2) + 1;
		PCaddtemp(1 downto 0) <= "00";
      PCadd <= PCaddtemp(datapath_size - 1 downto 0);  
		
-- Mux for Branch Address or Next Address        
		PCtemp <= Addresult WHEN (((Branch='1') AND (Zero='1')) OR ((BranchNotEqual='1') AND (Zero='0')) OR (JR='1'))
				   ELSE imemContent(datapath_size - 3 downto 0) & "00" WHEN Jump = '1'
					ELSE PCaddtemp(datapath_size - 1 downto 0);
-- Load next PC
		PROCESS (phi2)
        Begin
        if (phi2'event) and (phi2='1') then
				If reset='1' then
					PC<=(conv_std_logic_vector(0,datapath_size));
					else PC<=PCtemp;
				end if;
		  end if;
        end process;

-- Fetch Instruction from memory     
      Process (PC)
          begin
 				imemContent <= imem(conv_integer(PC(imem_size + 1 downto 2)));
			 end process;
	instruction <= imemContent;
end behavior;

