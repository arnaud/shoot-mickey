--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MY_TYPES.ALL;
use work.MY_CONST.ALL;

entity GENERATEUR_MIDI is
    Port ( CLK, RAZ : in std_logic;
           NOTES : in std_logic_vector (6 downto 0);
           ON_OFF : in std_logic;
           START_M : in std_logic;
           BUSY_M : out std_logic;
           BUSY_UART : in std_logic;
           START_UART : out std_logic;
	        STATUS: in std_logic_vector(7 downto 0); 
           DATA : out std_logic_vector (7 downto 0));
end GENERATEUR_MIDI;

architecture GENERATEUR of GENERATEUR_MIDI is

signal ETAT_MIDI  : T_ETAT_MIDI;
----------------------------------------------------------

begin
---------------------------------------------------------
-- séquencement de l'envoi des 3 octets constituant la note
P_SEQUENCEUR : process (CLK, RAZ)
begin
	if RAZ = '1' then ETAT_MIDI <= E0;
	elsif CLK'event and CLK = '1' then
		case ETAT_MIDI is
			when E0 => BUSY_M <= '0';
				        if START_M ='1' then
					 			ETAT_MIDI <= E1;
				        end if;
			when E1 => BUSY_M <= '1';
				        START_UART <= '1';
				        DATA <= STATUS;
				        if BUSY_UART ='0' then
								ETAT_MIDI <= E2;
				        end if;
			when E2 => BUSY_M <= '1';
				        START_UART <= '1';
				        DATA(7) <= '0';
				        DATA(6 downto 0) <= NOTES;
				        if BUSY_UART ='0' then
								ETAT_MIDI <= E3;
				        end if;
			when E3 => BUSY_M <= '1';
				        START_UART <= '1';
				        if ON_OFF='1' then
								DATA <= velocite_on;
				        else
								DATA <= velocite_off;
				        end if;
				        if BUSY_UART ='0' then
								ETAT_MIDI <= E0;
				        end if;
		end case;
	end if;
end process P_SEQUENCEUR;


end GENERATEUR;
