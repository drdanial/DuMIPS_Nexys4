--
--
-- control module (simulates SPIM control module)
--
--
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
--library SYNTH;
--use SYNTH.VHDLSYNTH.ALL;
--use SYNTH.VL_COMPS.ALL;

entity control is
   port(  
			Op 		: in std_logic_vector(5 downto 0);
			RegDst 	: out std_logic;
			ALUSrc 	: out std_logic;
			MemtoReg 	: out std_logic;
			RegWrite 	: out std_logic;
			MemRead 	: out std_logic;
			MemWrite 	: out std_logic;
			Branch 	: out std_logic;
			BranchNotEqual : out std_logic;
			Jump		: out std_logic;
			JR			: out std_logic;
			funct		: in std_logic_vector(5 downto 0);
			ALUctl		: out std_logic_vector(4 downto 0));
--			phi2		: in std_logic);

end control;

--
-- SPIM control architecture
--

architecture behavior of control is
   
   signal  Rformat, Lw, Sw, immed, Beq, Bne, JAL, JRtemp: std_logic;

begin           -- behavior of SPIM control
------------------------------------------------------------------------------

	Rformat <= ((NOT Op(5)) AND (NOT Op(4)) AND (NOT Op(3)) AND
				(NOT Op(2)) AND (NOT Op(1)) AND (NOT Op(0)));

	Lw      <= (    Op(5)) AND (NOT Op(4)) AND (NOT Op(3)) AND
				(NOT Op(2)) AND (    Op(1)) AND (    Op(0));

	Sw      <= (    Op(5)) AND (NOT Op(4)) AND (    Op(3)) AND
				(NOT Op(2)) AND (    Op(1)) AND (    Op(0));

	Beq     <= (NOT Op(5)) AND (NOT Op(4)) AND (NOT Op(3)) AND
				(    Op(2)) AND (NOT Op(1)) AND (NOT Op(0));
				
	Bne     <= (NOT Op(5)) AND (NOT Op(4)) AND (NOT Op(3)) AND
				(    Op(2)) AND (NOT Op(1)) AND (    Op(0));
				
				-- Op(5 downto 3) = "001" (Addi, Addiu, slti, sltiu, andi ori, xori, lui)
	immed 	<= (NOT Op(5)) AND (NOT Op(4)) AND (    Op(3)); 
	
	Jump	<= ( NOT Op(5)) AND (NOT Op(4)) AND (NOT Op(3)) AND
					 (NOT Op(2)) AND (    Op(1)) ;

	JAL	<= ( NOT Op(5)) AND (NOT Op(4)) AND (NOT Op(3)) AND
					 (NOT Op(2)) AND (    Op(1)) AND (   Op(0));

	JRtemp	<= (( NOT funct(5)) AND (NOT funct(4)) AND (    funct(3)) AND
				( NOT funct(2)) AND (NOT funct(1)) AND (NOT funct(0)) AND Rformat);

		RegDst <=  Rformat;
		ALUSrc <=  Lw or Sw or immed;  
		MemtoReg <=  Lw;
		RegWrite <=  Rformat or Lw OR (immed AND (NOT JRtemp)) OR JAL;
		MemRead <=  Lw;
		MemWrite <=  Sw; 
		Branch <=  Beq;
		BranchNotEqual <=  Bne;
		JR <= JRtemp;
--		itype <= lw OR sw;




dummy: process (Rformat,funct,Op) is
	begin
		if (Rformat = '1') then
		
			case funct(5 downto 0) is
				WHEN "100000" => ALUctl <= "00010"; -- ADD
				WHEN "100101" => ALUctl <= "00001"; -- OR
				WHEN "100100" => ALUctl <= "00000"; -- AND
				WHEN "100010" => ALUctl <= "00110"; -- SUB
				WHEN "101010" => ALUctl <= "00111"; -- SLT
				WHEN "100110" => ALUctl <= "00011"; -- XOR
				WHEN "000000" => ALUctl <= "10000"; -- SLL
				WHEN "000010" => ALUctl <= "10010"; -- SRL 
				WHEN "000011" => ALUctl <= "10011"; -- SRA 
				WHEN "001000" => ALUctl <= "11001"; -- JR
				
				WHEN others => ALUctl <= "11111";
			end case;
		else 
			case Op(5 downto 0) is
				WHEN "100011" => ALUctl <= "00010";  -- LW
				WHEN "101011" => ALUctl <= "00010";  -- SW
				WHEN "001000" => ALUctl <= "00010";  -- ADDI
				WHEN "001101" => ALUctl <= "00001";  -- ORI
				WHEN "001100" => ALUctl <= "00000";  -- ANDI
				WHEN "000100" => ALUctl <= "00110";  -- for BEQ do a SUB
				WHEN "000101" => ALUctl <= "00110";  -- for BNE do a SUB
				WHEN "000011" => ALUctl <= "11000";  -- for JAL 
				WHEN others => ALUctl <= "11111";	 -- default is pass through
			end case;
		end if;
	end process;
		
	


end behavior;

