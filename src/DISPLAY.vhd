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
use work.SPRITES.ALL;

entity DISPLAY is
	Port(
-- Entrées/sorties du système 
	CLK: in std_logic;
	EN_PAUSE: in std_logic;
	EN_INTRO: in std_logic;
	XV, XL: in integer range 0 to SCR_WIDTH_MAX;
	YV, YL: in integer range 0 to SCR_HEIGHT_MAX;
	IMPACTS_X : in T_IMPACTS_X;
	IMPACTS_Y : in T_IMPACTS_Y;
	TPS_CLIC : in integer range 0 to N_TIMER_MAX;
	SCORE: in integer range 0 to N_SCORE_MAX;
	TIRS: in integer range 0 to N_TIRS_MAX;
	VSYNC, HSYNC: out std_logic;
	RVB: out std_logic_vector(0 to 2));
end DISPLAY;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
architecture Arch_DISPLAY of DISPLAY is

-- Signaux internes
signal VV, VVO, VL, VS, VS2, VB, VB2, VI, VC, VBG, VBG2, VR, VR2, VTB, VTS, VT, VT2, VP, VGO: std_logic; -- sig vidéos des sprites
signal VINTRO: integer range 0 to 3; -- Valeur d'un pixel du sprite coloré d'intro
signal VINTRO2: std_logic;
signal X : integer range 0 to SCR_WIDTH_MAX; -- position courante du curseur
signal Y : integer range 0 to SCR_HEIGHT_MAX; --
signal BLANK: std_logic; -- signal de blanc vidéo
signal X_MIN_2 : integer range 0 to SCR_WIDTH_MAX; -- coord X de l'ombre du score
signal Y_MIN_2 : integer range 0 to SCR_HEIGHT_MAX; -- coord Y de l'ombre du score
signal EN_TITRE : std_logic;

--------------------------------------------------------------------------------
-- Composants (déclaration)
--------------------------------------------------------------------------------
component video_score is 
	Port(
		SCORE : in integer range 0 to N_SCORE_MAX;
		X : in integer range 0 to SCR_WIDTH_MAX;
		Y : in integer range 0 to SCR_HEIGHT_MAX;
		VS : out std_logic
	);
end component;
--------------------------------------------------------------------------------
component CTRL_VGA is
	Port(
		CLK: in std_logic;
		VSYNC, BLANK, HSYNC: out std_logic;
		X : out integer range 0 to SCR_WIDTH_MAX;
		Y : out integer range 0 to SCR_HEIGHT_MAX
	);
end component;
--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------
-- Positionnement des sprites
--------------------------------------------------------------------------------
X_MIN_2 <= X - 2;
Y_MIN_2 <= Y - 2;
EN_TITRE <= '1' when X>=X_DEB_BR and X<X_FIN_BR and Y<Y_DEB_TITRE+33 else '0';

-- Image d'intro
VINTRO <= SPRITE_INTRO(Y-Y_DEB_INTRO)((X-X_DEB_INTRO)/2)
	when X>=X_DEB_INTRO and X<=X_DEB_INTRO+142*2 and Y>=Y_DEB_INTRO and Y<=Y_DEB_INTRO+314
	else 1;
-- Contour de l'image d'intro
VINTRO2 <= '1'
	when X>=X_DEB_INTRO-7 and X<X_DEB_INTRO+142*2+7 and Y>=Y_DEB_INTRO-7 and Y<Y_DEB_INTRO+314+7
	and not (X>=X_DEB_INTRO-5 and X<X_DEB_INTRO+142*2+5 and Y>=Y_DEB_INTRO-5 and Y<Y_DEB_INTRO+314+5)
	else '0';
-- Titre
VT <= SPRITE_TITRE(Y-Y_DEB_TITRE)((X-X_DEB_TITRE)/2)
	when X>=X_DEB_TITRE and X<X_DEB_TITRE+118*2 and Y>=Y_DEB_TITRE and Y<Y_DEB_TITRE+28
	else '0';
