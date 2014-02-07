----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:56:43 11/01/2009 
-- Design Name: 
-- Module Name:    RegisterFile - Behavioral 
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


entity RegisterFile is -- three-port register file

	generic(datapath_size : integer);
  port(clk:           in  STD_LOGIC;
       we3:           in  STD_LOGIC;
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR(4 downto 0);
       wd3:           in  STD_LOGIC_VECTOR(datapath_size - 1 downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR(datapath_size - 1 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is

  type ramtype is array (31 downto 0) of STD_LOGIC_VECTOR(datapath_size - 1 downto 0);
  signal regfile: ramtype;
  
begin
  -- three-ported register file
  -- read two ports combinationally
  -- write third port on rising edge of clock
  process(clk) begin
    if (clk'event and clk = '1') then
       if we3 = '1' then regfile(to_INTEGER(unsigned(wa3))) <= wd3;
       end if;
    end if;
  end process;

  rd1 <= std_logic_vector(to_unsigned(0,datapath_size)) when (to_integer(unsigned(ra1)) = 0) -- register 0 holds 0
         else regfile(to_INTEGER(unsigned(ra1)));
  rd2 <= std_logic_vector(to_unsigned(0,datapath_size)) when (to_integer(unsigned(ra2)) = 0) -- register 0 holds 0
         else regfile(to_INTEGER(unsigned(ra2)));

end;

