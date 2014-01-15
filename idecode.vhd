library IEEE;
use IEEE.STD_LOGIC_1164.all;
--library SYNTH;
--use SYNTH.VHDLSYNTH.ALL;
--use SYNTH.VL_COMPS.ALL;
--  Idecode module (provides the register file for the SPIM computer)

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--library SYNTH;
--use SYNTH.VHDLSYNTH.ALL;

entity Idecode is
generic (
			datapath_size : integer;
			word_size : integer
			);
port(
		rr1d_bus : out std_logic_vector(datapath_size - 1 downto 0);
      rr2d_bus : out std_logic_vector(datapath_size - 1 downto 0);
      Instruction : in std_logic_vector(word_size - 1 downto 0);
      wrd_bus : in std_logic_vector(datapath_size - 1 downto 0);
      RegWrite : in std_logic;
      RegDst : in std_logic;
      Extend : out std_logic_vector(datapath_size - 1 downto 0);
      phi2: in std_logic);

end Idecode;



--
-- Idecode architecture
--

architecture behavior of Idecode is

component RegisterFile 			-- three-port register file
	generic (
			datapath_size : integer
			);  
	port(clk:          in  STD_LOGIC;
       we3:           in  STD_LOGIC;
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR(4 downto 0);
       wd3:           in  STD_LOGIC_VECTOR(datapath_size - 1 downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR(datapath_size - 1 downto 0));
	end component;

	signal wraddress : std_logic_vector(4 downto 0);
	signal rr1add_bus, rr2add_bus, wra_bus, wra2_bus: std_logic_vector(4 downto 0);
	signal Ivalue: std_logic_vector(15 downto 0);
	signal JAL: std_logic;

	begin
	
	regfile:  RegisterFile 			-- three-port register file
	generic map (
			datapath_size => datapath_size
			)
	port map (clk =>  phi2,
       we3 => RegWrite,
		 ra1 => rr1add_bus,
		 ra2 => rr2add_bus,
		 wa3 => wraddress,
       wd3 => wrd_bus,
       rd1 => rr1d_bus,
		 rd2 => rr2d_bus);

		rr1add_bus <= Instruction(25 downto 21);
		rr2add_bus <= Instruction(20 downto 16);
		wra_bus <=  Instruction(15 downto 11);
		wra2_bus <=  Instruction(20 downto 16);
		Ivalue <= Instruction(15 downto 0);
		
		JAL <= ( NOT Instruction(31)) AND (NOT Instruction(30)) AND (NOT Instruction(29)) AND
					 (NOT Instruction(28)) AND (Instruction(27)) AND (Instruction(26)) ;


	-- Mux for Register Write Address
			wraddress <= "11111" WHEN JAL = '1'
					   ELSE wra_bus WHEN RegDst='1'     -- write address mux
						ELSE wra2_bus;

--			wraddress <= wra_bus WHEN RegDst='1'     -- write address mux
--						ELSE wra2_bus;
									 									 
-- Sign Extend Unit  (NOTE: This only works for a 16 bit wide datapath.  
       Extend(datapath_size - 1 downto 0) <= Ivalue;  -- Sign Extend 16 to 32 bits
--       Extend(31 downto 16) <= X"FFFF" WHEN Ivalue(15)='1' 
--        ELSE X"0000";

--	Extend <= Ivalue(7 downto 0);
	

end behavior;
