----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- Displays 8 independent characters using 7 segment displays
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seg7_controller is Port (
	--Clock (100MHz)
	clk : in std_logic;
	--Asynchronous reset
	rst : in std_logic;
	--Digits to display
	d0, d1, d2, d3, d4, d5, d6, d7 : in std_logic_vector(3 downto 0);
	--7 segment display annodes and cathodes
	an : out std_logic_vector(7 downto 0);
	cath : out std_logic_vector(7 downto 0)
	);
end seg7_controller;

architecture Behavioral of seg7_controller is
	signal digit : std_logic_vector(3 downto 0);
	signal output_sel : unsigned(2 downto 0);
	signal pulse_1kHz : std_logic;
begin
	--7 segment display driver (single channel)
	seg7 : entity seg7_hex port map (
		digit => digit,
		seg7 => cath);
	
	--1kHz Pulse generator (divides clk by 100,000)
	pulse1kHz : entity pulseGenerator port map (
		clk => clk,
		reset => rst,
		MaxCounter => to_unsigned(100_000,28),
		Pulse => pulse_1kHz);
	
	--Increment ouput_sel counter at 1kHz
	process (clk, rst) begin
		if (rst = '1') then
			output_sel <= "000";
		elsif rising_edge(clk) then
			if (pulse_1kHz = '1') then
				output_sel <= output_sel + 1;
			end if;
		end if;
	end process;
	
	--Select annode based on output_sel counter
	with output_sel select an <= 
		"11111110" when "000",
		"11111101" when "001",
		"11111011" when "010",
		"11110111" when "011",
		"11101111" when "100",
		"11011111" when "101",
		"10111111" when "110",
		"01111111" when others;
	
	--Select an input digit based on output_sel counter
	with output_sel select digit <=
		d0 when "000",
		d1 when "001",
		d2 when "010",
		d3 when "011",
		d4 when "100",
		d5 when "101",
		d6 when "110",
		d7 when others;

end Behavioral;
