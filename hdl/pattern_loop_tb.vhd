----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2018 04:24:32 PM
-- Design Name: 
-- Module Name: pattern_loop_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

use work.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pattern_loop_tb is
--  Port ( );
end pattern_loop_tb;

architecture Behavioral of pattern_loop_tb is
	signal clk : std_logic;
	signal rst : std_logic;
	signal pattern : std_logic_vector(15 downto 0);
	signal beat : unsigned(15 downto 0);
	signal pulse_out : std_logic;
	signal count : unsigned(3 downto 0);
begin

dut : entity pattern_loop port map (
	clk => clk,
	rst => rst,
	pattern => pattern,
	beat => beat,
	pulse_out => pulse_out
	);
	
process begin
	clk<= '0';
	wait for 5ns;
	clk <= '1';
	wait for 5ns;
end process;

process (clk) begin
	if rising_edge(clk) then
		if rst = '1' then
			count <= x"0";
		else
			count <= count + 1;
		end if;
		
		if rst = '1' then
			beat <= x"0001";
		elsif count = x"0" then
			beat <= beat rol 1;
		end if;
	end if;
end process;
	
pattern <= x"421F";

process begin
	rst <= '1';
	wait for 20 ns;
	rst <= '0';
	wait;
end process;


end Behavioral;
