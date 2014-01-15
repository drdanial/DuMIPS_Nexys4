--
-- I/O
-- 		Address		Port contents
--			-------     --------------
--			0xC000		Switches and push buttons(LSB)
-- 		0xC004		Counter (16-bit)
--			0xC008		8 LEDs  (output only)
--			0xC00C		4-digit Seven Segment display 

-- DMEMORY module (provides the data memory for the SPIM computer)
library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

entity dmemory is
	generic (
		datapath_size : integer;
		word_size : integer;
		dmem_size : integer
		);

   port(
		rd_bus : out std_logic_vector(datapath_size - 1 downto 0);
		ra_bus : in std_logic_vector(datapath_size - 1 downto 0);
		wd_bus : in std_logic_vector(datapath_size - 1 downto 0);
		wadd_bus : in std_logic_vector(datapath_size - 1 downto 0);
		MemRead, Memwrite, MemtoReg : in std_logic;
		
		-- seven segment LED display outputs
		segments : out std_logic_vector(0 to 7);  -- 8th bit is decimal point
		anodes   : out std_logic_vector(3 downto 0);  -- for each of the four digits

		-- I/O ports to the processor follow here
		port0 : out std_logic_vector(7 downto 0);  -- 8 LEDs. 

		-- digin(11 downto 8) go to push buttons
		-- digin(7 downto 0) go to slide switches
		digin : in std_logic_vector(10 downto 0);  
		phi2,reset: in std_logic);

end dmemory;



architecture behavior of dmemory is

-- components:
	component IO_Module is
		Port ( up       : in  STD_LOGIC;
				 down     : in  STD_LOGIC;
			    RESET    : in STD_LOGIC;
			    hexValue : in STD_LOGIC_VECTOR(15 downto 0);  -- values on switches and pushbuttons
				 pcounter : out STD_LOGIC_VECTOR(15 downto 0); -- 16 bit counter
			    segments : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
			    anodes   : out  STD_LOGIC_VECTOR(3 downto 0);
			    sysclock : in  STD_LOGIC);
	end component;
	
	component Debouncer is
		Port ( btn_in : in STD_LOGIC;
				 clk : in STD_LOGIC;
				 db_btn : out STD_LOGIC);
		end component;

	-- internal signals. 
	signal mux : std_logic_vector(datapath_size - 1 downto 0);
	signal ioread : std_logic;
	signal iovalue : std_logic_vector(datapath_size - 1 downto 0);
	signal port1 : std_logic_vector(15 downto 0);  -- signal to hold value output to seven segment LEDs
	signal pcounter : std_logic_vector(15 downto 0);
	 
	type memory_array is array (0 to 2**dmem_size - 1) of std_logic_vector(datapath_size - 1 downto 0);
	signal mem : memory_array ; --:= (Shouldn't need to initialize RAM.
	signal up, down : std_logic;

begin

	-- component instantiation

	ioport0:  IO_Module
	Port map ( up => up,
			     down => down,
				--  need to map reset here
				  reset => reset,
				  hexValue => port1,
				  pcounter => pcounter,
				  segments => segments,
				  anodes => anodes,
				  sysclock => phi2);		-- get data from io pins if io read is taking place
				  
	-- Set counter to  count up on Button 1 and down on Button 2. 
	debounce1: Debouncer
		Port map ( btn_in => digin(9),
					  clk => phi2,
					  db_btn => up);
	
	
	debounce2: Debouncer
		Port map ( btn_in => digin(10),
					  clk => phi2,
					  db_btn => down);
	
	

	
	-- signals used to handle a read from an I/O port rather than memory. 
				  
	ioread <= ra_bus(datapath_size - 1) AND ra_bus(datapath_size - 2);
	-- choose port 0 or port 1 to read
	
	iovalue <= "00000" & digin WHEN ra_bus(3 downto 0) = "0000"  -- read from digital switches and pushbuttons  0xC000 is switches and pushbuttons
			ELSE pcounter   WHEN ra_bus(3 downto 0) = "0100"  -- read from counter 
			ELSE "1111100000000001" ;  -- this line needs modifying if datapath_size changes 
	
	-- Read Data Memory
	mux <= mem(conv_integer(ra_bus(dmem_size - 1 downto 0)))
	WHEN (ioread = '0') ELSE iovalue;
		
	-- Mux to skip data memory for Rformat instructions
	rd_bus <= ra_bus(datapath_size - 1 downto 0) WHEN (MemtoReg = '0') ELSE 
				 mux 											WHEN (MemRead = '1') ELSE 
				 (conv_std_logic_vector(-1,datapath_size));

	-- The following process code handles reset and memory and output write operations. 
	-- Note that memory writes and output writes take place on the clock edge.  
	
	process(phi2)
		begin   
		if phi2'event and phi2='1' then
			if (reset = '1') then
				  mem(0) <= conv_std_logic_vector(55,datapath_size);  -- we set these values just so we can see that a reset has occurred. 
				  mem(1) <= conv_std_logic_vector(175,datapath_size);  
			else
				if Memwrite= '1' and wadd_bus(datapath_size - 1 downto datapath_size - 2) = "00" then 	-- Write to data memory?
					mem(conv_integer(wadd_bus(dmem_size - 1 downto 0))) <= wd_bus;
				elsif Memwrite = '1' and wadd_bus(datapath_size - 1 downto datapath_size - 2) = "11" then  
						-- write to an output port
					if wadd_bus(3 downto 0) = "1000" then  --- address 0xC008 is LEDS
						port0 <= wd_bus(7 downto 0);
					elsif wadd_bus(3 downto 0) = "1100" then  --- address 0xC00C is Seven Segment Display
						port1 <= wd_bus(15 downto 0);
					end if;  -- Can add more here if we get a new output port. 
				end if;
			end if;
		end if;
		end process;

end behavior;

