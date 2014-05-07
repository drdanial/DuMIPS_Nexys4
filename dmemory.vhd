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
		
		-- ports that connect to 7 segment display anodes and cathodes.
		segments : out std_logic_vector(0 to 7);      -- 8th bit is decimal point
		anodes   : out std_logic_vector(7 downto 0);  -- for each of the eight digits
		-- I/O ports to the processor follow here
		digOut0 : out std_logic_vector(15 downto 0);  -- 16 LEDs on Nexys4
		-- go to slide switches on Nexys4
		digIn0 : in std_logic_vector(15 downto 0); 
		-- buttons on Nexys4 plus whatever else we want to connect it to. 
		digIn1 : in std_logic_vector(15 downto 0);
		phi2,reset: in std_logic);

end dmemory;



architecture behavior of dmemory is

-- components:
	component IO_Module is
		generic (
			datapath_size : integer;
			word_size : integer);
		Port ( clk		 : in STD_LOGIC;
				 reset    : in STD_LOGIC;
				 enable   : in STD_LOGIC;
				 io_addr  : in STD_LOGIC_VECTOR(datapath_size - 1 downto 0);
			    dataWrite   : in STD_LOGIC_VECTOR(15 downto 0);  -- values to display locations
				 dataRead  : out STD_LOGIC_VECTOR(15 downto 0); -- values from inputs to processor
			  -- physical I/O connections
				 leds	  : out STD_LOGIC_VECTOR(15 downto 0);
			    switches : in STD_LOGIC_VECTOR(15 downto 0);
			    buttons  : in STD_LOGIC_VECTOR(15 downto 0);
			    segments : out  STD_LOGIC_VECTOR(0 to 7);  -- 8th bit is decimal point
			    anodes   : out  STD_LOGIC_VECTOR(7 downto 0);
			    sysclock : in  STD_LOGIC);
	end component;
	
	component Debouncer is
		Port ( btn_in : in STD_LOGIC;
				 clk : in STD_LOGIC;
				 db_btn : out STD_LOGIC);
		end component;

	-- internal signals. 
	signal mux : std_logic_vector(datapath_size - 1 downto 0);
	signal io_enable : std_logic;
	signal iovalue : std_logic_vector(datapath_size - 1 downto 0);
	signal port1 : std_logic_vector(15 downto 0);  -- signal to hold value output to seven segment LEDs
	signal pcounter : std_logic_vector(15 downto 0);
	 
	signal memoryReadData : std_logic_vector(datapath_size - 1 downto 0);
	signal ioReadData : std_logic_vector(datapath_size - 1 downto 0);

	type memory_array is array (0 to 2**dmem_size - 1) of std_logic_vector(datapath_size - 1 downto 0);
	signal mem : memory_array ; --:= (Shouldn't need to initialize RAM.
	signal up, down : std_logic;

begin

	-- component instantiation

	ioport0:  IO_Module
	generic map (
			datapath_size => datapath_size,
			word_size => word_size)
	Port map ( clk  => phi2,
				  reset => reset,
				  enable => io_enable,
				  io_addr => wadd_bus,
				  dataRead => ioReadData,
				  dataWrite => wd_bus,
				  -- physical I/O connections
				  leds	 => digOut0,
			     switches => digIn0,
			     buttons => digIn1,
				  segments => segments,
				  anodes => anodes,
				  sysclock => phi2);		-- get data from io pins if io read is taking place
				  
	
	-- signals used to handle a read from an I/O port rather than memory. 
				  
	io_enable <= '1' WHEN (wadd_bus(15 downto 8) = X"C0") ELSE '0';
	-- choose port 0 or port 1 to read
	
	-- Read Data Memory
	mux <= mem(conv_integer(ra_bus(dmem_size - 1 downto 0)))
	WHEN (io_enable = '0') ELSE ioReadData;
		
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
--				elsif Memwrite = '1' and wadd_bus(datapath_size - 1 downto datapath_size - 2) = "11" then  
--						-- write to an output port
--					if wadd_bus(3 downto 0) = "1000" then  --- address 0xC008 is LEDS
--						port0 <= wd_bus(7 downto 0);
--					elsif wadd_bus(3 downto 0) = "1100" then  --- address 0xC00C is Seven Segment Display
--						port1 <= wd_bus(15 downto 0);
--					end if;  -- Can add more here if we get a new output port. 
				end if;
			end if;
		end if;
		end process;

end behavior;

