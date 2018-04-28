----------------------------------------------------------------------------------
-- Author: Owen Lu
-- Description: Debounces button presses and outputs a pulse for a single clock cycle
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity button_pulse is Port (
	--clock
	clk : in std_logic;
	--push button
	btn : in std_logic;
	--output pulse (1 clock cycle)
	pulse : out std_logic);
end button_pulse;

architecture Behavioral of button_pulse is
	signal counter : unsigned(19 downto 0);
	signal armed : std_logic;
	signal p : std_logic;
begin
	
	process (clk, btn, armed, counter, p) begin
		if rising_edge(clk) then
			if (btn = '0') then
				--reset counter and enable output
				counter <= x"00000";
				armed <= '1';
			else
				--increment counter while button is pressed
				counter <= counter + 1;
			end if;
			
			if (p = '1') then
				--limit output to one clock cycle
				p <= '0';
			elsif (armed = '1' and counter = x"FFFFF") then
				--output a pulse if the counter reaches maximum
				p <= '1';
				--disable output until the button is released
				armed <= '0';
			end if;
		end if;
	end process;
	
	pulse <= p;
	
end Behavioral;
