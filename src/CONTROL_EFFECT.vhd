--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CONTROL_EFFECT is
    Port ( CLK, RAZ : in std_logic;
           START : in std_logic;
           STOP : in std_logic;
           NOTES : out std_logic_vector (6 downto 0);
           ON_OFF : out std_logic;
	     SS : integer range 0 to 2;
           START_M : out std_logic;
	     STATUS : out std_logic_vector(7 downto 0);
           BUSY_M : in std_logic);
end CONTROL_EFFECT;

architecture EFFECT of CONTROL_EFFECT is

type T_ETAT_S is (E0,E1);

constant NBNOTE : integer := 20;
signal ETAT_S : T_ETAT_S;
signal DNOTE : integer 0 range to 63;
signal CNOTE : integer 0 to NBNOTE;
signal MORCEAU : T_MORCEAU;
signal DUREE: T_DUREE;
signal TIMER: integer 0 range to 31;

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
				when E1 => TIMER = 0;
					     CNOTE <= CNOTE +1;
					     ETAT_S <= E2;
				when E2 => ON_OFF <= '1';
					     STATUS <= "10010001";
					     START_M <= '1';
					     if SS = 1 then
							NOTES <= EFFECT1;
					     elsif SS = 2
							NOTES <= EFFECT2;
					     end if;
					     if timer = 1000 then
							ETAT_S <= E3;
					     end if;
				when E3 => ON_OFF <= '0';
					     STATUS <= "10010001";
					     START_M <= '1';
					     if SS = 1 then
							NOTES <= EFFECT1;
					     elsif SS = 2
							NOTES <= EFFECT2;
					     end if;
					     if BUSY_M = 0 then
							ETAT_S <= E4;
					     end if;
				when E4 => ETAT_S <= E5;
					     START_M <= '0';
					     if STOP = 0 then
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
-- génération des effets

P_MUSIC : process(CLK)
begin
	if (CLK'event and CLK='1') then
		if (ETAT_S=E0) then
				--La premiere note joue est l'avant derniere
				--des notes déclarees et on remonte vers la premiere
				EFFECT1 <= (CONV_STD_LOGIC_VECTOR(36,7));
				EFFECT2 <= (CONV_STD_LOGIC_VECTOR(37,7));
		end if;
	end if;		
end process P_MUSIC;
---------------------------------------------------------
-- TIMER

P_TIMER : process(CLK)
begin
	if (CLK'event and CLK='1') then
		if (ETAT_S=E2) then
			TIMER <= TIMER +1;
		endif;
	endif;
end process P_TIMER;
---------------------------------------------------------
---------------------------------------------------------
end CONTROL;

