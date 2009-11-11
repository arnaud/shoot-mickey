--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MY_CONST.ALL;
use work.MY_TYPES.ALL;

entity CORE is
	Port(
		-- Entrées/sorties du système 
		CLK, RAZ: in std_logic;
		NEW_GAME: in std_logic;
		PAUSE: in std_logic;
		EN_PAUSE: out std_logic;
		EN_INTRO: out std_logic;
		XV : in integer range 0 to SCR_WIDTH_MAX;
		YV : in integer range 0 to SCR_HEIGHT_MAX;
		BG, BD : in std_logic;
		XL : out integer range 0 to SCR_WIDTH_MAX;
		YL : out integer range 0 to SCR_HEIGHT_MAX;
		IMPACTS_X : out T_IMPACTS_X;
		IMPACTS_Y : out T_IMPACTS_Y;
		TPS_CLIC : out integer range 0 to N_TIMER_MAX;
		SCORE : out integer range 0 to N_SCORE_MAX;
		TIRS : out integer range 0 to N_TIRS_MAX;
		SS : out integer range 0 to 7;
		START : out std_logic;
      STOP : out std_logic
	);
end CORE;
---------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------- 
architecture Arch_CORE of CORE is

-- signaux internes
signal SEQUENCEUR: T_SEQUENCEUR; -- états du séquenceur
signal XXL: integer range 0 to SCR_WIDTH_MAX;
signal YYL: integer range 0 to SCR_HEIGHT_MAX;
signal XSCORE: integer range 0 to N_SCORE_MAX;
signal XTIRS: integer range 0 to N_TIRS_MAX;
signal TIMER_M: integer range 0 to N_TIMER_MAX;
signal XTPS_CLIC: integer range 0 to N_TIMER_MAX;
signal COUP, COUP1, COUP2, COUP3: bit;			  
signal XPAUSE1, XPAUSE2, XPAUSE3: bit;			  
signal POS_X: integer range X_DEB_BG to X_FIN_BG-31;
signal POS_Y: integer range Y_DEB_BG to Y_FIN_BG-31;
signal MICKEY_TOUCHE: std_logic;
signal XEN_PAUSE: std_logic;
signal DANS_ZONE_TIRS: boolean;
--------------------------------------------------------------------------------
-- Composant RANDOM
component RANDOM
	generic(
		MIN : integer;
		MAX : integer;
		N_BIT_REG : integer);
	Port(
		-- Entrées/sorties du système
		CLK : in std_logic;
		NOMBRE : out integer range 0 to SCR_WIDTH);
end component;
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------- 
begin
--------------------------------------------------------------------------------
-- Déclaration des components
COMP_RANDOM_X : RANDOM
	generic map (MIN => X_DEB_BG, MAX => X_FIN_BG-31, N_BIT_REG => 10) 
	Port map(
		CLK => CLK,
		NOMBRE => POS_X);

COMP_RANDOM_Y : RANDOM 
	generic map (MIN => X_DEB_BG, MAX => X_FIN_BG-31, N_BIT_REG => 9) 
	Port map(
		CLK => CLK,
		NOMBRE => POS_Y);
--------------------------------------------------------------------------------
-- signaux asynchrones
XL <= XXL;
YL <= YYL;
SCORE <= XSCORE;
TIRS <= XTIRS;
COUP <= COUP1 and not COUP2;
EN_PAUSE <= XEN_PAUSE;
EN_INTRO <= '1' when SEQUENCEUR=E0 else '0';
TPS_CLIC <= XTPS_CLIC;
DANS_ZONE_TIRS <= XV+16>X_DEB_BG and XV+16<X_FIN_BG and YV+16>Y_DEB_BG and YV+16<Y_FIN_BG;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Gestion de l'état de la pause
P_ETAT_PAUSE : process(CLK,RAZ)
begin
	if RAZ='1' then
		XEN_PAUSE <= '0';
	elsif CLK'EVENT and CLK = '1' then
		if XPAUSE1='1' and XPAUSE2='0' then
			XEN_PAUSE <= not XEN_PAUSE;
		else
			XEN_PAUSE <= XEN_PAUSE;
		end if;
	end if;
