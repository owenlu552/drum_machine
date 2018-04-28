----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- Plays a pre-defined waveform using a ROM initialized from a text file
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use xpm library for ROM generation macro
Library xpm;
use xpm.vcomponents.all;

use IEEE.NUMERIC_STD.ALL;

entity waveform_player is Generic (
	--text file containing 16-bit audio samples in hex.
	--must be signed (two's complement) values centered at zero
	mem_file : string;
	--number of samples in mem_file
	mem_file_length : unsigned(15 downto 0)
);Port (
	clk : in std_logic;
	rst : in std_logic;
	--pulse determining the audio sample rate
	sample_pulse : in std_logic;
	--being outputing waveform when this pulse is received
	start_pulse : in std_logic;
	--waveform output
	dout : out std_logic_vector(15 downto 0)
);
end waveform_player;

architecture Behavioral of waveform_player is
	signal bram_dout : std_logic_vector(15 downto 0);
	signal bram_addr : std_logic_vector(15 downto 0);
	signal bram_en : std_logic;
	
	type player_state is (S_IDLE, S_ACTIVE);
	signal state, nextState : player_state;
	signal btnr_db : std_logic;
begin

--Generate single port ROM initialized with mem_file
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

--state machine
process (clk) begin
	if rising_edge(clk) then
		state <= nextState;
	end if;
end process;

process (start_pulse, bram_addr, state, rst) begin
	nextState <= state;
	if rst = '1' then
		nextState <= S_IDLE;
	else
		case state is
			when S_IDLE =>
				if start_pulse = '1' then
					nextState <= S_ACTIVE;
				end if;
			when S_ACTIVE =>
				if unsigned(bram_addr) >= (mem_file_length-1) then
					nextState <= S_IDLE;
				end if;
			when others =>
				nextState <= S_IDLE;
		end case;
	end if;
end process;

--Memory address logic
process(clk) begin
	if rising_edge(clk) then
		--set address to zero on reset or start_pulse
		--note that start_pulse can occur during the active state
		if (start_pulse = '1' or rst = '1') then 
			bram_addr <= (others => '0');
		elsif (state = S_ACTIVE and sample_pulse = '1') then
			bram_addr <= std_logic_vector(unsigned(bram_addr) + 1);
		end if;
	end if;
end process;

dout <= bram_dout;

end Behavioral;
