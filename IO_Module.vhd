----------------------------------------------------------------------------------
-- Company: Loras College
-- Engineer: Danial J. Neebel
-- 
-- Create Date:    08:12:24 09/22/2009 
-- Design Name: DuMIPS i/o block 
-- Project Name: DuMIPS
-- Target Devices: xc3s500e
-- Tool versions: ISE 12.2
-- Description: Provides the following input and output:
-- 		8 switches, 4 pushbuttons
--			A 16-bit counter
--			8 LEDs
--			Seven Segment dispay board		
--
-- Dependencies: 
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

entity IO_Module is
    Port ( up       : in STD_LOGIC;
	        down     : in STD_LOGIC;
			  reset    : in STD_LOGIC;
			  hexValue : in STD_LOGIC_VECTOR(15 downto 0);
			  pcounter : out STD_LOGIC_VECTOR(15 downto 0); 
			  segments : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
           anodes   : out  STD_LOGIC_VECTOR(3 downto 0);
           sysclock : in  STD_LOGIC);
end IO_Module;

architecture Behavioral of IO_Module is


-- seven segment decoder (may need modification for Nexsys 2)

component sevenSegmentDisplay is
    Port ( Digits : in  STD_LOGIC_VECTOR (15 downto 0);
			  sysclock : in STD_LOGIC;
           sevenSegs : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
           anodes : out  STD_LOGIC_VECTOR(3 downto 0));
end component sevenSegmentDisplay;

-- a simple binary up/down counter
component counter is
    Port ( clock       : in std_logic;  -- 50 MHz clock
			  reset			: in std_logic; -- set counter to zero
			  increment    : in std_logic;  -- count up
       	  decrement    : in std_logic;  -- count down
			  pcounter     : out std_logic_vector(15 downto 0)); -- 16 bit counter
end component counter;

-- add debounce module here.
component Debouncer is
	  Port ( btn_in : in STD_LOGIC;
				clk : in STD_LOGIC;
				db_btn : out STD_LOGIC);
end component Debouncer;

-- internal signals
--signal up, down : STD_LOGIC;


begin

  
theCounter: component counter
    Port map ( clock   => sysclock, 
       	 increment   => up,    -- count up one
       	 decrement   => down,  -- count down one
			 reset		=>  reset,  -- reset counter to zero
			 pcounter   =>	  pcounter); -- 16 bit counter 

	

display: component sevenSegmentDisplay 
    Port map (Digits(15 downto 0) => hexValue(15 downto 0),
			  sysclock => sysclock,
           sevenSegs => segments,
           anodes => anodes);


		
end Behavioral;

