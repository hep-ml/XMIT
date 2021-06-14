library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--debugging
library std;
use std.textio.all;
use ieee.std_logic_textio.all; --require for writing std_logic etc.

use work.TP_pkg.all;


entity TP_generator is
generic (
	N		: natural := 12
);
port (
	clk196 		: in std_logic;
	rst		: in std_logic;
	data_in		: in std_logic_vector(31 downto 0);
	TP_Raw		: out generator_to_buffer_t
);
end TP_generator;

architecture behavioral of TP_generator is
file outfile : text open write_mode is "DEBUG_GENERATOR_OUTPUT.txt";
type value_type is array (1 downto 0) of std_logic_vector(15 downto 0);
type adc_value_type is array (1 downto 0) of unsigned(11 downto 0);

constant TP_FRAME_LENGTH : natural := 14;
type rx_state_type is (IDLE, OP);
type tx_state_type is (IDLE, TX, RS);
type rx_substate_type is (Idle, Header, ADC);
signal rx_state : rx_state_type;
signal tx_state : tx_state_type;
signal rx_substate : rx_substate_type;
signal length : integer;
signal txcnt : natural RANGE 0 to TP_FRAME_LENGTH;
signal rxcnt : natural;
signal headercnt : integer RANGE 0 to TOTAL_HEADER_LENGTH-1;
signal headerjump : std_logic;
signal TP_Raw_Frame : generator_to_buffer_t;
signal TP_Raw_Frame_Buffer : generator_to_buffer_t;
begin

sequential : process (clk196, rst) -- sensitivity list
variable value		: value_type;
variable adc_value 	: adc_value_type;
variable integralN_1 	: unsigned (23 downto 0);
variable integralN_2 	: unsigned (23 downto 0);
variable line_out 	: line;
begin

value(1) := data_in(15 downto 0);
value(0) := data_in (31 downto 16);

if rst = '1' then
	rx_state	<= IDLE;
	tx_state	<= IDLE;
	rx_substate	<= Idle;
	txcnt		<= 0;
	rxcnt		<= 0;
	headercnt	<= 0;
	TP_Raw_Frame	<= init_g;
	TP_Raw_Frame_Buffer	<= init_g;

