--
--
-- Execute module (simulates SPIM (ALU) Execute module)
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--library SYNTH;
--use SYNTH.VHDLSYNTH.ALL;
--use SYNTH.VL_COMPS.ALL;

entity  Execute is
		generic (
				datapath_size : integer;
				word_size : integer
				);
		port(	Readdata1 	: in std_logic_vector(datapath_size - 1 downto 0);
				Readdata2 	: in std_logic_vector(datapath_size - 1 downto 0);
				Extend 		: in std_logic_vector(datapath_size - 1 downto 0);
				ALUctl 		: in std_logic_vector(4 downto 0);
				ALUSrc 		: in std_logic;
				shamt			: in std_logic_vector(4 downto 0);
				Zero 			: out std_logic;
				ALUResult 	: out std_logic_vector(datapath_size - 1 downto 0);
				ADDResult 	: out std_logic_vector(datapath_size - 1 downto 0);
				PCadd 		: in std_logic_vector(datapath_size - 1 downto 0));
--				phi2			: in std_logic);

end Execute;

architecture behavior of Execute is

	component shifter 
		generic (
				datapath_size : integer;
				word_size : integer
			);
    Port ( dataIn : in  STD_LOGIC_VECTOR (datapath_size - 1  downto 0);
           dataOut : out  STD_LOGIC_VECTOR (datapath_size - 1 downto 0);
           shamt : in  STD_LOGIC_VECTOR (4 downto 0);
			  ALUctl : in STD_LOGIC_VECTOR (4 downto 0));
	end component;

 
   Signal Ainput, Binput : std_logic_vector(datapath_size - 1 downto 0);
	Signal ResMux: std_logic_vector(datapath_size - 1 downto 0);
	Signal ShiftedValue : std_logic_vector(datapath_size - 1 downto 0);

	begin
	
		SHIFT: 	shifter 
		generic map (
				datapath_size => datapath_size,
				word_size => word_size
			)
		Port map( 
			dataIn => Binput,
         dataOut => ShiftedValue,
         shamt => shamt,
			ALUctl => ALUctl);

		Ainput <= Readdata1;
		Binput <= Readdata2 WHEN (ALUSrc='0') ELSE Extend(datapath_size - 1 downto 0);


		-- Generate Zero Flag
		Zero <= '1' WHEN (ResMux(datapath_size - 1 downto 0) = conv_std_logic_vector(0,datapath_size)) 
						ELSE '0';    

		-- Select ALU output  
		ALUresult <= (conv_std_logic_vector(0,datapath_size - 1)) & ResMux(datapath_size - 1) 
						WHEN ALUctl="00111"   							-- choice for SLT instruction
						ELSE ResMux(datapath_size - 1 downto 0);	-- all other instructions
						
		-- Adder for Branch Address with MUX for BRANCH or JR
		Addresult <= Ainput WHEN ALUctl = "11001" --  JR
						ELSE PCadd + (Extend(datapath_size - 3 downto 0) & "00");  -- BRANCH

		Process (ALUctl,Ainput,Binput,ShiftedValue,PCadd)
		begin
			 case ALUctl(4 downto 0) is
				 -- Select ALU operation
				 -- ALU performs ALUresult = bus_A AND bus_B
				 WHEN "00000" => ResMux <= Ainput AND Binput; 
				 -- ALU performs ALUresult = bus_A OR bus_B
				 WHEN "00001" => ResMux <= Ainput OR Binput;	-- need to make this happen for a li inst. 
				 -- ALU performs ALUresult = bus_A + bus_B
				 WHEN "00010" => ResMux <= Ainput + Binput;
				 -- ALU performs ??  Let's just make this the XOR function  
				 WHEN "00011" => ResMux <= Ainput XOR Binput;
				 -- ALU performs bus_A AND NOT bus_B
				 WHEN "00100" => ResMux <= Ainput AND NOT Binput;
				 -- ALU performs bus_A OR NOT bus_B
				 WHEN "00101" => ResMux <= Ainput OR NOT Binput;
				 -- ALU performs ALUresult = bus_A - bus_B
				 WHEN "00110" => ResMux <= Ainput - Binput;  -- This is a subtract for BEQ
				 -- ALU performs SLT which we won't use!
				 WHEN "00111" => ResMux <= Ainput - Binput;
--				 -- ALU performs MULTIPLY!! 
--				 WHEN "01000" => ResMux <= (conv_std_logic_vector(
--													conv_integer(Ainput) * conv_integer(Binput), datapath_size));
--				 -- ALU performs Divide!! 
--				 WHEN "01000" => ResMux <= (conv_std_logic_vector(
--													conv_integer(Ainput) / conv_integer(Binput), datapath_size));
				 WHEN "10000"	=> ResMux <= ShiftedValue;  -- Signal for shift Left instruction
				 WHEN "10010"	=> ResMux <= ShiftedValue;  -- Signal for shift right logical instruction
				 WHEN "10011"	=> ResMux <= ShiftedValue;  -- Signal for shift arithmetic instruction
--				 WHEN "10000"	=> ResMux <= (conv_std_logic_vector(233,datapath_size));  -- alternative for testing
				 WHEN "11000"	=> ResMux <= PCadd;  -- need to pass PC to register file for JAL instruction
				 WHEN "11001"  => ResMux <= Ainput;  -- Pass through for JR instruction. 
				 WHEN Others => ResMux <= (conv_std_logic_vector(238,datapath_size));  -- display two E's on error.
			 end case;
		end process;
end behavior;

