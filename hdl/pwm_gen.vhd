----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- Outputs a PWM signal given duty cycle
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

entity pwm_gen is Generic (
	resolution : Integer
); Port ( 
	clk : in std_logic;
	reset : in std_logic;
	duty_cycle : in std_logic_vector(resolution - 1 downto 0);
	pwm_out : out std_logic
);
end pwm_gen;

architecture Behavioral of pwm_gen is
	signal counter : unsigned(resolution - 1 downto 0);
begin

	--simple counter
	process(clk, reset) begin
		if (reset = '1') then
			counter <= (others => '0');
		elsif rising_edge(clk) then
			counter <= counter + 1;
		end if;
	end process;
	
	--output logic
	pwm_out <= '1' when counter < unsigned(duty_cycle) else '0';

end Behavioral;
