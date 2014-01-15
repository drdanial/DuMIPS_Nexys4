----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:22:25 09/22/2009 
-- Design Name: 
-- Module Name:    debounce - Behavioral 
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

entity Debouncer is
	Port ( btn_in : in STD_LOGIC;
		clk : in STD_LOGIC;
		db_btn : out STD_LOGIC);
	end Debouncer;

architecture Behavioral of Debouncer is

	signal counter: STD_LOGIC_VECTOR (12 downto 0) := "0000000000000";
	signal btn_save: STD_LOGIC;

	begin
		process(clk, btn_in)
			begin
			if (clk'event AND clk='1') then
				if (btn_in /= btn_save) then
					btn_save <= btn_in;
					counter <= "0000000000000";
				end if;
				counter <= counter + 1;
				if (counter = "1111111111111") then
					db_btn <= btn_save;
				end if;
			end if;
		end process;
end Behavioral;



