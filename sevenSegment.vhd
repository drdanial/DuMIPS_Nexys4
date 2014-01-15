----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:56:31 09/04/2009 
-- Design Name: 
-- Module Name:    part1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sevenSegmentDisplay is
    Port ( Digits : in  STD_LOGIC_VECTOR (15 downto 0);
			  sysclock : in STD_LOGIC;
           sevenSegs : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
           anodes    : out  STD_LOGIC_VECTOR(3 downto 0));
end sevenSegmentDisplay;

architecture Behavioral of sevenSegmentDisplay is


signal flip: STD_LOGIC := '1';
signal counter : STD_LOGIC_VECTOR(19 downto 0) := "00000000000000000000";
signal digit: STD_LOGIC_VECTOR(3 downto 0);

begin

process(sysclock) 
	
		begin
			if (sysclock'event and sysclock = '1') then
				counter <= counter + 1;
			end if;
		end process;

process(Digits, counter, digit) 
	begin 
		case counter(19 downto 18) is
			 when       "00" => anodes <= "1110"; digit <= digits(3 downto 0);
			 when       "01" => anodes <= "1101"; digit <= digits(7 downto 4);
			 when       "10" => anodes <= "1011"; digit <= digits(11 downto 8);
			 when       "11" => anodes <= "0111"; digit <= digits(15 downto 12);
			 when 		others => anodes <= "0110";
		end case;
				
		case digit is
			 when       "0000" => sevenSegs <= "00000011";
			 when       "0001" => sevenSegs <= "10011111";
			 when       "0010" => sevenSegs <= "00100101";
			 when       "0011" => sevenSegs <= "00001101";
			 when       "0100" => sevenSegs <= "10011001";
			 when       "0101" => sevenSegs <= "01001001";
			 when       "0110" => sevenSegs <= "01000001";
			 when       "0111" => sevenSegs <= "00011111";
			 when       "1000" => sevenSegs <= "00000001";
			 when       "1001" => sevenSegs <= "00011001";
			 when       "1010" => sevenSegs <= "00010001";
			 when       "1011" => sevenSegs <= "11000001";
			 when       "1100" => sevenSegs <= "01100011";
			 when       "1101" => sevenSegs <= "10000101";
			 when       "1110" => sevenSegs <= "01100001";
			 when       "1111" => sevenSegs <= "01110001";
			 when 		others => sevenSegs <= "01101111";
		end case;
  
  end process;	
  
end Behavioral;

