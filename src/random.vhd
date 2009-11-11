------------------------------------------------------------------------
-- RANDOM.VHD : Générateur pseudo-aléatoire de nombres
-- D.GENET - Nov. 2004
------------------------------------------------------------------------
-- Paramètres génériques :
--   N_BIT_REG : nb de bits du générateur
--   MAX : taille maxi des entiers à produire
------------------------------------------------------------------------
-- Le caractère pseudo aléatoire sera d'autant plus vrai que la longueur
-- du registre utilisé (paramètre générique N_BIT_REG)est élevée.
-- La taille du nombre retourné est fonction du paramètre générique
-- MAX. Par défaut le registre REG utilisé ainsi que le nombre produit
-- sont ajustés à 8 bits.
-- NB : ce component n'est pas supporté par MAX+II
------------------------------------------------------------------------
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.MY_CONST.ALL;
------------------------------------------------------------------------
entity RANDOM is
	generic(
		MIN : integer := 0;
		MAX : integer := 639;
		N_BIT_REG : integer := 10);
	port (
		CLK : in std_logic;
		NOMBRE : out integer range MIN to MAX);
end RANDOM;
------------------------------------------------------------------------
architecture ARCH_RANDOM of RANDOM is

signal REG : std_logic_vector(0 to N_BIT_REG-1):= (others =>'0');
signal REG_OUT : std_logic_vector(0 to N_BIT_REG-1);


function N_BIT(constant MAX : integer) return integer is
variable N: integer;
begin
N:= 0;
for I in 0 to N_BIT_REG loop
	if MAX+1>= 2**I then 
		N:= N+1;
	end if;	
end loop;
return N-1;
end N_BIT;
------------------------------------------------------------------------

begin

P_REG : process (CLK)
variable LAST,FIRST,NB_BIT_OUT : integer;
begin
	LAST := N_BIT_REG-1;
	NB_BIT_OUT := N_BIT(MAX)-1;
	case N_BIT_REG is
		when 04 => FIRST := 0;
		when 05 => FIRST := 1;
		when 06 => FIRST := 0;
		when 07 => FIRST := 2;
		when 08 => FIRST := 2;
		when 09 => FIRST := 3;
		when 10 => FIRST := 2;
		when 11 => FIRST := 1;
		when 12 => FIRST := 0;
		when 13 => FIRST := 0;
		when 14 => FIRST := 0;
		when 15 => FIRST := 0;
		when 16 => FIRST := 2;
		when 17 => FIRST := 2;
		when others => FIRST := 0;
	end case;

	if CLK'event and CLK='1' then
		REG(0) <= not(REG(LAST) xor REG(FIRST));
		REG(1 to LAST)<= REG(0 to LAST-1); 
    end if;

	REG_OUT <= (others => '0');
	REG_OUT(0 to NB_BIT_OUT) <= REG(0 to NB_BIT_OUT);

end process P_REG;
NOMBRE <= conv_integer(REG);
end ARCH_RANDOM;
------------------------------------------------------------------------
