--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.MY_CONST.ALL;
--------------------------------------------------------------------------------
package MY_TYPES is
	type T_SEQUENCEUR is (E0,E1,E2,E3);
	type T_IMPACTS_X is array(0 to N_TIRS_MAX-1) of integer range X_DEB_BG/2 to X_FIN_BG/2;
	type T_IMPACTS_Y is array(0 to N_TIRS_MAX-1) of integer range Y_DEB_BG/2 to (Y_FIN_BG+16)/2;
	type T_MORCEAU is array (20 downto 0) of std_logic_vector(6 downto 0);
	type T_DUREE is array (20 downto 0) of integer range 0 to 1023;
	type T_ETAT_MIDI is (E0,E1,E2,E3);
	type T_ETAT_S is (E0,E1,E2,E3,E4,E5,E6);
	type T_ETAT_UART is (E0,E1,E2,E3);		
--------------------------------------------------------------------------------
end MY_TYPES;
