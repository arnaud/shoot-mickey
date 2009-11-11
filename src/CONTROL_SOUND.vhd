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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CONTROL_SOUND is
    Port ( CLK, RAZ : in std_logic;
           START : in std_logic;
           STOP : in std_logic;
           NOTES : out std_logic_vector (6 downto 0);
           ON_OFF : out std_logic;
           START_M : out std_logic;
	     	  STATUS : out std_logic_vector(7 downto 0);
           BUSY_M : in std_logic);
end CONTROL_SOUND;

architecture CONTROL of CONTROL_SOUND is


signal ETAT_S : T_ETAT_S;
signal DNOTE : integer range 0 to 63;
signal CNOTE : integer range 0 to NBNOTE;
signal MORCEAU : T_MORCEAU;
signal DUREE: T_DUREE;
signal TMP: integer range 0 to 31;

begin

---------------------------------------------------------
-- séquenceur
P_SEQUENCEUR : process (CLK, RAZ)
begin
	if RAZ = '1' then ETAT_S <= E0;
	elsif CLK'event and CLK = '1' then
		case ETAT_S is
				when E0 => if START = '1' then
									ETAT_S <= E1;
									CNOTE<=0;
					    	  end if;
				when E1 => CNOTE <= CNOTE +1;
					        ETAT_S <= E2;
				when E2 => ON_OFF <= '1';
					        STATUS <= "10010000";
					        START_M <= '1';
					        NOTES <= MORCEAU(CNOTE);
					        if TMP = DNOTE then
									ETAT_S <= E3;
					        end if;
				when E3 => ON_OFF <= '0';
					        STATUS <= "10010000";
					    	  START_M <= '1';
					        NOTES <= MORCEAU(CNOTE);
					        if BUSY_M = '0' then
									ETAT_S <= E4;
					        end if;
				when E4 => ETAT_S <= E5;
					        START_M <= '0';
					        if STOP = '0' then
									ETAT_S <= E5;
					        else
									ETAT_S <= E6;
					    	  end if;
				when E5 => ETAT_S <= E1;
				when E6 => ETAT_S <= E0;
		end case;
	end if;
end process P_SEQUENCEUR;

---------------------------------------------------------
-- génération de la musique de fond jeu 1

P_MUSIC : process(CLK)
begin
	if (CLK'event and CLK='1') then
		if (ETAT_S=E0) then
				--La premiere note joue est l'avant derniere
				--des notes déclarees et on remonte vers la premiere
				MORCEAU <= (CONV_STD_LOGIC_VECTOR(36,7),
								CONV_STD_LOGIC_VECTOR(38,7),
								CONV_STD_LOGIC_VECTOR(40,7),
								CONV_STD_LOGIC_VECTOR(41,7),
								CONV_STD_LOGIC_VECTOR(43,7),
								CONV_STD_LOGIC_VECTOR(41,7),
								CONV_STD_LOGIC_VECTOR(43,7),
								CONV_STD_LOGIC_VECTOR(41,7),
								CONV_STD_LOGIC_VECTOR(40,7),
								CONV_STD_LOGIC_VECTOR(43,7),
								CONV_STD_LOGIC_VECTOR(41,7),										
								CONV_STD_LOGIC_VECTOR(40,7),
								CONV_STD_LOGIC_VECTOR(36,7),
								CONV_STD_LOGIC_VECTOR(40,7),
								CONV_STD_LOGIC_VECTOR(38,7),
								CONV_STD_LOGIC_VECTOR(36,7),
								CONV_STD_LOGIC_VECTOR(36,7),
								CONV_STD_LOGIC_VECTOR(40,7),
								CONV_STD_LOGIC_VECTOR(38,7),
								CONV_STD_LOGIC_VECTOR(36,7),
								CONV_STD_LOGIC_VECTOR(36,7));
				DUREE <= (1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000);
		end if;
	end if;		
end process P_MUSIC;

---------------------------------------------------------
-- control de la durée d'une note

P_NOTE : process(CLK)
begin
	if (CLK'event and CLK='1') then
		if (ETAT_S=E2) then
			DNOTE <= DUREE(CNOTE);
		end if;
	end if;
end process P_NOTE;

---------------------------------------------------------
-- TIMER

P_TMP : process(CLK)
begin
	if (CLK'event and CLK='1') then
		if (ETAT_S=E0) then
			TMP <= 0;
		elsif (ETAT_S=E2) then
			TMP <= TMP +1;
		end if;
	end if;
end process P_TMP;


end CONTROL;
