--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:18:16 03/07/2014
-- Design Name:   
-- Module Name:   C:/Users/Danial.Neebel/Documents/XilinxProjects/DuMIPSN4a/DMTB.vhd
-- Project Name:  DuMIPSN4a
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DuMIPS
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY DMTB IS
END DMTB;
 
ARCHITECTURE behavior OF DMTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DuMIPS
    PORT(
         reset_in : IN  std_logic;
         sys_clk : IN  std_logic;
         switchin : IN  std_logic_vector(15 downto 0);
         leds : OUT  std_logic_vector(15 downto 0);
         buttons : IN  std_logic_vector(15 downto 0);
         anodes : OUT  std_logic_vector(7 downto 0);
         segments : OUT  std_logic_vector(0 to 7)
        );
    END COMPONENT;
    

   --Inputs
   signal reset_in : std_logic := '0';
   signal sys_clk : std_logic := '0';
   signal switchin : std_logic_vector(15 downto 0) := (others => '0');
   signal buttons : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal leds : std_logic_vector(15 downto 0);
   signal anodes : std_logic_vector(7 downto 0);
   signal segments : std_logic_vector(0 to 7);

   -- Clock period definitions
   constant sys_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DuMIPS PORT MAP (
          reset_in => reset_in,
          sys_clk => sys_clk,
          switchin => switchin,
          leds => leds,
          buttons => buttons,
          anodes => anodes,
          segments => segments
        );

   -- Clock process definitions
   sys_clk_process :process
   begin
		sys_clk <= '0';
		wait for sys_clk_period/2;
		sys_clk <= '1';
		wait for sys_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		reset_in <= '0';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset_in <= '1';
--
      wait for sys_clk_period*10;
--		
		switchin <= X"00AA";
--		buttons <= X"B0B0";
--
--      -- insert stimulus here 
      wait for sys_clk_period*20;
--		

      wait;
   end process;

END;
