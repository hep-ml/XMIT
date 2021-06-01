library ieee;
use ieee.std_logic_1164.all;
library work;
use work.tb_package.all;

package input is
  constant number_of_doublewords : natural := LENGTHPLACEHOLDER
  
  constant rundata : doubleword_array(number_of_doublewords-1 DOWNTO 0) := (
----HERE COMES THE DATA IN 32BIT CHUNKS---- DATAPLACEHOLDER
----END OF DATA WORD----
);
end input;
