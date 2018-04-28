----------------------------------------------------------------------------------
--
-- Author: Owen Lu
--
-- Description:
-- High level state machine and control logic
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control is Port (
	clk : in std_logic;
	rst : in std_logic;
	--push buttons for user input
	btnu, btnd, btnr : in std_logic;
	--enable lines for pattern registers
	en1, en2, en3 : out std_logic;
	--one-hot encoding of the current loop position
	beat : out unsigned(15 downto 0);
	--7 segment display for tempo
	SEG7_CATH : out std_logic_vector(7 downto 0);
	SEG7_AN : out std_logic_vector(7 downto 0);
	--led to visualize loop position
	LED : out std_logic_vector(15 downto 0)
);
end control;

architecture Behavioral of control is
	constant BEAT_PULSE_DIV_DEFAULT : unsigned(27 downto 0) := x"0C65D40"; --default loop speed: 130ms per switch position
	constant BEAT_PULSE_DIV_INCR : unsigned(27 downto 0) := x"00F4240"; --10ms increments for tempo adjustment
	constant BIT0 : unsigned(15 downto 0) := x"8000";
	
	type top_state is (S_TEMPO, S_LENGTH, S_INST1, S_INST2, S_INST3);
	signal state, next_state : top_state;
	signal btnr_db, btnu_db, btnd_db : std_logic;
	signal beat_pulse, sample_pulse : std_logic;
	signal beat_pulse_div : unsigned(27 downto 0);
	signal beat_i : unsigned(15 downto 0);
	signal set_tempo, set_length : std_logic;
	signal tempo_disp : std_logic_vector(11 downto 0);
	signal an : std_logic_vector(7 downto 0);
	signal beat_len : natural range 1 to 16;
	signal led_len : std_logic_vector(15 downto 0);
	signal beat_rst : std_logic;
begin

--debounce all push-buttons
debounceR : entity button_pulse port map (
	clk => clk,
	btn => btnr,
	pulse => btnr_db
);
debounceU : entity button_pulse port map (
	clk => clk,
	btn => btnu,
	pulse => btnu_db
);
debounceD : entity button_pulse port map (
	clk => clk,
	btn => btnd,
	pulse => btnd_db
);

--display tempo in ms per switch position
seg7 : entity seg7_controller port map (
	clk => clk,
	rst => rst,
	d0 => tempo_disp(3 downto 0),
	d1 => tempo_disp(7 downto 4),
	d2 => tempo_disp(11 downto 8),
	d3 => x"0",
	d4 => x"0",
	d5 => x"0",
	d6 => x"0",
	d7 => x"0",
	an => an,
	cath => SEG7_CATH
);
SEG7_AN <= "11111" & an(2 downto 0);

--High level state machine
process (clk) begin
	if rising_edge(clk) then
		state <= next_state;
	end if;
end process;

process (btnr_db, rst) begin
	--default assignments
	next_state <= state;
	en1 <= '0';
	en2 <= '0';
	en3 <= '0';
	set_tempo <= '0';
	set_length <= '0';
	beat_rst <= '0';
	if rst = '1' then
		next_state <= S_TEMPO;
	else
		case state is
			--User sets tempo using up/down buttons
			when S_TEMPO =>
				beat_rst <= '1';
				set_tempo <= '1';
				if btnr_db = '1' then
					next_state <= S_LENGTH;
				end if;
			--User sets pattern length using up/down buttons
			when S_LENGTH =>
				beat_rst <= '1';
				set_length <= '1';
				if btnr_db = '1' then
					next_state <= S_INST1;
				end if;
			--User sets bass drum pattern using switches
			when S_INST1 =>
				en1 <= '1';
				if btnr_db = '1' then
					next_state <= S_INST2;
				end if;
			--user sets snare drum pattern using switches
			when S_INST2 =>
				en2 <= '1';
				if btnr_db = '1' then
					next_state <= S_INST3;
				end if;
			--user sets hi-hat pattern using switches
			when S_INST3 =>
				en3 <= '1';
				if btnr_db = '1' then
					next_state <= S_INST1;
				end if;
			when others =>
				next_state <= S_TEMPO;
		end case;
	end if;
end process;

--Settings registers
process (clk, rst) begin
	if rst = '1' then
		--default values
		beat_pulse_div <= BEAT_PULSE_DIV_DEFAULT;
		tempo_disp <= x"082";
		beat_len <= 16;
	elsif rising_edge(clk) then
		if set_tempo = '1' then
			if btnu_db = '1' then
				beat_pulse_div <= beat_pulse_div + BEAT_PULSE_DIV_INCR;
				tempo_disp <= std_logic_vector(unsigned(tempo_disp) + x"00A");
			elsif btnd_db = '1' then
				beat_pulse_div <= beat_pulse_div - BEAT_PULSE_DIV_INCR;
				tempo_disp <= std_logic_vector(unsigned(tempo_disp) - x"00A");
			end if;
		end if;
		if set_length = '1' then
			if beat_len < 16 and btnu_db = '1' then
				beat_len <= beat_len + 1;
			elsif beat_len > 1 and btnd_db = '1' then
				beat_len <= beat_len - 1;
			end if;
		end if;
	end if;
end process;

--generate pulse to advance the loop position
bp : entity pulseGenerator port map (
	clk => clk,
	reset => rst,
	MaxCounter => beat_pulse_div,
	Pulse => beat_pulse
);

--generate one-hot encoding of loop position (beat)
process (clk, beat_rst) begin
	if beat_rst = '1' then
		beat_i <= BIT0;
	elsif rising_edge(clk) then
		if beat_pulse = '1' then
			if beat_i(16 - beat_len) = '1' then
				beat_i <= BIT0;
			else
				beat_i <= beat_i ror 1;
			end if;
		end if;
	end if;
end process;

beat <= beat_i;
led_len <= std_logic_vector(shift_right(BIT0, beat_len -1));
LED <= led_len when set_length = '1' else std_logic_vector(beat_i);

end Behavioral;