-- Viseur actif (dans la zone de tir)
VV <= SPRITE_VISEUR(Y-YV)(X-XV)
	when X>=XV and X<XV+32 and Y>=YV and Y<YV+32
	else '0';
-- Viseur inactif (en dehors de la zone de tir)
VVO <= SPRITE_VISEUR_OUT(Y-YV)(X-XV)
	when ((X>=XV and X<=XV+31 and Y>=YV and Y<=YV+31) and ((X<X_DEB_BG or X>X_FIN_BG or Y<Y_DEB_BG-1 or Y>Y_FIN_BG+1) or EN_INTRO='1'))
	else '0';
-- Mickey
VL <= SPRITE_MICKEY(Y-YL)(X-XL)
	when X>=XL and X<=XL+61 and Y>=YL and Y<=YL+58
	else '0';
-- Contours de la Barre de rapidité
VR <= '1'
	when ((X>=X_DEB_BR and X<=X_FIN_BR and Y>=Y_DEB_BR and Y<=Y_FIN_BR)
	and not (X>=X_DEB_BR+2 and X<=X_FIN_BR-2 and Y>=Y_DEB_BR+1 and Y<=Y_FIN_BR-1)
	and not (X>=X_DEB_BR+8 and X<=X_DEB_BR+48 and Y>=Y_FIN_BR-1))
	or	(X=X_DEB_BR + (X_FIN_BR-X_DEB_BR)/4 and Y>=Y_DEB_BR and Y<=Y_DEB_BR+3)
	or (X=X_DEB_BR + (X_FIN_BR-X_DEB_BR)/2 and Y>=Y_DEB_BR and Y<=Y_DEB_BR+5)
	or (X=X_DEB_BR + 3*(X_FIN_BR-X_DEB_BR)/4 and Y>=Y_DEB_BR and Y<=Y_DEB_BR+3)
	else '0';
-- Barre de rapidité
VR2 <= '1'
	when (TIRS<N_TIRS_MAX and X>=X_DEB_BR+2 and Y>=Y_DEB_BR+1 and Y<=Y_FIN_BR-1)
	and (X <= X_DEB_BR+2 + ((X_FIN_BR-X_DEB_BR)*(TPS_CLIC-N_TIMER_MAX/4))/N_TIMER_MAX)
	else '0';
-- Texte de la barre de rapidité
VTB <= SPRITE_SCORE_ETAT(Y-Y_DEB_BR_TXT)(X-X_DEB_BR_TXT)
	when X>=X_DEB_BR_TXT and X<=X_DEB_BR_TXT+38 and Y>=Y_DEB_BR_TXT and Y<Y_DEB_BR_TXT+8
	else '0';
-- Texte du score
VTS <= SPRITE_SCORE_TXT(Y-Y_DEB_SCORE_TXT)(X-X_DEB_SCORE_TXT)
	when X>=X_DEB_SCORE_TXT and X<=X_DEB_SCORE_TXT+32 and Y>=Y_DEB_SCORE_TXT and Y<Y_DEB_SCORE_TXT+8
	else '0';
-- Texte de la pause
VP <= SPRITE_PAUSE(Y/8-Y_DEB_PAUSE)(X/8-X_DEB_PAUSE)
	when EN_PAUSE = '1' and X/8>=X_DEB_PAUSE and X/8<=X_DEB_PAUSE+28 and Y/8>=Y_DEB_PAUSE and Y/8<Y_DEB_PAUSE+8
	else '0';
-- Texte de Game Over
VGO <= SPRITE_GAME_OVER(Y/8-Y_DEB_GAME_OVER)(X/8-X_DEB_GAME_OVER)
	when EN_INTRO='0' and TIRS=N_TIRS_MAX
	and X/8>=X_DEB_GAME_OVER and X/8<=X_DEB_GAME_OVER+51 and Y/8>=Y_DEB_GAME_OVER and Y/8<Y_DEB_GAME_OVER+8
	else '0';
