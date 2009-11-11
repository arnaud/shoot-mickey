----------------------------------------------------------------
-- Generateur video des caractères de l'affichage du score
-- Les chiffres sont matricés  en pavés 8x8 pixels.
-- Cette entity fait appel à l'entity GEN_CHIFFRE
-- Le tout est asynchrone (uniquement combinatoire)
----------------------------------------------------------------
-- D.Genet Avril 2004
----------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.MY_CONST.ALL;
----------------------------------------------------------------
entity video_score is

	port(	score : in integer range 0 to N_SCORE_MAX;
			X : in integer range 0 to SCR_WIDTH_MAX;
		  	Y : in integer range 0 to SCR_HEIGHT_MAX;
			VS : out std_logic);
end  video_score;	
----------------------------------------------------------------
architecture Arch_video_score of video_score is

component GEN_CHIFFRE 

	port(	CHIFFRE : in integer range 0 to 9;
		  	YC : in integer range 0 to 7;
			XC : in integer range 0 to 7;
			VALID : in std_logic;
			VC : out std_logic);
end component;


signal XD : integer range 0 to 9;		-- abscisse des pavés 8x8 des chiffres
signal YD : integer range 0 to 8;		-- ordonnée des pavés 8x8 des chiffres
signal X_DOT : integer range 0 to 7;	-- abscisse des pavés 8x8 des unités
signal Y_DOT : integer range 0 to 7;	-- ordonnée des pavés 8x8 des unités

signal CHIFFRE_A_AFFICHER : integer range 0 to 9;
signal EN_DISP : std_logic;		  
signal xscore : integer range 0 to N_SCORE_MAX;	  
----------------------------------------------------------------
begin

XD <= X/64;	 -- abcisse des matrices
YD <=  Y/64; -- ordonnée des matrices

X_DOT <= X/8; -- abcisse des points
Y_DOT <= Y/8; -- ordonnées des points

EN_DISP <= '1' when YD=0 and (XD=7 or XD=8 or XD=9) else '0';

------------------------------------------------
-- instanciation du générateur de chiffres
DISP : GEN_CHIFFRE
	port map(
		CHIFFRE => CHIFFRE_A_AFFICHER,
		YC => Y_DOT,
		XC => X_DOT,
		VALID => EN_DISP,
		VC => VS
	);
------------------------------------------------
P_CHIFFRE_A_AFFICHER : process (SCORE, XD)
begin
	if score < 10 then		  	
		if (XD=9) then
	    	CHIFFRE_A_AFFICHER <= SCORE; 
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 0;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 20 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 10;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 1;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 30 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 20;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 2;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 40 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 30;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 3;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 50 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 40;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 4;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 60 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 50;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 5;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 70 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 60;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 6;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 80 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 70;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 7;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	elsif score < 90 then
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 80;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 8;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
	else
		if (XD=9) then
			CHIFFRE_A_AFFICHER <= SCORE - 90;
		elsif (XD=8) then
			CHIFFRE_A_AFFICHER <= 9;
		elsif (XD=7) then
			CHIFFRE_A_AFFICHER <= 0;
		end if;
--	else
--		if (XD=9) then
--			CHIFFRE_A_AFFICHER <= 0;
--		elsif (XD=8) then
--			CHIFFRE_A_AFFICHER <= 0;
--		elsif (XD=7) then
--			CHIFFRE_A_AFFICHER <= 1;
--		end if;
	end if;
end process P_CHIFFRE_A_AFFICHER;
------------------------------------------------
end Arch_video_score;