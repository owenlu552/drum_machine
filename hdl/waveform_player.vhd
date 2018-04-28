----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2018 11:39:44 AM
-- Design Name: 
-- Module Name: waveform_player - Behavioral
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

Library xpm;
use xpm.vcomponents.all;

use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity waveform_player is Generic (
	mem_file : string;
	mem_file_length : unsigned(15 downto 0)
);Port (
	clk : in std_logic;
	rst : in std_logic;
	sample_pulse : in std_logic;
	start_pulse : in std_logic;
	dout : out std_logic_vector(15 downto 0)
);
end waveform_player;

architecture Behavioral of waveform_player is
	signal bram_dout : std_logic_vector(15 downto 0);
	signal bram_addr : std_logic_vector(15 downto 0);
	signal bram_en : std_logic;
	
	type player_state is (IDLE, ACTIVE);
	signal state, nextState : player_state;
	signal btnr_db : std_logic;
begin

xpm_memory_sprom_inst : xpm_memory_sprom generic map(
	ADDR_WIDTH_A=>16,
	--DECIMAL
	AUTO_SLEEP_TIME=>0,
	--DECIMAL
	ECC_MODE=>"no_ecc",
	--String
	MEMORY_INIT_FILE=>mem_file,--String
	MEMORY_INIT_PARAM=>"0",--String
	MEMORY_PRIMITIVE=>"auto",--String
	MEMORY_SIZE=>to_integer(mem_file_length & "0000"),
	--DECIMAL
	MESSAGE_CONTROL=>0,
	--DECIMAL
	READ_DATA_WIDTH_A=>16,--DECIMAL
	READ_LATENCY_A=>1,
	--DECIMAL
	READ_RESET_VALUE_A=>"0",--String
	USE_MEM_INIT=>1,
	--DECIMAL
	WAKEUP_TIME=>"disable_sleep"--String
) port map (
	dbiterra=>open, --1-bitoutput:Leaveopen.
	douta=>bram_dout, --READ_DATA_WIDTH_A-bitoutput:DataoutputforportAreadoperations.
	sbiterra=>open, --1-bitoutput:Leaveopen.
	addra=>bram_addr, --ADDR_WIDTH_A-bitinput:AddressforportAreadoperations.
	clka=>clk, --1-bitinput:ClocksignalforportA.
	ena=>bram_en, --1-bitinput:MemoryenablesignalforportA.Mustbehighonclock
	--cycleswhenreadoperationsareinitiated.Pipelinedinternally.
	injectdbiterra=>'0',--1-bitinput:Donotchangefromtheprovidedvalue.
	injectsbiterra=>'0',--1-bitinput:Donotchangefromtheprovidedvalue.
	regcea=>'1',
	--1-bitinput:Donotchangefromtheprovidedvalue.
	rsta=>rst,
	--1-bitinput:ResetsignalforthefinalportAoutputregister
	--stage.Synchronouslyresetsoutputportdoutatothevaluespecified
	--byparameterREAD_RESET_VALUE_A.
	sleep=>'0'--1-bitinput:sleepsignaltoenablethedynamicpowersavingfeature.
);

bram_en <= '1';

process (clk) begin
	if rising_edge(clk) then
		state <= nextState;
	end if;
end process;

process (start_pulse, bram_addr, state, rst) begin
	nextState <= state;
	if rst = '1' then
		nextState <= IDLE;
	else
		case state is
			when IDLE =>
				if start_pulse = '1' then
					nextState <= ACTIVE;
				end if;
			when ACTIVE =>
				if unsigned(bram_addr) >= (mem_file_length-1) then
					nextState <= IDLE;
				end if;
			when others =>
				nextState <= IDLE;
		end case;
	end if;
end process;

process(clk) begin
	if rising_edge(clk) then
		if (start_pulse = '1' or rst = '1') then 
			bram_addr <= (others => '0');
		elsif (state = ACTIVE and sample_pulse = '1') then
			bram_addr <= std_logic_vector(unsigned(bram_addr) + 1);
		end if;
	end if;
end process;

dout <= bram_dout;

end Behavioral;
