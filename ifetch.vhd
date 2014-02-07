--
--
-- Ifetch module (provides the PC and instruction memory for the SPIM computer)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
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

	signal PC : std_logic_vector(datapath_size - 1 downto 0);
	signal PCtemp : std_logic_vector(datapath_size - 1 downto 0);
	signal PCaddtemp : std_logic_vector(datapath_size - 1 downto 0);
	signal imemContent: std_logic_vector(word_size - 1 downto 0);
	
	-- Insert SPIM Machine Language Test Program Here

	type memory_array is array (0 to 2**imem_size - 1) of std_logic_vector(word_size - 1 downto 0);
	constant imem : memory_array := (
-- place your machine code here:
-- include assembly code as comments

	X"3410c000", X"8e120000", X"ae120080", X"8e110008",
	X"ae110084", X"1000fffa", 

	
		(x"00000000"),	(x"00000000"),	
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
      PCaddtemp <= std_logic_vector(unsigned(PC) + 4);
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
					PC<= "0000000000000000";  -- DJN: would like a slicker way to do this.  
					else PC<=PCtemp;
				end if;
		  end if;
        end process;

-- Fetch Instruction from memory     
      Process (PC)
          begin
 				imemContent <= imem(to_integer(unsigned(PC(imem_size + 1 downto 2))));
			 end process;
	instruction <= imemContent;
end behavior;