elsif (clk196 ='1' and clk196'event) then

	case rx_state is
	when IDLE =>
		if unsigned(data_in) = X"ffffffff" then
			rx_state	<= OP;
			rx_substate	<= Header;
			rxcnt		<= 0;
			txcnt		<= 0;
			headercnt	<= 0;
		end if;

	when  OP =>
		case rx_substate is
		when Header =>
			if value(0)(15 downto 12) = X"F" then
				case headercnt is
				when 0 =>
					TP_Raw_Frame_Buffer.fem_header1(15 downto 0) <= value(0);
					TP_Raw_Frame_Buffer.fem_header1(31 downto 16) <= value(1);
					headercnt <= headercnt + 1;
				when 1 =>
					TP_Raw_Frame_Buffer.fem_header2(15 downto 0) <= value(0);
					TP_Raw_Frame_Buffer.fem_header2(31 downto 16) <= value(1);
					headercnt <= headercnt + 1;
				when 2 =>
					TP_Raw_Frame_Buffer.fem_header3(15 downto 0) <= value(0);
					TP_Raw_Frame_Buffer.fem_header3(31 downto 16) <= value(1);
					headercnt <= headercnt + 1;
				when 3 =>
					TP_Raw_Frame_Buffer.fem_header4(15 downto 0) <= value(0);
					TP_Raw_Frame_Buffer.fem_header4(31 downto 16) <= value(1);
					headercnt <= headercnt + 1;
				when 4 =>
					headercnt <= headercnt + 1;
				when 5 =>
					rx_substate <= ADC;
					headerjump <= '1';
					headercnt  <= 0;
				end case;
			end if;
		when ADC =>
			headerjump <= '0';	
			for i in 0 to 1 loop
				if value(i)(15 downto 13) = "001" then
					adc_value(i) := unsigned(value(i)(11 downto 0));
				elsif value(i)(15 downto 12) = "0001" then
					if i = 1 then
						TP_Raw_Frame_Buffer.channel_header	<= value(1);
					else
						TP_Raw_Frame_Buffer.channel_header	<= value(0);
					end if;
					adc_value(i) := (others => '0');
				elsif value(i)(15 downto 14) = "01" then
					TP_Raw_Frame_Buffer.frame_start <= value(i);
					adc_value(i) := (others => '0');
				else
					adc_value(i) := (others => '0');
				end if;
			end loop;

			if value(1)(15 downto 12) = "0001" or value(0)(15 downto 12) = "0001" 
					or data_in = X"e0000000" or value(0) = X"ffff" or value(1) = X"ffff" then
				write(line_out,888888,right,15);
				writeline(outfile,line_out);
				if (value(0) = X"ffff" or value(1) = X"ffff") and data_in /= X"e0000000"  then -- end of FEM
					rx_substate <= Header;
					TP_Raw_Frame_Buffer.fem_header1(15 downto 0) <= value(0);
					TP_Raw_Frame_Buffer.fem_header1(31 downto 16) <= value(1);
					headercnt <= 1;
				end if;

				--if data_in = X"e0000000" then
				--end if;
				if headerjump = '0' then
					tx_state <= TX; --not if on first channel after header
				end if;
				TP_Raw_Frame_Buffer.amplitude <= (others => '0');
				TP_Raw_Frame_Buffer.nb_values <= (others => '0');
				TP_Raw_Frame_Buffer.integralN <= (others => '0');
				TP_Raw_Frame_Buffer.integralFull <= (others => '0');
				rxcnt <= 0;
				TP_Raw_Frame.channel_header	<= TP_Raw_Frame_Buffer.channel_header;
				TP_Raw_Frame.frame_start	<= TP_Raw_Frame_Buffer.frame_start;
				TP_Raw_Frame.fem_header1	<= TP_Raw_Frame_Buffer.fem_header1;
				TP_Raw_Frame.fem_header2	<= TP_Raw_Frame_Buffer.fem_header2;
				TP_Raw_Frame.fem_header3	<= TP_Raw_Frame_Buffer.fem_header3;
				TP_Raw_Frame.fem_header4	<= TP_Raw_Frame_Buffer.fem_header4;

				if value(1)(15 downto 12) = "0001" or data_in = X"e0000000" then
					---- Shift to buffer
					TP_Raw_Frame.amplitude 		<= TP_Raw_Frame_Buffer.amplitude;
					TP_Raw_Frame.nb_values		<= TP_Raw_Frame_Buffer.nb_values;
					TP_Raw_Frame.integralN		<= TP_Raw_Frame_Buffer.integralN;
					TP_Raw_Frame.integralFull	<= TP_Raw_Frame_Buffer.integralFull;
					if data_in = X"e0000000" then
						rx_state <= IDLE;
						rx_substate <= Idle;
						rxcnt <= 0;
					TP_Raw_Frame.eof <= '1';
				else
					TP_Raw_Frame.eof <= '0';
					end if;
				elsif value(0)(15 downto 12) = "0001" then
					---- Shift to buffer
					TP_Raw_Frame.integralFull	<= TP_Raw_Frame_Buffer.integralFull + adc_value(1);
					if adc_value(1) > TP_Raw_Frame_Buffer.amplitude then
						TP_Raw_Frame.amplitude 		<= adc_value(1);
					else
						TP_Raw_Frame.amplitude 		<= TP_Raw_Frame_Buffer.amplitude;
					end if;
					for i in 0 to 2 loop
--						if adc_value(1) >= threshold(i) then
						if adc_value(1) > 0 then -- SIMPLIFIED
							TP_Raw_Frame.nb_values	<= TP_Raw_Frame_Buffer.nb_values + 1;
						else
							TP_Raw_Frame.nb_values	<= TP_Raw_Frame_Buffer.nb_values;
						end if;
					end loop; 
					if rxcnt <= N then
						TP_Raw_Frame.integralN		<= TP_Raw_Frame_Buffer.integralN + adc_value(1);
					else
						TP_Raw_Frame.integralN		<= TP_Raw_Frame_Buffer.integralN;
					end if;	
				end if;

			elsif value(0)(15 downto 13) = "001" or value(1)(15 downto 13) = "001" then
				write(line_out,to_integer(adc_value(0)),right,15);
				write(line_out,to_integer(adc_value(1)),right,15);
				writeline(outfile,line_out);

				if value(0)(12) = '1' or value(1)(12) = '1' then
					if headerjump = '0' then
						tx_state <= TX; --not if on first channel after header
					end if;
					TP_Raw_Frame_Buffer.amplitude <= (others => '0');
					TP_Raw_Frame_Buffer.nb_values <= (others => '0');
					TP_Raw_Frame_Buffer.integralN <= (others => '0');
					TP_Raw_Frame_Buffer.integralFull <= (others => '0');
					rxcnt <= 0;
					TP_Raw_Frame.channel_header	<= TP_Raw_Frame_Buffer.channel_header;
					TP_Raw_Frame.frame_start	<= TP_Raw_Frame_Buffer.frame_start;
					TP_Raw_Frame.fem_header1	<= TP_Raw_Frame_Buffer.fem_header1;
					TP_Raw_Frame.fem_header2	<= TP_Raw_Frame_Buffer.fem_header2;
					TP_Raw_Frame.fem_header3	<= TP_Raw_Frame_Buffer.fem_header3;
					TP_Raw_Frame.fem_header4	<= TP_Raw_Frame_Buffer.fem_header4;
					TP_Raw_Frame.integralFull <= TP_Raw_Frame_Buffer.integralFull + adc_value(0) + adc_value(1);
					if adc_value(0) > adc_value(1) then
						if adc_value(0) > TP_Raw_Frame_Buffer.amplitude then
							TP_Raw_Frame.amplitude <= adc_value(0);
						else
							TP_Raw_Frame.amplitude <= TP_Raw_Frame_Buffer.amplitude;
						end if;
					else
						if adc_value(1) > TP_Raw_Frame_Buffer.amplitude then
							TP_Raw_Frame.amplitude <= adc_value(1);
						else
							TP_Raw_Frame.amplitude <= TP_Raw_Frame_Buffer.amplitude;
						end if;
					end if;
					for i in 0 to 2 loop
						if adc_value(0) > 0 then -- SIMPLIFIED
							if adc_value(1) > 0 then -- SIMPLIFIED
								TP_Raw_Frame.nb_values	<= TP_Raw_Frame_Buffer.nb_values + 2;
							else
								TP_Raw_Frame.nb_values	<= TP_Raw_Frame_Buffer.nb_values + 1;
							end if;
						else
	--						if adc_value(1) >= threshold(i) then
							if adc_value(1) > 0 then -- SIMPLIFIED
								--nb_values(i) <= nb_values(i) + 1;
								TP_Raw_Frame.nb_values	<= TP_Raw_Frame_Buffer.nb_values + 1;
							end if;
						end if;
					end loop; 
					if rxcnt <= N then
						integralN_1(11 downto 0) := adc_value(1);
						integralN_1(23 downto 12) := (others => '0');
					else
						integralN_1 := (others => '0');
					end if;	
					if rxcnt+1 <= N then
						integralN_2(11 downto 0) := adc_value(0);
						integralN_2(23 downto 12) := (others => '0');
					else
						integralN_2 := (others => '0');
					end if;	
					TP_Raw_Frame.integralN <= TP_Raw_Frame_Buffer.integralN+integralN_1+integralN_2;
					-- no rxcnt as data is being sent out anyway
				else
					TP_Raw_Frame_Buffer.integralFull <= TP_Raw_Frame_Buffer.integralFull + adc_value(0) + adc_value(1);

					if adc_value(0) > adc_value(1) then
						if adc_value(0) > TP_Raw_Frame_Buffer.amplitude then
							TP_Raw_Frame_Buffer.amplitude <= adc_value(0);
						end if;
					else
						if adc_value(1) > TP_Raw_Frame_Buffer.amplitude then
							TP_Raw_Frame_Buffer.amplitude <= adc_value(1);
						end if;
					end if;
					for i in 0 to 2 loop
						write(line_out,i,right,15);
						write(line_out,to_integer(TP_Raw_Frame_Buffer.nb_values),right,15);
						writeline(outfile,line_out);
	--					if adc_value(0) >= (threshold(i)) then
						if adc_value(0) > 0 then -- SIMPLIFIED
	--						if adc_value(1) >= threshold(i) then
							if adc_value(1) > 0 then -- SIMPLIFIED
								TP_Raw_Frame_Buffer.nb_values	<= TP_Raw_Frame_Buffer.nb_values + 2;
							else
								TP_Raw_Frame_Buffer.nb_values	<= TP_Raw_Frame_Buffer.nb_values + 1;
							end if;
						else
	--						if adc_value(1) >= threshold(i) then
							if adc_value(1) > 0 then -- SIMPLIFIED
								--nb_values(i) <= nb_values(i) + 1;
								TP_Raw_Frame_Buffer.nb_values	<= TP_Raw_Frame_Buffer.nb_values + 1;
							end if;
						end if;
					end loop; 
					if rxcnt <= N then
						integralN_1(11 downto 0) := adc_value(1);
						integralN_1(23 downto 12) := (others => '0');
					else
						integralN_1 := (others => '0');
					end if;	
					if rxcnt+1 <= N then
						integralN_2(11 downto 0) := adc_value(0);
						integralN_2(23 downto 12) := (others => '0');
					else
						integralN_2 := (others => '0');
					end if;	
					TP_Raw_Frame_Buffer.integralN <= TP_Raw_Frame_Buffer.integralN+integralN_1+integralN_2;

					--set counter, dependent on how many ADC value there are
					if not(value(0)(15 downto 13) = "001") or not(value(1)(15 downto 13) = "001") then
						rxcnt <= rxcnt + 1;
					else
						rxcnt <= rxcnt + 2;
					end if;
				end if;
			end if;

		when Idle =>
			TP_Raw_Frame_Buffer <= init_g;
			rxcnt <= 0;
			headercnt <= 0;
		end case;
	end case;

	case tx_state is
	when IDLE =>	
		TP_Raw <= init_g;
	when TX =>
		TP_Raw <= 
			(fem_header1	=> TP_Raw_Frame.fem_header1,
			fem_header2	=> TP_Raw_Frame.fem_header2,
			fem_header3	=> TP_Raw_Frame.fem_header3,
			fem_header4	=> TP_Raw_Frame.fem_header4,
			channel_header	=> TP_Raw_Frame.channel_header,
			frame_start	=> TP_Raw_Frame.frame_start,
			nb_values	=> TP_Raw_Frame.nb_values,
			amplitude	=> TP_Raw_Frame.amplitude,
			integralFull	=> TP_Raw_Frame.integralFull,
			integralN	=> TP_Raw_Frame.integralN,
			eof		=> TP_Raw_Frame.eof,
			valid		=> '1');
		tx_state 	<= RS;
	when RS =>
		tx_state	<= IDLE;
		TP_Raw 		<= init_g;
	end case;				
end if;
end process;
end architecture behavioral;
