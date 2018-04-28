----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2018 01:17:06 PM
-- Design Name: 
-- Module Name: waveform_player_tb - Behavioral
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

use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity waveform_player_tb is
end waveform_player_tb;

architecture Behavioral of waveform_player_tb is
	signal clk : std_logic;
	signal rst : std_logic;
	signal sample_pulse : std_logic;
	signal start_pulse : std_logic;
	signal dout : std_logic_vector(15 downto 0);
begin

dut : entity waveform_player generic map (
	mem_file => "test.mem",
	mem_file_length => x"0010"
) port map (
	clk => clk,
	rst => rst,
	sample_pulse => sample_pulse,
	start_pulse => start_pulse,
	dout => dout
);

process begin
	clk <= '0';
	wait for 5ns;
	clk <= '1';
	wait for 5ns;
end process;

process begin
	sample_pulse <= '0';
	wait for 40ns;
	sample_pulse <= '1';
	wait for 10ns;
end process;

process begin
	rst <= '1';
	wait for 20ns;
	rst <= '0';
	wait for 100ns;
	start_pulse <= '1';
	wait for 10ns;
	start_pulse <= '0';
	wait for 200ns;
	start_pulse <= '1';
	wait for 10ns;
	start_pulse <= '0';
	wait;
end process;


end Behavioral;
