----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- Outputs an audio PWM signal given signed duty cycle
-- PWM is 50% for input of zero
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity audio_pwm is Generic (
	resolution : Integer
); Port ( 
	clk : in std_logic;
	reset : in std_logic;
	--changed duty cyle to signed value
	duty_cycle : in signed(resolution - 1 downto 0);
	pwm_out : out std_logic
);
end audio_pwm;

architecture Behavioral of audio_pwm is
	signal counter : signed(resolution - 1 downto 0);
begin

	--simple counter
	process(clk, reset) begin
		if (reset = '1') then
			--reset counter to largest negative number
			counter <= ((resolution - 1) => '1', others => '0');
		elsif rising_edge(clk) then
			counter <= counter + 1;
		end if;
	end process;
	
	--output logic
	pwm_out <= '1' when counter < duty_cycle else '0';

end Behavioral;
