library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all; -- require for writing std_logic etc.

library work;
use work.tb_package.all;
use work.input.all;
use work.TP_pkg.all;
use work.all;

entity tp_tb is
end tp_tb ;

architecture tb of tp_tb is
-- Constants
  file outfile : text open write_mode is "TP_FRAMES.txt";

  constant clock_period : time := 60 ns;
  constant reset_time : time := 10 * clock_period;
--  constant threshold1 : unsigned(11 downto 0) := "001010111100";--700
--  constant threshold2 : unsigned(11 downto 0) := "001011101110";--750
--  constant threshold3 : unsigned(11 downto 0) := "001100001100";--780
--  constant threshold1 : unsigned(11 downto 0) := "000000000001";
--  constant threshold2 : unsigned(11 downto 0) := "000010000000";
--  constant threshold3 : unsigned(11 downto 0) := "100000000000";
--  constant N_value    : unsigned(31 downto 0) := "00000000000000000000000000000110";
  

-- Control Signals    
    signal clock196 : std_logic := '0' ; 
    signal rst : std_logic := '0';
    signal data_in : std_logic_vector(31 downto 0) := (others => '0');
    signal thresholds : std_logic_vector(36*64-1 downto 0);
    signal output : std_logic_vector(WORD+2-1 downto 0) := (others => '0');
    signal N : std_logic_vector(31 downto 0) := (others => '0');
    signal valid: std_logic := '0';
    signal TP_Raw : generator_to_buffer_t;
    signal overflow_flag : std_logic;
component TP_module is
port (
	clk196 		: in std_logic;
	rst		: in std_logic;
	data_in		: in std_logic_vector(31 downto 0);
	data_out	: out std_logic_vector(17 downto 0);
	overflow	: out std_logic;
	valid		: out std_logic
);
end component TP_module;

begin
--   generate_thresholds : for i in 0 to 63 generate
--	    thresholds(35+(36*i) downto 24+(36*i)) <= std_logic_vector(threshold3);
--	    thresholds(23+(36*i) downto 12+(36*i)) <= std_logic_vector(threshold2);
--	    thresholds(11+(36*i) downto 0+(36*i))  <= std_logic_vector(threshold1);
--    end generate;
--    N                        <= std_logic_vector(N_value);
    
    TP_inst : component TP_module
    port map (
	clk196		=> clock196,
	rst		=> rst,
	data_in		=> data_in,
	data_out	=> output,
	overflow	=> overflow_flag,
	valid		=> valid
    );


    clk196 : process
    begin
	for i in 0 to 2*number_of_doublewords+500 loop
		clock196 <= not(clock196) ;
		wait for clock_period/2;
	end loop;
        wait;
    end process; 

    reset : process
    begin
	rst <= '1';
	wait for reset_time;
	rst <= '0';
        wait;
    end process; 

    run : process
    begin
	wait for 1 ns;
	data_in <= (others => '0');
	wait for 2*reset_time;
        for i in 0 to number_of_doublewords-1 loop
		data_in <= rundata(number_of_doublewords-1-i);
		wait for clock_period;
	end loop;		
	wait;
    end process;

    write_output : process
    variable line_out : line;
    begin
	for i in 0 to 2*number_of_doublewords+500 loop
		if valid = '1' then
			--write(line_out,to_integer(unsigned(output)));
			write(line_out,(output(17 downto 2)));
			writeline(outfile,line_out);
	--		write(line_out,overflow_flag);
	--		writeline(outfile,line_out);
		end if;
		wait for clock_period;
	end loop;
	wait;
    end process;
end tb;
