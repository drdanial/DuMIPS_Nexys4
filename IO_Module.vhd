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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IO_Module is
	 generic (
		datapath_size : integer;
		word_size : integer);
    Port ( clk		  : in STD_LOGIC;
			  reset    : in STD_LOGIC;
			  io_addr  : in STD_LOGIC_VECTOR(15 downto 0);
			  dataWrite	  : in STD_LOGIC_VECTOR(15 downto 0);  -- values to display on a peripheral
			  dataRead  : out STD_LOGIC_VECTOR(15 downto 0);  -- values read from peripheral
			  -- physical I/O connections
			  leds	  : out STD_LOGIC_VECTOR(15 downto 0);
			  switches : in STD_LOGIC_VECTOR(15 downto 0);
			  buttons  : in STD_LOGIC_VECTOR(15 downto 0);
			  segments : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
           anodes   : out  STD_LOGIC_VECTOR(7 downto 0);
			  
           sysclock : in  STD_LOGIC);
end IO_Module;

architecture Behavioral of IO_Module is


-- seven segment decoder (may need modification for Nexsys 2)

component sevenSegmentDisplay is
    Port ( Digits : in  STD_LOGIC_VECTOR (31 downto 0);
			  sysclock : in STD_LOGIC;
           sevenSegs : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
           anodes : out  STD_LOGIC_VECTOR(7 downto 0));
end component sevenSegmentDisplay;

-- a simple binary up/down counter
component counter is
    Port ( clock       : in std_logic;  -- 50 MHz clock
			  reset			: in std_logic; -- set counter to zero
			  increment    : in std_logic;  -- count up
       	  decrement    : in std_logic;  -- count down
			  pcounter     : out std_logic_vector(15 downto 0)); -- 16 bit counter
end component counter;

	component Debouncer is
		Port ( btn_in : in STD_LOGIC;
				 clk : in STD_LOGIC;
				 db_btn : out STD_LOGIC);
		end component;


-- internal signals
	signal up, down : STD_LOGIC;
	signal io_enable : STD_LOGIC;
	signal counterValue : STD_LOGIC_VECTOR(15 downto 0);
	signal sevenSegmentValue : STD_LOGIC_VECTOR(31 downto 0);
	


begin

  
theCounter: component counter
    Port map ( clock   => sysclock, 
       	 increment   => up,    -- count up one
       	 decrement   => down,  -- count down one
			 reset		=>  reset,  -- reset counter to zero
			 pcounter   =>	  counterValue); -- 16 bit counter 

	

display: component sevenSegmentDisplay 
    Port map (Digits => sevenSegmentValue,
			  sysclock => sysclock,
           sevenSegs => segments,
           anodes => anodes);

	-- Set counter to  count up on Button Upper and down on Button Lower. 
	-- mapping for counter up/down
	debounce1: Debouncer
		Port map ( btn_in => buttons(4),
					  clk => clk,
					  db_btn => up);
	
	
	debounce2: Debouncer
		Port map ( btn_in => buttons(2),
					  clk => clk,
					  db_btn => down);
	
			  
	-- all 16 switches
	-- all 6 buttons (plus any other inputs).

	io_enable <= '1' WHEN io_addr(datapath_size - 1 downto datapath_size - 8) = X"C0"
				ELSE '0';
	
	
	-- MUX to get proper data input given lower 8 bits of address
	
	dataRead <= switches			 		WHEN io_addr(7 downto 0) = X"00"  -- read from digital switches 0xC000
			ELSE buttons					WHEN io_addr(7 downto 0) = X"04"  -- read from buttons 0xC004
			ELSE counterValue				WHEN io_addr(7 downto 0) = X"08"  -- read from counter 0xC008
			ELSE "1111100000000001" ;  -- this line needs modifying if datapath_size changes 
	
	--DJN: need to fix this so that the output is enabled at the proper time.  Input can
	--always happen and will be muxed out at one level up.  

	PROCESS(io_enable)
	BEGIN
		if (io_enable'event) and (io_enable = '1') then
		-- here we write to one of the following connections.  
	-- upper four digits of seven-seg display
	-- lower four digits of seven-seg display
	-- all 16 LEDs at once.			
			case io_addr(7 downto 0) is 
				when X"80" => leds <= dataWrite;
			   when X"84" => sevenSegmentValue(15 downto 0) <= dataWrite;
				when X"88" => sevenSegmentValue(31 downto 16) <= dataWrite;
				when others => null ;
			end case;
						

			
		end if;
	END PROCESS;
		

		
end Behavioral;

