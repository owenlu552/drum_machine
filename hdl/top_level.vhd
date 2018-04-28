----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- Final Project (Drum Machine) Top Level
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity top_level is Port (
	--clock
	CLK100MHZ : in std_logic;
	--push buttons
	BTNC, BTNR, BTNU, BTND : in std_logic;
	--switches
	SW : in std_logic_vector(15 downto 0);
	--Seg7 display signals
	SEG7_CATH : out std_logic_vector(7 downto 0);
	AN : out std_logic_vector(7 downto 0);
	--audio amplifier
	AUD_SD : out std_logic;
	AUD_PWM : out std_logic;
	--LEDs
	LED : out std_logic_vector(15 downto 0)
);
end top_level;

architecture Behavioral of top_level is
	constant SAMPLE_PULSE_DIV : unsigned(27 downto 0) := x"00008DB"; --44.1kHz sample rate
	
	signal pwm_duty_cycle1, pwm_duty_cycle2, pwm_duty_cycle3 : std_logic_vector(15 downto 0);
	signal pwm_sum : signed(15 downto 0);
	signal beat : unsigned(15 downto 0);
	signal trigger_pulse1, trigger_pulse2, trigger_pulse3, sample_pulse : std_logic;
	signal pattern_reg1, pattern_reg2, pattern_reg3 : std_logic_vector(15 downto 0);
	signal en1, en2, en3 : std_logic;
	
begin

--Main state machine to generate control signals
ctrl : entity control port map (
	clk => CLK100MHZ,
	rst => BTNC,
	btnu => BTNU,
	btnd => BTND,
	btnr => BTNR,
	en1 => en1,
	en2 => en2,
	en3 => en3,
	beat => beat,
	SEG7_CATH => SEG7_CATH,
	SEG7_AN => AN,
	LED => LED 
);

--Registers to store rhythm patterns defined by switch inputs
process (CLK100MHZ, BTNC) begin
	if BTNC = '1' then
		pattern_reg1 <= (others => '0');
		pattern_reg2 <= (others => '0');
		pattern_reg3 <= (others => '0');
	elsif rising_edge(CLK100MHZ) then
		if en1 = '1' then
			pattern_reg1 <= SW;
		end if;
		if en2 = '1' then
			pattern_reg2 <= SW;
		end if;
		if en3 = '1' then
			pattern_reg3 <= SW;
		end if;
	end if;
end process;

--timing pulse generation for bass drum
pl : entity pattern_loop port map (
	clk => CLK100MHZ,
	rst => BTNC,
	pattern => pattern_reg1,
	beat => beat,
	pulse_out => trigger_pulse1
	);

--timing pulse generation for snare drum
p2 : entity pattern_loop port map (
	clk => CLK100MHZ,
	rst => BTNC,
	pattern => pattern_reg2,
	beat => beat,
	pulse_out => trigger_pulse2
	);
	
--timing pulse generation for hi-hat
p3 : entity pattern_loop port map (
		clk => CLK100MHZ,
		rst => BTNC,
		pattern => pattern_reg3,
		beat => beat,
		pulse_out => trigger_pulse3
		);

--audio sample rate generation
sp : entity pulseGenerator port map (
	clk => CLK100MHZ,
	reset => BTNC,
	MaxCounter => SAMPLE_PULSE_DIV,
	Pulse => sample_pulse
);

--base drum waveform player
wp1 : entity waveform_player generic map (
	mem_file => "kick.mem",
	mem_file_length => x"5FCA"
) port map (
	clk => CLK100MHZ,
	rst => BTNC,
	sample_pulse => sample_pulse,
	start_pulse => trigger_pulse1,
	dout => pwm_duty_cycle1
);

--snare drum waveform player
wp2 : entity waveform_player generic map (
	mem_file => "snare.mem",
	mem_file_length => x"4500"
) port map (
	clk => CLK100MHZ,
	rst => BTNC,
	sample_pulse => sample_pulse,
	start_pulse => trigger_pulse2,
	dout => pwm_duty_cycle2
);

--hi-hat waveform player
wp3 : entity waveform_player generic map (
	mem_file => "hat.mem",
	mem_file_length => x"13FE"
) port map (
	clk => CLK100MHZ,
	rst => BTNC,
	sample_pulse => sample_pulse,
	start_pulse => trigger_pulse3,
	dout => pwm_duty_cycle3
);

--Add the waveforms to generate net PWM value
pwm_sum <= signed(pwm_duty_cycle1) + signed(pwm_duty_cycle2) + signed(pwm_duty_cycle3);

--generate pwm signal based on signed duty cycle
pwm : entity audio_pwm generic map (
	resolution => 10
) port map (
	clk => CLK100MHZ,
	reset => '0',
	duty_cycle => pwm_sum(15 downto 6),
	pwm_out => AUD_PWM
	);

AUD_SD <= '1';

end Behavioral;
