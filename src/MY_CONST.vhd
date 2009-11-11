--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--------------------------------------------------------------------------------
package My_Const is
	-------------------------------------------
	-- Constantes modifiables
	-------------------------------------------

	-- Vitesse du jeu
	constant N_TIMER_MAX : integer := 2**25;
	-- Nombre de tirs par partie
	constant N_TIRS_MAX : integer := 10;
	-- Score donné pour la dernière balle
	constant N_LAST_POINTS : integer := 10;
	-- Positionnement des sprites
	constant X_DEB_INTRO : integer := 178; -- Image d'intro
	constant Y_DEB_INTRO : integer := 83;  --
	constant X_DEB_BG : integer := 20; -- Arrière-plan
	constant Y_DEB_BG : integer := 80; --
	constant X_FIN_BG : integer := 580;--
	constant Y_FIN_BG : integer := 460;--
	constant X_DEB_BR : integer := 20; -- Barre de rapidité
	constant Y_DEB_BR : integer := 45; --
	constant X_FIN_BR : integer := 400;--
	constant Y_FIN_BR : integer := 65; --
	constant X_DEB_BR_TXT : integer := X_DEB_BR+10; -- Texte de la barre de rapidité
	constant Y_DEB_BR_TXT : integer := Y_FIN_BR-4;  --
	constant X_DEB_CHARGEUR : integer := 589; -- Chargeur
	constant Y_DEB_CHARGEUR : integer := 79;  --
	constant X_DEB_BALLES : integer := X_DEB_CHARGEUR+9; -- Balle
	constant Y_DEB_BALLES : integer := Y_DEB_CHARGEUR+5; --
	constant X_DEB_SCORE_BG : integer := 440; -- Pourtour du score
	constant Y_DEB_SCORE_BG : integer := 65;  --
	constant X_DEB_SCORE_TXT : integer := X_DEB_SCORE_BG+10;	-- Texte du score
	constant Y_DEB_SCORE_TXT : integer := Y_DEB_SCORE_BG-4;  --
	constant X_DEB_TITRE : integer := 94; -- Titre
	constant Y_DEB_TITRE : integer := 4;  --
	constant X_DEB_PAUSE : integer := 23; -- Pause (entre 0 et 79)
	constant Y_DEB_PAUSE : integer := 27; --       (entre 0 et 59)
	constant X_DEB_GAME_OVER : integer := 11; -- Game Over (entre 0 et 79)
	constant Y_DEB_GAME_OVER : integer := 27; --           (entre 0 et 59)
	-- Constantes de son
	constant NBNOTE : integer := 21;
	constant NB_BIT : integer := 7; 

--------------------------------------------------------------------------------
	-------------------------------------------
	-- Constantes non modifiables
	-------------------------------------------

	-- Constantes de limitation du score
	constant N_SCORE_MAX : integer := 99;
	-- Constantes de périphériques
	constant SCR_WIDTH_MAX : integer := 799;
	constant SCR_HEIGHT_MAX : integer := 524;
	constant SCR_WIDTH : integer := 639;
	constant SCR_HEIGHT : integer := 479;
	-- Constantes de son
	constant velocite_on  : std_logic_vector(7 downto 0) := "01111111";
   constant velocite_off : std_logic_vector(7 downto 0) := "00000000";
	-- Constantes des couleurs
	constant C_NOIR :    std_logic_vector(0 to 2) := "000";
	constant C_BLEU :    std_logic_vector(0 to 2) := "001";
	constant C_VERT :    std_logic_vector(0 to 2) := "010";
	constant C_CYAN :    std_logic_vector(0 to 2) := "011";
	constant C_ROUGE :   std_logic_vector(0 to 2) := "100";
	constant C_MAGENTA : std_logic_vector(0 to 2) := "101";
	constant C_JAUNE :   std_logic_vector(0 to 2) := "110";
	constant C_BLANC :   std_logic_vector(0 to 2) := "111";
--------------------------------------------------------------------------------
end My_Const;
