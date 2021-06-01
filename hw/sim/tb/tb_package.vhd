library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all; -- require for writing std_logic etc.

package tb_package is
	type doubleword_array is array (integer range <>) of std_logic_vector(31 downto 0);
end tb_package;
