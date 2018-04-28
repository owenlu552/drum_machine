----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- Outputs a pulse after a given number of clock cycles. Modified from code given in lecture.
--
----------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pulseGenerator is port(
	--Clock
	clk : in std_logic;
	--Asynchronous reset
	reset : in std_logic;
	--Clock division factor (increased to 28 bits)
	MaxCounter : in unsigned(27 downto 0);
	--Output pulse active for one clock cycle at a time
	Pulse : out std_logic);
end pulseGenerator ;

architecture behavioral of pulseGenerator is
	signal cntr : unsigned(27 downto 0);
	signal syncReset : std_logic;
begin
	
	--Sequential logic
	process(clk, reset) begin
		if(reset = '1') then
			cntr <= (others => '0');
		elsif (rising_edge(clk)) then
			if(syncReset = '1') then
				cntr <= (others => '0');
			else
				cntr <= cntr + 1;
			end if;
		end if;
	end process;
	
	--Reset counter when max value is reached
	syncReset <= '1' when (cntr = MaxCounter) else '0';
	
	Pulse <= syncReset;

end behavioral;

