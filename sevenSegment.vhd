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
    Port ( Digits : in  STD_LOGIC_VECTOR (31 downto 0);
			  sysclock : in STD_LOGIC;
           sevenSegs : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
           anodes    : out  STD_LOGIC_VECTOR(7 downto 0));
end sevenSegmentDisplay;

architecture Behavioral of sevenSegmentDisplay is

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
		case counter(20 downto 18) is
			 when       "000" => anodes <= "11111110"; digit <= digits(3 downto 0);
			 when       "001" => anodes <= "11111101"; digit <= digits(7 downto 4);
			 when       "010" => anodes <= "11111011"; digit <= digits(11 downto 8);
			 when       "011" => anodes <= "11110111"; digit <= digits(15 downto 12);
			 when       "100" => anodes <= "11101111"; digit <= digits(19 downto 16);
			 when       "101" => anodes <= "11011111"; digit <= digits(23 downto 20);
			 when       "110" => anodes <= "10111111"; digit <= digits(27 downto 24);
			 when       "111" => anodes <= "01111111"; digit <= digits(31 downto 28);
			 when 		others => anodes <= "01100110";
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

