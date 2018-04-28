----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- Generates pulses to activate the instrument with timing based on the input pattern and 
--
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

entity pattern_loop is Port (
	clk : in std_logic;
	rst : in std_logic;
	--Rhythm pattern
	pattern : in std_logic_vector(15 downto 0);
	--Current loop position (one-hot encoding)
	beat : in unsigned(15 downto 0);
	--Output
	pulse_out : out std_logic
	);
end pattern_loop;

architecture Behavioral of pattern_loop is
	signal beat_q : unsigned(15 downto 0);
	signal pulse : std_logic;
begin

process (clk, rst) begin
	if rst = '1' then
		pulse <= '0';
		beat_q <= x"0000";
	elsif rising_edge(clk) then
		beat_q <= beat;
		--activate output if beat changes and the beat position is included in the pattern
		if beat_q /= beat then
			if (unsigned(pattern) and beat) /= x"0000" then
				pulse <= '1';
			end if;
		end if;
		--turn off output after one clock cycle
		if pulse = '1' then
			pulse <= '0';
		end if;
	end if;
end process;

pulse_out <= pulse;

end Behavioral;
