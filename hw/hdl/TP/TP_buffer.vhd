library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--debugging
library std;
use std.textio.all;
use ieee.std_logic_textio.all; 

use work.TP_pkg.all;


entity TP_buffer is
generic (
	BUFFER_LENGTH	: natural := 23;
	PAYLOAD_LENGTH	: natural := 6
);
port (
	clk196 		: in std_logic;
	rst		: in std_logic;
	TP_Raw		: in generator_to_buffer_t;
	data_out	: out std_logic_vector(15 downto 0);
	overflow_flag	: out std_logic;
	fst		: out std_logic;
	lst		: out std_logic;
	valid		: out std_logic
);
end TP_buffer;

architecture behavioral of TP_buffer is
file outfile : text open write_mode is "DEBUG_BUFFER_OUTPUT.txt";
type state_t is (INIT1,INIT2,FEMHEADER_VAL1A,FEMHEADER_VAL1B,FEMHEADER_VAL2A,FEMHEADER_VAL2B,FEMHEADER_VAL3A,FEMHEADER_VAL3B,FEMHEADER_VAL4A,FEMHEADER_VAL4B,FEMHEADER_FILLER,SUBHEADER2,SUBHEADER1,PAYLOAD,ENDOFFRAME1,ENDOFFRAME2,IDLE,ENDOFFEM1,ENDOFFEM2);
type std_logic_vector_array is array(PAYLOAD_LENGTH-1 downto 0) of std_logic_vector(WORD-1 downto 0);
signal tp_buffer 		: tp_buffer_array(BUFFER_LENGTH-1 downto 0);
signal tp_ff 			: generator_to_buffer_t;
signal tp_ff_old 		: generator_to_buffer_t;
signal buffer_length_pointer	: natural range 0 to BUFFER_LENGTH;
signal number_filler		: natural range 0 to TOTAL_HEADER_LENGTH;
signal payload_pointer		: natural range 0 to PAYLOAD_LENGTH;
signal state 			: state_t;
signal tp_map			: std_logic_vector_array;
signal lst_buffer		: std_logic;
signal eof			: std_logic;
begin

lst		<= lst_buffer;

sequential : process (clk196, rst) 
variable line_out 	: line;
begin

if rst = '1' then
	tp_buffer	<= (others => init_g);
	overflow_flag	<= '0';
	buffer_length_pointer <= 0;
	number_filler <= 0;
	state <= IDLE;
	fst <= '0';
	lst_buffer <= '0';
	eof <= '1';