-- Balles
VB <= SPRITE_BALLE((Y-Y_DEB_BALLES) mod 16)(X-X_DEB_BALLES)
	when X>=X_DEB_BALLES and X<=X_DEB_BALLES+30 and Y>=Y_DEB_BALLES and Y<Y_DEB_BALLES+16*(N_TIRS_MAX-TIRS)
	else '0';
VB2<= SPRITE_BALLE((Y-Y_DEB_BALLES) mod 16)(X-X_DEB_BALLES)
	when X>=X_DEB_BALLES and X<=X_DEB_BALLES+30 and Y>=Y_DEB_BALLES+16*(N_TIRS_MAX-TIRS) and Y<Y_DEB_BALLES+16*N_TIRS_MAX
	else '0';
-- Chargeur
VC <= '1'
	when X>=X_DEB_CHARGEUR and X<=SCR_WIDTH and Y>=Y_DEB_CHARGEUR and Y<=Y_DEB_CHARGEUR+16*N_TIRS_MAX+5
	else '0';
-- Background (bordures)
VBG <= '1'
	when Y<Y_DEB_BG or X<=X_DEB_BG or (X>=X_FIN_BG and X<=SCR_WIDTH) or (Y>=Y_FIN_BG and Y<=SCR_HEIGHT)
	else '0';
-- Background2 (cadres)
VBG2 <= '1'
	when (X>=X_DEB_BG-1 and X<=X_FIN_BG+1 and Y>=Y_DEB_BG-1 and Y<=Y_DEB_BG+1)		-- bordures centrales
	or (X>=X_DEB_BG-1 and X<=X_DEB_BG+1 and Y>=Y_DEB_BG-1 and Y<=Y_FIN_BG+1)		-- bordures centrales
	or (X>=X_FIN_BG-1 and X<=X_FIN_BG+1 and Y>=Y_DEB_BG-1 and Y<=Y_FIN_BG+1)		-- bordures centrales
	or (X>=X_DEB_BG-1 and X<=X_FIN_BG+1 and Y>=Y_FIN_BG-1 and Y<=Y_FIN_BG+1)		-- bordures centrales
	or (X>=X_DEB_SCORE_BG-1 and X<=X_DEB_SCORE_BG and Y<=Y_DEB_SCORE_BG)				-- bordures du score
	or (X>=X_DEB_SCORE_BG-1 and X<=X_DEB_SCORE_BG+8 and Y=Y_DEB_SCORE_BG)			-- bordures du score
	or (X>=X_DEB_SCORE_BG+42 and Y=Y_DEB_SCORE_BG)											-- bordures du score
	or (X>=X_DEB_BR and X<=X_DEB_BR+1 and Y<=Y_DEB_TITRE+32)								-- bordures du titre
	or (X>=X_FIN_BR-1 and X<=X_FIN_BR and Y<=Y_DEB_TITRE+32)								-- bordures du titre
	or (X>=X_DEB_BR and X<=X_FIN_BR and Y>=Y_DEB_TITRE+32 and Y<=Y_DEB_TITRE+32+1)-- bordures du titre
	else '0';
--------------------------------------------------------------------------------
-- Composants (assignations)
--------------------------------------------------------------------------------
COMP_VIDEO_SCORE : video_score 
	Port map(
		SCORE => SCORE,
		X => X,
		Y => Y,
		VS => VS);
--------------------------------------------------------------------------------
COMP_VIDEO_SCORE_OMBRE: video_score 
	Port map(
		SCORE => SCORE,
		X => X_MIN_2,
		Y => Y_MIN_2,
		VS => VS2);
--------------------------------------------------------------------------------
COMP_CTRL_VGA : CTRL_VGA 
	Port map(
		CLK => CLK,
		VSYNC => VSYNC,
		BLANK => BLANK,
		HSYNC => HSYNC,
		X => X,
		Y => Y);