end process P_ETAT_PAUSE;
----------------------------------------------------------------------------------
-- Synchronisation pour déterminer si le coup vient d'être donné
SYNCHRO_COUP : process(CLK)
begin
	if CLK'event and CLK = '1' then
		if SEQUENCEUR = E0 then
			COUP1 <= '0';
			COUP2 <= '0';
		else
			COUP1 <= COUP3;
			COUP2 <= COUP1;
		end if;
	end if;
end process SYNCHRO_COUP;
---------------------------------------------------------------------------------- 
-- Gestion des coups
P_COUP: process(CLK,BG)
begin
	if (CLK'event and CLK='1') then
		if SEQUENCEUR = E1 then COUP3 <= '0';
		elsif SEQUENCEUR = E2 then
			if BG = '1' then
				COUP3 <= '1';
			else
				COUP3 <= '0';
			end if;
		end if;
	end if;
end process P_COUP;
----------------------------------------------------------------------------------
-- Synchronisation pour déterminer si la pause est activée
SYNCHRO_PAUSE : process(CLK)
begin
	if CLK'event and CLK = '1' then
		if SEQUENCEUR = E0 then
			XPAUSE1 <= '0';
			XPAUSE2 <= '0';
		else
		  XPAUSE1 <= XPAUSE3;
		  XPAUSE2 <= XPAUSE1;
		end if;
	end if;
end process SYNCHRO_PAUSE;
---------------------------------------------------------------------------------- 
-- Gestion de la pause
P_PAUSE: process(CLK,PAUSE)
begin
	if (CLK'event and CLK='1') then
		if SEQUENCEUR = E2 then
			if PAUSE = '1' then
				XPAUSE3 <= '1';
			else
				XPAUSE3 <= '0';
			end if;
		end if;
	end if;
end process P_PAUSE;
---------------------------------------------------------------------------------- 
-- Incrémentation du Timer du Mickey (plus le score augmente, plus le compteur diminue)
P_TIMER: process(CLK)
begin
	if (CLK'event and CLK='1') then
		if XEN_PAUSE = '1' then
			TIMER_M <= TIMER_M;
		elsif MICKEY_TOUCHE = '1' or TIMER_M > N_TIMER_MAX - 3*XSCORE * (N_TIMER_MAX/2**8) then
			TIMER_M <= 0; -- réinitialisation du Timer du Mickey quand Mickey touché
		else
			TIMER_M <= TIMER_M + 1;	-- incrémentation du Timer
		end if;
	end if;
end process P_TIMER;
---------------------------------------------------------------------------------- 
-- Gestion du temps de clic
P_TPS_CLIC: process(CLK,RAZ)
begin
	if RAZ='1' then
		XTPS_CLIC <= N_TIMER_MAX;
	elsif (CLK'event and CLK='1') then
		if MICKEY_TOUCHE='1' then
			XTPS_CLIC <= TIMER_M;
		else
			XTPS_CLIC <= XTPS_CLIC;
		end if;
	end if;
end process P_TPS_CLIC;
---------------------------------------------------------------------------------- 
-- Gestion de l'état du mickey (touché/non touché)
P_MICKEY_TOUCHE: process(CLK)
begin
	if (CLK'event and CLK='1') then
		if (SEQUENCEUR = E2 and XV+16>=XXL and XV+16<=XXL+62 and YV+16>=YYL and YV+16<=YYL+59) then
			if COUP = '1' then
				MICKEY_TOUCHE <= '1';
			else
				MICKEY_TOUCHE <= '0';
			end if;
		end if;
	end if;
end process P_MICKEY_TOUCHE;
---------------------------------------------------------------------------------- 
-- Gestion du compteur de score (incrémentation fonction de la rapidité de clic)
P_SCORE: process(CLK,RAZ)
begin
	if RAZ='1' then
		XSCORE <= 0;
	elsif (CLK'event and CLK='1') then
		if SEQUENCEUR = E1 then XSCORE <= 0;
		elsif (SEQUENCEUR = E2 and MICKEY_TOUCHE = '1') then
			if XTIRS = N_TIRS_MAX then
				XSCORE <= XSCORE + N_LAST_POINTS;
			else
				XSCORE <= XSCORE + (4 * (N_TIMER_MAX - TIMER_M)) / N_TIMER_MAX + 1;
			end if;
		end if;
	end if;
end process P_SCORE;
---------------------------------------------------------------------------------- 
-- Gestion du compteur de tirs (condition : être dans la zone de tir au centre)
P_TIRS: process(CLK,RAZ)
begin
	if RAZ='1' then
		XTIRS <= 0;
	elsif (CLK'event and CLK='1') then
		if SEQUENCEUR = E1 then XTIRS <= 0; -- initialisation
		elsif SEQUENCEUR = E2 then
			if COUP = '1' and DANS_ZONE_TIRS then
				XTIRS <= XTIRS + 1 ;
			end if;
		end if;
	end if;
end process P_TIRS;
---------------------------------------------------------------------------------- 
-- Gestion des impacts
P_IMPACTS: process(CLK,RAZ)
begin
	if RAZ = '1' then -- initialisation
		for I in 0 to N_TIRS_MAX-1 loop
			IMPACTS_X(I) <= X_FIN_BG/2;		-- abscisse en dehors de l'écran
			IMPACTS_Y(I) <= (Y_FIN_BG+16)/2;	-- ordonnée en dehors de l'écran
		end loop;
	elsif (CLK'event and CLK='1') then
		if SEQUENCEUR = E0 then
			for I in 0 to N_TIRS_MAX-1 loop
				IMPACTS_X(I) <= X_FIN_BG/2;
				IMPACTS_Y(I) <= (Y_FIN_BG+16)/2;
			end loop;
		elsif SEQUENCEUR = E2 and COUP = '1' and DANS_ZONE_TIRS then
			IMPACTS_X(XTIRS) <= (XV + 16)/2;
			IMPACTS_Y(XTIRS) <= (YV + 16)/2;
		end if;
	end if;
end process P_IMPACTS;
---------------------------------------------------------------------------------- 
-- Gestion du son
P_SS: process(CLK)
begin
	if (CLK'event and CLK='1') then
		if SEQUENCEUR = E2 then
			if MICKEY_TOUCHE = '1' then -- tir réussi
				SS <= 1;
			elsif COUP = '1' then -- tir raté
				SS <= 2;
			end if;
		end if;
	end if;
end process P_SS;
---------------------------------------------------------------------------------- 
-- Gestion de la position du Mickey
P_POSITION: process(CLK)
begin
	if (CLK'event and CLK='1') then
		if SEQUENCEUR = E2 then
			if (TIMER_M = 0) then -- Position X du Mickey dans le plateau
				if (POS_X >=X_DEB_BG and POS_X <X_FIN_BG-31) then
					XXL <= POS_X;
				elsif (POS_X >=X_FIN_BG-31) then
					XXL <= POS_X-(SCR_WIDTH-X_FIN_BG);
				elsif (POS_X <X_DEB_BG) then
					XXL <= POS_X+X_DEB_BG;
				end if;
			elsif (TIMER_M = 1) then -- Position Y du Mickey dans le plateau  
				if (POS_Y >=Y_DEB_BG and POS_Y <Y_FIN_BG-31) then
					YYL <= POS_Y;
				elsif (POS_Y >=380) then
					YYL <= POS_Y-(SCR_HEIGHT-Y_DEB_BG);
				else
					YYL <= POS_Y+Y_DEB_BG;
				end if;
			end if;
		end if;
	end if;
end process P_POSITION;
---------------------------------------------------------------------------------- 
-- Séquenceur principal du jeu
P_SEQUENCEUR: process(CLK,RAZ,NEW_GAME,BG)
begin
	if RAZ='1' then SEQUENCEUR <= E0;
	elsif (CLK'event and CLK='1') then
		case SEQUENCEUR is
			when E0 => if BG='1' then SEQUENCEUR <= E1; end if;
						  START <= '1';
						  STOP <= '0';
			when E1 => SEQUENCEUR <= E2;
			when E2 => if XTIRS=N_TIRS_MAX then SEQUENCEUR <= E3; end if;
			when E3 => if NEW_GAME='1' then SEQUENCEUR <= E0; end if;
						  START <= '0';
						  STOP <= '1';
		end case;
	end if;
end process P_SEQUENCEUR;
---------------------------------------------------------------------------------- 

end Arch_CORE;
