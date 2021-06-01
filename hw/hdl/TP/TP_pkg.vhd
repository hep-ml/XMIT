library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
package TP_pkg is
 
	constant WORD 				: natural := 16;
	constant SIGNIFICANT_HEADER_LENGTH 	: natural := 4;
	constant TOTAL_HEADER_LENGTH 		: natural := 6;
	constant TOTAL_FILLER			: natural := 4;


	subtype fem_header_t is std_logic_vector(2*WORD-1 downto 0);
	subtype word_t is std_logic_vector(WORD-1 downto 0);
	subtype tp_value_t is unsigned(11 downto 0);
	subtype tp_double_value_t is unsigned(23 downto 0);

	-- TP between TP_generator and TP_buffer
	type generator_to_buffer_t is record
		fem_header1	: fem_header_t;                
		fem_header2	: fem_header_t;                
		fem_header3	: fem_header_t;                
		fem_header4	: fem_header_t;                
		channel_header	: word_t;
		frame_start	: word_t;
		nb_values	: tp_value_t;
		amplitude	: tp_value_t;
		integralFull	: tp_double_value_t;
		integralN	: tp_double_value_t;
		eof		: std_logic;
		valid		: std_logic;
	end record generator_to_buffer_t;  

	type tp_buffer_array is array (natural range <>) of generator_to_buffer_t;

	constant init_g	: generator_to_buffer_t :=	(fem_header1	=> (others => '0'),
							fem_header2	=> (others => '0'),
							fem_header3	=> (others => '0'),
							fem_header4	=> (others => '0'),
							channel_header	=> (others => '0'),
							frame_start	=> (others => '0'),
							nb_values	=> (others => '0'),
							amplitude	=> (others => '0'),
							integralFull	=> (others => '0'),
							integralN	=> (others => '0'),
							eof		=> '0',
							valid		=> '0');	
end package TP_pkg;

package body TP_pkg is
	--
end TP_pkg;