--------------------------------------------------------------------------------
-- Processus
--------------------------------------------------------------------------------
-- Impacts de balle
P_VI: process (X,Y,IMPACTS_X,IMPACTS_Y)
	variable VI_tmp : std_logic; -- variable temporaire
	variable posX : integer range 0 to 31;
	variable posY : integer range 0 to 31;
begin
	VI_tmp := '0';
	for I in 0 to N_TIRS_MAX-1 loop
		if X/2>=IMPACTS_X(I)-8 and X/2<IMPACTS_X(I)+8 and Y/2>=IMPACTS_Y(I)-8 and Y/2<IMPACTS_Y(I)+8 then
			posX := X-2*(IMPACTS_X(I)+8);
			posY := Y-2*(IMPACTS_Y(I)+8);
			if(IMPACTS_X(I) mod 2 = 1) then -- caractère aléatoire du choix du sprite
				VI_tmp := VI_tmp or SPRITE_IMPACT(posY)(posX);
			else
				VI_tmp := VI_tmp or SPRITE_IMPACT2(posY)(posX);
			end if;
		end if;
	end loop;
	VI <= VI_tmp;
end process P_VI;
--------------------------------------------------------------------------------
-- Affichage des signaux videos (sprites)
P_RVB: process (CLK,EN_INTRO,EN_PAUSE,TIRS)
begin
   if CLK'event and CLK = '1' then
		if BLANK = '1'       then RVB <= C_NOIR;
		elsif VP = '1' then RVB <= C_ROUGE;	-- Sprite de la pause
		elsif VGO= '1' then RVB <= C_ROUGE;	-- Sprite de Game Over
		elsif VVO= '1' then RVB <= C_VERT;	-- Sprite du viseur en dehors de la zone de tir
		elsif EN_INTRO='1'   then
			if VINTRO2='1' then RVB <= C_JAUNE;
			elsif VINTRO = 0  then RVB <= C_BLANC;
			elsif VINTRO = 1  then RVB <= C_NOIR;
			elsif VINTRO = 2  then RVB <= C_ROUGE;
			elsif VINTRO = 3  then RVB <= C_JAUNE;
			end if;
		elsif VTS= '1' then RVB <= C_BLEU;	-- Sprite de la barre d'état du score
		elsif VS = '1' then RVB <= C_ROUGE;	-- Sprite du score
		elsif VS2= '1' then RVB <= C_JAUNE;	-- Sprite de l'ombre du score
		elsif VB = '1' then RVB <= C_JAUNE;	-- Sprite d'une balle
		elsif VB2= '1' then RVB <= C_NOIR;	-- Sprite d'une balle utilisée
		elsif VC = '1' then RVB <= C_BLEU;	-- Sprite du chargeur
		elsif VTB= '1' then RVB <= C_BLEU;	-- Sprite du texte de la barre de rapidité
		elsif VR=  '1' then RVB <= C_BLEU;	-- Sprite de la barre de rapidité
		elsif VR2= '1' then RVB <= C_VERT;	-- Sprite de la barre de rapidité (2)
		elsif VBG2='1' then RVB <= C_BLEU;	-- Sprite du fond (cadre)
		elsif EN_TITRE='1' then					-- Sprite du titre
			if VT=  '1' then RVB <= C_NOIR;
			else             RVB <= C_BLANC;
			end if;
		elsif VBG= '1' then
			if TIRS < N_TIRS_MAX then
			                 RVB <= C_CYAN;	-- Sprite du fond
			else             RVB <= C_ROUGE;	-- Sprite du fond
			end if;
		elsif VV = '1' then RVB <= C_ROUGE;	-- Sprite du viseur
		elsif VL = '1' then						-- Sprite du Mickey
			if TIRS>=N_TIRS_MAX-1 then			--
				              RVB <= C_ROUGE;	--  > dernier niveau
			else RVB <= C_NOIR; end if;		--  > général
		elsif VI = '1' then RVB <= C_NOIR;	-- Sprite d'un impact
		else                RVB <= C_BLANC;	-- Reste = Zone de tir
		end if; 
   end if;
end process P_RVB;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Arch_DISPLAY;
