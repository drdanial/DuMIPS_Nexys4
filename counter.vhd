------------------------------------------------------------------------
--   Author:  Dan Neebel
------------------------------------------------------------------------
--
-- This project is compatible with Xilinx ISE or Xilinx WebPack tools.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
    Port ( clock       : in std_logic;  -- 50 MHz clock
			  reset		  : in std_logic;  -- set counter to zero
       	  increment   : in std_logic;  -- count up
       	  decrement    : in std_logic;  -- count down
			  pcounter     : out std_logic_vector(15 downto 0)); -- 16 bit counter


end counter;

architecture Behavioral of counter is

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------

	 signal the_counter	: std_logic_vector(15 downto 0);
	 signal old_incr : STD_LOGIC := '0';
	 signal old_decr : STD_LOGIC := '0';

------------------------------------------------------------------------
-- Module Implementation - Binary Counter
------------------------------------------------------------------------

begin


-- Divide the clock to produce various timing signals
    process (clock)     
    begin
      if clock'Event and clock = '1' then 
			-- on a clock event sample the left and right buttons
			-- if it has gone from 0 to 1 then increment the counter
			if (reset = '1') then
				the_counter <= "0000000000000000";
			else 
				if (increment = '1') AND (old_incr = '0') then
					the_counter <= the_counter + 1;			end if;

					-- if the left button has gone from 0 to 1 decrement the counter
				if (decrement = '1') AND (old_decr = '0') then
					the_counter <= the_counter - 1;

				end if;
			end if;

			old_incr <= increment;
			old_decr <= decrement;
		end if;
    end process;

-- output the counter all the time. 
	pcounter <= the_counter;
	
end Behavioral;

