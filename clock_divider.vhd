----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:06:08 03/10/2014 
-- Design Name: 
-- Module Name:    clock_divider - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_divider is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           nreset : out  STD_LOGIC;
           clk_div : out  STD_LOGIC);
end clock_divider;

architecture Behavioral of clock_divider is

signal phi2 : std_logic;
begin

	process(clk, phi2) 
	begin
	if (clk'event and clk = '1') then
		phi2 <= not phi2;
	end if;
	clk_div <= phi2;
	
	end process;
	
	nreset <= not reset;
	
end Behavioral;

