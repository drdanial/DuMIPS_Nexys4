----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:51:21 11/23/2010 
-- Design Name: 
-- Module Name:    shifter - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shifter is
		generic (
				datapath_size : integer;
				word_size : integer
			);
    Port ( dataIn : in  STD_LOGIC_VECTOR (datapath_size-1 downto 0);
           dataOut : out  STD_LOGIC_VECTOR (datapath_size-1 downto 0);
           shamt : in  STD_LOGIC_VECTOR (4 downto 0);
			  ALUctl : in STD_LOGIC_VECTOR (4 downto 0));
end shifter;

architecture Behavioral of shifter is

   signal leftShiftValue, rightShiftLogicalValue, 
			 rightShiftArithValue : std_logic_vector(datapath_size-1 downto 0);
	
begin

	leftShiftValue <= std_logic_vector(shift_left(unsigned(dataIn), to_integer(unsigned(shamt))));
	
--	with shamt select       
--		leftShiftValue <= 	dataIn       when "00000",
--						dataIn(datapath_size - 2 downto 0) & conv_std_logic_vector(0,1) when "00001",    
--						dataIn(datapath_size - 3 downto 0) & conv_std_logic_vector(0,2) when "00010",    
--						dataIn(datapath_size - 4 downto 0) & conv_std_logic_vector(0,3) when "00011",    
--						dataIn(datapath_size - 5 downto 0) & conv_std_logic_vector(0,4) when "00100",    
--						dataIn(datapath_size - 6 downto 0) & conv_std_logic_vector(0,5) when "00101",    
--						dataIn(datapath_size - 7 downto 0) & conv_std_logic_vector(0,6) when "00110",    
--						dataIn(datapath_size - 8 downto 0) & conv_std_logic_vector(0,7) when "00111",    
--						dataIn(datapath_size - 9 downto 0) & conv_std_logic_vector(0,8) when "01000",    
--						dataIn(datapath_size - 10 downto 0) & conv_std_logic_vector(0,9) when "01001",    
--						dataIn(datapath_size - 11 downto 0) & conv_std_logic_vector(0,10) when "01010",    
--						dataIn(datapath_size - 12 downto 0) & conv_std_logic_vector(0,11) when "01011",    
--						dataIn(datapath_size - 13 downto 0) & conv_std_logic_vector(0,12) when "01100",    
--						dataIn(datapath_size - 14 downto 0) & conv_std_logic_vector(0,13) when "01101",    
--						dataIn(datapath_size - 15 downto 0) & conv_std_logic_vector(0,14) when "01110",    
--						dataIn(datapath_size - 16 downto 0) & conv_std_logic_vector(0,15) when "01111",    
--						dataIn when others;    

	rightShiftLogicalValue <= std_logic_vector(shift_right(unsigned(dataIn), to_integer(unsigned(shamt))));
	
--	with shamt select       
--		rightShiftLogicalValue <= 	dataIn       when "00000",
--						conv_std_logic_vector(0,1) & dataIn(datapath_size - 1 downto 1) when "00001",    
--						conv_std_logic_vector(0,2) & dataIn(datapath_size - 1 downto 2) when "00010",    
--						conv_std_logic_vector(0,3) & dataIn(datapath_size - 1 downto 3) when "00011",    
--						conv_std_logic_vector(0,4) & dataIn(datapath_size - 1 downto 4) when "00100",    
--						conv_std_logic_vector(0,5) & dataIn(datapath_size - 1 downto 5) when "00101",    
--						conv_std_logic_vector(0,6) & dataIn(datapath_size - 1 downto 6) when "00110",    
--						conv_std_logic_vector(0,7) & dataIn(datapath_size - 1 downto 7) when "00111",    
--						conv_std_logic_vector(0,8) & dataIn(datapath_size - 1 downto 8) when "01000",    
--						conv_std_logic_vector(0,9) & dataIn(datapath_size - 1 downto 9) when "01001",    
--						conv_std_logic_vector(0,10) & dataIn(datapath_size - 1 downto 10) when "01010",    
--						conv_std_logic_vector(0,11) & dataIn(datapath_size - 1 downto 11) when "01011",    
--						conv_std_logic_vector(0,12) & dataIn(datapath_size - 1 downto 12) when "01100",    
--						conv_std_logic_vector(0,13) & dataIn(datapath_size - 1 downto 13) when "01101",    
--						conv_std_logic_vector(0,14) & dataIn(datapath_size - 1 downto 14) when "01110",    
--						conv_std_logic_vector(0,15) & dataIn(datapath_size - 1 downto 15) when "01111",    
--						dataIn when others;   
--	

	rightShiftArithValue <= std_logic_vector(shift_right(unsigned(dataIn), to_integer(unsigned(shamt))));

					
--	with shamt select       
--		rightShiftArithValue <= 	dataIn       when "00000",
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),1) & dataIn(datapath_size - 1 downto 1) when "00001",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),2) & dataIn(datapath_size - 1 downto 2) when "00010",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),3) & dataIn(datapath_size - 1 downto 3) when "00011",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),4) & dataIn(datapath_size - 1 downto 4) when "00100",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),5) & dataIn(datapath_size - 1 downto 5) when "00101",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),6) & dataIn(datapath_size - 1 downto 6) when "00110",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),7) & dataIn(datapath_size - 1 downto 7) when "00111",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),8) & dataIn(datapath_size - 1 downto 8) when "01000",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),9) & dataIn(datapath_size - 1 downto 9) when "01001",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),10) & dataIn(datapath_size - 1 downto 10) when "01010",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),11) & dataIn(datapath_size - 1 downto 11) when "01011",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),12) & dataIn(datapath_size - 1 downto 12) when "01100",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),13) & dataIn(datapath_size - 1 downto 13) when "01101",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),14) & dataIn(datapath_size - 1 downto 14) when "01110",    
--						conv_std_logic_vector(conv_integer(dataIn(datapath_size-1)),15) & dataIn(datapath_size - 1 downto 15) when "01111",    
--						dataIn when others;   
						
	with ALUctl select 
		dataOut <= leftShiftValue when "10000",
					  dataIn when "10001",
				     rightShiftLogicalValue when "10010",
				     rightShiftArithValue when "10011",
				     dataIn when others;
				  
										
end Behavioral;