elsif (clk196 ='1' and clk196'event) then

	if  state = INIT1 or state = INIT2 then
		data_out <= (others => '1');
		valid		<=	'1';
	elsif state = FEMHEADER_VAL1B then
		data_out <= tp_ff.fem_header1(WORD-1 downto 0);
		valid		<=	'1';
	elsif state = FEMHEADER_VAL1A then
		data_out <= tp_ff.fem_header1(2*WORD-1 downto WORD);
		valid		<=	'1';
	elsif state = FEMHEADER_VAL2B then
		data_out <= tp_ff.fem_header2(WORD-1 downto 0);
		valid		<=	'1';
	elsif state = FEMHEADER_VAL2A then
		data_out <= tp_ff.fem_header2(2*WORD-1 downto WORD);
		valid		<=	'1';
	elsif state = FEMHEADER_VAL3B then
		data_out <= tp_ff.fem_header3(WORD-1 downto 0);
		valid		<=	'1';
	elsif state = FEMHEADER_VAL3A then
		data_out <= tp_ff.fem_header3(2*WORD-1 downto WORD);
		valid		<=	'1';
	elsif state = FEMHEADER_VAL4B then
		data_out <= tp_ff.fem_header4(WORD-1 downto 0);
		valid		<=	'1';
	elsif state = FEMHEADER_VAL4A then
		data_out <= tp_ff.fem_header4(2*WORD-1 downto WORD);
		valid		<=	'1';
	elsif state = FEMHEADER_FILLER then
		data_out <= X"F000";
		valid		<=	'1';
	elsif state = SUBHEADER2 then
		data_out <= tp_ff.channel_header;
		valid		<=	'1';
	elsif state = SUBHEADER1 then
		data_out <= tp_ff.frame_start;
		valid		<=	'1';
	elsif state = PAYLOAD then
		if payload_pointer = 1 then
			data_out <= X"C" & std_logic_vector(	tp_ff.nb_values			);
		elsif payload_pointer = 0 then
			data_out <= X"C" & std_logic_vector(	tp_ff.integralFull(11 downto 0)	); 
		elsif payload_pointer = 3 then
			data_out <= X"C" & std_logic_vector(	tp_ff.integralFull(23 downto 12)	);
		elsif payload_pointer = 2 then
			data_out <=  X"C" & std_logic_vector(	tp_ff.integralN(11 downto 0)	);
		elsif payload_pointer = 5 then
			data_out <= X"C" & std_logic_vector(	tp_ff.integralN(23 downto 12)	); 
		elsif payload_pointer = 4 then
			data_out<= X"C" & std_logic_vector(	tp_ff.amplitude	);
		end if;
		valid		<=	'1';
	elsif state = ENDOFFRAME2 then
		data_out <= X"E000";
		valid		<=	'1';
	elsif state = ENDOFFRAME1 then
		data_out <= X"0000";
		valid		<=	'1';
	elsif state = ENDOFFEM2 then
		data_out <= X"0000";
		valid		<=	'1';
	elsif state = ENDOFFEM1 then
		data_out <= X"0000";
		valid		<=	'1';
	elsif state = IDLE then
		data_out <= X"0000";
		if lst_buffer = '1' then
			valid		<=	'1';
		else
			valid		<=	'0';
		end if;
	end if;

------------------------------------------------------------------------------------

	if TP_Raw.valid = '1' then
		if (state = PAYLOAD and payload_pointer >= PAYLOAD_LENGTH - 1) then
			if buffer_length_pointer - 1 >= 0 then
				tp_buffer(buffer_length_pointer-1)	<= TP_Raw;
			else	
				tp_buffer(0)	<= TP_Raw;
			end if;
		end if;
	end if;
	if (state = PAYLOAD and payload_pointer >= PAYLOAD_LENGTH - 1) then
		if buffer_length_pointer > 0 then
			buffer_length_pointer	<= buffer_length_pointer - 1;
		end if;
		overflow_flag		<= '0';
	else
		if TP_Raw.valid = '1' then
			if buffer_length_pointer + 1 < BUFFER_LENGTH then
				buffer_length_pointer			<= buffer_length_pointer + 1;
				tp_buffer(buffer_length_pointer)	<= TP_Raw;
				overflow_flag				<= '0';
			else
				overflow_flag				<= '1';
			end if;
		end if;
	end if;

------------------------------------------------------------------------------------

	case state is 
	
	when INIT1 =>
		state <= INIT2;
		fst <= '1';

	when INIT2 =>
		state <= FEMHEADER_VAL1A;
		fst <= '0';

	when FEMHEADER_VAL1A =>
		state <= FEMHEADER_VAL1B;

	when FEMHEADER_VAL1B =>
		state <= FEMHEADER_VAL2A;

	when FEMHEADER_VAL2A =>
		state <= FEMHEADER_VAL2B;

	when FEMHEADER_VAL2B =>
		state <= FEMHEADER_VAL3A;

	when FEMHEADER_VAL3A =>
		state <= FEMHEADER_VAL3B;

	when FEMHEADER_VAL3B =>
		state <= FEMHEADER_VAL4A;

	when FEMHEADER_VAL4A =>
		state <= FEMHEADER_VAL4B;

	when FEMHEADER_VAL4B =>
			state		<= FEMHEADER_FILLER;
			number_filler	<= 0;

	when FEMHEADER_FILLER =>
		if number_filler >= TOTAL_FILLER - 1 then
			state		<= SUBHEADER1;
			number_filler <= 0;
		else 
			number_filler	<= number_filler + 1;	
		end if;

	when SUBHEADER1 =>
		state		<= SUBHEADER2;

	when SUBHEADER2 =>
		state		<= PAYLOAD;
		payload_pointer <= 0;

	when PAYLOAD =>
		if payload_pointer >= PAYLOAD_LENGTH - 1 then
			payload_pointer <= 0;
			if tp_ff.eof = '0' then
				if tp_buffer(1).valid = '1' then
					if (tp_buffer(1).fem_header1 /= tp_ff.fem_header1 or
					tp_buffer(1).fem_header2 /= tp_ff.fem_header2 or
					tp_buffer(1).fem_header3 /= tp_ff.fem_header3 or
					tp_buffer(1).fem_header4 /= tp_ff.fem_header4) then
						state		<= ENDOFFEM1;
						number_filler	<= 0;
					else
						if tp_buffer(1).channel_header /= tp_ff.channel_header  then
							state	<= SUBHEADER1;
						else
							if (tp_buffer(1).frame_start /= tp_ff.frame_start) then
								state <= SUBHEADER1;			

							else
								state <= IDLE;
							end if;
						end if;
					end if;
				else
					state <= IDLE;
				end if;
			else
				state <= ENDOFFRAME1;
				eof <= '1';
			end if;
			for i in 0 to BUFFER_LENGTH-2 loop 
				tp_buffer(i) <= tp_buffer(i+1);
			end loop;
			tp_ff	<= tp_buffer(1);
			tp_ff_old	<= tp_ff;
		else
			payload_pointer <= payload_pointer + 1;
		end if;	

	when ENDOFFRAME1 =>
		state <= ENDOFFRAME2;

	when ENDOFFRAME2 =>
		if tp_ff.valid = '1' then
			state		<= INIT1;
			tp_ff	<= tp_buffer(0);
			eof <= '0';
		else
			state		<= IDLE;
			lst_buffer  <= '1';
		end if;
		number_filler	<= 0;

	when ENDOFFEM1 =>
		state <= ENDOFFEM2;

	when ENDOFFEM2 =>
		state <= FEMHEADER_VAL1A ;

	when IDLE =>
		if tp_buffer(0).valid = '1' then
			if eof = '1' then
				eof <= '0';
				state <= INIT1;
			else
				if (tp_ff_old.fem_header1 /= tp_buffer(0).fem_header1 or
				tp_ff_old.fem_header2 /= tp_buffer(0).fem_header2 or
				tp_ff_old.fem_header3 /= tp_buffer(0).fem_header3 or
				tp_ff_old.fem_header4 /= tp_buffer(0).fem_header4) then
					state		<= FEMHEADER_VAL1A;
					number_filler	<= 0;
				else
					if tp_ff_old.channel_header /= tp_buffer(0).channel_header  then
						state	<= SUBHEADER1;
					else
						if (tp_ff_old.frame_start /= tp_buffer(0).frame_start) then
							state <= SUBHEADER1;			

						else
							state <= PAYLOAD;
						end if;
					end if;
				end if;
			end if;
			tp_ff	<= tp_buffer(0);
		else
			fst   <= '0';
		end if;
		lst_buffer	<= '0';
		--! debug
		write(line_out,888888,right,15); 
		writeline(outfile,line_out);

	end case;	
end if;
end process;
end architecture behavioral;
