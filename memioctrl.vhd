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

entity memioctrl is
	generic (
		datapath_size : integer;
		word_size : integer;
		dmem_size : integer
		);

   port(
		rd_bus : out std_logic_vector(datapath_size - 1 downto 0);
		wd_bus : in std_logic_vector(datapath_size - 1 downto 0);
		add_bus : in std_logic_vector(datapath_size - 1 downto 0);
		MemRead, MemWrite, MemtoReg : in std_logic;

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

end memioctrl;



architecture behavior of memioctrl is

-- components:
------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT data_mem
  PORT (
    clka : IN STD_LOGIC;
	 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------


	component IO_Module is
		generic (
			datapath_size : integer;
			word_size : integer);
		Port ( up       : in  STD_LOGIC;
				 down     : in  STD_LOGIC;
			    RESET    : in STD_LOGIC;
				 io_addr  : in STD_LOGIC_VECTOR(datapath_size - 1 downto 0);
			    dataIn   : in STD_LOGIC_VECTOR(15 downto 0);  -- values from inputs to processor
				 dataOut  : out STD_LOGIC_VECTOR(15 downto 0); -- values to display locations
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
	signal ioread : std_logic;
	signal iovalue : std_logic_vector(datapath_size - 1 downto 0);
	signal port1 : std_logic_vector(15 downto 0);  -- signal to hold value output to seven segment LEDs
	signal pcounter : std_logic_vector(15 downto 0);
	 
--	type memory_array is array (0 to 2**dmem_size - 1) of std_logic_vector(datapath_size - 1 downto 0);
--	signal mem : memory_array ; --:= (Shouldn't need to initialize RAM.
	signal up, down : std_logic;

	signal address : std_logic_vector(datapath_size - 1 downto 0);
	signal read_data : std_logic_vector(datapath_size - 1 downto 0);
	signal io_enable : std_logic;
	signal write_enable : std_logic_vector(0 downto 0);  -- generated RAM has this type
	signal mem_enable : std_logic;
	
begin

	-- component instantiation

------------- From the INSTANTIATION Template ----- INST_TAG
	Data_RAM : data_mem
	PORT MAP (clka => phi2,
             wea => write_enable,
             addra => add_bus(7 downto 0),
             dina => wd_bus,
             douta => read_data);
	 
-- INST_TAG_END ------ End INSTANTIATION Template ------------


	ioport0:  IO_Module
	generic map (
			datapath_size => datapath_size,
			word_size => word_size)
	Port map ( up => up,
			     down => down,
				  --  need to map reset here
				  reset => reset,
				  io_addr => add_bus,
				  dataIn => wd_bus,
				  dataOut => iovalue,
				  -- physical I/O connections
				  leds	 => digOut0,
			     switches => digIn0,
			     buttons => digIn1,
				  segments => segments,
				  anodes => anodes,
				  sysclock => phi2);		-- get data from io pins if io read is taking place
				  
	-- Set counter to  count up on Button 1 and down on Button 2. 
	debounce1: Debouncer
		Port map ( btn_in => digIn1(0),
					  clk => phi2,
					  db_btn => up);
	
	
	debounce2: Debouncer
		Port map ( btn_in => digIn1(1),
					  clk => phi2,
					  db_btn => down);
	
	-- Logic used to handle a read from an I/O port rather than memory. 
	-- I/0 memory locations are all at 0xC0XX
   -- need signals for data output bus to MUX between memory, IO, and Regsiter file.  
	
	io_enable <= '1' WHEN (add_bus(15 downto 0) = X"C0") ELSE '0';
	mem_enable <= '1' WHEN (io_enable = '0') and ((MemRead or MemWrite) = '1') ELSE '0';
	write_enable <= "1" WHEN ((MemWrite = '1') and (io_enable = '0')) ELSE "0";

	
	-- MUX to feed proper data from Memory, Register file, or I/O back to register file
	mux 	<= 	read_data 	WHEN ((io_enable = '0') and (MemtoReg = '0')) 
			ELSE 	add_bus  	WHEN ((io_enable = '0') and (MemtoReg = '0'))
			ELSE 	iovalue 		WHEN  (io_enable = '1')
			ELSE 	(conv_std_logic_vector(-1,datapath_size));

end behavior;
