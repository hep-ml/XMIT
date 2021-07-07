library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--debugging
library std;
use std.textio.all;
use ieee.std_logic_textio.all; --require for writing std_logic etc.

use work.TP_pkg.all;


entity TP_module is
port (
	clk196 		: in std_logic;
	rst		: in std_logic;
	data_in		: in std_logic_vector(31 downto 0);
	data_out	: out std_logic_vector(17 downto 0);
	overflow	: out std_logic;
	valid		: out std_logic
);
end TP_module;

architecture rtl of TP_module is

component TP_generator is
    generic (
	N		: natural := 12
);
    port (
	clk196 		: in std_logic;
	rst		: in std_logic;
	data_in		: in std_logic_vector(31 downto 0);
	TP_Raw		: out generator_to_buffer_t
);
end component TP_generator;

component TP_buffer is
    generic (
	BUFFER_LENGTH	: natural := 64;
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
end component TP_buffer;

signal TP_Raw : generator_to_buffer_t;
signal fst	: std_logic;
signal lst	: std_logic;
signal overflow_buffer	: std_logic;
signal TP_signal: std_logic_vector(15 downto 0);

begin
	
    --data_out(0) <= '1' when TP_signal = X"FFFF" else '0';
    data_out(0) <= fst;
    --data_out(1) <= '1' when TP_signal = X"E000" else '0';
    data_out(1) <= lst;
    --data_out(17 downto 2) <= TP_signal when overflow_buffer = '0' else X"DEAD";
    data_out(17 downto 2) <= TP_signal;
    overflow <= overflow_buffer;

    TP_generator_inst : component TP_generator 
    port map (
	clk196		=> clk196,
	rst		=> rst,
	data_in		=> data_in,
	TP_Raw		=> TP_Raw
    );

    TP_buffer_inst : component TP_buffer
    generic map (
	BUFFER_LENGTH	=> 128,
	PAYLOAD_LENGTH	=> 6
    )
    port map (
	clk196		=> clk196,
	rst		=> rst,
	TP_Raw		=> TP_Raw,
	data_out	=> TP_signal,
	overflow_flag	=> overflow_buffer,
	fst		=> fst,
	lst		=> lst,
	valid		=> valid
    );

sequential : process (clk196, rst) -- sensitivity list
begin

if rst = '1' then

elsif (clk196 ='1' and clk196'event) then

end if;
end process;

end architecture rtl;
